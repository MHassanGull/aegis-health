import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../state/auth_state.dart';
import '../widgets/auth_scaffold.dart';
import 'register_screen.dart';
import 'home_shell.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _username = TextEditingController();
  final _password = TextEditingController();
  bool _busy = false;
  bool _obscure = true;
  String? _error;

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_username.text.trim().isEmpty || _password.text.isEmpty) {
      setState(() => _error = 'Please enter your username and password.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await context.read<AuthState>().login(_username.text.trim(), _password.text);
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
    if (e.contains('No active account') || e.contains('credentials')) {
      return 'Wrong username or password.';
    }
    if (e.contains('SocketException') || e.contains('Connection')) {
      return 'Can’t reach the server. Is the backend running?';
    }
    return e;
  }

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    return AuthScaffold(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 10),
          const Center(child: FloatingLogo(size: 74))
              .animate()
              .scale(duration: 600.ms, curve: Curves.easeOutBack)
              .fadeIn(),
          const SizedBox(height: 22),
          Text('Aegis Health',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 15,
                      letterSpacing: 2,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.green))
              .animate()
              .fadeIn(delay: 150.ms),
          const SizedBox(height: 6),
          Text('Welcome back',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 28, fontWeight: FontWeight.w800, color: p.ink))
              .animate()
              .fadeIn(delay: 220.ms)
              .moveY(begin: 12, end: 0),
          const SizedBox(height: 6),
          Text('Log in to check your health risk',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: p.subtle))
              .animate()
              .fadeIn(delay: 300.ms),
          const SizedBox(height: 26),
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
                ).animate().fadeIn(delay: 360.ms).moveX(begin: -14, end: 0),
                const SizedBox(height: 14),
                TextField(
                  controller: _password,
                  obscureText: _obscure,
                  onSubmitted: (_) => _submit(),
                  decoration: InputDecoration(
                    hintText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                    suffixIcon: IconButton(
                      icon: Icon(_obscure
                          ? Icons.visibility_off_rounded
                          : Icons.visibility_rounded),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                ).animate().fadeIn(delay: 440.ms).moveX(begin: -14, end: 0),
                if (_error != null) ...[
                  const SizedBox(height: 14),
                  _ErrorBanner(_error!).animate().shake(hz: 4, offset: const Offset(3, 0)),
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
                      : const Text('Log In'),
                ).animate().fadeIn(delay: 520.ms).moveY(begin: 10, end: 0),
              ],
            ),
          ).animate().fadeIn(delay: 340.ms).moveY(begin: 18, end: 0),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("New to Aegis? ", style: TextStyle(color: p.subtle)),
              GestureDetector(
                onTap: _busy
                    ? null
                    : () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const RegisterScreen())),
                child: const Text('Create account',
                    style: TextStyle(
                        color: AppTheme.green, fontWeight: FontWeight.w800)),
              ),
            ],
          ).animate().fadeIn(delay: 620.ms),
        ],
      ),
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
