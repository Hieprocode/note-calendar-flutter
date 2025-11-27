import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'dashboard_controller.dart';
import '../../routes/app_routes.dart';

// Import các màn hình con
import '../services/services_view.dart';
import '../settings/settings_view.dart';
import '../calendar/calendar_view.dart';

// Import Booking để dùng cho nút "Tạo đơn"
import '../booking/booking_controller.dart';
import '../booking/view/add_booking_view.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Giữ trạng thái các tab để không phải load lại
      body: Obx(() => IndexedStack(
        index: controller.currentTabIndex.value,
        children: [
          _buildHomeTab(),          // Tab 0: Trang chủ
          const CalendarView(),     // Tab 1: Lịch
          const ServicesView(),     // Tab 2: Dịch vụ
          const SettingsView(),     // Tab 3: Cài đặt
        ],
      )),
      
      // Thanh điều hướng dưới đáy
      bottomNavigationBar: Obx(() => BottomNavigationBar(
        currentIndex: controller.currentTabIndex.value,
        onTap: controller.changeTab,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Tổng quan'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'Lịch'),
          BottomNavigationBarItem(icon: Icon(Icons.spa), label: 'Dịch vụ'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Cài đặt'),
        ],
      )),
    );
  }

  // --- TAB TỔNG QUAN (HOME) ---
  Widget _buildHomeTab() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. HEADER: Xin chào Shop
            Row(
              children: [
                Obx(() {
                  var url = controller.currentShop.value?.avatarUrl;
                  bool isValid = url != null && url.isNotEmpty && url.startsWith('http');
                  return CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.grey.shade200,
                    backgroundImage: isValid ? NetworkImage(url) : null,
                    child: !isValid ? const Icon(Icons.store, color: Colors.grey) : null,
                  );
                }),
                const SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Xin chào,", style: TextStyle(color: Colors.grey)),
                    Obx(() => Text(
                      controller.currentShop.value?.name ?? "Đang tải...",
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    )),
                  ],
                )
              ],
            ),

            const SizedBox(height: 30),

            // 2. THỐNG KÊ (REALTIME)
            const Text("Hôm nay", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            Obx(() => Row(
              children: [
                _buildStatCard(
                  "Doanh thu", 
                  NumberFormat.currency(locale: 'vi', symbol: 'đ').format(controller.todayRevenue.value), 
                  Colors.green, 
                  Icons.attach_money
                ),
                const SizedBox(width: 15),
                _buildStatCard(
                  "Lịch hẹn", 
                  "${controller.todayBookingCount.value}", 
                  Colors.orange, 
                  Icons.people
                ),
              ],
            )),

            const SizedBox(height: 30),

            // 3. PHÍM TẮT CHỨC NĂNG
            const Text("Phím tắt", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              childAspectRatio: 1.2,
              children: [
                
                // NÚT 1: TẠO ĐƠN (Mở BottomSheet Booking)
                _buildActionButton(Icons.add, "Tạo đơn", Colors.blue, () {
                   // Reset form trước khi mở
                   Get.find<BookingController>().resetFormForAdd();
                   
                   // Mở bảng nhập liệu
                   Get.bottomSheet(
                     const AddBookingView(),
                     isScrollControlled: true,
                     backgroundColor: Colors.transparent,
                     enterBottomSheetDuration: const Duration(milliseconds: 300),
                     exitBottomSheetDuration: const Duration(milliseconds: 250),
                   );
                }),

                // NÚT 2: DS KHÁCH (Chưa làm -> Hiện thông báo)
                _buildActionButton(Icons.list, "DS Khách", Colors.purple, () {
                   Get.toNamed(AppRoutes.CUSTOMERS);
                }),

                // NÚT 3: THÔNG BÁO (Chưa làm -> Hiện thông báo)
                _buildActionButton(Icons.notifications, "Thông báo", Colors.red, () {
                   Get.snackbar(
                     "Thông báo", 
                     "Tính năng Thông báo sẽ có trong bản cập nhật sau",
                     snackPosition: SnackPosition.BOTTOM,
                     backgroundColor: Colors.black87,
                     colorText: Colors.white,
                     margin: const EdgeInsets.all(10),
                     borderRadius: 10,
                   );
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Widget con: Thẻ thống kê
  Widget _buildStatCard(String title, String value, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: 10),
            Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
            Text(title, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  // Widget con: Nút chức năng (Đã tối ưu)
  Widget _buildActionButton(IconData icon, String label, Color color, VoidCallback onTap) {
    return Column(
      children: [
        InkWell(
          onTap: onTap, // Gọi hàm được truyền vào
          borderRadius: BorderRadius.circular(15),
          child: Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: color, size: 30),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}