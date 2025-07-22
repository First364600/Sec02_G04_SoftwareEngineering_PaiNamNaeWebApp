const express = require('express');
const authRoutes = require('./auth.routes');
const userRoutes = require('./user.routes');

const router = express.Router();

router.use('/auth', authRoutes);
router.use('/', userRoutes); // User routes will be at /api/users, /api/admin/users etc.


module.exports = router;