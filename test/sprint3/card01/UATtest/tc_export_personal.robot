*** Settings ***
Library           SeleniumLibrary
Resource          resources/variables.robot
Resource          resources/keywords.robot
Suite Setup       Setup Suite Session
Suite Teardown    Close All Browsers


*** Test Cases ***

# ตรวจสอบว่าสามารถเปิด Export Modal ได้สำเร็จ
TC08 Export Modal Opens
    Open First User Log
    Open Export Modal
    Page Should Contain    ข้อมูลส่วนบุคคล
    Close Export Modal

# ตรวจสอบว่า Export Modal แสดงทุก section ที่ต้องมี
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

# ตรวจสอบว่าสามารถ Export ข้อมูล "ประวัติส่วนตัว" ของผู้ใช้ได้
TC10 Export Personal History
    Open First User Log
    Open Export Modal
    Select Personal Section    ประวัติส่วนตัว
    Confirm Export

# ตรวจสอบว่าสามารถ Export "ประวัติการเดินทาง" ของผู้ใช้ได้
TC11 Export Travel History
    Open First User Log
    Open Export Modal
    Select Personal Section    ประวัติการเดินทาง
    Confirm Export

# ตรวจสอบว่าสามารถ Export "ประวัติการสร้างเส้นทาง" ของผู้ใช้ได้
TC12 Export Route History
    Open First User Log
    Open Export Modal
    Select Personal Section    ประวัติการสร้างเส้นทาง
    Confirm Export

# ตรวจสอบการกด Export โดยที่ไม่เลือกตัวเลือกใดเลย
TC13 Export No Options Selected
    Open First User Log
    Open Export Modal
    Confirm Export

# ตรวจสอบว่าปุ่ม Cancel สามารถปิด Export Modal ได้
TC14 Export Cancel Closes Modal
    Open First User Log
    Open Export Modal
    Close Export Modal
    Page Should Not Contain    Export log