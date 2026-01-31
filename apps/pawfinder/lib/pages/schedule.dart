import 'dart:math';

import 'package:beariscope_scouter/custom_widgets/int_button.dart';
import 'package:beariscope_scouter/custom_widgets/bool_button.dart';
import 'package:beariscope_scouter/custom_widgets/int_button.dart';
import 'package:beariscope_scouter/custom_widgets/slider.dart';
import 'package:beariscope_scouter/custom_widgets/text_box.dart';
import 'package:beariscope_scouter/custom_widgets/tristate.dart';
import 'package:beariscope_scouter/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

enum Positions { red1, red2, red3, blue1, blue2, blue3, none }

class SchedulePageState extends ConsumerState<SchedulePage> {
  String searchedText = "";
  EventTypes selectedItem = EventTypes.all;
  List<Event> events = [
    Event(
      time: '2:45',
      name: "Match 16",
      matchInformation: MatchInformation(
        matchID: 16,
        position: Positions.red1,
        robot: 9455,
      ),
      eventType: EventTypes.match,
      commonPhrases: ['Match', 'Strat'],
    ),
    Event(
      time: '3:00',
      name: "Match 17",
      matchInformation: MatchInformation(
        matchID: 17,
        position: Positions.blue2,
        robot: 5484,
      ),
      eventType: EventTypes.match,
      commonPhrases: ['Match', 'Strat'],
    ),
    Event(
      time: '3:15',
      name: "Match 18",
      matchInformation: MatchInformation(
        matchID: 18,
        position: Positions.blue2,
        robot: 1728,
      ),
      eventType: EventTypes.match,
      commonPhrases: ['Match', 'Strat'],
    ),
    Event(
      time: '3:30',
      name: "Match 19",
      matchInformation: MatchInformation(
        matchID: 19,
        position: Positions.red2,
        robot: 924,
      ),
      eventType: EventTypes.match,
      commonPhrases: ['Match', 'Strat'],
    ),
    Event(
      time: '3:45',
      name: "Match 20",
      matchInformation: MatchInformation(
        matchID: 20,
        position: Positions.blue1,
        robot: 4956,
      ),
      eventType: EventTypes.match,
      commonPhrases: ['Match', 'Strat'],
    ),
    Event(
      time: '4:00',
      name: "Match 21",
      matchInformation: MatchInformation(
        matchID: 21,
        position: Positions.red3,
        robot: 8725,
      ),
      eventType: EventTypes.match,
      commonPhrases: ['Match', 'Strat'],
    ),
    Event(
      time: '4:15',
      name: "Match 22",
      matchInformation: MatchInformation(
        matchID: 22,
        position: Positions.red1,
        robot: 395,
      ),
      eventType: EventTypes.match,
      commonPhrases: ['Match', 'Strat'],
    ),
    Event(
      time: '4:30',
      name: "Match 23",
      matchInformation: MatchInformation(
        matchID: 23,
        position: Positions.blue3,
        robot: 7144,
      ),
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
                  context.push("/Match/Auto", extra: event.matchInformation);
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

class MatchInformation {
  final int matchID;
  final Positions position;
  final int robot;

  MatchInformation({
    this.matchID = 0,
    this.position = Positions.none,
    this.robot = 0,
  });
}

class Event {
  final String time;
  final String name;
  MatchInformation? matchInformation;
  EventTypes eventType;
  String tbaMatchKey;
  final List<String> commonPhrases;

  Event({
    required this.time,
    required this.name,
    this.matchInformation,
    required this.eventType,
    this.tbaMatchKey = "",
    this.commonPhrases = const [],
  });
}
