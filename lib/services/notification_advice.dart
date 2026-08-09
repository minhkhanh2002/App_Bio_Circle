/// Tóm tắt 3 chỉ số (thể chất/cảm xúc/trí tuệ) thành MỘT câu duy nhất cho
/// nội dung thông báo đẩy — không dùng icon trang trí vô nghĩa, chỉ giữ ⚠️
/// khi có chỉ số ở mức báo động đỏ vì icon đó mang thông tin thật sự.
class NotificationAdvice {
  /// Dưới ngưỡng này coi là "báo động đỏ" — thấp hơn hẳn mức "low" (40)
  /// thường dùng để hiển thị trong app, chỉ dành riêng cho cảnh báo nổi bật.
  static const int _redAlertThreshold = 20;

  static const List<String> _order = ['physical', 'emotional', 'intellectual'];

  static const Map<String, String> _labelVi = {
    'physical': 'Thể lực',
    'emotional': 'Tâm trạng',
    'intellectual': 'Đầu óc',
  };
  static const Map<String, String> _labelEn = {
    'physical': 'Physical energy',
    'emotional': 'Mood',
    'intellectual': 'Mental focus',
  };

  static String summarize({
    required String locale,
    required Map<String, int> metrics,
    required int seed,
  }) {
    final clauses = locale == 'en' ? _clausesEn : _clausesVi;
    final labels = locale == 'en' ? _labelEn : _labelVi;

    final parts = <String>[];
    String? redAlertCycle;
    for (var i = 0; i < _order.length; i++) {
      final cycle = _order[i];
      final value = metrics[cycle] ?? 50;
      if (value < _redAlertThreshold && redAlertCycle == null) {
        redAlertCycle = cycle;
      }
      final variants = clauses[cycle]![_level(value)]!;
      parts.add(variants[(seed + i) % variants.length]);
    }

    final joiner = locale == 'en' ? ', ' : ', ';
    final and = locale == 'en' ? 'and' : 'và';
    final today = locale == 'en' ? 'today' : 'hôm nay';
    final body = parts.length == 3
        ? '${parts[0]}$joiner${parts[1]} $and ${parts[2]} $today'
        : parts.join(joiner);
    final sentence = '${body[0].toUpperCase()}${body.substring(1)}.';

    if (redAlertCycle == null) {
      return sentence;
    }

    final label = labels[redAlertCycle]!;
    final tail = locale == 'en'
        ? ' — please rest, $label is critically low right now!'
        : ' — hãy nghỉ ngơi ngay, $label đang ở mức báo động đỏ nhé!';
    return '⚠️ ${sentence.substring(0, sentence.length - 1)}$tail';
  }

  static String _level(int pct) => pct > 65 ? 'high' : (pct < 40 ? 'low' : 'mid');

  static const Map<String, Map<String, List<String>>> _clausesVi = {
    'physical': {
      'high': ['thể lực đang lên đỉnh', 'cơ thể tràn năng lượng', 'sức bền đang rất tốt'],
      'mid': ['thể trạng ổn định', 'sức khỏe cân bằng', 'cơ thể bình thường'],
      'low': ['năng lượng hơi xuống', 'cơ thể cần nghỉ ngơi', 'sức lực hơi đuối'],
    },
    'emotional': {
      'high': ['tâm trạng rất tích cực', 'cảm xúc thăng hoa', 'tinh thần phơi phới'],
      'mid': ['cảm xúc cân bằng', 'tâm trí nhẹ nhàng', 'lòng khá bình ổn'],
      'low': ['cảm xúc hơi nhạy cảm', 'tâm trạng hơi chùng', 'dễ xúc động hơn thường ngày'],
    },
    'intellectual': {
      'high': ['đầu óc rất sắc bén', 'tư duy minh mẫn', 'khả năng tập trung cao'],
      'mid': ['trí lực ổn định', 'đầu óc tỉnh táo vừa phải', 'tư duy bình thường'],
      'low': ['khó tập trung hơn', 'đầu óc hơi chậm', 'trí óc cần nghỉ ngơi'],
    },
  };

  static const Map<String, Map<String, List<String>>> _clausesEn = {
    'physical': {
      'high': ['physical energy is peaking', 'the body feels full of energy', 'stamina is strong'],
      'mid': ['physical condition is steady', 'health feels balanced', 'the body feels normal'],
      'low': ['energy is a bit low', 'the body needs rest', 'stamina feels a little drained'],
    },
    'emotional': {
      'high': ['mood is very positive', 'emotions are soaring', 'spirits are high'],
      'mid': ['emotions are balanced', 'the mind feels calm', 'spirits are fairly steady'],
      'low': ['emotions feel a bit sensitive', 'mood is a little low', 'feelings run deeper than usual'],
    },
    'intellectual': {
      'high': ['the mind is razor-sharp', 'thinking is very clear', 'focus is high'],
      'mid': ['mental power is steady', 'the mind is fairly clear', 'thinking feels normal'],
      'low': ['focus is harder than usual', 'the mind feels a bit slow', 'the brain needs rest'],
    },
  };
}
