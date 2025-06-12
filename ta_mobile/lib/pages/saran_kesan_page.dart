import 'package:flutter/material.dart';

class SaranKesanPage extends StatefulWidget {
  const SaranKesanPage({super.key});

  @override
  State<SaranKesanPage> createState() => _SaranKesanPageState();
}

class _SaranKesanPageState extends State<SaranKesanPage> {
  final namaController = TextEditingController();
  final nimController = TextEditingController();
  final kesanController = TextEditingController();
  final saranController = TextEditingController();

  String hasil = '';

  void kirimSaran() {
    final nama = namaController.text.trim();
    final nim = nimController.text.trim();
    final kesan = kesanController.text.trim();
    final saran = saranController.text.trim();

    if (nama.isEmpty || nim.isEmpty || kesan.isEmpty || saran.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Semua kolom harus diisi')));
      return;
    }

    setState(() {
      hasil = 'Nama: $nama\nNIM: $nim\n\nKesan:\n$kesan\n\nSaran:\n$saran';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Terima kasih atas masukannya!')),
    );

    // Kosongkan field
    namaController.clear();
    nimController.clear();
    kesanController.clear();
    saranController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final inputDecoration = InputDecoration(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Saran & Kesan')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Silakan isi form di bawah untuk memberikan saran dan kesan kamu.',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: namaController,
                decoration: inputDecoration.copyWith(labelText: 'Nama'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nimController,
                decoration: inputDecoration.copyWith(labelText: 'NIM'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: kesanController,
                decoration: inputDecoration.copyWith(labelText: 'Kesan'),
                maxLines: 4,
                textInputAction: TextInputAction.newline,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: saranController,
                decoration: inputDecoration.copyWith(labelText: 'Saran'),
                maxLines: 4,
                textInputAction: TextInputAction.newline,
              ),
              const SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  onPressed: kirimSaran,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Kirim', style: TextStyle(fontSize: 18)),
                ),
              ),
              const SizedBox(height: 30),
              if (hasil.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Text(
                    hasil,
                    style: const TextStyle(fontSize: 16, height: 1.4),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
