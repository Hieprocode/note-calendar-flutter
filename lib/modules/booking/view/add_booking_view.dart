// lib/modules/booking/view/add_booking_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../data/models/service_model.dart';
import '../../../core/config/app_colors.dart';
import '../booking_controller.dart';

class AddBookingView extends StatelessWidget {
  const AddBookingView({super.key});

  // Cached formatters for performance
  static final _dateFormat = DateFormat('dd/MM/yyyy');

  // Cached const widgets to avoid rebuilds
  static const _calendarIcon = Icon(Icons.calendar_today_rounded, color: AppColors.primary, size: 20);
  static const _timeIcon = Icon(Icons.access_time_rounded, color: AppColors.primary, size: 20);

  // Cached decoration for reuse (white glass style)
  static final _whiteGlassDecoration = BoxDecoration(
    color: Colors.white.withOpacity(0.7),
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: Colors.white.withOpacity(0.8), width: 1.5),
    boxShadow: [
      BoxShadow(
        color: Colors.blue.withOpacity(0.08),
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BookingController>();

    return Container(
      color: Colors.transparent,
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: DraggableScrollableSheet(
          initialChildSize: 0.9,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          expand: false,
          builder: (_, scrollController) => Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFF0F4FF),
                  Color(0xFFFFFFFF),
                  Color(0xFFF8FAFF),
                ],
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                // Thanh kéo
                Container(
                  margin: const EdgeInsets.only(top: 10),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 16),

                // Nội dung cuộn
                Expanded(
                  child: SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // GLASS HEADER
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: _whiteGlassDecoration,
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF4A90E2), Color(0xFF357ABD)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.event_available_rounded, color: Colors.white, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'create_booking'.tr,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2D3748),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // GLASS FORM CONTAINER
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: _whiteGlassDecoration,
                    child: Column(
                      children: [
                        // Tên khách
                        TextField(
                          controller: controller.nameController,
                          style: const TextStyle(color: AppColors.textPrimaryConst, fontWeight: FontWeight.w500),
                          decoration: _buildInputDecoration(
                            label: 'customer_name'.tr,
                            prefixWidget: Image.asset(
                              'assets/user.png',
                              width: 13,
                              height: 13,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),

                        // Số điện thoại
                        TextField(
                          controller: controller.phoneController,
                          keyboardType: TextInputType.phone,
                          style: const TextStyle(color: AppColors.textPrimaryConst, fontWeight: FontWeight.w500),
                          decoration: _buildInputDecoration(
                            label: 'phone_number'.tr,
                            prefixWidget: Image.asset(
                              'assets/phone.png',
                              width: 13,
                              height: 13,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),

                        // Dịch vụ
                        Obx(() {
                          final services = controller.servicesList;
                          final currentSelected = controller.selectedService.value;
                          final isServiceDeleted = currentSelected != null && 
                            !services.any((s) => s.id == currentSelected.id);
                          if (isServiceDeleted) {
                            controller.selectedService.value = null;
                          }
              
                          return DropdownButtonFormField<ServiceModel>(
                            value: controller.selectedService.value,
                            hint: Text('select_service'.tr, style: const TextStyle(color: AppColors.textSecondaryConst)),
                            style: const TextStyle(color: AppColors.textPrimaryConst, fontWeight: FontWeight.w500),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.7),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: AppColors.glassBorderConst),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: AppColors.glassBorderConst, width: 1.5),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: AppColors.primary, width: 2),
                              ),
                              prefixIcon: const Icon(Icons.spa_rounded, color: AppColors.primary)
                            ),
                            icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primary, size: 24),
                            dropdownColor: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            elevation: 8,
                            menuMaxHeight: 300,
                            items: controller.servicesList.map((s) => DropdownMenuItem(
                              value: s,
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryLightest.withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(Icons.spa_rounded, color: AppColors.primary, size: 14),
                                  ),
                                  const SizedBox(width: 10),
                                  Text("${s.name} (${s.durationMinutes}p)"),
                                ],
                              ),
                            )).toList(),
                            onChanged: (val) => controller.selectService(val!),
                          );
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // DATE & TIME GLASS CONTAINER
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: _whiteGlassDecoration,
                    child: Column(
                      children: [
                        RepaintBoundary(
                          child: Row(
                            children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.7),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.glassBorder, width: 1.5),
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(12),
                                    onTap: () async {
                                      final d = await showDatePicker(
                                        context: context,
                                        initialDate: controller.selectedDate.value,
                                        firstDate: DateTime.now(),
                                        lastDate: DateTime.now().add(const Duration(days: 365)),
                                        initialEntryMode: DatePickerEntryMode.calendarOnly,
                                        builder: (context, child) {
                                          return Theme(
                                            data: Theme.of(context).copyWith(
                                              colorScheme: ColorScheme.light(
                                                primary: AppColors.primary,
                                                onPrimary: Colors.white,
                                                surface: Colors.white,
                                                onSurface: AppColors.textPrimary,
                                              ),
                                              textButtonTheme: TextButtonThemeData(
                                                style: TextButton.styleFrom(
                                                  foregroundColor: AppColors.primary,
                                                  textStyle: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              datePickerTheme: DatePickerThemeData(
                                                backgroundColor: Colors.white,
                                                headerBackgroundColor: AppColors.primary,
                                                headerForegroundColor: Colors.white,
                                                todayBackgroundColor: MaterialStateProperty.resolveWith((states) {
                                                  if (states.contains(MaterialState.selected)) {
                                                    return AppColors.primary;
                                                  }
                                                  return const Color(0xFFFFD700).withOpacity(0.3); // Màu vàng nhạt cho ngày hiện tại
                                                }),
                                                todayForegroundColor: MaterialStateProperty.resolveWith((states) {
                                                  if (states.contains(MaterialState.selected)) {
                                                    return Colors.white;
                                                  }
                                                  return AppColors.primary;
                                                }),
                                                todayBorder: const BorderSide(
                                                  color: Color(0xFFFFD700), // Viền vàng cho ngày hiện tại
                                                  width: 2,
                                                ),
                                                dayStyle: const TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                            child: child!,
                                          );
                                        },
                                      );
                                      if (d != null) controller.selectedDate.value = d;
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          _calendarIcon,
                                          const SizedBox(width: 8),
                                          Obx(() => Text(
                                            _dateFormat.format(controller.selectedDate.value),
                                            style: const TextStyle(
                                              color: AppColors.textPrimaryConst,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 15,
                                            ),
                                          )),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.7),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.glassBorder, width: 1.5),
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(12),
                                    onTap: () async {
                                      final t = await showTimePicker(
                                        context: context,
                                        initialTime: controller.selectedTime.value,
                                        builder: (context, child) {
                                          return Theme(
                                            data: Theme.of(context).copyWith(
                                              colorScheme: const ColorScheme.light(
                                                primary: AppColors.primary,
                                                onPrimary: Colors.white,
                                                surface: Colors.white,
                                              ),
                                            ),
                                            child: child!,
                                          );
                                        },
                                      );
                                      if (t != null) controller.selectTime(t);
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          _timeIcon,
                                          const SizedBox(width: 8),
                                          Obx(() => Text(
                                            controller.selectedTime.value.format(context),
                                            style: const TextStyle(
                                              color: AppColors.textPrimaryConst,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 15,
                                            ),
                                          )),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF059669).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFF059669).withOpacity(0.3), width: 1.5),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle_rounded, color: Color(0xFF059669), size: 20),
                              const SizedBox(width: 8),
                              Obx(() => Text(
                                "${'expected_end_time'.tr}: ${controller.endTime.value.format(context)}",
                                style: const TextStyle(
                                  color: AppColors.green,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              )),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // SAVE BUTTON
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4A90E2), Color(0xFF357ABD)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF4A90E2).withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () async {
                          await controller.saveBooking();
                          if (context.mounted) Navigator.pop(context);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: Text(
                              'save_booking'.tr,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
            ],
          ),
        ),
      ),
      ),
    );

  }

  // Helper method to build input decoration (reusable)
  InputDecoration _buildInputDecoration({
    required String label,
    required Widget prefixWidget,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppColors.primary),
      filled: true,
      fillColor: Colors.white.withOpacity(0.7),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.glassBorderConst),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.glassBorderConst, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      prefixIcon: Padding(
        padding: const EdgeInsets.all(20),
        child: prefixWidget,
      ),
    );
  }
}