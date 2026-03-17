*** Settings ***
Library    SeleniumLibrary
Library    RequestsLibrary
Library    Collections
Library    String
Library    DateTime
Library    OperatingSystem
Resource    ../../../../resources/forCreateTestUser.robot
Resource    ../../../../resources/services/driver_service.robot
Resource    ../../../../resources/services/passenger_service.robot
Resource    ../../../../resources/services/admin_serive.robot
Resource    ../../../../resources/variables.robot

*** Variables ***
${FRONTEND_URL}     http://localhost:3001
${BROWSER}          Chrome
${CONFIRM_TEXT}     ยืนยัน
${TIMEOUT}          10s

*** Keywords ***

เปิดเว็บ
    Open Browser    ${FRONTEND_URL}    ${BROWSER}
    Maximize Browser Window

ปิดเว็บ
    Close Browser

ล็อกอินด้วยข้อมูล
    [Arguments]    ${email}    ${password}
    Go To    ${FRONTEND_URL}/login
    Wait Until Element Is Visible    id=identifier    ${TIMEOUT}
    Input Text    id=identifier    ${email}
    Input Text    id=password      ${password}
    Click Button    css=button[type="submit"]
    Wait Until Page Does Not Contain    เข้าสู่ระบบ    ${TIMEOUT}
    Wait Until Page Contains    เดินทางร่วมกัน    ${TIMEOUT}

ไปหน้าลบบัญชี
    Go To    ${FRONTEND_URL}/profile/deleteAccount
    Wait Until Page Contains    การลบบัญชีผู้ใช้    ${TIMEOUT}

กรอกข้อมูลเพื่อลบบัญชี
    Execute Javascript    window.scrollTo(0, 0)
    Sleep    0.5s

    ${cb_profile}=    Get WebElement
    ...    xpath=//label[contains(.,'ประวัติส่วนตัว')]//input[@type='checkbox']
    Execute Javascript
    ...    arguments[0].checked = true; arguments[0].dispatchEvent(new Event('input', {bubbles: true})); arguments[0].dispatchEvent(new Event('change', {bubbles: true}));
    ...    ARGUMENTS    ${cb_profile}
    Sleep    1s

    ${cb_accept}=    Get WebElement
    ...    xpath=//label[contains(.,'รับทราบข้อตกลง')]//input[@type='checkbox']
    Scroll Element Into View    ${cb_accept}
    Execute Javascript
    ...    arguments[0].checked = true; arguments[0].dispatchEvent(new Event('input', {bubbles: true})); arguments[0].dispatchEvent(new Event('change', {bubbles: true}));
    ...    ARGUMENTS    ${cb_accept}
    Sleep    1s

    ${input}=    Get WebElement    css=input[placeholder="พิมพ์คำว่า ยืนยัน"]
    Scroll Element Into View    ${input}
    Click Element    ${input}
    Input Text    ${input}    ${CONFIRM_TEXT}
    Sleep    2s

กดปุ่มยืนยันลบบัญชี
    Scroll Element Into View    xpath=//button[contains(text(),'ยืนยันการลบข้อมูล')]
    Wait Until Element Is Visible    xpath=//button[contains(text(),'ยืนยันการลบข้อมูล')]    ${TIMEOUT}
    Wait Until Element Is Enabled    xpath=//button[contains(text(),'ยืนยันการลบข้อมูล')]    ${TIMEOUT}
    Click Element    xpath=//button[contains(text(),'ยืนยันการลบข้อมูล')]
    Sleep    3s
    ${source}=    Get Source
    Log    PAGE SOURCE AFTER DELETE: ${source}

ตรวจสอบ Popup ลบสำเร็จ
    Wait Until Page Contains    ลบบัญชีสำเร็จ    20s
    Page Should Contain    เราได้ทำการลบข้อมูลของบัญชีเรียบร้อยแล้ว

กด ตกลง แล้วตรวจสอบ redirect
    Wait Until Element Is Visible    xpath=//button[contains(text(),'ตกลง')]    ${TIMEOUT}
    Click Element    xpath=//button[contains(text(),'ตกลง')]
    Wait Until Location Is    ${FRONTEND_URL}/    ${TIMEOUT}

ตรวจสอบ Popup ลบไม่สำเร็จ (มีการเดินทางค้างอยู่)
    Sleep    2s

    ${has_modal}=    Run Keyword And Return Status
    ...    Page Should Contain    ไม่สามารถลบบัญชีได้
    ${has_toast}=    Run Keyword And Return Status
    ...    Page Should Contain    ล้มเหลว
    Should Be True    ${has_modal} or ${has_toast}
    ...    msg=ไม่พบ modal หรือ toast แจ้งว่าลบไม่ได้

