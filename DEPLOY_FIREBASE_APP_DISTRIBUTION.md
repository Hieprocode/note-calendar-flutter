# Hướng dẫn Deploy App qua Firebase App Distribution (MIỄN PHÍ)

## Bước 1: Cài đặt Firebase CLI
```bash
npm install -g firebase-tools
firebase login
```

## Bước 2: Build APK Release
```bash
# Build APK release
flutter build apk --release

# Hoặc build APK cho nhiều kiến trúc (file nhỏ hơn)
flutter build apk --split-per-abi --release

# File APK sẽ nằm ở: build/app/outputs/flutter-apk/app-release.apk
```

## Bước 3: Khởi tạo Firebase App Distribution
```bash
cd d:/Projects/note_calendar
firebase init appdistribution

# Chọn project Firebase hiện tại
# Chọn các app cần phân phối (Android)
```

## Bước 4: Upload APK lên App Distribution
```bash
# Upload APK
firebase appdistribution:distribute build/app/outputs/flutter-apk/app-release.apk \
  --app YOUR_FIREBASE_APP_ID \
  --release-notes "Phiên bản test đầu tiên" \
  --testers "email1@gmail.com,email2@gmail.com"

# Hoặc upload tới nhóm testers
firebase appdistribution:distribute build/app/outputs/flutter-apk/app-release.apk \
  --app YOUR_FIREBASE_APP_ID \
  --groups "testers" \
  --release-notes "Phiên bản test đầu tiên"
```

## Bước 5: Lấy Firebase App ID
1. Vào [Firebase Console](https://console.firebase.google.com/)
2. Chọn project `note_calendar`
3. Settings > General > Your apps > Android app
4. Copy **App ID** (dạng: `1:123456789:android:abc123def456`)

## Bước 6: Quản lý Testers
### Qua Firebase Console (dễ hơn):
1. Vào [Firebase Console](https://console.firebase.google.com/)
2. App Distribution > Testers & Groups
3. Thêm email testers hoặc tạo nhóm
4. Upload APK và gửi invite

### Qua CLI:
```bash
# Thêm testers
firebase appdistribution:testers:add email1@gmail.com email2@gmail.com

# Tạo nhóm testers
firebase appdistribution:group:create testers \
  --emails "email1@gmail.com,email2@gmail.com"
```

## Testers nhận được gì?
1. Email mời join App Distribution
2. Link tải app (qua browser hoặc Firebase App Tester app)
3. Tự động thông báo khi có bản cập nhật

## Lưu ý quan trọng:
- Testers cần cài **Firebase App Tester** app từ Play Store
- Hoặc bật "Install from unknown sources" để cài qua browser
- App Distribution HỖ TRỢ tối đa 200 testers miễn phí

## Script tự động deploy (tùy chọn)
Tạo file `deploy.sh`:
```bash
#!/bin/bash
echo "Building APK..."
flutter build apk --release

echo "Uploading to Firebase App Distribution..."
firebase appdistribution:distribute build/app/outputs/flutter-apk/app-release.apk \
  --app YOUR_FIREBASE_APP_ID \
  --groups "testers" \
  --release-notes "$(git log -1 --pretty=%B)"

echo "Deploy thành công!"
```

Chạy: `bash deploy.sh`
