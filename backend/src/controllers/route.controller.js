const asyncHandler = require("express-async-handler");
const routeService = require("../services/route.service");
const vehicleService = require("../services/vehicle.service");
const ApiError = require("../utils/ApiError");

const getAllRoutes = asyncHandler(async (req, res) => {
  const routes = await routeService.getAllRoutes();
  res.status(200).json({
    success: true,
    data: routes,
  });
});

const getRouteById = asyncHandler(async (req, res) => {
  const route = await routeService.getRouteById(req.params.id);
  if (!route) {
    throw new ApiError(404, "Route not found");
  }
  res.status(200).json({
    success: true,
    data: route,
  });
});

const createRoute = asyncHandler(async (req, res) => {
  const driverId = req.user.sub;
  const { vehicleId, ...routeFields } = req.body;

  await vehicleService.getVehicleById(vehicleId, driverId);

  const payload = {
    ...routeFields,
    driverId,
    vehicleId,
    departureTime: new Date(routeFields.departureTime),
  };

  const newRoute = await routeService.createRoute(payload);
  res.status(201).json({ success: true, data: newRoute });
});

const updateRoute = asyncHandler(async (req, res) => {
  const driverId = req.user.sub;
  const { id } = req.params;
  const { vehicleId, ...routeFields } = req.body;

  const existing = await routeService.getRouteById(id);
  if (!existing) throw new ApiError(404, "Route not found");
  if (existing.driverId !== driverId) throw new ApiError(403, "Forbidden");

  // await vehicleService.getVehicleById(vehicleId, driverId);
  let newVehicleId = existing.vehicleId;
  if (vehicleId) {
    await vehicleService.getVehicleById(vehicleId, driverId);
    newVehicleId = vehicleId;
  }
  const payload = {
    ...routeFields,
    vehicleId: newVehicleId,
    ...(routeFields.departureTime && {
      departureTime: new Date(routeFields.departureTime),
    }),
  };

  const updated = await routeService.updateRoute(id, payload);
  res.status(200).json({ success: true, data: updated });
});

const deleteRoute = asyncHandler(async (req, res) => {
  const driverId = req.user.sub;
  const { id } = req.params;

  const existing = await routeService.getRouteById(id);
  if (!existing) throw new ApiError(404, "Route not found");
  if (existing.driverId !== driverId) throw new ApiError(403, "Forbidden");

  const result = await routeService.deleteRoute(id);
  res.status(200).json({
    success: true,
    message: "Route deleted",
    data: result
  });
});

module.exports = {
  getAllRoutes,
  getRouteById,
  createRoute,
  updateRoute,
  deleteRoute,
};
