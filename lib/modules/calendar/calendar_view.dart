// lib/modules/calendar/calendar_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:note_calendar/modules/booking/booking_controller.dart';
import 'package:note_calendar/modules/booking/view/add_booking_view.dart';
import 'package:table_calendar/table_calendar.dart';
import 'calendar_controller.dart';
import '../../data/models/booking_model.dart';
import '../../core/widgets/app_slidable.dart';
import '../../core/config/app_colors.dart';
import '../booking/view/booking_detail_view.dart';

class CalendarView extends GetView<CalendarController> {
  CalendarView({super.key});

  // Reactive calendar format
  final Rx<CalendarFormat> _calendarFormat = CalendarFormat.week.obs;

  // Cached formatters for performance
  static final _timeFormat = DateFormat('HH:mm');
  static final _dateFormat = DateFormat('dd/MM/yyyy');
  static final _fullDateFormat = DateFormat('EEEE, dd/MM/yyyy', 'vi');
  static final _currencyFormat = NumberFormat.currency(locale: 'vi', symbol: 'đ');

  // Static status data - no need to recreate on every call
  static const _statusDataMap = {
    'confirmed': {
      'color': AppColors.redConfirmed,
      'icon': Icons.schedule_rounded,
      'textKey': 'confirmed',
      'shortTextKey': 'confirmed_short',
    },
    'completed': {
      'color': AppColors.green,
      'icon': Icons.check_circle_rounded,
      'textKey': 'completed',
      'shortTextKey': 'completed_short',
    },
    'checked_in': {
      'color': AppColors.purpleCheckIn,
      'icon': Icons.login_rounded,
      'textKey': 'checked_in',
      'shortTextKey': 'checked_in_short',
    },
  };

