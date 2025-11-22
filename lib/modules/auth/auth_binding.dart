import 'package:get/get.dart';
import 'auth_controller.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    // Khởi tạo AuthController ngay khi vào màn hình Login
    Get.lazyPut<AuthController>(() => AuthController());
  }
}