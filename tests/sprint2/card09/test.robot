*** Settings ***
Library    RequestsLibrary
Library    Collections
Library    String
Resource    ../card09/setup.robot

Suite Setup    Setup All Sessions
Suite Teardown    Delete All Users

*** Variables ***
&{BOOKINGS}

*** Test Cases ***

# =====================================================================================
# FLOW 1: การเดินทางสำเร็จช่วงต้น (Happy Path & Guard Clauses) - ใช้ route1_book1
# =====================================================================================

TC-01.1: [Negative] คนขับกดรับผู้โดยสาร (สิทธิ์ไม่ถูกต้อง)
    ${current_booking_id}=    Set Variable    ${BOOKINGS_LIST}[route1_book1][id]
    Run Keyword And Expect Error    *403*
    ...    Driver Arrived (pickup passenger)
    ...    sessionName=Passenger1Session
    ...    bookingId=${current_booking_id}

TC-01.2: [Positive] คนขับ ถึงจุดนัดหมายและกดรับผู้โดยสาร
    ${current_booking_id}=    Set Variable    ${BOOKINGS_LIST}[route1_book1][id]
    ${response}=    Driver Arrived (pickup passenger)
    ...    sessionName=DriverSession
    ...    bookingId=${current_booking_id}
    Should Be True    ${response}[success]
    Should Be Equal As Strings    ${response}[data][passengerStatus]    WAITING_PICKUP

TC-01.3: [Negative] คนขับกดรับผู้โดยสาร ซ้ำ (Double Arrive)
    ${current_booking_id}=    Set Variable    ${BOOKINGS_LIST}[route1_book1][id]
    Run Keyword And Expect Error    *400*
    ...    Driver Arrived (pickup passenger)
    ...    sessionName=DriverSession
    ...    bookingId=${current_booking_id}

TC-02.1: [Negative] ผู้โดยสารกดเริ่มเดินทาง (สิทธิ์ไม่ถูกต้อง)
    ${current_booking_id}=    Set Variable    ${BOOKINGS_LIST}[route1_book1][id]
    Run Keyword And Expect Error    *403*
    ...    Passenger Begin the Journey
    ...    sessionName=Passenger2Session
    ...    bookingId=${current_booking_id}

TC-02.2: [Positive] ผู้โดยสารกดเริ่มเดินทาง
    ${current_booking_id}=    Set Variable    ${BOOKINGS_LIST}[route1_book1][id]
    ${response}=    Passenger Begin the Journey
    ...    sessionName=Passenger1Session
    ...    bookingId=${current_booking_id}
    Should Be True    ${response}[success]
    Should Be Equal As Strings    ${response}[data][passengerStatus]    IN_TRANSIT

TC-02.3: [Negative] ผู้โดยสารกดเริ่มเดินทาง ซ้ำ
    ${current_booking_id}=    Set Variable    ${BOOKINGS_LIST}[route1_book1][id]
    Run Keyword And Expect Error    *400*
    ...    Passenger Begin the Journey
    ...    sessionName=Passenger1Session
    ...    bookingId=${current_booking_id}

# =====================================================================================
# FLOW 2: การยกเลิก (Cancel Path) - ใช้ route1_book2 (ต้องทำก่อนจบการเดินทาง)
# =====================================================================================

TC-04.1: [Negative] ผู้โดยสารกดเริ่มเดินทาง ทั้งที่คนขับยังไม่มากด Arrive
    ${current_booking_id}=    Set Variable    ${BOOKINGS_LIST}[route1_book2][id]
    Run Keyword And Expect Error    *400*
    ...    Passenger Begin the Journey
    ...    sessionName=Passenger2Session
    ...    bookingId=${current_booking_id}

TC-04.2: [Negative] คนขับกดยกเลิกการเดินทาง (สิทธิ์ไม่ถูกต้อง)
    ${current_booking_id}=    Set Variable    ${BOOKINGS_LIST}[route1_book2][id]
    Run Keyword And Expect Error    *403*
    ...    Driver Cancel the Passenger Journey
    ...    sessionName=Passenger1Session
    ...    bookingId=${current_booking_id}

TC-04.3: [Positive] คนขับกดยกเลิกการเดินทาง
    ${current_booking_id}=    Set Variable    ${BOOKINGS_LIST}[route1_book2][id]
    ${response}=    Driver Cancel the Passenger Journey
    ...    sessionName=DriverSession
    ...    bookingId=${current_booking_id}
    Should Be True    ${response}[success]
    Should Be True    ${response}[data][driverCancelRequest]

