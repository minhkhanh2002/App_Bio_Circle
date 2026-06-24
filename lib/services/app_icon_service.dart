import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_dynamic_icon_plus/flutter_dynamic_icon_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Tính năng ẩn: tự đổi icon app theo giờ trong ngày, MỖI KHI mở/quay lại app.
/// - Chỉ bật sau khi cài app hơn 1 ngày.
/// - 21h → 6h sáng hôm sau: icon "calm".
/// - 6h → 21h: ngẫu nhiên emotional/intellectual/physical (giữ cố định trong ngày).
///
/// Lưu ý nền tảng: iOS đổi ngay (đã tắt hộp thoại nhờ isSilent); Android đổi êm
/// khi người dùng rời app (qua FlutterDynamicIconPlusService).
class AppIconService {
  static final AppIconService _instance = AppIconService._internal();
  factory AppIconService() => _instance;
  AppIconService._internal();

  static const String _androidPackage = 'com.kanen.biocircle';
  static const String _kFirstInstall = 'firstInstallEpochMs';
  static const String _kMorningDate = 'iconMorningDate';
  static const String _kMorningChoice = 'iconMorningChoice';

  // logical -> hậu tố tên (khớp activity-alias Android & key CFBundleAlternateIcons iOS)
  static const Map<String, String> _suffix = {
    'calm': 'PioCalm',
    'emotional': 'PioEmotional',
    'intellectual': 'PioIntellectual',
    'physical': 'PioPhysical',
  };

  /// Gọi khi app khởi động và mỗi lần quay lại foreground.
  Future<void> applyTimeBasedIcon() async {
    if (kIsWeb) return;
    if (defaultTargetPlatform != TargetPlatform.android &&
        defaultTargetPlatform != TargetPlatform.iOS) {
      return;
    }
    try {
      if (!await _isUnlocked()) return;
      final supported = await FlutterDynamicIconPlus.supportsAlternateIcons;
      if (!supported) return;

      final target = _platformIconName(await _targetLogicalIcon());
      final current = await FlutterDynamicIconPlus.alternateIconName;
      if (current == target) return;

      await FlutterDynamicIconPlus.setAlternateIconName(
        iconName: target,
        isSilent: true, // iOS: không hiện hộp thoại "Đã đổi icon"
      );
    } catch (_) {
      // Thiết bị không hỗ trợ / lỗi nền tảng → bỏ qua, giữ icon hiện tại.
    }
  }

  String _platformIconName(String logical) {
    final suffix = _suffix[logical]!;
    if (defaultTargetPlatform == TargetPlatform.android) {
      return '$_androidPackage.$suffix';
    }
    return suffix; // iOS dùng key trong CFBundleAlternateIcons
  }

  /// Đã cài hơn 1 ngày chưa? Lần chạy đầu tiên sẽ ghi mốc cài đặt và trả về false.
  Future<bool> _isUnlocked() async {
    final prefs = await SharedPreferences.getInstance();
    final first = prefs.getInt(_kFirstInstall);
    if (first == null) {
      await prefs.setInt(_kFirstInstall, DateTime.now().millisecondsSinceEpoch);
      return false;
    }
    final installed = DateTime.fromMillisecondsSinceEpoch(first);
    return DateTime.now().difference(installed) > const Duration(days: 1);
  }

  Future<String> _targetLogicalIcon() async {
    final now = DateTime.now();
    // Tối/đêm (21h–6h): luôn calm.
    if (now.hour >= 21 || now.hour < 6) return 'calm';

    // Ban ngày (6h–21h): ngẫu nhiên 1 trong 3, cố định theo ngày.
    final prefs = await SharedPreferences.getInstance();
    final todayKey = '${now.year}-${now.month}-${now.day}';
    if (prefs.getString(_kMorningDate) == todayKey) {
      final saved = prefs.getString(_kMorningChoice);
      if (saved != null) return saved;
    }
    const choices = ['emotional', 'intellectual', 'physical'];
    final pick = choices[Random().nextInt(choices.length)];
    await prefs.setString(_kMorningDate, todayKey);
    await prefs.setString(_kMorningChoice, pick);
    return pick;
  }
}
