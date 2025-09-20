const express = require("express");
const validate = require("../middlewares/validate");
const { protect } = require("../middlewares/auth");
const requireDriverVerified = require('../middlewares/driverVerified');
const routeController = require("../controllers/route.controller");
const {
  idParamSchema,
  createRouteSchema,
  updateRouteSchema,
  createRouteByAdminSchema,
  updateRouteByAdminSchema,
} = require("../validations/route.validation");

const router = express.Router();

// GET /routes
router.get("/", routeController.getAllRoutes);

// GET /routes/me
router.get(
  "/me",
  protect,
  routeController.getMyRoutes
);

// GET /routes/:id
router.get(
  "/:id",
  validate({ params: idParamSchema }),
  routeController.getRouteById
);

// POST /routes
router.post(
  "/",
  protect,
  requireDriverVerified,
  validate({ body: createRouteSchema }),
  routeController.createRoute
);

// PUT /routes/:id
router.put(
  "/:id",
  protect,
  requireDriverVerified,
  validate({ params: idParamSchema, body: updateRouteSchema }),
  routeController.updateRoute
);

// DELETE /routes/:id
router.delete(
  "/:id",
  protect,
  requireDriverVerified,
  validate({ params: idParamSchema }),
  routeController.deleteRoute
);

// --- Admin Routes ---
// POST /routes/admin
router.post(
  "/admin",
  protect,
  requireAdmin,
  validate({ body: createRouteByAdminSchema }),
  routeController.adminCreateRoute
);

// PUT /routes/admin/:id
router.put(
  "/admin/:id",
  protect,
  requireAdmin,
  validate({ params: idParamSchema, body: updateRouteByAdminSchema }),
  routeController.adminUpdateRoute
);

// DELETE /routes/admin/:id
router.delete(
  "/admin/:id",
  protect,
  requireAdmin,
  validate({ params: idParamSchema }),
  routeController.adminDeleteRoute
);
module.exports = router;
