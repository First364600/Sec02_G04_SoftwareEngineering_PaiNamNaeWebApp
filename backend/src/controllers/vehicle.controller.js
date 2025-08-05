const asyncHandler = require("express-async-handler");
const vehicleService = require("../services/vehicle.service");
const ApiError = require("../utils/ApiError");
const { uploadToCloudinary } = require('../utils/cloudinary');

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
  const ownerId = req.user.sub;
  const { id } = req.params;
  const vehicle = await vehicleService.getVehicleById(id, ownerId);

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
  const payload = {...req.body};

  if (req.files?.photos) {
    const uploads = await Promise.all(
      req.files.photos.map(file =>
        uploadToCloudinary(file.buffer, 'painamnae/vehicles')
      )
    );

    payload.photos = uploads.map(u => u.url); // เก็บเป็น array ของ URL
  }

  const newVehicle = await vehicleService.createVehicle(payload, ownerId);
  res.status(201).json({
    success: true,
    message: "Vehicle created successfully.",
    data: newVehicle,
  });
});

const updateVehicle = asyncHandler(async (req, res) => {
  const ownerId = req.user.sub;
  const { id } = req.params
  const payload = {...req.body};

  if (req.files?.photos) {
    const uploads = await Promise.all(
      req.files.photos.map(file =>
        uploadToCloudinary(file.buffer, 'painamnae/vehicles')
      )
    );
    payload.photos = uploads.map(u => u.url);
  }

  const updated = await vehicleService.updateVehicle(id, ownerId, payload)

  res.status(200).json({
    success: true,
    message: "Vehicle updated successfully.",
    data: updated,
  });
});

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
