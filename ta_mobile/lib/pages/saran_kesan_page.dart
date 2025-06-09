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
    final nama = namaController.text;
    final nim = nimController.text;
    final kesan = kesanController.text;
    final saran = saranController.text;

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
    return Scaffold(
      appBar: AppBar(title: const Text('Saran & Kesan')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: namaController,
                decoration: const InputDecoration(labelText: 'Nama'),
              ),
              TextField(
                controller: nimController,
                decoration: const InputDecoration(labelText: 'NIM'),
              ),
              TextField(
                controller: kesanController,
                decoration: const InputDecoration(labelText: 'Kesan'),
                maxLines: 3,
              ),
              TextField(
                controller: saranController,
                decoration: const InputDecoration(labelText: 'Saran'),
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: kirimSaran,
                  child: const Text('Kirim'),
                ),
              ),
              const SizedBox(height: 20),
              if (hasil.isNotEmpty)
                Text(hasil, style: const TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }
}
