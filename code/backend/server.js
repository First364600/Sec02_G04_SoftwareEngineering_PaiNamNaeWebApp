require("dotenv").config();
const http = require('http'); // ต้องเพิ่มเพื่อใช้กับ Socket.io
const express = require('express');
const { Server } = require('socket.io'); // เพิ่ม Socket.io
const webpush = require('web-push'); //  เพิ่ม Web-Push

const logger = require('./src/middlewares/logger');
const cors = require('cors');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');
const cookieParser = require('cookie-parser');
const xss = require('xss-clean');
const hpp = require('hpp');
const promClient = require('prom-client');
const swaggerUi = require('swagger-ui-express');
const swaggerSpec = require('./src/config/swagger');
const routes = require('./src/routes');
const { errorHandler } = require('./src/middlewares/errorHandler');
const ApiError = require('./src/utils/ApiError');
const { metricsMiddleware } = require('./src/middlewares/metrics');
const ensureAdmin = require('./src/bootstrap/ensureAdmin');
const messageRoutes = require('./src/routes/message.routes');


const app = express();
const server = http.createServer(app); 


webpush.setVapidDetails(
  'mailto:3224oonchira@gmail.com', // must include "mailto:"
  process.env.VAPID_PUBLIC_KEY,
  process.env.VAPID_PRIVATE_KEY
);

// 3. ตั้งค่า Socket.io
const io = new Server(server, {
  cors: {
    origin: ["http://localhost:3001", "https://amazing-crisp-9bcb1a.netlify.app"],// ปรับเป็น URL ของ frontend Domainที่ deploy ไว้
    credentials: true
  }
});
app.set('io', io); 

io.on('connection', (socket) => {
  console.log(' User connected:', socket.id);
  socket.on('join:route', (routeId) => {
    socket.join(`route:${routeId}`);
    console.log(` User joined room: route:${routeId}`);
  });
  socket.on('disconnect', () => { console.log(' User disconnected'); });
});

// --- Middlewares ---
app.use(cors({
  origin: ["http://localhost:3001", "https://amazing-crisp-9bcb1a.netlify.app"],
  credentials: true,
  exposedHeaders: ['Content-Disposition']
}));

promClient.collectDefaultMetrics();
app.set('trust proxy', 1);
app.disable('x-powered-by');
app.use(helmet());
app.use(express.json());
app.use(cookieParser());
app.use(xss());
app.use(hpp());
app.use(logger);
app.use(metricsMiddleware);

// --- Routes ---
app.use('/api/messages', messageRoutes);
app.use('/api', routes);

// Health Check
app.get('/health', async (req, res) => {
  try {
    const prisma = require('./src/utils/prisma');
    await prisma.$queryRaw`SELECT 1`;
    res.status(200).json({ status: 'ok' });
  } catch (err) {
    res.status(503).json({ status: 'error', detail: err.message });
  }
});

// Metrics & Swagger
app.get('/metrics', async (req, res) => {
  res.set('Content-Type', promClient.register.contentType);
  res.end(await promClient.register.metrics());
});
app.use('/documentation', swaggerUi.serve, swaggerUi.setup(swaggerSpec));

// 404 Handler
app.use((req, res, next) => {
  next(new ApiError(404, `Cannot ${req.method} ${req.originalUrl}`));
});

// Error Handling
app.use(errorHandler);

// --- Start Server ---
const PORT = process.env.PORT || 3000;
(async () => {
  try {
    await ensureAdmin();
  } catch (e) {
    console.error('Admin bootstrap failed:', e);
  }

  
  server.listen(PORT, () => {
    console.log(`🚀 Server running on port ${PORT}`);
  });
})();

// Graceful Shutdown
process.on('unhandledRejection', (err) => {
  console.error('UNHANDLED REJECTION! 💥', err);
  process.exit(1);
});