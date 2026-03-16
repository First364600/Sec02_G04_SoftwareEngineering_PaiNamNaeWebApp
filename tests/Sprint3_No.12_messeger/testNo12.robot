*** Settings ***
Library    SeleniumLibrary
Suite Teardown    Close All Browsers


*** Variables ***
${URL}                http://localhost:3001
${BROWSER}            chrome

${DRIVER_USER}        ohm159@gmail.com
${DRIVER_PASS}        Namidablack1

${PASS_USER}          ohm163@gmail.com
${PASS_PASS}          Namidablack1

${PASS2_USER}        ohm168@gmail.com    
${PASS2_PASS}        Namidablack1       

${MSG_TC1_PASS}       ขอบคุณครับ เดี๋ยวไปที่จุดรับ
${QUICK_MSG_TEXT}     คนขับกำลังมาหาคุณแล้ว

${URL_MY_ROUTE}       ${URL}/myroute
${URL_MY_TRIPS}       ${URL}/mytrip
${URL_FINDTRIP}       ${URL}/findtrip

${CARD}    xpath=//div[contains(@class, 'trip-card') ]
${BTN_SEARCH_ROUTE}      xpath=//button[contains(.,'ค้นหา')]
${ROUTE_CARD}            xpath=(//div[contains(@class,'route')])[1]
${BTN_BOOK_ROUTE}        xpath=(//button[contains(.,'จองที่นั่ง')])[1]

${INPUT_PICKUP}          xpath=(//input[contains(@placeholder,'พิมพ์ชื่อสถานที่')])[1]
${INPUT_DROPOFF}         xpath=(//input[contains(@placeholder,'พิมพ์ชื่อสถานที่')])[2]

${BTN_CONFIRM_BOOKING}   xpath=//button[contains(.,'ยืนยันการจอง')]

${TAB_PENDING}           xpath=//button[contains(.,'รอดำเนินการ')]
${BTN_ACCEPT_BOOKING}    xpath=(//button[contains(.,'ยืนยันคำขอ')])[1]
${BTN_CONFIRM_MODAL}     xpath=(//button[contains(.,'ยืนยันคำขอ')])[2]

${BTN_START_TRIP}        xpath=//button[contains(.,'เริ่มต้นการเดินทาง')]
${BTN_MODAL_CONFIRM}     xpath=//button[contains(.,'เริ่มเดินทาง')]
${BTN_CHECKPOINT}        xpath=//button[contains(.,'Checkpoint')]

${BTN_SEND_MESSAGE}      xpath=//button[contains(.,'ส่งข้อความ')]
${BTN_QUICK_MSG}         xpath=//button[contains(.,'คนขับกำลังมาหาคุณแล้ว')]

${PASSENGER_TAB_CONFIRMED}    xpath=//button[contains(.,'ยืนยัน')]
${TRIP_CARD_PASSENGER}        xpath=//div[.//button[contains(.,'ข้อความจากคนขับ')]]

${BTN_OPEN_CHAT_PASS}    xpath=(//button[contains(.,'ข้อความจากคนขับ')])[1]
${PASS_REPLY_INPUT}      xpath=//input[@placeholder='พิมพ์ข้อความตอบกลับ...']
${PASS_SEND_REPLY_BTN}   xpath=//button[contains(.,'ส่ง')]
${TAB_MY_ROUTE}    xpath=//button[contains(.,'เส้นทางของฉัน')]
${BTN_SEND_MESSAGER}    xpath=//button[contains(@class, 'p-2.5 text-white bg-purple-600 rounded-full hover:bg-purple-700 disabled:opacity-50 transition flex-shrink-0')]
${BTN_SEND_TO_ALL}    xpath=//button[contains(.,'ส่งข้อความทุกคน')]
${BTN_SELECT_ALL_CHAT}    xpath=//button[contains(.,'เลือกทุกคน')]
${BTN_QUICK_MSG_2}        xpath=//button[contains(.,'คนขับกำลังมาหาคุณแล้ว เตรียมตัวได้เลย!')]
${BTN_CONFIRM_SEND}       xpath=//button[contains(@class, 'bg-purple-600') and contains(.,'ส่งข้อความ')]
${BTN_CLOSE_MODAL}    xpath=//button[contains(@class, 'text-gray-400') and .//*[local-name()='svg']]


*** Keywords ***
# AIช่วยในส่วนOpen chrome
Open Chrome Auto Allow
    [Arguments]    ${url}    ${alias}
    # 1. เรียกใช้ ChromeOptions
    ${options}=    Evaluate    sys.modules['selenium.webdriver'].ChromeOptions()    sys, selenium.webdriver
    
    # 2. ตั้งค่าให้กด Allow อัตโนมัติ (1 = Allow, 2 = Block) 
    # geolocation คือ ตำแหน่งที่ตั้ง, notifications คือ การแจ้งเตือน
    ${prefs}=      Create Dictionary    profile.default_content_setting_values.geolocation=1    profile.default_content_setting_values.notifications=1
    Call Method    ${options}    add_experimental_option    prefs    ${prefs}
    
    # (แถม) ปิดพวกป๊อปอัปจุกจิกของ Chrome ที่ชอบเด้งมากวนใจ
    Call Method    ${options}    add_argument    --disable-notifications
    Call Method    ${options}    add_argument    --disable-infobars

    # 3. เปิดเบราว์เซอร์ด้วย Options ที่ตั้งค่าไว้
    Create Webdriver    Chrome    alias=${alias}    options=${options}
    Go To    ${url}
    Maximize Browser Window

Login
    [Arguments]    ${user}    ${pass}
    Wait Until Element Is Visible    id=identifier    20s
    Input Text    id=identifier    ${user}
    Input Text    id=password    ${pass}
    Click Button    xpath=//button[contains(.,'เข้าสู่ระบบ')]
    Wait Until Location Does Not Contain    login    20s


Open Driver
    Open Chrome Auto Allow    ${URL}/login    Driver
    Login    ${DRIVER_USER}    ${DRIVER_PASS}


Open Passenger
    Open Chrome Auto Allow    ${URL}/login    Passenger
    Login    ${PASS_USER}    ${PASS_PASS}

Open Passenger 2
    Open Chrome Auto Allow    ${URL}/login    Passenger2
    Login    ${PASS2_USER}    ${PASS2_PASS}

Click JS
    [Arguments]    ${locator}
    Wait Until Element Is Visible    ${locator}    30s
    ${el}=    Get WebElement    ${locator}
    Execute Javascript    arguments[0].click();    ARGUMENTS    ${el}


Passenger Book Route
    [Arguments]    ${alias}=Passenger
    Switch Browser    ${alias}

    Go To    ${URL_FINDTRIP}

    Click JS    ${BTN_SEARCH_ROUTE}

    Wait Until Element Is Visible    ${ROUTE_CARD}    30s
    Click JS    ${ROUTE_CARD}

    Click JS    ${BTN_BOOK_ROUTE}

    Wait Until Element Is Visible    ${INPUT_PICKUP}    20s

    Input Text    ${INPUT_PICKUP}    SC09
    Sleep    2s
    Press Keys    ${INPUT_PICKUP}    ARROW_DOWN
    Press Keys    ${INPUT_PICKUP}    ARROW_DOWN
    Press Keys    ${INPUT_PICKUP}    ARROW_DOWN
    Press Keys    ${INPUT_PICKUP}    ENTER

    Input Text    ${INPUT_DROPOFF}    ตึกกลม
    Sleep    2s
    Press Keys    ${INPUT_DROPOFF}    ARROW_DOWN

    Press Keys    ${INPUT_DROPOFF}    ENTER

    Sleep    2s

    Wait Until Element Is Enabled    ${BTN_CONFIRM_BOOKING}    10s
    Click JS    ${BTN_CONFIRM_BOOKING}


Driver Accept Booking
    Switch Browser    Driver

    Go To    ${URL_MY_ROUTE}

    Sleep    3s

    Click JS    ${TAB_PENDING}

    Wait Until Element Is Visible    ${BTN_ACCEPT_BOOKING}    30s
    Click JS    ${BTN_ACCEPT_BOOKING}

    Wait Until Element Is Visible    ${BTN_CONFIRM_MODAL}    20s
    Click JS    ${BTN_CONFIRM_MODAL}

    Sleep    2s


Driver Start Trip
    Switch Browser    Driver

    Go To    ${URL_MY_ROUTE}

    Reload Page
    Sleep    2s

    Click JS    ${TAB_MY_ROUTE}

    Sleep    2s

    Wait Until Element Is Visible    ${BTN_START_TRIP}    30s
    Click JS    ${BTN_START_TRIP}

    Wait Until Element Is Visible    ${BTN_MODAL_CONFIRM}    20s
    Click JS    ${BTN_MODAL_CONFIRM}

    Wait Until Element Is Visible    ${CARD}    10s
    Click JS    ${CARD}

    Wait Until Element Is Visible    ${BTN_CHECKPOINT}    20s
    Click JS    ${BTN_CHECKPOINT}


Driver Send Quick Message
    Switch Browser    Driver

    Wait Until Element Is Visible    ${BTN_SEND_MESSAGE}    20s
    Click JS    ${BTN_SEND_MESSAGE}

    Wait Until Element Is Visible    ${BTN_QUICK_MSG}    20s
    Click JS    ${BTN_QUICK_MSG}

    Click JS    ${BTN_SEND_MESSAGER}

    Sleep    1s

    # ปิด modal
    Wait Until Element Is Visible    ${BTN_CLOSE_MODAL}    10s
    Click JS    ${BTN_CLOSE_MODAL}

    # รอหน้าโหลดใหม่
    Wait Until Element Is Visible    ${TAB_MY_ROUTE}    20s
    Click JS    ${TAB_MY_ROUTE}

    # รอ card แล้ว scroll
    Wait Until Element Is Visible    ${CARD}    30s
    Scroll Element Into View    ${CARD}

    Sleep    1s

    Click JS    ${CARD}

    


Passenger Reply Chat
    [Arguments]    ${alias}=Passenger
    Switch Browser    ${alias}


    Go To    ${URL_MY_TRIPS}

    Click JS    ${PASSENGER_TAB_CONFIRMED}

    Wait Until Element Is Visible    ${TRIP_CARD_PASSENGER}    30s
    Click JS    ${TRIP_CARD_PASSENGER}

    Click JS    ${BTN_OPEN_CHAT_PASS}

    Wait Until Page Contains    ${QUICK_MSG_TEXT}    30s

    Input Text    ${PASS_REPLY_INPUT}    ${MSG_TC1_PASS}

    Click JS    ${PASS_SEND_REPLY_BTN}

Driver Send Broadcast Message
    Switch Browser    Driver

    Wait Until Element Is Visible    ${BTN_SEND_TO_ALL}    20s
    Click JS    ${BTN_SEND_TO_ALL}

    Wait Until Element Is Visible    ${BTN_SELECT_ALL_CHAT}    20s
    Click JS    ${BTN_SELECT_ALL_CHAT}

    Wait Until Element Is Visible    ${BTN_QUICK_MSG_2}    10s
    Click JS    ${BTN_QUICK_MSG_2}

    Wait Until Element Is Enabled    ${BTN_CONFIRM_SEND}    10s
    Click JS    ${BTN_CONFIRM_SEND}

    Log To Console    ส่งข้อความ Broadcast เรียบร้อยแล้ว

Verify Driver Receive Reply
    Switch Browser    Driver

    Go To    ${URL_MY_ROUTE}

    Wait Until Element Is Visible    ${TAB_MY_ROUTE}    20s
    Click JS    ${TAB_MY_ROUTE}

    Wait Until Element Is Visible    ${CARD}    20s
    Click JS    ${CARD}

    # เปิด chat
    Wait Until Element Is Visible    ${BTN_SEND_MESSAGE}    20s
    Click JS    ${BTN_SEND_MESSAGE}

    Wait Until Page Contains    ${MSG_TC1_PASS}    30s

*** Test Cases ***

TC01_Driver_Accept_Two_Passengers
    # เปิด Browser สำหรับ 3 ไอดี
    Open Driver
    Open Passenger
    Open Passenger 2

    # คนที่ 1 จอง -> คนขับกดรับ
    Passenger Book Route    Passenger
    Driver Accept Booking

    # คนที่ 2 จอง -> คนขับกดรับ
    Passenger Book Route    Passenger2
    Driver Accept Booking

TC02_Driver_Start_Trip
    # เริ่มเดินทาง
    Driver Start Trip

TC03_Driver_And_Passenger_Chat
    # ส่งข้อความหาคนที่ 1 และทดสอบระบบแชทกลุ่ม
    Driver Send Quick Message
    Passenger Reply Chat    Passenger    # ให้คนที่ 1 เป็นคนตอบแชท
    Verify Driver Receive Reply
    Driver Send Broadcast Message
