const asyncHandler = require('express-async-handler');
const userService = require("../services/user.service");
const ApiError = require('../utils/ApiError');
const { uploadToCloudinary } = require('../utils/cloudinary');

const adminListUsers = asyncHandler(async (req, res) => {
    const result = await userService.searchUsers(req.query);
    res.status(200).json({
        success: true,
        message: "Users (admin) retrieved",
        ...result,
    });
});

const getAllUsers = asyncHandler(async (req, res) => {
    const users = await userService.getAllUsers();
    res.status(200).json({
        success: true,
        message: "Users retrieved",
        data: users
    });
});

const getUserById = asyncHandler(async (req, res) => {
    const user = await userService.getUserById(req.params.id);
    if (!user) {
        throw new ApiError(404, "User not found");
    }
    res.status(200).json({
        success: true,
        message: "User retrieved",
        data: user
    });
});

const getMyUser = asyncHandler(async (req, res) => {
    const user = req.user.sub
    const data = await userService.getUserById(user)
    res.status(200).json({
        success: true,
        message: "User retrieved",
        data: data
    })

})
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
    res.status(201).json({
        success: true,
        message: "User created successfully. Please wait for verification.",
        data: newUser
    });
});

const updateCurrentUserProfile = asyncHandler(async (req, res) => {
    // เอาข้อมูล text fields ที่มากับ req.body
    const updateData = { ...req.body };


    if (req.files?.nationalIdPhotoUrl) {
        const buf = req.files.nationalIdPhotoUrl[0].buffer;
        const result = await uploadToCloudinary(buf, 'painamnae/national_ids');
        updateData.nationalIdPhotoUrl = result.url;
    }

    if (req.files?.selfiePhotoUrl) {
        const buf = req.files.selfiePhotoUrl[0].buffer;
        const result = await uploadToCloudinary(buf, 'painamnae/selfies');
        updateData.selfiePhotoUrl = result.url;
    }

    if (req.files?.profilePicture) {
        const buf = req.files.profilePicture[0].buffer;
        const result = await uploadToCloudinary(buf, 'painamnae/profiles');
        updateData.profilePicture = result.url;
    }

    const updatedUser = await userService.updateUserProfile(req.user.sub, updateData);
    res.status(200).json({
        success: true,
        message: "Profile updated",
        data: updatedUser
    });
});

const adminUpdateUser = asyncHandler(async (req, res) => {
    const updatedUser = await userService.updateUserProfile(req.params.id, req.body);
    res.status(200).json({
        success: true,
        message: "User updated by admin",
        data: updatedUser
    });
});

const adminDeleteUser = asyncHandler(async (req, res) => {
    const deletedUser = await userService.deleteUser(req.params.id);
    res.status(200).json({
        success: true,
        message: "User deleted successfully.",
        data: { deletedUserId: deletedUser.id }
    });
});

const setUserStatus = asyncHandler(async (req, res) => {
    const { isActive, isVerified } = req.body

    //const updatedUser = await userService.setUserStatus(req.params.id, req.body.isActive);

    let updatedUser;
    if (isActive) {
        updatedUser = await userService.setUserStatusActive(req.params.id, isActive)
    }
    else if (isVerified) {
        updatedUser = await userService.setUserStatusVerified(req.params.id, isVerified)
    }
    res.status(200).json({ success: true, message: "User status updated", data: updatedUser });
});

module.exports = {
    adminListUsers,
    getAllUsers,
    getUserById,
    getMyUser,
    createUser,
    updateCurrentUserProfile,
    adminUpdateUser,
    adminDeleteUser,
    setUserStatus,

};