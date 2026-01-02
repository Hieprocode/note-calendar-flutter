// lib/modules/services/services_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/base/base_controller.dart';
import '../../data/models/service_model.dart';
import '../../data/repositories/service_repository.dart';
import '../../data/repositories/booking_repository.dart';

class ServicesController extends BaseController {
  final ServiceRepository _serviceRepo = Get.find<ServiceRepository>();
  final BookingRepository _bookingRepo = Get.find<BookingRepository>();

  // Danh sách dịch vụ realtime
  var servicesList = <ServiceModel>[].obs;

  // Form
  final nameController = TextEditingController();
  final priceController = TextEditingController();
  final durationController = TextEditingController(text: "30");

  var selectedColor = '0xFF2196F3'.obs;

  final List<String> colorPalette = [
    '0xFF2196F3', '0xFFF44336', '0xFFE91E63', '0xFF9C27B0',
    '0xFF009688', '0xFF4CAF50', '0xFFFF9800', '0xFF795548',
    '0xFF607D8B', '0xFF3F51B5',
  ];

  // Biến tạm để biết đang sửa dịch vụ nào
  ServiceModel? _editingService;

  @override
  void onInit() {
    super.onInit();
    final uid = FirebaseAuth.instance.currentUser?.uid ?? "";
    servicesList.bindStream(_serviceRepo.getServicesStream(uid));
  }

  // === CHUẨN BỊ SỬA ===
  void prepareEdit(ServiceModel service) {
    nameController.text = service.name;
    priceController.text = service.price.toStringAsFixed(0);
    durationController.text = service.durationMinutes.toString();
    selectedColor.value = service.colorHex;
    _editingService = service;
  }

  // === RESET FORM (public để View gọi được) ===
  void resetForm() {
    nameController.clear();
    priceController.clear();
    durationController.text = "30";
    selectedColor.value = '0xFF2196F3';
    _editingService = null;
  }

  // === HÀM LƯU CHUNG (THÊM + SỬA) – PUBLIC ===
  Future<void> saveService({BuildContext? context}) async {
  final name = nameController.text.trim();
  final priceText = priceController.text.trim();
  final durationText = durationController.text.trim();

  if (name.isEmpty) {
    showError("Vui lòng nhập tên dịch vụ");
    return;
  }
  if (priceText.isEmpty || double.tryParse(priceText) == null) {
    showError("Giá không hợp lệ");
    return;
  }

  // ĐÓNG DIALOG NGAY – DÙNG NAVIGATOR
  if (context != null) {
    Navigator.of(context).pop();
  } else if (Get.context != null) {
    Navigator.of(Get.context!).pop();
  }

  FocusManager.instance.primaryFocus?.unfocus();

  await safeCall(() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      showError("Vui lòng đăng nhập lại");
      return;
    }
    final uid = user.uid;

    final service = ServiceModel(
      id: _editingService?.id,
      shopId: uid,
      name: name,
      price: double.parse(priceText),
      durationMinutes: int.tryParse(durationText) ?? 30,
      colorHex: selectedColor.value,
      isActive: true,
    );

    if (_editingService == null) {
      await _serviceRepo.createService(service);
      showSuccess("Đã thêm dịch vụ: $name");
    } else {
      await _serviceRepo.updateService(service);
      showSuccess("Đã cập nhật dịch vụ: $name");
    }

    resetForm();
  });
}

  Future<void> deleteService(String id, {bool forceDelete = false}) async {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? "";
    if (uid.isEmpty) return;

    // Kiểm tra số lượng booking đang sử dụng service này
    final bookingCount = await _bookingRepo.countBookingsByService(uid, id);

    if (bookingCount > 0 && !forceDelete) {
      // Hiển thị dialog cảnh báo
      _showDeleteWarningDialog(id, bookingCount);
      return;
    }

    // Xóa service (và booking nếu forceDelete = true)
    await safeCall(() async {
      if (forceDelete && bookingCount > 0) {
        // Xóa tất cả booking liên quan
        final deletedCount = await _bookingRepo.deleteBookingsByService(uid, id);
        print("Đã xóa $deletedCount booking");
      }

      // Xóa service
      await _serviceRepo.deleteService(id);
      
      if (forceDelete && bookingCount > 0) {
        showSuccess("Đã xóa dịch vụ và $bookingCount lịch hẹn");
      } else {
        showSuccess("Đã xóa dịch vụ");
      }
    });
  }

  void _showDeleteWarningDialog(String serviceId, int bookingCount) {
    final service = servicesList.firstWhere((s) => s.id == serviceId);
    
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.warning_rounded,
                color: Colors.orange,
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                "Cảnh báo!",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Dịch vụ \"${service.name}\" đang được sử dụng trong:",
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.event_note, color: Colors.orange, size: 24),
                  const SizedBox(width: 12),
                  Text(
                    "$bookingCount lịch hẹn",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Bạn có muốn:",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              "• Xóa dịch vụ và TẤT CẢ lịch hẹn liên quan",
              style: TextStyle(fontSize: 13, color: Colors.red),
            ),
            const SizedBox(height: 4),
            const Text(
              "• Hoặc hủy bỏ thao tác xóa",
              style: TextStyle(fontSize: 13),
            ),
          ],
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.of(Get.context!).pop(),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              side: BorderSide(color: Colors.grey.shade400),
            ),
            child: const Text(
              "Hủy bỏ",
              style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(Get.context!).pop(); // Đóng dialog
              deleteService(serviceId, forceDelete: true); // Xóa tất cả
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
            child: const Text(
              "Xóa tất cả",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  @override
  void onClose() {
    nameController.dispose();
    priceController.dispose();
    durationController.dispose();
    super.onClose();
  }
}