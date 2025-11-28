// lib/core/widgets/app_slidable.dart
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/Get.dart';

class AppSlidable extends StatelessWidget {
  final String itemId;
  final Widget child;
  final VoidCallback? onEdit;                    // Không bắt buộc
  final Future<void> Function(String id) onDelete;

  const AppSlidable({
    Key? key,
    required this.itemId,
    required this.child,
    this.onEdit,                                 // Không required
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TỰ ĐỘNG CHỈ HIỆN NÚT XÓA KHI KHÔNG CÓ onEdit!
    final bool showEditButton = onEdit != null;

    return Slidable(
      key: ValueKey(itemId),
      endActionPane: ActionPane(
        motion: const StretchMotion(),
        extentRatio: showEditButton ? 0.6 : 0.35, // Có Sửa → rộng, không có → hẹp
        children: [
          // CHỈ HIỆN NÚT SỬA KHI CÓ onEdit
          if (showEditButton)
            SlidableAction(
              onPressed: (_) => onEdit!(),
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              icon: Icons.edit,
              label: 'Sửa',
              borderRadius: const BorderRadius.all(Radius.circular(16)),
            ),
          // NÚT XÓA LUÔN HIỆN
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
              Get.rawSnackbar(
                message: "Đã xóa thành công!",
                backgroundColor: Colors.green,
                snackPosition: SnackPosition.TOP,
                margin: const EdgeInsets.all(16),
                borderRadius: 12,
                duration: const Duration(seconds: 2),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Xóa", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}