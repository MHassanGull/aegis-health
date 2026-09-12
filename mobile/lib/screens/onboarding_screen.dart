import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/theme.dart';
import 'login_screen.dart';

class _Slide {
  final String title;
  final String body;
  const _Slide(this.title, this.body);
}

const _slides = [
  _Slide('Years\nof warning.',
      'Aegis estimates your risk of diabetes and chronic kidney disease before either one has started.'),
  _Slide('No needle.\nNo lab.',
      'Nineteen questions about how you live. Your answers are enough for the model to work with.'),
  _Slide('What to\nchange first.',
      'Aegis ranks the habits that matter most for you, and shows how far each one would move your risk.'),
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
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final last = _page == _slides.length - 1;
    final p = Palette.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Index and skip, set on one baseline against the gutter.
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppTheme.gutter, 8, AppTheme.gutter - 8, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                      '${(_page + 1).toString().padLeft(2, '0')} / '
                      '${_slides.length.toString().padLeft(2, '0')}',
                      style: AppType.mono
                          .copyWith(color: p.subtle, letterSpacing: 0.5)),
                  TextButton(
                    onPressed: _finish,
                    child: Text('SKIP',
                        style: AppType.label.copyWith(color: p.subtle)),
                  ),
                ],
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.gutter),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(s.title,
                            style: AppType.display
                                .copyWith(color: p.ink, fontSize: 40)),
                        const SizedBox(height: 28),
                        SizedBox(
                            width: 44,
                            child: Container(height: 2, color: AppTheme.green)),
                        const SizedBox(height: 28),
                        Text(s.body,
                            style: AppType.body
                                .copyWith(color: p.subtle, height: 1.6)),
                      ],
                    ),
                  );
                },
              ),
            ),
            // Progress as filled segments of one rule — a measure, not dots.
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: AppTheme.gutter),
              child: Row(
                children: List.generate(_slides.length, (i) {
                  return Expanded(
                    child: Container(
                      height: 2,
                      margin: EdgeInsets.only(
                          right: i < _slides.length - 1 ? 4 : 0),
                      color: i <= _page ? AppTheme.green : p.line,
                    ),
                  );
                }),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppTheme.gutter, 24, AppTheme.gutter, 24),
              child: FilledButton(
                onPressed: () {
                  if (last) {
                    _finish();
                  } else {
                    _controller.nextPage(
                        duration: const Duration(milliseconds: 280),
                        curve: Curves.easeOut);
                  }
                },
                child: Text(last ? 'GET STARTED' : 'NEXT'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
