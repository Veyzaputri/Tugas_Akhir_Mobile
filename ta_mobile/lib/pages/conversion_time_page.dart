import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reminder Minum Obat',
      theme: ThemeData(primarySwatch: Colors.blue),
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
  String? jadwalObat;
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  @override
  void initState() {
    super.initState();
    initNotifications();
    loadJadwalObat();
  }

  Future<void> initNotifications() async {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (response) {
        debugPrint('Notification tapped with payload: ${response.payload}');
      },
    );

    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
  }

  Future<void> loadJadwalObat() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      jadwalObat = prefs.getString('jadwalObat');
    });
  }

  tz.TZDateTime _nextInstanceOfTime(TimeOfDay time) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  Future<void> scheduleNotification(TimeOfDay time) async {
    final scheduledDate = _nextInstanceOfTime(time);

    const androidDetails = AndroidNotificationDetails(
      'medic_channel',
      'Pengingat Obat',
      channelDescription: 'Channel untuk pengingat minum obat',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    debugPrint("Scheduling notification at: $scheduledDate");

    await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      'Pengingat Minum Obat',
      'Saatnya minum obat!',
      scheduledDate,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> testNotification() async {
    const androidDetails = AndroidNotificationDetails(
      'test_channel',
      'Test Channel',
      channelDescription: 'Channel untuk testing notifikasi',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      999,
      'Test Notifikasi',
      'Ini notifikasi test langsung muncul',
      notificationDetails,
      payload: 'test_payload',
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Notifikasi test sudah dikirim!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void konversiWaktuObat(BuildContext context) async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime:
          jadwalObat != null
              ? TimeOfDay(
                hour: int.parse(jadwalObat!.split(':')[0]),
                minute: int.parse(jadwalObat!.split(':')[1]),
              )
              : TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF4A6FA5),
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );

    if (pickedTime != null) {
      final now = DateTime.now();
      final waktu = DateTime(
        now.year,
        now.month,
        now.day,
        pickedTime.hour,
        pickedTime.minute,
      );

      final formatted = DateFormat("HH:mm").format(waktu);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('jadwalObat', formatted);

      setState(() {
        jadwalObat = formatted;
      });

      await scheduleNotification(pickedTime);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Pengingat disetel jam $formatted WIB"),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.green.shade700,
        ),
      );
    }
  }

  void hapusJadwalObat(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jadwalObat');

    setState(() {
      jadwalObat = null;
    });

    await flutterLocalNotificationsPlugin.cancelAll();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Pengingat minum obat dihapus"),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  String konversiWaktu(String waktuWIB, String zonaTujuan) {
    final parts = waktuWIB.split(':');
    int jam = int.parse(parts[0]);
    int menit = int.parse(parts[1]);

    int offset = 0;
    if (zonaTujuan == 'WITA') {
      offset = 1;
    } else if (zonaTujuan == 'WIT') {
      offset = 2;
    }

    jam += offset;
    if (jam >= 24) {
      jam -= 24;
    }

    final jamStr = jam.toString().padLeft(2, '0');
    final menitStr = menit.toString().padLeft(2, '0');

    return '$jamStr:$menitStr $zonaTujuan';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text("Reminder Minum Obat"),
        backgroundColor: const Color(0xFF4A6FA5),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.medical_services_rounded,
                size: 72,
                color: Colors.blueGrey.shade600,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.access_time),
                label: const Text("Atur Waktu Minum Obat"),
                onPressed: () => konversiWaktuObat(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A6FA5),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton.icon(
                icon: const Icon(Icons.delete_forever),
                label: const Text("Hapus Pengingat"),
                onPressed: () => hapusJadwalObat(context),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.redAccent,
                  textStyle: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                icon: const Icon(Icons.notifications_active),
                label: const Text("Test Notifikasi Langsung"),
                onPressed: () => testNotification(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              if (jadwalObat != null)
                Column(
                  children: [
                    Text(
                      "Pengingat Minum Obat",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                        color: Colors.blueGrey.shade900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      jadwalObat!,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.blue.shade700,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "WITA: ${konversiWaktu(jadwalObat!, 'WITA')}",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    Text(
                      "WIT: ${konversiWaktu(jadwalObat!, 'WIT')}",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                )
              else
                Text(
                  "Belum ada pengingat yang disetel.",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey.shade600,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
