User manual-Change Log version 1.0
คู่มือใช้งาน “ไปนําแหน่” เว็บแอปพลิเคชันการเดินทางร่วมกันอย่างปลอดภัย “Pai Nam Nae” A Safe Ride Sharing: Web Application (เพิ่มเติม)
ผู้จัดทำ
1. นายวัชรวิศว์ ชัยปลื้ม รหัสนักศึกษา 663380023-1 Username: First364600
2. นายกันต์ธีร์ แข้คำ รหัสนักศึกษา 663380198-6 Username: Kantee Khaekham
3. นายจิติศักดิ์ มงคลเคหา รหัสนักศึกษา 663380204-7 Username: Chitisak Mongkhonkheha
4. นางสาวปิยะธิดา วิจิตรจันทร์ รหัสนักศึกษา 663380508-7 Username: PiyatidaWijitjan
5. นายวัฒนชัย บึงจันทร์ รหัสนักศึกษา 663380232-2 Username: watthanachai
6. นางสาวอรจิรา แสนตา รหัสนักศึกษา 663380244-5 Username: Oonchira Saenta

Product Backlog Items No.1 
As an admin, I want a log that complies to the related law.
ฟังก์ชันการดูและดาวน์โหลด Log การใช้งาน สำหรับแอดมิน
1.แอดมินเข้าสู่ระบบการใช้งาน ไปยังเมนู Dashboard
<img width="1883" height="1048" alt="image" src="https://github.com/user-attachments/assets/47c6c216-5364-4cf3-912f-51b1fc4e7c62" />

2.หน้าDashboard แสดงรายละเอียดและข้อมูลของผู้ใช้งาน ในเมนูการกระทำ คลิกเลือก"ไอคอนหน้ากระดาษ"ไปยังหน้า Log การกระทำของผู้ใช้งานที่ได้เลือก
<img width="2048" height="1158" alt="image" src="https://github.com/user-attachments/assets/cd7619dc-3d5a-4dc1-8a14-2680a8d6b73e" />

3.หน้า Log ผู้ใช้งาน แสดงLogการทำงานทั้งหมดของ ผู้ใช้งานคนนั้น ประกอบไปด้วย Username, UserID, Event, IP Address เป็นต้น และมีปุ่ม Export ให้ แอดมินสามารถดาวน์โหลด Log การทำงานของผู้ใช้งานคนนั้น เพื่อนำไปใช้ในทางกฎหมายได้ 
<img width="2048" height="1158" alt="image" src="https://github.com/user-attachments/assets/836e6740-df6c-4be1-ab0b-21e4792831b4" />





Product Backlog Items No.9 
As a driver, I want suggested routes based on the pickup points and drop-off locations as indicated by all of the passengers.
ฟังก์ชันการเริ่มต้นการเดินทางและการเเนะนำเส้นทางสำหรับคนขับ
1.คนขับเข้าสู่ระบบการใช้งาน ไปยังเมนูคำขอจองเส้นทางของฉัน
<img width="1899" height="1039" alt="image" src="https://github.com/user-attachments/assets/ac878b8b-6a36-4e55-a833-d4b591485465" />

2.หน้าคำขอจองเส้นทางของฉัน เลือกเส้นทางของฉัน
<img width="1888" height="1037" alt="image" src="https://github.com/user-attachments/assets/e3281e2d-aba0-45d3-ae92-b01fbb968e13" />

3.หน้าเส้นทางของฉันแสดงรายละเอียดเส้นทางการเดินทางทั้งหมด ที่คนขับได้สร้างไว้
<img width="1892" height="1032" alt="image" src="https://github.com/user-attachments/assets/33947643-3849-4207-8e41-eca0fddb77c9" />

