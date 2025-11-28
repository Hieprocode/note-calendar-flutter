import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart'; // Để format ngày giờ
import 'notification_controller.dart';
import '../../data/models/notification_model.dart';

class NotificationView extends GetView<NotificationController> {
  const NotificationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Hoạt Động Gần Đây"), centerTitle: true),
      body: Obx(() {
        if (controller.notifications.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.notifications_off, size: 60, color: Colors.grey.shade300),
                const SizedBox(height: 10),
                const Text("Chưa có thông báo nào", style: TextStyle(color: Colors.grey)),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(10),
          itemCount: controller.notifications.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final noti = controller.notifications[index];
            return _buildNotiItem(noti);
          },
        );
      }),
    );
  }

  Widget _buildNotiItem(NotificationModel noti) {
    // Màu nền: Chưa đọc thì màu xanh nhạt, đọc rồi thì trắng
    return Container(
      color: noti.isRead ? Colors.white : Colors.blue.shade50,
      child: ListTile(
        onTap: () => controller.markAsRead(noti.id!),
        leading: CircleAvatar(
          backgroundColor: _getIconColor(noti.type).withOpacity(0.1),
          child: Icon(_getIcon(noti.type), color: _getIconColor(noti.type)),
        ),
        title: Text(
          noti.title, 
          style: TextStyle(
            fontWeight: noti.isRead ? FontWeight.normal : FontWeight.bold,
            fontSize: 16
          )
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 5),
            Text(noti.body),
            const SizedBox(height: 5),
            Text(
              DateFormat('dd/MM HH:mm').format(noti.createdAt ?? DateTime.now()),
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        trailing: noti.isRead 
            ? null 
            : const Icon(Icons.circle, size: 10, color: Colors.blue),
      ),
    );
  }

  IconData _getIcon(String type) {
    switch (type) {
      case 'new_booking': return Icons.calendar_today;
      case 'cancel_booking': return Icons.cancel;
      case 'system': return Icons.info;
      default: return Icons.notifications;
    }
  }

  Color _getIconColor(String type) {
    switch (type) {
      case 'new_booking': return Colors.green;
      case 'cancel_booking': return Colors.red;
      case 'system': return Colors.blue;
      default: return Colors.grey;
    }
  }
}