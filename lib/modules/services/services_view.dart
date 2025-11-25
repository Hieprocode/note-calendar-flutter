// lib/modules/services/services_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../data/models/service_model.dart';
import 'services_controller.dart';

class ServicesView extends GetView<ServicesController> {
  const ServicesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Danh sách Dịch vụ"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),

      // Nút thêm mới nổi
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showServiceDialog(),
        label: const Text("Thêm dịch vụ"),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),

      body: Obx(() {
        // Loading
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        // Trống
        if (controller.servicesList.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.spa_outlined, size: 80, color: Colors.grey.shade300),
                const SizedBox(height: 20),
                const Text(
                  "Chưa có dịch vụ nào",
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Bấm nút (+) để thêm dịch vụ đầu tiên",
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        // Danh sách dịch vụ
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100), // tránh bị FAB che
          itemCount: controller.servicesList.length,
          itemBuilder: (context, index) {
            final service = controller.servicesList[index];
            final color = _parseColor(service.colorHex);
            final letter = service.name.isNotEmpty ? service.name[0].toUpperCase() : "?";

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Slidable(
                // Vuốt sang trái → hiện nút Sửa + Xóa
                endActionPane: ActionPane(
                  motion: const StretchMotion(),
                  extentRatio: 0.5,
                  children: [
                    SlidableAction(
                      onPressed: (_) => _showServiceDialog(editingService: service),
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      icon: Icons.edit,
                      label: 'Sửa',
                      borderRadius: const BorderRadius.all(Radius.circular(16)),
                    ),
                    SlidableAction(
                      onPressed: (_) => _confirmDelete(context, service.id!),
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      icon: Icons.delete_outline,
                      label: 'Xóa',
                      borderRadius: const BorderRadius.all(Radius.circular(16)),
                    ),
                  ],
                ),

                // CARD CHÍNH – SIÊU ĐẸP
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Avatar có màu
                      CircleAvatar(
                        radius: 26,
                        backgroundColor: color.withOpacity(0.15),
                        child: Text(
                          letter,
                          style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                        ),
                      ),

                      const SizedBox(width: 16),

                      // Nội dung chính (tự co giãn)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              service.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                                const SizedBox(width: 4),
                                Text(
                                  "${service.durationMinutes} phút",
                                  style: TextStyle(color: Colors.grey[700], fontSize: 13),
                                ),
                                const SizedBox(width: 20),
                                Icon(Icons.attach_money, size: 16, color: Colors.green[700]),
                                const SizedBox(width: 4),
                                Text(
                                  NumberFormat.currency(locale: 'vi', symbol: 'đ').format(service.price),
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Gợi ý có thể vuốt
                      Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.grey[400],
                        size: 22,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }

  // Parse màu từ hex string
  Color _parseColor(String hex) {
    try {
      return Color(int.parse(hex));
    } catch (e) {
      return Colors.blue;
    }
  }

  // DIALOG THÊM / SỬA DỊCH VỤ
  void _showServiceDialog({ServiceModel? editingService}) {
    if (editingService != null) {
      controller.prepareEdit(editingService);
    } else {
      controller.resetForm();
    }

    final formKey = GlobalKey<FormState>();

    showDialog(
      context: Get.context!,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          editingService == null ? "Thêm Dịch Vụ" : "Chỉnh sửa Dịch Vụ",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: controller.nameController,
                  decoration: const InputDecoration(
                    labelText: "Tên dịch vụ *",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.spa),
                  ),
                  validator: (v) => v!.trim().isEmpty ? "Nhập tên dịch vụ" : null,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: controller.priceController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: "Giá tiền *",
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.attach_money),
                          suffixText: "đ",
                        ),
                        validator: (v) => v!.isEmpty || double.tryParse(v) == null ? "Giá không hợp lệ" : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: controller.durationController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: "Thời gian *",
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.access_time),
                          suffixText: "phút",
                        ),
                        validator: (v) => v!.isEmpty ? "Nhập phút" : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Chọn màu hiển thị:", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 12),
                Center(
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: controller.colorPalette.map((hex) {
                      return GestureDetector(
                        onTap: () => controller.selectedColor.value = hex,
                        child: Obx(() {
                          final selected = controller.selectedColor.value == hex;
                          return Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: Color(int.parse(hex)),
                              shape: BoxShape.circle,
                              border: selected ? Border.all(color: Colors.black, width: 3) : null,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: selected ? const Icon(Icons.check, color: Colors.white, size: 24) : null,
                          );
                        }),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(Get.context!),
            child: const Text("Hủy", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                controller.saveService();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(editingService == null ? "Thêm mới" : "Cập nhật", style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // XÁC NHẬN XÓA
  void _confirmDelete(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Xóa dịch vụ?", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
        content: const Text("Dịch vụ sẽ bị ẩn vĩnh viễn và không thể khôi phục."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy")),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              controller.deleteService(id);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Xóa", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}