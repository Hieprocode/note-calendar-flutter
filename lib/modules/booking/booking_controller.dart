// lib/modules/booking/booking_controller.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  final NotificationService _notiService = Get.find<NotificationService>();
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

      // TÌM KHÁCH CŨ
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
        // CHỈ SỬA LỊCH
        await _bookingRepo.updateBooking(booking);
      } else {
        // TẠO MỚI LỊCH
        await _bookingRepo.createBooking(booking);

        if (existingCustomer != null) {
          // KHÁCH CŨ -> Update dùng ID thật
          await _customerRepo.incrementBookingCount(existingCustomer.id);
        } else {
          // KHÁCH MỚI -> Tạo mới (Dùng ID Unique: uid_phone)
          final newCustomer = CustomerModel(
            id: "${uid}_$phone", // <--- CHỖ NÀY SỬA LẠI CHO AN TOÀN
            shopId: uid,
            name: nameController.text.trim(),
            phone: phone,
            totalBookings: 1,
            isBadGuest: false,
          );
          await _customerRepo.saveCustomer(newCustomer);
        }

        // TẠO THÔNG BÁO
        try {
          NotificationModel noti = NotificationModel(
            shopId: uid,
            title: "Lịch hẹn mới",
            body: "${nameController.text} - ${selectedService.value?.name} lúc ${selectedTime.value.format(Get.context!)}",
            type: "new_booking",
            isRead: false,
            createdAt: DateTime.now(),
          );
          await _notiRepo.createNotification(noti);
        } catch (e) {
          print("Lỗi tạo noti: $e");
        }
        await _notiService.scheduleBookingReminder(
          id: booking.hashCode,
          customerName: booking.customerName,
          bookingTime: booking.startTime,
        );
        await NotificationService().showNotification(
        title: "Có khách đặt lịch mới!",
        body: "${nameController.text.trim()} • ${selectedService.value!.name} • ${DateFormat('HH:mm').format(start)}",
      );
      }

      // --- KẾT THÚC QUY TRÌNH ---
      
      // 1. Kích hoạt cập nhật UI (nếu Calendar lắng nghe biến này)
      BookingController.triggerRefresh.value++;

      // 2. Đóng màn hình
      
      
      // 3. Hiện thông báo thành công
      Get.rawSnackbar(
        message: isEditMode.value ? "Cập nhật thành công!" : "Đã thêm lịch hẹn!",
        backgroundColor: Colors.green,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 2),
      );

      // 4. Reset form nếu tạo mới
      if (!isEditMode.value) {
        resetFormForAdd();
      }
    });
    Get.back();
    }
    Future<void> changeBookingStatus(String bookingId, String newStatus) async {
    try {
      // 1. Cập nhật status lên Firestore
      await _bookingRepo.updateStatus(bookingId, newStatus);

      // 2. Lấy thông tin booking để tạo thông báo đẹp
      final booking = await _bookingRepo.getBookingById(bookingId);
      if (booking == null) return;

      final customerName = booking.customerName;
      final serviceName = booking.serviceName;
      final timeStr = DateFormat('HH:mm • dd/MM').format(booking.startTime);

      // 3. Nội dung thông báo theo từng trạng thái
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

      // 4. Lưu thông báo vào Firestore (hiện trong tab Hoạt Động)
      await _notiRepo.createNotification(NotificationModel(
        shopId: booking.shopId,
        title: title,
        body: "$customerName • $serviceName • $timeStr",
        type: type,
        isRead: false,
        createdAt: DateTime.now(),
      ));

      // 5. THÔNG BÁO NGOÀI MÀN HÌNH KHÓA NGAY LẬP TỨC
      await NotificationService().showNotification(
        title: title,
        body: "$customerName • $serviceName • $timeStr",
      );

      // 6. Cập nhật UI
      BookingController.triggerRefresh.value++;

      Get.snackbar("Thành công", "Đã cập nhật trạng thái", 
          backgroundColor: Colors.green, colorText: Colors.white);

    } catch (e) {
      Get.snackbar("Lỗi", "Không thể cập nhật", 
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