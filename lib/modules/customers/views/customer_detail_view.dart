// lib/modules/customers/views/customer_detail_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../data/models/customer_model.dart';
import '../../../data/models/booking_model.dart';
import '../../../data/repositories/booking_repository.dart';
import '../customer_controller.dart';
import '../../../core/utils/app_alert.dart'; // DÙNG CHUNG TOÀN APP

class CustomerDetailView extends StatelessWidget {
  final CustomerModel customer;
  const CustomerDetailView({super.key, required this.customer});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CustomerController>();
    final bookingRepo = Get.find<BookingRepository>();
    final uid = FirebaseAuth.instance.currentUser?.uid ?? "";

    return Scaffold(
      appBar: AppBar(
        title: const Text("Hồ Sơ Khách Hàng"),
        centerTitle: true,
        actions: [
          // NÚT SỬA
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              controller.prepareForm(customer: customer);
              
            },
          ),
          // NÚT XÓA – DÙNG POPUP ĐẸP NHƯ AppSlidable
          IconButton(
            icon: const Icon(Icons.delete_forever, color: Colors.red),
            onPressed: () => _showDeleteConfirm(context, customer),
          ),
        ],
      ),

      body: Column(
        children: [
          // HEADER THÔNG TIN
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: customer.isBadGuest
                    ? [Colors.red.shade50, Colors.red.shade100]
                    : [Colors.blue.shade50, Colors.blue.shade100],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white,
                  child: Icon(
                    customer.isBadGuest ? Icons.sentiment_very_dissatisfied : Icons.person,
                    size: 60,
                    color: customer.isBadGuest ? Colors.red : Colors.blue,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  customer.name,
                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  customer.phone,
                  style: const TextStyle(fontSize: 18, color: Colors.black87),
                ),
                if (customer.isBadGuest) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(20)),
                    child: const Text("Bùng kèo", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ],
                const SizedBox(height: 16),
                if (customer.note?.isNotEmpty == true)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)),
                    child: Text("Ghi chú: ${customer.note}", style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.black87)),
                  ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _actionButton(Icons.phone, "Gọi", Colors.green),
                    const SizedBox(width: 20),
                    _actionButton(Icons.message, "Nhắn tin", Colors.blue),
                  ],
                ),
              ],
            ),
          ),

          // TIÊU ĐỀ LỊCH SỬ
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: Row(
              children: [
                const Icon(Icons.history, size: 28, color: Colors.grey),
                const SizedBox(width: 12),
                const Text("Lịch sử đặt chỗ", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const Spacer(),
                Text("${customer.totalBookings} lần", style: TextStyle(fontSize: 16, color: Colors.grey[600])),
              ],
            ),
          ),

          // DANH SÁCH LỊCH SỬ
          Expanded(
            child: StreamBuilder<List<BookingModel>>(
              stream: bookingRepo.getBookingsByCustomer(uid, customer.phone),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text("Lỗi tải dữ liệu", style: TextStyle(color: Colors.red)));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final bookings = snapshot.data!;
                if (bookings.isEmpty) {
                  return const Center(child: Text("Chưa có lịch hẹn nào", style: TextStyle(color: Colors.grey)));
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: bookings.length,
                  itemBuilder: (context, index) {
                    final b = bookings[index];
                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: b.status == 'completed' ? Colors.green.shade100 : Colors.orange.shade100,
                          child: Icon(
                            b.status == 'completed' ? Icons.check : Icons.access_time,
                            color: b.status == 'completed' ? Colors.green : Colors.orange,
                          ),
                        ),
                        title: Text(b.serviceName, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(DateFormat('dd/MM/yyyy HH:mm').format(b.startTime)),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              NumberFormat.currency(locale: 'vi', symbol: 'đ').format(b.servicePrice),
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                            ),
                            Text(
                              b.status == 'completed' ? "Hoàn thành" : "Đã đặt",
                              style: TextStyle(fontSize: 11, color: b.status == 'completed' ? Colors.green : Colors.orange),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton(IconData icon, String label, Color color) {
    return ElevatedButton.icon(
      onPressed: () => AppAlert.success("Tính năng $label đang phát triển"),
      icon: Icon(icon, size: 20),
      label: Text(label),
      style: ElevatedButton.styleFrom(backgroundColor: color, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 20)),
    );
  }

  void _showDeleteConfirm(BuildContext context, CustomerModel customer) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Xóa khách hàng?", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
        content: Text("Khách hàng ${customer.name} sẽ bị xóa vĩnh viễn."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy")),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await Get.find<CustomerController>().deleteCustomer(customer.id ?? customer.phone);
              Get.back(); // quay về danh sách
              AppAlert.success("Đã xóa khách hàng thành công!");
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Xóa", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}