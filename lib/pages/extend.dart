import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/birthdate_provider.dart';
import '../services/app_settings_provider.dart';
import '../services/app_localizations.dart';
import '../services/advice_service.dart';
import '../services/advice_bank.dart';
import '../widgets/widget_support.dart';
import '../widgets/info_sheet.dart';
import '../widgets/custom_snackbar.dart';
import '../widgets/achievement_dialog.dart';

const Color _kAccent = Color(0xFFFF9900);

class Extend extends StatefulWidget {
  const Extend({super.key});
  @override
  State<Extend> createState() => _ExtendState();
}

class _ExtendState extends State<Extend> {
  DateTime today = DateTime.now();
  DateTime selectedDate = DateTime.now();

  static const int _tlSpan = 30;
  static const int _tlVisible = 5;
  final ScrollController _tlController = ScrollController();

  String? _aiAdvice;
  bool _aiLoading = false;
  bool _aiUsedToday = false;
  // Lời khuyên AI đã sinh trong ngày, kèm ngày (selectedDate) nó thuộc về — để
  // nếu người dùng bấm "Đổi gợi ý" rồi bấm AI lại (đã hết lượt), có thể hiện
  // lại đúng câu đã sinh thay vì chỉ báo hết lượt và mất luôn nội dung.
  String? _savedAiAdvice;
  String? _savedAiAdviceDateKey;
  int _bankSeed = 0;
  int _aiNagCount = 0; // số lần cố bấm sau khi đã hết lượt (lời nhắc phân tầng)

  @override
  void initState() {
    super.initState();
    today = DateTime(today.year, today.month, today.day);
    selectedDate = today;
    WidgetsBinding.instance.addPostFrameCallback((_) => _centerOnDate(today, animate: false));
    _loadAiUsage();
  }

  String get _todayKey =>
      '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

  String get _selectedDateKey =>
      '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}';

  Future<void> _loadAiUsage() async {
    final prefs = await SharedPreferences.getInstance();
    final used = prefs.getString('lastAiAdviceYmd_extended') == _todayKey;
    if (!used || !mounted) return;
    final savedText = prefs.getString('lastAiAdviceText_extended');
    final savedDateKey = prefs.getString('lastAiAdviceDateKey_extended');
    setState(() {
      _aiUsedToday = true;
      _savedAiAdvice = savedText;
      _savedAiAdviceDateKey = savedDateKey;
      if (savedText != null && savedDateKey == _selectedDateKey) {
        _aiAdvice = savedText;
      }
    });
  }