ตรวจสอบว่าปุ่มยืนยันลบยัง Disabled อยู่
    Element Should Be Disabled    xpath=//button[contains(text(),'ยืนยันการลบข้อมูล')]


สร้าง Session สำหรับ User
    [Arguments]    ${test_user}    ${session_name}
    [Documentation]    Login ผ่าน API และสร้าง session สำหรับใช้ใน API calls
    ${token}=    เข้าสู่ระบบด้วย Test User    ${test_user}
    &{headers}=    Create Dictionary
    ...    Authorization=Bearer ${token}
    ...    x-gateway-key=${X-GATEWAY-KEY}
    Create Session    ${session_name}    ${BASE_URL}    headers=${headers}    disable_warnings=1
    RETURN    ${token}

สร้าง Driver พร้อม Route ค้างอยู่
    [Documentation]    สร้าง driver → สร้างรถ → verify → admin approve → สร้าง route
    # (สังเกตว่า setup.robot สร้างรถก่อน verify ได้)

    ${driver_user}=    สร้าง Test User ใหม่
    ${driver_email}=   Get From Dictionary    ${driver_user}    email

    ${driver_token}    ${driver_id}=    Login And Get Token
    ...    user_email=${driver_email}
    ...    user_password=TestPassword123
    &{driver_headers}=    Create Dictionary
    ...    Authorization=Bearer ${driver_token}
    ...    x-gateway-key=${X-GATEWAY-KEY}
    Create Session    DriverTestSession    ${BASE_URL}
    ...    headers=${driver_headers}    disable_warnings=1

    ${admin_token}    ${admin_id}=    Login And Get Token
    ...    user_email=${ADMIN_EMAIL}
    ...    user_password=${ADMIN_PASSWORD}
    &{admin_headers}=    Create Dictionary
    ...    Authorization=Bearer ${admin_token}
    ...    x-gateway-key=${X-GATEWAY-KEY}
    Create Session    AdminTestSession    ${BASE_URL}
    ...    headers=${admin_headers}    disable_warnings=1

    ${RANDOM_ID}=    Generate Random String    length=6    chars=0123456789
    ${plate}=        Catenate    SEPARATOR=    กข    ${RANDOM_ID}

    ${vehicle_data}=    Evaluate
    ...    [('vehicleModel','Toyota'),('licensePlate','${plate}'),('vehicleType','sedan'),('color','black'),('seatCapacity','4'),('isDefault','true'),('amenities','Music'),('amenities','WiFi')]

    ${frontImage}=    Get File For Streaming Upload    ${CURDIR}/../../resources/services/../vehicleImage/front.png
    ${sideImage}=     Get File For Streaming Upload    ${CURDIR}/../../resources/services/../vehicleImage/side.png
    ${inSideImage}=   Get File For Streaming Upload    ${CURDIR}/../../resources/services/../vehicleImage/inSide.png
    ${files}=    Create List
    ...    ${{ ("photos", ("front.png", $frontImage, "image/png")) }}
    ...    ${{ ("photos", ("side.png", $sideImage, "image/png")) }}
    ...    ${{ ("photos", ("inSide.png", $inSideImage, "image/png")) }}

    ${lib}=       Get Library Instance    RequestsLibrary
    ${sess}=      Call Method    ${lib._cache}    get_connection    DriverTestSession
    ${veh_res}=   Call Method    ${sess}    request
    ...    POST    ${CREATE_VEHICLE_URL}
    ...    data=${vehicle_data}
    ...    files=${files}
    ${veh_json}=    Set Variable    ${veh_res.json()}

    Log    Vehicle Response: ${veh_json}
    Should Be True    ${veh_json}[success]    msg=Create Vehicle failed: ${veh_json}
    ${vehicle_id}=    Get From Dictionary    ${veh_json}[data]    id

    Driver Verification
    ...    sessionName=DriverTestSession
    ...    licenseNumber=${RANDOM_ID}
    ...    firstNameOnLicense=TestDriver
    ...    lastNameOnLicense=TestDriver
    ...    typeOnLicense=LIFETIME
    ...    licenseIssueDate=2020-01-01T00:00:00.000Z
    ...    licenseExpiryDate=2030-01-01T00:00:00.000Z

    Admin Verifired Driver
    ...    sessionName=AdminTestSession
    ...    userId=${driver_id}
    ...    isVerified=${{True}}

    &{start}=    Create Dictionary
    ...    lat=${16.432}    lng=${102.823}
    ...    name=ขอนแก่น    address=ขอนแก่น
    &{end}=    Create Dictionary
    ...    lat=${13.756}    lng=${100.501}
    ...    name=กรุงเทพ    address=กรุงเทพ
    @{waypoints}=    Create List

    ${route_response}=    Driver Create Route
    ...    sessionName=DriverTestSession
    ...    vehicleId=${vehicle_id}
    ...    startLocation=${start}
    ...    endLocation=${end}
    ...    waypoints=${waypoints}
    ...    departureTime=2027-12-31T08:00:00.000Z
    ...    seats=${4}
    ...    price=${100}
    ...    conditions=Test

    Log    Route Response: ${route_response}
    Should Be True    ${route_response}[success]    msg=Create Route failed: ${route_response}
    ${route_id}=    Get From Dictionary    ${route_response}[data]    id
    Set To Dictionary    ${driver_user}    route_id=${route_id}

    RETURN    ${driver_user}

