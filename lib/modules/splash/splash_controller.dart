import 'dart:async';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/shop_repository.dart';
import '../../data/services/fcm_service.dart';
import '../../routes/app_routes.dart';

class SplashController extends GetxController {
  final AuthRepository _authRepo = Get.find<AuthRepository>();
  final ShopRepository _shopRepo = Get.find<ShopRepository>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription<User?>? _authSubscription;

  @override
  void onReady() {
    super.onReady();
    print("--> SPLASH: Bắt đầu chạy...");
    _checkLoginStatus();
  }

  @override
  void onClose() {
    _authSubscription?.cancel();
    super.onClose();
  }

  Future<void> _checkLoginStatus() async {
    try {
      print("--> SPLASH: Bắt đầu check login status...");

      // ✅ CHỜ Firebase Auth initialization hoàn tất
      // Tăng timeout và số lần thử để đảm bảo restore session
      User? user;

      for (int attempt = 0; attempt < 20; attempt++) {
        user = FirebaseAuth.instance.currentUser;

        if (user != null) {
          print(
            "✅ SPLASH: Tìm thấy user sau ${attempt} lần thử - ${user.email ?? user.phoneNumber ?? user.uid}",
          );
          break;
        }

        // Tăng thời gian chờ mỗi lần thử lên 300ms (tổng max: 20 * 300ms = 6s)
        if (attempt < 19) {
          await Future.delayed(const Duration(milliseconds: 300));
        }
      }

      print(
        "--> SPLASH: Kết quả cuối cùng: ${user?.email ?? user?.phoneNumber ?? 'null'} (${user?.uid ?? 'no uid'})",
      );

      if (user == null) {
        print("⚠️ SPLASH: Không có user -> LOGIN");
        Get.offAllNamed(AppRoutes.LOGIN);
        return;
      }

      print(
        "✅ SPLASH: User đăng nhập: ${user.email ?? user.phoneNumber} (${user.uid})",
      );
      print("--> SPLASH: Kiểm tra thông tin user trong Firestore...");

      // Kiểm tra user tồn tại trong Firestore
      try {
        final userDoc = await _firestore
            .collection('users')
            .doc(user.uid)
            .get();

        if (!userDoc.exists) {
          print("⚠️ SPLASH: User không tồn tại trong Firestore");
          await _authRepo.logout();
          Get.offAllNamed(AppRoutes.LOGIN);
          return;
        }

        final userData = userDoc.data();

        // ✅ SỬA: Xử lý authProvider an toàn hơn
        // Nếu không có authProvider, coi như đã verified (backward compatibility)
        final authProvider = userData?['authProvider'] as String? ?? 'unknown';
        final emailVerified = userData?['emailVerified'] as bool? ?? false;

        print(
          "📋 SPLASH: Auth Provider: $authProvider, Email Verified: $emailVerified",
        );

        // Kiểm tra verification dựa trên authProvider
        if (authProvider == 'firebase_phone') {
          // Đăng nhập bằng Phone -> đã verify qua OTP -> OK
          print("✅ SPLASH: Phone Auth - đã verify");
        } else if (authProvider == 'google' || authProvider == 'facebook') {
          // Đăng nhập bằng Google/Facebook -> đã verify bởi provider -> OK
          print("✅ SPLASH: Social Auth ($authProvider) - đã verify");
        } else if (authProvider == 'email') {
          // Đăng nhập bằng Email -> kiểm tra emailVerified
          if (!emailVerified) {
            print("⚠️ SPLASH: Email chưa xác minh");
            await _authRepo.logout();
            Get.offAllNamed(AppRoutes.LOGIN);
            return;
          }
          print("✅ SPLASH: Email đã xác minh");
        } else {
          // Unknown provider hoặc không có authProvider
          // Giữ nguyên logic cũ: kiểm tra emailVerified
          if (!emailVerified && authProvider != 'unknown') {
            print("⚠️ SPLASH: Chưa xác minh (provider: $authProvider)");
            await _authRepo.logout();
            Get.offAllNamed(AppRoutes.LOGIN);
            return;
          }
          print("✅ SPLASH: Verified hoặc backward compatibility");
        }
      } catch (e) {
        print("❌ SPLASH: Lỗi kiểm tra Firestore: $e");
        await _authRepo.logout();
        Get.offAllNamed(AppRoutes.LOGIN);
        return;
      }

      print("--> SPLASH: Kiểm tra Shop...");

      // Kiểm tra Shop
      var shop = await _shopRepo.getShop(user.uid);

      if (shop != null) {
        print("✅ SPLASH: User có shop -> DASHBOARD");
        Get.offAllNamed(AppRoutes.DASHBOARD);

        // Xử lý pending notification
        try {
          final fcmService = Get.find<FCMService>();
          fcmService.processPendingMessage();
        } catch (e) {
          print("⚠️ SPLASH: Không tìm thấy FCMService: $e");
        }
      } else {
        print("⚠️ SPLASH: User chưa có shop -> SETUP_SHOP");
        Get.offAllNamed(AppRoutes.SETUP_SHOP);
      }
    } catch (e, stacktrace) {
      print("❌ SPLASH: LỖI NGHIÊM TRỌNG - $e");
      print("Stacktrace: $stacktrace");
      Get.offAllNamed(AppRoutes.LOGIN);
    }
  }
}
