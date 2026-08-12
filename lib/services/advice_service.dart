import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Lỗi từ Worker, code khớp với các mã cũ của FirebaseFunctionsException
/// (resource-exhausted, failed-precondition, invalid-argument, unavailable...)
/// để phần gọi (home.dart/extend.dart) xử lý y hệt logic trước đây.
class AdviceException implements Exception {
  final String code;
  final String message;
  AdviceException(this.code, this.message);

  @override
  String toString() => 'AdviceException($code): $message';
}

/// Gọi Cloudflare Worker "biorhythm-advice" để lấy lời khuyên do AI sinh ra.
///
/// Trước đây gọi qua Firebase Cloud Function, nhưng Cloud Functions gen2 bắt
/// buộc gói Blaze (trả phí) mới được gọi ra internet — project này kẹt ở gói
/// Spark (miễn phí, lỗi OR_ASMF_04 khi thêm thẻ để nâng cấp). Worker port lại
/// y hệt logic cũ (guardrails + giới hạn 1 lần/ngày), xem worker/src/index.ts.
///
/// Có cache trong phiên theo (scope + chỉ số + ngôn ngữ + phong cách).
class AdviceService {
  static final AdviceService _instance = AdviceService._internal();
  factory AdviceService() => _instance;
  AdviceService._internal();

  static const String _workerUrl = 'https://biorhythm-advice.ngomi-gbfs.workers.dev';

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

    final response = await http
        .post(
          Uri.parse(_workerUrl),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'scope': scope,
            'locale': locale,
            'name': name,
            'style': style,
            'styleNote': styleNote,
            'anonUserId': await _anonUserId(),
            ...metrics,
          }),
        )
        .timeout(const Duration(seconds: 25));

    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode >= 400) {
      throw AdviceException(
        (body['error'] as String?) ?? 'unavailable',
        (body['message'] as String?) ?? 'Unknown error',
      );
    }

    final advice = (body['advice'] as String?)?.trim() ?? '';
    if (advice.isEmpty) {
      throw Exception('empty advice');
    }
    _cache[key] = advice;
    return advice;
  }
}