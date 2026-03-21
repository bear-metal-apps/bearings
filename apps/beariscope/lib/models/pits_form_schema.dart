enum PitsFormFieldType {
  number,
  singleSelect,
  multiSelect,
  radio,
  slider,
  text,
  multilineText,
}

extension PitsFormFieldTypeX on PitsFormFieldType {
  String get jsonValue => switch (this) {
    PitsFormFieldType.number => 'number',
    PitsFormFieldType.singleSelect => 'single_select',
    PitsFormFieldType.multiSelect => 'multi_select',
    PitsFormFieldType.radio => 'radio',
    PitsFormFieldType.slider => 'slider',
    PitsFormFieldType.text => 'text',
    PitsFormFieldType.multilineText => 'multiline_text',
  };

  bool get requiresOptions => switch (this) {
    PitsFormFieldType.singleSelect ||
    PitsFormFieldType.multiSelect ||
    PitsFormFieldType.radio => true,
    _ => false,
  };

  static PitsFormFieldType fromJsonValue(String value) {
    return switch (value) {
      'number' => PitsFormFieldType.number,
      'single_select' => PitsFormFieldType.singleSelect,
      'multi_select' => PitsFormFieldType.multiSelect,
      'radio' => PitsFormFieldType.radio,
      'slider' => PitsFormFieldType.slider,
      'text' => PitsFormFieldType.text,
      'multiline_text' => PitsFormFieldType.multilineText,
      _ => throw FormatException('Unsupported pits field type: $value'),
    };
  }
}

class PitsFormSchema {
  final PitsFormMeta meta;
  final List<PitsFormSection> sections;

  const PitsFormSchema({required this.meta, required this.sections});

  factory PitsFormSchema.fromJson(Map<String, dynamic> json) {
    return PitsFormSchema(
      meta: PitsFormMeta.fromJson(_asMap(json['meta'], 'meta')),
      sections: _asList(
        json['sections'],
        'sections',
      ).map((raw) => PitsFormSection.fromJson(_asMap(raw, 'section'))).toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'meta': meta.toJson(),
    'sections': sections.map((section) => section.toJson()).toList(),
  };

  List<String> validate() {
    final issues = <String>[];
    final fieldIds = <String>{};

    for (final section in sections) {
      for (final field in section.fields) {
        if (!fieldIds.add(field.id)) {
          issues.add('Duplicate field id found: ${field.id}');
        }

        if (field.type.requiresOptions && field.options.isEmpty) {
          issues.add(
            'Field ${field.id} (${field.type.jsonValue}) requires at least one option.',
          );
        }

        if (field.defaultValue != null) {
          switch (field.type) {
            case PitsFormFieldType.singleSelect || PitsFormFieldType.radio:
              final defaultOption = field.defaultValue;
              if (defaultOption is! String) {
                issues.add('Field ${field.id} defaultValue must be a string.');
              } else if (!field.options.contains(defaultOption)) {
                issues.add(
                  'Field ${field.id} defaultValue must match an option.',
                );
              }

            case PitsFormFieldType.multiSelect:
              final defaultOptionSet = field.defaultValue;
              final selectedValues = switch (defaultOptionSet) {
                List() => defaultOptionSet,
                Set() => defaultOptionSet.toList(),
                _ => null,
              };

              if (selectedValues == null) {
                issues.add(
                  'Field ${field.id} defaultValue must be a list or set of strings.',
                );
              } else {
                final invalidType = selectedValues.any(
                  (value) => value is! String,
                );
                if (invalidType) {
                  issues.add(
                    'Field ${field.id} defaultValue must contain only strings.',
                  );
                } else {
                  final hasUnknownOption = selectedValues.any(
                    (value) => !field.options.contains(value),
                  );
                  if (hasUnknownOption) {
                    issues.add(
                      'Field ${field.id} defaultValue contains unknown option(s).',
                    );
                  }
                }
              }

            case PitsFormFieldType.number || PitsFormFieldType.slider:
              if (field.defaultValue is! num) {
                issues.add('Field ${field.id} defaultValue must be numeric.');
              }

            case PitsFormFieldType.text || PitsFormFieldType.multilineText:
              if (field.defaultValue is! String) {
                issues.add('Field ${field.id} defaultValue must be a string.');
              }
          }
        }

        if (field.type == PitsFormFieldType.slider) {
          final min = _asNumOrNull(field.params['min']);
          final max = _asNumOrNull(field.params['max']);
          if (min == null || max == null) {
            issues.add(
              'Slider field ${field.id} must define numeric min and max.',
            );
          } else if (min >= max) {
            issues.add('Slider field ${field.id} requires min < max.');
          } else {
            final defaultNumber = _asNumOrNull(field.defaultValue);
            if (defaultNumber != null &&
                (defaultNumber < min || defaultNumber > max)) {
              issues.add(
                'Slider field ${field.id} defaultValue must be within min/max.',
              );
            }
          }

          final divisions = _asNumOrNull(field.params['divisions']);
          if (divisions != null && divisions <= 0) {
            issues.add('Slider field ${field.id} requires divisions > 0.');
          }
        }
      }
    }

    return issues;
  }
}

class PitsFormMeta {
  final int season;
  final String author;
  final int version;
  final String type;

