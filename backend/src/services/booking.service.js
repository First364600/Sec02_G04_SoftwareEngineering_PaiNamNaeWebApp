const prisma = require('../utils/prisma');
const ApiError = require('../utils/ApiError');
const { RouteStatus, BookingStatus } = require('@prisma/client');
const { checkAndApplyPassengerSuspension } = require('./penalty.service');

const ACTIVE_STATUSES = [BookingStatus.PENDING, BookingStatus.CONFIRMED];

const searchBookingsAdmin = async (opts = {}) => {
  const {
    page = 1,
    limit = 20,
    q,
    status,
    routeId,
    passengerId,
    driverId,
    createdFrom,
    createdTo,
    routeDepartureFrom,
    routeDepartureTo,
    sortBy = 'createdAt',
    sortOrder = 'desc',
  } = opts;

  const where = {
    ...(status && { status }),
    ...(routeId && { routeId }),
    ...(passengerId && { passengerId }),
    ...(createdFrom || createdTo ? {
      createdAt: {
        ...(createdFrom ? { gte: new Date(createdFrom) } : {}),
        ...(createdTo ? { lte: new Date(createdTo) } : {}),
      }
    } : {}),
    ...(driverId || routeDepartureFrom || routeDepartureTo || q ? {
      route: {
        ...(driverId ? { driverId } : {}),
        ...(routeDepartureFrom || routeDepartureTo ? {
          departureTime: {
            ...(routeDepartureFrom ? { gte: new Date(routeDepartureFrom) } : {}),
            ...(routeDepartureTo ? { lte: new Date(routeDepartureTo) } : {}),
          }
        } : {}),
        ...(q ? {
          OR: [
            { routeSummary: { contains: q, mode: 'insensitive' } },
            // ถ้าต้องการค้นทะเบียนรถ/รุ่นรถ
            {
              vehicle: {
                is: {
                  OR: [
                    { licensePlate: { contains: q, mode: 'insensitive' } },
                    { vehicleModel: { contains: q, mode: 'insensitive' } },
                    { vehicleType: { contains: q, mode: 'insensitive' } },
                  ]
                }
              }
            }
          ]
        } : {}),
      }
    } : {}),
    ...(q ? {
      OR: [
        {
          passenger: {
            is: {
              OR: [
                { firstName: { contains: q, mode: 'insensitive' } },
                { lastName: { contains: q, mode: 'insensitive' } },
                { email: { contains: q, mode: 'insensitive' } },
                { username: { contains: q, mode: 'insensitive' } },
              ]
            }
          }
        }
      ]
    } : {})
  };

  const skip = (page - 1) * limit;
  const take = limit;

  const [total, data] = await prisma.$transaction([
    prisma.booking.count({ where }),
    prisma.booking.findMany({
      where,
      orderBy: { [sortBy]: sortOrder },
      skip, take,
      include: {
        passenger: {
          select: { id: true, firstName: true, lastName: true, email: true, username: true, profilePicture: true }
        },
        route: {
          include: {
            driver: { select: { id: true, firstName: true, lastName: true, email: true, isVerified: true } },
            vehicle: { select: { licensePlate: true, vehicleModel: true, vehicleType: true } },
          }
        }
      }
    })
  ]);

  return {
    data,
    pagination: { page, limit, total, totalPages: Math.ceil(total / limit) }
  };
};

const adminCreateBooking = async (data) => {
  return prisma.$transaction(async (tx) => {
    const route = await tx.route.findUnique({ where: { id: data.routeId } });
    if (!route) throw new ApiError(404, 'Route not found');

    // ป้องกันการจองให้คนขับเอง
    if (route.driverId === data.passengerId) {
      throw new ApiError(400, 'Driver cannot book their own route.');
    }
    if (route.status !== RouteStatus.AVAILABLE) {
      throw new ApiError(400, 'This route is no longer available.');
    }
    if (route.availableSeats < data.numberOfSeats) {
      throw new ApiError(400, 'Not enough seats available on this route.');
    }

    const booking = await tx.booking.create({
      data: {
        routeId: data.routeId,
        passengerId: data.passengerId,
        numberOfSeats: data.numberOfSeats,
        pickupLocation: data.pickupLocation,
        dropoffLocation: data.dropoffLocation,
        // status: (default -> PENDING)
      },
    });

    const updatedRoute = await tx.route.update({
      where: { id: data.routeId },
      data: { availableSeats: { decrement: data.numberOfSeats } },
    });
    if (updatedRoute.availableSeats === 0) {
      await tx.route.update({ where: { id: data.routeId }, data: { status: RouteStatus.FULL } });
    }
    return booking;
  });
};

