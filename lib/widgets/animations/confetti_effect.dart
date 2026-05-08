import 'package:flutter/material.dart';
import 'dart:math';

class ConfettiOverlay extends StatefulWidget {
  final Widget child;

  const ConfettiOverlay({super.key, required this.child});

  static void show(BuildContext context) {
    final overlay = Overlay.of(context);
    final entry = OverlayEntry(
      builder: (context) => const ConfettiWidget(),
    );

    overlay.insert(entry);

    Future.delayed(const Duration(seconds: 2), () {
      entry.remove();
    });
  }

  @override
  State<ConfettiOverlay> createState() => _ConfettiOverlayState();
}

class _ConfettiOverlayState extends State<ConfettiOverlay> {
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

class ConfettiWidget extends StatefulWidget {
  const ConfettiWidget({super.key});

  @override
  State<ConfettiWidget> createState() => _ConfettiWidgetState();
}

class _ConfettiWidgetState extends State<ConfettiWidget>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  final List<ConfettiParticle> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _initParticles();
    _controller.forward();
  }

  void _initParticles() {
    final colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.yellow,
      Colors.purple,
      Colors.orange,
      Colors.pink,
      Colors.cyan,
      const Color(0xFF6C63FF),
      const Color(0xFF1D9E75),
    ];

    for (int i = 0; i < 60; i++) {
      _particles.add(ConfettiParticle(
        color: colors[_random.nextInt(colors.length)],
        x: _random.nextDouble() * 400 - 200,
        y: -_random.nextDouble() * 200 - 50,
        size: _random.nextDouble() * 10 + 4,
        speed: _random.nextDouble() * 250 + 150,
        angle: _random.nextDouble() * pi * 2,
        rotation: _random.nextDouble() * pi * 2,
        rotationSpeed: _random.nextDouble() * 12 - 6,
      ));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          children: [
            // Transparent background to catch taps
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {}, // Block taps during animation
            ),
            ..._particles.map((particle) {
              final progress = _controller.value;
              final currentY = particle.y + (particle.speed * progress);
              final currentX = particle.x +
                  (sin(progress * pi * 2 + particle.angle) * 60 * (1 - progress));
              final currentRotation = particle.rotation +
                  (particle.rotationSpeed * progress);

              return Positioned(
                left: size.width / 2 + currentX,
                top: currentY,
                child: Transform.rotate(
                  angle: currentRotation,
                  child: Opacity(
                    opacity: 1 - (progress * 0.8),
                    child: Container(
                      width: particle.size,
                      height: particle.size,
                      decoration: BoxDecoration(
                        color: particle.color,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }
}

class ConfettiParticle {
  final Color color;
  final double x;
  final double y;
  final double size;
  final double speed;
  final double angle;
  final double rotation;
  final double rotationSpeed;

  ConfettiParticle({
    required this.color,
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.angle,
    required this.rotation,
    required this.rotationSpeed,
  });
}


