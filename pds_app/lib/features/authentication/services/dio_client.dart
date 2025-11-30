// lib/core/services/dio_client.dart
import 'dart:async';
import 'package:dio/dio.dart';
// import 'package:shared_preferences/shared_preferences.dart';/
import 'token_store.dart';

/// Singleton Dio client with auth interceptor + logging
class DioClient {
  static final DioClient _instance = DioClient._internal();
  final Dio dio;

  factory DioClient() => _instance;

  DioClient._internal()
    : dio = Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 20),
          receiveTimeout: const Duration(seconds: 20),
          // set a baseUrl if most endpoints share it:
          // baseUrl: 'http://192.168.29.202:8080/v1',
          headers: {'Content-Type': 'application/json'},
        ),
      ) {
    dio.interceptors.addAll([
      _AuthInterceptor(dio),
      LogInterceptor(requestBody: true, responseBody: true),
    ]);
  }
}

class _AuthInterceptor extends Interceptor {
  final Dio dio;
  Completer<void>? _refreshCompleter;

  _AuthInterceptor(this.dio);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      final token = await TokenStorage.getAccessToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    } catch (e) {
      // ignore
    }
    return handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    return handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final requestOptions = err.requestOptions;

    // handle 401: try refresh + retry once
    if (err.response?.statusCode == 401 &&
        requestOptions.extra['retried'] != true) {
      // If a refresh is already in progress, wait for it
      if (_refreshCompleter != null) {
        await _refreshCompleter!.future;
      } else {
        _refreshCompleter = Completer<void>();
        try {
          final refreshed = await _performRefresh();
          _refreshCompleter!.complete();
          _refreshCompleter = null;
          if (!refreshed) {
            // refresh failed -> forward original error
            return handler.next(err);
          }
        } catch (e) {
          _refreshCompleter!.complete();
          _refreshCompleter = null;
          return handler.next(err);
        }
      }

      // after refresh try retrying the original request with new token
      try {
        final newToken = await TokenStorage.getAccessToken();
        final opts = Options(
          method: requestOptions.method,
          headers: Map<String, dynamic>.from(requestOptions.headers),
          responseType: requestOptions.responseType,
          extra: {...requestOptions.extra, 'retried': true},
        );
        if (newToken != null && newToken.isNotEmpty) {
          opts.headers?['Authorization'] = 'Bearer $newToken';
        }

        final cloneResp = await dio.request(
          requestOptions.path,
          data: requestOptions.data,
          queryParameters: requestOptions.queryParameters,
          options: opts,
        );

        return handler.resolve(cloneResp);
      } catch (e) {
        return handler.next(err);
      }
    }

    // non-401 or already retried
    return handler.next(err);
  }

  /// Call your refresh token endpoint here.
  /// Returns true if refresh succeeded and saved new tokens.
  Future<bool> _performRefresh() async {
    try {
      final refreshToken = await TokenStorage.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) return false;

      // use a Dio instance without this interceptor to avoid loops
      final plain = Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
          headers: {'Content-Type': 'application/json'},
        ),
      );

      // Adjust URL/payload to your API spec
      const refreshUrl = 'http://192.168.29.202:8080/v1/m/auth/refresh';

      final response = await plain.post(
        refreshUrl,
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        final newAccess = data['accessToken'] as String?;
        final newRefresh = data['refreshToken'] as String?;
        if (newAccess != null && newAccess.isNotEmpty) {
          await TokenStorage.saveAccessToken(newAccess);
          if (newRefresh != null && newRefresh.isNotEmpty) {
            await TokenStorage.saveRefreshToken(newRefresh);
          }
          return true;
        }
      }
    } catch (e) {
      print('Refresh token failed: $e');
    }
    return false;
  }
}
