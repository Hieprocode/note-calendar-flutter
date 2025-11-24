import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/base/base_controller.dart';
import '../../data/models/service_model.dart';
import '../../data/repositories/service_repository.dart';

class ServicesController extends BaseController {
  // Lấy ServiceRepo từ bộ nhớ (đã inject ở InitialBinding)
  final ServiceRepository _serviceRepo = Get.find<ServiceRepository>();

  // Danh sách dịch vụ (Tự động cập nhật từ Firestore)
  var servicesList = <ServiceModel>[].obs;

  // Các Controller nhập liệu
  final nameController = TextEditingController();
  final priceController = TextEditingController();
  final durationController = TextEditingController(text: "30"); // Mặc định 30 phút

  // --- LOGIC MỚI: CHỌN MÀU ---
  
  // Biến lưu màu đang chọn (Mặc định là Xanh dương)
  var selectedColor = '0xFF2196F3'.obs; 

  // Bảng màu (Palette) để hiện lên cho người dùng chọn
  final List<String> colorPalette = [
    '0xFF2196F3', // Xanh dương (Mặc định)
    '0xFFF44336', // Đỏ
    '0xFFE91E63', // Hồng
    '0xFF9C27B0', // Tím
    '0xFF009688', // Xanh ngọc
    '0xFF4CAF50', // Xanh lá
    '0xFFFF9800', // Cam
    '0xFF795548', // Nâu
    '0xFF607D8B', // Xám xanh
    '0xFF3F51B5', // Xanh đậm
  ];

  @override
  void onInit() {
    super.onInit();
    // 1. Lấy UID người dùng hiện tại
    String uid = FirebaseAuth.instance.currentUser?.uid ?? "";
    
    // 2. Lắng nghe dữ liệu realtime (Bind Stream)
    // Truyền uid vào để chỉ lấy dịch vụ của Shop này
    servicesList.bindStream(_serviceRepo.getServicesStream(uid));
  }

  // Hàm Thêm Dịch Vụ
  Future<void> addService() async {
    String name = nameController.text.trim();
    String priceStr = priceController.text.trim();
    String durationStr = durationController.text.trim();

    // Validate cơ bản
    if (name.isEmpty) {
      showError("Vui lòng nhập tên dịch vụ");
      return;
    }
    if (priceStr.isEmpty) {
      showError("Vui lòng nhập giá tiền");
      return;
    }

    // Đóng Dialog trước khi xử lý
    Get.back(); 
    
    // Ẩn bàn phím
    FocusManager.instance.primaryFocus?.unfocus();

    await safeCall(() async {
      String uid = FirebaseAuth.instance.currentUser!.uid;
      
      // Tạo Model mới
      ServiceModel newService = ServiceModel(
        shopId: uid,
        name: name,
        price: double.tryParse(priceStr) ?? 0,
        durationMinutes: int.tryParse(durationStr) ?? 30,
        colorHex: selectedColor.value, // <--- LƯU MÀU ĐÃ CHỌN
        isActive: true,
      );

      // Gửi sang Repo để lưu xuống Firestore
      await _serviceRepo.createService(newService);
      
      // Reset Form về mặc định để nhập cái tiếp theo
      nameController.clear();
      priceController.clear();
      durationController.text = "30";
      selectedColor.value = '0xFF2196F3'; // Reset về màu xanh
      
      showSuccess("Đã thêm dịch vụ: $name");
    });
  }

  // Hàm Xóa Dịch Vụ (Xóa mềm)
  Future<void> deleteService(String id) async {
    await safeCall(() async {
      await _serviceRepo.deleteService(id);
      showSuccess("Đã xóa dịch vụ");
    });
  }
  
  @override
  void onClose() {
    // Giải phóng controller khi không dùng nữa
    nameController.dispose();
    priceController.dispose();
    durationController.dispose();
    super.onClose();
  }
}