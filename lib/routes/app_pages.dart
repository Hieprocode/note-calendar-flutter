import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'app_routes.dart';

// Import màn hình Setup Shop
import '../modules/setup_shop/setup_shop_view.dart'; 
import '../modules/setup_shop/setup_shop_binding.dart';

// Import màn hình Auth
import '../modules/auth/auth_view.dart';
import '../modules/auth/auth_binding.dart';

class AppPages {
  static final pages = [
    GetPage(
      name: AppRoutes.LOGIN,
      page: () => const AuthView(),
      binding: AuthBinding(),
    ),
    
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