import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:async';
import 'dart:math';

class SensorPage extends StatefulWidget {
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

        // Reset status setelah 3 detik
        Future.delayed(Duration(seconds: 3), () {
          setState(() {
            isShaking = false;
            status = "Tenang";
          });
        });
      }
    });
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
        title: Text("Deteksi Kegelisahan Pasien"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isShaking ? Icons.warning : Icons.health_and_safety,
                color: isShaking ? Colors.red : Colors.green,
                size: 100,
              ),
              SizedBox(height: 20),
              Text(
                status,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 30),
              if (isShaking)
                ElevatedButton.icon(
                  onPressed: () {
                    // Tambahkan logika panggil petugas / API call
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Petugas telah dipanggil")),
                    );
                  },
                  icon: Icon(Icons.notifications_active),
                  label: Text("Panggil Petugas"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
