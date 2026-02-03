import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // 1. Base URL
  // Android Emulator uses 10.0.2.2 to reach your PC's localhost
  static const String baseUrl = 'http://10.0.2.2:3000/api';

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

  // 5. Helper: Handle Success vs Error
  // dynamic means "I don't know the type yet" (like 'any' in TS)
  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      throw Exception('API Error: ${response.statusCode} ${response.body}');
    }
  }
}
