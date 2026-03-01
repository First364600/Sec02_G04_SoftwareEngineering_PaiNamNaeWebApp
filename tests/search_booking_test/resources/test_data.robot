*** Settings ***
Documentation    Test Data สำหรับ UAT ระบบจองเส้นทาง — ไปนำแหน่
...              ใช้ประกอบกับ search_booking_uat.robot

*** Variables ***

# ===================== URLs ========================
${BASE_URL}                 http://localhost:3001
${SEARCH_URL}               ${BASE_URL}/findTrip

# ===================== Browser =====================
${BROWSER}                  chrome

# ===================== User Accounts ===============
${PASSENGER_EMAIL}          oonchira44
${PASSENGER_PASSWORD}       888Frist19
${DRIVER_EMAIL}             oonchira22
${DRIVER_PASSWORD}          888Frist19

# ===================== Route Info ==================
# เส้นทางที่คนขับสร้างไว้ใน DB (ชุมแพ, ขอนแก่น)
# Checkpoint ของคนขับ:
#   [0] origin : โรงเรียนชุมแพ          (16.5439, 102.0990)
#   [1] stop1  : โตโยต้า สาขาชุมแพ      (16.5425, 102.1030)  ห่าง origin ~400ม.
#   [2] stop2  : หมูกระทะริมคลอง ชุมแพ  (16.5380, 102.1060)  ห่าง stop1 ~550ม.
#   [3] dest   : ศูนย์วิจัยข้าวชุมแพ    (16.5310, 102.1110)
${ROUTE_ORIGIN}             โรงเรียนชุมแพ
${ROUTE_DEST}               ศูนย์วิจัยข้าวชุมแพ
${ROUTE_DATE}               2026-03-15

# ===================== Case 1: Happy Path ==========
# จุดขึ้น: ใกล้ stop1 (<500ม.) / จุดลง: ใกล้ stop2 (<500ม.)
${C1_PICKUP}                โตโยต้า สาขาชุมแพ
${C1_DROPOFF}               หมูกระทะริมคลอง ชุมแพ
${C1_SEATS}                 1
${C1_EXPECTED_RESULT}       ส่งคำขอจองสำเร็จ

# ===================== Case 2: Radius ==============
# จุดที่ห่างจาก checkpoint ทุกจุดเกิน 500ม.
${C2_FAR_PICKUP}            บึงแก่นนคร ขอนแก่น
${C2_FAR_DROPOFF}           ห้างสรรพสินค้าเซ็นทรัล ขอนแก่น
${C2_EXPECTED_MODAL_TITLE}  ตำแหน่งไม่อยู่ในเส้นทาง
${C2_EXPECTED_MODAL_MSG}    กรุณาเลือกจุดรับ-ส่งที่อยู่ห่างจากจุดจอดของคนขับไม่เกิน 500 เมตรค่ะ

# ===================== Case 3: Sequence ============
# ขึ้น = stop2 (index 2), ลง = stop1 (index 1) ผิดลำดับ
${C3_PICKUP_LATER_STOP}     หมูกระทะริมคลอง ชุมแพ
${C3_DROPOFF_EARLIER_STOP}  โตโยต้า สาขาชุมแพ
${C3_EXPECTED_MODAL_TITLE}  จุดลงรถไม่ถูกต้อง
${C3_EXPECTED_MODAL_MSG}    จุดลงรถต้องอยู่ถัดจากจุดขึ้นรถในเส้นทาง

# ===================== Case 4: Checkpoint Exact ====
# ขึ้น = stop1 (checkpoint พอดี), ลง = ใกล้ stop2 (<500ม.)
${C4_PICKUP}                โตโยต้า สาขาชุมแพ
${C4_DROPOFF}               ร้านอาหารริมน้ำชุมแพ
${C4_EXPECTED_RESULT}       ส่งคำขอจองสำเร็จ

# ===================== Case 5: Auth ================
${C5_EXPECTED_URL}          /login

# ===================== Case 6: Empty Fields ========
${C6_EXPECTED_WARNING}      ข้อมูลไม่ครบถ้วน

# ===================== Case 7: No Filter ===========
${C7_EXPECTED_HEADER}       ผลการค้นหา

# ===================== Case 8: No Result ===========
${C8_NO_RESULT_DATE}        2099-01-01
${C8_EXPECTED_MSG}          ไม่พบเส้นทางที่ค้นหา
