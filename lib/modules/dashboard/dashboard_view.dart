import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:note_calendar/modules/calendar/calendar_view.dart';
import 'dashboard_controller.dart';

// Import các màn hình con (Tạm thời dùng Placeholder nếu chưa code xong)
import '../services/services_view.dart';
import '../settings/settings_view.dart';
// import '../calendar/calendar_view.dart'; 

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Dùng IndexedStack để giữ trạng thái các màn hình khi chuyển tab
      // (Không bị load lại dữ liệu khi chuyển qua lại)
      body: Obx(() => IndexedStack(
        index: controller.currentTabIndex.value,
        children: [
          _buildHomeTab(),           // Tab 0: Trang chủ Dashboard
          const Center(child: CalendarView()), // Tab 1 (Placeholder)
          const Center(child: ServicesView()), // Tab 2 
          const Center(child: SettingsView()), // Tab 3 
        ],
      )),
      
      // Thanh điều hướng dưới đáy
      bottomNavigationBar: Obx(() => BottomNavigationBar(
        currentIndex: controller.currentTabIndex.value,
        onTap: controller.changeTab,
        type: BottomNavigationBarType.fixed, // Cố định, không hiệu ứng nhảy
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

  // --- GIAO DIỆN TAB 0: TỔNG QUAN (HOME) ---
  Widget _buildHomeTab() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Header: Xin chào Shop
            Row(
              children: [
                Obx(() {
                  // Nếu có Avatar thì hiện, không thì hiện Icon mặc định
                  var url = controller.currentShop.value?.avatarUrl;
                  return CircleAvatar(
                    radius: 25,
                    backgroundImage: url != null ? NetworkImage(url) : null,
                    child: url == null ? const Icon(Icons.store) : null,
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

            // 2. Card Thống kê nhanh
            const Text("Hôm nay", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            Row(
              children: [
                _buildStatCard("Doanh thu", "0đ", Colors.green, Icons.attach_money),
                const SizedBox(width: 15),
                _buildStatCard("Lịch hẹn", "0", Colors.orange, Icons.people),
              ],
            ),

            const SizedBox(height: 30),

            // 3. Phím tắt chức năng
            const Text("Phím tắt", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              childAspectRatio: 1.2,
              children: [
                _buildActionButton(Icons.add, "Tạo đơn", Colors.blue, () {}),
                _buildActionButton(Icons.list, "DS Khách", Colors.purple, () {}),
                _buildActionButton(Icons.notifications, "Thông báo", Colors.red, () {}),
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
            Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
            Text(title, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  // Widget con: Nút chức năng
  Widget _buildActionButton(IconData icon, String label, Color color, VoidCallback onTap) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
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