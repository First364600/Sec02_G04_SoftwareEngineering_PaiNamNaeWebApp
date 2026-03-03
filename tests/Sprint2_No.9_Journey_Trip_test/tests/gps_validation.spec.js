const { test, expect } = require('@playwright/test');
const data = require('../data/test_data.json');

test.describe('หมวด 2: GPS Validation (รัศมี 500 เมตร)', () => {


  test('TC02: ต้องกด Checkpoint สำเร็จเมื่ออยู่ในระยะ 500 เมตร', async ({ browser }) => {

    const context = await browser.newContext({
      permissions: ['geolocation'], 
        geolocation: { latitude: 16.4322, longitude: 102.8236 }
    });
    const page = await context.newPage();


    await page.goto('http://localhost:3001/login');
    await page.getByRole('textbox', { name: /ชื่อผู้ใช้ หรือ อีเมล/ }).fill(data.driver.email);
    await page.getByRole('textbox', { name: /รหัสผ่าน/ }).fill(data.driver.password);
    await page.getByRole('button', { name: 'เข้าสู่ระบบ' }).click();

    await page.getByRole('link', { name: 'การเดินทางทั้งหมด' }).hover();
    await page.getByText(/คำขอจองเส้นทางของฉัน/).filter({ visible: true }).click();
    await page.waitForURL('**/myRoute');
    await page.getByRole('button', { name: /เส้นทางของฉัน/ }).click();
    
    const tripCard = page.locator('.trip-card').filter({ hasText: /ขอนแก่น|Khon Kaen/ }).first();
    await tripCard.click();


    const checkpointBtn = tripCard.getByRole('button', { name: /Checkpoint/i });
    await checkpointBtn.click();


    await expect(page.getByText(/สำเร็จ/)).toBeVisible();
    await page.screenshot({ path: 'screenshots/tc02-checkpoint-success.png' });
  });

  
  test('TC03: ต้องกด Checkpoint ไม่สำเร็จหากอยู่ห่างเกิน 500 เมตร', async ({ browser }) => {
    const context = await browser.newContext({
      permissions: ['geolocation'],
      geolocation: { 
        latitude: data.driver.out_of_range_gps.lat, 
        longitude: data.driver.out_of_range_gps.lng 
      }
    });
    const page = await context.newPage();

  
    await page.goto('http://localhost:3001/login');
    await page.getByRole('textbox', { name: /ชื่อผู้ใช้ หรือ อีเมล/ }).fill(data.driver.email);
    await page.getByRole('textbox', { name: /รหัสผ่าน/ }).fill(data.driver.password);
    await page.getByRole('button', { name: 'เข้าสู่ระบบ' }).click();
    await page.getByRole('link', { name: 'การเดินทางทั้งหมด' }).hover();
    await page.getByText(/คำขอจองเส้นทางของฉัน/).filter({ visible: true }).click();
    await page.waitForURL('**/myRoute');
    await page.getByRole('button', { name: /เส้นทางของฉัน/ }).click();
    const tripCard = page.locator('.trip-card').filter({ hasText: /ขอนแก่น|Khon Kaen/ }).first();
    await tripCard.click();

  
    const checkpointBtn = tripCard.getByRole('button', { name: /Checkpoint/i });
    await checkpointBtn.click();

    await expect(page.getByText(/ไม่อยู่ในพื้นที่/)).toBeVisible();
    await page.screenshot({ path: 'screenshots/tc03-checkpoint-fail.png' });
  });
});