// lib/core/utils/tr_extensions.dart
import 'package:get/get.dart';

/// Extension để tối ưu performance cho translations
/// Sử dụng: 'key'.trOptimized thay vì 'key'.tr
extension TranslationOptimization on String {
  /// Cached translation để tránh lookup nhiều lần
  /// Chỉ dùng cho static text không thay đổi
  String get trOptimized {
    return Get.find<_TranslationCache>().get(this);
  }
}

/// Internal cache service
class _TranslationCache extends GetxService {
  final Map<String, String> _cache = {};
  
  String get(String key) {
    return _cache.putIfAbsent(key, () => key.tr);
  }
  
  void clear() {
    _cache.clear();
  }
  
  /// Gọi khi đổi ngôn ngữ để refresh cache
  void refresh() {
    final keys = _cache.keys.toList();
    _cache.clear();
    for (final key in keys) {
      _cache[key] = key.tr;
    }
  }
}
