const express = require('express');
const userController = require("../controllers/user.controller");
const validate = require('../middlewares/validate');
const upload = require('../middlewares/upload.middleware');
const { idParamSchema, createUserSchema, updateMyProfileSchema, updateUserByAdminSchema, updateUserStatusSchema, listUsersQuerySchema } = require('../validations/user.validation');
const { protect, requireAdmin } = require('../middlewares/auth');

const router = express.Router();

// --- Admin Routes ---

// GET /api/admin/logs
router.get('/logs', async (req, res) => {
    try {
        // ดึง Log ล่าสุด 100 รายการ
        const result = await db.query('SELECT * FROM system_logs ORDER BY created_at DESC LIMIT 100');
        
        // ส่งข้อมูลกลับไปเป็น JSON
        res.status(200).json(result.rows);
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server Error' });
    }
});

// GET /api/users/admin
router.get(
    '/admin',
    protect,
    requireAdmin,
    validate({ query: listUsersQuerySchema }),
    userController.adminListUsers
);

// PUT /api/users/admin/:id
router.put(
    '/admin/:id',
    protect,
    requireAdmin,
    upload.fields([
        { name: 'nationalIdPhotoUrl', maxCount: 1 },
        { name: 'selfiePhotoUrl', maxCount: 1 },
        { name: 'profilePicture', maxCount: 1 },
    ]),
    validate({ params: idParamSchema, body: updateUserByAdminSchema }),
    userController.adminUpdateUser
);

// DELETE /api/users/admin/:id
router.delete(
    '/admin/:id',
    protect,
    requireAdmin,
    validate({ params: idParamSchema }),
    userController.adminDeleteUser
);

// GET /api/users/admin/:id
router.get(
    '/admin/:id',
    protect,
    requireAdmin,
    validate({ params: idParamSchema }),
    userController.getUserById
);

// PATCH /api/users/admin/:id/status
router.patch(
    '/admin/:id/status',
    protect,
    requireAdmin,
    validate({ params: idParamSchema, body: updateUserStatusSchema }),
    userController.setUserStatus
);

// --- Public / User-specific Routes ---
// GET /api/users/me
router.get(
    '/me',
    protect,
    userController.getMyUser
);

// GET /api/users/:id
router.get(
    '/:id',
    validate({ params: idParamSchema }),
    userController.getUserPublicById
);

// POST /api/users
router.post(
    '/',
    upload.fields([
        { name: 'nationalIdPhotoUrl', maxCount: 1 },
        { name: 'selfiePhotoUrl', maxCount: 1 }
    ]),
    validate({ body: createUserSchema }),
    userController.createUser
);

// PUT /api/users/me
router.put(
    '/me',
    protect,
    upload.fields([
        { name: 'nationalIdPhotoUrl', maxCount: 1 },
        { name: 'selfiePhotoUrl', maxCount: 1 },
        { name: 'profilePicture', maxCount: 1 },
    ]),
    validate({ body: updateMyProfileSchema }),
    userController.updateCurrentUserProfile
);

module.exports = router;