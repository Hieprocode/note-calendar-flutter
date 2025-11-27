// lib/modules/customers/views/add_customer_view.dart
import 'package:flutter/material.dart';
import 'package:get/Get.dart';
import '../customer_controller.dart';

class AddCustomerView extends StatelessWidget {
  const AddCustomerView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CustomerController>();

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        expand: false,
        builder: (_, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Thanh kéo
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 50,
                height: 5,
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
              ),

              // Tiêu đề – DÙNG GetBuilder ĐỂ TRÁNH LỖI Obx
              GetBuilder<CustomerController>(
                builder: (ctrl) => Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Text(
                    ctrl.editingId == null ? "Thêm Khách Mới" : "Sửa Thông Tin Khách",
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              // Nội dung cuộn
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tên khách
                      TextField(
                        controller: controller.nameController,
                        textCapitalization: TextCapitalization.words,
                        decoration: const InputDecoration(
                          labelText: "Tên khách hàng *",
                          border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                          prefixIcon: Icon(Icons.person),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Số điện thoại – KHÓA KHI SỬA
                      TextField(
                        controller: controller.phoneController,
                        keyboardType: TextInputType.phone,
                        enabled: controller.editingId == null,
                        decoration: InputDecoration(
                          labelText: "Số điện thoại *",
                          hintText: controller.editingId != null ? "Không thể thay đổi số điện thoại" : null,
                          border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                          prefixIcon: const Icon(Icons.phone),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Ghi chú
                      TextField(
                        controller: controller.noteController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: "Ghi chú (tính cách, sở thích, v.v.)",
                          border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                          prefixIcon: Icon(Icons.note),
                          alignLabelWithHint: true,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // NÚT "BÙNG KÈO" – HOẠT ĐỘNG HOÀN HẢO
                      GetBuilder<CustomerController>(
                        builder: (ctrl) => SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text(
                            "Đánh dấu khách bùng kèo",
                            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          subtitle: const Text("Sẽ hiển thị cảnh báo đỏ ở mọi nơi"),
                          value: ctrl.isBadGuest.value,
                          activeColor: Colors.red,
                          onChanged: (val) => ctrl.isBadGuest.value = val,
                        ),
                      ),

                      const SizedBox(height: 30),

                      // NÚT "CẬP NHẬT" / "THÊM" – ĐÓNG MƯỢT + THÔNG BÁO ĐẸP
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () async {
                            final success = await controller.saveCustomer();
                            if (success && context.mounted) {
                              Navigator.pop(context); // ĐÓNG BOTTOM SHEET
                              Get.rawSnackbar(
                                message: controller.editingId == null
                                    ? "Đã thêm khách hàng thành công!"
                                    : "Cập nhật thông tin thành công!",
                                backgroundColor: Colors.green,
                                snackPosition: SnackPosition.TOP,
                                margin: const EdgeInsets.all(16),
                                borderRadius: 12,
                                duration: const Duration(seconds: 2),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 4,
                          ),
                          child: GetBuilder<CustomerController>(
                            builder: (ctrl) => Text(
                              ctrl.editingId == null ? "THÊM KHÁCH MỚI" : "CẬP NHẬT",
                              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // NÚT XÓA (khi đang sửa)
                      if (controller.editingId != null)
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () => _showDeleteConfirm(context),
                            icon: const Icon(Icons.delete_forever, color: Colors.red),
                            label: const Text("Xóa khách hàng này", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.red),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirm(BuildContext context) {
    final controller = Get.find<CustomerController>();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Xóa khách hàng?", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
        content: Text("Khách hàng ${controller.nameController.text} sẽ bị xóa vĩnh viễn."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy")),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await controller.deleteCustomer(controller.editingId!);
              if (success && context.mounted) {
                Navigator.pop(context);
                Get.rawSnackbar(message: "Đã xóa khách hàng!", backgroundColor: Colors.red, snackPosition: SnackPosition.TOP, margin: const EdgeInsets.all(16), borderRadius: 12);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Xóa ngay", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}