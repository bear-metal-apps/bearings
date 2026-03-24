class MatchConfig {
  const MatchConfig({required this.meta, required this.pages});

  final MatchConfigMeta meta;
  final List<PageConfig> pages;

  factory MatchConfig.fromJson(Map<String, dynamic> json) {
    final rawPages = json['pages'] as List<dynamic>? ?? const [];

    return MatchConfig(
      meta: MatchConfigMeta.fromJson(_asStringMap(json['meta']) ?? const {}),
      pages: rawPages
          .map((item) => PageConfig.fromJson(_asStringMap(item) ?? const {}))
          .toList(growable: false),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'meta': meta.toJson(),
      'pages': pages.map((page) => page.toJson()).toList(growable: false),
    };
  }
}

class MatchConfigMeta {
  const MatchConfigMeta({
    required this.season,
    required this.author,
    required this.version,
    required this.type,
  });

  final int season;
  final String author;
  final int version;
  final String type;

  factory MatchConfigMeta.fromJson(Map<String, dynamic> json) {
    return MatchConfigMeta(
      season: _asInt(json['season']) ?? 0,
      author: json['author']?.toString() ?? '',
      version: _asInt(json['version']) ?? 0,
      type: json['type']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'season': season,
      'author': author,
      'version': version,
      'type': type,
    };
  }
}

class PageConfig {
  const PageConfig({
    required this.sectionId,
    required this.title,
    required this.width,
    required this.height,
    required this.components,
  });

  final String sectionId;
  final String title;
  final num width;
  final num height;
  final List<ComponentConfig> components;

  factory PageConfig.fromJson(Map<String, dynamic> json) {
    final rawComponents = json['components'] as List<dynamic>? ?? const [];

    return PageConfig(
      sectionId: json['sectionId']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      width: _asNum(json['width']) ?? 0,
      height: _asNum(json['height']) ?? 0,
      components: rawComponents
          .map(
            (item) => ComponentConfig.fromJson(_asStringMap(item) ?? const {}),
          )
          .toList(growable: false),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sectionId': sectionId,
      'title': title,
      'width': width,
      'height': height,
      'components': components
          .map((component) => component.toJson())
          .toList(growable: false),
    };
  }
}

class ComponentConfig {
  const ComponentConfig({
    required this.fieldId,
    required this.type,
    required this.layout,
    required this.parameters,
    required this.alias,
  });

  final String fieldId;
  final String type;
  final Layout layout;
  final Map<String, dynamic> parameters;
  final String alias;

  factory ComponentConfig.fromJson(Map<String, dynamic> json) {
    return ComponentConfig(
      fieldId: json['fieldId']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      layout: Layout.fromJson(_asStringMap(json['layout']) ?? const {}),
      parameters: _asStringMap(json['parameters']) ?? const {},
      alias: json['alias']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fieldId': fieldId,
      'type': type,
      'alias': alias,
      'layout': layout.toJson(),
      'parameters': parameters,
    };
  }
}

class Layout {
  const Layout({
    required this.x,
    required this.y,
    required this.w,
    required this.h,
  });

  final num x;
  final num y;
  final num w;
  final num h;

  factory Layout.fromJson(Map<String, dynamic> json) {
    return Layout(
      x: _asNum(json['x']) ?? 0,
      y: _asNum(json['y']) ?? 0,
      w: _asNum(json['w']) ?? 0,
      h: _asNum(json['h']) ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'x': x, 'y': y, 'w': w, 'h': h};
  }
}

Map<String, dynamic>? _asStringMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) {
    return value.map((key, val) => MapEntry(key.toString(), val));
  }
  return null;
}

int? _asInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}

num? _asNum(dynamic value) {
  if (value == null) return null;
  if (value is num) return value;
  return num.tryParse(value.toString());
}
