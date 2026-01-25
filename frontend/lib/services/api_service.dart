import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../lang/strings.dart';

class ApiService {
  static const String baseUrl = "https://filamented-toshiko-unheated.ngrok-free.dev";

  static Map<String, dynamic> _decodeJson(String body, BuildContext context) {
    final decoded = jsonDecode(body);
    if (decoded is Map<String, dynamic>) return decoded;
    throw Exception(context.tr.apiUnexpectedResponseFormat);
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
      "body": jsonDecode(response.body), // nechávam pôvodné správanie (bez prekladu)
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
      "body": jsonDecode(response.body), // nechávam pôvodné správanie (bez prekladu)
    };
  }

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
      "body": jsonDecode(response.body)
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
      "body": jsonDecode(response.body),
    };
  }

  // =====================
  // 🌿 QR SCAN + PROFILE
  // =====================

  static Future<Map<String, dynamic>> scanByQrToken(
      BuildContext context,
      String qrToken,
      String token,
      ) async {
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
      throw Exception(context.tr.apiQrNotOurs);
    }
    if (response.statusCode != 200) {
      throw Exception(context.tr.apiScanFailed);
    }

    return _decodeJson(response.body, context);
  }

  static Future<Map<String, dynamic>> getProfile(
      BuildContext context,
      String token,
      ) async {
    final url = Uri.parse("$baseUrl/api/profile");

    final response = await http.get(
      url,
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode != 200) {
      throw Exception(context.tr.apiProfileLoadFailed);
    }

    return _decodeJson(response.body, context);
  }

  /// (Voliteľné) Helper, aby UI nemuselo riešiť typy.
  static Future<Set<int>> getDiscoveredPlantIds(
      BuildContext context,
      String token,
      ) async {
    final prof = await getProfile(context, token);
    final ids = List<int>.from(prof['discoveredPlantIds'] ?? const []);
    return ids.toSet();
  }
}
