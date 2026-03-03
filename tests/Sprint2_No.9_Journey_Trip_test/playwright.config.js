const { defineConfig } = require('@playwright/test');

module.exports = defineConfig({
  testDir: './tests',
  timeout: 30000,
  
  // กำหนดให้ทุกอย่างไปกองอยู่ที่โฟลเดอร์ results
  outputDir: './results', 
  
  reporter: [
    ['html', { 
      outputFolder: './results', // สร้าง index.html ไว้ใน results
      open: 'never' 
    }]
  ],

  use: {
    baseURL: 'http://localhost:3001',
    screenshot: 'on',
    video: 'on-first-retry',
    trace: 'on', // สำคัญมากสำหรับการดูย้อนหลังใน UI Mode
  },
});