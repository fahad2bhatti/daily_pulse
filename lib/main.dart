import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart' as p;
import 'core/theme/app_theme.dart';
import 'providers/user_provider.dart';
import 'providers/app_provider.dart';
import 'providers/habit_provider.dart';
import 'providers/reminder_provider.dart';
import 'providers/score_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/student_hub_login_screen.dart';
import 'screens/student_hub_signup_screen.dart';
import 'screens/student_hub_profile_setup_screen.dart';
import 'screens/student_hub_groups_screen.dart';
import 'screens/student_hub_group_detail_screen.dart';

// Background message handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling a background message: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Set up background message handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(
    ProviderScope(
      child: p.MultiProvider(
        providers: [
          p.ChangeNotifierProvider(create: (_) => UserProvider()),
          p.ChangeNotifierProvider(create: (_) => AppProvider()),
          p.ChangeNotifierProvider(create: (_) => HabitProvider()),
          p.ChangeNotifierProvider(create: (_) => ReminderProvider()),
          p.ChangeNotifierProvider(create: (_) => ScoreProvider()),
        ],
        child: const MyApp(),
      ),
    ),
  );
}

// Router setup
final GoRouter _router = GoRouter(
  initialLocation: '/student-hub-login',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    // 🔐 Student Hub Routes
    GoRoute(
      path: '/student-hub-login',
      builder: (context, state) => const StudentHubLoginScreen(),
    ),
    GoRoute(
      path: '/student-hub-signup',
      builder: (context, state) => const StudentHubSignupScreen(),
    ),
    GoRoute(
      path: '/student-hub-profile-setup',
      builder: (context, state) => const StudentHubProfileSetupScreen(),
    ),
    GoRoute(
      path: '/student-hub-home',
      builder: (context, state) => const StudentHubGroupsScreen(),
    ),
    GoRoute(
      path: '/student-hub-groups',
      builder: (context, state) => const StudentHubGroupsScreen(),
    ),
    GoRoute(
      path: '/student-hub-group-detail/:groupId',
      builder: (context, state) {
        final groupId = state.pathParameters['groupId']!;
        return StudentHubGroupDetailScreen(groupId: groupId);
      },
    ),
  ],
);
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    // This will be called for authenticated users after login
    // For now, we initialize the service here for when user logs in
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'DailyPulse',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      routerConfig: _router,
    );
  }
}