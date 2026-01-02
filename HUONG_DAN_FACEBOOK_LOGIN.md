# Hướng Dẫn Setup Facebook Login Chi Tiết

## 📱 Bước 1: Tạo Facebook App

### 1.1. Vào Facebook Developers
1. Mở https://developers.facebook.com/
2. Đăng nhập bằng tài khoản Facebook cá nhân
3. Click **"My Apps"** (Ứng dụng của tôi) ở góc trên bên phải
4. Click **"Create App"** (Tạo ứng dụng)

### 1.2. Chọn Loại Ứng Dụng
1. Chọn **"Consumer"** (Người tiêu dùng)
   - Hoặc **"None"** nếu không thấy Consumer
2. Click **"Next"** (Tiếp theo)

### 1.3. Điền Thông Tin App
1. **App Display Name** (Tên hiển thị): `Note Calendar` (hoặc tên app của bạn)
2. **App Contact Email**: Email của bạn
3. Click **"Create App"** (Tạo ứng dụng)
4. Nhập mật khẩu Facebook để xác nhận

---

## 🔑 Bước 2: Lấy App ID và App Secret

### 2.1. Vào Dashboard
1. Sau khi tạo xong, bạn sẽ ở trang **Dashboard**
2. Bên trái, tìm phần **"Settings"** → Click **"Basic"** (Cài đặt → Cơ bản)

### 2.2. Copy Thông Tin
Bạn sẽ thấy:

```
App ID: 1234567890123456
App Secret: [Click "Show" để hiện] → abc123def456ghi789...
```

**LƯU LẠI 2 GIÁ TRỊ NÀY!**

---

## 🔥 Bước 3: Cấu Hình Firebase

### 3.1. Vào Firebase Console
1. Mở https://console.firebase.google.com/
2. Chọn project **note_calendar**
3. Menu bên trái → **Authentication** (Xác thực)
4. Tab **Sign-in method** (Phương thức đăng nhập)

### 3.2. Bật Facebook Provider
1. Tìm **Facebook** trong danh sách
2. Click vào dòng **Facebook**
3. Bật công tắc **Enable** (Bật)

### 3.3. Nhập Thông Tin
1. **App ID**: Paste App ID từ Facebook (bước 2.2)
2. **App secret**: Paste App Secret từ Facebook (bước 2.2)
3. **QUAN TRỌNG:** Copy **OAuth redirect URI**
   - Ví dụ: `https://note-calendar-xxxxx.firebaseapp.com/__/auth/handler`
   - **LƯU LẠI URI NÀY** để dùng ở Bước 4

4. Click **Save** (Lưu)

---

## 📲 Bước 4: Paste OAuth Redirect URI vào Facebook

### 4.1. Quay lại Facebook Developers
1. Vào https://developers.facebook.com/apps/
2. Click vào App vừa tạo (Note Calendar)

### 4.2. Thêm Facebook Login Product
1. Bên trái menu, tìm **"Add Product"** (Thêm sản phẩm)
2. Tìm **"Facebook Login"** trong danh sách
3. Click **"Set Up"** (Thiết lập)

### 4.3. Chọn Platform
1. Chọn **"Android"** (hoặc platform bạn đang dùng)
2. Click **"Next"** (nếu có)

### 4.4. Paste OAuth Redirect URI
**ĐÂY LÀ BƯỚC QUAN TRỌNG!**

1. Bên trái menu, tìm **"Facebook Login"**
2. Click vào **"Settings"** (Cài đặt) bên dưới Facebook Login
3. Bạn sẽ thấy trang **"Facebook Login Settings"**
4. Tìm ô **"Valid OAuth Redirect URIs"** (URI chuyển hướng OAuth hợp lệ)
5. **PASTE URI đã copy từ Firebase** vào ô này
   - Ví dụ: `https://note-calendar-xxxxx.firebaseapp.com/__/auth/handler`
6. Click **"Save Changes"** (Lưu thay đổi) ở cuối trang

### Hình ảnh mô tả vị trí:
```
Facebook Developers
└── [Your App Name]
    └── Products (Sản phẩm)
        └── Facebook Login
            └── Settings (Cài đặt) ← Click vào đây
                └── Valid OAuth Redirect URIs ← Paste vào đây
```

---

## 🤖 Bước 5: Cấu Hình Android App

### 5.1. Lấy Package Name
Package name của bạn là: `com.example.note_calendar`

(Kiểm tra trong `android/app/build.gradle.kts` → `namespace`)

### 5.2. Lấy Key Hashes
Chạy lệnh này trong terminal:

**Windows:**
```bash
cd android
keytool -exportcert -alias androiddebugkey -keystore ~/.android/debug.keystore | openssl sha1 -binary | openssl base64
```

**Mac/Linux:**
```bash
cd android
keytool -exportcert -alias androiddebugkey -keystore ~/.android/debug.keystore | openssl sha1 -binary | openssl base64
```

Password: `android` (mặc định)

Kết quả: `XYZ123abc456...=`

### 5.3. Thêm vào Facebook App
1. Quay lại Facebook Developers Dashboard
2. **Settings** → **Basic** (Cài đặt → Cơ bản)
3. Kéo xuống cuối, click **"+ Add Platform"** (Thêm nền tảng)
4. Chọn **"Android"**
5. Điền:
   - **Google Play Package Name**: `com.example.note_calendar`
   - **Class Name**: `com.example.note_calendar.MainActivity`
   - **Key Hashes**: Paste key hash từ bước 5.2
