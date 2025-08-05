const express = require('express');
const validate = require('../middlewares/validate');
const upload   = require('../middlewares/upload.middleware');
const { protect, requireAdmin } = require('../middlewares/auth');
const driverVerifController = require('../controllers/driverVerification.controller');
const {
  idParamSchema,
  createDriverVerificationSchema,
  updateDriverVerificationSchema,
  updateVerificationStatusSchema,
} = require('../validations/driverVerification.validation');

const router = express.Router();

// --- Driver routes ---
// GET /driver-verifications/me
router.get(
  '/me',
  protect,
  driverVerifController.getMyVerification
);

// POST /driver-verifications
router.post(
  '/',
  protect,
  upload.single('licensePhotoUrl'),
  validate({ body: createDriverVerificationSchema }),
  driverVerifController.createVerification
);

// PUT /driver-verifications/:id
router.put(
  '/:id',
  protect,
  upload.single('licensePhotoUrl'),
  validate({ params: idParamSchema, body: updateDriverVerificationSchema }),
  driverVerifController.updateVerification
);

// --- Admin routes ---
// GET /driver-verifications
router.get(
  '/',
  protect,
  requireAdmin,
  driverVerifController.getAllVerifications
);

// GET /driver-verifications/:id
router.get(
  '/:id',
  protect,
  requireAdmin,
  validate({ params: idParamSchema }),
  driverVerifController.getVerificationById
);

// PATCH /driver-verifications/:id/status
router.patch(
  '/:id/status',
  protect,
  requireAdmin,
  validate({ params: idParamSchema, body: updateVerificationStatusSchema }),
  driverVerifController.updateVerificationStatus
);

module.exports = router;
