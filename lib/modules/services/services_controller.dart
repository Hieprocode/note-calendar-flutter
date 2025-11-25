// lib/modules/services/services_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/base/base_controller.dart';
import '../../data/models/service_model.dart';
import '../../data/repositories/service_repository.dart';

class ServicesController extends BaseController {
  final ServiceRepository _serviceRepo = Get.find<ServiceRepository>();

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
    final uid = FirebaseAuth.instance.currentUser!.uid;

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

  // === XÓA DỊCH VỤ ===
  Future<void> deleteService(String id) async {
    await safeCall(() async {
      await _serviceRepo.deleteService(id);
      showSuccess("Đã xóa dịch vụ");
    });
  }

  @override
  void onClose() {
    nameController.dispose();
    priceController.dispose();
    durationController.dispose();
    super.onClose();
  }
}