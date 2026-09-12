import 'package:flutter/material.dart';
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
        icon: Icon(Icons.arrow_back, color: p.ink, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AuthHeader(
            title: 'Create\naccount.',
            subtitle: 'Two minutes, no blood test.',
          ),
          const FieldLabel('Username'),
          TextField(
            controller: _username,
            textInputAction: TextInputAction.next,
            autocorrect: false,
            decoration: const InputDecoration(hintText: 'pick a username'),
          ),
          const SizedBox(height: 20),
          Row(children: [
            const FieldLabel('Email'),
            const SizedBox(width: 8),
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text('OPTIONAL',
                  style: AppType.label
                      .copyWith(color: p.subtle.withValues(alpha: 0.7))),
            ),
          ]),
          TextField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autocorrect: false,
            decoration: const InputDecoration(hintText: 'you@example.com'),
          ),
          const SizedBox(height: 20),
          const FieldLabel('Password'),
          TextField(
            controller: _password,
            obscureText: _obscure,
            onSubmitted: (_) => _submit(),
            decoration: InputDecoration(
              hintText: 'at least 6 characters',
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
          if (_password.text.isNotEmpty) ...[
            const SizedBox(height: 12),
            _StrengthMeter(_strength, p),
          ],
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
                : const Text('CREATE ACCOUNT'),
          ),
          const SizedBox(height: 20),
          Text(
              'Aegis is an educational screening tool. It does not diagnose '
              'disease and does not replace a doctor.',
              style: AppType.small
                  .copyWith(color: p.subtle, fontSize: 12, height: 1.5)),
        ],
      ),
    );
  }
}

/// Password strength as three flat segments and a word. Square segments, one
/// radius, no animation — it is a readout, not an effect.
class _StrengthMeter extends StatelessWidget {
  final int strength; // 0..3
  final Palette p;
  const _StrengthMeter(this.strength, this.p);

  @override
  Widget build(BuildContext context) {
    const labels = ['WEAK', 'OKAY', 'GOOD', 'STRONG'];
    const colors = [
      AppTheme.high,
      AppTheme.amber,
      AppTheme.green,
      AppTheme.green
    ];
    final color = colors[strength];
    return Row(
      children: [
        ...List.generate(3, (i) {
          return Expanded(
            child: Container(
              height: 3,
              margin: EdgeInsets.only(right: i < 2 ? 4 : 10),
              color: i < strength ? color : p.line,
            ),
          );
        }),
        Text(labels[strength], style: AppType.label.copyWith(color: color)),
      ],
    );
  }
}
