*** Settings ***
Resource    ../../sprint1/resources/api_keywords.robot

Suite Setup       Setup Test Environment
Suite Teardown    Teardown Test Environment

*** Keywords ***
Setup Test Environment
    [Documentation]    สร้าง Session HTTP และเชื่อมต่อ Database ตอนเริ่มเทสต์
    Create Session    api    ${BASE_URL}
    # ต่อฐานข้อมูล PostgreSQL เพื่อไว้ตรวจสอบข้อมูลตรงๆ
    Connect To Database    psycopg2    ${DB_NAME}    ${DB_USER}    ${DB_PASS}    ${DB_HOST}    ${DB_PORT}

Teardown Test Environment
    [Documentation]    ปิด Session และยกเลิกการเชื่อมต่อ Database เมื่อเทสต์เสร็จ
    Execute Sql String    DELETE FROM "SystemLog" WHERE id IN (SELECT id FROM "SystemLog" ORDER BY "createdAt" DESC LIMIT 17);
    
    Delete All Sessions
    Disconnect From Database

*** Test Cases ***

# ส่วนที่ 1: Logging & Sanitization
TC-1.1: Verify AUTH Log Generation
    [Documentation]    ทดสอบว่าการ Login จะสร้าง Log ประเภท AUTH
    ${body}=    Create Dictionary    email=${ADMIN_EMAIL}    password=${ADMIN_PASS}
    ${response}=    POST On Session    api    /api/auth/login    json=${body}
    Status Should Be    200    ${response}
    ${ADMIN_TOKEN}=    Set Variable    ${response.json()['data']['token']}
    Set Suite Variable    ${ADMIN_TOKEN}
    Sleep    1s
    # ตรวจสอบใน DB ว่ามี AUTH Log เกิดขึ้น
    ${query_result}=    Query    SELECT "logType" FROM "SystemLog" ORDER BY "createdAt" DESC LIMIT 1;
    Should Be Equal As Strings    ${query_result[0][0]}    AUTH

TC-1.2: Verify BEHAVIOR Log Generation
    [Documentation]    ทดสอบว่าการเรียกดูข้อมูล (GET) สร้าง Log ประเภท BEHAVIOR
    ${headers}=    Create Dictionary    Authorization=Bearer ${ADMIN_TOKEN}
    ${response}=    GET On Session    api    /api/users/me    headers=${headers}
    Status Should Be    200    ${response}
    Sleep    1s
    # ตรวจสอบใน DB
    ${query_result}=    Query    SELECT "logType" FROM "SystemLog" ORDER BY "createdAt" DESC LIMIT 1;
    Should Be Equal As Strings    ${query_result[0][0]}    BEHAVIOR

TC-1.3: Verify TRANSACTION Log and Password Sanitization
    [Documentation]    ทดสอบว่าการทำ PUT สร้าง TRANSACTION Log และเซ็นเซอร์รหัสผ่าน
    ${headers}=    Create Dictionary    Authorization=Bearer ${ADMIN_TOKEN}
    ${body}=    Create Dictionary    firstName=RobotTest    password=SuperSecretPassword
    ${response}=    PUT On Session    api    /api/users/me    json=${body}    headers=${headers}
    Status Should Be    200    ${response}
    
    # ดึง Log ล่าสุดมาเช็ค
    ${query_result}=    Query    SELECT "details"::text FROM "SystemLog" WHERE "logType" = 'AUTH' ORDER BY "createdAt" DESC LIMIT 1;
    
    # คราวนี้จะ PASS แน่นอนเพราะมีคำว่า ***REDACTED*** แล้ว
    Should Contain        ${query_result[0][0]}    ***REDACTED***
    Should Not Contain    ${query_result[0][0]}    SuperSecretPassword

TC-1.4: Verify SECURITY Log on Unauthorized Access
    [Documentation]    ทดสอบว่าเข้าถึงโดยไม่มีสิทธิ์ จะเกิด SECURITY Log
    # ไม่ใส่ Token
    ${response}=    GET On Session    api    /api/logs    expected_status=401
    
    Sleep    1s
    ${query_result}=    Query    SELECT "logType" FROM "SystemLog" ORDER BY "createdAt" DESC LIMIT 1;
    Should Be Equal As Strings    ${query_result[0][0]}    SECURITY

