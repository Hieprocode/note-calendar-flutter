import 'package:get/get.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../core/widgets/custom_dialog.dart';
import '../../../routes/app_routes.dart';
import 'dart:async';

class VerifyOtpController extends GetxController {
  final AuthRepository _authRepo = Get.find<AuthRepository>();

  // Parameters từ màn hình trước
  late String email;
  late String fullName;
  late String password;
  late String userId;
  
  // Phone auth parameters
  String? phoneNumber;
  bool isPhoneAuth = false;

  // OTP controllers (6 ô input)
  final otp1 = ''.obs;
  final otp2 = ''.obs;
  final otp3 = ''.obs;
  final otp4 = ''.obs;
  final otp5 = ''.obs;
  final otp6 = ''.obs;

  // Countdown timer
  var countdown = 60.obs;
  var canResend = false.obs;
  Timer? _timer;

  @override
  void onInit() {
    super.onInit();

    // Kiểm tra xem có phải phone auth không
    isPhoneAuth = Get.arguments['isPhoneAuth'] as bool? ?? false;

    if (isPhoneAuth) {
      // Phone authentication
      phoneNumber = Get.arguments['phoneNumber'] as String;
      email = '';
      fullName = '';
      password = '';
      userId = '';
    } else {
      // Email authentication (cũ)
      email = Get.arguments['email'] as String;
      fullName = Get.arguments['fullName'] as String;
      password = Get.arguments['password'] as String;
      userId = Get.arguments['userId'] as String;
    }

    startCountdown();
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  void startCountdown() {
    countdown.value = 60;
    canResend.value = false;

    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (countdown.value > 0) {
        countdown.value--;
      } else {
        canResend.value = true;
        timer.cancel();
      }
    });
  }

  Future<void> verifyOTP() async {
    // Ghép OTP từ 6 ô
    final otpCode =
        otp1.value +
        otp2.value +
        otp3.value +
        otp4.value +
        otp5.value +
        otp6.value;

    if (otpCode.length != 6) {
      CustomDialog.showWarning(
        'Vui lòng nhập đầy đủ 6 số mã xác thực',
        title: 'Chưa đủ mã OTP',
      );
      return;
    }

    try {
      if (isPhoneAuth) {
        // Phone authentication với Supabase
        bool hasShop = await _authRepo.verifyPhoneOTP(
          phoneNumber: phoneNumber!,
          otpCode: otpCode,
        );

        CustomDialog.showSuccess(
          'Xác thực thành công!',
          title: '🎉 Đăng nhập thành công',
        );

        await Future.delayed(Duration(seconds: 1));

        if (hasShop) {
          Get.offAllNamed(AppRoutes.DASHBOARD);
        } else {
          Get.offAllNamed(AppRoutes.SETUP_SHOP);
        }
      } else {
        // Email authentication với Firebase (cũ)
        bool success = await _authRepo.verifyOTP(
          userId: userId,
          otpCode: otpCode,
        );

        if (success) {
          CustomDialog.showSuccess(
            'Email đã được xác thực thành công!',
            title: '🎉 Xác thực thành công',
          );

          await Future.delayed(Duration(seconds: 1));

          // Kiểm tra xem đã có shop chưa
          final shopDoc = await _authRepo.firestore
              .collection('shops')
              .doc(userId)
              .get();

          if (shopDoc.exists) {
            Get.offAllNamed(AppRoutes.DASHBOARD);
          } else {
            Get.offAllNamed(AppRoutes.SETUP_SHOP);
          }
        }
      }
    } catch (e) {
      if (isPhoneAuth) {
        // Phone auth error - không cần logout Supabase
        CustomDialog.showError(e.toString(), title: 'Xác thực thất bại');
      } else {
        // Email auth error - sign out user và quay về login
        await _authRepo.logout();
        CustomDialog.showError(e.toString(), title: 'Xác thực thất bại');
        await Future.delayed(Duration(seconds: 2));
        Get.back(); // Về màn login
      }
    }
  }

  Future<void> resendOTP() async {
    if (!canResend.value) {
      CustomDialog.showWarning(
        'Vui lòng đợi ${countdown.value}s trước khi gửi lại',
        title: 'Vui lòng đợi',
      );
      return;
    }

    try {
      if (isPhoneAuth) {
        // Resend phone OTP với Supabase
        await _authRepo.signInWithPhone(phoneNumber!);

        CustomDialog.showInfo(
          'Mã xác thực mới đã được gửi đến số điện thoại của bạn',
          title: '📱 Đã gửi lại OTP',
        );
      } else {
        // Resend email OTP
        await _authRepo.resendOTP(
          userId: userId,
          email: email,
          fullName: fullName,
        );

        CustomDialog.showInfo(
          'Mã xác thực mới đã được gửi đến email của bạn',
          title: '📧 Đã gửi lại OTP',
        );
      }

      // Reset OTP fields
      otp1.value = '';
      otp2.value = '';
      otp3.value = '';
      otp4.value = '';
      otp5.value = '';
      otp6.value = '';

      startCountdown();
    } catch (e) {
      CustomDialog.showError(e.toString(), title: 'Gửi lại thất bại');
    }
  }
}
