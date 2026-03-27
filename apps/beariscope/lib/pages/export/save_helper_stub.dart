import 'dart:typed_data';

import 'package:share_plus/share_plus.dart';

Future<void> saveOrShareExcel(_, List<int> bytes, String filename) async {
  await Share.shareXFiles([
    XFile.fromData(
      Uint8List.fromList(bytes),
      name: filename,
      mimeType:
          'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    ),
  ]);
}
