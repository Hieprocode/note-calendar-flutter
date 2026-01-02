// lib/core/README_TRANSLATIONS.md
# Hệ thống đa ngôn ngữ (i18n)

## Cấu trúc

```
lib/core/
├── translations/
│   ├── app_translations.dart  # Main translations class
│   ├── vi_vn.dart            # Tiếng Việt
│   └── en_us.dart            # English
├── services/
│   └── locale_service.dart   # Service quản lý ngôn ngữ
├── widgets/
│   └── language_selector.dart # Widget chọn ngôn ngữ
└── config/
    └── app_locale.dart       # Cấu hình locale
```

## Cách sử dụng

### 1. Thêm text mới vào hệ thống đa ngôn ngữ

**Bước 1:** Thêm key vào `lib/core/translations/vi_vn.dart`
```dart
const Map<String, String> viVN = {
  'my_new_key': 'Văn bản tiếng Việt',
  // ...
};
```

**Bước 2:** Thêm key tương ứng vào `lib/core/translations/en_us.dart`
```dart
const Map<String, String> enUS = {
  'my_new_key': 'English text',
  // ...
};
```

**Bước 3:** Sử dụng trong code
```dart
// Cách 1: Trong Widget
Text('my_new_key'.tr)

// Cách 2: Trong Controller/Service
String text = 'my_new_key'.tr;

// Cách 3: Với tham số động
'welcome_message'.trParams({'name': 'John'})
// Trong file translation: 'welcome_message': 'Xin chào @name'
```

### 2. Đổi ngôn ngữ

**Option A: Sử dụng LocaleService (Recommended)**
```dart
final localeService = Get.find<LocaleService>();

// Đổi sang tiếng Việt
await localeService.changeToVietnamese();

// Đổi sang tiếng Anh
await localeService.changeToEnglish();

// Hoặc custom locale
await localeService.changeLocale(Locale('vi', 'VN'));
```

**Option B: Sử dụng widget có sẵn**
```dart
// Trong Settings page hoặc bất kỳ đâu
LanguageSelector()
```

### 3. Check ngôn ngữ hiện tại

```dart
final localeService = Get.find<LocaleService>();

// Check tiếng Việt
if (localeService.isVietnamese) {
  // ...
}

// Check tiếng Anh
if (localeService.isEnglish) {
  // ...
}

// Lấy tên ngôn ngữ
String langName = localeService.currentLanguageName; // "Tiếng Việt" hoặc "English"
```

### 4. Reactive UI với ngôn ngữ

```dart
// UI sẽ tự động rebuild khi đổi ngôn ngữ
Obx(() => Text('greeting'.tr))
```

## Quy tắc đặt tên key

- Sử dụng **snake_case**: `customer_name`, `save_booking`
- Nhóm theo chức năng: `booking_`, `notification_`, `setting_`
- Ngắn gọn, dễ hiểu
- Tránh trùng lặp

### Ví dụ tốt:
```dart
'booking_create': 'Tạo lịch hẹn',
'booking_edit': 'Sửa lịch hẹn',
'booking_delete': 'Xóa lịch hẹn',
'notification_mark_read': 'Đánh dấu đã đọc',
```

### Tránh:
```dart
'text1': 'Tạo lịch',  // ❌ Không rõ nghĩa
'CreateBookingButtonLabel': 'Tạo lịch',  // ❌ camelCase
'tạo_lịch': 'Tạo lịch',  // ❌ Tiếng Việt trong key
```

## Thêm ngôn ngữ mới

**Bước 1:** Tạo file mới (ví dụ: `ja_jp.dart` cho tiếng Nhật)
```dart
// lib/core/translations/ja_jp.dart
const Map<String, String> jaJP = {
  'app_name': 'アポイントメントカレンダー',
  'calendar': 'カレンダー',
  // ...
};
```

**Bước 2:** Import và thêm vào `app_translations.dart`
```dart
import 'ja_jp.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    'vi_VN': viVN,
    'en_US': enUS,
    'ja_JP': jaJP,  // Thêm dòng này
  };
}
```

**Bước 3:** Cập nhật `app_locale.dart`
```dart
static const List<Locale> supportedLocales = [
  Locale('vi', 'VN'),
  Locale('en', 'US'),
  Locale('ja', 'JP'),  // Thêm dòng này
];
```

**Bước 4:** Thêm method vào `locale_service.dart`
```dart
Future<void> changeToJapanese() async {
  await changeLocale(const Locale('ja', 'JP'));
}
```

## Best Practices

1. **Luôn thêm translation cho TẤT CẢ ngôn ngữ** khi thêm text mới
2. **Test trên cả 2 ngôn ngữ** trước khi commit
3. **Không hardcode text** - luôn dùng `.tr`
4. **Nhóm keys theo module** để dễ quản lý
5. **Document các key phức tạp** bằng comment

## Migration từ hardcoded text

### Before:
```dart
Text("Lịch Hẹn")
Text("Không có lịch hẹn")
```

### After:
```dart
Text('calendar'.tr)
Text('no_bookings'.tr)
```

## Troubleshooting

### 1. Text không đổi khi switch language
- Check xem đã dùng `.tr` chưa
- Check xem widget có wrap trong `Obx()` nếu cần reactive

### 2. Key not found
- Check xem key có tồn tại trong **cả 2 file** vi_vn.dart và en_us.dart chưa
- Check spelling của key

### 3. Locale không persist sau khi restart app
- Check `GetStorage.init()` đã được gọi trong `main()` chưa
- Check LocaleService đã được initialize chưa
