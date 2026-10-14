import 'dart:async';

import 'package:dio/dio.dart';

import '../config/env.dart';
import 'api_exception.dart';

/// Thin wrapper around Dio for talking to Lifecome-Backend. Callers get back decoded JSON or
/// an [ApiException] — Dio's own exception types never leak past this class.
///
/// The patient's access token lives here, in memory. [SessionManager] puts it
/// in (and, for a remembered sign-in, saves it to the device's secure
/// storage); every request except the public identity ones then carries it.
class ApiClient {
  ApiClient({Dio? dio, this.onSessionExpired})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: Env.apiBaseUrl,
              connectTimeout: const Duration(seconds: 15),
              receiveTimeout: const Duration(seconds: 15),
              headers: {'Accept': 'application/json'},
            ),
          );

  final Dio _dio;

  /// Called once when the backend rejects the saved token (it expired, or the
  /// account was signed out elsewhere). The app signs the person out and sends
  /// them to the sign-in screen.
  final FutureOr<void> Function()? onSessionExpired;

  String? _accessToken;

  /// Set once signed in so subsequent requests are authenticated; cleared on sign out.
  set accessToken(String? token) => _accessToken = token;

  bool get hasAccessToken => _accessToken != null;

  String get baseUrl => _dio.options.baseUrl;

  /// The `Authorization` header, for loading something outside this client —
  /// the profile photo goes through `Image.network`, for instance.
  Map<String, String> get authHeaders => {
    if (_accessToken != null) 'Authorization': 'Bearer $_accessToken',
  };

  /// `GET` a single JSON object.
  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? query,
  }) async => _asMap(await _send('GET', path, query: query));

  /// `GET` a JSON array (a list endpoint).
  Future<List<dynamic>> getList(
    String path, {
    Map<String, dynamic>? query,
  }) async => _asList(await _send('GET', path, query: query));

  /// `POST`. A `204 No Content` reply comes back as an empty map.
  ///
  /// [authenticated] is false for the public sign-in / sign-up endpoints,
  /// which must not carry a (possibly stale) token. Pass [idempotencyKey] for
  /// anything that must not run twice — see `newIdempotencyKey`.
  Future<Map<String, dynamic>> post(
    String path, {
    Object? data,
    bool authenticated = true,
    String? idempotencyKey,
  }) async => _asMap(
    await _send(
      'POST',
      path,
      data: data,
      authenticated: authenticated,
      idempotencyKey: idempotencyKey,
    ),
  );

  Future<Map<String, dynamic>> put(String path, {Object? data}) async =>
      _asMap(await _send('PUT', path, data: data));

  Future<Map<String, dynamic>> patch(String path, {Object? data}) async =>
      _asMap(await _send('PATCH', path, data: data));

  Future<void> delete(String path) async {
    await _send('DELETE', path);
  }

  Future<dynamic> _send(
    String method,
    String path, {
    Object? data,
    Map<String, dynamic>? query,
    bool authenticated = true,
    String? idempotencyKey,
  }) async {
    final headers = <String, dynamic>{
      if (authenticated && _accessToken != null)
        'Authorization': 'Bearer $_accessToken',
      'Idempotency-Key': ?idempotencyKey,
    };

    try {
      final response = await _dio.request<dynamic>(
        path,
        data: data,
        queryParameters: _cleanQuery(query),
        options: Options(method: method, headers: headers),
      );
      return response.data;
    } on DioException catch (error) {
      final exception = _toApiException(error);
      if (authenticated &&
          _accessToken != null &&
          exception.statusCode == 401) {
        _accessToken = null;
        await onSessionExpired?.call();
        throw const ApiException(
          ApiException.sessionExpiredMessage,
          code: ApiException.sessionExpiredCode,
          statusCode: 401,
        );
      }
      throw exception;
    }
  }

  /// Drops empty filters so `?specialty=` is never sent.
  Map<String, dynamic>? _cleanQuery(Map<String, dynamic>? query) {
    if (query == null) return null;
    final cleaned = {
      for (final entry in query.entries)
        if (entry.value != null && '${entry.value}'.isNotEmpty)
          entry.key: entry.value,
    };
    return cleaned.isEmpty ? null : cleaned;
  }

  Map<String, dynamic> _asMap(dynamic body) {
    if (body is Map<String, dynamic>) return body;
    return const {};
  }

  List<dynamic> _asList(dynamic body) {
    if (body is List<dynamic>) return body;
    return const [];
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
          fieldErrors: _fieldErrors(errorBody['details']),
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

  /// The backend reports validation problems as `details: [{path, message}]`.
  Map<String, String> _fieldErrors(Object? details) {
    if (details is! List) return const {};
    final errors = <String, String>{};
    for (final item in details) {
      if (item is Map<String, dynamic>) {
        final path = item['path'];
        final message = item['message'];
        if (path is String && path.isNotEmpty && message is String) {
          errors.putIfAbsent(path, () => message);
        }
      }
    }
    return errors;
  }
}
