const ApiError = require('../utils/ApiError');

const requireGatewayKey = (req, res, next) => {
    const gatewaySecret = process.env.GATEWAY_SECRET;

    // ถ้าไม่ได้ตั้งค่า Secret ใน Environment Variable ถือว่าไม่บังคับใช้
    if (!gatewaySecret) {
        return next();
    }

    const clientKey = req.headers['x-gateway-key'];

    if (!clientKey || clientKey !== gatewaySecret) {
        return next(new ApiError(403, 'Forbidden: Invalid or missing Gateway Key'));
    }

    next();
};

module.exports = requireGatewayKey;
