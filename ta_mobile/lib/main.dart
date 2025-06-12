import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ta_mobile/pages/conversion_time_page.dart';
import 'package:ta_mobile/pages/home_page.dart';
import 'package:ta_mobile/pages/login_pages.dart';
import 'package:ta_mobile/pages/notif_test_page.dart';
import 'package:ta_mobile/pages/register_pages.dart';
import 'package:ta_mobile/provider/auth_provider.dart';

void main() {
  NotificationController.initializeLocalNotifications();
  runApp(const MentalCareApp());
}

class MentalCareApp extends StatelessWidget {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();
  const MentalCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        navigatorKey: navigatorKey,
        title: 'MentalCare+',
        theme: ThemeData(
          brightness: Brightness.light,
          scaffoldBackgroundColor: Colors.white,
          primaryColor: Color(0xFFC0C0C0), // silver
          appBarTheme: AppBarTheme(
            backgroundColor: Color(0xFFB0B0B0), // greyish silver
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade400),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade600),
            ),
            labelStyle: TextStyle(color: Colors.black87),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFB0B0B0),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            ),
          ),
          dropdownMenuTheme: DropdownMenuThemeData(
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          textTheme: TextTheme(
            bodyLarge: TextStyle(color: Colors.black87),
            bodyMedium: TextStyle(color: Colors.black87),
            titleLarge: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        initialRoute: '/',
        routes: {
          '/': (_) => const LoginScreen(),
          '/register': (_) => const RegisterScreen(),
          '/home': (_) => const HomePage(),
          '/notification-page': (context) => MedicineReminderPage(),
        },
      ),
    );
  }
}
