const nodemailer = require('nodemailer');
const XLSX = require('xlsx');
const userService = require('./user.service');
const ApiError = require('../utils/ApiError');


const generateAndSendUserData = async (userId, options) => {
    const { selectProfileData, selectTripHistoryData, selectRouteAndVehicleData } = options;

    const user = await userService.getUserById(userId);
    if (!user || !user.email) {
        throw new ApiError(404, "ไม่พบข้อมูลอีเมลของผู้ใช้");
    }

    const fullData = await userService.exportFullUserData(userId);
    if (!fullData) {
        throw new ApiError(404, "ไม่พบข้อมูลผู้ใช้");
    }

    const wb = XLSX.utils.book_new()
    let hasData = false

    if (selectProfileData) {
        // จัดรูปแบบข้อมูลส่วนตัว (Profile)
        const profileData = {
            ID: fullData.id,
            Username: fullData.username,
            Email: fullData.email,
            FirstName: fullData.firstName,
            LastName: fullData.lastName,
            Gender: fullData.gender,
            Phone: fullData.phoneNumber,
            NationalID: fullData.nationalIdNumber,
            Role: fullData.role,
            NationalIdPhotoUrl: fullData.nationalIdPhotoUrl,
            SelfiePhotoUrl: fullData.selfiePhotoUrl,
            IsVerified: fullData.isVerified ? 'Yes' : 'No',
            IsActive: fullData.isActive ? 'Yes' : 'No',
            CreatedAt: fullData.createdAt ? new Date(fullData.createdAt).toLocaleString('th-TH') : '',
        };

        if (profileData) {
            const ws = XLSX.utils.json_to_sheet([profileData])
            XLSX.utils.book_append_sheet(wb, ws, "Profile")
            hasData = true
        }
    }
    if (selectTripHistoryData) {
        const bookings = fullData.bookings || [];
        // จัดรูปแบบข้อมูลการจอง (Booking)
        const bookingData = bookings.length > 0 
            ? bookings.map(b => ({
                BookingID: b.id,
                Status: b.status,
                Seats: b.numberOfSeats,
                Pickup: b.pickupLocation?.address || b.pickupLocation?.name || '',
                Dropoff: b.dropoffLocation?.address || b.dropoffLocation?.name || '',
                RouteSummary: b.route?.routeSummary || '',
                Price: b.route?.pricePerSeat || 0,
                BookedAt: b.createdAt ? new Date(b.createdAt).toLocaleString('th-TH') : ''
            }))
            : [{ Info: "ไม่พบประวัติการเดินทาง" }]; // กรณีไม่มีข้อมูล

        const ws = XLSX.utils.json_to_sheet(bookingData)
        XLSX.utils.book_append_sheet(wb, ws, "Trip History")
        hasData = true
    }
    if (selectRouteAndVehicleData) {
        const vehicleData = fullData.vehicles || [];
        
        // จัดรูปแบบข้อมูลรถ (Vehicle)
        const formattedVehicles = vehicleData.length > 0
            ? vehicleData.map(v => ({
                LicensePlate: v.licensePlate,
                Model: v.vehicleModel,
                Type: v.vehicleType,
                Color: v.color,
                Seats: v.seatCapacity,
                IsDefault: v.isDefault ? 'Yes' : 'No'
            }))
            : [{ Info: "ไม่พบข้อมูลรถยนต์" }];

        const ws = XLSX.utils.json_to_sheet(formattedVehicles);
        XLSX.utils.book_append_sheet(wb, ws, "Vehicles");
        hasData = true;

        // เพิ่มข้อมูลเส้นทางที่สร้าง (Routes)
        const createdRoutes = fullData.createdRoutes || [];
        if (createdRoutes.length > 0) {
            const routeData = createdRoutes.map(r => ({ 
                RouteID: r.id,
                Start: r.startLocation?.address || r.startLocation?.name,
                End: r.endLocation?.address || r.endLocation?.name,
                Departure: r.departureTime ? new Date(r.departureTime).toLocaleString('th-TH') : '',
                Status: r.status,
                Price: r.pricePerSeat,
                Seats: r.availableSeats
            }));
            const wsRoutes = XLSX.utils.json_to_sheet(routeData);
            XLSX.utils.book_append_sheet(wb, wsRoutes, "Created Routes");
        }
    }
    
    if (!hasData) {
        // showToast("แจ้งเตือน", "ไม่พบข้อมูลของคุณ กรุณาลองไหม่ในภายหลัง", "warning")
        //  throw errorMessages("ไม่พบข้อมูลของคุณ กรุณาลองไหม่ในภายหลัง")
        throw new ApiError(400, "ไม่พบข้อมูลตามรายการที่เลือก");
    }

    const buffer = XLSX.write(wb, { type: 'buffer', bookType: 'xlsx'});
    const transporter = nodemailer.createTransport({
        service: 'gmail',
        auth: {
            user: process.env.EMAIL_USER,
            pass: process.env.EMAIL_PASS
        }
    });

    await transporter.sendMail({
        from: `"Pai Nam Nae Support" <no-reply@painamnae.cskku24.cpkku.com>`,
        to: user.email,
        subject: 'ข้อมูลส่วนบุคคลของคุณ (Data Export)',
        text: `เรียนคุณ ${user.firstName || 'ผู้ใช้งาน'}, \n\nระบบได้จัดส่งไฟล์ข้อมูลส่วนบุคคลที่คุณร้องขอตามไฟล์แนบ\n\nด้วยความเคารพ,\nทีมงาน Pai Nam Nae`,
        attachments:[{ 
            filename: `UserData_${user.username || 'export'}.xlsx`,
            content: buffer
        }]
    });

    return { email: user.email };
}

module.exports = {
    generateAndSendUserData
};