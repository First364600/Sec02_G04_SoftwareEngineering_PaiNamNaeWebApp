*** Settings ***
Library    SeleniumLibrary
Library    RequestsLibrary
Library    Collections
Library    String
Library    DateTime
Library    OperatingSystem

*** Variables ***
${BASE_URL}                     http://localhost:3000
${TEST_IMAGE_PATH}              ${CURDIR}${/}Untitled2_20260126225300.png

*** Keywords ***
สร้าง Test User ใหม่
    [Documentation]    สร้าง Test user ใหม่โดยใช้ข้อมูลที่ random ทุกครั้ง
    ...                ฟังก์ชันนี้จะสร้าง unique email ด้วย timestamp
    ...                และใช้รูปภาพ Untitled2_20260126225300.png เป็น profile picture
    
    # สร้าง unique data โดยใช้ timestamp
    ${timestamp}=    Get Current Date    result_format=%Y%m%d%H%M%S%f
    ${random_id}=    Generate Random String    length=5    chars=0123456789
    ${unique_id}=    Evaluate    "${timestamp}".replace('-', '').replace(':', '').replace(' ', '')[:16]
    
    # เตรียมข้อมูล Test User
    ${email}=           Catenate    testuser${unique_id}@example.com
    ${username}=        Catenate    testuser${unique_id}
    ${password}=        Set Variable    TestPassword123
    ${firstName}=       Set Variable    TestUser
    ${lastName}=        Set Variable    ${unique_id}
    ${phoneNumber}=     Catenate    081${random_id}12345
    ${gender}=          Set Variable    MALE
    ${nationalId}=      Generate Random String    length=13    chars=0123456789
    
    # คำนวณวันหมดอายุ (ปีปัจจุบัน + 5 ปี)
    ${expiry_year}=     Evaluate    int(__import__('datetime').datetime.now().year) + 5
    ${expiry_date}=     Catenate    ${expiry_year}-12-31T23:59:59Z
    
    # ตรวจสอบว่าไฟล์รูปภาพมีอยู่
    File Should Exist    ${TEST_IMAGE_PATH}    ไม่พบไฟล์รูปภาพ: ${TEST_IMAGE_PATH}
    
    # เตรียมข้อมูล form data
    &{data}=            Create Dictionary
    ...                 email=${email}
    ...                 username=${username}
    ...                 password=${password}
    ...                 firstName=${firstName}
    ...                 lastName=${lastName}
    ...                 phoneNumber=${phoneNumber}
    ...                 gender=${gender}
    ...                 nationalIdNumber=${nationalId}
    ...                 nationalIdExpiryDate=${expiry_date}
    
    # สร้าง session และส่ง POST request พร้อมไฟล์ขึ้น
    Create Session    usesession    ${BASE_URL}    disable_warnings=1
    
    # ใช้ POST ON SESSION พร้อม files parameter
    ${file_tuple}=     Evaluate    ('Untitled2_20260126225300.png', open(r'${TEST_IMAGE_PATH}', 'rb').read(), 'image/png')
    &{files}=          Create Dictionary
    ...                nationalIdPhotoUrl=${file_tuple}
    ...                selfiePhotoUrl=${file_tuple}
    
    ${response}=       POST On Session    usesession
    ...                /api/users
    ...                data=${data}
    ...                files=${files}
    ...                expected_status=any
    
    # ตรวจสอบ response
    Log    Response Status: ${response.status_code}
    Log    Response Body: ${response.text}
    Should Be True    '${response.status_code}' == '201' or '${response.status_code}' == '200'
    ...    msg=API Error: ${response.text}    # ← จะแสดง error message ใน FAIL
    
    # คืนค่า user data สำหรับใช้ต่อ
    &{test_user}=       Create Dictionary
    ...                 email=${email}
    ...                 username=${username}
    ...                 password=${password}
    ...                 firstName=${firstName}
    ...                 lastName=${lastName}
    ...                 phoneNumber=${phoneNumber}
    ...                 gender=${gender}
    ...                 nationalIdNumber=${nationalId}
    ...                 response_status=${response.status_code}
    ...                 response_body=${response.text}
    
    RETURN    ${test_user}


สร้าง Test User และเก็บข้อมูล
    [Documentation]    สร้าง Test user และเก็บข้อมูลใน Suite Variable
    
    ${test_user}=          สร้าง Test User ใหม่
    Set Suite Variable     ${TEST_USER}    ${test_user}
    
    ${user_email}=         Get From Dictionary    ${test_user}    email
    ${response_status}=    Get From Dictionary    ${test_user}    response_status
    
    Run Keyword If    '${response_status}' == '201' or '${response_status}' == '200'
    ...    Log    สร้าง Test User สำเร็จ - Email: ${user_email} (Status: ${response_status})
    ...    ELSE    Fail    การสร้าง Test User ล้มเหลว - Status: ${response_status}
    
    RETURN    ${test_user}


เข้าสู่ระบบด้วย Test User
    [Documentation]    ใช้ email และ password ของ test user เพื่อเข้าสู่ระบบและขอ token
    [Arguments]         ${test_user}
    
    ${email}=           Get From Dictionary    ${test_user}    email
    ${password}=        Get From Dictionary    ${test_user}    password
    
    Create Session    authsession    ${BASE_URL}    disable_warnings=1
    &{body}=            Create Dictionary    email=${email}    password=${password}
    
    ${response}=        POST On Session    authsession    /api/auth/login    json=${body}
    
    Should Be Equal As Strings    ${response.status_code}    200    ล็อกอินล้มเหลว: ${response.text}
    
    ${json_response}=   Set Variable            ${response.json()}
    ${data_part}=       Get From Dictionary     ${json_response}    data
    ${token}=           Get From Dictionary     ${data_part}        token
    
    Log    เข้าสู่ระบบสำเร็จ - Token: ${token}
    
    RETURN    ${token}


ลบ Test User หลังจากทดสอบเสร็จ
    [Documentation]    ลบ test user หลังจากการทดสอบเสร็จสิ้น
    [Arguments]         ${test_user}
    
    ${token}=           เข้าสู่ระบบด้วย Test User    ${test_user}
    
    Create Session    delsession    ${BASE_URL}    disable_warnings=1
    &{headers}=         Create Dictionary    Authorization=Bearer ${token}
    
    ${response}=        DELETE On Session    delsession    /api/users/me    headers=${headers}    expected_status=any
    
    Log    ลบ Test User - Status: ${response.status_code}
    
    RETURN    ${response}
    
Login And Get Token
    [Documentation]    Login ผ่าน API แล้ว return token และ user_id
    [Arguments]    ${user_email}    ${user_password}
    Create Session    loginSession    ${BASE_URL}    disable_warnings=1
    &{body}=    Create Dictionary    email=${user_email}    password=${user_password}
    ${response}=    POST On Session    loginSession    /api/auth/login    json=${body}
    Should Be Equal As Strings    ${response.status_code}    200
    ...    msg=Login failed: ${response.text}
    ${json}=      Set Variable    ${response.json()}
    ${token}=     Get From Dictionary    ${json}[data]    token
    ${user_id}=   Get From Dictionary    ${json}[data][user]    id
    RETURN    ${token}    ${user_id}
