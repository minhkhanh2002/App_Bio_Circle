import 'dart:ui' show ImageFilter;
import 'package:app_bio/pages/forecast.dart';
import 'package:app_bio/pages/setting.dart';
import 'package:flutter/material.dart';

import '../services/app_localizations.dart';
import '../widgets/widget_support.dart';
import 'extend.dart';
import 'home.dart';

class BottomNav extends StatefulWidget {
  const BottomNav({super.key});

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  int currentTabIndex = 0;
  late List<Widget> pages;
  late Home homepage;
  late Extend extendpage;
  late Forecast forecastpage;
  late SettingsPage settingpage;

  @override
  void initState() {
    homepage = Home();
    extendpage = Extend();
    forecastpage = Forecast();
    settingpage = SettingsPage();
    pages = [homepage, extendpage, forecastpage, settingpage];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final isDark = AppWidget.isDark;
    final barColor = isDark
        ? Colors.white.withValues(alpha: 0.06)
        : Colors.white.withValues(alpha: 0.75);
    final iconActive = isDark ? Colors.white : const Color(0xFF161A2B);
    final iconInactive = isDark ? Colors.white54 : const Color(0xFF6A7088);
    final labels = [s.t('navHome'), s.t('navExtended'), s.t('navForecast'), s.t('navSettings')];

    return Scaffold(
      extendBody: true, // Cho phép nội dung trang chui xuống dưới Bottom Bar để hiệu ứng Blur hoạt động đẹp nhất
      body: Stack(
        children: [
          // Content Page — IndexedStack giữ state của cả 4 trang khi chuyển tab
          // (nếu không, lời khuyên AI sẽ mất khi rời trang rồi quay lại).
          IndexedStack(index: currentTabIndex, children: pages),

          // Floating Glassmorphic Bottom Navigation Bar
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: const EdgeInsets.only(left: 20, right: 20, bottom: 22),
              height: 68,
              decoration: BoxDecoration(
                color: barColor,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.12)
                      : Colors.black.withValues(alpha: 0.06),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.12),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: List.generate(4, (index) {
                        final isSelected = currentTabIndex == index;
                        final icons = [
                          Icons.insights_rounded,
                          Icons.add_chart_rounded,
                          Icons.timeline_rounded,
                          Icons.settings_rounded,
                        ];

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              currentTabIndex = index;
                            });
                          },
                          behavior: HitTestBehavior.opaque,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? (isDark
                                      ? Colors.white.withValues(alpha: 0.12)
                                      : const Color(0xFF2575FC).withValues(alpha: 0.12))
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  icons[index],
                                  color: isSelected ? iconActive : iconInactive,
                                  size: 24,
                                ),
                                if (isSelected) ...[
                                  const SizedBox(width: 8),
                                  Text(
                                    labels[index],
                                    style: TextStyle(
                                      color: iconActive,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

