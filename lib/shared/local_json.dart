import 'dart:convert';

import '../features/business/business_persistence_stub.dart'
    if (dart.library.js_interop) '../features/business/business_persistence_web.dart';

/// Small JSON-in-localStorage helpers for the feature stores.
///
/// Every store here keeps its own copy in the browser so the first frame is
/// right and the feature works without a network. A corrupt or missing entry
/// reads as empty rather than throwing: losing a draft goal is bad, a white
/// screen on launch is worse.
List<Map<String, dynamic>> readJsonList(String key) {
  final raw = readRaw(key);
  if (raw == null || raw.isEmpty) return const [];
  try {
    final decoded = jsonDecode(raw);
    if (decoded is! List) return const [];
    return decoded.whereType<Map<String, dynamic>>().toList();
  } catch (_) {
    return const [];
  }
}

Map<String, dynamic>? readJsonMap(String key) {
  final raw = readRaw(key);
  if (raw == null || raw.isEmpty) return null;
  try {
    final decoded = jsonDecode(raw);
    return decoded is Map<String, dynamic> ? decoded : null;
  } catch (_) {
    return null;
  }
}

void writeJson(String key, Object value) => writeRaw(key, jsonEncode(value));

DateTime? readDate(Object? v) => v is String ? DateTime.tryParse(v) : null;
