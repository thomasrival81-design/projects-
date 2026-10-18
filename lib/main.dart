import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'login_page.dart';
import 'dashboard_page.dart';
import 'home_page.dart';
import 'seller_page.dart';
import 'admin_page.dart';
import 'landing.dart';
import 'project_dashboard.dart';

String baseUrl = "http://panelprivatkenzxcpanelpanel.pterodactylxcz.my.id:4113";

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Show the bundled intro immediately; remote config loads in the background.
  unawaited(loadConfig());
  runApp(const MyApp());
}
Future<void> loadConfig() async {
  // Startup must not wait forever for remote configuration; the intro is local.
  try {
    final response = await http
        .get(Uri.parse(
            "https://raw.githubusercontent.com/otaxXOne/OTAX-APP/refs/heads/main/config.json"))
        .timeout(const Duration(seconds: 4));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final configuredUrl = data["base_url"]?.toString();
      if (configuredUrl != null && configuredUrl.isNotEmpty) {
        baseUrl = configuredUrl;
      }
    }
  } catch (_) {
    // Continue offline; screens and bundled intro video remain available.
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PINZX PROJECT',
      theme: ThemeData(
        brightness: Brightness.dark,
        fontFamily: 'ShareTechMono',
        scaffoldBackgroundColor: Colors.black,
        colorScheme: const ColorScheme.dark().copyWith(
          secondary: Colors.purple,
        ),
      ),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        switch (settings.name) {

          case '/':
            return MaterialPageRoute(builder: (_) => const LandingPage());

          case '/login':
            return MaterialPageRoute(builder: (_) => const LoginPage());

          case '/project-dashboard':
            return MaterialPageRoute(builder: (_) => const ProjectDashboardPage());

          case '/dashboard':
            final args = settings.arguments as Map<String, dynamic>? ?? {};
            return MaterialPageRoute(
              builder: (_) => DashboardPage(
                username: args['username'] ?? '',
                password: args['password'] ?? '',
                role: args['role'] ?? '',
                sessionKey: args['key'] ?? '',
                expiredDate: args['expiredDate'] ?? '',
                listBug: List<Map<String, dynamic>>.from(args['listBug'] ?? []),
                listDoos: List<Map<String, dynamic>>.from(args['listDoos'] ?? []),
                news: List<Map<String, dynamic>>.from(args['news'] ?? []),
              ),
            );

          case '/home':
            final args = settings.arguments as Map<String, dynamic>? ?? {};
            return MaterialPageRoute(
              builder: (_) => HomePage(
                username: args['username'] ?? '',
                password: args['password'] ?? '',
                listBug: List<Map<String, dynamic>>.from(args['listBug'] ?? []),
                role: args['role'] ?? '',
                expiredDate: args['expiredDate'] ?? '',
                sessionKey: args['sessionKey'] ?? '',
              ),
            );

          case '/seller':
            final args = settings.arguments as Map<String, dynamic>? ?? {};
            return MaterialPageRoute(
              builder: (_) => SellerPage(
                keyToken: args['keyToken'] ?? '',
              ),
            );

          case '/admin':
            final args = settings.arguments as Map<String, dynamic>? ?? {};
            return MaterialPageRoute(
              builder: (_) => AdminPage(
                sessionKey: args['sessionKey'] ?? '',
              ),
            );

          default:
            return MaterialPageRoute(
              builder: (_) => const Scaffold(
                body: Center(child: Text("404 - Not Found")),
              ),
            );
        }
      },
    );
  }
}