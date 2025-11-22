import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'app_routes.dart';

// Import màn hình Setup Shop
import '../setup_shop/setup_shop_view.dart'; 
import '../setup_shop/setup_shop_binding.dart';

// Import màn hình Auth
import '../auth/auth_view.dart';
import '../auth/auth_binding.dart';

class AppPages {
  static final pages = [
    GetPage(
      name: AppRoutes.LOGIN,
      page: () => const AuthView(),
      binding: AuthBinding(),
    ),
    
    // --- ĐOẠN QUAN TRỌNG NHẤT LÀ Ở ĐÂY ---
    GetPage(
      name: AppRoutes.SETUP_SHOP,
      page: () => const SetupShopView(), // Phải là SetupShopView, KHÔNG ĐƯỢC LÀ Scaffold(...)
      binding: SetupShopBinding(),       // Phải có Binding
    ),
    // --------------------------------------

    GetPage(
      name: AppRoutes.DASHBOARD,
      page: () => const Scaffold(body: Center(child: Text("Dashboard"))),
    ),
  ];
}