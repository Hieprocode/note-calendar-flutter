# Hướng Dẫn Setup Google Sign In - Đơn Giản

## ✅ Những gì đã có sẵn:
- ✅ Code đã implement xong trong app
- ✅ Package `google_sign_in: ^6.2.2` đã cài
- ✅ SHA-256 Debug Key đã có: `30:4E:17:6B:B0:13:B0:4F:99:04:E4:E4:8E:8D:FF:A4:88:80:E3:0C:96:44:E3:53:3F:4E:E1:66:AF:5C:66:2C`

---

## 🔥 Bước 1: Enable Google Sign In trong Firebase Console

### 1.1. Vào Firebase Console
1. Mở https://console.firebase.google.com/
2. Chọn project **note_calendar**
3. Menu trái → **Authentication** (Xác thực)
4. Tab **Sign-in method** (Phương thức đăng nhập)

### 1.2. Enable Google Provider
1. Tìm **Google** trong danh sách providers
2. Click vào dòng **Google**
3. Bật công tắc **Enable** (Bật)
4. **Project support email**: Chọn email của bạn từ dropdown
5. Click **Save** (Lưu)

**✅ XONG! Google Sign In đã enable!**

---

## 🎨 Bước 2 (Tùy chọn): Thêm Logo Google

Hiện tại app dùng icon fallback. Muốn logo Google đẹp hơn:

### Cách 1: Download logo
1. Download logo Google PNG: https://www.google.com/images/branding/googlelogo/1x/googlelogo_color_272x92dp.png
2. Resize về 24x24 px hoặc 48x48 px (dùng tool online)
3. Đổi tên thành `google_logo.png`
4. Copy vào thư mục `assets/` trong project

### Cách 2: Dùng Google "G" icon
1. Download từ: https://upload.wikimedia.org/wikipedia/commons/thumb/5/53/Google_%22G%22_Logo.svg/512px-Google_%22G%22_Logo.svg.png
2. Đổi tên thành `google_logo.png`
3. Copy vào thư mục `assets/`

### Cách 3: Giữ icon mặc định
App hiện đang dùng `Icons.login` làm fallback, vẫn hoạt động bình thường!

---

## 🚀 Bước 3: Test Google Sign In

### 3.1. Rebuild App (Nếu cần)
```bash
flutter clean
flutter pub get
flutter run
```

### 3.2. Test Flow
1. Mở app → Màn hình đăng nhập
2. Click **"Tiếp tục với Google"**
3. Popup chọn tài khoản Google → Chọn tài khoản
4. App tự động đăng nhập
5. Nếu chưa có shop → Chuyển đến Setup Shop
6. Nếu đã có shop → Chuyển đến Dashboard

---

## 🔧 Troubleshooting

### ❌ "PlatformException(sign_in_failed)"
**Nguyên nhân:** SHA-256 chưa thêm vào Firebase  
**Giải pháp:**
1. Firebase Console → Project Settings → Your apps → Android app
2. Kéo xuống **SHA certificate fingerprints**
3. Click **Add fingerprint**
4. Paste: `30:4E:17:6B:B0:13:B0:4F:99:04:E4:E4:8E:8D:FF:A4:88:80:E3:0C:96:44:E3:53:3F:4E:E1:66:AF:5C:66:2C`
5. Save
6. Download `google-services.json` mới và replace vào `android/app/`

### ❌ "ApiException: 10"
**Nguyên nhân:** `google-services.json` không đúng  
**Giải pháp:**
1. Firebase Console → Project Settings
2. Scroll xuống **Your apps** → Android app
3. Click **Download google-services.json**
4. Replace file cũ trong `android/app/google-services.json`
5. Rebuild app: `flutter clean && flutter run`

### ❌ "Google Sign In cancelled"
**Nguyên nhân:** User đóng popup  
**Giải pháp:** Đây là hành vi bình thường, không phải lỗi

### ❌ Logo không hiện (Icon đỏ xuất hiện)
**Nguyên nhân:** File `assets/google_logo.png` không tồn tại  
**Giải pháp:** 
- Thêm file `google_logo.png` vào `assets/` (Bước 2)
- Hoặc bỏ qua, app vẫn chạy bình thường với fallback icon

---

## 📋 Checklist Hoàn Thành Google Sign In

- [x] Package google_sign_in đã cài (v6.2.2)
- [x] Code đã implement trong AuthRepository, AuthController, AuthView
- [x] SHA-256 đã có: 30:4E:17:6B:B0:13:B0:4F:99:04:E4:E4:8E:8D:FF:A4:88:80:E3:0C:96:44:E3:53:3F:4E:E1:66:AF:5C:66:2C
- [ ] **Enable Google trong Firebase Console** (Bước 1)
- [ ] Thêm SHA-256 vào Firebase nếu chưa có
- [ ] (Tùy chọn) Thêm `google_logo.png` vào assets
- [ ] Test đăng nhập Google

---

## 🎯 Tóm Tắt Nhanh

**Chỉ cần làm 1 việc:**

1. Firebase Console → Authentication → Sign-in method → Google → Enable → Chọn email → Save

**XONGGoogle Sign In hoạt động ngay!**

---

## 📸 SHA-256 đã có (Đã chạy lệnh trước đó)

```
30:4E:17:6B:B0:13:B0:4F:99:04:E4:E4:8E:8D:FF:A4:88:80:E3:0C:96:44:E3:53:3F:4E:E1:66:AF:5C:66:2C
```

**Nếu Firebase báo cần SHA-256:**
1. Firebase Console → Project Settings → Android app
2. Add fingerprint → Paste SHA-256 trên → Save
3. Download google-services.json mới → Replace vào android/app/

---

**Updated:** December 28, 2025
