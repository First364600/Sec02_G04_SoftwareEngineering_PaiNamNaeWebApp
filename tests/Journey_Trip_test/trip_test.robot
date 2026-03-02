*** Settings ***
Library         SeleniumLibrary
Resource        resources/test_data.robot
Resource        resources/keywords.robot
Suite Setup     Setup Browsers
Suite Teardown  Close All Browsers

*** Keywords ***
Setup Browsers
    Open Ride Sharing App    ${DRIVER_URL}    driver_browser
    Open Ride Sharing App    ${PASSENGER_URL}    passenger_browser

*** Test Cases ***

# ==========================================
# หมวดที่ 1: การทำงานพื้นฐาน (Happy Path & UI Visibility)
# ==========================================

TC01: ปุ่มแก้ไขเส้นทางและยกเลิกหายไปเมื่อเริ่มเดินทาง
    [Tags]    ui_visibility
    Switch To Driver
    Click Element    ${TAB_MY_ROUTES}
    Click Element    ${TRIP_CARD}
    Wait Until Element Is Visible    ${BTN_START_TRIP}
    Click Element    ${BTN_START_TRIP}
    Click Element    ${BTN_CONFIRM_MODAL}
    Wait Until Element Is Visible    ${BTN_STARTED_DISABLED}
    Element Should Not Be Visible    ${BTN_EDIT_ROUTE}
    
    Switch To Passenger
    Sleep    ${POLLING_WAIT_TIME}
    Click Element    ${TRIP_CARD}
    Element Should Not Be Visible    ${BTN_CANCEL_BOOKING}

TC02: การเดินทางของผู้โดยสาร 1 คน (ขึ้นจุด Origin, ลงจุด Destination)
    [Tags]    happy_path    1_pax
    # สมมติฐาน: รับผู้โดยสารที่ Origin เลย
    Switch To Driver
    Click Element    ${BTN_PICKUP_PASSENGER}
    Click Element    ${BTN_CONFIRM_MODAL}
    
    Switch To Passenger
    Sleep    ${POLLING_WAIT_TIME}
    Click Element    ${BTN_PASSENGER_START}
    Click Element    ${BTN_CONFIRM_MODAL}
    
    Switch To Driver
    # ขับไปถึงปลายทาง
    Mock Geolocation    ${GPS_DESTINATION_LAT}    ${GPS_DESTINATION_LNG}
    Click Element    ${BTN_REACHED_DEST}
    Click Element    ${BTN_CONFIRM_MODAL}
    Wait Until Page Contains    การเดินทางนี้เสร็จสิ้นสมบูรณ์แล้ว
    
    Switch To Passenger
    Sleep    ${POLLING_WAIT_TIME}
    Click Element    ${BTN_END_TRIP}
    Click Element    ${BTN_CONFIRM_MODAL}

TC03: ปุ่ม Checkpoint เปลี่ยนเป็นปุ่มถึงปลายทาง
    [Tags]    ui_visibility
    Switch To Driver
    # สมมติว่า Checkpoint จนถึงจุดสุดท้ายก่อน Destination แล้ว
    Page Should Contain Element    ${BTN_REACHED_DEST}
    Element Should Not Be Visible    ${BTN_CHECKPOINT}


# ==========================================
# หมวดที่ 2: กรณีผู้โดยสารหลายคนและจุดขึ้น-ลงที่แตกต่างกัน
# (กลุ่มนี้ต้องมี Data Setup ที่ซับซ้อนขึ้น)
# ==========================================

TC04: ผู้โดยสาร 2 คน ขึ้น-ลง จุดเดียวกันทั้งหมด
    [Tags]    multi_pax
    Switch To Driver
    Click Element    ${TAB_MY_ROUTES}
    # คลิกรถที่มี 2 คน
    Click Element    ${TRIP_CARD_2_PAX} 
    # ต้องมีปุ่มรับผู้โดยสาร 2 ปุ่ม (หรือกดยืนยันรวม)
    Page Should Contain    รับคุณ ผู้โดยสารคนที่1 และ รับคุณ ผู้โดยสารคนที่2
    Click Element    ${BTN_PICKUP_PASSENGER}
    Click Element    ${BTN_CONFIRM_MODAL}

TC05: ผู้โดยสาร 2 คน ขึ้นจุดเดียวกัน แต่ลงคนละจุด (Origin -> CP1 และ Origin -> Destination)
    [Tags]    multi_pax    diff_dropoff
    Switch To Driver
    # สมมติว่ารับมาแล้วทั้ง 2 คน
    Mock Geolocation    ${GPS_CP1_LAT}    ${GPS_CP1_LNG}
    Click Element    ${BTN_CHECKPOINT}
    # ตรวจสอบว่าระบบส่งผู้โดยสารคนที่ 1 ลงที่ CP1 สำเร็จ
    Wait Until Page Contains    ส่งคุณ ผู้โดยสารคนที่1
    
