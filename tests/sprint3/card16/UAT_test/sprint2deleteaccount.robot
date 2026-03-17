*** Settings ***
Resource    sprint216resources/sprint216keyword.robot
Suite Setup    เปิดเว็บ
Suite Teardown    ปิดเว็บ

*** Test Cases ***
ลบบัญชีแบบเลือกประวัติส่วนตัว

    ไปหน้า สมัครสมาชิก
    # ประกาศตัวแปรให้เป็นการสุ่มตัวเลขเพื่อใช้ในการทดสอบ
    ${rand}=    Generate Random String    5    1234567890
    ${username}=    Set Variable    test${rand}
    ${email}=       Set Variable    test${rand}@gmail.com

    Input Text    id=username           ${username}
    sleep    5
    Input Text    id=email              ${email}
    sleep    5
    Input Text    id=password           ${PASSWORD}
    sleep    5
    Input Text    id=confirmPassword    ${PASSWORD}
    sleep    5
    Click Button    xpath=//button[contains(text(),"ถัดไป")]

    Wait Until Page Contains    ข้อมูลส่วนตัว

    Input Text    id=firstName    ohm${rand}
    sleep    5
    Input Text    id=lastName     watth${rand}
    sleep    5
    Input Text    id=phoneNumber  0891234567
    sleep    5
    Click Element    xpath=//input[@value="male"]
    sleep    5
    Click Button    xpath=//button[contains(text(),"ถัดไป")]

    Wait Until Page Contains    ยืนยันตัวตน

    กรอกข้อมูลยืนยันตัวตน

    ไปหน้า Login
    Input Text    id=identifier    ${username}
    sleep    5
    Input Text    id=password      ${PASSWORD}
    sleep    5
    กดปุ่ม Login

    ไปหน้าโปรไฟล์ผู้ใช้
    เลือกประวัติส่วนตัว
    กรอกข้อมูลยืนยันการลบ
    ยืนยันลบบัญชี
    ต้องเห็น popup ลบสำเร็จ
    กดปุ่มตกลงใน popup
    ต้องเด้งไปหน้า Home
ลบบัญชีแบบเลือกประวัติการเดินทาง

    ไปหน้า สมัครสมาชิก
    ${rand}=    Generate Random String    5    1234567890
    ${username}=    Set Variable    test${rand}
    ${email}=       Set Variable    test${rand}@gmail.com

    Input Text    id=username           ${username}
    sleep    5
    Input Text    id=email              ${email}
    sleep    5
    Input Text    id=password           ${PASSWORD}
    sleep    5
    Input Text    id=confirmPassword    ${PASSWORD}
    sleep    5
    Click Button    xpath=//button[contains(text(),"ถัดไป")]

    Wait Until Page Contains    ข้อมูลส่วนตัว

    Input Text    id=firstName    ohm${rand}
    sleep    5
    Input Text    id=lastName     watth${rand}
    sleep    5
    Input Text    id=phoneNumber  0891234567
    sleep    5
    Click Element    xpath=//input[@value="male"]
    sleep    5
    Click Button    xpath=//button[contains(text(),"ถัดไป")]

    Wait Until Page Contains    ยืนยันตัวตน

    กรอกข้อมูลยืนยันตัวตน

    ไปหน้า Login
    Input Text    id=identifier    ${username}
    sleep    5
    Input Text    id=password      ${PASSWORD}
    sleep    5
    กดปุ่ม Login

    ไปหน้าโปรไฟล์ผู้ใช้
    เลือกประวัติการเดินทาง
    กรอกข้อมูลยืนยันการลบ
    ยืนยันลบบัญชี
    ต้องเห็น popup ลบสำเร็จ
    กดปุ่มตกลงใน popup
    ต้องเด้งไปหน้า Home

