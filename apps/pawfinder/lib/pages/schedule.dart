import 'package:beariscope_scouter/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SchedulePage extends ConsumerStatefulWidget {
  const SchedulePage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return SchedulePageState();
  }
}

enum EventTypes { strat, match, all }

class SchedulePageState extends ConsumerState<SchedulePage> {
  EventTypes selectedItem = EventTypes.all;
  List<Event> events = [
    Event(time: '2:45', name: "Match 16", eventType: EventTypes.all, commonPhrases: ['Match','Strat', '2:45']),
    Event(time: '3:00', name: "Match 17", eventType: EventTypes.all, commonPhrases: ['Match','Strat', '3:00']),
    Event(time: '3:15', name: "Match 18", eventType: EventTypes.all, commonPhrases: ['Match','Strat', '3:15']),
    Event(time: '3:30', name: "Match 19", eventType: EventTypes.all, commonPhrases: ['Match','Strat', '3:30']),
    Event(time: '3:45', name: "Match 20", eventType: EventTypes.all, commonPhrases: ['Match','Strat', '3:45']),
    Event(time: '4:00', name: "Match 21", eventType: EventTypes.match, commonPhrases: ['Match','Strat', '4:00']),
    Event(time: '4:15', name: "Match 22", eventType: EventTypes.strat, commonPhrases: ['Match','Strat', '4:15']),
    Event(time: '4:30', name: "Match 23", eventType: EventTypes.all, commonPhrases: ['Match','Strat', '4:30']),

  ];
  List<Widget> createTiles(){
    List<Widget> list = [
      SearchBar(
        leading: Icon(Icons.search),
        onChanged: (text) {},
        trailing: [
          PopupMenuButton(
            initialValue: selectedItem,
            onSelected: (EventTypes item) {
              setState(() {
                selectedItem = item;
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
      )
    ];
    for(var event in events) {
      if (event.eventType == selectedItem || selectedItem == EventTypes.all) {
        list.add(ListTile(
          leading: Icon(Icons.check_circle),
          title: Text(event.name),
          subtitle: Text(event.time),
          onTap: () {


          },
          trailing: TextButton.icon(
            onPressed: () {
              if (event.eventType == EventTypes.match || event.eventType == EventTypes.all) {
                MyApp.router.go("/Match/Auto");
              } else if (event.eventType == EventTypes.strat) {
                MyApp.router.go("/Strat");
              }
            },
            label: Icon(Icons.open_in_full_outlined),
          ),
        ));
      }
    }
    return list;
  }
  
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(4.0),
      children:  createTiles(),
    );
  }
}

class Event {
  late final String time;
  late final String name;
  EventTypes eventType;
  String tbaMatchKey;
  final List<String> commonPhrases;

  Event({
    required this.time,
    required this.name,
    required this.eventType,
    this.tbaMatchKey = "",
    required this.commonPhrases,
  });
}

