import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BirthDateProvider extends ChangeNotifier {
  DateTime? _birthDate;

  DateTime? get birthDate => _birthDate;

  BirthDateProvider() {
    _loadBirthDate();
  }

  Future<void> _loadBirthDate() async {
    final prefs = await SharedPreferences.getInstance();
    final birthDateString = prefs.getString('birth_date');
    if (birthDateString != null) {
      _birthDate = DateTime.parse(birthDateString);
      notifyListeners();
    }
  }

  Future<void> setBirthDate(DateTime date) async {
    _birthDate = date;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('birth_date', date.toIso8601String());
    notifyListeners();
  }
}
