import 'package:beariscope/models/observation_note.dart';
import 'package:beariscope/providers/current_event_provider.dart';
import 'package:beariscope/providers/scouting_data_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:services/providers/api_provider.dart';
import 'package:services/providers/permissions_provider.dart';
import 'package:services/providers/user_profile_provider.dart';

class ObservationSheet extends ConsumerStatefulWidget {
  final String teamName;
  final int teamNumber;

  const ObservationSheet({
    super.key,
    required this.teamName,
    required this.teamNumber,
  });

  @override
  ConsumerState<ObservationSheet> createState() => _ObservationSheetState();
}

class _ObservationSheetState extends ConsumerState<ObservationSheet> {
  final TextEditingController _controller = TextEditingController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onTextChanged)
      ..dispose();
    super.dispose();
  }

  void _onTextChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<String> _resolveScoutedBy() async {
    final userInfo = await ref.read(userInfoProvider.future);
    final name = userInfo?.name?.trim();
    if (name != null && name.isNotEmpty) {
      return name;
    }
    return 'Unknown User';
  }

  Future<void> _submit() async {
    if (_isSaving) return;

    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() => _isSaving = true);

    try {
      final authMe = await ref.read(authMeProvider.future);
      final eventKey = ref.read(currentEventProvider);
      final scoutedBy = await _resolveScoutedBy();
      final userId = authMe?.user.id ?? '';

      final note = ObservationNote(
        teamNumber: widget.teamNumber,
        note: text,
        scoutedBy: scoutedBy,
        userId: userId,
        eventKey: eventKey,
        season: 2026,
      );

      await ref
          .read(honeycombClientProvider)
          .post(
            '/scout/ingest',
            data: {
              'entries': [note.toIngestEntry()],
            },
          );

      await ref.read(scoutingDataProvider.notifier).refresh();

      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save observation: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canSubmit = !_isSaving && _controller.text.trim().isNotEmpty;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'New Observation',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontFamily: 'Xolonium',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${widget.teamName} — ${widget.teamNumber}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _controller,
                    autofocus: true,
                    maxLines: null,
                    minLines: 12,
                    textAlignVertical: TextAlignVertical.top,
                    textInputAction: TextInputAction.newline,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Observation',
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: canSubmit ? _submit : null,
                      child: _isSaving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Upload Observation'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