const adminUpdateBooking = async (id, patch) => {
  return prisma.$transaction(async (tx) => {
    const existing = await tx.booking.findUnique({
      where: { id }, include: { route: true }
    });
    if (!existing) throw new ApiError(404, 'Booking not found');

    // ค่าเป้าหมาย
    const targetStatus = patch.status ?? existing.status;
    const oldActive = ACTIVE_STATUSES.includes(existing.status);
    const newActive = ACTIVE_STATUSES.includes(targetStatus);
    const targetRouteId = patch.routeId ?? existing.routeId;
    const targetSeats = patch.numberOfSeats ?? existing.numberOfSeats;
    const targetPassengerId = patch.passengerId ?? existing.passengerId;

    // helper คืนที่นั่งให้ route
    const refundSeats = async (routeId, seats) => {
      const r = await tx.route.update({
        where: { id: routeId },
        data: { availableSeats: { increment: seats } },
      });
      if (r.status === RouteStatus.FULL && r.availableSeats > 0) {
        await tx.route.update({ where: { id: routeId }, data: { status: RouteStatus.AVAILABLE } });
      }
    };
    // helper จองที่นั่งจาก route (ตรวจเงื่อนไข)
    const reserveSeats = async (routeId, seats, passengerId) => {
      const r = await tx.route.findUnique({ where: { id: routeId } });
      if (!r) throw new ApiError(404, 'Route not found');
      if (r.driverId === passengerId) throw new ApiError(400, 'Driver cannot book their own route.');
      if (r.status !== RouteStatus.AVAILABLE) throw new ApiError(400, 'This route is no longer available.');
      if (r.availableSeats < seats) throw new ApiError(400, 'Not enough seats available on this route.');
      const updated = await tx.route.update({
        where: { id: routeId },
        data: { availableSeats: { decrement: seats } },
      });
      if (updated.availableSeats === 0) {
        await tx.route.update({ where: { id: routeId }, data: { status: RouteStatus.FULL } });
      }
    };

    // กรณีเปลี่ยน route/seats หรือเปลี่ยนสถานะระหว่าง active<->inactive
    // ขั้นตอน: ถ้าปัจจุบันถือครองที่นั่งอยู่ (active) → refund ก่อน
    if (oldActive) {
      await refundSeats(existing.routeId, existing.numberOfSeats);
    }
    // จากนั้น ถ้าปลายทางต้องถือครองที่นั่ง (newActive) → reserve ที่ route เป้าหมาย ด้วยจำนวนเป้าหมาย
    if (newActive) {
      await reserveSeats(targetRouteId, targetSeats, targetPassengerId);
    }

    // อัปเดตข้อมูล booking
    const updated = await tx.booking.update({
      where: { id },
      data: {
        routeId: targetRouteId,
        passengerId: targetPassengerId,
        numberOfSeats: targetSeats,
        pickupLocation: patch.pickupLocation ?? existing.pickupLocation,
        dropoffLocation: patch.dropoffLocation ?? existing.dropoffLocation,
        status: targetStatus,
      },
      include: { route: true, passenger: true }
    });
    return updated;
  });
};

const createBooking = async (data, passengerId) => {
  return prisma.$transaction(async (tx) => {

    const route = await tx.route.findUnique({
      where: { id: data.routeId },
    });

    if (!route) {
      throw new ApiError(404, 'Route not found');
    }

    if (route.driverId === passengerId) {
      throw new ApiError(400, 'Driver cannot book their own route.');
    }

    if (route.status !== RouteStatus.AVAILABLE) {
      throw new ApiError(400, 'This route is no longer available.');
    }
    if (route.availableSeats < data.numberOfSeats) {
      throw new ApiError(400, 'Not enough seats available on this route.');
    }

    const booking = await tx.booking.create({
      data: {
        routeId: data.routeId,
        passengerId,
        numberOfSeats: data.numberOfSeats,
        pickupLocation: data.pickupLocation,
        dropoffLocation: data.dropoffLocation,
      },
    });

    const updatedRoute = await tx.route.update({
      where: { id: data.routeId },
      data: {
        availableSeats: {
          decrement: data.numberOfSeats,
        },
      },
    });

    if (updatedRoute.availableSeats === 0) {
      await tx.route.update({
        where: { id: data.routeId },
        data: { status: RouteStatus.FULL },
      });
    }

    return booking;
  });
};

const getMyBookings = async (passengerId) => {
  return prisma.booking.findMany({
    where: { passengerId },
    include: {
      route: {
        include: {
          driver: {
            select: {
              id: true,
              firstName: true,
              lastName: true,
              gender: true,
              profilePicture: true,
              isVerified: true
            }
          },
          vehicle: {
            select: {
              vehicleModel: true,
              vehicleType: true,
              photos: true,
              amenities: true
            }
          }
        }
      }

    },
    orderBy: { createdAt: 'desc' },
  });
};

const getBookingById = async (id) => {
  return prisma.booking.findUnique({
    where: { id },
    include: { route: true, passenger: true },
  });
};

