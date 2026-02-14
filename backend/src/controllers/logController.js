const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();
const { Parser } = require('json2csv');


const getLogs = async (req, res) => {
    try {
        // 1. รับค่า Page และ Limit จาก Frontend
        const page = parseInt(req.query.page) || 1;
        const limit = parseInt(req.query.limit) || 20;
        
        // 2. คำนวณจุดเริ่มต้น
        const skip = (page - 1) * limit;

        // 3. ดึงข้อมูลจาก Database
        const [logs, total] = await prisma.$transaction([
            prisma.systemLog.findMany({
                skip: skip,
                take: limit,
                orderBy: {
                    created_at: 'desc'
                },
                include: {
                    user: {
                        select: {
                            id: true,
                            email: true,
                            role: true
                        }
                    }
                }
            }),
            prisma.systemLog.count()
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
        res.status(500).json({ 
            success: false, 
            message: "Failed to fetch logs",
            error: error.message 
        });
    }
};

const exportLogs = async (req, res) => {
    try {
        // 1. รับช่วงเวลาที่จะ Export (ถ้าไม่ส่งมา เอา 7 วันล่าสุด)
        const endDate = req.query.end_date ? new Date(req.query.end_date) : new Date();
        const startDate = req.query.start_date ? new Date(req.query.start_date) : new Date(new Date().setDate(endDate.getDate() - 7));

        // 2. ดึงข้อมูลจาก
        const logs = await prisma.systemLog.findMany({
            where: {
                created_at: {
                    gte: startDate,
                    lte: endDate
                }
            },
            orderBy: {
                created_at: 'desc'
            },
            include: {
                user: {
                    select: { email: true, role: true }
                }
            }
        });

        if (logs.length === 0) {
            return res.status(404).json({ message: "No logs found for this period" });
        }

        // 3. เตรียมข้อมูลสำหรับ CSV
        const logData = logs.map(log => ({
            ID: log.id,
            User: log.user ? log.user.email : 'Guest',
            Role: log.user ? log.user.role : '-',
            Action: log.action,
            Method: log.method,
            Endpoint: log.endpoint,
            IP_Address: log.ip_address,
            Status: log.status_code,
            Date: log.created_at.toISOString().split('T')[0],
            Time: log.created_at.toISOString().split('T')[1].split('.')[0]
        }));

        // 4. JSON -> CSV
        const json2csvParser = new Parser();
        const csv = json2csvParser.parse(logData);

        // 5. name file
        const filename = `system_logs_${startDate.toISOString().split('T')[0]}_to_${endDate.toISOString().split('T')[0]}.csv`;
        
        res.header('Content-Type', 'text/csv');
        res.attachment(filename);
        return res.send(csv);

    } catch (error) {
        console.error("Export Error:", error);
        res.status(500).json({ message: "Export failed", error: error.message });
    }
};

module.exports = { getLogs ,exportLogs };