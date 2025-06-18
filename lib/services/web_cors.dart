import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:developer' as developer;
import 'dart:js' as js;
import 'dart:async';

/// Helper class untuk menangani permintaan HTTP di Flutter Web
/// dengan mengatasi masalah CORS
class WebCorsClient {
  static const Duration timeoutDuration = Duration(seconds: 30);
  static const bool _useJsonp = false; // JSONP tidak digunakan untuk URL baru
  static const String _apiBaseUrl = 'http://penantian-001-site1.qtempurl.com';
  
  /// Mengecek apakah browser adalah Microsoft Edge
  static bool isEdgeBrowser() {
    try {
      final userAgent = js.context['navigator']['userAgent'].toString().toLowerCase();
      return userAgent.contains('edg') || userAgent.contains('edge');
    } catch (e) {
      return false;
    }
  }
  
  /// Mendapatkan origin URL untuk header
  static String getOrigin() {
    try {
      return js.context['window']['location']['origin'].toString();
    } catch (e) {
      // Fallback jika tidak berhasil mendapatkan origin
      return 'http://localhost';
    }
  }
  
  /// Memperbaiki URL .ashx menggunakan fungsi JavaScript
  static String fixAshxUrl(String url) {
    try {
      // Log URL sebelum diperbaiki
      developer.log('URL sebelum diperbaiki: $url', name: 'WEB_CORS');
      
      if (url.contains('.ashx') && js.context['window']['fixAshxRequests'] != null) {
        final fixedUrl = js.context.callMethod('fixAshxRequests', [url]);
        if (fixedUrl != null && fixedUrl is String) {
          developer.log('URL .ashx diperbaiki: $url -> $fixedUrl', name: 'WEB_CORS');
          return fixedUrl;
        }
      }
    } catch (e) {
      developer.log('Error memperbaiki URL .ashx: ${e.toString()}', name: 'WEB_CORS');
    }
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
    
    if (_useJsonp && url.contains('/api/test.ashx')) {
      // Gunakan endpoint JSONP sebagai pengganti
      return url.replaceAll('/test.ashx', '/jsonp_test.ashx') + '?callback=handleJSONPResponse';
    }
    
    // Jika mengakses API lokal, mungkin perlu menggunakan proxy CORS
    if (url.contains('localhost') || url.contains('127.0.0.1')) {
      // Gunakan proxy CORS publik jika diperlukan
      return 'https://cors-anywhere.herokuapp.com/$url';
    }
    
    // Tanpa proxy untuk API production
    return url;
  }
  
  /// Mengambil data dengan JSONP (JavaScript callback)
  static Future<Map<String, dynamic>> getWithJsonp(String url) async {
    // Membuat Completer untuk menunggu callback JSONP
    final completer = Completer<Map<String, dynamic>>();
    
    // Menangani callback dari respons JSONP
    js.context['handleJSONPResponse'] = (dynamic data) {
      developer.log('JSONP Response received', name: 'WEB_CORS');
      // Convert JavaScript object to Dart Map
      final Map<String, dynamic> result = Map<String, dynamic>.from(
        Map.castFrom<dynamic, dynamic, String, dynamic>(data as Map)
      );
      completer.complete(result);
    };
    
    // Buat script element untuk JSONP request
    final scriptTag = js.context['document'].createElement('script');
    scriptTag['src'] = url;
    scriptTag['async'] = true;
    scriptTag['type'] = 'text/javascript';
    
    // Handle timeout
    final timer = Timer(timeoutDuration, () {
      if (!completer.isCompleted) {
        completer.completeError('JSONP request timed out');
      }
    });
    
    // Handle script load error
    scriptTag['onerror'] = js.allowInterop((event) {
      timer.cancel();
      if (!completer.isCompleted) {
        completer.completeError('Failed to load JSONP script');
      }
    });
    
    // Tambahkan script ke document
    js.context['document']['head'].appendChild(scriptTag);
    
    try {
      // Tunggu data dari callback
      final result = await completer.future;
      return result;
    } finally {
      // Cleanup - hapus script tag
      if (js.context['document']['head'].contains(scriptTag)) {
        js.context['document']['head'].removeChild(scriptTag);
      }
      timer.cancel();
    }
  }

  /// GET request dengan penanganan CORS
  static Future<http.Response> get(String url, {Map<String, String>? headers}) async {
    final targetUrl = buildUrl(url);
    developer.log('CORS GET: $targetUrl', name: 'WEB_CORS');
    
    // Jika menggunakan JSONP dan endpoint adalah test.ashx, gunakan getWithJsonp
    if (_useJsonp && url.contains('/api/test.ashx')) {
      try {
        final jsonpData = await getWithJsonp(targetUrl);
        // Buat response manual karena JSONP tidak menggunakan HTTP
        return http.Response(
          json.encode(jsonpData),
          200,
          headers: {'content-type': 'application/json'},
        );
      } catch (e) {
        developer.log('JSONP Error: $e', name: 'WEB_CORS');
        // Fallback ke metode normal jika JSONP gagal
      }
    }
    
    // Headers yang sesuai untuk mengatasi masalah CORS
    final Map<String, String> fullHeaders = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'X-Requested-With': 'XMLHttpRequest',
      'Origin': isEdgeBrowser() ? 'http://localhost' : getOrigin(),
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
      'Origin': isEdgeBrowser() ? 'http://localhost' : getOrigin(),
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
      'Origin': isEdgeBrowser() ? 'http://localhost' : getOrigin(),
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

  /// Test connection untuk URL tertentu
  static Future<Map<String, dynamic>> testConnection(String url) async {
    try {
      final response = await get(url);
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        try {
          return json.decode(response.body);
        } catch (e) {
          return {
            'success': false,
            'message': 'Error parsing response: ${e.toString()}'
          };
        }
      } else {
        return {
          'success': false,
          'message': 'HTTP Error: ${response.statusCode}'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection error: ${e.toString()}'
      };
    }
  }
}

/// Window location helper
class window {
  static String get location => js.context['window']['location']['href'].toString();
  static String get origin {
    try {
      return js.context['window']['location']['origin'].toString();
    } catch (e) {
      final href = location;
      final uri = Uri.parse(href);
      return '${uri.scheme}://${uri.host}${uri.port == null || uri.port == 80 || uri.port == 443 ? '' : ':${uri.port}'}';
    }
  }
}