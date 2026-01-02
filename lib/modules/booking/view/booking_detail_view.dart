// lib/modules/booking/views/booking_detail_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:note_calendar/modules/calendar/calendar_controller.dart';
import '../../../../data/models/booking_model.dart';
import '../booking_controller.dart'; // <-- QUAN TRỌNG: Dùng BookingController để có thông báo ngoài thiết bị

// Hàm mở chi tiết từ bên ngoài (giữ nguyên)
void showBookingDetail(BookingModel booking) {
  showModalBottomSheet(
    context: Get.context!,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => BookingDetailContent(booking: booking),
  );
}

class BookingDetailContent extends StatelessWidget {
  final BookingModel booking;
  const BookingDetailContent({super.key, required this.booking});

  // Cached formatters for performance
  static final _timeFormat = DateFormat('HH:mm');
  static final _fullDateFormat = DateFormat('EEEE, dd/MM/yyyy', 'vi');
  static final _currencyFormat = NumberFormat.currency(locale: 'vi', symbol: 'đ');

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Lắng nghe refresh từ BookingController
      BookingController.triggerRefresh.value;

      // Lấy booking mới nhất từ danh sách (nếu có thay đổi)
      final calendarCtrl = Get.find<CalendarController>();
      final updatedBooking = calendarCtrl.allBookings.firstWhereOrNull(
            (b) => b.id == booking.id,
          ) ??
          booking;

      return DraggableScrollableSheet(
        initialChildSize: 0.7,
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

              // Glass Header
              Container(
                margin: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.8), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
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
                      child: const Icon(Icons.event_note_rounded, color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'booking_detail_title'.tr,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D3748),
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.close_rounded, size: 22),
                        onPressed: () => Navigator.pop(context),
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),

              // Nội dung cuộn
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Glass Customer Card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withOpacity(0.8), width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.1),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                                    ),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF667EEA).withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(Icons.person_rounded, color: Colors.white, size: 26),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        updatedBooking.customerName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          color: Color(0xFF2D3748),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(Icons.phone_rounded, size: 14, color: Colors.grey.shade600),
                                          const SizedBox(width: 4),
                                          Text(
                                            updatedBooking.customerPhone,
                                            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF11998E), Color(0xFF38EF7D)],
                                ),
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF11998E).withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.payments_rounded, color: Colors.white, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    _currencyFormat.format(updatedBooking.servicePrice),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      fontSize: 20,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Glass Info Container
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
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
                        ),
                        child: Column(
                          children: [
                            // Dịch vụ
                            _buildInfoRow(
                              icon: Icons.spa_rounded,
                              iconColor: const Color(0xFF9333EA),
                              label: 'service'.tr,
                              value: updatedBooking.serviceName,
                            ),
                            const Divider(height: 24),
                            
                            // Giờ
                            _buildInfoRow(
                              icon: Icons.access_time_rounded,
                              iconColor: const Color(0xFFEA580C),
                              label: 'time'.tr,
                              value: '${_timeFormat.format(updatedBooking.startTime)} → ${_timeFormat.format(updatedBooking.endTime)} (${updatedBooking.durationMinutes} ${'minutes_short'.tr})',
                            ),
                            const Divider(height: 24),
                            
                            // Ngày
                            _buildInfoRow(
                              icon: Icons.calendar_today_rounded,
                              iconColor: const Color(0xFF2563EB),
                              label: 'appointment_date'.tr,
                              value: _fullDateFormat.format(updatedBooking.startTime),
                            ),
                          ],
                        ),
                      ),

                      // Ghi chú
                      if (updatedBooking.note?.isNotEmpty == true) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade50.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.amber.shade200, width: 1.5),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.note_rounded, color: Colors.amber.shade700, size: 20),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  updatedBooking.note!,
                                  style: TextStyle(
                                    color: Colors.grey.shade800,
                                    fontSize: 14,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 24),

                      // Status Label
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'update_status'.tr,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF64748B),
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // NÚT TRẠNG THÁI – CÓ THÔNG BÁO NGOÀI THIẾT BỊ KHI BẤM
                      Row(
                        children: [
                          Expanded(
                            child: _statusButton(
                              'arrived'.tr,
                              Icons.login_rounded,
                              const [Color(0xFFEA580C), Color(0xFFFB923C)],
                              updatedBooking.status == 'checked_in',
                              () => _updateStatus(context, updatedBooking.id ?? '', 'checked_in'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _statusButton(
                              'completed'.tr,
                              Icons.check_circle_rounded,
                              const [Color(0xFF059669), Color(0xFF10B981)],
                              updatedBooking.status == 'completed',
                              () => _updateStatus(context, updatedBooking.id ?? '', 'completed'),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Nút xóa
                      Center(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.red.shade50.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.red.shade200, width: 1.5),
                          ),
                          child: TextButton.icon(
                            onPressed: () => _showDeleteConfirm(context, updatedBooking.id ?? ''),
                            icon: const Icon(Icons.delete_forever_rounded, color: Color(0xFFDC2626)),
                            label: Text(
                              'delete_appointment'.tr,
                              style: TextStyle(
                                color: Color(0xFFDC2626),
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  // Helper: Info row
  Widget _buildInfoRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  color: Color(0xFF2D3748),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Status button với gradient
  Widget _statusButton(
    String label,
    IconData icon,
    List<Color> gradientColors,
    bool isActive,
    VoidCallback onTap,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: isActive ? LinearGradient(colors: gradientColors) : null,
        color: isActive ? null : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive ? gradientColors[0] : Colors.grey.shade300,
          width: isActive ? 2 : 1.5,
        ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: gradientColors[0].withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Column(
              children: [
                Icon(
                  icon,
                  color: isActive ? Colors.white : Colors.grey.shade600,
                  size: 24,
                ),
                const SizedBox(height: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: isActive ? Colors.white : Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ĐÃ SỬA: DÙNG BookingController → CÓ THÔNG BÁO NGOÀI MÀN HÌNH KHÓA
  void _updateStatus(BuildContext context, String id, String status) async {
    if (id.isEmpty) return;

    await Get.find<BookingController>().changeBookingStatus(id, status);

    BookingController.triggerRefresh.value++;
    Navigator.pop(context);
  }

  // Xóa lịch (giữ nguyên)
  void _showDeleteConfirm(BuildContext context, String id) {
    if (id.isEmpty) return;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('delete_booking_title'.tr, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
        content: Text('delete_booking_warning'.tr),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('cancel'.tr)),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await Get.find<CalendarController>().deleteBooking(id);
              BookingController.triggerRefresh.value++;
              Navigator.pop(context);
              Get.rawSnackbar(
                message: 'booking_deleted_msg'.tr,
                backgroundColor: Colors.red,
                snackPosition: SnackPosition.TOP,
                margin: const EdgeInsets.all(16),
                borderRadius: 12,
                duration: const Duration(seconds: 2),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('delete'.tr, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}