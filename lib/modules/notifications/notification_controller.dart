import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/base/base_controller.dart';
import '../../data/models/notification_model.dart';
import '../../data/repositories/notification_repository.dart';

class NotificationController extends BaseController {
  // Vì NotificationRepo chưa được put ở InitialBinding (hoặc đã put rồi thì thôi), 
  // ta cứ dùng Get.put để chắc ăn nếu nó chưa có.
  final NotificationRepository _notiRepo = Get.find<NotificationRepository>();

  var notifications = <NotificationModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    String uid = FirebaseAuth.instance.currentUser?.uid ?? "";
    if (uid.isNotEmpty) {
      // Lắng nghe realtime
      notifications.bindStream(_notiRepo.getNotificationsStream(uid));
    }
  }

  // Đánh dấu đã đọc
  Future<void> markAsRead(String id) async {
    await _notiRepo.markAsRead(id);
  }
  
  // Xóa thông báo (nếu cần)
  Future<void> deleteNotification(String id) async {
    await _notiRepo.deleteNotification(id);
  }
}