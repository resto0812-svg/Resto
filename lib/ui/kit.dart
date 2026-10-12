import 'package:flutter/material.dart';

import 'theme.dart';

/// Briques visuelles des maquettes « Ivoire & Or » : pastilles de filtre,
/// cartes blanches, cartes à bandeau or, indicateurs, compteurs, boutons or.

/// Carte blanche à ombre douce (bloc d'un écran).
class SoftCard extends StatelessWidget {
  const SoftCard({super.key, required this.child, this.padding = const EdgeInsets.all(20), this.radius = 20, this.onTap, this.color});
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final VoidCallback? onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final box = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? Theme.of(context).colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: dark ? null : RestoColors.softShadow(8),
        border: dark ? Border.all(color: Theme.of(context).colorScheme.outlineVariant) : null,
      ),
      child: child,
    );
    if (onTap == null) return box;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: onTap, child: box),
    );
  }
}

/// Titre de bloc avec pictogramme or (« Top plats », « Transactions récentes »).
class SectionHeading extends StatelessWidget {
  const SectionHeading({super.key, required this.title, this.icon, this.trailing, this.subtitle});
  final String title;
  final IconData? icon;
  final Widget? trailing;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(children: [
      if (icon != null) ...[GoldIcon(icon!, size: 36), const SizedBox(width: 12)],
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: theme.textTheme.titleMedium),
          if (subtitle != null) Text(subtitle!, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        ]),
      ),
      ?trailing,
    ]);
  }
}

/// Pictogramme or dans un rond (plein = dégradé or, sinon crème bordé d'or).
class GoldIcon extends StatelessWidget {
  const GoldIcon(this.icon, {super.key, this.size = 44, this.filled = false});
  final IconData icon;
  final double size;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: filled ? RestoColors.brandGradient : null,
        color: filled ? null : RestoColors.primarySoft,
        border: filled ? null : Border.all(color: RestoColors.primaryBright.withValues(alpha: 0.8)),
      ),
      child: Icon(icon, size: size * 0.5, color: filled ? Colors.white : RestoColors.primaryDeep),
    );
  }
}

/// Barre de pastilles (une seule sélectionnée) : or pour la sélection,
/// blanc bordé d'or sinon. Défile horizontalement si nécessaire.
class PillBar<T> extends StatelessWidget {
  const PillBar({super.key, required this.items, required this.selected, required this.onSelected, this.dense = false});
  final List<PillItem<T>> items;
  final T selected;
  final ValueChanged<T> onSelected;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(children: [
        for (final it in items)
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 8),
            child: GoldPill(
              label: it.label,
              icon: it.icon,
              count: it.count,
              selected: it.value == selected,
              dense: dense,
              onTap: () => onSelected(it.value),
            ),
          ),
      ]),
    );
  }
}

class PillItem<T> {
  const PillItem(this.value, this.label, {this.icon, this.count});
  final T value;
  final String label;
  final IconData? icon;
  final int? count;
}

/// Bouton rond de l'en-tête des modules : blanc cerclé d'or, ou doré plein
/// pour l'action principale (« + »).
class RoundIconButton extends StatelessWidget {
  const RoundIconButton({super.key, required this.icon, required this.onTap, required this.tooltip, this.gold = false});
  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;
  final bool gold;

  @override
  Widget build(BuildContext context) => Tooltip(
        message: tooltip,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              width: gold ? 38 : 34,
              height: gold ? 38 : 34,
              decoration: BoxDecoration(
                gradient: gold ? RestoColors.brandGradient : null,
                color: gold ? null : Colors.white,
                shape: BoxShape.circle,
                border: gold ? null : Border.all(color: RestoColors.primary.withValues(alpha: 0.40)),
                boxShadow: gold
                    ? [BoxShadow(color: RestoColors.primary.withValues(alpha: 0.35), blurRadius: 10, offset: const Offset(0, 4))]
                    : null,
              ),
              child: Icon(icon, size: gold ? 24 : 18, color: gold ? Colors.white : RestoColors.primaryDeep),
            ),
          ),
        ),
      );
}

class GoldPill extends StatelessWidget {
  const GoldPill({super.key, required this.label, required this.selected, required this.onTap, this.icon, this.count, this.dense = false});
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;
  final int? count;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final fg = selected ? Colors.white : RestoColors.ink;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: EdgeInsets.symmetric(horizontal: dense ? 11 : 14, vertical: dense ? 5 : 7),
          decoration: BoxDecoration(
            gradient: selected ? RestoColors.brandGradient : null,
            color: selected ? null : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: selected ? Colors.transparent : RestoColors.primary.withValues(alpha: 0.40)),
            boxShadow: selected ? [BoxShadow(color: RestoColors.primary.withValues(alpha: 0.25), blurRadius: 8, offset: const Offset(0, 3))] : null,
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            if (icon != null) ...[Icon(icon, size: dense ? 14 : 16, color: selected ? Colors.white : RestoColors.primaryDeep), const SizedBox(width: 6)],
            Text(label, style: TextStyle(color: fg, fontWeight: FontWeight.w600, fontSize: dense ? 12 : 13)),
            if (count != null) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
                decoration: BoxDecoration(
                  color: selected ? Colors.white.withValues(alpha: 0.28) : RestoColors.primarySoft,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('$count', style: TextStyle(color: selected ? Colors.white : RestoColors.primaryDeep, fontSize: 11.5, fontWeight: FontWeight.w700)),
              ),
            ],
          ]),
        ),
      ),
    );
  }
}

