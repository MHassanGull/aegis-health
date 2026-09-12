import 'package:flutter/material.dart';

/// Aegis Health — warm green/coral design system with light + dark palettes.
class AppTheme {
  // Brand colours (fixed in both light & dark)
  static const Color green = Color(0xFF20A57A);
  static const Color greenDark = Color(0xFF15805C);
  static const Color coral = Color(0xFFFF7A63);
  static const Color amber = Color(0xFFF2A03D);

  // Risk tiers
  static const Color low = Color(0xFF22A56A);
  static const Color moderate = Color(0xFFF2A03D);
  static const Color high = Color(0xFFEB5B49);

  // Light-mode neutral aliases (kept for widgets that don't need to adapt).
  // For surfaces/text that must follow dark mode, use Palette.of(context).
  static const Color ink = Color(0xFF1E2A24);
  static const Color slate = Color(0xFF7C8A82);
  static const Color line = Color(0xFFE7ECE7);
  static const Color bg = Color(0xFFF6F8F4);
  static const Color card = Colors.white;
  static const Color greenSoft = Color(0xFFE7F6EF);
  static const Color coralSoft = Color(0xFFFFEDE8);

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF24B083), Color(0xFF12835C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient coralGradient = LinearGradient(
    colors: [Color(0xFFFF8E72), Color(0xFFFF6F61)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static Color tierColor(String tier) {
    switch (tier.toLowerCase()) {
      case 'high':
        return high;
      case 'moderate':
        return moderate;
      default:
        return low;
    }
  }

  // ---- Themes ----------------------------------------------------------
  static ThemeData _build(Palette p, Brightness b) {
    final base = ThemeData(
      useMaterial3: true,
      brightness: b,
      colorScheme: ColorScheme.fromSeed(
        seedColor: green,
        brightness: b,
        primary: green,
        secondary: coral,
        surface: p.bg,
      ),
      scaffoldBackgroundColor: p.bg,
    );
    return base.copyWith(
      textTheme: base.textTheme.apply(bodyColor: p.ink, displayColor: p.ink),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: p.ink,
        centerTitle: true,
        titleTextStyle: TextStyle(
            color: p.ink, fontSize: 18, fontWeight: FontWeight.w700),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: green,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(56),
          elevation: 0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          textStyle:
              const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: p.field,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        prefixIconColor: p.subtle,
        hintStyle: TextStyle(color: p.subtle),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: p.line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: p.line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: green, width: 1.6),
        ),
      ),
    );
  }

  static ThemeData get light => _build(Palette.light, Brightness.light);
  static ThemeData get dark => _build(Palette.dark, Brightness.dark);
}

/// Brightness-aware neutral colours. Brand colours live on [AppTheme].
class Palette {
  final Color bg;       // scaffold background
  final Color card;     // card surface
  final Color ink;      // primary text
  final Color subtle;   // secondary text
  final Color line;     // borders / dividers
  final Color field;    // input fill
  final bool isDark;

  const Palette({
    required this.bg,
    required this.card,
    required this.ink,
    required this.subtle,
    required this.line,
    required this.field,
    required this.isDark,
  });

  static const light = Palette(
    bg: Color(0xFFF6F8F4),
    card: Colors.white,
    ink: Color(0xFF1E2A24),
    subtle: Color(0xFF7C8A82),
    line: Color(0xFFE7ECE7),
    field: Colors.white,
    isDark: false,
  );

  static const dark = Palette(
    bg: Color(0xFF111A16),
    card: Color(0xFF1B2620),
    ink: Color(0xFFECF3EE),
    subtle: Color(0xFF93A39A),
    line: Color(0xFF2A372F),
    field: Color(0xFF1B2620),
    isDark: true,
  );

  static Palette of(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? dark : light;

  /// A soft brand tint that reads well on both light & dark surfaces.
  Color tint(Color brand) => brand.withValues(alpha: isDark ? 0.20 : 0.12);

  List<BoxShadow> get shadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: isDark ? 0.30 : 0.06),
          blurRadius: 22,
          offset: const Offset(0, 8),
        ),
      ];
}

/// Rounded surface card that adapts to light/dark.
class SoftCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;
  const SoftCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: p.card,
          borderRadius: BorderRadius.circular(22),
          boxShadow: p.shadow,
        ),
        child: child,
      ),
    );
  }
}
