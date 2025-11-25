// lib/modules/calendar/calendar_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/base/base_controller.dart';
import '../../data/models/booking_model.dart';
import '../../data/repositories/booking_repository.dart';
import 'widgets/add_booking_sheet.dart';

class CalendarController extends BaseController {
  final BookingRepository _bookingRepo = Get.find<BookingRepository>();

  var allBookings = <BookingModel>[].obs;
  var focusedDay = DateTime.now().obs;
  var selectedDay = DateTime.now().obs;

  @override
  void onInit() {
    super.onInit();
    final uid = FirebaseAuth.instance.currentUser?.uid ?? "";
    allBookings.bindStream(_bookingRepo.getBookingsStream(uid));
  }

  void onDaySelected(DateTime selected, DateTime focused) {
    selectedDay.value = selected;
    focusedDay.value = focused;
  }

  List<BookingModel> getBookingsForDay(DateTime day) {
    return allBookings.where((b) => isSameDay(b.startTime, day)).toList();
  }

  bool isSameDay(DateTime? a, DateTime? b) {
    if (a == null || b == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  void showAddBookingSheet() {
    Get.bottomSheet(
      const AddBookingBottomSheet(),
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    );
  }
}