*** Variables ***
# --- System Settings ---
${BASE_URL}             http://localhost:3001
${BROWSER}              Chrome
${TIMEOUT}              10s

# --- Account ---
${USERNAME}             first2547
${PASSWORD}             888Frist19
${CONFIRM_TEXT}         ยืนยัน

# --- Element Selectors (Navigation System) ---
${TRIP_CARD}            css=.trip-card
${BTN_START_TRIP}       xpath=//button[contains(text(), 'เริ่มต้นการเดินทาง')]
${BTN_CHECKPOINT}       xpath=//button[contains(text(), 'Checkpoint')]
${BTN_FINISH}           xpath=//button[contains(text(), 'ยืนยันการถึงปลายทาง')]
${BTN_MODAL_CONFIRM}    xpath=//button[contains(text(), 'เริ่มเดินทาง')]
${BTN_MODAL_CANCEL}     xpath=//button[contains(text(), 'ยกเลิก')]
${BTN_MODAL_OK}         xpath=//button[contains(text(), 'ตกลง')]

# --- GPS Coordinates (พิกัดสำหรับการทดสอบระบบนำทาง) ---
# จุดเริ่มต้น (Origin - Point A)
${LOC_ORIGIN_LAT}        16.4795586
${LOC_ORIGIN_LNG}        102.8230013

# จุดแวะที่ 1 (Stop 1)
${LOC_STOP1_LAT}         16.441800
${LOC_STOP1_LNG}         102.827500

# จุดปลายทาง (Destination)
${LOC_DEST_LAT}          16.4750000
${LOC_DEST_LNG}          102.8200000

# พิกัดห่างไกล (Far Away - สำหรับทดสอบกรณี Failed)
${LOC_FAR_LAT}           15.0000
${LOC_FAR_LNG}           101.0000