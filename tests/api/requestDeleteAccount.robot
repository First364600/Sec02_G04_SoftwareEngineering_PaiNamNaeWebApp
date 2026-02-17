*** Settings ***
Library    RequestsLibrary
Library    String
Library    OperatingSystem
Library    Collections
Library    DateTime

*** Variables ***
${BASE_URL}              http://localhost:3000/api
${TEST_EMAIL}            eeeeee5@gmail.com
${TEST_PASSWORD}         e123456789

*** Test Cases ***
Test Request Delete Account
    [Documentation]    ทดสอบการลบบัญชี: 
    ...                Pre-condition: login อยู่แล้ว
    ...                1. ล็อกอิน
    ...                2. Request delete account
    ...                3. ตรวจสอบ login ล้มเหลว
    [Setup]    Setup Test Session
    
    ${login_response}=    User Login    ${TEST_EMAIL}    ${TEST_PASSWORD}
    Should Be Equal As Integers    ${login_response.status_code}    200    Failed to login
    
    ${auth_token}=    Get From Dictionary    ${login_response.json()['data']}    token
    ${login_user}=    Get From Dictionary    ${login_response.json()['data']}    user
    
    ${delete_response}=    Delete User Account    ${auth_token}
    Should Be Equal As Integers    ${delete_response.status_code}    200    Failed to request delete
    
    ${delete_response_json}=    Evaluate    json.loads('''${delete_response.text}''')    json
    Should Be True    ${delete_response_json['success']}    Delete response success is false
    ${scheduled_deletion}=    Get From Dictionary    ${delete_response_json['data']}    scheduledDeletionDate

    Sleep    1s
    
    ${failed_login_response}=    User Login    ${TEST_EMAIL}    ${TEST_PASSWORD}
    Should Be Equal As Integers    ${failed_login_response.status_code}    401    Login should fail
    
    ${failed_login_json}=    Evaluate    json.loads('''${failed_login_response.text}''')    json
    Should Contain    ${failed_login_json['message']}    deactivated

*** Keywords ***
Setup Test Session
    [Documentation]    สร้าง session สำหรับการทดสอบ
    
    Create Session    api_session    ${BASE_URL}    timeout=10    verify=False

User Login
    [Arguments]    ${email}    ${password}
    [Documentation]    ยืนยันตัวตนด้วย email และ password
    
    ${login_data}=    Create Dictionary    email=${email}    password=${password}
    
    ${response}=    POST On Session    api_session    /auth/login    json=${login_data}    expected_status=any
    
    RETURN    ${response}

Delete User Account
    [Arguments]    ${auth_token}
    [Documentation]    ทำการ request ลบบัญชี (DELETE /api/users/me)
    
    ${headers}=    Create Dictionary
    ...    Authorization=Bearer ${auth_token}
    ...    Content-Type=application/json
    
    ${response}=    DELETE On Session    api_session    /users/me    headers=${headers}    expected_status=any
    
    RETURN    ${response}
