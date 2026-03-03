*** Settings ***
Library    RequestsLibrary
Library    OperatingSystem
Library    Collections
Library    String
Library    DateTime

Resource    ../variables.robot

*** Keywords ***
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

Passenger Begin the Journey
    [Arguments]    ${sessionName}    ${bookingId}
    [Documentation]    ผู้โดยสารเริ่มต้นการเดินทาง

    ${response}=    PATCH On Session
    ...    ${sessionName}
    ...    ${BOOKING_ROUTE_URL}/${bookingId}/passenger-start

    RETURN    ${response.json()}

Passenger Reject Pickup
    [Arguments]    ${sessionName}    ${bookingId}
    [Documentation]    ผู้โดยสารปฏิเสธการมารับของคนขับ
    ${response}=    PATCH On Session
    ...    ${sessionName}
    ...    ${BOOKING_ROUTE_URL}/${bookingId}/passenger-reject-pickup

    RETURN    ${response.json()}

Passenger Confirm Trip Cancellation
    [Arguments]    ${sessionName}    ${bookingId}
    [Documentation]    ผู้โดยสารยืนยันการขอยกเลิกการเดินทางของคนขับ
    ${response}=    PATCH On Session
    ...    ${sessionName}
    ...    ${BOOKING_ROUTE_URL}/${bookingId}/passenger-confirm-cancel

    RETURN    ${response.json()}

Passenger Reject Trip Cancellation
    [Arguments]    ${sessionName}    ${bookingId}
    [Documentation]    ผู้โดยสารปฏิเสธการขอยกเลิกการเดินทางของคนขับ
    ${response}=    PATCH On Session
    ...    ${sessionName}
    ...    ${BOOKING_ROUTE_URL}/${bookingId}/passenger-reject-cancel

    RETURN    ${response.json()}