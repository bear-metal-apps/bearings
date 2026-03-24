import 'package:uuid/uuid.dart';

class MatchFormData {
  const MatchFormData({
    required this.id,
    required this.eventKey,
    required this.matchNumber,
    required this.pos,
    required this.season,
    required this.configVersion,
    this.teamNumber,
    this.scoutedBy,
    required this.lastModified,
    required this.sections,
  });

  final String id;
  final String eventKey;
  final int matchNumber;
  final int pos;
  final int season;
  final int configVersion;
  final int? teamNumber;
  final String? scoutedBy;
  final DateTime lastModified;
  final Map<String, Map<String, dynamic>> sections;

  factory MatchFormData.blank({
    required String eventKey,
    required int matchNumber,
    required int pos,
    required int season,
    required int configVersion,
    int? teamNumber,
    String? scoutedBy,
  }) {
    return MatchFormData(
      id: const Uuid().v4(),
      eventKey: eventKey,
      matchNumber: matchNumber,
      pos: pos,
      season: season,
      configVersion: configVersion,
      teamNumber: teamNumber,
      scoutedBy: scoutedBy,
      lastModified: DateTime.now().toUtc(),
      sections: const {},
    );
  }

  dynamic getField(String sectionId, String fieldId) {
    return sections[sectionId]?[fieldId];
  }

  MatchFormData copyWithField(String sectionId, String fieldId, dynamic value) {
    final updatedSection = Map<String, dynamic>.from(
      sections[sectionId] ?? const {},
    )..[fieldId] = value;

    final updatedSections = Map<String, Map<String, dynamic>>.from(sections)
      ..[sectionId] = updatedSection;

    return copyWith(
      sections: updatedSections,
      lastModified: DateTime.now().toUtc(),
    );
  }

  MatchFormData copyWith({
    String? id,
    String? eventKey,
    int? matchNumber,
    int? pos,
    int? season,
    int? configVersion,
    Object? teamNumber = _noChange,
    Object? scoutedBy = _noChange,
    DateTime? lastModified,
    Map<String, Map<String, dynamic>>? sections,
  }) {
    return MatchFormData(
      id: id ?? this.id,
      eventKey: eventKey ?? this.eventKey,
      matchNumber: matchNumber ?? this.matchNumber,
      pos: pos ?? this.pos,
      season: season ?? this.season,
      configVersion: configVersion ?? this.configVersion,
      teamNumber: identical(teamNumber, _noChange)
          ? this.teamNumber
          : teamNumber as int?,
      scoutedBy: identical(scoutedBy, _noChange)
          ? this.scoutedBy
          : scoutedBy as String?,
      lastModified: (lastModified ?? this.lastModified).toUtc(),
      sections: sections != null
          ? _copySections(sections)
          : _copySections(this.sections),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'meta': {
        'season': season,
        'version': configVersion,
        'type': 'match',
        'event': eventKey,
        'scoutedBy': scoutedBy,
      },
      'matchNumber': matchNumber,
      'pos': pos,
      'sections': _sectionsToJson(sections),
      if (teamNumber != null) 'teamNumber': teamNumber,
    };
  }

  Map<String, dynamic> toStoredJson() {
    return {
      'id': id,
      'lastModified': lastModified.toUtc().toIso8601String(),
      'payload': toJson(),
    };
  }

  factory MatchFormData.fromJson(Map<String, dynamic> json) {
    final wrapped = json['payload'];
    if (wrapped is Map) {
      return _fromPayload(
        Map<String, dynamic>.from(wrapped),
        id: json['id']?.toString(),
        lastModified: _asDateTime(json['lastModified']),
      );
    }

    return _fromPayload(
      json,
      id: json['_id']?.toString() ?? json['id']?.toString(),
      lastModified: _asDateTime(json['lastModified']),
    );
  }

  static MatchFormData _fromPayload(
    Map<String, dynamic> json, {
    String? id,
    DateTime? lastModified,
  }) {
    final meta = json['meta'];
    final legacySections = json['sections'];

    if (meta is Map) {
      return MatchFormData(
        id: id ?? json['_id']?.toString() ?? const Uuid().v4(),
        eventKey: meta['event']?.toString() ?? '',
        matchNumber: _asInt(json['matchNumber']) ?? 0,
        pos: _asInt(json['pos']) ?? 0,
        season: _asInt(meta['season']) ?? 0,
        configVersion: _asInt(meta['version']) ?? 0,
        teamNumber: _asInt(json['teamNumber']),
        scoutedBy: meta['scoutedBy']?.toString(),
        lastModified: lastModified ?? DateTime.now().toUtc(),
        sections: _sectionsFromJson(legacySections),
      );
    }

    return MatchFormData(
      id: id ?? json['_id']?.toString() ?? const Uuid().v4(),
      eventKey: json['eventKey']?.toString() ?? '',
      matchNumber: _asInt(json['matchNumber']) ?? 0,
      pos: _asInt(json['pos']) ?? 0,
      season: _asInt(json['season']) ?? 0,
      configVersion: _asInt(json['configVersion']) ?? 0,
      teamNumber: _asInt(json['teamNumber']),
      scoutedBy: json['scoutedBy']?.toString(),
      lastModified:
          lastModified ??
          _asDateTime(json['lastModified']) ??
          DateTime.now().toUtc(),
      sections: _sectionsFromJson(legacySections),
    );
  }
}

const Object _noChange = Object();

Map<String, Map<String, dynamic>> _copySections(
  Map<String, Map<String, dynamic>> source,
) {
  return source.map(
    (sectionId, fields) =>
        MapEntry(sectionId, Map<String, dynamic>.from(fields)),
  );
}

Map<String, Map<String, dynamic>> _sectionsFromJson(dynamic value) {
  if (value is Map) {
    final result = <String, Map<String, dynamic>>{};
    value.forEach((key, sectionValue) {
      if (sectionValue is Map) {
        result[key.toString()] = sectionValue.map(
          (fieldId, fieldValue) => MapEntry(fieldId.toString(), fieldValue),
        );
      }
    });
    return result;
  }

  if (value is List) {
    final result = <String, Map<String, dynamic>>{};
    for (final sectionValue in value) {
      if (sectionValue is! Map) continue;
      final sectionId = sectionValue['sectionId']?.toString() ?? '';
      final fields = sectionValue['fields'];
      if (sectionId.isEmpty || fields is! Map) continue;
      result[sectionId] = fields.map(
        (fieldId, fieldValue) => MapEntry(fieldId.toString(), fieldValue),
      );
    }
    return result;
  }

  return {};
}

List<dynamic> _sectionsToJson(Map<String, Map<String, dynamic>> sections) {
  return sections.entries
      .map((entry) => {'sectionId': entry.key, 'fields': entry.value})
      .toList();
}

int? _asInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}

DateTime? _asDateTime(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value.toUtc();
  return DateTime.tryParse(value.toString())?.toUtc();
}
