const express = require('express');
const userController = require("../controllers/user.controller");
const validate = require('../middlewares/validate');
const upload = require('../middlewares/upload.middleware');
const { idParamSchema, createUserSchema, updateUserSchema, updateUserStatusSchema } = require('../validations/user.validation');
const { protect, requireAdmin } = require('../middlewares/auth');

const router = express.Router();

// --- Admin Routes ---
router.get(
    '/admin',
    protect,
    requireAdmin,
    userController.getAllUsers
);
router.put(
    '/admin/users/:id',
    protect,
    requireAdmin,
    validate({ params: idParamSchema, body: updateUserSchema }),
    userController.adminUpdateUser
);
router.delete(
    '/admin/:id',
    protect,
    requireAdmin,
    validate({ params: idParamSchema }),
    userController.adminDeleteUser
);
router.patch(
    '/admin/:id/status',
    protect,
    requireAdmin,
    validate({ params: idParamSchema, body: updateUserStatusSchema }),
    userController.setUserStatus

);

// --- Public / User-specific Routes ---
router.get(
    '/:id',
    validate({ params: idParamSchema }),
    userController.getUserById
);
router.post(
        '/',
        upload.fields([
            { name: 'nationalIdPhotoUrl', maxCount: 1 },
            { name: 'selfiePhotoUrl', maxCount: 1 }
        ]),
        validate({ body: createUserSchema }),
        userController.createUser
    );
router.put(
    '/me',
    protect,
    validate({ body: updateUserSchema }),
    userController.updateCurrentUserProfile
);

module.exports = router;