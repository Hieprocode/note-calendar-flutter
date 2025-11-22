import 'package:get/get.dart';

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

