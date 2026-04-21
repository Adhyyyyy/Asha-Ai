import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // 1. Base URL
  // If running on Web, use localhost. If Emulator, use 10.0.2.2
  static String get baseUrl {
    const String envUrl = String.fromEnvironment('API_BASE_URL');
    if (envUrl.isNotEmpty) return envUrl;
    
    if (kIsWeb) {
      return 'http://localhost:3000/api';
    }
    return 'http://10.0.2.2:3000/api';
  }

  // 2. Helper: Get Token (Private function start with _)
  // Future<String?> is like Promise<string | null> in TS
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // 3. POST Request
  Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
    final token = await _getToken();

    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'), // e.g. http://.../api/auth/login
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );

    return _handleResponse(response);
  }

  // 4. GET Request
  Future<dynamic> get(String endpoint) async {
    final token = await _getToken();

    final response = await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    return _handleResponse(response);
  }

  // PUT Request
  Future<dynamic> put(String endpoint, Map<String, dynamic> data) async {
    final token = await _getToken();
    final response = await http.put(
      Uri.parse('$baseUrl$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );
    return _handleResponse(response);
  }

  // DELETE Request
  Future<dynamic> delete(String endpoint) async {
    final token = await _getToken();
    final response = await http.delete(
      Uri.parse('$baseUrl$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
    return _handleResponse(response);
  }

  // 5. Helper: Handle Success vs Error
  // dynamic means "I don't know the type yet" (like 'any' in TS)
  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      throw Exception('API Error: ${response.statusCode} ${response.body}');
    }
  }
  // 6. Upload File (Multipart Request) - UPDATED FOR WEB SUPPORT
  Future<dynamic> uploadFile(String endpoint, List<int> bytes, String filename, Map<String, String> fields) async {
    final token = await _getToken();
    var uri = Uri.parse('$baseUrl$endpoint');
    var request = http.MultipartRequest('POST', uri);

    // Add Headers
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    // Add Fields (e.g., patientId, modality)
    request.fields.addAll(fields);

    // Add File as Bytes (Works on both Web and Mobile)
    var pic = http.MultipartFile.fromBytes(
      'file',
      bytes,
      filename: filename,
    );
    request.files.add(pic);

    // Send
    var streamResponse = await request.send();
    var response = await http.Response.fromStream(streamResponse);

    return _handleResponse(response);
  }
}
