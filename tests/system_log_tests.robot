*** Settings ***
Resource    resources/api_keywords.robot
Suite Setup    เชื่อมต่อระบบ API

*** Test Cases ***
Admin ดึงข้อมูล System Logs ได้สำเร็จ
    [Documentation]    ทดสอบกรณี Happy Path (Login -> Get Logs)
    Admin เข้าสู่ระบบเพื่อขอ token
    ดึงข้อมูล System Logs
    ตรวจสอบสถานะต้องเป็น    200
    ตรวจสอบว่ามีข้อมูล Logs กลับมา

ดึงข้อมูล System Logs ไม่ได้ถ้าไม่มี Token
    [Documentation]    ทดสอบกรณีความปลอดภัย (No Token)
    ดึงข้อมูล System Logs แบบไม่ใส่ Token
    ตรวจสอบสถานะต้องเป็น    401

Admin สามารถ Export Logs เป็นไฟล์ CSV ได้
    [Documentation]    ทดสอบ API Export
    Admin เข้าสู่ระบบเพื่อขอ Token
    สั่ง Export System Logs
    ตรวจสอบสถานะต้องเป็น    200
    ตรวจสอบว่าเป็นไฟล์ CSV