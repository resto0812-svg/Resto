import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Identité « Ivoire & Or » (maquettes « DELICES » de l'utilisateur,
/// 2026-10-11) : fond ivoire chaud, cartes blanches à ombre douce, or pour les
/// actions et la sélection, grands titres à empattements (Playfair Display),
/// textes en Poppins.
abstract final class RestoColors {
  static const base = Color(0xFFF8F4EC); // fond ivoire de toute l'application
  static const raised = Color(0xFFFFFFFF); // cartes blanches
  static const sunken = Color(0xFFF3ECE0); // champs
  static const band = Color(0xFFF2E8D6); // bandeaux beige (infos d'une carte)
  static const shadowDark = Color(0xFFE2D6C2); // ombre douce
  static const shadowLight = Color(0xFFFFFFFF);
  static const primary = Color(0xFFC69C3A); // or : actions, sélection (remplissages)
  static const primaryDeep = Color(0xFF7E5F17); // or foncé : textes et icônes sur fond clair (contraste 5,4:1 sur ivoire)
  static const primaryBright = Color(0xFFE2C26F);
  static const primarySoft = Color(0xFFF6ECD4);
  static const onPrimary = Color(0xFFFFFFFF); // texte sur l'or
  static const ink = Color(0xFF231A12); // textes (brun très foncé)
  static const muted = Color(0xFF6E6250); // textes secondaires (contraste 5,4:1 sur ivoire)
  static const line = Color(0xFFECE2D1); // filets

  /// Dégradé or (boutons principaux, bandeaux, sélection).
  static const brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFB48526), primary, primaryBright],
  );

  /// Ombre douce des cartes blanches.
  static List<BoxShadow> softShadow([double d = 8]) => [
        BoxShadow(color: const Color(0xFF7A5A20).withValues(alpha: 0.09), blurRadius: d * 2.4, offset: Offset(0, d * 0.6)),
      ];
}

/// Grands titres à empattements des maquettes (« Cuisine », « Rapports »).
TextStyle serifTitle(BuildContext context, {double size = 34, Color? color, FontWeight weight = FontWeight.w600}) {
  final fonts = Theme.of(context).extension<RestoFonts>()?.enabled ?? false;
  final base = TextStyle(fontSize: size, fontWeight: weight, color: color ?? RestoColors.ink, height: 1.1);
  return fonts ? GoogleFonts.playfairDisplay(textStyle: base) : base.copyWith(fontFamily: 'serif');
}

/// Polices téléchargées ou non (tests hors ligne).
class RestoFonts extends ThemeExtension<RestoFonts> {
  const RestoFonts(this.enabled);
  final bool enabled;

  @override
  RestoFonts copyWith({bool? enabled}) => RestoFonts(enabled ?? this.enabled);

  @override
  RestoFonts lerp(RestoFonts? other, double t) => this;
}

/// Couleurs d'état, identiques partout (salle, commandes, cuisine, caisse).
abstract final class StatusColors {
  static const free = Color(0xFF16A36A); // libre
  static const reserved = Color(0xFF8B5CF6); // réservée
  static const occupied = Color(0xFF475569); // occupée (ardoise)
  static const toValidate = Color(0xFFF59E0B); // à valider (commande client)
  static const cooking = Color(0xFFF97316); // en préparation
  static const ready = Color(0xFF0EA5A4); // prête à servir
  static const toPay = Color(0xFFDB2777); // à encaisser
  static const late = Color(0xFFE11D48); // en retard
  static const done = Color(0xFF64748B); // terminée
}

ColorScheme _scheme(bool light) => light
    ? const ColorScheme(
        brightness: Brightness.light,
        primary: RestoColors.primaryDeep,
        onPrimary: Colors.white,
        primaryContainer: RestoColors.primarySoft,
        onPrimaryContainer: Color(0xFF5E4710),
        secondary: RestoColors.primary,
        onSecondary: RestoColors.onPrimary,
        secondaryContainer: Color(0xFFF3E7CC),
        onSecondaryContainer: RestoColors.ink,
        tertiary: Color(0xFF0EA5A4),
        onTertiary: Colors.white,
        error: Color(0xFFD9363E),
        onError: Colors.white,
        surface: RestoColors.base,
        onSurface: RestoColors.ink,
        surfaceContainerLowest: RestoColors.raised,
        surfaceContainerLow: Color(0xFFFBF8F2),
        surfaceContainer: RestoColors.sunken,
        surfaceContainerHigh: Color(0xFFEDE3D3),
        surfaceContainerHighest: Color(0xFFE6DAC6),
        onSurfaceVariant: RestoColors.muted,
        outline: Color(0xFFC9B99E),
        outlineVariant: RestoColors.line,
        inverseSurface: RestoColors.ink,
        onInverseSurface: RestoColors.base,
      )
    : const ColorScheme(
        brightness: Brightness.dark,
        primary: Color(0xFFE3C46E),
        onPrimary: Color(0xFF1C2230),
        primaryContainer: Color(0xFF5E4710),
        onPrimaryContainer: Color(0xFFF3E9CC),
        secondary: Color(0xFFE3C46E),
        onSecondary: Color(0xFF1C2230),
        secondaryContainer: Color(0xFF2A3550),
        onSecondaryContainer: Color(0xFFE7ECF5),
        tertiary: Color(0xFF2DD4BF),
        onTertiary: Color(0xFF032B26),
        error: Color(0xFFFB7185),
        onError: Color(0xFF4C0519),
        surface: Color(0xFF1C2230),
        onSurface: Color(0xFFE7ECF5),
        surfaceContainerLowest: Color(0xFF222A3A),
        surfaceContainerLow: Color(0xFF1F2635),
        surfaceContainer: Color(0xFF181D29),
        surfaceContainerHigh: Color(0xFF2A3346),
        surfaceContainerHighest: Color(0xFF323C52),
        onSurfaceVariant: Color(0xFF9AA6BF),
        outline: Color(0xFF6B7891),
        outlineVariant: Color(0xFF2E3749),
        inverseSurface: Color(0xFFE7ECF5),
        onInverseSurface: Color(0xFF1C2230),
      );

