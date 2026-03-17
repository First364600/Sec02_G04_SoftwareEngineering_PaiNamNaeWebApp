*** Settings ***
Library           SeleniumLibrary
Resource          resources/variables.robot
Resource          resources/keywords.robot
Suite Setup       Setup Suite Session
Suite Teardown    Close All Browsers
Test Setup        Ensure On Admin Users Page
Test Teardown    Run Keyword If Test Failed    Capture Page Screenshot    EMBED

*** Test Cases ***

# ตรวจสอบว่าสามารถ export log ประเภท Authentication & Access Logs ได้
TC15 Export AUTH Log
    Open First User Log
    Open Export Modal
    Select Log Type    AUTH
    Confirm Export

# ตรวจสอบว่าสามารถ export log ประเภท Transactional & Activity Logs ได้
TC16 Export TRANSACTION Log
    Open First User Log
    Open Export Modal
    Select Log Type    TRANSACTION
    Confirm Export

# ตรวจสอบว่าสามารถ export log ประเภท Navigation & Behavioral Logs ได้
TC17 Export BEHAVIOR Log
    Open First User Log
    Open Export Modal
    Select Log Type    BEHAVIOR
    Confirm Export

# ตรวจสอบว่าสามารถ export log ประเภท Security & Audit Logs ได้
TC18 Export SECURITY Log
    Open First User Log
    Open Export Modal
    Select Log Type    SECURITY
    Confirm Export

# ตรวจสอบว่าสามารถ export log โดยกำหนดช่วงวันที่ได้
TC19 Export With Date Range
    Open First User Log
    Open Export Modal
    Set Date Range    2026-03-15    2026-03-15
    Confirm Export