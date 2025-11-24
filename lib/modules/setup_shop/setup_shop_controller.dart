import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/base/base_controller.dart';
import '../../data/models/shop_model.dart';
import '../../data/repositories/shop_repository.dart';
import '../../data/services/storage_service.dart';
import '../../routes/app_routes.dart';

class SetupShopController extends BaseController {
  final ShopRepository _shopRepo = ShopRepository();
  final StorageService _storageService = StorageService();

  final nameController = TextEditingController();
  // THAY ĐỔI: Dùng Controller nhập tay thay vì biến chọn Dropdown
  final industryController = TextEditingController(); 
  
  var selectedImage = Rxn<File>();

  // Hàm chọn ảnh (Giữ nguyên)
  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      selectedImage.value = File(pickedFile.path);
    }
  }

  // Hàm Lưu Shop
  Future<void> createShop() async {
    String name = nameController.text.trim();
    String industry = industryController.text.trim(); // Lấy dữ liệu nhập tay

    if (name.isEmpty) {
      showError("Vui lòng nhập tên cửa hàng");
      return;
    }
    if (industry.isEmpty) {
      showError("Vui lòng nhập ngành nghề kinh doanh");
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();

    await safeCall(() async {
      String uid = FirebaseAuth.instance.currentUser!.uid;
      String phone = FirebaseAuth.instance.currentUser!.phoneNumber ?? "";
      String? avatarUrl;

      if (selectedImage.value != null) {
        avatarUrl = await _storageService.uploadShopLogo(selectedImage.value!, uid);
      }

      ShopModel newShop = ShopModel(
        uid: uid,
        phone: phone,
        name: name,
        industry: industry, // Lưu cái họ vừa nhập vào
        avatarUrl: avatarUrl,
        workingHours: {},
      );

      await _shopRepo.createShop(newShop);
      Get.offAllNamed(AppRoutes.DASHBOARD);
    });
  }
}