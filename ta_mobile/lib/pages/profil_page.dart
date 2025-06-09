import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 60,
              backgroundImage: AssetImage(
                'assets/images/profile.png',
              ), // pastikan gambar ada di folder assets
            ),
            const SizedBox(height: 20),
            const Text(
              "Nama Lengkap",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const Text("NIM: 123220102", style: TextStyle(fontSize: 16)),
            const Text("Kelas: IF-B", style: TextStyle(fontSize: 16)),
            const Text(
              "Email: Veyzaputri2004@gmail.com",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 30),
            const Text(
              "Aplikasi Rumah Sakit Jiwa\nTugas Akhir Teknologi dan Pemrograman Mobile",
              style: TextStyle(fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
