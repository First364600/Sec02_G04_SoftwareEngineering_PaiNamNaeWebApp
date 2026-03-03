const prisma = require("../utils/prisma");
const { LogType } = require("@prisma/client");
const asyncHandler = require("express-async-handler");
const bookingService = require("../services/booking.service");
const ApiError = require("../utils/ApiError");

const adminListBookings = asyncHandler(async (req, res) => {
  const result = await bookingService.searchBookingsAdmin(req.query);
  res.status(200).json({ success: true, message: 'Bookings (admin) retrieved', ...result });
});

const adminCreateBooking = asyncHandler(async (req, res) => {
  const booking = await bookingService.adminCreateBooking(req.body);
  res.status(201).json({ success: true, data: booking });
});

const adminUpdateBooking = asyncHandler(async (req, res) => {
  const { id } = req.params;
  const updated = await bookingService.adminUpdateBooking(id, req.body);
  await prisma.systemLog.create({
  data: {
    userId: driverId,
    bookingId: updated.id,
    routeId: updated.routeId,
    logType: LogType.TRANSACTION,
    action: "UPDATE_BOOKING_STATUS",
    method: req.method,
    endpoint: req.originalUrl,
    statusCode: 200,
    ipAddress: req.ip,
    userAgent: req.headers["user-agent"]
  }
});
  res.status(200).json({ success: true, data: updated });
});

const createBooking = asyncHandler(async (req, res) => {
  const passengerId = req.user.sub;
  const payload = {
    routeId: req.body.routeId,
    numberOfSeats: req.body.numberOfSeats,
    pickupLocation: req.body.pickupLocation,
    dropoffLocation: req.body.dropoffLocation,
  };

  const booking = await bookingService.createBooking(payload, passengerId);
  await prisma.systemLog.create({
    data: {
      userId: passengerId,
      bookingId: booking.id,
      routeId: booking.routeId,
      logType: LogType.TRANSACTION,
      action: "CREATE_BOOKING",
      method: req.method,
      endpoint: req.originalUrl,
      statusCode: 201,
      ipAddress: req.ip,
      userAgent: req.headers["user-agent"]
    }
  });
  res.status(201).json({ success: true, data: booking });
});

const getMyBookings = asyncHandler(async (req, res) => {
  const passengerId = req.user.sub;
  const list = await bookingService.getMyBookings(passengerId);
  res.status(200).json({ success: true, data: list });
});

const adminGetBookingById = asyncHandler(async (req, res) => {
  const { id } = req.params

  const booking = await bookingService.getBookingById(id);
  if (!booking) throw new ApiError(404, 'Booking not found');

  res.status(200).json({ success: true, data: booking });
})

const getBookingById = asyncHandler(async (req, res) => {
  const { id } = req.params;
  const booking = await bookingService.getBookingById(id);
  if (!booking) throw new ApiError(404, 'Booking not found');

  const userId = req.user.sub;
  if (
    booking.passengerId !== userId &&
    booking.route.driverId !== userId
  ) {
    throw new ApiError(403, 'Forbidden');
  }

  res.status(200).json({ success: true, data: booking });
});

const updateBookingStatus = asyncHandler(async (req, res) => {
  const driverId = req.user.sub;
  const { id } = req.params;
  const { status } = req.body;

  const updated = await bookingService.updateBookingStatus(
    id,
    status,
    driverId
  );
  res.status(200).json({ success: true, data: updated });
});

const cancelBooking = asyncHandler(async (req, res) => {
  const passengerId = req.user.sub;
  const { id } = req.params;
  const { reason } = req.body;

  const cancelled = await bookingService.cancelBooking(id, passengerId, { reason });
  await prisma.systemLog.create({
  data: {
    userId: passengerId,
    bookingId: cancelled.id,
    routeId: cancelled.routeId,
    logType: LogType.TRANSACTION,
    action: "CANCEL_BOOKING",
    method: req.method,
    endpoint: req.originalUrl,
    statusCode: 200,
    ipAddress: req.ip,
    userAgent: req.headers["user-agent"]
  }
});
  res.status(200).json({ success: true, data: cancelled });
});

const deleteBooking = asyncHandler(async (req, res) => {
  const userId = req.user.sub;
  const { id } = req.params;
  const deleted = await bookingService.deleteBooking(id, userId);
  res.status(200).json({ success: true, data: deleted });
});

const adminDeleteBooking = asyncHandler(async (req, res) => {
  const { id } = req.params;
  const result = await bookingService.adminDeleteBooking(id);
  res.status(200).json({ success: true, data: result });
});