/// [fonts] = false dans les tests (pas de téléchargement de polices).
ThemeData restoTheme(Brightness brightness, {bool fonts = true}) {
  final light = brightness == Brightness.light;
  final scheme = _scheme(light);
  final base = ThemeData(useMaterial3: true, colorScheme: scheme, brightness: brightness);
  var text = fonts ? GoogleFonts.poppinsTextTheme(base.textTheme) : base.textTheme;
  // Titres d'écran à empattements, comme sur les maquettes.
  TextStyle? serif(TextStyle? s) =>
      s == null ? null : (fonts ? GoogleFonts.playfairDisplay(textStyle: s) : s).copyWith(fontWeight: FontWeight.w600);
  text = text
      .copyWith(
        displayLarge: serif(text.displayLarge),
        displayMedium: serif(text.displayMedium),
        displaySmall: serif(text.displaySmall),
        headlineLarge: serif(text.headlineLarge),
        headlineMedium: serif(text.headlineMedium),
        headlineSmall: serif(text.headlineSmall),
        titleLarge: text.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        titleMedium: text.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        titleSmall: text.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        labelLarge: text.labelLarge?.copyWith(fontWeight: FontWeight.w600),
      )
      .apply(bodyColor: scheme.onSurface, displayColor: scheme.onSurface);

  final shadow = light ? const Color(0x2E7A5A20) : const Color(0xFF0F131C);
  OutlineInputBorder border(Color c, [double w = 1]) =>
      OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: c, width: w));

  final gold = light ? RestoColors.primary : const Color(0xFFE3C46E);
  return base.copyWith(
    textTheme: text,
    extensions: [RestoFonts(fonts)],
    scaffoldBackgroundColor: scheme.surface,
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surface,
      foregroundColor: scheme.onSurface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: text.titleLarge,
    ),
    tabBarTheme: TabBarThemeData(
      labelColor: scheme.primary,
      unselectedLabelColor: scheme.onSurfaceVariant,
      indicatorColor: scheme.primary,
      labelStyle: text.labelLarge,
      dividerColor: Colors.transparent,
    ),
    // Cartes en léger relief : un peu plus claires que le fond, ombre douce.
    cardTheme: CardThemeData(
      color: scheme.surfaceContainerLowest,
      surfaceTintColor: Colors.transparent,
      elevation: 3,
      shadowColor: shadow,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    ),
    filledButtonTheme: FilledButtonThemeData(
      // Boutons pleins : or, texte bleu nuit.
      style: FilledButton.styleFrom(
        minimumSize: const Size(64, 48),
        padding: const EdgeInsets.symmetric(horizontal: 22),
        backgroundColor: gold,
        foregroundColor: RestoColors.onPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 2,
        shadowColor: gold.withValues(alpha: 0.4),
        textStyle: text.labelLarge,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(64, 48),
        padding: const EdgeInsets.symmetric(horizontal: 18),
        backgroundColor: scheme.surfaceContainerLowest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        side: BorderSide(color: scheme.outlineVariant),
        textStyle: text.labelLarge,
      ),
    ),
    textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(textStyle: text.labelLarge)),
    // Champs « creusés » : un ton plus sombre que la surface, sans bordure.
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: scheme.surfaceContainer,
      border: border(Colors.transparent),
      enabledBorder: border(Colors.transparent),
      focusedBorder: border(scheme.primary, 1.6),
      errorBorder: border(scheme.error.withValues(alpha: 0.6)),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: scheme.surfaceContainerLowest,
      selectedColor: scheme.primaryContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      side: BorderSide(color: scheme.outlineVariant),
      labelStyle: text.labelMedium,
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: SegmentedButton.styleFrom(
        backgroundColor: scheme.surfaceContainerLowest,
        selectedBackgroundColor: scheme.primaryContainer,
        side: BorderSide(color: scheme.outlineVariant),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: scheme.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: scheme.surface,
      surfaceTintColor: Colors.transparent,
      showDragHandle: true,
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: scheme.surfaceContainerLowest,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: light ? RestoColors.ink : const Color(0xFFE7ECF5),
      contentTextStyle: text.bodyMedium?.copyWith(color: light ? Colors.white : RestoColors.ink),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(color: light ? RestoColors.ink : const Color(0xFFE7ECF5), borderRadius: BorderRadius.circular(10)),
      textStyle: TextStyle(color: light ? Colors.white : RestoColors.ink, fontWeight: FontWeight.w500),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    ),
    dividerTheme: DividerThemeData(color: scheme.outlineVariant, space: 1),
    navigationRailTheme: NavigationRailThemeData(indicatorColor: scheme.primaryContainer),
    navigationBarTheme: NavigationBarThemeData(indicatorColor: scheme.primaryContainer),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: gold,
      foregroundColor: RestoColors.onPrimary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    ),
  );
}

/// Pastille d'état : petit badge coloré (« Libre », « Prête »…).
class StatusPill extends StatelessWidget {
  const StatusPill({super.key, required this.label, required this.color, this.icon, this.dense = false});
  final String label;
  final Color color;
  final IconData? icon;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: dense ? 8 : 11, vertical: dense ? 3 : 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        if (icon != null) ...[Icon(icon, size: dense ? 12 : 14, color: color), SizedBox(width: dense ? 3 : 5)],
        Flexible(
          child: Text(label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: dense ? 11 : 12, height: 1.2)),
        ),
      ]),
    );
  }
}
