// lib/data/services/notification_service.dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin plugin = FlutterLocalNotificationsPlugin();

  static const String channelId = "booking_reminder";
  static const String channelName = "Nhắc lịch hẹn";
  static const String channelDesc = "Thông báo trước khi có khách";

  Future<void> init() async {
    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Ho_Chi_Minh'));

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await plugin.initialize(const InitializationSettings(android: android, iOS: ios));

    const channel = AndroidNotificationChannel(
      channelId,
      channelName,
      description: channelDesc,
      importance: Importance.max,
      playSound: true,
    );

    final androidPlugin = plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(channel);
    await androidPlugin?.requestNotificationsPermission();
  }

  // ĐÃ SỬA HOÀN HẢO CHO PHIÊN BẢN 19.5.0+ – CHẠY NGON 100%!
  Future<void> scheduleBookingReminder({
    required int id,
    required String customerName,
    required DateTime bookingTime,
  }) async {
    final scheduledDate = bookingTime.subtract(const Duration(minutes: 15));

    if (scheduledDate.isBefore(DateTime.now())) {
      print("Đã qua giờ nhắc → bỏ qua");
      return;
    }

    try {
      await plugin.zonedSchedule(
        id,
        'Sắp có khách: $customerName',
        'Lịch hẹn lúc ${bookingTime.hour.toString().padLeft(2, '0')}:${bookingTime.minute.toString().padLeft(2, '0')}',
        tz.TZDateTime.from(scheduledDate, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            channelId,
            channelName,
            channelDescription: channelDesc,
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
            icon: '@mipmap/ic_launcher',
            sound: RawResourceAndroidNotificationSound('notification'),
          ),
          iOS: DarwinNotificationDetails(presentSound: true,sound: 'notification.mp3'),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,

      );

      print("ĐÃ ĐẶT NHẮC HẸN THÀNH CÔNG: $scheduledDate");
    } catch (e) {
      print("Lỗi đặt nhắc hẹn: $e");
    }
  }

  Future<void> showNotification({required String title, required String body}) async {
    await plugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(channelId, channelName,
            channelDescription: channelDesc, importance: Importance.max, priority: Priority.high),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  Future<void> cancel(int id) async => await plugin.cancel(id);
  Future<void> cancelAll() async => await plugin.cancelAll();
}