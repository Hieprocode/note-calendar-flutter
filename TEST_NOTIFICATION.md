# 🧪 Hướng dẫn Test Notification Đồng Bộ

## ✅ Đã sửa các lỗi:

1. ✅ **FCMService**: Dùng `uid` làm `shopId` (không lấy từ Firestore user doc)
2. ✅ **NotificationController**: Dùng `uid` làm `shopId`
3. ✅ **InitialBinding**: Xóa duplicate init FCMService (đã init trong main.dart)
4. ✅ **BookingRepository**: Tự động gửi notification khi tạo/hủy booking

---

## 🚀 Test trên 2 thiết bị:

### **Bước 1: Build & Install app**
```bash
# Clean project
flutter clean
flutter pub get

# Build & run trên Device A
flutter run

# Build & run trên Device B (mở terminal mới)
flutter run
```

### **Bước 2: Đăng nhập cùng số điện thoại**
- **Device A**: Đăng nhập với số `+84xxxxxxxxx`
- **Device B**: Đăng nhập với số `+84xxxxxxxxx` (cùng số)

### **Bước 3: Kiểm tra FCM đã init**
Xem console logs:
```
--> FCM: Đã cấp quyền thông báo
--> FCM TOKEN: ey...
--> Đã lưu Token vào users collection
--> Đã subscribe topic: shop_ABC123_notifications
```

### **Bước 4: Test tạo booking**
- **Device A**: Tạo booking mới
- **Kết quả mong đợi:**
  - Device A: Console log `"--> Notification gửi thành công"`
  - Device B: 
    - Nhận FCM Push Notification (nếu app background)
    - Thấy notification trong tab "Hoạt Động Gần Đây"
    - Console log `"--> NotificationController: Nhận được X thông báo"`

### **Bước 5: Kiểm tra Firestore**
Mở Firebase Console → Firestore:

1. **Collection `notifications`**:
```json
{
  "shop_id": "ABC123",
  "title": "📅 Có khách mới đặt lịch!",
  "body": "Nguyễn Văn A - Cắt tóc",
  "type": "new_booking",
  "is_read": false,
  "created_at": "2025-12-11T10:30:00Z"
}
```

2. **Collection `users`**:
```json
{
  "fcm_token": "ey...",
  "email": "+84xxxxxxxxx",
  "updated_at": "2025-12-11T10:29:00Z"
}
```

---

## 🐛 Nếu không nhận được notification:

### **1. Kiểm tra permission**
- Android: Settings → Apps → YourApp → Notifications (Allow)
- iOS: Settings → YourApp → Notifications (Allow)

### **2. Kiểm tra console logs**
```bash
# Device A
--> Booking tạo thành công + gửi notification
--> Notification gửi thành công

# Device B
--> NotificationController: Nhận được 1 thông báo
--> FCM Foreground: 📅 Có khách mới đặt lịch!
```

### **3. Kiểm tra Firestore Rules**
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

### **4. Kiểm tra FCM Token có lưu không**
Firebase Console → Firestore → `users/{uid}` → Phải có field `fcm_token`

### **5. Kiểm tra Topic subscription**
Console log phải có: `"--> Đã subscribe topic: shop_XXX_notifications"`

---

## 📊 Luồng hoạt động:

```
Device A: Tạo Booking
    ↓
BookingRepository.createBooking()
    ├─ Lưu booking vào Firestore
    └─ _sendNotificationToShop()
        ↓
        Lưu notification → Firestore collection "notifications"
        {shop_id: "ABC123", ...}
    ↓
NotificationController (Device B)
    ↓
Lắng nghe Firestore Stream
.where('shop_id', isEqualTo: uid)
.snapshots()
    ↓
Phát hiện notification mới
    ↓
notifications.assignAll([...])
    ↓
UI Update + Hiển thị notification
```

---

## ✅ Checklist hoàn chỉnh:

- [x] FCMService khởi tạo trong main.dart
- [x] NotificationService khởi tạo trong main.dart
- [x] FCMService.init() subscribe topic "shop_{uid}_notifications"
- [x] NotificationController lắng nghe Firestore theo uid
- [x] BookingRepository gửi notification khi tạo/hủy booking
- [x] NotificationRepository stream notifications theo shop_id
- [x] Firebase permissions đã cấp
- [x] Firestore rules cho phép read/write

---

## 🎯 Kết quả:

**Khi Device A tạo booking, Device B sẽ thấy notification trong vòng 1-2 giây!**

---

## 💡 Tips:

- Nếu app ở background, notification sẽ hiện ở notification tray
- Nếu app foreground, notification hiện trong app (Local Notification)
- Tap vào notification sẽ mở app và chuyển đến tab Notifications
- Số notification chưa đọc hiển thị ở badge (nếu có implement)

---

**Good luck! 🚀**
