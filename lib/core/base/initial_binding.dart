import 'package:get/get.dart';
import '../../data/repositories/shop_repository.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/services/storage_service.dart';
import '../../data/repositories/service_repository.dart';
import '../../data/repositories/booking_repository.dart';
class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // 1. Inject AuthRepository (Dùng chung toàn App)
    Get.put(AuthRepository(), permanent: true);

    // 2. Inject StorageService (Upload ảnh)
    Get.put(StorageService(), permanent: true);

    // 3. Bạn có thể Inject thêm các Repository hoặc Service khác dùng chung toàn App ở đây
    Get.put(ShopRepository(), permanent: true);

    Get.put(ServiceRepository(), permanent: true);

    Get.put(BookingRepository(), permanent: true);
  }
}