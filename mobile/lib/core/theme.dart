import 'package:flutter/material.dart';

import 'motion.dart';

/// Aegis Health design system.
///
/// Direction: clinical Swiss. One grotesque typeface (Archivo) for the
/// interface, one monospace (IBM Plex Mono) for data, a strict type scale,
/// a single corner radius, and hairline rules instead of drop shadows.
/// Colour is used to mean something — never as decoration.
class AppTheme {
  // ---- Brand -----------------------------------------------------------
  static const Color green = Color(0xFF20A57A);
  static const Color greenDark = Color(0xFF15805C);
  static const Color coral = Color(0xFFFF7A63);
  static const Color amber = Color(0xFFF2A03D);

  // ---- Risk tiers (semantic, never decorative) -------------------------
  static const Color low = Color(0xFF22A56A);
  static const Color moderate = Color(0xFFF2A03D);
  static const Color high = Color(0xFFEB5B49);

  // ---- Light-mode neutral aliases --------------------------------------
  // Prefer Palette.of(context) for anything that must follow dark mode.
  static const Color ink = Color(0xFF141A17);
  static const Color slate = Color(0xFF6B7872);
  static const Color line = Color(0xFFDDE4DF);
  static const Color bg = Color(0xFFF4F6F3);
  static const Color card = Colors.white;
  static const Color greenSoft = Color(0xFFE7F6EF);
  static const Color coralSoft = Color(0xFFFFEDE8);

  // ---- High-contrast panel ---------------------------------------------
  /// Near-black field used for data bands. Hard contrast is what gives Swiss
  /// layouts their punch — without it the page reads as timid, not restrained.
  static const Color panel = Color(0xFF101613);
  static const Color panelDark = Color(0xFF050A07);

  // ---- Geometry --------------------------------------------------------
  /// One radius for the whole app. Tight, near-square — deliberate, not soft.
  static const double radius = 4;

  /// Page gutter. Everything aligns to this left edge.
  static const double gutter = 20;

  /// Hairline weight for rules and borders.
  static const double hair = 1;

  /// Heavy rule, for the breaks that carry the page's structure.
  static const double heavy = 3;

  // ---- Typeface --------------------------------------------------------
  static const String sans = 'Archivo';
  static const String mono = 'PlexMono';

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

  // ---- Theme -----------------------------------------------------------
  static ThemeData _build(Palette p, Brightness b) {
    final base = ThemeData(
      useMaterial3: true,
      brightness: b,
      fontFamily: sans,
      colorScheme: ColorScheme.fromSeed(
        seedColor: green,
        brightness: b,
        primary: green,
        secondary: coral,
        surface: p.bg,
      ),
      scaffoldBackgroundColor: p.bg,
      splashFactory: InkSparkle.splashFactory,
      pageTransitionsTheme: const PageTransitionsTheme(builders: {
        TargetPlatform.android: EditorialPageTransition(),
        TargetPlatform.iOS: EditorialPageTransition(),
      }),
    );

    return base.copyWith(
      textTheme: base.textTheme.apply(
        fontFamily: sans,
        bodyColor: p.ink,
        displayColor: p.ink,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: p.bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: p.ink,
        centerTitle: false,
        titleSpacing: gutter,
        titleTextStyle: TextStyle(
          fontFamily: sans,
          color: p.ink,
          fontSize: 17,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
        ),
      ),
      dividerTheme: DividerThemeData(
        color: p.line,
        thickness: hair,
        space: hair,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: green,
          foregroundColor: Colors.white,
          disabledBackgroundColor: p.line,
          disabledForegroundColor: p.subtle,
          minimumSize: const Size.fromHeight(52),
          elevation: 0,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(radius)),
          ),
          textStyle: const TextStyle(
            fontFamily: sans,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: p.ink,
          minimumSize: const Size.fromHeight(52),
          side: BorderSide(color: p.line, width: hair),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(radius)),
          ),
          textStyle: const TextStyle(
            fontFamily: sans,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: green,
          textStyle: const TextStyle(
            fontFamily: sans,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: p.field,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        prefixIconColor: p.subtle,
        hintStyle: TextStyle(color: p.subtle, fontSize: 15),
        labelStyle: TextStyle(color: p.subtle, fontSize: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: BorderSide(color: p.line, width: hair),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: BorderSide(color: p.line, width: hair),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: const BorderSide(color: ink, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: const BorderSide(color: high, width: hair),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: const BorderSide(color: high, width: 1.5),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: p.isDark ? const Color(0xFF2A372F) : ink,
        contentTextStyle: const TextStyle(
            fontFamily: sans, color: Colors.white, fontSize: 14),
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(radius)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: p.card,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(radius)),
        ),
        titleTextStyle: TextStyle(
          fontFamily: sans,
          color: p.ink,
          fontSize: 17,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  static ThemeData get light => _build(Palette.light, Brightness.light);
  static ThemeData get dark => _build(Palette.dark, Brightness.dark);
}

/// The type scale. Six sizes, no improvisation — every screen draws from here.
///
/// Swiss practice: tight negative tracking on large text, positive tracking on
/// small uppercase labels. Data uses the monospace face so digits line up.
class AppType {
  /// Screen-defining statement. One per screen, at most.
  static const display = TextStyle(
    fontFamily: AppTheme.sans,
    fontSize: 32,
    height: 1.06,
    fontWeight: FontWeight.w700,
    letterSpacing: -1.0,
  );

  /// Poster scale. One per screen, set tight and loud.
  static const poster = TextStyle(
    fontFamily: AppTheme.sans,
    fontSize: 46,
    height: 0.95,
    fontWeight: FontWeight.w700,
    letterSpacing: -2.2,
  );

  /// Oversized figure used as a graphic element, not as reading matter.
  static const figure = TextStyle(
    fontFamily: AppTheme.mono,
    fontSize: 56,
    height: 0.9,
    fontWeight: FontWeight.w500,
    letterSpacing: -3,
  );

  /// Section heading.
  static const h1 = TextStyle(
    fontFamily: AppTheme.sans,
    fontSize: 22,
    height: 1.15,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
  );

  /// Sub-section / card title.
  static const h2 = TextStyle(
    fontFamily: AppTheme.sans,
    fontSize: 16,
    height: 1.25,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
  );

  /// Reading copy.
  static const body = TextStyle(
    fontFamily: AppTheme.sans,
    fontSize: 15,
    height: 1.5,
    fontWeight: FontWeight.w400,
  );

  /// Secondary copy, captions, helper text.
  static const small = TextStyle(
    fontFamily: AppTheme.sans,
    fontSize: 13,
    height: 1.45,
    fontWeight: FontWeight.w400,
  );

  /// Uppercase tracked label — the Swiss signature. Use above every block.
  static const label = TextStyle(
    fontFamily: AppTheme.sans,
    fontSize: 10.5,
    height: 1.2,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.1,
  );

  /// Large figure (a risk percentage). Tabular, so digits never shift.
  static const metric = TextStyle(
    fontFamily: AppTheme.mono,
    fontSize: 34,
    height: 1.0,
    fontWeight: FontWeight.w500,
    letterSpacing: -1.4,
  );

  /// Inline figure inside a row or table.
  static const mono = TextStyle(
    fontFamily: AppTheme.mono,
    fontSize: 13,
    height: 1.3,
    fontWeight: FontWeight.w400,
  );
}

/// Brightness-aware neutral colours. Brand colours live on [AppTheme].
class Palette {
  final Color bg; // page background
  final Color card; // raised surface
  final Color ink; // primary text
  final Color subtle; // secondary text
  final Color line; // rules and borders — the main structural device
  final Color field; // input fill
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
    bg: Color(0xFFF4F6F3),
    card: Colors.white,
    ink: Color(0xFF141A17),
    subtle: Color(0xFF6B7872),
    line: Color(0xFFDDE4DF),
    field: Colors.white,
    isDark: false,
  );

  static const dark = Palette(
    bg: Color(0xFF0F1512),
    card: Color(0xFF171F1A),
    ink: Color(0xFFEDF2EE),
    subtle: Color(0xFF8A9992),
    line: Color(0xFF27322C),
    field: Color(0xFF171F1A),
    isDark: true,
  );

  static Palette of(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? dark : light;

  /// A flat brand wash for a filled block. No gradients anywhere in this app.
  Color tint(Color brand) => brand.withValues(alpha: isDark ? 0.16 : 0.10);

  /// Deprecated in this design system: surfaces are separated by rules, not
  /// shadows. Retained only for the bottom navigation bar's lift.
  List<BoxShadow> get shadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: isDark ? 0.36 : 0.05),
          blurRadius: 12,
          offset: const Offset(0, -2),
        ),
      ];
}

