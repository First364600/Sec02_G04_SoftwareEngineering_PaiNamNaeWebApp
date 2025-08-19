const asyncHandler = require("express-async-handler");
const verifService = require("../services/driverVerification.service");
const ApiError = require("../utils/ApiError");
const { uploadToCloudinary } = require("../utils/cloudinary");

const getMyVerification = asyncHandler(async (req, res) => {
  const userId = req.user.sub;
  const record = await verifService.getVerificationByUser(userId);
  res.status(200).json({
    success: true,
    message: "Driver verification record retrieved successfully",
    data: record,
  });
});

const createVerification = asyncHandler(async (req, res) => {
  const userId = req.user.sub;
  // ไฟล์ต้องมีอยู่
  if (!req.files || !req.files.licensePhotoUrl || !req.files.selfiePhotoUrl) {
    throw new ApiError(400, "License photo and selfie photo are required");
  }

  // อัปโหลดรูปไป Cloudinary
  // const result = await uploadToCloudinary(
  //   req.file.buffer,
  //   "painamnae/licenses"
  // );

  const [licenseResult, selfieResult] = await Promise.all([
    uploadToCloudinary(
      req.files.licensePhotoUrl[0].buffer,
      "painamnae/licenses"
    ),
    uploadToCloudinary(req.files.selfiePhotoUrl[0].buffer, "painamnae/selfies"),
  ]);

  const payload = {
    userId,
    licenseNumber: req.body.licenseNumber,
    firstNameOnLicense: req.body.firstNameOnLicense,
    lastNameOnLicense: req.body.lastNameOnLicense,
    typeOnLicense: req.body.typeOnLicense,
    licenseIssueDate: new Date(req.body.licenseIssueDate),
    licenseExpiryDate: new Date(req.body.licenseExpiryDate),
    licensePhotoUrl: licenseResult.url,
    selfiePhotoUrl: selfieResult.url,
  };

  const newRec = await verifService.createVerification(payload);
  res.status(201).json({
    success: true,
    message: "Driver verification submitted and pending approval",
    data: newRec,
  });
});

const updateVerification = asyncHandler(async (req, res) => {
  const userId = req.user.sub;
  const { id } = req.params;

  const existing = await verifService.getVerificationById(id);
  if (!existing) throw new ApiError(404, "Verification not found");
  if (existing.userId !== userId) throw new ApiError(403, "Forbidden");

  // ถ้ามีไฟล์ใหม่ ให้อัปโหลดทับ
  let photoUrl = existing.licensePhotoUrl;
  if (req.file) {
    const result = await uploadToCloudinary(
      req.file.buffer,
      "painamnae/licenses"
    );
    photoUrl = result.url;
  }

  const payload = {
    ...req.body,
    licenseIssueDate: req.body.licenseIssueDate
      ? new Date(req.body.licenseIssueDate)
      : undefined,
    licenseExpiryDate: req.body.licenseExpiryDate
      ? new Date(req.body.licenseExpiryDate)
      : undefined,
    licensePhotoUrl: photoUrl,
  };

  const updated = await verifService.updateVerification(id, payload);
  res.status(200).json({
    success: true,
    message: "Driver verification updated successfully",
    data: updated,
  });
});

const getAllVerifications = asyncHandler(async (req, res) => {
  const list = await verifService.getAllVerifications();
  res.status(200).json({
    success: true,
    message: "All driver verifications retrieved successfully",
    data: list,
  });
});

const getVerificationById = asyncHandler(async (req, res) => {
  const { id } = req.params;
  const rec = await verifService.getVerificationById(id);
  if (!rec) throw new ApiError(404, "Verification not found");
  res.status(200).json({
    success: true,
    message: "Driver verification record retrieved successfully",
    data: rec,
  });
});

const updateVerificationStatus = asyncHandler(async (req, res) => {
  const { id } = req.params;
  const { status } = req.body;
  const updated = await verifService.updateVerificationStatus(id, status);
  res.status(200).json({
    success: true,
    message: `Driver verification status updated to ${status}`,
    data: updated,
  });
});

module.exports = {
  getMyVerification,
  createVerification,
  updateVerification,
  getAllVerifications,
  getVerificationById,
  updateVerificationStatus,
};
