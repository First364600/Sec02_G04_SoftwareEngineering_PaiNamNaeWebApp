// src/db.js
const { Pool } = require('pg');

require('dotenv').config();
/*
const pool = new Pool({
  user: process.env.DB_USER,
  host: process.env.DB_HOST,
  database: process.env.DB_NAME,
  password: process.env.DB_PASSWORD,
  port: process.env.DB_PORT,
});
*/
const pool = new Pool({
  user: 'postgres',
  host: 'localhost',
  database: 'postgres', // เช็คชื่อ DB ให้ถูก
  password: '123', // รหัส pgAdmin 4
  port: 5432,
});

module.exports = pool;