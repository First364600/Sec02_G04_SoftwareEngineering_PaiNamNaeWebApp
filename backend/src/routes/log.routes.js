// routes/log.routes.js
const express = require('express');
const router = express.Router();
const logController = require('../controllers/logController');
const { authenticateToken, isAdmin } = require('../middlewares/auth');

// GET /api/logs
router.get('/', protect, requireAdmin, logController.getLogs);

module.exports = router;