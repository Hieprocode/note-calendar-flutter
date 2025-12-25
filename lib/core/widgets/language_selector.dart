// lib/core/widgets/language_selector.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/locale_service.dart';
import '../config/app_colors.dart';

/// Widget để chọn ngôn ngữ (có thể dùng trong Settings)
class LanguageSelector extends StatelessWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context) {
    // Lazy initialization - tạo nếu chưa có
    final localeService = Get.isRegistered<LocaleService>() 
        ? Get.find<LocaleService>() 
        : Get.put(LocaleService());
    
    return Obx(() => Container(
      decoration: BoxDecoration(
        color: AppColors.glassBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorder, width: 1.5),
      ),
      child: Column(
        children: [
          _buildLanguageOption(
            title: 'vietnamese'.tr,
            locale: const Locale('vi', 'VN'),
            isSelected: localeService.isVietnamese,
            icon: '🇻🇳',
            onTap: () => localeService.changeToVietnamese(),
          ),
          Divider(height: 1, color: AppColors.glassBorder),
          _buildLanguageOption(
            title: 'english'.tr,
            locale: const Locale('en', 'US'),
            isSelected: localeService.isEnglish,
            icon: '🇺🇸',
            onTap: () => localeService.changeToEnglish(),
          ),
          Divider(height: 1, color: AppColors.glassBorder),
          _buildLanguageOption(
            title: 'korean'.tr,
            locale: const Locale('ko', 'KR'),
            isSelected: localeService.isKorean,
            icon: '🇰🇷',
            onTap: () => localeService.changeToKorean(),
          ),
        ],
      ),
    ));
  }
  
  Widget _buildLanguageOption({
    required String title,
    required Locale locale,
    required bool isSelected,
    required String icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Text(
                icon,
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? AppColors.primary : AppColors.textPrimary,
                  ),
                ),
              ),
              if (isSelected)
                const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.primary,
                  size: 22,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
