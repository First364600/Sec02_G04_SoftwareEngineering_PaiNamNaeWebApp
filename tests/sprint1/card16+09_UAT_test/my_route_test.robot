*** Settings ***
Library         SeleniumLibrary
Resource        resources/navigation_keywords.robot
Resource        resources/variables.robot

Suite Setup     Run Keywords    เปิดแอปและไปที่หน้า Login    AND    Login ด้วยบัญชีของฉัน
Suite Teardown  Close Browser

*** Test Cases ***

TC-01: ตรวจสอบการแสดงผลข้อมูลและหมุดบนแผนที่ (Success)
    [Documentation]    ตรวจสอบ UI เริ่มต้นและการแสดงผล carDetails
    Go To    ${BASE_URL}/myRoute
    Wait Until Element Is Visible    xpath=//button[contains(text(), 'เส้นทางของฉัน')]    timeout=10s
    Click Element    xpath=//button[contains(text(), 'เส้นทางของฉัน')]
    Wait Until Element Is Visible    ${TRIP_CARD}    timeout=10s
    Click Element    ${TRIP_CARD}
    Wait Until Page Contains    Toyota (Sedan)    ${TIMEOUT}
    Wait Until Page Contains    -              ${TIMEOUT}
    Element Should Be Visible    id=map

TC-02: เริ่มต้นการเดินทาง (Success Flow)
    [Documentation]    กดเริ่มเดินทางและยืนยัน สถานะต้องเปลี่ยนเป็นกำลังเดินทาง
    ${PURE_XPATH}=    Set Variable    (//button[.//span[contains(text(), 'เริ่มต้นการเดินทาง')]])[1]
    Wait Until Page Contains Element    xpath=${PURE_XPATH}    timeout=15s
    Execute JavaScript    document.evaluate("${PURE_XPATH}", document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue.click()
    Wait Until Element Is Visible    xpath=//button[contains(., 'เริ่มเดินทาง')]    timeout=10s
    Click Element    xpath=//button[contains(., 'เริ่มเดินทาง')]
    Wait Until Page Contains    กำลังเดินทาง    timeout=${TIMEOUT}

TC-03: Check-in ไม่ผ่านเพราะพิกัดอยู่ห่างเกิน 500 เมตร (Failed)
    จำลองพิกัด GPS    ${LOC_FAR_LAT}    ${LOC_FAR_LNG}
    Click Button    ${BTN_CHECKPOINT}
    Wait Until Page Contains    คุณไม่อยู่ในพื้นที่    ${TIMEOUT}
    Capture Page Screenshot

TC-04: Check-in จุดเริ่มต้นสำเร็จและระบบนำทางไปจุดถัดไป (Success)
    จำลองพิกัด GPS    ${LOC_ORIGIN_LAT}    ${LOC_ORIGIN_LNG}
    Wait Until Element Is Visible    ${BTN_CHECKPOINT}    timeout=10s
    Click Button    ${BTN_CHECKPOINT}
    Wait Until Page Contains    Check-in สำเร็จ    timeout=${TIMEOUT}
    Wait Until Page Contains    Central Khonkaen    timeout=${TIMEOUT}
    Element Should Be Visible    xpath=//span[contains(text(), 'กำลังเดินทาง')]

TC-05: เช็คอินจุดแวะสำเร็จและนำทางสู่ปลายทาง (Success)
    [Documentation]    เช็คอินที่ Central Khonkaen
    จำลองพิกัด GPS    16.441865    102.827660
    Sleep    3s
    ${BTN_ACTION}=    Set Variable    xpath=//button[contains(@class, 'w-full') and (contains(., 'Checkpoint') or contains(., 'ยืนยันการถึงปลายทาง'))]
    Wait Until Page Contains Element    ${BTN_ACTION}    timeout=15s
    Execute JavaScript    document.evaluate("${BTN_ACTION.replace('xpath=', '')}", document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue.click()
    Wait Until Page Contains    Check-in สำเร็จ    timeout=${TIMEOUT}