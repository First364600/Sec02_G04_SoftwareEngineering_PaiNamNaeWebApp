*** Variables ***
# ================= Configuration =================
${BROWSER}                  Chrome
${DRIVER_URL}               http://localhost:3000/driver/my-routes
${PASSENGER_URL}            http://localhost:3000/passenger/my-trips
${POLLING_WAIT_TIME}        20s    # เผื่อเวลาให้ setInterval ทำงาน (15-20 วิ ตามโค้ด)
${SHORT_WAIT}               5s

# ================= Mock GPS Coordinates =================
# พิกัด Origin (สมมติว่าเป็นจุดเริ่มต้น)
${GPS_ORIGIN_LAT}           13.7563
${GPS_ORIGIN_LNG}           100.5018
# พิกัดที่อยู่นอกระยะ 500 เมตร (สำหรับทดสอบ Error)
${GPS_OUT_OF_RANGE_LAT}     14.0000
${GPS_OUT_OF_RANGE_LNG}     100.0000

# ================= Locators: ฝั่งคนขับ (Driver) =================
${TAB_MY_ROUTES}            xpath=//button[contains(@class, 'tab-button') and contains(., 'เส้นทางของฉัน')]
${TAB_PENDING}              xpath=//button[contains(@class, 'tab-button') and contains(., 'รอดำเนินการ')]
${TRIP_CARD}                css=.trip-card
${BTN_START_TRIP}           xpath=//button[contains(., 'เริ่มต้นการเดินทาง') and not(@disabled)]
${BTN_STARTED_DISABLED}     xpath=//button[contains(., 'กำลังเดินทาง...')]
${BTN_EDIT_ROUTE}           xpath=//a[contains(., 'แก้ไขเส้นทาง')]
${BTN_CHECKPOINT}           xpath=//button[contains(., 'Checkpoint')]
${BTN_REACHED_DEST}         xpath=//button[contains(., 'ยืนยันการถึงปลายทาง')]
${BTN_PICKUP_PASSENGER}     xpath=//button[contains(., 'รับผู้โดยสาร')]
${BTN_DRIVER_CANCEL}        xpath=//button[contains(., 'ยกเลิกการเดินทาง')]
${BTN_CONFIRM_MODAL}        xpath=//button[contains(@class, 'bg-blue-600') and contains(., 'ยืนยัน')]

# ================= Locators: ฝั่งผู้โดยสาร (Passenger) =================
${TAB_PASSENGER_CONFIRMED}  xpath=//button[contains(@class, 'tab-button') and contains(., 'ยืนยันแล้ว')]
${TAB_PASSENGER_CANCELLED}  xpath=//button[contains(@class, 'tab-button') and contains(., 'ยกเลิก')]
${BTN_CANCEL_BOOKING}       xpath=//button[contains(., 'ยกเลิกการจอง')]
${SELECT_CANCEL_REASON}     xpath=//select
${BTN_SUBMIT_CANCEL}        xpath=//button[contains(., 'ยืนยันการยกเลิก')]
${BTN_PASSENGER_START}      xpath=//button[contains(., 'เริ่มต้นการเดินทาง')]
${BTN_PASSENGER_REJECT}     xpath=//button[contains(., 'ปฏิเสธการเดินทาง')]
${BTN_END_TRIP}             xpath=//button[contains(., 'สิ้นสุดการเดินทาง')]
${BTN_CONFIRM_CANCEL_REQ}   xpath=//button[contains(., 'ยืนยันยกเลิกการเดินทาง')]
${BTN_DELETE_HISTORY}       xpath=//button[contains(., 'ลบรายการ')]