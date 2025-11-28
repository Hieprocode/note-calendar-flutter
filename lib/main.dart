import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../data/services/notification_service.dart';

// Import các file cấu hình và route
import 'core/config/supabase_config.dart';
import 'core/base/initial_binding.dart';
import 'routes/app_pages.dart';
import 'routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );
  await initializeDateFormatting();
  await NotificationService().init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Note Calendar',
      debugShowCheckedModeBanner: false,
      
      // --- Cấu hình Theme (Màu sắc chủ đạo) ---
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        // Font chữ mặc định (cần cài google_fonts ở pubspec.yaml trước)
        // fontFamily: GoogleFonts.inter().fontFamily, 
      ),
      initialBinding: InitialBinding(),
      // --- Cấu hình Route (Quan trọng nhất) ---
      // Màn hình đầu tiên khi mở app
      initialRoute: AppRoutes.SPLASH, 
      
      // Danh sách tất cả màn hình đã định nghĩa bên AppPages
      getPages: AppPages.pages,
      
      // (Tùy chọn) Binding khởi tạo các Controller dùng chung (như AuthController)
      // initialBinding: InitialBinding(), 
    );
  }
}