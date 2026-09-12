import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.heroGradient),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const AnimatedShieldLogo(size: 110, onDark: true)
                  .animate()
                  .scale(duration: 700.ms, curve: Curves.easeOutBack)
                  .fadeIn(duration: 500.ms),
              const SizedBox(height: 22),
              const Text('Aegis Health',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.3))
                  .animate()
                  .fadeIn(delay: 350.ms, duration: 600.ms)
                  .moveY(begin: 12, end: 0),
              const SizedBox(height: 8),
              Text('Protect your future health',
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 15))
                  .animate()
                  .fadeIn(delay: 650.ms, duration: 600.ms),
            ],
          ),
        ),
      ),
    );
  }
}
