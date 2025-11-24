import 'package:get/get.dart';
import 'package:note_calendar/modules/dashboard/dashboard_binding.dart';
import 'package:note_calendar/modules/dashboard/dashboard_view.dart';
import 'package:note_calendar/modules/settings/settings_view.dart';
import 'app_routes.dart';

// Import màn hình Setup Shop
import '../modules/setup_shop/setup_shop_view.dart'; 
import '../modules/setup_shop/setup_shop_binding.dart';

// Import màn hình Auth
import '../modules/auth/auth_view.dart';
import '../modules/auth/auth_binding.dart';

// Import màn hình splash
import '../modules/splash/splash_view.dart';
import '../modules/splash/splash_binding.dart';

// Import màn hình Services
import '../modules/services/services_view.dart';

import '../modules/calendar/calendar_view.dart';

// Import màn hình Settings
class AppPages {
  static final pages = [
    GetPage(
      name: AppRoutes.SPLASH,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: AppRoutes.LOGIN,
      page: () => const AuthView(),
      binding: AuthBinding(),
    ),
    
    GetPage(
      name: AppRoutes.SETUP_SHOP,
      page: () => const SetupShopView(), 
      binding: SetupShopBinding(),       
    ),
    // --------------------------------------

    GetPage(
      name: AppRoutes.DASHBOARD,
      page: () => const DashboardView(),
      binding: DashboardBinding(),
    ),

    GetPage(
      name: AppRoutes.DASHBOARD,
      page: () => const ServicesView()
    ),

    GetPage(
      name: AppRoutes.DASHBOARD,
      page: () => const SettingsView()
    ),

    GetPage(
      name: AppRoutes.DASHBOARD,
      page: () => const CalendarView()
    ),
  ];
}