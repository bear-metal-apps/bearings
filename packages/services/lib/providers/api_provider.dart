import 'package:core/utils/hive_cache_interceptor.dart';
import 'package:dio/dio.dart';
import 'package:hive_ce/hive.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:services/providers/auth_provider.dart';
import 'package:services/providers/connectivity_provider.dart';

export 'package:core/utils/hive_cache_interceptor.dart' show CachePolicy;

part 'api_provider.g.dart';

const _honeycombScope = 'ORLhqJbHiTfgdF3Q8hqIbmdwT1wTkkP7';

@riverpod
Dio dio(Ref ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl:
          'https://honeycomb-a3d3bbaacjhsaxbu.westus2-01.azurewebsites.net/api',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  final Box<dynamic> cacheBox = Hive.box('api_cache');

  dio.interceptors.add(HiveCacheInterceptor(cacheBox));
  return dio;
}

@riverpod
HoneycombClient honeycombClient(Ref ref) {
  return HoneycombClient(ref);
}

class HoneycombClient {
  final Ref _ref;
  final Future<String?> Function()? tokenOverride;

  HoneycombClient(this._ref, {this.tokenOverride});

  Future<T> _performRequest<T>(
    String method,
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    CachePolicy cachePolicy = CachePolicy.cacheFirst,
  }) async {
    final dio = _ref.read(dioProvider);

    bool isOffline = !(await checkOnline(_ref));
    String? token;

    if (!isOffline) {
      try {
        if (tokenOverride != null) {
          token = await tokenOverride!();
        } else {
          final authService = _ref.read(authProvider);
          token = await authService.getAccessToken([_honeycombScope]);
        }
      } on OfflineAuthException {
        isOffline = true;
      } catch (e) {
        rethrow;
      }
    }

    try {
      final response = await dio.request(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: Options(
          method: method,
          headers: {
            if (token != null) 'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          extra: {'cachePolicy': cachePolicy, 'isOffline': isOffline},
        ),
      );

      return response.data as T;
    } on DioException catch (e) {
      if (e.response != null) {
        final responseData = e.response?.data;
        throw Exception(
          'API Error: ${e.response?.statusCode} - ${e.response?.statusMessage} ${responseData ?? ''}',
        );
      }
      throw Exception('Network Error: ${e.message}');
    }
  }

  Future<T> get<T>(
    String endpoint, {
    CachePolicy cachePolicy = CachePolicy.cacheFirst,
    Map<String, dynamic>? queryParams,
  }) async {
    return _performRequest<T>(
      'GET',
      endpoint,
      cachePolicy: cachePolicy,
      queryParameters: queryParams,
    );
  }

  void invalidateCache(String endpoint, {Map<String, dynamic>? queryParams}) {
    final dio = _ref.read(dioProvider);
    final uri = Uri.parse('${dio.options.baseUrl}$endpoint');
    final key = queryParams != null
        ? uri
              .replace(
                queryParameters: queryParams.map(
                  (k, v) => MapEntry(k, v.toString()),
                ),
              )
              .toString()
        : uri.toString();

    final box = Hive.box<dynamic>('api_cache');
    final record = box.get(key);
    if (record is Map) {
      box.put(key, <String, dynamic>{
        ...Map<String, dynamic>.from(record),
        'timestamp': 0,
      });
    }
  }

  Future<void> clearCache() async {
    await Hive.box<dynamic>('api_cache').clear();
  }

  Future<T> post<T>(String endpoint, {required dynamic data}) async {
    return _performRequest<T>('POST', endpoint, data: data);
  }

  Future<T> put<T>(String endpoint, {required dynamic data}) async {
    return _performRequest<T>('PUT', endpoint, data: data);
  }

  Future<T> patch<T>(String endpoint, {required dynamic data}) async {
    return _performRequest<T>('PATCH', endpoint, data: data);
  }

  Future<void> delete(String endpoint, {dynamic data}) async {
    return _performRequest<void>('DELETE', endpoint, data: data);
  }
}

@Deprecated('Use get<Map<String, dynamic>>() in honeycombClientProvider.')
@riverpod
Future<Map<String, dynamic>> getData(
  Ref ref, {
  required String endpoint,
  bool forceRefresh = false,
}) async {
  return ref
      .watch(honeycombClientProvider)
      .get<Map<String, dynamic>>(
        endpoint,
        cachePolicy: forceRefresh
            ? CachePolicy.networkFirst
            : CachePolicy.cacheFirst,
      );
}

@Deprecated('Use get<List<dynamic>>() in honeycombClientProvider.')
@riverpod
Future<List<dynamic>> getListData(
  Ref ref, {
  required String endpoint,
  bool forceRefresh = false,
}) async {
  return ref
      .watch(honeycombClientProvider)
      .get<List<dynamic>>(
        endpoint,
        cachePolicy: forceRefresh
            ? CachePolicy.networkFirst
            : CachePolicy.cacheFirst,
      );
}