  Future<void> _markAiUsed() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lastAiAdviceYmd_extended', _todayKey);
    if (mounted) setState(() => _aiUsedToday = true);
  }

  /// Như [_markAiUsed] nhưng lưu kèm nội dung AI đã sinh, để có thể hiện lại
  /// nếu người dùng chuyển qua gợi ý từ kho rồi bấm AI lại trong cùng ngày.
  Future<void> _saveAiAdvice(String advice) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lastAiAdviceYmd_extended', _todayKey);
    await prefs.setString('lastAiAdviceText_extended', advice);
    await prefs.setString('lastAiAdviceDateKey_extended', _selectedDateKey);
    if (mounted) {
      setState(() {
        _aiUsedToday = true;
        _savedAiAdvice = advice;
        _savedAiAdviceDateKey = _selectedDateKey;
      });
    }
  }

  void _snack(String msg, {bool isError = false}) {
    CustomSnackBar.show(context, msg, isError: isError);
  }

  Map<String, int> _extMetrics(DateTime birthDate) => {
        'intuition': _toPercentage(getValueOnDate(38, selectedDate, birthDate)),
        'aesthetic': _toPercentage(getValueOnDate(43, selectedDate, birthDate)),
        'awareness': _toPercentage(getValueOnDate(48, selectedDate, birthDate)),
        'spiritual': _toPercentage(getValueOnDate(53, selectedDate, birthDate)),
      };

  /// Đã hết lượt mà vẫn bấm: nhắc phân tầng + tích lũy mở khóa huy hiệu ẩn.
  Future<void> _handleAiNag(AppStrings s) async {
    _aiNagCount++;
    final justUnlocked =
        await context.read<AppSettingsProvider>().recordAiNagTap();
    if (!mounted) return;
    // Lần 5 (đạt ngưỡng) mở khóa huy hiệu; lần 1→4 là các câu đáng thương dần.
    if (justUnlocked) {
      _snack(s.t('ai.badgeUnlocked'));
      AchievementDialog.show(context);
    } else if (_aiNagCount <= 1) {
      _snack(s.t('ai.limit'));
    } else if (_aiNagCount == 2) {
      _snack(s.t('ai.nag2'));
    } else if (_aiNagCount == 3) {
      _snack(s.t('ai.nag3'));
    } else {
      _snack(s.t('ai.nag4'));
    }
  }

  Future<void> _fetchAiAdvice(AppStrings s, DateTime birthDate, String? name) async {
    if (_aiUsedToday) {
      // Đã hết lượt hôm nay: nếu đúng ngày này đã có câu AI sinh sẵn (người
      // dùng chỉ đang xem lại sau khi bấm "Đổi gợi ý"), hiện lại luôn, không
      // gọi API mới. Vẫn tính là "cố bấm sau khi hết lượt" (_handleAiNag) như
      // trước — nếu không, người dùng đang xem đúng ngày đã có AI sẽ không
      // bao giờ tích lũy được lời nhắc phân tầng / mở khóa huy hiệu ẩn.
      if (_savedAiAdvice != null && _savedAiAdviceDateKey == _selectedDateKey) {
        setState(() => _aiAdvice = _savedAiAdvice);
      }
      await _handleAiNag(s);
      return;
    }
    final settings = context.read<AppSettingsProvider>();
    setState(() => _aiLoading = true);
    try {
      final advice = await AdviceService().getAdvice(
        scope: 'extended',
        locale: s.code,
        name: name,
        style: settings.aiStyle,
        styleNote: settings.aiStyleNote,
        metrics: _extMetrics(birthDate),
      );
      if (!mounted) return;
      setState(() => _aiAdvice = advice);
      await _saveAiAdvice(advice);
    } on AdviceException catch (e) {
      if (e.code == 'resource-exhausted') {
        await _markAiUsed();
        if (mounted) _snack(s.t('ai.limit'));
      } else if (e.code == 'failed-precondition') {
        if (mounted) _snack(s.t('ai.brokeOwner'), isError: true);
      } else if (mounted) {
        _snack(s.t('ai.error'), isError: true);
      }
    } catch (_) {
      if (mounted) _snack(s.t('ai.error'), isError: true);
    } finally {
      if (mounted) setState(() => _aiLoading = false);
    }
  }

  Widget buildAiCoach(AppStrings s, DateTime birthDate, String? name) {
    final isAi = _aiAdvice != null;
    final text = _aiAdvice ??
        AdviceBank.advice(locale: s.code, metrics: _extMetrics(birthDate), seed: _bankSeed);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: AppWidget.glassDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ShaderMask(
                shaderCallback: (b) => const LinearGradient(
                  colors: [Color(0xFF7F00FF), Color(0xFF00F2FE)],
                ).createShader(b),
                child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 10),
              Text(s.t('ai.title'),
                  style: TextStyle(
                      color: AppWidget.primaryText,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'BeVietnamPro')),
              if (isAi) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFF7F00FF), Color(0xFF00F2FE)]),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('✨ ${s.t('ai.badge')}',
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),
          Text(text, style: TextStyle(color: AppWidget.secondaryText, fontSize: 13.5, height: 1.45)),
          const SizedBox(height: 6),
          Row(
            children: [
              TextButton.icon(
                onPressed: _aiLoading
                    ? null
                    : () => setState(() {
                          _bankSeed++;
                          _aiAdvice = null;
                        }),
                icon: Icon(Icons.shuffle_rounded, size: 16, color: AppWidget.secondaryText),
                label: Text(s.t('ai.shuffle'),
                    style: TextStyle(color: AppWidget.secondaryText, fontSize: 12.5)),
              ),
              const Spacer(),
              TextButton.icon(
                // Vẫn bấm được khi hết lượt để kích hoạt lời nhắc phân tầng (ẩn).
                onPressed: _aiLoading ? null : () => _fetchAiAdvice(s, birthDate, name),
                icon: _aiLoading
                    ? const SizedBox(
                        width: 14, height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF7F00FF)))
                    : Icon(Icons.auto_awesome_rounded, size: 16,
                        color: _aiUsedToday ? AppWidget.mutedText : const Color(0xFF7F00FF)),
                label: Text(
                    _aiLoading ? s.t('ai.loading') : (isAi ? s.t('ai.regenerate') : s.t('ai.personalize')),
                    style: TextStyle(
                        color: _aiUsedToday ? AppWidget.mutedText : const Color(0xFF7F00FF),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tlController.dispose();
    super.dispose();
  }

  void _centerOnDate(DateTime date, {bool animate = true}) {
    final d = DateTime(date.year, date.month, date.day);
    final index = d.difference(today).inDays + _tlSpan;
    if (index < 0 || index > _tlSpan * 2) return;
    if (!_tlController.hasClients) return;
    final viewport = _tlController.position.viewportDimension;
    final extent = viewport / _tlVisible;
    double target = index * extent + extent / 2 - viewport / 2;
    target = target.clamp(0.0, _tlController.position.maxScrollExtent);
    if (animate) {
      _tlController.animateTo(target,
          duration: const Duration(milliseconds: 350), curve: Curves.easeInOut);
    } else {
      _tlController.jumpTo(target);
    }
  }

  void _selectDate(DateTime date) {
    setState(() {
      selectedDate = date;
      // Lời khuyên gắn với từng ngày: nếu ngày này đã có câu AI sinh sẵn
      // trong ngày hôm nay, hiện lại luôn; nếu không thì về gợi ý kho.
      _aiAdvice = (_savedAiAdvice != null && _savedAiAdviceDateKey == _selectedDateKey)
          ? _savedAiAdvice
          : null;
    });
    _centerOnDate(date);
  }

  double getValueOnDate(int cycleLength, DateTime date, DateTime birthDate) {
    final d0 = DateTime(birthDate.year, birthDate.month, birthDate.day);
    final d1 = DateTime(date.year, date.month, date.day);
    final daysLived = d1.difference(d0).inDays;
    return sin(2 * pi * daysLived / cycleLength);
  }

  List<FlSpot> generateCyclePoints(int cycleLength, DateTime birthDate) {
    final List<FlSpot> points = [];
    for (int i = -3; i <= 7; i++) {
      final date = selectedDate.add(Duration(days: i));
      points.add(FlSpot(i.toDouble(), getValueOnDate(cycleLength, date, birthDate)));
    }
    return points;
  }

  int _toPercentage(double value) => ((value + 1) * 50).round();

  void _resetToToday() {
    setState(() {
      selectedDate = today;
      _aiAdvice = (_savedAiAdvice != null && _savedAiAdviceDateKey == _selectedDateKey)
          ? _savedAiAdvice
          : null;
    });
    _centerOnDate(today);
  }

  void _pickDate(BuildContext context, DateTime birthDate) async {
    final isDark = AppWidget.isDark;
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: birthDate,
      lastDate: today.add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: (isDark ? const ColorScheme.dark() : const ColorScheme.light()).copyWith(
              primary: _kAccent,
              onPrimary: Colors.white,
              surface: AppWidget.surface,
              onSurface: AppWidget.onSurface,
            ),
          ),
          child: child!,
        );
      },
    );
    if (pickedDate != null) {
      _selectDate(DateTime(pickedDate.year, pickedDate.month, pickedDate.day));
    }
  }

  Widget buildOverallSummary(AppStrings s, double a, double b, double c, double d) {
    final percent = _toPercentage((a + b + c + d) / 4);
    String description = s.t('extend.soul.mid');
    if (percent > 65) {
      description = s.t('extend.soul.high');
    } else if (percent < 40) {
      description = s.t('extend.soul.low');
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppWidget.glassDecoration(),
      child: Row(
        children: [
          Icon(Icons.auto_awesome_rounded, color: Colors.orangeAccent[100], size: 40),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s.t('extend.soulTitle'),
                    style: TextStyle(color: AppWidget.mutedText, fontSize: 13, fontFamily: 'BeVietnamPro')),
                const SizedBox(height: 4),
                Text(description,
                    style: TextStyle(
                        color: AppWidget.primaryText,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'BeVietnamPro')),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget buildHorizontalTimeline() {
    final isDark = AppWidget.isDark;
    const gap = 8.0;
    return SizedBox(
      height: 78,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final extent = constraints.maxWidth / _tlVisible;
          final cardWidth = extent - gap;
          return ListView.builder(
            controller: _tlController,
            scrollDirection: Axis.horizontal,
            itemCount: _tlSpan * 2 + 1,
            itemBuilder: (context, index) {
              final offsetDays = index - _tlSpan;
              final date = today.add(Duration(days: offsetDays));
              final isSelected = selectedDate.year == date.year &&
                  selectedDate.month == date.month &&
                  selectedDate.day == date.day;
              final isToday = offsetDays == 0;

              final dayName = DateFormat('E').format(date);
              final dayStr = DateFormat('dd').format(date);

              final Color bg = isSelected
                  ? _kAccent.withValues(alpha: 0.85)
                  : isToday
                      ? (isDark ? Colors.white.withValues(alpha: 0.15) : _kAccent.withValues(alpha: 0.10))
                      : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03));
              final Color border = isSelected
                  ? const Color(0xFFFFE57F).withValues(alpha: 0.8)
                  : isToday
                      ? _kAccent.withValues(alpha: 0.5)
                      : AppWidget.cardBorderColor;

              return GestureDetector(
                onTap: () => _selectDate(date),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: cardWidth,
                  margin: const EdgeInsets.only(right: gap, top: 2, bottom: 2),
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: border, width: isToday || isSelected ? 1.8 : 1.2),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: _kAccent.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            )
                          ]
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(dayName,
                          style: TextStyle(
                              color: isSelected ? Colors.white : AppWidget.mutedText,
                              fontSize: 12,
                              fontWeight: FontWeight.w500)),
                      const SizedBox(height: 4),
                      Text(dayStr,
                          style: TextStyle(
                              color: isSelected ? Colors.white : AppWidget.primaryText,
                              fontSize: 18,
                              fontWeight: isToday || isSelected ? FontWeight.bold : FontWeight.w600)),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget buildChart(AppStrings s, DateTime birthDate) {
    return Container(
      height: 220,
      padding: const EdgeInsets.only(top: 20, right: 16, left: 4),
      decoration: AppWidget.glassDecoration(),
      child: LineChart(
        LineChartData(
          minX: -3,
          maxX: 7,
          minY: -5,
          maxY: 105,
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              tooltipBgColor: AppWidget.surface.withValues(alpha: 0.95),
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((barSpot) {
                  final val = barSpot.y.round();
                  String title = "";
                  Color itemColor = AppWidget.primaryText;
                  if (barSpot.barIndex == 0) {
                    title = s.t('intuition');
                    itemColor = AppWidget.intuitionGradient.first;
                  } else if (barSpot.barIndex == 1) {
                    title = s.t('aesthetic');
                    itemColor = AppWidget.aestheticGradient.first;
                  } else if (barSpot.barIndex == 2) {
                    title = s.t('awareness');
                    itemColor = AppWidget.awarenessGradient.first;
                  } else if (barSpot.barIndex == 3) {
                    title = s.t('spiritual');
                    itemColor = AppWidget.spiritualGradient.first;
                  }
                  return LineTooltipItem("$title: $val%",
                      TextStyle(color: itemColor, fontWeight: FontWeight.bold, fontSize: 13));
                }).toList();
              },
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) => FlLine(
              color: AppWidget.cardBorderColor,
              strokeWidth: 1,
              dashArray: const [4, 4],
            ),
          ),
          titlesData: FlTitlesData(
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 34,
                getTitlesWidget: (value, meta) {
                  final style = TextStyle(color: AppWidget.mutedText, fontSize: 9);
                  if (value == 100) return Text("100%", style: style);
                  if (value == 50) return Text("50%", style: style);
                  if (value == 0) return Text("0%", style: style);
                  return const SizedBox();
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 2,
                getTitlesWidget: (value, meta) {
                  final date = selectedDate.add(Duration(days: value.toInt()));
                  final isCenter = value.toInt() == 0;
                  return Text(
                    DateFormat('dd/MM').format(date),
                    style: TextStyle(
                      color: isCenter ? _kAccent : AppWidget.mutedText,
                      fontSize: 10,
                      fontWeight: isCenter ? FontWeight.bold : FontWeight.normal,
                    ),
                  );
                },
              ),
            ),
          ),
          extraLinesData: ExtraLinesData(
            verticalLines: [
              VerticalLine(
                x: 0,
                color: _kAccent.withValues(alpha: 0.4),
                strokeWidth: 1.5,
                dashArray: [5, 5],
              ),
            ],
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            _barData(generateCyclePoints(38, birthDate), AppWidget.intuitionGradient),
            _barData(generateCyclePoints(43, birthDate), AppWidget.aestheticGradient),
            _barData(generateCyclePoints(48, birthDate), AppWidget.awarenessGradient),
            _barData(generateCyclePoints(53, birthDate), AppWidget.spiritualGradient),
          ],
        ),
      ),
    );
  }

  LineChartBarData _barData(List<FlSpot> spots, List<Color> gradient) {
    return LineChartBarData(
      spots: spots.map((spot) => FlSpot(spot.x, (spot.y + 1) * 50)).toList(),
      gradient: LinearGradient(colors: gradient),
      isCurved: true,
      preventCurveOverShooting: true,
      dotData: const FlDotData(show: false),
      barWidth: 2.5,
      belowBarData: BarAreaData(
        show: true,
        gradient: LinearGradient(
          colors: gradient.map((c) => c.withValues(alpha: 0.05)).toList(),
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );
  }

  Widget buildCycleCards(AppStrings s, DateTime birthDate) {
    final inPct = _toPercentage(getValueOnDate(38, selectedDate, birthDate));
    final aePct = _toPercentage(getValueOnDate(43, selectedDate, birthDate));
    final awPct = _toPercentage(getValueOnDate(48, selectedDate, birthDate));
    final spPct = _toPercentage(getValueOnDate(53, selectedDate, birthDate));

    String advice(String base, int pct) => pct > 65
        ? s.t('$base.high')
        : pct < 40
            ? s.t('$base.low')
            : s.t('$base.mid');

    return Column(
      children: [
        _buildMetricTile(s.t('intuition'), s.cycleDays(38), inPct, advice('extend.intuition', inPct),
            AppWidget.intuitionGradient, Icons.remove_red_eye_rounded),
        const SizedBox(height: 12),
        _buildMetricTile(s.t('aesthetic'), s.cycleDays(43), aePct, advice('extend.aesthetic', aePct),
            AppWidget.aestheticGradient, Icons.palette_rounded),
        const SizedBox(height: 12),
        _buildMetricTile(s.t('awareness'), s.cycleDays(48), awPct, advice('extend.awareness', awPct),
            AppWidget.awarenessGradient, Icons.center_focus_strong_rounded),
        const SizedBox(height: 12),
        _buildMetricTile(s.t('spiritual'), s.cycleDays(53), spPct, advice('extend.spiritual', spPct),
            AppWidget.spiritualGradient, Icons.self_improvement_rounded),
      ],
    );
  }

  Widget _buildMetricTile(String title, String subtitle, int percent, String advice,
      List<Color> gradient, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: AppWidget.glassDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(colors: gradient).createShader(bounds),
                    child: Icon(icon, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: TextStyle(
                              color: AppWidget.primaryText,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'BeVietnamPro')),
                      Text(subtitle,
                          style: TextStyle(color: AppWidget.mutedText, fontSize: 11, fontFamily: 'BeVietnamPro')),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: gradient),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text("$percent%",
                    style: const TextStyle(
                        color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold, fontFamily: 'BeVietnamPro')),
              )
            ],
          ),
          const SizedBox(height: 12),
          Text(advice, style: TextStyle(color: AppWidget.secondaryText, fontSize: 13, height: 1.35)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final provider = context.watch<BirthDateProvider>();
    final birthDate = provider.birthDate;
    final showBackToToday = selectedDate != today;

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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(s.t('extend.title'),
                              style: AppWidget.HeadlineTextFeildStyle().copyWith(fontSize: 22)),
                          Text(s.date(DateFormat('dd/MM/yyyy').format(selectedDate)),
                              style: AppWidget.LightTextFeildStyle()),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        if (showBackToToday)
                          IconButton(
                            icon: const Icon(Icons.today_rounded, color: _kAccent),
                            onPressed: _resetToToday,
                            tooltip: s.t('backToToday'),
                          ),
                        if (birthDate != null)
                          IconButton(
                            icon: Icon(Icons.calendar_month_rounded, color: AppWidget.secondaryText),
                            onPressed: () => _pickDate(context, birthDate),
                          ),
                        IconButton(
                          icon: Icon(Icons.info_outline_rounded, color: AppWidget.secondaryText),
                          tooltip: s.t('info.title'),
                          onPressed: () => showMetricsInfo(context, 'extended'),
                        ),
                      ],
                    ),
                  ],
                ),
                if (birthDate == null)
                  Expanded(
                    child: Center(
                      child: Text(s.t('needBirthdate'),
                          style: TextStyle(color: AppWidget.mutedText)),
                    ),
                  )
                else ...[
                  const SizedBox(height: 12),
                  buildHorizontalTimeline(),
                  const SizedBox(height: 4),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.only(bottom: 110),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          buildOverallSummary(
                            s,
                            getValueOnDate(38, selectedDate, birthDate),
                            getValueOnDate(43, selectedDate, birthDate),
                            getValueOnDate(48, selectedDate, birthDate),
                            getValueOnDate(53, selectedDate, birthDate),
                          ),
                          const SizedBox(height: 16),
                          buildAiCoach(s, birthDate, provider.name),
                          const SizedBox(height: 16),
                          Text(s.t('extend.chartTitle'), style: AppWidget.semiBoldTextFeildStyle()),
                          const SizedBox(height: 8),
                          buildChart(s, birthDate),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(s.t('extend.detailTitle'), style: AppWidget.semiBoldTextFeildStyle()),
                              IconButton(
                                icon: Icon(Icons.info_outline_rounded, color: AppWidget.secondaryText, size: 20),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                tooltip: s.t('info.title'),
                                onPressed: () => showMetricsInfo(context, 'extended'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          buildCycleCards(s, birthDate),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
