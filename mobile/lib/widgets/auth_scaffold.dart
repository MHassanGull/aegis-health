import 'package:flutter/material.dart';

import '../core/theme.dart';
import 'shield_logo.dart';

/// Page frame for the authentication screens.
///
/// Deliberately quiet: a flat background, content aligned to the page gutter,
/// no animated backdrop. On a sign-in screen the form is the subject — anything
/// moving behind it is noise.
class AuthScaffold extends StatelessWidget {
  final Widget child;
  final Widget? leading; // optional top-left control (e.g. a back button)
  const AuthScaffold({super.key, required this.child, this.leading});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 48,
              child: leading == null
                  ? null
                  : Align(alignment: Alignment.centerLeft, child: leading),
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                    AppTheme.gutter, 0, AppTheme.gutter, 28),
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The masthead: brand mark, wordmark, and the screen's one statement.
///
/// The mark is a fixed square of brand colour — a printed logotype, not a
/// floating orb. Nothing here animates.
class AuthHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  const AuthHeader({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              height: 34,
              width: 34,
              padding: const EdgeInsets.all(5),
              decoration: const BoxDecoration(
                color: AppTheme.green,
                borderRadius:
                    BorderRadius.all(Radius.circular(AppTheme.radius)),
              ),
              child: const ShieldLogo(size: 24, onDark: true),
            ),
            const SizedBox(width: 10),
            Text('AEGIS HEALTH',
                style: AppType.label.copyWith(color: p.ink, letterSpacing: 1.6)),
          ],
        ),
        const SizedBox(height: 40),
        Text(title, style: AppType.display.copyWith(color: p.ink)),
        const SizedBox(height: 10),
        Text(subtitle, style: AppType.body.copyWith(color: p.subtle)),
        const SizedBox(height: 28),
        Rule(),
        const SizedBox(height: 28),
      ],
    );
  }
}

/// Uppercase label sitting above an input. Swiss forms name their fields
/// outside the box, so the label stays readable once the field has content.
class FieldLabel extends StatelessWidget {
  final String text;
  const FieldLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text.toUpperCase(),
          style: AppType.label.copyWith(color: p.subtle)),
    );
  }
}

/// An error message: a labelled rule and plain red text. No tinted pill, no
/// icon badge — the label and the colour already carry the meaning, and a
/// rule reads as part of the form rather than a sticker dropped on top of it.
class ErrorNote extends StatelessWidget {
  final String text;
  const ErrorNote(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Text('ERROR',
              style: AppType.label.copyWith(color: AppTheme.high)),
          const SizedBox(width: 10),
          const Expanded(
              child: SizedBox(height: AppTheme.hair, child: ColoredBox(color: AppTheme.high))),
        ]),
        const SizedBox(height: 8),
        Text(text,
            style: AppType.small.copyWith(color: AppTheme.high, height: 1.4)),
      ],
    );
  }
}
