import 'package:app_bio/services/birthdate_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import 'package:provider/provider.dart';
import '../services/app_localizations.dart';
import '../widgets/widget_support.dart';

class Forecast extends StatelessWidget {
  const Forecast({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final provider = context.watch<BirthDateProvider>();
    final birthDate = provider.birthDate;

    if (birthDate == null) {
      return Scaffold(
        body: Container(
          decoration: AppWidget.cosmicBackground(),
          child: Center(
            child: Text(
              s.t('needBirthdateSettings'),
              style: TextStyle(color: AppWidget.mutedText, fontFamily: 'Poppins'),
            ),
          ),
        ),
      );
    }

    final data = _calculateForecastData(birthDate);

    return Scaffold(
      body: Container(
        decoration: AppWidget.cosmicBackground(),
        height: double.infinity,
        width: double.infinity,
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                Text(
                  s.t('forecast.title'),
                  style: AppWidget.HeadlineTextFeildStyle().copyWith(fontSize: 22),
                ),
                Text(
                  s.t('forecast.subtitle'),
                  style: AppWidget.LightTextFeildStyle(),
                ),
                const SizedBox(height: 16),
                
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 110),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Card thời kỳ hoàng kim (Golden Days)
                        _buildPeriodCard(
                          title: s.t('forecast.goldenTitle'),
                          dateRange: data.goldenRangeStr,
                          description: s.t('forecast.goldenDesc'),
                          gradientColors: const [Color(0xFF6A11CB), Color(0xFF2575FC)],
                        ),
                        const SizedBox(height: 16),

                        // Card thời kỳ nghỉ ngơi (Healing Days)
                        _buildPeriodCard(
                          title: s.t('forecast.healingTitle'),
                          dateRange: data.healingRangeStr,
                          description: s.t('forecast.healingDesc'),
                          gradientColors: const [Color(0xFF1D2671), Color(0xFFC33764)],
                        ),
                        const SizedBox(height: 24),

                        Text(
                          s.t('forecast.extremesTitle'),
                          style: AppWidget.semiBoldTextFeildStyle(),
                        ),
                        const SizedBox(height: 10),

                        _buildMilestoneCard(s.t('forecast.bestPhysical'), data.bestPhysicalStr, s.t('forecast.bestPhysical.tip'), AppWidget.physicalGradient),
                        const SizedBox(height: 12),
                        _buildMilestoneCard(s.t('forecast.worstPhysical'), data.worstPhysicalStr, s.t('forecast.worstPhysical.tip'), const [Colors.grey, Colors.blueGrey]),
                        const SizedBox(height: 12),
                        _buildMilestoneCard(s.t('forecast.bestEmotional'), data.bestEmotionalStr, s.t('forecast.bestEmotional.tip'), AppWidget.emotionalGradient),
                        const SizedBox(height: 12),
                        _buildMilestoneCard(s.t('forecast.worstEmotional'), data.worstEmotionalStr, s.t('forecast.worstEmotional.tip'), const [Colors.grey, Colors.blueGrey]),
                        const SizedBox(height: 12),
                        _buildMilestoneCard(s.t('forecast.bestIntellectual'), data.bestIntellectualStr, s.t('forecast.bestIntellectual.tip'), AppWidget.intellectualGradient),
                        const SizedBox(height: 12),
                        _buildMilestoneCard(s.t('forecast.worstIntellectual'), data.worstIntellectualStr, s.t('forecast.worstIntellectual.tip'), const [Colors.grey, Colors.blueGrey]),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPeriodCard({
    required String title,
    required String dateRange,
    required String description,
    required List<Color> gradientColors,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors.map((c) => c.withValues(alpha: 0.85)).toList(),
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: gradientColors.first.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  dateRange,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: const TextStyle(
              color: Color(0xFFEEEEEE),
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMilestoneCard(String title, String date, String tip, List<Color> gradient) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppWidget.glassDecoration(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Indicator circle
          Container(
            width: 12,
            height: 12,
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(colors: gradient),
              boxShadow: [
                BoxShadow(
                  color: gradient.first.withValues(alpha: 0.4),
                  blurRadius: 6,
                  spreadRadius: 1,
                )
              ]
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        title,
                        style: TextStyle(
                          color: AppWidget.primaryText,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                    Text(
                      date,
                      style: TextStyle(
                        color: AppWidget.isDark ? const Color(0xFF00F2FE) : const Color(0xFF0091A7),
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  tip,
                  style: TextStyle(
                    color: AppWidget.secondaryText,
                    fontSize: 12.5,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _ForecastData _calculateForecastData(DateTime birthDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    const futureDays = 60;

    final overall = <double>[];

    DateTime bestIntellectual = today, worstIntellectual = today;
    DateTime bestPhysical = today, worstPhysical = today;
    DateTime bestEmotional = today, worstEmotional = today;

    int bestOverallIdx = 0, worstOverallIdx = 0;
    double maxIntellectual = -1, minIntellectual = 1;
    double maxPhysical = -1, minPhysical = 1;
    double maxEmotional = -1, minEmotional = 1;

    for (int i = 0; i < futureDays; i++) {
      final date = today.add(Duration(days: i));
      final intellectual = _cycleValue(33, date, birthDate);
      final physical = _cycleValue(23, date, birthDate);
      final emotional = _cycleValue(28, date, birthDate);
      overall.add((intellectual + physical + emotional) / 3);

      if (overall[i] > overall[bestOverallIdx]) bestOverallIdx = i;
      if (overall[i] < overall[worstOverallIdx]) worstOverallIdx = i;

      if (intellectual > maxIntellectual) {
        maxIntellectual = intellectual;
        bestIntellectual = date;
      }
      if (intellectual < minIntellectual) {
        minIntellectual = intellectual;
        worstIntellectual = date;
      }
      if (physical > maxPhysical) {
        maxPhysical = physical;
        bestPhysical = date;
      }
      if (physical < minPhysical) {
        minPhysical = physical;
        worstPhysical = date;
      }
      if (emotional > maxEmotional) {
        maxEmotional = emotional;
        bestEmotional = date;
      }
      if (emotional < minEmotional) {
        minEmotional = emotional;
        worstEmotional = date;
      }
    }

    List<DateTime> rangeAround(int peak, bool wantHigh) {
      int lo = peak, hi = peak;
      bool good(int j) => wantHigh ? overall[j] > 0.4 : overall[j] < -0.4;
      if (good(peak)) {
        while (lo - 1 >= 0 && good(lo - 1)) lo--;
        while (hi + 1 < overall.length && good(hi + 1)) hi++;
      }
      return [today.add(Duration(days: lo)), today.add(Duration(days: hi))];
    }

    final bestRange = rangeAround(bestOverallIdx, true);
    final worstRange = rangeAround(worstOverallIdx, false);

    String fmtRange(List<DateTime> r) => r[0] == r[1]
        ? DateFormat('dd/MM').format(r[0])
        : "${DateFormat('dd/MM').format(r[0])} - ${DateFormat('dd/MM').format(r[1])}";

    String fmtDate(DateTime d) => DateFormat('dd/MM/yyyy').format(d);

    return _ForecastData(
      goldenRangeStr: fmtRange(bestRange),
      healingRangeStr: fmtRange(worstRange),
      bestPhysicalStr: fmtDate(bestPhysical),
      worstPhysicalStr: fmtDate(worstPhysical),
      bestEmotionalStr: fmtDate(bestEmotional),
      worstEmotionalStr: fmtDate(worstEmotional),
      bestIntellectualStr: fmtDate(bestIntellectual),
      worstIntellectualStr: fmtDate(worstIntellectual),
    );
  }

  double _cycleValue(int cycleLength, DateTime date, DateTime birthDate) {
    final d0 = DateTime(birthDate.year, birthDate.month, birthDate.day);
    final d1 = DateTime(date.year, date.month, date.day);
    final daysLived = d1.difference(d0).inDays;
    return sin(2 * pi * daysLived / cycleLength);
  }
}

class _ForecastData {
  final String goldenRangeStr;
  final String healingRangeStr;
  final String bestPhysicalStr;
  final String worstPhysicalStr;
  final String bestEmotionalStr;
  final String worstEmotionalStr;
  final String bestIntellectualStr;
  final String worstIntellectualStr;

  _ForecastData({
    required this.goldenRangeStr,
    required this.healingRangeStr,
    required this.bestPhysicalStr,
    required this.worstPhysicalStr,
    required this.bestEmotionalStr,
    required this.worstEmotionalStr,
    required this.bestIntellectualStr,
    required this.worstIntellectualStr,
  });
}

