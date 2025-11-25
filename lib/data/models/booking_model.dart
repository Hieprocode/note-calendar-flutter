// lib/data/models/booking_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class BookingModel {
  String? id;
  final String shopId;
  final String customerName;
  final String customerPhone;
  final String serviceId;
  final String serviceName;
  final double servicePrice;
  final int durationMinutes;
  final DateTime startTime;
  final DateTime endTime;
  final String status;
  final String source;

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
    this.status = 'confirmed',
    this.source = 'manual',
  });

  factory BookingModel.fromJson(Map<String, dynamic> json, String id) {
    return BookingModel(
      id: id,
      shopId: json['shop_id'] ?? '',
      customerName: json['customer_name'] ?? '',
      customerPhone: json['customer_phone'] ?? '',
      serviceId: json['service_id'] ?? '',
      serviceName: json['service_name'] ?? '',
      servicePrice: (json['service_price'] as num?)?.toDouble() ?? 0.0,
      durationMinutes: json['duration'] ?? 30,
      startTime: (json['start_time'] as Timestamp).toDate(),
      endTime: (json['end_time'] as Timestamp).toDate(),
      status: json['status'] ?? 'pending',
      source: json['source'] ?? 'manual',
    );
  }

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
    };
  }

  /// HÀM QUAN TRỌNG: DÙNG ĐỂ TẠO BẢN SAO CÓ ID SAU KHI ADD
  BookingModel copyWith({
    String? id,
    String? shopId,
    String? customerName,
    String? customerPhone,
    String? serviceId,
    String? serviceName,
    double? servicePrice,
    int? durationMinutes,
    DateTime? startTime,
    DateTime? endTime,
    String? status,
    String? source,
  }) {
    return BookingModel(
      id: id ?? this.id,
      shopId: shopId ?? this.shopId,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      serviceId: serviceId ?? this.serviceId,
      serviceName: serviceName ?? this.serviceName,
      servicePrice: servicePrice ?? this.servicePrice,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      status: status ?? this.status,
      source: source ?? this.source,
    );
  }
}