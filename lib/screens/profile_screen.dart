import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../utils/constants.dart';
import '../widgets/glass_card.dart';
import 'package:provider/provider.dart';
import '../providers/reminder_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _darkMode = true;
  bool _disciplineMode = true;
  bool _notifications = true;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(18, 14, 18, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Profile', style: kH2(context).copyWith(fontSize: 22)),
          SizedBox(height: 16),

          // avatar row
          GlassCard(
            radius: 20,
            child: Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: kMainGradient,
                  ),
                  child: Center(
                    child: Text(
                      'FS',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                        color: Colors.white,
                        fontFamily: 'Nunito',
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Fahad Saeed',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                        fontFamily: 'Nunito',
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '21-day streak member 🔥',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.55),
                        fontSize: 12,
                        fontFamily: 'Nunito',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 16),

          Text(
            'Settings',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontWeight: FontWeight.w800,
              fontSize: 12,
              fontFamily: 'Nunito',
            ),
          ),
          SizedBox(height: 10),

          _toggleTile(
            'Dark Mode',
            Icons.dark_mode_rounded,
            _darkMode,
                (v) => setState(() => _darkMode = v),
          ),
          SizedBox(height: 8),
          _toggleTile(
            'Discipline Mode',
            Icons.bolt_rounded,
            _disciplineMode,
                (v) => setState(() => _disciplineMode = v),
          ),
          SizedBox(height: 8),
          _toggleTile(
            'Notifications',
            Icons.notifications_rounded,
            _notifications,
                (v) => setState(() => _notifications = v),
          ),
          SizedBox(height: 16),

          // Test Notification Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                context.read<ReminderProvider>().testNotification();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Test notification sent! 🔔'),
                    duration: Duration(seconds: 2),
                    backgroundColor: Colors.orange,
                  ),
                );
              },
              icon: Icon(Icons.notifications_active_rounded),
              label: const Text(
                'Test Notification',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Nunito',
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          SizedBox(height: 16), // ✅ Comma yahan tha missing

          Text(
            'Account',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontWeight: FontWeight.w800,
              fontSize: 12,
              fontFamily: 'Nunito',
            ),
          ),
          SizedBox(height: 10),

          _actionTile('Edit Profile', Icons.edit_rounded),
          SizedBox(height: 8),
          _actionTile('Export Data', Icons.download_rounded),
          SizedBox(height: 8),
          _actionTile(
            'Sign Out',
            Icons.logout_rounded,
            color: AppColors.danger,
          ),
          SizedBox(height: 90),
        ],
      ),
    );
  }

  Widget _toggleTile(
      String label,
      IconData icon,
      bool value,
      ValueChanged<bool> onChanged,
      ) {
    return GlassCard(
      radius: 16,
      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: AppColors.purple, size: 20),
          SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontFamily: 'Nunito',
            ),
          ),
          const Spacer(),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.teal,
          ),
        ],
      ),
    );
  }

  Widget _actionTile(String label, IconData icon, {Color? color}) {
    return GlassCard(
      radius: 16,
      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Row(
        children: [
          Icon(
            icon,
            color: color ?? Colors.white.withValues(alpha: 0.7),
            size: 20,
          ),
          SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontFamily: 'Nunito',
              color: color ?? Colors.white,
            ),
          ),
          const Spacer(),
          Icon(
            Icons.chevron_right_rounded,
            color: Colors.white.withValues(alpha: 0.3),
            size: 18,
          ),
        ],
      ),
    );
  }
}





