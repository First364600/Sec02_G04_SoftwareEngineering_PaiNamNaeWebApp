const express = require("express");
const validate = require("../middlewares/validate");
const { protect } = require("../middlewares/auth");
const requireDriverVerified = require('../middlewares/driverVerified');
const routeController = require("../controllers/route.controller");
const {
  idParamSchema,
  createRouteSchema,
  updateRouteSchema,
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

module.exports = router;
