# Sync Flow — Shot List (Firebase + Supabase)

Mục tiêu: Bộ ảnh minh họa đầy đủ cho quy trình đồng bộ thông báo (Subscribe → Publish → Distribute → Display) của dự án Note Calendar.

## 1) Subscribe — Đăng ký Token & Topic
- [ ] App đăng nhập thành công (màn hình login/splash sau khi Auth): tham chiếu khởi tạo tại [lib/main.dart](../lib/main.dart).
- [ ] Firestore → Authentication → Users: danh sách user (che mờ email/UID).
- [ ] Firestore → Collections: mở `users/{uid}` có trường `fcmToken` (che mờ token).
- [ ] VS Code Debug Console: log lấy token và subscribe topic từ `onTokenRefresh`/init tại [lib/data/services/fcm_service.dart](../lib/data/services/fcm_service.dart).
- [ ] (Tuỳ chọn) Ảnh code ở [lib/data/services/fcm_service.dart](../lib/data/services/fcm_service.dart) phần lưu token/subscription (chụp khung, không lộ khóa).

## 2) Publish — Tạo lịch hẹn & gọi Edge Function
- [ ] Màn hình tạo/sửa Booking: form có ngày/giờ, nội dung nhắc, bật nhắc (UI flow).
- [ ] Log app khi tạo booking: controller/repository phát sự kiện (tham chiếu [lib/data/repositories/booking_repository.dart](../lib/data/repositories/booking_repository.dart)).
- [ ] Supabase Dashboard → Functions: danh sách `send-notification` & `check-upcoming-bookings`.
- [ ] Mã nguồn `send-notification`: ảnh đoạn gọi FCM v1 trong [supabase/functions/send-notification/index.ts](../supabase/functions/send-notification/index.ts).
- [ ] Supabase → Settings → Secrets: có `FIREBASE_SERVICE_ACCOUNT` (che mờ toàn bộ giá trị).

## 3) Distribute — Đẩy tin qua FCM Topic
- [ ] Supabase Functions → Logs: bản ghi gửi thành công (HTTP 200/OK hoặc message id).
- [ ] (Tuỳ chọn) Terminal: lệnh xem logs `npx supabase functions logs send-notification` chạy và hiển thị OK.
- [ ] (Tuỳ chọn) Firebase Console → Cloud Messaging: ảnh màn “Send a test message” thành công (nếu test qua console).

## 4) Display — Hiển thị trên thiết bị
- [ ] Android/iOS: ảnh thông báo đẩy xuất hiện (foreground/background).
- [ ] VS Code Debug Console: handler `onMessage`/tap trong [lib/data/services/fcm_service.dart](../lib/data/services/fcm_service.dart) in ra payload.
- [ ] App điều hướng sau khi bấm thông báo: ảnh màn hình/route liên quan (đối chiếu [lib/routes/app_pages.dart](../lib/routes/app_pages.dart)).
- [ ] (Tuỳ chọn) Kênh thông báo Android: App Info → Notifications (channel đã tạo).

## 5) Nhắc cục bộ — Lịch hẹn tại thiết bị
- [ ] Ảnh thông báo local hiển thị đúng giờ.
- [ ] Log lên lịch nhắc từ `scheduleBookingReminder` ở [lib/data/services/notification_service.dart](../lib/data/services/notification_service.dart).

## 6) Kiến trúc & Quy trình
- [ ] Sơ đồ kiến trúc: App → Firestore (lưu `fcmToken`) → Supabase Edge Function → FCM → Thiết bị → App route.
- [ ] Ảnh/tài liệu mô tả topic (ví dụ `shop_{uid}_notifications`) và vị trí subscribe tại [lib/data/services/fcm_service.dart](../lib/data/services/fcm_service.dart).

## 7) Bảo mật & Cấu hình
- [ ] Firebase Options: ảnh [lib/firebase_options.dart](../lib/firebase_options.dart) (chỉ cấu trúc, không full nội dung nhạy cảm).
- [ ] Supabase Config: ảnh [lib/core/config/supabase_config.dart](../lib/core/config/supabase_config.dart) (che URL/Key nếu cần).
- [ ] Che mờ: email thật, UID, token, secrets, service account key.

---

## Hướng dẫn nhanh xem log
- VS Code Debug Console (khi `flutter run`): xem `print`/logger từ app.
- Android Logcat: lọc theo "flutter", "FirebaseMessaging" hoặc tag riêng.
- Supabase Functions:
  ```bash
  npx supabase functions logs send-notification
  ```
- Firebase Functions (nếu dùng):
  ```bash
  firebase functions:log
  ```

## Gợi ý tag log (dễ lọc)
Thêm tag thống nhất khi lên lịch/gửi/nhận:
- Trong `NotificationService`: `print('[NC-Notify] Scheduled reminder: bookingId=... at ...')` ở [lib/data/services/notification_service.dart](../lib/data/services/notification_service.dart).
- Trong `FcmService`: `print('[NC-Notify] FCM received: ...')` ở [lib/data/services/fcm_service.dart](../lib/data/services/fcm_service.dart).

Ghi chú: Giữ ảnh nhất quán (cùng theme, độ phân giải), và luôn che mờ thông tin nhạy cảm.
