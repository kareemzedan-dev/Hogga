import 'package:dio/dio.dart';
import '../utils/app_strings.dart';

class ApiErrorHandler {
  static Future<void> ensureConnected(RequestOptions requestOptions) async {
    // Disabled manual check as it's often flaky and Dio handles connection errors natively.
    return;
  }

  static DioException normalizeDioException(
    DioException error, {
    String fallbackMessage = AppStrings.errorServer,
  }) {
    return DioException(
      requestOptions: error.requestOptions,
      response: error.response,
      type: error.type,
      error: error.error,
      stackTrace: error.stackTrace,
      message: _mapDioMessage(error, fallbackMessage: fallbackMessage),
    );
  }

  static String _mapDioMessage(
    DioException error, {
    required String fallbackMessage,
  }) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return AppStrings.requestTimedOut;
      case DioExceptionType.connectionError:
        return AppStrings.noInternetConnection;
      case DioExceptionType.cancel:
        return AppStrings.operationCancelled;
      case DioExceptionType.badResponse:
        return _mapBadResponseMessage(error, fallbackMessage: fallbackMessage);
      case DioExceptionType.unknown:
        final message = _extractMessage(error.response?.data);
        if (message != null && !_looksCorrupted(message)) {
          return message;
        }
        return AppStrings.unexpectedError;
      case DioExceptionType.badCertificate:
        return AppStrings.errorServer;
    }
  }

  static String _mapBadResponseMessage(
    DioException error, {
    required String fallbackMessage,
  }) {
    final statusCode = error.response?.statusCode;
    final message = _extractMessage(error.response?.data);
    final safeMessage = (message != null && !_looksCorrupted(message))
        ? message
        : fallbackMessage;

    if (statusCode == 401) {
      return AppStrings.sessionExpired;
    }

    if (statusCode == 408 || statusCode == 504) {
      return AppStrings.requestTimedOut;
    }

    return safeMessage;
  }

  static String? _extractMessage(dynamic data) {
    if (data is Map) {
      final errors = data['errors'];
      if (errors is Map && errors.isNotEmpty) {
        final firstError = errors.values.first;
        if (firstError is List && firstError.isNotEmpty) {
          return firstError.first.toString();
        }
        if (firstError != null) {
          return firstError.toString();
        }
      }

      final message = data['message'];
      if (message != null) {
        return message.toString();
      }
    }

    if (data is String && data.trim().isNotEmpty) {
      return data;
    }

    return null;
  }

  static bool _looksCorrupted(String value) {
    return RegExp(r'[ظطØÙÃ]{3,}').hasMatch(value);
  }
}
