import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../config/app_colors.dart';

class CustomDialog {
  // Show Error Dialog
  static void showError(String message, {String? title}) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: _buildDialogContent(
          title: title ?? 'Lỗi',
          message: message,
          icon: Icons.error_outline,
          iconColor: Colors.red.shade600,
          backgroundColor: Colors.white,
        ),
      ),
      barrierDismissible: false,
    );

    // Auto close after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
    });
  }

  // Show Warning Dialog
  static void showWarning(String message, {String? title}) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: _buildDialogContent(
          title: title ?? 'Cảnh báo',
          message: message,
          icon: Icons.warning_amber_rounded,
          iconColor: Colors.orange.shade600,
          backgroundColor: Colors.white,
        ),
      ),
      barrierDismissible: false,
    );

    // Auto close after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
    });
  }

  // Show Success Dialog
  static void showSuccess(String message, {String? title}) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: _buildDialogContent(
          title: title ?? 'Thành công',
          message: message,
          icon: Icons.check_circle_outline,
          iconColor: Colors.green.shade600,
          backgroundColor: Colors.white,
        ),
      ),
      barrierDismissible: false,
    );

    // Auto close after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
    });
  }

  // Show Info Dialog
  static void showInfo(String message, {String? title}) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: _buildDialogContent(
          title: title ?? 'Thông báo',
          message: message,
          icon: Icons.info_outline,
          iconColor: Colors.blue.shade600,
          backgroundColor: Colors.white,
        ),
      ),
      barrierDismissible: false,
    );

    // Auto close after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
    });
  }

  // Build Dialog Content
  static Widget _buildDialogContent({
    required String title,
    required String message,
    required IconData icon,
    required Color iconColor,
    required Color backgroundColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 48,
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Title
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 12),
          
          // Message
          Text(
            message,
            style: TextStyle(
              fontSize: 15,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 20),
          
          // Progress Indicator
          SizedBox(
            height: 3,
            child: TweenAnimationBuilder<double>(
              duration: const Duration(seconds: 3),
              tween: Tween(begin: 1.0, end: 0.0),
              builder: (context, value, child) {
                return LinearProgressIndicator(
                  value: value,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(iconColor),
                  borderRadius: BorderRadius.circular(2),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
