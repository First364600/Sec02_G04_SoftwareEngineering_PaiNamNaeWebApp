*** Settings ***
Library    RequestsLibrary
Library    Collections
Library    String
Resource    ${CURDIR}/../../../resources/services/admin_serive.robot
Resource    ${CURDIR}/../../../resources/services/driver_service.robot
Resource    ${CURDIR}/../../../resources/services/passenger_service.robot
Resource    ${CURDIR}/../../../resources/services/guest_service.robot
Resource    ${CURDIR}/../../../resources/variables.robot

*** Variables ***

# Global variables
&{ROUTES_LIST}
@{USERS_ID}
&{BOOKINGS_LIST}

# ผู้โดยสาร
${PASSENGER_EMAIL}                   passsenger@test.com
${PASSENGER_USERNAME}                passenger
${PASSENGER_PASSWORD}                Passenger1234567
${PASSENGER_FIRSTNAME}               passenger_firstname
${PASSENGER_LASTNAME}                passenger_lastname
${PASSENGER_PHONE_NUMBER}            0123456789
${PASSENGER_GENDER}                  MALE
${PASSENGER_ROLE}                    PASSENGER
${PASSENGER_NATIONAL_ID_NUMBER}      0123456789545
${PASSENGER_NATIONAL_ID_EXPIRY_DATE}    2025-12-23T00:00:00.000Z
# ไม่ต้องใส่ path ก็ได้ เพราะว่าทำ default ไว้ให้แล้ว
${PASSENGER_ID_CARD_IMAGE_PATH}      tests/esources/serImage/id_card.png
${PASSENGER_SELFIE_IMAGE_PATH}      tests/esources/serImage/selfie_image.png

# ผู้โดยสารคนที่สอง
${PASSENGER2_EMAIL}                   passsenger2@test.com
${PASSENGER2_USERNAME}                passenger2
${PASSENGER2_PASSWORD}                Passenger21234567
${PASSENGER2_FIRSTNAME}               passenger2_firstname
${PASSENGER2_LASTNAME}                passenger2_lastname
${PASSENGER2_PHONE_NUMBER}            0123456789
${PASSENGER2_GENDER}                  MALE
${PASSENGER2_ROLE}                    PASSENGER
${PASSENGER2_NATIONAL_ID_NUMBER}      0123456789233
${PASSENGER2_NATIONAL_ID_EXPIRY_DATE}    2025-12-23T00:00:00.000Z

# คนขับ
${DRIVER_EMAIL}                   firstt99000@gmail.com
${DRIVER_USERNAME}                driver
${DRIVER_PASSWORD}                Driver1234567
${DRIVER_FIRSTNAME}               driver_firstname
${DRIVER_LASTNAME}                driver_lastname
${DRIVER_PHONE_NUMBER}            0123456789
${DRIVER_GENDER}                  MALE
${DRIVER_ROLE}                    DRIVER
${DRIVER_NATIONAL_ID_NUMBER}      0123456789543
${DRIVER_NATIONAL_ID_EXPIRY_DATE}    2025-12-23T00:00:00.000Z

# คนขับยืนยันตัวตน
${DRIVER_VERIFICATION_LICENSE_NUMBER}               12345667
${DRIVER_VERIFICATION_FIRST_NAME_ON_LICENSE}        driver_firstname
${DRIVER_VERIFICATION_LAST_NAME_ON_LICENSE}         driver_lastname
${DRIVER_VERIFICATION_TYPE_ON_LICENSE}              LIFETIME
${DRIVER_VERIFICATION_LICENSE_ISSUE_DATE}           2026-03-04T00:00:00.000Z
${DRIVER_VERIFICATION_LICENSE_EXPIRY_DATE}          2026-03-11T00:00:00.000Z

# คนขับสร้างรถ ใหม่
${VEHICLE_MODEL}                Toyota
${VEHICLE_LICENSE_PLATE}        กก 1234
${VEHICLE_TYPE}                 sedan
${VEHICLE_COLOR}                black
${VEHICLE_SEAT_CAPACITY}        ${4}
${VEHICLE_IS_DEFAULT}           ${{True}}
@{VEHICLE_AMENITIES}            Music    WiFi

