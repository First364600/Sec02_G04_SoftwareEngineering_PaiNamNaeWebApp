const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();
const crypto = require('crypto');
const stringify = require('fast-json-stable-stringify');

const logger = (req, res, next) => {
    const start = Date.now();
    const requestTime = new Date();

    res.on('finish', async () => {
        try {
            const userId = req.user?.id || req.user?.sub || null;
            const { method, originalUrl: url } = req;
            const statusCode = res.statusCode;

            // log type classification
            let logType = 'TRANSACTION';
            if (url.includes('/auth') || url.includes('/login')) logType = 'AUTH';
            else if (statusCode >= 400 || url.includes('/admin')) logType = 'SECURITY';
            else if (method === 'GET') logType = 'BEHAVIOR';

            const sanitize = (data) => {
                if (!data) return null;
                const cleanData = { ...data };
                if (cleanData.password) cleanData.password = '***REDACTED***';
                if (cleanData.oldPassword) cleanData.oldPassword = '***REDACTED***';
                return cleanData;
            };

            const payload = method === 'GET' ? req.query : sanitize(req.body);

            const rawDataObj = {
                userId,
                logType,
                method,
                endpoint: url,
                statusCode,
                ip: req.ip,
                timestamp: requestTime.toISOString(),
                details: payload
            };
            const rawDataString = stringify(rawDataObj);

            const hmac = crypto.createHmac('sha256', process.env.LOG_HMAC_SECRET)
                               .update(rawDataString)
                               .digest('hex');

            await prisma.systemLog.create({
                data: {
                    userId: userId,
                    logType: logType,
                    action: `${method} ${url}`,
                    method: method,
                    endpoint: url,
                    ipAddress: req.ip,
                    userAgent: req.get('User-Agent') || 'unknown',
                    statusCode: statusCode,
                    details: rawDataObj, // raw data
                    logHash: hmac,       // HMAC hash of the log entry
                    createdAt: requestTime
                }
            });
        } catch (err) {
            console.error('Logging Error:', err);
        }
    });
    next();
};

module.exports = logger;