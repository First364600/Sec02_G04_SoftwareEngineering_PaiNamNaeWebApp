*** Settings ***
Library    RequestsLibrary
Library    OperatingSystem
Library    Collections
Library    String
Library    DateTime

Resource    variables.robot

*** Keywords ***
Create User
    [Arguments]    ${username}    ${email}    ${password}    ${firstName}    ${lastName}    ${phoneNumber}    ${gender}    ${nationalIdNumber}    ${nationalIdExpiryDate}    ${role}    
    ...    ${id_card_image_path}=${CURDIR}/userImage/id_card.png    
    ...    ${selfie_image_path}=${CURDIR}/userImage/selfie_image.png
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

Driver Create Route
    [Arguments]    ${sessionName}    ${vehicleId}    ${startLocation}    ${endLocation}    ${waypoints}    ${departureTime}    ${seats}    ${price}    ${conditions}
    [Documentation]    Keyword สำหรับสร้างเส้นทาง (route) โดยคนขับ

    ${payload}=    Create Dictionary
    ...    vehicleId=${vehicleId}
    ...    startLocation=${startLocation}
    ...    endLocation=${endLocation}
    ...    waypoints=${waypoints}
    ...    optimizedWaypoints=${{True}}
    ...    departureTime=${departureTime}
    ...    availableSeats=${{int(${seats})}}
    ...    pricePerSeat=${{int(${price})}}
    ...    conditions=${conditions}

    ${response}=    POST On Session    
    ...    ${sessionName}    
    ...    ${ROUTE_URL}    
    ...    json=${payload}
    
    RETURN    ${response.json()}

Driver Create Vehicle
    [Arguments]    ${sessionName}    ${vehicleModel}    ${licensePlate}    ${vehicleType}    ${color}    ${seatCapacity}    ${isDefault}    ${amenities}    
    ...    ${frontImagePath}=${CURDIR}/vehicleImage/front.png
    ...    ${sideImagePath}=${CURDIR}/vehicleImage/side.png
    ...    ${inSideImagePath}=${CURDIR}/vehicleImage/inside.png
    [Documentation]    สร้างรถใหม่

    ${data}=    Create Dictionary
    ...    vehicleModel=${vehicleModel}
    ...    licensePlate=${licensePlate}
    ...    vehicleType=${vehicleType}
    ...    color=${color}
    ...    seatCapacity=${seatCapacity}
    ...    isDefault=${isDefault}
    ...    amenities=${amenities}

    ${frontImage}=    Get File For Streaming Upload    ${frontImagePath}
    ${sideImage}=    Get File For Streaming Upload    ${sideImagePath}
    ${inSideImage}=    Get File For Streaming Upload    ${inSideImagePath}
    
    ${files}=    Create List
    ...    ${{ ("photos", ("front.png", $frontImage, "image/png")) }}
    ...    ${{ ("photos", ("side.png", $sideImage, "image/png")) }}
    ...    ${{ ("photos", ("inSide.png", $inSideImage, "image/png")) }}

    # Workaround for RequestsLibrary issue with list of files
    ${lib}=    Get Library Instance    RequestsLibrary
    ${session}=    Call Method    ${lib._cache}    get_connection    ${sessionName}
    ${response}=    Call Method    ${session}    request    POST    ${CREATE_VEHICLE_URL}    data=${data}    files=${files}
    RETURN    ${response.json()}

Driver Verification
    [Arguments]    ${sessionName}    ${licenseNumber}    ${firstNameOnLicense}    ${lastNameOnLicense}    ${typeOnLicense}    ${licenseIssueDate}    ${licenseExpiryDate}    
    ...    ${licensePhotoUrl}=${CURDIR}/userImage/id_card.png
    ...    ${selfiePhotoUrl}=${CURDIR}/userImage/selfie_image.png
    [Documentation]    การยืนยันตัวตนของคนขับ

    ${data}=    Create Dictionary
    ...    licenseNumber=${licenseNumber}
    ...    firstNameOnLicense=${firstNameOnLicense}
    ...    lastNameOnLicense=${typeOnLicense}
    ...    typeOnLicense=${typeOnLicense}
    ...    licenseIssueDate=${licenseIssueDate}
    ...    licenseExpiryDate=${licenseExpiryDate}
    
    ${licensePhoto}=    Get File For Streaming Upload    ${licensePhotoUrl}
    ${selfiePhoto}=    Get File For Streaming Upload    ${selfiePhotoUrl}

    ${licensePhotoTuple}=    Evaluate    ("id_card.png", $licensePhoto, "image/png")
    ${selfiePhotoTuple}=    Evaluate    ("selfie.png", $selfiePhoto, "image/png")

    ${files}=    Create Dictionary
    ...    licensePhotoUrl=${licensePhotoTuple}
    ...    selfiePhotoUrl=${selfiePhotoTuple}

    ${response}=    POST On Session
    ...    ${sessionName}
    ...    ${DRIVER_VERIFICATION_URL}
    ...    data=${data}
    ...    files=${files}

    RETURN    ${response.json()}

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

Passenger Bookings Route
    [Arguments]    ${sessionName}    ${routeId}    ${numberOfSeats}    ${pickupLocation}    ${dropoffLocation}  
    [Documentation]    ผู้ใช้จองการเดินทาง  
    ${data}=    Create Dictionary
    ...    routeId=${routeId}
    ...    numberOfSeats=${numberOfSeats}
    ...    pickupLocation=${pickupLocation}
    ...    dropoffLocation=${dropoffLocation}

    ${response}=    POST On Session
    ...    ${sessionName}
    ...    ${BOOKING_ROUTE_URL}
    ...    json=${data}

    RETURN    ${response.json()}

Driver Confirm User Bookings
    [Arguments]    ${sessionName}    ${bookingId}    ${status}
    [Documentation]    คนขับยืนยันคำขอ หรือปฏิเสธ
    ${data}=    Create Dictionary
    ...    status=${status}
    
    ${response}=    PATCH On Session
    ...    ${sessionName}
    ...    ${BOOKING_ROUTE_URL}/${bookingId}/status
    ...    json=${data}

    RETURN    ${response.json()}

Driver Begin the Journey
    [Arguments]    ${sessionName}    ${routeId}    ${currentStep}=${0}    ${status}=IN_TRANSIT
    [Documentation]    คนขับเริ่มต้นการเดินทาง
    ${data}=    Create Dictionary
    ...    currentStep=${currentStep}
    ...    status=${status}

    ${response}=    PATCH On Session
    ...    ${sessionName}
    ...    ${ROUTE_URL}/${routeId}/progress
    ...    json=${data}

    RETURN    ${response.json()}

Driver Arrived (pickup passenger)
    [Arguments]    ${sessionName}    ${bookingId}
    [Documentation]    คนขับมาถึงจุดรับผู้โดยสาร
    
    ${response}=    PATCH On Session
    ...    ${sessionName}
    ...    ${BOOKING_ROUTE_URL}/${bookingId}/driver-arrived

    RETURN    ${response.json()}

Passenger Begin the Journey
    [Arguments]    ${sessionName}    ${bookingId}
    [Documentation]    ผู้โดยสารเริ่มต้นการเดินทาง

    ${response}=    PATCH On Session
    ...    ${sessionName}
    ...    ${BOOKING_ROUTE_URL}/${bookingId}/passenger-start

    RETURN    ${response.json()}
