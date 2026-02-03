import 'dart:convert';

import 'package:beariscope_scouter/custom_widgets/match_page.dart';
import 'package:beariscope_scouter/data/local_data.dart';
import 'package:beariscope_scouter/pages/match.dart';
import 'package:hive_ce_flutter/adapters.dart';

typedef MatchIdentity = ({String eventKey, int matchNumber, bool isRedAlliance, int position, int robotNum});

String matchDataKey(MatchIdentity identity, String sectionId, String fieldId) {
  return "MATCH_${identity.eventKey}_${identity.matchNumber}_${identity.isRedAlliance}_${identity.position}_${sectionId}_$fieldId";
}

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

  SectionJsonData({
    required this.sectionId,
    required this.fields,
  });

  factory SectionJsonData.fromJson(Map<String, dynamic> json) {
    return SectionJsonData(
      sectionId: json['sectionId'],
      fields: Map<String, dynamic>.from(json['fields'] ?? {})
    );
  }

  Map<String, dynamic> toJson() => {
    'sectionId': sectionId,
    'fields': fields,
  };
}

class MetaJsonData {
  final int season;
  final String author;
  final int version;
  final String type;

  MetaJsonData({
    required this.season,
    required this.author,
    required this.version,
    required this.type,
  });

  factory MetaJsonData.fromJson(Map<String, dynamic> json) {
    return MetaJsonData(
      season: json['season'],
      author: json['author'],
      version: json['version'],
      type: json['type'],
    );
  }

  Map<String, dynamic> toJson() => {
    'season': season,
    'author': author,
    'version': version,
    'type': type,
  };
}

class MatchJsonData {
  final MetaJsonData meta;
  final List<SectionJsonData> sections;

  MatchJsonData({required this.meta, required this.sections});

  factory MatchJsonData.fromJson(Map<String, dynamic> json) {
    return MatchJsonData(
      meta: MetaJsonData.fromJson(json['meta']),
      sections: (json['sections'] as List)
          .map((e) => SectionJsonData.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'meta': meta.toJson(),
    'sections': sections.map((e) => e.toJson()).toList(),
  };
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

MetaJsonData generateMetaJsonHive(Meta config) => 
  MetaJsonData(
    season: config.season,
    author: config.author,
    type: config.type,
    version: config.version,
  );


/// Uses the MatchConfig, and looks up hive data for necessary values.
MatchJsonData generateMatchJsonHive(MatchConfig config, MatchIdentity info) => 
  MatchJsonData(
    meta: generateMetaJsonHive(config.meta),
    sections: config.pages.map((e) => generateSectionJsonHive(e, info)).toList(),
  );


/// Loads the MatchJsonData into the appropriate hive keys using eventKey.
void loadMatchJsonToHive(MatchJsonData data, MatchIdentity info) {
  Box dataBox = Hive.box(boxKey);

  for (final section in data.sections) {
    section.fields.forEach((k, v) =>
      dataBox.put(matchDataKey(info, section.sectionId, k), v));
  }
}