const asyncHandler = require('express-async-handler');
const { PrismaClient } = require('@prisma/client');
const ApiError = require('../utils/ApiError');
const prisma = new PrismaClient();

const requireDriverVerified = asyncHandler(async (req, res, next) => {
    const driverId = req.user.sub;
    const dv = await prisma.driverVerification.findUnique({
        where: { userId: driverId }
    });
    if (!dv || dv.status !== 'APPROVED') {
        throw new ApiError(403, 'คุณต้องยืนยันตัวตนผู้ขับก่อนจึงจะดำเนินการนี้ได้');
    }
    next();
});

module.exports = requireDriverVerified;
