const asyncHandler = require('express-async-handler');
const userService = require("../services/user.service");
const ApiError = require('../utils/ApiError');
const { uploadToCloudinary } = require('../utils/cloudinary');

const getAllUsers = asyncHandler(async (req, res) => {
    const users = await userService.getAllUsers();
    res.status(200).json({ success: true, message: "Users retrieved", data: users });
});

const getUserById = asyncHandler(async (req, res) => {
    const user = await userService.getUserById(req.params.id);
    if (!user) {
        throw new ApiError(404, "User not found");
    }
    res.status(200).json({ success: true, message: "User retrieved", data: user });
});

const createUser = asyncHandler(async (req, res) => {
    const userData = req.body;

    if (!req.files || !req.files.nationalIdPhotoUrl || !req.files.selfiePhotoUrl) {
        throw new ApiError(400, "National ID photo and selfie photo are required.");
    }

    // อัปโหลดรูปทั้งสองไปยัง Cloudinary
    const [nationalIdResult, selfieResult] = await Promise.all([
        uploadToCloudinary(req.files.nationalIdPhotoUrl[0].buffer, 'painamnae/national_ids'),
        uploadToCloudinary(req.files.selfiePhotoUrl[0].buffer, 'painamnae/selfies')
    ]);

    // เพิ่ม URL ของรูปภาพเข้าไปในข้อมูลที่จะบันทึก
    userData.nationalIdPhotoUrl = nationalIdResult.url;
    userData.selfiePhotoUrl = selfieResult.url;

    const newUser = await userService.createUser(userData);
    res.status(201).json({ success: true, message: "User created successfully. Please wait for verification.", data: newUser });
});

const updateCurrentUserProfile = asyncHandler(async (req, res) => {
    const updatedUser = await userService.updateUserProfile(req.user.sub, req.body);
    res.status(200).json({ success: true, message: "Profile updated", data: updatedUser });
});

const adminUpdateUser = asyncHandler(async (req, res) => {
    const updatedUser = await userService.updateUserProfile(req.params.id, req.body);
    res.status(200).json({ success: true, message: "User updated by admin", data: updatedUser });
});

const adminDeleteUser = asyncHandler(async (req, res) => {
    const deletedUser = await userService.deleteUser(req.params.id);
    res.status(200).json({
        success: true,
        message: "User deleted successfully.",
        data: { deletedUserId: deletedUser.id }
    });
});

// const uploadImage = asyncHandler(async (req, res) => {

//     const imageFile = req.body.image
//     if (imageFile && imageFile.hapi && imageFile.hapi.filename) {

//         console.log("Uploading image to Cloudinary...");
//         const result = await uploadToCloudinary(
//             imageFile,
//             "my_app/upload"
//         );
//         Data.imageUrl = result.url;
//         Data.imagePublicId = result.public_id;
//         console.log("Upload successful:", result.url);
//     }
//     const createDate = await userService.uploadImage(Data)
//     return res.status(201).json({ success: true, message: "Upload successful", data: createDate });
// })

const setUserStatus = asyncHandler(async (req, res) => {
    const updatedUser = await userService.setUserStatus(req.params.id, req.body.isActive);
    res.status(200).json({ success: true, message: "User status updated", data: updatedUser });
});

module.exports = {
    getAllUsers,
    getUserById,
    createUser,
    updateCurrentUserProfile,
    adminUpdateUser,
    adminDeleteUser,
    setUserStatus,
    
};