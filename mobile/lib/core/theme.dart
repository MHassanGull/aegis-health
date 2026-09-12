import 'package:flutter/material.dart';

import 'motion.dart';

/// Aegis Health design system, "Forecast".
///
/// The model does not return a verdict, it returns a probability. So the app
/// borrows the vernacular of forecasting rather than diagnosis: a value, a
/// threshold, and a projection of where you could get to. Surfaces are soft
/// and layered, the ground is warm paper rather than clinical grey, and colour
/// is reserved for meaning.
///
/// Every pairing used for text meets WCAG AA (4.5:1); interactive boundaries
/// meet 3:1. The type scale lives in [ThemeData.textTheme], so the reader's
/// system text-size setting scales the whole app.
class AppTheme {
  // ---- Brand -----------------------------------------------------------
  //
  // One hue, four jobs. A single green cannot be legible as text, legible
  // beneath white text, and vivid as a fill all at once, so each job gets its
  // own value at the same hue.
  static const Color green = Color(0xFF20A57A); // fills, marks, chart series
  static const Color greenInk = Color(0xFF197F5E); // green set as text
  static const Color greenField = Color(0xFF198361); // field under white text
  static const Color greenDeep = Color(0xFF0E5C44); // deep ground
  static const Color greenDark = Color(0xFF15805C);

  static const Color coral = Color(0xFFFF7A63); // accent fills
  static const Color coralInk = Color(0xFFC2412B); // coral set as text
  static const Color amber = Color(0xFFF2A03D);
  static const Color amberInk = Color(0xFF8A5A11);

  // ---- Risk tiers (semantic, never decorative) -------------------------
  static const Color low = Color(0xFF1F9A63);
  static const Color moderate = Color(0xFFCC7A14);
  static const Color high = Color(0xFFD2402B);

  // ---- Light-mode aliases, for call sites that do not adapt -------------
  static const Color ink = Color(0xFF12211C);
  static const Color slate = Color(0xFF62706A);
  static const Color line = Color(0xFFE7E3DB);
  static const Color bg = Color(0xFFFCFAF7);
  static const Color card = Colors.white;
  static const Color greenSoft = Color(0xFFE4F3EC);
  static const Color coralSoft = Color(0xFFFFEDE8);
  static const Color panel = Color(0xFF12211C);
  static const Color panelDark = Color(0xFF08110D);

  // ---- Geometry --------------------------------------------------------
  /// Cards and panels. Generous: soft, large radii are what currently reads as
  /// modern, and the previous near-square 4px read as dated.
  static const double rCard = 20;

  /// Buttons, inputs, chips.
  static const double rControl = 14;

  /// Fully rounded, for pills and status badges.
  static const double rPill = 100;

  /// Alias for call sites written against the previous system.
  static const double radius = rControl;

  /// Page gutter.
  static const double gutter = 22;

  static const double hair = 1;
  static const double heavy = 3;

  // ---- Typeface --------------------------------------------------------
  /// Display face. Characterful, reserved for one statement per screen.
  static const String display = 'Bricolage';

  /// Body and interface face.
  static const String sans = 'InstrumentSans';

  /// Figures. Tabular, so digits hold their column.
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

  /// Darkened variant of a brand colour, for when it must carry text.
  static Color onLight(Color c) =>
      Color.alphaBlend(Colors.black.withValues(alpha: 0.24), c);

  // ---- Type scale ------------------------------------------------------
  static TextTheme _text(Palette p) => TextTheme(
        displayLarge: TextStyle(
            fontFamily: display,
            fontSize: 38,
            height: 1.02,
            fontWeight: FontWeight.w700,
            letterSpacing: -1.3,
            color: p.ink),
        displayMedium: TextStyle(
            fontFamily: display,
            fontSize: 30,
            height: 1.08,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.9,
            color: p.ink),
        displaySmall: TextStyle(
            fontFamily: display,
            fontSize: 24,
            height: 1.15,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.5,
            color: p.ink),
        headlineSmall: TextStyle(
            fontFamily: display,
            fontSize: 19,
            height: 1.25,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.3,
            color: p.ink),
        titleMedium: TextStyle(
            fontFamily: sans,
            fontSize: 16,
            height: 1.3,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.1,
            color: p.ink),
        titleSmall: TextStyle(
            fontFamily: sans,
            fontSize: 14,
            height: 1.35,
            fontWeight: FontWeight.w600,
            color: p.ink),
        bodyLarge: TextStyle(
            fontFamily: sans,
            fontSize: 15.5,
            height: 1.55,
            fontWeight: FontWeight.w400,
            color: p.ink),
        bodyMedium: TextStyle(
            fontFamily: sans,
            fontSize: 14,
            height: 1.5,
            fontWeight: FontWeight.w400,
            color: p.subtle),
        bodySmall: TextStyle(
            fontFamily: sans,
            fontSize: 12.5,
            height: 1.45,
            fontWeight: FontWeight.w400,
            color: p.subtle),
        labelLarge: TextStyle(
            fontFamily: sans,
            fontSize: 15,
            height: 1.2,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
            color: p.ink),
        labelMedium: TextStyle(
            fontFamily: sans,
            fontSize: 12.5,
            height: 1.2,
            fontWeight: FontWeight.w600,
            color: p.subtle),
        labelSmall: TextStyle(
            fontFamily: sans,
            fontSize: 11,
            height: 1.2,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.7,
            color: p.subtle),
      );

