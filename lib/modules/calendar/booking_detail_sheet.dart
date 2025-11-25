// lib/modules/calendar/widgets/booking_detail_sheet.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../data/models/booking_model.dart';

class BookingDetailSheet extends StatelessWidget {
  final BookingModel booking;
  const BookingDetailSheet({super.key, required this.booking});

  // Định dạng giờ 12h + AM/PM
  String _formatTime12h(DateTime dt) {
    final hour = dt.hour == 0 ? 12 : (dt.hour > 12 ? dt.hour - 12 : dt.hour);
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  // Màu trạng thái (dùng String như cũ)
  Color _getStatusColor(String status) {
    switch (status) {
      case 'confirmed': return Colors.green;
      case 'pending':   return Colors.orange;
      case 'cancelled': return Colors.red;
      case 'completed': return Colors.blue;
      default:          return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'confirmed': return "Đã xác nhận";
      case 'pending':   return "Chưa xác nhận";
      case 'cancelled': return "Đã hủy";
      case 'completed': return "Hoàn thành";
      default:          return "Chưa xác nhận";
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, controller) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          controller: controller,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thanh kéo
              Center(child: Container(width: 50, height: 5, color: Colors.grey[300],)),
              const SizedBox(height: 20),

              // Tiêu đề
              const Text("Chi Tiết Lịch Hẹn", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),

              // Tên khách
              ListTile(
                leading: const Icon(Icons.person, size: 40, color: Colors.blue),
                title: Text(booking.customerName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                subtitle: Text(booking.customerPhone, style: const TextStyle(fontSize: 16)),
              ),

              // Dịch vụ
              ListTile(
                leading: const Icon(Icons.spa, size: 40, color: Colors.pink),
                title: Text(booking.serviceName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                subtitle: Text("${booking.durationMinutes} phút"),
                trailing: Text(
                  NumberFormat.currency(locale: 'vi', symbol: 'đ').format(booking.servicePrice),
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
                ),
              ),

              // Thời gian
              ListTile(
                leading: const Icon(Icons.access_time, size: 40, color: Colors.orange),
                title: Text("${_formatTime12h(booking.startTime)} → ${_formatTime12h(booking.endTime)}",
                    style: const TextStyle(fontSize: 18)),
                subtitle: Text(DateFormat('EEEE, dd/MM/yyyy', 'vi').format(booking.startTime),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              ),

              // Trạng thái (chỉ hiển thị, không đổi)
              const SizedBox(height: 30),
              Center(
                child: Chip(
                  backgroundColor: _getStatusColor(booking.status),
                  label: Text(
                    _getStatusText(booking.status),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}