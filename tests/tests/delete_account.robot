*** Settings ***
Resource    resources/common_keywords.robot
Suite Setup    เปิดเว็บ
Suite Teardown    ปิดเว็บ

*** Test Cases ***
ผู้ใช้ลบบัญชีได้หลัง Login
    ไปหน้า Login
    กรอกข้อมูล Login
    กดปุ่ม Login
    ต้องอยู่หน้า Home
    ไปหน้าโปรไฟล์ผู้ใช้
    กดปุ่มลบบัญชีจากหน้าโปรไฟล์
    ต้องอยู่หน้าลบบัญชี
    กรอกข้อมูลยืนยันการลบ
    ยืนยันลบบัญชี
    ต้องเห็น popup ลบสำเร็จ