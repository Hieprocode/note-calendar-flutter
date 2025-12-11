import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/base/base_controller.dart';
import '../../data/models/notification_model.dart';
import '../../data/repositories/notification_repository.dart';

class NotificationController extends BaseController {
  final NotificationRepository _notiRepo = Get.find<NotificationRepository>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  var notifications = <NotificationModel>[].obs;
  var unreadCount = 0.obs;

  String? _shopId;

  @override
  void onInit() {
    super.onInit();
    _loadShopIdAndListen();
  }

  // Lấy shopId từ Firestore user document
  Future<void> _loadShopIdAndListen() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // ✅ Dùng uid làm shopId (đúng với kiến trúc dự án)
      _shopId = user.uid;

      if (_shopId != null && _shopId!.isNotEmpty) {
        // Lắng nghe realtime theo shopId
        notifications.bindStream(_notiRepo.getNotificationsStream(_shopId!));
        
        // Lắng nghe thay đổi để update unreadCount
        _notiRepo.getNotificationsStream(_shopId!).listen((_) {
          _updateUnreadCount();
        });
      }
    } catch (e) {
      print("--> NotificationController Error loading shop: $e");
    }
  }

  // Cập nhật số thông báo chưa đọc
  void _updateUnreadCount() {
    unreadCount.value = notifications.where((n) => !n.isRead).length;
  }

  // Đánh dấu đã đọc
  Future<void> markAsRead(String id) async {
    try {
      await _notiRepo.markAsRead(id);
      // Update local state
      final index = notifications.indexWhere((n) => n.id == id);
      if (index != -1) {
        notifications[index].isRead = true;
        notifications.refresh();
        _updateUnreadCount();
      }
    } catch (e) {
      print("--> Lỗi mark as read: $e");
    }
  }

  // Đánh dấu tất cả đã đọc
  Future<void> markAllAsRead() async {
    try {
      for (var notif in notifications.where((n) => !n.isRead).toList()) {
        await _notiRepo.markAsRead(notif.id!);
      }
      for (var n in notifications) {
        n.isRead = true;
      }
      notifications.refresh();
      _updateUnreadCount();
    } catch (e) {
      print("--> Lỗi mark all as read: $e");
    }
  }

  // Xóa thông báo
  Future<void> deleteNotification(String id) async {
    try {
      await _notiRepo.deleteNotification(id);
      notifications.removeWhere((n) => n.id == id);
      _updateUnreadCount();
    } catch (e) {
      print("--> Lỗi xóa notification: $e");
    }
  }
}