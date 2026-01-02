import 'package:get/get.dart';
import '../widgets/custom_dialog.dart';

class BaseController extends GetxController {
  // Chỉ dùng biến này để kiểm soát trạng thái
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  void showLoading() => isLoading.value = true;
  void hideLoading() => isLoading.value = false;

  // Hiển thị lỗi cho người dùng bằng Dialog
  void handleError(dynamic error) {
    hideLoading();
    String errorMsg = error.toString();
    errorMessage.value = errorMsg;
    
    print("❌ [Error] $errorMsg");
    
    // Hiển thị popup lỗi, tự động đóng sau 3s
    CustomDialog.showError(errorMsg);
  }

  void showSuccess(String msg) {
    hideLoading();
    CustomDialog.showSuccess(msg);
  }
  
  void showWarning(String msg) {
    hideLoading();
    CustomDialog.showWarning(msg);
  }
  
  void showInfo(String msg) {
    hideLoading();
    CustomDialog.showInfo(msg);
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

