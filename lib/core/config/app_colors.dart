import 'package:flutter/material.dart';

/// Màu chủ đạo của ứng dụng
class AppColors {
  AppColors._(); // Private constructor để không thể khởi tạo

  // Màu chính - Xanh dương gradient
  static const Color primary = Color(0xFF3B7197);
  static const Color primaryLight = Color(0xFF4A8DB7);
  static const Color primaryLighter = Color(0xFF74BDE0);
  static const Color primaryLightest = Color(0xFFA1E1FA);
  static const Color primaryDark = Color(0xFF2E424D);
  static const Color greypastel = Color(0xFFCCCDC7);
  
  // Màu cam - Orange palette
  static const Color orange = Color(0xFFFF8200);
  static const Color orangeLight = Color(0xFFFFC929);
  static const Color yellow = Color.fromARGB(255, 248, 242, 137);  
  static const Color green = Color(0xFF57C785);
  static const Color purpleCheckIn = Color(0xFF886FE3);
  static const Color redConfirmed = Color(0xFFFD1D1D);
  // Gradient chính của app
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryLight],
  );

  static const LinearGradient orangeGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [orange, orangeLight],
  );

  static const LinearGradient primaryGradientLight = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryLight, primaryLighter],
  );

  // Màu nền
  static const Color ivory = Color(0xFFFFFFF0);
  static const Color cardBackground = Colors.white;

  // Màu văn bản
  static final Color textPrimary = Colors.grey.shade900;
  static final Color textSecondary = Colors.grey.shade600;
  static const Color textLight = Colors.white;
  static final Color textHint = Colors.grey.shade400;

  // Const versions for performance (avoiding .shade runtime calculation)
  static const Color textPrimaryConst = Color(0xFF212121); // grey[900]
  static const Color textSecondaryConst = Color(0xFF757575); // grey[600]

  // Màu trạng thái
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFA726);
  static const Color error = Color(0xFFEF5350);
  static const Color info = Color(0xFF29B6F6);

  // Màu cho các trạng thái booking
  static const Color pending = Color(0xFFFFA726);
  static const Color confirmed = Color(0xFF29B6F6);
  static const Color completed = Color(0xFF4CAF50);
  static const Color cancelled = Color(0xFFEF5350);

  // Màu shadow
  static Color shadowLight = Colors.black.withOpacity(0.05);
  static Color shadowMedium = Colors.black.withOpacity(0.1);
  static Color shadowDark = Colors.black.withOpacity(0.15);

  // Glass morphism colors
  static Color glassBackground = Colors.white.withOpacity(0.5);
  static Color glassBorder = Colors.white.withOpacity(0.3);

  // Const versions for performance
  static const Color glassBackgroundConst = Color(0x80FFFFFF); // white with 50% opacity
  static const Color glassBorderConst = Color(0x4DFFFFFF); // white with 30% opacity
}
