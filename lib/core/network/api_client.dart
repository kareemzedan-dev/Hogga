import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../config/shared_preference/shared_preference.dart';
import '../constants/end_points.dart';

import 'api_error_handler.dart';

class ApiClient {
  final Dio dio;
  final VoidCallback? onUnauthorized;
  static const String baseUrl = AppEndPoints.baseUrl;

  ApiClient({required this.dio, this.onUnauthorized}) {
    dio.options.baseUrl = baseUrl;
    dio.options.connectTimeout = const Duration(seconds: 120);
    dio.options.receiveTimeout = const Duration(seconds: 120);
    dio.options.sendTimeout = const Duration(seconds: 120);
    dio.options.headers = {
      'Authorization': 'Bearer ${AppPreferences().token ?? ''}',
      'Accept': 'application/json',
    };

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = AppPreferences().token;
          final locale = AppPreferences().locale;

          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          options.headers['Accept'] = 'application/json';
          options.headers['Accept-Language'] = locale;
          options.headers['lang'] =
              locale; // Keeping this as a backup common practice

          return handler.next(options);
        },
        onError: (DioException e, handler) {
          if (e.response?.statusCode == 401) {
            onUnauthorized?.call();
          }
          return handler.next(e);
        },
      ),
    );

    if (kDebugMode) {
      dio.interceptors.add(
        LogInterceptor(
          request: true,
          requestBody: true,
          responseBody: true,
          requestHeader: true,
          responseHeader: false,
          error: true,
        ),
      );
    }
  }

  final Map<String, Future<Response>> _inFlightRequests = {};

  String _buildKey(
    String method,
    String path,
    Map<String, dynamic>? queryParameters,
    dynamic data,
  ) {
    return '$method:$path:${queryParameters?.toString()}:${data?.toString()}';
  }

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    final key = _buildKey('GET', path, queryParameters, null);

    if (_inFlightRequests.containsKey(key)) {
      debugPrint('🚀 Deduplicating GET request: $path');
      return _inFlightRequests[key]!;
    }

    final future = _executeGet(
      path,
      queryParameters: queryParameters,
      options: options,
    );
    _inFlightRequests[key] = future;

    try {
      return await future;
    } finally {
      _inFlightRequests.remove(key);
    }
  }

  Future<Response> _executeGet(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      await ApiErrorHandler.ensureConnected(RequestOptions(path: path));
      return await dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw ApiErrorHandler.normalizeDioException(e);
    } catch (_) {
      throw DioException(
        requestOptions: RequestOptions(path: path),
        type: DioExceptionType.unknown,
        message: 'unexpectedError',
      );
    }
  }

  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    ProgressCallback? onSendProgress,
  }) async {
    if (kDebugMode && data is FormData) {
      debugPrint('FormData request -> $path');
      for (final file in data.files) {
        debugPrint('File field: ${file.key} (${file.value.filename})');
      }
    }
    try {
      await ApiErrorHandler.ensureConnected(RequestOptions(path: path));
      return await dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        onSendProgress: onSendProgress,
      );
    } on DioException catch (e) {
      throw ApiErrorHandler.normalizeDioException(e);
    } catch (_) {
      throw DioException(
        requestOptions: RequestOptions(path: path),
        type: DioExceptionType.unknown,
        message: 'unexpectedError',
      );
    }
  }

  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      await ApiErrorHandler.ensureConnected(RequestOptions(path: path));
      return await dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw ApiErrorHandler.normalizeDioException(e);
    } catch (_) {
      throw DioException(
        requestOptions: RequestOptions(path: path),
        type: DioExceptionType.unknown,
        message: 'unexpectedError',
      );
    }
  }

  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      await ApiErrorHandler.ensureConnected(RequestOptions(path: path));
      return await dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw ApiErrorHandler.normalizeDioException(e);
    } catch (_) {
      throw DioException(
        requestOptions: RequestOptions(path: path),
        type: DioExceptionType.unknown,
        message: 'unexpectedError',
      );
    }
  }
}
