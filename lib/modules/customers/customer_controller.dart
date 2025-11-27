// lib/modules/customers/customer_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/base/base_controller.dart';
import '../../data/models/customer_model.dart';
import '../../data/repositories/customer_repository.dart';
import '../booking/booking_controller.dart';

class CustomerController extends BaseController {
  final CustomerRepository _customerRepo = Get.find<CustomerRepository>();

  var filteredCustomers = <CustomerModel>[].obs;
  var allCustomers = <CustomerModel>[].obs;

  final searchController = TextEditingController();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final noteController = TextEditingController();
  
  var isBadGuest = false.obs;
  String? editingId;

  @override
  void onInit() {
    super.onInit();
    final uid = FirebaseAuth.instance.currentUser?.uid ?? "";
    if (uid.isEmpty) return;

    _customerRepo.getCustomersStream(uid).listen((data) {
      allCustomers.assignAll(data);
      filterCustomers(); // GỌI HÀM MỚI
    });

    searchController.addListener(filterCustomers); // GỌI HÀM MỚI
  }

  // HÀM MỚI – GIẢI QUYẾT LỖI 100%
  void filterCustomers() {
    final query = searchController.text.toLowerCase();
    if (query.isEmpty) {
      filteredCustomers.assignAll(allCustomers);
    } else {
      final result = allCustomers.where((c) =>
        c.name.toLowerCase().contains(query) ||
        c.phone.contains(query)
      ).toList();
      filteredCustomers.assignAll(result);
    }
  }

  void prepareForm({CustomerModel? customer}) {
    if (customer != null) {
      editingId = customer.id;
      nameController.text = customer.name;
      phoneController.text = customer.phone;
      noteController.text = customer.note ?? "";
      isBadGuest.value = customer.isBadGuest;
    } else {
      editingId = null;
      nameController.clear();
      phoneController.clear();
      noteController.clear();
      isBadGuest.value = false;
    }
  }

  Future<bool> saveCustomer() async {
    if (nameController.text.trim().isEmpty || phoneController.text.trim().isEmpty) {
      Get.snackbar("Lỗi", "Vui lòng nhập tên và số điện thoại",
          backgroundColor: Colors.redAccent, colorText: Colors.white);
      return false;
    }

    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final phone = phoneController.text.trim();
      final docId = editingId ?? "${uid}_$phone";

      final customer = CustomerModel(
        id: docId,
        shopId: uid,
        name: nameController.text.trim(),
        phone: phone,
        note: noteController.text.trim().isEmpty ? null : noteController.text.trim(),
        isBadGuest: isBadGuest.value,
        totalBookings: editingId != null
            ? (allCustomers.firstWhereOrNull((c) => c.id == editingId)?.totalBookings ?? 0)
            : 0,
      );
      await _customerRepo.saveCustomer(customer);
      Get.rawSnackbar(
        message: editingId == null ? "Đã thêm khách hàng!" : "Cập nhật thành công!",
        backgroundColor: Colors.green,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 2),
      );
      return true;
    } catch (e) {
      Get.snackbar("Lỗi", "Không thể lưu khách hàng", backgroundColor: Colors.red);
      return false;
    }
  }

  Future<bool> deleteCustomer(String id) async {
    try {
      await _customerRepo.deleteCustomer(id);
      Get.rawSnackbar(message: "Đã xóa khách hàng!", backgroundColor: Colors.red,
          snackPosition: SnackPosition.TOP, margin: const EdgeInsets.all(16), borderRadius: 12);
      return true;
    } catch (e) {
      Get.snackbar("Lỗi", "Không thể xóa", backgroundColor: Colors.red);
      return false;
    }
  }

  @override
  void onClose() {
    searchController.dispose();
    nameController.dispose();
    phoneController.dispose();
    noteController.dispose();
    super.onClose();
  }
}