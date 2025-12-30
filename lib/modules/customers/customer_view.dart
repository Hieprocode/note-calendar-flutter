// lib/modules/customers/customer_view.dart
import 'package:flutter/material.dart';
import 'package:get/Get.dart';
import 'customer_controller.dart';
import '../../core/widgets/app_slidable.dart';
import '../../core/config/app_colors.dart';
import 'views/customer_detail_view.dart';
import 'views/add_customer_view.dart';

class CustomerView extends GetView<CustomerController> {
  const CustomerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      appBar: AppBar(
        title: const Text(
          "Quản Lý Khách Hàng",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
          ),
        ),
      ),

      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF0F4FF),
              Color(0xFFFFFFFF),
              Color(0xFFF8FAFF),
            ],
          ),
        ),
        child: Column(
          children: [
            // THANH TÌM KIẾM với Glass Effect
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.8),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.08),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: TextField(
                  controller: controller.searchController,
                  onChanged: (_) => controller.filterCustomers(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    hintText: "Tìm tên hoặc số điện thoại...",
                    hintStyle: TextStyle(
                      color: Colors.grey.shade400,
                    ),
                    prefixIcon: Container(
                      margin: const EdgeInsets.all(8),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.search_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    suffixIcon: controller.searchController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear_rounded, color: AppColors.textSecondary),
                            onPressed: () {
                              controller.searchController.clear();
                              controller.filterCustomers();
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
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
        child: Container(
          margin: const EdgeInsets.all(32),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.7),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withOpacity(0.8),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.08),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primaryLightest.withOpacity(0.3),
                      AppColors.primaryLighter.withOpacity(0.2),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person_search_rounded,
                  size: 80,
                  color: AppColors.primary.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                "Chưa có khách hàng",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimaryConst,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Khách sẽ tự động xuất hiện\nkhi họ đặt lịch lần đầu",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: customers.length,
      itemBuilder: (context, index) {
        final customer = customers[index];

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: AppSlidable(
            itemId: customer.id,
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
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: customer.isBadGuest 
                    ? Colors.red.withOpacity(0.3)
                    : Colors.white.withOpacity(0.8),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: customer.isBadGuest
                      ? Colors.red.withOpacity(0.1)
                      : AppColors.primary.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    Get.to(() => CustomerDetailView(customer: customer));
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        // Avatar với gradient hoặc ảnh thật
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            gradient: customer.avatarUrl == null
                              ? (customer.isBadGuest
                                  ? LinearGradient(
                                      colors: [
                                        Colors.red.shade300,
                                        Colors.red.shade400,
                                      ],
                                    )
                                  : AppColors.primaryGradient)
                              : null,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: customer.isBadGuest
                                ? Colors.red.withOpacity(0.5)
                                : AppColors.primary.withOpacity(0.3),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: (customer.isBadGuest ? Colors.red : AppColors.primary)
                                  .withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: customer.avatarUrl != null
                              ? Image.network(
                                  customer.avatarUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Icon(
                                    customer.isBadGuest
                                      ? Icons.sentiment_very_dissatisfied_rounded
                                      : Icons.person_rounded,
                                    size: 32,
                                    color: Colors.white,
                                  ),
                                )
                              : Icon(
                                  customer.isBadGuest
                                    ? Icons.sentiment_very_dissatisfied_rounded
                                    : Icons.person_rounded,
                                  size: 32,
                                  color: Colors.white,
                                ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                customer.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: AppColors.textPrimaryConst,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.phone_rounded,
                                    size: 14,
                                    color: AppColors.textSecondary,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    customer.phone,
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                              if (customer.isBadGuest) ...[
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text(
                                    "⚠️ Bùng kèo",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        // Booking count
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.green.withOpacity(0.1),
                                AppColors.green.withOpacity(0.05),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Text(
                                customer.totalBookings.toString(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 24,
                                  color: AppColors.green,
                                  height: 1,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "lịch hẹn",
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
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
            ),
          ),
        );
      },
    );
  }),
),
          ],
        ),
      ),
    );
  }
}