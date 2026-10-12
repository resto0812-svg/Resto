import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'common.dart';
import 'item_stats.dart' show itemHeartColor;
import 'theme.dart';

/// Bordeaux du bouton rond (panier, actions) des cartes plats.
const dishActionColor = Color(0xFF7A1730);

/// Carte d'un plat, la même côté client (carte du restaurant) et côté
/// restaurant (module Menus) : grande photo, état en haut à gauche, prix en
/// haut à droite, nom, étoile avec la note et le nombre d'avis, compteurs
/// (J'aime, cœurs, avis, vues) et bouton rond (panier côté client, actions
/// côté restaurant).
class DishCard extends StatelessWidget {
  const DishCard({
    super.key,
    required this.image,
    required this.name,
    required this.statusLabel,
    required this.statusColor,
    this.price,
    this.rating,
    this.reviews = 0,
    this.likes = 0,
    this.favorites = 0,
    this.comments = 0,
    this.views = 0,
    this.liked = false,
    this.favorite = false,
    this.dimmed = false,
    this.badge,
    this.video = false,
    this.onTap,
    this.onLike,
    this.onHeart,
    this.onComment,
    this.action,
  });

  /// Photo (ou visuel par défaut).
  final Widget image;
  final String name;
  final String statusLabel;
  final Color statusColor;
  final String? price;
  final double? rating;
  final int reviews;
  final int likes;
  final int favorites;
  final int comments;
  final int views;
  final bool liked;
  final bool favorite;

  /// Plat épuisé ou masqué : photo atténuée.
  final bool dimmed;

  /// Mention posée en bas de la photo (ex. : « Best-seller »).
  final String? badge;
  final bool video;
  final VoidCallback? onTap;
  final VoidCallback? onLike;
  final VoidCallback? onHeart;
  final VoidCallback? onComment;

  /// Bouton rond bordeaux en bas à droite.
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    final compact = NumberFormat.compact(locale: locale);
    Widget count(IconData off, IconData on, bool active, Color activeColor, int n, VoidCallback? tap) {
      final child = Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(active ? on : off, size: 18, color: active ? activeColor : const Color(0xFF6E665C)),
        const SizedBox(width: 4),
        Text(compact.format(n), style: const TextStyle(color: Color(0xFF6E665C), fontSize: 13, fontWeight: FontWeight.w500)),
      ]);
      if (tap == null) return child;
      return InkWell(
        onTap: tap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2), child: child),
      );
    }

    final hasRating = rating != null && reviews > 0;
    return Material(
      color: const Color(0xFFFFFCF7),
      borderRadius: BorderRadius.circular(16),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: const Color(0xFF5A3E1B).withValues(alpha: 0.10), blurRadius: 16, offset: const Offset(0, 6))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: AspectRatio(
                  aspectRatio: 1.45,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Opacity(opacity: dimmed ? 0.45 : 1, child: image),
                      if (video) const Center(child: Icon(Icons.play_circle_fill_rounded, color: Colors.white70, size: 38)),
                      PositionedDirectional(
                        start: 10,
                        top: 10,
                        end: price == null ? 10 : 96,
                        child: Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                            child: Row(mainAxisSize: MainAxisSize.min, children: [
                              Container(width: 8, height: 8, decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle)),
                              const SizedBox(width: 5),
                              Flexible(
                                child: Text(statusLabel,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.w600)),
                              ),
                            ]),
                          ),
                        ),
                      ),
                      if (price != null)
                        PositionedDirectional(
                          end: 10,
                          top: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
                            decoration: BoxDecoration(color: const Color(0xFFC9A04A), borderRadius: BorderRadius.circular(14)),
                            child: Text(price!,
                                style: const TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w700)),
                          ),
                        ),
                      if (badge != null)
                        PositionedDirectional(
                          start: 10,
                          bottom: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                            decoration: BoxDecoration(gradient: RestoColors.brandGradient, borderRadius: BorderRadius.circular(12)),
                            child: Row(mainAxisSize: MainAxisSize.min, children: [
                              const Icon(Icons.workspace_premium_rounded, size: 13, color: Colors.white),
                              const SizedBox(width: 4),
                              Text(badge!, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800)),
                            ]),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(14, 12, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15.5, color: RestoColors.ink)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(children: [
                                Icon(hasRating ? Icons.star_rounded : Icons.star_outline_rounded, size: 18, color: const Color(0xFFC9A04A)),
                                const SizedBox(width: 4),
                                if (hasRating) ...[
                                  Text(NumberFormat('0.0', locale).format(rating),
                                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5, color: RestoColors.ink)),
                                  const SizedBox(width: 5),
                                  Text('($reviews)', style: const TextStyle(color: RestoColors.muted, fontSize: 13)),
                                ] else
                                  Flexible(
                                    child: Text(context.t.noReviewsYet,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(color: RestoColors.muted, fontSize: 12.5)),
                                  ),
                              ]),
                              const SizedBox(height: 8),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: AlignmentDirectional.centerStart,
                                child: Row(children: [
                                  count(Icons.thumb_up_outlined, Icons.thumb_up_rounded, liked, RestoColors.primaryDeep, likes, onLike),
                                  const SizedBox(width: 12),
                                  count(Icons.favorite_border_rounded, Icons.favorite_rounded, favorite, itemHeartColor, favorites, onHeart),
                                  const SizedBox(width: 12),
                                  count(Icons.chat_bubble_outline_rounded, Icons.chat_bubble_outline_rounded, false, RestoColors.primaryDeep,
                                      comments, onComment),
                                  const SizedBox(width: 12),
                                  count(Icons.visibility_outlined, Icons.visibility_outlined, false, RestoColors.primaryDeep, views, null),
                                ]),
                              ),
                            ],
                          ),
                        ),
                        if (action != null) ...[const SizedBox(width: 8), action!],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Bouton rond bordeaux des cartes plats (panier, actions).
class DishRoundButton extends StatelessWidget {
  const DishRoundButton({super.key, required this.icon, required this.tooltip, this.onPressed});
  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => Tooltip(
        message: tooltip,
        child: Material(
          color: onPressed == null ? const Color(0xFFB9AFA4) : dishActionColor,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onPressed,
            child: SizedBox(width: 44, height: 44, child: Icon(icon, color: Colors.white, size: 21)),
          ),
        ),
      );
}
