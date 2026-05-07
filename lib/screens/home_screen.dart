import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_colors.dart';
import '../utils/constants.dart';
import '../widgets/glass_card.dart';
import '../widgets/progress_ring.dart';
import '../widgets/streak_badge.dart';
import '../providers/reminder_provider.dart';
import '../providers/score_provider.dart';
import '../models/reminder_model.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ReminderProvider>(
      builder: (context, reminderProvider, _) {
        return Consumer<ScoreProvider>(
          builder: (context, scoreProvider, _) {
            final reminders = reminderProvider.reminders;
            final recent = reminders.take(3).toList();
            final report = scoreProvider.getDailyReport();

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with Streak
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Good morning',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                fontFamily: 'Nunito',
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "Let's crush today, Fahad 🔥",
                              style: kBody(context),
                            ),
                          ],
                        ),
                      ),
                      StreakBadge(days: reminderProvider.streak),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Discipline Score Card
                  _buildDisciplineCard(context, scoreProvider, report),
                  const SizedBox(height: 16),

                  // Today's Progress
                  GlassCard(
                    radius: 20,
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Today's\nProgress",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  height: 1.1,
                                  fontFamily: 'Nunito',
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                '${reminderProvider.doneCount} of ${reminderProvider.totalCount} completed',
                                style: kBody(context),
                              ),
                              const SizedBox(height: 12),
                              Row(children: [
                                _dot(AppColors.purple),
                                const SizedBox(width: 6),
                                _dot(AppColors.teal),
                                const SizedBox(width: 6),
                                _dot(Colors.white.withValues(alpha: 0.20)),
                              ]),
                            ],
                          ),
                        ),
                        ProgressRing(
                          progress: reminderProvider.progress,
                          size: 96,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Today's Hits Header
                  Row(
                    children: [
                      const Text(
                        "Today's Hits",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          fontFamily: 'Nunito',
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'View All',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          fontFamily: 'Nunito',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Task List
                  if (reminders.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: Text(
                          'Koi task nahi — Add tab se add karo!',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.35),
                            fontFamily: 'Nunito',
                          ),
                        ),
                      ),
                    )
                  else
                    ...recent.map(
                          (r) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _HitTile(reminder: r),
                      ),
                    ),

                  const SizedBox(height: 90),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Discipline Score Card Widget
  Widget _buildDisciplineCard(BuildContext context, ScoreProvider provider, Map<String, dynamic> report) {
    return GlassCard(
      radius: 20,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              // Rank Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6C63FF), Color(0xFF4A90E2)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  provider.rank,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Nunito',
                  ),
                ),
              ),
              const Spacer(),
              // Level
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
                child: Text(
                  'Lvl ${provider.level}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Nunito',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Score Display with Ring
          Row(
            children: [
              // Animated Score Ring
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 80,
                    height: 80,
                    child: CircularProgressIndicator(
                      value: provider.levelProgress,
                      strokeWidth: 6,
                      backgroundColor: Colors.white.withValues(alpha: 0.1),
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6C63FF)),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${provider.totalScore}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: 'Nunito',
                        ),
                      ),
                      Text(
                        'SCORE',
                        style: TextStyle(
                          fontSize: 8,
                          color: Colors.white.withValues(alpha: 0.5),
                          fontFamily: 'Nunito',
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(width: 20),

              // Stats Column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatRow(Icons.add_circle, 'Today', '+${provider.todayScore}', Colors.green),
                    const SizedBox(height: 8),
                    _buildStatRow(Icons.check_circle, 'Done', '${provider.score.tasksCompleted}', AppColors.teal),
                    const SizedBox(height: 8),
                    _buildStatRow(Icons.local_fire_department, 'Streak', '${provider.score.currentStreak}', Colors.orange),
                  ],
                ),
              ),
            ],
          ),

          // Level Progress Bar
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: provider.levelProgress,
              backgroundColor: Colors.white.withValues(alpha: 0.1),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6C63FF)),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Level ${provider.level}',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.white.withValues(alpha: 0.5),
                  fontFamily: 'Nunito',
                ),
              ),
              Text(
                '${(provider.levelProgress * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.white.withValues(alpha: 0.7),
                  fontFamily: 'Nunito',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withValues(alpha: 0.6),
            fontFamily: 'Nunito',
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
            fontFamily: 'Nunito',
          ),
        ),
      ],
    );
  }

  static Widget _dot(Color c) => Container(
    width: 14,
    height: 4,
    decoration: BoxDecoration(
      color: c,
      borderRadius: BorderRadius.circular(99),
    ),
  );
}

class _HitTile extends StatelessWidget {
  final ReminderModel reminder;
  const _HitTile({required this.reminder});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      radius: 18,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: AppColors.purple.withValues(alpha: 0.18),
              border: Border.all(
                color: AppColors.purple.withValues(alpha: 0.30),
              ),
            ),
            child: Icon(
              reminder.icon,
              color: Colors.white.withValues(alpha: 0.9),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reminder.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontFamily: 'Nunito',
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  reminder.time.format(context),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.55),
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    fontFamily: 'Nunito',
                  ),
                ),
              ],
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: reminder.isDone
                  ? AppColors.teal.withValues(alpha: 0.18)
                  : Colors.white.withValues(alpha: 0.08),
              border: Border.all(
                color: reminder.isDone
                    ? AppColors.teal.withValues(alpha: 0.7)
                    : Colors.white.withValues(alpha: 0.14),
              ),
            ),
            child: Icon(
              reminder.isDone
                  ? Icons.check_rounded
                  : Icons.circle_outlined,
              size: 16,
              color: reminder.isDone
                  ? AppColors.teal
                  : Colors.white.withValues(alpha: 0.55),
            ),
          ),
        ],
      ),
    );
  }
}