import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tzdata;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Medicine Reminder',
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: Colors.grey[400], // silver utama
        scaffoldBackgroundColor: Colors.grey[100], // background terang abu
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.grey[400],
          foregroundColor: Colors.grey[900],
          elevation: 2,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[500], // tombol silver abu medium
            foregroundColor: Colors.grey[900],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        textTheme: const TextTheme(
          titleLarge: TextStyle(color: Colors.black87),
          bodyMedium: TextStyle(color: Colors.black87),
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: Colors.grey[700],
          contentTextStyle: const TextStyle(color: Colors.white),
        ),
      ),
      home: const MedicineReminderPage(),
    );
  }
}

class MedicineReminderPage extends StatefulWidget {
  const MedicineReminderPage({super.key});

  @override
  State<MedicineReminderPage> createState() => _MedicineReminderPageState();
}

class _MedicineReminderPageState extends State<MedicineReminderPage> {
  TimeOfDay? jadwalObat;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    tzdata.initializeTimeZones(); // Inisialisasi timezone
    loadSavedSchedule();

    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (jadwalObat != null) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> loadSavedSchedule() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('jadwalObat');
    if (saved != null) {
      final parts = saved.split(':');
      if (parts.length == 2) {
        final hour = int.tryParse(parts[0]);
        final minute = int.tryParse(parts[1]);
        if (hour != null && minute != null) {
          setState(() {
            jadwalObat = TimeOfDay(hour: hour, minute: minute);
          });
        }
      }
    }
  }

  Future<void> saveSchedule(TimeOfDay time) async {
    final prefs = await SharedPreferences.getInstance();
    final formattedTime =
        "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
    await prefs.setString('jadwalObat', formattedTime);
    setState(() {
      jadwalObat = time;
    });
  }

  void pilihWaktuObat() async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: jadwalObat ?? TimeOfDay.now(),
      builder: (context, child) {
        // Override theme for time picker dialog supaya matching silver
        return Theme(
          data: ThemeData(
            colorScheme: ColorScheme.light(
              primary: Colors.grey[600]!, // header time picker
              onPrimary: Colors.white, // teks header
              onSurface: Colors.grey[600]!, // teks jam/menit
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey[700], // tombol batalkan/ok
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      await saveSchedule(picked);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Jadwal berhasil disimpan!')),
      );
    }
  }

  Future<void> hapusJadwalObat() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jadwalObat');
    setState(() {
      jadwalObat = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Jadwal minum obat dihapus"),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  String konversiWaktu(TimeOfDay time) {
    return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
  }

  String getStatusObat() {
    if (jadwalObat == null) return "Belum ada jadwal yang disimpan";

    final now = TimeOfDay.now();
    final nowMinutes = now.hour * 60 + now.minute;
    final jadwalMinutes = jadwalObat!.hour * 60 + jadwalObat!.minute;

    if (nowMinutes == jadwalMinutes) {
      return "⏰ Sekarang waktunya minum obat!";
    } else if (nowMinutes > jadwalMinutes) {
      return "⚠️ Kamu sudah melewati jadwal minum obat.";
    } else {
      return "⌛ Belum waktunya minum obat.";
    }
  }

  Map<String, String> konversiZonaWaktu(TimeOfDay time) {
    final now = DateTime.now();

    final lokal = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    final wita = tz.getLocation('Asia/Makassar');
    final wit = tz.getLocation('Asia/Jayapura');
    final london = tz.getLocation('Europe/London');
    final kairo = tz.getLocation('Africa/Cairo');

    final lokalTz = tz.TZDateTime.from(lokal, tz.local);
    final witaTime = tz.TZDateTime.from(lokalTz, wita);
    final witTime = tz.TZDateTime.from(lokalTz, wit);
    final londonTime = tz.TZDateTime.from(lokalTz, london);
    final kairoTime = tz.TZDateTime.from(lokalTz, kairo);

    String formatTime(tz.TZDateTime dt) =>
        "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";

    return {
      'WITA': formatTime(witaTime),
      'WIT': formatTime(witTime),
      'London': formatTime(londonTime),
      'Kairo': formatTime(kairoTime),
    };
  }

  @override
  Widget build(BuildContext context) {
    final waktuZona =
        jadwalObat != null ? konversiZonaWaktu(jadwalObat!) : null;

    return Scaffold(
      appBar: AppBar(title: const Text("Atur Jadwal Minum Obat")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade300,
                    blurRadius: 6,
                    offset: const Offset(2, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    jadwalObat != null
                        ? "🕐 Jadwal Obat: ${konversiWaktu(jadwalObat!)}"
                        : "Belum ada jadwal obat",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    getStatusObat(),
                    style: TextStyle(
                      fontSize: 16,
                      color:
                          jadwalObat != null
                              ? Colors.grey[700]
                              : Colors.grey[500],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
            if (waktuZona != null) ...[
              Text(
                "🌐 Waktu di zona lain:",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[400]!),
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children:
                      waktuZona.entries.map((entry) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.access_time,
                                size: 18,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "${entry.key}: ",
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                entry.value,
                                style: TextStyle(
                                  color: Colors.grey[800],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                ),
              ),
              const SizedBox(height: 30),
            ],
            const Divider(thickness: 1.2),
            const SizedBox(height: 20),

            Center(
              child: Column(
                children: [
                  ElevatedButton.icon(
                    onPressed: pilihWaktuObat,
                    icon: const Icon(Icons.access_time),
                    label: const Text("Pilih Jadwal Minum Obat"),
                  ),
                  const SizedBox(height: 16),
                  if (jadwalObat != null)
                    ElevatedButton.icon(
                      onPressed: hapusJadwalObat,
                      icon: const Icon(Icons.delete),
                      label: const Text("Hapus Jadwal"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[700],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 24,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
