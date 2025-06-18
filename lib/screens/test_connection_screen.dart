import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:developer' as developer;

class TestConnectionScreen extends StatefulWidget {
  const TestConnectionScreen({Key? key}) : super(key: key);

  @override
  _TestConnectionScreenState createState() => _TestConnectionScreenState();
}

class _TestConnectionScreenState extends State<TestConnectionScreen> {
  String _result = "Belum ada hasil";
  bool _isLoading = false;
  TextEditingController _urlController = TextEditingController(text: "http://10.0.2.2:58971/api/test.ashx");
  
  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _testConnection() async {
    setState(() {
      _isLoading = true;
      _result = "Menghubungi server...";
    });

    try {
      final url = _urlController.text;
      developer.log('Testing connection to: $url', name: 'TEST');
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));
      
      developer.log('Status: ${response.statusCode}', name: 'TEST');
      developer.log('Headers: ${response.headers}', name: 'TEST');
      developer.log('Body: ${response.body}', name: 'TEST');
      
      setState(() {
        _result = 'Status: ${response.statusCode}\n\nHeaders: ${response.headers}\n\nBody: ${response.body}';
      });
    } catch (e) {
      setState(() {
        _result = 'Error: ${e.toString()}';
      });
      developer.log('Error: ${e.toString()}', name: 'TEST');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Test Koneksi API"),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _urlController,
              decoration: InputDecoration(
                labelText: "URL",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _testConnection,
              child: _isLoading 
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : Text("Test Koneksi"),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            SizedBox(height: 16),
            Text("Hasil Test:", style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(_result),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 