import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_colors.dart';
//import '../utils/constants.dart';
import '../widgets/glass_card.dart';
import '../widgets/progress_ring.dart';
import '../widgets/streak_badge.dart';
import '../providers/reminder_provider.dart';
import '../providers/score_provider.dart';
import '../providers/user_provider.dart';
import '../models/reminder_model.dart';
import 'discipline_screen.dart';
import 'tasks_screen.dart';
import 'stats_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ReminderProvider>(
      builder: (context, reminderProvider, _) {
        return Consumer<ScoreProvider>(
          builder: (context, scoreProvider, _) {
            return Consumer<UserProvider>(
              builder: (context, userProvider, _) {
                final reminders = reminderProvider.reminders;
                final recent = reminders.take(3).toList();
                final user = userProvider.user;

                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 🔥 Header with User Name
                      _buildHeader(context, user.name, reminderProvider.streak),
                      const SizedBox(height: 20),

                      // 🔥 Discipline Score Card
                      _buildDisciplineCard(context, scoreProvider),
                      const SizedBox(height: 16),

                      // 🔥 Today's Progress Ring
                      _buildProgressCard(context, reminderProvider),
                      const SizedBox(height: 16),

                      // 🔥 Quick Actions Row
                      _buildQuickActions(context),
                      const SizedBox(height: 16),

                      // 🔥 Today's Tasks Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Today's Hits",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              fontFamily: 'Nunito',
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const TasksScreen()),
                            ),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'View All',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.6),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                  fontFamily: 'Nunito',
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // 🔥 Task List
                      if (reminders.isEmpty)
                        _buildEmptyState()
                      else
                        ...recent.map((r) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _HitTile(
                            reminder: r,
                            onComplete: () {
                              // Confetti + Score update
                              scoreProvider.completeTask(
                                isOnTime: true,
                                currentStreak: reminderProvider.streak,
                              );
                            },
                          ),
                        )),

                      const SizedBox(height: 20),

                      // 🔥 Stats Preview
                      _buildStatsPreview(context, scoreProvider),
                      const SizedBox(height: 90),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  // 🔥 HEADER
  Widget _buildHeader(BuildContext context, String name, int streak) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Good morning,',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.6),
                  fontFamily: 'Nunito',
                ),
              ),
              const SizedBox(height: 4),
              Text(
                name.isEmpty ? 'Fahad' : name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontFamily: 'Nunito',
                ),
              ),
            ],
          ),
        ),
        StreakBadge(days: streak),
      ],
    );
  }

  // 🔥 DISCIPLINE SCORE CARD
  Widget _buildDisciplineCard(BuildContext context, ScoreProvider provider) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const DisciplineScreen()),
      ),
      child: GlassCard(
        borderRadius: BorderRadius.circular(24),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
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
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
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
                Icon(
                  Icons.chevron_right,
                  color: Colors.white.withValues(alpha: 0.3),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 70,
                      height: 70,
                      child: CircularProgressIndicator(
                        value: provider.levelProgress,
                        strokeWidth: 5,
                        backgroundColor: Colors.white.withValues(alpha: 0.1),
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6C63FF)),
                      ),
                    ),
                    Text(
                      '${provider.totalScore}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'Nunito',
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildMiniStat('Today', '+${provider.todayScore}', Colors.green),
                      const SizedBox(height: 6),
                      _buildMiniStat('Done', '${provider.score.tasksCompleted}', AppColors.teal),
                      const SizedBox(height: 6),
                      _buildMiniStat('Streak', '${provider.score.currentStreak}', Colors.orange),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 🔥 PROGRESS CARD
  Widget _buildProgressCard(BuildContext context, ReminderProvider provider) {
    final progress = provider.totalCount > 0
        ? provider.doneCount / provider.totalCount
        : 0.0;

    return GlassCard(
      borderRadius: BorderRadius.circular(24),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Today's Progress",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'Nunito',
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${provider.doneCount} of ${provider.totalCount} completed',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.6),
                    fontFamily: 'Nunito',
                  ),
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.white.withValues(alpha: 0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      progress >= 1.0 ? AppColors.teal : const Color(0xFF6C63FF),
                    ),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          ProgressRing(
            progress: progress,
            size: 80,
          ),
        ],
      ),
    );
  }

  // 🔥 QUICK ACTIONS
  Widget _buildQuickActions(BuildContext context) {
    final actions = [
      {'icon': Icons.add_task, 'label': 'Add Task', 'color': const Color(0xFF6C63FF)},
      {'icon': Icons.insights, 'label': 'Stats', 'color': const Color(0xFF1D9E75)},
      {'icon': Icons.person, 'label': 'Profile', 'color': const Color(0xFFFFA726)},
    ];

    return Row(
      children: actions.map((action) {
        return Expanded(
          child: GestureDetector(
            onTap: () {
              if (action['label'] == 'Stats') {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const StatsScreen()));
              } else if (action['label'] == 'Profile') {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
              }
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: (action['color'] as Color).withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    action['icon'] as IconData,
                    color: action['color'] as Color,
                    size: 24,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    action['label'] as String,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.7),
                      fontFamily: 'Nunito',
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // 🔥 EMPTY STATE
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 30),
        child: Column(
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 48,
              color: Colors.white.withValues(alpha: 0.2),
            ),
            const SizedBox(height: 12),
            Text(
              'No tasks yet',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.4),
                fontFamily: 'Nunito',
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Tap + to add your first habit',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.3),
                fontFamily: 'Nunito',
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔥 STATS PREVIEW
  Widget _buildStatsPreview(BuildContext context, ScoreProvider provider) {
    provider.getDailyReport();

    return GlassCard(
      borderRadius: BorderRadius.circular(20),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'This Week',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Nunito',
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const StatsScreen()),
                ),
                child: Icon(
                  Icons.arrow_forward,
                  size: 16,
                  color: Colors.white.withValues(alpha: 0.4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildWeekStat('Mon', '85%', Colors.green),
              _buildWeekStat('Tue', '60', Colors.orange),
              _buildWeekStat('Wed', '100', AppColors.teal),
              _buildWeekStat('Thu', '40', Colors.red),
              _buildWeekStat('Fri', '90', Colors.green),
              _buildWeekStat('Sat', '70', Colors.orange),
              _buildWeekStat('Sun', '-', Colors.white24),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeekStat(String day, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: color,
            fontFamily: 'Nunito',
          ),
        ),
        const SizedBox(height: 4),
        Text(
          day,
          style: TextStyle(
            fontSize: 10,
            color: Colors.white.withValues(alpha: 0.5),
            fontFamily: 'Nunito',
          ),
        ),
      ],
    );
  }

  Widget _buildMiniStat(String label, String value, Color color) {
    return Row(
      children: [
        Icon(Icons.circle, size: 6, color: color),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.white.withValues(alpha: 0.6),
            fontFamily: 'Nunito',
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: color,
            fontFamily: 'Nunito',
          ),
        ),
      ],
    );
  }

}

// 🔥 HIT TILE with Confetti
class _HitTile extends StatelessWidget {
  final ReminderModel reminder;
  final VoidCallback? onComplete;

  const _HitTile({required this.reminder, this.onComplete});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderRadius: BorderRadius.circular(18),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: reminder.isDone
                  ? AppColors.teal.withValues(alpha: 0.2)
                  : AppColors.purple.withValues(alpha: 0.18),
              border: Border.all(
                color: reminder.isDone
                    ? AppColors.teal.withValues(alpha: 0.5)
                    : AppColors.purple.withValues(alpha: 0.30),
              ),
            ),
            child: Icon(
              reminder.isDone ? Icons.check : reminder.icon,
              color: reminder.isDone ? AppColors.teal : Colors.white.withValues(alpha: 0.9),
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
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontFamily: 'Nunito',
                    decoration: reminder.isDone ? TextDecoration.lineThrough : null,
                    decorationColor: Colors.white.withValues(alpha: 0.3),
                    color: reminder.isDone
                        ? Colors.white.withValues(alpha: 0.5)
                        : Colors.white,
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
          GestureDetector(
            onTap: onComplete,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 28,
              height: 28,
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
          ),
        ],
      ),
    );
  }
}


