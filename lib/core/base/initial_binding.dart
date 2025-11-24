import 'package:get/get.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/services/storage_service.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // 1. Inject AuthRepository (Dùng chung toàn App)
    Get.put(AuthRepository(), permanent: true);

    // 2. Inject StorageService (Upload ảnh)
    Get.put(StorageService(), permanent: true);
  }
}