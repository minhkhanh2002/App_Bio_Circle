import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import 'package:provider/provider.dart';

import '../services/birthdate_provider.dart';


class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  DateTime today = DateTime.now();
  DateTime viewStartDate = DateTime.now();
  int selectedOffset = 0;
  double? touchedX;

  double getValueOnDate(int cycleLength, DateTime date, DateTime birthDate) {
    final daysLived = date.difference(birthDate).inDays;
    return sin(2 * pi * daysLived / cycleLength);
  }

  List<FlSpot> generateCyclePoints(int cycleLength, DateTime birthDate) {
    final List<FlSpot> points = [];
    for (int i = -3; i <= 7; i += 1) {
      final date = viewStartDate.add(Duration(days: i));
      final value = getValueOnDate(cycleLength, date, birthDate);
      points.add(FlSpot(i.toDouble(), value));
    }
    return points;
  }

  void _changeViewWindow(int offsetDays) {
    setState(() {
      viewStartDate = viewStartDate.add(Duration(days: offsetDays));
      selectedOffset += offsetDays;
      touchedX = null;
    });
  }

  void _resetToToday() {
    setState(() {
      viewStartDate = DateTime(today.year, today.month, today.day);
      selectedOffset = 0;
      touchedX = null;
    });
  }

  String getAdvice({required DateTime forDate, required DateTime birthDate}) {
    final physical = getValueOnDate(23, forDate, birthDate);
    final emotional = getValueOnDate(28, forDate, birthDate);
    final intellectual = getValueOnDate(33, forDate, birthDate);

    String physicalTip = physical > 0.5
        ? "Bạn đang có thể chất tốt. Hãy vận động nhiều hơn."
        : physical < -0.5
        ? "Thể chất đang yếu, nên nghỉ ngơi."
        : "Thể chất ổn định.";

    String emotionalTip = emotional > 0.5
        ? "Tâm trạng tích cực, tận dụng cho giao tiếp."
        : emotional < -0.5
        ? "Dễ nhạy cảm, nên tránh căng thẳng."
        : "Cảm xúc cân bằng.";

    String intellectualTip = intellectual > 0.5
        ? "Trí tuệ sắc bén, thích hợp cho học tập và sáng tạo."
        : intellectual < -0.5
        ? "Tập trung kém, nên thư giãn tinh thần."
        : "Trí tuệ ở mức ổn định.";

    return "$physicalTip\n$emotionalTip\n$intellectualTip";
  }

  Widget buildChart(DateTime birthDate) {
    return LineChart(
      LineChartData(
        minX: -3,
        maxX: 7,
        minY: -1,
        maxY: 1,
        lineTouchData: LineTouchData(
          enabled: true,
          touchCallback: (event, response) {
            if (event is FlTapUpEvent && response != null && response.lineBarSpots != null && response.lineBarSpots!.isNotEmpty) {
              setState(() {
                touchedX = response.lineBarSpots!.first.x;
              });
            }
          },
        ),
        gridData: FlGridData(show: true),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true, interval: 1, getTitlesWidget: (value, meta) {
              final date = viewStartDate.add(Duration(days: value.toInt()));
              return Text(DateFormat('dd/MM').format(date), style: TextStyle(fontSize: 10));
            }),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: generateCyclePoints(23, birthDate),
            color: Colors.green,
            isCurved: true,
            dotData: FlDotData(show: false),
            barWidth: 2,
          ),
          LineChartBarData(
            spots: generateCyclePoints(28, birthDate),
            color: Colors.red,
            isCurved: true,
            dotData: FlDotData(show: false),
            barWidth: 2,
          ),
          LineChartBarData(
            spots: generateCyclePoints(33, birthDate),
            color: Colors.blue,
            isCurved: true,
            dotData: FlDotData(show: false),
            barWidth: 2,
          ),
        ],
        borderData: FlBorderData(show: true),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BirthDateProvider>();
    final birthDate = provider.birthDate;
    final chartHeight = MediaQuery.of(context).size.height * 0.5;

    return Scaffold(
      appBar: AppBar(
        title: Text('Biểu đồ Chu kỳ Sinh học'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (birthDate == null)
              Expanded(child: Center(child: Text('Vui lòng chọn ngày sinh trong cài đặt.')))
            else ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () => _changeViewWindow(-1),
                    icon: Icon(Icons.arrow_left),
                  ),
                  Text(
                    'Xem từ: ${DateFormat('dd/MM/yyyy').format(viewStartDate)}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    onPressed: () => _changeViewWindow(1),
                    icon: Icon(Icons.arrow_right),
                  ),
                ],
              ),
              if (selectedOffset != 0)
                TextButton(
                  onPressed: _resetToToday,
                  child: Text("Quay về hôm nay"),
                ),
              SizedBox(height: chartHeight, child: buildChart(birthDate)),
              Text(getAdvice(forDate: viewStartDate, birthDate: birthDate), textAlign: TextAlign.center),
            ],
          ],
        ),
      ),
    );
  }
}