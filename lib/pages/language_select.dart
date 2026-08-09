import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/app_settings_provider.dart';
import '../widgets/widget_support.dart';
import 'bottomnav.dart';
import 'welcome.dart';
import 'Screen.dart';

/// Màn hình hỏi ngôn ngữ trong lần đầu mở app.
class LanguageSelectScreen extends StatelessWidget {
  const LanguageSelectScreen({super.key});

  Future<void> _choose(BuildContext context, String code) async {
    await context.read<AppSettingsProvider>().setLanguage(code);
    final prefs = await SharedPreferences.getInstance();
    final hasUserData = prefs.getString('birthDate') != null;
    final seenOnboarding = prefs.getBool('seenOnboarding') ?? false;
    if (!context.mounted) return;

    Widget next;
    if (hasUserData) {
      next = const BottomNav();
    } else if (!seenOnboarding) {
      next = const OnboardingScreen();
    } else {
      next = WelcomeScreen();
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => next),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: AppWidget.cosmicBackground(),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.language_rounded, size: 72, color: Color(0xFF2575FC)),
                  const SizedBox(height: 24),
                  Text(
                    'Choose language / Chọn ngôn ngữ',
                    textAlign: TextAlign.center,
                    style: AppWidget.HeadlineTextFeildStyle().copyWith(fontSize: 22),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'You can change this anytime in Settings.\nBạn có thể đổi lại bất cứ lúc nào trong Cài đặt.',
                    textAlign: TextAlign.center,
                    style: AppWidget.LightTextFeildStyle(),
                  ),
                  const SizedBox(height: 36),
                  _LangButton(
                    flag: '🇻🇳',
                    label: 'Tiếng Việt',
                    onTap: () => _choose(context, 'vi'),
                  ),
                  const SizedBox(height: 16),
                  _LangButton(
                    flag: '🇬🇧',
                    label: 'English',
                    onTap: () => _choose(context, 'en'),
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

class _LangButton extends StatelessWidget {
  final String flag;
  final String label;
  final VoidCallback onTap;
  const _LangButton({required this.flag, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        decoration: AppWidget.glassDecoration(radius: 16),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 26)),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                color: AppWidget.primaryText,
                fontSize: 17,
                fontWeight: FontWeight.w600,
                fontFamily: 'BeVietnamPro',
              ),
            ),
            const Spacer(),
            Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppWidget.mutedText),
          ],
        ),
      ),
    );
  }
}
