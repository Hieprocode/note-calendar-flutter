import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:note_calendar/data/repositories/customer_repository.dart';
import 'dart:async';
import '../../core/base/base_controller.dart';
import '../../data/models/booking_model.dart';
import '../../data/repositories/booking_repository.dart';
import '../booking/booking_controller.dart';
import '../../data/repositories/notification_repository.dart';
import '../../data/models/notification_model.dart';

class CalendarController extends BaseController {
  final BookingRepository _bookingRepo = Get.find<BookingRepository>();
  final NotificationRepository _notiRepo = Get.find<NotificationRepository>();
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
    try {
      await _bookingRepo.updateStatus(id, status);
      
      // ---> THÊM ĐOẠN NÀY: Ghi log thông báo
      String uid = FirebaseAuth.instance.currentUser?.uid ?? "";
      // Tìm booking hiện tại để lấy tên khách
      var booking = allBookings.firstWhereOrNull((b) => b.id == id);
      String clientName = booking?.customerName ?? "Khách hàng";

      NotificationModel noti = NotificationModel(
        shopId: uid,
        title: "Cập nhật trạng thái",
        body: "Đơn của $clientName đã: $status",
        type: status == 'cancelled' ? 'cancel_booking' : 'completed',
        isRead: false,
        createdAt: DateTime.now(),
      );
      _notiRepo.createNotification(noti);

      if (Get.isBottomSheetOpen == true) Get.back();
    } catch (e) {
      print("Lỗi update: $e");
    }
  }
  
  Future<void> deleteBooking(String id) async {
  try {
    // 1. LẤY BOOKING TRƯỚC KHI XÓA ĐỂ LẤY SỐ ĐIỆN THOẠI KHÁCH
    final bookingSnapshot = await _bookingRepo.getBookingById(id);
    if (bookingSnapshot == null) {
      Get.snackbar("Lỗi", "Không tìm thấy lịch hẹn");
      return;
    }

    final customerPhone = bookingSnapshot.customerPhone;

    // 2. XÓA BOOKING TRÊN FIRESTORE
    await _bookingRepo.deleteBooking(id);

    // 3. GIẢM totalBookings CỦA KHÁCH (QUAN TRỌNG NHẤT!)
    if (customerPhone.isNotEmpty) {
      await Get.find<CustomerRepository>().decrementBookingCount(customerPhone);
    }
    // 4. REALTIME TOÀN APP
    BookingController.triggerRefresh.value++;

    // 5. ĐÓNG BOTTOM SHEET + THÔNG BÁO
    if (Get.isBottomSheetOpen == true) Get.back();

    Get.rawSnackbar(
      message: "Đã xóa lịch hẹn thành công!",
      backgroundColor: Colors.red,
      snackPosition: SnackPosition.TOP,
      margin:  EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 2),
    );
  } catch (e) {
    Get.snackbar("Lỗi", "Không thể xóa lịch hẹn", backgroundColor: Colors.red);
  }
}
}