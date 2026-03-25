import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

Future<void> saveOrShareExcel(
  BuildContext context,
  List<int> bytes,
  String filename,
) async {
  if (Platform.isIOS || Platform.isAndroid) {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$filename');
    await file.writeAsBytes(bytes, flush: true);

    await Share.shareXFiles(
      [
        XFile(
          file.path,
          mimeType:
              'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
          name: filename,
        ),
      ],
      subject: filename,
      sharePositionOrigin: _getShareOrigin(context),
    );
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

Rect _getShareOrigin(BuildContext context) {
  final box = context.findRenderObject() as RenderBox?;
  if (box == null) return Rect.zero;
  return box.localToGlobal(Offset.zero) & box.size;
}
