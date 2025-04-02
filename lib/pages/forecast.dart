import 'package:app_bio/services/birthdate_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import 'package:provider/provider.dart';


class Forecast extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BirthDateProvider>();
    final birthDate = provider.birthDate;

    if (birthDate == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Dự đoán Chu kỳ Sinh học')),
        body: Center(child: Text('Vui lòng chọn ngày sinh trong cài đặt.')),
      );
    }

    final forecast = generateForecast(birthDate);

    return Scaffold(
      appBar: AppBar(title: Text('Dự đoán Chu kỳ Sinh học')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(forecast, style: TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }
}

String generateForecast(DateTime birthDate) {
  final today = DateTime.now();
  final futureDays = 60;

  DateTime bestOverallStart = today, bestOverallEnd = today;
  DateTime worstOverallStart = today, worstOverallEnd = today;
  DateTime bestIntellectual = today, worstIntellectual = today;
  DateTime bestPhysical = today, worstPhysical = today;
  DateTime bestEmotional = today, worstEmotional = today;

  double maxOverall = -1, minOverall = 1;
  double maxIntellectual = -1, minIntellectual = 1;
  double maxPhysical = -1, minPhysical = 1;
  double maxEmotional = -1, minEmotional = 1;

  for (int i = 0; i < futureDays; i++) {
    final date = today.add(Duration(days: i));
    final intellectual = sin(2 * pi * date.difference(birthDate).inDays / 33);
    final physical = sin(2 * pi * date.difference(birthDate).inDays / 23);
    final emotional = sin(2 * pi * date.difference(birthDate).inDays / 28);
    final overall = (intellectual + physical + emotional) / 3;

    if (overall > maxOverall) {
      maxOverall = overall;
      bestOverallStart = date;
    } else if (overall < minOverall) {
      minOverall = overall;
      worstOverallStart = date;
    }

    if (intellectual > maxIntellectual) {
      maxIntellectual = intellectual;
      bestIntellectual = date;
    } else if (intellectual < minIntellectual) {
      minIntellectual = intellectual;
      worstIntellectual = date;
    }

    if (physical > maxPhysical) {
      maxPhysical = physical;
      bestPhysical = date;
    } else if (physical < minPhysical) {
      minPhysical = physical;
      worstPhysical = date;
    }

    if (emotional > maxEmotional) {
      maxEmotional = emotional;
      bestEmotional = date;
    } else if (emotional < minEmotional) {
      minEmotional = emotional;
      worstEmotional = date;
    }
  }

  return "Cơ thể bạn đạt trạng thái tốt nhất về trí tuệ, sức khỏe và tình cảm \nở khoảng ngày "
      "${DateFormat('dd/MM').format(bestOverallStart)} - ${DateFormat('dd/MM/yyyy').format(bestOverallStart.add(Duration(days: 2)))}"
      " và kém nhất ở khoảng ngày ${DateFormat('dd/MM').format(worstOverallStart)} - ${DateFormat('dd/MM/yyyy').format(worstOverallStart.add(Duration(days: 2)))}.\n\n"
      "Trí tuệ của bạn tốt nhất ở ngày ${DateFormat('dd/MM/yyyy').format(bestIntellectual)} và kém nhất ở ${DateFormat('dd/MM/yyyy').format(worstIntellectual)}.\n"
      "Sức khỏe của bạn tốt nhất ở ngày ${DateFormat('dd/MM/yyyy').format(bestPhysical)} và kém nhất ở ${DateFormat('dd/MM/yyyy').format(worstPhysical)}.\n"
      "Tình cảm của bạn tốt nhất ở ngày ${DateFormat('dd/MM/yyyy').format(bestEmotional)} và kém nhất ở ${DateFormat('dd/MM/yyyy').format(worstEmotional)}.";
}
