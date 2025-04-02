import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import 'package:provider/provider.dart';
import '../services/birthdate_provider.dart';
import 'package:intl/intl.dart';
//1111
class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  DateTime today = DateTime.now();
  DateTime viewStartDate = DateTime.now();
  int selectedOffset = 0;
  double? touchedX;
  DateTime? selectedDate;
  DateTime? forDate = DateTime.now();

  double getValueOnDate(int cycleLength, DateTime date, DateTime birthDate) {
    final daysLived = date.difference(birthDate).inDays;
    return sin(2 * pi * daysLived / cycleLength);
  }

  List<FlSpot> generateCyclePoints(int cycleLength, DateTime birthDate) {
    final List<FlSpot> points = [];
    for (int i = -2; i <= 6; i += 1) {
      final date = viewStartDate.add(Duration(days: i));
      final value = getValueOnDate(cycleLength, date, birthDate);
      points.add(FlSpot(i.toDouble(), value));
    }
    return points;
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

  String todayAdvice = "";

  @override
  void initState() {
    super.initState();
    final provider = context.read<BirthDateProvider>();
    if (provider.birthDate != null) {
      forDate = today;
      todayAdvice = getAdvice(forDate: today, birthDate: provider.birthDate!);
    }
    // if (picked != null) {
    //   todayAdvice = getAdvice(forDate: today, birthDate: provider.birthDate!);
    // }
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

  void _pickDate(BuildContext context, DateTime birthDate) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: today,
      firstDate: birthDate,
      lastDate: today.add(Duration(days: 365)),
    );
    if (pickedDate != null) {
      setState(() {
        forDate = pickedDate;
        viewStartDate = pickedDate;
        selectedOffset = pickedDate.difference(today).inDays;
        touchedX = null;
      });
    } else{
      forDate = today;
    }
  }

  Widget buildLegend(DateTime birthDate) {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 10),
        Text('Chú thích:', style: TextStyle(fontWeight: FontWeight.bold)),
        Row(children: [
          Icon(Icons.line_axis, color: Colors.green, size: 16),
          SizedBox(width: 6),
          Text('Thể chất (23 ngày)'),
        ]),
        Row(children: [
          Icon(Icons.line_axis, color: Colors.red, size: 16),
          SizedBox(width: 6),
          Text('Cảm xúc (28 ngày)'),
        ]),
        Row(children: [
          Icon(Icons.line_axis, color: Colors.blue, size: 16),
          SizedBox(width: 6),
          Text('Trí tuệ (33 ngày)'),
        ]),
        SizedBox(height: 10),
        Text('Lời khuyên cho ngày hôm nay: (${DateFormat('dd/MM/yyyy').format(today)}) ' , style: TextStyle(fontWeight: FontWeight.bold)),
        Text(todayAdvice),
      ],
    );
  }

  Widget buildChart(DateTime birthDate) {
    return SizedBox(
      height: MediaQuery.of(context).size.height / 2.5,
      child: LineChart(
        LineChartData(
          minX: -2,
          maxX: 6,
          minY: -1,
          maxY: 1,
          lineBarsData: [
            LineChartBarData(spots: generateCyclePoints(23, birthDate), color: Colors.green, isCurved: true, dotData: FlDotData(show: false), barWidth: 2),
            LineChartBarData(spots: generateCyclePoints(28, birthDate), color: Colors.red, isCurved: true, dotData: FlDotData(show: false), barWidth: 2),
            LineChartBarData(spots: generateCyclePoints(33, birthDate), color: Colors.blue, isCurved: true, dotData: FlDotData(show: false), barWidth: 2),
          ],
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  final date = viewStartDate.add(Duration(days: value.toInt()));
                  return Text(DateFormat('dd/MM').format(date), style: TextStyle(fontSize: 10));
                },
              ),
            ),
          ),
          extraLinesData: ExtraLinesData(
            verticalLines: [
              VerticalLine(
                x: today.difference(viewStartDate).inDays.toDouble(),
                color: Colors.red,
                strokeWidth: 1.5,
                dashArray: [5, 5],
                label: VerticalLineLabel(
                  show: true,
                  alignment: Alignment.topCenter,
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                  labelResolver: (line) => 'Hôm nay',
                ),
              ),
            ],
          ),
          borderData: FlBorderData(show: true),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BirthDateProvider>();
    final birthDate = provider.birthDate;

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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(icon: Icon(Icons.arrow_back), onPressed: () => _changeViewWindow(-7)),
                  ElevatedButton(onPressed: () => _pickDate(context, birthDate), child: Text('Chọn ngày cụ thể')),
                  IconButton(icon: Icon(Icons.arrow_forward), onPressed: () => _changeViewWindow(7)),
                ],
              ),
              if (selectedOffset != 0)
                TextButton(
                  onPressed: _resetToToday,
                  child: Text("Quay về hôm nay"),
                ),
              buildChart(birthDate),
              buildLegend(birthDate),
            ],
          ],
        ),
      ),
    );
  }
}
