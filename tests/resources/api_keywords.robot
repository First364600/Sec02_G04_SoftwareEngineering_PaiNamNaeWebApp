*** Settings ***
Library    RequestsLibrary
Library    Collections
Library    String

*** Variables ***
${BASE_URL}     http://localhost:3000
${ADMIN_EMAIL}  admin@example.com
${ADMIN_PASS}   123456789
${TOKEN}        ${EMPTY}

*** Keywords ***
เชื่อมต่อระบบ API
    Create Session    mysession    ${BASE_URL}    disable_warnings=1

Admin เข้าสู่ระบบเพื่อขอ Token
    [Documentation]    ยิง API Login และเก็บ Token ไว้ในตัวแปร ${TOKEN}
    &{headers}=    Create Dictionary    Content-Type=application/json
    &{body}=       Create Dictionary    email=${ADMIN_EMAIL}    password=${ADMIN_PASS}
    
    ${response}=   POST On Session    mysession    /api/auth/login    json=${body}
    Should Be Equal As Strings    ${response.status_code}    200

    ${json_response}=    Set Variable           ${response.json()}
    ${data_part}=        Get From Dictionary    ${json_response}    data
    ${token_value}=      Get From Dictionary    ${data_part}        token
    
    Set Suite Variable    ${TOKEN}    Bearer ${token_value}
    Log    Token ที่ได้คือ: ${TOKEN}

ดึงข้อมูล System Logs
    &{headers}=    Create Dictionary    Authorization=${TOKEN}
    ${response}=   GET On Session     mysession    /api/logs    headers=${headers}    expected_status=any
    Set Test Variable    ${RESPONSE}    ${response}

ดึงข้อมูล System Logs แบบไม่ใส่ Token
    &{headers}=    Create Dictionary    Content-Type=application/json
    ${response}=   GET On Session     mysession    /api/logs    headers=${headers}    expected_status=any
    Set Test Variable    ${RESPONSE}    ${response}

สั่ง Export System Logs
    &{headers}=    Create Dictionary    Authorization=${TOKEN}
    ${response}=   GET On Session     mysession    /api/logs/export    headers=${headers}    expected_status=any
    Set Test Variable    ${RESPONSE}    ${response}

ตรวจสอบสถานะต้องเป็น
    [Arguments]    ${expected_status}
    Should Be Equal As Strings    ${RESPONSE.status_code}    ${expected_status}

ตรวจสอบว่ามีข้อมูล Logs กลับมา
    Dictionary Should Contain Key    ${RESPONSE.json()}    data
    ${data_list}=    Get From Dictionary    ${RESPONSE.json()}    data
    Should Not Be Empty    ${data_list}

ตรวจสอบว่าเป็นไฟล์ CSV
    ${content_type}=    Get From Dictionary    ${RESPONSE.headers}    Content-Type
    Should Contain      ${content_type}        text/csv