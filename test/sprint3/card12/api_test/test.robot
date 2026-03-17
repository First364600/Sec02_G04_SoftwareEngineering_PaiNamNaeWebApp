*** Settings ***
Library    RequestsLibrary
Library    Collections
Library    String
Resource   setup.robot

Suite Setup    Setup All Sessions
Suite Teardown    Delete All Users

*** Variables ***
&{MESSAGES_ID_LIST}

*** Test Cases ***
# =====================================================================================
# FLOW 1: คนขับและผู้โดยสารส่งข้อความถึงกัน (ก่อนที่การเดินทางจะเริ่ม)
# =====================================================================================
TC01.2: [Negative] คนขับกดส่งข้อความก่อนที่การเดินทางจะเริ่ม
    ${message}=    Set Variable    คนขับถึงจุดหมายแล้วครับ
    ${current_route_id}=    Set Variable    ${ROUTES_LIST}[route1][id]
    @{bookings}=    Create List    ${BOOKINGS_LIST}[route1_book1][id]
    ${response}=    Driver Send Message to Passenger (one or more)
    ...    sessionName=DriverSession
    ...    routeId=${current_route_id}
    ...    bookingIds=${bookings}
    ...    message=${message}
    Log To Console    ${response}
    Should Not Be True    ${response}[success]
    Should Be Equal As Strings    ${response}[message]    ไม่สามารถส่งข้อความได้ เนื่องจากเส้นทางยังไม่เริ่มต้น


# =====================================================================================
# FLOW 2: คนขับและผู้โดยสารส่งข้อความถึงกัน (เมื่อเริ่มการเดินทางแล้ว)
# =====================================================================================
TC01.1: [Negative] กดส่งข้อความ ทั้งที่ตนเองไม่ใช่เจ้าของการเดินทางหรือไม่ใช่เจ้าของการจองนั้น
    ${message}=    Set Variable    คนขับถึงจุดหมายแล้วครับ
    ${current_route_id}=    Set Variable    ${ROUTES_LIST}[route1][id]
    @{bookings}=    Create List    ${BOOKINGS_LIST}[route1_book1][id]
    ${response}=    Driver Send Message to Passenger (one or more)
    ...    sessionName=Passenger2Session
    ...    routeId=${current_route_id}
    ...    bookingIds=${bookings}
    ...    message=${message}
    Log To Console    ${response}
    Should Not Be True    ${response}[success]
    Should Be Equal As Strings    ${response}[message]    คุณต้องยืนยันตัวตนผู้ขับก่อนจึงจะดำเนินการนี้ได้

    
TC01.3: [Negative] คนขับกดส่งข้อความไปที่ผู้โดยสาร พร้อมกันหลายคน ทั้งที่การเดินทางยังไม่เริ่ม
    ${message}=    Set Variable    กำลังออกเดินทาง และกำลังไปรับทุกๆ คน
    ${current_route_id}=    Set Variable    ${ROUTES_LIST}[route1][id]
    @{bookings_list}=    Create List    
    ...    ${BOOKINGS_LIST}[route1_book1][id]
    ...    ${BOOKINGS_LIST}[route1_book2][id]

    ${response}=    Driver Send Message to Passenger (one or more)
    ...    sessionName=DriverSession
    ...    routeId=${current_route_id}
    ...    bookingIds=${bookings_list}
    ...    message=${message}

    Should Not Be True    ${response}[success]
    Should Be Equal As Strings    ${response}[message]    ไม่สามารถส่งข้อความได้ เนื่องจากเส้นทางยังไม่เริ่มต้น

TC01.4: [Positive] คนขับกดส่งข้อความไปที่ผู้โดยสารคนเดียว
    ${message}=    Set Variable    คนขับถึงจุดหมายแล้วครับ
    ${current_route_id}=    Set Variable    ${ROUTES_LIST}[route1][id]
    @{bookings}=    Create List    ${BOOKINGS_LIST}[route1_book2][id]

    # เรื่มต้นการเดินทาง
    Driver Update Trip (start trip, checkpoint, end trip)
    ...    sessionName=DriverSession
    ...    routeId=${current_route_id}
    ...    currentStep=${1}
    ...    status=IN_TRANSIT
    # ส่งข้อความ
    ${response}=    Driver Send Message to Passenger (one or more)
    ...    sessionName=DriverSession
    ...    routeId=${current_route_id}
    ...    bookingIds=${bookings}
    ...    message=${message}

    Should Be True    ${response}[success]
    Should Be Equal As Strings    ${response}[data][0][content]    ${message}
    Log To Console    ${response}
    Set To Dictionary    ${MESSAGES_ID_LIST}    route1_message1    ${response}[data][0][id]

