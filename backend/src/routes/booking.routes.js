const express = require('express');
const validate = require('../middlewares/validate');
const { protect } = require('../middlewares/auth');
const requireDriverVerified = require('../middlewares/driverVerified');
const bookingController = require('../controllers/booking.controller');
const {
  createBookingSchema,
  idParamSchema,
  updateBookingStatusSchema,
} = require('../validations/booking.validation');

const router = express.Router();

// GET /bookings/me
router.get(
  '/me',
  protect,
  bookingController.getMyBookings
);

// GET /bookings/:id
router.get(
  '/:id',
  protect,
  validate({ params: idParamSchema }),
  bookingController.getBookingById
);

// POST /bookings
router.post(
  '/',
  protect,
  validate({ body: createBookingSchema }),
  bookingController.createBooking
);

// PATCH /bookings/:id/status
router.patch(
  '/:id/status',
  protect,
  requireDriverVerified,
  validate({ params: idParamSchema, body: updateBookingStatusSchema }),
  bookingController.updateBookingStatus
);

// PATCH /bookings/:id/cancel
router.patch(
  '/:id/cancel',
  protect,
  validate({ params: idParamSchema }),
  bookingController.cancelBooking
);

// DELETE /bookings/:id
router.delete(
  '/:id',
  protect,
  validate({ params: idParamSchema }),
  bookingController.deleteBooking
);

module.exports = router;
