*** Settings ***
Library    RequestsLibrary
Library    Collections
Library    String
Resource    ../card09/setup.robot

Suite Setup    Setup All Sessions
Suite Teardown    Delete All Sessions

*** Variables ***
&{BOOKINGS}

*** Test Cases ***
TC-01: คนขับ ถึงจุดนัดหมายและ รับผู้โดยสาร **สำเร็จ**
    ${current_route_id}=    Set Variable    ${ROUTES_LIST}[0][id]

    # จองเส้นทาง
    ${response}=    Passenger Bookings Route    
    ...    sessionName=PassengerSession    
    ...    routeId=${current_route_id}   
    ...    numberOfSeats=${2}    
    ...    pickupLocation=${BOOKINGS_PICKUP_LOCATION}    
    ...    dropoffLocation=${BOOKINGS_DROPOFF_LOCATION}
    Set To Dictionary    ${BOOKINGS}    booking_1    ${response}[data]

    # คนขับมารับผู้โดยสาร
    ${current_booking_id}=    Set Variable    ${BOOKINGS}[booking_1][id]
    ${response}=    Driver Arrived (pickup passenger)  
    ...    sessionName=DriverSession    
    ...    bookingId=${current_booking_id}
    
    # ผู้โดยสารยืนยันว่าคนขับมารับ (กด เริ่มต้นเดินทาง)
    ${response}=    Passenger Begin the Journey    
    ...    sessionName=PassengerSession    
    ...    bookingId=${current_booking_id}
    # Log To Console    response: ${response}
    Should Be True    ${response}[success]    msg=เริ่มต้นการเดินทางไม่สำเร็จ: ${response}
    Should Be Equal As Strings    ${response}[data][passengerStatus]    IN_TRANSIT
    
TC-02: คนขับ ถึงจุดนัดหมายและ รับผู้โดยสาร **ไม่สำเร็จ**
    ${current_route_id}=    Set Variable    ${ROUTES_LIST}[0][id]

    # จองเส้นทาง
    ${response}=    Passenger Bookings Route    
    ...    sessionName=PassengerSession    
    ...    routeId=${current_route_id}   
    ...    numberOfSeats=${2}    
    ...    pickupLocation=${BOOKINGS_PICKUP_LOCATION}    
    ...    dropoffLocation=${BOOKINGS_DROPOFF_LOCATION}
    Set To Dictionary    ${BOOKINGS}    booking_2    ${response}[data]

    # คนขับมารับผู้โดยสาร
    ${current_booking_id}=    Set Variable    ${BOOKINGS}[booking_2][id]
    ${response}=    Driver Arrived (pickup passenger)    
    ...    sessionName=DriverSession    
    ...    bookingId=${current_booking_id}
    
    # ผู้โดยสารยืนยันว่าคนขับมารับ (กด เริ่มต้นเดินทาง)
    ${response}=    Passenger Reject Pickup  
    ...    sessionName=PassengerSession    
    ...    bookingId=${current_booking_id}
    # Log To Console    response: ${response}
    Should Be True    ${response}[success]    msg=เริ่มต้นการเดินทางไม่สำเร็จ: ${response}
    Should Be Equal As Strings    ${response}[data][passengerStatus]    REJECTED_PICKUP

    # กรณีที่ rejected ไปแล้ว แต่ api request status ไปเป็น PENDING ใหม่อีกรอบ