  static final _defaultStatusData = {
    'color': AppColors.textSecondary,
    'icon': Icons.help_outline_rounded,
    'textKey': 'status',
    'shortTextKey': 'status',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ANIMATED BACKGROUND
          Positioned.fill(
            child: RepaintBoundary(
              child: _buildAnimatedBackground(),
            ),
          ),
          
          // MAIN CONTENT
          SafeArea(
            child: Column(
              children: [
                // GLASSMORPHISM HEADER
                _buildGlassHeader(),
                
                const SizedBox(height: 16),
                
                // GLASS CALENDAR - AUTO HEIGHT
                _buildGlassCalendar(),
                
                const SizedBox(height: 12),
                
                // BOOKING LIST - FLEXIBLE
                Expanded(
                  child: _buildBookingList(),
                ),
              ],
            ),
          ),
        ],
      ),
      
      // GLASSMORPHISM FAB
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          heroTag: "btn_add_booking",
          onPressed: () {
            Get.find<BookingController>().resetFormForAdd();
            Get.bottomSheet(
              const AddBookingView(),
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
            );
          },
          backgroundColor: AppColors.primaryLightest,
          elevation: 0,
          icon: const Icon(Icons.add_rounded, size: 26),
          label: Text(
            'create_new'.tr,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          ),
        ),
      ),
    );
  }

  // ANIMATED BACKGROUND WITH PATTERN
  Widget _buildAnimatedBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryLightest,
            AppColors.primaryLighter,
            AppColors.primaryLight,
          ],
        ),
      ),
      child: Image.asset(
        'assets/polygon-scatter-haikei (1).png',
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        opacity: const AlwaysStoppedAnimation(0.6),
      ),
    );
  }

  // GLASSMORPHISM HEADER
  Widget _buildGlassHeader() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      decoration: BoxDecoration(
        color: AppColors.glassBackgroundConst,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.glassBorderConst, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(-5, -5),
          ),
          BoxShadow(
            color: AppColors.primary.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(5, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.calendar_month_rounded, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 14),
            Text(
              'calendar'.tr,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: AppColors.primary,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // GLASSMORPHISM CALENDAR
  Widget _buildGlassCalendar() {
    return Obx(() => AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.glassBackgroundConst,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.glassBorderConst, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(-5, -5),
          ),
          BoxShadow(
            color: AppColors.primaryLightest.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(5, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: TableCalendar<BookingModel>(
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: controller.focusedDay.value,
          selectedDayPredicate: (day) => controller.isSameDay(controller.selectedDay.value, day),
          onDaySelected: controller.onDaySelected,
          calendarFormat: _calendarFormat.value,
          onFormatChanged: (format) {
            _calendarFormat.value = format;
          },
          startingDayOfWeek: StartingDayOfWeek.monday,
          availableCalendarFormats: {
            CalendarFormat.month: 'month'.tr,
            CalendarFormat.week: 'week'.tr,
          },
          headerStyle: HeaderStyle(
            formatButtonVisible: true,
            titleCentered: true,
            formatButtonShowsNext: false,
            titleTextStyle: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
            formatButtonDecoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.primary.withOpacity(0.3)),
            ),
            formatButtonTextStyle: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
            leftChevronIcon: const Icon(Icons.chevron_left_rounded, color: AppColors.primary, size: 26),
            rightChevronIcon: const Icon(Icons.chevron_right_rounded, color: AppColors.primary, size: 26),
            headerPadding: const EdgeInsets.symmetric(vertical: 10),
          ),
          daysOfWeekStyle: DaysOfWeekStyle(
            weekdayStyle: TextStyle(
              color: AppColors.primary.withOpacity(0.8),
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
            weekendStyle: const TextStyle(
              color: AppColors.redConfirmed,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
          calendarStyle: CalendarStyle(
            cellMargin: const EdgeInsets.all(4),
            todayDecoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.orangeLight, AppColors.orange],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.orange.withOpacity(0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            todayTextStyle: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
            selectedDecoration: BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryLightest.withOpacity(0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            selectedTextStyle: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
            weekendTextStyle: const TextStyle(color: AppColors.redConfirmed),
            outsideTextStyle: TextStyle(color: AppColors.textHint),
            markerDecoration: BoxDecoration(
              color: AppColors.green,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.green.withOpacity(0.4),
                  blurRadius: 4,
                ),
              ],
            ),
            markerSize: 6,
            markersMaxCount: 3,
            defaultTextStyle: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
              color: AppColors.textPrimaryConst,
            ),
          ),
          eventLoader: controller.getBookingsForDay,
        ),
      ),
    ));
  }

  // BOOKING LIST WITH HEADER
  Widget _buildBookingList() {
    return Column(
      children: [
        // GLASS HEADER
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.glassBackgroundConst,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.glassBorderConst, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.white.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(-3, -3),
              ),
              BoxShadow(
                color: AppColors.primary.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(3, 3),
              ),
            ],
          ),
          child: Obx(() {
            final date = controller.selectedDay.value;
            final bookingCount = controller.getBookingsForDay(date).length;
            return Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradientLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.event_note_rounded, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _fullDateFormat.format(date),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "$bookingCount",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            );
          }),
        ),
        
        // BOOKING LIST
        Expanded(
          child: Obx(() {
            final dailyBookings = controller.getBookingsForDay(controller.selectedDay.value);

            if (dailyBookings.isEmpty) {
              return Center(
                child: Container(
                  margin: const EdgeInsets.all(24),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.glassBackgroundConst,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.glassBorderConst, width: 1.5),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          
                          color: AppColors.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.event_busy_rounded,
                          size: 48,
                          color: AppColors.primary.withOpacity(0.5),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'no_bookings'.tr,
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _dateFormat.format(controller.selectedDay.value),
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return ListView.separated(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: dailyBookings.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final booking = dailyBookings[index];
                return RepaintBoundary(
                  child: _buildGlassBookingCard(booking),
                );
              },
            );
          }),
        ),
      ],
    );
  }

  // GLASSMORPHISM BOOKING CARD
  Widget _buildGlassBookingCard(BookingModel b) {
    final statusData = _getStatusData(b.status);

    return AppSlidable(
      itemId: b.id!,
      onDelete: (id) async {
        await controller.deleteBooking(id);
        BookingController.triggerRefresh.value++;
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.glassBackgroundConst,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.glassBorderConst, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.white.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(-5, -5),
            ),
            BoxShadow(
              color: AppColors.primary.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(5, 5),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => showBookingDetail(b),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 100,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLightest.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 1.5),
                    ),
                    child: Column(
                      children: [
                        Image.asset(
                          'assets/clock.png',
                          width: 15,
                          height: 15,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _timeFormat.format(b.startTime),
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            color: AppColors.primary,
                            fontSize: 16,
                          ),
                        ),
                        Container(
                          height: 1.5,
                          width: 20,
                          color: AppColors.primary,
                          margin: const EdgeInsets.symmetric(vertical: 4),
                        ),
                        Text(
                          _timeFormat.format(b.endTime),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryLight,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 12),

                  // INFO
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Image.asset(
                              'assets/user.png',
                              width: 10,
                              height: 10,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                b.customerName,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: AppColors.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(Icons.spa_rounded, size: 13, color: AppColors.textSecondary),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                b.serviceName,
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 14,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [AppColors.green.withOpacity(0.8), AppColors.green],
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.payments_rounded, color: Colors.white, size: 12),
                              const SizedBox(width: 4),
                              Text(
                                _currencyFormat.format(b.servicePrice),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

                  // STATUS BADGE - COMPACT
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: (statusData['color'] as Color).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: statusData['color'] as Color, width: 1.5),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          statusData['icon'] as IconData,
                          color: statusData['color'] as Color,
                          size: 18,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          (statusData['shortTextKey'] as String).tr,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: statusData['color'] as Color,
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
    );
  }

  Map<String, dynamic> _getStatusData(String status) {
    return _statusDataMap[status] ?? _defaultStatusData;
  }
}
