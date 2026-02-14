// routes/log.routes.js
const express = require('express');
const router = express.Router();
const logController = require('../controllers/logController');
const { protect, requireAdmin } = require('../middlewares/auth');

// GET /api/logs
router.get('/', protect, requireAdmin, logController.getLogs);

// GET /api/logs/export
router.get('/', protect, requireAdmin, logController.getLogs);
router.get('/export', protect, requireAdmin, logController.exportLogs);

module.exports = router;