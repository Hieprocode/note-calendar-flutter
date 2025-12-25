import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import '../models/notification_model.dart';
import '../../routes/app_routes.dart';

class FCMService {
  static final FCMService _instance = FCMService._internal();
  
  factory FCMService() {
    return _instance;
  }
  
  FCMService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  String? _shopId;
  StreamSubscription? _tokenRefreshSubscription;
  RemoteMessage? _pendingMessage; // Lưu message khi app mở từ notification (app đã tắt)

  Future<void> init() async {
    // 1. Xin quyền thông báo
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('--> FCM: Đã cấp quyền thông báo');
      
      // 2. Lấy và lưu Token
      await _saveTokenToFirestore();
      
      // 3. Lắng nghe token refresh
      _setupTokenRefreshListener();
      
      // 4. Đăng ký Topic dựa trên Shop
      await _setupTopicSubscription();
      
      // 5. Xử lý thông báo ở Foreground
      _setupForegroundMessageHandler();
      
      // 6. Xử lý khi bấm vào thông báo
      _setupMessageOpenedAppHandler();
      
      // 7. Xử lý Background Message
      FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);
      
    } else {
      print('--> FCM: Người dùng từ chối quyền thông báo');
    }
  }

  // 2️⃣ Lưu Token vào Firestore (Dùng để gửi notification từ server)
  Future<void> _saveTokenToFirestore() async {
    try {
      String? token = await _messaging.getToken();
      User? user = FirebaseAuth.instance.currentUser;
      
      if (user == null || token == null) return;

      print("--> FCM TOKEN: $token");
      
      // ✅ Lưu vào collection 'users' để có thể gửi tới user đó
      await _firestore.collection('users').doc(user.uid).set({
        'fcm_token': token,
        'email': user.email ?? '',
        'updated_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      
      print("--> Đã lưu Token vào users collection");
      
    } catch (e) {
      print("--> Lỗi lưu Token: $e");
    }
  }

  // 3️⃣ Lắng nghe token refresh (khi token hết hạn, Firebase cấp token mới)
  void _setupTokenRefreshListener() {
    _tokenRefreshSubscription?.cancel();
    
    _tokenRefreshSubscription = _messaging.onTokenRefresh.listen((newToken) {
      print("--> FCM Token refresh: $newToken");
      _saveTokenToFirestore(); // Cập nhật token mới
    });
  }

  // 4️⃣ Đăng ký Topic để nhận thông báo broadcast
  Future<void> _setupTopicSubscription() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // ✅ Dùng uid làm shopId (đúng với kiến trúc dự án)
      _shopId = user.uid;

      if (_shopId != null && _shopId!.isNotEmpty) {
        // Subscribe vào topic shop này
        String topic = "shop_${_shopId}_notifications";
        await _messaging.subscribeToTopic(topic);
        print("--> Đã subscribe topic: $topic");
      }
    } catch (e) {
      print("--> Lỗi setup Topic: $e");
    }
  }

  // 5️⃣ Xử lý thông báo khi App đang mở (Foreground)
  void _setupForegroundMessageHandler() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('--> FCM Foreground: ${message.notification?.title}');
      
      if (message.notification != null) {
        // ❌ KHÔNG show local notification nữa vì FCM đã tự động hiển thị
        // FCM sẽ tự động show notification tray
        
        // ✅ CHỈ lưu vào Firestore để có lịch sử
        _saveNotificationToFirestore(message);
      }
    });
  }

  // 6️⃣ Xử lý khi user bấm vào thông báo
  void _setupMessageOpenedAppHandler() {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('--> FCM: Người dùng bấm vào thông báo');
      _handleNotificationTap(message);
    });
  }

  // 7️⃣ Xử lý Background Message (App tắt hoặc ở background)
  static Future<void> _handleBackgroundMessage(RemoteMessage message) async {
    print('--> FCM Background: ${message.notification?.title}');
    // Firebase tự động hiển thị notification, 
    // nhưng nếu cần xử lý logic thêm có thể code ở đây
  }

  // 📝 Lưu notification vào Firestore (tạo lịch sử)
  Future<void> _saveNotificationToFirestore(RemoteMessage message) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      NotificationModel notification = NotificationModel(
        title: message.notification?.title ?? "",
        body: message.notification?.body ?? "",
        shopId: _shopId ?? "",
        type: (message.data['type'] as String?) ?? 'system',
        relatedBookingId: message.data['related_booking_id'] as String?,
        isRead: false,
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection('notifications')
          .add(notification.toJson());
          
      print("--> Lưu notification vào Firestore");
    } catch (e) {
      print("--> Lỗi lưu notification: $e");
    }
  }

  // 🔗 Xử lý khi user tap vào notification
  void _handleNotificationTap(RemoteMessage message) {
    String? relatedBookingId = message.data['related_booking_id'] as String?;
    String? type = message.data['type'] as String?;

    print("--> Tapped notification type: $type, bookingId: $relatedBookingId");

    // Navigate đến booking detail nếu có bookingId
    if (relatedBookingId != null && relatedBookingId.isNotEmpty) {
      // Điều hướng đến chi tiết booking
      Get.toNamed(AppRoutes.BOOKING_DETAIL, arguments: relatedBookingId);
    } else {
      // Nếu không có bookingId, mở màn hình notifications
      Get.toNamed(AppRoutes.NOTIFICATIONS);
    }
  }

  // 💾 Lưu pending message khi app mở từ notification (app đã tắt)
  void setPendingMessage(RemoteMessage message) {
    _pendingMessage = message;
    print("--> FCM: Đã lưu pending message");
  }

  // 🚀 Xử lý pending message sau khi app đã navigate xong splash
  void processPendingMessage() {
    if (_pendingMessage != null) {
      print("--> FCM: Đang xử lý pending message");
      // Đợi 500ms để đảm bảo dashboard đã load xong
      Future.delayed(const Duration(milliseconds: 500), () {
        _handleNotificationTap(_pendingMessage!);
        _pendingMessage = null; // Clear sau khi xử lý
      });
    }
  }

  // 🧹 Cleanup
  void dispose() {
    _tokenRefreshSubscription?.cancel();
  }
}