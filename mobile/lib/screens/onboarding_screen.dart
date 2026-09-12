import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/theme.dart';
import 'login_screen.dart';

class _Slide {
  final IconData icon;
  final Color color;
  final String title;
  final String body;
  const _Slide(this.icon, this.color, this.title, this.body);
}

const _slides = [
  _Slide(Icons.insights_rounded, AppTheme.green, 'See your future health',
      'Aegis predicts your risk of diabetes and kidney disease years before it shows up.'),
  _Slide(Icons.bloodtype_outlined, AppTheme.coral, 'No blood test needed',
      'Just answer a few simple questions about your lifestyle. That’s it.'),
  _Slide(Icons.auto_awesome_rounded, AppTheme.amber, 'Know what to change',
      'Get clear, personalised advice on the habits that lower your risk the most.'),
];

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seen_onboarding', true);
    if (!mounted) return;
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final last = _page == _slides.length - 1;
    final p = Palette.of(context);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _finish,
                child: Text('Skip', style: TextStyle(color: p.subtle)),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (i) => setState(() => _page = i),
                itemCount: _slides.length,
                itemBuilder: (context, i) {
                  final s = _slides[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: 200,
                          width: 200,
                          decoration: BoxDecoration(
                            color: s.color.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(s.icon, size: 96, color: s.color),
                        ).animate(key: ValueKey(i)).scale(
                            duration: 500.ms, curve: Curves.easeOutBack),
                        const SizedBox(height: 48),
                        Text(s.title,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w800,
                                    color: p.ink))
                            .animate(key: ValueKey('t$i'))
                            .fadeIn(duration: 400.ms)
                            .moveY(begin: 14, end: 0),
                        const SizedBox(height: 14),
                        Text(s.body,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 15.5,
                                    height: 1.5,
                                    color: p.subtle))
                            .animate(key: ValueKey('b$i'))
                            .fadeIn(delay: 120.ms, duration: 400.ms),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            SmoothPageIndicator(
              controller: _controller,
              count: _slides.length,
              effect: const ExpandingDotsEffect(
                activeDotColor: AppTheme.green,
                dotColor: AppTheme.line,
                dotHeight: 9,
                dotWidth: 9,
                expansionFactor: 3,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
              child: FilledButton(
                onPressed: () {
                  if (last) {
                    _finish();
                  } else {
                    _controller.nextPage(
                        duration: const Duration(milliseconds: 350),
                        curve: Curves.easeOut);
                  }
                },
                child: Text(last ? 'Get Started' : 'Next'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
