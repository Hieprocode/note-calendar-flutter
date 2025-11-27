import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import '../../core/base/base_controller.dart';
import '../../data/models/shop_model.dart';
import '../../data/models/booking_model.dart';
import '../../data/repositories/shop_repository.dart';
import '../../data/repositories/booking_repository.dart';
import '../booking/booking_controller.dart';

class DashboardController extends BaseController {
  final ShopRepository _shopRepo = Get.find<ShopRepository>();
  final BookingRepository _bookingRepo = Get.find<BookingRepository>();

  var currentTabIndex = 0.obs;
  var currentShop = Rxn<ShopModel>();

  // Biến thống kê
  var todayRevenue = 0.0.obs;
  var todayBookingCount = 0.obs;

  StreamSubscription? _statsSubscription;

  @override
  void onInit() {
    super.onInit();
    print("--> DASHBOARD: onInit (Khởi tạo)");
    fetchShopProfile();
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
    
    // Lọc đơn HÔM NAY
    final todayList = bookings.where((b) {
      return b.startTime.year == now.year &&
             b.startTime.month == now.month &&
             b.startTime.day == now.day;
    }).toList();

    int count = 0;
    double revenue = 0;

    for (var b in todayList) {
      if (b.status != 'cancelled') {
        count++;
        revenue += b.servicePrice;
      }
    }

    todayBookingCount.value = count;
    todayRevenue.value = revenue;
    
    // Refresh biến Rx để chắc chắn UI vẽ lại
    todayRevenue.refresh();
    todayBookingCount.refresh();
    
    print("--> DASHBOARD CẬP NHẬT: $count khách - $revenue VNĐ");
  }

  @override
  void onClose() {
    print("--> DASHBOARD: onClose (Bị hủy)");
    _statsSubscription?.cancel();
    super.onClose();
  }
}