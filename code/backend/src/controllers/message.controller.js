const asyncHandler = require('express-async-handler');
const prisma = require('../utils/prisma');
const ApiError = require('../utils/ApiError');
const webpush = require('web-push');


const PRESET_MESSAGES = {
  ON_MY_WAY:      'คนขับกำลังมาหาคุณแล้ว เตรียมตัวได้เลย!',
  ALMOST_THERE:   'คนขับใกล้ถึงจุดรับของคุณแล้ว ประมาณ 5 นาที',
  ARRIVED_PICKUP: 'คนขับมาถึงจุดรับของคุณแล้ว กรุณามาขึ้นรถ',
  WAIT_A_MOMENT:  'คนขับขอให้คุณรอสักครู่',
  CALL_ME:        'กรุณาโทรหาคนขับ',
  ALMOST_DROPOFF: 'คนขับใกล้ถึงจุดส่งของคุณแล้ว',
};

// ฟังก์ชันส่ง Web Push
async function sendPushToUser(userId, title, body, data = {}) {
  try {
    const subs = await prisma.webPushSubscription.findMany({ where: { userId } });
    const payload = JSON.stringify({ title, body, data });
    await Promise.allSettled(
      subs.map(sub =>
        webpush.sendNotification(
          { endpoint: sub.endpoint, keys: { p256dh: sub.p256dh, auth: sub.auth } },
          payload
        ).catch(async (err) => {
          if (err.statusCode === 410) {
            await prisma.webPushSubscription.delete({ where: { id: sub.id } });
          }
        })
      )
    );
  } catch (e) {
    console.warn('Push notification failed:', e.message);
  }
}

//  GET /api/messages/presets
const getPresets = asyncHandler(async (req, res) => {
  const presetOptions = Object.entries(PRESET_MESSAGES).map(([key, text]) => ({
    key,
    text
  }));
  res.json({ success: true, data: presetOptions });
});

//  POST /api/messages/route/:routeId 
const sendMessage = asyncHandler(async (req, res) => {
  const driverId = req.user.sub;
  const { routeId } = req.params;
  

  const { bookingIds, presetKey, customText } = req.body;

  const route = await prisma.route.findUnique({
    where: { id: routeId },
    include: {
      bookings: {
        where: { status: 'CONFIRMED' },
        include: { passenger: true }
      }
    }
  });

  if (!route) throw new ApiError(404, 'ไม่พบเส้นทางนี้');
  if (route.driverId !== driverId) throw new ApiError(403, 'คุณไม่มีสิทธิ์ส่งข้อความในเส้นทางนี้');


  let content = customText?.trim();
  if (!content && presetKey) {
    content = PRESET_MESSAGES[presetKey];
  }

  if (!content) throw new ApiError(400, 'กรุณาพิมพ์ข้อความหรือเลือกข้อความสำเร็จรูป');


  const targetBookings = (bookingIds && bookingIds.length > 0)
    ? route.bookings.filter(b => bookingIds.includes(b.id))
    : route.bookings;

  if (targetBookings.length === 0) throw new ApiError(400, 'ไม่พบผู้โดยสารเป้าหมายที่ต้องการส่ง');

  // สร้าง Message และแจ้งเตือนแยกรายบุคคล
  const createdMessages = await Promise.all(
    targetBookings.map(async (booking) => {
      const msg = await prisma.tripMessage.create({
        data: {
          routeId,
          senderId: driverId,
          bookingId: booking.id,
          content,
          isPreset: !customText, 
        }
      });

      // ส่ง Web Push
      await sendPushToUser(booking.passengerId, 'ข้อความจากคนขับ', content, { 
        type: 'TRIP_MESSAGE', 
        routeId 
      });

      // สร้าง In-app Notification
      await prisma.notification.create({
        data: {
          userId: booking.passengerId,
          type: 'BOOKING',
          title: 'ข้อความจากคนขับ',
          body: content,
          link: '/my-trips',
          metadata: { bookingId: booking.id, routeId, messageId: msg.id }
        }
      });

      return msg;
    })
  );

  const io = req.app.get('io');
  if (io) {
    io.to(`route:${routeId}`).emit('new_trip_message', {
      content,
      senderName: 'คนขับ',
      recipientCount: targetBookings.length
    });
  }

  res.status(201).json({ success: true, data: createdMessages });
});