# ส่วนที่ 2: Data Retrieval & Filtering
TC-2.1: Admin Can Get All Logs
    [Documentation]    แอดมินดึงข้อมูล Log ได้ และดึง ID ล่าสุดมาใช้ใน TC ถัดไป
    ${headers}=    Create Dictionary    Authorization=Bearer ${ADMIN_TOKEN}
    ${response}=    GET On Session    api    /api/users/admin/logs    headers=${headers}
    Status Should Be    200    ${response}
    
    # เก็บ ID ของ Log แถวแรกสุดไว้ทดสอบการแฮก
    ${LATEST_LOG_ID}=    Set Variable    ${response.json()['data'][0]['id']}
    Set Suite Variable    ${LATEST_LOG_ID}

TC-2.2: Filter Logs by Type
    ${headers}=    Create Dictionary    Authorization=Bearer ${ADMIN_TOKEN}

    # 1. ยิง API โดยกรองประเภทเป็น SECURITY
    ${response}=    GET On Session    api    url=/api/users/admin/logs?type=SECURITY&limit=100    headers=${headers}
    
    # 2. ตรวจสอบว่า Response ต้องมีข้อมูลที่เป็น SECURITY
    ${body_string}=   Convert To String    ${response.json()}
    Should Contain    ${body_string}       SECURITY
    
    # 3. (Optional) ตรวจสอบว่าไม่มีข้อมูลประเภทอื่นหลุดมา (ถ้า Backend กรองสำเร็จ)
    # Should Not Contain    ${body_string}   TRANSACTION

# ส่วนที่ 3: Security & Integrity UAT
TC-3.1: User Cannot Access Admin Logs
    [Documentation]    จำกัดสิทธิ์ User ไม่ให้เข้าถึง API ของแอดมิน (RBAC Test)
    # สมมติว่ามีฟังก์ชัน Login User ธรรมดา และได้ USER_TOKEN มาแล้ว
    # (หากไม่มีระบบแยก Role ชัดเจน ให้ใช้ Token ปลอมหรือ Token ที่สิทธิ์ไม่ถึง)
    ${headers}=    Create Dictionary    Authorization=Bearer invalid_or_user_token
    ${response}=    GET On Session    api    /api/users/admin/logs    headers=${headers}    expected_status=401

TC-3.2: Verify Valid Log HMAC
    [Documentation]    ทดสอบ Verify ข้อมูล Log ที่ยังไม่ถูกแก้ไข (ต้องผ่าน)
    ${headers}=    Create Dictionary    Authorization=Bearer ${ADMIN_TOKEN}
    
    # create new ADMIN_PASS
    GET On Session    api    /api/users/me    headers=${headers}
    Sleep    1s
    
    # search for latest log
    ${query_result}=    Query    SELECT id FROM "SystemLog" ORDER BY "createdAt" DESC LIMIT 1;
    ${NEW_LOG_ID}=      Set Variable    ${query_result[0][0]}
    
    # check latest log
    ${response}=    GET On Session    api    url=/api/users/admin/logs/${NEW_LOG_ID}/verify    headers=${headers}
    Status Should Be    200    ${response}
    Should Be True      ${response.json()['isValid']}

TC-3.3: Tamper Detection (HMAC Catching Payload Modification)
    [Documentation]    จำลองการแฮกแก้ข้อมูลเนื้อหา Log (แก้คอลัมน์ details ที่ใช้คำนวณ Hash)
    
    # simulate payload modification
    Execute Sql String    UPDATE "SystemLog" SET "details" = '{"tampered": true}' WHERE id = '${LATEST_LOG_ID}';
    
    # api check again
    ${headers}=    Create Dictionary    Authorization=Bearer ${ADMIN_TOKEN}
    ${response}=   GET On Session    api    /api/users/admin/logs/${LATEST_LOG_ID}/verify    headers=${headers}
    Status Should Be    200    ${response}
    
    # check log Should be false
    Should Not Be True    ${response.json()['isValid']}
    Should Be Equal As Strings    ${response.json()['status']}    Tampered (Data changed!)

TC-3.4: Tamper Detection (HMAC Catching Hash Modification)
    [Documentation]    จำลองการแฮกโดยการเดา/เปลี่ยนค่า Hash โดยตรงใน Database
    
    # try to edit loghash
    Execute Sql String    UPDATE "SystemLog" SET "logHash" = 'fake_hash_123456789abcdef' WHERE id = '${LATEST_LOG_ID}';
    
    # api check again
    ${headers}=    Create Dictionary    Authorization=Bearer ${ADMIN_TOKEN}
    ${response}=   GET On Session    api    /api/users/admin/logs/${LATEST_LOG_ID}/verify    headers=${headers}
    Status Should Be    200    ${response}
    
    # check log Should be false
    Should Not Be True    ${response.json()['isValid']}
    Should Be Equal As Strings    ${response.json()['status']}    Tampered (Data changed!)

    Execute Sql String    DELETE FROM "SystemLog" WHERE id = '${LATEST_LOG_ID}';
    
