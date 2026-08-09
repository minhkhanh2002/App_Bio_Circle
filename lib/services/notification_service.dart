import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

import 'biorhythm_calculator.dart';
import 'notification_advice.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();
    // Mặc định tz.local là UTC nếu không set; phải gán đúng múi giờ thiết bị
    // thì giờ hẹn thông báo mới khớp với giờ người dùng chọn.
    try {
      final timezoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timezoneName));
    } catch (_) {
      // Không lấy được múi giờ thiết bị → giữ UTC, còn hơn là crash.
    }

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

  // ID gốc cho chuỗi thông báo chu kỳ sinh học; mỗi ngày trong "cửa sổ" dùng
  // id = _bioBaseId + số ngày offset để có thể lên lịch nhiều ngày riêng biệt
  // với nội dung khác nhau (thay vì 1 thông báo lặp lại nội dung tĩnh).
  static const int _bioBaseId = 100;
  static const int _maxWindowDays = 14;

  /// Lên lịch thông báo hằng ngày trong [days] ngày tới, mỗi ngày một nội
  /// dung riêng: lời chào + tóm tắt nhanh từ kho lời khuyên theo đúng chỉ số
  /// chu kỳ sinh học (thể chất/cảm xúc/trí tuệ) của ngày đó. Nên gọi lại hàm
  /// này mỗi khi app mở lên hoặc người dùng đổi cài đặt để "cửa sổ" lịch luôn
  /// được làm mới, tránh hết hạn nếu người dùng không mở app trong nhiều ngày.
  Future<void> scheduleDailyBiorhythmNotifications({
    required int hour,
    required int minute,
    required DateTime birthDate,
    required String locale,
    required String greetingTitle,
    int days = 7,
  }) async {
    await cancelDailyNotification();

    final now = tz.TZDateTime.now(tz.local);
    final today = DateTime.now();
    for (int i = 0; i < days; i++) {
      final date = DateTime(today.year, today.month, today.day).add(Duration(days: i));
      final scheduled =
          tz.TZDateTime(tz.local, date.year, date.month, date.day, hour, minute);
      if (scheduled.isBefore(now)) {
        continue; // giờ hẹn hôm nay đã qua thì bỏ qua, các ngày sau vẫn còn.
      }

      final metrics = BiorhythmCalculator.coreMetrics(birthDate, date);
      final seed = date
          .difference(DateTime(birthDate.year, birthDate.month, birthDate.day))
          .inDays;
      final body = NotificationAdvice.summarize(locale: locale, metrics: metrics, seed: seed);

      await _plugin.zonedSchedule(
        _bioBaseId + i,
        greetingTitle,
        body,
        scheduled,
        NotificationDetails(
          android: AndroidNotificationDetails(
            // ID channel đổi sang _v2 vì âm thanh gắn với channel: channel cũ đã
            // tạo không có âm tùy chỉnh nên phải tạo channel mới thì âm mới ăn.
            'daily_notification_channel_v2',
            'Daily reminder',
            channelDescription: 'Daily biorhythm reminder',
            importance: Importance.high,
            priority: Priority.high,
            styleInformation: BigTextStyleInformation(body),
            sound: const RawResourceAndroidNotificationSound('pio_chirp'),
          ),
          iOS: const DarwinNotificationDetails(
            sound: 'pio_chirp.caf',
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    }
  }

  /// Huỷ toàn bộ thông báo chu kỳ sinh học đã lên lịch (cả id tĩnh id=0 của
  /// phiên bản cũ, để dọn sạch khi người dùng nâng cấp app).
  Future<void> cancelDailyNotification() async {
    await _plugin.cancel(0);
    for (int i = 0; i < _maxWindowDays; i++) {
      await _plugin.cancel(_bioBaseId + i);
    }
  }
}
