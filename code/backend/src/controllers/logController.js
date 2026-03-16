const { PrismaClient, LogType } = require('@prisma/client');
const prisma = new PrismaClient();
const { Parser } = require('json2csv');
const ExcelJS = require('exceljs');
const crypto = require('crypto');
const stringify = require('fast-json-stable-stringify');


const getLogs = async (req, res) => {
    try {
        // 1. รับค่า Page และ Limit จาก Frontend
        const page = parseInt(req.query.page) || 1;
        const limit = parseInt(req.query.limit) || 20;

        // 2. คำนวณจุดเริ่มต้น
        const skip = (page - 1) * limit;

        const { userId, dateFrom, dateTo } = req.query;

        // normalize + convert เป็น Prisma Enum
        let logTypeFilter = []

        if (req.query.logType) {

          let types = []

          if (Array.isArray(req.query.logType)) {
            types = req.query.logType
          } else {
            types = req.query.logType.split(',')
          }

        // convert string → Prisma Enum
        logTypeFilter = types
          .map(t => LogType[t])
          .filter(Boolean) // กันค่าผิด
      }

          const where = {
            ...(userId && { userId }),

            ...(logTypeFilter.length && {
              logType: {
                in: logTypeFilter
              }
            }),

            ...((dateFrom || dateTo) && {
              createdAt: {
                ...(dateFrom && {
                  gte: new Date(new Date(dateFrom).setHours(0, 0, 0, 0))
                }),
                ...(dateTo && {
                  lte: new Date(new Date(dateTo).setHours(23, 59, 59, 999))
                })
              }
            })
          };

        // 3. ดึงข้อมูลจาก Database
         const [logs, total] = await prisma.$transaction([
             prisma.systemLog.findMany({
                 where,
                 skip: skip,
                 take: limit,
                 orderBy: {
                   createdAt: 'desc'
             },
                include: {
                    user: {
                        select: {
                            id: true,
                            email: true,
                            role: true,
                            username:    true,  
                            firstName:   true,  
                            lastName:    true,  
                            gender:      true, 
                            phoneNumber: true 
                        }
                    }
                }
            }),
            prisma.systemLog.count({ where })
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

// ฟังก์ชันสำหรับ Export Logs เป็น Excel
const exportLogs = async (req, res) => {
  try {

    const { userId, dateFrom, dateTo } = req.query

    const includePersonal = req.query.includePersonal === "true"
    const includeTravel   = req.query.includeTravel === "true"
    const includeRoutes   = req.query.includeRoutes === "true"

    // -------- logType filter --------
    let logTypeFilter = []

    if (req.query.logType) {

      const raw = req.query.logType
      let types = []

      if (Array.isArray(raw)) {
        types = raw
      } else if (typeof raw === "string") {
        types = raw.split(",")
      }

      logTypeFilter = types
        .map(t => LogType[t])
        .filter(Boolean)
    }

    const buildDateFilter = () => {
      if (!dateFrom && !dateTo) return {};
      if (!dateFrom && !dateTo) return {}

      return {
        createdAt: {
          ...(dateFrom && {
            gte: new Date(new Date(dateFrom).setHours(0,0,0,0))
          }),
          ...(dateTo && {
            lte: new Date(new Date(dateTo).setHours(23,59,59,999))
          })
        }
      }
    }

    const workbook = new ExcelJS.Workbook()
    workbook.creator = "PaiNamNae System"

    let hasData = false

    // =========================
    // SHEET 1 : USER PROFILE
    // =========================
    if (includePersonal) {

      const users = await prisma.user.findMany({
        where: {
          ...(userId && { id: userId })
        },
        select: {
          username: true,
          email: true,
          firstName: true,
          lastName: true,
          gender: true,
          phoneNumber: true,
          role: true
        }
      })

      if (users.length) {

        hasData = true

        const sheet = workbook.addWorksheet("User Profile")

        sheet.columns = [
          { header: "Username", key: "username", width: 20 },
          { header: "Email", key: "email", width: 30 },
          { header: "First Name", key: "firstName", width: 15 },
          { header: "Last Name", key: "lastName", width: 15 },
          { header: "Gender", key: "gender", width: 10 },
          { header: "Phone Number", key: "phoneNumber", width: 15 },
          { header: "Role", key: "role", width: 12 }
        ]

        sheet.getRow(1).font = { bold: true }

        users.forEach(user => {
          sheet.addRow(user)
        })

      }
    }

    // =========================
    // SHEET 2 : SYSTEM LOGS
    // =========================
    const logs = await prisma.systemLog.findMany({

      where: {

        ...(userId && { userId }),

        ...(logTypeFilter.length && {
          logType: {
            in: logTypeFilter
          }
        }),

        ...buildDateFilter()

      },

      orderBy: {
        createdAt: "desc"
      }

    })

    if (logs.length) {

      hasData = true

      const sheet = workbook.addWorksheet("System Logs")

      sheet.columns = [

        { header: "Log ID", key: "logId", width: 10 },
        { header: "Log Type", key: "logType", width: 14 },
        { header: "Action", key: "action", width: 40 },
        { header: "Method", key: "method", width: 10 },
        { header: "Endpoint", key: "endpoint", width: 50 },
        { header: "IP Address", key: "ipAddress", width: 15 },
        { header: "User Agent", key: "userAgent", width: 50 },
        { header: "Status Code", key: "statusCode", width: 12 },
        { header: "Details", key: "details", width: 50 },
        { header: "Log Hash", key: "logHash", width: 70 },
        { header: "Date Time", key: "dateTime", width: 22 }

      ]

      sheet.getRow(1).font = { bold: true }

      logs.forEach(log => {

        sheet.addRow({

          logId: log.id,
          logType: log.logType,
          action: log.action,
          method: log.method,
          endpoint: log.endpoint,
          ipAddress: log.ipAddress || "",
          userAgent: log.userAgent || "",
          statusCode: log.statusCode || "",
          details: log.details ? JSON.stringify(log.details) : "",
          logHash: log.logHash || "",
          dateTime: log.createdAt.toISOString()

        })

      })

    }

    // =========================
    // SHEET 3 : ACTIVITY
    // =========================
    if (includeTravel || includeRoutes) {

      const sheet = workbook.addWorksheet("Activity")

      sheet.columns = [

        { header: "Section", key: "section", width: 10 },
        { header: "Username", key: "username", width: 20 },
        { header: "Email", key: "email", width: 30 },

        { header: "Booking ID", key: "bookingID", width: 30 },
        { header: "Route ID", key: "routeID", width: 30 },
        { header: "Seats", key: "numberOfSeats", width: 8 },
        { header: "Booking Status", key: "bookingStatus", width: 16 },

        { header: "Pickup", key: "pickupLocation", width: 40 },
        { header: "Dropoff", key: "dropoffLocation", width: 40 },

        { header: "Route Status", key: "routeStatus", width: 14 },
        { header: "Start Location", key: "startLocation", width: 40 },
        { header: "End Location", key: "endLocation", width: 40 },

        { header: "Created At", key: "createdAt", width: 22 }

      ]

      sheet.getRow(1).font = { bold: true }

      if (includeTravel) {

        const bookings = await prisma.booking.findMany({

          where: {
            ...(userId && { passengerId: userId }),
            ...buildDateFilter()
          },

          include: {
            passenger: {
              select: { username: true, email: true }
            }
          }

        })

        bookings.forEach(b => {

          sheet.addRow({

            section: "Travel",
            username: b.passenger?.username || "",
            email: b.passenger?.email || "",

            bookingID: b.id,
            routeID: b.routeId,
            numberOfSeats: b.numberOfSeats,
            bookingStatus: b.status,

            pickupLocation: JSON.stringify(b.pickupLocation),
            dropoffLocation: JSON.stringify(b.dropoffLocation),

            createdAt: b.createdAt.toISOString()

          })

        })

      }

      if (includeRoutes) {

        const routes = await prisma.route.findMany({

          where: {
            ...(userId && { driverId: userId }),
            ...buildDateFilter()
          },

          include: {
            driver: {
              select: { username: true, email: true }
            }
          }

        })

        routes.forEach(r => {

          sheet.addRow({

            section: "Route",
            username: r.driver?.username || "",
            email: r.driver?.email || "",

            routeID: r.id,
            routeStatus: r.status,
            startLocation: JSON.stringify(r.startLocation),
            endLocation: JSON.stringify(r.endLocation),

            createdAt: r.createdAt.toISOString()

          })

        })

      }

    }

    if (!hasData) {
      return res.status(404).json({ message: "No data found" })
    }

    let userName = "all_users"

    if (userId) {
      const user = await prisma.user.findUnique({
        where: { id: userId },
        select: {
          firstName: true,
          lastName: true,
          username: true
        }
      })

      if (user) {
        userName = `${user.firstName || ""}_${user.lastName || ""}` 
          || user.username 
          || "user"
      }
    }

    const today = new Date().toISOString().split("T")[0]
    const fileName = `${userName}_${today}.xlsx`

    res.setHeader(
      "Content-Type",
      "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
    )

    res.setHeader(
      "Content-Disposition",
      `attachment; filename="${fileName}"`
    )

    await workbook.xlsx.write(res)

    res.end()

  } catch (error) {

    console.error("Export Error:", error)

    return res.status(500).json({
      message: "Export failed",
      error: error.message
    })

  }
}

const verifyLogIntegrity = async (req, res) => {
    const { id } = req.params;
    const log = await prisma.systemLog.findUnique({ 
        where: { id: parseInt(id) } 
    });

  if (!log) {
    return res.status(404).json({ message: "Log not found" });
  }

  const rawDataString = stringify(log.details);

  const computedHash = crypto.createHmac('sha256', process.env.LOG_HMAC_SECRET)
                               .update(rawDataString)
                               .digest('hex');

  const isValid = (computedHash === log.logHash);

  res.json({
        logId: id,
        isValid: isValid,
        status: isValid ? "Verified (No tampering)" : "Tampered (Data changed!)",
        timestamp: new Date()
    });
};

const auditAllLogs = async (req, res) => {
    try {
        const logs = await prisma.systemLog.findMany({
            select: { 
                id: true, 
                details: true, 
                logHash: true 
            }
        });

        const tamperedLogIds = [];

        for (const log of logs) {
            if (log.details && log.logHash) {
                // ใช้ fast-json-stable-stringify เพื่อจัดเรียง Key ให้เหมือนตอนสร้าง
                const rawDataString = stringify(log.details);
                
                const computedHash = crypto.createHmac('sha256', process.env.LOG_HMAC_SECRET)
                                           .update(rawDataString)
                                           .digest('hex');
                
                // ถ้าไม่ตรงกัน แปลว่าโดนแก้
                if (computedHash !== log.logHash) {
                    tamperedLogIds.push(log.id);
                }
            }
        }

        if (tamperedLogIds.length === 0) {
            return res.status(200).json({ 
                success: true,
                status: "Secure", 
                message: "All logs are perfectly intact. No tampering detected.",
                totalScanned: logs.length,
                tamperedLogIds: []
            });
        } else {
            return res.status(200).json({ 
                success: true,
                status: "Warning", 
                message: `Alert! Found ${tamperedLogIds.length} tampered logs!`,
                totalScanned: logs.length,
                tamperedLogIds: tamperedLogIds 
            });
        }

    } catch (error) {
        console.error("Audit Error:", error);
        return res.status(500).json({ 
            success: false, 
            message: "Audit failed", 
            error: error.message 
        });
    }
};

module.exports = { getLogs, exportLogs, verifyLogIntegrity, auditAllLogs };