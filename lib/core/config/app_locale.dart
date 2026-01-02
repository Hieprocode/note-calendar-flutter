// lib/core/config/app_locale.dart
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/// Cấu hình ngôn ngữ cho ứng dụng
class AppLocale {
  // Ngôn ngữ mặc định
  static const Locale defaultLocale = Locale('vi', 'VN');
  
  // Danh sách ngôn ngữ hỗ trợ
  static const List<Locale> supportedLocales = [
    Locale('vi', 'VN'), // Tiếng Việt
    Locale('en', 'US'), // Tiếng Anh
  ];
  
  // Localization delegates cho Material, Cupertino và Widgets
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = [
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];
  
  /// Lấy tên ngôn ngữ hiển thị
  static String getLanguageName(Locale locale) {
    switch (locale.languageCode) {
      case 'vi':
        return 'Tiếng Việt';
      case 'en':
        return 'English';
      default:
        return 'Unknown';
    }
  }
}
