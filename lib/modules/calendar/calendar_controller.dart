import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import '../../core/base/base_controller.dart';
import '../../data/models/booking_model.dart';
import '../../data/repositories/booking_repository.dart';
import '../booking/booking_controller.dart';

class CalendarController extends BaseController {
  final BookingRepository _bookingRepo = Get.find<BookingRepository>();

  var allBookings = <BookingModel>[].obs;
  StreamSubscription? _bookingSubscription;

  var focusedDay = DateTime.now().obs;
  var selectedDay = DateTime.now().obs;

  @override
  void onInit() {
    super.onInit();
    _startListening();
    ever(BookingController.triggerRefresh, (_) {
      print("--> Calendar: Phát hiện thay đổi từ Booking → reconnect stream");
      _bookingSubscription?.cancel();
      _startListening(); // reconnect → nhận data mới nhất trong < 0.5s
    });
  
  }

  // void _startListening() {
  //   String uid = FirebaseAuth.instance.currentUser?.uid ?? "";
  //   _bookingSubscription?.cancel();
    
  //   // Nghe realtime
  //   _bookingSubscription = _bookingRepo.getBookingsStream(uid).listen((data) {
  //     allBookings.assignAll(data);
  //     allBookings.refresh();
  //     update(); // Cập nhật UI
  //   });
  // }

  void _startListening() {
    String uid = FirebaseAuth.instance.currentUser?.uid ?? "";
    if (uid.isEmpty) return;

    print("--> CALENDAR: Đang kết nối Stream...");

    // Hủy kết nối cũ nếu có (để tránh bị double)
    _bookingSubscription?.cancel();

    // Lắng nghe thủ công
    _bookingSubscription = _bookingRepo.getBookingsStream(uid).listen((data) {
      print("--> CALENDAR: Nhận được ${data.length} đơn (Có thay đổi!)");

      allBookings.assignAll(data);
      
      allBookings.refresh();
      
      update(); 
      
    }, onError: (e) {
      print("--> CALENDAR LỖI STREAM: $e");
    });
  }

  @override
  void onClose() {
    _bookingSubscription?.cancel();
    super.onClose();
  }

  // Logic lọc ngày
  List<BookingModel> getBookingsForDay(DateTime day) {
    return allBookings.where((b) => isSameDay(b.startTime, day)).toList();
  }

  bool isSameDay(DateTime? a, DateTime? b) {
    if (a == null || b == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  void onDaySelected(DateTime selected, DateTime focused) {
    selectedDay.value = selected;
    focusedDay.value = focused;
    update();
  }
  
  // Logic đổi trạng thái nhanh
  Future<void> updateStatus(String id, String status) async {
    await _bookingRepo.updateStatus(id, status);
    if (Get.isBottomSheetOpen == true) Get.back();
  }
  
  // Logic xóa nhanh
  Future<void> deleteBooking(String id) async {
    await _bookingRepo.deleteBooking(id);
    if (Get.isBottomSheetOpen == true) Get.back();
  }
}