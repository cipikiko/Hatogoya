import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // ZMENIŤ NA TVOJU IP ADRESU / 10.0.2.2 AK IDEŠ CEZ EMULÁTOR
  static const String baseUrl = "http://10.0.2.2:5000";

  static Future<Map<String, dynamic>> register(String username, String email, String password) async {
    final url = Uri.parse("$baseUrl/register");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "username": username,
        "email": email,
        "password": password
      }),
    );

    return {
      "status": response.statusCode,
      "body": jsonDecode(response.body)
    };
  }

  static Future<Map<String, dynamic>> login(String username, String password) async {
    final url = Uri.parse("$baseUrl/login");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "username": username,
        "password": password
      }),
    );

    return {
      "status": response.statusCode,
      "body": jsonDecode(response.body)
    };
  }
}
