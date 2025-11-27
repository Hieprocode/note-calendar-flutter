// lib/modules/booking/views/booking_detail_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../data/models/booking_model.dart';
import '../view/add_booking_view.dart';
import '../../calendar/calendar_controller.dart'; 
import '../booking_controller.dart';

class BookingDetailView extends StatelessWidget {
  final BookingModel booking;
  const BookingDetailView({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    final calendarCtrl = Get.find<CalendarController>();

    // DÒNG QUAN TRỌNG NHẤT: Theo dõi triggerRefresh → rebuild toàn bộ Detail
    return Obx(() {
      // Khi triggerRefresh thay đổi → ép rebuild để lấy dữ liệu mới nhất từ Firestore
      BookingController.triggerRefresh.value;

      // Lấy booking mới nhất từ danh sách realtime của CalendarController
      final updatedBooking = calendarCtrl.allBookings
          .firstWhereOrNull((b) => b.id == booking.id) ?? booking;

      return DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        expand: false,
        builder: (_, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
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

              // Thông tin khách
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: Text(updatedBooking.customerName, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(updatedBooking.customerPhone),
                trailing: Text(
                  NumberFormat.currency(locale: 'vi', symbol: 'đ').format(updatedBooking.servicePrice),
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 16),
                ),
              ),

              const SizedBox(height: 20),

              // NÚT SỬA
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Get.back();
                    Get.find<BookingController>().fillDataForEdit(updatedBooking);
                    Get.bottomSheet(
                      const AddBookingView(),
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                    );
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text("Chỉnh sửa thông tin"),
                ),
              ),

              const SizedBox(height: 15),

              // NÚT TRẠNG THÁI – TỰ ĐỘNG ĐỔI MÀU KHI BẤM
              Row(
                children: [
                  Expanded(
                    child: _actionBtn(
                      "Đã đến",
                      updatedBooking.status == 'checked_in' ? Colors.orange : Colors.grey,
                      () => calendarCtrl.updateStatus(updatedBooking.id!, 'checked_in'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _actionBtn(
                      "Hoàn thành",
                      updatedBooking.status == 'completed' ? Colors.green : Colors.grey,
                      () => calendarCtrl.updateStatus(updatedBooking.id!, 'completed'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Center(
                child: TextButton(
                  onPressed: () => _showDeleteConfirm(context, calendarCtrl, updatedBooking.id!),
                  child: const Text("Xóa đơn này", style: TextStyle(color: Colors.red)),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _actionBtn(String label, Color color, VoidCallback onTap) {
    return ElevatedButton(
      onPressed: () async {
         onTap();
        // Trigger rebuild ngay lập tức
        BookingController.triggerRefresh.value++;
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(color == Colors.grey ? 0.1 : 0.2),
        foregroundColor: color == Colors.grey ? Colors.grey[600] : color,
        elevation: 0,
      ),
      child: Text(label, style: TextStyle(fontWeight: color != Colors.grey ? FontWeight.bold : FontWeight.normal)),
    );
  }

  void _showDeleteConfirm(BuildContext context, CalendarController ctrl, String id) {
    Get.dialog(
      AlertDialog(
        title: const Text("Xóa lịch hẹn?"),
        content: const Text("Bạn chắc chắn muốn xóa đơn này?"),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("Hủy")),
          TextButton(
            onPressed: () async {
              Get.back();
              await ctrl.deleteBooking(id);
              BookingController.triggerRefresh.value++;
              Get.back(); // đóng detail
            },
            child: const Text("Xóa", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}