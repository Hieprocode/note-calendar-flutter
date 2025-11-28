// lib/modules/customers/customer_view.dart
import 'package:flutter/material.dart';
import 'package:get/Get.dart';
import 'customer_controller.dart';
import '../../core/widgets/app_slidable.dart';
import 'views/customer_detail_view.dart';
import 'views/add_customer_view.dart';

class CustomerView extends GetView<CustomerController> {
  const CustomerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Quản Lý Khách Hàng"),
        centerTitle: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
      ),

      // ĐÃ BỎ NÚT "THÊM KHÁCH" – KHÁCH TỰ VÀO KHI ĐẶT LỊCH → SIÊU THÔNG MINH!

      body: Column(
        children: [
          // THANH TÌM KIẾM
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: controller.searchController,
              onChanged: (_) => controller.filterCustomers(),
              decoration: InputDecoration(
                hintText: "Tìm tên hoặc số điện thoại...",
                prefixIcon: const Icon(Icons.search),
                suffixIcon: controller.searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          controller.searchController.clear();
                          controller.filterCustomers();
                        },
                      )
                    : null,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(vertical: 18),
              ),
            ),
          ),

          // DANH SÁCH KHÁCH – VUỐT RA: SỬA + XÓA
          Expanded(
  child: Obx(() {
    // PHẢI ĐẶT DÒNG NÀY ĐẦU TIÊN – TRƯỚC KHI DÙNG BIẾN NÀO!
    controller.triggerRefresh.value;

    final customers = controller.filteredCustomers;

    if (customers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_search_rounded, size: 100, color: Colors.grey.shade400),
            const SizedBox(height: 24),
            const Text(
              "Chưa có khách hàng",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            Text(
              "Khách sẽ tự động xuất hiện\nkhi họ đặt lịch lần đầu",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: customers.length,
      itemBuilder: (context, index) {
        final customer = customers[index];

        return AppSlidable(
          itemId: customer.id ?? customer.phone,
          onEdit: () {
            controller.prepareForm(customer: customer);
            Get.bottomSheet(
              const AddCustomerView(),
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
            );
          },
          onDelete: (id) async {
            await controller.deleteCustomer(id);
          },
          child: Card(
            elevation: 5,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: ListTile(
              onTap: () {
                Get.to(() => CustomerDetailView(customer: customer));
              },
              leading: CircleAvatar(
                radius: 34,
                backgroundColor: customer.isBadGuest ? Colors.red.shade100 : Colors.blue.shade100,
                child: Icon(
                  customer.isBadGuest ? Icons.sentiment_very_dissatisfied : Icons.person,
                  size: 40,
                  color: customer.isBadGuest ? Colors.red : Colors.blue,
                ),
              ),
              title: Text(customer.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 19)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(customer.phone, style: const TextStyle(fontSize: 15)),
                  if (customer.isBadGuest)
                    Container(
                      margin: const EdgeInsets.only(top: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(20)),
                      child: const Text("Bùng kèo", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                ],
              ),
              trailing: SizedBox(
                width: 70,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      customer.totalBookings.toString(),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 26, color: Colors.green, height: 1),
                      textAlign: TextAlign.center,
                    ),
                    const Text("lịch hẹn", style: TextStyle(fontSize: 11, color: Colors.grey), textAlign: TextAlign.center),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }),
),
        ],
      ),
    );
  }
}