// lib/modules/booking/booking_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../core/base/base_controller.dart';
import '../../data/models/booking_model.dart';
import '../../data/models/customer_model.dart';
import '../../data/models/service_model.dart';
import '../../data/repositories/booking_repository.dart';
import '../../data/repositories/customer_repository.dart';
import '../../data/repositories/service_repository.dart';
import '../../data/repositories/notification_repository.dart';
import '../../data/models/notification_model.dart';
import '../../data/services/notification_service.dart';

class BookingController extends BaseController {
  // Repos
  final NotificationRepository _notiRepo = Get.find<NotificationRepository>();
  final BookingRepository _bookingRepo = Get.find<BookingRepository>();
  final CustomerRepository _customerRepo = Get.find<CustomerRepository>();
  final ServiceRepository _serviceRepo = Get.find<ServiceRepository>();
  final NotificationService _notiService = Get.find<NotificationService>();

  // Form Inputs
  final phoneController = TextEditingController();
  final nameController = TextEditingController();
  final noteController = TextEditingController();

  // State Variables
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
    
    // Load dữ liệu cũ nếu là sửa
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
    editingId = null;
    nameController.clear();
    phoneController.clear();
    noteController.clear();
    selectedService.value = null;
    selectedDate.value = DateTime.now();
    selectedTime.value = TimeOfDay.now();
    paymentMethod.value = 'cash';
    paymentStatus.value = 'unpaid';
  }

  void fillDataForEdit(BookingModel booking) {
    isEditMode.value = true;
    editingId = booking.id;
    
    nameController.text = booking.customerName;
    phoneController.text = booking.customerPhone;
    noteController.text = booking.note ?? "";
    
    selectedDate.value = booking.startTime;
    selectedTime.value = TimeOfDay.fromDateTime(booking.startTime);
    endTime.value = TimeOfDay.fromDateTime(booking.endTime);
    
    paymentMethod.value = booking.paymentMethod;
    paymentStatus.value = booking.paymentStatus;
    
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

  // ============================================================
  // 🔔 HÀM LƯU BOOKING VỚI NOTIFICATION ĐÃ TỐI ƯU
  // ============================================================
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

      // Tạo ID notification duy nhất (dùng timestamp)
      final notificationId = DateTime.now().millisecondsSinceEpoch % 2147483647;
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
        // ========== CHẾ ĐỘ SỬA ==========
        await _bookingRepo.updateBooking(booking);
        
        // Hủy thông báo cũ trước khi đặt lại
        await _notiService.cancelNotification(notificationId);
        
        // Đặt lại thông báo với thời gian mới
        await _scheduleNotification(booking, notificationId);
        
        Get.rawSnackbar(
          message: "Cập nhật lịch hẹn thành công!",
          backgroundColor: Colors.blue,
          snackPosition: SnackPosition.TOP,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
          duration: const Duration(seconds: 2),
        );
      } else {
        // ========== CHẾ ĐỘ TẠO MỚI ==========
        await _bookingRepo.createBooking(booking);
        
        // Xử lý khách hàng (cũ/mới)
        await _handleCustomer(uid, phone);
        
        // Tạo thông báo trong app (Firebase)
        await _createInAppNotification(uid, booking);
        
        // Đặt lịch nhắc nhở trước 15 phút
        await _scheduleNotification(booking, notificationId);
        
        // Hiện thông báo ngay lập tức
        await _notiService.showNotification(
          title: "Đặt lịch thành công!",
          body: "${nameController.text.trim()} • ${selectedService.value!.name} • ${DateFormat('HH:mm').format(start)}",
        );
        
        Get.rawSnackbar(
          message: "Đã thêm lịch hẹn!",
          backgroundColor: Colors.green,
          snackPosition: SnackPosition.TOP,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
          duration: const Duration(seconds: 2),
        );
        
        resetFormForAdd();
      }
      // Cập nhật UI
      BookingController.triggerRefresh.value++;
      Get.back();
    });
  }


  Future<void> _scheduleNotification(BookingModel booking, int notificationId) async {
    try {
      await _notiService.scheduleBookingReminder(
        id: notificationId,
        customerName: booking.customerName,
        bookingTime: booking.startTime,
      );
      print("✅ Đã đặt lịch nhắc nhở cho: ${booking.customerName} lúc ${booking.startTime}");
    } catch (e) {
      print("❌ Lỗi đặt lịch thông báo: $e");
    }
  }

  Future<void> _handleCustomer(String uid, String phone) async {
    try {
      final existingCustomer = await _customerRepo.findCustomerByPhone(phone, uid);
      
      if (existingCustomer != null) {
        // Khách cũ → tăng số lần đặt
        await _customerRepo.incrementBookingCount(existingCustomer.id);
      } else {
        // Khách mới → tạo mới
        final newCustomer = CustomerModel(
          id: "${uid}_$phone",
          shopId: uid,
          name: nameController.text.trim(),
          phone: phone,
          totalBookings: 1,
          isBadGuest: false,
        );
        await _customerRepo.saveCustomer(newCustomer);
      }
    } catch (e) {
      print("❌ Lỗi xử lý khách hàng: $e");
    }
  }


  Future<void> _createInAppNotification(String uid, BookingModel booking) async {
    try {
      NotificationModel noti = NotificationModel(
        shopId: uid,
        title: "Lịch hẹn mới",
        body: "${booking.customerName} - ${booking.serviceName} lúc ${selectedTime.value.format(Get.context!)}",
        type: "new_booking",
        isRead: false,
        createdAt: DateTime.now(),
      );
      await _notiRepo.createNotification(noti);
    } catch (e) {
      print("❌ Lỗi tạo thông báo trong app: $e");
    }
  }


  Future<void> changeBookingStatus(String bookingId, String newStatus) async {
    try {
      await _bookingRepo.updateStatus(bookingId, newStatus);
      
      final booking = await _bookingRepo.getBookingById(bookingId);
      if (booking == null) return;

      final timeStr = DateFormat('HH:mm • dd/MM').format(booking.startTime);
      
      String title = "";
      String type = "status_update";
      
      switch (newStatus) {
        case 'checked_in':
          title = "Khách đã đến tiệm";
          type = "checked_in";
          break;
        case 'completed':
          title = "Hoàn thành dịch vụ";
          type = "completed";
          break;
        default:
          title = "Cập nhật trạng thái";
      }

      // Lưu thông báo vào Firebase
      await _notiRepo.createNotification(NotificationModel(
        shopId: booking.shopId,
        title: title,
        body: "${booking.customerName} • ${booking.serviceName} • $timeStr",
        type: type,
        isRead: false,
        createdAt: DateTime.now(),
      ));

      // Hiện thông báo ngay lập tức
      await _notiService.showNotification(
        title: title,
        body: "${booking.customerName} • ${booking.serviceName} • $timeStr",
      );

      BookingController.triggerRefresh.value++;
      
      Get.snackbar("Thành công", "Đã cập nhật trạng thái", 
          backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      Get.snackbar("Lỗi", "Không thể cập nhật", 
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }


  Future<void> deleteBooking(String bookingId, DateTime bookingTime) async {
    try {
      // Hủy thông báo đã đặt lịch
      final notificationId = bookingTime.millisecondsSinceEpoch ~/ 1000;
      await _notiService.cancelNotification(notificationId);
      
      // Xóa booking khỏi database
      await _bookingRepo.deleteBooking(bookingId);
      
      BookingController.triggerRefresh.value++;
      
      Get.snackbar("Thành công", "Đã xóa lịch hẹn", 
          backgroundColor: Colors.orange, colorText: Colors.white);
    } catch (e) {
      Get.snackbar("Lỗi", "Không thể xóa", 
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  @override
  void onClose() {
    phoneController.dispose();
    nameController.dispose();
    noteController.dispose();
    super.onClose();
  }
}