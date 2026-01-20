import 'package:beariscope_scouter/custom_widgets/bool_button.dart';
import 'package:beariscope_scouter/custom_widgets/int_button.dart';
import 'package:beariscope_scouter/custom_widgets/slider.dart';
import 'package:beariscope_scouter/custom_widgets/text_box.dart';
import 'package:beariscope_scouter/custom_widgets/tristate.dart';
import 'package:beariscope_scouter/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  'tristate2': buttonState.unchecked,
  'tristate1': buttonState.unchecked,
};

enum EventTypes { strat, match, all }

class SchedulePageState extends ConsumerState<SchedulePage> {
  String searchedText = "";
  EventTypes selectedItem = EventTypes.all;
  List<Event> events = [
    Event(
      time: '2:45',
      name: "Match 16",
      eventType: EventTypes.all,
      commonPhrases: ['Match', 'Strat'],
    ),
    Event(
      time: '3:00',
      name: "Match 17",
      eventType: EventTypes.all,
      commonPhrases: ['Match', 'Strat'],
    ),
    Event(
      time: '3:15',
      name: "Match 18",
      eventType: EventTypes.all,
      commonPhrases: ['Match', 'Strat'],
    ),
    Event(
      time: '3:30',
      name: "Match 19",
      eventType: EventTypes.all,
      commonPhrases: ['Match', 'Strat'],
    ),
    Event(
      time: '3:45',
      name: "Match 20",
      eventType: EventTypes.all,
      commonPhrases: ['Match', 'Strat'],
    ),
    Event(
      time: '4:00',
      name: "Match 21",
      eventType: EventTypes.match,
      commonPhrases: ['Match', 'Strat'],
    ),
    Event(
      time: '4:15',
      name: "Match 22",
      eventType: EventTypes.strat,
      commonPhrases: ['Match', 'Strat'],
    ),
    Event(
      time: '4:30',
      name: "Match 23",
      eventType: EventTypes.all,
      commonPhrases: ['Match', 'Strat'],
    ),
    Event(time: '4:45', name: "Lunch", eventType: EventTypes.all),
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
            onTap: () {},
            trailing: TextButton.icon(
              onPressed: () {
                if (event.eventType == EventTypes.match ||
                    event.eventType == EventTypes.all) {
                  MyApp.router.go("/Match/Auto");
                } else if (event.eventType == EventTypes.strat) {
                  MyApp.router.go("/Strat");
                }
              },
              label: Icon(Icons.open_in_full_outlined),
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
  EventTypes eventType;
  String tbaMatchKey;
  final List<String> commonPhrases;

  Event({
    required this.time,
    required this.name,
    required this.eventType,
    this.tbaMatchKey = "",
    this.commonPhrases = const [],
  });
}
