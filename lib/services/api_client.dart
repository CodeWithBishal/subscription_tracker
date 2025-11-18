import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';

class ApiClient {
  ApiClient({required this.baseUrl, this.apiKey, http.Client? httpClient})
    : _httpClient = httpClient ?? http.Client();

  final String baseUrl;
  final String? apiKey;
  final http.Client _httpClient;

  Future<Map<String, dynamic>> get({
    Map<String, String>? queryParameters,
  }) async {
    final uri = _buildUri(queryParameters);
    final response = await _httpClient
        .get(uri, headers: _headers())
        .timeout(AppConfig.requestTimeout);
    return _decodeResponse(response);
  }

  Future<Map<String, dynamic>> post({
    Map<String, String>? queryParameters,
    Map<String, dynamic>? body,
  }) async {
    final uri = _buildUri(queryParameters);
    final response = await _httpClient
        .post(
          uri,
          headers: _headers(),
          body: jsonEncode(body ?? <String, dynamic>{}),
        )
        .timeout(AppConfig.requestTimeout);
    return _decodeResponse(response);
  }

  Future<Map<String, dynamic>> put({
    Map<String, String>? queryParameters,
    Map<String, dynamic>? body,
  }) async {
    final uri = _buildUri(queryParameters);
    final response = await _httpClient
        .put(
          uri,
          headers: _headers(),
          body: jsonEncode(body ?? <String, dynamic>{}),
        )
        .timeout(AppConfig.requestTimeout);
    return _decodeResponse(response);
  }

  Uri _buildUri(Map<String, String>? queryParameters) {
    final uri = Uri.parse(baseUrl);
    final merged = {
      if (uri.hasQuery) ...uri.queryParameters,
      if (queryParameters != null) ...queryParameters,
      if ((apiKey ?? '').isNotEmpty) 'apiKey': apiKey!,
    };
    return uri.replace(queryParameters: merged.isEmpty ? null : merged);
  }

  Map<String, String> _headers() => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  Map<String, dynamic> _decodeResponse(http.Response response) {
    final payload = response.body.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (payload is Map<String, dynamic>) {
        return payload;
      }
      return {'data': payload};
    }

    final message = payload['message']?.toString() ?? 'Unexpected error';
    throw ApiException(response.statusCode, message);
  }

  void dispose() => _httpClient.close();
}

class ApiException implements Exception {
  ApiException(this.statusCode, this.message);

  final int statusCode;
  final String message;

  @override
  String toString() => 'ApiException($statusCode): $message';
}