6. Click **"Save Changes"**

---

## 📝 Bước 6: Cấu Hình Android Code

### 6.1. Tạo file strings.xml
Tạo file `android/app/src/main/res/values/strings.xml`:

```xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <string name="app_name">Note Calendar</string>
    <string name="facebook_app_id">PASTE_APP_ID_Ở_ĐÂY</string>
    <string name="facebook_client_token">PASTE_APP_SECRET_Ở_ĐÂY</string>
</resources>
```

**Thay thế:**
- `PASTE_APP_ID_Ở_ĐÂY` → App ID từ bước 2.2
- `PASTE_APP_SECRET_Ở_ĐÂY` → App Secret từ bước 2.2

### 6.2. Cập nhật AndroidManifest.xml
Mở `android/app/src/main/AndroidManifest.xml`

Thêm vào trong tag `<application>` (trước `</application>`):

```xml
<!-- Facebook SDK -->
<meta-data 
    android:name="com.facebook.sdk.ApplicationId" 
    android:value="@string/facebook_app_id"/>
    
<meta-data 
    android:name="com.facebook.sdk.ClientToken" 
    android:value="@string/facebook_client_token"/>

<activity 
    android:name="com.facebook.FacebookActivity"
    android:configChanges="keyboard|keyboardHidden|screenLayout|screenSize|orientation"
    android:label="@string/app_name" />
    
<activity
    android:name="com.facebook.CustomTabActivity"
    android:exported="true">
    <intent-filter>
        <action android:name="android.intent.action.VIEW" />
        <category android:name="android.intent.category.DEFAULT" />
        <category android:name="android.intent.category.BROWSABLE" />
        <data android:scheme="@string/facebook_app_id" />
    </intent-filter>
</activity>
```

---

## 🚀 Bước 7: Chuyển App Sang Live Mode

**QUAN TRỌNG:** App mặc định ở Development Mode, chỉ admin test được!

### 7.1. Thêm Test Users (Tạm thời)
1. Facebook Developers → **Roles** (Vai trò)
2. **Test Users** → Click **"Add"**
3. Tạo test user để test

### 7.2. Chuyển Live (Khi sẵn sàng)
1. Facebook Developers → Top menu
2. Toggle từ **"In Development"** → **"Live"**
3. Cần điền thêm:
   - Privacy Policy URL (URL chính sách bảo mật)
   - Terms of Service URL (URL điều khoản dịch vụ)
   - App Icon

---

## ✅ Bước 8: Test

### 8.1. Rebuild App
```bash
flutter clean
flutter pub get
flutter run
```

### 8.2. Test Flow
1. Mở app → Màn hình đăng nhập
2. Click **"Tiếp tục với Facebook"**
3. Popup Facebook login → Đăng nhập
4. Cho phép quyền truy cập
5. App tự động đăng nhập và chuyển màn hình

---

## 🔧 Troubleshooting

### ❌ "App Not Setup: This app is still in development mode"
**Nguyên nhân:** App chưa Live hoặc user không phải test user  
**Giải pháp:** Thêm user vào Test Users (Bước 7.1) hoặc chuyển Live (Bước 7.2)

### ❌ "Invalid OAuth Redirect URI"
**Nguyên nhân:** URI trong Facebook không khớp với Firebase  
**Giải pháp:** 
1. Firebase Console → Authentication → Facebook → Copy lại URI
2. Facebook Developers → Facebook Login → Settings → Paste lại đúng

### ❌ "Invalid key hash"
**Nguyên nhân:** Key hash không đúng  
**Giải pháp:** Chạy lại lệnh ở Bước 5.2, paste key mới vào Facebook

### ❌ "Can't Load URL: The domain of this URL isn't included in the app's domains"
**Nguyên nhân:** Chưa thêm Firebase domain vào Facebook  
**Giải pháp:**
1. Facebook Developers → Settings → Basic
2. **App Domains**: Thêm `note-calendar-xxxxx.firebaseapp.com`
3. Save

---

## 📋 Checklist Hoàn Thành

- [ ] Tạo Facebook App
- [ ] Copy App ID & App Secret
- [ ] Enable Facebook trong Firebase
- [ ] Paste App ID & Secret vào Firebase
- [ ] **Copy OAuth Redirect URI từ Firebase**
- [ ] **Paste OAuth URI vào Facebook Login → Settings → Valid OAuth Redirect URIs**
- [ ] Thêm Android Platform vào Facebook
- [ ] Thêm Package Name & Key Hashes
- [ ] Tạo file `strings.xml` với App ID & Secret
- [ ] Cập nhật `AndroidManifest.xml`
- [ ] Rebuild app (`flutter clean && flutter run`)
- [ ] Test đăng nhập Facebook

---

## 🎯 Tóm Tắt Nhanh

**OAuth Redirect URI paste vào đâu?**

```
Facebook Developers
→ Chọn App của bạn
→ Menu bên trái: Products (Sản phẩm)
→ Facebook Login
→ Settings (Cài đặt)
→ Ô "Valid OAuth Redirect URIs"
→ PASTE URI từ Firebase vào đây
→ Save Changes
```

**URI trông như thế nào?**
```
https://note-calendar-xxxxx.firebaseapp.com/__/auth/handler
```

**Nếu không thấy "Facebook Login" trong menu bên trái:**
1. Dashboard → Add Product
2. Tìm "Facebook Login"
3. Click "Set Up"
4. Sau đó mới thấy "Facebook Login" trong menu

---

**Updated:** December 28, 2025
