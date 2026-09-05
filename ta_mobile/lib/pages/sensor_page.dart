import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class SensorPage extends StatefulWidget {
  const SensorPage({Key? key}) : super(key: key);

  @override
  _SensorPageState createState() => _SensorPageState();
}

class _SensorPageState extends State<SensorPage> {
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;

  double shakeThreshold = 20.0;
  bool isShaking = false;
  String status = "Tenang";

  @override
  void initState() {
    super.initState();
    _startListening();
  }

  void _startListening() {
    _accelerometerSubscription = accelerometerEvents.listen((event) {
      double totalAcceleration = sqrt(
        event.x * event.x + event.y * event.y + event.z * event.z,
      );

      if (totalAcceleration > shakeThreshold && !isShaking) {
        setState(() {
          isShaking = true;
          status = "Guncangan terdeteksi! Pasien mungkin gelisah.";
        });

        _showNotification();

        // Reset status setelah 3 detik
        Future.delayed(const Duration(seconds: 3), () {
          setState(() {
            isShaking = false;
            status = "Tenang";
          });
        });
      }
    });
  }

  void _showNotification() async {
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      await AwesomeNotifications().requestPermissionToSendNotifications();
    }

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
        channelKey: 'alerts',
        title: '🚨 Guncangan Terdeteksi!',
        body: 'Pasien kemungkinan sedang mengalami kegelisahan.',
        notificationLayout: NotificationLayout.Default,
        color: Colors.red,
        payload: {'source': 'sensor'},
      ),
    );
  }

  @override
  void dispose() {
    _accelerometerSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Deteksi Guncangan Pasien"),
        backgroundColor: const Color.fromARGB(255, 116, 116, 117),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isShaking ? Icons.warning : Icons.self_improvement,
              color: isShaking ? Colors.red : Colors.green,
              size: 100,
            ),
            const SizedBox(height: 20),
            Text(
              status,
              style: TextStyle(
                fontSize: 22,
                color: isShaking ? Colors.red : Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
