import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/score_provider.dart';
import '../services/discipline_score_service.dart';
import '../widgets/glass_card.dart';
import '../models/discipline_score.dart';  // <-- YEH ADD KARO

class DisciplineScreen extends StatelessWidget {
  const DisciplineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      body: Consumer<ScoreProvider>(
        builder: (context, scoreProvider, child) {
          final report = scoreProvider.getDailyReport();
          final score = scoreProvider.score;

          return SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  const Text(
                    'Discipline Score',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'Nunito',
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Track your daily discipline progress',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.6),
                      fontFamily: 'Nunito',
                    ),
                  ),
                  SizedBox(height: 30),

                  // Main Score Card
                  _buildScoreCard(report, scoreProvider),
                  SizedBox(height: 20),

                  // Stats Grid
                  _buildStatsGrid(score),
                  SizedBox(height: 20),

                  // Level Progress
                  _buildLevelProgress(scoreProvider),
                  SizedBox(height: 20),

                  // Weekly History
                  _buildHistorySection(score),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildScoreCard(Map<String, dynamic> report, ScoreProvider provider) {
    return GlassCard(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            // Rank Badge
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: _getRankColor(report['rank']).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _getRankColor(report['rank']).withValues(alpha: 0.5),
                ),
              ),
              child: Text(
                report['rank'],
                style: TextStyle(
                  color: _getRankColor(report['rank']),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Nunito',
                ),
              ),
            ),
            SizedBox(height: 20),

            // Big Score
            Text(
              '${provider.totalScore}',
              style: TextStyle(
                fontSize: 56,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontFamily: 'Nunito',
              ),
            ),
            const Text(
              'TOTAL SCORE',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white54,
                letterSpacing: 2,
                fontFamily: 'Nunito',
              ),
            ),
            SizedBox(height: 16),

            // Today's Score
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildMiniStat('Today', '+${provider.todayScore}', Colors.green),
                SizedBox(width: 30),
                _buildMiniStat('Level', '${report['level']}', Colors.blue),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
            fontFamily: 'Nunito',
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.white54,
            fontFamily: 'Nunito',
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid(DisciplineScore score) {
    final stats = [
      {'icon': Icons.check_circle, 'label': 'Completed', 'value': '${score.tasksCompleted}', 'color': Colors.green},
      {'icon': Icons.cancel, 'label': 'Missed', 'value': '${score.tasksMissed}', 'color': Colors.red},
      {'icon': Icons.local_fire_department, 'label': 'Streak', 'value': '${score.currentStreak}', 'color': Colors.orange},
      {'icon': Icons.emoji_events, 'label': 'Best', 'value': '${score.bestStreak}', 'color': Colors.amber},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.4,
      ),
      itemCount: stats.length,
      itemBuilder: (context, index) {
        final stat = stats[index];
        return GlassCard(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(stat['icon'] as IconData, color: stat['color'] as Color, size: 24),
                const Spacer(),
                Text(
                  stat['value'] as String,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'Nunito',
                  ),
                ),
                Text(
                  stat['label'] as String,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white54,
                    fontFamily: 'Nunito',
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLevelProgress(ScoreProvider provider) {
    return GlassCard(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Level Progress',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                fontFamily: 'Nunito',
              ),
            ),
            SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: provider.levelProgress,
                backgroundColor: Colors.white.withValues(alpha: 0.1),
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6C63FF)),
                minHeight: 8,
              ),
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Level ${provider.level}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white54,
                    fontFamily: 'Nunito',
                  ),
                ),
                Text(
                  '${(provider.levelProgress * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                    fontFamily: 'Nunito',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistorySection(DisciplineScore score) {
    if (score.history.isEmpty) {
      return GlassCard(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.history, size: 40, color: Colors.white.withValues(alpha: 0.3)),
                SizedBox(height: 12),
                Text(
                  'No history yet',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontFamily: 'Nunito',
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Activity',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            fontFamily: 'Nunito',
          ),
        ),
        SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: score.history.length > 7 ? 7 : score.history.length,
          itemBuilder: (context, index) {
            final history = score.history.reversed.toList()[index];
            return Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: GlassCard(
                child: ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: history.score > 0
                          ? Colors.green.withValues(alpha: 0.2)
                          : Colors.red.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      history.score > 0 ? Icons.trending_up : Icons.trending_down,
                      color: history.score > 0 ? Colors.green : Colors.red,
                    ),
                  ),
                  title: Text(
                    '${history.tasksDone}/${history.tasksTotal} tasks',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    '${history.date.day}/${history.date.month}/${history.date.year}',
                    style: TextStyle(
                      color: Colors.white54,
                      fontFamily: 'Nunito',
                      fontSize: 12,
                    ),
                  ),
                  trailing: Text(
                    '+${history.score}',
                    style: TextStyle(
                      color: history.score > 0 ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Nunito',
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Color _getRankColor(String rank) {
    final hexColor = DisciplineScoreService.getRankColor(rank);
    return Color(int.parse(hexColor.replaceFirst('#', '0xFF')));
  }
}




