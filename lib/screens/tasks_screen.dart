import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_colors.dart';
import '../utils/constants.dart';
import '../widgets/glass_card.dart';
import '../providers/reminder_provider.dart';
import '../models/reminder_model.dart';

class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ReminderProvider>(
      builder: (context, provider, _) {
        final reminders = provider.reminders;
        final doneCount = provider.doneCount;
        final progress  = provider.progress;

        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(18, 14, 18, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Today's Tasks",
                  style: kH2(context).copyWith(fontSize: 22)),
              SizedBox(height: 8),
              Text(
                '$doneCount of ${reminders.length} completed',
                style: kBody(context),
              ),
              SizedBox(height: 12),
              _ProgressBar(progress: progress),
              SizedBox(height: 16),

              if (reminders.isEmpty)
                Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 40),
                    child: Column(
                      children: [
                        Icon(Icons.add_circle_outline_rounded,
                            size: 48,
                            color: Colors.white.withValues(alpha: 0.25)),
                        SizedBox(height: 12),
                        Text(
                          'Koi reminder nahi\nAdd karo pehla task!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.4),
                            fontFamily: 'Nunito',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else ...[
                Text(
                  'Pending',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                    fontFamily: 'Nunito',
                  ),
                ),
                SizedBox(height: 10),
                ...reminders
                    .where((r) => !r.isDone)
                    .map((r) => Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: _TaskTile(
                    reminder: r,
                    onToggle: () =>
                        provider.toggleDone(r.id),
                    onDelete: () =>
                        provider.deleteReminder(r.id),
                  ),
                )),
                if (reminders.any((r) => r.isDone)) ...[
                  SizedBox(height: 8),
                  Text(
                    'Completed',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.4),
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                      fontFamily: 'Nunito',
                    ),
                  ),
                  SizedBox(height: 10),
                  ...reminders
                      .where((r) => r.isDone)
                      .map((r) => Padding(
                    padding: EdgeInsets.only(bottom: 10),
                    child: _TaskTile(
                      reminder: r,
                      onToggle: () =>
                          provider.toggleDone(r.id),
                      onDelete: () =>
                          provider.deleteReminder(r.id),
                    ),
                  )),
                ],
              ],
              SizedBox(height: 90),
            ],
          ),
        );
      },
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final double progress;
  const _ProgressBar({required this.progress});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(99),
      child: Container(
        height: 8,
        color: Colors.white.withValues(alpha: 0.08),
        child: Align(
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: progress.clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(gradient: kMainGradient),
            ),
          ),
        ),
      ),
    );
  }
}

class _TaskTile extends StatelessWidget {
  final ReminderModel reminder;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const _TaskTile({
    required this.reminder,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(reminder.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.danger.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Icon(Icons.delete_rounded,
            color: AppColors.danger),
      ),
      child: GlassCard(
        borderRadius: BorderRadius.circular(18),
        padding: EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 44,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(99),
                color: reminder.isDone
                    ? AppColors.teal
                    : AppColors.purple,
              ),
            ),
            SizedBox(width: 10),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: AppColors.purple.withValues(alpha: 0.15),
                border: Border.all(
                    color: AppColors.purple.withValues(alpha: 0.30)),
              ),
              child: Icon(reminder.icon,
                  color: Colors.white.withValues(alpha: 0.92), size: 20),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reminder.title,
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Nunito',
                      decoration: reminder.isDone
                          ? TextDecoration.lineThrough
                          : null,
                      color: reminder.isDone
                          ? Colors.white.withValues(alpha: 0.45)
                          : Colors.white,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    '${reminder.time.format(context)} · ${reminder.repeat}',
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
            InkWell(
              onTap: onToggle,
              borderRadius: BorderRadius.circular(99),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: reminder.isDone
                      ? AppColors.teal.withValues(alpha: 0.2)
                      : Colors.white.withValues(alpha: 0.08),
                  border: Border.all(
                    color: reminder.isDone
                        ? AppColors.teal
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
                      : Colors.white.withValues(alpha: 0.7),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}






