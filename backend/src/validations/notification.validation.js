const { z } = require('zod');
const { NotificationType } = require('@prisma/client');

// ใช้ร่วมกัน
const idParamSchema = z.object({
    id: z.string().cuid({ message: 'Invalid notification ID format' }),
});

// ========= User: list =========
const listMyNotificationsQuerySchema = z.object({
    page: z.coerce.number().int().min(1).default(1),
    limit: z.coerce.number().int().min(1).max(100).default(20),

    q: z.string().trim().min(1).optional(), // ค้น title/body
    type: z.nativeEnum(NotificationType).optional(),
    read: z.coerce.boolean().optional(), // true → readAt != null, false → readAt == null

    createdFrom: z.string().refine(v => !v || !isNaN(Date.parse(v)), { message: 'Invalid createdFrom' }).optional(),
    createdTo: z.string().refine(v => !v || !isNaN(Date.parse(v)), { message: 'Invalid createdTo' }).optional(),

    sortBy: z.enum(['createdAt', 'title']).default('createdAt'),
    sortOrder: z.enum(['asc', 'desc']).default('desc'),
});

// ========= Admin: list =========
const listNotificationsAdminQuerySchema = listMyNotificationsQuerySchema.extend({
    userId: z.string().cuid().optional(),
});

// ========= Admin: create =========
const createNotificationAdminSchema = z.object({
    userId: z.string().cuid({ message: 'userId must be a CUID' }),
    type: z.nativeEnum(NotificationType).default('SYSTEM').optional(),
    title: z.string().min(1, 'title is required'),
    body: z.string().min(1, 'body is required'),
    link: z.string().url('link must be a valid URL').optional(),
    // metadata ยอมรับอะไรก็ได้ (เช่น object), ให้ frontend ส่ง JSON แล้ว parse ก่อนก็ได้
    metadata: z.any().optional(),
});

module.exports = {
    idParamSchema,
    listMyNotificationsQuerySchema,
    listNotificationsAdminQuerySchema,
    createNotificationAdminSchema,
};
