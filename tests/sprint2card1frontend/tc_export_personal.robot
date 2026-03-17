*** Settings ***
Library           SeleniumLibrary
Resource          resources_card1/variables.robot
Resource          resources_card1/keywords.robot
Suite Setup       Setup Suite Session
Suite Teardown    Close All Browsers


TC08 Export Modal Opens
    Open First User Log
    Open Export Modal
    Page Should Contain    ข้อมูลส่วนบุคคล
    Close Export Modal

TC09 Export Modal Shows All Sections
    Open First User Log
    Open Export Modal
    Page Should Contain    ข้อมูลส่วนบุคคล
    Page Should Contain    ประวัติส่วนตัว
    Page Should Contain    ประวัติการเดินทาง
    Page Should Contain    ประวัติการสร้างเส้นทาง
    Page Should Contain    วันที่
    Page Should Contain    ประเภทของ Log
    Page Should Contain    Authentication & Access Logs
    Page Should Contain    Transactional & Activity Logs
    Page Should Contain    Navigation & Behavioral Logs
    Page Should Contain    Security & Audit Logs
    Close Export Modal

TC10 Export Personal History
    Open First User Log
    Open Export Modal
    Select Personal Section    ประวัติส่วนตัว
    Confirm Export

TC11 Export Travel History
    Open First User Log
    Open Export Modal
    Select Personal Section    ประวัติการเดินทาง
    Confirm Export

TC12 Export Route History
    Open First User Log
    Open Export Modal
    Select Personal Section    ประวัติการสร้างเส้นทาง
    Confirm Export


TC13 Export No Options Selected
    Open First User Log
    Open Export Modal
    Confirm Export

TC14 Export Cancel Closes Modal
    Open First User Log
    Open Export Modal
    Close Export Modal
    Page Should Not Contain    Export log