*** Settings ***
Library           SeleniumLibrary
Resource          resources/variables.robot
Resource          resources/keywords.robot
Suite Setup       Setup Suite Session
Suite Teardown    Close All Browsers
Test Setup        Ensure On Admin Users Page

*** Test Cases ***
TC01 Valid Login
    ${url}=    Get Location
    Should Not Contain    ${url}    login

TC02 Open User Management
    Page Should Contain    User Management

TC03 Open Log Page
    Open First User Log
    Page Should Contain    Log Event

TC04 Log Table Columns Correct
    Open First User Log
    Page Should Contain    Event
    Page Should Contain    User Id
    Page Should Contain    Name
    Page Should Contain    Date
    Page Should Contain    IP Adddress
    Page Should Contain    Log on - Log off

TC05 Pagination Next And Previous
    Open First User Log
    # เช็คก่อนว่ามีหลายหน้าไหม
    ${next_enabled}=    Run Keyword And Return Status
    ...    Element Should Be Enabled    xpath=//button[normalize-space()='Next']
    Pass Execution If    not ${next_enabled}    Only one page - skip pagination test
    # ไปหน้า 2
    Click Next Page
    Element Should Be Enabled    xpath=//button[normalize-space()='Previous']
    # วนกด Previous จนกลับหน้า 1 (Previous disabled)
    FOR    ${i}    IN RANGE    100
        ${disabled}=    Run Keyword And Return Status
        ...    Element Should Be Disabled    xpath=//button[normalize-space()='Previous']
        Exit For Loop If    ${disabled}
        Click Previous Page
    END
    Element Should Be Disabled    xpath=//button[normalize-space()='Previous']

TC06 Log Row Exists
    Open First User Log
    Wait Until Page Contains Element    xpath=//tbody/tr
    ${count}=    Get Element Count    xpath=//tbody/tr
    Should Be True    ${count} > 0

TC07 Log Page Shows User Summary
    Open First User Log
    Page Should Contain    ผู้ใช้
    Page Should Contain    อีเมล
    Page Should Contain    บทบาท
    Page Should Contain    สถานะ
    Page Should Contain    ยืนยันตัวตน