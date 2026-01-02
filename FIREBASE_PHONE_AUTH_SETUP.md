# Hướng dẫn cấu hình Firebase Phone Authentication

## Tổng quan thay đổi

Dự án đã được cập nhật để sử dụng **Firebase Phone Authentication** làm phương thức đăng nhập chính, thay vì Firebase Email/Password. Firebase Google Sign-in vẫn được giữ lại như một tùy chọn phụ.

## Tại sao chọn Firebase Phone Auth?

1. ✅ Đã tích hợp sẵn Firebase trong dự án
2. ✅ Không cần đăng ký third-party SMS provider (Twilio, MessageBird)
3. ✅ **Miễn phí**: 10,000 verifications/tháng
4. ✅ Hỗ trợ Việt Nam tốt
5. ✅ Auto-detect SMS trên Android
6. ✅ Cấu hình đơn giản hơn Supabase

## Những gì đã thay đổi

### 1. Files mới tạo
- `lib/data/services/supabase_auth_service.dart` → Đã đổi thành **Firebase Phone Auth Service**

### 2. Files đã cập nhật
- `lib/data/repositories/auth_repository.dart` - Sử dụng Firebase Phone Auth
- `lib/modules/auth/auth_controller.dart` - Logic phone login
- `lib/modules/auth/auth_view.dart` - UI ưu tiên phone input
- `lib/modules/verify_otp/verify_otp_controller.dart` - Hỗ trợ phone OTP
- `lib/modules/verify_otp/verify_otp_view.dart` - UI động
- `lib/core/base/initial_binding.dart` - Đăng ký FirebasePhoneAuthService

## Cấu hình Firebase Phone Authentication

### Bước 1: Bật Phone Authentication trong Firebase Console

