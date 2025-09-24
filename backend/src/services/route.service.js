const prisma = require('../utils/prisma');

const baseInclude = {
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
};

const getAllRoutes = async () => {
  return prisma.route.findMany({
    include: baseInclude,
    orderBy: { createdAt: 'desc' }
  });
};

const searchRoutes = async (opts) => {
  const {
    page = 1,
    limit = 20,
    q,
    status,
    driverId,
    vehicleId,
    dateFrom,
    dateTo,
    sortBy = 'createdAt',
    sortOrder = 'desc',
  } = opts || {};

  const where = {
    ...(status && { status }),
    ...(driverId && { driverId }),
    ...(vehicleId && { vehicleId }),
    ...(dateFrom || dateTo ? {
      departureTime: {
        ...(dateFrom ? { gte: new Date(dateFrom) } : {}),
        ...(dateTo ? { lte: new Date(dateTo) } : {}),
      }
    } : {}),
    ...(q ? {
      OR: [
        { routeSummary: { contains: q, mode: 'insensitive' } },
        { conditions: { contains: q, mode: 'insensitive' } },
        // ค้นในความสัมพันธ์ด้วย (ชื่อคนขับ / รุ่นรถ / ประเภท / ทะเบียน ถ้ามีใน model อื่น)
        {
          driver: {
            is: {
              OR: [
                { firstName: { contains: q, mode: 'insensitive' } },
                { lastName: { contains: q, mode: 'insensitive' } },
              ]
            }
          }
        },
        {
          vehicle: {
            is: {
              OR: [
                { vehicleModel: { contains: q, mode: 'insensitive' } },
                { vehicleType: { contains: q, mode: 'insensitive' } },
                // ถ้าต้องการค้นทะเบียน ให้ดึงจาก vehicle.licensePlate (มี @unique)
                { licensePlate: { contains: q, mode: 'insensitive' } },
              ]
            }
          }
        },
      ]
    } : {}),
  };

  const skip = (page - 1) * limit;
  const take = limit;

  const [total, data] = await prisma.$transaction([
    prisma.route.count({ where }),
    prisma.route.findMany({
      where,
      include: baseInclude,
      orderBy: { [sortBy]: sortOrder },
      skip, take,
    })
  ]);

  return {
    data,
    pagination: {
      page,
      limit,
      total,
      totalPages: Math.ceil(total / limit),
    }
  };
};

const getRouteById = async (id) => {
  return prisma.route.findUnique({
    where: { id },
    include: {
      bookings: {
        include: {
          passenger: {
            select: {
              id: true,
              firstName: true,
              lastName: true,
              profilePicture: true
            }
          }
        }
      },
      ...baseInclude
    },
  });
};

const getMyRoutes = async (driverId) => {
  return prisma.route.findMany({
    where: {
      driverId
    },
    include: {

      bookings: {
        include: {
          passenger: {
            select: {
              id: true,
              firstName: true,
              lastName: true,
              profilePicture: true,
              isVerified: true,
              email: true
            }
          }
        }
      },
      ...baseInclude
    },

    orderBy: { createdAt: 'desc' },
  })
}

const createRoute = async (data) => {
  return prisma.route.create({ data });
};

const updateRoute = async (id, data) => {
  return prisma.route.update({
    where: { id },
    data
  });
};

const deleteRoute = async (id) => {
  await prisma.route.delete({
    where: { id }
  });
  return { id }
};

module.exports = {
  getAllRoutes,
  searchRoutes,
  getRouteById,
  getMyRoutes,
  createRoute,
  updateRoute,
  deleteRoute
};
