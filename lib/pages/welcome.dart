import 'package:app_bio/pages/bottomnav.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

import '../services/birthdate_provider.dart';

class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final TextEditingController _nameController = TextEditingController();
  DateTime? _selectedDate;

  // Future<void> _saveUserData() async {
  //   if (_nameController.text.isEmpty || _selectedDate == null) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text("Vui lòng nhập đầy đủ thông tin")),
  //     );
  //     return;
  //   }
  //
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   await prefs.setString('userName', _nameController.text);
  //   await prefs.setString('birthDate', DateFormat('yyyy-MM-dd').format(_selectedDate!));
  //
  //   Navigator.pushReplacement(
  //     context,
  //     MaterialPageRoute(builder: (context) => BottomNav()),
  //   );
  // }

  Future<void> _saveUserData() async {
    if (_nameController.text.isEmpty || _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Vui lòng nhập đầy đủ thông tin")),
      );
      return;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', _nameController.text);
    await prefs.setString('birthDate', DateFormat('yyyy-MM-dd').format(_selectedDate!));

    // Cập nhật Provider
    Provider.of<BirthDateProvider>(context, listen: false).setBirthDate(_selectedDate!);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => BottomNav()),
    );
  }

  Future<void> _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Chào mừng!", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text("Vui lòng nhập thông tin để bắt đầu"),
            SizedBox(height: 20),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: "Tên của bạn", border: OutlineInputBorder()),
            ),
            SizedBox(height: 20),
            ListTile(
              title: Text(_selectedDate == null ? "Chọn ngày sinh" : "Ngày sinh: ${DateFormat('dd/MM/yyyy').format(_selectedDate!)}"),
              trailing: Icon(Icons.calendar_today),
              onTap: _pickDate,
            ),
            SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: _saveUserData,
                child: Text("Tiếp tục"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}