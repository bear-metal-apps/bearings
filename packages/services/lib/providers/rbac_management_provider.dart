import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:services/providers/api_provider.dart';

part 'rbac_management_provider.g.dart';

class ManagedRole {
  final String id;
  final String name;
  final String? description;
  final List<String> permissions;

  const ManagedRole({
    required this.id,
    required this.name,
    this.description,
    required this.permissions,
  });

  factory ManagedRole.fromJson(Map<String, dynamic> json) {
    return ManagedRole(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      permissions: (json['permissions'] as List<dynamic>? ?? const [])
          .whereType<String>()
          .toList(),
    );
  }
}

class ManagedUser {
  final String id;
  final String? auth0UserId;
  final String? name;
  final String? avatarUrl;
  final List<String> roles;

  const ManagedUser({
    required this.id,
    this.auth0UserId,
    this.name,
    this.avatarUrl,
    required this.roles,
  });

  factory ManagedUser.fromJson(Map<String, dynamic> json) {
    return ManagedUser(
      id: json['id'] as String? ?? '',
      auth0UserId: json['auth0UserId'] as String?,
      name: json['name'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      roles: (json['roles'] as List<dynamic>? ?? const [])
          .whereType<String>()
          .toList(),
    );
  }
}

class RbacPermissionMetadata {
  final String key;
  final String name;
  final String description;

  const RbacPermissionMetadata({
    required this.key,
    required this.name,
    required this.description,
  });

  factory RbacPermissionMetadata.fromJson(Map<String, dynamic> json) {
    return RbacPermissionMetadata(
      key: json['key'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
    );
  }
}

class RbacMetadata {
  final List<RbacPermissionMetadata> permissions;

  const RbacMetadata({required this.permissions});

  factory RbacMetadata.fromJson(Map<String, dynamic> json) {
    return RbacMetadata(
      permissions: (json['permissions'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(RbacPermissionMetadata.fromJson)
          .toList(),
    );
  }
}

class RbacManagementService {
  final Ref _ref;

  const RbacManagementService(this._ref);

  HoneycombClient get _client => _ref.read(honeycombClientProvider);

  Future<List<ManagedRole>> getRoles() async {
    final payload = await _client.get<Map<String, dynamic>>(
      '/rbac/roles',
      cachePolicy: CachePolicy.networkFirst,
    );
    return (payload['roles'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(ManagedRole.fromJson)
        .toList();
  }

  Future<ManagedRole> createRole({
    required String id,
    required String name,
    String? description,
    required List<String> permissions,
  }) async {
    final payload = await _client.post<Map<String, dynamic>>(
      '/rbac/roles',
      data: {
        'id': id,
        'name': name,
        'description': description,
        'permissions': permissions,
      },
    );

    return ManagedRole.fromJson(payload['role'] as Map<String, dynamic>);
  }

  Future<ManagedRole> updateRole({
    required String id,
    String? name,
    String? description,
    List<String>? permissions,
  }) async {
    final data = <String, dynamic>{};
    if (name != null) data['name'] = name;
    if (description != null) data['description'] = description;
    if (permissions != null) data['permissions'] = permissions;

    final payload = await _client.patch<Map<String, dynamic>>(
      '/rbac/roles/$id',
      data: data,
    );

    return ManagedRole.fromJson(payload['role'] as Map<String, dynamic>);
  }

  Future<void> deleteRole(String id) async {
    await _client.delete('/rbac/roles/$id');
  }

  Future<List<ManagedUser>> getUsers() async {
    final payload = await _client.get<Map<String, dynamic>>(
      '/rbac/users',
      cachePolicy: CachePolicy.networkFirst,
    );
    return (payload['users'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(ManagedUser.fromJson)
        .toList();
  }

  Future<ManagedUser> updateUserRoles({
    required String userId,
    String? name,
    required List<String> roles,
  }) async {
    final data = <String, dynamic>{'roles': roles};
    if (name != null) {
      data['name'] = name;
    }

    final payload = await _client.patch<Map<String, dynamic>>(
      '/rbac/users/${Uri.encodeComponent(userId)}/roles',
      data: data,
    );

    return ManagedUser.fromJson(payload['user'] as Map<String, dynamic>);
  }

  Future<RbacMetadata> getMetadata() async {
    final payload = await _client.get<Map<String, dynamic>>(
      '/rbac/metadata',
      cachePolicy: CachePolicy.networkFirst,
    );
    return RbacMetadata.fromJson(payload);
  }
}

@Riverpod(keepAlive: true)
RbacManagementService rbacManagementService(Ref ref) {
  return RbacManagementService(ref);
}

@Riverpod(keepAlive: true)
Future<List<ManagedRole>> rbacRoles(Ref ref) async {
  return ref.watch(rbacManagementServiceProvider).getRoles();
}

@Riverpod(keepAlive: true)
Future<List<ManagedUser>> rbacUsers(Ref ref) async {
  return ref.watch(rbacManagementServiceProvider).getUsers();
}

@Riverpod(keepAlive: true)
Future<RbacMetadata> rbacMetadata(Ref ref) async {
  return ref.watch(rbacManagementServiceProvider).getMetadata();
}
