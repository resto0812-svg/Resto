import 'package:flutter/material.dart';

import 'theme.dart';

/// Surfaces du thème « Ivoire & Or » : fond ivoire, cartes blanches à ombre
/// douce, champs crème. Utilisé pour la connexion, le dock, la barre
/// flottante et l'accueil.
class NeuPalette {
  const NeuPalette._(this.base, this.card, this.field, this.dark, this.accent, this.text, this.muted, this.isDark);

  /// Fond de page.
  final Color base;

  /// Cartes, dock, barre flottante.
  final Color card;

  /// Champs et zones creusées.
  final Color field;
  final Color dark;
  final Color accent;
  final Color text;
  final Color muted;
  final bool isDark;

  static NeuPalette of(BuildContext context) => Theme.of(context).brightness == Brightness.dark
      ? const NeuPalette._(Color(0xFF1C2230), Color(0xFF242C3D), Color(0xFF181D29), Color(0xFF0B0E15), Color(0xFFE3C46E),
          Color(0xFFE7ECF5), Color(0xFF9AA6BF), true)
      : const NeuPalette._(RestoColors.base, RestoColors.raised, RestoColors.sunken, RestoColors.shadowDark, RestoColors.primaryDeep,
          RestoColors.ink, RestoColors.muted, false);

  /// Ombre douce sous une carte.
  List<BoxShadow> raised([double d = 8]) => isDark
      ? [BoxShadow(color: dark, offset: Offset(0, d * 0.6), blurRadius: d * 2.4)]
      : RestoColors.softShadow(d);

  /// Appui : l'ombre se resserre.
  List<BoxShadow> inset([double d = 4]) => isDark
      ? [BoxShadow(color: dark, offset: Offset(0, d * 0.3), blurRadius: d)]
      : [BoxShadow(color: const Color(0xFF7A5A20).withValues(alpha: 0.06), offset: Offset(0, d * 0.3), blurRadius: d)];
}

/// Carte blanche à ombre douce.
class NeuCard extends StatelessWidget {
  const NeuCard({super.key, required this.child, this.radius = 28, this.padding = const EdgeInsets.all(32), this.depth = 12});
  final Widget child;
  final double radius;
  final EdgeInsets padding;
  final double depth;

  @override
  Widget build(BuildContext context) {
    final p = NeuPalette.of(context);
    return Container(
      padding: padding,
      decoration: BoxDecoration(color: p.card, borderRadius: BorderRadius.circular(radius), boxShadow: p.raised(depth)),
      child: child,
    );
  }
}

/// Médaillon rond en relief : icône seule, ou bouton si [onTap].
class NeuCircle extends StatefulWidget {
  const NeuCircle({super.key, required this.icon, this.size = 84, this.onTap, this.tooltip});
  final IconData icon;
  final double size;
  final VoidCallback? onTap;
  final String? tooltip;

  @override
  State<NeuCircle> createState() => _NeuCircleState();
}

class _NeuCircleState extends State<NeuCircle> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final p = NeuPalette.of(context);
    final circle = AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        color: p.card,
        shape: BoxShape.circle,
        border: Border.all(color: RestoColors.primaryBright.withValues(alpha: 0.7), width: 1.4),
        boxShadow: _down ? p.inset(3) : p.raised(widget.size / 12),
      ),
      child: Icon(widget.icon, color: p.accent, size: widget.size * 0.42),
    );
    if (widget.onTap == null) return circle;
    final button = GestureDetector(
      onTapDown: (_) => setState(() => _down = true),
      onTapCancel: () => setState(() => _down = false),
      onTapUp: (_) => setState(() => _down = false),
      onTap: widget.onTap,
      child: MouseRegion(cursor: SystemMouseCursors.click, child: circle),
    );
    return widget.tooltip == null ? button : Tooltip(message: widget.tooltip!, child: button);
  }
}

