// lib/core/widgets/app_slidable.dart
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/Get.dart';
import 'package:note_calendar/core/config/app_colors.dart';

class AppSlidable extends StatelessWidget {
  final String itemId;
  final Widget child;
  final VoidCallback? onEdit;                    // Không bắt buộc
  final Future<void> Function(String id) onDelete;

  const AppSlidable({
    super.key,
    required this.itemId,
    required this.child,
    this.onEdit,                                 // Không required
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // TỰ ĐỘNG CHỈ HIỆN NÚT XÓA KHI KHÔNG CÓ onEdit!
    final bool showEditButton = onEdit != null;

    return Slidable(
      key: ValueKey(itemId),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        extentRatio: showEditButton ? 0.4 : 0.25,
        children: [
          const SizedBox(width: 4),
          // CHỈ HIỆN NÚT SỬA KHI CÓ onEdit
          if (showEditButton)
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(right: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => onEdit!(),
                    borderRadius: BorderRadius.circular(12),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.edit_rounded, color: Colors.white, size: 20),
                          const SizedBox(height: 2),
                          Text(
                            'edit'.tr,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                            overflow: TextOverflow.clip,
                            maxLines: 1,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          // NÚT XÓA LUÔN HIỆN
          Expanded(
            child: Container(
              margin: EdgeInsets.only(left: showEditButton ? 4 : 0),
              decoration: BoxDecoration(
                color: AppColors.redConfirmed,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.redConfirmed.withOpacity(0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _confirmDelete(context),
                  borderRadius: BorderRadius.circular(12),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.delete_rounded, color: Colors.white, size: 20),
                        const SizedBox(height: 2),
                        Text(
                          'delete'.tr,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                          overflow: TextOverflow.clip,
                          maxLines: 1,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
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
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.redConfirmed.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.warning_rounded,
                color: AppColors.redConfirmed,
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'confirm_delete'.tr,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          'confirm_delete_message'.tr,
          style: TextStyle(fontSize: 15),
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              side: BorderSide(color: Colors.grey.shade400),
            ),
            child: Text(
              'cancel'.tr,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await onDelete(itemId);
              Get.rawSnackbar(
                message: 'deleted_successfully'.tr,
                backgroundColor: AppColors.green,
                snackPosition: SnackPosition.TOP,
                margin: const EdgeInsets.all(16),
                borderRadius: 12,
                duration: const Duration(seconds: 2),
                icon: const Icon(Icons.check_circle_rounded, color: Colors.white),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.redConfirmed,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
            child: Text(
              'delete'.tr,
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}