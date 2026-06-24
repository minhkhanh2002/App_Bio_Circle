import 'package:app_bio/pages/bottomnav.dart';
import 'package:app_bio/pages/welcome.dart';
import 'package:app_bio/pages/Screen.dart';
import 'package:app_bio/pages/language_select.dart';
import 'package:app_bio/services/birthdate_provider.dart';
import 'package:app_bio/services/app_settings_provider.dart';
import 'package:app_bio/services/feedback_service.dart';
import 'package:app_bio/services/notification_service.dart';
import 'package:app_bio/services/app_localizations.dart';
import 'package:app_bio/services/app_icon_service.dart';
import 'package:app_bio/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:app_bio/widgets/widget_support.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting();

  // Khởi tạo Firebase (dùng cho ghi góp ý). Có guard để app vẫn chạy nếu
  // dự án Firebase chưa được cấu hình (ví dụ khi test trên web chưa setup).
  try {
    // Timeout để KHÔNG bao giờ kẹt ở màn splash nếu mạng kém/không có (hoặc
    // thiết bị thiếu Google Play Services). App vẫn chạy, chỉ là tính năng cần
    // mạng sẽ tạm không dùng được.
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ).timeout(const Duration(seconds: 6));

    // App Check: chỉ app thật (đã được chứng thực) mới gọi được Cloud Functions
    // có enforceAppCheck. Debug build dùng debug provider; release dùng
    // Play Integrity (Android) / App Attest (iOS). Lỗi/timeout không chặn app —
    // chỉ khiến tính năng cần App Check tạm không dùng được.
    try {
      await FirebaseAppCheck.instance
          .activate(
            providerAndroid: kDebugMode
                ? AndroidDebugProvider()
                : AndroidPlayIntegrityProvider(),
            providerApple:
                kDebugMode ? AppleDebugProvider() : AppleAppAttestProvider(),
          )
          .timeout(const Duration(seconds: 6));
    } catch (_) {
      // Bỏ qua: thiếu Play Services / mạng kém → AI tạm không gọi được.
    }

    FeedbackService.ready = true;
    // Gửi lại các góp ý còn tồn trong hàng đợi offline (không chặn khởi động).
    FeedbackService().flushQueue();
  } catch (_) {
    FeedbackService.ready = false;
  }

  final prefs = await SharedPreferences.getInstance();
  final birthDateString = prefs.getString('birthDate');
  final seenOnboarding = prefs.getBool('seenOnboarding') ?? false;
  final notificationsEnabled = prefs.getBool('notificationsEnabled') ?? false;
  final isDarkMode = prefs.getBool('isDarkMode') ?? true;
  final languageCode = prefs.getString('languageCode') ?? 'vi';
  final languageChosen = prefs.getBool('languageChosen') ?? false;

  if (!kIsWeb) {
    try {
      final notifService = NotificationService();
      await notifService.init().timeout(const Duration(seconds: 6));
      if (notificationsEnabled) {
        final notifHour = prefs.getInt('notificationHour') ?? 6;
        final notifMinute = prefs.getInt('notificationMinute') ?? 0;
        final s = AppStrings(languageCode);
        await notifService.scheduleDailyNotification(
          notifHour,
          notifMinute,
          title: s.t('notif.title'),
          body: s.t('notif.body'),
        );
      }
    } catch (_) {
      // Khởi tạo thông báo lỗi/timeout → bỏ qua, không chặn khởi động app.
    }
  }

  runApp(MyApp(
    hasUserData: birthDateString != null,
    seenOnboarding: seenOnboarding,
    isDarkMode: isDarkMode,
    languageCode: languageCode,
    languageChosen: languageChosen,
  ));
}

class MyApp extends StatefulWidget {
  final bool hasUserData;
  final bool seenOnboarding;
  final bool isDarkMode;
  final String languageCode;
  final bool languageChosen;

  const MyApp({
    super.key,
    required this.hasUserData,
    required this.seenOnboarding,
    required this.isDarkMode,
    required this.languageCode,
    required this.languageChosen,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Tính năng ẩn: đổi icon theo giờ (chỉ chạy sau khi cài >1 ngày).
    AppIconService().applyTimeBasedIcon();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      AppIconService().applyTimeBasedIcon();
    }
  }

  /// Màn hình khởi đầu sau khi đã chọn ngôn ngữ.
  Widget startAfterLanguage() {
    if (widget.hasUserData) return const BottomNav();
    if (!widget.seenOnboarding) return const OnboardingScreen();
    return WelcomeScreen();
  }

  Widget get _initialScreen {
    // Lần đầu sử dụng: hỏi ngôn ngữ trước tiên.
    if (!widget.languageChosen) return const LanguageSelectScreen();
    return startAfterLanguage();
  }

  ThemeData _theme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: 'Poppins',
      scaffoldBackgroundColor:
          isDark ? AppWidget.darkBgStart : AppWidget.lightBgStart,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF2575FC),
        brightness: brightness,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BirthDateProvider()),
        ChangeNotifierProvider(
          create: (_) => AppSettingsProvider.seed(
            isDarkMode: widget.isDarkMode,
            languageCode: widget.languageCode,
            languageChosen: widget.languageChosen,
          ),
        ),
      ],
      child: Consumer<AppSettingsProvider>(
        builder: (context, settings, _) {
          // Đồng bộ bảng màu + locale mặc định cho intl (định dạng ngày/thứ).
          AppWidget.isDark = settings.isDarkMode;
          Intl.defaultLocale = settings.locale.languageCode;
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            themeMode: settings.themeMode,
            theme: _theme(Brightness.light),
            darkTheme: _theme(Brightness.dark),
            locale: settings.locale,
            supportedLocales: const [Locale('vi'), Locale('en')],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            // Tự co giãn giao diện cho màn hình lớn (tablet/desktop):
            // layout 450px được phóng to & canh giữa, giữ bố cục như điện thoại.
            builder: (context, child) => ResponsiveBreakpoints.builder(
              breakpoints: const [
                Breakpoint(start: 0, end: 450, name: MOBILE),
                Breakpoint(start: 451, end: 800, name: TABLET),
                Breakpoint(start: 801, end: 1920, name: DESKTOP),
                Breakpoint(start: 1921, end: double.infinity, name: '4K'),
              ],
              child: Builder(
                builder: (context) {
                  final bp = ResponsiveBreakpoints.of(context);
                  if (bp.largerThan(MOBILE)) {
                    return MaxWidthBox(
                      maxWidth: 600,
                      backgroundColor:
                          AppWidget.isDark ? AppWidget.darkBgStart : AppWidget.lightBgStart,
                      child: ResponsiveScaledBox(
                        width: 450,
                        child: child!,
                      ),
                    );
                  }
                  return child!;
                },
              ),
            ),
            home: _initialScreen,
          );
        },
      ),
    );
  }
}
