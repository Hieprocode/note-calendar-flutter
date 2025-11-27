// lib/core/utils/app_alert.dart
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class AppAlert {
  static void success(String message) {
    Get.rawSnackbar(
      message: "Checkmark $message",
      backgroundColor: Colors.green,
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 2),
      animationDuration: const Duration(milliseconds: 400),
    );
  }

  static void error(String message) {
    Get.rawSnackbar(
      message: "Cross $message",
      backgroundColor: Colors.red,
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
    );
  }
}