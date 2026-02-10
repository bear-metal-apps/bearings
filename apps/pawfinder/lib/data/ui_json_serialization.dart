//CHAT GPT - WILL REMOVE LATER
class MatchConfig {
  final Meta meta;
  final List<PageConfig> pages;

  MatchConfig({required this.meta, required this.pages});

  factory MatchConfig.fromJson(Map<String, dynamic> json) {
    return MatchConfig(
      meta: Meta.fromJson(json['meta']),
      pages: (json['pages'] as List)
          .map((e) => PageConfig.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'meta': meta.toJson(),
    'pages': pages.map((e) => e.toJson()).toList(),
  };
}

class Meta {
  final int season;
  final String author;
  final int version;
  final String type;

  Meta({
    required this.season,
    required this.author,
    required this.version,
    required this.type,
  });

  factory Meta.fromJson(Map<String, dynamic> json) {
    return Meta(
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

class PageConfig {
  final String sectionId;
  final String title;
  final num width;
  final num height;
  final List<ComponentConfig> components;

  PageConfig({
    required this.sectionId,
    required this.title,
    required this.width,
    required this.height,
    required this.components,
  });

  factory PageConfig.fromJson(Map<String, dynamic> json) {
    return PageConfig(
      sectionId: json['sectionId'],
      title: json['title'],
      width: json['width'],
      height: json['height'],
      components: (json['components'] as List)
          .map((e) => ComponentConfig.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'sectionId': sectionId,
    'title': title,
    'width': width,
    'height': height,
    'components': components.map((e) => e.toJson()).toList(),
  };
}

class ComponentConfig {
  final String fieldId;
  final String type;
  final Layout layout;
  final Map<String, dynamic> parameters;
  final String alias;

  ComponentConfig({
    required this.fieldId,
    required this.type,
    required this.layout,
    required this.parameters,
    required this.alias
  });

  factory ComponentConfig.fromJson(Map<String, dynamic> json) {
    return ComponentConfig(
      fieldId: json['fieldId'],
      type: json['type'],
      alias: json['alias'],
      layout: Layout.fromJson(json['layout']),
      parameters: Map<String, dynamic>.from(json['parameters'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() => {
    'fieldId': fieldId,
    'type': type,
    'layout': layout.toJson(),
    'parameters': parameters,
  };
}

class Layout {
  final num x;
  final num y;
  final num w;
  final num h;

  Layout({required this.x, required this.y, required this.w, required this.h});

  factory Layout.fromJson(Map<String, dynamic> json) {
    return Layout(x: json['x'], y: json['y'], w: json['w'], h: json['h']);
  }

  Map<String, dynamic> toJson() => {'x': x, 'y': y, 'w': w, 'h': h};
}
