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
    [Arguments]    ${check_pdpa}=False
    Run Keyword If    '${check_pdpa}' == 'True'
    ...    Click Element    css=input[name="pdpa_request"][value="true"]
    ...    ELSE
    ...    Click Element    css=input[name="pdpa_request"][value="false"]
    Click Element    xpath=//label[contains(.,'รับทราบข้อตกลง')]//input[@type='checkbox']
    Input Text    css=input[placeholder="พิมพ์คำว่า ยืนยัน"]    ${CONFIRM_TEXT}

    Sleep    1s

ยืนยันลบบัญชี
    Wait Until Element Is Enabled    css=button:not([disabled])    ${TIMEOUT}
    Click Element    css=button:not([disabled])

ตรวจสอบ Popup ลบสำเร็จ
    Run Keyword And Continue On Failure    Wait Until Page Contains    ลบบัญชีสำเร็จ    20s
    ${source}=    Get Source
    Log    Page Source: ${source}
    Page Should Contain    ลบบัญชีสำเร็จ