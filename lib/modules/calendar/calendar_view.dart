// lib/modules/calendar/calendar_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'calendar_controller.dart';
import '../../data/models/booking_model.dart';
import 'booking_detail_sheet.dart'; // THÊM DÒNG NÀY

class CalendarView extends GetView<CalendarController> {
  const CalendarView({super.key});

  // Hàm chuyển 24h → 12h + AM/PM
  String _formatTime12h(DateTime dateTime) {
    final hour = dateTime.hour == 0
        ? 12
        : dateTime.hour > 12
            ? dateTime.hour - 12
            : dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Lịch Hẹn"), centerTitle: true),

      floatingActionButton: FloatingActionButton(
        onPressed: controller.showAddBookingSheet,
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),

      body: Column(
        children: [
          Obx(() => TableCalendar<BookingModel>(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: controller.focusedDay.value,
                selectedDayPredicate: (day) => controller.isSameDay(controller.selectedDay.value, day),
                onDaySelected: controller.onDaySelected,
                calendarFormat: CalendarFormat.week,
                startingDayOfWeek: StartingDayOfWeek.monday,
                availableCalendarFormats: const {
                  CalendarFormat.month: 'Tháng',
                  CalendarFormat.week: 'Tuần',
                },
                calendarStyle: const CalendarStyle(
                  todayDecoration: BoxDecoration(color: Colors.blueAccent, shape: BoxShape.circle),
                  selectedDecoration: BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
                ),
                eventLoader: controller.getBookingsForDay,
              )),

          const Divider(height: 1),

          Expanded(
            child: Obx(() {
              final bookings = controller.getBookingsForDay(controller.selectedDay.value);
              if (bookings.isEmpty) {
                return Center(
                  child: Text(
                    "Không có lịch hẹn\n${DateFormat('dd/MM/yyyy').format(controller.selectedDay.value)}",
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: bookings.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, i) => _buildBookingCard(bookings[i]),
              );
            }),
          ),
        ],
      ),
    );
  }

  // CARD GIỮ NGUYÊN + CHỈ THÊM BẤM ĐỂ XEM CHI TIẾT
  Widget _buildBookingCard(BookingModel b) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell( // THÊM INKWELL ĐỂ BẤM ĐƯỢC
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Get.bottomSheet(
            BookingDetailSheet(booking: b),
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            // Để sheet tràn màn hình đẹp hơn
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cột thời gian – 12h format
              Container(
                width: 78,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    Text(
                      _formatTime12h(b.startTime),
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue, fontSize: 13),
                    ),
                    const Icon(Icons.arrow_downward, size: 18, color: Colors.blue),
                    Text(
                      _formatTime12h(b.endTime),
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue, fontSize: 13),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 14),

              // Nội dung chính
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      b.customerName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${b.serviceName} • ${NumberFormat.currency(locale: 'vi', symbol: 'đ').format(b.servicePrice)}",
                      style: const TextStyle(fontSize: 13.5, color: Colors.black87),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 10),

              // Chip trạng thái
              Chip(
                labelPadding: const EdgeInsets.symmetric(horizontal: 10),
                label: Text(
                  b.status.toUpperCase(),
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                backgroundColor: _getStatusColor(b.status),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'confirmed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      case 'completed':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}