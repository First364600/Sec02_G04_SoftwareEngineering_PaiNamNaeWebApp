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

# =================================================================================================================
# คนขับ ถึงจุดนัดหมายและ กดรับผู้โดยสาร
# =================================================================================================================

TC-01: คนขับ ถึงจุดนัดหมายและ กดรับผู้โดยสาร
    ${current_booking_id}=    Set Variable    ${BOOKINGS_LIST}[route1_book1][id]

    ${response}=    Driver Arrived (pickup passenger)
    ...    sessionName=DriverSession
    ...    bookingId=${current_booking_id}
    # Log To Console    arrived: ${response}
    Should Be True    ${response}[success]    msg=กดรับผู้โดยสารไม่สำเร็จ: ${response}
    Should Be Equal As Strings    ${response}[data][passengerStatus]    WAITING_PICKUP    msg=กดรับผู้โดยสารไม่สำเร็จ: ต้องการ passenger status: WAITING_PICKUP แต่ได้รับเป็น ${response}[data][passengerStatus]

TC-02: คนขับ ถึงจุดนัดหมายและ กดรับผู้โดยสาร (คนที่ request เป็นคนอื่นที่ไม่ใช่เจ้าของการเดินทาง)
    ${current_route_id}=    Set Variable    ${ROUTES_LIST}[route1][id]

TC-03: คนขับ กดรับผู้โดยสาร มากกว่าหนึ่งครั้ง
    ${current_route_id}=    Set Variable    ${ROUTES_LIST}[route1][id]

# =================================================================================================================
# คนขับกดยกเลิกการเดินทางของผู้โดยสาร
# =================================================================================================================
TC-01: คนขับ กดยกเลิกการเดินทางของผู้โดยสาร
    ${current_booking_id}=    Set Variable    ${BOOKINGS_LIST}[route1_book2][id]

    ${response}=    Driver Cancel the Passenger Journey
    ...    sessionName=DriverSession
    ...    bookingId=${current_booking_id}

    # Log To Console    cancel journey: ${response}
    Should Be True    ${response}[success]    msg=ยกเลิกการเดินทางของผู้โดยสารไม่สำเร็จ: ${response}
    Should Be True    ${response}[data][driverCancelRequest]    msg=ยกเลิกการเดินทางไม่สำเร็จ เพราะ driver cancel request ไม่เป็น true

TC-03: คนขับ กดยกเลิกการเดินทางของผู้โดยสาร (คนที่ request เป็นคนอื่นที่ไม่ใช่เจ้าของการเดินทาง)
    ${current_booking_id}=    Set Variable    ${BOOKINGS_LIST}[route1_book2][id]

TC-04: คนขับ กดยกเลิกการเดินทางของผู้โดยสาร มากกว่าหนึ่งครั้ง
    ${current_route_id}=    Set Variable    ${ROUTES_LIST}[route1][id]

TC-04: คนขับ กดยกเลิกการเดินทางของผู้โดยสาร ทั้งที่การเดินทาง complete ไปแล้ว
    ${current_route_id}=    Set Variable    ${ROUTES_LIST}[route1][id]

# =================================================================================================================
# ผู้โดยสาร *ยืนยัน* คำขอการยกเลิกกการเดินทาง ของคนขับ
# =================================================================================================================
TC-02-1: ผู้โดยสาร *ยืนยัน* คำขอการยกเลิกกการเดินทาง ของคนขับ
    ${current_booking_id}=    Set Variable    ${BOOKINGS_LIST}[route1_book2][id]

    ${response}=    Passenger Confirm Trip Cancellation
    ...    sessionName=Passenger2Session
    ...    bookingId=${current_booking_id}
    Log To Console    booking 2: ${response}
    Should Be True    ${response}[success]    msg=ไม่สามารถยืนยันคำขอการยกเลิกการเดินทางของคนขับได้: ${response}
    Should Be Equal As Strings    ${response}[data][status]    CANCELLED    msg=ไม่สามารถยืนยันคำขอการยกเลิกการเดินทางของคนขับได้เพราะต้องการ status: CANCELLED แต่ได้รับ ${response}[data][status]
    Should Be Equal As Strings    ${response}[data][passengerStatus]    CANCELLED    msg=ไม่สามารถยืนยันคำขอการยกเลิกการเดินทางของคนขับได้เพราะต้องการ status: CANCELLED แต่ได้รับ ${response}[data][passengerStatus]

