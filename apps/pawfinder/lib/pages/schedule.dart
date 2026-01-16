import 'dart:math';

import 'package:beariscope_scouter/custom_widgets/int_button.dart';
import 'package:beariscope_scouter/custom_widgets/tristate.dart';
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

// DELETE BEFORE DEPLOYMENT
Map<String, dynamic> gameData = {'example': 67};

class SchedulePageState extends ConsumerState<SchedulePage> {
  String searchedText = "";
  EventTypes selectedItem = EventTypes.all;
  List<Event> events = [
    Event(time: '2:45', name: "Match 16", eventType: EventTypes.all, commonPhrases: ['Match','Strat']),
    Event(time: '3:00', name: "Match 17", eventType: EventTypes.all, commonPhrases: ['Match','Strat']),
    Event(time: '3:15', name: "Match 18", eventType: EventTypes.all, commonPhrases: ['Match','Strat']),
    Event(time: '3:30', name: "Match 19", eventType: EventTypes.all, commonPhrases: ['Match','Strat']),
    Event(time: '3:45', name: "Match 20", eventType: EventTypes.all, commonPhrases: ['Match','Strat']),
    Event(time: '4:00', name: "Match 21", eventType: EventTypes.match, commonPhrases: ['Match','Strat']),
    Event(time: '4:15', name: "Match 22", eventType: EventTypes.strat, commonPhrases: ['Match','Strat']),
    Event(time: '4:30', name: "Match 23", eventType: EventTypes.all, commonPhrases: ['Match','Strat']),
    Event(time: '4:45', name: "Lunch", eventType: EventTypes.all),

  ];

  List<Widget> createTiles(){
    List<Widget> list = [];
    for(var event in events) {
      var searched = false;
      for (var string in event.commonPhrases){
        if(string.contains(searchedText)){
          searched = true;
          break;
        }
      }
      if ((event.eventType == selectedItem || selectedItem == EventTypes.all) && (searched || event.name.contains(searchedText) || event.time.contains(searchedText))) {
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
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Text(
            'Schedule Page',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          TristateButton(
            dataName: 'dataName',
            xLength: 300,
            yLength: 100,
            initialState: 0,
            onChanged: (int value) {
              // Handle the value change here
              print('TristateButton changed to state: $value');
            },
          ),
        ],
      ),
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

