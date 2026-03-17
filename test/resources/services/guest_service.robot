*** Settings ***
Library    RequestsLibrary
Library    OperatingSystem
Library    Collections
Library    String
Library    DateTime

Resource    ../variables.robot

*** Keywords ***
Create User
    [Arguments]    ${username}    ${email}    ${password}    ${firstName}    ${lastName}    ${phoneNumber}    ${gender}    ${nationalIdNumber}    ${nationalIdExpiryDate}    ${role}    
    ...    ${id_card_image_path}=${CURDIR}/../userImage/id_card.png    
    ...    ${selfie_image_path}=${CURDIR}/../userImage/selfie_image.png
    [Documentation]    Create User
    
    ${data}=    Create Dictionary
    ...    username=${username}
    ...    email=${email}
    ...    password=${password}
    ...    firstName=${firstName}
    ...    lastName=${lastName}
    ...    phoneNumber=${phoneNumber}
    ...    gender=${gender}
    ...    nationalIdNumber=${nationalIdNumber}
    ...    nationalIdExpiryDate=${nationalIdExpiryDate}
    ...    role=${role}

    ${id_card_file}=    Get File For Streaming Upload    ${id_card_image_path}
    ${selfie_file}=    Get File For Streaming Upload    ${selfie_image_path}

    ${id_card_tuple}=    Evaluate    ("id_card.png", $id_card_file, "image/png")
    ${selfie_tuple}=     Evaluate    ("selfie.png", $selfie_file, "image/png")
    
    ${files}=    Create Dictionary
    ...    nationalIdPhotoUrl=${id_card_tuple}
    ...    selfiePhotoUrl=${selfie_tuple}

    ${response}=    POST
    ...    ${REGISTER_URL}
    ...    data=${data}
    ...    files=${files}
    RETURN    ${response.json()}

Login And Get Token
    [Arguments]    ${user_email}    ${user_password}
    [Documentation]    Login และเก็บ JWT token ไว้ใช้ทุก testcase
    Create Session    auth    ${BASE_URL}    verify=false

    ${credentials}=    Create Dictionary
    ...    email=${user_email}
    ...    password=${user_password}

    ${headers}=    Create Dictionary
    ...    Content-Type=application/json
    ...    x-gateway-key=${X-GATEWAY-KEY}

    ${response}=    POST On Session    auth    ${LOGIN_URL}    json=${credentials}    headers=${headers}
    Status Should Be    200    ${response}

    ${body}=    Set Variable    ${response.json()}
    ${data}=    Set Variable    ${body}[data]
    # Log To Console    data: ${data}
    ${token}=    Get From Dictionary    ${data}    token
    ${user_id}=    Get From Dictionary    ${data}[user]    id

    ${headers}=    Create Dictionary
    ...    Authorization=Bearer ${token}
    ...    Content-Type=application/json

    # Create Session    myRoute    ${BASE_URL}    headers=${headers}    verify=false
    # Log    Logged in - token acquired
    RETURN    ${token}    ${user_id}

