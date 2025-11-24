import 'package:get/get.dart';
import 'package:flutter/material.dart';

class BaseController extends GetxController {
  // Chỉ dùng biến này để kiểm soát trạng thái
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  void showLoading() => isLoading.value = true;
  void hideLoading() => isLoading.value = false;

  // Chỉ dùng để set lỗi, View sẽ tự hiện
  void handleError(dynamic error) {
    hideLoading();
    errorMessage.value = error.toString();
    print("Lỗi System: $error");
    
    // Dùng rawSnackbar để an toàn hơn
    if (Get.context != null) {
      Get.rawSnackbar(message: "Lỗi: $error");
    }
  }

void showSuccess(String msg) {
    hideLoading();
    if (Get.context != null) {
      Get.rawSnackbar(
        title: "Thành công",
        message: msg,
        backgroundColor: Colors.green,
        icon: const Icon(Icons.check_circle, color: Colors.white),
        snackPosition: SnackPosition.BOTTOM,
        borderRadius: 10,
        margin: const EdgeInsets.all(10),
      );
    }
  }

void showError(String message) {
    handleError(message);
  }

  Future<void> safeCall(Future<void> Function() func) async {
    try {
      showLoading();
      await func();
      hideLoading();
    } catch (e) {
      handleError(e);
    }
  }

  
}