  const PitsFormMeta({
    required this.season,
    required this.author,
    required this.version,
    required this.type,
  });

  factory PitsFormMeta.fromJson(Map<String, dynamic> json) {
    return PitsFormMeta(
      season: _asInt(json['season'], 'meta.season'),
      author: _asString(json['author'], 'meta.author'),
      version: _asInt(json['version'], 'meta.version'),
      type: _asString(json['type'], 'meta.type'),
    );
  }

  Map<String, dynamic> toJson() => {
    'season': season,
    'author': author,
    'version': version,
    'type': type,
  };
}

class PitsFormSection {
  final String id;
  final String displayName;
  final List<PitsFormField> fields;

  const PitsFormSection({
    required this.id,
    required this.displayName,
    required this.fields,
  });

  factory PitsFormSection.fromJson(Map<String, dynamic> json) {
    return PitsFormSection(
      id: _asString(json['id'], 'section.id'),
      displayName: _asString(json['displayName'], 'section.displayName'),
      fields: _asList(
        json['fields'],
        'section.fields',
      ).map((raw) => PitsFormField.fromJson(_asMap(raw, 'field'))).toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'displayName': displayName,
    'fields': fields.map((field) => field.toJson()).toList(),
  };
}

class PitsFormField {
  final String id;
  final String displayName;
  final PitsFormFieldType type;
  final Map<String, dynamic> params;
  final Object? defaultValue;
  final bool? required;
  final String? storageKey;

  const PitsFormField({
    required this.id,
    required this.displayName,
    required this.type,
    required this.params,
    this.defaultValue,
    this.required,
    this.storageKey,
  });

  List<String> get options {
    final raw = params['options'];
    if (raw is! List) {
      return const [];
    }

    return raw.map((value) => value.toString()).toList();
  }

  factory PitsFormField.fromJson(Map<String, dynamic> json) {
    return PitsFormField(
      id: _asString(json['id'], 'field.id'),
      displayName: _asString(json['displayName'], 'field.displayName'),
      type: PitsFormFieldTypeX.fromJsonValue(
        _asString(json['type'], 'field.type'),
      ),
      params: _asMap(json['params'], 'field.params'),
      defaultValue: json['defaultValue'],
      required: json['required'] as bool?,
      storageKey: json['storageKey'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'displayName': displayName,
      'type': type.jsonValue,
      'params': params,
      if (defaultValue != null) 'defaultValue': defaultValue,
      if (required != null) 'required': required,
      if (storageKey != null) 'storageKey': storageKey,
    };
  }
}

Map<String, dynamic> _asMap(Object? value, String key) {
  if (value is Map<String, dynamic>) {
    return value;
  }
  if (value is Map) {
    return Map<String, dynamic>.from(value);
  }
  throw FormatException('Expected object for $key.');
}

List<dynamic> _asList(Object? value, String key) {
  if (value is List) {
    return value;
  }
  throw FormatException('Expected array for $key.');
}

String _asString(Object? value, String key) {
  if (value is String) {
    return value;
  }
  throw FormatException('Expected string for $key.');
}

int _asInt(Object? value, String key) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  throw FormatException('Expected integer for $key.');
}

num? _asNumOrNull(Object? value) {
  if (value is num) {
    return value;
  }
  return null;
}
