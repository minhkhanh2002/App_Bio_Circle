import 'dart:math';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Gọi Cloud Function "biorhythmAdvice" để lấy lời khuyên do Claude sinh ra.
/// Có cache trong phiên theo (scope + chỉ số + ngôn ngữ + phong cách).
class AdviceService {
  static final AdviceService _instance = AdviceService._internal();
  factory AdviceService() => _instance;
  AdviceService._internal();

  final Map<String, String> _cache = {};

  Future<String> _anonUserId() async {
    final prefs = await SharedPreferences.getInstance();
    var id = prefs.getString('anonUserId');
    if (id == null) {
      final r = Random();
      id = List.generate(20, (_) => r.nextInt(16).toRadixString(16)).join();
      await prefs.setString('anonUserId', id);
    }
    return id;
  }

  Future<String> getAdvice({
    required String scope, // 'core' | 'extended'
    required Map<String, int> metrics,
    required String locale,
    String? name,
    String style = 'friendly',
    String styleNote = '',
  }) async {
    final key =
        '$scope|$locale|$style|$styleNote|${metrics.entries.map((e) => '${e.key}:${e.value}').join(',')}';
    final cached = _cache[key];
    if (cached != null) return cached;

    final callable = FirebaseFunctions.instanceFor(region: 'us-central1')
        .httpsCallable('biorhythmAdvice');

    final result = await callable.call<Map<String, dynamic>>({
      'scope': scope,
      'locale': locale,
      'name': name,
      'style': style,
      'styleNote': styleNote,
      'anonUserId': await _anonUserId(),
      ...metrics,
    }).timeout(const Duration(seconds: 25));

    final advice = (result.data['advice'] as String?)?.trim() ?? '';
    if (advice.isEmpty) {
      throw Exception('empty advice');
    }
    _cache[key] = advice;
    return advice;
  }
}