/// A surface bounded by a hairline rule. The app's only container.
///
/// Flat fill, one radius, no shadow — depth comes from the rule, which is how
/// print and Swiss interface design separate things.
class SoftCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;

  /// Optional accent stripe along the top edge — used sparingly, and only to
  /// carry meaning (a risk tier), never as decoration.
  final Color? accent;

  const SoftCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    final body = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: BorderRadius.circular(AppTheme.radius),
        border: Border.all(color: p.line, width: AppTheme.hair),
      ),
      child: child,
    );

    final content = accent == null
        ? body
        : Column(mainAxisSize: MainAxisSize.min, children: [
            Container(height: 3, color: accent),
            Expanded(child: body),
          ]);

    if (onTap == null) return content;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radius),
        child: content,
      ),
    );
  }
}

/// Uppercase tracked section label with a rule running to the right margin.
///
/// This is the app's main structural device: it names a block and physically
/// separates it, doing the job a drop shadow was doing before.
class SectionLabel extends StatelessWidget {
  final String text;
  final Widget? trailing;
  const SectionLabel(this.text, {super.key, this.trailing});

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(text.toUpperCase(),
              style: AppType.label.copyWith(color: p.subtle)),
          const SizedBox(width: 10),
          Expanded(child: Container(height: AppTheme.hair, color: p.line)),
          if (trailing != null) ...[const SizedBox(width: 10), trailing!],
        ],
      ),
    );
  }
}

/// A flat brand-filled block. Replaces the old gradient hero panels.
class BrandBlock extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final Color color;
  const BrandBlock({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.color = AppTheme.green,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppTheme.radius),
      ),
      child: child,
    );
  }
}

/// A square brand-tinted icon holder. Replaces the old gradient icon tiles.
class IconChip extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;
  const IconChip(this.icon, {super.key, this.color = AppTheme.green, this.size = 40});

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        color: p.tint(color),
        borderRadius: BorderRadius.circular(AppTheme.radius),
      ),
      child: Icon(icon, color: color, size: size * 0.5),
    );
  }
}

/// A full-width hairline rule.
class Rule extends StatelessWidget {
  final EdgeInsets margin;
  const Rule({super.key, this.margin = EdgeInsets.zero});

  @override
  Widget build(BuildContext context) => Container(
        height: AppTheme.hair,
        margin: margin,
        color: Palette.of(context).line,
      );
}