TC-03: ผู้โดยสาร *ยืนยัน* คำขอการยกเลิกกการเดินทาง (คนที่ request เป็นคนอื่นที่ไม่ใช่เจ้าของการเดินทาง)
    ${current_booking_id}=    Set Variable    ${BOOKINGS_LIST}[route1_book2][id]

TC-02-1: ผู้โดยสาร *ยืนยัน* คำขอการยกเลิกกการเดินทาง ของคนขับ ทั้งๆ ที่คนขับ ยังไม่ได้กดส่งคำขอ ยกเลิกมา
    ${current_booking_id}=    Set Variable    ${BOOKINGS_LIST}[route1_book2][id]

TC-02-1: ผู้โดยสาร *ยืนยัน* คำขอการยกเลิกกการเดินทาง ของคนขับ (กรณีที่ผู้โดยสารนั้นไม่ใช่เจ้าของการจองนี้)
    ${current_booking_id}=    Set Variable    ${BOOKINGS_LIST}[route1_book2][id]

# =================================================================================================================
# ผู้โดยสาร *ปฏิเสธ* คำขอการยกเลิกกการเดินทาง ของคนขับ
# =================================================================================================================

TC-02-2: ผู้โดยสาร *ปฏิเสธ* คำขอการยกเลิกการเดินทาง ของคนขับ
    ${current_booking_id}=    Set Variable    ${BOOKINGS_LIST}[route1_book1][id]

    ${response}=    Passenger Reject Trip Cancellation
    ...    sessionName=Passenger1Session
    ...    bookingId=${current_booking_id}

    Should Be True    ${response}[success]    msg=ไม่สามารถปฏิเสธคำขอการยกเลิกการเดินทางของคนขับได้: ${response}
    Should Not Be True    ${response}[data][driverCancelRequest]    msg=ไม่สามารถปฏิเสธคำขอการยกเลิกการเดินทางของคนขับได้เพราะต้องการ driver cancel request: false แต่ได้รับ true

TC-03: ผู้โดยสาร *ปฏิเสธ* คำขอการยกเลิกกการเดินทาง (คนที่ request เป็นคนอื่นที่ไม่ใช่เจ้าของการเดินทาง)
    ${current_booking_id}=    Set Variable    ${BOOKINGS_LIST}[route1_book2][id]

TC-02-1: ผู้โดยสาร *ปฏิเสธ* คำขอการยกเลิกกการเดินทาง ของคนขับ ทั้งๆ ที่คนขับ ยังไม่ได้กดส่งคำขอ ยกเลิกมา
    ${current_booking_id}=    Set Variable    ${BOOKINGS_LIST}[route1_book2][id]

TC-02-1: ผู้โดยสาร *ปฏิเสธ* คำขอการยกเลิกกการเดินทาง ของคนขับ (กรณีที่ผู้โดยสารนั้นไม่ใช่เจ้าของการจองนี้)
    ${current_booking_id}=    Set Variable    ${BOOKINGS_LIST}[route1_book2][id]

# =================================================================================================================
# ผู้โดยสาร กดเริ่มต้นการเดินทาง
# =================================================================================================================

TC-03: ผู้โดยสาร กดเริ่มต้นการเดินทาง
    # เป็น booking ที่คนขับกดรับผู้โดยสาร (จาก TC-01)
    ${current_booking_id}=    Set Variable    ${BOOKINGS_LIST}[route1_book1][id]
    
    ${response}=    Passenger Begin the Journey
    ...    sessionName=Passenger1Session
    ...    bookingId=${current_booking_id}

    Should Be True    ${response}[success]    msg=ไม่สามารถเริ่มการเดินทางได้: ${response}
    Should Be Equal As Strings    ${response}[data][passengerStatus]    IN_TRANSIT    msg=ไม่สามารถเริ่มต้นการเดินทางได้: ต้องการ passenger status: IN_TRANSIT แต่ได้รับเป็น ${response}[data][passengerStatus]

