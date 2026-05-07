import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class ProgressRing extends StatelessWidget {
  final double progress;
  final double size;

  const ProgressRing({
    super.key,
    required this.progress,
    this.size = 84,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 9,
              backgroundColor: Colors.white.withValues(alpha: 0.08),
              valueColor: const AlwaysStoppedAnimation(AppColors.teal),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${(progress * 100).round()}%',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                  fontFamily: 'Nunito',
                ),
              ),
              Text(
                'Done',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.55),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Nunito',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}




