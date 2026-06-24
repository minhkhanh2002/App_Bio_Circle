import 'package:flutter/material.dart';

import '../services/app_localizations.dart';
import '../services/feedback_service.dart';
import '../widgets/widget_support.dart';
import '../widgets/custom_snackbar.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _messageController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _snack(String msg, {bool isError = false}) {
    CustomSnackBar.show(context, msg, isError: isError);
  }

  Future<void> _send() async {
    final s = AppStrings.read(context);
    final message = _messageController.text.trim();
    if (message.isEmpty) {
      _snack(s.t('settings.feedbackEmpty'), isError: true);
      return;
    }
    final email = _emailController.text.trim();
    if (email.isNotEmpty) {
      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (!emailRegex.hasMatch(email)) {
        _snack(s.t('settings.feedbackEmailInvalid'), isError: true);
        return;
      }
    }
    final locale = s.code;
    setState(() => _sending = true);
    try {
      final result = await FeedbackService().submit(
        message: message,
        email: email,
        locale: locale,
      );
      if (!mounted) return;
      _snack(result == FeedbackResult.sent
          ? s.t('settings.feedbackSent')
          : s.t('settings.feedbackQueued'));
      Navigator.of(context).pop();
    } catch (_) {
      if (mounted) _snack(s.t('settings.feedbackError'), isError: true);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return Scaffold(
      body: Container(
        decoration: AppWidget.cosmicBackground(),
        height: double.infinity,
        width: double.infinity,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back_rounded, color: AppWidget.primaryText),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    Expanded(
                      child: Text(s.t('feedback.title'),
                          style: AppWidget.HeadlineTextFeildStyle().copyWith(fontSize: 20)),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Text(s.t('feedback.subtitle'), style: AppWidget.LightTextFeildStyle()),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: AppWidget.glassDecoration(),
                  child: Column(
                    children: [
                      TextField(
                        controller: _messageController,
                        maxLines: 5,
                        maxLength: 1000,
                        autofocus: true,
                        style: TextStyle(color: AppWidget.primaryText, fontSize: 14, fontFamily: 'Poppins'),
                        decoration: InputDecoration(
                          hintText: s.t('settings.feedbackHint'),
                          hintStyle: TextStyle(color: AppWidget.mutedText),
                          counterStyle: TextStyle(color: AppWidget.mutedText),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: AppWidget.cardBorderColor),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFFE100FF)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: TextStyle(color: AppWidget.primaryText, fontSize: 14, fontFamily: 'Poppins'),
                        decoration: InputDecoration(
                          hintText: s.t('settings.feedbackEmailHint'),
                          hintStyle: TextStyle(color: AppWidget.mutedText, fontSize: 13),
                          prefixIcon: Icon(Icons.alternate_email_rounded, color: AppWidget.secondaryText, size: 20),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: AppWidget.cardBorderColor),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFFE100FF)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.lock_outline_rounded, size: 14, color: AppWidget.mutedText),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(s.t('settings.feedbackAnon'),
                                style: TextStyle(color: AppWidget.mutedText, fontSize: 12)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Container(
                        width: double.infinity,
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF7F00FF), Color(0xFFE100FF)],
                          ),
                        ),
                        child: ElevatedButton(
                          onPressed: _sending ? null : _send,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            disabledBackgroundColor: Colors.transparent,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: _sending
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                                )
                              : Text(
                                  s.t('settings.sendFeedback'),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
