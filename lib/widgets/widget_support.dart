import 'package:flutter/material.dart';

class AppWidget {
  /// Cờ toàn cục điều khiển bảng màu sáng/tối. Được set từ AppSettingsProvider.
  static bool isDark = true;

  // ----- Bảng màu nền (tối / sáng) -----
  static const Color darkBgStart = Color(0xFF0B0D19);
  static const Color darkBgEnd = Color(0xFF121526);
  static const Color lightBgStart = Color(0xFFF5F7FC);
  static const Color lightBgEnd = Color(0xFFE7ECF6);

  /// Màu nền bề mặt dùng cho date picker, tooltip... (thích ứng theme).
  static Color get surface => isDark ? darkBgEnd : Colors.white;
  static Color get onSurface => isDark ? Colors.white : const Color(0xFF1A1C2E);

  // ----- Màu chữ thích ứng -----
  static Color get primaryText => isDark ? Colors.white : const Color(0xFF161A2B);
  static Color get secondaryText => isDark ? Colors.white70 : const Color(0xFF3C4258);
  static Color get mutedText => isDark ? Colors.white54 : const Color(0xFF6A7088);

  // ----- Glassmorphism thích ứng -----
  static Color get cardColor =>
      isDark ? const Color(0x13FFFFFF) : Colors.white;
  static Color get cardBorderColor =>
      isDark ? const Color(0x1BFFFFFF) : const Color(0x11000000);

  // ----- Gradient neon cho các chu kỳ (không đổi theo theme) -----
  static const List<Color> physicalGradient = [Color(0xFF00F2FE), Color(0xFF4FACFE)];
  static const List<Color> emotionalGradient = [Color(0xFFFF5E62), Color(0xFFFF2A54)];
  static const List<Color> intellectualGradient = [Color(0xFF7F00FF), Color(0xFFE100FF)];
  static const List<Color> intuitionGradient = [Color(0xFF3F51B5), Color(0xFF2196F3)];
  static const List<Color> aestheticGradient = [Color(0xFFFF9900), Color(0xFFFF5E62)];
  static const List<Color> awarenessGradient = [Color(0xFF11998E), Color(0xFF38EF7D)];
  static const List<Color> spiritualGradient = [Color(0xFFA18CD1), Color(0xFFFBC2EB)];

  // ----- Kiểu chữ (Poppins) thích ứng theme -----
  static TextStyle boldTextFieldStyle() {
    return TextStyle(
        color: primaryText,
        fontSize: 20.0,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.2,
        fontFamily: 'Poppins');
  }

  static TextStyle HeadlineTextFeildStyle() {
    return TextStyle(
        color: primaryText,
        fontSize: 26.0,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.3,
        fontFamily: 'Poppins');
  }

  static TextStyle LightTextFeildStyle() {
    return TextStyle(
        color: mutedText,
        fontSize: 14.0,
        fontWeight: FontWeight.w400,
        height: 1.4,
        fontFamily: 'Poppins');
  }

  static TextStyle semiBoldTextFeildStyle() {
    return TextStyle(
        color: secondaryText,
        fontSize: 17.0,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        fontFamily: 'Poppins');
  }

  // ----- Glass box decoration thích ứng -----
  static BoxDecoration glassDecoration({double radius = 24}) {
    return BoxDecoration(
      color: cardColor,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: cardBorderColor, width: 1.5),
      boxShadow: isDark
          ? null
          : [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
    );
  }

  // ----- Nền gradient thích ứng -----
  static BoxDecoration cosmicBackground() {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: isDark
            ? const [darkBgStart, darkBgEnd]
            : const [lightBgStart, lightBgEnd],
      ),
    );
  }
}