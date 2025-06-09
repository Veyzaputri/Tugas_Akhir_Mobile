import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/api_service.dart';

class DataDokterPage extends StatefulWidget {
  @override
  _DataDokterPageState createState() => _DataDokterPageState();
}

class _DataDokterPageState extends State<DataDokterPage> {
  List<dynamic> dokterList = [];
  List<dynamic> filteredDokterList = [];
  TextEditingController _searchController = TextEditingController();
  String token = ""; // Ambil dari penyimpanan token jika pakai login

  @override
  void initState() {
    super.initState();
    fetchDokter();
    _searchController.addListener(_onSearchChanged);
    _loadDokter();
  }

  Future<void> _loadDokter() async {
    await fetchDokter();
  }

  Future<void> fetchDokter() async {
    String? token =
        await ApiService.getToken(); // ambil token dari SharedPreferences

    if (token == null || token.isEmpty) {
      print("Token tidak ditemukan, user belum login");
      return;
    }

    final response = await http.get(
      Uri.parse(
        "https://final-project-prak-tcc-103949415038.us-central1.run.app/doctor",
      ),
      headers: {"Authorization": "Bearer $token"},
    );

    print("Status code: ${response.statusCode}");
    print("Response body: ${response.body}");

    if (response.statusCode == 200) {
      final List<dynamic> dokter = json.decode(response.body);
      setState(() {
        dokterList = dokter;
        filteredDokterList = dokter;
      });
    } else {
      print("Gagal mengambil data dokter: ${response.statusCode}");
    }
  }

  void _onSearchChanged() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      filteredDokterList =
          dokterList.where((dokter) {
            final nama = dokter['nama_dokter'].toLowerCase();
            return nama.contains(query);
          }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Widget buildDokterCard(Map<String, dynamic> dokter) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      child: ListTile(
        leading: Icon(Icons.medical_services, color: Colors.deepPurple),
        title: Text(dokter['nama_dokter']),
        subtitle: Text("Spesialis: ${dokter['spesialis']}"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Data Dokter RSJ"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Cari nama dokter...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child:
                  filteredDokterList.isNotEmpty
                      ? ListView.builder(
                        itemCount: filteredDokterList.length,
                        itemBuilder: (context, index) {
                          return buildDokterCard(filteredDokterList[index]);
                        },
                      )
                      : Center(child: Text("Tidak ada dokter ditemukan")),
            ),
          ],
        ),
      ),
    );
  }
}
