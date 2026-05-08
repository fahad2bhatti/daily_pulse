import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_colors.dart';
import '../utils/constants.dart';
import '../widgets/glass_card.dart';
import '../providers/reminder_provider.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ReminderProvider>(
      builder: (context, provider, _) {
        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(18, 14, 18, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Your Stats',
                  style: kH2(context).copyWith(fontSize: 22)),
              SizedBox(height: 6),
              Text('Track your progress and growth',
                  style: kBody(context)),
              SizedBox(height: 14),

              // stat cards
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.35,
                children: [
                  _StatCard(
                    icon: Icons.local_fire_department_rounded,
                    value: '${provider.streak}',
                    label: 'Day Streak',
                    iconColor: AppColors.teal,
                  ),
                  _StatCard(
                    icon: Icons.emoji_events_rounded,
                    value: '${provider.bestStreak}',
                    label: 'Best Streak',
                    iconColor: AppColors.purple,
                  ),
                  _StatCard(
                    icon: Icons.check_circle_rounded,
                    value: '${provider.doneCount}',
                    label: 'Done Today',
                    iconColor: AppColors.purple,
                  ),
                  _StatCard(
                    icon: Icons.track_changes_rounded,
                    value: '${(provider.progress * 100).round()}%',
                    label: 'Today Rate',
                    iconColor: AppColors.teal,
                  ),
                ],
              ),
              SizedBox(height: 14),

              // weekly chart
              GlassCard(
                borderRadius: BorderRadius.circular(20),
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Weekly Progress',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontFamily: 'Nunito',
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Last 7 days',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.45),
                        fontSize: 12,
                        fontFamily: 'Nunito',
                      ),
                    ),
                    SizedBox(height: 16),
                    _WeeklyChart(data: provider.weeklyData),
                  ],
                ),
              ),
              SizedBox(height: 14),

              // streak info card
              GlassCard(
                borderRadius: BorderRadius.circular(20),
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.orange.withValues(alpha: 0.15),
                        border: Border.all(
                          color: Colors.orange.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Icon(
                        Icons.local_fire_department_rounded,
                        color: Colors.orange,
                        size: 28,
                      ),
                    ),
                    SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${provider.streak} day streak! 🔥',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                              fontFamily: 'Nunito',
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            provider.streak >= 7
                                ? 'Zabardast! Ek hafte se zyada!'
                                : provider.streak >= 3
                                ? 'Wah bhai! Chalta reh!'
                                : 'Shuru ho gaya safar!',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.55),
                              fontSize: 12,
                              fontFamily: 'Nunito',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 90),
            ],
          ),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color iconColor;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderRadius: BorderRadius.circular(18),
      padding: EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              fontFamily: 'Nunito',
            ),
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.55),
              fontWeight: FontWeight.w700,
              fontSize: 12,
              fontFamily: 'Nunito',
            ),
          ),
        ],
      ),
    );
  }
}

class _WeeklyChart extends StatelessWidget {
  final List<double> data;
  const _WeeklyChart({required this.data});

  @override
  Widget build(BuildContext context) {
    final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final todayIndex = DateTime.now().weekday - 1;

    return SizedBox(
      height: 140,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(7, (i) {
          final val     = data.length > i ? data[i] : 0.0;
          final isToday = i == todayIndex;
          final height  = val > 0 ? 100.0 : 20.0;

          return Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 5),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeOut,
                    height: height,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      gradient: val > 0
                          ? LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: isToday
                            ? [AppColors.teal, AppColors.teal2]
                            : [
                          AppColors.purple,
                          AppColors.purple2,
                        ],
                      )
                          : null,
                      color: val == 0
                          ? Colors.white.withValues(alpha: 0.08)
                          : null,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    days[i],
                    style: TextStyle(
                      fontSize: 11,
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w700,
                      color: isToday
                          ? AppColors.teal
                          : Colors.white.withValues(alpha: 0.45),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}






