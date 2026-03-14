User manual-Change Log version 1.1
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
<img width="1916" height="1040" alt="image" src="https://github.com/user-attachments/assets/7189356f-3d34-40f6-9154-52ca45b399c7" />

3.หน้า Log ผู้ใช้งาน แสดงLogการทำงานทั้งหมดของ ผู้ใช้งานคนนั้น ประกอบไปด้วย Username, UserID, Event, IP Address เป็นต้น และมีปุ่ม Export ให้ แอดมินสามารถดาวน์โหลด Log การทำงานของผู้ใช้งานคนนั้น เพื่อนำไปใช้ในทางกฎหมายได้ 
<img width="1897" height="1034" alt="image" src="https://github.com/user-attachments/assets/9226758b-e869-42d1-a054-5c35b69dd02a" />

4.การ export สามารถเลือกข้อมูลได้ว่าจะเอาอะไรบ้าง และประเภท log อะไร
<img width="1903" height="1039" alt="image" src="https://github.com/user-attachments/assets/a6a9cc62-0e8e-43e5-abb9-348c604f69b5" />
<img width="1903" height="1039" alt="image" src="https://github.com/user-attachments/assets/a6a9cc62-0e8e-43e5-abb9-348c604f69b5" />








Product Backlog Items No.9 
As a driver, I want suggested routes based on the pickup points and drop-off locations as indicated by all of the passengers.
ฟังก์ชันการเริ่มต้นการเดินทางและการเเนะนำเส้นทางสำหรับคนขับ
1.คนขับเข้าสู่ระบบการใช้งาน ไปยังเมนูคำขอจองเส้นทางของฉัน
<img width="1899" height="1039" alt="image" src="https://github.com/user-attachments/assets/ac878b8b-6a36-4e55-a833-d4b591485465" />

2.หน้าคำขอจองเส้นทางของฉัน เลือกเส้นทางของฉัน
<img width="1888" height="1037" alt="image" src="https://github.com/user-attachments/assets/e3281e2d-aba0-45d3-ae92-b01fbb968e13" />

3.หน้าเส้นทางของฉันแสดงรายละเอียดเส้นทางการเดินทางทั้งหมด ที่คนขับได้สร้างไว้และมีรายละเอียดของลูกค้าจุดขึ้นลงที่ลูกค้าต้องการ
<img width="1895" height="1098" alt="image" src="https://github.com/user-attachments/assets/954a73d6-b672-4cdd-b4ad-b9dab62338e0" />


4.คนขับสามารถเลือกเส้นทางการเดินทางเพื่อเริ่มต้นการเดินทาง เมื่อคลิก "เริ่มต้นการเดินทาง" จะมีปุ่ม "CheckPoint"ปรากฎขึ้น รวมทั้งปรากฎปุ่ม รับผู้โดยสาร และยกเลิกการเดินทาง
<img width="1903" height="1029" alt="image" src="https://github.com/user-attachments/assets/05e6730e-3f2c-4e57-b3fd-77532c7aff4b" />


5.เมื่อคลิกปุ่ม "CheckPoint" คนขับจะต้องเปิด GPS เพื่อยืนยันการเริ่มต้นการเดินทาง 
<img width="1895" height="1030" alt="image" src="https://github.com/user-attachments/assets/d4896071-0ce7-4f2d-bae5-2270f44f836c" />


6.เมื่อเริ่มต้นการเดินทางแล้วคนขับจะต้องไปยังจุดหมายถัดไป แผนที่จะเปลี่ยนจากการแสดงผลเส้นทางจากจุดเริ่มต้นไปยังจุดสิ้นสุด มาเป็นเส้นทางจากจุดเริ่มต้นไปยังจุดแวะพักถัดไป โดยจะเเสดงเส้นทางให้คนขับเลือกว่าจะไปทางใดได้บ้างถึงจุดหมายนั้น หากอยู่ห่างจากจุดหมายนั้น มากกว่า 500 เมตรจะไม่สามารถยืนยันได้
<img width="1895" height="1030" alt="image" src="https://github.com/user-attachments/assets/b8e3fabf-ca08-42bb-8b1f-68e41a875704" />

7.เมื่อถึงจุดcheckpoint ที่มีผู้โดยสารขึ้นรถ จะไม่สามารถกดcheckpointได้เลย จะต้องรับผู้โดยสารก่อน 
<img width="1900" height="1033" alt="image" src="https://github.com/user-attachments/assets/a2e0ef56-55eb-455c-986c-ade51b523074" />

<img width="1893" height="1032" alt="image" src="https://github.com/user-attachments/assets/e9d9c4c0-1a08-455a-b6db-55279c60c2eb" />
 
 หากผู้โดยสารปฏิเสธจะไม่สามารถ checkpoint ได้จะต้องติดต่อผู้โดยสาร
<img width="1899" height="1032" alt="image" src="https://github.com/user-attachments/assets/7759ca17-c2d6-4452-851e-67958192576e" />

8.เมื่อถึงจุดสิ้นสุดการเดินทาง การเดินทางนั้นจะไม่สามารถแก้ไขและเริ่มต้นการเดินทางได้อีกต่อไป
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

4.หน้าลบบัญชีผู้ใช้ แสดงรายละเอียดคำเตือนถ้าหากยืนยันการลบบัญชีผู้ใช้ จะไม่สามารถเข้าใช้งานบัญชีนี้ได้อีก ผู้ใช้สามารถเลือกได้ว่าจะรับชุดข้อมูลประวัติการใช้งานของตนเอง  และถ้าต้องการลบ ต้องพิมพ์ "ยืนยัน" เพื่อยืนยันการลบบัญชี และมีปุ่ม "ยืนยันการลบข้อมูล"
<img width="1897" height="1034" alt="image" src="https://github.com/user-attachments/assets/e4803578-f936-4717-8547-be37fbdbbf7a" />
ไม่สามารถลบบัญชีได้เนื่องจากมีการเดินทางที่ยังไม่เสร็จสิ้น
<img width="1900" height="1034" alt="image" src="https://github.com/user-attachments/assets/c3fb1e4f-6d03-46e9-84df-11a0f1cccf5a" />

5.การลบข้อมูลเสร็จสิ้น หากผู้ใช้งานเลือกรับชุดข้อมูลจะมีชุดข้อมูลไปที่อีเมลของผู้ใช้
6.การลบข้อมูลผู้ใช้เสร็จสิ้น 

