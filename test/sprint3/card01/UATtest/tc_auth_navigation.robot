*** Settings ***
Library           SeleniumLibrary
Resource          resources/variables.robot
Resource          resources/keywords.robot
Suite Setup       Setup Suite Session
Suite Teardown    Close All Browsers
Test Setup        Ensure On Admin Users Page

*** Test Cases ***
# ตรวจสอบว่าผู้ใช้ login สำเร็จ
TC01 Valid Login
    ${url}=    Get Location
    Should Not Contain    ${url}    login

# ตรวจสอบว่าหน้า Admin มีเมนูหรือข้อความ User Management แสดงอยู่
# เพื่อยืนยันว่าเข้ามาที่หน้า Admin Users ได้สำเร็จ
TC02 Open User Management
    Page Should Contain    User Management

# ตรวจสอบว่าสามารถเปิดหน้า Log ของ user ได้
TC03 Open Log Page
    Open First User Log
    Page Should Contain    Log Event

# ตรวจสอบว่า Table ของ Log มี column header ครบตามที่กำหนด
TC04 Log Table Columns Correct
    Open First User Log
    Page Should Contain    Event
    Page Should Contain    User Id
    Page Should Contain    Name
    Page Should Contain    Date
    Page Should Contain    IP Address
    Page Should Contain    Log Type

# ตรวจสอบการทำงานของ Pagination
TC05 Pagination Next And Previous
    Open First User Log

    ${next_enabled}=    Run Keyword And Return Status
    ...    Element Should Be Enabled    xpath=//button[normalize-space()='Next']

    Pass Execution If    not ${next_enabled}    Only one page - skip pagination test

    Click Next Page

    Wait Until Element Is Enabled    xpath=//button[normalize-space()='Previous']
    Element Should Be Enabled        xpath=//button[normalize-space()='Previous']

    FOR    ${i}    IN RANGE    100
        ${disabled}=    Run Keyword And Return Status
        ...    Element Should Be Disabled    xpath=//button[normalize-space()='Previous']

        Exit For Loop If    ${disabled}

        Click Previous Page
    END

    Element Should Be Disabled    xpath=//button[normalize-space()='Previous']

# ตรวจสอบว่าในตาราง Log มีข้อมูลอย่างน้อย 1 row
TC06 Log Row Exists
    Open First User Log
    Wait Until Page Contains Element    xpath=//tbody/tr
    ${count}=    Get Element Count    xpath=//tbody/tr
    Should Be True    ${count} > 0

# ตรวจสอบว่าในหน้า Log มีการแสดงข้อมูลสรุปของ User
TC07 Log Page Shows User Summary
    Open First User Log
    Page Should Contain    ผู้ใช้
    Page Should Contain    อีเมล
    Page Should Contain    บทบาท
    Page Should Contain    สถานะ
    Page Should Contain    ยืนยันตัวตน