import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

Future<void> saveOrShareExcel(
  BuildContext context,
  List<int> bytes,
  String filename,
) async {
  if (Platform.isIOS || Platform.isAndroid) {
    await Share.shareXFiles([
      XFile.fromData(
        Uint8List.fromList(bytes),
        name: filename,
        mimeType:
            'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      ),
    ]);
    return;
  }

  final path = await FilePicker.platform.saveFile(
    dialogTitle: 'Save Excel file',
    fileName: filename,
    type: FileType.custom,
    allowedExtensions: const ['xlsx'],
  );
  if (path == null || path.isEmpty) return;

  await File(path).writeAsBytes(bytes, flush: true);
  if (context.mounted) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Saved $filename')));
  }
}
