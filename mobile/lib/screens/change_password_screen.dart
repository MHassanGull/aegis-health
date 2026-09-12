import 'package:flutter/material.dart';

import '../core/api_client.dart';
import '../core/theme.dart';

/// Lets the signed-in user change their password.
///
/// The current password is required, so an unlocked phone in the wrong hands
/// cannot be used to lock the real owner out of their account.
class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _current = TextEditingController();
  final _next = TextEditingController();
  final _confirm = TextEditingController();

  bool _busy = false;
  bool _hideCurrent = true;
  bool _hideNext = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    // The requirements list updates as the user types.
    _next.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _current.dispose();
    _next.dispose();
    _confirm.dispose();
    super.dispose();
  }

  bool get _longEnough => _next.text.length >= 8;
  bool get _hasLetterAndDigit =>
      RegExp(r'[A-Za-z]').hasMatch(_next.text) &&
      RegExp(r'[0-9]').hasMatch(_next.text);
  bool get _notTheOldOne =>
      _next.text.isNotEmpty && _next.text != _current.text;
  bool get _ready => _longEnough && _hasLetterAndDigit && _notTheOldOne;

  Future<void> _submit() async {
    if (_next.text != _confirm.text) {
      setState(() => _error = 'The two new passwords do not match.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ApiClient.instance.changePassword(_current.text, _next.text);
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Your password has been changed.')));
    } catch (e) {
      setState(() => _error = _friendly(e.toString()));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _friendly(String e) {
    if (e.contains('not your current password')) {
      return 'That is not your current password.';
    }
    if (e.contains('too common')) {
      return 'That password is too common. Pick something less predictable.';
    }
    if (e.contains('too short') || e.contains('at least')) {
      return 'That password is too short.';
    }
    if (e.contains('entirely numeric')) {
      return 'Use letters as well as numbers.';
    }
    if (e.contains('SocketException') || e.contains('Connection')) {
      return 'Cannot reach the server. Check your connection.';
    }
    if (e.contains('throttled') || e.contains('Request was throttled')) {
      return 'Too many attempts. Wait a minute and try again.';
    }
    return e;
  }

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    final t = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Change password')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
            AppTheme.gutter, 8, AppTheme.gutter, 32),
        children: [
          Text('Pick something you have not used anywhere else.',
              style: t.bodyMedium),
          const SizedBox(height: 28),

          Text('Current password', style: t.titleSmall),
          const SizedBox(height: 8),
          TextField(
            controller: _current,
            obscureText: _hideCurrent,
            autocorrect: false,
            decoration: InputDecoration(
              hintText: 'the one you use now',
              suffixIcon: _eye(_hideCurrent,
                  () => setState(() => _hideCurrent = !_hideCurrent), p),
            ),
          ),
          const SizedBox(height: 22),

          Text('New password', style: t.titleSmall),
          const SizedBox(height: 8),
          TextField(
            controller: _next,
            obscureText: _hideNext,
            autocorrect: false,
            decoration: InputDecoration(
              hintText: 'at least 8 characters',
              suffixIcon: _eye(
                  _hideNext, () => setState(() => _hideNext = !_hideNext), p),
            ),
          ),
          const SizedBox(height: 14),

          // Live requirements, so the rules are visible before submitting
          // rather than arriving as an error afterwards.
          _rule('At least 8 characters', _longEnough, p, t),
          _rule('Contains letters and numbers', _hasLetterAndDigit, p, t),
          _rule('Different from your current one', _notTheOldOne, p, t),

          const SizedBox(height: 22),
          Text('Confirm new password', style: t.titleSmall),
          const SizedBox(height: 8),
          TextField(
            controller: _confirm,
            obscureText: _hideNext,
            autocorrect: false,
            onSubmitted: (_) => _ready ? _submit() : null,
            decoration: const InputDecoration(hintText: 'type it again'),
          ),

          if (_error != null) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.high.withValues(alpha: p.isDark ? 0.18 : 0.10),
                borderRadius: BorderRadius.circular(AppTheme.rControl),
              ),
              child: Text(_error!,
                  style: t.bodyMedium?.copyWith(color: p.on(AppTheme.high))),
            ),
          ],

          const SizedBox(height: 30),
          FilledButton(
            onPressed: (_busy || !_ready) ? null : _submit,
            child: _busy
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                : const Text('Change password'),
          ),
          const SizedBox(height: 16),
          Text(
              'You will stay signed in on this phone. Anyone signed in '
              'elsewhere keeps access until their session expires.',
              style: t.bodySmall),
        ],
      ),
    );
  }

  Widget _eye(bool hidden, VoidCallback onTap, Palette p) => IconButton(
        iconSize: 20,
        icon: Icon(
            hidden ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: p.subtle),
        onPressed: onTap,
      );

  Widget _rule(String text, bool met, Palette p, TextTheme t) => Padding(
        padding: const EdgeInsets.only(bottom: 7),
        child: Row(children: [
          Icon(met ? Icons.check_circle_rounded : Icons.circle_outlined,
              size: 17, color: met ? p.on(AppTheme.green) : p.subtle),
          const SizedBox(width: 9),
          Text(text,
              style: t.bodySmall?.copyWith(
                  color: met ? p.ink : p.subtle,
                  fontWeight: met ? FontWeight.w500 : FontWeight.w400)),
        ]),
      );
}
