import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // ZMENIŤ NA TVOJU IP ADRESU / 10.0.2.2 AK IDEŠ CEZ EMULÁTOR
  static const String baseUrl = "http://10.0.2.2:5000";

  static Map<String, dynamic> _decodeJson(String body) {
    final decoded = jsonDecode(body);
    if (decoded is Map<String, dynamic>) return decoded;
    throw Exception('Nečakaný formát odpovede (nie je JSON objekt).');
  }

  static Future<Map<String, dynamic>> register(
      String username,
      String email,
      String password,
      ) async {
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
      "body": _decodeJson(response.body),
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
      "body": _decodeJson(response.body),
    };
  }

  // ✅ RESEND VERIFICATION EMAIL
  static Future<Map<String, dynamic>> resendVerification(String email) async {
    final url = Uri.parse("$baseUrl/resend-verification");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email
      }),
    );

    return {
      "status": response.statusCode,
      "body": _decodeJson(response.body),
    };
  }

  static Future<Map<String, dynamic>> requestPasswordReset(String email) async {
    final url = Uri.parse("$baseUrl/request-password-reset");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email}),
    );

    return {
      "status": response.statusCode,
      "body": _decodeJson(response.body),
    };
  }

  // =====================
  // 🌿 QR SCAN + PROFILE
  // =====================

  static Future<Map<String, dynamic>> scanByQrToken(String qrToken, String token) async {
    final url = Uri.parse("$baseUrl/api/scan");

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({"qr_token": qrToken.trim()}),
    );

    if (response.statusCode == 404) {
      throw Exception("Toto nie je náš QR kód.");
    }
    if (response.statusCode != 200) {
      throw Exception("Sken sa nepodaril.");
    }

    return _decodeJson(response.body);
  }

  /// ✅ Profile response should include:
  /// - foundCount: int
  /// - lastPlants: List<int>
  /// - discoveredPlantIds: List<int>   <-- pre fajky v PlantsScreen
  static Future<Map<String, dynamic>> getProfile(String token) async {
    final url = Uri.parse("$baseUrl/api/profile");

    final response = await http.get(
      url,
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode != 200) {
      throw Exception("Nepodarilo sa načítať profil. HTTP ${response.statusCode}: ${response.body}");
    }

    return _decodeJson(response.body);
  }

  /// (Voliteľné) Helper, aby UI nemuselo riešiť typy.
  static Future<Set<int>> getDiscoveredPlantIds(String token) async {
    final prof = await getProfile(token);
    final ids = List<int>.from(prof['discoveredPlantIds'] ?? const []);
    return ids.toSet();
  }
}
