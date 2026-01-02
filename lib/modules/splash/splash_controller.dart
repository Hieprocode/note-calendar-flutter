import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/shop_repository.dart';
import '../../data/services/fcm_service.dart';
import '../../routes/app_routes.dart';

class SplashController extends GetxController {
  // Dùng Get.find để lấy Repo đã khởi tạo ở InitialBinding
  final AuthRepository _authRepo = Get.find<AuthRepository>();
  final ShopRepository _shopRepo = Get.find<ShopRepository>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void onReady() {
    super.onReady();
    print("--> SPLASH: Bắt đầu chạy...");
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    try {
      print("--> SPLASH: Đang chờ 2 giây...");
      await Future.delayed(const Duration(seconds: 2));

      // 1. Kiểm tra User
      print("--> SPLASH: Đang lấy User...");
      var user = _authRepo.currentUser; 

      if (user == null) {
        print("--> SPLASH: Chưa đăng nhập -> Chuyển sang LOGIN");
        Get.offAllNamed(AppRoutes.LOGIN);
        return;
      }
      
      print("--> SPLASH: User ID: ${user.uid}. Đang kiểm tra email verification...");
      
      // 1.5. Kiểm tra email đã xác minh chưa (từ Firestore, không dùng Firebase Auth emailVerified)
      try {
        final userDoc = await _firestore.collection('users').doc(user.uid).get();
        
        if (!userDoc.exists) {
          print("--> SPLASH: Không tìm thấy user trong Firestore -> Đăng xuất");
          await _authRepo.logout();
          Get.offAllNamed(AppRoutes.LOGIN);
          return;
        }
        
        final userData = userDoc.data();
        final emailVerified = userData?['emailVerified'] as bool? ?? false;
        
        if (!emailVerified) {
          print("--> SPLASH: Email chưa xác minh (Firestore) -> Đăng xuất");
          await _authRepo.logout();
          Get.offAllNamed(AppRoutes.LOGIN);
          return;
        }
      } catch (e) {
        print("--> SPLASH: Lỗi kiểm tra verification: $e");
        await _authRepo.logout();
        Get.offAllNamed(AppRoutes.LOGIN);
        return;
      }
      
      print("--> SPLASH: Email đã xác minh. Đang kiểm tra Shop...");
      
      // 2. Kiểm tra Shop
      var shop = await _shopRepo.getShop(user.uid);
      
      if (shop != null) {
        print("--> SPLASH: Đã có Shop -> Chuyển sang DASHBOARD");
        Get.offAllNamed(AppRoutes.DASHBOARD);
        
        // Xử lý pending notification nếu có (app mở từ notification khi đã tắt)
        try {
          final fcmService = Get.find<FCMService>();
          fcmService.processPendingMessage();
        } catch (e) {
          print("--> SPLASH: Không tìm thấy FCMService: $e");
        }
      } else {
        print("--> SPLASH: Chưa có Shop -> Chuyển sang SETUP_SHOP");
        Get.offAllNamed(AppRoutes.SETUP_SHOP);
      }
    } catch (e, stacktrace) {
      // Bắt lỗi và in ra
      print("--> SPLASH LỖI NGHIÊM TRỌNG: $e");
      print("--> Stacktrace: $stacktrace");
      
      // Nếu lỗi quá nặng, chuyển tạm về Login để không bị kẹt
      Get.offAllNamed(AppRoutes.LOGIN);
    }
  }
}