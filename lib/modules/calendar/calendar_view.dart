import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:note_calendar/modules/booking/booking_controller.dart';
import 'package:note_calendar/modules/booking/view/add_booking_view.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'calendar_controller.dart';
import '../../data/models/booking_model.dart';
import '../../core/widgets/app_slidable.dart';

// IMPORT QUAN TRỌNG: Lấy View từ module Booking sang để dùng
import '../booking/view/booking_detail_view.dart'; 

class CalendarView extends GetView<CalendarController> {
  const CalendarView({super.key});

  // Hàm format giờ (Helper)
  String _formatTime12h(DateTime dateTime) {
    final hour = dateTime.hour == 0 ? 12 : (dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour);
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Lịch Hẹn"), centerTitle: true),

      // NÚT TẠO MỚI -> Chuyển sang Module Booking
      floatingActionButton: FloatingActionButton(
      heroTag: "btn_add_booking",
      onPressed: () {
      Get.back();
      Get.find<BookingController>().resetFormForAdd(); // bạn nên có hàm này trong controller
    
      Get.bottomSheet(
       AddBookingView(), // Dùng luôn file bạn vừa gửi
      isScrollControlled: true, // BẮT BUỘC phải có để full height + bàn phím không che
      backgroundColor: Colors.transparent, // để bo góc trong suốt đẹp hơn
      // Các tùy chỉnh đẹp thêm (tùy chọn)
      enterBottomSheetDuration: const Duration(milliseconds: 300),
      exitBottomSheetDuration: const Duration(milliseconds: 250),
    );
  },
  backgroundColor: Colors.blue,
  child: const Icon(Icons.add, color: Colors.white),
),

      body: Column(
        children: [
          // 1. CÁI LỊCH
          Obx(() => TableCalendar<BookingModel>(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: controller.focusedDay.value,
            selectedDayPredicate: (day) => controller.isSameDay(controller.selectedDay.value, day),
            onDaySelected: controller.onDaySelected,
            
            calendarFormat: CalendarFormat.week,
            startingDayOfWeek: StartingDayOfWeek.monday,
            
            // Tắt nút 2 weeks để tránh crash
            availableCalendarFormats: const {
              CalendarFormat.month: 'Tháng',
              CalendarFormat.week: 'Tuần',
            },
            
            calendarStyle: const CalendarStyle(
              todayDecoration: BoxDecoration(color: Colors.blueAccent, shape: BoxShape.circle),
              selectedDecoration: BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
              markerDecoration: BoxDecoration(color: Colors.green, shape: BoxShape.circle),
            ),
            
            // Dấu chấm trên lịch
            eventLoader: controller.getBookingsForDay,
          )),

          const Divider(height: 1),

          // 2. DANH SÁCH
          Expanded(
            // Obx này sẽ lắng nghe allBookings.refresh() từ Controller
            child: Obx(() {
              // Lọc dữ liệu ngay trong Obx để khi allBookings đổi, biến này đổi theo
              final dailyBookings = controller.getBookingsForDay(controller.selectedDay.value);

              if (dailyBookings.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.event_busy, size: 50, color: Colors.grey.shade300),
                      const SizedBox(height: 10),
                      Text(
                        "Không có lịch hẹn\n${DateFormat('dd/MM/yyyy').format(controller.selectedDay.value)}",
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: dailyBookings.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final booking = dailyBookings[index];
                  return _buildBookingCard(booking);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  // THẺ BOOKING
  Widget _buildBookingCard(BookingModel b) {
  final color = _getStatusColor(b.status);

  return AppSlidable(
    itemId: b.id!,
    onEdit: () {
      Get.back(); // đóng detail nếu đang mở
      Get.find<BookingController>().fillDataForEdit(b);
      Get.bottomSheet(
        const AddBookingView(),
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
      );
    },
    onDelete: (id) async {
      await controller.deleteBooking(id);
      BookingController.triggerRefresh.value++; // realtime ngay lập tức
    },
    child: Card(
      elevation: 3,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          showBookingDetail(b);
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // Cột thời gian
              Container(
                width: 70,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.blue.shade100),
                ),
                child: Column(
                  children: [
                    Text(
                      DateFormat('HH:mm').format(b.startTime),
                      style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.blue, fontSize: 15),
                    ),
                    Container(height: 1, width: 24, color: Colors.blue.shade200, margin: const EdgeInsets.symmetric(vertical: 4)),
                    Text(
                      DateFormat('HH:mm').format(b.endTime),
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue.shade700, fontSize: 13),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 14),

              // Thông tin chính
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(b.customerName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text(b.serviceName, style: TextStyle(color: Colors.grey[800], fontSize: 14)),
                    const SizedBox(height: 4),
                    Text(
                      NumberFormat.currency(locale: 'vi', symbol: 'đ').format(b.servicePrice),
                      style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ],
                ),
              ),

              // Trạng thái
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: color),
                ),
                child: Text(
                  b.status == 'confirmed' ? 'OK' :
                  b.status == 'completed' ? 'Xong' :
                  b.status == 'cancelled' ? 'Hủy' : b.status,
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

  Color _getStatusColor(String status) {
  switch (status) {
    case 'confirmed':
      return Colors.orange.shade600;
    case 'completed':
      return Colors.green.shade600;
    case 'cancelled':
      return Colors.red.shade600;
    case 'checked_in':
      return Colors.blue.shade600;
    default:
      return Colors.grey.shade600;
  }
}
}