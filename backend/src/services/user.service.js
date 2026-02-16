const prisma = require("../utils/prisma");
const ApiError = require('../utils/ApiError');
const bcrypt = require("bcrypt");
const SALT_ROUNDS = 10;
//const prisma = new PrismaClient();

const searchUsers = async (opts = {}) => {
    const {
        page = 1,
        limit = 20,
        q,
        role,
        isActive,
        isVerified,
        createdFrom,
        createdTo,
        sortBy = 'createdAt',
        sortOrder = 'desc',
    } = opts;

    const where = {
        ...(role && { role }),
        ...(typeof isActive === 'boolean' ? { isActive } : {}),
        ...(typeof isVerified === 'boolean' ? { isVerified } : {}),
        ...((createdFrom || createdTo) ? {
            createdAt: {
                ...(createdFrom ? { gte: new Date(createdFrom) } : {}),
                ...(createdTo ? { lte: new Date(createdTo) } : {}),
            }
        } : {}),
        ...(q ? {
            OR: [
                { email: { contains: q, mode: 'insensitive' } },
                { username: { contains: q, mode: 'insensitive' } },
                { firstName: { contains: q, mode: 'insensitive' } },
                { lastName: { contains: q, mode: 'insensitive' } },
                { phoneNumber: { contains: q, mode: 'insensitive' } },
            ]
        } : {}),
    };

    const skip = (page - 1) * limit;
    const take = limit;

    const [total, dataRaw] = await prisma.$transaction([
        prisma.user.count({ where }),
        prisma.user.findMany({
            where,
            orderBy: { [sortBy]: sortOrder },
            skip, take,
            select: {
                id: true, email: true, username: true,
                firstName: true, lastName: true, gender: true,
                phoneNumber: true, profilePicture: true,
                role: true, isVerified: true, isActive: true,
                createdAt: true, updatedAt: true,
            }
        })
    ]);

    return {
        data: dataRaw,
        pagination: {
            page,
            limit,
            total,
            totalPages: Math.ceil(total / limit),
        }
    };
};

const getUserByEmail = async (email) => {
    return await prisma.user.findUnique({ where: { email } })
}

const getUserByUsername = async (username) => {
    return await prisma.user.findUnique({ where: { username } })
}

const comparePassword = async (user, plainPassword) => {
    return bcrypt.compare(plainPassword, user.password);
};

const getAllUsers = async () => {
    const users = await prisma.user.findMany({
        where: {
            isActive: true
        }
    })

    // หรือจะสร้าง object ใหม่แบบนี้ก็ได้ (ปลอดภัยกว่า)
    /*
    const safeUsers = users.map(user => ({
      id: user.id,
      email: user.email,
      username: user.username,
      // ... เอาฟิลด์อื่นๆ ที่ต้องการมาใส่ ...
    }));
    */

    return users.map(user => {
        const { password, ...safeUser } = user;
        return safeUser;
    });
}

const getUserById = async (id) => {
    const user = await prisma.user.findUnique({ where: { id } })

    if (!user) {
        throw new ApiError(404, 'User not found');
    }

    const { password, ...safeUser } = user;
    return safeUser
}

const getUserPublicById = async (id) => {
    const user = await prisma.user.findUnique({
        where: { id },
        select: {
            id: true, firstName: true, lastName: true,
            profilePicture: true, role: true, isVerified: true,
            createdAt: true
        }
    });
    if (!user) throw new ApiError(404, 'User not found');
    return user;
};

// const getMyUser = async (id) => {
//     const user = await prisma.user.findUnique({ where: { id } })

//     if (!user) {
//         return null;
//     }

//     const { password, ...safeUser } = user;
//     return safeUser
// }

const createUser = async (data) => {
    const existingUserByEmail = await getUserByEmail(data.email);
    if (existingUserByEmail) {
        throw new ApiError(409, "This email is already in use.");
    }
    const existingUserByUsername = await getUserByUsername(data.username);
    if (existingUserByUsername) {
        throw new ApiError(409, "This username is already taken.");
    }
    const hashedPassword = await bcrypt.hash(data.password, SALT_ROUNDS);

    const createData = {
        email: data.email,
        username: data.username,
        password: hashedPassword,
        firstName: data.firstName,
        lastName: data.lastName,
        phoneNumber: data.phoneNumber,
        gender: data.gender,
        nationalIdNumber: data.nationalIdNumber,
        nationalIdExpiryDate: new Date(data.nationalIdExpiryDate), // แปลง string เป็น Date object
        nationalIdPhotoUrl: data.nationalIdPhotoUrl, // URL จาก Cloudinary
        selfiePhotoUrl: data.selfiePhotoUrl, // URL จาก Cloudinary
        role: data.role || 'PASSENGER'
    };

    const user = await prisma.user.create({ data: createData });

    const { password, ...safeUser } = user;
    return safeUser;
}

