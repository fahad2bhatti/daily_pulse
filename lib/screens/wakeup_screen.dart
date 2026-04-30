import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../utils/constants.dart';
import '../widgets/app_background.dart';
import '../widgets/gradient_button.dart';
import 'app_shell.dart';

class WakeupScreen extends StatefulWidget {
  const WakeupScreen({super.key});

  @override
  State<WakeupScreen> createState() => _WakeupScreenState();
}

class _WakeupScreenState extends State<WakeupScreen> {
  int _hour = 7;
  int _minute = 0;
  bool _am = true;

  void _incHour(int d) => setState(() {
    _hour += d;
    if (_hour <= 0) _hour = 12;
    if (_hour > 12) _hour = 1;
  });

  void _incMinute(int d) => setState(() {
    _minute += d;
    if (_minute < 0) _minute = 55;
    if (_minute >= 60) _minute = 0;
  });

  Widget _ampmChip(String label, {required bool selected}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: selected ? kMainGradient : null,
        color: selected ? null : Colors.transparent,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: 12,
          fontFamily: 'Nunito',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hh = _hour.toString().padLeft(2, '0');
    final mm = _minute.toString().padLeft(2, '0');

    return AppBackground(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('When do you rise?', style: kH2(context)),
            const SizedBox(height: 6),
            Text(
              "We'll build your day around this",
              style: kBody(context),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Center(
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.05),
                    border: Border.all(
                      color: AppColors.purple.withOpacity(0.25),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(
                            onPressed: () => _incHour(1),
                            icon: Icon(
                              Icons.keyboard_arrow_up_rounded,
                              color: Colors.white.withOpacity(0.65),
                            ),
                          ),
                          IconButton(
                            onPressed: () => _incMinute(5),
                            icon: Icon(
                              Icons.keyboard_arrow_up_rounded,
                              color: Colors.white.withOpacity(0.65),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '$hh : $mm',
                        style: TextStyle(
                          fontSize: 44,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2,
                          fontFamily: 'Nunito',
                          color: AppColors.teal.withOpacity(0.9),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.20),
                          borderRadius: BorderRadius.circular(99),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.10),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            InkWell(
                              onTap: () => setState(() => _am = true),
                              child: _ampmChip('AM', selected: _am),
                            ),
                            InkWell(
                              onTap: () => setState(() => _am = false),
                              child: _ampmChip('PM', selected: !_am),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(
                            onPressed: () => _incHour(-1),
                            icon: Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: Colors.white.withOpacity(0.65),
                            ),
                          ),
                          IconButton(
                            onPressed: () => _incMinute(-5),
                            icon: Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: Colors.white.withOpacity(0.65),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            GradientButton(
              text: 'Start My Journey',
              trailing: Icons.arrow_forward_rounded,
              onTap: () => Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const AppShell()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}