TC01.5: [Negative] คนขับกดส่งข้อความที่ ว่างเปล่า ไปที่ผู้โดยสาร
    ${message}=    Set Variable    
    ${current_route_id}=    Set Variable    ${ROUTES_LIST}[route1][id]
    @{bookings}=    Create List    ${BOOKINGS_LIST}[route1_book2][id]

    # ส่งข้อความ
    ${response}=    Driver Send Message to Passenger (one or more)
    ...    sessionName=DriverSession
    ...    routeId=${current_route_id}
    ...    bookingIds=${bookings}
    ...    message=${message}
    Log To Console    empty: ${response}
    Should Not Be True    ${response}[success]
    Should Be Equal As Strings    ${response}[message]    ไม่สามารถส่งข้อความที่ว่างเปล่าได้

TC01.6 [Negative] คนขับไม่สามารถส่งข้อความไปที่แชทที่ไม่ได้จองกับการเดินทางของตัวเอง (Booking id ไม่ได้เกี่ยวข้อง Route id นั้นๆ ของตัวเอง)
    ${message}=    Set Variable    นี่เป็นข้อความที่ไม่ได้มาจากการเดินทางนี้
    ${current_route_id}=    Set Variable    ${ROUTES_LIST}[route1][id]
    @{bookings}=    Create List    ${BOOKINGS_LIST}[route2_book1][id]

    ${response}=    Driver Send Message to Passenger (one or more)
    ...    sessionName=DriverSession
    ...    routeId=${current_route_id}
    ...    bookingIds=${bookings}
    ...    message=${message}

    Log To Console    1.6: ${response}
    Should Not Be True    ${response}[success]
    Should Be Equal As Strings    ${response}[message]    ไม่พบผู้โดยสารเป้าหมายที่ต้องการส่ง

TC01.7: [Positive] คนขับกดส่งข้อความไปที่ผู้โดยสาร พร้อมกันหลายคน
    ${message}=    Set Variable    กำลังออกเดินทาง และกำลังไปรับทุกๆ คน
    ${current_route_id}=    Set Variable    ${ROUTES_LIST}[route1][id]
    @{bookings_list}=    Create List    
    ...    ${BOOKINGS_LIST}[route1_book1][id]
    ...    ${BOOKINGS_LIST}[route1_book2][id]
    Log To Console    booking list: ${bookings_list}
    ${response}=    Driver Send Message to Passenger (one or more)
    ...    sessionName=DriverSession
    ...    routeId=${current_route_id}
    ...    bookingIds=${bookings_list}
    ...    message=${message}
    Log To Console    mose: ${response}
    Should Be True    ${response}[success]
    Should Be Equal As Strings    ${response}[data][0][content]    ${message}
    Should Be Equal As Strings    ${response}[data][1][content]    ${message}

    Set To Dictionary    ${MESSAGES_ID_LIST}    
    ...    route1_message1    ${response}[data][0][id]
    ...    route1_message2    ${response}[data][1][id]

TC01.8: [Negative] ผู้โดยสารส่งข้อความไปที่แชทที่ไม่ได้เกี่ยวข้องกับตัวเอง
    ${message}=    Set Variable    นี่ไม่ใช่แชทของฉัน
    ${response}=    Passenger Send Message to Driver
    ...    sessionName=Passenger1Session
    # ผู้โดยสารคนแรก ส่งข้อความไปที่แชทของผู้โดยสารคนที่สอง
    ...    messageId=${MESSAGES_ID_LIST}[route1_message2]
    ...    message=${message}
    Log To Console    ${response}
    Should Not Be True    ${response}[success]
    Should Be Equal As Strings    ${response}[data]    None 

TC01.9: [Positive] ผู้โดยสารตอบกลับข้อความของคนขับ
    ${message}=    Set Variable    โอเค
    ${response}=    Passenger Send Message to Driver
    ...    sessionName=Passenger1Session
    ...    messageId=${MESSAGES_ID_LIST}[route1_message1]
    ...    message=${message}

    Should Be True    ${response}[success]
    Should Be Equal As Strings    ${response}[data][content]    ${message}

