import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum FeedbackResult { sent, queued }

/// Ghi lại góp ý của người dùng vào Firebase Firestore, có hàng đợi offline.
///
/// Nguyên tắc:
/// - Ẩn danh mặc định (chỉ kèm ID thiết bị ngẫu nhiên, không gửi tên/ngày sinh).
/// - Email tùy chọn (opt-in) để phản hồi lại.
/// - `createdAt` do máy chủ đặt (serverTimestamp).
/// - Mỗi góp ý có `clientId` cố định; ghi bằng `doc(clientId).set()` nên gửi lại
///   nhiều lần cũng KHÔNG bị trùng (idempotent).
/// - Nếu mất mạng / chưa cấu hình Firebase: lưu vào hàng đợi local và tự gửi lại.
class FeedbackService {
  /// true khi Firebase đã khởi tạo thành công (set ở main()).
  static bool ready = false;

  static const _kAnonId = 'anonUserId';
  static const _kQueue = 'feedbackQueue';
  static const _writeTimeout = Duration(seconds: 8);

  // ---- Tiện ích ----
  Future<String> _anonUserId() async {
    final prefs = await SharedPreferences.getInstance();
    var id = prefs.getString(_kAnonId);
    if (id == null) {
      id = _randomId();
      await prefs.setString(_kAnonId, id);
    }
    return id;
  }

  String _randomId() {
    final r = Random();
    return List.generate(20, (_) => r.nextInt(16).toRadixString(16)).join();
  }

  String get _platform => kIsWeb ? 'web' : defaultTargetPlatform.name;

  Future<Map<String, dynamic>> _buildPayload({
    required String message,
    String? email,
    int? rating,
    String? category,
    required String locale,
  }) async {
    String appVersion = '';
    try {
      final info = await PackageInfo.fromPlatform();
      appVersion = '${info.version}+${info.buildNumber}';
    } catch (_) {}

    return {
      'clientId': _randomId(),
      'message': message.trim(),
      'email': (email != null && email.trim().isNotEmpty) ? email.trim() : null,
      'rating': rating,
      'category': category ?? 'other',
      'anonUserId': await _anonUserId(),
      'appVersion': appVersion,
      'platform': _platform,
      'locale': locale,
      'queuedAt': DateTime.now().toUtc().toIso8601String(),
    };
  }

  /// Ghi 1 bản ghi lên Firestore (idempotent theo clientId).
  Future<void> _write(Map<String, dynamic> payload) async {
    if (!ready) throw StateError('Firebase chưa được cấu hình.');
    final id = payload['clientId'] as String;
    final data = Map<String, dynamic>.from(payload)
      ..['status'] = 'new'
      ..['createdAt'] = FieldValue.serverTimestamp();
    await FirebaseFirestore.instance.collection('feedback').doc(id).set(data);
  }

  // ---- API chính ----
  Future<FeedbackResult> submit({
    required String message,
    String? email,
    int? rating,
    String? category,
    required String locale,
  }) async {
    final payload = await _buildPayload(
      message: message,
      email: email,
      rating: rating,
      category: category,
      locale: locale,
    );
    try {
      await _write(payload).timeout(_writeTimeout);
      // Gửi thành công thì tranh thủ đẩy nốt hàng đợi cũ.
      unawaited(flushQueue());
      return FeedbackResult.sent;
    } catch (_) {
      // Mất mạng / timeout / chưa cấu hình -> lưu hàng đợi để gửi lại sau.
      await _enqueue(payload);
      return FeedbackResult.queued;
    }
  }

  // ---- Hàng đợi offline ----
  Future<void> _enqueue(Map<String, dynamic> payload) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_kQueue) ?? [];
    list.add(jsonEncode(payload));
    await prefs.setStringList(_kQueue, list);
  }

  /// Thử gửi lại toàn bộ góp ý đang chờ. Mục nào gửi được thì xoá khỏi hàng đợi,
  /// mục nào lỗi thì giữ lại cho lần sau. An toàn để gọi nhiều lần.
  Future<void> flushQueue() async {
    if (!ready) return;
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_kQueue) ?? [];
    if (list.isEmpty) return;

    final remaining = <String>[];
    for (final item in list) {
      try {
        final payload = jsonDecode(item) as Map<String, dynamic>;
        await _write(payload).timeout(_writeTimeout);
      } catch (_) {
        remaining.add(item); // giữ lại để thử lần sau
      }
    }
    await prefs.setStringList(_kQueue, remaining);
  }

  Future<int> pendingCount() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_kQueue) ?? []).length;
  }
}
