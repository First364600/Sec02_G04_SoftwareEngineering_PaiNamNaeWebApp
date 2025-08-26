const express = require('express');
const userController = require("../controllers/user.controller");
const validate = require('../middlewares/validate');
const upload = require('../middlewares/upload.middleware');
const { idParamSchema, createUserSchema, updateUserSchema, updateUserStatusSchema } = require('../validations/user.validation');
const { protect, requireAdmin } = require('../middlewares/auth');

const router = express.Router();

// --- Admin Routes ---
// GET /api/users/admin
router.get(
    '/admin',
    protect,
    requireAdmin,
    userController.getAllUsers
);

// PUT /api/users/admin/:id
router.put(
    '/admin/users/:id',
    protect,
    requireAdmin,
    validate({ params: idParamSchema, body: updateUserSchema }),
    userController.adminUpdateUser
);

// DELETE /api/admin/users/:id
router.delete(
    '/admin/users/:id',
    protect,
    requireAdmin,
    validate({ params: idParamSchema }),
    userController.adminDeleteUser
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
    userController.getUserById
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
    validate({ body: updateUserSchema }),
    userController.updateCurrentUserProfile
);

module.exports = router;