# =====================================================================================
# FLOW 3: คนขับและผู้โดยสารส่งข้อความถึงกัน (เมื่อการเดินทางของผู้โดยสารนั้นๆ ถูกยกเลิกแล้ว)
# =====================================================================================
TC03.1: [Negative] คนขับกดส่งข้อความทั้งที่การเดินทางของผู้โดยสารคนนั้น ถูกยกเลิกไปแล้ว
    ${message}=    Set Variable    การเดินทางของผู้โดยสารคนนี้ถูกยกเลิกแล้ว
    # คนขับขอยกเลิก
    Driver Cancel the Passenger Journey
    ...    sessionName=DriverSession
    ...    bookingId=${BOOKINGS_LIST}[route1_book1][id]

    # ผู้โดยสารยินยอมคำขอยกเลิกการเดินทางของคนขับ
    Passenger Confirm Trip Cancellation
    ...    sessionName=Passenger1Session
    ...    bookingId=${BOOKINGS_LIST}[route1_book1][id]

    # test
    ${response}=    Driver Send Message to Passenger (one or more)
    ...    sessionName=DriverSession
    ...    routeId=${ROUTES_LIST}[route1][id]
    ...    bookingIds=${BOOKINGS_LIST}[route1_book1][id]
    # ...    messageId=${MESSAGES_ID_LIST}[route1_message1]
    ...    message=${message}

    Log To Console    179: ${response}
    Should Not Be True    ${response}[success]
    Should Be Equal As Strings    ${response}[message]    ไม่พบผู้โดยสารเป้าหมายที่ต้องการส่ง

TC03.2: [Negative] ผู้โดยสารส่งข้อความทั้งที่การเดินทางของตัวเอง ถูกยกเลิกไปแล้ว
    ${message}=    Set Variable    การเดินทางของฉันถูกยกเลิกแล้ว

    ${response}=    Passenger Send Message to Driver
    ...    sessionName=Passenger1Session
    ...    messageId=${MESSAGES_ID_LIST}[route1_message1]
    # ...    routeId=${ROUTES_LIST}[route1][id]
    # ...    bookingIds=${BOOKINGS_LIST}[route1_book1][id]
    ...    message=${message}

    Log To Console    3.2: ${response}
    Should Not Be True    ${response}[success]
    Should Be Equal As Strings    ${response}[message]    ไม่สามารถส่งข้อความได้ เนื่องจากเส้นทางถูกยกเลิก

# =====================================================================================
# FLOW 4: คนขับและผู้โดยสารส่งข้อความถึงกัน (เมื่อการเดินทางสิ้นสุดแล้ว)
# =====================================================================================
TC04.1: [Negative] คนขับส่งข้อความทั้งที่การเดินทางสิ้นสุดแล้ว
    ${message}=    Set Variable    การเดินทางนี้สิ้นสุดลงแล้ว

    # คนขับกดรับผู้โดยสารคนที่ 2
    Driver Arrived (pickup passenger)
    ...    sessionName=DriverSession
    ...    bookingId=${BOOKINGS_LIST}[route1_book2][id]

    # ผู้โดยคนที่ 2 สารยืนการว่าคนขับมารับ
    Passenger Begin the Journey
    ...    sessionName=Passenger2Session
    ...    bookingId=${BOOKINGS_LIST}[route1_book2][id]

    # คนขับกดสิ้นสุดการเดินทาง
    Driver Update Trip (start trip, checkpoint, end trip)
    ...    sessionName=DriverSession
    ...    routeId=${ROUTES_LIST}[route1][id]
    ...    currentStep=${3}
    ...    status=COMPLETED

    # test
    ${response}=    Driver Send Message to Passenger (one or more)
    ...    sessionName=DriverSession
    ...    routeId=${ROUTES_LIST}[route1][id]
    ...    bookingIds=${BOOKINGS_LIST}[route1_book2][id]
    ...    message=${message}

    Log To Console    4.1: ${response}
    Should Not Be True    ${response}[success]
    Should Be Equal As Strings    ${response}[message]    ไม่สามารถส่งข้อความได้ เนื่องจากเส้นทางเสร็จสิ้นแล้ว

TC04.2: [Negative] ผู้โดยสารส่งข้อความทั้งที่การเดินทางสิ้นสุดแล้ว
    ${message}=    Set Variable    การเดินทางของฉันสิ้นสุดแล้ว

    ${response}=    Passenger Send Message to Driver
    ...    sessionName=Passenger2Session
    ...    messageId=${MESSAGES_ID_LIST}[route1_message2]
    ...    message=${message}

    Log To Console    4.2: ${response}
    Should Not Be True    ${response}[success]
    Should Be Equal As Strings    ${response}[message]    ไม่สามารถส่งข้อความได้ เนื่องจากการเดินทางของคุณเสร็จสิ้นแล้ว