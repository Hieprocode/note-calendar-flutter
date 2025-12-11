import 'package:get/get.dart';
import 'package:note_calendar/data/repositories/customer_repository.dart';
import '../../data/repositories/shop_repository.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/services/storage_service.dart';
import '../../data/repositories/service_repository.dart';
import '../../data/repositories/booking_repository.dart';
import '../../data/repositories/notification_repository.dart';
import '../../data/services/notification_service.dart';
import '../../data/services/fcm_service.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(AuthRepository(), permanent: true);

    Get.put(StorageService(), permanent: true);

    Get.put(ShopRepository(), permanent: true);

    Get.put(ServiceRepository(), permanent: true);

    Get.put(BookingRepository(), permanent: true);

    Get.put(CustomerRepository(), permanent: true);

    Get.put(NotificationRepository(), permanent: true);

    Get.put(NotificationService(), permanent: true);
    
    // ✅ Khởi tạo FCMService
    Get.put(FCMService(), permanent: true);
    Get.find<FCMService>().init();
  }
}