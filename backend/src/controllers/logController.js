const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

const getLogs = async (req, res) => {
    try {
        // 1. รับค่า Page และ Limit จาก Frontend (ถ้าไม่ส่งมา ให้ใช้ค่า Default)
        const page = parseInt(req.query.page) || 1;     // หน้าปัจจุบัน (Default: 1)
        const limit = parseInt(req.query.limit) || 20;  // จำนวนต่อหน้า (Default: 20)
        
        // 2. คำนวณจุดเริ่มต้น (Skip)
        const skip = (page - 1) * limit;

        // 3. ดึงข้อมูลจาก Database (ใช้ Transaction เพื่อดึงทั้ง Data และ Count พร้อมกัน)
        const [logs, total] = await prisma.$transaction([
            prisma.systemLog.findMany({
                skip: skip,
                take: limit,
                orderBy: {
                    created_at: 'desc' // เรียงจากใหม่ไปเก่า (สำคัญมากสำหรับ Log)
                },
                include: {
                    user: { // จอยตาราง User เพื่อเอาชื่อคนทำมาแสดง
                        select: { username: true, email: true } 
                    }
                }
            }),
            prisma.systemLog.count() // นับจำนวนทั้งหมดเพื่อคำนวณหน้า
        ]);

        // 4. ส่ง response กลับไปให้ Frontend
        res.status(200).json({
            status: 'success',
            data: logs,
            meta: {
                total_items: total,
                total_pages: Math.ceil(total / limit),
                current_page: page,
                items_per_page: limit
            }
        });

    } catch (error) {
        console.error("Get Logs Error:", error);
        res.status(500).json({ error: "Failed to fetch logs" });
    }
};

module.exports = { getLogs };