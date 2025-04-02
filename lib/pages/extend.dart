import 'package:app_bio/services/birthdate_provider.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import 'package:provider/provider.dart';

//11111
class Extend extends StatefulWidget {
  @override
  _ExtendState createState() => _ExtendState();
}

class _ExtendState extends State<Extend> {
  DateTime today = DateTime.now();
  DateTime viewStartDate = DateTime.now();
  int selectedOffset = 0;
  DateTime? selectedDate;
  String adviceText = "";
  double? touchedX;
  DateTime? forDate = DateTime.now();

  double getValueOnDate(int cycleLength, DateTime date, DateTime birthDate) {
    final daysLived = date.difference(birthDate).inDays;
    return sin(2 * pi * daysLived / cycleLength);
  }

  List<FlSpot> generateCyclePoints(int cycleLength, DateTime birthDate) {
    final List<FlSpot> points = [];
    for (int i = -2; i <= 6; i++) {
      final date = viewStartDate.add(Duration(days: i));
      final value = getValueOnDate(cycleLength, date, birthDate);
      points.add(FlSpot(i.toDouble(), value));
    }
    return points;
  }

  String getAdvice({required DateTime forDate, required DateTime birthDate}) {
    final intuition = getValueOnDate(38, forDate, birthDate);
    final aesthetic = getValueOnDate(43, forDate, birthDate);
    final awareness = getValueOnDate(48, forDate, birthDate);
    final spiritual = getValueOnDate(53, forDate, birthDate);

    String intuitionTip = intuition > 0.5
        ? "Trực giác mạnh, hãy tin vào cảm nhận của mình."
        : intuition < -0.5
        ? "Trực giác chưa ổn định, cần suy nghĩ kỹ."
        : "Trực giác ổn định.";

    String aestheticTip = aesthetic > 0.5
        ? "Cảm giác thẩm mỹ tốt, thời điểm lý tưởng cho nghệ thuật."
        : aesthetic < -0.5
        ? "Cảm nhận thẩm mỹ không cao, tránh ra quyết định liên quan nghệ thuật."
        : "Cảm nhận thẩm mỹ cân bằng.";

    String awarenessTip = awareness > 0.5
        ? "Nhận thức rõ ràng, thời điểm tốt để học hỏi."
        : awareness < -0.5
        ? "Nhận thức kém sắc bén, tránh quyết định quan trọng."
        : "Nhận thức ở mức ổn định.";

    String spiritualTip = spiritual > 0.5
        ? "Tinh thần tốt, dễ kết nối với cảm xúc bên trong."
        : spiritual < -0.5
        ? "Tinh thần yếu, nên dành thời gian nghỉ ngơi."
        : "Tinh thần ở mức ổn định.";

    return "$intuitionTip\n$aestheticTip\n$awarenessTip\n$spiritualTip";
  }

  String todayAdviceExtend = "";

  // String getAdvice({required DateTime forDate, required DateTime birthDate}) {
  //   final intuition = getValueOnDate(38, forDate, birthDate);
  //   final aesthetic = getValueOnDate(43, forDate, birthDate);
  //   final awareness = getValueOnDate(48, forDate, birthDate);
  //   final spiritual = getValueOnDate(53, forDate, birthDate);
  //
  //   return "Lời khuyên (${DateFormat('dd/MM/yyyy').format(forDate)}):\n" +
  //       (intuition > 0.5 ? "Trực giác mạnh, hãy tin vào cảm nhận của mình.\n" : "Trực giác chưa ổn định, cần suy nghĩ kỹ.\n") +
  //       (aesthetic > 0.5 ? "Cảm giác thẩm mỹ tốt, thời điểm lý tưởng cho nghệ thuật.\n" : "Cảm nhận thẩm mỹ không cao, tránh ra quyết định liên quan nghệ thuật.\n") +
  //       (awareness > 0.5 ? "Nhận thức rõ ràng, thời điểm tốt để học hỏi.\n" : "Nhận thức kém sắc bén, tránh quyết định quan trọng.\n") +
  //       (spiritual > 0.5 ? "Tinh thần tốt, dễ kết nối với cảm xúc bên trong.\n" : "Tinh thần yếu, nên dành thời gian nghỉ ngơi.");
  // }

