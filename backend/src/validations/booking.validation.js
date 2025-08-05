const { z } = require('zod');
const { BookingStatus } = require('@prisma/client');

const createBookingSchema = z.object({
  routeId: z.string().cuid({ message: 'Invalid route ID format' }),
  numberOfSeats: z.number().int().min(1, 'At least 1 seat must be booked'),
  pickupLocation: z.any(),
  dropoffLocation: z.any(),
});

const idParamSchema = z.object({
  id: z.string().cuid({ message: 'Invalid booking ID format' }),
});

const updateBookingStatusSchema = z.object({
  status: z.nativeEnum(BookingStatus, {
    required_error: 'Status is required',
    invalid_type_error: 'Invalid status value',
  }),
});

module.exports = {
  createBookingSchema,
  idParamSchema,
  updateBookingStatusSchema,
};
