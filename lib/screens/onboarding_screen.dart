import 'package:flutter/material.dart';
import 'dart:math' show pi;
import 'lifestyle_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardData {
  final String titleA;
  final String titleB;
  final String subtitle;
  final IconData icon;
  final List<Color> colors;

  const _OnboardData({
    required this.titleA,
    required this.titleB,
    required this.subtitle,
    required this.icon,
    required this.colors,
  });
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final _controller = PageController();
  int _index = 0;

  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  final _pages = const [
    _OnboardData(
      titleA: 'Build',
      titleB: 'Discipline',
      subtitle: 'Transform your daily routine into\nunstoppable momentum',
      icon: Icons.local_fire_department,
      colors: [Color(0xFF6C63FF), Color(0xFF4A90E2)],
    ),
    _OnboardData(
      titleA: 'No',
      titleB: 'Excuses',
      subtitle: 'Your future self is counting on\nthe choices you make today',
      icon: Icons.fitness_center,
      colors: [Color(0xFF1D9E75), Color(0xFF4A90E2)],
    ),
    _OnboardData(
      titleA: 'Stay',
      titleB: 'Consistent',
      subtitle: 'Small actions every day create\nextraordinary results',
      icon: Icons.emoji_events,
      colors: [Color(0xFFFF6B6B), Color(0xFF6C63FF)],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<double>(begin: 50, end: 0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_index < _pages.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _goToLifestyle();
    }
  }

  void _goToLifestyle() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const LifestyleScreen(),
        transitionsBuilder: (_, a, __, c) {
          return FadeTransition(
            opacity: a,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.3),
                end: Offset.zero,
              ).animate(a),
              child: c,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      body: Stack(
        children: [
          // Full screen animated background
          ...List.generate(3, (i) {
            return AnimatedBuilder(
              animation: _animController,
              builder: (context, child) {
                return Positioned(
                  top: size.height * 0.1 + (i * 200),
                  left: i.isEven ? -80 : null,
                  right: i.isOdd ? -80 : null,
                  child: Transform.rotate(
                    angle: _animController.value * pi * (i + 1) * 0.3,
                    child: Container(
                      width: 250,
                      height: 250,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            _pages[_index].colors[0].withValues(alpha: 0.12),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          }),

          // Page View - Full Screen
          PageView.builder(
            controller: _controller,
            itemCount: _pages.length,
            onPageChanged: (i) {
              setState(() => _index = i);
              _animController.reset();
              _animController.forward();
            },
            itemBuilder: (context, i) {
              final p = _pages[i];
              return AnimatedBuilder(
                animation: _animController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, _slideAnimation.value),
                    child: Opacity(
                      opacity: _fadeAnimation.value,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Top spacing
                            SizedBox(height: size.height * 0.08),

                            // Page Indicator
                            _PageIndicator(
                              count: _pages.length,
                              index: _index,
                            ),

                            const Spacer(),

                            // Animated Icon - BIGGER
                            TweenAnimationBuilder(
                              tween: Tween<double>(begin: 0, end: 1),
                              duration: const Duration(milliseconds: 600),
                              builder: (context, value, child) {
                                return Transform.scale(
                                  scale: value,
                                  child: Container(
                                    width: 160,
                                    height: 160,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        colors: p.colors,
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: p.colors[0].withValues(alpha: 0.5),
                                          blurRadius: 40,
                                          spreadRadius: 10,
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      p.icon,
                                      size: 70,
                                      color: Colors.white,
                                    ),
                                  ),
                                );
                              },
                            ),

                            const SizedBox(height: 50),

                            // Title - BIGGER & FULL WIDTH
                            Text(
                              p.titleA,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 52,
                                fontWeight: FontWeight.w300,
                                color: Colors.white.withValues(alpha: 0.9),
                                fontFamily: 'Nunito',
                                height: 1.1,
                              ),
                            ),

                            // Gradient Title B
                            ShaderMask(
                              shaderCallback: (rect) => LinearGradient(
                                colors: p.colors,
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ).createShader(rect),
                              child: Text(
                                p.titleB,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 52,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontFamily: 'Nunito',
                                  height: 1.1,
                                ),
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Subtitle - BIGGER
                            Text(
                              p.subtitle,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white.withValues(alpha: 0.6),
                                fontFamily: 'Nunito',
                                height: 1.6,
                              ),
                            ),

                            const Spacer(),

                            // Next Button - FULL WIDTH
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                gradient: LinearGradient(
                                  colors: p.colors,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: p.colors[0].withValues(alpha: 0.4),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: _next,
                                  borderRadius: BorderRadius.circular(16),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 18),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          i == _pages.length - 1 ? "Let's Begin" : 'Next',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            fontFamily: 'Nunito',
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        const Icon(
                                          Icons.arrow_forward_rounded,
                                          color: Colors.white,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 12),

                            // Skip Button
                            TextButton(
                              onPressed: _goToLifestyle,
                              child: Text(
                                'Skip',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.5),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Nunito',
                                ),
                              ),
                            ),

                            // Bottom spacing
                            SizedBox(height: size.height * 0.05),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class _PageIndicator extends StatelessWidget {
  final int count;
  final int index;

  const _PageIndicator({required this.count, required this.index});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final selected = i == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: selected ? 28 : 8,
          height: 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(99),
            gradient: selected
                ? const LinearGradient(
              colors: [Color(0xFF6C63FF), Color(0xFF4A90E2)],
            )
                : null,
            color: selected ? null : Colors.white.withValues(alpha: 0.2),
          ),
        );
      }),
    );
  }
}


