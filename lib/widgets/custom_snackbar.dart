import 'package:flutter/material.dart';
import 'widget_support.dart';

/// Lớp tiện ích hỗ trợ hiển thị thông báo SnackBar tùy chỉnh
/// Thiết kế trẻ trung, hiện đại, dạng Floating bồng bềnh và đổ bóng Neon màu sắc
class CustomSnackBar {
  static void show(
    BuildContext context,
    String message, {
    bool isError = false,
    IconData? icon,
  }) {
    final isDark = AppWidget.isDark;

    // Chọn gradient và bóng tương ứng với loại thông báo
    final gradient = isError
        ? const LinearGradient(
            colors: [Color(0xFFFF5E62), Color(0xFFFF2A54)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        : const LinearGradient(
            colors: [Color(0xFF7F00FF), Color(0xFF00F2FE)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );

    final shadowColor = isError
        ? const Color(0xFFFF2A54).withValues(alpha: 0.35)
        : const Color(0xFF7F00FF).withValues(alpha: 0.3);

    final resolvedIcon = icon ?? (isError ? Icons.error_outline_rounded : Icons.auto_awesome_rounded);

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        duration: const Duration(seconds: 3),
        content: Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xEC121526) : const Color(0xECFFFFFF),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark ? const Color(0x28FFFFFF) : const Color(0x1B000000),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: shadowColor,
                blurRadius: 18,
                spreadRadius: 1,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  // Thanh màu chạy dọc ở cạnh trái
                  Container(
                    width: 6,
                    decoration: BoxDecoration(
                      gradient: gradient,
                    ),
                  ),
                  const SizedBox(width: 14),
                  // Biểu tượng được lồng gradient màu neon
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.08)
                            : Colors.black.withValues(alpha: 0.05),
                        shape: BoxShape.circle,
                      ),
                      child: ShaderMask(
                        shaderCallback: (bounds) => gradient.createShader(bounds),
                        child: Icon(
                          resolvedIcon,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Nội dung thông báo
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 16, top: 14, bottom: 14),
                      child: Text(
                        message,
                        style: TextStyle(
                          color: isDark ? Colors.white : const Color(0xFF161A2B),
                          fontSize: 14.0,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'BeVietnamPro',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
