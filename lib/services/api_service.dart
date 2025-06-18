import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as developer;
import 'web_cors.dart'; // Import helper untuk menangani CORS

class ApiService {
  // Base URL dan konfigurasi
  static const bool _debug = true; 
  static const String _productionUrl = 'http://penantian-001-site1.qtempurl.com';
  static const String _localUrl = 'http://localhost:58971';
  static const String _ipUrl = 'http://127.0.0.1:58971'; 
  static const String _browserUrl = 'http://penantian-001-site1.qtempurl.com'; 
  
  static const Duration timeoutDuration = Duration(seconds: 30);
  static const String tokenKey = 'auth_token';

  // Headers
  static Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'X-Requested-With': 'XMLHttpRequest',
  };

  static String getBaseUrl() {
    if (_debug) {
      developer.log('Using browser URL: $_browserUrl', name: 'API');
    }
    return _browserUrl;
  }

  static Future<Map<String, dynamic>> testConnection() async {
    List<String> urlsToTry = [
      '$_browserUrl/api/test.ashx',
      '$_productionUrl/api/test.ashx',
      '$_localUrl/api/test.ashx',
      '$_ipUrl/api/test.ashx',
    ];
    
    Map<String, dynamic>? finalResult;
    
    for (String url in urlsToTry) {
      try {
        developer.log('Testing API connection to $url via WebCorsClient', name: 'API');
        
        final result = await WebCorsClient.testConnection(url);
        if (result['success'] == true) {
          developer.log('Connection successful with URL: $url', name: 'API');
          return result;
        } else {
          finalResult = result;
        }
      } catch (e) {
        developer.log('Connection Test Error for $url: ${e.toString()}', name: 'API');
        finalResult = {
          'success': false,
          'message': 'Connection error: ${e.toString()}'
        };
      }
    }
    
    return finalResult ?? {
      'success': false,
      'message': 'All connection attempts failed'
    };
  }

  // Get stored token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(tokenKey);
  }

  // Set token
  static Future<void> setToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(tokenKey, token);
    _headers['Authorization'] = 'Bearer $token';
  }

  // Clear token
  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(tokenKey);
    _headers.remove('Authorization');
  }

  // Initialize headers with token if available
  static Future<void> initializeHeaders() async {
    final token = await getToken();
    if (token != null && token.isNotEmpty) {
      _headers['Authorization'] = 'Bearer $token';
    }
  }

  // GET request
  static Future<Map<String, dynamic>> get(String endpoint, {Map<String, dynamic>? queryParams}) async {
    await initializeHeaders();
    
    // Pastikan endpoint memiliki awalan 'api/' jika belum
    String finalEndpoint = endpoint;
    if (!endpoint.startsWith('api/') && !endpoint.startsWith('/api/')) {
      finalEndpoint = 'api/$endpoint';
    }
    
    final Uri uri = Uri.parse('${getBaseUrl()}/$finalEndpoint').replace(
      queryParameters: queryParams?.map((key, value) => MapEntry(key, value.toString())),
    );
    
    try {
      developer.log('GET Request: $uri', name: 'API');
      developer.log('Headers: $_headers', name: 'API');

      final response = await WebCorsClient.get(uri.toString(), headers: _headers);
      
      developer.log('Response Status: ${response.statusCode}', name: 'API');
      developer.log('Response Body: ${response.body}', name: 'API');
      
      return _handleResponse(response);
    } catch (e) {
      developer.log('GET Error: ${e.toString()}', name: 'API');
      return _handleError(e);
    }
  }

  // POST request
  static Future<Map<String, dynamic>> post(String endpoint, {Map<String, dynamic>? data}) async {
    await initializeHeaders();
    
    // Pastikan endpoint memiliki awalan 'api/' jika belum
    String finalEndpoint = endpoint;
    if (!endpoint.startsWith('api/') && !endpoint.startsWith('/api/')) {
      finalEndpoint = 'api/$endpoint';
    }
    
    final Uri uri = Uri.parse('${getBaseUrl()}/$finalEndpoint');
    
    try {
      developer.log('POST Request: $uri', name: 'API');
      developer.log('Headers: $_headers', name: 'API');
      developer.log('Body: ${data != null ? json.encode(data) : "null"}', name: 'API');
      
      // Gunakan WebCorsClient untuk menangani CORS di Flutter Web
      final response = await WebCorsClient.post(
        uri.toString(),
        headers: _headers,
        body: data != null ? json.encode(data) : null,
      );
      
      developer.log('Response Status: ${response.statusCode}', name: 'API');
      developer.log('Response Body: ${response.body}', name: 'API');
      
      return _handleResponse(response);
    } catch (e) {
      developer.log('POST Error: ${e.toString()}', name: 'API');
      return _handleError(e);
    }
  }

  // PUT request
  static Future<Map<String, dynamic>> put(String endpoint, {Map<String, dynamic>? data}) async {
    await initializeHeaders();
    
    // Pastikan endpoint memiliki awalan 'api/' jika belum
    String finalEndpoint = endpoint;
    if (!endpoint.startsWith('api/') && !endpoint.startsWith('/api/')) {
      finalEndpoint = 'api/$endpoint';
    }
    
    final Uri uri = Uri.parse('${getBaseUrl()}/$finalEndpoint');
    
    try {
      developer.log('PUT Request: $uri', name: 'API');
      developer.log('Headers: $_headers', name: 'API');
      developer.log('Body: ${data != null ? json.encode(data) : "null"}', name: 'API');
      
      // Gunakan WebCorsClient untuk menangani CORS di Flutter Web
      final response = await WebCorsClient.put(
        uri.toString(),
        headers: _headers,
        body: data != null ? json.encode(data) : null,
      );
      
      developer.log('Response Status: ${response.statusCode}', name: 'API');
      developer.log('Response Body: ${response.body}', name: 'API');
      
      return _handleResponse(response);
    } catch (e) {
      developer.log('PUT Error: ${e.toString()}', name: 'API');
      return _handleError(e);
    }
  }

  // Handle API response
  static Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return {'success': true};
      }
      
      try {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse is Map<String, dynamic>) {
          return jsonResponse;
        } else {
          return {'success': true, 'data': jsonResponse};
        }
      } catch (e) {
        developer.log('JSON Parse Error: ${e.toString()}', name: 'API');
        return {'success': false, 'message': 'Respons tidak valid: ${e.toString()}'};
      }
    } else if (response.statusCode == 401) {
      // Unauthorized - token might be expired
      clearToken();
      return {'success': false, 'message': 'Sesi Anda telah berakhir. Silakan login kembali.'};
    } else {
      String errorMessage = 'Terjadi kesalahan: ${response.statusCode}';
      
      try {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse is Map && jsonResponse.containsKey('message')) {
          errorMessage = jsonResponse['message'];
        }
      } catch (_) {}
      
      developer.log('HTTP Error: $errorMessage', name: 'API');
      return {'success': false, 'message': errorMessage};
    }
  }

  // Handle error
  static Map<String, dynamic> _handleError(dynamic error) {
    String errorMessage = 'Terjadi kesalahan: ${error.toString()}';
    
    if (error is http.ClientException) {
      errorMessage = 'Gagal terhubung ke server. Periksa koneksi Anda.';
    } else if (error.toString().contains('timeout')) {
      errorMessage = 'Permintaan timeout. Coba lagi nanti.';
    }
    
    developer.log('Error Handler: $errorMessage', name: 'API');
    return {'success': false, 'message': errorMessage};
  }
}