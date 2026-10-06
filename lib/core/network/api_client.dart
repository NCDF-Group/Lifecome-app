import 'package:dio/dio.dart';

import '../config/env.dart';
import 'api_exception.dart';

/// Thin wrapper around Dio for talking to Lifecome-Backen. Callers get back decoded JSON or
/// an [ApiException] — Dio's own exception types never leak past this class.
class ApiClient {
  ApiClient({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: Env.apiBaseUrl,
              connectTimeout: const Duration(seconds: 15),
              receiveTimeout: const Duration(seconds: 15),
            ),
          );

  final Dio _dio;

  /// Set once signed in so subsequent requests are authenticated; cleared on sign out.
  set accessToken(String? token) {
    if (token == null) {
      _dio.options.headers.remove('Authorization');
    } else {
      _dio.options.headers['Authorization'] = 'Bearer $token';
    }
  }

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? data,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(path, data: data);
      return response.data ?? const {};
    } on DioException catch (error) {
      throw _toApiException(error);
    }
  }

  ApiException _toApiException(DioException error) {
    final data = error.response?.data;
    if (data is Map<String, dynamic>) {
      final errorBody = data['error'];
      if (errorBody is Map<String, dynamic>) {
        return ApiException(
          errorBody['message'] as String? ??
              'Something went wrong. Please try again.',
          code: errorBody['code'] as String?,
          statusCode: error.response?.statusCode,
        );
      }
    }

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.connectionError:
        return const ApiException(ApiException.networkMessage);
      default:
        return const ApiException('Something went wrong. Please try again.');
    }
  }
}