TC06: ผู้โดยสารขึ้นจุด Checkpoint 1 ลงจุด Destination
    [Tags]    diff_pickup
    Switch To Driver
    Mock Geolocation    ${GPS_CP1_LAT}    ${GPS_CP1_LNG}
    Click Element    ${BTN_CHECKPOINT}
    # มาถึง CP1 ต้องเจอผู้โดยสารให้รับ
    Page Should Contain Element    ${BTN_PICKUP_PASSENGER}
    
TC07: ผู้โดยสารขึ้นจุด Checkpoint 1 ลงจุด Checkpoint 2
    [Tags]    diff_pickup_dropoff
    Switch To Driver
    Mock Geolocation    ${GPS_CP1_LAT}    ${GPS_CP1_LNG}
    Click Element    ${BTN_CHECKPOINT}
    Click Element    ${BTN_PICKUP_PASSENGER}
    Click Element    ${BTN_CONFIRM_MODAL}
    
    Mock Geolocation    ${GPS_CP2_LAT}    ${GPS_CP2_LNG}
    Click Element    ${BTN_CHECKPOINT}
    # ส่งผู้โดยสารสำเร็จ
    Wait Until Page Contains    ส่งคุณ ผู้โดยสารคนที่1


# ==========================================
# หมวดที่ 3: การตรวจสอบระยะทาง (Checkpoint & GPS Validation)
# ==========================================

TC08: Checkpoint ไม่ผ่านเนื่องจากอยู่นอกระยะ 500 เมตร
    [Tags]    gps_validation    negative
    Switch To Driver
    Mock Geolocation    ${GPS_OUT_OF_RANGE_LAT}    ${GPS_OUT_OF_RANGE_LNG}
    Click Element    ${BTN_CHECKPOINT}
    Wait Until Page Contains    คุณไม่อยู่ในพื้นที่    timeout=${SHORT_WAIT}

TC09: Checkpoint ผ่านเมื่ออยู่ในระยะ 500 เมตร
    [Tags]    gps_validation    positive
    Switch To Driver
    Mock Geolocation    ${GPS_CP1_LAT}    ${GPS_CP1_LNG}
    Click Element    ${BTN_CHECKPOINT}
    Wait Until Page Contains    Check-in สำเร็จ    timeout=${SHORT_WAIT}

TC10: บังคับรับผู้โดยสารก่อน Checkpoint
    [Tags]    gps_validation    negative
    Switch To Driver
    Mock Geolocation    ${GPS_ORIGIN_LAT}    ${GPS_ORIGIN_LNG}
    # ห้ามกดรับผู้โดยสาร กด Checkpoint เลย
    Click Element    ${BTN_CHECKPOINT}
    Wait Until Page Contains    ยังรับผู้โดยสารไม่ครบ    timeout=${SHORT_WAIT}


# ==========================================
# หมวดที่ 4: การยกเลิกและปฏิเสธการเดินทาง
# ==========================================

TC11: ผู้โดยสารยกเลิกการเดินทาง (สถานะ Pending)
    [Tags]    cancel    pending
    Switch To Passenger
    Click Element    xpath=//button[contains(@class, 'tab-button') and contains(., 'รอดำเนินการ')]
    Click Element    ${TRIP_CARD}
    Click Element    ${BTN_CANCEL_BOOKING}
    Click Element    ${BTN_CONFIRM_MODAL}
    Wait Until Page Contains    ยกเลิกการจองสำเร็จ

TC12: ผู้โดยสารยกเลิกพร้อมระบุเหตุผล (สถานะ Confirmed)
    [Tags]    cancel    confirmed
    Switch To Passenger
    Click Element    ${TAB_PASSENGER_CONFIRMED}
    Click Element    ${TRIP_CARD}
    Click Element    ${BTN_CANCEL_BOOKING}
    Select From List By Value    ${SELECT_CANCEL_REASON}    DRIVER_DELAY
    Click Element    ${BTN_SUBMIT_CANCEL}
    Wait Until Page Contains    ยกเลิกการจองสำเร็จ
    
    Switch To Driver
    Sleep    ${POLLING_WAIT_TIME}
    Click Element    xpath=//button[contains(@class, 'tab-button') and contains(., 'ยกเลิก')]
    Click Element    ${TRIP_CARD}
    Wait Until Page Contains    คนขับล่าช้าหรือเลื่อนเวลา

TC13: คนขับขอยกเลิก -> ผู้โดยสารอนุมัติการยกเลิก
    [Tags]    driver_cancel
    Switch To Driver
    Click Element    ${TAB_MY_ROUTES}
    Click Element    ${TRIP_CARD}
    Click Element    ${BTN_DRIVER_CANCEL}
    Click Element    ${BTN_CONFIRM_MODAL}
    
    Switch To Passenger
    Sleep    ${POLLING_WAIT_TIME}
    Wait Until Page Contains    คนขับขอยกเลิกการเดินทางของคุณ
    Click Element    ${BTN_CONFIRM_CANCEL_REQ}
    Click Element    ${BTN_CONFIRM_MODAL}
    Wait Until Page Contains    การเดินทางนี้ถูกยกเลิกแล้ว