1. Truy cập [Firebase Console](https://console.firebase.google.com/)
2. Chọn project của bạn
3. Vào **Authentication** → **Sign-in method**
4. Tìm **Phone** và click **Enable**
5. Click **Save**

**Xong!** Không cần cấu hình gì thêm cho development.

### Bước 2: Test trong Development

Firebase Phone Auth cho phép test miễn phí mà không cần SMS thật:

#### 2.1. Thêm số điện thoại test
1. Firebase Console → **Authentication** → **Sign-in method**
2. Scroll xuống **Phone numbers for testing**
3. Click **Add phone number**
4. Nhập:
   - **Phone number**: `+84987654321` (hoặc số bạn muốn)
   - **Verification code**: `123456` (mã OTP cố định)
5. **Add**

#### 2.2. Test trong app
```
Nhập: 0987654321
→ Nhận OTP: 123456 (không cần SMS thật)
→ Verify thành công!
```

### Bước 3: Production Setup (khi deploy app thật)

#### 3.1. Android (Google Play Services)
- Firebase tự động gửi SMS miễn phí qua Google Play Services
- **Không cần cấu hình gì thêm**

#### 3.2. iOS (APNs - Apple Push Notification Service)
1. Firebase Console → **Project Settings** → **Cloud Messaging**
2. Upload **APNs Authentication Key** (lấy từ Apple Developer)
3. Nhập **Team ID** và **Key ID**

#### 3.3. SHA-256 Certificate (Android)
Firebase cần SHA-256 để verify app:

**Windows:**
```bash
cd android
gradlew signingReport
```

**macOS/Linux:**
```bash
cd android
./gradlew signingReport
```

Copy **SHA-256** từ output và thêm vào Firebase Console → **Project Settings** → **Your apps** → Android app → **Add fingerprint**

## Giới hạn và chi phí Firebase Phone Auth

### Free Tier (Spark Plan)
- **10,000** phone verifications/tháng
- Đủ cho hầu hết app startup/SME

### Blaze Plan (Pay-as-you-go)
- **$0.06/verification** sau 10,000 đầu
- Ví dụ: 20,000 verifications = $0 (10k free) + $6 (10k × $0.06) = **$6/tháng**

### So sánh với các provider khác
| Provider | Free Tier | Paid |
|----------|-----------|------|
| **Firebase** | 10,000/tháng | $0.06/SMS |
| Twilio | $0 (trial $15) | $0.0079/SMS |
| MessageBird | €10 credit | €0.05/SMS |
| AWS SNS | 100 SMS free | $0.00645/SMS |

→ **Firebase là tốt nhất** cho app nhỏ/vừa!

## Sử dụng trong app

### Flow đăng nhập mới

1. **Người dùng nhập số điện thoại** → App gọi `signInWithPhone()`
2. **Firebase gửi OTP qua SMS** (hoặc auto-detect trên Android)
3. **Người dùng nhập OTP** → App gọi `verifyPhoneOTP()`
4. **Xác thực thành công** → User được đồng bộ vào Firestore
5. **Kiểm tra shop** → Chuyển đến Dashboard hoặc Setup Shop

### Code example

```dart
// Trong AuthController
Future<void> signInWithPhoneNumber() async {
  String phone = phoneController.text.trim(); // VD: 0987654321
  
  // Gửi OTP (Firebase tự động gửi SMS)
  String formattedPhone = await _authRepo.signInWithPhone(phone);
  // formattedPhone = +84987654321
  
  // Chuyển đến màn hình verify OTP
  Get.toNamed(AppRoutes.VERIFY_OTP, arguments: {
    'phoneNumber': formattedPhone,
    'isPhoneAuth': true,
  });
}

// Trong VerifyOtpController  
Future<void> verifyOTP() async {
  String otpCode = '123456'; // User input
  
  // Verify OTP
  bool hasShop = await _authRepo.verifyPhoneOTP(
    phoneNumber: phoneNumber,
    otpCode: otpCode,
  );
  
  // Navigate
  if (hasShop) {
    Get.offAllNamed(AppRoutes.DASHBOARD);
  } else {
    Get.offAllNamed(AppRoutes.SETUP_SHOP);
  }
}
```

## Định dạng số điện thoại

App tự động chuyển đổi số điện thoại Việt Nam:
- Input: `0987654321`
- Formatted: `+84987654321`

Regex validate: `^0[3|5|7|8|9][0-9]{8}$`

## Auto-detect SMS (Android)

Firebase Phone Auth có khả năng tự động đọc SMS OTP trên Android:
- Không cần user nhập OTP thủ công
- SMS được detect và verify tự động
- Cải thiện UX đáng kể

## Troubleshooting

### Lỗi: "Invalid phone number"
- Kiểm tra định dạng: phải có `+84` đầu
- Regex validation có chạy không
- Firebase Console có bật Phone Auth chưa

### Lỗi: "Missing verification ID"
- `sendOTP()` chưa hoàn tất
- Kiểm tra callback `onCodeSent` có được gọi không
- Thử gửi lại OTP

### Lỗi: "Invalid verification code"  
- OTP sai hoặc đã hết hạn (60s)
- Thử gửi lại OTP mới

### SMS không đến (Production)
- Kiểm tra SHA-256 certificate đã thêm vào Firebase chưa
- Xem Firebase Console → **Authentication** → **Usage** để check quota
- Kiểm tra số điện thoại có đúng format quốc tế (+84...)

### Lỗi: "Quota exceeded"
- Đã vượt 10,000 verifications/tháng (free tier)
- Upgrade lên Blaze Plan trong Firebase Console

## Môi trường Production

### Checklist trước khi deploy
- [ ] Xóa **Phone numbers for testing** trong Firebase Console
- [ ] Thêm SHA-256 certificate (Android)
- [ ] Cấu hình APNs (iOS)
- [ ] Kiểm tra rate limiting
- [ ] Monitor usage qua Firebase Console → Authentication → Usage
- [ ] Backup authentication: giữ Google Sign-in hoạt động
- [ ] Upgrade Blaze Plan nếu expect >10k users/tháng

## Giữ lại Firebase Email/Password (tùy chọn)

Flow email/password vẫn hoạt động bình thường:
- Toggle "Đăng nhập bằng Email" trong UI
- Controller sẽ gọi `signInWithEmail()` thay vì `signInWithPhone()`
- Phù hợp cho admin hoặc internal users

## Sync Firebase ↔ Firestore

Khi user đăng nhập bằng phone:
1. Firebase Auth tạo user với UID
2. App tự động sync user đó vào Firestore `users/{uid}`
3. Tạo shop mặc định trong `shops/{uid}`
4. Tất cả logic booking/notification vẫn dùng Firestore như cũ

## Monitoring & Analytics

Firebase cung cấp dashboard theo dõi:
- **Authentication → Usage**: Số verifications mỗi ngày
- **Authentication → Users**: Danh sách users phone auth
- **Authentication → Settings**: Cấu hình rate limiting

## Support & Tài nguyên

### Firebase Documentation
- [Phone Auth - Android](https://firebase.google.com/docs/auth/android/phone-auth)
- [Phone Auth - iOS](https://firebase.google.com/docs/auth/ios/phone-auth)  
- [Phone Auth - Flutter](https://firebase.google.com/docs/auth/flutter/phone-auth)

### Nếu có vấn đề
1. Kiểm tra Firebase Console → **Authentication** logs
2. Debug với **Phone numbers for testing** trước
3. Xem Firebase Status: [status.firebase.google.com](https://status.firebase.google.com)
4. Liên hệ Firebase Support (Blaze Plan có priority support)

---

**Cập nhật:** 30/12/2024 - Chuyển từ Supabase sang Firebase Phone Authentication
