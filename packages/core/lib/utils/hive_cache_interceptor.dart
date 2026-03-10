import 'package:dio/dio.dart';
import 'package:hive_ce/hive.dart';

/// Controls how the cache is consulted for a GET request.
///
/// All policies are offline-safe: when offline (no auth token available),
/// cached data is always preferred over returning an error, because cached
/// data cannot be re-fetched until connectivity is restored.
enum CachePolicy {
  /// Return cached data if it is fresh (< 1 hour old). If stale or absent,
  /// fetch from the network. If offline, return any cached data regardless
  /// of age.
  ///
  /// This is the default policy.
  cacheFirst,

  /// Always attempt a network fetch. Fall back to any cached data (regardless
  /// of age) on any network error or when offline.
  networkFirst,

  /// Always attempt a network fetch. Do not fall back to cache on transient
  /// network errors — throw instead. If offline (no auth token), fall back to
  /// cached data as a safety-net.
  networkOnly,

  /// Return cached data only. Never perform a network fetch. Rejects the
  /// request if no cached data exists.
  cacheOnly,
}

class HiveCacheInterceptor extends Interceptor {
  final Box box;

  HiveCacheInterceptor(this.box);

  // Marker placed in RequestOptions.extra when a response is served from
  // cache, so that onResponse knows not to overwrite Hive with stale data.
  static const _kFromCache = '__hive_from_cache__';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (options.method != 'GET') {
      return handler.next(options);
    }

    final key = options.uri.toString();
    final policy =
        options.extra['cachePolicy'] as CachePolicy? ?? CachePolicy.cacheFirst;
    final isOffline = options.extra['isOffline'] == true;
    final record = box.get(key);

    Response? buildCacheResponse() {
      if (record is! Map || !record.containsKey('data')) return null;
      final cachedData = record['data'];
      final normalized = cachedData is Map
          ? Map<String, dynamic>.from(cachedData)
          : cachedData is List
          ? List<dynamic>.from(cachedData)
          : cachedData;
      options.extra[_kFromCache] = true;
      return Response(
        requestOptions: options,
        data: normalized,
        statusCode: 200,
        statusMessage: 'From Cache',
      );
    }

    void rejectNoCache() => handler.reject(
      DioException(
        requestOptions: options,
        error: 'Offline: No cached data available for $key',
        type: DioExceptionType.connectionError,
      ),
    );

    switch (policy) {
      case CachePolicy.cacheOnly:
        final cached = buildCacheResponse();
        return cached != null ? handler.resolve(cached) : rejectNoCache();

      case CachePolicy.networkFirst:
      case CachePolicy.networkOnly:
        if (isOffline) {
          final cached = buildCacheResponse();
          return cached != null ? handler.resolve(cached) : rejectNoCache();
        }
        return handler.next(options);

      case CachePolicy.cacheFirst:
        if (record is Map && record['timestamp'] is int) {
          final age =
              DateTime.now().millisecondsSinceEpoch -
              (record['timestamp'] as int);
          final isFresh = age < const Duration(hours: 1).inMilliseconds;

          if (isFresh || isOffline) {
            final cached = buildCacheResponse();
            if (cached != null) return handler.resolve(cached);
          }
        } else if (isOffline) {
          return rejectNoCache();
        }
        return handler.next(options);
    }
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final request = err.requestOptions;
    if (request.method != 'GET') return handler.next(err);

    final policy =
        request.extra['cachePolicy'] as CachePolicy? ?? CachePolicy.cacheFirst;

    if (policy == CachePolicy.networkOnly) return handler.next(err);

    final isNetworkError =
        err.type == DioExceptionType.connectionError ||
        err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.unknown;

    if (isNetworkError) {
      final key = request.uri.toString();
      final record = box.get(key);

      if (record is Map && record.containsKey('data')) {
        final cachedData = record['data'];
        final normalized = cachedData is Map
            ? Map<String, dynamic>.from(cachedData)
            : cachedData is List
            ? List<dynamic>.from(cachedData)
            : cachedData;
        request.extra[_kFromCache] = true;
        return handler.resolve(
          Response(
            requestOptions: request,
            data: normalized,
            statusCode: 200,
            statusMessage: 'From Cache (Network Error Fallback)',
          ),
        );
      }
    }

    handler.next(err);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final fromCache = response.requestOptions.extra[_kFromCache] == true;

    if (!fromCache &&
        response.requestOptions.method == 'GET' &&
        response.statusCode == 200) {
      final key = response.requestOptions.uri.toString();
      box.put(key, <String, dynamic>{
        'data': response.data,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
    }

    handler.next(response);
  }
}
