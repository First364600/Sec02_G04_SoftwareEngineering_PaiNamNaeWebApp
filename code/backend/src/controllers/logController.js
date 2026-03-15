const { PrismaClient, LogType } = require('@prisma/client');
const prisma = new PrismaClient();
const { Parser } = require('json2csv');
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
                            role: true
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


const exportLogs = async (req, res) => {
  try {
    const { userId, dateFrom, dateTo } = req.query;
    // normalize เป็น boolean
    const includePersonal = req.query.includePersonal === 'true';
    const includeTravel   = req.query.includeTravel   === 'true';
    const includeRoutes   = req.query.includeRoutes   === 'true';

    // ถ้าไม่เลือกอะไร → export ทั้งหมด
    const exportAll = !includePersonal && !includeTravel && !includeRoutes;
    const shouldExportPersonal = exportAll || includePersonal;
    const shouldExportTravel   = exportAll || includeTravel;
    const shouldExportRoutes   = exportAll || includeRoutes;



    // declare ก่อนใช้
    const buildDateFilter = () => {
      if (!dateFrom && !dateTo) return {};
      return {
        createdAt: {
          ...(dateFrom && { gte: new Date(new Date(dateFrom).setHours(0, 0, 0, 0)) }),
          ...(dateTo   && { lte: new Date(new Date(dateTo).setHours(23, 59, 59, 999)) })
        }
      };
    };

    // declare ก่อนใช้
    let logTypeFilter = [];
    if (req.query.logType) {
      const types = Array.isArray(req.query.logType)
        ? req.query.logType
        : req.query.logType.split(',');
      logTypeFilter = types.map(t => LogType[t]).filter(Boolean);
    }

    let rows = [];

    // ใช้ shouldExportPersonal แทน
    if (shouldExportPersonal) {
      const logs = await prisma.systemLog.findMany({
        where: {
          ...(userId && { userId }),
          ...(logTypeFilter.length && { logType: { in: logTypeFilter } }),
          ...buildDateFilter()
        },
        include: { user: true },
        orderBy: { createdAt: 'desc' }
      });

      console.log('logs', logs);

      logs.forEach(log => {
        rows.push({
          Section: "Personal",
          username:    log.user?.username    || "",
          email:       log.user?.email       || "",
          firstName:   log.user?.firstName   || "",
          lastName:    log.user?.lastName    || "",
          gender:      log.user?.gender      || "",
          phoneNumber: log.user?.phoneNumber || "",
          role:        log.user?.role        || "",
          LogID:      log.id,
          LogType:    log.logType,
          Action:     log.action,
          Method:     log.method,
          Endpoint:   log.endpoint,
          StatusCode: log.statusCode || "",
          DateTime:   log.createdAt.toISOString()
        });
      });
    }

    // ใช้ shouldExportTravel แทน
    if (shouldExportTravel) {
      const bookings = await prisma.booking.findMany({
        where: {
          ...(userId && { passengerId: userId }),
          ...buildDateFilter()
        },
        include: { passenger: true },
        orderBy: { createdAt: 'desc' }
      });

      bookings.forEach(booking => {
        rows.push({
          Section:         "Travel",
          username:        booking.passenger?.username || "",
          email:           booking.passenger?.email   || "",
          bookingID:       booking.id,
          routeID:         booking.routeId,
          numberOfSeats:   booking.numberOfSeats,
          status:          booking.status,
          pickupLocation:  JSON.stringify(booking.pickupLocation),
          dropoffLocation: JSON.stringify(booking.dropoffLocation),
          createdAt:       booking.createdAt.toISOString(),
          cancelledAt:     booking.cancelledAt?.toISOString() ?? ""
        });
      });
    }

    // ใช้ shouldExportRoutes แทน
    if (shouldExportRoutes) {
      const routes = await prisma.route.findMany({
        where: {
          ...(userId && { driverId: userId }),
          ...buildDateFilter()
        },
        include: { driver: true, vehicle: true },
        orderBy: { createdAt: 'desc' }
      });

      routes.forEach(route => {
        rows.push({
          Section:       "Route",
          username:      route.driver?.username || "",
          email:         route.driver?.email   || "",
          RouteID:       route.id,
          driverId:      route.driverId,
          vehicleId:     route.vehicleId,
          startLocation: JSON.stringify(route.startLocation),
          endLocation:   JSON.stringify(route.endLocation),
          departureTime: route.departureTime.toISOString(),
          availableSeats: route.availableSeats,
          pricePerSeat:   route.pricePerSeat,
          createdAt:      route.createdAt.toISOString(),
          updatedAt:      route.updatedAt.toISOString(),
          licensePlate:   route.vehicle?.licensePlate  || "",
          vehicleType:    route.vehicle?.vehicleType   || "",
          color:          route.vehicle?.color         || "",
          seatCapacity:   route.vehicle?.seatCapacity  || ""
        });
      });
    }

    if (!rows.length) {
      return res.status(404).json({ message: "No data found" });
    }

    // defaultValue: '' กัน error เวลา columns ต่างกัน
    const parser = new Parser({ defaultValue: '' });
    const csv = parser.parse(rows);

    const uniqueUsers = [...new Set(rows.map(r => r.username).filter(Boolean))];
    const today = new Date().toISOString().split("T")[0];

    let fileName = `${Date.now()}.csv`;
    if (uniqueUsers.length === 1) {
      fileName = `${uniqueUsers[0].replace(/\s+/g, "_")}_${today}.csv`;
    } else if (uniqueUsers.length > 1) {
      fileName = `export_multiple_users_${today}.csv`;
    }

    res.header("Content-Type", "text/csv");
    res.attachment(fileName);
    return res.send(csv);

  } catch (error) {
    console.error("Export Error:", error);
    return res.status(500).json({ message: "Export failed", error: error.message });
  }
};

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