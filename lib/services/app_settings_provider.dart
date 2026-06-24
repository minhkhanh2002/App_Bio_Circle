import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/widget_support.dart';

/// Quản lý cấu hình toàn cục: chế độ sáng/tối và ngôn ngữ (vi/en).
/// Lưu vào SharedPreferences để giữ lại giữa các phiên.
class AppSettingsProvider extends ChangeNotifier {
  static const _kDarkMode = 'isDarkMode';
  static const _kLanguageCode = 'languageCode';
  static const _kLanguageChosen = 'languageChosen';
  static const _kAiStyle = 'aiStyle';
  static const _kAiStyleNote = 'aiStyleNote';
  static const _kAiNagTaps = 'aiNagTaps';
  static const _kExploitBadge = 'exploitBadgeUnlocked';

  /// Số lần "nài nỉ" tích lũy cần để mở khóa huy hiệu ẩn.
  static const int exploitBadgeThreshold = 5;

  bool _isDarkMode = true; // Mặc định theo thiết kế "cosmic" tối.
  Locale _locale = const Locale('vi');
  bool _languageChosen = false;
  String _aiStyle = 'friendly';
  String _aiStyleNote = '';
  int _aiNagTaps = 0; // số lần cố bấm AI sau khi đã hết lượt (tích lũy)
  bool _exploitBadgeUnlocked = false;

  bool get isDarkMode => _isDarkMode;
  Locale get locale => _locale;
  bool get languageChosen => _languageChosen;
  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;
  String get aiStyle => _aiStyle;
  String get aiStyleNote => _aiStyleNote;
  int get aiNagTaps => _aiNagTaps;
  bool get exploitBadgeUnlocked => _exploitBadgeUnlocked;

  AppSettingsProvider() {
    _load();
  }

  /// Khởi tạo từ giá trị đã đọc sẵn ở main() để tránh nhấp nháy theme.
  AppSettingsProvider.seed({
    required bool isDarkMode,
    required String languageCode,
    required bool languageChosen,
  })  : _isDarkMode = isDarkMode,
        _locale = Locale(languageCode),
        _languageChosen = languageChosen {
    AppWidget.isDark = _isDarkMode;
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool(_kDarkMode) ?? true;
    _locale = Locale(prefs.getString(_kLanguageCode) ?? 'vi');
    _languageChosen = prefs.getBool(_kLanguageChosen) ?? false;
    _aiStyle = prefs.getString(_kAiStyle) ?? 'friendly';
    _aiStyleNote = prefs.getString(_kAiStyleNote) ?? '';
    _aiNagTaps = prefs.getInt(_kAiNagTaps) ?? 0;
    _exploitBadgeUnlocked = prefs.getBool(_kExploitBadge) ?? false;
    AppWidget.isDark = _isDarkMode;
    notifyListeners();
  }

  /// Ghi nhận một lần người dùng cố bấm AI khi đã hết lượt.
  /// Trả về `true` nếu lần này vừa MỞ KHÓA huy hiệu ẩn (để UI ăn mừng 1 lần).
  Future<bool> recordAiNagTap() async {
    _aiNagTaps++;
    final justUnlocked =
        !_exploitBadgeUnlocked && _aiNagTaps >= exploitBadgeThreshold;
    if (justUnlocked) _exploitBadgeUnlocked = true;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kAiNagTaps, _aiNagTaps);
    if (justUnlocked) await prefs.setBool(_kExploitBadge, true);
    return justUnlocked;
  }

  Future<void> setAiStyle(String style) async {
    _aiStyle = style;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kAiStyle, style);
  }

  Future<void> setAiStyleNote(String note) async {
    _aiStyleNote = note;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kAiStyleNote, note);
  }

  Future<void> setDarkMode(bool value) async {
    if (_isDarkMode == value) return;
    _isDarkMode = value;
    AppWidget.isDark = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kDarkMode, value);
  }

  Future<void> toggleTheme() => setDarkMode(!_isDarkMode);

  Future<void> setLanguage(String code) async {
    _locale = Locale(code);
    _languageChosen = true;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLanguageCode, code);
    await prefs.setBool(_kLanguageChosen, true);
  }

  bool get isVietnamese => _locale.languageCode == 'vi';
}