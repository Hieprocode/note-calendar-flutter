import 'package:cloud_firestore/cloud_firestore.dart';

class ServiceModel {
  String? id;
  String shopId;
  String name;
  double price;
  int durationMinutes; // 30, 45, 60, 90...
  String colorHex; // Màu hiển thị trên lịch (VD: #FF0000)
  bool isActive;   // True: Đang dùng, False: Đã xóa mềm

  ServiceModel({
    this.id,
    required this.shopId,
    required this.name,
    required this.price,
    required this.durationMinutes,
    this.colorHex = '#3498db', // Mặc định xanh dương
    this.isActive = true,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json, String id) {
    return ServiceModel(
      id: id,
      shopId: json['shop_id'] ?? '',
      name: json['name'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      durationMinutes: json['duration'] ?? 30,
      colorHex: json['color_hex'] ?? '#3498db',
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'shop_id': shopId,
      'name': name,
      'price': price,
      'duration': durationMinutes,
      'color_hex': colorHex,
      'is_active': isActive,
      'created_at': FieldValue.serverTimestamp(),
    };
  }
}