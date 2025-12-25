import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/notification_model.dart';
import '../../data/repositories/notification_repository.dart';
import 'base_pagination_controller.dart';

/// Pagination controller cho Notifications
/// Chứa logic load notifications với pagination
class NotificationPaginationController extends BasePaginationController<NotificationModel> {
  final NotificationRepository _repository;
  final String shopId;

  NotificationPaginationController({
    required this.shopId,
    required NotificationRepository repository,
    int pageSize = 20,
  })  : _repository = repository,
        super(pageSize: pageSize);

  @override
  Future<Map<String, dynamic>> fetchItems({
    DocumentSnapshot? lastDocument,
    int? limit,
  }) async {
    try {
      print("--> [NOTI_PAGINATION] Fetching notifications for shopId: $shopId");
      
      final result = await _repository.getNotifications(
        shopId: shopId,
        lastDocument: lastDocument,
        limit: limit ?? pageSize,
      );

      final notifications = result['notifications'] as List<NotificationModel>;
      print("--> [NOTI_PAGINATION] Fetched ${notifications.length} notifications");

      return {
        'items': notifications,
        'lastDocument': result['lastDocument'],
      };
    } catch (e) {
      print("--> [NOTI_PAGINATION ERROR] fetchItems: $e");
      rethrow;
    }
  }

  // Helper method để lấy notifications (alias cho items)
  List<NotificationModel> get notifications => items;
  
  // Helper method để lấy unread count
  int get unreadCount => notifications.where((n) => !n.isRead).length;
}
