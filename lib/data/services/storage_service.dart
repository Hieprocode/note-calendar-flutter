import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/config/supabase_config.dart';

class StorageService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Hàm upload ảnh và trả về link Public
  Future<String> uploadShopLogo(File imageFile, String userId) async {
    try {
      final fileExt = imageFile.path.split('.').last; // Lấy đuôi file (jpg, png)
      final fileName = '$userId/logo_${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      
      // 1. Upload lên Bucket 'shop-images'
      await _supabase.storage
          .from(SupabaseConfig.bucketName) // 'shop-images'
          .upload(fileName, imageFile);

      // 2. Lấy link Public để lưu vào Firestore
      final imageUrl = _supabase.storage
          .from(SupabaseConfig.bucketName)
          .getPublicUrl(fileName);
          
      return imageUrl;
    } catch (e) {
      throw Exception("Lỗi Upload ảnh: $e");
    }
  }

  // Upload avatar khách hàng
  Future<String> uploadCustomerAvatar(File imageFile, String userId, String customerPhone) async {
    try {
      final fileExt = imageFile.path.split('.').last;
      final fileName = '$userId/customers/${customerPhone}_avatar_${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      
      // Upload lên Bucket
      await _supabase.storage
          .from(SupabaseConfig.bucketName)
          .upload(fileName, imageFile);

      // Lấy link Public
      final imageUrl = _supabase.storage
          .from(SupabaseConfig.bucketName)
          .getPublicUrl(fileName);
          
      return imageUrl;
    } catch (e) {
      throw Exception("Lỗi Upload avatar khách hàng: $e");
    }
  }

  Future<dynamic> init() async {}
}