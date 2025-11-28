// lib/modules/booking/booking_controller.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/base/base_controller.dart';
import '../../data/models/booking_model.dart';
import '../../data/models/customer_model.dart';
import '../../data/models/service_model.dart';
import '../../data/repositories/booking_repository.dart';
import '../../data/repositories/customer_repository.dart';
import '../../data/repositories/service_repository.dart';

class BookingController extends BaseController {
  // Repos
  final BookingRepository _bookingRepo = Get.find<BookingRepository>();
  final CustomerRepository _customerRepo = Get.find<CustomerRepository>();
  final ServiceRepository _serviceRepo = Get.find<ServiceRepository>();

  // Form Inputs
  final phoneController = TextEditingController();
  final nameController = TextEditingController();
  final noteController = TextEditingController();

  // State Variables (Dùng .obs để UI tự cập nhật)
  var selectedDate = DateTime.now().obs;
  var selectedTime = TimeOfDay.now().obs;
  var endTime = TimeOfDay.now().obs;
  var servicesList = <ServiceModel>[].obs;
  var selectedService = Rxn<ServiceModel>();
  
  // Mode
  var isEditMode = false.obs;
  String? editingId;
  var paymentMethod = 'cash'.obs;
  var paymentStatus = 'unpaid'.obs;
  static final triggerRefresh = 0.obs;
  @override
  void onInit() {
    super.onInit();
    _loadServices();
    
    // Tự động tính giờ kết thúc
    ever(selectedTime, (_) => _calculateEndTime());
    ever(selectedService, (_) => _calculateEndTime());

    phoneController.addListener(_onPhoneChanged);

    // --- QUAN TRỌNG: LOAD DỮ LIỆU CŨ NẾU LÀ SỬA ---
    if (Get.arguments != null && Get.arguments is BookingModel) {
      fillDataForEdit(Get.arguments as BookingModel);
    }
  }

  void _loadServices() {
    String uid = FirebaseAuth.instance.currentUser?.uid ?? "";
    if (uid.isEmpty) return;
    servicesList.bindStream(_serviceRepo.getServicesStream(uid));
  }

  void resetFormForAdd() {
    isEditMode.value = false;

    nameController.clear();
    phoneController.clear();
    
    selectedService.value = null;
    selectedDate.value = DateTime.now();
    selectedTime.value = TimeOfDay.now();

    // Nếu bạn có thêm trường nào (note, staff, v.v.) thì clear ở đây luôn
    // noteController.clear();
  }

  void fillDataForEdit(BookingModel booking) {
    isEditMode.value = true;
    editingId = booking.id;
    
    nameController.text = booking.customerName;
    phoneController.text = booking.customerPhone;
    noteController.text = booking.note ?? "";
    
    // Cập nhật biến Rx để UI thay đổi theo
    selectedDate.value = booking.startTime;
    selectedTime.value = TimeOfDay.fromDateTime(booking.startTime);
    endTime.value = TimeOfDay.fromDateTime(booking.endTime);
    
    paymentMethod.value = booking.paymentMethod;
    paymentStatus.value = booking.paymentStatus;

    // Tạo object service tạm để Dropdown nhận diện
    selectedService.value = ServiceModel(
      shopId: booking.shopId,
      name: booking.serviceName,
      price: booking.servicePrice,
      durationMinutes: booking.durationMinutes,
      id: booking.serviceId,
    );
  }

  void _onPhoneChanged() async {
    if (isEditMode.value) return; 
    String phone = phoneController.text.trim();
    if (phone.length >= 10) {
      String uid = FirebaseAuth.instance.currentUser?.uid ?? "";
      if (uid.isNotEmpty) {
        var customer = await _customerRepo.findCustomerByPhone(phone, uid);
        if (customer != null) {
          nameController.text = customer.name;
        }
      }
    }
  }

  void selectService(ServiceModel service) => selectedService.value = service;
  void selectTime(TimeOfDay time) => selectedTime.value = time;

  void _calculateEndTime() {
    if (selectedService.value == null) {
      final start = _getDateTime(selectedDate.value, selectedTime.value);
      final end = start.add(const Duration(minutes: 30));
      endTime.value = TimeOfDay.fromDateTime(end);
      return;
    }
    final start = _getDateTime(selectedDate.value, selectedTime.value);
    final end = start.add(Duration(minutes: selectedService.value!.durationMinutes));
    endTime.value = TimeOfDay.fromDateTime(end);
  }

