
import 'dart:convert';

import 'package:beariscope_scouter/custom_widgets/bool_button.dart';
import 'package:beariscope_scouter/custom_widgets/dropdown.dart';
import 'package:beariscope_scouter/custom_widgets/int_button.dart';
import 'package:beariscope_scouter/custom_widgets/text_box.dart';
import 'package:beariscope_scouter/custom_widgets/tristate.dart';
import 'package:beariscope_scouter/data/local_data.dart';
import 'package:beariscope_scouter/data/match_json_gen.dart';
import 'package:beariscope_scouter/pages/match.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce/hive.dart';

class MatchWidget extends StatefulWidget {
  final Map<String, dynamic> json;
  final int pageIndex;

  const MatchWidget({super.key, required this.json, required this.pageIndex});

  @override
  State<StatefulWidget> createState() {
    return MatchWidgetState();
  }
}

class MatchWidgetState extends State<MatchWidget> {
  List<Widget> matchPage = [];
  Box dataBox = Hive.box(boxKey);

  @override
  Widget build(BuildContext context) {
    double ultimateHeight = MediaQuery.of(context).size.height;
    double ultimateWidth = MediaQuery.of(context).size.width;
    PageConfig page = MatchConfig.fromJson(widget.json).pages[widget.pageIndex];
    double horizontalStep = (ultimateWidth / page.width);
    double verticalStep = ((ultimateHeight - 130) / page.height);
    
    MatchIdentity exampleMatchIdentity = (eventKey: "eventKey", matchNumber: 0, isRedAlliance: false, position: 0);

    //print(jsonEncode(generateMatchJsonHive(MatchConfig.fromJson(widget.json), exampleMatchIdentity).toJson()));

    for (var data in page.components) {
      final dataBoxKey = matchDataKey(exampleMatchIdentity, page.sectionId, data.fieldId);

      switch (data.type) {
        case "int_button":
          {
            matchPage.add(
              Positioned(
                top: data.layout.y * verticalStep,
                left: data.layout.x * horizontalStep,
                child: NumberButton(
                  backgroundColor: Colors.white,
                  dataName: data.fieldId,
                  xLength: data.layout.w * horizontalStep,
                  yLength: data.layout.h * verticalStep,
                  initialValue: dataBox.get(dataBoxKey),
                  onChanged: (value) => dataBox.put(dataBoxKey, value),
                ),
              ),
            );
            break;
          }
        case "toggle_button":
          {
            matchPage.add(
              Positioned(
                top: data.layout.y * verticalStep,
                left: data.layout.x * horizontalStep,
                child: BoolButton(
                  dataName: data.fieldId,
                  xLength: data.layout.w * horizontalStep,
                  yLength: data.layout.h * verticalStep,
                  initialValue: dataBox.get(dataBoxKey),
                  onChanged: (value) => dataBox.put(dataBoxKey, value),
                  visualFeedback: true,
                ),
              ),
            );
            break;
          }
        case "text_box":
          {
            matchPage.add(
              Positioned(
                top: data.layout.y * verticalStep,
                left: data.layout.x * horizontalStep,
                child: StringTextbox(
                  dataName: data.fieldId,
                  xLength: data.layout.w * horizontalStep,
                  yLength: data.layout.h * verticalStep,                  
                  onChanged: (value) => dataBox.put(dataBoxKey, value),
                ),
              ),
            );
            break;
          }
        case "dropdown":
          {
            matchPage.add(
              Positioned(
                top: data.layout.y * verticalStep,
                left: data.layout.x * horizontalStep,
                child: Dropdown(
                  title: '',
                  backgroundColor: Colors.blueAccent,
                  items: [],
                  // TODO get initial value whatever
                  onChanged: (value) => dataBox.put(dataBoxKey, value),
                  xValue: data.layout.w * horizontalStep,
                  yValue: data.layout.h * verticalStep,
                ),
              ),
            );
            break;
          }
        case "tristate":
          {
            matchPage.add(
              Positioned(
                top: data.layout.y * verticalStep,
                left: data.layout.x * horizontalStep,
                child: TristateButton(
                  dataName: data.fieldId,
                  xLength: data.layout.w * horizontalStep,
                  yLength: data.layout.h * verticalStep,
                  initialState: dataBox.get(dataBoxKey),
                  onChanged: (value) => dataBox.put(dataBoxKey, value),
                ),
              ),
            );
            break;
          }
      }
    }
    return Stack(children: matchPage);
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
