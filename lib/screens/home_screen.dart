import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_colors.dart';
import '../utils/constants.dart';
import '../widgets/glass_card.dart';
import '../widgets/progress_ring.dart';
import '../widgets/streak_badge.dart';
import '../providers/reminder_provider.dart';
import '../models/reminder_model.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ReminderProvider>(
      builder: (context, provider, _) {
        final reminders = provider.reminders;
        final recent = reminders.take(3).toList();

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                  StreakBadge(days: provider.streak),
                ],
              ),
              const SizedBox(height: 16),

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
                            '${provider.doneCount} of ${provider.totalCount} completed',
                            style: kBody(context),
                          ),
                          const SizedBox(height: 12),
                          Row(children: [
                            _dot(AppColors.purple),
                            const SizedBox(width: 6),
                            _dot(AppColors.teal),
                            const SizedBox(width: 6),
                            _dot(Colors.white.withOpacity(0.20)),
                          ]),
                        ],
                      ),
                    ),
                    ProgressRing(
                      progress: provider.progress,
                      size: 96,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

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
                      color: Colors.white.withOpacity(0.6),
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      fontFamily: 'Nunito',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              if (reminders.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Text(
                      'Koi task nahi — Add tab se add karo!',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.35),
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
              color: AppColors.purple.withOpacity(0.18),
              border: Border.all(
                  color: AppColors.purple.withOpacity(0.30)),
            ),
            child: Icon(reminder.icon,
                color: Colors.white.withOpacity(0.9), size: 20),
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
                    color: Colors.white.withOpacity(0.55),
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
                  ? AppColors.teal.withOpacity(0.18)
                  : Colors.white.withOpacity(0.08),
              border: Border.all(
                color: reminder.isDone
                    ? AppColors.teal.withOpacity(0.7)
                    : Colors.white.withOpacity(0.14),
              ),
            ),
            child: Icon(
              reminder.isDone
                  ? Icons.check_rounded
                  : Icons.circle_outlined,
              size: 16,
              color: reminder.isDone
                  ? AppColors.teal
                  : Colors.white.withOpacity(0.55),
            ),
          ),
        ],
      ),
    );
  }
}