สร้าง Passenger พร้อม Booking ค้างอยู่
    [Documentation]    สร้าง passenger user → จองเส้นทาง (active) → return test_user
    ...                ต้องการ route ที่ active อยู่ก่อน (ส่งผ่าน argument)
    [Arguments]    ${route_id}

    ${passenger_user}=    สร้าง Test User ใหม่
    ${token}=             สร้าง Session สำหรับ User    ${passenger_user}    PassengerTestSession

    &{pickup}=    Create Dictionary
    ...    lat=${14.973}    lng=${102.083}
    ...    name=นครราชสีมา    address=นครราชสีมา    placeId=test
    &{dropoff}=    Create Dictionary
    ...    lat=${16.432}    lng=${102.823}
    ...    name=ขอนแก่น    address=ขอนแก่น    placeId=test
    ${booking_response}=    Passenger Bookings Route
    ...    sessionName=PassengerTestSession
    ...    routeId=${route_id}
    ...    numberOfSeats=${1}
    ...    pickupLocation=${pickup}
    ...    dropoffLocation=${dropoff}

    RETURN    ${passenger_user}

ลบ User ผ่าน Admin API
    [Arguments]    ${user_id}    ${admin_token}
    &{headers}=    Create Dictionary    Authorization=Bearer ${admin_token}
    Create Session    AdminCleanupSession    ${BASE_URL}    headers=${headers}    disable_warnings=1
    ${response}=    DELETE On Session
    ...    AdminCleanupSession
    ...    /api/users/admin/${user_id}
    ...    expected_status=any
    Log    Cleanup user ${user_id}: ${response.status_code}

*** Test Cases ***

TC01: ลบบัญชีสำเร็จ (ไม่มีการเดินทางค้างอยู่)
    [Documentation]    สร้าง test user → login → กรอกข้อมูล → ลบบัญชี → ตรวจสอบ redirect
    [Tags]    delete_account    happy_path

    ${test_user}=    สร้าง Test User ใหม่
    ${email}=        Get From Dictionary    ${test_user}    email
    ${password}=     Get From Dictionary    ${test_user}    password

    เปิดเว็บ
    ล็อกอินด้วยข้อมูล    ${email}    ${password}
    ไปหน้าลบบัญชี
    กรอกข้อมูลเพื่อลบบัญชี
    กดปุ่มยืนยันลบบัญชี
    ตรวจสอบ Popup ลบสำเร็จ
    กด ตกลง แล้วตรวจสอบ redirect

    [Teardown]    ปิดเว็บ


TC02: ลบบัญชีไม่ได้ เมื่อไม่ได้เลือกข้อมูลที่ต้องการรับ
    [Documentation]    ไม่ติ๊ก checkbox ข้อมูลใดเลย → ปุ่มต้อง disabled
    [Tags]    delete_account    negative    ui

    ${test_user}=    สร้าง Test User ใหม่
    ${email}=        Get From Dictionary    ${test_user}    email
    ${password}=     Get From Dictionary    ${test_user}    password

    เปิดเว็บ
    ล็อกอินด้วยข้อมูล    ${email}    ${password}
    ไปหน้าลบบัญชี

    Click Element    xpath=//label[contains(.,'รับทราบข้อตกลง')]//input[@type='checkbox']
    Input Text    css=input[placeholder="พิมพ์คำว่า ยืนยัน"]    ${CONFIRM_TEXT}
    Sleep    1s

    ตรวจสอบว่าปุ่มยืนยันลบยัง Disabled อยู่
    Page Should Contain    กรุณาเลือกข้อมูลอย่างน้อย 1 รายการ

    [Teardown]    Run Keywords
    ...    ลบ Test User หลังจากทดสอบเสร็จ    ${test_user}
    ...    AND    ปิดเว็บ


