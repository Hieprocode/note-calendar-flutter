// lib/modules/dashboard/widgets/circular_service_chart.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/config/app_colors.dart';
import '../dashboard_controller.dart';
import 'dart:math' as math;

class CircularServiceChart extends GetView<DashboardController> {
  const CircularServiceChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final serviceStats = controller.showDay.value 
        ? controller.topServices 
        : controller.monthTopServices;
      
      final allServices = controller.allServices;
      
      // Merge: Tất cả services với booking counts
      final Map<String, int> allServiceCounts = {};
      
      // Thêm tất cả services với count = 0
      for (var service in allServices) {
        allServiceCounts[service.name] = 0;
      }
      
      // Cập nhật count từ bookings
      serviceStats.forEach((serviceName, count) {
        allServiceCounts[serviceName] = count;
      });
      
      // Sắp xếp theo count giảm dần
      final sortedServices = allServiceCounts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      
      // Lấy top 3 có booking
      final topServices = sortedServices.where((e) => e.value > 0).take(3).toList();
      
      if (topServices.isEmpty) {
        return _buildEmptyChart();
      }
      
      final total = topServices.fold<int>(0, (sum, entry) => sum + entry.value);
      
      // Màu sắc cho các dịch vụ
      final colors = [
        const Color(0xFF6366F1), // Indigo
        const Color(0xFFEC4899), // Pink
        const Color(0xFF14B8A6), // Teal
      ];

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
                  'popular_services'.tr,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  controller.showDay.value ? 'today'.tr : 'this_month'.tr,
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
              key: ValueKey(controller.showDay.value),
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
                      CustomPaint(
                        size: const Size(200, 200),
                        painter: ServiceCircularChartPainter(
                          services: topServices,
                          total: total,
                          colors: colors,
                          animationValue: animationValue,
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "${(topServices.isNotEmpty ? (topServices[0].value / total * 100 * animationValue) : 0).toStringAsFixed(0)}%",
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            'top_service'.tr,
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
            // Hiển thị TẤT CẢ services
            ...sortedServices.map((entry) {
              final serviceName = entry.key;
              final count = entry.value;
              final index = sortedServices.indexOf(entry);
              final isTop = index == 0 && count > 0;
              final hasBooking = count > 0;
              
              // Chỉ hiển thị top 3 có booking + các service còn lại
              final isTopThree = index < 3 && hasBooking;
              final color = isTopThree && index < colors.length 
                ? colors[index] 
                : Colors.grey;
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _buildLegendItem(
                  serviceName,
                  color,
                  count,
                  isTop,
                ),
              );
            }).toList(),
          ],
        ),
      );
    });
  }

  Widget _buildLegendItem(String serviceName, Color color, int count, bool isTop) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        if (isTop) ...[
          const Text(
            "👑",
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(width: 4),
        ],
        Expanded(
          child: Text(
            serviceName,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isTop ? FontWeight.w600 : FontWeight.w400,
              color: count > 0 ? AppColors.textPrimary : AppColors.textSecondary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: count > 0 ? color.withOpacity(0.1) : Colors.grey.withOpacity(0.05),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            "$count",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: count > 0 ? color : Colors.grey,
            ),
          ),
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
            'popular_services'.tr,
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
                  const Icon(Icons.spa_outlined, size: 40, color: Colors.grey),
                  const SizedBox(height: 10),
                  Text(
                    'no_data'.tr,
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

// Custom Painter cho service chart
class ServiceCircularChartPainter extends CustomPainter {
  final List<MapEntry<String, int>> services;
  final int total;
  final List<Color> colors;
  final double animationValue;

  ServiceCircularChartPainter({
    required this.services,
    required this.total,
    required this.colors,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 20;
    const strokeWidth = 15.0;
    const gapAngle = 0.3;
    
    double startAngle = -math.pi / 2;
    
    for (int i = 0; i < services.length && i < colors.length; i++) {
      final service = services[i];
      final sweepAngle = (service.value / total) * 2 * math.pi * animationValue - gapAngle;
      
      if (sweepAngle > 0) {
        final paint = Paint()
          ..color = colors[i]
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round;

        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          startAngle,
          sweepAngle,
          false,
          paint,
        );
        
        startAngle += sweepAngle + gapAngle;
      }
    }
  }

  @override
  bool shouldRepaint(ServiceCircularChartPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
           oldDelegate.services != services;
  }
}
