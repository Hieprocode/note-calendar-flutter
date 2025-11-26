import 'package:get/get.dart';
import 'dashboard_controller.dart';

// Import thêm Controller của các module con để khởi tạo luôn
import '../services/services_controller.dart';
import '../settings/settings_controller.dart';
import '../calendar/calendar_controller.dart'; 
import '../booking/booking_controller.dart';

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DashboardController>(() => DashboardController(), fenix: true);
    
    // Khởi tạo sẵn Controller của các tab con để chuyển tab là có dữ liệu ngay
    Get.lazyPut(() => CalendarController());
    Get.lazyPut(() => ServicesController()); // (Bạn cần tạo file này rỗng trước hoặc tạm comment lại)
    Get.lazyPut(() => SettingsController()); // (Tương tự)
    Get.lazyPut<BookingController>(() => BookingController(), fenix: true);
  }
}