import 'package:flutter/material.dart';
import 'dart:math';

class ProgressRing extends StatefulWidget {
  final double progress; // 0.0 to 1.0
  final double size;
  final double strokeWidth;
  final Color? backgroundColor;
  final Color? progressColor;
  final Widget? centerChild;
  final Duration animationDuration;

  const ProgressRing({
    super.key,
    required this.progress,
    this.size = 120,
    this.strokeWidth = 8,
    this.backgroundColor,
    this.progressColor,
    this.centerChild,
    this.animationDuration = const Duration(milliseconds: 1500),
  });

  @override
  State<ProgressRing> createState() => _ProgressRingState();
}

class _ProgressRingState extends State<ProgressRing>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );

    _animation = Tween<double>(
      begin: 0,
      end: widget.progress,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _controller.forward();
  }

  @override
  void didUpdateWidget(ProgressRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _animation = Tween<double>(
        begin: _animation.value,
        end: widget.progress,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ));
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.backgroundColor ?? Colors.white.withValues(alpha: 0.1);
    final progColor = widget.progressColor ?? const Color(0xFF6C63FF);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background ring
              CustomPaint(
                painter: _RingPainter(
                  progress: 1,
                  color: bgColor,
                  strokeWidth: widget.strokeWidth,
                ),
              ),
              // Progress ring
              CustomPaint(
                painter: _RingPainter(
                  progress: _animation.value,
                  color: progColor,
                  strokeWidth: widget.strokeWidth,
                  gradientColors: [
                    progColor,
                    progColor.withValues(alpha: 0.7),
                  ],
                ),
              ),
              // Center content
              if (widget.centerChild != null)
                Center(child: widget.centerChild!),
            ],
          ),
        );
      },
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;
  final List<Color>? gradientColors;

  _RingPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
    this.gradientColors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final rect = Rect.fromCircle(center: center, radius: radius);

    Paint paint;

    if (gradientColors != null && gradientColors!.length > 1) {
      paint = Paint()
        ..shader = SweepGradient(
          colors: gradientColors!,
          startAngle: -pi / 2,
          endAngle: -pi / 2 + (2 * pi * progress),
        ).createShader(rect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;
    } else {
      paint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;
    }

    canvas.drawArc(
      rect,
      -pi / 2,
      2 * pi * progress,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Usage example widget for home screen
class DailyProgressRing extends StatelessWidget {
  final int completedTasks;
  final int totalTasks;
  final String? label;

  const DailyProgressRing({
    super.key,
    required this.completedTasks,
    required this.totalTasks,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    final progress = totalTasks > 0 ? completedTasks / totalTasks : 0.0;
    final percentage = (progress * 100).toInt();

    return ProgressRing(
      progress: progress,
      size: 140,
      strokeWidth: 10,
      progressColor: progress >= 1.0
          ? const Color(0xFF1D9E75) // Green when complete
          : const Color(0xFF6C63FF), // Purple default
      centerChild: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$percentage%',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: 'Nunito',
            ),
          ),
          if (label != null)
            Text(
              label!,
              style: TextStyle(
                fontSize: 11,
                color: Colors.white54,
                fontFamily: 'Nunito',
              ),
            ),
        ],
      ),
    );
  }
}




