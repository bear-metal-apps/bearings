


import 'dart:convert';

import 'package:beariscope_scouter/pages/match_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';
import 'package:libkoala/providers/api_provider.dart';
import '../data/local_data.dart';
import '../data/match_json_gen.dart';
import '../data/ui_json_serialization.dart';
import '../models/scouting_session.dart';


class UploadButton extends ConsumerStatefulWidget{


  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return UploadButtonState();
  }
}

class UploadButtonState extends ConsumerState<UploadButton>{

    @override
    Widget build(BuildContext context) {
      return ElevatedButton(
        onPressed: () async {
          final json = jsonDecode(
            await rootBundle.loadString('resources/ui_creator.json'),
          );
          final matchConfig = MatchConfig.fromJson(json);

          List<Map<String,dynamic>> uploadingData = [];
          String dataToUploadName = "";
          dataToUpload.forEach((MatchIdentity element){
            uploadingData.add(generateMatchJsonHive(
                matchConfig,
                element,
                scoutsToUpload[dataToUpload.indexOf(element)] ?? Scout(name: 'NoScout', uuid: '')
            ).toJson());
            dataToUploadName = "$dataToUploadName MATCH: ${element.matchNumber}";
          });

          final data = {
            "uploadBatchId": dataToUploadName,
            "entries": uploadingData
          };

          await ref.watch(honeycombClientProvider).post("/scout/ingest", data: jsonEncode(data));
          dataToUpload = [];
          dataToUploadName = "";
        },
        child: Icon(
            Icons.upload
        ),
      );
    }

}