/// Compteur d'en-tête (« 12 commandes aujourd'hui », « 4 en cours »).
class CounterTile extends StatelessWidget {
  const CounterTile({super.key, required this.icon, required this.value, required this.label, this.highlight = false});
  final IconData icon;
  final String value;
  final String label;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        gradient: highlight ? RestoColors.brandGradient : null,
        color: highlight ? null : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: highlight ? null : Border.all(color: RestoColors.primary.withValues(alpha: 0.35)),
        boxShadow: RestoColors.softShadow(5),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 17, color: highlight ? Colors.white : RestoColors.primaryDeep),
        const SizedBox(width: 8),
        Text(value, style: theme.textTheme.titleMedium?.copyWith(color: highlight ? Colors.white : RestoColors.ink, fontWeight: FontWeight.w700)),
        const SizedBox(width: 5),
        Text(label, style: theme.textTheme.bodySmall?.copyWith(color: highlight ? Colors.white : RestoColors.muted, fontSize: 12.5)),
      ]),
    );
  }
}

/// Indicateur (CA du jour, commandes en cours…) avec tendance facultative.
class KpiCard extends StatelessWidget {
  const KpiCard({super.key, required this.icon, required this.label, required this.value, this.trend, this.trendUp = true, this.footer, this.onTap});
  final IconData icon;
  final String label;
  final String value;
  final String? trend;
  final bool trendUp;
  final Widget? footer;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SoftCard(
      onTap: onTap,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
        Row(children: [
          GoldIcon(icon, size: 42),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodyMedium?.copyWith(color: RestoColors.muted)),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: AlignmentDirectional.centerStart,
                child: Text(value, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
              ),
            ]),
          ),
          if (trend != null) TrendChip(text: trend!, up: trendUp),
        ]),
        if (footer != null) ...[const SizedBox(height: 10), footer!],
      ]),
    );
  }
}

class TrendChip extends StatelessWidget {
  const TrendChip({super.key, required this.text, this.up = true, this.color});
  final String text;
  final bool up;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? (up ? const Color(0xFF2E9E5B) : const Color(0xFFD9363E));
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(color: c.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(up ? Icons.trending_up_rounded : Icons.trending_down_rounded, size: 15, color: c),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(color: c, fontWeight: FontWeight.w700, fontSize: 12)),
      ]),
    );
  }
}

/// Carte à bandeau or (commande, ticket de cuisine) : titre, puce à droite,
/// bandeau d'informations beige facultatif, contenu, action en bas.
class GoldHeaderCard extends StatelessWidget {
  const GoldHeaderCard({
    super.key,
    required this.title,
    this.titleIcon,
    this.badge,
    this.info,
    required this.child,
    this.action,
    this.headerColor,
    this.onTap,
  });
  final String title;
  final IconData? titleIcon;
  final Widget? badge;
  final Widget? info;
  final Widget child;
  final Widget? action;

  /// Bandeau d'une autre couleur (en retard, à valider…) ; or par défaut.
  final Color? headerColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SoftCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      radius: 18,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisSize: MainAxisSize.min, children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 11, 12, 11),
            decoration: BoxDecoration(
              gradient: headerColor == null ? RestoColors.brandGradient : null,
              color: headerColor,
            ),
            child: Row(children: [
              if (titleIcon != null) ...[Icon(titleIcon, size: 18, color: Colors.white), const SizedBox(width: 8)],
              Expanded(
                child: Text(title.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.w700, letterSpacing: 0.4)),
              ),
              ?badge,
            ]),
          ),
          if (info != null)
            Container(
              color: RestoColors.band,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
              child: DefaultTextStyle.merge(style: theme.textTheme.bodySmall?.copyWith(color: RestoColors.ink), child: info!),
            ),
          Padding(padding: const EdgeInsets.fromLTRB(16, 12, 16, 12), child: child),
          if (action != null) Padding(padding: const EdgeInsets.fromLTRB(14, 0, 14, 14), child: action),
        ]),
      ),
    );
  }
}