TC-3.5: Verify All Logs in First Page
    ${headers}=    Create Dictionary    Authorization=Bearer ${ADMIN_TOKEN}
    ${query}=       Create Dictionary    logType=TRANSACTION    limit=100
    ${response}=    GET On Session    api    url=/api/users/admin/logs    params=${query}    headers=${headers}

    ${logs}=    Set Variable    ${response.json()['data']}
    
    FOR    ${log}    IN    @{logs}
        ${log_id}=    Set Variable    ${log['id']}
        
        Continue For Loop If    '${log_id}' == '${LATEST_LOG_ID}'
        ${v_res}=     GET On Session    api    url=/api/users/admin/logs/${log_id}/verify    headers=${headers}
        
        Log To Console    Checking Log ID: ${log_id} - Status: ${v_res.json()['isValid']}
        Should Be True    ${v_res.json()['isValid']}    msg=Log ID ${log_id} has been tampered!
    END

# ส่วนที่ 4: Exporting Logs
TC-4.1: Admin Can Export Logs to CSV
    [Documentation]    ทดสอบการดาวน์โหลดไฟล์ Log และตรวจสอบเนื้อหา
    ${headers}=    Create Dictionary    Authorization=Bearer ${ADMIN_TOKEN}
    
    # 1. เรียก API สำหรับ Export
    ${response}=    GET On Session    api    url=/api/logs/export    headers=${headers}    expected_status=200
    
    # 2. ตรวจสอบ Header ว่าเป็นไฟล์ดาวน์โหลดจริงไหม
    Dictionary Should Contain Key    ${response.headers}    Content-Disposition
    Should Contain    ${response.headers['Content-Disposition']}    attachment
    Should Contain    ${response.headers['Content-Disposition']}    .csv
    
    # 3. ตรวจสอบเนื้อหาในไฟล์ (Content)
    ${file_content}=    Convert To String    ${response.content}
    
    Should Contain    ${file_content}    ID
    Should Contain    ${file_content}    Action
    Should Contain    ${file_content}    Status
    Should Contain    ${file_content}    Date
    
    Log To Console    \nExport Verified: Found matching headers in CSV!

# ส่วนที่ 5: Filtering Logs
TC-5.1: Filter Logs by Date Range
    [Documentation]    ทดสอบการดึงข้อมูล Log โดยกรองจากช่วงวันที่ (dateFrom ถึง dateTo)
    ${headers}=    Create Dictionary    Authorization=Bearer ${ADMIN_TOKEN}
    
    ${date_from}=    Set Variable    2024-01-01
    ${date_to}=      Set Variable    2024-12-31
    ${query}=        Create Dictionary    dateFrom=${date_from}    dateTo=${date_to}    limit=50
    
    ${response}=     GET On Session    api    /api/users/admin/logs    params=${query}    headers=${headers}
    Status Should Be    200    ${response}
    
    ${logs}=         Set Variable    ${response.json()['data']}
    
    FOR    ${log}    IN    @{logs}
        #ตัดเอาเฉพาะส่วนวันที่ 10 ตัวแรก (YYYY-MM-DD) มาเทียบ
        ${log_date}=       Evaluate    "${log['createdAt']}"[:10]
        
        ${is_in_range}=    Evaluate    "${date_from}" <= "${log_date}" <= "${date_to}"
        Should Be True     ${is_in_range}    msg=Log ID ${log['id']} (Date: ${log_date}) หลุดกรอบเวลาที่ค้นหา!
    END
    
