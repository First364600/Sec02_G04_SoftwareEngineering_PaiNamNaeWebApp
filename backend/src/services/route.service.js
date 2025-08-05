const prisma = require('../utils/prisma');

const getAllRoutes = async () => {
  return prisma.route.findMany({
    include: { bookings: true },
  });
};

const getRouteById = async (id) => {
  return prisma.route.findUnique({
    where: { id },
    include: { bookings: true }
  });
};

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
  return {id}
};

module.exports = {
  getAllRoutes,
  getRouteById,
  createRoute,
  updateRoute,
  deleteRoute
};
