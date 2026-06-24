import 'package:flutter/material.dart';

import '../services/app_localizations.dart';
import 'widget_support.dart';

class _CycleInfo {
  final IconData icon;
  final String nameKey;
  final String descKey;
  final int days;
  final List<Color> gradient;
  const _CycleInfo(this.icon, this.nameKey, this.descKey, this.days, this.gradient);
}

const List<_CycleInfo> _core = [
  _CycleInfo(Icons.fitness_center_rounded, 'physical', 'info.physical.desc', 23, AppWidget.physicalGradient),
  _CycleInfo(Icons.favorite_rounded, 'emotional', 'info.emotional.desc', 28, AppWidget.emotionalGradient),
  _CycleInfo(Icons.psychology_rounded, 'intellectual', 'info.intellectual.desc', 33, AppWidget.intellectualGradient),
];

const List<_CycleInfo> _extended = [
  _CycleInfo(Icons.remove_red_eye_rounded, 'intuition', 'info.intuition.desc', 38, AppWidget.intuitionGradient),
  _CycleInfo(Icons.palette_rounded, 'aesthetic', 'info.aesthetic.desc', 43, AppWidget.aestheticGradient),
  _CycleInfo(Icons.center_focus_strong_rounded, 'awareness', 'info.awareness.desc', 48, AppWidget.awarenessGradient),
  _CycleInfo(Icons.self_improvement_rounded, 'spiritual', 'info.spiritual.desc', 53, AppWidget.spiritualGradient),
];

/// Hiển thị hộp giải thích ý nghĩa các chỉ số.
/// scope: 'core' | 'extended' | 'all'
void showMetricsInfo(BuildContext context, String scope) {
  final s = AppStrings.read(context);
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) {
      return Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        decoration: BoxDecoration(
          color: AppWidget.isDark ? AppWidget.darkBgEnd : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: Border.all(color: AppWidget.cardBorderColor),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppWidget.mutedText,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.info_outline_rounded, color: Color(0xFF2575FC)),
                  const SizedBox(width: 10),
                  Text(s.t('info.title'),
                      style: AppWidget.HeadlineTextFeildStyle().copyWith(fontSize: 20)),
                ],
              ),
              const SizedBox(height: 12),
              Text(s.t('info.scale'),
                  style: TextStyle(color: AppWidget.secondaryText, fontSize: 13.5, height: 1.45)),
              const SizedBox(height: 20),
              if (scope == 'core' || scope == 'all') ...[
                Text(s.t('info.coreTitle'), style: AppWidget.semiBoldTextFeildStyle()),
                const SizedBox(height: 10),
                ..._core.map((c) => _row(s, c)),
              ],
              if (scope == 'extended' || scope == 'all') ...[
                if (scope == 'all') const SizedBox(height: 18),
                Text(s.t('info.extendedTitle'), style: AppWidget.semiBoldTextFeildStyle()),
                const SizedBox(height: 10),
                ..._extended.map((c) => _row(s, c)),
              ],
              const SizedBox(height: 16),
              Text(s.t('info.note'),
                  style: TextStyle(
                      color: AppWidget.mutedText,
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      height: 1.4)),
              const SizedBox(height: 24),
              const Divider(color: Colors.white24, height: 1),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppWidget.isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.03),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppWidget.cardBorderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.menu_book_rounded, color: AppWidget.secondaryText, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            s.t('info.detailIntroTitle'),
                            style: TextStyle(
                              color: AppWidget.primaryText,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      s.t('info.detailIntroBody'),
                      style: TextStyle(
                        color: AppWidget.secondaryText,
                        fontSize: 13,
                        height: 1.55,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

Widget _row(AppStrings s, _CycleInfo c) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: c.gradient),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(c.icon, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${s.t(c.nameKey)} · ${s.cycleDays(c.days)}',
                  style: TextStyle(
                      color: AppWidget.primaryText,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins')),
              const SizedBox(height: 2),
              Text(s.t(c.descKey),
                  style: TextStyle(color: AppWidget.secondaryText, fontSize: 13, height: 1.35)),
            ],
          ),
        ),
      ],
    ),
  );
}