  // ---- Theme -----------------------------------------------------------
  static ThemeData _build(Palette p, Brightness b) {
    final text = _text(p);
    final base = ThemeData(
      useMaterial3: true,
      brightness: b,
      fontFamily: sans,
      textTheme: text,
      scaffoldBackgroundColor: p.bg,
      colorScheme: ColorScheme.fromSeed(
        seedColor: green,
        brightness: b,
        primary: greenField,
        onPrimary: Colors.white,
        secondary: coral,
        surface: p.card,
        onSurface: p.ink,
        error: high,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(builders: {
        TargetPlatform.android: EditorialPageTransition(),
        TargetPlatform.iOS: EditorialPageTransition(),
      }),
    );

    return base.copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: p.bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: p.ink,
        centerTitle: false,
        titleSpacing: gutter,
        titleTextStyle: text.headlineSmall,
      ),
      dividerTheme:
          DividerThemeData(color: p.line, thickness: hair, space: hair),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: greenField,
          foregroundColor: Colors.white,
          disabledBackgroundColor: p.line,
          disabledForegroundColor: p.subtle,
          minimumSize: const Size.fromHeight(54),
          elevation: 0,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(rControl))),
          textStyle: text.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: p.ink,
          minimumSize: const Size.fromHeight(54),
          side: BorderSide(color: p.edge, width: hair),
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(rControl))),
          textStyle: text.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: greenInk,
          minimumSize: const Size(48, 48),
          textStyle: text.labelLarge,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: p.field,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        prefixIconColor: p.subtle,
        hintStyle: text.bodyLarge?.copyWith(color: p.subtle),
        labelStyle: text.bodyLarge?.copyWith(color: p.subtle),
        border: _fieldBorder(p.edge),
        enabledBorder: _fieldBorder(p.edge),
        focusedBorder: _fieldBorder(greenField, width: 2),
        errorBorder: _fieldBorder(high),
        focusedErrorBorder: _fieldBorder(high, width: 2),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: p.isDark ? const Color(0xFF23302A) : ink,
        contentTextStyle: text.bodyMedium?.copyWith(color: Colors.white),
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(rControl))),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: p.card,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(rCard))),
        titleTextStyle: text.headlineSmall,
      ),
      switchTheme: SwitchThemeData(
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
        thumbColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected) ? Colors.white : p.subtle),
        trackColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected) ? greenField : p.line),
      ),
      sliderTheme: SliderThemeData(
        trackHeight: 6,
        activeTrackColor: greenField,
        inactiveTrackColor: p.line,
        thumbColor: Colors.white,
        overlayColor: greenField.withValues(alpha: 0.12),
        thumbShape: const RoundSliderThumbShape(
            enabledThumbRadius: 11, elevation: 2, pressedElevation: 4),
      ),
    );
  }

  static OutlineInputBorder _fieldBorder(Color c, {double width = hair}) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(rControl),
        borderSide: BorderSide(color: c, width: width),
      );

  static ThemeData get light => _build(Palette.light, Brightness.light);
  static ThemeData get dark => _build(Palette.dark, Brightness.dark);
}

/// Brightness-aware neutrals. Brand colours live on [AppTheme].
class Palette {
  final Color bg; // page ground
  final Color card; // raised surface
  final Color sunk; // recessed band, one step off the page
  final Color ink; // primary text
  final Color subtle; // secondary text, AA on [bg]
  final Color line; // decorative dividers
  final Color edge; // interactive boundaries, 3:1 on [bg]
  final Color field; // input fill
  final bool isDark;

  const Palette({
    required this.bg,
    required this.card,
    required this.sunk,
    required this.ink,
    required this.subtle,
    required this.line,
    required this.edge,
    required this.field,
    required this.isDark,
  });

  static const light = Palette(
    bg: Color(0xFFFCFAF7), // warm paper, not clinical grey
    card: Colors.white,
    sunk: Color(0xFFF3F0E9),
    ink: Color(0xFF12211C),
    subtle: Color(0xFF62706A), // 4.9:1 on bg
    line: Color(0xFFE7E3DB),
    edge: Color(0xFF6E7C75), // 3.5:1 on bg
    field: Colors.white,
    isDark: false,
  );

