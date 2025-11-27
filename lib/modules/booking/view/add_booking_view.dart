// lib/modules/booking/view/add_booking_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../data/models/service_model.dart';
import '../booking_controller.dart';

class AddBookingView extends StatelessWidget {
  const AddBookingView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BookingController>();

    // DÙNG showModalBottomSheet + Padding → context luôn sống → đóng được!
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: DraggableScrollableSheet(
        initialChildSize: 0.9,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        expand: false,
        builder: (_, scrollController) => Material(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: Container(width: 50, height: 5, color: Colors.grey[300])),
                const SizedBox(height: 20),

                Obx(() => Text(
                  controller.isEditMode.value ? "Cập nhật Lịch Hẹn" : "Tạo Lịch Hẹn Mới",
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                )),
                const SizedBox(height: 20),

                // Tên khách
                TextField(
                  controller: controller.nameController,
                  decoration: const InputDecoration(
                    labelText: "Tên khách hàng *",
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 15),

                // Số điện thoại
                TextField(
                  controller: controller.phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: "Số điện thoại *",
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                    prefixIcon: Icon(Icons.phone),
                  ),
                ),
                const SizedBox(height: 15),

                // Dịch vụ
                Obx(() => DropdownButtonFormField<ServiceModel>(
                  value: controller.selectedService.value,
                  hint: const Text("Chọn dịch vụ *"),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                    prefixIcon: Icon(Icons.spa),
                  ),
                  items: controller.servicesList.map((s) => DropdownMenuItem(
                    value: s,
                    child: Text("${s.name} (${s.durationMinutes}p)"),
                  )).toList(),
                  onChanged: (val) => controller.selectService(val!),
                )),

                const SizedBox(height: 20),

                // Ngày & Giờ
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final d = await showDatePicker(
                            context: context,
                            initialDate: controller.selectedDate.value,
                            firstDate: DateTime.now().subtract(const Duration(days: 30)),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          if (d != null) controller.selectedDate.value = d;
                        },
                        icon: const Icon(Icons.calendar_today),
                        label: Obx(() => Text(DateFormat('dd/MM/yyyy').format(controller.selectedDate.value))),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final t = await showTimePicker(context: context, initialTime: controller.selectedTime.value);
                          if (t != null) controller.selectTime(t);
                        },
                        icon: const Icon(Icons.access_time),
                        label: Obx(() => Text(controller.selectedTime.value.format(context))),
                      ),
                    ),
                  ],
                ),

                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Obx(() => Text(
                    "Dự kiến xong lúc: ${controller.endTime.value.format(context)}",
                    style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                  )),
                ),

                const SizedBox(height: 30),

                // NÚT LƯU – BẤM XONG TỰ ĐÓNG BẰNG Navigator.pop
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async {
                      await controller.saveBooking();
                      // ĐÓNG BOTTOM SHEET BẰNG Navigator.pop → LUÔN HOẠT ĐỘNG!
                      if (context.mounted) Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Obx(() => Text(
                      controller.isEditMode.value ? "CẬP NHẬT" : "LƯU LỊCH HẸN",
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    )),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}