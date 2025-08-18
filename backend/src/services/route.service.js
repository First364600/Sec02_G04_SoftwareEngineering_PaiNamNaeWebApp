const prisma = require('../utils/prisma');

const getAllRoutes = async () => {
  return prisma.route.findMany({
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
    },
    orderBy: { createdAt: 'desc' }
  });
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
              profilePicture: true
            }
          }
        }
      },
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
  getRouteById,
  getMyRoutes,
  createRoute,
  updateRoute,
  deleteRoute
};
