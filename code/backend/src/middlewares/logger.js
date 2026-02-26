const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();
const crypto = require('crypto');

const logger = (req, res, next) => {
    const start = Date.now();
    const requestTime = new Date();

    res.on('finish', async () => {
        try {
            let userId = null;
            if (req.user) {
                userId = req.user.sub || req.user.id || null;
            }

            const ip = req.headers['x-forwarded-for'] || req.socket.remoteAddress;
            const method = req.method;
            const url = req.originalUrl;
            const userAgent = req.get('User-Agent') || 'unknown';
            const statusCode = res.statusCode;
            const duration = Date.now() - start;
            
            const action = res.locals.logAction || `${method} ${url}`;

            const rawData = `${userId}|${action}|${method}|${url}|${ip}|${userAgent}|${statusCode}|${requestTime.toISOString()}`;
            const logHash = crypto.createHash('sha256').update(rawData).digest('hex');

            await prisma.systemLog.create({
                data: {
                    user_id: userId,
                    action: action,
                    method: method,
                    endpoint: url,
                    ip_address: ip,
                    user_agent: userAgent,
                    status_code: statusCode,
                    log_hash: logHash,
                    created_at: requestTime
                }
            });
            console.log(`Log Saved: ${method} ${url} (${statusCode}) - User: ${userId || 'Guest'}`);

        } catch (err) {
            console.error('Logger Error:', err.message);
        }
    });

    next();
};

module.exports = logger;