TC-04.4: [Negative] คนขับกดยกเลิก ซ้ำ (ส่งคำขอไปแล้ว)
    ${current_booking_id}=    Set Variable    ${BOOKINGS_LIST}[route1_book2][id]
    Run Keyword And Expect Error    *400*
    ...    Driver Cancel the Passenger Journey
    ...    sessionName=DriverSession
    ...    bookingId=${current_booking_id}

TC-05.1: [Negative] ผู้โดยสารปฏิเสธคำขอยกเลิก (สิทธิ์ไม่ถูกต้อง)
    ${current_booking_id}=    Set Variable    ${BOOKINGS_LIST}[route1_book2][id]
    Run Keyword And Expect Error    *403*
    ...    Passenger Reject Trip Cancellation
    ...    sessionName=Passenger1Session
    ...    bookingId=${current_booking_id}

TC-05.2: [Positive] ผู้โดยสารปฏิเสธคำขอยกเลิก
    ${current_booking_id}=    Set Variable    ${BOOKINGS_LIST}[route1_book2][id]
    ${response}=    Passenger Reject Trip Cancellation
    ...    sessionName=Passenger2Session
    ...    bookingId=${current_booking_id}
    Should Be True    ${response}[success]
    Should Not Be True    ${response}[data][driverCancelRequest]

TC-05.3: [Negative] ผู้โดยสารยืนยันการยกเลิก (ทั้งที่ไม่มีคำขอค้างอยู่ เพราะเพิ่งปฏิเสธไป)
    ${current_booking_id}=    Set Variable    ${BOOKINGS_LIST}[route1_book2][id]
    Run Keyword And Expect Error    *400*
    ...    Passenger Confirm Trip Cancellation
    ...    sessionName=Passenger2Session
    ...    bookingId=${current_booking_id}

TC-06.1: [Setup] คนขับกดยกเลิกการเดินทางอีกครั้ง (เพื่อให้ผู้โดยสารกดยืนยัน)
    ${current_booking_id}=    Set Variable    ${BOOKINGS_LIST}[route1_book2][id]
    ${response}=    Driver Cancel the Passenger Journey
    ...    sessionName=DriverSession
    ...    bookingId=${current_booking_id}
    Should Be True    ${response}[success]
    Should Be True    ${response}[data][driverCancelRequest]

TC-06.2: [Positive] ผู้โดยสาร ยืนยัน คำขอยกเลิก
    ${current_booking_id}=    Set Variable    ${BOOKINGS_LIST}[route1_book2][id]
    ${response}=    Passenger Confirm Trip Cancellation
    ...    sessionName=Passenger2Session
    ...    bookingId=${current_booking_id}
    Should Be True    ${response}[success]
    Should Be Equal As Strings    ${response}[data][status]    CANCELLED
    Should Be Equal As Strings    ${response}[data][passengerStatus]    CANCELLED

TC-06.3: [Negative] ผู้โดยสารยืนยันคำขอยกเลิก ซ้ำ (สถานะ Cancelled ไปแล้ว)
    ${current_booking_id}=    Set Variable    ${BOOKINGS_LIST}[route1_book2][id]
    Run Keyword And Expect Error    *400*
    ...    Passenger Confirm Trip Cancellation
    ...    sessionName=Passenger2Session
    ...    bookingId=${current_booking_id}

# =====================================================================================
# FLOW 3: จบการเดินทาง (End Trip) - ใช้ route1
# =====================================================================================

TC-03.1: [Positive] คนขับ กด Checkpoint
    ${response}=    Driver Update Trip (start trip, checkpoint, end trip)
    ...    sessionName=DriverSession
    ...    routeId=${ROUTES_LIST}[route1][id]
    ...    currentStep=${{int(${ROUTES_LIST}[route1][currentStep]) + 1}}
    ...    status=IN_TRANSIT
    Should Be True    ${response}[success]
    Should Be Equal As Strings    ${response}[data][status]    IN_TRANSIT

TC-03.2: [Positive] คนขับ กด สิ้นสุดการเดินทาง (End Trip)
    ${response}=    Driver Update Trip (start trip, checkpoint, end trip)
    ...    sessionName=DriverSession
    ...    routeId=${ROUTES_LIST}[route1][id]
    ...    currentStep=${{int(${ROUTES_LIST}[route1][currentStep]) + 2}}
    ...    status=COMPLETED
    Should Be True    ${response}[success]
    Should Be Equal As Strings    ${response}[data][status]    COMPLETED

TC-03.3: [Negative] คนขับกดยกเลิก ทั้งๆ ที่เดินทางเสร็จไปแล้ว
    ${current_booking_id}=    Set Variable    ${BOOKINGS_LIST}[route1_book1][id]
    Run Keyword And Expect Error    *400*
    ...    Driver Cancel the Passenger Journey
    ...    sessionName=DriverSession
    ...    bookingId=${current_booking_id}