/// Champ de saisie creusé dans la surface.
class NeuField extends StatefulWidget {
  const NeuField({
    super.key,
    required this.controller,
    required this.hint,
    this.icon,
    this.obscure = false,
    this.keyboard,
    this.autofill,
    this.validator,
    this.onSubmitted,
    this.maxLength,
    this.textAlign = TextAlign.start,
    this.style,
    this.autofocus = false,
  });

  final TextEditingController controller;
  final String hint;
  final IconData? icon;
  final bool obscure;
  final TextInputType? keyboard;
  final Iterable<String>? autofill;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onSubmitted;
  final int? maxLength;
  final TextAlign textAlign;
  final TextStyle? style;
  final bool autofocus;

  @override
  State<NeuField> createState() => _NeuFieldState();
}

class _NeuFieldState extends State<NeuField> {
  late bool _hidden = widget.obscure;

  @override
  Widget build(BuildContext context) {
    final p = NeuPalette.of(context);
    final t = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: p.field,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: RestoColors.line),
      ),
      child: TextFormField(
        controller: widget.controller,
        obscureText: _hidden,
        autofocus: widget.autofocus,
        keyboardType: widget.keyboard,
        autofillHints: widget.autofill,
        validator: widget.validator,
        onFieldSubmitted: widget.onSubmitted,
        maxLength: widget.maxLength,
        textAlign: widget.textAlign,
        style: widget.style ?? t.textTheme.bodyLarge?.copyWith(color: p.text),
        decoration: InputDecoration(
          filled: false,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          focusedErrorBorder: InputBorder.none,
          counterText: '',
          hintText: widget.hint,
          hintStyle: t.textTheme.bodyLarge?.copyWith(color: p.muted),
          prefixIcon: widget.icon == null ? null : Icon(widget.icon, color: p.muted, size: 20),
          suffixIcon: widget.obscure
              ? IconButton(
                  onPressed: () => setState(() => _hidden = !_hidden),
                  icon: Icon(_hidden ? Icons.visibility_rounded : Icons.visibility_off_rounded, color: p.muted),
                )
              : null,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        ),
      ),
    );
  }
}

/// Bouton en relief : s'enfonce à l'appui, roue pendant l'opération.
class NeuButton extends StatefulWidget {
  const NeuButton({super.key, required this.label, required this.onPressed, this.icon, this.filled = false});
  final String label;
  final Future<void> Function()? onPressed;
  final IconData? icon;

  /// Plein (couleur d'accent) pour l'action principale d'un écran sombre.
  final bool filled;

  @override
  State<NeuButton> createState() => _NeuButtonState();
}

class _NeuButtonState extends State<NeuButton> {
  bool _down = false;
  bool _busy = false;

  Future<void> _run() async {
    if (_busy || widget.onPressed == null) return;
    setState(() => _busy = true);
    try {
      await widget.onPressed!();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = NeuPalette.of(context);
    final fg = widget.filled ? Colors.white : p.accent;
    return GestureDetector(
      onTapDown: (_) => setState(() => _down = true),
      onTapCancel: () => setState(() => _down = false),
      onTapUp: (_) => setState(() => _down = false),
      onTap: _run,
      child: MouseRegion(
        cursor: widget.onPressed == null ? SystemMouseCursors.basic : SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          height: 58,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: widget.filled ? null : p.card,
            gradient: widget.filled ? RestoColors.brandGradient : null,
            border: widget.filled ? null : Border.all(color: RestoColors.primary.withValues(alpha: 0.55)),
            borderRadius: BorderRadius.circular(18),
            boxShadow: _down || _busy ? p.inset(3) : p.raised(7),
          ),
          child: _busy
              ? SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.4, color: fg))
              : Row(mainAxisSize: MainAxisSize.min, children: [
                  if (widget.icon != null) ...[Icon(widget.icon, color: fg, size: 20), const SizedBox(width: 8)],
                  Text(widget.label, style: TextStyle(color: fg, fontWeight: FontWeight.w800, fontSize: 16, letterSpacing: 0.3)),
                ]),
        ),
      ),
    );
  }
}
