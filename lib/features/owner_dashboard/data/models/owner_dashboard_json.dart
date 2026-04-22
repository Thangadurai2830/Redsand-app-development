Map<String, dynamic> normalizeMap(Object? value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) {
    return value.map((key, value) => MapEntry(key.toString(), value));
  }
  return <String, dynamic>{};
}

Map<String, dynamic> unwrapObject(Map<String, dynamic> json) {
  final candidates = [json, normalizeMap(json['data']), normalizeMap(json['result'])];
  for (final candidate in candidates) {
    if (candidate.isNotEmpty) return candidate;
  }
  return json;
}

List<Map<String, dynamic>> unwrapList(Map<String, dynamic> json) {
  final sources = [
    json['data'],
    json['listings'],
    json['interests'],
    json['items'],
    json['results'],
  ];
  for (final source in sources) {
    if (source is List) {
      return source.whereType<Map>().map(normalizeMap).toList(growable: false);
    }
    if (source is Map<String, dynamic>) {
      final nested = source['items'] ?? source['results'] ?? source['data'];
      if (nested is List) {
        return nested.whereType<Map>().map(normalizeMap).toList(growable: false);
      }
    }
  }
  return const [];
}

String stringValue(
  Map<String, dynamic> json,
  List<String> keys, {
  String fallback = '',
}) {
  for (final key in keys) {
    final value = json[key];
    if (value is String && value.trim().isNotEmpty) {
      return value.trim();
    }
    if (value != null && value.toString().trim().isNotEmpty) {
      return value.toString().trim();
    }
  }
  return fallback;
}

String? nullableStringValue(Map<String, dynamic> json, List<String> keys) {
  final value = stringValue(json, keys);
  return value.isEmpty ? null : value;
}

int intValue(
  Map<String, dynamic> json,
  List<String> keys, {
  int fallback = 0,
}) {
  for (final key in keys) {
    final value = json[key];
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) {
      final parsed = int.tryParse(value.trim());
      if (parsed != null) return parsed;
    }
  }
  return fallback;
}

double doubleValue(
  Map<String, dynamic> json,
  List<String> keys, {
  double fallback = 0,
}) {
  for (final key in keys) {
    final value = json[key];
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) {
      final parsed = double.tryParse(value.trim());
      if (parsed != null) return parsed;
    }
  }
  return fallback;
}

bool boolValue(
  Map<String, dynamic> json,
  List<String> keys, {
  bool fallback = false,
}) {
  for (final key in keys) {
    final value = json[key];
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      if (normalized == 'true' || normalized == 'yes' || normalized == '1') {
        return true;
      }
      if (normalized == 'false' || normalized == 'no' || normalized == '0') {
        return false;
      }
    }
  }
  return fallback;
}

DateTime? dateTimeValue(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is String && value.trim().isNotEmpty) {
      return DateTime.tryParse(value.trim());
    }
  }
  return null;
}

