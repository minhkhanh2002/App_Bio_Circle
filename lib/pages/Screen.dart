import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/app_localizations.dart';
import '../widgets/widget_support.dart';
import 'welcome.dart';

/// Một trang giới thiệu trong luồng onboarding (lưu KEY để dịch lúc build).
class _OnboardPageData {
  final IconData icon;
  final String titleKey;
  final String descKey;
  final List<Color> gradient;
  final List<_FeatureChip> highlights;

  const _OnboardPageData({
    required this.icon,
    required this.titleKey,
    required this.descKey,
    required this.gradient,
    this.highlights = const [],
  });
}

class _FeatureChip {
  final IconData icon;
  final String nameKey; // key tên chu kỳ
  final int days; // 0 = không hiển thị số ngày
  final Color color;
  const _FeatureChip(this.icon, this.nameKey, this.days, this.color);
}

const List<_OnboardPageData> _pages = [
  _OnboardPageData(
    icon: Icons.auto_graph_rounded,
    titleKey: 'ob.1.title',
    descKey: 'ob.1.desc',
    gradient: [Color(0xFF6A11CB), Color(0xFF2575FC)],
  ),
  _OnboardPageData(
    icon: Icons.show_chart_rounded,
    titleKey: 'ob.2.title',
    descKey: 'ob.2.desc',
    gradient: [Color(0xFF11998E), Color(0xFF38EF7D)],
    highlights: [
      _FeatureChip(Icons.fitness_center_rounded, 'physical', 23, Colors.greenAccent),
      _FeatureChip(Icons.favorite_rounded, 'emotional', 28, Colors.redAccent),
      _FeatureChip(Icons.psychology_rounded, 'intellectual', 33, Colors.blueAccent),
    ],
  ),
  _OnboardPageData(
    icon: Icons.insights_rounded,
    titleKey: 'ob.3.title',
    descKey: 'ob.3.desc',
    gradient: [Color(0xFFFF512F), Color(0xFFDD2476)],
    highlights: [
      _FeatureChip(Icons.lightbulb_outline_rounded, 'intuition', 0, Colors.purpleAccent),
      _FeatureChip(Icons.palette_outlined, 'aesthetic', 0, Colors.orangeAccent),
      _FeatureChip(Icons.self_improvement_rounded, 'spiritual', 0, Colors.tealAccent),
    ],
  ),
  _OnboardPageData(
    icon: Icons.science_outlined,
    titleKey: 'ob.4.title',
    descKey: 'ob.4.desc',
    gradient: [Color(0xFF1D2671), Color(0xFFC33764)],
  ),
  _OnboardPageData(
    icon: Icons.emoji_objects_outlined,
    titleKey: 'ob.5.title',
    descKey: 'ob.5.desc',
    gradient: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
  ),
];

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  bool get _isLastPage => _currentPage == _pages.length - 1;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seenOnboarding', true);
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => WelcomeScreen()),
    );
  }

  void _next() {
    if (_isLastPage) {
      _completeOnboarding();
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final page = _pages[_currentPage];

    return Scaffold(
      body: Container(
        decoration: AppWidget.cosmicBackground(),
        child: Stack(
          children: [
            Positioned(
              top: MediaQuery.of(context).size.height * 0.15,
              left: MediaQuery.of(context).size.width * 0.05,
              right: MediaQuery.of(context).size.width * 0.05,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 600),
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      page.gradient.first.withValues(alpha: 0.35),
                      page.gradient.last.withValues(alpha: 0.0),
                    ],
                    radius: 0.9,
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: AnimatedOpacity(
                      opacity: _isLastPage ? 0.0 : 1.0,
                      duration: const Duration(milliseconds: 250),
                      child: Padding(
                        padding: const EdgeInsets.only(right: 16.0, top: 8.0),
                        child: TextButton(
                          onPressed: _isLastPage ? null : _completeOnboarding,
                          child: Text(
                            s.t('ob.skip'),
                            style: TextStyle(
                              color: AppWidget.secondaryText,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'BeVietnamPro',
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: _pages.length,
                      onPageChanged: (index) =>
                          setState(() => _currentPage = index),
                      itemBuilder: (context, index) => _buildPage(_pages[index], s),
                    ),
                  ),
                  _buildDots(),
                  const SizedBox(height: 30),
                  _buildBottomButton(s),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(_OnboardPageData page, AppStrings s) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              shape: BoxShape.circle,
              border: Border.all(
                color: page.gradient.first.withValues(alpha: 0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: page.gradient.first.withValues(alpha: 0.2),
                  blurRadius: 20,
                  spreadRadius: 2,
                )
              ],
            ),
            child: Icon(page.icon, size: 68, color: page.gradient.last),
          ),
          const SizedBox(height: 48),
          Text(
            s.t(page.titleKey),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppWidget.primaryText,
              letterSpacing: 0.3,
              fontFamily: 'BeVietnamPro',
            ),
          ),
          const SizedBox(height: 16),
          Text(
            s.t(page.descKey),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              height: 1.5,
              color: AppWidget.secondaryText,
              fontFamily: 'BeVietnamPro',
            ),
          ),
          if (page.highlights.isNotEmpty) ...[
            const SizedBox(height: 32),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 10,
              runSpacing: 10,
              children: page.highlights.map((c) => _buildChip(c, s)).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildChip(_FeatureChip chip, AppStrings s) {
    final label = chip.days > 0
        ? s.chipDays(s.t(chip.nameKey), chip.days)
        : s.t(chip.nameKey);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: chip.color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: chip.color.withValues(alpha: 0.35),
          width: 1.2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(chip.icon, size: 16, color: chip.color),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: chip.color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
              fontFamily: 'BeVietnamPro',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_pages.length, (index) {
        final active = _currentPage == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 5),
          width: active ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: active ? AppWidget.primaryText : AppWidget.mutedText.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(10),
          ),
        );
      }),
    );
  }

  Widget _buildBottomButton(AppStrings s) {
    final page = _pages[_currentPage];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: LinearGradient(
            colors: page.gradient,
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          boxShadow: [
            BoxShadow(
              color: page.gradient.first.withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 6),
            )
          ],
        ),
        child: ElevatedButton(
          onPressed: _next,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
          ),
          child: Text(
            _isLastPage ? s.t('ob.explore') : s.t('ob.next'),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: 'BeVietnamPro',
            ),
          ),
        ),
      ),
    );
  }
}
