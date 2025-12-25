# 🔔 Hướng Dẫn Sử Dụng Thông Báo Firebase (FCM)

## 📱 Tính Năng Đã Hoàn Thành

### ✅ Khi App Đang Mở (Foreground)
- Thông báo hiển thị tự động ở system tray
- Lưu vào Firestore để có lịch sử
- Tap vào thông báo → Navigate đến chi tiết booking

### ✅ Khi App Đang Ở Background
- FCM tự động hiển thị thông báo
- User tap vào → App mở lên và navigate đến chi tiết booking
- Handler: `FirebaseMessaging.onMessageOpenedApp`

### ✅ Khi App Đã Tắt Hoàn Toàn
- FCM vẫn nhận được thông báo
- User tap vào → Mở app và navigate đến chi tiết booking
- Handler: `FirebaseMessaging.getInitialMessage()`

---

## 🛠️ Cách Hoạt Động

### 1. **main.dart** - Khởi Tạo
```dart
// Kiểm tra xem app có được mở từ notification không
RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();

// Truyền initialMessage vào MyApp
runApp(MyApp(initialMessage: initialMessage));
```

### 2. **MyApp** - Xử Lý Initial Message
```dart
class MyApp extends StatelessWidget {
  final RemoteMessage? initialMessage;
  
  // Sau khi build xong, kiểm tra và navigate
  if (initialMessage != null) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleInitialMessage(initialMessage!);
    });
  }
}
```

### 3. **FCMService** - Xử Lý Background Tap
```dart
void _setupMessageOpenedAppHandler() {
  // Khi app đang background và user tap notification
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    _handleNotificationTap(message);
  });
}
```

### 4. **Navigation Logic**
```dart
void _handleNotificationTap(RemoteMessage message) {
  String? bookingId = message.data['related_booking_id'];
  
  if (bookingId != null && bookingId.isNotEmpty) {
    // Navigate đến chi tiết booking
    Get.toNamed(AppRoutes.BOOKING_DETAIL, arguments: bookingId);
  } else {
    // Mở màn hình danh sách notifications
    Get.toNamed(AppRoutes.NOTIFICATIONS);
  }
}
```

---

## 📊 Cấu Trúc File

```
lib/
├── main.dart                           # Khởi tạo FCM & xử lý initial message
├── data/
│   └── services/
│       └── fcm_service.dart           # Xử lý FCM (foreground, background)
├── modules/
│   └── booking/
│       └── view/
│           ├── booking_detail_page.dart   # Trang chi tiết (navigate được)
│           └── booking_detail_view.dart   # UI chi tiết (bottom sheet)
└── routes/
    ├── app_routes.dart                # Định nghĩa routes
    └── app_pages.dart                 # Mapping routes → pages
```

---

## 🔑 Cấu Trúc Notification Data

### Từ Server Gửi
```json
{
  "notification": {
    "title": "Lịch hẹn mới",
    "body": "Khách hàng Nguyễn Văn A đã đặt lịch"
  },
  "data": {
    "type": "new_booking",
    "related_booking_id": "abc123xyz"
  }
}
```

### Trong Code Xử Lý
```dart
String? type = message.data['type'];                    // 'new_booking'
String? bookingId = message.data['related_booking_id']; // 'abc123xyz'
```

---

## 🎯 Luồng Xử Lý Chi Tiết

### Kịch Bản 1: App Đang Mở
1. Server gửi FCM → `FirebaseMessaging.onMessage`
2. `_setupForegroundMessageHandler()` nhận message
3. FCM tự động hiển thị notification ở system tray
4. `_saveNotificationToFirestore()` lưu vào Firestore
5. User tap notification → `onMessageOpenedApp` → navigate

### Kịch Bản 2: App Đang Background
1. Server gửi FCM → System nhận và hiển thị notification
2. User tap notification → Mở app
3. `FirebaseMessaging.onMessageOpenedApp` trigger
4. `_handleNotificationTap()` → Navigate đến booking detail

### Kịch Bản 3: App Đã Tắt
1. Server gửi FCM → System nhận và hiển thị notification
2. User tap notification → Mở app
3. `main()` gọi `getInitialMessage()` → Có message
4. Truyền message vào `MyApp`
5. `addPostFrameCallback` → `_handleInitialMessage()`
6. Đợi 2 giây cho splash screen
7. Navigate đến booking detail

---

## 🚀 Test Notification

### Gửi Test Từ Firebase Console
1. Vào Firebase Console → Cloud Messaging
2. Send your first message
3. **Notification:**
   - Title: "Lịch hẹn mới"
   - Body: "Khách hàng đã đặt lịch"
4. **Additional options → Custom data:**
   - Key: `type`, Value: `new_booking`
   - Key: `related_booking_id`, Value: `[your-booking-id]`
5. Select app và gửi

### Từ Backend (Node.js/Python)
```javascript
// Node.js Example
const message = {
  notification: {
    title: 'Lịch hẹn mới',
    body: 'Khách hàng Nguyễn Văn A đã đặt lịch'
  },
  data: {
    type: 'new_booking',
    related_booking_id: 'abc123xyz'
  },
  topic: 'shop_USER_ID_notifications'
};

await admin.messaging().send(message);
```

---

## ⚠️ Lưu Ý Quan Trọng

### 1. **Không Gọi Local Notification Thủ Công**
```dart
// ❌ SAI - Gây trùng lặp
_localNoti.showNotification(...);

// ✅ ĐÚNG - FCM tự động hiển thị
_saveNotificationToFirestore(message);
```

### 2. **Related Booking ID Phải Tồn Tại**
- Nếu `related_booking_id` không có trong database
- BookingDetailPage sẽ hiển thị error screen
- User có thể tap "Quay lại" để về trang trước

### 3. **Timing Cho Initial Message**
```dart
// Đợi 2 giây cho splash screen load xong
Future.delayed(const Duration(seconds: 2), () {
  Get.toNamed(AppRoutes.BOOKING_DETAIL, arguments: bookingId);
});
```

---

## 🎨 UI Flow

```
[Notification Tap]
        ↓
  [Có bookingId?]
     ↙       ↘
   Có         Không
    ↓           ↓
[Fetch      [Navigate to
 Booking]    Notifications]
    ↓
[Hiển thị
 Detail]
```

---

## ✨ Tính Năng Đặc Biệt

1. **Auto Reload**: Khi vào booking detail, nếu booking có thay đổi trong Firestore, UI tự động cập nhật
2. **Error Handling**: Nếu không tìm thấy booking, hiển thị error screen thay vì crash
3. **Loading State**: Hiển thị loading khi đang fetch booking
4. **Gradient Background**: UI đẹp với gradient background giống các màn hình khác

---

## 📝 Checklist Khi Deploy

- [ ] Firebase Cloud Messaging đã bật
- [ ] google-services.json đã config đúng
- [ ] Permissions notification đã có trong AndroidManifest.xml
- [ ] Test notification với app đang mở
- [ ] Test notification với app background
- [ ] Test notification với app đã tắt
- [ ] Test với bookingId không tồn tại
- [ ] Test với notification không có bookingId

---

**🎉 Hoàn Thành! Notification giờ hoạt động hoàn hảo trong mọi trường hợp!**
