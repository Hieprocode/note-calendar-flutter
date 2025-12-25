// lib/core/services/locale_service.dart
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

/// Service để quản lý ngôn ngữ của ứng dụng
class LocaleService extends GetxService {
  final _storage = GetStorage();
  static const String _localeKey = 'app_locale';
  
  // Current locale observable
  final Rx<Locale> currentLocale = const Locale('vi', 'VN').obs;
  
  @override
  void onInit() {
    super.onInit();
    _loadSavedLocale();
  }
  
  /// Load ngôn ngữ đã lưu từ storage
  void _loadSavedLocale() {
    final savedLocale = _storage.read(_localeKey);
    if (savedLocale != null) {
      final parts = (savedLocale as String).split('_');
      if (parts.length == 2) {
        currentLocale.value = Locale(parts[0], parts[1]);
        Get.updateLocale(currentLocale.value);
      }
    }
  }
  
  /// Đổi ngôn ngữ
  Future<void> changeLocale(Locale locale) async {
    currentLocale.value = locale;
    Get.updateLocale(locale);
    await _storage.write(_localeKey, '${locale.languageCode}_${locale.countryCode}');
  }
  
  /// Đổi sang tiếng Việt
  Future<void> changeToVietnamese() async {
    await changeLocale(const Locale('vi', 'VN'));
  }
  
  /// Đổi sang tiếng Anh
  Future<void> changeToEnglish() async {
    await changeLocale(const Locale('en', 'US'));
  }
  
  /// Đổi sang tiếng Hàn
  Future<void> changeToKorean() async {
    await changeLocale(const Locale('ko', 'KR'));
  }
  
  /// Lấy tên ngôn ngữ hiện tại
  String get currentLanguageName {
    if (currentLocale.value.languageCode == 'vi') {
      return 'Tiếng Việt';
    } else if (currentLocale.value.languageCode == 'en') {
      return 'English';
    } else if (currentLocale.value.languageCode == 'ko') {
      return '한국어';
    }
    return 'Unknown';
  }
  
  /// Check xem có phải tiếng Việt không
  bool get isVietnamese => currentLocale.value.languageCode == 'vi';
  
  /// Check xem có phải tiếng Anh không
  bool get isEnglish => currentLocale.value.languageCode == 'en';
  
  /// Check xem có phải tiếng Hàn không
  bool get isKorean => currentLocale.value.languageCode == 'ko';
}
