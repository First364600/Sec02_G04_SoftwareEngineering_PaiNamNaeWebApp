*** Settings ***
Library    RequestsLibrary
Library    Collections
Library    String
Resource    ../card09/setup.robot

Suite Setup    Setup All Sessions
Suite Teardown    Delete All Sessions

*** Test Cases ***
TC-01: คนขับ เริ่มต้นการเดินทาง
    ${response}=    GET On Session    PassengerSession    ${BASE_URL}/api/routes
    # Log To Console    routes: ${response.json()}
    # POST On Session    driverSession    ${TRIPS_URL}
    # ${lib}=    Get Library Instance    RequestsLibrary
    # ${session}=    Set Variable    ${lib._cache.switch("DriverSession")}
    # Log To Console    ${session.headers}

    # ...    frontImagePath=
    # ...    sideImagePath=
    # ...    inSideImagePath=
    
