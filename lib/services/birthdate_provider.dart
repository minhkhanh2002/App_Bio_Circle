import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BirthDateProvider extends ChangeNotifier {
  DateTime? _birthDate;
  String? _name;
  DateTime? get birthDate => _birthDate;
  String? get name => _name;

  BirthDateProvider() {
    //_loadBirthDate();
    _loadData(); // Tải dữ liệu đã lưu khi khởi động
  }

  // Lưu dữ liệu vào SharedPreferences
  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    if (_birthDate != null) {
      prefs.setString('birthDate', _birthDate!.toIso8601String());
    }
    if (_name != null) {
      prefs.setString('name', _name!);
    }
  }

  // Tải dữ liệu từ SharedPreferences
  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final birthDateString = prefs.getString('birthDate');
    final savedName = prefs.getString('name');

    if (birthDateString != null) {
      _birthDate = DateTime.parse(birthDateString);
    }
    if (savedName != null) {
      _name = savedName;
    }
    notifyListeners(); // Cập nhật UI
  }

  void setBirthDate(DateTime date) {
    _birthDate = date;
    _saveData();
    notifyListeners();
  }

  void setName(String name) {
    _name = name;
    _saveData();
    notifyListeners();
  }
}

  // Future<void> loadBirthDate() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   String? birthDateString = prefs.getString('birthDate');
  //   if (birthDateString != null) {
  //     _birthDate = DateFormat('yyyy-MM-dd').parse(birthDateString);
  //     notifyListeners();
  //   }
  // }
  //
  // void setBirthDate(DateTime birthDate) {
  //   _birthDate = birthDate;
  //   notifyListeners();
  // }
  // Future<void> _loadBirthDate() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final birthDateString = prefs.getString('birth_date');
  //   if (birthDateString != null) {
  //     _birthDate = DateTime.parse(birthDateString);
  //     notifyListeners();
  //   }
  // }

  // Future<void> setBirthDate(DateTime date) async {
  //   _birthDate = date;
  //   final prefs = await SharedPreferences.getInstance();
  //   await prefs.setString('birth_date', date.toIso8601String());
  //   notifyListeners();
  // }
// }
