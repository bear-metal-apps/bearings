import 'package:beariscope/providers/shared_preferences_provider.dart';
import 'package:beariscope/providers/tba_preferences_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'reads the saved beta preference immediately and persists updates',
    () async {
      SharedPreferences.setMockInitialValues({'useBetaTbaWebsite': true});
      final prefs = await SharedPreferences.getInstance();

      final container = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );
      addTearDown(container.dispose);

      expect(container.read(useBetaTbaWebsiteProvider), isTrue);
      await container
          .read(useBetaTbaWebsiteProvider.notifier)
          .setUseBetaTbaWebsite(true);
      expect(container.read(useBetaTbaWebsiteProvider), isTrue);

      expect(prefs.getBool('useBetaTbaWebsite'), isTrue);

      await container
          .read(useBetaTbaWebsiteProvider.notifier)
          .setUseBetaTbaWebsite(false);
      expect(container.read(useBetaTbaWebsiteProvider), isFalse);
      expect(prefs.getBool('useBetaTbaWebsite'), isFalse);
    },
  );
}