4.คนขับสามารถเลือกเส้นทางการเดินทางเพื่อเริ่มต้นการเดินทาง เมื่อคลิก "เริ่มต้นการเดินทาง" จะมีปุ่ม "CheckPoint"ปรากฎขึ้น
<img width="1846" height="1033" alt="image" src="https://github.com/user-attachments/assets/4d64629d-3bd5-4655-8de1-00950122ae84" />

5.เมื่อคลิกปุ่ม "CheckPoint" คนขับจะต้องเปิด GPS เพื่อยืนยันการเริ่มต้นการเดินทาง 
<img width="1846" height="1033" alt="image" src="https://github.com/user-attachments/assets/ce1d7743-2496-41b8-86c7-ef29b73d8f3a" />

6.เมื่อเริ่มต้นการเดินทางแล้วคนขับจะต้องไปยังจุดหมายถัดไป แผนที่จะเปลี่ยนจากการแสดงผลเส้นทางจากจุดเริ่มต้นไปยังจุดสิ้นสุด มาเป็นเส้นทางจากจุดเริ่มต้นไปยังจุดแวะพักถัดไป โดยจะเเสดงเส้นทางให้คนขับเลือกว่าจะไปทางใดได้บ้างถึงจุดหมายนั้น หากอยู่ห่างจากจุดหมายนั้น มากกว่า 500 เมตรจะไม่สามารถยืนยันได้
<img width="1884" height="1030" alt="image" src="https://github.com/user-attachments/assets/13a1d472-03ea-4105-8a7d-fdcf39ce81f4" />

7.เมื่อถึงจุดสิ้นสุดการเดินทาง การเดินทางนั้นจะไม่สามารถแก้ไขและเริ่มต้นการเดินทางได้อีกต่อไป
<img width="1859" height="1027" alt="image" src="https://github.com/user-attachments/assets/adff0241-2581-4164-8347-5655d4a4740d" />











Product Backlog Items No.16 
As a user, I want my account and information to be removed from the system when I am no longer want to be apart of this community.
ระบบลบบัญชีผู้ใช้ (Account Deletion) 
1.ผู้ใช้เข้าสู่ระบบ 
<img width="1919" height="1039" alt="image" src="https://github.com/user-attachments/assets/c7fa0b70-83be-4cc7-a36b-ee585ba53c69" />

2.ไปยังเมนูบัญชีของฉัน
<img width="1882" height="1041" alt="image" src="https://github.com/user-attachments/assets/972a8d3a-ccd4-4cb0-bf09-b6f0f2dccc14" />

3.หน้าบัญชีของฉันมีรายละเอียดและเมนูต่างๆ คลิก "ลบบัญชีผู้ใช้" เพื่อเข้าสู่หน้าลบบัญชีผู้ใช้งาน
<img width="1855" height="1030" alt="image" src="https://github.com/user-attachments/assets/95b030ed-aacd-4d2a-8506-513be1884e4b" />

4.หน้าลบบัญชีผู้ใช้ แสดงรายละเอียดคำเตือนถ้าหากยืนยันการลบบัญชีผู้ใช้ จะไม่สามารถเข้าใช้งานบัญชีนี้ได้อีก ผู้ใช้สามารถเลือกได้ว่าจะรับชุดข้อมูลประวัติการใช้งานของตนเอง หรือไม่รับก็ได้ และถ้าต้องการลบ ต้องพิมพ์ "ยืนยัน" เพื่อยืนยันการลบบัญชี และมีปุ่ม "ยืนยันการลบข้อมูล"
<img width="1889" height="1049" alt="image" src="https://github.com/user-attachments/assets/94740ceb-db18-4264-a2d3-b742994ddd73" />

5.การลบข้อมูลเสร็จสิ้น หากผู้ใช้งานเลือกรับชุดข้อมูลจะมีชุดข้อมูล(CSV) ให้ดาวน์โหลด

6.การลบข้อมูลผู้ใช้เสร็๗สิ้น หากผู้ใช้งานเลือกไม่รับชุดข้อมูล จะไม่มีชุดข้อมูลให้ดาวน์โหลด









