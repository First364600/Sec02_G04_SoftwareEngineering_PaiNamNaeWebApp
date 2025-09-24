const asyncHandler = require("express-async-handler");
const routeService = require("../services/route.service");
const vehicleService = require("../services/vehicle.service");
const ApiError = require("../utils/ApiError");
const verifService = require("../services/driverVerification.service");

const getAllRoutes = asyncHandler(async (req, res) => {
  const routes = await routeService.getAllRoutes();
  res.status(200).json({
    success: true,
    message: "Routes retrieved successfully",
    data: routes,
  });
});

const listRoutes = asyncHandler(async (req, res) => {
  const result = await routeService.searchRoutes(req.query);
  res.status(200).json({
    success: true,
    message: "Routes retrieved successfully",
    ...result,
  });
});

const adminListRoutes = asyncHandler(async (req, res) => {
  const result = await routeService.searchRoutes(req.query);
  res.status(200).json({
    success: true,
    message: "Routes (admin) retrieved successfully",
    ...result,
  });
});

const getRouteById = asyncHandler(async (req, res) => {
  const route = await routeService.getRouteById(req.params.id);
  if (!route) {
    throw new ApiError(404, "Route not found");
  }
  res.status(200).json({
    success: true,
    message: "Route retrieved successfully",
    data: route,
  });
});

const getMyRoutes = asyncHandler(async (req, res) => {
  const driverId = req.user.sub
  const list = await routeService.getMyRoutes(driverId)
  res.status(200).json({
    success: true,
    message: "Route retrieved successfully",
    data: list
  })
})

const adminGetRoutesByDriver = asyncHandler(async (req, res) => {
  const { driverId } = req.params
  const list = await routeService.getMyRoutes(driverId)
  res.status(200).json({
    success: true,
    message: "retrieved successfully",
    data: list
  })
})

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
  res.status(201).json({
    success: true,
    message: "Route created successfully",
    data: newRoute
  });
});

const updateRoute = asyncHandler(async (req, res) => {
  const driverId = req.user.sub;
  const { id } = req.params;
  const { vehicleId, ...routeFields } = req.body;

  const existing = await routeService.getRouteById(id);
  if (!existing) throw new ApiError(404, "Route not found");
  if (existing.driverId !== driverId) throw new ApiError(403, "Forbidden");

  if (existing.status === 'CANCELLED') {
    throw new ApiError(400, "ไม่สามารถแก้ไขเส้นทางที่ถูกยกเลิกได้");
  }

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
  res.status(200).json({
    success: true,
    message: "Route updated successfully",
    data: updated
  });
});

const deleteRoute = asyncHandler(async (req, res) => {
  const driverId = req.user.sub;
  const { id } = req.params;

  const existing = await routeService.getRouteById(id);
  if (!existing) throw new ApiError(404, "Route not found");
  if (existing.driverId !== driverId) throw new ApiError(403, "Forbidden");

  if (existing.status === 'CANCELLED') {
    throw new ApiError(400, "ไม่สามารถลบเส้นทางที่ถูกยกเลิกได้");
  }
  const result = await routeService.deleteRoute(id);
  res.status(200).json({
    success: true,
    message: "Route deleted successfully",
    data: result
  });
});

const adminCreateRoute = asyncHandler(async (req, res) => {
  const { driverId, vehicleId, ...routeFields } = req.body;

  const approved = await verifService.canCreateRoutes(driverId);
  if (!approved) {
    throw new ApiError(400, "ไม่สามารถสร้างเส้นทางให้ไดรเวอร์ที่ยังไม่ได้ยืนยันตัวตน (ต้องมีรายการยืนยันและสถานะไม่เป็น REJECTED)");
  }

  await vehicleService.getVehicleById(vehicleId, driverId);

  const payload = {
    ...routeFields,
    driverId,
    vehicleId,
    departureTime: new Date(routeFields.departureTime),
  };

  const newRoute = await routeService.createRoute(payload);
  res.status(201).json({
    success: true,
    message: "Route (by admin) created successfully",
    data: newRoute,
  });
});

const adminUpdateRoute = asyncHandler(async (req, res) => {
  const { id } = req.params;
  const { driverId, vehicleId, ...routeFields } = req.body;

  const existing = await routeService.getRouteById(id);
  if (!existing) throw new ApiError(404, "Route not found");

  let newDriverId = existing.driverId;
  let newVehicleId = existing.vehicleId;

  if (driverId) {
    const approved = await verifService.canCreateRoutes(driverId);
    if (!approved) {
      throw new ApiError(400, "ไม่สามารถสร้างเส้นทางให้ไดรเวอร์ที่ยังไม่ได้ยืนยันตัวตน (ต้องมีรายการยืนยันและสถานะไม่เป็น REJECTED)");
    }
    newDriverId = driverId;
  }

  if (vehicleId) {
    const ownerToCheck = driverId ? driverId : newDriverId;
    await vehicleService.getVehicleById(vehicleId, ownerToCheck);
    newVehicleId = vehicleId;
  }

  const payload = {
    ...routeFields,
    driverId: newDriverId,
    vehicleId: newVehicleId,
    ...(routeFields.departureTime && {
      departureTime: new Date(routeFields.departureTime),
    }),
  };

  const updated = await routeService.updateRoute(id, payload);
  res.status(200).json({
    success: true,
    message: "Route (by admin) updated successfully",
    data: updated,
  });
});

const adminDeleteRoute = asyncHandler(async (req, res) => {
  const { id } = req.params;

  const existing = await routeService.getRouteById(id);
  if (!existing) throw new ApiError(404, "Route not found");

  const result = await routeService.deleteRoute(id);
  res.status(200).json({
    success: true,
    message: "Route (by admin) deleted successfully",
    data: result,
  });
});

module.exports = {
  getAllRoutes,
  listRoutes,
  adminListRoutes,
  getRouteById,
  getMyRoutes,
  createRoute,
  updateRoute,
  deleteRoute,
  adminCreateRoute,
  adminUpdateRoute,
  adminDeleteRoute,
  adminGetRoutesByDriver,
};
