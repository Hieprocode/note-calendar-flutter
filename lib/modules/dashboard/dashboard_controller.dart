import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import '../../core/base/base_controller.dart';
import '../../data/models/shop_model.dart';
import '../../data/models/booking_model.dart';
import '../../data/models/service_model.dart';
import '../../data/repositories/shop_repository.dart';
import '../../data/repositories/booking_repository.dart';
import '../../data/repositories/service_repository.dart';
import '../booking/booking_controller.dart';

class DashboardController extends BaseController {
  final ShopRepository _shopRepo = Get.find<ShopRepository>();
  final BookingRepository _bookingRepo = Get.find<BookingRepository>();
  final ServiceRepository _serviceRepo = Get.find<ServiceRepository>();

  var currentTabIndex = 0.obs;
  var currentShop = Rxn<ShopModel>();
  var allServices = <ServiceModel>[].obs;

  // Biến thống kê
  var todayRevenue = 0.0.obs;
  var todayBookingCount = 0.obs;
  
  // Biến đếm theo status cho circular chart
  var completedCount = 0.obs;
  var confirmedCount = 0.obs;
  var checkedInCount = 0.obs;
  
  // Biến toggle giữa doanh thu và lịch hẹn (true = doanh thu, false = lịch hẹn)
  var showRevenue = true.obs;
  
  // Biến toggle giữa ngày và tháng (true = ngày, false = tháng)
  var showDay = true.obs;
  
  // Thống kê theo tháng
  var monthRevenue = 0.0.obs;
  var monthBookingCount = 0.obs;
  var monthCompletedCount = 0.obs;
  var monthConfirmedCount = 0.obs;
  var monthCheckedInCount = 0.obs;
  
  // Thống kê dịch vụ phổ biến
  var topServices = <String, int>{}.obs;
  var monthTopServices = <String, int>{}.obs;
  
  void toggleStatCard() {
    showRevenue.value = !showRevenue.value;
  }

  StreamSubscription? _statsSubscription;
  StreamSubscription? _servicesSubscription;

  @override
  void onInit() {
    super.onInit();
    print("--> DASHBOARD: onInit (Khởi tạo)");
    fetchShopProfile();
    _loadServices();
    _startListeningStats();
    debounce(BookingController.triggerRefresh, (_) {
    print("--> DASHBOARD: Reconnect stream sau thay đổi booking");
    _statsSubscription?.cancel();
    _startListeningStats();
  }, time: const Duration(milliseconds: 600));
  }

  // Gọi lại khi Tab Dashboard được chọn (để chắc chắn Stream còn sống)
  void onTabSelected() {
    if (_statsSubscription == null || _statsSubscription!.isPaused) {
      print("--> DASHBOARD: Kết nối lại Stream...");
      _startListeningStats();
    }
  }

  void changeTab(int index) {
    currentTabIndex.value = index;
    if (index == 0) { // Nếu quay về Tab Tổng quan
      onTabSelected();
    }
  }

  Future<void> fetchShopProfile() async {
    String uid = FirebaseAuth.instance.currentUser?.uid ?? "";
    if (uid.isNotEmpty) {
      currentShop.value = await _shopRepo.getShop(uid);
    }
  }

  void _loadServices() {
    String uid = FirebaseAuth.instance.currentUser?.uid ?? "";
    if (uid.isEmpty) return;
    
    _servicesSubscription = _serviceRepo.getServicesStream(uid).listen((services) {
      allServices.value = services;
      print("--> DASHBOARD: Loaded ${services.length} services");
    });
  }

  void _startListeningStats() {
    String uid = FirebaseAuth.instance.currentUser?.uid ?? "";
    
    if (uid.isEmpty) {
      print("--> DASHBOARD LỖI: UID rỗng, chưa đăng nhập!");
      return;
    }

    print("--> DASHBOARD: Đang lắng nghe dữ liệu cho Shop $uid");

    _statsSubscription?.cancel();

    _statsSubscription = _bookingRepo.getBookingsStream(uid).listen((bookings) {
      print("--> DASHBOARD: Nhận được ${bookings.length} đơn (Realtime)");
      _calculateStats(bookings);
    }, onError: (e) {
      print("--> DASHBOARD LỖI STREAM: $e");
    });
  }

