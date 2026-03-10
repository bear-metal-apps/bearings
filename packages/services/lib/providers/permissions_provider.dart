import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:services/providers/api_provider.dart';
import 'package:services/providers/auth_provider.dart';

part 'permissions_provider.g.dart';

class PermissionKey {
  static const externalRead = 'external.read';
  static const matchRead = 'match.read';
  static const matchUpload = 'match.upload';
  static const matchCorrect = 'match.correct';
  static const pitsRead = 'pits.read';
  static const pitsUpload = 'pits.upload';
  static const notesRead = 'notes.read';
  static const driveTeamUpload = 'drive_team.upload';
  static const scoutsRead = 'scouts.read';
  static const scoutsManage = 'scouts.manage';
  static const usersRolesManage = 'rbac.manage';
  static const picklistsRead = 'picklists.read';
  static const picklistsManage = 'picklists.manage';
  static const deviceProvision = 'device.provision';
}

class AuthUserAccess {
  final String id;
  final Set<String> permissions;

  const AuthUserAccess({required this.id, required this.permissions});

  factory AuthUserAccess.fromJson(Map<String, dynamic> json) {
    final rawPermissions = (json['permissions'] as List<dynamic>? ?? const []);

    return AuthUserAccess(
      id: json['id'] as String? ?? '',
      permissions: rawPermissions.whereType<String>().toSet(),
    );
  }
}

class AuthMePayload {
  final AuthUserAccess user;
  final List<PermissionMetadata> permissionMetadata;

  const AuthMePayload({required this.user, required this.permissionMetadata});

  factory AuthMePayload.fromJson(Map<String, dynamic> json) {
    final rawGlobal =
        json['global_config'] as Map<String, dynamic>? ?? const {};
    final rawPermissionMetadata =
        (rawGlobal['permission_metadata'] as List<dynamic>? ?? const []);

    return AuthMePayload(
      user: AuthUserAccess.fromJson(
        json['user'] as Map<String, dynamic>? ?? const {},
      ),
      permissionMetadata: rawPermissionMetadata
          .whereType<Map<String, dynamic>>()
          .map(PermissionMetadata.fromJson)
          .toList(),
    );
  }
}

class PermissionMetadata {
  final String key;
  final String name;
  final String description;

  const PermissionMetadata({
    required this.key,
    required this.name,
    required this.description,
  });

  factory PermissionMetadata.fromJson(Map<String, dynamic> json) {
    return PermissionMetadata(
      key: json['key'] as String? ?? '',
      name: json['name'] as String? ?? json['key'] as String? ?? '',
      description: json['description'] as String? ?? '',
    );
  }
}

class PermissionChecker {
  final Set<String> permissions;

  const PermissionChecker({required this.permissions});

  bool hasPermission(String permission) {
    return permissions.contains(permission);
  }

  bool hasAnyPermission(Iterable<String> permissionValues) {
    for (final permission in permissionValues) {
      if (hasPermission(permission)) {
        return true;
      }
    }
    return false;
  }
}

@Riverpod(keepAlive: true)
Future<AuthMePayload?> authMe(Ref ref) async {
  final authStatus = ref.watch(authStatusProvider);
  if (authStatus != AuthStatus.authenticated) {
    return null;
  }

  final client = ref.watch(honeycombClientProvider);
  final payload = await client.get<Map<String, dynamic>>(
    '/auth/me',
    cachePolicy: CachePolicy.networkFirst,
  );
  return AuthMePayload.fromJson(payload);
}

@Riverpod(keepAlive: true)
PermissionChecker? permissionChecker(Ref ref) {
  final authMe = ref.watch(authMeProvider).asData?.value;
  if (authMe == null) {
    return null;
  }

  return PermissionChecker(permissions: authMe.user.permissions);
}
