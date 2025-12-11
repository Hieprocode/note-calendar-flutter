import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/config/supabase_config.dart';
import 'core/base/initial_binding.dart';
import 'routes/app_pages.dart';
import 'routes/app_routes.dart';
import 'firebase_options.dart';
import '../data/services/notification_service.dart';
import '../data/services/fcm_service.dart';

// BACKGROUND HANDLER
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Khởi tạo lại Service khi chạy ngầm
  await NotificationService().init(); 
  
  print("--> FCM BACKGROUND: ${message.notification?.title}");
  if (message.notification != null) {
    NotificationService().showNotification(
      title: message.notification!.title ?? "Thông báo",
      body: message.notification!.body ?? "",
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. KHỞI TẠO FIREBASE
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 2. KHỞI TẠO SUPABASE
  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );

  // 3. ĐĂNG KÝ & KHỞI TẠO LOCAL NOTIFICATION (SỬA ĐOẠN NÀY)
  // Dùng Get.put để đăng ký vào bộ nhớ ngay lập tức
  final notiService = Get.put(NotificationService(), permanent: true);
  await notiService.init(); 

  // 4. KHỞI TẠO FORMAT NGÀY GIỜ
  await initializeDateFormatting();

  // 5. ĐĂNG KÝ BACKGROUND HANDLER
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // 6. KÍCH HOẠT FCM SERVICE
  // Bây giờ gọi Get.put(FCMService) sẽ an toàn vì NotificationService đã có rồi
  final fcmService = Get.put(FCMService(), permanent: true);
  await fcmService.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Note Calendar',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      initialBinding: InitialBinding(),
      initialRoute: AppRoutes.SPLASH,
      getPages: AppPages.pages,
    );
  }
}