import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/base/base_controller.dart';
import '../../data/repositories/auth_repository.dart';
import '../../routes/app_routes.dart';

class AuthController extends BaseController {
  final AuthRepository _authRepo = Get.find<AuthRepository>();
  final phoneController = TextEditingController();
  final otpController = TextEditingController();

  var isOtpSent = false.obs; 

  void sendOtp() async {
    String phone = phoneController.text.trim();
    if (phone.isEmpty) return;

    if (phone.startsWith('0')) phone = phone.substring(1); 
    if (!phone.startsWith('+84')) phone = '+84$phone';

    // Ẩn bàn phím
    FocusManager.instance.primaryFocus?.unfocus();

    await safeCall(() async {
      await _authRepo.sendOTP(
        phone: phone,
        onCodeSent: (verificationId) {
          // Chỉ đổi trạng thái, KHÔNG hiện thông báo
          isOtpSent.value = true; 
          print("--> Đã chuyển sang nhập OTP");
        },
        onError: (msg) {
          handleError(msg);
        },
      );
    });
  }

  void verifyOtp() async {
    String otp = otpController.text.trim();
    if (otp.length != 6) return;

    FocusManager.instance.primaryFocus?.unfocus();

    await safeCall(() async {
      bool hasShop = await _authRepo.verifyOTP(otp);
      
      // Chuyển màn hình ngay lập tức
      if (hasShop) {
        Get.offAllNamed(AppRoutes.DASHBOARD);
      } else {
        Get.offAllNamed(AppRoutes.SETUP_SHOP);
      }
    });
  }
}