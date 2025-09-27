const express = require('express');
const validate = require('../middlewares/validate');
const upload = require('../middlewares/upload.middleware');
const { protect, requireAdmin } = require('../middlewares/auth');
const driverVerifController = require('../controllers/driverVerification.controller');
const {
  idParamSchema,
  createDriverVerificationSchema,
  updateDriverVerificationSchema,
  updateVerificationStatusSchema,
  listDriverVerifsQuerySchema,
} = require('../validations/driverVerification.validation');

const router = express.Router();

// --- Admin routes ---
// GET /driver-verifications
router.get(
  '/',
  protect,
  requireAdmin,
  validate({ query: listDriverVerifsQuerySchema }),
  driverVerifController.adminListVerifications
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
  // upload.single('licensePhotoUrl'),
  upload.fields([
    { name: 'licensePhotoUrl', maxCount: 1 },
    { name: 'selfiePhotoUrl', maxCount: 1 }
  ]),
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
module.exports = router;
