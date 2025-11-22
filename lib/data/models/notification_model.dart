import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  String? id;
  String shopId;
  String title; // Ví dụ: "Có khách mới đặt lịch!"
  String body;  // Ví dụ: "Anh Tuấn vừa đặt Sân 5 lúc 17:00"
  String type;  // 'new_booking', 'cancel', 'system'
  String? relatedBookingId; // ID đơn hàng liên quan (bấm vào thông báo nhảy tới đơn đó)
  bool isRead;  // Đã xem chưa
  DateTime? createdAt;

  NotificationModel({
    this.id,
    required this.shopId,
    required this.title,
    required this.body,
    required this.type,
    this.relatedBookingId,
    this.isRead = false,
    this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json, String id) {
    return NotificationModel(
      id: id,
      shopId: json['shop_id'] ?? '',
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      type: json['type'] ?? 'system',
      relatedBookingId: json['related_booking_id'],
      isRead: json['is_read'] ?? false,
      createdAt: json['created_at'] != null 
          ? (json['created_at'] as Timestamp).toDate() 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'shop_id': shopId,
      'title': title,
      'body': body,
      'type': type,
      'related_booking_id': relatedBookingId,
      'is_read': isRead,
      'created_at': createdAt != null 
          ? Timestamp.fromDate(createdAt!) 
          : FieldValue.serverTimestamp(),
    };
  }
}