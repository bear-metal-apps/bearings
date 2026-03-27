// packages/services/lib/providers/secure_storage_provider.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'secure_storage_provider.g.dart';

abstract class TokenStorage {
  Future<String?> read({required String key});

  Future<void> write({required String key, required String? value});

  Future<void> delete({required String key});

  Future<void> deleteAll();
}

class _SecureTokenStorage implements TokenStorage {
  final FlutterSecureStorage _storage;

  const _SecureTokenStorage(this._storage);

  @override
  Future<String?> read({required String key}) => _storage.read(key: key);

  @override
  Future<void> write({required String key, required String? value}) =>
      _storage.write(key: key, value: value);

  @override
  Future<void> delete({required String key}) => _storage.delete(key: key);

  @override
  Future<void> deleteAll() => _storage.deleteAll();
}

class _PrefsTokenStorage implements TokenStorage {
  final SharedPreferences _prefs;

  const _PrefsTokenStorage(this._prefs);

  @override
  Future<String?> read({required String key}) async => _prefs.getString(key);

  @override
  Future<void> write({required String key, required String? value}) async {
    if (value == null) {
      await _prefs.remove(key);
    } else {
      await _prefs.setString(key, value);
    }
  }

  @override
  Future<void> delete({required String key}) async => _prefs.remove(key);

  @override
  Future<void> deleteAll() async => _prefs.clear();
}

@riverpod
Future<TokenStorage> tokenStorage(Ref ref) async {
  if (kIsWeb) {
    final prefs = await SharedPreferences.getInstance();
    return _PrefsTokenStorage(prefs);
  }
  return const _SecureTokenStorage(FlutterSecureStorage());
}
