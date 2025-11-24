import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/base/base_controller.dart';
import '../../data/models/shop_model.dart';
import '../../data/repositories/shop_repository.dart';

class DashboardController extends BaseController {
  final ShopRepository _shopRepo = Get.find<ShopRepository>();
  
  // Biến quản lý Tab hiện tại (0: Home, 1: Calendar, 2: Services, 3: Settings)
  var currentTabIndex = 0.obs;

  // Biến lưu thông tin Shop để hiển thị lên Header
  var currentShop = Rxn<ShopModel>();

  @override
  void onInit() {
    super.onInit();
    fetchShopProfile();
  }

  void changeTab(int index) {
    currentTabIndex.value = index;
  }

  // Lấy thông tin Shop từ Firestore
  Future<void> fetchShopProfile() async {
    String uid = FirebaseAuth.instance.currentUser?.uid ?? "";
    if (uid.isEmpty) return;

    await safeCall(() async {
      var shop = await _shopRepo.getShop(uid);
      if (shop != null) {
        currentShop.value = shop;
      }
    });
  }
}