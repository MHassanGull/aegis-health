import 'dart:convert';

import 'package:flutter/material.dart';

import '../core/api_client.dart';
import '../core/theme.dart';

/// Shows the user's profile photo if set, otherwise a coloured-initial avatar.
/// Rebuilds automatically whenever the cached avatar changes.
class UserAvatar extends StatelessWidget {
  final double radius;
  const UserAvatar({super.key, this.radius = 24});

  static Color parseColor(String hex) {
    var h = hex.replaceAll('#', '');
    if (h.length == 6) h = 'FF$h';
    return Color(int.tryParse(h, radix: 16) ?? 0xFF20A57A);
  }

  @override
  Widget build(BuildContext context) {
    final api = ApiClient.instance;
    final p = Palette.of(context);
    final side = radius * 2;

    return ValueListenableBuilder<int>(
      valueListenable: api.avatarRev,
      builder: (context, _, __) {
        final b64 = api.avatarB64;
        // Square, one radius, matching every other surface in the app. A
        // circle here would be the only round thing on the screen.
        if (b64.isNotEmpty) {
          try {
            return ClipRRect(
              borderRadius: BorderRadius.circular(AppTheme.radius),
              child: Image.memory(base64Decode(b64),
                  height: side, width: side, fit: BoxFit.cover),
            );
          } catch (_) {/* fall back to the initial */}
        }
        final name = api.username;
        final letter = name.isEmpty ? '?' : name[0];
        final color = parseColor(api.avatarColor);
        return Container(
          height: side,
          width: side,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: color.withValues(alpha: p.isDark ? 0.26 : 0.14),
            borderRadius: BorderRadius.circular(AppTheme.radius),
          ),
          child: Text(letter,
              style: TextStyle(
                  fontFamily: AppTheme.sans,
                  color: color,
                  fontSize: radius * 0.9,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.5)),
        );
      },
    );
  }
}
