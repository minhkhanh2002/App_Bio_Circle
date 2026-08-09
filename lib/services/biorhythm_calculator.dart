import 'dart:math';

/// Công thức tính chu kỳ sinh học thuần Dart (không phụ thuộc Flutter/State),
/// dùng chung cho UI và cho việc soạn nội dung thông báo trước.
class BiorhythmCalculator {
  static double valueOnDate(int cycleLength, DateTime date, DateTime birthDate) {
    final d0 = DateTime(birthDate.year, birthDate.month, birthDate.day);
    final d1 = DateTime(date.year, date.month, date.day);
    final daysLived = d1.difference(d0).inDays;
    return sin(2 * pi * daysLived / cycleLength);
  }

  static int toPercentage(double value) => ((value + 1) * 50).round();

  static Map<String, int> coreMetrics(DateTime birthDate, DateTime date) => {
        'physical': toPercentage(valueOnDate(23, date, birthDate)),
        'emotional': toPercentage(valueOnDate(28, date, birthDate)),
        'intellectual': toPercentage(valueOnDate(33, date, birthDate)),
      };
}
