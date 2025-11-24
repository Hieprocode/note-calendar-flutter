// lib/data/repositories/service_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/service_model.dart';

class ServiceRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Lấy danh sách dịch vụ của Shop (Stream để tự update khi có thay đổi)
  Stream<List<ServiceModel>> getServicesStream(String shopId) {
    return _firestore
        .collection('services')
        .where('shop_id', isEqualTo: shopId)
        .where('is_active', isEqualTo: true) // Chỉ lấy cái đang hoạt động
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ServiceModel.fromJson(doc.data(), doc.id))
            .toList());
  }

  // Thêm dịch vụ mới
  Future<void> createService(ServiceModel service) async {
    await _firestore.collection('services').add(service.toJson());
  }

  // Cập nhật dịch vụ
  Future<void> updateService(ServiceModel service) async {
    await _firestore.collection('services').doc(service.id).update(service.toJson());
  }

  // Xóa mềm (Chỉ ẩn đi chứ không xóa mất data)
  Future<void> deleteService(String id) async {
    await _firestore.collection('services').doc(id).update({'is_active': false});
  }
}