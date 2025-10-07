const prisma = require("../utils/prisma");

const PASSENGER_CANCEL_LIMIT = 3; // ≥ 3 ครั้งใน 30 วัน
const DRIVER_CANCEL_LIMIT = 2;
const WINDOW_DAYS = 30;
const SUSPEND_DAYS = 7;

function addDays(date, days) {
  return new Date(date.getTime() + days * 24 * 60 * 60 * 1000);
}

// 👇 ปรับรับ opts
async function checkAndApplyPassengerSuspension(passengerId, opts = {}) {
  const since = new Date(Date.now() - WINDOW_DAYS * 24 * 60 * 60 * 1000);

  let cancelCount;

  if (opts.confirmedOnly) {
    // ✅ นับเฉพาะ "การยกเลิกหลังจากเคย CONFIRMED"
    // อ้างอิงจาก Notification ที่บันทึกไว้ตอน cancel
    cancelCount = await prisma.notification.count({
      where: {
        userId: passengerId,
        type: "SYSTEM",
        createdAt: { gte: since },
        // Prisma JSON filter (PostgreSQL): ต้องใช้ Prisma 5 ขึ้นไป
        metadata: {
          // path -> ค่าในคีย์ JSON
          path: ["kind"],
          equals: "PASSENGER_CONFIRMED_CANCEL",
        },
      },
    });
  } else {
    // พฤติกรรมเดิม (ไม่ใช้ใน flow ใหม่ แต่เก็บไว้เผื่อที่อื่นเรียก)
    cancelCount = await prisma.booking.count({
      where: {
        passengerId,
        status: "CANCELLED",
        cancelledBy: "PASSENGER",
        cancelledAt: { gte: since },
      },
    });
  }

  if (cancelCount >= PASSENGER_CANCEL_LIMIT) {
    const until = addDays(new Date(), SUSPEND_DAYS);
    await prisma.user.update({
      where: { id: passengerId },
      data: { passengerSuspendedUntil: until },
    });

    try {
      await prisma.notification.create({
        data: {
          userId: passengerId,
          type: "SYSTEM",
          title: "ระงับสิทธิ์การจองชั่วคราว",
          body: `คุณถูกระงับสิทธิ์การจอง ${SUSPEND_DAYS} วัน เนื่องจากยกเลิกการจองที่อนุมัติแล้ว ${PASSENGER_CANCEL_LIMIT} ครั้ง ภายใน ${WINDOW_DAYS} วัน`,
          metadata: {
            kind: "PASSENGER_SUSPENSION",
            windowDays: WINDOW_DAYS,
            suspendDays: SUSPEND_DAYS,
          },
        },
      });
    } catch (_) {}
  }
}

module.exports = {
  checkAndApplyPassengerSuspension,
};
