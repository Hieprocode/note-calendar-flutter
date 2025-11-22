

### BƯỚC 1: Cấu hình `.gitignore` (Chặn file rác)

Mặc dù Flutter tạo sẵn file này, nhưng bạn cần bổ sung để đảm bảo IDE của người khác (VS Code/Android Studio) không gây xung đột file cấu hình.

Hãy mở file `.gitignore` ở thư mục gốc và đảm bảo nó có đủ các nội dung sau:

```text
# -----------------------
# MISCELLANEOUS (Rác hệ thống)
# -----------------------
*.class
*.log
*.pyc
*.swp
.DS_Store
.atom/
.build/
.buildlog/
.history
.svn/
.swiftpm/
migrate_working_dir/
Thumbs.db
ehthumbs.db
Desktop.ini

# -----------------------
# IDE & EDITOR (Cấu hình cá nhân)
# -----------------------
# IntelliJ / Android Studio
*.iml
*.ipr
*.iws
.idea/

# VS Code (Nên chặn để tránh xung đột setting giữa các máy dev)
.vscode/

# -----------------------
# FLUTTER / DART / PUB
# -----------------------
**/doc/api/
**/ios/Flutter/.last_build_id
.dart_tool/
.flutter-plugins
.flutter-plugins-dependencies
.pub-cache/
.pub/
/build/
/coverage/

# -----------------------
# SYMBOLICATION & OBFUSCATION
# -----------------------
app.*.symbols
app.*.map.json

# -----------------------
# ANDROID RELATED
# -----------------------
/android/app/debug
/android/app/profile
/android/app/release
/android/app/build
/android/build
/android/.gradle
/android/local.properties

# Key ký ứng dụng (Tuyệt đối không public file này nếu có)
android/key.properties

# Firebase Config Android
# (Nếu team nhỏ/private repo thì CÓ THỂ commit file này để dev khác chạy luôn. 
# Nếu muốn bảo mật tuyệt đối thì bỏ dấu # ở dòng dưới để chặn nó)
# android/app/google-services.json

# -----------------------
# IOS RELATED
# -----------------------
/ios/Flutter/App.framework
/ios/Flutter/Flutter.framework
/ios/Flutter/Generated.xcconfig
/ios/ServiceDefinitions.json
/ios/Runner/GeneratedPluginRegistrant.*
/ios/Pods/
/ios/.symlinks/
/ios/Profile/
/ios/Release/

# Firebase Config iOS
# (Tương tự Android, để dòng này mở để team dễ làm việc)
# ios/Runner/GoogleService-Info.plist

# -----------------------
# WEB RELATED
# -----------------------
lib/generated_plugin_registrant.dart

# -----------------------
# ENVIRONMENT VARIABLES (QUAN TRỌNG)
# -----------------------
# Chặn file chứa Key API nhạy cảm (nếu sau này dùng package flutter_dotenv)
.env*
```

*Lưu ý về `google-services.json`:* Vì đây là dự án private team nhỏ, bạn có thể **commit luôn file `android/app/google-services.json`** lên GitHub để dev kia pull về chạy được ngay. Nếu dự án public, file này phải nằm trong `.gitignore`.

-----
````markdown
# 📅 NOTE CALENDAR - Mobile App

Ứng dụng quản lý đặt lịch đa năng dành cho chủ kinh doanh (Sân bóng, Spa, Salon, v.v.).
Dự án sử dụng Flutter (GetX + Clean Architecture) kết hợp Firebase & Supabase.

## 🛠 Tech Stack
- **Framework:** Flutter 3.24+
- **Language:** Dart
- **State Management:** GetX
- **Architecture:** Clean Architecture (Data - Domain - Presentation)
- **Backend:**
  - Firebase Auth (Login OTP)
  - Cloud Firestore (Database)
  - Supabase Storage (Image Storage)

## 🚀 Yêu cầu môi trường (Prerequisites)
- Flutter SDK: >= 3.24.0
- Java JDK: 11 hoặc 17
- Android Studio / VS Code

