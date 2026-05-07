import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../utils/app_colors.dart';

class AppBackground extends StatelessWidget {
  final Widget child;
  const AppBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(gradient: kBgGradient),
        child: Stack(
          children: [
            Positioned(
              left: -120,
              top: 120,
              child: _GlowCircle(
                color: AppColors.purple.withValues(alpha: 0.22),
                size: 260,
              ),
            ),
            Positioned(
              right: -140,
              bottom: 140,
              child: _GlowCircle(
                color: AppColors.teal.withValues(alpha: 0.18),
                size: 300,
              ),
            ),
            SafeArea(child: child),
          ],
        ),
      ),
    );
  }
}

class _GlowCircle extends StatelessWidget {
  final Color color;
  final double size;
  const _GlowCircle({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color,
            blurRadius: 80,
            spreadRadius: 20,
          ),
        ],
      ),
    );
  }
}



