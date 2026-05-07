import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_colors.dart';
import '../utils/constants.dart';
import '../widgets/glass_card.dart';
import '../widgets/gradient_button.dart';
import '../models/reminder_model.dart';
import '../providers/reminder_provider.dart';

class AddReminderScreen extends StatefulWidget {
  const AddReminderScreen({super.key});

  @override
  State<AddReminderScreen> createState() => _AddReminderScreenState();
}

class _AddReminderScreenState extends State<AddReminderScreen> {
  final _nameCtrl = TextEditingController();
  IconData _selectedIcon = Icons.fitness_center_rounded;
  TimeOfDay _time = const TimeOfDay(hour: 9, minute: 0);
  String _repeat = 'Daily';
  bool _sound = true;
  bool _vibration = true;
  bool _saving = false;

  final _icons = <IconData>[
    Icons.fitness_center_rounded,
    Icons.menu_book_rounded,
    Icons.medication_rounded,
    Icons.restaurant_rounded,
    Icons.water_drop_rounded,
    Icons.nightlight_round,
    Icons.self_improvement_rounded,
    Icons.directions_run_rounded,
    Icons.auto_stories_rounded,
    Icons.work_rounded,
    Icons.brush_rounded,
    Icons.track_changes_rounded,
  ];

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time,
      builder: (context, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.teal,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _time = picked);
  }

  Future<void> _save() async {
    if (_nameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Task name likhna zaroori hai!')),
      );
      return;
    }

    setState(() => _saving = true);

    final reminder = ReminderModel(
      id:            DateTime.now().millisecondsSinceEpoch.toString(),
      title:         _nameCtrl.text.trim(),
      iconCodePoint: _selectedIcon.codePoint.toString(),
      timeHour:      _time.hour,
      timeMinute:    _time.minute,
      repeat:        _repeat,
      sound:         _sound,
      vibration:     _vibration,
    );

    await context.read<ReminderProvider>().addReminder(reminder);

    setState(() => _saving = false);

    if (!mounted) return;
    _nameCtrl.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Reminder save ho gaya! ✅'),
        backgroundColor: AppColors.teal.withValues(alpha: 0.8),
      ),
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(18, 14, 18, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Add Reminder', style: kH2(context).copyWith(fontSize: 22)),
          SizedBox(height: 14),

          _label('Task Name'),
          SizedBox(height: 8),
          TextField(
            controller: _nameCtrl,
            style: TextStyle(fontFamily: 'Nunito'),
            decoration: InputDecoration(
              hintText: 'e.g., Morning Workout',
              hintStyle: TextStyle(
                color: Colors.white.withValues(alpha: 0.28),
                fontFamily: 'Nunito',
              ),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.06),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.10)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.10)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: AppColors.teal.withValues(alpha: 0.6)),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 14, vertical: 14,
              ),
            ),
          ),
          SizedBox(height: 16),

          _label('Choose Icon'),
          SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _icons.map((ic) {
              final sel = ic == _selectedIcon;
              return InkWell(
                onTap: () => setState(() => _selectedIcon = ic),
                borderRadius: BorderRadius.circular(14),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: sel ? kMainGradient : null,
                    color: sel ? null : Colors.white.withValues(alpha: 0.06),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: sel ? 0.0 : 0.10),
                    ),
                  ),
                  child: Icon(ic, color: Colors.white.withValues(alpha: 0.92), size: 22),
                ),
              );
            }).toList(),
          ),
          SizedBox(height: 16),

          _label('Time'),
          SizedBox(height: 8),
          InkWell(
            onTap: _pickTime,
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
              ),
              child: Row(
                children: [
                  Icon(Icons.access_time_rounded,
                      color: Colors.white.withValues(alpha: 0.8)),
                  SizedBox(width: 10),
                  Text(
                    _time.format(context),
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Nunito',
                    ),
                  ),
                  const Spacer(),
                  Icon(Icons.chevron_right_rounded,
                      color: Colors.white.withValues(alpha: 0.6)),
                ],
              ),
            ),
          ),
          SizedBox(height: 16),

          _label('Repeat'),
          SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: ['Daily', 'Weekdays', 'Weekend', 'Custom']
                .map((r) => InkWell(
              onTap: () => setState(() => _repeat = r),
              borderRadius: BorderRadius.circular(99),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                padding: EdgeInsets.symmetric(
                  horizontal: 16, vertical: 10,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(99),
                  gradient: _repeat == r ? kMainGradient : null,
                  color: _repeat == r
                      ? null
                      : Colors.white.withValues(alpha: 0.06),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.10),
                  ),
                ),
                child: Text(
                  r,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                    fontFamily: 'Nunito',
                  ),
                ),
              ),
            ))
                .toList(),
          ),
          SizedBox(height: 16),

          _toggleRow('Sound', Icons.notifications_active_rounded,
              _sound, (v) => setState(() => _sound = v)),
          SizedBox(height: 10),
          _toggleRow('Vibration', Icons.vibration_rounded,
              _vibration, (v) => setState(() => _vibration = v)),

          SizedBox(height: 18),

          GradientButton(
            text: _saving ? 'Saving...' : 'Save Reminder',
            trailing: _saving ? null : Icons.check_rounded,
            onTap: _saving ? null : _save,
          ),
          SizedBox(height: 90),
        ],
      ),
    );
  }

  Widget _label(String text) => Text(
    text,
    style: TextStyle(
      color: Colors.white.withValues(alpha: 0.65),
      fontWeight: FontWeight.w800,
      fontSize: 12,
      fontFamily: 'Nunito',
    ),
  );

  Widget _toggleRow(String label, IconData icon, bool value,
      ValueChanged<bool> onChanged) {
    return GlassCard(
      radius: 16,
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: Colors.white.withValues(alpha: 0.85)),
          SizedBox(width: 10),
          Text(label,
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontFamily: 'Nunito',
              )),
          const Spacer(),
          Switch(value: value, onChanged: onChanged, activeThumbColor: AppColors.teal),
        ],
      ),
    );
  }
}





