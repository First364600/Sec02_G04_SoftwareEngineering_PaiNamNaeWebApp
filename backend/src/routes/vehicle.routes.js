const express = require('express');
const validate = require('../middlewares/validate');
const vehicleController = require('../controllers/vehicle.controller');
const { idParamSchema, createVehicleSchema, updateVehicleSchema } = require('../validations/vehicle.validation');
const { protect } = require('../middlewares/auth');

const router = express.Router();

// GET /api/vehicles
router.get(
  '/',
  protect,
  vehicleController.getVehicles
);

// GET /api/vehicles/:id
router.get(
  '/:id',
   protect,
  validate({ params: idParamSchema }),
  vehicleController.getVehicleById
);

// POST /api/vehicles
router.post(
  '/',
   protect,
  validate({ body: createVehicleSchema }),
  vehicleController.createVehicle
);

// PUT /api/vehicles/:id
router.put(
  '/:id',
    protect,
  validate({ params: idParamSchema, body: updateVehicleSchema }),
  vehicleController.updateVehicle
);

// DELETE /api/vehicles/:id
router.delete(
  '/:id',
   protect,
  validate({ params: idParamSchema }),
  vehicleController.deleteVehicle
);

// PUT /api/vehicles/:id/default
router.put(
  '/:id/default',
    protect,
  validate({ params: idParamSchema }),
  vehicleController.setDefaultVehicle
);

module.exports = router;