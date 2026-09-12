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
      body: SafeArea(
        child: Center(
          child: _error == null ? _loading() : _errorView(),
        ),
      ),
    );
  }

  Widget _loading() {
    final p = Palette.of(context);
    // A determinate-looking bar and a plain statement. A pulsing logo inside a
    // spinner is theatre; this reads as a machine doing work.
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.gutter),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('RUNNING MODEL',
              style: AppType.label.copyWith(color: AppTheme.green)),
          const SizedBox(height: 16),
          Text('Estimating\nyour risk.',
              style: AppType.display.copyWith(color: p.ink)),
          const SizedBox(height: 28),
          SizedBox(
            height: 3,
            child: LinearProgressIndicator(
              backgroundColor: p.line,
              valueColor: const AlwaysStoppedAnimation(AppTheme.green),
            ),
          ),
          const SizedBox(height: 16),
          Text(
              'Nineteen inputs through a shared network, then attribution and '
              'the what-if pass.',
              style: AppType.small.copyWith(color: p.subtle, height: 1.55)),
        ],
      ),
    );
  }

  Widget _errorView() {
    final p = Palette.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.gutter),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('COULD NOT COMPLETE',
              style: AppType.label.copyWith(color: AppTheme.high)),
          const SizedBox(height: 14),
          Text(_error!, style: AppType.body.copyWith(color: p.ink)),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('GO BACK'),
            ),
          ),
        ],
      ),
    );
  }
}
