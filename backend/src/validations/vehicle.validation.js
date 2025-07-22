const { z } = require('zod')

const createVehicleSchema = z.object({
  vehicleModel: z.string().min(1, 'vehicleModel is required'),
  licensePlate: z.string().min(1, 'licensePlate is required'),
  vehicleType:  z.string().min(1, 'vehicleType is required'),
  color:        z.string().min(1, 'color is required'),
  seatCapacity: z.number().int({ message: 'seatCapacity must be an integer' }),
  amenities:    z.array(z.string().min(1, 'Each amenity must be a non-empty string')),
  photos:       z.array(z.string().url('Each photo must be a valid URL')).optional(),
  isDefault:    z.boolean().optional(),
});

const idParamSchema = z.object({
  id: z.string().cuid({ message: 'Invalid vehicle ID format' }),
});

const updateVehicleSchema = createVehicleSchema.partial();

module.exports = {
  idParamSchema,
  createVehicleSchema,
  updateVehicleSchema,
};