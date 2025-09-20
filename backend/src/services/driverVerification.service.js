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
  const existing = await getVerificationByUser(data.userId)
  if (existing) {
    return updateVerification(existing.id, data)
  }

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
  const updatePayload = {
    ...data,
    status: 'PENDING'
  };
  return prisma.driverVerification.update({
    where: { id },
    data: updatePayload,
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
        data: { isVerified: true, role: 'DRIVER' },
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
          driverId: verification.userId,
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

const isDriverApproved = async (userId) => {
  const rec = await prisma.driverVerification.findUnique({
    where: { userId },
    select: { status: true },
  });
  return rec?.status === 'APPROVED';
};

module.exports = {
  getVerificationByUser,
  getAllVerifications,
  getVerificationById,
  createVerification,
  updateVerification,
  updateVerificationStatus,
  isDriverApproved
};