  DateTime _getDateTime(DateTime date, TimeOfDay time) {
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

//   Future<void> saveBooking() async {
//   if (nameController.text.isEmpty || selectedService.value == null) {
//     Get.snackbar("Lỗi", "Vui lòng nhập tên và chọn dịch vụ", backgroundColor: Colors.redAccent, colorText: Colors.white);
//     return;
//   }

//   await safeCall(() async {
//     String uid = FirebaseAuth.instance.currentUser!.uid;
//     final start = _getDateTime(selectedDate.value, selectedTime.value);
//     final end = _getDateTime(selectedDate.value, endTime.value);

//     BookingModel booking = BookingModel(
//       id: editingId,
//       shopId: uid,
//       customerName: nameController.text,
//       customerPhone: phoneController.text,
//       serviceId: selectedService.value!.id!,
//       serviceName: selectedService.value!.name,
//       servicePrice: selectedService.value!.price,
//       durationMinutes: selectedService.value!.durationMinutes,
//       startTime: start,
//       endTime: end,
//       status: 'confirmed',
//       source: 'manual',
//       note: noteController.text,
//       paymentMethod: paymentMethod.value,
//       paymentStatus: paymentStatus.value,
//     );

//     if (isEditMode.value) {
//       await _bookingRepo.updateBooking(booking);
//       Get.back();
//       Get.snackbar("Thành công", "Đã cập nhật đơn hàng", backgroundColor: Colors.green, colorText: Colors.white);
//     } else {
//       await _bookingRepo.createBooking(booking);
      
//       // Lưu khách (giữ nguyên)
//       CustomerModel customer = CustomerModel(
//         id: "${uid}_${phoneController.text.trim()}",
//         shopId: uid,
//         name: nameController.text,
//         phone: phoneController.text,
//         totalBookings: 1,
//       );
//       _customerRepo.saveCustomer(customer);
//       _customerRepo.incrementBookingCount(customer.id);

//       // Reset form
//       nameController.clear();
//       phoneController.clear();
//       noteController.clear();
//       selectedService.value = null;
      
//       Get.rawSnackbar(message: "Đã thêm mới thành công! Nhập tiếp nào.", backgroundColor: Colors.green);
//     }

//     // DÒNG NÀY PHẢI ĐẶT Ở NGOÀI CẢ 2 NHÁNH (if/else) – QUAN TRỌNG NHẤT!
//     BookingController.triggerRefresh.value++;  // Cập nhật calendar dù thêm hay sửa
//     Get.back(); // ĐÓNG BOTTOM SHEET DÙ THÊM HAY SỬA!
//   });
// }

Future<void> saveBooking() async {
  if (nameController.text.trim().isEmpty || selectedService.value == null) {
    Get.snackbar("Lỗi", "Vui lòng nhập tên và chọn dịch vụ",
        backgroundColor: Colors.redAccent, colorText: Colors.white);
    return;
  }

  await safeCall(() async {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? "";
    if (uid.isEmpty) return;

    final phone = phoneController.text.trim();
    final start = _getDateTime(selectedDate.value, selectedTime.value);
    final end = _getDateTime(selectedDate.value, endTime.value);

    // TÌM KHÁCH CŨ TRONG FIRESTORE
    final existingCustomer = await _customerRepo.findCustomerByPhone(phone, uid);

    BookingModel booking = BookingModel(
      id: editingId,
      shopId: uid,
      customerName: nameController.text.trim(),
      customerPhone: phone,
      serviceId: selectedService.value!.id!,
      serviceName: selectedService.value!.name,
      servicePrice: selectedService.value!.price,
      durationMinutes: selectedService.value!.durationMinutes,
      startTime: start,
      endTime: end,
      status: 'confirmed',
      source: 'manual',
      note: noteController.text.trim().isEmpty ? null : noteController.text.trim(),
      paymentMethod: paymentMethod.value,
      paymentStatus: paymentStatus.value,
    );

    if (isEditMode.value) {
      // CHỈ SỬA LỊCH – KHÔNG ĐỘNG VÀO KHÁCH
      await _bookingRepo.updateBooking(booking);
    } else {
      // TẠO MỚI LỊCH
      await _bookingRepo.createBooking(booking);

      if (existingCustomer != null) {
        // KHÁCH CŨ → CHỈ TĂNG totalBookings (dùng hàm có sẵn)
        await _customerRepo.incrementBookingCount(phone);
      } else {
        // KHÁCH MỚI → TẠO MỚI VỚI totalBookings = 1
        final newCustomer = CustomerModel(
          id: phone,
          shopId: uid,
          name: nameController.text.trim(),
          phone: phone,
          totalBookings: 1,
          isBadGuest: false,
        );
        await _customerRepo.saveCustomer(newCustomer);
      }
    }

    // REALTIME TOÀN APP
    BookingController.triggerRefresh.value++;

    // ĐÓNG + THÔNG BÁO
    Get.back();
    Get.rawSnackbar(
      message: isEditMode.value ? "Cập nhật thành công!" : "Đã thêm lịch hẹn!",
      backgroundColor: Colors.green,
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 2),
    );

    // Reset form nếu tạo mới
    if (!isEditMode.value) {
      resetFormForAdd();
    }
  });
}
  @override
  void onClose() {
    phoneController.dispose();
    nameController.dispose();
    noteController.dispose();
    super.onClose();
  }
}