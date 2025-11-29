// lib/main.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../data/services/notification_service.dart';
import 'core/config/supabase_config.dart';
import 'core/base/initial_binding.dart';
import 'routes/app_pages.dart';
import 'routes/app_routes.dart';

// BACKGROUND HANDLER – BẮT BUỘC PHẢI CÓ
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  await NotificationService().init(); // cần init lại khi app tắt
  print("FCM khi app tắt: ${message.notification?.title}");
  await NotificationService().showNotification(
    title: message.notification?.title ?? "Sắp có khách!",
    body: message.notification?.body ?? "",
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Notification local + Firebase
  await NotificationService().init();
  await Firebase.initializeApp();

  // 2. Đăng ký background FCM
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // 3. LẤY TOKEN TRƯỚC
  final token = await FirebaseMessaging.instance.getToken();
  print('=====================================');
  print('FCM TOKEN CỦA BẠN:');
  print(token);
  print('=====================================');

  // 4. XIN QUYỀN THÔNG BÁO
  await FirebaseMessaging.instance.requestPermission();

  // 5. KHỞI TẠO SUPABASE TRƯỚC KHI DÙNG Supabase.instance
  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );

  // 6. LƯU TOKEN LÊN FIRESTORE SAU KHI SUPABASE ĐÃ KHỞI TẠO
  final user = Supabase.instance.client.auth.currentUser;
  if (user != null && token != null) {
    await FirebaseFirestore.instance
        .collection('shop_tokens')
        .doc(user.id)
        .set({'token': token, 'updatedAt': FieldValue.serverTimestamp()}, SetOptions(merge: true));
  }

  // 7. HIỆN TOKEN TRÊN MÀN HÌNH SAU KHI runApp() (an toàn nhất)
  await initializeDateFormatting();

  runApp(MyApp(token: token)); // truyền token vào app
}

class MyApp extends StatelessWidget {
  final String? token;
  const MyApp({super.key, this.token});

  @override
  Widget build(BuildContext context) {
    // HIỆN TOKEN SAU KHI GetX ĐÃ KHỞI TẠO
    if (token != null) {
      Future.delayed(const Duration(milliseconds: 500), () {
        Get.snackbar(
          "FCM Token – Copy ngay!",
          token!,
          duration: const Duration(seconds: 20),
          backgroundColor: Colors.black87,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
      });
    }

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