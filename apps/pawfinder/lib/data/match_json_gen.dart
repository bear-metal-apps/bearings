import 'dart:convert';

import 'package:beariscope_scouter/data/local_data.dart';
import 'package:beariscope_scouter/data/ui_json_serialization.dart';
import 'package:beariscope_scouter/models/scouting_session.dart';
import 'package:hive_ce_flutter/adapters.dart';

typedef MatchIdentity = ({
  ScoutingEvent event,
  int matchNumber,
  ScoutPosition postion,
  Scout scout,
});

String identityDataKey(MatchIdentity identity) {
  return "MATCH_${identity.event.key}_${identity.matchNumber}_${identity.postion.name}_${identity.scout.name}";
}

String matchDataKey(MatchIdentity identity, String sectionId, String fieldId) {
  return "${identityDataKey(identity)}_${sectionId}_$fieldId";
}

String matchTeamKey(MatchIdentity identity) =>
    '${identityDataKey(identity)}_team';

/*
class FieldJsonData {
  final String fieldId;
  final String displayName;
  final String dataType;
  final Map<String, dynamic> parameters;

  FieldJsonData({
    required this.fieldId,
    required this.displayName,
    required this.dataType,
    required this.parameters,
  });

  factory FieldJsonData.fromJson(Map<String, dynamic> json) {
    return FieldJsonData(
      fieldId: json['fieldId'],
      displayName: json['displayName'],
      dataType: json['dataType'],
      parameters: Map<String, dynamic>.from(json['parameters'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() => {
    'fieldId': fieldId,
    'displayName': displayName,
    'dataType': dataType,
    'parameters': parameters,
  };
}
*/

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

/// Uses the PageConfig, and looks up hive data for necessary values.
SectionJsonData generateSectionJsonHive(PageConfig config, MatchIdentity info) {
  SectionJsonData sectionJsonData = SectionJsonData(
    sectionId: config.sectionId,
    fields: {},
  );

  Box dataBox = Hive.box(boxKey);

  for (var data in config.components) {
    // retrieve the hive data
    final dataBoxKey = matchDataKey(info, config.sectionId, data.fieldId);

    final dynamic dataValue = dataBox.get(dataBoxKey) ?? 0;
    sectionJsonData.fields[data.fieldId] = dataValue;
  }

  return sectionJsonData;
}

MetaJsonData generateMetaJsonHive(Meta config, MatchIdentity info) =>
    MetaJsonData(
      season: config.season,
      type: config.type,
      version: config.version,
      event: info.event.key,
      scoutedBy: info.scout.name,
    );

/// Uses the MatchConfig, and looks up hive data for necessary values.
MatchJsonData generateMatchJsonHive(MatchConfig config, MatchIdentity info) {
  final box = Hive.box(boxKey);
  final rawTeam = box.get(matchTeamKey(info));
  final teamNumber = rawTeam is int ? rawTeam : null;

  return MatchJsonData(
    meta: generateMetaJsonHive(config.meta, info),
    teamNumber: teamNumber,
    matchNumber: info.matchNumber,
    pos: info.postion.posIndex,
    sections: config.pages
        .map((e) => generateSectionJsonHive(e, info))
        .toList(),
  );
}

/// Loads the MatchJsonData into the appropriate hive keys using MatchIdentity.
void loadMatchJsonToHive(MatchJsonData data, MatchIdentity info) {
  Box dataBox = Hive.box(boxKey);

  for (final section in data.sections) {
    section.fields.forEach(
      (k, v) => dataBox.put(matchDataKey(info, section.sectionId, k), v),
    );
  }
}

/// Saves the MatchJsonData to Hive.
void insertMatchJsonToHive(MatchJsonData data, MatchIdentity info) {
  Box dataBox = Hive.box(boxKey);

  dataBox.put("${identityDataKey(info)}_JSON", jsonEncode(data.toJson()));
}

MatchJsonData? getMatchJsonFromHive(MatchIdentity info) {
  Box dataBox = Hive.box(boxKey);

  String? jsonRaw = dataBox.get("${identityDataKey(info)}_JSON");
  if (jsonRaw == null) {
    return null;
  }

  Map<String, dynamic> json = jsonDecode(jsonRaw);
  return MatchJsonData.fromJson(json);
}
