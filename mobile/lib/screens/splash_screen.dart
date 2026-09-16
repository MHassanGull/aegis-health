import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/api_client.dart';
import '../core/theme.dart';
import '../core/motion.dart';
import '../widgets/ecg_line.dart';
import '../widgets/shield_logo.dart';
import 'onboarding_screen.dart';
import 'login_screen.dart';
import 'home_shell.dart';
import 'permissions_screen.dart';

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
    // Long enough to read the wordmark, short enough not to feel like
    // a loading screen.
    await Future.delayed(const Duration(milliseconds: 1700));
    if (!mounted) return;
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getBool('seen_onboarding') ?? false;
    Widget next;
    if (ApiClient.instance.isAuthenticated) {
      // A returning user who has never seen the permissions screen (an
      // install that predates it, or one where it was skipped) still gets it
      // once, rather than silently missing out on the reminder fix forever.
      next = await PermissionsScreen.alreadySeen()
          ? const HomeShell()
          : const PermissionsScreen(onboarding: true);
    } else if (!seen) {
      next = const OnboardingScreen();
    } else {
      next = const LoginScreen();
    }
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 280),
        pageBuilder: (_, a, __) => FadeTransition(opacity: a, child: next),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Centred, and the cardiac trace runs the full width beneath the mark, so
    // the first thing the app does is the thing the app is for: read a line
    // and watch it move.
    return Scaffold(
      backgroundColor: AppTheme.greenField,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const _Mark(),
              const SizedBox(height: 26),
              const Text('Aegis',
                  style: TextStyle(
                      fontFamily: AppTheme.display,
                      color: Colors.white,
                      fontSize: 44,
                      height: 1.0,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -1.6)),
              const SizedBox(height: 10),
              Text('Know your risk early',
                  style: TextStyle(
                      fontFamily: AppTheme.sans,
                      color: Colors.white.withValues(alpha: 0.72),
                      fontSize: 15,
                      fontWeight: FontWeight.w500)),
              const SizedBox(height: 44),
              const SizedBox(
                height: 64,
                width: double.infinity,
                child: EcgLine(
                  color: Colors.white,
                  amplitude: 0.40,
                  sweepSeconds: 2.1,
                  beatsAcross: 2.4,
                  strokeWidth: 2.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The shield, easing up to full size once as the app opens.
class _Mark extends StatefulWidget {
  const _Mark();
  @override
  State<_Mark> createState() => _MarkState();
}

class _MarkState extends State<_Mark> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: Motion.slow)..forward();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const mark = ShieldLogo(size: 92, onDark: true);
    if (Motion.reduced(context)) return mark;
    final t = CurvedAnimation(parent: _c, curve: Motion.enter);
    return AnimatedBuilder(
      animation: t,
      builder: (context, child) => Opacity(
        opacity: t.value,
        child: Transform.scale(scale: 0.88 + 0.12 * t.value, child: child),
      ),
      child: mark,
    );
  }
}
