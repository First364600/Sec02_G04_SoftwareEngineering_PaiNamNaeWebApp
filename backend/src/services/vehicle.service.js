const prisma = require('../utils/prisma');
const ApiError = require('../utils/ApiError');

const getAllVehicles = async (userId) => {
  return prisma.vehicle.findMany({
    where: { userId },
    orderBy: { createdAt: 'desc' },
  });
};

const getVehicleById = async (vehicleId, userId) => {
  const vehicle = await prisma.vehicle.findUnique({ where: { id: vehicleId, userId } });
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

// const updateVehicle = async (id, data) => {
//   if (data.isDefault) {
//     const existing = await getVehicleById(id);
//     await prisma.vehicle.updateMany({
//       where: { userId: existing.userId, isDefault: true },
//       data: { isDefault: false },
//     });
//   }
//   try {
//     return await prisma.vehicle.update({
//       where: { id },
//       data,
//     });
//   } catch (err) {
//     if (err.code === 'P2025') {
//       throw new ApiError(404, 'Vehicle not found');
//     }
//     throw err;
//   }
// };

const updateVehicle = async (vehicleId, userId, updateData) => {
  const existingVehicle = await prisma.vehicle.findFirst({
    where: { id: vehicleId, userId },
  });
  if (!existingVehicle) {
    throw new Error("Vehicle not found or access denied");
  }

  if (updateData.isDefault === true && !existingVehicle.isDefault) {
    await prisma.vehicle.updateMany({
      where: { userId, isDefault: true, NOT: { id: vehicleId } },
      data: { isDefault: false },
    });
  }

  return prisma.vehicle.update({
    where: { id: vehicleId },
    data: updateData,
  });
};

// const deleteVehicle = async (id) => {
//   await getVehicleById(id); // will throw if not found
//   await prisma.vehicle.delete({ where: { id } });
//   return { id };
// };

const deleteVehicle = async (vehicleId, userId) => {
  const existingVehicle = await prisma.vehicle.findFirst({
    where: { id: vehicleId, userId }
  })
  if (!existingVehicle) {
    throw new Error("Vehicle not found or access denied");
  }

  await prisma.vehicle.delete({ where: { id: vehicleId } });
  return { id: vehicleId };
};

const setDefaultVehicle = async (vehicleId, userId) => {
  const vehicleToSetDefault = await prisma.vehicle.findFirst({
    where: { id: vehicleId, userId },
  });
  if (!vehicleToSetDefault) {
    throw new Error("Vehicle not found or access denied");
  }

  if (vehicleToSetDefault.isDefault) {
    return vehicleToSetDefault;
  }

  return prisma.$transaction(async (tx) => {
    await tx.vehicle.updateMany({
      where: { userId, isDefault: true },
      data: { isDefault: false },
    });
    const updatedVehicle = await tx.vehicle.update({
      where: { id: vehicleId },
      data: { isDefault: true },
    });
    return updatedVehicle;
  });
};

const getVehicleByIdAdmin = async (vehicleId) => {
  const v = await prisma.vehicle.findUnique({ where: { id: vehicleId } });
  if (!v) throw new ApiError(404, 'Vehicle not found');
  return v;
};

const updateVehicleByAdmin = async (vehicleId, updateData) => {
  const existing = await getVehicleByIdAdmin(vehicleId);

  const targetUserId = updateData.userId ?? existing.userId;

  return prisma.$transaction(async (tx) => {
    // ถ้าจะตั้ง default ให้คันนี้ → reset คันอื่นของเจ้าของเป้าหมาย
    if (updateData.isDefault === true) {
      await tx.vehicle.updateMany({
        where: { userId: targetUserId, isDefault: true, NOT: { id: vehicleId } },
        data: { isDefault: false },
      });
    }

    const updated = await tx.vehicle.update({
      where: { id: vehicleId },
      data: {
        ...updateData,
        userId: targetUserId,
      },
    });

    return updated;
  });
};

const deleteVehicleByAdmin = async (vehicleId) => {
  await getVehicleByIdAdmin(vehicleId);
  await prisma.vehicle.delete({ where: { id: vehicleId } });
  return { id: vehicleId };
};

module.exports = {
  getAllVehicles,
  getVehicleById,
  createVehicle,
  updateVehicle,
  deleteVehicle,
  setDefaultVehicle,
  getVehicleByIdAdmin,
  updateVehicleByAdmin,
  deleteVehicleByAdmin
};