/// Puce claire sur un bandeau or (« 12 min », « Prête »).
class HeaderBadge extends StatelessWidget {
  const HeaderBadge({super.key, required this.text, this.icon});
  final String text;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.92), borderRadius: BorderRadius.circular(10)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        if (icon != null) ...[Icon(icon, size: 14, color: RestoColors.primaryDeep), const SizedBox(width: 4)],
        Text(text, style: const TextStyle(color: RestoColors.primaryDeep, fontWeight: FontWeight.w700, fontSize: 12.5)),
      ]),
    );
  }
}

/// Bouton principal or (dégradé), pleine largeur si [expand].
class GoldButton extends StatefulWidget {
  const GoldButton({super.key, required this.label, required this.onPressed, this.icon, this.expand = true, this.outlined = false});
  final String label;
  final Future<void> Function()? onPressed;
  final IconData? icon;
  final bool expand;

  /// Variante blanche bordée d'or (action secondaire).
  final bool outlined;

  @override
  State<GoldButton> createState() => _GoldButtonState();
}

class _GoldButtonState extends State<GoldButton> {
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
    final disabled = widget.onPressed == null;
    final fg = widget.outlined ? RestoColors.primaryDeep : Colors.white;
    final content = _busy
        ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.2, color: fg))
        : Row(mainAxisSize: MainAxisSize.min, children: [
            if (widget.icon != null) ...[Icon(widget.icon, size: 19, color: fg), const SizedBox(width: 8)],
            Flexible(
              child: Text(widget.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: fg, fontWeight: FontWeight.w700, fontSize: 14.5)),
            ),
          ]);
    final body = Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        gradient: widget.outlined || disabled ? null : RestoColors.brandGradient,
        color: widget.outlined ? Colors.white : (disabled ? RestoColors.line : null),
        borderRadius: BorderRadius.circular(14),
        border: widget.outlined ? Border.all(color: RestoColors.primary.withValues(alpha: 0.6)) : null,
        boxShadow: widget.outlined || disabled
            ? null
            : [BoxShadow(color: RestoColors.primary.withValues(alpha: 0.32), blurRadius: 14, offset: const Offset(0, 6))],
      ),
      // Pleine largeur si [expand], sinon à la taille du libellé (même dans un Wrap ou un Align).
      child: Center(widthFactor: widget.expand ? null : 1, child: content),
    );
    return MouseRegion(
      cursor: disabled ? SystemMouseCursors.basic : SystemMouseCursors.click,
      child: GestureDetector(
        onTap: _run,
        child: widget.expand ? SizedBox(width: double.infinity, child: body) : body,
      ),
    );
  }
}

/// État vide élégant (« Rien à encaisser pour le moment »).
class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.icon, required this.title, this.message, this.action});
  final IconData icon;
  final String title;
  final String? message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SoftCard(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        GoldIcon(icon, size: 76, filled: true),
        const SizedBox(height: 18),
        Text(title, textAlign: TextAlign.center, style: theme.textTheme.titleLarge),
        if (message != null) ...[
          const SizedBox(height: 6),
          Text(message!, textAlign: TextAlign.center, style: theme.textTheme.bodyMedium?.copyWith(color: RestoColors.muted)),
        ],
        if (action != null) ...[const SizedBox(height: 18), action!],
      ]),
    );
  }
}

/// Zone en pointillés or (dépôt d'un logo, de photos).
class DashedBox extends StatelessWidget {
  const DashedBox({super.key, required this.child, this.radius = 16, this.padding = const EdgeInsets.all(18), this.onTap});
  final Widget child;
  final double radius;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final box = CustomPaint(
      painter: _DashPainter(radius),
      child: Container(
        padding: padding,
        decoration: BoxDecoration(color: RestoColors.primarySoft.withValues(alpha: 0.45), borderRadius: BorderRadius.circular(radius)),
        child: child,
      ),
    );
    if (onTap == null) return box;
    return MouseRegion(cursor: SystemMouseCursors.click, child: GestureDetector(onTap: onTap, child: box));
  }
}

class _DashPainter extends CustomPainter {
  _DashPainter(this.radius);
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = RestoColors.primary.withValues(alpha: 0.75)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    final path = Path()..addRRect(RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius)));
    for (final metric in path.computeMetrics()) {
      var d = 0.0;
      while (d < metric.length) {
        canvas.drawPath(metric.extractPath(d, d + 6), paint);
        d += 11;
      }
    }
  }

  @override
  bool shouldRepaint(_DashPainter old) => old.radius != radius;
}

/// Grand titre d'écran à empattements, avec la marque en or dessous.
class ScreenTitle extends StatelessWidget {
  const ScreenTitle({super.key, required this.title, this.subtitle, this.trailing});
  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final small = MediaQuery.sizeOf(context).width < 600;
    return Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: serifTitle(context, size: small ? 30 : 40)),
          if (subtitle != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(subtitle!, style: theme.textTheme.bodyMedium?.copyWith(color: RestoColors.muted)),
            ),
        ]),
      ),
      ?trailing,
    ]);
  }
}
