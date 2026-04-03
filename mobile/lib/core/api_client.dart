import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  String get baseUrl => _baseUrl;
  String get _baseUrl => dotenv.get('API_BASE_URL', fallback: 'http://10.0.2.2:8000');
  String get _apiKey => dotenv.get('API_KEY', fallback: '');

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'X-API-Key': _apiKey,
      };

  Future<http.Response> get(String endpoint) {
    final url = Uri.parse('$_baseUrl$endpoint');
    return http.get(url, headers: _headers).timeout(const Duration(seconds: 30));
  }

  Future<http.Response> post(String endpoint, Map<String, dynamic> body) {
    final url = Uri.parse('$_baseUrl$endpoint');
    return http.post(url, headers: _headers, body: jsonEncode(body))
        .timeout(const Duration(seconds: 30));
  }
}
