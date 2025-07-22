const express = require('express');
const validate = require('../middlewares/validate');
const vehicleController = require('../controllers/vehicle.controller');
const { idParamSchema, createVehicleSchema, updateVehicleSchema } = require('../validations/vehicle.validation');
const { protect } = require('../middlewares/auth');

const router = express.Router();

router.get(
  '/',
  protect,
  vehicleController.getVehicles
);

router.get(
  '/:id',
   protect,
  validate({ params: idParamSchema }),
  vehicleController.getVehicleById
);

router.post(
  '/',
   protect,
  validate({ body: createVehicleSchema }),
  vehicleController.createVehicle
);

router.put(
  '/:id',
    protect,
  validate({ params: idParamSchema, body: updateVehicleSchema }),
  vehicleController.updateVehicle
);

router.delete(
  '/:id',
   protect,
  validate({ params: idParamSchema }),
  vehicleController.deleteVehicle
);

module.exports = router;