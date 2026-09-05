import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/struk_model.dart';
import '../services/api_service.dart';

class ConvertPage extends StatefulWidget {
  const ConvertPage({super.key});

  @override
  State<ConvertPage> createState() => _ConvertPageState();
}

class _ConvertPageState extends State<ConvertPage> {
  List<StrukModel> strukList = [];
  StrukModel? selectedStruk;
  String? errorMessage;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchAllStruk();
  }

  Future<void> fetchAllStruk() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final token = await ApiService.getToken();
      print("🔑 Token dari SharedPreferences: $token");

      if (token == null) {
        setState(() {
          errorMessage = "Token tidak ditemukan. Silakan login ulang.";
          isLoading = false;
        });
        return;
      }

      final url = Uri.parse("${ApiService.baseUrl}/struk");
      print("📤 Mengirim request ke: $url");

      final response = await http.get(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      print("📥 Status: ${response.statusCode}");
      print("📥 Body: ${response.body}");

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        setState(() {
          strukList = data.map((e) => StrukModel.fromJson(e)).toList();
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage =
              "Gagal ambil data struk (${response.statusCode}): ${response.body}";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Error: $e";
        isLoading = false;
      });
    }
  }

  void selectStruk(StrukModel struk) {
    setState(() {
      selectedStruk = struk;
      errorMessage = null;
    });
  }

  void convertCurrency() {
    if (selectedStruk == null) return;
    double rate = 15000;
    double converted = selectedStruk!.totalBiaya / rate;

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            backgroundColor: Colors.grey[100],
            title: const Text(
              "Konversi Mata Uang",
              style: TextStyle(color: Colors.black),
            ),
            content: Text(
              "Total biaya Rp ${selectedStruk!.totalBiaya.toStringAsFixed(2)} setara dengan \$${converted.toStringAsFixed(2)}",
              style: const TextStyle(color: Colors.black87),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Tutup"),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text('Daftar Struk'),
        backgroundColor: Colors.grey[800],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else if (errorMessage != null)
              Text(
                errorMessage!,
                style: const TextStyle(color: Colors.redAccent),
              )
            else if (strukList.isEmpty)
              const Text("Tidak ada data struk tersedia")
            else
              Expanded(
                child: ListView.builder(
                  itemCount: strukList.length,
                  itemBuilder: (context, index) {
                    final struk = strukList[index];
                    final isSelected = selectedStruk?.idStruk == struk.idStruk;
                    return Card(
                      color: isSelected ? Colors.grey[300] : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color:
                              isSelected
                                  ? Colors.grey.shade700
                                  : Colors.grey.shade300,
                          width: 1,
                        ),
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        title: Text(
                          'Struk ID: ${struk.idStruk} - Total: Rp ${struk.totalBiaya.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                        subtitle: Text(
                          'Status: ${struk.status}',
                          style: const TextStyle(color: Colors.black54),
                        ),
                        onTap: () => selectStruk(struk),
                      ),
                    );
                  },
                ),
              ),
            if (selectedStruk != null) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade400),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Struk Terpilih ID: ${selectedStruk!.idStruk}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Total biaya: Rp ${selectedStruk!.totalBiaya.toStringAsFixed(2)}",
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[800],
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: convertCurrency,
                        child: const Text("Konversi Mata Uang"),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
