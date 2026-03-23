import 'dart:convert';

import 'package:beariscope/models/pits_form_schema.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final pitsFormSchemaProvider = FutureProvider<PitsFormSchema>((ref) async {
  final rawJson = await rootBundle.loadString('assets/pits_form_schema.json');
  final decoded = jsonDecode(rawJson);

  if (decoded is! Map) {
    throw const FormatException('Pits form schema must be a JSON object.');
  }

  final schema = PitsFormSchema.fromJson(Map<String, dynamic>.from(decoded));
  final validationIssues = schema.validate();

  if (validationIssues.isNotEmpty) {
    throw FormatException(
      'Invalid pits form schema: ${validationIssues.join(' | ')}',
    );
  }

  return schema;
});
