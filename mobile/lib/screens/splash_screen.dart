import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/api_client.dart';
import '../core/theme.dart';
import '../widgets/shield_logo.dart';
import 'onboarding_screen.dart';
import 'login_screen.dart';
import 'home_shell.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _route();
  }

  Future<void> _route() async {
    await Future.delayed(const Duration(milliseconds: 2100));
    if (!mounted) return;
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getBool('seen_onboarding') ?? false;
    Widget next;
    if (ApiClient.instance.isAuthenticated) {
      next = const HomeShell();
    } else if (!seen) {
      next = const OnboardingScreen();
    } else {
      next = const LoginScreen();
    }
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (_, a, __) => FadeTransition(opacity: a, child: next),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // A flat brand field with the mark and wordmark set against the page
    // gutter, the way a title page is set. No gradient, no bounce.
    return Scaffold(
      backgroundColor: AppTheme.green,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.gutter),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              const ShieldLogo(size: 56, onDark: true),
              const SizedBox(height: 28),
              const Text('Aegis',
                  style: TextStyle(
                      fontFamily: AppTheme.sans,
                      color: Colors.white,
                      fontSize: 46,
                      height: 1.0,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -1.8)),
              const SizedBox(height: 10),
              Text('PREVENTIVE HEALTH SCREENING',
                  style: AppType.label.copyWith(
                      color: Colors.white.withValues(alpha: 0.75),
                      letterSpacing: 1.8)),
              const Spacer(),
              Container(
                  height: AppTheme.hair,
                  color: Colors.white.withValues(alpha: 0.25)),
              const SizedBox(height: 14),
              Text('DIABETES  ·  KIDNEY DISEASE',
                  style: AppType.label.copyWith(
                      color: Colors.white.withValues(alpha: 0.6))),
            ],
          ),
        ),
      ),
    );
  }
}
