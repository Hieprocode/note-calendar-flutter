import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/base/base_controller.dart';
import '../../data/models/booking_model.dart';
import '../../data/repositories/booking_repository.dart';

class CalendarController extends BaseController {
  final BookingRepository _bookingRepo = Get.find<BookingRepository>();

  // Danh sách TẤT CẢ booking (Dữ liệu thô)
  var allBookings = <BookingModel>[].obs;

  // Biến cho TableCalendar
  var focusedDay = DateTime.now().obs;
  var selectedDay = DateTime.now().obs;

  @override
  void onInit() {
    super.onInit();
    String uid = FirebaseAuth.instance.currentUser?.uid ?? "";
    // Lắng nghe dữ liệu Realtime
    allBookings.bindStream(_bookingRepo.getBookingsStream(uid));
  }

  // Hàm khi người dùng bấm chọn ngày trên lịch
  void onDaySelected(DateTime selected, DateTime focused) {
    selectedDay.value = selected;
    focusedDay.value = focused;
  }

  // Hàm lọc booking theo ngày cụ thể (Để hiện list bên dưới lịch)
  List<BookingModel> getBookingsForDay(DateTime day) {
    return allBookings.where((booking) {
      return isSameDay(booking.startTime, day);
    }).toList();
  }

  // Hàm tiện ích so sánh ngày (Bỏ qua giờ phút)
  bool isSameDay(DateTime? a, DateTime? b) {
    if (a == null || b == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}