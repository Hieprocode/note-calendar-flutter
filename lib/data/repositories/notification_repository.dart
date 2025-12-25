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

  // 2. LẤY DANH SÁCH (Pagination - Load more)
  // Trả về Map với 'notifications' và 'lastDocument'
  Future<Map<String, dynamic>> getNotifications({
    required String shopId,
    DocumentSnapshot? lastDocument,
    int limit = 20,
  }) async {
    try {
      print("--> [REPO DEBUG] Querying notifications with shopId: $shopId, limit: $limit");
      
      Query query = _firestore
          .collection(_collection)
          .where('shop_id', isEqualTo: shopId)
          .orderBy('created_at', descending: true)
          .limit(limit);

      // Nếu có lastDocument, load tiếp từ vị trí đó
      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
        print("--> [REPO DEBUG] Using pagination with lastDocument");
      }

      final snapshot = await query.get();
      print("--> [REPO DEBUG] Query returned ${snapshot.docs.length} documents");
      
      final notifications = snapshot.docs
          .map((doc) => NotificationModel.fromJson(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
      
      return {
        'notifications': notifications,
        'lastDocument': snapshot.docs.isNotEmpty ? snapshot.docs.last : null,
      };
    } catch (e) {
      print("--> [REPO ERROR] Lỗi load notifications: $e");
      return {
        'notifications': <NotificationModel>[],
        'lastDocument': null,
      };
    }
  }

  // 2b. Stream cho realtime updates (chỉ dùng cho unread count)
  Stream<List<NotificationModel>> getNotificationsStream(String shopId) {
    return _firestore
        .collection(_collection)
        .where('shop_id', isEqualTo: shopId)
        .orderBy('created_at', descending: true)
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