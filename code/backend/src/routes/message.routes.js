const express = require('express');
const router = express.Router();
const { protect } = require('../middlewares/auth');
const requireDriverVerified = require('../middlewares/driverVerified');
const ctrl = require('../controllers/message.controller');

// Push subscription
router.post('/push/subscribe', protect, ctrl.subscribePush);

// Preset list
router.get('/presets', protect, ctrl.getPresets);

// Driver — ส่ง message
router.post('/route/:routeId', protect, requireDriverVerified, ctrl.sendMessage);

// Driver — ดู messages + replies ทั้งหมดของ route
router.get('/route/:routeId', protect, ctrl.getRouteMessages);

// Driver — unread replies count
router.get('/route/:routeId/unread-count', protect, ctrl.getUnreadRepliesCount);

// Passenger — ดู messages ที่เกี่ยวกับตัวเอง
router.get('/booking/:bookingId', protect, ctrl.getBookingMessages);

// Passenger — reply
router.post('/:messageId/reply', protect, ctrl.replyMessage);

module.exports = router;