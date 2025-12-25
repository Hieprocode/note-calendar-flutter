import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'dashboard_controller.dart';
import '../../routes/app_routes.dart';
import '../../core/config/app_colors.dart';

// Import các màn hình con
import '../services/services_view.dart';
import '../settings/settings_view.dart';
import '../calendar/calendar_view.dart';

// Import Booking để dùng cho nút "Tạo đơn"
import '../booking/booking_controller.dart';
import '../booking/view/add_booking_view.dart';

// Import Circular Chart Widget
import 'widgets/circular_booking_chart.dart';
import 'widgets/circular_service_chart.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() => IndexedStack(
        index: controller.currentTabIndex.value,
        children: [
          _buildHomeTab(),          // Tab 0: Trang chủ
           CalendarView(),     // Tab 1: Lịch
          const ServicesView(),     // Tab 2: Dịch vụ
          const SettingsView(),     // Tab 3: Cài đặt
        ],
      )),
      
      // Thanh điều hướng dưới đáy với curve design
      bottomNavigationBar: Obx(() => CurvedNavigationBar(
        index: controller.currentTabIndex.value,
        height: 65,
        items: <Widget>[
          Image.asset('assets/dashboard.png', width: 25, height: 25, color: Colors.white,),
          Image.asset('assets/calendar.png', width: 25, height: 25, color: Colors.white,),
          Image.asset('assets/tools.png', width: 25, height: 25, color: Colors.white,),
          Image.asset('assets/settings.png', width: 25, height: 25, color: Colors.white,),
        ],
        color: AppColors.primaryDark,
        buttonBackgroundColor: AppColors.primaryLighter,
        backgroundColor: Colors.transparent,
        animationCurve: Curves.easeInOutCubic,
        animationDuration: const Duration(milliseconds: 400),
        onTap: (index) {
          controller.changeTab(index);
        },
        letIndexChange: (index) => true,
      )),
    );
  }

  // --- TAB TỔNG QUAN (HOME) ---
  Widget _buildHomeTab() {
    return Stack(
      children: [
        // Phần 1: Background gradient 1/3 màn hình
        Column(
          children: [
            // Container với background image
            Container(
              height: Get.height * 0.33,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/background1.png'),
                  fit: BoxFit.cover,
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header: Button thông báo ở góc phải
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          _buildGlassButton(
                            Icons.notifications_outlined,
                            () => Get.toNamed(AppRoutes.NOTIFICATIONS),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Avatar và xin chào với glass morphism
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.glassBackground,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.glassBorder,
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Obx(() {
                              var url = controller.currentShop.value?.avatarUrl;
                              bool isValid = url != null && url.isNotEmpty && url.startsWith('http');
                              return Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppColors.glassBackground.withOpacity(0.5), width: 3),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: CircleAvatar(
                                  radius: 30,
                                  backgroundColor: AppColors.ivory.withOpacity(0.3),
                                  backgroundImage: isValid ? NetworkImage(url) : null,
                                  child: !isValid ? const Icon(Icons.store, color: Colors.white, size: 30) : null,
                                ),
                              );
                            }),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'hello'.tr,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Obx(() => Text(
                                    controller.currentShop.value?.name ?? 'loading_shop'.tr,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  )),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(child: Container(color: AppColors.ivory)),
          ],
        ),
        
        // Phần 2: Container trắng với curved top
        Positioned(
          top: Get.height * 0.28,
          left: 5,
          right: 5,
          bottom: 0,
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/polygon-scatter-haikei (1).png'),
                fit: BoxFit.cover,
                opacity: 0.7, // Tùy chỉnh opacity tại đây (0.0 - 1.0)
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(40),
                topRight: Radius.circular(40),
              ),
            ),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics()  ,
              padding: const EdgeInsets.only(top: 30, left: 20, right: 20, bottom: 100),
              child: Column(
                children: [
                  _buildToggleStatCard(),
                  const SizedBox(height: 25),
                  _buildDateToggle(),
                  const SizedBox(height: 20),
                  const CircularBookingChart(),
                  const SizedBox(height: 25),
                  const CircularServiceChart(),
                  const SizedBox(height: 25),
                  // Phím tắt
                  Row(
                    children: [
                      Expanded(
                        child: _buildMainActionCard(
                          'create_booking_short'.tr,
                          null,
                          AppColors.cardBackground,
                          () {
                            Get.find<BookingController>().resetFormForAdd();
                            Get.bottomSheet(
                              const AddBookingView(),
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              enterBottomSheetDuration: const Duration(milliseconds: 300),
                              exitBottomSheetDuration: const Duration(milliseconds: 250),
                            );
                          },
                          imagePath: 'assets/add.png',
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: _buildMainActionCard(
                          'customer_list_short'.tr,
                          null,
                          AppColors.cardBackground,
                          () => Get.toNamed(AppRoutes.CUSTOMERS),
                          imagePath: 'assets/customer-satisfaction.png',
                        ),
                      ),
                    ],
                  ),
                  
                  // Circular Chart
                  
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  // Toggle ngày/tháng
  Widget _buildDateToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            Colors.white,
          ],
        ),
      ),
      child: Row(
        children: [
          // Tab Ngày
          Expanded(
            child: Obx(() => GestureDetector(
              onTap: () => controller.showDay.value = true,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: controller.showDay.value
                    ? AppColors.primaryLight.withOpacity(0.2)
                    : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: controller.showDay.value
                    ? Border.all(
                        color: AppColors.primaryLight.withOpacity(0.5),
                        width: 1.5,
                      )
                    : null,
                  boxShadow: controller.showDay.value ? [
                    BoxShadow(
                      color: AppColors.primaryLight.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ] : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.today,
                      size: 18,
                      color: controller.showDay.value 
                        ? AppColors.primary
                        : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'today'.tr,
                      style: TextStyle(
                        color: controller.showDay.value 
                          ? AppColors.textPrimary
                          : AppColors.primaryDark,
                        fontWeight: controller.showDay.value 
                          ? FontWeight.w600 
                          : FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            )),
          ),
          // Tab Tháng
          Expanded(
            child: Obx(() => GestureDetector(
              onTap: () => controller.showDay.value = false,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: !controller.showDay.value
                    ? AppColors.primaryLight.withOpacity(0.2)
                    : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: !controller.showDay.value
                    ? Border.all(
                        color: AppColors.primaryLight.withOpacity(0.5),
                        width: 1.5,
                      )
                    : null,
                  boxShadow: !controller.showDay.value ? [
                    BoxShadow(
                      color: AppColors.primaryLight.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ] : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.calendar_month,
                      size: 18,
                      color: !controller.showDay.value 
                        ? AppColors.primary
                        : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'this_month'.tr,
                      style: TextStyle(
                        color: !controller.showDay.value 
                          ? AppColors.textPrimary
                          : AppColors.primaryDark,
                        fontWeight: !controller.showDay.value 
                          ? FontWeight.w600 
                          : FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            )),
          ),
        ],
      ),
    );
  }
  
  // Glass morphism button cho thông báo
  Widget _buildGlassButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.glassBackground,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: AppColors.glassBorder,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Icon(icon, color: AppColors.orangeLight, size: 24),
      ),
    );
  }
  
  // Toggle stat card (doanh thu <-> lịch hẹn)
  Widget _buildToggleStatCard() {
    return Column(
      children: [
        // Custom Toggle Switch
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                Colors.white,
              ],
            )
          ),
          child: Row(
            children: [
              // Tab Doanh thu
              Expanded(
                child: Obx(() => GestureDetector(
                  onTap: () => controller.showRevenue.value = true,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: controller.showRevenue.value
                        ? AppColors.orange.withOpacity(0.5)
                        : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: controller.showRevenue.value
                        ? Border.all(
                            color: AppColors.orange.withOpacity(0.5),
                            width: 1.5,
                          )
                        : null,
                      boxShadow: controller.showRevenue.value ? [
                        BoxShadow(
                          color: AppColors.orange.withOpacity(0.5),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ] : null,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/money.png',
                          width: 20,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'revenue_short'.tr,
                          style: TextStyle(
                            color: controller.showRevenue.value 
                              ? AppColors.textPrimary
                              : AppColors.primaryDark,
                            fontWeight: controller.showRevenue.value 
                              ? FontWeight.w600 
                              : FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
              ),
              // Tab Lịch hẹn
              Expanded(
                child: Obx(() => GestureDetector(
                  onTap: () => controller.showRevenue.value = false,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: !controller.showRevenue.value
                        ? AppColors.orange.withOpacity(0.5)
                        : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: !controller.showRevenue.value
                        ? Border.all(
                            color: AppColors.orange.withOpacity(0.5),
                            width: 1.5,
                          )
                        : null,
                      boxShadow: !controller.showRevenue.value ? [
                        BoxShadow(
                          color: AppColors.orange.withOpacity(0.5),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ] : null,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/booking.png',
                          width: 20,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'calendar'.tr,
                          style: TextStyle(
                            color: !controller.showRevenue.value 
                              ? AppColors.textPrimary
                              : AppColors.primaryDark,
                            fontWeight: !controller.showRevenue.value 
                              ? FontWeight.w600 
                              : FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 20),
        
        // Stat Card
        Obx(() => AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.0, 0.1),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            );
          },
          child: Container(
            key: ValueKey<bool>(controller.showRevenue.value),
            width: double.infinity,
            height: 150,
            margin: const EdgeInsets.symmetric(vertical: 10),
            padding: const EdgeInsets.only(left: 20),
            decoration: BoxDecoration(
              gradient: AppColors.orangeGradient,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.orange.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      controller.showRevenue.value 
                        ? (controller.showDay.value ? 'today_revenue'.tr : 'month_revenue_full'.tr)
                        : (controller.showDay.value ? 'today_bookings_full'.tr : 'month_bookings_full'.tr),
                      style: const TextStyle(
                        color: AppColors.primaryDark,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Image.asset(
                          controller.showRevenue.value
                            ? 'assets/money.png'
                            : 'assets/booking.png',
                            width: 30,                        
                        ),
                        const SizedBox(width: 10),
                        Text(
                      controller.showRevenue.value
                        ? NumberFormat.currency(locale: 'vi', symbol: 'đ')
                            .format(controller.showDay.value 
                              ? controller.todayRevenue.value 
                              : controller.monthRevenue.value)
                        : controller.showDay.value
                          ? "${controller.todayBookingCount.value} ${'guests'.tr}"
                          : "${controller.monthBookingCount.value} ${'guests'.tr}",
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryDark,
                      ),
                    ),
                      ],
                    ),                           
                  ],
                ),
                // Icon với glass morphism ở góc phải trên
                Positioned(
                  top: 2,
                  right: 2,
                  child: Transform.rotate(
                    angle: -0.524, // -30 độ (về bên trái)
                    child: Container(
                      width: 100,
                      height: 100,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: controller.showRevenue.value 
                        ? Image.asset(
                            'assets/money.png',
                            width: 50,
                            height: 50, )
                        : Image.asset(
                            'assets/booking.png',
                            width: 50,
                            height: 50,
                        ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        )),
      ],
    );
  }
  
  // Main action cards cho các chức năng chính
  Widget _buildMainActionCard(String title, IconData? icon, Color color, VoidCallback onTap, {String? imagePath}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 20),
        decoration: BoxDecoration(
          color: AppColors.glassBorder,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: imagePath != null 
                ? Image.asset(imagePath, width: 35, height: 35)
                : Icon(icon, color: color, size: 35),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}