ลบบัญชีแบบเลือกประวัติการสร้างเส้นทางและข้อมูลรถยนต์ (กรณีเป็นผู้ขับขี่)

    ไปหน้า สมัครสมาชิก
    ${rand}=    Generate Random String    5    1234567890
    ${username}=    Set Variable    test${rand}
    ${email}=       Set Variable    test${rand}@gmail.com

    Input Text    id=username           ${username}
    sleep    5
    Input Text    id=email              ${email}
    sleep    5
    Input Text    id=password           ${PASSWORD}
    sleep    5
    Input Text    id=confirmPassword    ${PASSWORD}
    sleep    5
    Click Button    xpath=//button[contains(text(),"ถัดไป")]

    Wait Until Page Contains    ข้อมูลส่วนตัว

    Input Text    id=firstName    ohm${rand}
    sleep    5
    Input Text    id=lastName     watth${rand}
    sleep    5
    Input Text    id=phoneNumber  0891234567
    sleep    5
    Click Element    xpath=//input[@value="male"]
    sleep    5
    Click Button    xpath=//button[contains(text(),"ถัดไป")]

    Wait Until Page Contains    ยืนยันตัวตน

    กรอกข้อมูลยืนยันตัวตน

    ไปหน้า Login
    Input Text    id=identifier    ${username}
    sleep    5
    Input Text    id=password      ${PASSWORD}
    sleep    5
    กดปุ่ม Login

    ไปหน้าโปรไฟล์ผู้ใช้
    เลือกประวัติการสร้างเส้นทางและข้อมูลรถยนต์ (กรณีเป็นผู้ขับขี่)
    กรอกข้อมูลยืนยันการลบ
    ยืนยันลบบัญชี
    ต้องเห็น popup ลบสำเร็จ
    กดปุ่มตกลงใน popup
    ต้องเด้งไปหน้า Home

ลบบัญชีแบบเลือกประวัติส่วนตัวและเลือกประวัติการเดินทาง

    ไปหน้า สมัครสมาชิก
    ${rand}=    Generate Random String    5    1234567890
    ${username}=    Set Variable    test${rand}
    ${email}=       Set Variable    test${rand}@gmail.com

    Input Text    id=username           ${username}
    sleep    5
    Input Text    id=email              ${email}
    sleep    5
    Input Text    id=password           ${PASSWORD}
    sleep    5
    Input Text    id=confirmPassword    ${PASSWORD}
    sleep    5
    Click Button    xpath=//button[contains(text(),"ถัดไป")]

    Wait Until Page Contains    ข้อมูลส่วนตัว

    Input Text    id=firstName    ohm${rand}
    sleep    5
    Input Text    id=lastName     watth${rand}
    sleep    5
    Input Text    id=phoneNumber  0891234567
    sleep    5
    Click Element    xpath=//input[@value="male"]
    sleep    5
    Click Button    xpath=//button[contains(text(),"ถัดไป")]

    Wait Until Page Contains    ยืนยันตัวตน

    กรอกข้อมูลยืนยันตัวตน

    ไปหน้า Login
    Input Text    id=identifier    ${username}
    sleep    5
    Input Text    id=password      ${PASSWORD}
    sleep    5
    กดปุ่ม Login

    ไปหน้าโปรไฟล์ผู้ใช้
    เลือกประวัติส่วนตัว
    เลือกประวัติการเดินทาง
    กรอกข้อมูลยืนยันการลบ
    ยืนยันลบบัญชี
    ต้องเห็น popup ลบสำเร็จ
    กดปุ่มตกลงใน popup
    ต้องเด้งไปหน้า Home

ลบบัญชีแบบเลือกประวัติส่วนตัวและเลือกประวัติการสร้างเส้นทางและข้อมูลรถยนต์ (กรณีเป็นผู้ขับขี่)

    ไปหน้า สมัครสมาชิก
    ${rand}=    Generate Random String    5    1234567890
    ${username}=    Set Variable    test${rand}
    ${email}=       Set Variable    test${rand}@gmail.com

    Input Text    id=username           ${username}
    sleep    5
    Input Text    id=email              ${email}
    sleep    5
    Input Text    id=password           ${PASSWORD}
    sleep    5
    Input Text    id=confirmPassword    ${PASSWORD}
    sleep    5
    Click Button    xpath=//button[contains(text(),"ถัดไป")]

    Wait Until Page Contains    ข้อมูลส่วนตัว

    Input Text    id=firstName    ohm${rand}
    sleep    5
    Input Text    id=lastName     watth${rand}
    sleep    5
    Input Text    id=phoneNumber  0891234567
    sleep    5
    Click Element    xpath=//input[@value="male"]
    sleep    5
    Click Button    xpath=//button[contains(text(),"ถัดไป")]

    Wait Until Page Contains    ยืนยันตัวตน

    กรอกข้อมูลยืนยันตัวตน

    ไปหน้า Login
    Input Text    id=identifier    ${username}
    sleep    5
    Input Text    id=password      ${PASSWORD}
    sleep    5
    กดปุ่ม Login

    ไปหน้าโปรไฟล์ผู้ใช้
    เลือกประวัติส่วนตัว
    เลือกประวัติการสร้างเส้นทางและข้อมูลรถยนต์ (กรณีเป็นผู้ขับขี่)
    กรอกข้อมูลยืนยันการลบ
    ยืนยันลบบัญชี
    ต้องเห็น popup ลบสำเร็จ
    กดปุ่มตกลงใน popup
    ต้องเด้งไปหน้า Home

