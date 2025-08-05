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
  return prisma.$transaction(async (tx) => {
    const newRec = await tx.driverVerification.create({ data });
    await tx.user.update({
      where: { id: data.userId },
      data: { role: 'DRIVER' },
    });
    return newRec;
  });
};

const updateVerification = async (id, data) => {
  return prisma.driverVerification.update({
    where: { id },
    data,
  });
};

const updateVerificationStatus = async (id, status) => {
  return prisma.$transaction(async (tx) => {
    const verification = await tx.driverVerification.update({
      where: { id },
      data: { status },
    });
    if (status === 'APPROVED') {
      await tx.user.update({
        where: { id: verification.userId },
        data: { isVerified: true },
      });
    }
    else if (status === 'REJECTED') {
      await tx.user.update({
        where: { id: verification.userId },
        data: {
          role: 'PASSENGER',
          isVerified: false,
        },
      });

      await tx.route.updateMany({
        where: {
          driverId: userId,
          status: 'AVAILABLE',
        },
        data: {
          status: 'CANCELLED',
        },
      });
    }
    return verification;
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
