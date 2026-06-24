import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    // iOS: không xin quyền ngay lúc init; sẽ xin khi người dùng bật thông báo.
    const DarwinInitializationSettings darwinInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const InitializationSettings initSettings =
        InitializationSettings(android: androidInit, iOS: darwinInit);

    await _plugin.initialize(initSettings);
  }

  /// Xin quyền hiển thị thông báo (Android 13+ và iOS). Trả về true nếu được cấp.
  Future<bool> requestPermission() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      final granted = await android.requestNotificationsPermission();
      return granted ?? false;
    }
    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    if (ios != null) {
      final granted = await ios.requestPermissions(
          alert: true, badge: true, sound: true);
      return granted ?? false;
    }
    return true;
  }

  /// Lên lịch thông báo nhắc nhở hằng ngày. Tiêu đề/nội dung truyền theo ngôn
  /// ngữ hiện tại của người dùng. Dùng inexact alarm (không cần quyền đặc biệt).
  Future<void> scheduleDailyNotification(
    int hour,
    int minute, {
    required String title,
    required String body,
  }) async {
    await _plugin.zonedSchedule(
      0,
      title,
      body,
      _nextInstanceOfReminderTime(hour, minute),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          // ID channel đổi sang _v2 vì âm thanh gắn với channel: channel cũ đã
          // tạo không có âm tùy chỉnh nên phải tạo channel mới thì âm mới ăn.
          'daily_notification_channel_v2',
          'Daily reminder',
          channelDescription: 'Daily biorhythm reminder',
          importance: Importance.high,
          priority: Priority.high,
          sound: RawResourceAndroidNotificationSound('pio_chirp'),
        ),
        iOS: DarwinNotificationDetails(
          sound: 'pio_chirp.caf',
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancelDailyNotification() async {
    await _plugin.cancel(0);
  }

  tz.TZDateTime _nextInstanceOfReminderTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }
}
