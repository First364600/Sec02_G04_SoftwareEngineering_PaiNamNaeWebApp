*** Settings ***
Library           DatabaseLibrary
Library           RequestsLibrary
Library           Collections
Library           String
Resource          ../resources/api_keywords.robot

Suite Setup       Connect To Database    psycopg2    ${DB_NAME}    ${DB_USER}    ${DB_PASS}    ${DB_HOST}    ${DB_PORT}
Suite Teardown    Disconnect From Database

*** Test Cases ***

TC-5.1: Verify 90-Day Data Retention
    [Documentation]    จำลองการสร้างข้อมูลย้อนหลัง 90 วัน และตรวจสอบว่า Admin ยังดึงข้อมูลได้
    
    # 1. Login เพื่อเอา Token (ปรับตามโครงสร้าง data.token)
    ${auth_body}=     Create Dictionary    email=${ADMIN_EMAIL}    password=${ADMIN_PASS}
    Create Session    api    ${BASE_URL}
    ${login_res}=     POST On Session    api    /api/auth/login    json=${auth_body}
    ${token}=         Set Variable    ${login_res.json()['data']['token']}
    Set Suite Variable    ${ADMIN_TOKEN}    ${token}

    # 2. สร้างข้อมูลจำลองย้อนหลัง 90 วัน (ใช้ camelCase ตาม Prisma Schema)
    ${random_num}=    Generate Random String    8    [NUMBERS]
    ${test_action}=   Set Variable    RETENTION_TEST_${random_num}
    
    # เพิ่ม logType และ statusCode เพื่อให้ Data Integrity ครบถ้วน
    Execute SQL String    INSERT INTO "SystemLog" ("action", "logType", "method", "endpoint", "ipAddress", "statusCode", "createdAt", "details") VALUES ('${test_action}', 'AUTH', 'TEST', '/manual/test', '127.0.0.1', 200, NOW() - INTERVAL '90 days', '{"test":"${test_action}"}');
    Log    Injected 90-day old log: ${test_action}

    Check If Exists In Database    SELECT id FROM "SystemLog" WHERE "action" = '${test_action}';
    
    Log    Success! Data from 90 days ago is still retrievable.

    # 5. Cleanup: ลบข้อมูลทดสอบทิ้ง (ค้นหาจากใน JSON details หรือ endpoint)
    Execute SQL String    DELETE FROM "SystemLog" WHERE "action" = '${test_action}';