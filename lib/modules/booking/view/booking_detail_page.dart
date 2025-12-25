import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/booking_model.dart';
import '../../calendar/calendar_controller.dart';
import 'booking_detail_view.dart';

/// Trang chi tiết booking - dùng để navigate từ notification
/// Nhận bookingId từ arguments, tìm booking và hiển thị
class BookingDetailPage extends StatelessWidget {
  const BookingDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Lấy bookingId từ arguments
    final String? bookingId = Get.arguments as String?;
    
    if (bookingId == null || bookingId.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text('error_title'.tr)),
        body: Center(
          child: Text('booking_info_not_found'.tr),
        ),
      );
    }

    return FutureBuilder<BookingModel?>(
      future: _fetchBooking(bookingId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              title: Text('booking_details'.tr),
              backgroundColor: Colors.transparent,
              elevation: 0,
            ),
            extendBodyBehindAppBar: true,
            body: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFF0F4FF),
                    Color(0xFFFFFFFF),
                    Color(0xFFF8FAFF),
                  ],
                ),
              ),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }

        if (snapshot.hasError || snapshot.data == null) {
          return Scaffold(
            appBar: AppBar(
              title: Text('error_title'.tr),
              backgroundColor: Colors.transparent,
              elevation: 0,
            ),
            extendBodyBehindAppBar: true,
            body: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFF0F4FF),
                    Color(0xFFFFFFFF),
                    Color(0xFFF8FAFF),
                  ],
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.event_busy,
                      size: 64,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'booking_not_found'.tr,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.arrow_back),
                      label: Text('back'.tr),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4A90E2),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        // Hiển thị booking detail trong Scaffold thay vì BottomSheet
        final booking = snapshot.data!;
        return Scaffold(
          appBar: AppBar(
            title: Text('booking_details'.tr),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          extendBodyBehindAppBar: true,
          body: BookingDetailContent(booking: booking),
        );
      },
    );
  }

  /// Tìm booking từ bookingId trong CalendarController
  Future<BookingModel?> _fetchBooking(String bookingId) async {
    try {
      // Đợi một chút để đảm bảo CalendarController đã được khởi tạo
      await Future.delayed(const Duration(milliseconds: 300));
      
      final calendarCtrl = Get.find<CalendarController>();
      
      // Tìm booking trong danh sách
      final booking = calendarCtrl.allBookings.firstWhereOrNull(
        (b) => b.id == bookingId,
      );
      
      return booking;
    } catch (e) {
      print('Lỗi khi fetch booking: $e');
      return null;
    }
  }
}
