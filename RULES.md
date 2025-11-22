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