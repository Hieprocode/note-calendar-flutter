# Hướng dẫn đồng bộ ngôn ngữ toàn app

## Kiến trúc hệ thống translations

### 1. Core Components
```
lib/core/
├── translations/
│   ├── app_translations.dart  # GetX Translations class
│   ├── vi_vn.dart            # Tiếng Việt keys
│   └── en_us.dart            # English keys
├── services/
│   └── locale_service.dart   # Quản lý đổi ngôn ngữ + cache
├── utils/
│   └── tr_extensions.dart    # Extension tối ưu performance
└── widgets/
    └── language_selector.dart # UI chọn ngôn ngữ
```

### 2. Performance Optimization

#### a) Static Text (không thay đổi)
```dart
// ❌ Chậm - lookup mỗi lần rebuild
Text('customer_name'.tr)

// ✅ Tối ưu - dùng cached translation
static final _nameLabel = 'customer_name'.tr;
Text(_nameLabel)

// Hoặc dùng extension (future improvement)
Text('customer_name'.trOptimized)
```

#### b) Dynamic Text (thay đổi theo state)
```dart
// ✅ Đúng cách - wrap trong Obx
Obx(() => Text('greeting'.tr))

// ❌ Sai - không reactive
Text('greeting'.tr)  // Sẽ không update khi đổi ngôn ngữ
```

#### c) Widget const optimization
```dart
// ❌ Không thể const vì .tr runtime
const Text('title'.tr)  // Error!

// ✅ Static final cho reusable widgets
class MyWidget extends StatelessWidget {
  static final _title = 'title'.tr;
  
  @override
  Widget build(BuildContext context) {
    return Text(_title);
  }
}
```

### 3. Best Practices theo từng loại widget

#### A. StatelessWidget
```dart
class BookingCard extends StatelessWidget {
  const BookingCard({super.key});
  
  // Cache translations as static final
  static final _statusLabel = 'status'.tr;
  static final _confirmLabel = 'confirm'.tr;
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(_statusLabel),
        ElevatedButton(
          onPressed: () {},
          child: Text(_confirmLabel),
        ),
      ],
    );
  }
}
```

#### B. Controllers
```dart
class BookingController extends GetxController {
  // Cache trong controller - shared across builds
  late final String deleteMessage = 'delete_booking_message'.tr;
  late final String successMessage = 'booking_deleted'.tr;
  
  void deleteBooking() {
    Get.dialog(
      AlertDialog(
        title: Text('confirm_delete'.tr),  // OK vì dialog rebuild hiếm
        content: Text(deleteMessage),  // Dùng cached
      ),
    );
  }
}
```

#### C. ListView/GridView Items
```dart
ListView.builder(
  itemBuilder: (context, index) {
    final item = items[index];
    return ListTile(
      // ❌ Chậm - .tr gọi nhiều lần
      title: Text('service'.tr),
      
      // ✅ Tối ưu - static final bên ngoài builder
      title: Text(_serviceLabel),
    );
  },
)

// Define outside builder
static final _serviceLabel = 'service'.tr;
```

### 4. Checklist khi thêm feature mới

- [ ] Thêm keys vào `vi_vn.dart` và `en_us.dart`
- [ ] Dùng `.tr` cho mọi hardcoded text
- [ ] Cache static text bằng `static final`
- [ ] Wrap dynamic text trong `Obx()` nếu cần reactive
- [ ] Test cả 2 ngôn ngữ trước khi commit
- [ ] Đặt tên key theo pattern: `module_feature`

### 5. Migration Strategy (Đã hoàn thành)

✅ Core:
- [x] Translations files (vi_vn, en_us)
- [x] LocaleService with GetStorage
- [x] LanguageSelector widget
- [x] InitialBinding registration

✅ Modules đã migrate:
- [x] Calendar (calendar_view.dart)
- [x] Settings (settings_view.dart)
- [x] Booking (add_booking_view.dart)
- [x] Dashboard (partial - dashboard_view.dart)
- [x] Services (partial - services_view.dart)

⏳ Còn lại cần migrate:
- [ ] booking_detail_view.dart
- [ ] customer_view.dart
- [ ] edit_service_view.dart
- [ ] notification_view.dart (đã có translations, chưa apply)
- [ ] dashboard_view.dart (hoàn thiện hết các text)

### 6. Testing

```dart
// Test đổi ngôn ngữ
final localeService = Get.find<LocaleService>();

// Chuyển sang tiếng Anh
await localeService.changeToEnglish();

// Kiểm tra UI update
expect(find.text('Calendar'), findsOneWidget);

// Chuyển lại tiếng Việt
await localeService.changeToVietnamese();
expect(find.text('Lịch Hẹn'), findsOneWidget);
```

### 7. Common Issues & Solutions

**Issue**: Text không đổi khi switch language
```dart
// ❌ Problem
class MyView extends StatelessWidget {
  final title = 'my_title'.tr;  // Evaluated once at initialization
  
  // ✅ Solution 1: Static final trong class
  static final _title = 'my_title'.tr;
  
  // ✅ Solution 2: Obx for reactive
  Obx(() => Text('my_title'.tr))
}
```

**Issue**: GetStorage not initialized
```dart
// Ensure in main.dart before runApp:
await GetStorage.init();
```

**Issue**: Performance lag with many .tr calls
```dart
// Use static finals for frequently accessed translations
static final _commonLabels = {
  'name': 'customer_name'.tr,
  'phone': 'phone_number'.tr,
  'service': 'service'.tr,
};
```

### 8. Architecture Benefits

1. **Single Source of Truth**: Tất cả text ở 2 files
2. **Type Safety**: Compile-time check (nếu typo key, app crash ngay)
3. **Easy Maintenance**: Thêm ngôn ngữ mới chỉ cần 1 file
4. **Performance**: Cache + static finals = minimal overhead
5. **Scalability**: Dễ dàng thêm 10+ ngôn ngữ

### 9. Next Steps

1. Hoàn thiện migration các module còn lại
2. Add tests cho translations
3. Consider fallback locale cho missing keys
4. Add translation management tool (optional)
