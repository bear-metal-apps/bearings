import 'dart:convert';

import 'package:beariscope/models/match_field_ids.dart';
import 'package:flutter/services.dart' show rootBundle;

class ExportColumn {
  final String sectionId;
  final String sectionTitle;
  final String fieldId;
  final String alias;
  final String type;

  const ExportColumn({
    required this.sectionId,
    required this.sectionTitle,
    required this.fieldId,
    required this.alias,
    required this.type,
  });

  String get columnHeader => '$sectionTitle $alias';

  bool get isNotesField => sectionId == kSectionEndgame && fieldId == kEndNotes;

  bool get isAutoFuelScored =>
      sectionId == kSectionAuto && fieldId == kAutoFuelScored;

  bool get isTeleFuelScored =>
      sectionId == kSectionTele && fieldId == kTeleFuelScored;
}

class UiCreatorSchema {
  final List<ExportColumn> columns;

  const UiCreatorSchema({required this.columns});

  static const _assetPath = 'packages/ui/assets/forms/ui_creator.json';

  static Future<UiCreatorSchema> load() async {
    final raw = await rootBundle.loadString(_assetPath);
    final json = jsonDecode(raw) as Map<String, dynamic>;
    final pages = json['pages'];
    if (pages is! List) {
      throw StateError('ui_creator.json is missing pages');
    }

    final columns = <ExportColumn>[];
    for (final page in pages) {
      if (page is! Map) continue;
      final sectionId = page['sectionId']?.toString() ?? '';
      final sectionTitle = page['title']?.toString() ?? sectionId;
      final components = page['components'];
      if (components is! List) continue;

      for (final component in components) {
        if (component is! Map) continue;
        final fieldId = component['fieldId']?.toString() ?? '';
        if (fieldId.isEmpty) continue;
        columns.add(
          ExportColumn(
            sectionId: sectionId,
            sectionTitle: sectionTitle,
            fieldId: fieldId,
            alias: component['alias']?.toString() ?? fieldId,
            type: component['type']?.toString() ?? '',
          ),
        );
      }
    }

    return UiCreatorSchema(columns: columns);
  }
}
