import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer' as developer;

void main() {
  runApp(const ApiTestApp());
}

class ApiTestApp extends StatelessWidget {
  const ApiTestApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'API Test',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const ApiTestScreen(),
    );
  }
}

class ApiTestScreen extends StatefulWidget {
  const ApiTestScreen({Key? key}) : super(key: key);

  @override
  State<ApiTestScreen> createState() => _ApiTestScreenState();
}

class _ApiTestScreenState extends State<ApiTestScreen> {
  String _result = 'Hasil test akan muncul di sini';
  bool _isLoading = false;
  final TextEditingController _urlController = TextEditingController(text: 'http://localhost:58971/api/test.ashx');

  // Daftar URL untuk dicoba
  final List<String> _testUrls = [
    'http://localhost:58971/api/test.ashx',
    'http://127.0.0.1:58971/api/test.ashx',
    'http://[::1]:58971/api/test.ashx',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('API Connection Test'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _urlController,
              decoration: const InputDecoration(
                labelText: 'API URL',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _testCustomUrl,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Test URL'),
            ),
            const SizedBox(height: 16),
            const Text('URL Alternatif:', style: TextStyle(fontWeight: FontWeight.bold)),
            Expanded(
              child: ListView.builder(
                itemCount: _testUrls.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_testUrls[index]),
                    trailing: ElevatedButton(
                      onPressed: _isLoading ? null : () => _testUrl(_testUrls[index]),
                      child: const Text('Test'),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            const Text('Hasil Test:', style: TextStyle(fontWeight: FontWeight.bold)),
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  child: Text(_result),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _testCustomUrl() async {
    await _testUrl(_urlController.text);
  }

  Future<void> _testUrl(String url) async {
    setState(() {
      _isLoading = true;
      _result = 'Testing $url...';
    });

    try {
      developer.log('Testing connection to: $url', name: 'API_TEST');
      
      // Tambahkan header lengkap
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-Requested-With': 'XMLHttpRequest',
          'Origin': 'http://localhost',
        },
      ).timeout(const Duration(seconds: 10));
      
      developer.log('Response status: ${response.statusCode}', name: 'API_TEST');
      developer.log('Response body: ${response.body}', name: 'API_TEST');
      
      // Format JSON untuk mudah dibaca
      var formattedJson = '';
      if (response.statusCode >= 200 && response.statusCode < 300) {
        try {
          final jsonResponse = json.decode(response.body);
          formattedJson = const JsonEncoder.withIndent('  ').convert(jsonResponse);
        } catch (e) {
          formattedJson = response.body;
        }
      }
      
      setState(() {
        _result = 'Status: ${response.statusCode}\n'
            'Headers: ${response.headers}\n\n'
            'Body:\n$formattedJson';
      });
    } catch (e) {
      developer.log('Error: $e', name: 'API_TEST');
      setState(() {
        _result = 'Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}