# คนขับสร้างเส้นทาง
${ROUTE_VEHICLE_ID}             null
${ROUTE_OPTIMIZED_WAYPOINTS}    ${{True}}
${ROUTE_DEPARTURE_TIME}         2026-03-10T08:00:00.000Z
${ROUTE_AVAILABLE_SEATS}        4
${ROUTE_PRICE_PER_SEAT}         150
${ROUTE_CONDITIONS}             No smoking

&{ROUTE_START_LOCATION}
...    lat=${16.43215376414419}
...    lng=${102.82355787126158}
...    name=เทศบาลนครขอนแก่น อำเภอเมืองขอนแก่น ขอนแก่น 40000
...    address=เทศบาลนครขอนแก่น อำเภอเมืองขอนแก่น ขอนแก่น 40000
&{ROUTE_END_LOCATION}
...    lat=${13.75632914260191}
...    lng=${100.50175864165533}
...    name=กรุงเทพมหานคร
...    address=กรุงเทพมหานคร
&{WAYPOINT_1}
...    lat=${14.973849056783576}
...    lng=${102.08365192790052}
...    name=เทศบาลนครนครราชสีมา ตำบลในเมือง อำเภอเมืองนครราชสีมา นครราชสีมา 30000
...    address=เทศบาลนครนครราชสีมา ตำบลในเมือง อำเภอเมืองนครราชสีมา นครราชสีมา 30000
# ${WAYPOINT_2}
# ...

@{ROUTE_WAYPOINTS}    ${WAYPOINT_1}    # ${WAYPOINT_2}

# ผู้โดยสาร 1 จองการเดินทาง
${P1_BOOKINGS_NUMBER_OF_SEATS}        ${1}

&{P1_BOOKINGS_PICKUP_LOCATION}
...    lat=${16.432153}
...    lng=${102.8235572}
...    address=Khon Kaen, Mueang Khon Kaen District, Khon Kaen 40000, Thailand
...    name=Khon Kaen
...    placeId=ChIJL46YkStgIjERxpx5zwUIPwk

&{P1_BOOKINGS_DROPOFF_LOCATION}
...    lat=${14.9739015}
...    lng=${102.0836593}
...    address=Nai Mueang, Mueang Nakhon Ratchasima District, Nakhon Ratchasima 30000, Thailand
...    name=Nai Mueang
...    placeId=ChIJhbHNZrhMGTERgOLeyM9pBAQ

# ผู้โดยสาร 2 จองการเดินทาง
${P2_BOOKINGS_NUMBER_OF_SEATS}        ${2}

&{P2_BOOKINGS_PICKUP_LOCATION}
...    lat=${14.9739015}
...    lng=${102.0836593}
...    address=Nai Mueang, Mueang Nakhon Ratchasima District, Nakhon Ratchasima 30000, Thailand
...    name=Nai Mueang
...    placeId=ChIJhbHNZrhMGTERgOLeyM9pBAQ

&{P2_BOOKINGS_DROPOFF_LOCATION}
...    lat=${13.75632914260191}
...    lng=${100.50175864165533}
...    name=กรุงเทพมหานคร
...    address=กรุงเทพมหานคร
...    placeId=ChIJL46YkStgIjERxpx5zwUIPwk

# คนขับยืนยันการจองของผู้ใช้
${DRIVER_CONFIRM_BOOKING_STATUS}        CONFIRMED

