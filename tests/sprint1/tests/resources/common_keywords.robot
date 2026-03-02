*** Settings ***
Library    SeleniumLibrary

*** Variables ***
${BASE_URL}        http://localhost:3001
${BROWSER}         Chrome
${USERNAME}        ohm123
${PASSWORD}        namidablack1
${CONFIRM_TEXT}    ยืนยัน


*** Keywords ***
เปิดเว็บ
    Open Browser    ${BASE_URL}    ${BROWSER}
    Maximize Browser Window

ปิดเว็บ
    Close Browser


ไปหน้า Login
    Go To    ${BASE_URL}/login
    Wait Until Page Contains    เข้าสู่ระบบ
    sleep    5s


กรอกข้อมูล Login
    Wait Until Element Is Visible    id=identifier    
    Input Text    id=identifier    ${USERNAME}
    sleep    5s

    Input Text    id=password    ${PASSWORD}
    sleep    5s


กดปุ่ม Login
    Click Button    xpath=//button[contains(text(),"เข้าสู่ระบบ")]
    Wait Until Page Does Not Contain    เข้าสู่ระบบ    
    sleep    5s


ไปหน้าโปรไฟล์ผู้ใช้
    Go To    ${BASE_URL}/profile/deleteAccount
    Wait Until Page Contains    การลบบัญชีผู้ใช้    
    sleep    5s


เลือก ไม่รับสำเนาข้อมูล
    Click Element    xpath=//span[contains(text(),"ไม่, ฉันไม่ต้องการรับข้อมูล")]/preceding-sibling::input
    sleep    5s


เลือก รับสำเนาข้อมูล
    Click Element    xpath=//span[contains(text(),"ใช่, ฉันต้องการรับสำเนาข้อมูล")]/preceding-sibling::input
    sleep    5s


กรอกข้อมูลยืนยันการลบ
    Click Element    xpath=//input[@type="checkbox"]
    sleep    5s

    Input Text    xpath=//input[@placeholder="พิมพ์คำว่า ยืนยัน"]    ${CONFIRM_TEXT}
    sleep    5s


ยืนยันลบบัญชี
    Wait Until Element Is Enabled    xpath=//button[contains(text(),"ยืนยันการลบข้อมูล")]   
    Click Element    xpath=//button[contains(text(),"ยืนยันการลบข้อมูล")]
    sleep    5s


ต้องเห็น popup ลบสำเร็จ
    Wait Until Page Contains    ลบบัญชีสำเร็จ   
    Page Should Contain    บัญชีของคุณถูกลบเรียบร้อยแล้ว
    sleep    5s


ต้องไม่เห็นส่วนดาวน์โหลดข้อมูล
    Page Should Not Contain    คลิกเพื่อดาวน์โหลด
    Page Should Not Contain    ฉันดาวน์โหลดข้อมูลเรียบร้อยแล้ว
    sleep    5s


ต้องเห็นส่วนดาวน์โหลดข้อมูล
    Page Should Contain    คลิกเพื่อดาวน์โหลด
    Page Should Contain    ฉันดาวน์โหลดข้อมูลเรียบร้อยแล้ว
    sleep    5s

ต้องกดปุ่มตกลง
    Wait Until Element Is Visible    xpath=//button[contains(text(),"ตกลง")]
    Click Button    xpath=//button[contains(text(),"ตกลง")]
    Sleep    5s

ต้องเด้งไปหน้า Home
    Wait Until Location Contains    /
    sleep    5s

ดาวน์โหลดข้อมูลและยืนยัน
    Wait Until Element Is Visible    xpath=//button[contains(.,'ดาวน์โหลด')]    
    sleep    10s
    Click Element                    xpath=//button[contains(.,'ดาวน์โหลด')]

    Wait Until Element Is Visible    xpath=//span[contains(text(),"ฉันดาวน์โหลดข้อมูลเรียบร้อยแล้ว")]
    sleep    10s    
    Click Element                    xpath=//span[contains(text(),"ฉันดาวน์โหลดข้อมูลเรียบร้อยแล้ว")]

    Wait Until Element Is Enabled    xpath=//button[contains(.,'เสร็จสิ้น')]
    sleep    10s    
    Click Element                    xpath=//button[contains(.,'เสร็จสิ้น')]