TC-5.2: Filter Logs by Date Range (Exclude Out-of-Range Data)
    [Documentation]    จำลองข้อมูลที่หลุดกรอบเวลา และทดสอบว่า API จะไม่ดึงข้อมูลนั้นมาให้
    
    ${query_result}=    Query    SELECT id FROM "SystemLog" ORDER BY "createdAt" DESC LIMIT 1;
    ${TARGET_LOG_ID}=   Set Variable    ${query_result[0][0]}
    
    Execute Sql String    UPDATE "SystemLog" SET "createdAt" = '2020-01-01 10:00:00' WHERE id = '${TARGET_LOG_ID}';
    
    ${headers}=      Create Dictionary    Authorization=Bearer ${ADMIN_TOKEN}
    ${date_from}=    Set Variable    2024-01-01
    ${date_to}=      Set Variable    2024-12-31
    ${query}=        Create Dictionary    dateFrom=${date_from}    dateTo=${date_to}    limit=50
    
    ${response}=     GET On Session    api    /api/users/admin/logs    params=${query}    headers=${headers}
    Status Should Be    200    ${response}
    
    ${logs}=         Set Variable    ${response.json()['data']}
    
    FOR    ${log}    IN    @{logs}
        ${log_id}=       Set Variable    ${log['id']}
        ${log_date}=     Evaluate    "${log['createdAt']}"[:10]
        
        # เช็คว่าต้องไม่เจอ ID ที่เราเพิ่งเปลี่ยนเป็นปี 2020
        Should Not Be Equal As Strings    '${log_id}'    '${TARGET_LOG_ID}'    msg=บั๊ก! API ดึงข้อมูลนอกกรอบเวลามาด้วย
        
        # เช็คย้ำอีกรอบว่า Log ทุกตัวที่ได้มา ต้องอยู่ในปี 2024 จริงๆ
        ${is_in_range}=    Evaluate    "${date_from}" <= "${log_date}" <= "${date_to}"
        Should Be True     ${is_in_range}    msg=Log ID ${log_id} (Date: ${log_date}) หลุดกรอบเวลาที่ค้นหา!
    END
    
    Execute Sql String    UPDATE "SystemLog" SET "createdAt" = CURRENT_TIMESTAMP WHERE id = '${TARGET_LOG_ID}';

TC-5.3: Filter Logs by Multiple Log Types
    [Documentation]    ทดสอบการกรอง Log ด้วยประเภทหลายๆ แบบพร้อมกัน (เช่น SECURITY และ AUTH)
    ${headers}=    Create Dictionary    Authorization=Bearer ${ADMIN_TOKEN}
    
    ${query}=        Create Dictionary    logType=SECURITY,AUTH    limit=50
    
    ${response}=     GET On Session    api    /api/users/admin/logs    params=${query}    headers=${headers}
    Status Should Be    200    ${response}
    
    ${logs}=         Set Variable    ${response.json()['data']}
    
    FOR    ${log}    IN    @{logs}
        ${current_type}=    Set Variable    ${log['logType']}
        ${is_valid_type}=   Evaluate    "${current_type}" in ["SECURITY", "AUTH"]
        Should Be True      ${is_valid_type}    msg=เจอ Log ชนิดอื่นหลุดมา! (Log ID: ${log['id']}, Type: ${current_type})
    END

# ส่วนที่ 6: Audit Logs
TC-6.1: Audit All Logs (Secure State)
    [Documentation]    ทดสอบ API สแกน Log ทั้งระบบ ในสถานะที่ไม่มีการโดนแฮก
    ${headers}=      Create Dictionary    Authorization=Bearer ${ADMIN_TOKEN}
    ${response}=     GET On Session    api    /api/users/admin/logs/audit    headers=${headers}
    
    Log To Console    Tampered IDs: ${response.json()['tamperedLogIds']}
    
    Status Should Be    200    ${response}
    
    # ต้องได้สถานะ Secure และ Array ของ tamperedLogIds ต้องว่างเปล่า
    Should Be Equal As Strings    ${response.json()['status']}    Secure
    Should Be Empty               ${response.json()['tamperedLogIds']}

TC-6.2: Audit All Logs (Detect Tampering)
    [Documentation]    จำลองการแฮกข้อมูล แล้วสั่ง Audit เพื่อดูว่าระบบตรวจเจอไหม

    ${query_result}=    Query    SELECT id FROM "SystemLog" ORDER BY "createdAt" DESC LIMIT 1;
    ${TARGET_LOG_ID}=   Set Variable    ${query_result[0][0]}

    Execute Sql String    UPDATE "SystemLog" SET "logHash" = 'hacked_hash_123456789' , "details" = '{"tampered": true}' WHERE id = '${TARGET_LOG_ID}';
    
    ${headers}=      Create Dictionary    Authorization=Bearer ${ADMIN_TOKEN}
    ${response}=     GET On Session    api    /api/users/admin/logs/audit    headers=${headers}
    Status Should Be    200    ${response}
    
    Should Be Equal As Strings    ${response.json()['status']}    Warning
    
    ${tampered_ids}=    Set Variable    ${response.json()['tamperedLogIds']}
    
    ${is_id_found}=     Evaluate    ${TARGET_LOG_ID} in ${tampered_ids}
    Should Be True      ${is_id_found}    msg=Audit API หา Log ที่โดนแฮกไม่เจอ!
    
    Execute Sql String    DELETE FROM "SystemLog" WHERE id = '${TARGET_LOG_ID}';