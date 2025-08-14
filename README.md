# Dog Breed Flutter App

แอปนี้เป็นแอป Flutter สำหรับแสดงข้อมูลสายพันธุ์สุนัขต่าง ๆ พร้อมภาพประกอบ ฟีเจอร์ค้นหา และระบบจัดการ Favorites

---

## ฟีเจอร์หลัก

- ดึงข้อมูลภาพสุนัขแบบสุ่มจาก [Dog CEO API](https://dog.ceo/dog-api/)
- แสดงสายพันธุ์สุนัข พร้อม:
  - ลักษณะนิสัย (Temperament)
  - ลักษณะขน (Coat)
  - การดูแล (Care)
- ระบบค้นหาสายพันธุ์และฟิลเตอร์ตามนิสัย ขน หรือการดูแล
- ระบบ Favorites บันทึกสายพันธุ์ที่ชอบด้วย `SharedPreferences`
- Dark Mode
- หน้ารายละเอียดสุนัขพร้อม Gallery และ Smooth Page Indicator

---

## ตัวอย่างหน้าจอ

| หน้าหลัก | รายละเอียดสายพันธุ์ |
|-----------|------------------|
| ![Home](assets/screenshots/home.png) | ![Detail](assets/screenshots/detail.png) |

---

## การติดตั้ง

1. **Clone โปรเจกต์**

```bash
git clone https://github.com/username/dog-breed-flutter.git
cd dog-breed-flutter
ติดตั้ง Dependencies

bash
Copy code
flutter pub get
รันแอป

bash
Copy code
flutter run
โครงสร้างโฟลเดอร์
bash
Copy code
lib/
├─ main.dart          # เริ่มต้นแอป
├─ dog_service.dart   # ดึงข้อมูลสุนัขจาก API
├─ models/
│  └─ dog.dart        # Model ของสุนัข
├─ screens/
│  ├─ dog_screen.dart      # หน้าหลัก
│  └─ dog_detail_screen.dart # หน้ารายละเอียด
└─ widgets/
   └─ dog_card.dart    # Card แสดงสุนัข
Dependencies หลัก
http – ดึงข้อมูลจาก API

shared_preferences – จัดการ Favorites

smooth_page_indicator – แสดง indicator ใน gallery

shimmer – แสดง loading effect

การใช้งาน
เปิดแอป จะเห็นรายการสายพันธุ์สุนัขแบบสุ่ม

ใช้แถบค้นหาเพื่อค้นหาสายพันธุ์หรือฟิลเตอร์ตามนิสัย ขน หรือการดูแล

กดปุ่มหัวใจเพื่อเพิ่มสายพันธุ์เข้าสู่ Favorites

กดแต่ละ Card เพื่อดูรายละเอียดพร้อม Gallery ของภาพสุนัข

ข้อมูลเพิ่มเติม
Dark/Light Mode เปลี่ยนได้จาก Icon บน AppBar

รองรับการ Refresh ข้อมูลโดยการลากลงบนหน้า List

รองรับกรณีโหลดภาพไม่สำเร็จ ด้วย Shimmer Loading

License
MIT License

yaml
Copy code

---

ถ้าต้องการ ผมสามารถทำ **เวอร์ชัน README พร้อมรูปภาพตัวอย่างจริงจากแอปและ GIF loading** ให้ดูสวยขึ้นและอ่านง่ายสำหรับ GitHub ด้วยครับ  

คุณอยากให้ผมทำแบบนั้นไหม?
