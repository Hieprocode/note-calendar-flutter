// lib/modules/booking/views/booking_detail_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../data/models/booking_model.dart';
import '../view/add_booking_view.dart';
// Import CalendarController để dùng ké hàm updateStatus
import '../../calendar/calendar_controller.dart'; 
import '../booking_controller.dart';

class BookingDetailView extends StatelessWidget {
  final BookingModel booking;
  const BookingDetailView({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    // Lấy CalendarController đang s  ống ở màn hình dưới
    final calendarCtrl = Get.find<CalendarController>();

    return DraggableScrollableSheet(
      initialChildSize: 0.6, 
      maxChildSize: 0.9,
      expand: false,
      builder: (_, scrollController) => Container(
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Chi tiết đơn", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Get.back()),
              ],
            ),
            const Divider(),
            
            // Thông tin
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const CircleAvatar(child: Icon(Icons.person)),
              title: Text(booking.customerName, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(booking.customerPhone),
              trailing: Text(
                NumberFormat.currency(locale: 'vi', symbol: 'đ').format(booking.servicePrice),
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 16),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // NÚT SỬA (Chuyển sang màn hình AddBookingView với dữ liệu cũ)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Get.back(); // Đóng bảng chi tiết
                  Get.find<BookingController>().fillDataForEdit(booking);
                  Get.bottomSheet(
                    AddBookingView(),
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                  );
                },
                icon: const Icon(Icons.edit),
                label: const Text("Chỉnh sửa thông tin"),
              ),
            ),
            
            const SizedBox(height: 15),
            
            // NÚT TRẠNG THÁI
            Row(
              children: [
                Expanded(child: _actionBtn("Đã đến", Colors.orange, () => calendarCtrl.updateStatus(booking.id!, 'checked_in'))),
                const SizedBox(width: 10),
                Expanded(child: _actionBtn("Hoàn thành", Colors.green, () => calendarCtrl.updateStatus(booking.id!, 'completed'))),
              ],
            ),
            const SizedBox(height: 10),
            Center(
              child: TextButton(
                onPressed: () => calendarCtrl.deleteBooking(booking.id!),
                child: const Text("Xóa đơn này", style: TextStyle(color: Colors.red)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _actionBtn(String label, Color color, VoidCallback onTap) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(backgroundColor: color.withOpacity(0.1), foregroundColor: color, elevation: 0),
      child: Text(label),
    );
  }
}