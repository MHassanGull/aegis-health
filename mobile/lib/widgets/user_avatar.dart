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
    return ValueListenableBuilder<int>(
      valueListenable: api.avatarRev,
      builder: (context, _, __) {
        final b64 = api.avatarB64;
        if (b64.isNotEmpty) {
          try {
            return CircleAvatar(
                radius: radius, backgroundImage: MemoryImage(base64Decode(b64)));
          } catch (_) {/* fall back to initial */}
        }
        final name = api.username;
        final letter = name.isEmpty ? '?' : name[0].toUpperCase();
        final color = parseColor(api.avatarColor);
        return CircleAvatar(
          radius: radius,
          backgroundColor:
              color.withValues(alpha: p.isDark ? 0.30 : 0.15),
          child: Text(letter,
              style: TextStyle(
                  color: color,
                  fontSize: radius * 0.82,
                  fontWeight: FontWeight.w800)),
        );
      },
    );
  }
}
