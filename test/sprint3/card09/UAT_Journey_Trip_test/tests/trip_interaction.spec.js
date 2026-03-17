const { test, expect } = require('@playwright/test');
const data = require('../data/test_data.json');

test.describe('หมวด 3: Full Trip Scenarios', () => {
  let driverPage, passengerPage,passengerPage2;
  let driverCtx, passengerCtx, passenger2Ctx;

  test.beforeAll(async ({ browser }) => {
    
    driverCtx = await browser.newContext({
      permissions: ['geolocation'],
      geolocation: { latitude: 16.4830, longitude: 102.8230 }
    });
    driverPage = await driverCtx.newPage();

    
    passengerCtx = await browser.newContext();
    passenger2Ctx = await browser.newContext();

    passengerPage2 = await passenger2Ctx.newPage();
    passengerPage = await passengerCtx.newPage();

    
    await driverPage.goto('http://localhost:3001/login');
    await driverPage.getByRole('textbox', { name: /ชื่อผู้ใช้/ }).fill(data.driver.email);
    await driverPage.getByRole('textbox', { name: /รหัสผ่าน/ }).fill(data.driver.password);
    await driverPage.getByRole('button', { name: 'เข้าสู่ระบบ' }).click();

    await passengerPage.goto('http://localhost:3001/login');
    await passengerPage.getByRole('textbox', { name: /ชื่อผู้ใช้/ }).fill(data.passenger.email);
    await passengerPage.getByRole('textbox', { name: /รหัสผ่าน/ }).fill(data.passenger.password);
    await passengerPage.getByRole('button', { name: 'เข้าสู่ระบบ' }).click();

   await passengerPage2.goto('http://localhost:3001/login');
    await passengerPage2.getByRole('textbox', { name: /ชื่อผู้ใช้/ }).fill(data.passenger2.email);
    await passengerPage2.getByRole('textbox', { name: /รหัสผ่าน/ }).fill(data.passenger2.password);
    await passengerPage2.getByRole('button', { name: 'เข้าสู่ระบบ' }).click();
  });

  
  test('Test 06: เริ่มเดินทางและผู้โดยสารปฏิเสธการรับ', async () => {
    
    await driverPage.goto('http://localhost:3001/myRoute');
    await driverPage.getByRole('button', { name: /เส้นทางของฉัน/ }).click();
    
    const driverTripCard = driverPage.locator('.trip-card').filter({ hasText: /ขอนแก่น|Khon Kaen|Chiang Mai/ }).first();
    await driverTripCard.click();
    
    
    await driverPage.getByRole('button', { name: 'รับผู้โดยสาร' }).first().click();
    await driverPage.getByRole('button', { name: 'ยืนยัน รับผู้โดยสาร' }).click();

    
    await passengerPage.goto('http://localhost:3001/myTrip');
    await passengerPage.getByRole('button', { name: /ทั้งหมด/ }).click();
    
    const passengerTripCard = passengerPage.locator('.trip-card').first();
    await passengerTripCard.click();
    
   
    await passengerPage.getByRole('button', { name: 'ปฏิเสธการเดินทาง' }).first().click();
    await passengerPage.getByRole('button', { name: 'ยืนยัน ปฏิเสธการรับ' }).click();

    
    await driverPage.waitForTimeout(2000); 
    await driverPage.reload();

    
    await driverPage.getByRole('button', { name: /เส้นทางของฉัน/ }).click();
    const driverTripCardAfter = driverPage.locator('.trip-card').filter({ hasText: /ขอนแก่น|Khon Kaen|Chiang Mai/ }).first();
    await driverTripCardAfter.click();


    await expect(driverPage.getByText('ผู้โดยสารปฏิเสธการรับ')).toBeVisible({ timeout: 15000 });
    
    await driverPage.screenshot({ path: 'screenshots/Tc06-fix-success.png' });
});

 
test('Test 07: ผู้โดยสารปฏิเสธการยกเลิกจากคนขับ (Final Version)', async () => {
  await driverPage.goto('http://localhost:3001/myRoute');
    await driverPage.getByRole('button', { name: /เส้นทางของฉัน/ }).click();
    
    const driverTripCard = driverPage.locator('.trip-card').filter({ hasText: /ขอนแก่น|Khon Kaen|Chiang Mai/ }).first();
    await driverTripCard.click();
    await driverPage.getByRole('button', { name: 'ยกเลิกการเดินทาง' }).first().click();
    await driverPage.getByRole('button', { name: 'ยืนยัน ส่งคำขอยกเลิก' }).click();
    
    await passengerPage.goto('http://localhost:3001/myTrip');
    await passengerPage.getByRole('button', { name: /ทั้งหมด/ }).click();
    
    const passengerTripCard = passengerPage.locator('.trip-card').first();
    await passengerTripCard.click();
    
    await passengerPage.getByRole('button', { name: 'ปฏิเสธการยกเลิก' }).first().click();
    
    const confirmBtn = passengerPage.getByRole('button', { name: 'ปฏิเสธการยกเลิก' }).filter({ visible: true }).last();
    await confirmBtn.click();
    
    await driverPage.waitForTimeout(2000);
    await driverPage.reload();

    await driverPage.getByRole('button', { name: /เส้นทางของฉัน/ }).click();
    const tripCard = driverPage.locator('.trip-card').filter({ hasText: /ขอนแก่น|Khon Kaen|Chiang Mai/ }).first();
    await tripCard.click();

    await expect(driverPage.getByText(/ผู้โดยสารปฏิเสธการรับ/))
      .toBeVisible({ timeout: 15000 });

    await driverPage.screenshot({ path: 'screenshots/Tc07-reject-cancel-success.png' });
  });

test('Test 08: ผู้โดยสารคนที่ 2 อนุมัติการยกเลิก -> จุด Checkpoint ลดลง', async () => {
    await driverPage.goto('http://localhost:3001/myRoute');
    await driverPage.getByRole('button', { name: /เส้นทางของฉัน/ }).click();
  
    const driverTripCard = driverPage.locator('.trip-card').filter({ hasText: /ขอนแก่น|Khon Kaen|Chiang Mai/ }).first();
    await driverTripCard.click();
    await driverPage.locator('.relative.z-10').first().waitFor({ state: 'visible' });
    const initialPoints = await driverPage.locator('.relative.z-10').count();
    const cancelButtons = driverPage.getByRole('button', { name: 'ยกเลิกการเดินทาง' });
    
    if (await cancelButtons.count() > 1) {
        await cancelButtons.nth(1).click();
    } else {
        await cancelButtons.first().click();
    }
    
    await driverPage.getByRole('button', { name: 'ยืนยัน ส่งคำขอยกเลิก' }).click();


    await passengerPage2.goto('http://localhost:3001/myTrip');
    await passengerPage2.getByRole('button', { name: /ทั้งหมด/ }).click();
    
    
    const p2Card = passengerPage2.locator('.trip-card').first();
    await p2Card.waitFor({ state: 'visible' });
    await p2Card.click();
    
    await passengerPage2.getByRole('button', { name: 'ยืนยันยกเลิกการเดินทาง' }).first().click();
    await passengerPage2.getByRole('button', { name: 'ยืนยัน' }).filter({ visible: true }).last().click();

    
    await driverPage.waitForTimeout(3000);
    await driverPage.reload();
    await driverPage.getByRole('button', { name: /เส้นทางของฉัน/ }).click();
    await driverPage.locator('.trip-card').filter({ hasText: /ขอนแก่น|Khon Kaen|Chiang Mai/ }).first().click();

    const currentPoints = await driverPage.locator('.relative.z-10').count();
    
    
    console.log(`Before: ${initialPoints}, After: ${currentPoints}`);
    expect(currentPoints).toBeLessThan(initialPoints);
});

  test('Test 09: Checkpoint จุดแรกผ่าน แต่อันที่สองติดเงื่อนไขต้องรับคน', async () => {
    await driverPage.goto('http://localhost:3001/myRoute');
    await driverPage.getByRole('button', { name: /เส้นทางของฉัน/ }).click();
    const driverTripCard = driverPage.locator('.trip-card').filter({ hasText: /mor din dang market/ }).first();
    await driverTripCard.click();
    const checkpointBtn = driverPage.getByRole('button', { name: 'Checkpoint' });
    await checkpointBtn.waitFor({ state: 'visible' });
    await checkpointBtn.click();
    await expect(driverPage.getByText(/สำเร็จ/).first())
      .toBeVisible({ timeout: 15000 });
    await driverPage.waitForTimeout(3000); 
    await checkpointBtn.click();
    await expect(driverPage.getByText(/รับผู้โดยสาร/).first())
      .toBeVisible({ timeout: 15000 });

    await driverPage.screenshot({ path: 'screenshots/Test09-checkpoint-blocked-final.png' });
  });


  test('Test 10: รับผู้โดยสาร -> ผู้โดยสารยืนยันการขึ้นรถ -> ปลดล็อกสถานะ', async () => {
    
    await driverPage.goto('http://localhost:3001/myRoute');
    await driverPage.getByRole('button', { name: /เส้นทางของฉัน/ }).click();
    
    const driverTripCard = driverPage.locator('.trip-card').filter({ hasText: /mor din dang market|ขอนแก่น|Chiang Mai/ }).first();
    await driverTripCard.scrollIntoViewIfNeeded();
    await driverTripCard.click();
    const pickupBtn = driverPage.getByRole('button', { name: 'รับผู้โดยสาร' }).first();
    await pickupBtn.waitFor({ state: 'visible', timeout: 10000 });
    await pickupBtn.click();
    
    await driverPage.getByRole('button', { name: 'ยืนยัน รับผู้โดยสาร' }).click();
    await passengerPage2.goto('http://localhost:3001/myTrip');
    await passengerPage2.getByRole('button', { name: /ทั้งหมด/ }).click();
    
    const pTripCard = passengerPage2.locator('.trip-card').first();
    await pTripCard.waitFor({ state: 'visible' });
    await pTripCard.click();

    const startTripBtn = passengerPage2.getByRole('button', { name: 'เริ่มต้นการเดินทาง' }).first();
    await startTripBtn.waitFor({ state: 'visible' });
    await startTripBtn.click();
    
    const confirmBtn = passengerPage2.getByRole('button', { name: 'ยืนยัน' }).filter({ visible: true }).last();
    await confirmBtn.click();

    await driverPage.waitForTimeout(3000);
    await driverPage.reload();

    await driverPage.getByRole('button', { name: /เส้นทางของฉัน/ }).click();
    const tripCardAfter = driverPage.locator('.trip-card').filter({ hasText: /mor din dang market|ขอนแก่น|Chiang Mai/ }).first();
    await tripCardAfter.click();

    await driverPage.screenshot({ path: 'screenshots/Test10-pickup-confirmed.png' });
  });

  test('Test 11: ถึงจุดส่ง -> ผู้โดยสารกดสิ้นสุดทริปรายคน', async () => {
  
    await passengerPage2.goto('http://localhost:3001/myTrip');
    await passengerPage2.getByRole('button', { name: /ทั้งหมด/ }).click();
    
    const pTripCard = passengerPage2.locator('.trip-card').first();
    await pTripCard.waitFor({ state: 'visible' });
    await pTripCard.click();
    
  
    const finishBtn = passengerPage2.getByRole('button', { name: 'สิ้นสุดการเดินทาง' }).first();
    await finishBtn.waitFor({ state: 'visible' });
    await finishBtn.click();
    
  
    const confirmBtn = passengerPage2.getByRole('button', { name: 'ยืนยัน' }).filter({ visible: true }).last();
    await confirmBtn.click();

  
    await expect(passengerPage2.getByText(/เสร็จสิ้น/))
      .toBeVisible({ timeout: 15000 });

    await passengerPage2.screenshot({ path: 'screenshots/Test11-passenger-finished.png' });
  });

});