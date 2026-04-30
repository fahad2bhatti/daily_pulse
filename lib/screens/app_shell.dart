import 'package:flutter/material.dart';
import '../widgets/app_background.dart';
import '../widgets/bottom_nav.dart';
import 'home_screen.dart';
import 'tasks_screen.dart';
import 'add_reminder_screen.dart';
import 'stats_screen.dart';
import 'profile_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      const HomeScreen(),
      const TasksScreen(),
      const AddReminderScreen(),
      const StatsScreen(),
      const ProfileScreen(),
    ];

    return AppBackground(
      child: Column(
        children: [
          Expanded(child: pages[_tab]),
          DailyBottomNav(
            index: _tab,
            onChange: (i) => setState(() => _tab = i),
          ),
        ],
      ),
    );
  }
}