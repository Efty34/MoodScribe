// import 'package:shared_preferences/shared_preferences.dart';

// class WelcomePreferences {
//   static const String _welcomeKey = 'has_shown_welcome';

//   static Future<bool> hasShownWelcome() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getBool(_welcomeKey) ?? false;
//   }

//   static Future<void> setWelcomeShown() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setBool(_welcomeKey, true);
//   }

//   static Future<void> resetWelcomeStatus() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setBool(_welcomeKey, false);
//   }
// }
