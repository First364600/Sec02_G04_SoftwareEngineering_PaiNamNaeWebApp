*** Settings ***
Library         SeleniumLibrary
Resource        test_data.robot

*** Keywords ***
Open Ride Sharing App
    [Arguments]    ${url}    ${alias}
    # ตั้งค่าให้ Chrome อนุญาตการเข้าถึง Location อัตโนมัติ
    ${options}=    Evaluate    sys.modules['selenium.webdriver'].ChromeOptions()    sys
    Call Method    ${options}    add_experimental_option    prefs    {"profile.default_content_setting_values.geolocation": 1}
    Open Browser    ${url}    ${BROWSER}    alias=${alias}    options=${options}
    Maximize Browser Window
    Wait Until Element Is Visible    ${TAB_MY_ROUTES}    timeout=${SHORT_WAIT}

Mock Geolocation
    [Arguments]    ${lat}    ${lng}
    [Documentation]    ใช้ Chrome DevTools Protocol (CDP) เพื่อหลอกพิกัด GPS
    Execute Javascript    window.navigator.geolocation.getCurrentPosition = function(success) { success({ coords: { latitude: ${lat}, longitude: ${lng}, accuracy: 10 } }); }

Switch To Driver
    Switch Browser    driver_browser

Switch To Passenger
    Switch Browser    passenger_browser

Driver Starts Trip
    Switch To Driver
    Wait Until Element Is Visible    ${TAB_MY_ROUTES}
    Click Element    ${TAB_MY_ROUTES}
    Wait Until Element Is Visible    ${TRIP_CARD}
    Click Element    ${TRIP_CARD}
    Wait Until Element Is Visible    ${BTN_START_TRIP}
    Click Element    ${BTN_START_TRIP}
    # รอกดยืนยันใน Modal
    Wait Until Element Is Visible    ${BTN_CONFIRM_MODAL}
    Click Element    ${BTN_CONFIRM_MODAL}
    Wait Until Element Is Visible    ${BTN_STARTED_DISABLED}

Driver Checkpoint Success
    Switch To Driver
    Mock Geolocation    ${GPS_ORIGIN_LAT}    ${GPS_ORIGIN_LNG}
    Click Element    ${BTN_CHECKPOINT}
    # ตรวจสอบว่าไม่ติด Error เรื่องระยะทาง 500 เมตร
    Page Should Not Contain    คุณไม่อยู่ในพื้นที่