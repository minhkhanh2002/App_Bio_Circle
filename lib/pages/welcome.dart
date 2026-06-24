import 'package:app_bio/pages/bottomnav.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../services/birthdate_provider.dart';
import '../services/app_localizations.dart';
import '../widgets/widget_support.dart';
import '../widgets/custom_snackbar.dart';

class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final TextEditingController _nameController = TextEditingController();
  DateTime? _selectedDate;

  Future<void> _saveUserData() async {
    if (_nameController.text.isEmpty || _selectedDate == null) {
      CustomSnackBar.show(
        context,
        AppStrings.read(context).t('welcome.fillAll'),
        isError: true,
      );
      return;
    }

    // Cập nhật Provider; Provider tự lưu 'name' và 'birthDate' (ISO8601)
    // xuống SharedPreferences, thống nhất với màn hình Cài đặt.
    final provider = Provider.of<BirthDateProvider>(context, listen: false);
    provider.setName(_nameController.text);
    provider.setBirthDate(_selectedDate!);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => BottomNav()),
    );
  }

  Future<void> _pickDate() async {
    final isDark = AppWidget.isDark;
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: (isDark ? const ColorScheme.dark() : const ColorScheme.light()).copyWith(
              primary: const Color(0xFF2575FC),
              onPrimary: Colors.white,
              surface: AppWidget.surface,
              onSurface: AppWidget.onSurface,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return Scaffold(
      body: Container(
        decoration: AppWidget.cosmicBackground(),
        child: Stack(
          children: [
            // Ambient glow
            Positioned(
              top: -100,
              right: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF6A11CB).withValues(alpha: 0.18),
                ),
              ),
            ),
            Positioned(
              bottom: -150,
              left: -50,
              child: Container(
                width: 350,
                height: 350,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF2575FC).withValues(alpha: 0.15),
                ),
              ),
            ),
            
            // Content
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Section
                      Center(
                        child: Image.asset(
                          'images/logo.png',
                          height: 140,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        s.t('welcome.title'),
                        style: AppWidget.HeadlineTextFeildStyle().copyWith(fontSize: 32),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        s.t('welcome.subtitle'),
                        style: AppWidget.LightTextFeildStyle(),
                      ),
                      const SizedBox(height: 32),
                      
                      // Glassmorphism Form Container
                      Container(
                        padding: const EdgeInsets.all(24.0),
                        decoration: AppWidget.glassDecoration(),
                        child: Column(
                          children: [
                            // Name input
                            TextField(
                              controller: _nameController,
                              style: TextStyle(color: AppWidget.primaryText, fontFamily: 'Poppins'),
                              decoration: InputDecoration(
                                labelText: s.t('welcome.yourName'),
                                labelStyle: TextStyle(color: AppWidget.mutedText, fontFamily: 'Poppins'),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(color: Colors.white24),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(color: Color(0xFF2575FC)),
                                ),
                                prefixIcon: const Icon(Icons.person_outline_rounded, color: Colors.white70),
                              ),
                            ),
                            const SizedBox(height: 20),
                            
                            // Birthdate select container button
                            InkWell(
                              onTap: _pickDate,
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.04),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.white12),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.calendar_today_rounded, color: AppWidget.secondaryText, size: 20),
                                        const SizedBox(width: 12),
                                        Text(
                                          _selectedDate == null
                                              ? s.t('welcome.chooseBirthdate')
                                              : DateFormat('dd/MM/yyyy').format(_selectedDate!),
                                          style: TextStyle(
                                            color: _selectedDate == null ? AppWidget.mutedText : AppWidget.primaryText,
                                            fontSize: 15,
                                            fontFamily: 'Poppins',
                                          ),
                                        ),
                                      ],
                                    ),
                                    Icon(Icons.arrow_forward_ios_rounded, color: AppWidget.mutedText, size: 16),
                                  ],
                                ),
                              ),
                            ),
                            
                            const SizedBox(height: 30),
                            
                            // Submit Button
                            Container(
                              width: double.infinity,
                              height: 54,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF2575FC).withValues(alpha: 0.35),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: _saveUserData,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: Text(
                                  s.t('welcome.continue'),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
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
          ],
        ),
      ),
    );
  }
}