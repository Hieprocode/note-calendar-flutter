import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // 1. Khởi tạo Timezone (để hẹn giờ chính xác)
    tz.initializeTimeZones();

    // 2. Cấu hình Android
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher'); // Đảm bảo icon này có trong android/app/src/main/res/drawable

    // 3. Cấu hình iOS (Xin quyền luôn)
    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
    
    // 4. Xin quyền Android 13+
    final androidImpl = flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidImpl != null) {
      await androidImpl.requestNotificationsPermission();
    }
  }

  // --- HÀM HẸN GIỜ NHẮC NHỞ (QUAN TRỌNG) ---
  Future<void> scheduleBookingReminder({
    required int id, // ID phải là số nguyên (ta sẽ dùng hashcode của bookingID)
    required String customerName,
    required DateTime bookingTime,
  }) async {
    // Tính thời điểm nhắc: Trước 15 phút
    final scheduledDate = bookingTime.subtract(const Duration(minutes: 15));

    // Nếu thời điểm nhắc đã qua rồi thì thôi không nhắc nữa
    if (scheduledDate.isBefore(DateTime.now())) return;

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      'Sắp có khách: $customerName',
      'Lịch hẹn bắt đầu lúc ${bookingTime.hour}:${bookingTime.minute.toString().padLeft(2, '0')}',
      tz.TZDateTime.from(scheduledDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'booking_channel', // Id kênh
          'Lịch hẹn', // Tên kênh
          channelDescription: 'Thông báo nhắc nhở lịch hẹn',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
    
    print("--> Đã hẹn giờ nhắc nhở lúc: $scheduledDate");
  }

  // Hủy nhắc nhở (Dùng khi Hủy đơn)
  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }
}