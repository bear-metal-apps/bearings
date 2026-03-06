import 'dart:convert';

import 'package:hive_ce_flutter/adapters.dart';
import 'package:pawfinder/data/local_data.dart';
import 'package:pawfinder/data/ui_json_serialization.dart';
import 'package:pawfinder/models/scouting_session.dart';

typedef MatchIdentity = ({
  ScoutingEvent event,
  int matchNumber,
  ScoutPosition position,
  Scout scout,
});

String identityDataKey(MatchIdentity identity) {
  return "MATCH_${identity.event.key}_${identity.matchNumber}_${identity.position.name}_${identity.scout.name}";
}

String matchDataKey(MatchIdentity identity, String sectionId, String fieldId) {
  return "${identityDataKey(identity)}_${sectionId}_$fieldId";
}

String matchTeamKey(MatchIdentity identity) =>
    '${identityDataKey(identity)}_team';

class SectionJsonData {
  final String sectionId;
  final Map<String, dynamic> fields;

  SectionJsonData({required this.sectionId, required this.fields});

  factory SectionJsonData.fromJson(Map<String, dynamic> json) {
    return SectionJsonData(
      sectionId: json['sectionId'],
      fields: Map<String, dynamic>.from(json['fields'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() => {'sectionId': sectionId, 'fields': fields};
}

class MetaJsonData {
  final int season;
  final int version;
  final String type;
  final String event;
  final String scoutedBy;

  MetaJsonData({
    required this.season,
    required this.version,
    required this.type,
    required this.event,
    required this.scoutedBy,
  });

  factory MetaJsonData.fromJson(Map<String, dynamic> json) {
    return MetaJsonData(
      season: json['season'],
      version: json['version'],
      type: json['type'],
      event: json['event']?.toString() ?? '',
      scoutedBy: json['scoutedBy']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'season': season,
    'version': version,
    'type': type,
    'event': event,
    'scoutedBy': scoutedBy,
  };
}

class MatchJsonData {
  final MetaJsonData meta;
  final int? teamNumber;
  final int matchNumber;
  final int pos;
  final List<SectionJsonData> sections;

  MatchJsonData({
    required this.meta,
    required this.matchNumber,
    required this.pos,
    required this.sections,
    this.teamNumber,
  });

  factory MatchJsonData.fromJson(Map<String, dynamic> json) {
    return MatchJsonData(
      meta: MetaJsonData.fromJson(json['meta']),
      teamNumber: json['teamNumber'] as int?,
      matchNumber: (json['matchNumber'] as int?) ?? 0,
      pos: (json['pos'] as int?) ?? 0,
      sections: (json['sections'] as List)
          .map((e) => SectionJsonData.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'meta': meta.toJson(),
      'matchNumber': matchNumber,
      'pos': pos,
      'sections': sections.map((e) => e.toJson()).toList(),
    };
    if (teamNumber != null) map['teamNumber'] = teamNumber;
    return map;
  }
}

// reads each field value out of hive
SectionJsonData generateSectionJsonHive(PageConfig config, MatchIdentity info) {
  final section = SectionJsonData(sectionId: config.sectionId, fields: {});
  final box = Hive.box(boxKey);

  for (final data in config.components) {
    final key = matchDataKey(info, config.sectionId, data.fieldId);
    section.fields[data.fieldId] = box.get(key) ?? 0;
  }

  return section;
}

MetaJsonData generateMetaJsonHive(Meta config, MatchIdentity info) =>
    MetaJsonData(
      season: config.season,
      type: config.type,
      version: config.version,
      event: info.event.key,
      scoutedBy: info.scout.name,
    );

// assembles the full match json from hive for upload
MatchJsonData generateMatchJsonHive(MatchConfig config, MatchIdentity info) {
  final box = Hive.box(boxKey);
  final rawTeam = box.get(matchTeamKey(info));
  final teamNumber = rawTeam is int ? rawTeam : null;

  return MatchJsonData(
    meta: generateMetaJsonHive(config.meta, info),
    teamNumber: teamNumber,
    matchNumber: info.matchNumber,
    pos: info.position.posIndex,
    sections: config.pages
        .map((e) => generateSectionJsonHive(e, info))
        .toList(),
  );
}

// restores saved match json data back into hive (editing old matches)
void loadMatchJsonToHive(MatchJsonData data, MatchIdentity info) {
  final dataBox = Hive.box(boxKey);

  for (final section in data.sections) {
    section.fields.forEach(
      (k, v) => dataBox.put(matchDataKey(info, section.sectionId, k), v),
    );
  }
}

// saves the full match json snapshot under the identity key
void insertMatchJsonToHive(MatchJsonData data, MatchIdentity info) {
  Hive.box(
    boxKey,
  ).put("${identityDataKey(info)}_JSON", jsonEncode(data.toJson()));
}

MatchJsonData? getMatchJsonFromHive(MatchIdentity info) {
  final jsonRaw =
      Hive.box(boxKey).get("${identityDataKey(info)}_JSON") as String?;
  if (jsonRaw == null) return null;
  return MatchJsonData.fromJson(jsonDecode(jsonRaw));
}
