const prisma = require('../utils/prisma');
const ApiError = require('../utils/ApiError');

const getAllVehicles = async (userId) => {
  return prisma.vehicle.findMany({
    where: { userId },
    orderBy: { createdAt: 'desc' },
  });
};

const getVehicleById = async (id) => {
  const vehicle = await prisma.vehicle.findUnique({ where: { id } });
  if (!vehicle) {
    throw new ApiError(404, 'Vehicle not found');
  }
  return vehicle;
};

const createVehicle = async (data, userId) => {
  if (data.isDefault) {
    // reset previous default
    await prisma.vehicle.updateMany({
      where: { userId, isDefault: true },
      data: { isDefault: false },
    });
  }
  return prisma.vehicle.create({
    data: { ...data, userId },
  });
};

const updateVehicle = async (id, data) => {
  if (data.isDefault) {
    const existing = await getVehicleById(id);
    await prisma.vehicle.updateMany({
      where: { userId: existing.userId, isDefault: true },
      data: { isDefault: false },
    });
  }
  try {
    return await prisma.vehicle.update({
      where: { id },
      data,
    });
  } catch (err) {
    if (err.code === 'P2025') {
      throw new ApiError(404, 'Vehicle not found');
    }
    throw err;
  }
};

const deleteVehicle = async (id) => {
  await getVehicleById(id); // will throw if not found
  await prisma.vehicle.delete({ where: { id } });
  return { id };
};

module.exports = {
  getAllVehicles,
  getVehicleById,
  createVehicle,
  updateVehicle,
  deleteVehicle,
};