  void _calculateStats(List<BookingModel> bookings) {
    final now = DateTime.now();
    
    print("\n========== DEBUG ALL BOOKINGS ==========");
    print("Tổng số bookings: ${bookings.length}");
    
    // Debug: In ra tất cả services trong database
    final allServiceCounts = <String, int>{};
    for (var b in bookings) {
      print("Booking #${b.id}: Service='${b.serviceName}' (ID: ${b.serviceId}), Status=${b.status}");
      if (b.status != 'cancelled' && b.serviceName.isNotEmpty) {
        allServiceCounts[b.serviceName] = (allServiceCounts[b.serviceName] ?? 0) + 1;
      }
    }
    
    print("\n--- TẤT CẢ SERVICES TRONG DATABASE ---");
    final sortedAll = allServiceCounts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    for (var entry in sortedAll) {
      print("  ${entry.key}: ${entry.value} lần");
    }
    print("========================================\n");
    
    // Lọc đơn HÔM NAY
    final todayList = bookings.where((b) {
      return b.startTime.year == now.year &&
             b.startTime.month == now.month &&
             b.startTime.day == now.day;
    }).toList();
    
    // Lọc đơn THÁNG NÀY
    final monthList = bookings.where((b) {
      return b.startTime.year == now.year &&
             b.startTime.month == now.month;
    }).toList();

    // Thống kê hôm nay
    int count = 0;
    double revenue = 0;
    int completed = 0;
    int confirmed = 0;
    int checkedIn = 0;

    for (var b in todayList) {
      if (b.status != 'cancelled') {
        count++;
        
        // Đếm theo status
        if (b.status == 'completed') {
          completed++;
          revenue += b.servicePrice;
        } else if (b.status == 'confirmed') {
          confirmed++;
        } else if (b.status == 'checked_in') {
          checkedIn++;
        }
      }
    }

    todayBookingCount.value = count;
    todayRevenue.value = revenue;
    completedCount.value = completed;
    confirmedCount.value = confirmed;
    checkedInCount.value = checkedIn;
    
    // Tính top services hôm nay - HOẶC dùng tất cả nếu hôm nay không có
    final todayServiceCounts = <String, int>{};
    for (var b in todayList) {
      if (b.status != 'cancelled' && b.serviceName.isNotEmpty) {
        todayServiceCounts[b.serviceName] = (todayServiceCounts[b.serviceName] ?? 0) + 1;
      }
    }
    
    // Nếu hôm nay không có service nào, dùng tất cả services
    final sortedToday = todayServiceCounts.isEmpty 
      ? Map.fromEntries(sortedAll)
      : Map.fromEntries(todayServiceCounts.entries.toList()..sort((a, b) => b.value.compareTo(a.value)));
    
    topServices.value = sortedToday;
    print("--> Top services hiển thị: ${sortedToday.length} dịch vụ");
    
    // Thống kê tháng này
    int monthCount = 0;
    double monthRev = 0;
    int monthComp = 0;
    int monthConf = 0;
    int monthCheck = 0;

    for (var b in monthList) {
      if (b.status != 'cancelled') {
        monthCount++;
        
        if (b.status == 'completed') {
          monthComp++;
          monthRev += b.servicePrice;
        } else if (b.status == 'confirmed') {
          monthConf++;
        } else if (b.status == 'checked_in') {
          monthCheck++;
        }
      }
    }

    monthBookingCount.value = monthCount;
    monthRevenue.value = monthRev;
    monthCompletedCount.value = monthComp;
    monthConfirmedCount.value = monthConf;
    monthCheckedInCount.value = monthCheck;
    
    // Tính top services tháng này - HOẶC dùng tất cả nếu tháng này không có
    final monthServiceCounts = <String, int>{};
    for (var b in monthList) {
      if (b.status != 'cancelled' && b.serviceName.isNotEmpty) {
        monthServiceCounts[b.serviceName] = (monthServiceCounts[b.serviceName] ?? 0) + 1;
      }
    }
    
    // Nếu tháng này không có service nào, dùng tất cả services
    final sortedMonth = monthServiceCounts.isEmpty
      ? Map.fromEntries(sortedAll)
      : Map.fromEntries(monthServiceCounts.entries.toList()..sort((a, b) => b.value.compareTo(a.value)));
    
    monthTopServices.value = sortedMonth;
    print("--> Top services tháng này: ${sortedMonth.length} dịch vụ");
    
    // Refresh biến Rx để chắc chắn UI vẽ lại
    todayRevenue.refresh();
    todayBookingCount.refresh();
    completedCount.refresh();
    confirmedCount.refresh();
    checkedInCount.refresh();
    monthRevenue.refresh();
    monthBookingCount.refresh();
    monthCompletedCount.refresh();
    monthConfirmedCount.refresh();
    monthCheckedInCount.refresh();
    topServices.refresh();
    monthTopServices.refresh();
    
    print("--> DASHBOARD CẬP NHẬT: $count khách - $revenue VNĐ | Completed: $completed, Confirmed: $confirmed, Checked-in: $checkedIn");
    print("--> DASHBOARD THÁNG: $monthCount khách - $monthRev VNĐ | Completed: $monthComp, Confirmed: $monthConf, Checked-in: $monthCheck");
  }

  @override
  void onClose() {
    print("--> DASHBOARD: onClose (Bị hủy)");
    _statsSubscription?.cancel();
    _servicesSubscription?.cancel();
    super.onClose();
  }
}