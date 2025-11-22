import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';
import 'auth_controller.dart';

class AuthView extends GetView<AuthController> {
  const AuthView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Đăng Nhập")),
      // Dùng Stack để xếp chồng Loading lên trên cùng
      body: Stack(
        children: [
          // 1. Lớp nội dung chính
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Obx(() => controller.isOtpSent.value 
                ? _buildOtpForm() 
                : _buildPhoneForm()
            ),
          ),

          // 2. Lớp Loading (Chỉ hiện khi isLoading = true)
          Obx(() {
            if (controller.isLoading.value) {
              return Container(
                color: Colors.black54, // Màu nền mờ
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              );
            } else {
              return const SizedBox.shrink(); // Ẩn đi
            }
          }),
        ],
      ),
    );
  }

  // Form nhập SĐT
  Widget _buildPhoneForm() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.phone_android, size: 80, color: Colors.blue),
        const SizedBox(height: 20),
        TextField(
          controller: controller.phoneController,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            prefixText: "+84 ",
            labelText: "Số điện thoại",
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: () => controller.sendOtp(),
            child: const Text("Gửi mã"),
          ),
        ),
      ],
    );
  }

  // Form nhập OTP
  Widget _buildOtpForm() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.lock, size: 80, color: Colors.green),
        const SizedBox(height: 20),
        Text("Đã gửi mã đến +84 ${controller.phoneController.text}"),
        const SizedBox(height: 20),
        Pinput(
          length: 6,
          controller: controller.otpController,
          onCompleted: (pin) => controller.verifyOtp(),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: () => controller.verifyOtp(),
            child: const Text("Xác nhận"),
          ),
        ),
        TextButton(
          onPressed: () => controller.isOtpSent.value = false,
          child: const Text("Quay lại"),
        )
      ],
    );
  }
}