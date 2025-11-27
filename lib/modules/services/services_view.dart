// lib/modules/services/services_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../data/models/service_model.dart';
import 'services_controller.dart';
import '../../core/widgets/app_slidable.dart'; // DÙNG CHUNG TOÀN APP
    // DÙNG CHUNG TOÀN APP (nếu muốn)

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

      floatingActionButton: FloatingActionButton.extended(
        heroTag: "btn_add_service",
        onPressed: () => _showServiceDialog(),
        label: const Text("Thêm dịch vụ"),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),

      body: Obx(() {
        final services = controller.servicesList;

        if (services.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.spa_outlined, size: 80, color: Colors.grey.shade300),
                const SizedBox(height: 20),
                const Text("Chưa có dịch vụ nào", style: TextStyle(fontSize: 18, color: Colors.grey)),
                const SizedBox(height: 8),
                const Text("Bấm nút (+) để thêm dịch vụ đầu tiên", style: TextStyle(color: Colors.grey)),
              ],
            ),
          );
        }

        return ListView.builder(
          key: const ValueKey("services_list"),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          itemCount: services.length,
          itemBuilder: (context, index) {
            final service = services[index];
            final color = _parseColor(service.colorHex);
            final letter = service.name.isNotEmpty ? service.name[0].toUpperCase() : "?";

            return AppSlidable(
              itemId: service.id!,
              onEdit: () => _showServiceDialog(editingService: service),
              onDelete: (id) async {
                await controller.deleteService(id);
                // Nếu muốn snackbar xanh đẹp hơn thì dùng AppAlert
                // AppAlert.success("Đã xóa dịch vụ");
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: color.withOpacity(0.15),
                      child: Text(
                        letter,
                        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 24),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            service.name,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                              const SizedBox(width: 4),
                              Text("${service.durationMinutes} phút", style: TextStyle(color: Colors.grey[700], fontSize: 13)),
                              const SizedBox(width: 20),
                              Icon(Icons.attach_money, size: 16, color: Colors.green[700]),
                              const SizedBox(width: 4),
                              Text(
                                NumberFormat.currency(locale: 'vi', symbol: 'đ').format(service.price),
                                style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w600, fontSize: 14),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_back_ios_new_rounded, color: Colors.grey[400], size: 22),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }

  Color _parseColor(String hex) {
    try {
      return Color(int.parse(hex));
    } catch (e) {
      return Colors.blue;
    }
  }

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
}