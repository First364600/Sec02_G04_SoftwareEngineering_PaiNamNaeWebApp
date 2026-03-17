*** Settings ***
Library    RequestsLibrary
Library    OperatingSystem
Library    Collections
Library    String
Library    DateTime

Resource    ../variables.robot

*** Keywords ***

Admin Verifired Driver
    [Arguments]    ${sessionName}    ${userId}    ${isVerified}
    [Documentation]    แอดมินยืนยัน การยืนยันตัวตนของคนขับ

    ${data}=    Create Dictionary
    ...    isVerified=${{bool(${isVerified})}}

    ${response}=    PATCH On Session
    ...    ${sessionName}
    ...    ${ADMIN_VERIFIED_DRIVER_URL}/${userId}/status
    ...    json=${data}

    RETURN    ${response.json()}

