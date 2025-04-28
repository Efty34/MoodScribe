import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:diary/auth/auth_wrapper.dart';
import 'package:diary/firebase_options.dart';
import 'package:diary/notification/notification_controller.dart';
import 'package:diary/pages/login_page.dart';
import 'package:diary/pages/register_page.dart';
import 'package:diary/pages/settings_page.dart';
import 'package:diary/pages/stats_page.dart';
import 'package:diary/services/mood_chart_provider.dart';
import 'package:diary/services/profile_provider.dart';
import 'package:diary/services/streak_calendar_provider.dart';
import 'package:diary/services/stress_chart_provider.dart';
import 'package:diary/utils/app_routes.dart';
import 'package:diary/utils/bottom_nav_bar.dart';
import 'package:diary/utils/monochrome_theme.dart';
import 'package:diary/utils/theme_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await AwesomeNotifications().initialize(null, [
    NotificationChannel(
      channelGroupKey: "notification_channel_group",
      channelKey: "notification_channel",
      channelName: "Notification channel",
      channelDescription: "Notification channel description",
      defaultColor: const Color(0xFF9D50DD),
      ledColor: const Color(0xFF9D50DD),
      importance: NotificationImportance.High,
      playSound: true,
    ),
    NotificationChannel(
      channelGroupKey: "notification_channel_group",
      channelKey: "todo_channel",
      channelName: "Todo Reminders",
      channelDescription: "Notifications for todo reminders",
      defaultColor: const Color(0xFF9D50DD),
      ledColor: const Color(0xFF9D50DD),
      importance: NotificationImportance.High,
      playSound: true,
    ),
  ], channelGroups: [
    NotificationChannelGroup(
      channelGroupKey: "notification_channel_group",
      channelGroupName: "Notification channel group",
    ),
  ]);

  bool isNotificationEnabled =
      await AwesomeNotifications().isNotificationAllowed();
  if (!isNotificationEnabled) {
    await AwesomeNotifications().requestPermissionToSendNotifications(
      permissions: [
        NotificationPermission.Alert,
        NotificationPermission.Sound,
        NotificationPermission.Badge,
        NotificationPermission.Vibration,
        NotificationPermission.Light,
        NotificationPermission.CriticalAlert,
      ],
    );
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => UserProfileProvider()),
        ChangeNotifierProvider(create: (_) => MoodChartProvider()),
        ChangeNotifierProvider(create: (_) => StreakCalendarProvider()),
        ChangeNotifierProvider(create: (_) => StressChartProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    AwesomeNotifications().setListeners(
        onActionReceivedMethod: NotificationController.onActionReceivedMethod,
        onNotificationCreatedMethod:
            NotificationController.onNotificationCreatedMethod,
        onNotificationDisplayedMethod:
            NotificationController.onNotificationDisplayedMethod,
        onDismissActionReceivedMethod:
            NotificationController.onNotificationDismissedMethod);
    super.initState();
  }

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
        AppRoutes.settingsPage: (context) => const SettingsPage(),
        AppRoutes.statsPage: (context) => const StatsPage(),
      },
    );
  }
}
