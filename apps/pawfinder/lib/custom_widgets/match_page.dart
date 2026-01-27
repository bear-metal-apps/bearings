
import 'dart:convert';

import 'package:beariscope_scouter/custom_widgets/bool_button.dart';
import 'package:beariscope_scouter/custom_widgets/dropdown.dart';
import 'package:beariscope_scouter/custom_widgets/int_button.dart';
import 'package:beariscope_scouter/custom_widgets/text_box.dart';
import 'package:beariscope_scouter/custom_widgets/tristate.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';

List<List<Widget>> matchPages = [];

void loadUI(BuildContext context) async{
  double ultimateHeight = MediaQuery.of(context).size.height;
  double ultimateWidth = MediaQuery.of(context).size.width;
  final json = jsonDecode(await rootBundle.loadString('resources/ui_creator.json'));
  List<PageConfig> page = MatchConfig.fromJson(json).pages;
  for (var pageIndex = 0; pageIndex != page.length - 1; pageIndex++) {
    matchPages.insert(pageIndex, []);
    for (var data in page[pageIndex].components) {
      double horizontalStep = (ultimateWidth / page[pageIndex].width);
      double verticalStep = ((ultimateHeight - 130) / page[pageIndex].height);
      switch (data.type) {
        case "int_button":
          {
            matchPages[pageIndex].add(
              Positioned(
                top: data.layout.y * verticalStep,
                left: data.layout.x * horizontalStep,
                child: NumberButton(
                  backgroundColor: Colors.white,
                  dataName: data.fieldId,
                  xLength: data.layout.w * horizontalStep,
                  yLength: data.layout.h * verticalStep,
                ),
              ),
            );
            break;
          }
        case "toggle_button":
          {
            matchPages[pageIndex].add(
              Positioned(
                top: data.layout.y * verticalStep,
                left: data.layout.x * horizontalStep,
                child: BoolButton(
                  dataName: data.fieldId,
                  xLength: data.layout.w * horizontalStep,
                  yLength: data.layout.h * verticalStep,
                  onChanged: (bool p1) {},
                  visualFeedback: true,
                ),
              ),
            );
            break;
          }
        case "text_box":
          {
            matchPages[pageIndex].add(
              Positioned(
                top: data.layout.y * verticalStep,
                left: data.layout.x * horizontalStep,
                child: StringTextbox(
                  dataName: data.fieldId,
                  xLength: data.layout.w * horizontalStep,
                  yLength: data.layout.h * verticalStep,
                  onChanged: (String p1) {},
                ),
              ),
            );
            break;
          }
        case "dropdown":
          {
            matchPages[pageIndex].add(
              Positioned(
                top: data.layout.y * verticalStep,
                left: data.layout.x * horizontalStep,
                child: Dropdown(
                  title: '',
                  backgroundColor: Colors.blueAccent,
                  items: [],
                  xValue: data.layout.w * horizontalStep,
                  yValue: data.layout.h * verticalStep,
                ),
              ),
            );
            break;
          }
        case "tristate":
          {
            matchPages[pageIndex].add(
              Positioned(
                top: data.layout.y * verticalStep,
                left: data.layout.x * horizontalStep,
                child:
                TristateButton(
                    dataName: data.fieldId,
                    xLength: data.layout.w * horizontalStep,
                    yLength: data.layout.h * verticalStep,
                  onChanged: (int p1) {  },
                ),
              ),
            );
            break;
          }
        default:
          {
            print("non-existent");
          }
      }
    }
  }
}






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

  ComponentConfig({
    required this.fieldId,
    required this.type,
    required this.layout,
    required this.parameters,
  });

  factory ComponentConfig.fromJson(Map<String, dynamic> json) {
    return ComponentConfig(
      fieldId: json['fieldId'],
      type: json['type'],
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