TC-03: ผู้โดยสาร กดเริ่มต้นการเดินทาง (คนที่ request เป็นคนอื่นที่ไม่ใช่เจ้าของการเดินทาง)
    ${current_booking_id}=    Set Variable    ${BOOKINGS_LIST}[route1_book2][id]

TC-03: ผู้โดยสาร กดเริ่มต้นการเดินทาง ทั้งๆ ที่คนขับยังไม่กด Arrived
    ${current_booking_id}=    Set Variable    ${BOOKINGS_LIST}[route1_book1][id]

TC-03: ผู้โดยสาร กดเริ่มต้นการเดินทาง ทั้งๆ ที่คนขับยังไม่กด Arrived
    ${current_booking_id}=    Set Variable    ${BOOKINGS_LIST}[route1_book1][id]

TC-03: ผู้โดยสาร กดเริ่มต้นการเดินทาง ทั้งที่กำลังเดินทางอยู่
    ${current_booking_id}=    Set Variable    ${BOOKINGS_LIST}[route1_book1][id]

TC-03: ผู้โดยสาร กดเริ่มต้นการเดินทาง ทั้งที่การเดินทางสิ้นสุดไปแล้ว
    ${current_booking_id}=    Set Variable    ${BOOKINGS_LIST}[route1_book1][id]

# =================================================================================================================
# คนขับ กด checkpoint
# =================================================================================================================

TC-04: คนขับ กด checkpoint
    Log To Console    route1: ${ROUTES_LIST}[route1]
    ${response}=    Driver Update Trip (start trip, checkpoint, end trip)
    ...    sessionName=DriverSession
    ...    routeId=${ROUTES_LIST}[route1][id]
    ...    currentStep=${{int(${ROUTES_LIST}[route1][currentStep]) + 1}}
    ...    status=IN_TRANSIT

    Should Be True    ${response}[success]    msg=ไม่สามารถ checkpoint ได้: ${response}
    Should Be Equal As Strings    ${response}[data][status]    IN_TRANSIT    msg=ไม่สามารถ checkpoint ได้เพราะต้องการ status: IN_TRANSIT แต่ได้รับเป็น ${response}[data][status]

TC-03: คนขับ กด checkpoint (คนที่ request เป็นคนอื่นที่ไม่ใช่เจ้าของการเดินทาง)
    ${current_booking_id}=    Set Variable    ${BOOKINGS_LIST}[route1_book2][id]

TC-04: คนขับ กด checkpoint ข้ามลำดับ
    Log To Console    route1: ${ROUTES_LIST}[route1]

# =================================================================================================================
# คนขับ กด สิ้นสุดการเดินทาง
# =================================================================================================================

TC-05: คนขับ กด สิ้นสุดการเดินทาง
    ${current_route_id}=    Set Variable    ${ROUTES_LIST}[route1][id]

    ${response}=    Driver Update Trip (start trip, checkpoint, end trip)
    ...    sessionName=DriverSession
    ...    routeId=${current_route_id}
    ...    currentStep=${{int(${ROUTES_LIST}[route1][currentStep]) + 1}}
    ...    status=COMPLETED

    Should Be True    ${response}[success]    msg=ไม่สามารถ กดสิ้นสุดการเดินทางได้: ${response}
    Should Be Equal As Strings    ${response}[data][status]    COMPLETED    msg=ไม่สามารถ กดสิ้นสุดการเดินทางได้เพราะต้องการ status: COMPLETE แต่ได้รับ ${response}[data][status]

TC-03: คนขับ กด สิ้นสุดการเดินทาง (คนที่ request เป็นคนอื่นที่ไม่ใช่เจ้าของการเดินทาง)
    ${current_booking_id}=    Set Variable    ${BOOKINGS_LIST}[route1_book2][id]

TC-04: คนขับ กด สิ้นสุดการเดินทาง ทั้งๆ ที่ผู้โดยสารยังไม่ได้กดเริ่มต้นการเดินทาง
    Log To Console    route1: ${ROUTES_LIST}[route1]