// คนขับกดรับผู้โดยสาร → แจ้ง passenger ว่าคนขับมาถึง
const driverArrivedPickup = asyncHandler(async (req, res) => {
  const driverId = req.user.sub;
  const { id } = req.params; // booking id

  const booking = await bookingService.getBookingById(id);
  if (!booking) throw new ApiError(404, 'Booking not found');
  if (booking.route.driverId !== driverId) throw new ApiError(403, 'Forbidden');

  // อัพเดต passengerStatus เป็น WAITING_PICKUP
  const updated = await prisma.booking.update({
    where: { id },
    data: { passengerStatus: 'WAITING_PICKUP' }
  });

  // ส่ง Notification ไปหาผู้โดยสาร
  await prisma.notification.create({
    data: {
      userId: booking.passengerId,
      type: 'BOOKING',
      title: 'คนขับมาถึงจุดรับคุณแล้ว!',
      body: `คนขับได้มาถึงจุดรับของคุณแล้ว กรุณากดเริ่มต้นการเดินทางเพื่อยืนยัน`,
      link: `/my-trips`,
      metadata: { bookingId: id, routeId: booking.routeId }
    }
  });

  res.status(200).json({ success: true, data: updated });
});

// ผู้โดยสารกดเริ่มต้นการเดินทาง
const passengerStartTrip = asyncHandler(async (req, res) => {
  const passengerId = req.user.sub;
  const { id } = req.params;

  const booking = await bookingService.getBookingById(id);
  if (!booking) throw new ApiError(404, 'Booking not found');
  if (booking.passengerId !== passengerId) throw new ApiError(403, 'Forbidden');
  if (booking.passengerStatus !== 'WAITING_PICKUP') {
    throw new ApiError(400, 'ไม่สามารถเริ่มการเดินทางได้ในขณะนี้');
  }

  const updated = await prisma.booking.update({
    where: { id },
    data: { passengerStatus: 'IN_TRANSIT' }
  });

  // แจ้งคนขับ
  await prisma.notification.create({
    data: {
      userId: booking.route.driverId,
      type: 'BOOKING',
      title: 'ผู้โดยสารขึ้นรถแล้ว',
      body: `คุณ ${booking.passenger.firstName} ได้ยืนยันการเดินทางแล้ว`,
      link: `/my-route`,
      metadata: { bookingId: id, routeId: booking.routeId }
    }
  });

  res.status(200).json({ success: true, data: updated });
});

// ผู้โดยสารปฏิเสธการรับ
const passengerRejectPickup = asyncHandler(async (req, res) => {
  const passengerId = req.user.sub;
  const { id } = req.params;

  const booking = await bookingService.getBookingById(id);
  if (!booking) throw new ApiError(404, 'Booking not found');
  if (booking.passengerId !== passengerId) throw new ApiError(403, 'Forbidden');

  const updated = await prisma.booking.update({
    where: { id },
    data: { passengerStatus: 'REJECTED_PICKUP' }
  });

  // แจ้งคนขับ
  await prisma.notification.create({
    data: {
      userId: booking.route.driverId,
      type: 'BOOKING',
      title: 'ผู้โดยสารปฏิเสธการรับ',
      body: `คุณ ${booking.passenger.firstName} ได้ปฏิเสธการรับผู้โดยสารของคุณ กรุณาติดต่อผู้โดยสาร`,
      link: `/my-route`,
      metadata: { bookingId: id, routeId: booking.routeId }
    }
  });

  res.status(200).json({ success: true, data: updated });
});

// คนขับขอยกเลิกการเดินทาง
const driverRequestCancel = asyncHandler(async (req, res) => {
  const driverId = req.user.sub;
  const { id } = req.params;

  const booking = await bookingService.getBookingById(id);
  if (!booking) throw new ApiError(404, 'Booking not found');
  if (booking.route.driverId !== driverId) throw new ApiError(403, 'Forbidden');

  const updated = await prisma.booking.update({
    where: { id },
    data: { driverCancelRequest: true }
  });

  // แจ้งผู้โดยสาร
  await prisma.notification.create({
    data: {
      userId: booking.passengerId,
      type: 'BOOKING',
      title: 'คนขับแจ้งขอยกเลิกการเดินทาง',
      body: `คนขับขอยกเลิกการเดินทางของคุณ กรุณาติดต่อคนขับ`,
      link: `/my-trips`,
      metadata: { bookingId: id, routeId: booking.routeId }
    }
  });

  res.status(200).json({ success: true, data: updated });
});

