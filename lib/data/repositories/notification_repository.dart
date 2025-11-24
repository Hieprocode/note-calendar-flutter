// lib/data/repositories/notification_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notification_model.dart';

class NotificationRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Lấy thông báo (Sắp xếp mới nhất lên đầu)
  Stream<List<NotificationModel>> getNotifications(String shopId) {
    return _firestore
        .collection('notifications')
        .where('shop_id', isEqualTo: shopId)
        .orderBy('created_at', descending: true)
        .limit(20) // Chỉ lấy 20 cái mới nhất
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => NotificationModel.fromJson(doc.data(), doc.id))
            .toList());
  }

  // Đánh dấu đã đọc
  Future<void> markAsRead(String id) async {
    await _firestore.collection('notifications').doc(id).update({'is_read': true});
  }
}