const { test, expect } = require('@playwright/test');
const data = require('../data/test_data.json');

test.describe('หมวด 1: UI Visibility', () => {

  test('TC01: ปุ่มแก้ไขต้องหายไปหลังเริ่มทริป', async ({ browser }) => {
    const context = await browser.newContext({
      permissions: ['geolocation'],
      geolocation: { latitude: data.driver.origin_gps.lat, longitude: data.driver.origin_gps.lng }
    });
    const page = await context.newPage();

    await page.goto('http://localhost:3001/login');
    await page.getByRole('textbox', { name: /ชื่อผู้ใช้ หรือ อีเมล/ }).fill(data.driver.email);
    await page.getByRole('textbox', { name: /รหัสผ่าน/ }).fill(data.driver.password);
    await page.getByRole('button', { name: 'เข้าสู่ระบบ' }).click();

 
    await page.getByRole('link', { name: 'การเดินทางทั้งหมด' }).hover();
    const myRouteOption = page.getByText(/คำขอจองเส้นทางของฉัน/).filter({ visible: true });
    await myRouteOption.click();


    await page.waitForURL('**/myRoute');
    await page.getByRole('button', { name: /เส้นทางของฉัน/ }).click();


    const tripCard = page.locator('.trip-card').filter({ hasText: /ขอนแก่น|Khon Kaen/ }).first();
    
 
    await tripCard.click();

 
    const editBtn = tripCard.getByRole('link', { name: 'แก้ไขเส้นทาง' });
    await expect(editBtn).toBeVisible();


    await tripCard.getByRole('button', { name: 'เริ่มต้นการเดินทาง' }).click();

 
    const confirmBtn = page.getByRole('button', { name: 'เริ่มเดินทาง' });
    await expect(confirmBtn).toBeVisible();
    await confirmBtn.click();

    await expect(editBtn).not.toBeVisible({ timeout: 10000 });
    
    await page.screenshot({ path: 'screenshots/tc01-success.png' });
  });
});