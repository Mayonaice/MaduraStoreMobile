import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:developer' as developer;
import 'package:js/js.dart' as js_pkg;
import 'dart:async';

/// Helper class untuk menangani permintaan HTTP di Flutter Web
/// dengan mengatasi masalah CORS
class WebCorsClient {
  static const Duration timeoutDuration = Duration(seconds: 30);
  static const bool _useJsonp = false; // JSONP tidak digunakan untuk URL baru
  static const String _apiBaseUrl = 'http://penantian-001-site1.qtempurl.com';
  
  /// Mengecek apakah browser adalah Microsoft Edge
  static bool isEdgeBrowser() {
    // Tidak dapat mengakses navigator di mobile
    return false;
  }
  
  /// Mendapatkan origin URL untuk header
  static String getOrigin() {
    // Gunakan nilai default untuk mobile
    return 'http://localhost';
  }
  
  /// Memperbaiki URL .ashx menggunakan fungsi JavaScript
  static String fixAshxUrl(String url) {
    // Log URL sebelum diperbaiki
    developer.log('URL sebelum diperbaiki: $url', name: 'WEB_CORS');
    return url;
  }
  
  /// Menambahkan proxy CORS jika diperlukan
  static String buildUrl(String url) {
    // Preservasi query string
    String baseUrl = url;
    String queryString = '';
    
    if (url.contains('?')) {
      final parts = url.split('?');
      baseUrl = parts[0];
      queryString = parts.length > 1 ? '?${parts[1]}' : '';
    }
    
    // Perbaiki URL untuk handler .ashx
    baseUrl = fixAshxUrl(baseUrl);
    
    // Gabungkan kembali dengan query string
    url = baseUrl + queryString;
    
    developer.log('URL akhir: $url', name: 'WEB_CORS');
    
    // Jika URL sudah mengarah ke production server, gunakan langsung
    if (url.startsWith(_apiBaseUrl)) {
      return url;
    }
    
    // Tanpa proxy untuk API production
    return url;
  }
  
  /// Mengambil data dengan JSONP (JavaScript callback)
  static Future<Map<String, dynamic>> getWithJsonp(String url) async {
    // JSONP tidak didukung di mobile
    throw UnsupportedError('JSONP tidak didukung di platform mobile');
  }

  /// GET request dengan penanganan CORS
  static Future<http.Response> get(String url, {Map<String, String>? headers}) async {
    final targetUrl = buildUrl(url);
    developer.log('CORS GET: $targetUrl', name: 'WEB_CORS');
    
    // Headers yang sesuai untuk mengatasi masalah CORS
    final Map<String, String> fullHeaders = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'X-Requested-With': 'XMLHttpRequest',
      'Origin': 'http://localhost',
      if (headers != null) ...headers,
    };
    
    try {
      final response = await http.get(
        Uri.parse(targetUrl),
        headers: fullHeaders,
      ).timeout(timeoutDuration);
      
      developer.log('Response Status: ${response.statusCode}', name: 'WEB_CORS');
      return response;
    } catch (e) {
      developer.log('CORS Error: $e', name: 'WEB_CORS');
      rethrow;
    }
  }

  /// POST request dengan penanganan CORS
  static Future<http.Response> post(String url, {Map<String, String>? headers, Object? body}) async {
    final targetUrl = buildUrl(url);
    developer.log('CORS POST: $targetUrl', name: 'WEB_CORS');
    
    // Headers yang sesuai untuk mengatasi masalah CORS
    final Map<String, String> fullHeaders = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'X-Requested-With': 'XMLHttpRequest',
      'Origin': 'http://localhost',
      if (headers != null) ...headers,
    };
    
    try {
      developer.log('POST Headers: $fullHeaders', name: 'WEB_CORS');
      developer.log('POST Body: $body', name: 'WEB_CORS');
      
      final response = await http.post(
        Uri.parse(targetUrl),
        headers: fullHeaders,
        body: body,
      ).timeout(timeoutDuration);
      
      developer.log('Response Status: ${response.statusCode}', name: 'WEB_CORS');
      developer.log('Response Body: ${response.body}', name: 'WEB_CORS');
      return response;
    } catch (e) {
      developer.log('CORS Error: $e', name: 'WEB_CORS');
      rethrow;
    }
  }

  /// PUT request dengan penanganan CORS
  static Future<http.Response> put(String url, {Map<String, String>? headers, Object? body}) async {
    final targetUrl = buildUrl(url);
    developer.log('CORS PUT: $targetUrl', name: 'WEB_CORS');
    
    // Headers yang sesuai untuk mengatasi masalah CORS
    final Map<String, String> fullHeaders = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'X-Requested-With': 'XMLHttpRequest',
      'Origin': 'http://localhost',
      if (headers != null) ...headers,
    };
    
    try {
      final response = await http.put(
        Uri.parse(targetUrl),
        headers: fullHeaders,
        body: body,
      ).timeout(timeoutDuration);
      
      developer.log('Response Status: ${response.statusCode}', name: 'WEB_CORS');
      return response;
    } catch (e) {
      developer.log('CORS Error: $e', name: 'WEB_CORS');
      rethrow;
    }
  }

  /// DELETE request dengan penanganan CORS
  static Future<http.Response> delete(String url, {Map<String, String>? headers}) async {
    final targetUrl = buildUrl(url);
    developer.log('CORS DELETE: $targetUrl', name: 'WEB_CORS');
    
    // Headers yang sesuai untuk mengatasi masalah CORS
    final Map<String, String> fullHeaders = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'X-Requested-With': 'XMLHttpRequest',
      'Origin': 'http://localhost',
      if (headers != null) ...headers,
    };
    
    try {
      final response = await http.delete(
        Uri.parse(targetUrl),
        headers: fullHeaders,
      ).timeout(timeoutDuration);
      
      developer.log('Response Status: ${response.statusCode}', name: 'WEB_CORS');
      return response;
    } catch (e) {
      developer.log('CORS Error: $e', name: 'WEB_CORS');
      rethrow;
    }
  }
  
  /// Mendapatkan URL lokasi saat ini
  static String get location => '';
  
  /// Mendapatkan origin URL saat ini
  static String get origin => '';
}