*** Keywords ***
Setup All Sessions
    [Documentation]    Login ทั้งคนขับและผู้โดยสาร

    # # Passenger Register
    Log To Console    Creating Passenger: ${PASSENGER_USERNAME}

    ${response}=    Create User
    ...    username=${PASSENGER_USERNAME}
    ...    email=${PASSENGER_EMAIL}
    ...    password=${PASSENGER_PASSWORD}
    ...    firstName=${PASSENGER_FIRSTNAME}
    ...    lastName=${PASSENGER_LASTNAME}
    ...    role=${PASSENGER_ROLE}
    ...    phoneNumber=${PASSENGER_PHONE_NUMBER}
    ...    gender=${PASSENGER_GENDER}
    ...    nationalIdNumber=${PASSENGER_NATIONAL_ID_NUMBER}
    ...    nationalIdExpiryDate=${PASSENGER_NATIONAL_ID_EXPIRY_DATE}

    # Driver Register
    Log To Console    Creating Driver: ${DRIVER_USERNAME}
    ${response}=    Create User
    ...    username=${DRIVER_USERNAME}
    ...    email=${DRIVER_EMAIL}
    ...    password=${DRIVER_PASSWORD}
    ...    firstName=${DRIVER_FIRSTNAME}
    ...    lastName=${DRIVER_LASTNAME}
    ...    role=${DRIVER_ROLE}
    ...    phoneNumber=${DRIVER_PHONE_NUMBER}
    ...    gender=${DRIVER_GENDER}
    ...    nationalIdNumber=${DRIVER_NATIONAL_ID_NUMBER}
    ...    nationalIdExpiryDate=${DRIVER_NATIONAL_ID_EXPIRY_DATE}

    Log To Console    Creating Passenger: ${PASSENGER2_USERNAME}
    ${response}=    Create User
    ...    username=${PASSENGER2_USERNAME}
    ...    email=${PASSENGER2_EMAIL}
    ...    password=${PASSENGER2_PASSWORD}
    ...    firstName=${PASSENGER2_FIRSTNAME}
    ...    lastName=${PASSENGER2_LASTNAME}
    ...    role=${PASSENGER2_ROLE}
    ...    phoneNumber=${PASSENGER2_PHONE_NUMBER}
    ...    gender=${PASSENGER2_GENDER}
    ...    nationalIdNumber=${PASSENGER2_NATIONAL_ID_NUMBER}
    ...    nationalIdExpiryDate=${PASSENGER2_NATIONAL_ID_EXPIRY_DATE}

    # Driver Login
    ${driver_token}    ${driver_id}=    Login And Get Token    user_email=${DRIVER_EMAIL}    user_password=${DRIVER_PASSWORD}
    &{driver_headers}=    Create Dictionary    Authorization=Bearer ${driver_token}    x-gateway-key=${X-GATEWAY-KEY}
    Create Session    DriverSession    ${BASE_URL}    headers=${driver_headers}
    Append To List    ${USERS_ID}    ${driver_id}
    
    # Passenger 1 Login
    ${passenger_token}    ${passenger_id}=    Login And Get Token    user_email=${PASSENGER_EMAIL}    user_password=${PASSENGER_PASSWORD}
    &{passenger_headers}=    Create Dictionary    Authorization=Bearer ${passenger_token}    x-gateway-key=${X-GATEWAY-KEY}
    Create Session    Passenger1Session    ${BASE_URL}    headers=${passenger_headers}
    Append To List    ${USERS_ID}    ${passenger_id}

    # Passenger 2 Login
    ${passenger2_token}    ${passenger2_id}=    Login And Get Token    user_email=${PASSENGER2_EMAIL}    user_password=${PASSENGER2_PASSWORD}
    &{passenger2_headers}=    Create Dictionary    Authorization=Bearer ${passenger2_token}    x-gateway-key=${X-GATEWAY-KEY}
    Create Session    Passenger2Session    ${BASE_URL}    headers=${passenger2_headers}
    Append To List    ${USERS_ID}    ${passenger2_id}

    # Admin Login
    ${admin_token}    ${admin_id}=    Login And Get Token    user_email=${ADMIN_EMAIL}    user_password=${ADMIN_PASSWORD}
    ${admin_headers}=    Create Dictionary    Authorization=Bearer ${admin_token}    x-gateway-key=${X-GATEWAY-KEY}
    Create Session    AdminSession    ${BASE_URL}    headers=${admin_headers}
    
    # # Driver Create Vehicle
    Log To Console    Creating Vehicle
    ${response}=    Driver Create Vehicle
    ...    sessionName=DriverSession
    ...    vehicleModel=${VEHICLE_MODEL}
    ...    licensePlate=${VEHICLE_LICENSE_PLATE}
    ...    vehicleType=${VEHICLE_TYPE}
    ...    color=${VEHICLE_COLOR}
    ...    seatCapacity=${VEHICLE_SEAT_CAPACITY}
    ...    isDefault=${VEHICLE_IS_DEFAULT}
    ...    amenities=${VEHICLE_AMENITIES}
    # ส่วนนี้ได้ set ค่า default ไว้แล้ว ไม่ต้องใส่ก็ได้
    # ...    frontImagePath=
    # ...    sideImagePath=
    # ...    inSideImagePath=
    ${data}=    Get From Dictionary    ${response}[data]    id
    Log To Console    data: ${data}
    Set Global Variable    ${ROUTE_VEHICLE_ID}    ${data}

    # Driver Verification
    Log To Console    Driver verification
    ${response}=    Driver Verification
    ...    sessionName=DriverSession
    ...    licenseNumber=${DRIVER_VERIFICATION_LICENSE_NUMBER}
    ...    firstNameOnLicense=${DRIVER_VERIFICATION_FIRST_NAME_ON_LICENSE}
    ...    lastNameOnLicense=${DRIVER_VERIFICATION_LAST_NAME_ON_LICENSE}
    ...    typeOnLicense=${DRIVER_VERIFICATION_TYPE_ON_LICENSE}
    ...    licenseIssueDate=${DRIVER_VERIFICATION_LICENSE_ISSUE_DATE}
    ...    licenseExpiryDate=${DRIVER_VERIFICATION_LICENSE_EXPIRY_DATE}

    # Admin Verified Driver
    Log To Console    Admin Verified Driver
    ${reponse}=    Admin Verifired Driver
    ...    sessionName=AdminSession
    ...    userId=${driver_id}
    ...    isVerified=${{True}}

    # Driver Create Route
    Log To Console    Creating Route
    ${response}=    Driver Create Route
    ...    sessionName=DriverSession
    ...    vehicleId=${ROUTE_VEHICLE_ID}
    ...    startLocation=${ROUTE_START_LOCATION}
    ...    endLocation=${ROUTE_END_LOCATION}
    ...    waypoints=${ROUTE_WAYPOINTS}
    ...    departureTime=${ROUTE_DEPARTURE_TIME}
    ...    seats=${ROUTE_AVAILABLE_SEATS}
    ...    price=${ROUTE_PRICE_PER_SEAT}
    ...    conditions=${ROUTE_CONDITIONS}

    ${ROUTE_ID}=    Get From Dictionary    ${response}[data]    id
    
    Set To Dictionary    ${ROUTES_LIST}    route1    ${response}[data]
    # Passenger 1 Bookings Route
    Log To Console    Passenger 1 Bookings Route
    ${response}=    Passenger Bookings Route
    ...    sessionName=Passenger1Session
    ...    routeId=${ROUTE_ID}
    ...    numberOfSeats=${P1_BOOKINGS_NUMBER_OF_SEATS}
    ...    pickupLocation=${P1_BOOKINGS_PICKUP_LOCATION}
    ...    dropoffLocation=${P1_BOOKINGS_DROPOFF_LOCATION}    

    ${BOOKING_ID}=    Get From Dictionary    ${response}[data]    id
    Set To Dictionary    ${BOOKINGS_LIST}    route1_book1    ${response}[data]    

    # Passenger 2 Bookings Route
    Log To Console    Passenger 2 Bookings Route
    ${response}=    Passenger Bookings Route
    ...    sessionName=Passenger2Session
    ...    routeId=${ROUTE_ID}
    ...    numberOfSeats=${P2_BOOKINGS_NUMBER_OF_SEATS}
    ...    pickupLocation=${P2_BOOKINGS_PICKUP_LOCATION}
    ...    dropoffLocation=${P2_BOOKINGS_DROPOFF_LOCATION}

    ${BOOKING_ID}=    Get From Dictionary    ${response}[data]    id
    Set To Dictionary    ${BOOKINGS_LIST}    route1_book2    ${response}[data]
    
    # Driver Confirm user bookings
    Log To Console    Driver comfirm bookings
    ${response}=    Driver Confirm User Bookings
    ...    sessionName=DriverSession
    ...    bookingId=${BOOKING_ID}
    ...    status=${DRIVER_CONFIRM_BOOKING_STATUS}

    # Driver Start Trip
    Log To Console    Driver Start Trip
    ${response}=    Driver Update Trip (start trip, checkpoint, end trip)
    ...    sessionName=DriverSession
    ...    routeId=${ROUTE_ID}
    ...    currentStep=0
    ...    status=IN_TRANSIT

    
    
    
    Log To Console    Setup Completed
# // DELETE /api/users/admin/:id
    
Delete All Users
    # Log To Console    users id: @{USERS_ID}
    FOR    ${user_id}    IN    @{USERS_ID}
        # Log To Console    user id: ${user_id}
        DELETE On Session    AdminSession    ${BASE_URL}/api/users/admin/${user_id}
    END
    Delete All Sessions
    