// ผู้โดยสารยืนยันยกเลิก
const passengerConfirmCancel = asyncHandler(async (req, res) => {
  const passengerId = req.user.sub;
  const { id } = req.params;

  const booking = await bookingService.getBookingById(id);
  if (!booking) throw new ApiError(404, 'Booking not found');
  if (booking.passengerId !== passengerId) throw new ApiError(403, 'Forbidden');

  const updated = await prisma.booking.update({
    where: { id },
    data: {
      status: 'CANCELLED',
      passengerStatus: 'CANCELLED',
      cancelledAt: new Date(),
      cancelledBy: passengerId,
      driverCancelRequest: false
    }
  });

  // แจ้งคนขับ
  await prisma.notification.create({
    data: {
      userId: booking.route.driverId,
      type: 'BOOKING',
      title: 'ยืนยันการยกเลิก',
      body: `คุณ ${booking.passenger.firstName} ได้ยืนยันการยกเลิกการเดินทางแล้ว`,
      link: `/my-route`,
      metadata: { bookingId: id, routeId: booking.routeId }
    }
  });

  res.status(200).json({ success: true, data: updated });
});

// ผู้โดยสารปฏิเสธการยกเลิก
const passengerRejectCancel = asyncHandler(async (req, res) => {
  const passengerId = req.user.sub;
  const { id } = req.params;

  const booking = await bookingService.getBookingById(id);
  if (!booking) throw new ApiError(404, 'Booking not found');
  if (booking.passengerId !== passengerId) throw new ApiError(403, 'Forbidden');

  const updated = await prisma.booking.update({
    where: { id },
    data: { driverCancelRequest: false }
  });

  // แจ้งคนขับ
  await prisma.notification.create({
    data: {
      userId: booking.route.driverId,
      type: 'BOOKING',
      title: 'ผู้โดยสารปฏิเสธการยกเลิกการเดินทาง',
      body: `คุณ ${booking.passenger.firstName} ปฏิเสธการยกเลิกการเดินทาง กรุณาติดต่อผู้โดยสาร`,
      link: `/my-route`,
      metadata: { bookingId: id, routeId: booking.routeId }
    }
  });

  res.status(200).json({ success: true, data: updated });
});

//  คนขับถึงจุดส่งของผู้โดยสาร
const driverReachedDropoff = asyncHandler(async (req, res) => {
  const driverId = req.user.sub;
  const { id } = req.params;

  const booking = await bookingService.getBookingById(id);
  if (!booking) throw new ApiError(404, 'Booking not found');
  if (booking.route.driverId !== driverId) throw new ApiError(403, 'Forbidden');

  const updated = await prisma.booking.update({
    where: { id },
    data: { reachedDropoff: true }
  });

  // แจ้งผู้โดยสาร
  await prisma.notification.create({
    data: {
      userId: booking.passengerId,
      type: 'BOOKING',
      title: 'ถึงจุดหมายของคุณแล้ว!',
      body: `คนขับได้นำส่งคุณถึงจุดหมายแล้ว กรุณากดสิ้นสุดการเดินทาง`,
      link: `/my-trips`,
      metadata: { bookingId: id, routeId: booking.routeId }
    }
  });

  res.status(200).json({ success: true, data: updated });
});

const getMyTripStatus = asyncHandler(async (req, res) => {
    const passengerId = req.user.sub

    // ดึงแค่ field ที่จำเป็นสำหรับ polling 
    const bookings = await prisma.booking.findMany({
        where: { 
            passengerId,
            status: 'CONFIRMED' // เฉพาะที่ confirmed เท่านั้น
        },
        select: {
            id: true,
            passengerStatus: true,
            driverCancelRequest: true,
            reachedDropoff: true,
            status: true,
            route: {
                select: {
                    id: true,
                    status: true,
                    currentStep: true
                }
            }
        }
    })

    res.status(200).json({ success: true, data: bookings })
})

module.exports = {
  adminListBookings,
  createBooking,
  getMyBookings,
  getBookingById,
  updateBookingStatus,
  cancelBooking,
  deleteBooking,
  adminGetBookingById,
  adminCreateBooking,
  adminUpdateBooking,
  adminDeleteBooking,
  driverArrivedPickup,
  passengerStartTrip,
  passengerRejectPickup,
  driverRequestCancel,
  passengerConfirmCancel,
  passengerRejectCancel,
  driverReachedDropoff,
  getMyTripStatus
};
