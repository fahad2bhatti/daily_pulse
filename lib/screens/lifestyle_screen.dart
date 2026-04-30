import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../models/habit_model.dart';
import '../widgets/app_background.dart';
import '../widgets/gradient_button.dart';
import 'wakeup_screen.dart';

class LifestyleScreen extends StatefulWidget {
  const LifestyleScreen({super.key});

  @override
  State<LifestyleScreen> createState() => _LifestyleScreenState();
}

class _LifestyleScreenState extends State<LifestyleScreen> {
  final _habits = [
    HabitModel(
      id: 'gym',
      title: 'Gym',
      iconCodePoint: Icons.fitness_center_rounded.codePoint.toString(),
    ),
    HabitModel(
      id: 'study',
      title: 'Study',
      iconCodePoint: Icons.menu_book_rounded.codePoint.toString(),
    ),
    HabitModel(
      id: 'meds',
      title: 'Meds',
      iconCodePoint: Icons.medication_rounded.codePoint.toString(),
    ),
    HabitModel(
      id: 'meals',
      title: 'Meals',
      iconCodePoint: Icons.restaurant_rounded.codePoint.toString(),
    ),
    HabitModel(
      id: 'water',
      title: 'Water',
      iconCodePoint: Icons.water_drop_rounded.codePoint.toString(),
    ),
    HabitModel(
      id: 'sleep',
      title: 'Sleep',
      iconCodePoint: Icons.nightlight_round.codePoint.toString(),
    ),
    HabitModel(
      id: 'meditation',
      title: 'Meditation',
      iconCodePoint: Icons.self_improvement_rounded.codePoint.toString(),
    ),
    HabitModel(
      id: 'running',
      title: 'Running',
      iconCodePoint: Icons.directions_run_rounded.codePoint.toString(),
    ),
  ];

  final _selected = <String>{};

  @override
  Widget build(BuildContext context) {
    final canContinue = _selected.isNotEmpty;

    return AppBackground(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('What defines your\nday?', style: kH2(context)),
            const SizedBox(height: 8),
            Text('Select the habits that matter most', style: kBody(context)),
            const SizedBox(height: 14),

            Expanded(
              child: GridView.builder(
                itemCount: _habits.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.05,
                ),
                itemBuilder: (context, i) {
                  final h = _habits[i];
                  final isSel = _selected.contains(h.id);

                  return InkWell(
                    onTap: () => setState(() {
                      isSel ? _selected.remove(h.id) : _selected.add(h.id);
                    }),
                    borderRadius: BorderRadius.circular(18),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        gradient: isSel
                            ? LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFF6D5BFF).withOpacity(0.35),
                            const Color(0xFF26D7A5).withOpacity(0.22),
                          ],
                        )
                            : null,
                        color: isSel
                            ? null
                            : Colors.white.withOpacity(0.06),
                        border: Border.all(
                          color: isSel
                              ? const Color(0xFF26D7A5).withOpacity(0.55)
                              : Colors.white.withOpacity(0.10),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              color: Colors.black.withOpacity(0.18),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.08),
                              ),
                            ),
                            child: Icon(
                              h.icon,
                              color: Colors.white.withOpacity(0.92),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            h.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Nunito',
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 10),

            GradientButton(
              text: canContinue ? 'Continue' : 'Select at least one',
              onTap: canContinue
                  ? () => Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => const WakeupScreen(),
                ),
              )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}