const updateBookingStatus = async (id, status, userId) => {
  const booking = await prisma.booking.findUnique({
    where: { id },
    include: { route: true },
  });
  if (!booking) throw new ApiError(404, 'Booking not found');
  if (booking.route.driverId !== userId) {
    throw new ApiError(403, 'Forbidden');
  }

  return prisma.$transaction(async (tx) => {
    const updated = await tx.booking.update({
      where: { id },
      data: { status },
    });

    if (status === BookingStatus.REJECTED) {
      // คืนที่นั่งให้ route
      const refunded = booking.numberOfSeats;
      const newSeats = booking.route.availableSeats + refunded;
      const routeUpdates = { availableSeats: newSeats };
      if (booking.route.status === RouteStatus.FULL && newSeats > 0) {
        routeUpdates.status = RouteStatus.AVAILABLE;
      }
      await tx.route.update({
        where: { id: booking.route.id },
        data: routeUpdates,
      });
    }
    return updated;
  });
};

const cancelBooking = async (id, passengerId, opts = {}) => {
  const { reason } = opts;

  const booking = await prisma.booking.findUnique({
    where: { id },
    include: { route: true },
  });
  if (!booking) throw new ApiError(404, 'Booking not found');
  if (booking.passengerId !== passengerId) throw new ApiError(403, 'Forbidden');
  if (![BookingStatus.PENDING, BookingStatus.CONFIRMED].includes(booking.status)) {
    throw new ApiError(400, 'Cannot cancel at this stage');
  }

  const wasConfirmed = booking.status === BookingStatus.CONFIRMED;

  const updated = await prisma.$transaction(async (tx) => {
    const updatedBooking = await tx.booking.update({
      where: { id },
      data: {
        status: BookingStatus.CANCELLED,
        cancelledAt: new Date(),
        cancelledBy: 'PASSENGER',
        cancelReason: reason || null,
      },
    });

    // คืนที่นั่งให้เส้นทาง (เดิม)
    const refunded = booking.numberOfSeats;
    const newSeats = booking.route.availableSeats + refunded;
    const routeUpdates = { availableSeats: newSeats };
    if (booking.route.status === RouteStatus.FULL && newSeats > 0) {
      routeUpdates.status = RouteStatus.AVAILABLE;
    }
    await tx.route.update({
      where: { id: booking.route.id },
      data: routeUpdates,
    });

    if (wasConfirmed) {
      await tx.notification.create({
        data: {
          userId: passengerId,
          type: 'SYSTEM',
          title: 'บันทึกการยกเลิกหลังยืนยัน',
          body: 'คุณได้ยกเลิกการจองที่เคยได้รับการยืนยันแล้ว',
          metadata: { kind: 'PASSENGER_CONFIRMED_CANCEL', bookingId: id },
        },
      });
    }

    return updatedBooking;
  });

  if (wasConfirmed) {
    await checkAndApplyPassengerSuspension(passengerId, { confirmedOnly: true });
  }

  return updated;
};

const deleteBooking = async (id, userId) => {
  const booking = await prisma.booking.findUnique({
    where: { id },
    include: { route: true },
  });
  if (!booking) throw new ApiError(404, 'Booking not found');
  // if (booking.status !== BookingStatus.REJECTED) {
  //   throw new ApiError(400, 'Only cancelled/rejected bookings can be deleted');
  // }
  if (![BookingStatus.CANCELLED, BookingStatus.REJECTED].includes(booking.status)) {
    throw new ApiError(400, 'Only cancelled or rejected bookings can be deleted');
  }
  if (
    booking.passengerId !== userId &&
    booking.route.driverId !== userId
  ) {
    throw new ApiError(403, 'Forbidden');
  }
  await prisma.booking.delete({ where: { id } });
  return { id };
};

const adminDeleteBooking = async (id) => {
  const booking = await prisma.booking.findUnique({
    where: { id },
    include: { route: true },
  });
  if (!booking) throw new ApiError(404, 'Booking not found');

  // แอดมินลบได้ทุกสถานะ แต่ถ้าเป็น PENDING/CONFIRMED ให้คืนที่นั่งให้เส้นทางด้วย
  return prisma.$transaction(async (tx) => {
    if (booking.route) {
      if (booking.status === BookingStatus.PENDING || booking.status === BookingStatus.CONFIRMED) {
        const refunded = booking.numberOfSeats;
        const newSeats = booking.route.availableSeats + refunded;

        const routeUpdates = { availableSeats: newSeats };
        // ถ้า route เคย FULL แล้วคืนที่นั่ง ทำให้กลับเป็น AVAILABLE
        if (booking.route.status === RouteStatus.FULL && newSeats > 0) {
          routeUpdates.status = RouteStatus.AVAILABLE;
        }
        await tx.route.update({
          where: { id: booking.route.id },
          data: routeUpdates,
        });
      }
    }

    await tx.booking.delete({ where: { id } });
    return { id };
  });
};

module.exports = {
  searchBookingsAdmin,
  adminCreateBooking,
  createBooking,
  adminUpdateBooking,
  adminCreateBooking,
  getMyBookings,
  getBookingById,
  updateBookingStatus,
  cancelBooking,
  deleteBooking,
  adminDeleteBooking
};
