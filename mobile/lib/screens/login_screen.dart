import 'package:flutter/material.dart';
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
      setState(() => _error = 'Enter your username and password.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await context
          .read<AuthState>()
          .login(_username.text.trim(), _password.text);
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
      return 'Cannot reach the server. Check your connection.';
    }
    return e;
  }

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    return AuthScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),
          const AuthHeader(
            title: 'Welcome\nback.',
            subtitle: 'Sign in to check your risk.',
          ),
          const FieldLabel('Username'),
          TextField(
            controller: _username,
            textInputAction: TextInputAction.next,
            autocorrect: false,
            decoration: const InputDecoration(hintText: 'your username'),
          ),
          const SizedBox(height: 20),
          const FieldLabel('Password'),
          TextField(
            controller: _password,
            obscureText: _obscure,
            onSubmitted: (_) => _submit(),
            decoration: InputDecoration(
              hintText: '••••••••',
              suffixIcon: IconButton(
                iconSize: 20,
                icon: Icon(
                    _obscure
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: p.subtle),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 22),
            ErrorNote(_error!),
          ],
          const SizedBox(height: 32),
          FilledButton(
            onPressed: _busy ? null : _submit,
            child: _busy
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                : const Text('SIGN IN'),
          ),
          const SizedBox(height: 24),
          Rule(),
          const SizedBox(height: 20),
          Row(
            children: [
              Text('New here?', style: AppType.small.copyWith(color: p.subtle)),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _busy
                    ? null
                    : () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const RegisterScreen())),
                child: Text('Create an account',
                    style: AppType.small.copyWith(
                        color: AppTheme.green,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                        decorationColor: AppTheme.green)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