  @override
  void initState() {
    super.initState();
    final provider = context.read<BirthDateProvider>();
    if (provider.birthDate != null) {
      forDate = today;
      todayAdviceExtend = getAdvice(forDate: today, birthDate: provider.birthDate!);
    }
  }

  void _changeViewWindow(int offsetDays) {
    setState(() {
      viewStartDate = viewStartDate.add(Duration(days: offsetDays));
      selectedOffset += offsetDays;
    });
  }

  void _resetToToday() {
    setState(() {
      viewStartDate = DateTime(today.year, today.month, today.day);
      selectedOffset = 0;
      touchedX = null;
    });
  }

  // void _pickDate(BuildContext context, DateTime birthDate) async {
  //   final pickedDate = await showDatePicker(
  //     context: context,
  //     initialDate: today,
  //     firstDate: birthDate,
  //     lastDate: today.add(Duration(days: 365)),
  //   );
  //   if (pickedDate != null) {
  //     setState(() {
  //       viewStartDate = pickedDate;
  //       selectedOffset = pickedDate.difference(today).inDays;
  //       adviceText = getAdvice(forDate: pickedDate, birthDate: birthDate);
  //     });
  //   }
  // }
  void _pickDate(BuildContext context, DateTime birthDate) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: today,
      firstDate: birthDate,
      lastDate: today.add(Duration(days: 365)),
    );
    if (pickedDate != null) {
      setState(() {
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
          Icon(Icons.line_axis, color: Colors.purple, size: 16),
          SizedBox(width: 6),
          Text('Trực giác (38 ngày)'),
        ]),
        Row(children: [
          Icon(Icons.line_axis, color: Colors.orange, size: 16),
          SizedBox(width: 6),
          Text('Thẩm mỹ (43 ngày)'),
        ]),
        Row(children: [
          Icon(Icons.line_axis, color: Colors.green, size: 16),
          SizedBox(width: 6),
          Text('Nhận thức (48 ngày)'),
        ]),
        Row(children: [
          Icon(Icons.line_axis, color: Colors.brown, size: 16),
          SizedBox(width: 6),
          Text('Tinh thần (53 ngày)'),
        ]),
        SizedBox(height: 10),
        Text('Lời khuyên cho ngày hôm nay: (${DateFormat('dd/MM/yyyy').format(today)})', style: TextStyle(fontWeight: FontWeight.bold)),
        Text(todayAdviceExtend),
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
            LineChartBarData(spots: generateCyclePoints(38, birthDate), color: Colors.purple, isCurved: true, dotData: FlDotData(show: false), barWidth: 2),
            LineChartBarData(spots: generateCyclePoints(43, birthDate), color: Colors.orange, isCurved: true, dotData: FlDotData(show: false), barWidth: 2),
            LineChartBarData(spots: generateCyclePoints(48, birthDate), color: Colors.teal, isCurved: true, dotData: FlDotData(show: false), barWidth: 2),
            LineChartBarData(spots: generateCyclePoints(53, birthDate), color: Colors.brown, isCurved: true, dotData: FlDotData(show: false), barWidth: 2),
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
        title: Text('Chu kỳ Sinh học Mở rộng'),
        centerTitle: true,
      ),
      body:
      Padding(
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
      // birthDate == null
      //     ? Center(child: Text('Vui lòng chọn ngày sinh trong cài đặt.'))
      //     : SingleChildScrollView(
      //   padding: EdgeInsets.all(16.0),
      //   child: Column(
      //     children: [
      //       Row(
      //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //         children: [
      //           IconButton(icon: Icon(Icons.arrow_back), onPressed: () => _changeViewWindow(-7)),
      //           ElevatedButton(onPressed: () => _pickDate(context, birthDate), child: Text('Chọn ngày cụ thể')),
      //           IconButton(icon: Icon(Icons.arrow_forward), onPressed: () => _changeViewWindow(7)),
      //         ],
      //       ),
      //       buildChart(birthDate),
      //       SizedBox(height: 10),
      //       Text("Chú thích:\n- Màu tím: Trực giác\n- Màu cam: Thẩm mỹ\n- Màu xanh lá: Nhận thức\n- Màu nâu: Tinh thần", textAlign: TextAlign.left, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      //       SizedBox(height: 10),
      //       Text(adviceText, textAlign: TextAlign.left, style: TextStyle(fontSize: 16)),
      //     ],
      //   ),
      // ),
    );
  }
}