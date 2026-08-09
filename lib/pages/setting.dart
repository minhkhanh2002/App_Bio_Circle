import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

import '../services/birthdate_provider.dart';
import '../services/app_settings_provider.dart';
import '../services/app_localizations.dart';
import '../services/notification_service.dart';
import '../widgets/widget_support.dart';
import '../widgets/info_sheet.dart';
import '../widgets/custom_snackbar.dart';
import '../widgets/achievement_dialog.dart';
import 'feedback_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController aiNoteController = TextEditingController();
  DateTime? birthDate;
  bool notificationsEnabled = false;
  int notifHour = 6;
  int notifMinute = 0;
  int _settingsTapCount = 0;

  static const List<String> _aiStyles = [
    'friendly',
    'concise',
    'humorous',
    'motivational',
    'professional',
    'poetic',
  ];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    nameController.dispose();
    aiNoteController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // watch (không phải read): BirthDateProvider tải dữ liệu bất đồng bộ từ
    // SharedPreferences lúc khởi động, nên lần didChangeDependencies đầu tiên
    // có thể chạy trước khi load xong. Phải watch để chạy lại khi provider
    // notifyListeners() sau khi tải xong, nếu không birthDate sẽ kẹt ở null.
    final provider = context.watch<BirthDateProvider>();
    if (provider.name != null && nameController.text.isEmpty) {
      nameController.text = provider.name!;
    }
    birthDate ??= provider.birthDate;
    if (aiNoteController.text.isEmpty) {
      aiNoteController.text = context.read<AppSettingsProvider>().aiStyleNote;
    }
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      notificationsEnabled = prefs.getBool('notificationsEnabled') ?? false;
      notifHour = prefs.getInt('notificationHour') ?? 6;
      notifMinute = prefs.getInt('notificationMinute') ?? 0;
    });
  }

  /// Hiển thị thông báo nhỏ xác nhận đã tự lưu.
  void _toastSaved() {
    final s = AppStrings.read(context);
    CustomSnackBar.show(context, s.t('settings.autoSaved'));
  }

  void _onNameChanged(String value) {
    context.read<BirthDateProvider>().setName(value);
  }

  Future<void> _persistAppPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notificationsEnabled', notificationsEnabled);
  }

  Future<void> _applyNotificationSchedule() async {
    if (kIsWeb) return;
    final s = AppStrings.read(context);
    final notif = NotificationService();
    await notif.cancelDailyNotification();
    if (notificationsEnabled && birthDate != null) {
      await notif.scheduleDailyBiorhythmNotifications(
        hour: notifHour,
        minute: notifMinute,
        birthDate: birthDate!,
        locale: s.code,
        greetingTitle: s.t('notif.title'),
      );
    }
  }

  void _pickNotificationTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: notifHour, minute: notifMinute),
      builder: (context, child) {
        final isDark = AppWidget.isDark;
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: (isDark ? const ColorScheme.dark() : const ColorScheme.light()).copyWith(
              primary: const Color(0xFFE100FF),
              onPrimary: Colors.white,
              surface: AppWidget.surface,
              onSurface: AppWidget.onSurface,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && (picked.hour != notifHour || picked.minute != notifMinute)) {
      setState(() {
        notifHour = picked.hour;
        notifMinute = picked.minute;
      });
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('notificationHour', notifHour);
      await prefs.setInt('notificationMinute', notifMinute);
      await _applyNotificationSchedule();
      _toastSaved();
    }
  }

  void _pickBirthDate(BuildContext context) async {
    final isDark = AppWidget.isDark;
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: birthDate ?? DateTime(2000, 1, 1),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: (isDark ? const ColorScheme.dark() : const ColorScheme.light()).copyWith(
              primary: const Color(0xFFE100FF),
              onPrimary: Colors.white,
              surface: AppWidget.surface,
              onSurface: AppWidget.onSurface,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != birthDate) {
      if (!mounted) return;
      setState(() => birthDate = picked);
      context.read<BirthDateProvider>().setBirthDate(picked);
      _toastSaved();
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final settings = context.watch<AppSettingsProvider>();

    return Scaffold(
      body: Container(
        decoration: AppWidget.cosmicBackground(),
        height: double.infinity,
        width: double.infinity,
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () {
                              _settingsTapCount++;
                              if (_settingsTapCount >= 5) {
                                _settingsTapCount = 0;
                                AchievementDialog.show(context);
                              }
                            },
                            child: Text(s.t('settings.title'),
                                style: AppWidget.HeadlineTextFeildStyle().copyWith(fontSize: 22)),
                          ),
                          Text(s.t('settings.subtitle'), style: AppWidget.LightTextFeildStyle()),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.info_outline_rounded, color: AppWidget.secondaryText),
                      tooltip: s.t('info.title'),
                      onPressed: () => showMetricsInfo(context, 'all'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 110),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ----- Hồ sơ cá nhân -----
                        Text(s.t('settings.profile'), style: AppWidget.semiBoldTextFeildStyle()),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: AppWidget.glassDecoration(),
                          child: Column(
                            children: [
                              TextField(
                                controller: nameController,
                                onChanged: _onNameChanged,
                                style: TextStyle(color: AppWidget.primaryText, fontFamily: 'BeVietnamPro'),
                                decoration: InputDecoration(
                                  labelText: s.t('settings.fullName'),
                                  labelStyle: TextStyle(color: AppWidget.mutedText),
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: AppWidget.cardBorderColor),
                                  ),
                                  focusedBorder: const UnderlineInputBorder(
                                    borderSide: BorderSide(color: Color(0xFFE100FF)),
                                  ),
                                  prefixIcon: Icon(Icons.person_outline_rounded, color: AppWidget.secondaryText),
                                ),
                              ),
                              const SizedBox(height: 16),
                              InkWell(
                                onTap: () => _pickBirthDate(context),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.cake_outlined, color: AppWidget.secondaryText),
                                          const SizedBox(width: 12),
                                          Text(
                                            birthDate == null
                                                ? s.t('settings.chooseBirthdate')
                                                : s.birthdateLabel(
                                                    '${birthDate!.day}/${birthDate!.month}/${birthDate!.year}'),
                                            style: TextStyle(
                                                color: AppWidget.primaryText,
                                                fontSize: 14.5,
                                                fontFamily: 'BeVietnamPro'),
                                          ),
                                        ],
                                      ),
                                      Icon(Icons.arrow_forward_ios_rounded,
                                          color: AppWidget.mutedText, size: 14),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // ----- Ứng dụng -----
                        Text(s.t('settings.app'), style: AppWidget.semiBoldTextFeildStyle()),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                          decoration: AppWidget.glassDecoration(),
                          child: Column(
                            children: [
                              // Chế độ tối
                              _settingRow(
                                icon: Icons.dark_mode_outlined,
                                label: s.t('settings.darkMode'),
                                trailing: Switch(
                                  value: settings.isDarkMode,
                                  activeColor: const Color(0xFFE100FF),
                                  onChanged: (v) => settings.setDarkMode(v),
                                ),
                              ),
                              Divider(color: AppWidget.cardBorderColor),
                              // Thông báo
                              _settingRow(
                                icon: Icons.notifications_none_rounded,
                                label: s.t('settings.dailyNotif'),
                                trailing: Switch(
                                  value: notificationsEnabled,
                                  activeColor: const Color(0xFFE100FF),
                                  onChanged: (v) async {
                                    // Bật: xin quyền trước (Android 13+/iOS); từ chối thì giữ tắt.
                                    if (v) {
                                      final granted =
                                          await NotificationService().requestPermission();
                                      if (!context.mounted) return;
                                      if (!granted) {
                                        CustomSnackBar.show(
                                          context,
                                          s.t('settings.notifDenied'),
                                          isError: true,
                                        );
                                        return;
                                      }
                                    }
                                    setState(() => notificationsEnabled = v);
                                    await _persistAppPrefs();
                                    await _applyNotificationSchedule();
                                  },
                                ),
                              ),
                              if (notificationsEnabled) ...[
                                Divider(color: AppWidget.cardBorderColor),
                                _settingRow(
                                  icon: Icons.access_time_rounded,
                                  label: s.t('settings.notifTime'),
                                  trailing: InkWell(
                                    onTap: () => _pickNotificationTime(context),
                                    borderRadius: BorderRadius.circular(8),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.05),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        "${notifHour.toString().padLeft(2, '0')}:${notifMinute.toString().padLeft(2, '0')}",
                                        style: TextStyle(
                                          color: AppWidget.primaryText,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'BeVietnamPro',
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                              Divider(color: AppWidget.cardBorderColor),
                              // Ngôn ngữ
                              _settingRow(
                                icon: Icons.language_rounded,
                                label: s.t('settings.language'),
                                trailing: DropdownButton<String>(
                                  value: settings.locale.languageCode,
                                  dropdownColor: AppWidget.surface,
                                  underline: const SizedBox(),
                                  icon: Icon(Icons.keyboard_arrow_down_rounded, color: AppWidget.secondaryText),
                                  style: TextStyle(color: AppWidget.primaryText, fontFamily: 'BeVietnamPro', fontSize: 14),
                                  items: const [
                                    DropdownMenuItem(value: 'vi', child: Text('Tiếng Việt')),
                                    DropdownMenuItem(value: 'en', child: Text('English')),
                                  ],
                                  onChanged: (code) {
                                    if (code != null) {
                                      settings.setLanguage(code);
                                    }
                                  },
                                ),
                              ),
                              Divider(color: AppWidget.cardBorderColor),
                              // Phong cách lời khuyên AI
                              _settingRow(
                                icon: Icons.auto_awesome_outlined,
                                label: s.t('settings.aiStyle'),
                                trailing: DropdownButton<String>(
                                  value: settings.aiStyle,
                                  dropdownColor: AppWidget.surface,
                                  underline: const SizedBox(),
                                  icon: Icon(Icons.keyboard_arrow_down_rounded, color: AppWidget.secondaryText),
                                  style: TextStyle(color: AppWidget.primaryText, fontFamily: 'BeVietnamPro', fontSize: 14),
                                  items: _aiStyles
                                      .map((st) => DropdownMenuItem(value: st, child: Text(s.t('style.$st'))))
                                      .toList(),
                                  onChanged: (st) {
                                    if (st != null) settings.setAiStyle(st);
                                  },
                                ),
                              ),
                              const SizedBox(height: 4),
                              TextField(
                                controller: aiNoteController,
                                onChanged: settings.setAiStyleNote,
                                maxLength: 120,
                                style: TextStyle(color: AppWidget.primaryText, fontSize: 13.5, fontFamily: 'BeVietnamPro'),
                                decoration: InputDecoration(
                                  isDense: true,
                                  labelText: s.t('settings.aiStyleNote'),
                                  labelStyle: TextStyle(color: AppWidget.mutedText, fontSize: 13),
                                  hintText: s.t('settings.aiStyleNoteHint'),
                                  hintStyle: TextStyle(color: AppWidget.mutedText, fontSize: 12),
                                  counterStyle: TextStyle(color: AppWidget.mutedText),
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: AppWidget.cardBorderColor),
                                  ),
                                  focusedBorder: const UnderlineInputBorder(
                                    borderSide: BorderSide(color: Color(0xFFE100FF)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // ----- Thành tựu ẩn (chỉ hiện sau khi mở khóa) -----
                        if (settings.exploitBadgeUnlocked) ...[
                          Text(s.t('badge.section'),
                              style: AppWidget.semiBoldTextFeildStyle()),
                          const SizedBox(height: 8),
                          _exploitBadge(s),
                          const SizedBox(height: 24),
                        ],

                        // ----- Phản hồi -----
                        Text(s.t('settings.feedback'), style: AppWidget.semiBoldTextFeildStyle()),
                        const SizedBox(height: 8),
                        InkWell(
                          borderRadius: BorderRadius.circular(24),
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const FeedbackPage()),
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: AppWidget.glassDecoration(),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFF7F00FF), Color(0xFFE100FF)],
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.chat_bubble_outline_rounded,
                                      color: Colors.white, size: 20),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(s.t('settings.feedbackOpen'),
                                          style: TextStyle(
                                              color: AppWidget.primaryText,
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                              fontFamily: 'BeVietnamPro')),
                                      const SizedBox(height: 2),
                                      Text(s.t('settings.feedbackOpenSub'),
                                          style: TextStyle(color: AppWidget.mutedText, fontSize: 12)),
                                    ],
                                  ),
                                ),
                                Icon(Icons.arrow_forward_ios_rounded,
                                    color: AppWidget.mutedText, size: 14),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Huy hiệu ẩn "Bóc lột người nghèo" — phần thưởng cho người tò mò bấm AI
  /// nhiều lần dù đã hết lượt. Thiết kế emblem gradient vàng-cam như một danh hiệu.
  Widget _exploitBadge(AppStrings s) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppWidget.glassDecoration(),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFFFFD200),
                width: 2.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF8008).withValues(alpha: 0.45),
                  blurRadius: 12,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: ClipOval(
              child: Image.asset(
                'images/pio_poor.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        s.t('badge.exploitTitle'),
                        style: TextStyle(
                            color: AppWidget.primaryText,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'BeVietnamPro'),
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text('🏆', style: TextStyle(fontSize: 14)),
                  ],
                ),
                const SizedBox(height: 3),
                Text(s.t('badge.exploitDesc'),
                    style: TextStyle(color: AppWidget.mutedText, fontSize: 12, height: 1.35)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _settingRow({required IconData icon, required String label, required Widget trailing}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: AppWidget.secondaryText),
              const SizedBox(width: 12),
              Text(label,
                  style: TextStyle(color: AppWidget.primaryText, fontSize: 14.5, fontFamily: 'BeVietnamPro')),
            ],
          ),
          trailing,
        ],
      ),
    );
  }
}
