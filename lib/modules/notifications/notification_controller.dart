import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../core/base/base_controller.dart';
import '../../core/pagination/notification_pagination_controller.dart';
import '../../data/models/notification_model.dart';
import '../../data/repositories/notification_repository.dart';

/// Controller chính cho Notification Module
/// Sử dụng NotificationPaginationController để quản lý pagination
/// Controller này chỉ lo business logic: markAsRead, markAllAsRead, unread count
class NotificationController extends BaseController {
  final NotificationRepository _notiRepo = Get.find<NotificationRepository>();

  // Pagination controller - composition pattern
  NotificationPaginationController? _paginationController;
  
  // Expose pagination properties
  List<NotificationModel> get notifications => _paginationController?.notifications ?? [];
  RxBool get isPaginationLoading => _paginationController?.isLoading ?? false.obs;
  RxBool get isLoadingMore => _paginationController?.isLoadingMore ?? false.obs;
  RxBool get hasMore => _paginationController?.hasMore ?? false.obs;
  
  var unreadCount = 0.obs;
  String? _shopId;

  // Selection mode for bulk delete
  var isSelectionMode = false.obs;
  var selectedNotifications = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadShopIdAndInitialData();
  }

  // Toggle selection mode
  void toggleSelectionMode() {
    isSelectionMode.value = !isSelectionMode.value;
    if (!isSelectionMode.value) {
      selectedNotifications.clear();
    }
  }

  // Toggle notification selection
  void toggleNotificationSelection(String id) {
    if (selectedNotifications.contains(id)) {
      selectedNotifications.remove(id);
    } else {
      selectedNotifications.add(id);
    }
  }

  // Select all notifications
  void selectAll() {
    selectedNotifications.clear();
    selectedNotifications.addAll(notifications.map((n) => n.id!));
  }

  // Clear selection
  void clearSelection() {
    selectedNotifications.clear();
  }

  // Lấy shopId và khởi tạo pagination controller
  Future<void> _loadShopIdAndInitialData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print("--> [NOTIFICATION] User is null!");
        return;
      }

      _shopId = user.uid;
      print("--> [NOTIFICATION] Shop ID: $_shopId");

      if (_shopId != null && _shopId!.isNotEmpty) {
        // Khởi tạo pagination controller
        _paginationController = NotificationPaginationController(
          shopId: _shopId!,
          repository: _notiRepo,
          pageSize: 20,
        );

        // Load initial data
        await _paginationController!.loadInitialItems();
        _updateUnreadCount();
        
        // Lắng nghe stream để update unread count realtime
        _notiRepo.getNotificationsStream(_shopId!).listen((streamNotis) {
          unreadCount.value = streamNotis.where((n) => !n.isRead).length;
        });
      }
    } catch (e) {
      print("--> [NOTIFICATION] Error loading shop: $e");
    }
  }

  // Delegate load more to pagination controller
  Future<void> loadMoreItems() async {
    await _paginationController?.loadMoreItems();
    _updateUnreadCount();
  }

  // Refresh data
  Future<void> refreshItems() async {
    await _paginationController?.refreshItems();
    _updateUnreadCount();
  }

  // Cập nhật số thông báo chưa đọc
  void _updateUnreadCount() {
    unreadCount.value = notifications.where((n) => !n.isRead).length;
  }

  // Đánh dấu đã đọc
  Future<void> markAsRead(String id) async {
    try {
      await _notiRepo.markAsRead(id);
      
      // Update local state trong pagination controller
      final index = notifications.indexWhere((n) => n.id == id);
      if (index != -1) {
        notifications[index].isRead = true;
        _paginationController?.items.refresh();
        _updateUnreadCount();
      }
    } catch (e) {
      print("--> [NOTIFICATION] Lỗi mark as read: $e");
    }
  }

  // Đánh dấu tất cả đã đọc
  Future<void> markAllAsRead() async {
    try {
      final unreadNotifications = notifications.where((n) => !n.isRead).toList();
      
      for (var notif in unreadNotifications) {
        await _notiRepo.markAsRead(notif.id!);
      }
      
      // Update local state
      for (var n in notifications) {
        n.isRead = true;
      }
      _paginationController?.items.refresh();
      _updateUnreadCount();
    } catch (e) {
      print("--> [NOTIFICATION] Lỗi mark all as read: $e");
    }
  }

  // Xóa thông báo
  Future<void> deleteNotification(String id) async {
    try {
      await _notiRepo.deleteNotification(id);
      _paginationController?.items.removeWhere((n) => n.id == id);
      _updateUnreadCount();
    } catch (e) {
      print("--> [NOTIFICATION] Lỗi xóa notification: $e");
    }
  }

  // Xóa các thông báo đã chọn
  Future<void> deleteSelectedNotifications() async {
    try {
      if (selectedNotifications.isEmpty) return;

      for (var id in selectedNotifications) {
        await _notiRepo.deleteNotification(id);
      }

      _paginationController?.items.removeWhere((n) => selectedNotifications.contains(n.id));
      selectedNotifications.clear();
      isSelectionMode.value = false;
      _updateUnreadCount();

      Get.snackbar(
        'success'.tr,
        'deleted_notifications'.tr.replaceAll('{count}', selectedNotifications.length.toString()),
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      print("--> [NOTIFICATION] Lỗi xóa notifications: $e");
      Get.snackbar(
        'error'.tr,
        'cannot_delete_notifications'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEF5350),
        colorText: Colors.white,
      );
    }
  }

  // Xóa tất cả thông báo
  Future<void> deleteAllNotifications() async {
    try {
      final allIds = notifications.map((n) => n.id!).toList();
      
      for (var id in allIds) {
        await _notiRepo.deleteNotification(id);
      }

      _paginationController?.items.clear();
      selectedNotifications.clear();
      isSelectionMode.value = false;
      _updateUnreadCount();

      Get.snackbar(
        'success'.tr,
        'deleted_all_notifications'.tr,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      print("--> [NOTIFICATION] Lỗi xóa tất cả notifications: $e");
      Get.snackbar(
        'error'.tr,
        'cannot_delete_notifications'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEF5350),
        colorText: Colors.white,
      );
    }
  }
}