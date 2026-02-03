import 'dart:math';

import 'package:beariscope_scouter/custom_widgets/int_button.dart';
import 'package:beariscope_scouter/custom_widgets/bool_button.dart';
import 'package:beariscope_scouter/custom_widgets/int_button.dart';
import 'package:beariscope_scouter/custom_widgets/slider.dart';
import 'package:beariscope_scouter/custom_widgets/text_box.dart';
import 'package:beariscope_scouter/custom_widgets/tristate.dart';
import 'package:beariscope_scouter/data/match_json_gen.dart';
import 'package:beariscope_scouter/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:beariscope_scouter/custom_widgets/int_textbox.dart';
import 'package:beariscope_scouter/custom_widgets/dropdown.dart';
import 'package:beariscope_scouter/custom_widgets/segmented_button.dart';
import 'package:go_router/go_router.dart';
import 'package:beariscope_scouter/custom_widgets/int_textbox.dart';
import 'package:beariscope_scouter/custom_widgets/dropdown.dart';
import 'package:beariscope_scouter/custom_widgets/segmented_button.dart';

class SchedulePage extends ConsumerStatefulWidget {
  const SchedulePage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return SchedulePageState();
  }
}

// DELETE BEFORE DEPLOYMENT
enum EventTypes {
  match,
  strat,
  misc,
  all
}

Map<String, dynamic> gameData = {
  'numberButton1': 0,
  'numberButton2': 0,
  'intTextbox1': 0,
  'intTextbox2': 0,
  'stringTextbox1': '',
  'stringTextbox2': '',
  'selectedSegmentedButton1': '',
  'selectedSegmentedButton2': '',
  'selectedDropdown': '',
  'selectedDropdown2': '',
  'DropdownOptions': <String>[
    'Option 1',
    'Option 2',
    'Option 3',
    'Option 4',
    'Option 5',
  ],
  'SegmentedButtonOptions': <String>['Zayden', 'Ben', 'Jack', 'Aadi', 'Aarav'],
  'slider1': 0.0,
  'slider2': 0.0,
  'boolButton1': false,
  'boolButton2': false,
  'tristate2': 0,
  'tristate1': 1,
};


class SchedulePageState extends ConsumerState<SchedulePage> {
  String searchedText = "";
  EventTypes selectedItem = EventTypes.all;
  List<Event> events = [
    Event(
      time: '2:45',
      name: "Match 16",
      matchIdentity: (eventKey: "eventKey", matchNumber: 16, isRedAlliance: false, position: 0, robotNum: 0),
      eventType: EventTypes.match,
      commonPhrases: ['Match', 'Strat'],
    ),
    Event(
      time: '3:00',
      name: "Match 17",
      matchIdentity: (eventKey: "eventKey", matchNumber: 17, isRedAlliance: false, position: 0, robotNum: 0),
      eventType: EventTypes.match,
      commonPhrases: ['Match', 'Strat'],
    ),
    Event(
      time: '3:15',
      name: "Match 18",
      matchIdentity: (eventKey: "eventKey", matchNumber: 18, isRedAlliance: false, position: 0, robotNum: 0),
      eventType: EventTypes.match,
      commonPhrases: ['Match', 'Strat'],
    ),
    Event(
      time: '3:30',
      name: "Match 19",
      matchIdentity: (eventKey: "eventKey", matchNumber: 19, isRedAlliance: false, position: 0, robotNum: 0),
      eventType: EventTypes.match,
      commonPhrases: ['Match', 'Strat'],
    ),
    Event(
      time: '3:45',
      name: "Match 20",
      matchIdentity: (eventKey: "eventKey", matchNumber: 20, isRedAlliance: false, position: 0, robotNum: 0),
      eventType: EventTypes.match,
      commonPhrases: ['Match', 'Strat'],
    ),
    Event(
      time: '4:00',
      name: "Match 21",
      matchIdentity: (eventKey: "eventKey", matchNumber: 21, isRedAlliance: false, position: 0, robotNum: 0),
      eventType: EventTypes.match,
      commonPhrases: ['Match', 'Strat'],
    ),
    Event(
      time: '4:15',
      name: "Match 22",
      matchIdentity: (eventKey: "eventKey", matchNumber: 22, isRedAlliance: false, position: 0, robotNum: 0),
      eventType: EventTypes.match,
      commonPhrases: ['Match', 'Strat'],
    ),
    Event(
      time: '4:30',
      name: "Match 23",
      matchIdentity: (eventKey: "eventKey", matchNumber: 23, isRedAlliance: false, position: 0, robotNum: 0),
      eventType: EventTypes.match,
      commonPhrases: ['Match', 'Strat'],
    ),
    Event(time: '4:45', name: "Lunch", eventType: EventTypes.misc),
  ];

  List<Widget> createTiles() {
    List<Widget> list = [];
    for (var event in events) {
      var searched = false;
      for (var string in event.commonPhrases) {
        if (string.contains(searchedText)) {
          searched = true;
          break;
        }
      }

      if ((event.eventType == selectedItem || selectedItem == EventTypes.all) &&
          (searched ||
              event.name.contains(searchedText) ||
              event.time.contains(searchedText))) {
        list.add(
          ListTile(
            leading: Icon(Icons.check_circle),
            title: Text(event.name),
            subtitle: Text(event.time),
            trailing: IconButton(
              icon: Icon(Icons.open_in_full_outlined),
              onPressed: () {
                if (event.eventType == EventTypes.match) {
                  context.push("/Match/Auto", extra: event.matchIdentity);
                } else if (event.eventType == EventTypes.strat) {
                  MyApp.router.go("/Strat");
                }
              },
            ),
          ),
        );
      }
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> cards = createTiles();
    return ListView(
      padding: EdgeInsets.all(4.0),
      children: [
        SearchBar(
          leading: Icon(Icons.search),
          onChanged: (text) {
            setState(() {
              searchedText = text;
              cards = createTiles();
            });
          },
          trailing: [
            PopupMenuButton(
              initialValue: selectedItem,
              onSelected: (EventTypes item) {
                setState(() {
                  selectedItem = item;
                  cards = createTiles();
                });
              },
              itemBuilder: (BuildContext context) =>
                  <PopupMenuEntry<EventTypes>>[
                    const PopupMenuItem<EventTypes>(
                      value: EventTypes.match,
                      child: Text('Match'),
                    ),
                    const PopupMenuItem<EventTypes>(
                      value: EventTypes.strat,
                      child: Text('Strat'),
                    ),
                    const PopupMenuItem<EventTypes>(
                      value: EventTypes.all,
                      child: Text('All'),
                    ),
                  ],
              child: Icon(Icons.filter),
            ),
          ],
        ),
        Column(children: cards),
      ],
    );
  }
}

class Event {
  final String time;
  final String name;
  MatchIdentity? matchIdentity;
  EventTypes eventType;
  String tbaMatchKey;
  final List<String> commonPhrases;

  Event({
    required this.time,
    required this.name,
    this.matchIdentity,
    required this.eventType,
    this.tbaMatchKey = "",
    this.commonPhrases = const [],
  });
}
