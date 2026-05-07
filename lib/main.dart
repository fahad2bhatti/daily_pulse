import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'utils/app_theme.dart';
import 'providers/reminder_provider.dart';
import 'providers/habit_provider.dart';
import 'providers/user_provider.dart';
import 'providers/score_provider.dart';
import 'screens/splash_screen.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.init();
  runApp(const DailyPulseApp());
}

class DailyPulseApp extends StatelessWidget {
  const DailyPulseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ReminderProvider()..init(),
        ),
        ChangeNotifierProvider(
          create: (_) => HabitProvider()..init(),
        ),
        ChangeNotifierProvider(
          create: (_) => UserProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => ScoreProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'DailyPulse',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        home: const SplashScreen(),
      ),
    );
  }
}