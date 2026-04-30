import 'package:flutter/material.dart';
import '../models/reminder_model.dart';
import '../utils/app_colors.dart';
import 'glass_card.dart';

class TaskCard extends StatelessWidget {
  final ReminderModel task;
  final VoidCallback onToggle;
  final bool overdue;

  const TaskCard({
    super.key,
    required this.task,
    required this.onToggle,
    this.overdue = false,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      radius: 18,
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(99),
              color: AppColors.purple.withOpacity(0.95),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: AppColors.purple.withOpacity(0.15),
              border: Border.all(
                color: AppColors.purple.withOpacity(0.30),
              ),
            ),
            child: Icon(
              task.icon,
              color: Colors.white.withOpacity(0.92),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontFamily: 'Nunito',
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  task.time.format(context),
                  style: TextStyle(
                    color: overdue
                        ? AppColors.danger
                        : Colors.white.withOpacity(0.55),
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    fontFamily: 'Nunito',
                  ),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(99),
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.08),
                border: Border.all(
                  color: Colors.white.withOpacity(0.14),
                ),
              ),
              child: Icon(
                task.isDone
                    ? Icons.check_rounded
                    : Icons.chevron_right_rounded,
                size: 18,
                color: task.isDone
                    ? AppColors.teal
                    : Colors.white.withOpacity(0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }
}