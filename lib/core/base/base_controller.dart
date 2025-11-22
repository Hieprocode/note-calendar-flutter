// File: lib/core/base/base_controller.dart
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class BaseController extends GetxController {
  var isLoading = false.obs;

  // Hiện Loading
  void showLoading() {
    isLoading.value = true;
    if (Get.isDialogOpen == false) {
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );
    }
  }

  // Ẩn Loading
  void hideLoading() {
    if (isLoading.value) {
      isLoading.value = false;
      if (Get.isDialogOpen == true) Get.back();
    }
  }

  // Hiện thông báo lỗi
  void showError(String msg) {
    hideLoading();
    Get.snackbar("Lỗi", msg, backgroundColor: Colors.redAccent, colorText: Colors.white);
  }

  // Hàm bao bọc logic an toàn (Tự động try-catch)
  Future<void> safeCall(Future<void> Function() func) async {
    try {
      showLoading();
      await func();
      hideLoading();
    } catch (e) {
      showError(e.toString());
    }
  }
}