const updatePassword = async (userId, currentPassword, newPassword) => {
    const userWithPassword = await prisma.user.findUnique({ where: { id: userId } });

    if (!userWithPassword) {
        return { success: false, error: 'USER_NOT_FOUND' };
    }

    const isPasswordCorrect = await bcrypt.compare(currentPassword, userWithPassword.password);

    if (!isPasswordCorrect) {
        return { success: false, error: 'INCORRECT_PASSWORD' };
    }

    const hashedNewPassword = await bcrypt.hash(newPassword, SALT_ROUNDS);

    await prisma.user.update({
        where: { id: userId },
        data: { password: hashedNewPassword },
    });

    return { success: true };
};

const updateUserProfile = async (id, data) => {
    const updatedUser = await prisma.user.update({ where: { id }, data });

    const { password, ...safeUser } = updatedUser;
    return safeUser;
};

const deleteUser = async (id) => {
    const deletedUser = await prisma.user.delete({ where: { id } });

    const { password, ...safeDeletedUser } = deletedUser;
    return safeDeletedUser;
};

const requestDeleteAccount = async (userId, ipAddress, userAgent) => {
    // ตรวจสอบว่า user มีอยู่
    const user = await prisma.user.findUnique({ where: { id: userId } });
    if (!user) {
        throw new ApiError(404, 'User not found');
    }

    // คำนวณวันที่สำหรับการลบอัตโนมัติ (90 วันหลังจากวันนี้)
    const scheduledDeletionDate = new Date();
    scheduledDeletionDate.setDate(scheduledDeletionDate.getDate() + 90);

    // สร้าง record ใน DeleteAccountRequest และ deactivate account พร้อมกัน
    const [deleteRequest] = await prisma.$transaction([
        prisma.deleteAccountRequest.create({
            data: {
                userId: userId,
                state: 'PENDING',
                ipAddress: ipAddress,
                userAgent: userAgent,
                scheduledDeletionDate: scheduledDeletionDate,
            },
        }),
        // Deactivate account ทันทีเพื่อไม่ให้ login ได้
        prisma.user.update({
            where: { id: userId },
            data: { isActive: false },
        }),
    ]);

    return {
        id: deleteRequest.id,
        message: 'Delete account request has been submitted. Your account will be deleted on ' + scheduledDeletionDate.toLocaleDateString('th-TH'),
        scheduledDeletionDate: scheduledDeletionDate,
    };
};

// ฟังก์ชันสำหรับลบบัญชีที่ครบกำหนดแล้ว (ควรเรียกจาก scheduler/cron job)
const processScheduledDeletions = async () => {
    const now = new Date();

    // ค้นหา DeleteAccountRequest ที่ถึงเวลาลบแล้ว
    const expiredRequests = await prisma.deleteAccountRequest.findMany({
        where: {
            state: 'PENDING',
            scheduledDeletionDate: {
                lte: now,
            },
        },
    });

    for (const request of expiredRequests) {
        try {
            // ลบข้อมูล user
            await prisma.user.delete({
                where: { id: request.userId },
            });

            // อัปเดต state เป็น COMPLETED
            await prisma.deleteAccountRequest.update({
                where: { id: request.id },
                data: {
                    state: 'COMPLETED',
                    completedAt: now,
                },
            });

            console.log(`✓ User ${request.userId} deleted successfully`);
        } catch (error) {
            console.error(`✗ Error deleting user ${request.userId}:`, error.message);
        }
    }

    return expiredRequests.length;
};

// const setUserStatusActive = async (id, isActive) => {
//     const updatedUser = await prisma.user.update({
//         where: { id },
//         data: { isActive: isActive },
//     });

//     const { password, ...safeUser } = updatedUser;
//     return safeUser;
// };

// const setUserStatusVerified = async (id, isVerified) => {
//     const updatedUser = await prisma.user.update({
//         where: { id },
//         data: { isVerified: isVerified },
//     });

//     const { password, ...safeUser } = updatedUser;
//     return safeUser;
// };

//เพิ่ม Export Full User Data 
const exportFullUserData = async (userId) => {

    if (!userId) {
    console.error("Error: exportFullUserData received undefined userId");
    throw new Error("UserId is required to fetch data");
  }

  return await prisma.user.findUnique({
    where: { id: userId },
    include: {
      vehicles: true,
      createdRoutes: { include: { vehicle: true } },
      bookings: { include: { route: true } },
      driverVerification: true,
      notification: { take: 20, orderBy: { createdAt: 'desc' } }
    }
  });
};

module.exports = {
    searchUsers,
    getAllUsers,
    getUserById,
    createUser,
    getUserByEmail,
    getUserByUsername,
    comparePassword,
    updatePassword,
    deleteUser,
    requestDeleteAccount,
    processScheduledDeletions,
    updateUserProfile,
    getUserPublicById,
    exportFullUserData,//เพิ่มตรงนี้ด้วยสำหรับฟังก์ชันส่งออกข้อมูลผู้ใช้แบบเต็มรูปแบบ
};