import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../widgets/app_background.dart';
import '../widgets/gradient_button.dart';
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
  final LinearGradient bg;
  const _OnboardData({
    required this.titleA,
    required this.titleB,
    required this.subtitle,
    required this.bg,
  });
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _index = 0;

  final _pages = const [
    _OnboardData(
      titleA: 'Build',
      titleB: 'Discipline',
      subtitle: 'Transform your daily routine\ninto unstoppable momentum',
      bg: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF0D0B2A), Color(0xFF2B0A3A)],
      ),
    ),
    _OnboardData(
      titleA: 'No',
      titleB: 'Excuses',
      subtitle: 'Your future self is counting on\nthe choices you make today',
      bg: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF061C1E), Color(0xFF051226)],
      ),
    ),
    _OnboardData(
      titleA: 'Stay',
      titleB: 'Consistent',
      subtitle: 'Small actions every day create\nextraordinary results',
      bg: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF0A1026), Color(0xFF062120)],
      ),
    ),
  ];

  void _next() {
    if (_index < _pages.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    } else {
      _goToLifestyle();
    }
  }

  void _goToLifestyle() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LifestyleScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: _pages.length,
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (context, i) {
              final p = _pages[i];
              return Padding(
                padding: const EdgeInsets.fromLTRB(22, 18, 22, 22),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: p.bg,
                    borderRadius: BorderRadius.circular(26),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.06),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(22, 18, 22, 22),
                    child: Column(
                      children: [
                        const SizedBox(height: 4),
                        _PageIndicator(
                          count: _pages.length,
                          index: _index,
                        ),
                        const Spacer(),
                        Text(
                          p.titleA,
                          style: kH1(context).copyWith(
                            color: Colors.white.withOpacity(0.92),
                          ),
                        ),
                        ShaderMask(
                          shaderCallback: (rect) =>
                              kMainGradient.createShader(rect),
                          child: Text(
                            p.titleB,
                            style: kH1(context).copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          p.subtitle,
                          textAlign: TextAlign.center,
                          style: kBody(context),
                        ),
                        const Spacer(),
                        GradientButton(
                          text: i == _pages.length - 1
                              ? "Let's Begin"
                              : 'Next',
                          trailing: Icons.arrow_forward_rounded,
                          onTap: _next,
                        ),
                        const SizedBox(height: 6),
                        TextButton(
                          onPressed: _goToLifestyle,
                          child: Text(
                            'Skip',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.55),
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Nunito',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
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
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: selected ? 20 : 8,
          height: 5,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(99),
            color: selected
                ? Colors.white.withOpacity(0.9)
                : Colors.white.withOpacity(0.18),
          ),
        );
      }),
    );
  }
}