const asyncHandler = require("express-async-handler");
const vehicleService = require("../services/vehicle.service");
const ApiError = require("../utils/ApiError");

const getVehicles = asyncHandler(async (req, res) => {
  const ownerId = req.user.sub;
  const list = await vehicleService.getAllVehicles(ownerId);

  res.status(200).json({
    success: true,
    message: "Vehicles retrieved successfully.",
    data: list,
  });
});

const getVehicleById = asyncHandler(async (req, res) => {
  const { id } = req.params;
  const vehicle = await vehicleService.getVehicleById(id);

  if (!vehicle) {
    throw new ApiError(404, "Vehicle not found");
  }

  res.status(200).json({
    success: true,
    message: "Vehicle retrieved successfully.",
    data: vehicle,
  });
});

const createVehicle = asyncHandler(async (req, res) => {
  const ownerId = req.user.sub;
  const payload = req.body;

  const newVehicle = await vehicleService.createVehicle(payload, ownerId);
  res.status(201).json({
    success: true,
    message: "Vehicle created successfully.",
    data: newVehicle,
  });
});

// const updateVehicle = asyncHandler(async (req, res) => {
//   const { id } = req.params;
//   const payload = req.body;

//   let updated;
//   try {
//     updated = await vehicleService.updateVehicle(id, payload);
//   } catch (err) {
//     if (err.code === "P2025") {
//       throw new ApiError(404, "Vehicle not found");
//     }
//     throw err;
//   }

//   res.status(200).json({
//     success: true,
//     message: "Vehicle updated successfully.",
//     data: updated,
//   });
// });

const updateVehicle = asyncHandler(async (req, res) => {
  const ownerId = req.user.sub;
  const { id } = req.params
  const payload = req.body;

  const updated = await vehicleService.updateVehicle(id, ownerId, payload)

  res.status(200).json({
    success: true,
    message: "Vehicle updated successfully.",
    data: updated,
  });
});

// const deleteVehicle = asyncHandler(async (req, res) => {
//   const { id } = req.params;
//   const result = await vehicleService.deleteVehicle(id);

//   res.status(200).json({
//     success: true,
//     message: "Vehicle deleted successfully.",
//     data: result,
//   });
// });

const deleteVehicle = asyncHandler(async (req, res) => {
  const ownerId = req.user.sub;
  const { id } = req.params;
  const result = await vehicleService.deleteVehicle(id, ownerId);

  res.status(200).json({
    success: true,
    message: "Vehicle deleted successfully.",
    data: result,
  });
});

const setDefaultVehicle = asyncHandler(async (req, res) => {
  const ownerId = req.user.sub;
  const { id } = req.params;
  const result = await vehicleService.setDefaultVehicle(id, ownerId);

  res.status(200).json({
    success: true,
    message: "Vehicle set Default successfully.",
    data: result,
  });
});

module.exports = {
  getVehicles,
  getVehicleById,
  createVehicle,
  updateVehicle,
  deleteVehicle,
  setDefaultVehicle
};
