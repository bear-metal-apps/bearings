import 'dart:convert';

import 'package:beariscope_scouter/providers/guest_mode_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:libkoala/providers/api_provider.dart';

import '../data/match_json_gen.dart';
import '../data/ui_json_serialization.dart';
import '../data/upload_queue.dart';

class UploadButton extends ConsumerStatefulWidget {
  const UploadButton({super.key});

  @override
  ConsumerState<UploadButton> createState() => UploadButtonState();
}

class UploadButtonState extends ConsumerState<UploadButton> {
  @override
  Widget build(BuildContext context) {
    // watch the queue so the button re-enables the moment a match is queued
    final queue = ref.watch(uploadQueueProvider);
    final isGuest = ref.watch(guestModeProvider);

    return FilledButton.tonal(
      onPressed: queue.isEmpty
          ? null
          : () async {
              final pending = List.of(queue);
              // Optimistically remove from queue before the network call.
              ref.read(uploadQueueProvider.notifier).removeUploaded(pending);

              try {
                final json = jsonDecode(
                  await rootBundle.loadString('resources/ui_creator.json'),
                );
                final matchConfig = MatchConfig.fromJson(json);

                final entries = pending
                    .map(
                      (id) => generateMatchJsonHive(matchConfig, id).toJson(),
                    )
                    .toList();

                await ref
                    .read(honeycombClientProvider)
                    .post('/scout/ingest', data: {'entries': entries});

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Uploaded ${entries.length} '
                        'entr${entries.length == 1 ? 'y' : 'ies'} successfully',
                      ),
                    ),
                  );
                  
                  // If in guest mode and upload successful, suggest exiting offline mode
                  if (isGuest) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Data uploaded! You can now exit offline mode in Settings.',
                        ),
                        duration: Duration(seconds: 4),
                      ),
                    );
                  }
                }
              } catch (e) {
                ref.read(uploadQueueProvider.notifier).restoreAll(pending);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Upload failed: $e'),
                      backgroundColor: Theme.of(context).colorScheme.error,
                    ),
                  );
                }
              }
            },
      child: isGuest && queue.isNotEmpty 
          ? Badge(
              label: Text('${queue.length}'),
              child: const Icon(Icons.upload),
            )
          : const Icon(Icons.upload),
    );
  }
}