TC03: ลบบัญชีไม่ได้ เมื่อไม่ได้ติ๊ก checkbox รับทราบข้อตกลง
    [Documentation]    เลือกข้อมูลแล้ว + พิมพ์ยืนยัน แต่ไม่ติ๊ก "รับทราบข้อตกลง" → ปุ่มต้อง disabled
    [Tags]    delete_account    negative    ui

    ${test_user}=    สร้าง Test User ใหม่
    ${email}=        Get From Dictionary    ${test_user}    email
    ${password}=     Get From Dictionary    ${test_user}    password

    เปิดเว็บ
    ล็อกอินด้วยข้อมูล    ${email}    ${password}
    ไปหน้าลบบัญชี

    Click Element    xpath=//label[contains(.,'ประวัติส่วนตัว')]//input[@type='checkbox']
    Input Text    css=input[placeholder="พิมพ์คำว่า ยืนยัน"]    ${CONFIRM_TEXT}
    Sleep    1s

    ตรวจสอบว่าปุ่มยืนยันลบยัง Disabled อยู่

    [Teardown]    Run Keywords
    ...    ลบ Test User หลังจากทดสอบเสร็จ    ${test_user}
    ...    AND    ปิดเว็บ


TC04: ลบบัญชีไม่ได้ เมื่อพิมพ์คำยืนยันผิด
    [Documentation]    ทำครบทุกขั้นตอนแต่พิมพ์คำยืนยันผิด → ปุ่มต้อง disabled
    [Tags]    delete_account    negative    ui

    ${test_user}=    สร้าง Test User ใหม่
    ${email}=        Get From Dictionary    ${test_user}    email
    ${password}=     Get From Dictionary    ${test_user}    password

    เปิดเว็บ
    ล็อกอินด้วยข้อมูล    ${email}    ${password}
    ไปหน้าลบบัญชี

    Click Element    xpath=//label[contains(.,'ประวัติส่วนตัว')]//input[@type='checkbox']
    Click Element    xpath=//label[contains(.,'รับทราบข้อตกลง')]//input[@type='checkbox']
    Input Text    css=input[placeholder="พิมพ์คำว่า ยืนยัน"]    ผิด
    Sleep    1s

    ตรวจสอบว่าปุ่มยืนยันลบยัง Disabled อยู่

    [Teardown]    Run Keywords
    ...    ลบ Test User หลังจากทดสอบเสร็จ    ${test_user}
    ...    AND    ปิดเว็บ


TC05: ลบบัญชีไม่ได้ เมื่อมี Route ค้างอยู่ (Driver)
    [Documentation]    สร้าง driver → สร้าง route ที่ยังไม่เสร็จ → ลองลบบัญชี
    ...                → ต้อง popup "ไม่สามารถลบบัญชีได้"
    [Tags]    delete_account    negative    business_logic    driver

    ${driver_user}=    สร้าง Driver พร้อม Route ค้างอยู่
    ${email}=          Get From Dictionary    ${driver_user}    email
    ${password}=       Get From Dictionary    ${driver_user}    password

    เปิดเว็บ
    ล็อกอินด้วยข้อมูล    ${email}    ${password}
    ไปหน้าลบบัญชี
    กรอกข้อมูลเพื่อลบบัญชี
    กดปุ่มยืนยันลบบัญชี

    ตรวจสอบ Popup ลบไม่สำเร็จ (มีการเดินทางค้างอยู่)
    
    ลบ Test User หลังจากทดสอบเสร็จ    ${driver_user}
    กด ตกลง แล้วตรวจสอบ redirect
    [Teardown]    ปิดเว็บ


TC06: ลบบัญชีไม่ได้ เมื่อมี Booking ค้างอยู่ (Passenger)
    [Tags]    delete_account    negative    business_logic    passenger

    ${driver_user}=    สร้าง Driver พร้อม Route ค้างอยู่
    ${route_id}=       Get From Dictionary    ${driver_user}    route_id

    ${passenger_user}=    สร้าง Passenger พร้อม Booking ค้างอยู่    ${route_id}
    ${email}=             Get From Dictionary    ${passenger_user}    email
    ${password}=          Get From Dictionary    ${passenger_user}    password

    เปิดเว็บ
    ล็อกอินด้วยข้อมูล    ${email}    ${password}
    ไปหน้าลบบัญชี
    กรอกข้อมูลเพื่อลบบัญชี
    กดปุ่มยืนยันลบบัญชี
    ตรวจสอบ Popup ลบไม่สำเร็จ (มีการเดินทางค้างอยู่)

    
    ลบ Test User หลังจากทดสอบเสร็จ    ${passenger_user}
    ลบ Test User หลังจากทดสอบเสร็จ    ${driver_user}
    กด ตกลง แล้วตรวจสอบ redirect
    [Teardown]    ปิดเว็บ
