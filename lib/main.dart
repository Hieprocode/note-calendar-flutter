import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:get_storage/get_storage.dart';

import 'core/config/supabase_config.dart';
import 'core/config/app_locale.dart';
import 'core/translations/app_translations.dart';
import 'core/base/initial_binding.dart';
import 'routes/app_pages.dart';
import 'routes/app_routes.dart';
import 'firebase_options.dart';
import 'data/services/notification_service.dart';
import 'data/services/fcm_service.dart';

// BACKGROUND HANDLER
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
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

  // 0. KHỞI TẠO GET STORAGE
  await GetStorage.init();

  // 1. KHỞI TẠO FIREBASE
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // ✅ ĐỢI Firebase Auth sẵn sàng (quan trọng cho cold start)
  print("🔐 [Main] Waiting for Firebase Auth initialization...");
  await Future.delayed(const Duration(milliseconds: 100));
  
  final currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser != null) {
    print("✅ [Main] User already logged in: ${currentUser.email}");
  } else {
    print("⚠️ [Main] No user logged in");
  }

  // DEBUG: Listen to auth state changes
  print("🔍 [Main] Setting up auth state listener...");
  FirebaseAuth.instance.authStateChanges().listen((user) {
    if (user == null) {
      print('⚠️ [Main] Auth state changed: User is signed out');
    } else {
      print('✅ [Main] Auth state changed: User signed in - ${user.email} (${user.uid})');
    }
  });

  // 2. KHỞI TẠO SUPABASE
  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );

  // 3. ĐĂNG KÝ & KHỞI TẠO LOCAL NOTIFICATION (SỬA ĐOẠN NÀY)
  // Dùng Get.put để đăng ký vào bộ nhớ ngay lập tức
  final notiService = Get.put(NotificationService(), permanent: true);
  await notiService.init(); 

  // 4. KHỞI TẠO FORMAT NGÀY GIỜ (TIẾNG VIỆT)
  await initializeDateFormatting('vi_VN', null);

  // 5. ĐĂNG KÝ BACKGROUND HANDLER
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // 6. KÍCH HOẠT FCM SERVICE
  // Bây giờ gọi Get.put(FCMService) sẽ an toàn vì NotificationService đã có rồi
  final fcmService = Get.put(FCMService(), permanent: true);
  await fcmService.init();

  // 7. KIỂM TRA XEM APP CÓ ĐƯỢC MỞ TỪ NOTIFICATION KHÔNG (khi app đã tắt)
  RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
  
  runApp(MyApp(initialMessage: initialMessage));
}

class MyApp extends StatelessWidget {
  final RemoteMessage? initialMessage;
  
  const MyApp({super.key, this.initialMessage});

  @override
  Widget build(BuildContext context) {
    // Lưu initialMessage vào FCMService để xử lý sau
    if (initialMessage != null) {
      final fcmService = Get.find<FCMService>();
      fcmService.setPendingMessage(initialMessage!);
    }
    
    return GetMaterialApp(
      title: 'Note Calendar',
      debugShowCheckedModeBanner: false,
      locale: AppLocale.defaultLocale,
      supportedLocales: AppLocale.supportedLocales,
      localizationsDelegates: AppLocale.localizationsDelegates,
      translations: AppTranslations(),
      fallbackLocale: AppLocale.defaultLocale,
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