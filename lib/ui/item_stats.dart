import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'common.dart';
import 'theme.dart';

/// Couleur des favoris (cœurs) sur les cartes produit.
const itemHeartColor = Color(0xFFE0457B);

/// Cinq étoiles dorées, la note et le nombre d'avis vérifiés d'un plat
/// (carte produit du module Menus et de la page restaurant côté client).
class ItemRatingLine extends StatelessWidget {
  const ItemRatingLine({super.key, required this.rating, required this.reviews});
  final double? rating;
  final int reviews;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final locale = Localizations.localeOf(context).toString();
    final r = rating;
    final has = r != null && reviews > 0;
    return Row(
      children: [
        for (var i = 0; i < 5; i++)
          Icon(
            !has
                ? Icons.star_outline_rounded
                : (r >= i + 0.75 ? Icons.star_rounded : (r >= i + 0.25 ? Icons.star_half_rounded : Icons.star_outline_rounded)),
            size: 15,
            color: has ? RestoColors.primary : RestoColors.shadowDark,
          ),
        const SizedBox(width: 5),
        Flexible(
          child: Text.rich(
            has
                ? TextSpan(
                    children: [
                      TextSpan(
                        text: NumberFormat('0.0', locale).format(r),
                        style: const TextStyle(color: RestoColors.ink, fontWeight: FontWeight.w800),
                      ),
                      TextSpan(text: ' (${t.reviewsCount(reviews)})'),
                    ],
                  )
                : TextSpan(text: t.noReviewsYet),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: RestoColors.muted, fontSize: 12),
          ),
        ),
      ],
    );
  }
}

/// Petite pastille teintée : icône et valeur (favoris, ventes).
class ItemStatChip extends StatelessWidget {
  const ItemStatChip({super.key, required this.icon, required this.color, required this.value, required this.tooltip});
  final IconData icon;
  final Color color;
  final int value;
  final String tooltip;

  @override
  Widget build(BuildContext context) => Tooltip(
        message: tooltip,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.10), borderRadius: BorderRadius.circular(10)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 13, color: color),
              const SizedBox(width: 4),
              Text(
                NumberFormat.compact(locale: Localizations.localeOf(context).toString()).format(value),
                style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 12),
              ),
            ],
          ),
        ),
      );
}

/// Pastille d'état posée sur la photo (point coloré et libellé).
class ItemStatusBadge extends StatelessWidget {
  const ItemStatusBadge({super.key, required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.94), borderRadius: BorderRadius.circular(10)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 7, height: 7, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 11),
              ),
            ),
          ],
        ),
      );
}

/// Ligne des compteurs d'un plat, façon Facebook : J'aime, cœurs, avis, vues
/// (et ventes des 30 derniers jours si [sold] est donné).
class ItemSocialCounts extends StatelessWidget {
  const ItemSocialCounts({super.key, required this.views, required this.likes, required this.comments, required this.favorites, this.sold});
  final int views;
  final int likes;
  final int comments;
  final int favorites;
  final int? sold;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final f = NumberFormat.compact(locale: Localizations.localeOf(context).toString());
    Widget count(IconData icon, Color color, int n, String tip, {bool bubble = false}) => Tooltip(
          message: tip,
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            bubble
                ? Container(
                    width: 17,
                    height: 17,
                    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                    child: Icon(icon, size: 10, color: Colors.white),
                  )
                : Icon(icon, size: 14, color: color),
            const SizedBox(width: 3),
            Text(f.format(n), style: const TextStyle(color: RestoColors.muted, fontSize: 12, fontWeight: FontWeight.w600)),
          ]),
        );
    return Wrap(spacing: 9, runSpacing: 4, crossAxisAlignment: WrapCrossAlignment.center, children: [
      count(Icons.thumb_up_rounded, RestoColors.primary, likes, t.itemLikesTip(likes), bubble: true),
      count(Icons.favorite_rounded, itemHeartColor, favorites, t.itemFavorites(favorites), bubble: true),
      count(Icons.mode_comment_outlined, RestoColors.muted, comments, t.reviewsCount(comments)),
      count(Icons.visibility_outlined, RestoColors.muted, views, t.adViews(views)),
      if (sold != null) count(Icons.local_fire_department_rounded, RestoColors.primaryDeep, sold!, '${t.itemSold30} · ${t.soldCount(sold!)}'),
    ]);
  }
}

/// Barre d'actions d'un plat côté client, façon Facebook : J'aime, Avis, Cœur.
class ItemActionBar extends StatelessWidget {
  const ItemActionBar({super.key, required this.liked, required this.favorite, required this.onLike, required this.onReview, required this.onHeart});
  final bool liked;
  final bool favorite;
  final VoidCallback onLike;
  final VoidCallback onReview;
  final VoidCallback onHeart;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    Widget action(IconData icon, String label, Color color, VoidCallback onTap, {bool on = false}) => Expanded(
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 7),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(icon, size: 17, color: on ? color : RestoColors.muted),
                  const SizedBox(width: 4),
                  Text(label,
                      style: TextStyle(color: on ? color : RestoColors.muted, fontWeight: FontWeight.w700, fontSize: 12.5)),
                ]),
              ),
            ),
          ),
        );
    return Row(children: [
      action(liked ? Icons.thumb_up_rounded : Icons.thumb_up_outlined, t.feedLike, RestoColors.primaryDeep, onLike, on: liked),
      action(Icons.mode_comment_outlined, t.itemReviewAction, RestoColors.primaryDeep, onReview),
      action(favorite ? Icons.favorite_rounded : Icons.favorite_border_rounded, t.itemHeartAction, itemHeartColor, onHeart, on: favorite),
    ]);
  }
}
