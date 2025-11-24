import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'services_controller.dart';

class ServicesView extends GetView<ServicesController> {
  const ServicesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Danh sách Dịch vụ"),
        centerTitle: true,
      ),
      
      // Nút thêm mới nổi
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDialog(context),
        label: const Text("Thêm mới"),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),

      body: Obx(() {
        // 1. Loading
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        
        // 2. Trống
        if (controller.servicesList.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.category_outlined, size: 80, color: Colors.grey.shade300),
                const SizedBox(height: 10),
                const Text("Chưa có dịch vụ nào", style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 5),
                const Text("Bấm nút (+) để tạo ngay", style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          );
        }

        // 3. Danh sách
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: controller.servicesList.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final service = controller.servicesList[index];
            
            // Parse màu
            Color serviceColor;
            try {
              serviceColor = Color(int.parse(service.colorHex));
            } catch (e) {
              serviceColor = Colors.blue;
            }
            
            String firstLetter = service.name.isNotEmpty ? service.name[0].toUpperCase() : "?";

            return Card(
              elevation: 0,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                
                // Avatar chữ cái
                leading: CircleAvatar(
                  radius: 24,
                  backgroundColor: serviceColor.withOpacity(0.2),
                  child: Text(
                    firstLetter,
                    style: TextStyle(color: serviceColor, fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                ),
                
                title: Text(service.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Row(
                    children: [
                      Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text("${service.durationMinutes}p", style: TextStyle(color: Colors.grey[600])),
                      const SizedBox(width: 15),
                      Icon(Icons.attach_money, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        NumberFormat.currency(locale: 'vi', symbol: 'đ').format(service.price),
                        style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => _confirmDelete(context, service.id!),
                ),
              ),
            );
          },
        );
      }),
    );
  }

  // --- HÀM _showAddDialog ĐÃ NÂNG CẤP (VALIDATE + FIX NÚT HỦY) ---
  void _showAddDialog(BuildContext context) {
    // 1. Reset dữ liệu cũ
    controller.selectedColor.value = '0xFF2196F3';
    controller.nameController.clear();
    controller.priceController.clear();
    controller.durationController.text = "30";

    // 2. Tạo Key để quản lý Validate form
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    // 3. Hiển thị Dialog
    showDialog(
      context: context,
      barrierDismissible: false, // Bắt buộc bấm nút mới được đóng
      builder: (context) {
        return AlertDialog(
          title: const Text("Dịch Vụ Mới", style: TextStyle(fontWeight: FontWeight.bold)),
          
          // Bọc nội dung trong Form để dùng tính năng Validate
          content: Form(
            key: formKey, // Gắn key vào đây
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),

                  // --- TÊN DỊCH VỤ (Có validate) ---
                  TextFormField(
                    controller: controller.nameController,
                    decoration: const InputDecoration(
                      labelText: "Tên dịch vụ *",
                      hintText: "VD: Cắt tóc, Sân 5...",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.edit),
                    ),
                    // Logic kiểm tra lỗi
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Vui lòng nhập tên dịch vụ"; // Hiện chữ đỏ
                      }
                      return null; // Hợp lệ
                    },
                  ),
                  const SizedBox(height: 15),

                  // --- GIÁ & THỜI GIAN ---
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: controller.priceController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: "Giá (VNĐ) *",
                            border: OutlineInputBorder(),
                            suffixText: "đ",
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) return "Nhập giá";
                            if (double.tryParse(value) == null) return "Phải là số";
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          controller: controller.durationController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: "Thời gian *",
                            border: OutlineInputBorder(),
                            suffixText: "phút",
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) return "Nhập phút";
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                  const Text("Chọn màu hiển thị:", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),

                  // --- BỘ CHỌN MÀU ---
                  Center(
                    child: Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      alignment: WrapAlignment.center,
                      children: controller.colorPalette.map((colorHex) {
                        return GestureDetector(
                          onTap: () => controller.selectedColor.value = colorHex,
                          child: Obx(() {
                            bool isSelected = controller.selectedColor.value == colorHex;
                            return Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: Color(int.parse(colorHex)),
                                shape: BoxShape.circle,
                                border: isSelected ? Border.all(color: Colors.black, width: 3) : null,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  )
                                ],
                              ),
                              child: isSelected
                                  ? const Icon(Icons.check, size: 20, color: Colors.white)
                                  : null,
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
            // --- NÚT HỦY (Fix lỗi không đóng) ---
            TextButton(
              onPressed: () {
                // Dùng lệnh gốc của Flutter -> Chắc chắn đóng 100%
                Navigator.of(context).pop();
              },
              child: const Text("Hủy", style: TextStyle(color: Colors.grey)),
            ),

            // --- NÚT LƯU (Có kiểm tra validate) ---
            ElevatedButton(
              onPressed: () {
                // Kiểm tra form có hợp lệ không?
                if (formKey.currentState!.validate()) {
                  Navigator.of(context).pop(); // Đóng Dialog trước
                  controller.addService();     // Gọi hàm thêm sau
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              child: const Text("Lưu Dịch Vụ", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // --- HÀM SỬA LỖI: Popup xóa ---
  // --- SỬA LẠI HÀM NÀY (QUAN TRỌNG) ---
  void _confirmDelete(BuildContext context, String id) {
    showDialog( // Dùng showDialog gốc của Flutter thay vì Get.dialog
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Xóa dịch vụ?", style: TextStyle(color: Colors.red)),
          content: const Text("Hành động này không thể hoàn tác."),
          actions: [
            // Nút Giữ lại
            TextButton(
              onPressed: () {
                // Dùng lệnh gốc của Flutter -> Chắc chắn đóng 100%
                Navigator.of(context).pop(); 
              },
              child: const Text("Giữ lại", style: TextStyle(color: Colors.grey)),
            ),
            
            // Nút Xóa ngay
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Đóng dialog trước
                controller.deleteService(id); // Sau đó mới gọi controller xóa
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text("Xóa ngay", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}