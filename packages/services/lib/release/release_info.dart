import 'package:flutter/services.dart';

const _codenameAssetPath = 'packages/services/assets/release/codename.txt';

Future<String> loadReleaseCodename() async {
  final codename = (await rootBundle.loadString(_codenameAssetPath)).trim();
  if (codename.isEmpty) {
    return 'Unknown';
  }
  return codename;
}
