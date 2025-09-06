import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'Pages/login_page.dart';
import 'Pages/dashboard_page.dart';
import 'Pages/bio_data_page.dart';
import 'Pages/accommodation_page.dart';
import 'Pages/finances_page.dart';
import 'Pages/registration_page.dart';
import 'Pages/results_page.dart';
import 'Pages/research_page.dart';
import 'Pages/elearning_page.dart';
import 'Pages/exam_slip_page.dart';
import 'Pages/api_service.dart';

// ✅ Custom HttpOverrides to bypass SSL errors in development
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Apply SSL bypass only in debug mode (for localhost APIs with self-signed certs)
  if (kDebugMode) {
    HttpOverrides.global = MyHttpOverrides();
  }

  // Log the effective API base URL (supports --dart-define or runtime override)
  Logger().i('API base: ${ApiService.currentBaseUrl}');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "UNZA SIS",
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.green[50],
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      debugShowCheckedModeBanner: false,

      // ✅ Check login status before deciding start page
      home: FutureBuilder<bool>(
        future: ApiService.checkLoginStatus(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          final isLoggedIn = snapshot.data ?? false;
          return isLoggedIn ? const DashboardPage() : const LoginPage();
        },
      ),

      // ✅ Named routes
      routes: {
        '/dashboard': (context) => const DashboardPage(),
        '/bio-data': (context) => const BioDataPage(),
        '/accommodation': (context) => const AccommodationPage(),
        '/finances': (context) => const FinancesPage(),
        '/registration': (context) => const RegistrationPage(),
        '/results': (context) => const ResultsPage(),
        '/research': (context) => const ResearchPage(),
        '/elearning': (context) => const ELearningPage(),
        '/exam-slip': (context) => const ExamSlipPage(),
      },
    );
  }
}
