*** Settings ***
Documentation       UAT Test Suite: ระบบค้นหาและจองเส้นทาง 
Library             SeleniumLibrary    timeout=20s    implicit_wait=2s    screenshot_root_directory=${EXECDIR}/results/screenshots
Library             Collections
Library             String
Resource            resources/test_data.robot

Suite Setup         Open Browser และ Login ตามวิดีโอ
Suite Teardown      Close All Browsers

*** Test Cases ***

# --- TC01 - TC03  ---
TC01_Search_With_Valid_Data
    [Tags]    search    smoke
    ไปหน้าค้นหาผ่าน Navbar
    Fill Search Form    ${ROUTE_ORIGIN}    ${ROUTE_DEST}    ${ROUTE_DATE}
    Click Search Button
    Wait For Search Results

TC02_Search_With_No_Filter
    [Tags]    search
    Reload Page
    Click Search Button
    Wait Until Page Contains    ผลการค้นหา

TC03_Search_No_Result_State
    [Tags]    search
    Fill Search Form    ${ROUTE_ORIGIN}    ${ROUTE_DEST}    ${C8_NO_RESULT_DATE}
    Click Search Button
    Wait Until Page Contains    ${C8_EXPECTED_MSG}

# ===========================================================================
# ส่วนที่แก้ไข: TC04 - TC11 
# ===========================================================================

TC04_Radius_Fail_Pickup_Too_Far
    Open Booking Modal
    Fill Pickup And Dropoff    ${C2_FAR_PICKUP}    ${C1_DROPOFF}
    Click Confirm Booking
    Verify Error Modal Is Shown    ${C2_EXPECTED_MODAL_TITLE}
    Click Confirm In Error Modal

TC05_Radius_Fail_Dropoff_Too_Far
    [Documentation]    จุดลงรถห่างเกิน 
    [Tags]             radius    validation
    Fill Pickup And Dropoff    ${C1_PICKUP}    ${C2_FAR_DROPOFF}
    Click Confirm Booking
    Verify Error Modal Is Shown    ${C2_EXPECTED_MODAL_TITLE}
    Click Confirm In Error Modal

TC06_Sequence_Fail_Dropoff_Before_Pickup
    [Documentation]    จองสลับลำดับจุดแวะ (ลงก่อนขึ้น)
    [Tags]             sequence    validation
    Fill Pickup And Dropoff    ${C3_PICKUP_LATER_STOP}    ${C3_CHECK}
    Click Confirm Booking
    # ระบบจะแสดง Error Modal เรื่องจุดลงรถไม่ถูกต้อง
    Verify Error Modal Is Shown    จุดลงรถไม่ถูกต้อง
    Click Confirm In Error Modal

