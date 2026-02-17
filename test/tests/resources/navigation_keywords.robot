*** Settings ***
Library    SeleniumLibrary
Resource   variables.robot

*** Keywords ***
Login ด้วยบัญชีของฉัน
    [Documentation]    ใช้สำหรับ Login เข้าสู่ระบบโดยตรง
    Input Text      id=identifier    ${USERNAME}
    Input Text      id=password      ${PASSWORD}
    Click Button    css=button[type="submit"]
    Wait Until Page Contains    เดินทางร่วมกัน    timeout=${TIMEOUT}
    Go To    ${BASE_URL}/myRoute

เปิดแอปและไปที่หน้า Login
    [Documentation]    เปิด Browser และเตรียมความพร้อม
    Open Browser    ${BASE_URL}/login    ${BROWSER}
    Maximize Browser Window
    Set Selenium Speed    0.2 seconds    # ช่วยให้เห็นขั้นตอนการรันชัดขึ้น

จำลองพิกัด GPS
    [Arguments]    ${lat}    ${lng}
    ${selenium}=    Get Library Instance    SeleniumLibrary
    ${lat_float}=    Evaluate    float(${lat})
    ${lng_float}=    Evaluate    float(${lng})
    ${location_params}=    Create Dictionary    latitude=${lat_float}    longitude=${lng_float}    accuracy=${100}
    Call Method    ${selenium.driver}    execute_cdp_cmd    Emulation.setGeolocationOverride    ${location_params}