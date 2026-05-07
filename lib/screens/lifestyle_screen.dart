import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' show pi;
import '../providers/user_provider.dart';
import 'wakeup_screen.dart';

class LifestyleScreen extends StatefulWidget {
  const LifestyleScreen({super.key});

  @override
  State<LifestyleScreen> createState() => _LifestyleScreenState();
}

class _LifestyleOption {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> colors;
  final String description;

  const _LifestyleOption({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.colors,
    required this.description,
  });
}

class _LifestyleScreenState extends State<LifestyleScreen>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = -1;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  final _options = const [
    _LifestyleOption(
      title: 'Early Bird',
      subtitle: '5:00 - 9:00 AM',
      icon: Icons.wb_sunny_outlined,
      colors: [Color(0xFFFFA726), Color(0xFFFF7043)],
      description: 'Rise with the sun and conquer\nyour day before noon',
    ),
    _LifestyleOption(
      title: 'Night Owl',
      subtitle: '6:00 PM - 12:00 AM',
      icon: Icons.nights_stay_outlined,
      colors: [Color(0xFF7C4DFF), Color(0xFF536DFE)],
      description: 'Peak performance when the\nworld goes quiet',
    ),
    _LifestyleOption(
      title: 'Flexible',
      subtitle: 'Anytime works',
      icon: Icons.schedule_outlined,
      colors: [Color(0xFF26A69A), Color(0xFF42A5F5)],
      description: 'Adapt and thrive on your\nown unique rhythm',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _selectOption(int index) {
    setState(() => _selectedIndex = index);

    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) {
        final lifestyle = _options[index].title;
        context.read<UserProvider>().updateLifestyle(lifestyle);

        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const WakeupScreen(),
            transitionsBuilder: (_, a, __, c) {
              return FadeTransition(
                opacity: a,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.2),
                    end: Offset.zero,
                  ).animate(a),
                  child: c,
                ),
              );
            },
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      body: Stack(
        children: [
          // Animated background orbs
          ...List.generate(2, (i) {
            return Positioned(
              top: i == 0 ? -100 : size.height * 0.6,
              left: i == 0 ? -80 : size.width * 0.5,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _controller.value * pi * 0.3,
                    child: Container(
                      width: 300,
                      height: 300,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            _selectedIndex >= 0
                                ? _options[_selectedIndex].colors[0].withValues(alpha: 0.15)
                                : const Color(0xFF6C63FF).withValues(alpha: 0.1),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          }),

          // Main Content — SingleChildScrollView added here
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: size.height * 0.04),

                    // Back Button
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.1),
                          ),
                        ),
                        child: Icon(
                          Icons.arrow_back_rounded,
                          color: Colors.white.withValues(alpha: 0.7),
                          size: 20,
                        ),
                      ),
                    ),

                    SizedBox(height: size.height * 0.03),

                    // Title
                    AnimatedBuilder(
                      animation: _fadeAnimation,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _fadeAnimation.value,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'What defines',
                                style: TextStyle(
                                  fontSize: 40,
                                  fontWeight: FontWeight.w300,
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontFamily: 'Nunito',
                                  height: 1.1,
                                ),
                              ),
                              ShaderMask(
                                shaderCallback: (rect) => const LinearGradient(
                                  colors: [Color(0xFF6C63FF), Color(0xFF4A90E2)],
                                ).createShader(rect),
                                child: const Text(
                                  'your day?',
                                  style: TextStyle(
                                    fontSize: 40,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontFamily: 'Nunito',
                                    height: 1.1,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 8),

                    // Subtitle
                    Text(
                      'Choose your rhythm to personalize\nyour experience',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.white.withValues(alpha: 0.5),
                        fontFamily: 'Nunito',
                        height: 1.5,
                      ),
                    ),

                    SizedBox(height: size.height * 0.03),

                    // Options
                    ...List.generate(_options.length, (index) {
                      final option = _options[index];
                      final isSelected = _selectedIndex == index;
                      final isAnimating = _selectedIndex >= 0 && !isSelected;

                      return AnimatedPadding(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        padding: EdgeInsets.only(
                          bottom: 16,
                          left: isAnimating ? 20 : 0,
                          right: isAnimating ? 20 : 0,
                        ),
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 300),
                          opacity: isAnimating ? 0.3 : 1,
                          child: GestureDetector(
                            onTap: () => _selectOption(index),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeInOut,
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                gradient: isSelected
                                    ? LinearGradient(
                                  colors: [
                                    option.colors[0].withValues(alpha: 0.3),
                                    option.colors[1].withValues(alpha: 0.2),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                )
                                    : null,
                                color: isSelected
                                    ? null
                                    : Colors.white.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected
                                      ? option.colors[0].withValues(alpha: 0.5)
                                      : Colors.white.withValues(alpha: 0.08),
                                  width: isSelected ? 2 : 1,
                                ),
                                boxShadow: isSelected
                                    ? [
                                  BoxShadow(
                                    color: option.colors[0].withValues(alpha: 0.3),
                                    blurRadius: 20,
                                    spreadRadius: -5,
                                  ),
                                ]
                                    : null,
                              ),
                              child: Row(
                                children: [
                                  // Icon Container
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    width: 56,
                                    height: 56,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: option.colors,
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: option.colors[0].withValues(alpha: 0.4),
                                          blurRadius: isSelected ? 15 : 8,
                                          spreadRadius: isSelected ? 2 : 0,
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      option.icon,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                  ),
                                  const SizedBox(width: 16),

                                  // Text Content
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          option.title,
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: isSelected
                                                ? Colors.white
                                                : Colors.white.withValues(alpha: 0.9),
                                            fontFamily: 'Nunito',
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          option.subtitle,
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.white.withValues(alpha: 0.5),
                                            fontFamily: 'Nunito',
                                          ),
                                        ),
                                        AnimatedSize(
                                          duration: const Duration(milliseconds: 300),
                                          child: isSelected
                                              ? Padding(
                                            padding: const EdgeInsets.only(top: 8),
                                            child: Text(
                                              option.description,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: option.colors[0].withValues(alpha: 0.8),
                                                fontFamily: 'Nunito',
                                                height: 1.4,
                                              ),
                                            ),
                                          )
                                              : const SizedBox.shrink(),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Selection Indicator
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: isSelected
                                          ? LinearGradient(colors: option.colors)
                                          : null,
                                      color: isSelected ? null : Colors.transparent,
                                      border: Border.all(
                                        color: isSelected
                                            ? Colors.transparent
                                            : Colors.white.withValues(alpha: 0.2),
                                      ),
                                    ),
                                    child: isSelected
                                        ? const Icon(
                                      Icons.check_rounded,
                                      color: Colors.white,
                                      size: 16,
                                    )
                                        : null,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }),

                    const SizedBox(height: 20),

                    // Bottom hint
                    Center(
                      child: Text(
                        'Tap to select your lifestyle',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.3),
                          fontFamily: 'Nunito',
                        ),
                      ),
                    ),

                    SizedBox(height: size.height * 0.03),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}