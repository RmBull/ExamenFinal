import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'api_exception.dart';

class ApiClient {
  static const _baseUrl = 'http://143.198.118.203:8100';
  static const _credentials = 'test:test2023';
  static const Duration _timeout = Duration(seconds: 12);

  final http.Client _http;

  ApiClient({http.Client? httpClient}) : _http = httpClient ?? http.Client();

  Map<String, String> get _headers => {
        HttpHeaders.authorizationHeader:
            'Basic ${base64Encode(utf8.encode(_credentials))}',
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.connectionHeader: 'close',
        HttpHeaders.acceptHeader: 'application/json',
      };

  Uri _buildUri(String path) {
    final normalized = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$_baseUrl$normalized');
  }

  Future<Map<String, dynamic>> getJson(String path) async {
    try {
      final response = await _http
          .get(_buildUri(path), headers: _headers)
          .timeout(_timeout);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (response.body.isEmpty) {
          return const {};
        }
        final data = jsonDecode(response.body);
        if (data is Map<String, dynamic>) {
          return data;
        }
        throw ApiException(
            response.statusCode, 'Formato de respuesta inesperado');
      }

      throw ApiException(response.statusCode, response.body);
    } on SocketException catch (e) {
      throw ApiException(0, 'Error de red: ${e.message}');
    } on http.ClientException catch (e) {
      throw ApiException(0, 'Error de conexión: ${e.message}');
    } on FormatException catch (e) {
      throw ApiException(500, 'Respuesta JSON inválida: ${e.message}');
    } on TimeoutException {
      throw ApiException(408, 'La petición excedió el tiempo de espera');
    }
  }

  Future<Map<String, dynamic>> postJson(
    String path,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await _http
          .post(
            _buildUri(path),
            headers: _headers,
            body: jsonEncode(body),
          )
          .timeout(_timeout);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (response.body.isEmpty) {
          return const {};
        }
        final data = jsonDecode(response.body);
        if (data is Map<String, dynamic>) {
          return data;
        }
        throw ApiException(
            response.statusCode, 'Formato de respuesta inesperado');
      }

      throw ApiException(response.statusCode, response.body);
    } on SocketException catch (e) {
      throw ApiException(0, 'Error de red: ${e.message}');
    } on http.ClientException catch (e) {
      throw ApiException(0, 'Error de conexión: ${e.message}');
    } on FormatException catch (e) {
      throw ApiException(500, 'Respuesta JSON inválida: ${e.message}');
    } on TimeoutException {
      throw ApiException(408, 'La petición excedió el tiempo de espera');
    }
  }

  void dispose() {
    _http.close();
  }
}
