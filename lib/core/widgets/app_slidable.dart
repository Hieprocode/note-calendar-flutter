// lib/core/widgets/app_slidable.dart
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import '../utils/app_alert.dart';

class AppSlidable extends StatelessWidget {
  final Widget child;
  final String itemId;
  final VoidCallback onEdit;
  final Future<void> Function(String id) onDelete;

  const AppSlidable({
    Key? key,
    required this.child,
    required this.itemId,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Slidable(
      key: ValueKey(itemId),
      endActionPane: ActionPane(
        motion: const StretchMotion(),
        extentRatio: 0.5,
        
        children: [
          SlidableAction(
            onPressed: (_) => onEdit(),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            icon: Icons.edit,
            label: 'Sửa',
            borderRadius: const BorderRadius.all(Radius.circular(16)),
          ),
          SlidableAction(
            onPressed: (_) => _confirmDelete(context),
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete_outline,
            label: 'Xóa',
            borderRadius: const BorderRadius.all(Radius.circular(16)),
          ),
        ],
      ),
      child: child,
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Xóa mục này?", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
        content: const Text("Hành động này không thể hoàn tác."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy")),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await onDelete(itemId);
              AppAlert.success("Đã xóa thành công!");
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Xóa", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}