*** Settings ***
Library    SeleniumLibrary
Library    String

*** Variables ***
${BASE_URL}        http://localhost:3001
${BROWSER}         Chrome
${PASSWORD}        Namidablack1
${CONFIRM_TEXT}    ยืนยัน

*** Keywords ***

เปิดเว็บ
    Open Browser    ${BASE_URL}    ${BROWSER}
    Maximize Browser Window
    Set Selenium Timeout    10s

ปิดเว็บ
    Close Browser


ไปหน้า Login
    Go To    ${BASE_URL}/login
    Wait Until Page Contains Element    id=identifier


กดปุ่ม Login
    Click Button    xpath=//button[contains(text(),"เข้าสู่ระบบ")]
    Wait Until Location Does Not Contain    /login


ไปหน้า สมัครสมาชิก
    Go To    ${BASE_URL}/register
    Wait Until Page Contains    สมัครสมาชิก


กรอกข้อมูลยืนยันตัวตน
    ${random_id}=    Generate Random String    13    1234567890
    Choose File    id=idCardFile    ${CURDIR}/idcard1.jpg
    sleep    5
    Input Text     id=idNumber      ${random_id}
    sleep    5
    Input Text     id=expiryDate    01/01/2030
    sleep    5
    Choose File    id=selfieFile    ${CURDIR}/selfie1.jpg
    sleep    5
    Click Element    xpath=//input[@type="checkbox"]
    sleep    5
    Click Button    xpath=//button[contains(text(),"สมัครสมาชิก")]
    sleep    5
    Wait Until Location Contains    /login


ไปหน้าโปรไฟล์ผู้ใช้
    Go To    ${BASE_URL}/profile/deleteAccount
    Wait Until Page Contains    การลบบัญชีผู้ใช้
    sleep    5

เลือกประวัติส่วนตัว
    Wait Until Element Is Visible    xpath=//span[contains(text(),"ประวัติส่วนตัว")]/preceding-sibling::input
    Click Element    xpath=//span[contains(text(),"ประวัติส่วนตัว")]/preceding-sibling::input
    sleep    5

เลือกประวัติการเดินทาง
    Wait Until Element Is Visible    xpath=//span[contains(text(),"ประวัติการเดินทาง")]/preceding-sibling::input
    Click Element    xpath=//span[contains(text(),"ประวัติการเดินทาง")]/preceding-sibling::input
    sleep    5

เลือกประวัติการสร้างเส้นทางและข้อมูลรถยนต์ (กรณีเป็นผู้ขับขี่)
    Wait Until Element Is Visible    xpath=//span[contains(text(),"ประวัติการสร้างเส้นทางและข้อมูลรถยนต์ (กรณีเป็นผู้ขับขี่)")]/preceding-sibling::input
    Click Element    xpath=//span[contains(text(),"ประวัติการสร้างเส้นทางและข้อมูลรถยนต์ (กรณีเป็นผู้ขับขี่)")]/preceding-sibling::input
    sleep    5

กรอกข้อมูลยืนยันการลบ
    Click Element    xpath=//span[contains(text(),"รับทราบข้อตกลง")]/preceding-sibling::input
    Input Text    xpath=//input[@placeholder="พิมพ์คำว่า ยืนยัน"]    ${CONFIRM_TEXT}
    sleep    5


ยืนยันลบบัญชี
    Wait Until Element Is Enabled    xpath=//button[contains(text(),"ยืนยันการลบข้อมูล")]
    Click Button    xpath=//button[contains(text(),"ยืนยันการลบข้อมูล")]
    sleep    5


ต้องเห็น popup ลบสำเร็จ
    Wait Until Page Contains    ลบบัญชีสำเร็จ 
    sleep    5

กดปุ่มตกลงใน popup
    Wait Until Element Is Visible    xpath=//div[contains(@class,"modal-content")]//button[contains(text(),"ตกลง")]
    Click Button    xpath=//div[contains(@class,"modal-content")]//button[contains(text(),"ตกลง")]
    sleep    5


ต้องเด้งไปหน้า Home
    Wait Until Location Is    ${BASE_URL}/