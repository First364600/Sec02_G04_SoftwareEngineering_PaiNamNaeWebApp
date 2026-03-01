*** Settings ***
Library    SeleniumLibrary
Library    OperatingSystem
Resource   resources/keywords.robot
Resource   resources/variables.robot

Suite Setup    Open Browser And Login
Suite Teardown    Close Browser
Test Teardown    Capture Page Screenshot


*** Test Cases ***

# ตรวจสอบว่า Admin สามารถเข้าไปที่หน้า User Log ได้สำเร็จ
TC-01 Access User Log Page
    Go To User Management Page
    Click User Log Button    ${ADMIN_EMAIL}
    Wait Until Page Contains    Log Event


# ตรวจสอบว่าในหน้า User Log มีตารางข้อมูลสำคัญแสดงครบ
TC-02 Verify User Log Data Correctness
    Go To User Management Page
    Click User Log Button    ${ADMIN_EMAIL}
    Wait Until Page Contains    Log Event    20s
    Page Should Contain    ${ADMIN_EMAIL}
    Page Should Contain    Date
    Page Should Contain    Event
    Page Should Contain    User Id
    Page Should Contain    IP Adddress
    Page Should Contain    Log on - Log off


# ตรวจสอบว่าเมื่อกด Export แล้วสามารถ download CSV ได้สำเร็จ
TC-03 Export CSV File
    Go To User Management Page
    Click User Log Button    ${ADMIN_EMAIL}
    Wait Until Page Contains    Log Event

    Click Element    xpath=//button[contains(.,"Export")]

    Wait Until Keyword Succeeds    20s    2s
    ...    Directory Should Not Be Empty    ${DOWNLOAD_DIR}

    ${files}=    List Files In Directory    ${DOWNLOAD_DIR}
    Should Not Be Empty    ${files}


# ตรวจสอบว่ามี log record แสดงอยู่ในระบบ
# โดยดึงวันที่ log ล่าสุดจาก table แล้วเช็คว่าไม่เป็นค่าว่าง เป็นแค่ check ว่ามี data
TC-04 Log Retention Policy
    Go To User Management Page
    Click User Log Button    ${ADMIN_EMAIL}

    Wait Until Page Contains    Log Event

    ${log_date}=    Get Text    xpath=(//table//tr[1]/td[1])
    Log    Latest Log Date: ${log_date}

    Should Not Be Empty    ${log_date}
