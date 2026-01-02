import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../core/config/app_colors.dart';
import 'verify_otp_controller.dart';

class VerifyOtpView extends GetView<VerifyOtpController> {
  const VerifyOtpView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Icon
              Obx(() => Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryLight],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  controller.isPhoneAuth ? Icons.phone_android : Icons.mail_outline, 
                  size: 60, 
                  color: Colors.white,
                ),
              )),

              const SizedBox(height: 32),

              // Title
              Obx(() => Text(
                controller.isPhoneAuth ? 'Xác thực Số điện thoại' : 'Xác thực Email',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              )),

              const SizedBox(height: 12),

              // Subtitle
              Obx(() => Text(
                'Nhập mã 6 số đã được gửi đến',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
              )),

              const SizedBox(height: 8),

              Obx(() => Text(
                controller.isPhoneAuth ? controller.phoneNumber ?? '' : controller.email,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              )),

              const SizedBox(height: 40),

              // OTP Input Fields (6 ô)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildOtpBox(controller.otp1, true),
                  _buildOtpBox(controller.otp2, false),
                  _buildOtpBox(controller.otp3, false),
                  _buildOtpBox(controller.otp4, false),
                  _buildOtpBox(controller.otp5, false),
                  _buildOtpBox(controller.otp6, false),
                ],
              ),

              const SizedBox(height: 40),

              // Verify Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: controller.verifyOTP,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Xác thực',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Resend OTP
              Obx(() {
                if (controller.canResend.value) {
                  return TextButton(
                    onPressed: controller.resendOTP,
                    child: Text(
                      'Gửi lại mã xác thực',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  );
                } else {
                  return Text(
                    'Gửi lại sau ${controller.countdown.value}s',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  );
                }
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOtpBox(RxString otpDigit, bool autoFocus) {
    final focusNode = FocusNode();

    return Container(
      width: 50,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: otpDigit.value.isEmpty
              ? Colors.grey.shade300
              : AppColors.primary,
          width: 2,
        ),
      ),
      child: TextField(
        focusNode: focusNode,
        autofocus: autoFocus,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(counterText: '', border: InputBorder.none),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onChanged: (value) {
          otpDigit.value = value;
          if (value.isNotEmpty) {
            // Tự động chuyển focus sang ô tiếp theo
            FocusScope.of(Get.context!).nextFocus();
          } else {
            // Nếu xóa, quay lại ô trước
            FocusScope.of(Get.context!).previousFocus();
          }
        },
      ),
    );
  }
}
