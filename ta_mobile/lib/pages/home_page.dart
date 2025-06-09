import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ta_mobile/pages/antrian_pasien.dart';
import 'package:ta_mobile/pages/data_dokter_page.dart';
import 'package:ta_mobile/pages/conversion_page.dart';
import 'package:ta_mobile/pages/conversion_time_page.dart';
import 'package:ta_mobile/pages/profil_page.dart';
import 'package:ta_mobile/pages/saran_kesan_page.dart';
import 'package:ta_mobile/pages/sensor_page.dart';
import 'package:ta_mobile/pages/login_pages.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomeContent(),
    const ProfilePage(),
    const SaranKesanPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('accessToken');
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        title: const Text("Beranda", style: TextStyle(color: Colors.black87)),
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: logout),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.grey[800],
        unselectedItemColor: Colors.grey[500],
        backgroundColor: Colors.grey[200],
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Beranda"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profil"),
          BottomNavigationBarItem(icon: Icon(Icons.feedback), label: "Saran"),
        ],
      ),
    );
  }
}

Widget buildMenuButton(
  BuildContext context, {
  required IconData icon,
  required String label,
  required Widget page,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        backgroundColor: Colors.grey[200],
        foregroundColor: Colors.black87,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 3,
        shadowColor: Colors.grey[400],
      ),
      onPressed: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => page));
      },
      icon: Icon(icon, color: Colors.black54),
      label: Text(label, style: const TextStyle(fontSize: 16)),
    ),
  );
}

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  String? jadwalObat;

  @override
  void initState() {
    super.initState();
    _loadJadwalObat();
  }

  Future<void> _loadJadwalObat() async {
    final prefs = await SharedPreferences.getInstance();
    final waktu = prefs.getString('jadwalObat');
    setState(() {
      jadwalObat = waktu;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Selamat datang di",
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                SizedBox(height: 4),
                Text(
                  "Aplikasi Rumah Sakit Jiwa",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          buildMenuButton(
            context,
            icon: Icons.attach_money,
            label: "Konversi Mata Uang",
            page: const ConvertPage(),
          ),
          buildMenuButton(
            context,
            icon: Icons.access_time,
            label: "Konversi Waktu",
            page: const MedicineReminderPage(),
          ),
          buildMenuButton(
            context,
            icon: Icons.sensors,
            label: "Sensor",
            page: SensorPage(),
          ),
          buildMenuButton(
            context,
            icon: Icons.search,
            label: "Pencarian Dokter",
            page: DataDokterPage(),
          ),
          buildMenuButton(
            context,
            icon: Icons.people_alt,
            label: "Lihat Antrian Pasien",
            page: AntrianPasienPage(),
          ),
          const SizedBox(height: 30),
          Card(
            color: Colors.grey[100],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 3,
            shadowColor: Colors.grey[300],
            child: ListTile(
              leading: const Icon(
                Icons.notifications_active,
                color: Colors.black54,
              ),
              title: const Text(
                "Pengingat Minum Obat!",
                style: TextStyle(color: Colors.black87),
              ),
              subtitle: Text(
                jadwalObat != null && jadwalObat!.isNotEmpty
                    ? "Setiap hari jam $jadwalObat WIB"
                    : "Yuk buat pengingat minum obat",
                style: TextStyle(
                  color:
                      jadwalObat != null && jadwalObat!.isNotEmpty
                          ? Colors.black87
                          : Colors.grey[600],
                ),
              ),
              trailing: const Icon(Icons.alarm, color: Colors.black45),
            ),
          ),
        ],
      ),
    );
  }
}