## ⚙️ Cài đặt & Chạy dự án (Setup)

### 1. Clone dự án
```bash
git clone <link-repo-cua-ban>
cd note_calendar
````

### 2\. Cài đặt thư viện

```bash
flutter pub get
```

### 3\. Cấu hình Key (Quan trọng)

Dự án đã tích hợp sẵn `google-services.json` cho Android.
Tuy nhiên, cần kiểm tra file `lib/core/config/supabase_config.dart` để đảm bảo đã có Key của Supabase.


### 4\. Chạy ứng dụng

```bash
# Chạy máy ảo Android
flutter run
```

## 📂 Cấu trúc thư mục (Folder Structure)

```text
lib/
├── core/           # Config, Utils, Constants, Widgets dùng chung
├── data/           # Models, Repositories, Providers (Firebase/Supabase)
├── modules/        # Các màn hình (Screen + Controller + Binding)
│   ├── auth/       # Đăng nhập
│   ├── dashboard/  # Màn hình chính
│   ├── booking/    # Quản lý lịch hẹn
│   └── ...
└── main.dart       # Entry point
```

````

---

### BƯỚC 3: Tạo file `RULES.md` (Quy định Code - Coding Convention)

Đây là file quan trọng nhất để giữ code sạch. Bạn tạo file tên là `RULES.md` ngang hàng với `README.md`.

```markdown
# 📏 QUY ĐỊNH CODE (CODING CONVENTIONS) - TEAM NOTE CALENDAR

Mọi thành viên vui lòng tuân thủ quy tắc dưới đây để đảm bảo code đồng bộ, dễ đọc và dễ bảo trì.

## 1. Quy tắc đặt tên (Naming Convention)

- **Tên thư mục & File:** snake_case (chữ thường, cách nhau gạch dưới)
  - ✅ Đúng: `home_screen.dart`, `auth_controller.dart`, `user_model.dart`
  - ❌ Sai: `HomeScreen.dart`, `authController.dart`

- **Tên Class:** PascalCase (Viết hoa chữ cái đầu mỗi từ)
  - ✅ Đúng: `class HomeScreen`, `class AuthController`

- **Tên Biến & Hàm:** camelCase (Chữ đầu thường, các từ sau viết hoa)
  - ✅ Đúng: `String userName`, `void getBookingList()`

- **Hằng số (Const):** SCREAMING_SNAKE_CASE (Viết hoa toàn bộ)
  - ✅ Đúng: `const double PADDING_DEFAULT = 16.0;`

## 2. Kiến trúc & GetX Pattern

- **Tuyệt đối không viết Logic trong UI (View):**
  - Mọi logic xử lý (gọi API, tính toán) phải nằm trong `Controller`.
  - View chỉ làm nhiệm vụ hiển thị và gọi hàm từ Controller.

- **Cấu trúc 1 Module:**
  Mỗi màn hình (Module) phải có thư mục riêng trong `lib/modules/`, bao gồm:
  - `..._view.dart`: Chứa giao diện.
  - `..._controller.dart`: Chứa logic.
  - `..._binding.dart`: Khởi tạo controller (Dependency Injection).

## 3. Import & Code Style
- Sử dụng `import` tương đối (relative) cho các file trong cùng module.
- Sử dụng `import` tuyệt đối (package:...) cho các file core hoặc module khác.
- Luôn chạy lệnh format code trước khi commit:
  ```bash
  dart format .
````

## 4\. Quy trình Git (Git Flow)

  - **Branch:** Không code trực tiếp trên nhánh `main`.

      - Tạo branch mới theo cú pháp: `feature/ten-tinh-nang` hoặc `fix/ten-loi`.
      - Ví dụ: `feature/login_screen`, `fix/crash_booking`.

  - **Commit Message:** Rõ ràng, ngắn gọn.

      - `[Feature] Thêm màn hình đăng nhập`
      - `[Fix] Sửa lỗi crash khi không có mạng`
      - `[Update] Cập nhật icon app`

<!-- end list -->

````




