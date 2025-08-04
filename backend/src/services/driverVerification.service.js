const prisma = require('../utils/prisma');

const getVerificationByUser = async (userId) => {
  return prisma.driverVerification.findUnique({
    where: { userId },
    include: { user: true },
  });
};

const getAllVerifications = async () => {
  return prisma.driverVerification.findMany({
    include: { user: true },
    orderBy: { createdAt: 'desc' },
  });
};

const getVerificationById = async (id) => {
  return prisma.driverVerification.findUnique({
    where: { id },
    include: { user: true },
  });
};

const createVerification = async (data) => {
  return prisma.driverVerification.create({ data });
};

const updateVerification = async (id, data) => {
  return prisma.driverVerification.update({
    where: { id },
    data,
  });
};

const updateVerificationStatus = async (id, status) => {
  return prisma.driverVerification.update({
    where: { id },
    data: { status },
  });
};

module.exports = {
  getVerificationByUser,
  getAllVerifications,
  getVerificationById,
  createVerification,
  updateVerification,
  updateVerificationStatus,
};
