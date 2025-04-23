import 'package:diary/auth/auth_wrapper.dart';
import 'package:diary/firebase_options.dart';
import 'package:diary/mood_buddy/pages/mood_buddy_page.dart';
import 'package:diary/pages/login_page.dart';
import 'package:diary/pages/register_page.dart';
import 'package:diary/pages/settings_page.dart';
import 'package:diary/utils/app_routes.dart';
import 'package:diary/utils/bottom_nav_bar.dart';
import 'package:diary/utils/monochrome_theme.dart';
import 'package:diary/utils/theme_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Hive.initFlutter();
  await Hive.openBox<String>('diaryBox');
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the theme provider
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      theme: MonochromeTheme.lightTheme.copyWith(
        textTheme:
            GoogleFonts.interTextTheme(MonochromeTheme.lightTheme.textTheme),
      ),
      darkTheme: MonochromeTheme.darkTheme.copyWith(
        textTheme:
            GoogleFonts.interTextTheme(MonochromeTheme.darkTheme.textTheme),
      ),
      themeMode: themeProvider.themeMode,
      debugShowCheckedModeBanner: false,
      home: const AuthWrapper(),
      routes: {
        AppRoutes.loginPage: (context) => const LoginPage(),
        AppRoutes.registerPage: (context) => const RegisterPage(),
        AppRoutes.bottomNavBar: (context) => const BottomNavBar(),
        AppRoutes.moodBuddyPage: (context) => const MoodBuddyPage(),
        AppRoutes.settingsPage: (context) => const SettingsPage(),
      },
    );
  }
}
