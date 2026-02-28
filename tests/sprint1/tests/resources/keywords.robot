*** Keywords ***

#เปิด browser + login admin
Open Browser And Login
    ${chrome options}=    Evaluate    sys.modules['selenium.webdriver'].ChromeOptions()    sys, selenium.webdriver

    ${prefs}=    Create Dictionary
    ...    download.default_directory=${DOWNLOAD_DIR}
    ...    download.prompt_for_download=${False}
    ...    download.directory_upgrade=${True}
    ...    safebrowsing.enabled=${True}

    Call Method    ${chrome options}    add_experimental_option    prefs    ${prefs}

    Open Browser    ${BASE_URL}/login    Chrome    options=${chrome options}

    Maximize Browser Window

    Wait Until Element Is Visible    id=identifier    20s
    Input Text    id=identifier    ${ADMIN_EMAIL}
    Input Text    id=password    ${ADMIN_PASSWORD}
    Click Button    xpath=//button[@type="submit"]

    Wait Until Page Contains    Dashboard    20s


#เข้าเมนู User Management
Go To User Management Page
    Go To    ${BASE_URL}/admin/users
    Wait Until Page Contains    User Management

#กดดู log ของ user ตาม email
Click User Log Button
    [Arguments]    ${email}

    Wait Until Element Is Visible    xpath=//table    20s
    Wait Until Page Contains         ${email}         20s

    Click Element
    ...    xpath=//tr[td[contains(.,"${email}")]]//button[contains(@title,"Log")]

