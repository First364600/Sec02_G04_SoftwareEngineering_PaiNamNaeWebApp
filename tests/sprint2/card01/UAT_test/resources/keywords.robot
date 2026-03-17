*** Settings ***
Library    SeleniumLibrary

*** Keywords ***

Setup Suite Session
    Open Browser    ${BASE_URL}/login    ${BROWSER}
    Maximize Browser Window
    Set Selenium Timeout    ${TIMEOUT}
    Login As Admin
    Wait Until Location Does Not Contain    login    timeout=15s
    Go To    ${BASE_URL}/admin/users?page=1
    Wait Until Page Contains    User Management

Ensure On Admin Users Page
    Go To    ${BASE_URL}/admin/users?page=1
    Sleep    2s
    ${need_login}=    Run Keyword And Return Status
    ...    Location Should Contain    login
    ${load_error}=    Run Keyword And Return Status
    ...    Page Should Contain    ไม่สามารถโหลดข้อมูลได้
    Run Keyword If    ${need_login} or ${load_error}    Re Login
    Wait Until Location Contains    /admin/users    timeout=15s
    Wait Until Page Contains Element    xpath=//tbody/tr    timeout=15s

Open First User Log
    ${modal_open}=    Run Keyword And Return Status
    ...    Page Contains Element    xpath=//h2[normalize-space()='Export log']
    Run Keyword If    ${modal_open}    Close Export Modal

    Sleep    2s
    Go To    ${BASE_URL}/admin/users?page=1
    Sleep    2s
    # เช็คทั้ง redirect ไป login และ error บนหน้า
    ${need_login}=    Run Keyword And Return Status
    ...    Location Should Contain    login
    ${load_error}=    Run Keyword And Return Status
    ...    Page Should Contain    ไม่สามารถโหลดข้อมูลได้
    Run Keyword If    ${need_login} or ${load_error}    Re Login
    Wait Until Location Contains    /admin/users    timeout=15s
    Wait Until Page Contains Element    xpath=//tbody/tr    timeout=15s
    Execute Javascript    window.scrollTo(0, 0)
    Wait Until Element Is Visible
    ...    xpath=(//button[@title="ดู Log"])[1]    timeout=15s
    Click Element    xpath=(//button[@title="ดู Log"])[1]
    Wait Until Page Contains    Log Event

Re Login
    Go To    ${BASE_URL}/login
    Wait Until Element Is Visible
    ...    xpath=//input[@placeholder='กรอกชื่อผู้ใช้หรืออีเมล']    timeout=15s
    Clear Element Text    xpath=//input[@placeholder='กรอกชื่อผู้ใช้หรืออีเมล']
    Input Text
    ...    xpath=//input[@placeholder='กรอกชื่อผู้ใช้หรืออีเมล']    ${ADMIN_EMAIL}
    Clear Element Text    xpath=//input[@placeholder='กรอกรหัสผ่าน']
    Input Password
    ...    xpath=//input[@placeholder='กรอกรหัสผ่าน']    ${ADMIN_PASSWORD}
    Sleep    1s
    Click Button    xpath=//button[contains(.,'เข้าสู่ระบบ')]
    # รอให้แน่ใจว่า login สำเร็จ ไม่ใช่แค่ไม่มี login ใน URL
    Wait Until Location Does Not Contain    login    timeout=15s
    Wait Until Page Does Not Contain    เข้าสู่ระบบไม่สำเร็จ    timeout=5s
    Go To    ${BASE_URL}/admin/users?page=1
    Wait Until Page Contains Element    xpath=//tbody/tr    timeout=15s

Login As Admin
    Wait Until Element Is Visible    xpath=//input[@placeholder='กรอกชื่อผู้ใช้หรืออีเมล']
    Input Text       xpath=//input[@placeholder='กรอกชื่อผู้ใช้หรืออีเมล']    ${ADMIN_EMAIL}
    Input Password   xpath=//input[@placeholder='กรอกรหัสผ่าน']               ${ADMIN_PASSWORD}
    Click Button     xpath=//button[contains(.,'เข้าสู่ระบบ')]
    Wait Until Location Does Not Contain    login    timeout=15s


Click Next Page
    Wait Until Element Is Visible    xpath=//button[normalize-space()='Next']
    Click Element    xpath=//button[normalize-space()='Next']
    Wait Until Page Contains    หน้า

Click Previous Page
    Wait Until Element Is Visible    xpath=//button[normalize-space()='Previous']
    Click Element    xpath=//button[normalize-space()='Previous']
    Wait Until Page Contains    หน้า

Go To Last Log Page
    FOR    ${i}    IN RANGE    20
        ${disabled}=    Run Keyword And Return Status
        ...    Element Should Be Disabled    xpath=//button[normalize-space()='Next']
        Exit For Loop If    ${disabled}
        Click Element    xpath=//button[normalize-space()='Next']
        Wait Until Page Contains    หน้า
    END


Open Export Modal
    Wait Until Element Is Visible    xpath=//button[normalize-space()='Export']
    Click Element    xpath=//button[normalize-space()='Export']
    Wait Until Page Contains Element    xpath=//h2[normalize-space()='Export log']


Close Export Modal
    Click Button    xpath=//button[normalize-space()='Cancel']
    Wait Until Page Does Not Contain Element    xpath=//h2[normalize-space()='Export log']


Select Log Type
    [Arguments]    ${value}
    Select Checkbox    xpath=//input[@value='${value}']


Select Personal Section
    [Arguments]    ${text}
    Select Checkbox    xpath=//label[contains(.,'${text}')]//input



Confirm Export
    # คลิกปุ่ม Export ที่อยู่ใน modal (div fixed) เท่านั้น ไม่ใช่ปุ่ม Export บน header
    Wait Until Element Is Visible
    ...    xpath=//div[contains(@class,'fixed')]//button[normalize-space()='Export']
    Click Element
    ...    xpath=//div[contains(@class,'fixed')]//button[normalize-space()='Export']
    Wait Until Page Does Not Contain Element
    ...    xpath=//h2[normalize-space()='Export log']

Set Date Range
    [Arguments]    ${start}    ${end}
    ${dates}=    Get WebElements    xpath=//input[@type='date']
    Execute Javascript
    ...    arguments[0].value = '${start}'; arguments[0].dispatchEvent(new Event('input', {bubbles:true})); arguments[0].dispatchEvent(new Event('change', {bubbles:true}));
    ...    ARGUMENTS    ${dates}[0]
    Execute Javascript
    ...    arguments[0].value = '${end}'; arguments[0].dispatchEvent(new Event('input', {bubbles:true})); arguments[0].dispatchEvent(new Event('change', {bubbles:true}));
    ...    ARGUMENTS    ${dates}[1]
