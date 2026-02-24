

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:libkoala/providers/api_provider.dart';
import '../data/local_data.dart';
import '../data/match_json_gen.dart';
import '../data/ui_json_serialization.dart';


class UploadButton extends ConsumerStatefulWidget{


  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return UploadButtonState();
  }
}

class UploadButtonState extends ConsumerState<UploadButton> {
  @override
  Widget build(BuildContext context) {
    return FilledButton.tonal(
      onPressed: dataToUpload.isEmpty
          ? null
          : () async {
              final pendingIdentities = List<MatchIdentity>.from(dataToUpload);
              dataToUpload = [];

              try {
                final json = jsonDecode(
                  await rootBundle.loadString('resources/ui_creator.json'),
                );
                final matchConfig = MatchConfig.fromJson(json);

                final entries = pendingIdentities
                    .map((identity) =>
                        generateMatchJsonHive(matchConfig, identity).toJson())
                    .toList();

                await ref
                    .read(honeycombClientProvider)
                    .post('/scout/ingest', data: {'entries': entries});

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Uploaded ${entries.length} entr${entries.length == 1 ? 'y' : 'ies'} successfully',
                      ),
                    ),
                  );
                }
              } catch (e) {
                dataToUpload = pendingIdentities;
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Upload failed: $e'),
                      backgroundColor:
                          Theme.of(context).colorScheme.error,
                    ),
                  );
                }
              }
            },
      child: const Icon(Icons.upload),
    );
  }
}
