// lib/modules/calendar/calendar_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:note_calendar/modules/booking/booking_controller.dart';
import 'package:note_calendar/modules/booking/view/add_booking_view.dart';
import 'package:table_calendar/table_calendar.dart';
import 'calendar_controller.dart';
import '../../data/models/booking_model.dart';
import '../../core/widgets/app_slidable.dart';
import '../booking/view/booking_detail_view.dart'; // Để mở chi tiết

class CalendarView extends GetView<CalendarController> {
  const CalendarView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Lịch Hẹn"), centerTitle: true),

      // NÚT TẠO MỚI – GIỮ NGUYÊN (vì vẫn cần thêm lịch)
      floatingActionButton: FloatingActionButton(
        heroTag: "btn_add_booking",
        onPressed: () {
          Get.find<BookingController>().resetFormForAdd();
          Get.bottomSheet(
            const AddBookingView(),
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
          );
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),

      body: Column(
        children: [
          // LỊCH
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

          // DANH SÁCH LỊCH HẸN
          Expanded(
            child: Obx(() {
              final dailyBookings = controller.getBookingsForDay(controller.selectedDay.value);

              if (dailyBookings.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.event_busy, size: 60, color: Colors.grey.shade300),
                      const SizedBox(height: 16),
                      Text("Không có lịch hẹn\n${DateFormat('dd/MM/yyyy').format(controller.selectedDay.value)}",
                          textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey, fontSize: 16)),
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

  // CHỈ CÒN XÓA – ĐÃ BỎ HOÀN TOÀN NÚT SỬA!
  Widget _buildBookingCard(BookingModel b) {
    final color = _getStatusColor(b.status);

    return AppSlidable(
      itemId: b.id!,
      onDelete: (id) async {
        await controller.deleteBooking(id);
        BookingController.triggerRefresh.value++; // realtime ngay
      },
      // ĐÃ BỎ onEdit → CHỈ CÒN XÓA!
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => showBookingDetail(b), // Chỉ xem chi tiết
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Giờ
                Container(
                  width: 76,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Column(
                    children: [
                      Text(DateFormat('HH:mm').format(b.startTime),
                          style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.blue, fontSize: 16)),
                      Container(height: 1, width: 30, color: Colors.blue.shade300, margin: const EdgeInsets.symmetric(vertical: 4)),
                      Text(DateFormat('HH:mm').format(b.endTime),
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue.shade700, fontSize: 14)),
                    ],
                  ),
                ),

                const SizedBox(width: 16),

                // Thông tin
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(b.customerName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                      const SizedBox(height: 4),
                      Text(b.serviceName, style: TextStyle(color: Colors.grey[700], fontSize: 15)),
                      const SizedBox(height: 6),
                      Text(
                        NumberFormat.currency(locale: 'vi', symbol: 'đ').format(b.servicePrice),
                        style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ],
                  ),
                ),

                // Trạng thái
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: color),
                  ),
                  child: Text(
                    b.status == 'confirmed' ? 'OK' :
                    b.status == 'completed' ? 'Xong' :
                    b.status == 'cancelled' ? 'Hủy' : b.status,
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color),
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
      case 'confirmed': return Colors.orange.shade600;
      case 'completed': return Colors.green.shade600;
      case 'cancelled': return Colors.red.shade600;
      case 'checked_in': return Colors.blue.shade600;
      default: return Colors.grey.shade600;
    }
  }
}