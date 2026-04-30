import 'package:flutter/material.dart';
import '../utils/constants.dart';
import 'glass_card.dart';

class DailyBottomNav extends StatelessWidget {
  final int index;
  final ValueChanged<int> onChange;

  const DailyBottomNav({
    super.key,
    required this.index,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
      child: GlassCard(
        radius: 20,
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
        child: Row(
          children: [
            _item(0, Icons.home_rounded, 'Home'),
            _item(1, Icons.checklist_rounded, 'Tasks'),
            const SizedBox(width: 6),
            _addBtn(),
            const SizedBox(width: 6),
            _item(3, Icons.bar_chart_rounded, 'Stats'),
            _item(4, Icons.person_rounded, 'Profile'),
          ],
        ),
      ),
    );
  }

  Widget _item(int i, IconData icon, String label) {
    final selected = index == i;
    return Expanded(
      child: InkWell(
        onTap: () => onChange(i),
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          margin: const EdgeInsets.symmetric(horizontal: 6),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected
                ? Colors.white.withOpacity(0.10)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected
                  ? Colors.white.withOpacity(0.12)
                  : Colors.transparent,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 20,
                color: selected
                    ? Colors.white
                    : Colors.white.withOpacity(0.55),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Nunito',
                  color: selected
                      ? Colors.white
                      : Colors.white.withOpacity(0.55),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _addBtn() {
    return InkWell(
      onTap: () => onChange(2),
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          gradient: kMainGradient,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6D5BFF).withOpacity(0.25),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: const Icon(
          Icons.add_rounded,
          color: Colors.white,
          size: 26,
        ),
      ),
    );
  }
}