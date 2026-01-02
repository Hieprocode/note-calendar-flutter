import 'package:get/get.dart';
import 'app_routes.dart';

// 1. Import các Module chính
import '../modules/splash/splash_view.dart';
import '../modules/splash/splash_binding.dart';

import '../modules/auth/auth_view.dart';
import '../modules/auth/auth_binding.dart';

import '../modules/verify_otp/verify_otp_view.dart';
import '../modules/verify_otp/verify_otp_binding.dart';

import '../modules/setup_shop/setup_shop_view.dart';
import '../modules/setup_shop/setup_shop_binding.dart';

import '../modules/dashboard/dashboard_view.dart';
import '../modules/dashboard/dashboard_binding.dart';

// 2. Import Module Booking (QUAN TRỌNG)
import '../modules/booking/view/add_booking_view.dart'; // <--- Import cái này
import '../modules/booking/view/booking_detail_page.dart';
import '../modules/booking/booking_binding.dart';

import '../modules/customers/customer_view.dart';
import '../modules/customers/customer_binding.dart';

import '../modules/notifications/notification_view.dart';
import '../modules/notifications/notification_binding.dart';
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
      name: AppRoutes.VERIFY_OTP,
      page: () => const VerifyOtpView(),
      binding: VerifyOtpBinding(),
    ),
    GetPage(
      name: AppRoutes.SETUP_SHOP,
      page: () => const SetupShopView(),
      binding: SetupShopBinding(),
    ),
    
    // Dashboard là khung chứa (Parent), các tab con (Calendar, Services...) 
    // nằm TRONG DashboardView, không cần khai báo route riêng ở đây.
    GetPage(
      name: AppRoutes.DASHBOARD,
      page: () => const DashboardView(),
      binding: DashboardBinding(),
    ),

    GetPage(
      name:AppRoutes.CALENDAR,
      page:() => const AddBookingView(),
      binding: BookingBinding(),
    ),

    // --- SỬA LẠI ĐOẠN NÀY CHO ĐÚNG ---
    GetPage(
      name: AppRoutes.ADD_BOOKING,
      page: () => const AddBookingView(), // <--- Phải gọi AddBookingView
      binding: BookingBinding(),
    ),

    GetPage(
      name: AppRoutes.BOOKING_DETAIL,
      page: () => const BookingDetailPage(),
      binding: BookingBinding(),
    ),

    GetPage(
      name: AppRoutes.CUSTOMERS,
      page: () => const CustomerView(),
      binding: CustomerBinding(),
),
    GetPage(
          name: AppRoutes.NOTIFICATIONS,
          page: () => const NotificationView(),
          binding: NotificationBinding(),
        ),
  ];
}