import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../core/api_client.dart';
import '../core/theme.dart';
import '../widgets/shield_logo.dart';
import 'result_screen.dart';

class AnalyzingScreen extends StatefulWidget {
  final Map<String, num> payload;
  const AnalyzingScreen({super.key, required this.payload});
  @override
  State<AnalyzingScreen> createState() => _AnalyzingScreenState();
}

class _AnalyzingScreenState extends State<AnalyzingScreen> {
  String? _error;

  @override
  void initState() {
    super.initState();
    _run();
  }

  Future<void> _run() async {
    final started = DateTime.now();
    try {
      final result = await ApiClient.instance.predict(widget.payload);
      // keep the animation visible for at least 1.8s so it feels considered
      final elapsed = DateTime.now().difference(started);
      final wait = const Duration(milliseconds: 1900) - elapsed;
      if (wait > Duration.zero) await Future.delayed(wait);
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 450),
          pageBuilder: (_, a, __) => FadeTransition(
              opacity: a,
              child: ResultScreen(result: result, payload: widget.payload)),
        ),
      );
    } catch (e) {
      if (mounted) {
        setState(() => _error = e.toString().contains('Connection') ||
                e.toString().contains('Socket')
            ? 'Can’t reach the server. Make sure the backend is running.'
            : e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _error == null ? _loading() : _errorView(),
      ),
    );
  }

  Widget _loading() {
    final p = Palette.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              height: 150,
              width: 150,
              child: CircularProgressIndicator(
                strokeWidth: 4,
                valueColor: const AlwaysStoppedAnimation(AppTheme.green),
                backgroundColor: AppTheme.greenSoft,
              ),
            ),
            const AnimatedShieldLogo(size: 78)
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .scale(
                    begin: const Offset(0.92, 0.92),
                    end: const Offset(1.06, 1.06),
                    duration: 900.ms,
                    curve: Curves.easeInOut),
          ],
        ),
        const SizedBox(height: 34),
        Text('Analysing your health…',
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.w800, color: p.ink)),
        const SizedBox(height: 8),
        Text('Our AI is estimating your risk',
            style: TextStyle(color: p.subtle)),
      ],
    );
  }

  Widget _errorView() {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off_rounded, size: 64, color: AppTheme.coral),
          const SizedBox(height: 18),
          Text(_error!,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Palette.of(context).ink, fontSize: 15.5)),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Go Back'),
          ),
        ],
      ),
    );
  }
}
