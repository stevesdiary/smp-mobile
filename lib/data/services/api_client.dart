import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  // Use 10.0.2.2 for Android emulator to reach host localhost
  static const String baseUrl = 'http://10.0.2.2:4000';

  String? _token;
  String? _tenantHint;

  void setToken(String token) => _token = token;
  void clearToken() => _token = null;
  void setTenantHint(String hint) => _tenantHint = hint;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
        if (_tenantHint != null && _tenantHint!.isNotEmpty) 'X-Tenant-ID': _tenantHint!,
      };

  static const _timeout = Duration(seconds: 15);

  Future<Map<String, dynamic>> post(String path, Map<String, dynamic> body) async {
    final res = await http.post(
      Uri.parse('$baseUrl$path'),
      headers: _headers,
      body: jsonEncode(body),
    ).timeout(_timeout);
    return _decode(res);
  }

  Future<dynamic> get(String path, {Map<String, String>? query}) async {
    final uri = Uri.parse('$baseUrl$path').replace(queryParameters: query);
    final res = await http.get(uri, headers: _headers).timeout(_timeout);
    return _decode(res);
  }

  dynamic _decode(http.Response res) {
    final body = jsonDecode(res.body);
    if (res.statusCode >= 400) {
      throw ApiException(res.statusCode, body['error'] ?? 'Request failed');
    }
    return body;
  }
}

class ApiException implements Exception {
  final int statusCode;
  final String message;
  ApiException(this.statusCode, this.message);

  @override
  String toString() => 'ApiException($statusCode): $message';
}

// Singleton
final apiClient = ApiClient();
