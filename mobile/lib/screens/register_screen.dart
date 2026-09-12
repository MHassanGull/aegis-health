import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../state/auth_state.dart';
import '../widgets/auth_scaffold.dart';
import 'home_shell.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _username = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _busy = false;
  bool _obscure = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _password.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _username.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  int get _strength {
    final s = _password.text;
    var score = 0;
    if (s.length >= 6) score++;
    if (s.length >= 10) score++;
    if (RegExp(r'[0-9]').hasMatch(s) && RegExp(r'[A-Za-z]').hasMatch(s)) score++;
    return score; // 0..3
  }

  Future<void> _submit() async {
    if (_username.text.trim().isEmpty || _password.text.length < 6) {
      setState(() => _error =
          'Pick a username and a password of at least 6 characters.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await context.read<AuthState>().register(
          _username.text.trim(), _email.text.trim(), _password.text);
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(context,
          MaterialPageRoute(builder: (_) => const HomeShell()), (r) => false);
    } catch (e) {
      setState(() => _error = _friendly(e.toString()));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _friendly(String e) {
    if (e.contains('already')) return 'That username is taken — try another.';
    if (e.contains('SocketException') || e.contains('Connection')) {
      return 'Can’t reach the server. Is the backend running?';
    }
    if (e.contains('too common') || e.contains('password')) {
      return 'Please choose a stronger password.';
    }
    return e;
  }

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    return AuthScaffold(
      leading: IconButton(
        icon: Icon(Icons.arrow_back_rounded, color: p.ink),
        onPressed: () => Navigator.pop(context),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 14),
          const Center(child: FloatingLogo(size: 64))
              .animate()
              .scale(duration: 600.ms, curve: Curves.easeOutBack)
              .fadeIn(),
          const SizedBox(height: 18),
          Text('Create your account',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 26, fontWeight: FontWeight.w800, color: p.ink))
              .animate()
              .fadeIn(delay: 180.ms)
              .moveY(begin: 12, end: 0),
          const SizedBox(height: 6),
          Text('Start protecting your health today',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: p.subtle))
              .animate()
              .fadeIn(delay: 260.ms),
          const SizedBox(height: 24),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _username,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                      hintText: 'Username',
                      prefixIcon: Icon(Icons.person_outline_rounded)),
                ).animate().fadeIn(delay: 320.ms).moveX(begin: -14, end: 0),
                const SizedBox(height: 14),
                TextField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                      hintText: 'Email (optional)',
                      prefixIcon: Icon(Icons.mail_outline_rounded)),
                ).animate().fadeIn(delay: 400.ms).moveX(begin: -14, end: 0),
                const SizedBox(height: 14),
                TextField(
                  controller: _password,
                  obscureText: _obscure,
                  onSubmitted: (_) => _submit(),
                  decoration: InputDecoration(
                    hintText: 'Password (6+ characters)',
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                    suffixIcon: IconButton(
                      icon: Icon(_obscure
                          ? Icons.visibility_off_rounded
                          : Icons.visibility_rounded),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                ).animate().fadeIn(delay: 480.ms).moveX(begin: -14, end: 0),
                if (_password.text.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _StrengthMeter(_strength, p),
                ],
                if (_error != null) ...[
                  const SizedBox(height: 14),
                  _ErrorBanner(_error!)
                      .animate()
                      .shake(hz: 4, offset: const Offset(3, 0)),
                ],
                const SizedBox(height: 22),
                FilledButton(
                  onPressed: _busy ? null : _submit,
                  child: _busy
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                              strokeWidth: 2.4, color: Colors.white))
                      : const Text('Create Account'),
                ).animate().fadeIn(delay: 560.ms).moveY(begin: 10, end: 0),
              ],
            ),
          ).animate().fadeIn(delay: 300.ms).moveY(begin: 18, end: 0),
        ],
      ),
    );
  }
}

class _StrengthMeter extends StatelessWidget {
  final int strength; // 0..3
  final Palette p;
  const _StrengthMeter(this.strength, this.p);
  @override
  Widget build(BuildContext context) {
    const labels = ['Weak', 'Okay', 'Good', 'Strong'];
    const colors = [AppTheme.high, AppTheme.amber, AppTheme.green, AppTheme.green];
    final color = colors[strength];
    return Row(
      children: [
        ...List.generate(3, (i) {
          final on = i < strength;
          return Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 6,
              margin: EdgeInsets.only(right: i < 2 ? 6 : 10),
              decoration: BoxDecoration(
                  color: on ? color : p.line,
                  borderRadius: BorderRadius.circular(4)),
            ),
          );
        }),
        Text(labels[strength],
            style: TextStyle(
                color: color, fontSize: 12, fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String text;
  const _ErrorBanner(this.text);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
          color: AppTheme.coralSoft,
          borderRadius: BorderRadius.circular(12)),
      child: Row(children: [
        const Icon(Icons.error_outline_rounded, color: AppTheme.high, size: 20),
        const SizedBox(width: 10),
        Expanded(
            child: Text(text,
                style: const TextStyle(color: AppTheme.high, fontSize: 13.5))),
      ]),
    );
  }
}
