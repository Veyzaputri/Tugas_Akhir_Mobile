import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import '../models/struk_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl =
      "https://final-project-prak-tcc-103949415038.us-central1.run.app";

  // Helper untuk ambil token dan buat header Authorization
  static Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken') ?? '';
    return {
      'Content-Type': 'application/json',
      if (token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  static Future<String> login(String username, String password) async {
    final response = await http.post(
      Uri.parse("$baseUrl/login"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data['accessToken'];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('accessToken', token);

      return token;
    } else {
      throw Exception('Failed to login: ${response.body}');
    }
  }

  static Future<bool> register(String username, String password) async {
    final response = await http.post(
      Uri.parse("$baseUrl/register"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return true;
    } else if (response.statusCode == 400) {
      return false;
    } else {
      throw Exception("Register failed: ${response.body}");
    }
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('accessToken');
  }

  static Future<Map<String, dynamic>> getStrukById(int idStruk) async {
    final headers = await _getHeaders();

    final response = await http.get(
      Uri.parse("$baseUrl/pasien/periksa/struk/$idStruk"),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Gagal mengambil struk: ${response.body}");
    }
  }

  static Future<List<StrukModel>> getAllStruk() async {
    final headers = await _getHeaders();

    final response = await http.get(
      Uri.parse("$baseUrl/struk"),
      headers: headers,
    );

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => StrukModel.fromJson(e)).toList();
    } else {
      throw Exception("Gagal mengambil data struk: ${response.statusCode}");
    }
  }

  // **Tambah method ambil daftar pasien (GET)**
  static Future<List<dynamic>> getPasienList() async {
    final headers = await _getHeaders();

    final response = await http.get(
      Uri.parse("$baseUrl/pasien"),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Gagal mengambil data pasien: ${response.statusCode}");
    }
  }

  // **Tambah method tambah pasien (POST)**
  static Future<bool> tambahPasien(Map<String, dynamic> pasienData) async {
    final headers = await _getHeaders();

    final response = await http.post(
      Uri.parse("$baseUrl/add-pasien"),
      headers: headers,
      body: jsonEncode(pasienData),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return true;
    } else {
      print('Tambah pasien gagal: ${response.body}');
      return false;
    }
  }

  static Future<List<Map<String, dynamic>>> getDokter() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/doctor'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      return jsonData
          .map((item) => {'id': item['id_dokter'], 'nama': item['nama_dokter']})
          .toList();
    } else {
      print('Response gagal dokter: ${response.statusCode} - ${response.body}');
      throw Exception('Gagal mengambil data dokter');
    }
  }
}
