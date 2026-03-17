*** Settings ***
Library           SeleniumLibrary
Resource          resources/variables.robot
Resource          resources/keywords.robot
Suite Setup       Setup Suite Session
Suite Teardown    Close All Browsers
Test Setup        Ensure On Admin Users Page
Test Teardown    Run Keyword If Test Failed    Capture Page Screenshot    EMBED

*** Test Cases ***
TC15 Export AUTH Log
    Open First User Log
    Open Export Modal
    Select Log Type    AUTH
    Confirm Export

TC16 Export TRANSACTION Log
    Open First User Log
    Open Export Modal
    Select Log Type    TRANSACTION
    Confirm Export

TC17 Export BEHAVIOR Log
    Open First User Log
    Open Export Modal
    Select Log Type    BEHAVIOR
    Confirm Export

TC18 Export SECURITY Log
    Open First User Log
    Open Export Modal
    Select Log Type    SECURITY
    Confirm Export

TC19 Export With Date Range
    Open First User Log
    Open Export Modal
    Set Date Range    2026-03-01    2026-03-01
    Confirm Export