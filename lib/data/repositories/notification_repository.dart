import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notification_model.dart';

class NotificationRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'notifications'; // Hằng số tên collection

  // 1. TẠO THÔNG BÁO MỚI (Hàm bạn đang thiếu)
  Future<void> createNotification(NotificationModel noti) async {
    try {
      await _firestore.collection(_collection).add(noti.toJson());
    } catch (e) {
      print("Lỗi tạo thông báo: $e");
    }
  }

  // 2. LẤY DANH SÁCH (Stream Realtime)
  Stream<List<NotificationModel>> getNotificationsStream(String shopId) {
    return _firestore
        .collection(_collection)
        .where('shop_id', isEqualTo: shopId)
        .orderBy('created_at', descending: true) // Mới nhất lên đầu
        .limit(50) // Lấy 50 tin gần nhất
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => NotificationModel.fromJson(doc.data(), doc.id))
            .toList());
  }

  // 3. ĐÁNH DẤU ĐÃ ĐỌC
  Future<void> markAsRead(String id) async {
    await _firestore.collection(_collection).doc(id).update({'is_read': true});
  }
  
  // 4. XÓA THÔNG BÁO (Nếu cần)
  Future<void> deleteNotification(String id) async {
    await _firestore.collection(_collection).doc(id).delete();
  }
}