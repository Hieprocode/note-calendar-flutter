import 'package:get/get.dart';
import 'setup_shop_controller.dart';

class SetupShopBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SetupShopController());
  }
}