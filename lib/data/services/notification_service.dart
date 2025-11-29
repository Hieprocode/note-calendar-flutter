// lib/data/services/notification_service.dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  // Singleton – chỉ khởi tạo 1 lần
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const String _channelId = "booking_channel";
  static const String _channelName = "Lịch hẹn";
  static const String _channelDescription = "Thông báo lịch hẹn salon";

  // KHỞI TẠO – DÙNG ĐƯỢC CẢ KHI APP TẮT
  Future<void> init() async {
    // Khởi tạo timezone (bắt buộc cho zonedSchedule)
    tz_data.initializeTimeZones();
    final vietnam = tz.getLocation('Asia/Ho_Chi_Minh');
    tz.setLocalLocation(vietnam);

    // Cấu hình khởi tạo
    const AndroidInitializationSettings androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings =
        InitializationSettings(android: androidInit, iOS: iosInit);

    await flutterLocalNotificationsPlugin.initialize(initSettings);

    // Tạo channel cho Android 8.0+
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDescription,
      importance: Importance.max,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('notification'), // không .mp3
    );

    final androidPlugin = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(channel);

    // Xin quyền Android 13+
    await androidPlugin?.requestNotificationsPermission();
  }

  // HIỂN THỊ THÔNG BÁO NGAY LẬP TỨC (khi tạo lịch mới)
  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('notification'),
      enableVibration: true,
      icon: '@mipmap/ic_launcher',
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(
        sound: 'notification.mp3',
        presentAlert: true,
        presentSound: true,
        presentBadge: true,
      ),
    );

    await flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      platformDetails,
      payload: payload,
    );
  }

  // HẸN GIỜ NHẮC TRƯỚC 15 PHÚT (dự phòng – nhưng giờ ta dùng Cloud Function rồi)
  Future<void> scheduleBookingReminder({
    required int id,
    required String customerName,
    required DateTime bookingTime,
  }) async {
    final scheduledDate = bookingTime.subtract(const Duration(minutes: 15));
    if (scheduledDate.isBefore(DateTime.now())) return;

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      'Sắp có khách: $customerName',
      'Lịch hẹn lúc ${bookingTime.hour.toString().padLeft(2, '0')}:${bookingTime.minute.toString().padLeft(2, '0')}',
      tz.TZDateTime.from(scheduledDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          sound: RawResourceAndroidNotificationSound('notification'),
        ),
        iOS: DarwinNotificationDetails(sound: 'notification.mp3'),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }
}