TC07_Validation_Empty_Fields
    [Documentation]    ล้างข้อมูลพิกัดใน Modal แล้วกดจอง (ต้องขึ้น Warning)
    [Tags]             validation
    Clear Element Text    xpath=(//input[@placeholder='พิมพ์ชื่อสถานที่...'])[1]
    Clear Element Text    xpath=(//input[@placeholder='พิมพ์ชื่อสถานที่...'])[2]
    Click Confirm Booking
    Verify Warning Toast    กรุณาเลือกจุดขึ้นรถและจุดลงรถ

TC08_Validation_Modal_Behavior
    [Documentation]    ตรวจสอบว่า Modal จองยังอยู่ และกดปิดเพื่อเริ่มเคสถัดไป
    [Tags]             radius
    Verify Booking Modal Still Open
    Click Element    xpath=//button[contains(text(),'ยกเลิก')]
    Sleep    1s

TC09_Booking_Success_Happy_Path
    [Documentation]    กรอกข้อมูลถูกต้อง -> จองสำเร็จ 
    [Tags]             happy_path    smoke
    Select First Available Route
    Open Booking Modal
    Select Seats    1
    Fill Pickup And Dropoff    ${C1_PICKUP}    ${C1_DROPOFF}
    Click Confirm Booking
    Verify Booking Success Toast
    Wait Until Location Contains    /myTrip    timeout=10s


*** Keywords ***

Open Browser และ Login ตามวิดีโอ
    Open Browser    ${BASE_URL}/login    ${BROWSER}
    Maximize Browser Window
    Wait Until Page Contains    เข้าสู่ระบบ
    Login As Passenger

Login As Passenger
    Go To    ${BASE_URL}/login
    Wait Until Element Is Visible    id=identifier    timeout=10s
    Input Text      id=identifier    ${PASSENGER_EMAIL}
    Input Password  id=password      ${PASSENGER_PASSWORD}
    Click Button    xpath=//button[@type='submit']
    Wait Until Page Contains    ค้นหาเส้นทาง    timeout=20s

Logout จากระบบตามวิดีโอ
    # เช็ค
    Wait Until Element Is Visible    xpath=//button[contains(.,'hello')]    timeout=10s
    Click Element    xpath=//button[contains(.,'hello')]
    Wait Until Element Is Visible    xpath=//button[contains(text(),'Logout')]    timeout=5s
    Click Button    xpath=//button[contains(text(),'Logout')]
    Sleep    2s

ไปหน้าค้นหาผ่าน Navbar
    #คลิกเมนู "ค้นหาเส้นทาง"
    Click Element    xpath=//a[contains(text(),'ค้นหาเส้นทาง')]
    Wait Until Page Contains    ค้นหาเส้นทาง    timeout=10s

Fill Search Form
    [Arguments]    ${origin}    ${dest}    ${date}
    Input Text    xpath=//input[@placeholder='เช่น กรุงเทพฯ']    ${origin}
    Input Text    xpath=//input[@placeholder='เช่น เชียงใหม่']    ${dest}
    # แก้ปัญหาไม่พิมพ์แต่เลือก: ใช้ JavaScript
    Execute JavaScript    document.querySelector('input[type="date"]').value = '${date}'
    Execute JavaScript    document.querySelector('input[type="date"]').dispatchEvent(new Event('input'))

Click Search Button
    Click Button    xpath=//button[contains(text(),'ค้นหา')]

Wait For Search Results
    Wait Until Element Is Visible    xpath=(//div[contains(@class,'cursor-pointer')])[1]    timeout=15s

Select First Available Route
    # คลิกที่ตัวการ์ดเส้นทางเพื่อให้รายละเอียดแสดงผล
    Click Element    xpath=(//div[contains(@class,'cursor-pointer')])[1]
    Wait Until Element Is Visible    xpath=//button[contains(text(),'จองที่นั่ง')]    timeout=10s

Open Booking Modal
    # คลิกปุ่มจองที่นั่งในส่วนรายละเอียด
    Click Button    xpath=//button[contains(text(),'จองที่นั่ง')]
    Wait Until Page Contains    ยืนยันการจอง    timeout=10s

Select Seats
    [Arguments]    ${num}
    Select From List By Value    xpath=//select    ${num}

Fill Pickup And Dropoff
    [Arguments]    ${pickup}    ${dropoff}
    # ใช้ Index ตามภาพ image_da5b3c.png เพราะมี 2 ช่องที่ชื่อเหมือนกัน
    Wait Until Element Is Visible    xpath=(//input[@placeholder='พิมพ์ชื่อสถานที่...'])[1]    timeout=10s
    Input Text    xpath=(//input[@placeholder='พิมพ์ชื่อสถานที่...'])[1]    ${pickup}
    Input Text    xpath=(//input[@placeholder='พิมพ์ชื่อสถานที่...'])[2]    ${dropoff}
    Sleep    1s

Click Confirm Booking
    # ปุ่มสีน้ำเงินด้านล่างสุดของ Modal
    Click Button    xpath=//button[contains(@class,'bg-blue-600') and contains(text(),'ยืนยันการจอง')]

Verify Error Modal Is Shown
    [Arguments]    ${title}
    Wait Until Page Contains    ${title}    timeout=10s

Click Confirm In Error Modal
    Click Button    xpath=//button[contains(text(),'รับทราบ')]
    Sleep    1s

Verify Booking Modal Still Open
    Page Should Contain    ยืนยันการจอง

Verify Booking Success Toast
    Wait Until Page Contains    ส่งคำขอจองสำเร็จ    timeout=10s

Verify Warning Toast
    [Arguments]    ${msg}
    Wait Until Page Contains    ${msg}    timeout=10s

Take Named Screenshot
    [Arguments]    ${name}
    Capture Page Screenshot    filename=${name}.png