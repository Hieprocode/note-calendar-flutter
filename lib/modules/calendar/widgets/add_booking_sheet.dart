// lib/modules/calendar/widgets/add_booking_sheet.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:note_calendar/data/models/service_model.dart';
import 'package:note_calendar/data/models/booking_model.dart';
import 'package:note_calendar/data/repositories/booking_repository.dart';
import 'package:note_calendar/modules/calendar/calendar_controller.dart';
import '../../services/services_controller.dart';


class AddBookingBottomSheet extends StatefulWidget {
  const AddBookingBottomSheet({super.key});

  @override
  State<AddBookingBottomSheet> createState() => _AddBookingBottomSheetState();
}

class _AddBookingBottomSheetState extends State<AddBookingBottomSheet> {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();

  ServiceModel? selectedService;
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = const TimeOfDay(hour: 9, minute: 0);

  @override
  Widget build(BuildContext context) {
    final servicesController = Get.find<ServicesController>();

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: DraggableScrollableSheet(
        initialChildSize: 0.9,
        maxChildSize: 0.95,
        minChildSize: 0.6,
        expand: false,
        builder: (_, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Thanh kéo
                  Center(
                    child: Container(width: 50, height: 5, color: Colors.grey[300]),
                  ),
                  const SizedBox(height: 16),
                  const Text("Thêm Lịch Hẹn Mới", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),

                  // Tên khách
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: "Tên khách hàng *",
                      prefixIcon: Icon(Icons.person_outline),
                      border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                    ),
                    validator: (v) => v!.trim().isEmpty ? "Vui lòng nhập tên" : null,
                  ),
                  const SizedBox(height: 16),

                  // Số điện thoại
                  TextFormField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: "Số điện thoại *",
                      prefixIcon: Icon(Icons.phone_outlined),
                      border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                    ),
                    validator: (v) => v!.trim().isEmpty ? "Vui lòng nhập SĐT" : null,
                  ),
                  const SizedBox(height: 16),

                  // Chọn dịch vụ
                  Obx(() => DropdownButtonFormField<ServiceModel>(
                        value: selectedService,
                        hint: const Text("Chọn dịch vụ *"),
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.spa_outlined),
                          border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                        ),
                        items: servicesController.servicesList
                            .map((s) => DropdownMenuItem(value: s, child: Text(s.name)))
                            .toList(),
                        onChanged: (v) => setState(() => selectedService = v),
                        validator: (v) => v == null ? "Vui lòng chọn dịch vụ" : null,
                      )),
                  const SizedBox(height: 20),

                  // Ngày
                  ListTile(
                    leading: const Icon(Icons.calendar_today, color: Colors.blue),
                    title: Text("Ngày: ${DateFormat('dd/MM/yyyy').format(selectedDate)}"),
                    trailing: const Icon(Icons.chevron_right),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Colors.grey)),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime.now().subtract(const Duration(days: 1)),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null) setState(() => selectedDate = date);
                    },
                  ),
                  const SizedBox(height: 12),

                  // Giờ bắt đầu
                  ListTile(
                    leading: const Icon(Icons.access_time, color: Colors.blue),
                    title: Text("Giờ bắt đầu: ${selectedTime.format(context)}"),
                    trailing: const Icon(Icons.chevron_right),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Colors.grey)),
                    onTap: () async {
                      final time = await showTimePicker(context: context, initialTime: selectedTime);
                      if (time != null) setState(() => selectedTime = time);
                    },
                  ),

                  // Hiển thị giờ kết thúc
                  if (selectedService != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      "→ Kết thúc: ${DateFormat('HH:mm').format(DateTime(selectedDate.year, selectedDate.month, selectedDate.day, selectedTime.hour, selectedTime.minute).add(Duration(minutes: selectedService!.durationMinutes)))}",
                      style: const TextStyle(fontSize: 15, color: Colors.green, fontWeight: FontWeight.bold),
                    ),
                  ],

                  const SizedBox(height: 32),

                  // Nút Thêm
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (formKey.currentState!.validate() && selectedService != null) {
                          final startTime = DateTime(
                          selectedDate.year,
                          selectedDate.month,
                          selectedDate.day,
                          selectedTime.hour,
                          selectedTime.minute,
                        );

                          final booking = BookingModel(
                            shopId: FirebaseAuth.instance.currentUser!.uid,
                            customerName: nameController.text.trim(),
                            customerPhone: phoneController.text.trim(),
                            serviceId: selectedService!.id!,
                            serviceName: selectedService!.name,
                            servicePrice: selectedService!.price,
                            durationMinutes: selectedService!.durationMinutes,
                            startTime: startTime,
                            endTime: startTime.add(Duration(minutes: selectedService!.durationMinutes)),
                            status: 'confirmed',
                            source: 'manual',
                          );

                          try {
                          // DÙNG REPO ĐÃ CÓ → CHUẨN GETX + CLEAN ARCHITECTURE
                          final docRef = await Get.find<BookingRepository>().addBooking(booking);

                          // THÊM NGAY VÀO LIST ĐỂ HIỆN REALTIME TỨC THÌ (không cần đợi stream)
                          final newBooking = booking.copyWith(id: docRef.id);
                          Get.find<CalendarController>().allBookings.add(newBooking);

                          Get.back();
                          Get.snackbar(
                            "Thành công!",
                            "Đã thêm lịch cho ${booking.customerName}",
                            backgroundColor: Colors.green,
                            colorText: Colors.white,
                          );
                        } catch (e) {
                            Get.snackbar("Lỗi", "Không thể thêm lịch hẹn", backgroundColor: Colors.red);
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text("Thêm Lịch Hẹn", style: TextStyle(fontSize: 16, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}