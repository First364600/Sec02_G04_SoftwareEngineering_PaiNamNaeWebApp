*** Settings ***
Library           DatabaseLibrary
Library           RequestsLibrary
Library           Collections
Library           String
Resource          ../resources/api_keywords.robot

Suite Setup       เตรียมสภาพแวดล้อมการทดสอบ
Suite Teardown    Disconnect From Database

*** Test Cases ***

ทดสอบกฎหมาย 90 วัน: ข้อมูลเก่า 90 วันต้องยังดึงออกมาได้
    [Documentation]    จำลองการสร้างข้อมูลย้อนหลัง 90 วัน แล้วเช็คว่า API ยังส่งกลับมาไหม
    
    Admin เข้าสู่ระบบเพื่อขอ Token

    # สร้าง Action name แบบสุ่ม เพื่อใช้ค้นหาตอน verify
    ${random_num}=    Generate Random String    8    [NUMBERS]
    ${test_action}=   Set Variable    TEST_RETENTION_${random_num}

    # ยิง SQL เข้า DB (แก้ให้ตรงตาม Schema Prisma)
    Execute SQL String    INSERT INTO "SystemLog" ("action", "method", "endpoint", "ip_address", "created_at") VALUES ('${test_action}', 'TEST', '/manual/test', '127.0.0.1', NOW() - INTERVAL '90 days');

    Log    Inject ข้อมูลย้อนหลัง 90 วันเรียบร้อย: Action=${test_action}

    # ยิง API ดึงข้อมูล
    &{headers}=       Create Dictionary    Authorization=${TOKEN}
    ${response}=      GET On Session    mysession    url=/api/logs?limit=100    headers=${headers}    expected_status=200

    # ตรวจสอบ: ต้องเจอ Action ที่เราเพิ่งยัดลงไป
    ${body_string}=   Convert To String    ${response.json()}
    Should Contain    ${body_string}       ${test_action}
    
    Log    Success! เจอข้อมูลเก่า 90 วัน ยืนยันว่าระบบเก็บข้อมูลถูกต้อง

    # ลบข้อมูลขยะทิ้ง โดยลบจาก Action ที่เราสร้าง
    Execute SQL String    DELETE FROM "SystemLog" WHERE "action" = '${test_action}';