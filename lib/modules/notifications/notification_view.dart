import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'notification_controller.dart';
import '../../data/models/notification_model.dart';

class NotificationView extends GetView<NotificationController> {
  const NotificationView({super.key});

  // Cached formatter for performance
  static final DateFormat _dateFormat = DateFormat('dd/MM HH:mm');

  // Const icons for performance
  static const Map<String, IconData> _iconMap = {
    'new_booking': Icons.calendar_today,
    'cancel_booking': Icons.cancel,
    'system': Icons.info,
  };

  // Const colors for performance
  static const Map<String, Color> _colorMap = {
    'new_booking': Color(0xFF4CAF50), // green
    'cancel_booking': Color(0xFFEF5350), // red
    'system': Color(0xFF29B6F6), // blue
  };

  @override
  Widget build(BuildContext context) {
    final ScrollController scrollController = ScrollController();

    // Listen to scroll events for load more
    scrollController.addListener(() {
      if (scrollController.position.pixels >= 
          scrollController.position.maxScrollExtent - 200) {
        controller.loadMoreItems();
      }
    });

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF0F4FF),
              Color(0xFFFFFFFF),
              Color(0xFFF8FAFF),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header with gradient
              _buildHeader(context),
              
              // Notification list
              Expanded(
                child: Obx(() {
                  // Show loading when first load
                  if (controller.notifications.isEmpty && controller.isPaginationLoading.value) {
                    return const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4A90E2)),
                      ),
                    );
                  }
                  
                  // Show empty state when no data and not loading
                  if (controller.notifications.isEmpty && !controller.isPaginationLoading.value) {
                    return _buildEmptyState();
                  }

                  return ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    itemCount: controller.notifications.length + 
                        (controller.hasMore.value ? 1 : 0),
                    itemBuilder: (context, index) {
                      // Loading indicator at bottom
                      if (index == controller.notifications.length) {
                        return _buildLoadingIndicator();
                      }
                      
                      final noti = controller.notifications[index];
                      return _buildNotiCard(noti);
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withOpacity(0.8),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4A90E2).withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Back button
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => Navigator.of(context).pop(),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4A90E2), Color(0xFF357ABD)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
              ),
            ),
          ),
          const SizedBox(width: 16),
          
          // Title
          Expanded(
            child: Text(
              'recent_activity'.tr,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3748),
              ),
            ),
          ),
          
          // Unread badge & Mark all button
          Obx(() {
            if (controller.isSelectionMode.value) {
              // Selection mode buttons
              return Row(
                children: [
                  // Selected count
                  if (controller.selectedNotifications.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4A90E2).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${controller.selectedNotifications.length}',
                        style: const TextStyle(
                          color: Color(0xFF4A90E2),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  const SizedBox(width: 8),
                  
                  // Select all button
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => controller.selectAll(),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4A90E2).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(0xFF4A90E2).withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          'select_all'.tr,
                          style: TextStyle(
                            color: Color(0xFF4A90E2),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  
                  // Delete button
                  if (controller.selectedNotifications.isNotEmpty)
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _showDeleteConfirmDialog(context),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFEF5350), Color(0xFFE53935)],
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.delete, color: Colors.white, size: 20),
                        ),
                      ),
                    ),
                ],
              );
            } else if (controller.unreadCount.value > 0) {
              return Row(
                children: [
                  // Unread count badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFEF5350), Color(0xFFE53935)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${controller.unreadCount.value}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  
                  // Mark all read button
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => controller.markAllAsRead(),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4A90E2).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(0xFF4A90E2).withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          'mark_all_read'.tr,
                          style: TextStyle(
                            color: Color(0xFF4A90E2),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }
            return const SizedBox();
          }),
          
          // More options button
          const SizedBox(width: 8),
          Obx(() => Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _showMoreOptions(context),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: controller.isSelectionMode.value
                      ? const Color(0xFFEF5350).withOpacity(0.1)
                      : const Color(0xFF4A90E2).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: controller.isSelectionMode.value
                        ? const Color(0xFFEF5350).withOpacity(0.3)
                        : const Color(0xFF4A90E2).withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Icon(
                  controller.isSelectionMode.value ? Icons.close : Icons.more_vert,
                  color: controller.isSelectionMode.value
                      ? const Color(0xFFEF5350)
                      : const Color(0xFF4A90E2),
                  size: 20,
                ),
              ),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.grey.shade300.withOpacity(0.3),
                  Colors.grey.shade200.withOpacity(0.2),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_off_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'no_notifications_yet'.tr,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'new_notifications_here'.tr,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotiCard(NotificationModel noti) {
    final iconData = _iconMap[noti.type] ?? Icons.notifications;
    final iconColor = _colorMap[noti.type] ?? Colors.grey;

    return Obx(() {
      final isSelected = controller.selectedNotifications.contains(noti.id);
      final isSelectionMode = controller.isSelectionMode.value;

      return RepaintBoundary(
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF4A90E2).withOpacity(0.15)
                : noti.isRead 
                    ? Colors.white.withOpacity(0.7)
                    : const Color(0xFF4A90E2).withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF4A90E2).withOpacity(0.4)
                  : noti.isRead
                      ? Colors.white.withOpacity(0.8)
                      : const Color(0xFF4A90E2).withOpacity(0.2),
              width: isSelected ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4A90E2).withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                if (isSelectionMode) {
                  controller.toggleNotificationSelection(noti.id!);
                } else {
                  controller.markAsRead(noti.id!);
                }
              },
              onLongPress: () {
                if (!isSelectionMode) {
                  controller.toggleSelectionMode();
                  controller.toggleNotificationSelection(noti.id!);
                }
              },
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Checkbox in selection mode or icon
                    if (isSelectionMode)
                      Container(
                        padding: const EdgeInsets.all(4),
                        margin: const EdgeInsets.only(right: 12),
                        child: Icon(
                          isSelected ? Icons.check_circle : Icons.circle_outlined,
                          color: isSelected ? const Color(0xFF4A90E2) : Colors.grey.shade400,
                          size: 28,
                        ),
                      )
                    else
                      // Icon with gradient
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              iconColor,
                              iconColor.withOpacity(0.7),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: iconColor.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(iconData, color: Colors.white, size: 24),
                      ),
                    const SizedBox(width: 16),
                  
                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                noti.title,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: noti.isRead 
                                      ? FontWeight.w500 
                                      : FontWeight.bold,
                                  color: const Color(0xFF2D3748),
                                ),
                              ),
                            ),
                            if (!noti.isRead)
                              Container(
                                width: 10,
                                height: 10,
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Color(0xFF4A90E2), Color(0xFF357ABD)],
                                  ),
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          noti.body,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF718096),
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _dateFormat.format(noti.createdAt ?? DateTime.now()),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        ),
      );
      
    });
  }

  // Show more options bottom sheet
  void _showMoreOptions(BuildContext context) {
    if (controller.isSelectionMode.value) {
      controller.toggleSelectionMode();
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Selection mode option
            ListTile(
              leading: const Icon(Icons.checklist, color: Color(0xFF4A90E2)),
              title: Text('select_notifications'.tr),
              onTap: () {
                Navigator.pop(context);
                controller.toggleSelectionMode();
              },
            ),
            
            // Delete all option
            ListTile(
              leading: const Icon(Icons.delete_sweep, color: Color(0xFFEF5350)),
              title: Text('delete_all'.tr),
              onTap: () {
                Navigator.pop(context);
                _showDeleteAllConfirmDialog(context);
              },
            ),
            
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // Show delete confirmation dialog
  void _showDeleteConfirmDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('confirm_delete'.tr),
        content: Text('confirm_delete_selected'.tr.replaceAll('{count}', controller.selectedNotifications.length.toString())),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('cancel'.tr),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.deleteSelectedNotifications();
            },
            child: Text(
              'delete'.tr,
              style: TextStyle(color: Color(0xFFEF5350)),
            ),
          ),
        ],
      ),
    );
  }

  // Show delete all confirmation dialog
  void _showDeleteAllConfirmDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('confirm_delete'.tr),
        content: Text('confirm_delete_all_notif'.tr.replaceAll('{count}', controller.notifications.length.toString())),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('cancel'.tr),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.deleteAllNotifications();
            },
            child: Text(
              'delete_all'.tr,
              style: TextStyle(color: Color(0xFFEF5350)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      alignment: Alignment.center,
      child: Obx(() {
        if (controller.isLoadingMore.value) {
          return const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4A90E2)),
            ),
          );
        }
        return const SizedBox();
      }),
    );
  }
}