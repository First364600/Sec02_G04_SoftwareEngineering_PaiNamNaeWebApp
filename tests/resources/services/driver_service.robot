*** Settings ***
Library    RequestsLibrary
Library    OperatingSystem
Library    Collections
Library    String
Library    DateTime

Resource    ../variables.robot

*** Keywords ***
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
    ...    ${frontImagePath}=${CURDIR}/../vehicleImage/front.png
    ...    ${sideImagePath}=${CURDIR}/../vehicleImage/side.png
    ...    ${inSideImagePath}=${CURDIR}/../vehicleImage/inSide.png
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
    ...    ${licensePhotoUrl}=${CURDIR}/../userImage/id_card.png
    ...    ${selfiePhotoUrl}=${CURDIR}/../userImage/selfie_image.png
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

Driver Update Trip (start trip, checkpoint, end trip)
    [Arguments]    ${sessionName}    ${routeId}    ${currentStep}=    ${status}=IN_TRANSIT
    [Documentation]    คนขับ currentStep= 0 เมื่อเริ่มต้นการเดินทาง, 2 ถึง n-1 เป็น checkpoint, n เป็นสิ้นสุดการเดินทาง
    ${data}=    Create Dictionary
    ...    currentStep=${{int(${currentStep})}}
    ...    status=${status}

    ${response}=    PATCH On Session
    ...    ${sessionName}
    ...    ${ROUTE_URL}/${routeId}/progress
    ...    json=${data}

    RETURN    ${response.json()}

# คนขับกดปุ่ม รับผู้โดยสาร
Driver Arrived (pickup passenger)
    [Arguments]    ${sessionName}    ${bookingId}
    [Documentation]    คนขับมาถึงจุดรับผู้โดยสาร
    
    ${response}=    PATCH On Session
    ...    ${sessionName}
    ...    ${BOOKING_ROUTE_URL}/${bookingId}/driver-arrived

    RETURN    ${response.json()}

# คนขับกดปุ่ม ยกเลิกการเดินทาง
Driver Cancel the Passenger Journey
    [Arguments]    ${sessionName}    ${bookingId}
    [Documentation]    คนขับยกเลิกการเดินทางของผู้โดยสาร
    ${response}=    PATCH On Session
    ...    ${sessionName}
    ...    ${BOOKING_ROUTE_URL}/${bookingId}/driver-cancel-request

    RETURN    ${response.json()}
