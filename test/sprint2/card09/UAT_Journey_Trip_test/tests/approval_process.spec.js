const { test, expect } = require('@playwright/test');
const data = require('../data/test_data.json');

test.describe('หมวด: การอนุมัติและการอัปเดตรายละเอียดเส้นทาง', () => {

  test('TC04: อนุมัติแล้วรายละเอียดในเส้นทางของฉันต้องอัปเดต', async ({ page }) => {
    await page.goto('http://localhost:3001/login');
    await page.getByRole('textbox', { name: /ชื่อผู้ใช้ หรือ อีเมล/ }).fill(data.driver.email);
    await page.getByRole('textbox', { name: /รหัสผ่าน/ }).fill(data.driver.password);
    await page.getByRole('button', { name: 'เข้าสู่ระบบ' }).click();

    await page.getByRole('link', { name: 'การเดินทางทั้งหมด' }).hover();
    await page.getByText(/คำขอจองเส้นทางของฉัน/).filter({ visible: true }).click();
    
    
    await page.getByRole('button', { name: /รอดำเนินการ/ }).click();

   
    const approveBtn = page.getByRole('button', { name: 'ยืนยันคำขอ' }).filter({ visible: true }).first();
    

    await approveBtn.waitFor({ state: 'visible', timeout: 10000 });
    await approveBtn.click();
    const confirmModalBtn = page.locator('button:has-text("ยืนยันคำขอ")').filter({ visible: true }).last();
    await confirmModalBtn.click();
   
    await expect(page.getByText(/สำเร็จ|อนุมัติแล้ว/)).toBeVisible();

  
    await page.getByRole('button', { name: /เส้นทางของฉัน/ }).click();
    const chiangMaiCard = page.locator('.trip-card').filter({ hasText: /เชียงใหม่|Chiang Mai/ }).first();
    await chiangMaiCard.click();
    await page.screenshot({ path: 'results/tc04-approve-first-change.png' });
  });

  test('TC05: อนุมัติใบแรก รายละเอียดหลักต้องยังคงเดิม', async ({ page }) => {
    
    await page.goto('http://localhost:3001/login');
    await page.getByRole('textbox', { name: /ชื่อผู้ใช้ หรือ อีเมล/ }).fill(data.driver.email);
    await page.getByRole('textbox', { name: /รหัสผ่าน/ }).fill(data.driver.password);
    await page.getByRole('button', { name: 'เข้าสู่ระบบ' }).click();

    await page.getByRole('link', { name: 'การเดินทางทั้งหมด' }).hover();
    await page.getByText(/คำขอจองเส้นทางของฉัน/).filter({ visible: true }).click();
    await page.waitForURL('**/myRoute');
    
  
    await page.getByRole('button', { name: /รอดำเนินการ/ }).click();

    
    const firstApproveBtn = page.getByRole('button', { name: 'ยืนยันคำขอ' }).filter({ visible: true }).first();
    await firstApproveBtn.click();
    
    
    await page.locator('button:has-text("ยืนยันคำขอ")').filter({ visible: true }).last().click();

    
    await page.getByRole('button', { name: /เส้นทางของฉัน/ }).click();
    
    
    const chiangMaiCard = page.locator('.trip-card').filter({ hasText: /Chiang Mai|เชียงใหม่/ }).first();
    await chiangMaiCard.click();
    
    await page.screenshot({ path: 'results/tc05-approve-first-no-change.png' });
  });
});