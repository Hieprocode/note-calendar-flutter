import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'calendar_controller.dart';
import '../../data/models/booking_model.dart';

class CalendarView extends GetView<CalendarController> {
  const CalendarView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Lịch Hẹn"), centerTitle: true),
      
      // Nút thêm Booking
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // --- ĐÃ SỬA: Dùng print thay vì Snackbar để tránh lỗi Overlay ---
          print("--> Bấm nút thêm booking (Chức năng này làm ở bước sau)");
          // Get.toNamed(AppRoutes.ADD_BOOKING); // Sau này sẽ mở dòng này
        },
        child: const Icon(Icons.add),
      ),

      body: Column(
        children: [
          // 1. CÁI LỊCH (TableCalendar)
          Obx(() => TableCalendar<BookingModel>(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: controller.focusedDay.value,
            
            // Cấu hình chọn ngày
            selectedDayPredicate: (day) => controller.isSameDay(controller.selectedDay.value, day),
            onDaySelected: controller.onDaySelected,
            
            // Cấu hình giao diện
            calendarFormat: CalendarFormat.week,
            startingDayOfWeek: StartingDayOfWeek.monday,
            
            // --- QUAN TRỌNG: THÊM DÒNG NÀY ĐỂ SỬA LỖI CRASH ---
            // Chỉ cho phép hiện Tuần và Tháng, tắt nút "2 weeks" đi
            availableCalendarFormats: const {
              CalendarFormat.month: 'Tháng',
              CalendarFormat.week: 'Tuần',
            },
            // --------------------------------------------------

            calendarStyle: const CalendarStyle(
              todayDecoration: BoxDecoration(color: Colors.blueAccent, shape: BoxShape.circle),
              selectedDecoration: BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
              markerDecoration: BoxDecoration(color: Colors.green, shape: BoxShape.circle),
            ),
            
            // Logic hiển thị dấu chấm (Marker)
            eventLoader: (day) {
              return controller.getBookingsForDay(day);
            },
          )),

          const Divider(),
          
          // 2. DANH SÁCH BOOKING CỦA NGÀY ĐƯỢC CHỌN
          Expanded(
            child: Obx(() {
              final dailyBookings = controller.getBookingsForDay(controller.selectedDay.value);

              if (dailyBookings.isEmpty) {
                return Center(
                  child: Text(
                    "Ngày ${DateFormat('dd/MM').format(controller.selectedDay.value)} trống lịch",
                    style: const TextStyle(color: Colors.grey),
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: dailyBookings.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
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

  // Widget con: Thẻ Booking
  Widget _buildBookingCard(BookingModel booking) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(DateFormat('HH:mm').format(booking.startTime), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
              const Text("đến", style: TextStyle(fontSize: 10, color: Colors.grey)),
              Text(DateFormat('HH:mm').format(booking.endTime), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
            ],
          ),
        ),
        title: Text(booking.customerName, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("${booking.serviceName} • ${NumberFormat.currency(locale: 'vi', symbol: 'đ').format(booking.servicePrice)}"),
        trailing: Chip(
          label: Text(booking.status, style: const TextStyle(fontSize: 10, color: Colors.white)),
          backgroundColor: _getStatusColor(booking.status),
          padding: EdgeInsets.zero,
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'confirmed': return Colors.green;
      case 'pending': return Colors.orange;
      case 'cancelled': return Colors.red;
      default: return Colors.grey;
    }
  }
}