// lib/modules/dashboard/widgets/circular_booking_chart.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/config/app_colors.dart';
import '../dashboard_controller.dart';
import 'dart:math' as math;

class CircularBookingChart extends GetView<DashboardController> {
  const CircularBookingChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final completed = controller.showDay.value 
        ? controller.completedCount.value 
        : controller.monthCompletedCount.value;
      final confirmed = controller.showDay.value 
        ? controller.confirmedCount.value 
        : controller.monthConfirmedCount.value;
      final checkedIn = controller.showDay.value 
        ? controller.checkedInCount.value 
        : controller.monthCheckedInCount.value;
      final total = completed + confirmed + checkedIn;

      // Nếu không có data, hiển thị chart rỗng
      if (total == 0) {
        return _buildEmptyChart();
      }

      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.glassBackground,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'statistics'.tr,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  controller.showDay.value ? "$total ${'bookings_today'.tr}" : "$total ${'bookings_this_month'.tr}",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TweenAnimationBuilder<double>(
              key: ValueKey(controller.showDay.value), // Force rebuild khi chuyển ngày/tháng
              duration: const Duration(milliseconds: 2000),
              curve: Curves.easeOutCubic,
              tween: Tween<double>(begin: 0.0, end: 1.0),
              builder: (context, animationValue, child) {
                return SizedBox(
                  height: 200,
                  width: 200,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Custom Circular Chart với rounded caps
                      CustomPaint(
                        size: const Size(200, 200),
                        painter: RoundedCircularChartPainter(
                          completed: completed,
                          confirmed: confirmed,
                          checkedIn: checkedIn,
                          total: total,
                          animationValue: animationValue,
                        ),
                      ),
                      // Center text với animation
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "${((completed / total) * 100 * animationValue).toStringAsFixed(0)}%",
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            'success_rate'.tr,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            // Legend
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildLegendItem('completed'.tr, AppColors.orangeLight, completed),
                _buildLegendItem('confirmed'.tr, AppColors.redConfirmed, confirmed),
                _buildLegendItem('checked_in'.tr, AppColors.purpleCheckIn, checkedIn),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildLegendItem(String label, Color color, int count) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              "$count",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEmptyChart() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'booking_status'.tr,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 30),
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.calendar_today_outlined, size: 40, color: Colors.grey),
                  const SizedBox(height: 10),
                  Text(
                    'no_bookings_yet'.tr,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}


// Custom Painter để vẽ circular chart với rounded caps
class RoundedCircularChartPainter extends CustomPainter {
  final int completed;
  final int confirmed;
  final int checkedIn;
  final int total;
  final double animationValue;

  RoundedCircularChartPainter({
    required this.completed,
    required this.confirmed,
    required this.checkedIn,
    required this.total,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 20;
    const strokeWidth = 15.0;
    const gapAngle = 0.3;  
    
    // Tính toán góc cho mỗi section với animation
    final completedAngle = (completed / total) * 2 * math.pi * animationValue - gapAngle;
    final confirmedAngle = (confirmed / total) * 2 * math.pi * animationValue - gapAngle;
    final checkedInAngle = (checkedIn / total) * 2 * math.pi * animationValue - gapAngle;

    double startAngle = -math.pi / 2; // Bắt đầu từ trên cùng

    // Vẽ section Completed (Vàng)
    if (completed > 0) {
      final paint = Paint()
        ..color = AppColors.orangeLight
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round; // Rounded caps!

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        completedAngle,
        false,
        paint,
      );
      startAngle += completedAngle + gapAngle;
    }

    // Vẽ section Confirmed (Đỏ)
    if (confirmed > 0) {
      final paint = Paint()
        ..color = AppColors.redConfirmed
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        confirmedAngle,
        false,
        paint,
      );
      startAngle += confirmedAngle + gapAngle;
    }

    // Vẽ section Checked-in (Tím)
    if (checkedIn > 0) {
      final paint = Paint()
        ..color = AppColors.purpleCheckIn
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        checkedInAngle,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant RoundedCircularChartPainter oldDelegate) {
    return oldDelegate.completed != completed ||
        oldDelegate.confirmed != confirmed ||
        oldDelegate.checkedIn != checkedIn ||
        oldDelegate.total != total ||
        oldDelegate.animationValue != animationValue;
  }
}