import 'package:cloud_firestore/cloud_firestore.dart';

class BookingModel {
  String? id;
  String shopId;
  
  // Thông tin khách hàng (Lưu trực tiếp để đỡ phải join bảng)
  String customerName;
  String customerPhone;
  
  // Thông tin dịch vụ (Snapshot - Lưu cứng giá trị lúc đặt)
  String serviceId;
  String serviceName;
  double servicePrice;
  int durationMinutes;
  
  // Thời gian
  DateTime startTime;
  DateTime endTime;
  
  // Trạng thái & Nguồn
  String status; // 'pending', 'confirmed', 'completed', 'cancelled', 'noshow'
  String source; // 'manual' (chủ nhập), 'google_form' (khách đặt)
  String? note;
  
  DateTime? createdAt;

  BookingModel({
    this.id,
    required this.shopId,
    required this.customerName,
    required this.customerPhone,
    required this.serviceId,
    required this.serviceName,
    required this.servicePrice,
    required this.durationMinutes,
    required this.startTime,
    required this.endTime,
    this.status = 'confirmed', // Mặc định là đã xác nhận (nếu chủ nhập)
    this.source = 'manual',
    this.note,
    this.createdAt,
  });

  // Chuyển từ JSON (Firestore) -> Object
  factory BookingModel.fromJson(Map<String, dynamic> json, String id) {
    return BookingModel(
      id: id,
      shopId: json['shop_id'] ?? '',
      customerName: json['customer_name'] ?? 'Khách lẻ',
      customerPhone: json['customer_phone'] ?? '',
      serviceId: json['service_id'] ?? '',
      serviceName: json['service_name'] ?? '',
      servicePrice: (json['service_price'] ?? 0).toDouble(),
      durationMinutes: json['duration'] ?? 30,
      startTime: (json['start_time'] as Timestamp).toDate(),
      endTime: (json['end_time'] as Timestamp).toDate(),
      status: json['status'] ?? 'pending',
      source: json['source'] ?? 'manual',
      note: json['note'],
      createdAt: json['created_at'] != null 
          ? (json['created_at'] as Timestamp).toDate() 
          : null,
    );
  }

  // Chuyển từ Object -> JSON (Firestore)
  Map<String, dynamic> toJson() {
    return {
      'shop_id': shopId,
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'service_id': serviceId,
      'service_name': serviceName,
      'service_price': servicePrice,
      'duration': durationMinutes,
      'start_time': Timestamp.fromDate(startTime),
      'end_time': Timestamp.fromDate(endTime),
      'status': status,
      'source': source,
      'note': note,
      'created_at': createdAt != null 
          ? Timestamp.fromDate(createdAt!) 
          : FieldValue.serverTimestamp(), // Tự lấy giờ server
    };
  }
}