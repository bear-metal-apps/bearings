import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'shared_preferences_provider.dart';

const _useBetaTbaWebsiteKey = 'useBetaTbaWebsite';

final useBetaTbaWebsiteProvider =
    NotifierProvider<UseBetaTbaWebsiteNotifier, bool>(
      UseBetaTbaWebsiteNotifier.new,
    );

class UseBetaTbaWebsiteNotifier extends Notifier<bool> {
  @override
  bool build() {
    final prefs = ref.read(sharedPreferencesProvider);
    return prefs.getBool(_useBetaTbaWebsiteKey) ?? false;
  }

  Future<void> setUseBetaTbaWebsite(bool value) async {
    state = value;
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setBool(_useBetaTbaWebsiteKey, value);
  }
}

extension TbaWebsitePreferencesRef on WidgetRef {
  bool get useBetaTbaWebsite => read(useBetaTbaWebsiteProvider);

  Uri tbaWebsiteUri(String path) {
    return buildTbaWebsiteUri(path: path, useBeta: useBetaTbaWebsite);
  }
}

Uri buildTbaWebsiteUri({required String path, required bool useBeta}) {
  final normalizedPath = path.startsWith('/') ? path : '/$path';
  final host = useBeta ? 'beta.thebluealliance.com' : 'www.thebluealliance.com';
  return Uri.parse('https://$host$normalizedPath');
}
