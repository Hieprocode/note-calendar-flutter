import 'package:cloud_firestore/cloud_firestore.dart';

class CustomerModel {
  String id; // Dùng luôn số điện thoại làm ID cho dễ tìm
  String shopId;
  String name;
  String phone;
  int totalBookings; // Tổng số lần đã đặt
  bool isBadGuest;   // Đánh dấu khách hay bùng kèo
  DateTime? lastBookingDate; // Ngày ghé gần nhất
  String? note; // Ghi chú riêng về khách (VD: Khách khó tính, hay tip...)
  String? avatarUrl; // Ảnh đại diện khách hàng

  CustomerModel({
    required this.id,
    required this.shopId,
    required this.name,
    required this.phone,
    this.totalBookings = 0,
    this.isBadGuest = false,
    this.lastBookingDate,
    this.note,
    this.avatarUrl,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json, String id) {
    return CustomerModel(
      id: id,
      shopId: json['shop_id'] ?? '',
      name: json['name'] ?? 'Khách ẩn danh',
      phone: json['phone'] ?? '',
      totalBookings: json['total_bookings'] ?? 0,
      isBadGuest: json['is_bad_guest'] ?? false,
      lastBookingDate: json['last_booking_date'] != null 
          ? (json['last_booking_date'] as Timestamp).toDate() 
          : null,
      note: json['note'],
      avatarUrl: json['avatar_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'shop_id': shopId,
      'name': name,
      'phone': phone,
      'total_bookings': totalBookings,
      'is_bad_guest': isBadGuest,
      'last_booking_date': lastBookingDate != null 
          ? Timestamp.fromDate(lastBookingDate!) 
          : null,
      'note': note,
      'avatar_url': avatarUrl,
      'updated_at': FieldValue.serverTimestamp(),
    };
  }
}