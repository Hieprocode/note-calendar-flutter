// lib/modules/booking/views/booking_detail_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';
import 'package:note_calendar/modules/calendar/calendar_controller.dart';
import '../../../../data/models/booking_model.dart';
import '../booking_controller.dart'; // <-- QUAN TRỌNG: Dùng BookingController để có thông báo ngoài thiết bị

// Hàm mở chi tiết từ bên ngoài (giữ nguyên)
void showBookingDetail(BookingModel booking) {
  showModalBottomSheet(
    context: Get.context!,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => BookingDetailContent(booking: booking),
  );
}

class BookingDetailContent extends StatelessWidget {
  final BookingModel booking;
  const BookingDetailContent({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Lắng nghe refresh từ BookingController
      BookingController.triggerRefresh.value;

      // Lấy booking mới nhất từ danh sách (nếu có thay đổi)
      final calendarCtrl = Get.find<CalendarController>();
      final updatedBooking = calendarCtrl.allBookings.firstWhereOrNull(
            (b) => b.id == booking.id,
          ) ??
          booking;

      return DraggableScrollableSheet(
        initialChildSize: 0.65,
        maxChildSize: 0.92,
        minChildSize: 0.4,
        expand: false,
        builder: (_, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Thanh kéo
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              // Tiêu đề + nút đóng
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Chi tiết lịch hẹn",
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),

              // Nội dung cuộn
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Card thông tin khách
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.blue.shade100,
                            child: const Icon(Icons.person, color: Colors.blue),
                          ),
                          title: Text(
                            updatedBooking.customerName,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          subtitle: Text(updatedBooking.customerPhone),
                          trailing: Text(
                            NumberFormat.currency(locale: 'vi', symbol: 'đ').format(updatedBooking.servicePrice),
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 18),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Dịch vụ
                      Row(
                        children: [
                          const Icon(Icons.spa, color: Colors.purple),
                          const SizedBox(width: 12),
                          Expanded(child: Text(updatedBooking.serviceName)),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Giờ
                      Row(
                        children: [
                          const Icon(Icons.access_time, color: Colors.orange),
                          const SizedBox(width: 12),
                          Text(
                            "${DateFormat('HH:mm').format(updatedBooking.startTime)} → ${DateFormat('HH:mm').format(updatedBooking.endTime)} | ${updatedBooking.durationMinutes} phút",
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Ngày
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, color: Colors.blue),
                          const SizedBox(width: 12),
                          Text(DateFormat('EEEE, dd/MM/yyyy', 'vi').format(updatedBooking.startTime)),
                        ],
                      ),

                      // Ghi chú
                      if (updatedBooking.note?.isNotEmpty == true) ...[
                        const SizedBox(height: 12),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.note, color: Colors.grey),
                            const SizedBox(width: 12),
                            Expanded(child: Text(updatedBooking.note!)),
                          ],
                        ),
                      ],

                      const SizedBox(height: 32),

                      // NÚT TRẠNG THÁI – CÓ THÔNG BÁO NGOÀI THIẾT BỊ KHI BẤM
                      Row(
                        children: [
                          Expanded(
                            child: _statusButton(
                              "Đã đến",
                              Colors.orange,
                              updatedBooking.status == 'checked_in',
                              () => _updateStatus(context, updatedBooking.id ?? '', 'checked_in'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _statusButton(
                              "Hoàn thành",
                              Colors.green,
                              updatedBooking.status == 'completed',
                              () => _updateStatus(context, updatedBooking.id ?? '', 'completed'),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Nút xóa
                      Center(
                        child: TextButton.icon(
                          onPressed: () => _showDeleteConfirm(context, updatedBooking.id ?? ''),
                          icon: const Icon(Icons.delete_forever, color: Colors.red),
                          label: const Text(
                            "Xóa lịch hẹn này",
                            style: TextStyle(color: Colors.red, fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  // Nút trạng thái đẹp
  Widget _statusButton(String label, Color activeColor, bool isActive, VoidCallback onTap) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: isActive ? activeColor : Colors.grey.shade200,
        foregroundColor: isActive ? Colors.white : Colors.grey.shade700,
        elevation: isActive ? 4 : 0,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
    );
  }

  // ĐÃ SỬA: DÙNG BookingController → CÓ THÔNG BÁO NGOÀI MÀN HÌNH KHÓA
  void _updateStatus(BuildContext context, String id, String status) async {
    if (id.isEmpty) return;

    await Get.find<BookingController>().changeBookingStatus(id, status);

    BookingController.triggerRefresh.value++;
    Navigator.pop(context);
  }

  // Xóa lịch (giữ nguyên)
  void _showDeleteConfirm(BuildContext context, String id) {
    if (id.isEmpty) return;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Xóa lịch hẹn?", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
        content: const Text("Lịch hẹn này sẽ bị xóa vĩnh viễn và không thể khôi phục."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy")),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await Get.find<CalendarController>().deleteBooking(id);
              BookingController.triggerRefresh.value++;
              Navigator.pop(context);
              Get.rawSnackbar(
                message: "Đã xóa lịch hẹn",
                backgroundColor: Colors.red,
                snackPosition: SnackPosition.TOP,
                margin: const EdgeInsets.all(16),
                borderRadius: 12,
                duration: const Duration(seconds: 2),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Xóa", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}