ลบบัญชีแบบเลือกประวัติการเดินทางและเลือกประวัติการสร้างเส้นทางและข้อมูลรถยนต์ (กรณีเป็นผู้ขับขี่)

    ไปหน้า สมัครสมาชิก
    ${rand}=    Generate Random String    5    1234567890
    ${username}=    Set Variable    test${rand}
    ${email}=       Set Variable    test${rand}@gmail.com

    Input Text    id=username           ${username}
    sleep    5
    Input Text    id=email              ${email}
    sleep    5
    Input Text    id=password           ${PASSWORD}
    sleep    5
    Input Text    id=confirmPassword    ${PASSWORD}
    sleep    5
    Click Button    xpath=//button[contains(text(),"ถัดไป")]

    Wait Until Page Contains    ข้อมูลส่วนตัว

    Input Text    id=firstName    ohm${rand}
    sleep    5
    Input Text    id=lastName     watth${rand}
    sleep    5
    Input Text    id=phoneNumber  0891234567
    sleep    5
    Click Element    xpath=//input[@value="male"]
    sleep    5
    Click Button    xpath=//button[contains(text(),"ถัดไป")]

    Wait Until Page Contains    ยืนยันตัวตน

    กรอกข้อมูลยืนยันตัวตน

    ไปหน้า Login
    Input Text    id=identifier    ${username}
    sleep    5
    Input Text    id=password      ${PASSWORD}
    sleep    5
    กดปุ่ม Login

    ไปหน้าโปรไฟล์ผู้ใช้
    เลือกประวัติการเดินทาง
    เลือกประวัติการสร้างเส้นทางและข้อมูลรถยนต์ (กรณีเป็นผู้ขับขี่)
    กรอกข้อมูลยืนยันการลบ
    ยืนยันลบบัญชี
    ต้องเห็น popup ลบสำเร็จ
    กดปุ่มตกลงใน popup
    ต้องเด้งไปหน้า Home


ลบบัญชีแบบเลือกทั้ง 3 แบบ

    ไปหน้า สมัครสมาชิก
    ${rand}=    Generate Random String    5    1234567890
    ${username}=    Set Variable    test${rand}
    ${email}=       Set Variable    test${rand}@gmail.com

    Input Text    id=username           ${username}
    sleep    5
    Input Text    id=email              ${email}
    sleep    5
    Input Text    id=password           ${PASSWORD}
    sleep    5
    Input Text    id=confirmPassword    ${PASSWORD}
    sleep    5
    Click Button    xpath=//button[contains(text(),"ถัดไป")]

    Wait Until Page Contains    ข้อมูลส่วนตัว

    Input Text    id=firstName    ohm${rand}
    sleep    5
    Input Text    id=lastName     watth${rand}
    sleep    5
    Input Text    id=phoneNumber  0891234567
    sleep    5
    Click Element    xpath=//input[@value="male"]
    sleep    5
    Click Button    xpath=//button[contains(text(),"ถัดไป")]

    Wait Until Page Contains    ยืนยันตัวตน

    กรอกข้อมูลยืนยันตัวตน

    ไปหน้า Login
    Input Text    id=identifier    ${username}
    sleep    5
    Input Text    id=password      ${PASSWORD}
    sleep    5
    กดปุ่ม Login

    ไปหน้าโปรไฟล์ผู้ใช้
    เลือกประวัติส่วนตัว
    เลือกประวัติการเดินทาง
    เลือกประวัติการสร้างเส้นทางและข้อมูลรถยนต์ (กรณีเป็นผู้ขับขี่)
    กรอกข้อมูลยืนยันการลบ
    ยืนยันลบบัญชี
    ต้องเห็น popup ลบสำเร็จ
    กดปุ่มตกลงใน popup
    ต้องเด้งไปหน้า Home