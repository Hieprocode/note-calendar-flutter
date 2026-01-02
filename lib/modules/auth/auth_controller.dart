import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/base/base_controller.dart';
import '../../core/widgets/custom_dialog.dart';
import '../../data/repositories/auth_repository.dart';
import '../../routes/app_routes.dart';

class AuthController extends BaseController {
  final AuthRepository _authRepo = Get.find<AuthRepository>();

  // Email/Password login fields
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // Signup fields
  final confirmPasswordController = TextEditingController();
  final fullNameController = TextEditingController();
  final phoneController = TextEditingController();

  var isPasswordVisible = false.obs;
  var isConfirmPasswordVisible = false.obs;
  var isLoginMode = true.obs; // true: Đăng nhập, false: Đăng ký
  var selectedGender = 'Nam'.obs; // Nam, Nữ, Khác
  var selectedDate = Rx<DateTime?>(null);

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    fullNameController.dispose();
    phoneController.dispose();
    super.onClose();
  }

  // Toggle hiện/ẩn mật khẩu
  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;
  }

  // Toggle giữa đăng nhập và đăng ký
  void toggleAuthMode() {
    isLoginMode.value = !isLoginMode.value;
    // Clear signup fields when switching
    if (isLoginMode.value) {
      confirmPasswordController.clear();
      fullNameController.clear();
      phoneController.clear();
      selectedDate.value = null;
    }
  }

  // Chọn giới tính
  void selectGender(String gender) {
    selectedGender.value = gender;
  }

  // Chọn ngày sinh
  void selectDate(DateTime date) {
    selectedDate.value = date;
  }

  // Đăng nhập hoặc Đăng ký (Email/Password - BỎ OTP)
  void authenticate() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    print(
      '📧 [authenticate] Email: "$email", Mode: ${isLoginMode.value ? "Login" : "SignUp"}',
    );

    if (email.isEmpty || password.isEmpty) {
      CustomDialog.showWarning(
        'Vui lòng nhập đầy đủ email và mật khẩu',
        title: 'Thiếu thông tin',
      );
      return;
    }

    // Validate email
    if (!GetUtils.isEmail(email)) {
      CustomDialog.showWarning(
        'Vui lòng nhập đúng định dạng email (vd: example@gmail.com)',
        title: 'Email không hợp lệ',
      );
      return;
    }

    // Validate password length
    if (password.length < 6) {
      CustomDialog.showWarning(
        'Mật khẩu phải có ít nhất 6 ký tự để đảm bảo an toàn',
        title: 'Mật khẩu quá ngắn',
      );
      return;
    }

    // Validate signup fields
    if (!isLoginMode.value) {
      String confirmPassword = confirmPasswordController.text.trim();
      String fullName = fullNameController.text.trim();
      String phone = phoneController.text.trim();

      if (password != confirmPassword) {
        CustomDialog.showWarning(
          'Mật khẩu và xác nhận mật khẩu phải giống nhau',
          title: 'Mật khẩu không khớp',
        );
        return;
      }

      if (fullName.isEmpty || phone.isEmpty) {
        CustomDialog.showWarning(
          'Vui lòng điền đầy đủ: Họ tên và Số điện thoại',
          title: 'Thiếu thông tin',
        );
        return;
      }

      if (phone.length < 10) {
        CustomDialog.showWarning(
          'Số điện thoại phải có ít nhất 10 chữ số',
          title: 'Số điện thoại không hợp lệ',
        );
        return;
      }

      if (selectedDate.value == null) {
        CustomDialog.showWarning(
          'Vui lòng chọn ngày sinh của bạn',
          title: 'Chưa chọn ngày sinh',
        );
        return;
      }
    }

    // Ẩn bàn phím
    FocusManager.instance.primaryFocus?.unfocus();

    await safeCall(() async {
      if (isLoginMode.value) {
        // Đăng nhập - BỎ OTP, đăng nhập trực tiếp
        print('🔐 [authenticate] Đăng nhập...');
        bool hasShop = await _authRepo.signInWithEmailDirectly(
          email: email,
          password: password,
        );

        print('✅ [authenticate] Thành công - hasShop: $hasShop');

        // Chuyển màn hình
        if (hasShop) {
          Get.offAllNamed(AppRoutes.DASHBOARD);
        } else {
          Get.offAllNamed(AppRoutes.SETUP_SHOP);
        }
      } else {
        // Đăng ký - BỎ OTP, tạo tài khoản và shop luôn
        print('📝 [authenticate] Đăng ký tài khoản mới...');
        bool hasShop = await _authRepo.signUpWithEmailDirectly(
          email: email,
          password: password,
          fullName: fullNameController.text.trim(),
          phone: phoneController.text.trim(),
          dateOfBirth: selectedDate.value!,
          gender: selectedGender.value,
        );

        print('✅ [authenticate] Đăng ký thành công');

        CustomDialog.showSuccess(
          'Tài khoản đã được tạo thành công!',
          title: '🎉 Chào mừng',
        );

        await Future.delayed(Duration(seconds: 1));

        // Chuyển màn hình
        if (hasShop) {
          Get.offAllNamed(AppRoutes.DASHBOARD);
        } else {
          Get.offAllNamed(AppRoutes.SETUP_SHOP);
        }

        // Clear fields
        emailController.clear();
        passwordController.clear();
        confirmPasswordController.clear();
        fullNameController.clear();
        phoneController.clear();
        selectedDate.value = null;
      }
    });
  }

  // Đăng nhập bằng Google
  void signInWithGoogle() async {
    print('🔵 [signInWithGoogle] Bắt đầu...');

    await safeCall(() async {
      bool hasShop = await _authRepo.signInWithGoogle();

      print('✅ [signInWithGoogle] Thành công - hasShop: $hasShop');

      // Chuyển màn hình
      if (hasShop) {
        Get.offAllNamed(AppRoutes.DASHBOARD);
      } else {
        Get.offAllNamed(AppRoutes.SETUP_SHOP);
      }
    });
  }

  // Đăng nhập bằng Facebook
  void signInWithFacebook() async {
    print('🔵 [signInWithFacebook] Bắt đầu...');

    await safeCall(() async {
      bool hasShop = await _authRepo.signInWithFacebook();

      print('✅ [signInWithFacebook] Thành công - hasShop: $hasShop');

      // Chuyển màn hình
      if (hasShop) {
        Get.offAllNamed(AppRoutes.DASHBOARD);
      } else {
        Get.offAllNamed(AppRoutes.SETUP_SHOP);
      }
    });
  }
}
