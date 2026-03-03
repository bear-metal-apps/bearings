import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/upload_queue.dart';
import '../services/scout_upload_service.dart';

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
      final count = await ref.read(scoutUploadServiceProvider).upload(pending);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('uploaded $count entr${count == 1 ? "y" : "ies"}')),
        );
      }
    } catch (e) {
      ref.read(uploadQueueProvider.notifier).restoreAll(pending);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('upload failed: $e'),
            backgroundColor: Theme
                .of(context)
                .colorScheme
                .error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }
}