TC14: คนขับขอยกเลิก -> ผู้โดยสารปฏิเสธการยกเลิก
    [Tags]    driver_cancel    reject
    Switch To Driver
    Click Element    ${TAB_MY_ROUTES}
    Click Element    ${TRIP_CARD}
    Click Element    ${BTN_DRIVER_CANCEL}
    Click Element    ${BTN_CONFIRM_MODAL}
    
    Switch To Passenger
    Sleep    ${POLLING_WAIT_TIME}
    Click Element    ${BTN_PASSENGER_REJECT_CANCEL_REQ}
    Click Element    ${BTN_CONFIRM_MODAL}
    Wait Until Page Contains    ส่งข้อความแจ้งคนขับแล้ว

TC15: คนขับกดปฏิเสธคำขอจองของผู้โดยสาร
    [Tags]    driver_reject
    Switch To Driver
    Click Element    ${TAB_PENDING}
    Click Element    ${TRIP_CARD}
    Click Element    xpath=//button[contains(., 'ปฏิเสธ')]
    Click Element    ${BTN_CONFIRM_MODAL}
    Wait Until Page Contains    ปฏิเสธคำขอแล้ว


# ==========================================
# หมวดที่ 5: การตอบรับหน้างาน (Pickup Actions)
# ==========================================

TC16: ผู้โดยสารปฏิเสธการรับ (เมื่อรถมาถึง)
    [Tags]    pickup    reject
    Switch To Driver
    Click Element    ${BTN_PICKUP_PASSENGER}
    Click Element    ${BTN_CONFIRM_MODAL}
    
    Switch To Passenger
    Sleep    ${POLLING_WAIT_TIME}
    Wait Until Page Contains    คนขับมาถึงจุดรับของคุณแล้ว
    Click Element    ${BTN_PASSENGER_REJECT}
    Click Element    ${BTN_CONFIRM_MODAL}
    
    Switch To Driver
    Sleep    ${POLLING_WAIT_TIME}
    Wait Until Page Contains    ผู้โดยสารปฏิเสธการรับ กรุณาติดต่อผู้โดยสาร

TC17: ผู้โดยสารยืนยันการขึ้นรถ (เริ่มต้นเดินทางรายบุคคล)
    [Tags]    pickup    accept
    Switch To Driver
    Click Element    ${BTN_PICKUP_PASSENGER}
    Click Element    ${BTN_CONFIRM_MODAL}
    
    Switch To Passenger
    Sleep    ${POLLING_WAIT_TIME}
    Click Element    ${BTN_PASSENGER_START}
    Click Element    ${BTN_CONFIRM_MODAL}


# ==========================================
# หมวดที่ 6: การสิ้นสุดการเดินทาง (End Trip Rules)
# ==========================================

TC18: ปุ่มสิ้นสุดการเดินทางฝั่งผู้โดยสาร Disabled ถ้ารถยังไม่ถึง
    [Tags]    end_trip    disabled
    Switch To Passenger
    Click Element    ${TAB_PASSENGER_CONFIRMED}
    Click Element    ${TRIP_CARD}
    # ตรวจสอบว่าปุ่มมี class สั่ง disabled ไว้
    Element Should Have Class    ${BTN_END_TRIP}    cursor-not-allowed
    Element Should Be Disabled    ${BTN_END_TRIP}

TC19: ผู้โดยสารกดสิ้นสุดการเดินทางได้เมื่อรถถึงจุด Dropoff
    [Tags]    end_trip    enabled
    Switch To Driver
    Mock Geolocation    ${GPS_DESTINATION_LAT}    ${GPS_DESTINATION_LNG}
    Click Element    ${BTN_REACHED_DEST}
    Click Element    ${BTN_CONFIRM_MODAL}
    
    Switch To Passenger
    Sleep    ${POLLING_WAIT_TIME}
    Element Should Have Class    ${BTN_END_TRIP}    bg-green-600
    Element Should Be Enabled    ${BTN_END_TRIP}
    Click Element    ${BTN_END_TRIP}
    Click Element    ${BTN_CONFIRM_MODAL}

TC20: การลบประวัติการเดินทาง
    [Tags]    delete_history
    Switch To Passenger
    Click Element    ${TAB_PASSENGER_CANCELLED}
    Click Element    ${TRIP_CARD}
    Click Element    ${BTN_DELETE_HISTORY}
    Click Element    ${BTN_CONFIRM_MODAL}
    Wait Until Page Contains    ลบรายการสำเร็จ

TC21: ระบบโหลดข้อมูลอัปเดตอัตโนมัติ (Polling Test)
    [Tags]    polling    realtime
    [Documentation]    เทสว่าไม่ต้อง Refresh หน้า UI ก็ปรับเปลี่ยนเอง
    Switch To Driver
    Click Element    ${BTN_PICKUP_PASSENGER}
    Click Element    ${BTN_CONFIRM_MODAL}
    
    Switch To Passenger
    # รอดูการเปลี่ยนแปลงโดยไม่มีการสั่ง Go To หรือ Reload Page
    Wait Until Page Contains    คนขับมาถึงจุดรับของคุณแล้ว    timeout=25s