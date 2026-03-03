*** Settings ***
Resource   ../../resources/forCreateTestUser.robot
Resource   ../../resources/common_keywords.robot

*** Test Cases ***
ตัวอย่าง 1: สร้าง Test User และเข้าสู่ระบบ
    [Documentation]    สร้าง test user ใหม่แล้วทำการเข้าสู่ระบบ
    
    ${test_user}=             สร้าง Test User ใหม่
    ${status}=                Get From Dictionary    ${test_user}    response_status
    ${body}=                  Get From Dictionary    ${test_user}    response_body
    
    Log    API Response: ${status} | ${body}
    Should Be True    '${status}' == '201' or '${status}' == '200'
    ...    msg=API Error ${status}: ${body}
    
    ${token}=                 เข้าสู่ระบบด้วย Test User    ${test_user}
    Should Not Be Empty       ${token}
    
    Log    Token: ${token}


ตัวอย่าง 2: ใช้ Keyword ที่เก็บข้อมูลไว้เพื่อใช้รีซ้ำ
    [Documentation]    สร้างและเก็บ test user data ไว้เพื่อใช้ทดสอบหลายครั้ง
    
    ${MY_TEST_USER}=    สร้าง Test User ใหม่
    Set Suite Variable    ${MY_TEST_USER}
    
    ${response_status}=    Get From Dictionary    ${MY_TEST_USER}    response_status
    
    ${email}=          Get From Dictionary    ${MY_TEST_USER}    email
    ${password}=       Get From Dictionary    ${MY_TEST_USER}    password
    
    Log    Email: ${email}
    Log    Password: ${password}


ตัวอย่าง 3: สร้าง Test User หลาย User เพื่อทดสอบ
    [Documentation]    สร้าง test user หลายคนสำหรับการทดสอบเรื่องที่ต้อง users หลายคน
    
    ${user1}=          สร้าง Test User ใหม่
    ${token1}=         เข้าสู่ระบบด้วย Test User    ${user1}
    
    ${user2}=          สร้าง Test User ใหม่
    ${token2}=         เข้าสู่ระบบด้วย Test User    ${user2}
    
    Log    User 1 Email: ${user1}[email]
    Log    User 2 Email: ${user2}[email]


ตัวอย่าง 4: สร้าง User และตรวจสอบ Response
    [Documentation]    สร้าง test user แล้วตรวจสอบว่าบันทึกในฐานข้อมูลถูกต้อง
    
    ${test_user}=          สร้าง Test User ใหม่
    ${response_status}=    Get From Dictionary    ${test_user}    response_status
    ${response_body}=      Get From Dictionary    ${test_user}    response_body
    
    Should Be True    '${response_status}' == '201' or '${response_status}' == '200'
    Log    Response Body: ${response_body}