  static const dark = Palette(
    bg: Color(0xFF0C1512),
    card: Color(0xFF14201B),
    sunk: Color(0xFF101A16),
    ink: Color(0xFFF0F4F1),
    subtle: Color(0xFF93A29B),
    line: Color(0xFF243029),
    edge: Color(0xFF6E7C75),
    field: Color(0xFF14201B),
    isDark: true,
  );

  static Palette of(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? dark : light;

  /// A soft brand wash for a filled surface.
  Color tint(Color brand) => brand.withValues(alpha: isDark ? 0.18 : 0.10);

  /// Brand colour adjusted so it can carry text on this brightness.
  Color on(Color brand) => isDark ? brand : AppTheme.onLight(brand);

  /// A very soft lift. Used sparingly, never to fake depth on everything.
  List<BoxShadow> get shadow => [
        BoxShadow(
          color: isDark
              ? Colors.black.withValues(alpha: 0.40)
              : const Color(0xFF12211C).withValues(alpha: 0.05),
          blurRadius: 24,
          offset: const Offset(0, 6),
        ),
      ];
}

/// The app's standard surface: a soft card on the warm ground.
class SoftCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;
  final Color? accent;
  final Color? color;
  const SoftCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.onTap,
    this.accent,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    final body = Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? p.card,
        borderRadius: BorderRadius.circular(AppTheme.rCard),
        border: Border.all(color: p.line, width: AppTheme.hair),
      ),
      child: child,
    );
    if (onTap == null) return body;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.rCard),
        child: body,
      ),
    );
  }
}

/// A section heading, marked as a heading so screen readers can jump to it.
class SectionLabel extends StatelessWidget {
  final String text;
  final Widget? trailing;
  const SectionLabel(this.text, {super.key, this.trailing});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Semantics(header: true, child: Text(text, style: t.headlineSmall)),
          const Spacer(),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// A filled brand panel.
class BrandBlock extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final Color color;
  const BrandBlock({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(22),
    this.color = AppTheme.greenField,
  });

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: padding,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(AppTheme.rCard),
        ),
        child: child,
      );
}

/// A rounded, brand-tinted icon holder.
class IconChip extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;
  const IconChip(this.icon,
      {super.key, this.color = AppTheme.green, this.size = 44});

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        color: p.tint(color),
        borderRadius: BorderRadius.circular(AppTheme.rControl),
      ),
      child: Icon(icon, color: p.on(color), size: size * 0.46),
    );
  }
}

/// A hairline divider.
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

/// A small status pill. Always carries a tier, never decoration.
class StatusPill extends StatelessWidget {
  final String text;
  final Color color;
  const StatusPill(this.text, this.color, {super.key});

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: p.isDark ? 0.20 : 0.12),
        borderRadius: BorderRadius.circular(AppTheme.rPill),
      ),
      child: Text(text,
          style: Theme.of(context)
              .textTheme
              .labelMedium
              ?.copyWith(color: p.on(color))),
    );
  }
}

/// Static type tokens.
///
/// Prefer `Theme.of(context).textTheme` in new code, because that path honours
/// the reader's system text-size setting. These exist so call sites written
/// against the earlier scale keep working, and they map onto the same faces
/// and sizes as the theme's scale.
class AppType {
  const AppType._();

  static const poster = TextStyle(
      fontFamily: AppTheme.display,
      fontSize: 38,
      height: 1.02,
      fontWeight: FontWeight.w700,
      letterSpacing: -1.3);

  static const display = TextStyle(
      fontFamily: AppTheme.display,
      fontSize: 30,
      height: 1.08,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.9);

  static const h1 = TextStyle(
      fontFamily: AppTheme.display,
      fontSize: 24,
      height: 1.15,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.5);

  static const h2 = TextStyle(
      fontFamily: AppTheme.sans,
      fontSize: 16,
      height: 1.3,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.1);

  static const body = TextStyle(
      fontFamily: AppTheme.sans,
      fontSize: 15.5,
      height: 1.55,
      fontWeight: FontWeight.w400);

  static const small = TextStyle(
      fontFamily: AppTheme.sans,
      fontSize: 13,
      height: 1.5,
      fontWeight: FontWeight.w400);

  static const label = TextStyle(
      fontFamily: AppTheme.sans,
      fontSize: 11,
      height: 1.2,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.7);

  static const metric = TextStyle(
      fontFamily: AppTheme.mono,
      fontSize: 34,
      height: 1.0,
      fontWeight: FontWeight.w500,
      letterSpacing: -1.4);

  static const figure = TextStyle(
      fontFamily: AppTheme.mono,
      fontSize: 48,
      height: 0.95,
      fontWeight: FontWeight.w500,
      letterSpacing: -2.4);

  static const mono = TextStyle(
      fontFamily: AppTheme.mono,
      fontSize: 13,
      height: 1.3,
      fontWeight: FontWeight.w400);
}