// GET /api/messages/route/:routeId — driver ดู messages + replies ทั้งหมด
const getRouteMessages = asyncHandler(async (req, res) => {
  const userId = req.user.sub;
  const { routeId } = req.params;

  const route = await prisma.route.findUnique({ where: { id: routeId } });
  if (!route) throw new ApiError(404, 'Route not found');
  if (route.driverId !== userId) throw new ApiError(403, 'Forbidden');

  const messages = await prisma.tripMessage.findMany({
    where: { routeId },
    include: {
      sender: { select: { firstName: true, profilePicture: true } },
      booking: {
        include: {
          passenger: { select: { firstName: true, lastName: true, profilePicture: true } }
        }
      },
      replies: {
        include: {
          sender: { select: { firstName: true, profilePicture: true } }
        },
        orderBy: { createdAt: 'asc' }
      }
    },
    orderBy: { createdAt: 'desc' }
  });

  res.json({ success: true, data: messages });
});

// GET /api/messages/booking/:bookingId — passenger ดู messages ที่เกี่ยวกับตัวเอง

const getBookingMessages = asyncHandler(async (req, res) => {
  const userId = req.user.sub;  
  const { bookingId } = req.params;

  const booking = await prisma.booking.findUnique({ 
    where: { id: bookingId },
    include: { route: true }  
  });
  if (!booking) throw new ApiError(404, 'Booking not found');
  
  
  const isPassenger = booking.passengerId === userId;
  const isDriver = booking.route.driverId === userId;
  if (!isPassenger && !isDriver) throw new ApiError(403, 'Forbidden');

  const messages = await prisma.tripMessage.findMany({
    where: { bookingId },
    include: {
      sender: { select: { firstName: true, profilePicture: true } },
      replies: {
        include: {
          sender: { select: { firstName: true, profilePicture: true } }
        },
        orderBy: { createdAt: 'asc' }
      }
    },
    orderBy: { createdAt: 'asc' }
  });

  
  if (isPassenger) {
    await prisma.tripMessage.updateMany({
      where: { bookingId, isRead: false },
      data: { isRead: true }
    });
  }

  res.json({ success: true, data: messages });
});

// POST /api/messages/:messageId/reply — passenger ตอบกลับ
const replyMessage = asyncHandler(async (req, res) => {
  const passengerId = req.user.sub;
  const { messageId } = req.params;
  const { content } = req.body;

  if (!content?.trim()) throw new ApiError(400, 'กรุณาระบุข้อความ');

  const message = await prisma.tripMessage.findUnique({
    where: { id: messageId },
    include: {
      booking: true,
      route: true,
      sender: { select: { firstName: true } }
    }
  });

  if (!message) throw new ApiError(404, 'Message not found');
  if (message.booking?.passengerId !== passengerId) throw new ApiError(403, 'Forbidden');

  const reply = await prisma.tripMessageReply.create({
    data: { messageId, senderId: passengerId, content },
    include: { sender: { select: { firstName: true, profilePicture: true } } }
  });

  // Push แจ้งคนขับ
  await sendPushToUser(
    message.route.driverId,
    ' ผู้โดยสารตอบกลับ',
    content,
    { type: 'TRIP_REPLY', replyId: reply.id, routeId: message.routeId }
  );

  await prisma.notification.create({
    data: {
      userId: message.route.driverId,
      type: 'BOOKING',
      title: ' ผู้โดยสารตอบกลับ',
      body: content,
      link: '/my-route',
      metadata: { messageId, routeId: message.routeId }
    }
  });

  // emit socket event ถ้ามี io
  const io = req.app.get('io');
  if (io) {
    io.to(`route:${message.routeId}`).emit('message:reply', {
      messageId,
      reply
    });
  }

  res.status(201).json({ success: true, data: reply });
});

// POST /api/messages/push/subscribe — เก็บ push subscription
const subscribePush = asyncHandler(async (req, res) => {
  const userId = req.user.sub;
  const { endpoint, keys } = req.body;

  if (!endpoint || !keys?.p256dh || !keys?.auth) {
    throw new ApiError(400, 'Invalid subscription');
  }

  await prisma.webPushSubscription.upsert({
    where: { endpoint },
    update: { p256dh: keys.p256dh, auth: keys.auth },
    create: { userId, endpoint, p256dh: keys.p256dh, auth: keys.auth }
  });

  res.json({ success: true });
});

// GET /api/messages/route/:routeId/unread-count — driver เช็ค unread replies
const getUnreadRepliesCount = asyncHandler(async (req, res) => {
  const driverId = req.user.sub;
  const { routeId } = req.params;

  const count = await prisma.tripMessageReply.count({
    where: {
      isRead: false,
      message: {
        routeId,
        route: { driverId }
      }
    }
  });

  res.json({ success: true, data: { count } });
});

module.exports = {
  getPresets,
  sendMessage,
  getRouteMessages,
  getBookingMessages,
  replyMessage,
  subscribePush,
  getUnreadRepliesCount,
};