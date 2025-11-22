import 'package:cloud_firestore/cloud_firestore.dart';

class ShopModel {
  String uid; // ID trùng với User ID
  String phone;
  String name;
  String industry; // 'spa', 'field', 'salon'...
  String? avatarUrl;
  Map<String, dynamic> workingHours; // Lưu cấu hình giờ mở cửa
  bool isActive;

  ShopModel({
    required this.uid,
    required this.phone,
    required this.name,
    required this.industry,
    this.avatarUrl,
    this.workingHours = const {},
    this.isActive = true,
  });

  factory ShopModel.fromJson(Map<String, dynamic> json, String id) {
    return ShopModel(
      uid: id,
      phone: json['phone'] ?? '',
      name: json['shop_name'] ?? '',
      industry: json['industry'] ?? 'other',
      avatarUrl: json['avatar_url'],
      workingHours: json['working_hours'] ?? {},
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'phone': phone,
      'shop_name': name,
      'industry': industry,
      'avatar_url': avatarUrl,
      'working_hours': workingHours,
      'is_active': isActive,
      'created_at': FieldValue.serverTimestamp(),
    };
  }
}