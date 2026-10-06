import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../config/env.dart';
import 'api_exception.dart';

/// Thin wrapper around Dio for talking to Lifecome-Backen. Callers get back decoded JSON or
/// an [ApiException] - Dio's own exception types never leak past this class.
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
  String? _accessToken;

  /// Called when a request made *with* a session token is rejected as unauthenticated (the token
  /// expired or was revoked), so the app can send the user back to sign in.
  void Function()? onUnauthorized;

  /// The current session token, if signed in.
  String? get accessToken => _accessToken;

  /// Set once signed in so subsequent requests are authenticated; cleared on sign out.
  set accessToken(String? token) {
    _accessToken = token;
    if (token == null) {
      _dio.options.headers.remove('Authorization');
    } else {
      _dio.options.headers['Authorization'] = 'Bearer $token';
    }
  }

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? data,
    Map<String, String>? headers,
  }) => _send<Map<String, dynamic>>(
    () => _dio.post<Map<String, dynamic>>(
      path,
      data: data,
      options: Options(headers: headers),
    ),
    (body) => body ?? const {},
  );

  Future<Map<String, dynamic>> put(String path, {Map<String, dynamic>? data}) =>
      _send<Map<String, dynamic>>(
        () => _dio.put<Map<String, dynamic>>(path, data: data),
        (body) => body ?? const {},
      );

  Future<Map<String, dynamic>> patch(
    String path, {
    Map<String, dynamic>? data,
  }) => _send<Map<String, dynamic>>(
    () => _dio.patch<Map<String, dynamic>>(path, data: data),
    (body) => body ?? const {},
  );

  Future<Map<String, dynamic>> getMap(String path) =>
      _send<Map<String, dynamic>>(
        () => _dio.get<Map<String, dynamic>>(path),
        (body) => body ?? const {},
      );

  Future<List<dynamic>> getList(String path) => _send<List<dynamic>>(
    () => _dio.get<List<dynamic>>(path),
    (body) => body ?? const [],
  );

  Future<Map<String, dynamic>> delete(String path) =>
      _send<Map<String, dynamic>>(
        () => _dio.delete<Map<String, dynamic>>(path),
        (body) => body ?? const {},
      );

  Future<Uint8List> getBytes(String path) => _send<List<int>>(
    () => _dio.get<List<int>>(
      path,
      options: Options(responseType: ResponseType.bytes),
    ),
    (body) => body ?? const <int>[],
  ).then(Uint8List.fromList);

  Future<T> _send<T>(
    Future<Response<dynamic>> Function() request,
    T Function(dynamic body) decode,
  ) async {
    try {
      final response = await request();
      return decode(response.data);
    } on DioException catch (error) {
      final exception = _toApiException(error);
      if (exception.statusCode == 401 && _accessToken != null) {
        onUnauthorized?.call();
      }
      throw exception;
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
        return ApiException(
          'Something went wrong. Please try again.',
          statusCode: error.response?.statusCode,
        );
    }
  }
}
