// lib/core/translations/app_translations.dart
import 'package:get/get.dart';
import 'vi_vn.dart';
import 'en_us.dart';
import 'ko_kr.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'vi_VN': viVN,
        'en_US': enUS,
        'ko_KR': koKR,
      };
}
