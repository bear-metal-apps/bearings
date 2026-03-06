// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:libkoala/providers/api_provider.dart';
import 'package:pawfinder/data/match_json_gen.dart';
import 'package:pawfinder/data/ui_json_serialization.dart';
import 'package:pawfinder/data/upload_queue.dart';

class UploadButton extends ConsumerStatefulWidget {
  const UploadButton({super.key});

  @override
  ConsumerState<UploadButton> createState() => _UploadButtonState();
}

class _UploadButtonState extends ConsumerState<UploadButton> {
  bool _uploading = false;

  @override
  Widget build(BuildContext context) {
    final queue = ref.watch(uploadQueueProvider);

    return FilledButton.tonal(
      onPressed: queue.isEmpty || _uploading ? null : _upload,
      child: _uploading
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.upload),
    );
  }

  Future<void> _upload() async {
    final pending = List.of(ref.read(uploadQueueProvider));
    // optimistically clear queue before network call
    ref.read(uploadQueueProvider.notifier).removeUploaded(pending);
    setState(() => _uploading = true);

    try {
      final json = jsonDecode(
        await rootBundle.loadString('resources/ui_creator.json'),
      );
      final matchConfig = MatchConfig.fromJson(json);

      final entries = pending
          .map((id) => generateMatchJsonHive(matchConfig, id).toJson())
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
    } finally {
      setState(() => _uploading = false);
    }
  }
}
