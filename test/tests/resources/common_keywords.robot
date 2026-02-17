*** Settings ***
Library    SeleniumLibrary

*** Variables ***
${BASE_URL}     http://localhost:3001
${BROWSER}      Chrome
${USERNAME}     ohm123
${PASSWORD}     namidablack1
${CONFIRM_TEXT}    ยืนยัน
${TIMEOUT}         5s

*** Keywords ***
เปิดเว็บ
    Open Browser    ${BASE_URL}    ${BROWSER}
    Maximize Browser Window

ปิดเว็บ
    Close Browser

ไปหน้า Login
    Go To    ${BASE_URL}/login
    Wait Until Page Contains    เข้าสู่ระบบ    ${TIMEOUT}

กรอกข้อมูล Login
    Wait Until Element Is Visible    id=identifier    ${TIMEOUT}
    Input Text    id=identifier    ${USERNAME}
    Input Text    id=password      ${PASSWORD}

กดปุ่ม Login
    Click Button    css=button[type="submit"]
    Wait Until Page Does Not Contain    เข้าสู่ระบบ    ${TIMEOUT}

ต้องอยู่หน้า Home
    Wait Until Page Contains    เดินทางร่วมกัน    ${TIMEOUT}
    Page Should Contain    ค้นหาเส้นทาง

ไปหน้าโปรไฟล์ผู้ใช้
    Go To    ${BASE_URL}/profile
    Wait Until Page Contains    บัญชีผู้ใช้    ${TIMEOUT}

กดปุ่มลบบัญชีจากหน้าโปรไฟล์
    Wait Until Page Contains    การลบบัญชีผู้ใช้    ${TIMEOUT}

ต้องอยู่หน้าลบบัญชี
    Page Should Contain    หากคุณลบบัญชี
    Page Should Contain    รับทราบข้อตกลง

กรอกข้อมูลยืนยันการลบ
    Click Element    css=input[type="checkbox"]
    Input Text       css=input[type="text"]    ${CONFIRM_TEXT}

ยืนยันลบบัญชี
    Wait Until Element Is Enabled    css=button:not([disabled])    ${TIMEOUT}
    Click Element    css=button:not([disabled])

ต้องเห็น popup ลบสำเร็จ
    Wait Until Page Contains    ลบบัญชีสำเร็จ    ${TIMEOUT}
    Page Should Contain    บัญชีของคุณถูกลบเรียบร้อยแล้ว
    Page Should Contain    ตกลง