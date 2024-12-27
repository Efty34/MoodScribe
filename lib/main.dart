import 'package:diary/firebase_options.dart';
import 'package:diary/pages/login_page.dart';
import 'package:diary/pages/register_page.dart';
import 'package:diary/pages/welcome_page.dart';
import 'package:diary/utils/app_routes.dart';
import 'package:diary/utils/bottom_nav_bar.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Hive.initFlutter();
  await Hive.openBox<String>('diaryBox');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        textTheme: GoogleFonts.interTextTheme(),
        brightness: Brightness.light,
      ),
      debugShowCheckedModeBanner: false,
      home: const WelcomePage(),
      routes: {
        AppRoutes.loginPage: (context) => const LoginPage(),
        AppRoutes.registerPage: (context) => const RegisterPage(),
        AppRoutes.bottomNavBar: (context) => const BottomNavBar(),
      },
    );
  }
}
