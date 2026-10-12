import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../app_state.dart';
import '../../core/money.dart';
import '../../data/customer_api.dart';
import '../../ui/common.dart';
import '../../ui/dish_card.dart';
import '../../ui/files.dart';
import '../../ui/item_stats.dart';
import '../../ui/kit.dart';
import '../../ui/theme.dart';
import '../menus/menu_widgets.dart' show allergenLabel, uuidV4;
import 'customer_account.dart';
import 'customer_home.dart';
import 'customer_shell.dart';
import 'feed_page.dart' show FeedCommentsSheet;
import 'group_order.dart';
import 'loyalty_pages.dart';
import 'reservation_sheet.dart';
import 'reviews.dart';
import 'tables_tab.dart';

String _money(BuildContext context, int minor, String currency) =>
    Money(minor, currency).format(Localizations.localeOf(context).toString(), minorUnitOf(currency));

String _locale(BuildContext context) => Localizations.localeOf(context).languageCode;

// ---------------------------------------------------------------------------
// Page d'un restaurant (maquette « DELICES ») : bandeau photo, onglets Menu /
// Avis / Infos, catégories, filtres (piment, mentions alimentaires), grille de
// plats, barre du panier.

class RestaurantPage extends StatefulWidget {
  const RestaurantPage({super.key, required this.branchId, this.openItemId});
  final String branchId;
  final String? openItemId;

  @override
  State<RestaurantPage> createState() => _RestaurantPageState();
}

class _RestaurantPageState extends State<RestaurantPage> {
  late final Future<PublicMenu> _menu = _load();
  String? _category;
  bool _opened = false;
  Map<String, ItemRating> _ratings = const {};

  /// Réactions des plats (J'aime, cœurs, avis, vues), façon Facebook.
  Map<String, ItemSocial> _social = {};
  int _tab = 0;

  /// Étiquettes choisies comme filtres (un plat doit les avoir toutes).
  final Set<String> _tags = {};
  bool? _favorite;

  Future<PublicMenu> _load() async {
    final api = AppScope.read(context).api!.customer;
    api
        .itemRatings(widget.branchId)
        .then((r) {
          if (mounted) setState(() => _ratings = r);
        })
        .catchError((_) {});
    api
        .favorites()
        .then((f) {
          if (mounted) setState(() => _favorite = f.contains(widget.branchId));
        })
        .catchError((_) {});
    final m = await api.menu(widget.branchId);
    // Les plats affichés comptent une vue ; les compteurs sont relus ensuite.
    api.recordItemViews([for (final c in m.categories) for (final i in c.items) i.id]).whenComplete(_loadSocial);
    if (widget.openItemId != null && !_opened) {
      _opened = true;
      final item = m.categories.expand((c) => c.items).where((i) => i.id == widget.openItemId).firstOrNull;
      if (item != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _openItem(m, item);
        });
      }
    }
    return m;
  }

  void _openItem(PublicMenu m, PublicItem item) {
    final scope = CustomerScope.of(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CustomerScope(
          cart: scope.notifier!,
          openTab: scope.openTab,
          child: ProductPage(menu: m, item: item, rating: _ratings[item.id]),
        ),
      ),
    );
  }

  Future<void> _loadSocial() async {
    final s = await AppScope.read(context).api!.customer.itemSocial(widget.branchId);
    if (mounted) setState(() => _social = s);
  }

  ItemSocial _socialOf(String itemId) => _social.putIfAbsent(itemId, ItemSocial.new);

  Future<void> _likeItem(PublicItem item) async {
    if (!await ensureCustomerSignedIn(context) || !mounted) return;
    final s = _socialOf(item.id);
    final before = (s.liked, s.likes);
    setState(() {
      s.liked = !s.liked;
      s.likes += s.liked ? 1 : -1;
    });
    try {
      final (liked, likes) = await AppScope.read(context).api!.customer.toggleItemLike(item.id);
      if (mounted) {
        setState(() {
          s.liked = liked;
          s.likes = likes;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        s.liked = before.$1;
        s.likes = before.$2;
      });
      showError(context, e);
    }
  }

  Future<void> _heartItem(PublicItem item) async {
    if (!await ensureCustomerSignedIn(context) || !mounted) return;
    final s = _socialOf(item.id);
    final on = !s.favorite;
    setState(() {
      s.favorite = on;
      s.favorites += on ? 1 : -1;
    });
    try {
      await AppScope.read(context).api!.customer.setItemFavorite(item.id, on);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        s.favorite = !on;
        s.favorites += on ? -1 : 1;
      });
      showError(context, e);
    }
  }

  /// Avis des clients sur un plat : avis libres (tout client connecté) et,
  /// en tête, accès aux avis notés après commande.
  Future<void> _reviewItem(PublicMenu m, PublicItem item) async {
    final t = context.t;
    final api = AppScope.read(context).api!.customer;
    final rating = _ratings[item.id];
    final count = rating?.count ?? item.reviewsCount;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheet) => FeedCommentsSheet(
        title: '${t.itemCommentsTitle} · ${tr(item.translations, _locale(context), item.name)}',
        load: () => api.itemComments(item.id),
        send: (body) => api.addItemComment(item.id, body),
        onCount: (n) {
          if (mounted) setState(() => _socialOf(item.id).comments = n);
        },
        header: count == 0
            ? null
            : ListTile(
                leading: const Icon(Icons.verified_rounded, color: RestoColors.primary),
                title: ItemRatingLine(rating: rating?.average ?? item.rating, reviews: count),
                subtitle: Text(t.itemVerifiedReviews),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => Navigator.push(sheet, MaterialPageRoute(builder: (_) => ItemReviewsPage(item: item, rating: rating))),
              ),
      ),
    );
  }

  /// « Commander » : un plat simple part directement au panier ; un plat à
  /// tailles ou options obligatoires ouvre sa fiche.
  Future<void> _orderItem(PublicMenu m, PublicItem item) async {
    final t = context.t;
    final cart = CustomerScope.cart(context);
    final variants = item.variants.where((v) => v.priceFor(cart.channelFor(m.branchId)) != null).toList();
    if (variants.length != 1 || item.groups.any((g) => g.minSelect > 0)) {
      _openItem(m, item);
      return;
    }
    final line = CartLine(item: item, variant: variants.first, modifiers: const [], quantity: 1);
    if (cart.groupToken != null) {
      try {
        await AppScope.read(context).api!.customer.addGroupLines(cart.groupToken!, [line]);
        if (mounted) showInfo(context, t.addedToGroup);
      } catch (e) {
        if (mounted) showError(context, e);
      }
      return;
    }
    cart.add(m, line);
    showInfo(context, t.addedToCart);
  }

  Future<void> _toggleFavorite() async {
    if (!await ensureCustomerSignedIn(context) || !mounted) return;
    final on = !(_favorite ?? false);
    setState(() => _favorite = on);
    try {
      await AppScope.read(context).api!.customer.setFavorite(widget.branchId, on);
    } catch (e) {
      if (mounted) {
        setState(() => _favorite = !on);
        showError(context, e);
      }
    }
  }

  bool _matches(PublicItem i) => _tags.every((tag) => i.tags.contains(tag));

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final cart = CustomerScope.cart(context);
    return Scaffold(
      backgroundColor: RestoColors.base,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: ListenableBuilder(
        listenable: cart,
        builder: (context, _) => cart.isEmpty || cart.groupToken != null
            ? const SizedBox.shrink()
            : CartBar(cart: cart),
      ),
      body: FutureBuilder<PublicMenu>(
        future: _menu,
        builder: (context, snap) {
          if (snap.hasError) return Center(child: Text(t.restaurantUnavailable));
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final m = snap.data!;
          final wide = MediaQuery.sizeOf(context).width >= 900;
          final side = wide ? 32.0 : 16.0;
          final content = switch (_tab) {
            1 => TablesTab(branchId: m.branchId, restaurantName: m.brandName),
            2 => _ReviewsTab(menu: m),
            3 => _InfosTab(menu: m),
            _ => _menuTab(context, m, side),
          };
          // Bandeau et feuille dans un même bloc : la feuille (et ses onglets) passe par-dessus la photo.
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _Hero(menu: m, favorite: _favorite, onFavorite: _toggleFavorite),
                    Transform.translate(
                      offset: const Offset(0, -26),
                      child: Container(
                        decoration: const BoxDecoration(
                          color: RestoColors.base,
                          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
                        ),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 1200),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _FolderTabs(
                                  labels: [t.menuTab, t.tablesTab, t.reviewsTab, t.infosTab],
                                  selected: _tab,
                                  onSelected: (i) => setState(() => _tab = i),
                                ),
                                content,
                                const SizedBox(height: 120),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _menuTab(BuildContext context, PublicMenu m, double side) {
    final t = context.t;
    final locale = _locale(context);
    final cart = CustomerScope.cart(context);
    final categories = m.categories.where((c) => c.items.isNotEmpty).toList();
    final all = categories.expand((c) => c.items).toList();
    // Étiquettes du restaurant, les plus utilisées d'abord.
    final counts = <String, int>{};
    for (final i in all) {
      for (final tag in i.tags) {
        counts[tag] = (counts[tag] ?? 0) + 1;
      }
    }
    final tags = counts.keys.toList()..sort((x, y) => counts[y]!.compareTo(counts[x]!));
    final items = (_category == null ? all : categories.where((c) => c.id == _category).expand((c) => c.items)).where(_matches).toList();
    Widget label(String text) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(color: RestoColors.muted, fontSize: 11.5, fontWeight: FontWeight.w700, letterSpacing: 1.4),
      ),
    );
    return Padding(
      padding: EdgeInsets.fromLTRB(side, 14, side, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (m.vacationMode || !m.acceptsOnlineOrders) ...[
            SoftCard(
              color: RestoColors.primarySoft,
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, color: RestoColors.primaryDeep),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      m.vacationMode ? (m.branch['vacation_message'] as String? ?? t.restaurantOnVacation) : t.onlineOrdersUnavailable,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
          if (cart.tableToken != null && cart.tableLabel != null) ...[
            StatusPill(label: t.orderingAtTable(cart.tableLabel!), color: RestoColors.primaryDeep, icon: Icons.table_restaurant_rounded),
            const SizedBox(height: 12),
          ],
          label(t.categoriesLabel),
          SizedBox(
            height: 42,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _Chip(label: t.allItems, count: all.length, selected: _category == null, onTap: () => setState(() => _category = null)),
                for (final c in categories)
                  _Chip(
                    label: tr(c.translations, locale, c.name),
                    count: c.items.length,
                    selected: _category == c.id,
                    onTap: () => setState(() => _category = _category == c.id ? null : c.id),
                  ),
              ],
            ),
          ),
          if (tags.isNotEmpty) ...[
            const SizedBox(height: 12),
            label(t.filtersLabel),
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  for (final tag in tags)
                    _Chip(
                      label: tag,
                      icon: _tags.contains(tag) ? Icons.check_circle_rounded : null,
                      selected: _tags.contains(tag),
                      dense: true,
                      onTap: () => setState(() => _tags.contains(tag) ? _tags.remove(tag) : _tags.add(tag)),
                    ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          if (items.isEmpty)
            EmptyState(icon: Icons.filter_alt_off_outlined, title: t.noDishMatches)
          else
            LayoutBuilder(
              builder: (context, box) {
                final cols = box.maxWidth >= 1000 ? 4 : (box.maxWidth >= 620 ? 3 : 2);
                final w = (box.maxWidth - (cols - 1) * 14) / cols;
                return Wrap(
                  spacing: 14,
                  runSpacing: 14,
                  children: [
                    for (final i in items)
                      SizedBox(
                        width: w,
                        child: _DishCard(
                          menu: m,
                          item: i,
                          rating: _ratings[i.id],
                          social: _social[i.id] ?? ItemSocial(),
                          onTap: () => _openItem(m, i),
                          onLike: () => _likeItem(i),
                          onReview: () => _reviewItem(m, i),
                          onHeart: () => _heartItem(i),
                          onOrder: () => _orderItem(m, i),
                        ),
                      ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }
}

/// Bandeau : photo d'ambiance, marque en lettres d'or, nom, note, avis, distance.
class _Hero extends StatelessWidget {
  const _Hero({required this.menu, required this.favorite, required this.onFavorite});
  final PublicMenu menu;
  final bool? favorite;
  final VoidCallback onFavorite;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final api = AppScope.read(context).api!.customer;
    final m = menu;
    final firstDish = m.categories.expand((c) => c.items).where((i) => i.imagePath != null).firstOrNull?.imagePath;
    final cover = m.coverPath ?? firstDish;
    final pos = customerPosition.value;
    final km = pos == null || m.latitude == null ? null : distanceKm(pos.$1, pos.$2, m.latitude!, m.longitude!);
    final top = MediaQuery.paddingOf(context).top;
    return SizedBox(
      height: 300 + top,
      child: Stack(
        fit: StackFit.expand,
        children: [
          NetImage(cover == null ? null : api.imageUrl(cover), icon: Icons.storefront_rounded),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0x66000000), Color(0x33000000), Color(0xCC1A120A)],
              ),
            ),
          ),
          Positioned(
            left: 10,
            right: 10,
            top: top + 6,
            child: Row(
              children: [
                _RoundButton(icon: Icons.arrow_back_rounded, onTap: () => Navigator.pop(context)),
                const Spacer(),
                _RoundButton(
                  icon: favorite == true ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  color: favorite == true ? RestoColors.primaryBright : Colors.white,
                  onTap: onFavorite,
                ),
              ],
            ),
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: 46,
            child: Column(
              children: [
                if (m.logoPath != null)
                  Container(
                    width: 64,
                    height: 64,
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: RestoColors.primaryBright, width: 2),
                    ),
                    child: ClipOval(child: NetImage(api.logoUrl(m.logoPath!), fit: BoxFit.contain)),
                  ),
                Text(
                  m.brandName.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: serifTitle(context, size: 30, color: RestoColors.primaryBright).copyWith(letterSpacing: 4),
                ),
                Container(
                  width: 70,
                  height: 1.4,
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  color: RestoColors.primaryBright.withValues(alpha: 0.7),
                ),
                if (m.branchName.isNotEmpty && m.branchName.toLowerCase() != m.brandName.toLowerCase())
                  Text(
                    m.branchName,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      shadows: [Shadow(blurRadius: 10)],
                    ),
                  ),
                const SizedBox(height: 8),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    if (m.rating != null) ...[
                      const Icon(Icons.star_rounded, color: RestoColors.primaryBright, size: 18),
                      Text(
                        '${m.rating}',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
                      ),
                      const Text('·', style: TextStyle(color: Colors.white70)),
                      Text(t.reviewsCount(m.reviewsCount), style: const TextStyle(color: Colors.white)),
                    ] else
                      Text(t.newRestaurant, style: const TextStyle(color: Colors.white)),
                    if (km != null) ...[
                      const Text('·', style: TextStyle(color: Colors.white70)),
                      const Icon(Icons.location_on_rounded, color: RestoColors.primaryBright, size: 16),
                      Text(distanceText(km), style: const TextStyle(color: Colors.white)),
                    ],
                    const Text('·', style: TextStyle(color: Colors.white70)),
                    Text(
                      m.openNow ? t.openNow : t.closedNow,
                      style: TextStyle(color: m.openNow ? const Color(0xFF7BE0A1) : Colors.white70, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({required this.icon, required this.onTap, this.color = Colors.white});
  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.black.withValues(alpha: 0.32),
    shape: const CircleBorder(),
    child: IconButton(
      onPressed: onTap,
      icon: Icon(icon, color: color),
    ),
  );
}

/// Onglets « dossier » : l'onglet choisi se fond dans la feuille ivoire.
class _FolderTabs extends StatelessWidget {
  const _FolderTabs({required this.labels, required this.selected, required this.onSelected});
  final List<String> labels;
  final int selected;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      for (var i = 0; i < labels.length; i++)
        Expanded(
          child: GestureDetector(
            onTap: () => onSelected(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              height: 54,
              decoration: BoxDecoration(
                color: i == selected ? RestoColors.base : RestoColors.band,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(i == 0 ? 26 : 16),
                  topRight: Radius.circular(i == labels.length - 1 ? 26 : 16),
                ),
              ),
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    labels[i],
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: i == selected ? FontWeight.w800 : FontWeight.w600,
                      color: i == selected ? RestoColors.primaryDeep : RestoColors.muted,
                    ),
                  ),
                  const SizedBox(height: 4),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: i == selected ? 70 : 0,
                    height: 2.5,
                    decoration: BoxDecoration(color: RestoColors.primary, borderRadius: BorderRadius.circular(2)),
                  ),
                ],
              ),
            ),
          ),
        ),
    ],
  );
}

/// Pastille (catégorie ou filtre) : or quand elle est choisie.
class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.selected, required this.onTap, this.count, this.icon, this.dense = false});
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final int? count;
  final IconData? icon;
  final bool dense;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsetsDirectional.only(end: 8),
    child: GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: EdgeInsets.symmetric(horizontal: dense ? 12 : 16),
        decoration: BoxDecoration(
          gradient: selected ? RestoColors.brandGradient : null,
          color: selected ? null : RestoColors.sunken,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: selected ? Colors.transparent : RestoColors.primary.withValues(alpha: 0.35)),
          boxShadow: selected ? RestoColors.softShadow(6) : null,
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[Icon(icon, size: 16, color: selected ? Colors.white : RestoColors.primaryDeep), const SizedBox(width: 5)],
            Text(
              count == null ? label : '$label $count',
              style: TextStyle(fontSize: dense ? 13 : 14, fontWeight: FontWeight.w600, color: selected ? Colors.white : RestoColors.ink),
            ),
          ],
        ),
      ),
    ),
  );
}

/// Carte d'un plat (modèle commun avec le module Menus) : photo, état, prix,
/// note, compteurs touchables (J'aime, cœur, avis) et panier.
class _DishCard extends StatelessWidget {
  const _DishCard({
    required this.menu,
    required this.item,
    required this.social,
    required this.onTap,
    required this.onLike,
    required this.onReview,
    required this.onHeart,
    required this.onOrder,
    this.rating,
  });
  final PublicMenu menu;
  final PublicItem item;
  final ItemSocial social;
  final VoidCallback onTap;
  final VoidCallback onLike;
  final VoidCallback onReview;
  final VoidCallback onHeart;
  final VoidCallback onOrder;
  final ItemRating? rating;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final api = AppScope.read(context).api!.customer;
    final cart = CustomerScope.cart(context);
    final price = item.fromPrice(cart.channelFor(menu.branchId));
    final canOrder = menu.acceptsOnlineOrders || cart.tableToken != null;
    return DishCard(
      image: NetImage(item.imagePath == null ? null : api.imageUrl(item.imagePath!)),
      name: tr(item.translations, _locale(context), item.name),
      statusLabel: item.soldOut ? t.soldOut : t.available,
      statusColor: item.soldOut ? const Color(0xFFD9363E) : const Color(0xFF2E9E5B),
      price: price == null ? null : _money(context, price, menu.currency),
      rating: rating?.average ?? item.rating,
      reviews: rating?.count ?? item.reviewsCount,
      likes: social.likes,
      favorites: social.favorites,
      comments: social.comments,
      views: social.views,
      liked: social.liked,
      favorite: social.favorite,
      dimmed: item.soldOut,
      badge: item.bestSeller ? t.bestSeller : null,
      onTap: item.soldOut ? null : onTap,
      onLike: onLike,
      onHeart: onHeart,
      onComment: onReview,
      action: canOrder
          ? DishRoundButton(icon: Icons.shopping_cart_outlined, tooltip: t.feedOrder, onPressed: item.soldOut ? null : onOrder)
          : null,
    );
  }
}
/// Onglet Avis : note du restaurant et derniers avis.
class _ReviewsTab extends StatelessWidget {
  const _ReviewsTab({required this.menu});
  final PublicMenu menu;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final locale = Localizations.localeOf(context).toString();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: FutureBuilder(
        future: AppScope.read(context).api!.customer.reviews(menu.branchId),
        builder: (context, snap) {
          final list = snap.data ?? const <(int, String?, String, DateTime)>[];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SoftCard(
                child: Row(
                  children: [
                    Text(menu.rating?.toString() ?? '—', style: serifTitle(context, size: 46)),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          StarRow(rating: menu.rating ?? 0, size: 22),
                          const SizedBox(height: 4),
                          Text(t.reviewsCount(menu.reviewsCount), style: const TextStyle(color: RestoColors.muted)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              if (!snap.hasData)
                const Padding(
                  padding: EdgeInsets.all(30),
                  child: Center(child: CircularProgressIndicator()),
                ),
              if (snap.hasData && list.isEmpty) EmptyState(icon: Icons.rate_review_outlined, title: t.noReviewsYet),
              for (final (rating, comment, author, date) in list)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: SoftCard(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: RestoColors.primarySoft,
                              child: Text(
                                author.isEmpty ? '?' : author.characters.first.toUpperCase(),
                                style: const TextStyle(color: RestoColors.primaryDeep, fontWeight: FontWeight.w700),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(author, style: const TextStyle(fontWeight: FontWeight.w700)),
                            ),
                            Text(
                              DateFormat.yMMMd(locale).format(date.toLocal()),
                              style: const TextStyle(color: RestoColors.muted, fontSize: 12),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        StarRow(rating: rating.toDouble()),
                        if (comment != null && comment.trim().isNotEmpty) ...[const SizedBox(height: 6), Text(comment)],
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

/// Onglet Infos : horaires, adresse, contact, livraison, réservation, commande groupée.
class _InfosTab extends StatelessWidget {
  const _InfosTab({required this.menu});
  final PublicMenu menu;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final m = menu;
    final cart = CustomerScope.cart(context);
    final locale = Localizations.localeOf(context).toString();
    final days = DateFormat.EEEE(locale).dateSymbols.STANDALONEWEEKDAYS;
    String dayName(int weekday) {
      final s = days[weekday % 7];
      return s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
    }

    Widget row(IconData icon, String text, {VoidCallback? onTap, String? action}) => ListTile(
      contentPadding: EdgeInsets.zero,
      leading: GoldIcon(icon, size: 40),
      title: Text(text),
      trailing: action == null ? null : TextButton(onPressed: onTap, child: Text(action)),
      onTap: onTap,
    );
    final address = [?m.address, m.city].where((s) => s.isNotEmpty).join(', ');
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if ((m.slogan ?? m.brandDescription) != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(m.brandDescription ?? m.slogan!, style: const TextStyle(height: 1.45)),
            ),
          if (m.cuisines.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [for (final c in m.cuisines) StatusPill(label: c, color: RestoColors.primaryDeep, dense: true)],
              ),
            ),
          SoftCard(
            padding: const EdgeInsets.fromLTRB(14, 6, 14, 6),
            child: Column(
              children: [
                if (address.isNotEmpty)
                  row(
                    Icons.location_on_outlined,
                    address,
                    action: m.latitude != null ? t.directions : null,
                    onTap: m.latitude == null
                        ? null
                        : () => openLink('https://www.google.com/maps/dir/?api=1&destination=${m.latitude},${m.longitude}'),
                  ),
                if (m.phone != null) row(Icons.call_outlined, m.phone!, action: t.callAction, onTap: () => openLink('tel:${m.phone}')),
                if (m.whatsapp != null)
                  row(
                    Icons.chat_outlined,
                    'WhatsApp',
                    action: t.writeAction,
                    onTap: () => openLink('https://wa.me/${m.whatsapp!.replaceAll(RegExp(r'[^0-9]'), '')}'),
                  ),
                if (m.prepMinutes != null) row(Icons.schedule_rounded, t.minutesRange(m.prepMinutes!, m.prepMinutes! + 15)),
                if (m.acceptsDelivery)
                  row(
                    Icons.delivery_dining_rounded,
                    [t.deliveryFee, _money(context, m.deliveryFeeMinor, m.currency), ?m.deliveryZone].join(' · '),
                  ),
                if (m.minOrderMinor > 0) row(Icons.shopping_bag_outlined, t.fromAmount(_money(context, m.minOrderMinor, m.currency))),
              ],
            ),
          ),
          if (m.hours.isNotEmpty) ...[
            const SizedBox(height: 14),
            SoftCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SectionHeading(title: t.openingHours, icon: Icons.access_time_rounded),
                  const SizedBox(height: 8),
                  for (final d in {for (final h in m.hours) h.$1})
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              dayName(d),
                              style: TextStyle(fontWeight: d == DateTime.now().weekday ? FontWeight.w800 : FontWeight.w500),
                            ),
                          ),
                          Text(m.hours.where((h) => h.$1 == d).map((h) => '${h.$2} – ${h.$3}').join('  ·  ')),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              if (m.acceptsReservations)
                GoldButton(
                  label: t.reserveTable,
                  icon: Icons.event_seat_outlined,
                  expand: false,
                  onPressed: () => requestTableReservation(context, branchId: m.branchId, restaurantName: m.brandName).then((_) {}),
                ),
              if (m.acceptsOnlineOrders && cart.tableToken == null && cart.groupToken == null)
                GoldButton(
                  label: t.groupOrderAction,
                  icon: Icons.groups_2_outlined,
                  outlined: true,
                  expand: false,
                  onPressed: () => startGroupOrder(context, m.branchId),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Détails du produit

class ProductPage extends StatefulWidget {
  const ProductPage({super.key, required this.menu, required this.item, this.rating});
  final PublicMenu menu;
  final PublicItem item;

  /// Note du plat (avis vérifiés), si elle existe.
  final ItemRating? rating;

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  late PublicVariant _variant = widget.item.variants.first;
  final Map<String, Set<String>> _chosen = {};
  int _quantity = 1;
  final _note = TextEditingController();
  int _photo = 0;
  String _sort = 'helpful';
  late Future<List<ItemReview>> _reviews = _loadReviews();

  Future<List<ItemReview>> _loadReviews() =>
      AppScope.read(context).api!.customer.itemReviews(widget.item.id, sort: _sort, limit: 3).catchError((_) => <ItemReview>[]);

  PublicItem get item => widget.item;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  String get _channel => CustomerScope.cart(context).channelFor(widget.menu.branchId);

  List<PublicModifier> get _modifiers => [
    for (final g in item.groups)
      for (final m in g.modifiers)
        if (_chosen[g.id]?.contains(m.id) ?? false) m,
  ];

  int get _unit => (_variant.priceFor(_channel) ?? 0) + _modifiers.fold(0, (a, m) => a + m.priceFor(_channel));

  void _toggle(PublicGroup g, PublicModifier m) {
    final set = _chosen.putIfAbsent(g.id, () => {});
    setState(() {
      if (g.maxSelect == 1) {
        set
          ..clear()
          ..add(m.id);
      } else if (set.contains(m.id)) {
        set.remove(m.id);
      } else if (g.maxSelect == null || set.length < g.maxSelect!) {
        set.add(m.id);
      }
    });
  }

  Future<void> _add() async {
    final t = context.t;
    for (final g in item.groups) {
      if ((_chosen[g.id]?.length ?? 0) < g.minSelect) {
        showInfo(context, t.chooseOptionRequired(tr(g.translations, _locale(context), g.name)));
        return;
      }
    }
    final cart = CustomerScope.cart(context);
    final line = CartLine(
      item: item,
      variant: _variant,
      modifiers: _modifiers,
      quantity: _quantity,
      note: _note.text.trim().isEmpty ? null : _note.text.trim(),
    );
    // Commande groupée : le plat rejoint la commande partagée.
    if (cart.groupToken != null) {
      try {
        await AppScope.read(context).api!.customer.addGroupLines(cart.groupToken!, [line]);
        if (!mounted) return;
        showInfo(context, t.addedToGroup);
        Navigator.pop(context);
      } catch (e) {
        if (mounted) showError(context, e);
      }
      return;
    }
    cart.add(widget.menu, line);
    showInfo(context, t.addedToCart);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final api = AppScope.read(context).api!.customer;
    final locale = _locale(context);
    final photos = item.photos;
    final currency = widget.menu.currency;
    final canOrder = widget.menu.acceptsOnlineOrders || CustomerScope.cart(context).tableToken != null;
    final wide = MediaQuery.sizeOf(context).width >= 900;
    final content = ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 130),
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: AspectRatio(
            aspectRatio: 4 / 3,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (photos.isEmpty)
                  const NetImage(null)
                else
                  PageView(onPageChanged: (i) => setState(() => _photo = i), children: [for (final p in photos) NetImage(api.imageUrl(p))]),
                if (item.videoPath != null)
                  Positioned(
                    right: 10,
                    bottom: 10,
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(backgroundColor: Colors.black54, foregroundColor: Colors.white),
                      onPressed: () => openLink(api.videoUrl(item.videoPath!)),
                      icon: const Icon(Icons.play_arrow_rounded),
                      label: Text(t.watchVideo),
                    ),
                  ),
                if (photos.length > 1)
                  Positioned(
                    bottom: 10,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (var i = 0; i < photos.length; i++)
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            width: i == _photo ? 16 : 7,
                            height: 7,
                            decoration: BoxDecoration(
                              color: i == _photo ? Colors.white : Colors.white54,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: Text(tr(item.translations, locale, item.name), style: serifTitle(context, size: 28))),
            const SizedBox(width: 10),
            Text(
              _money(context, _variant.priceFor(_channel) ?? 0, currency),
              style: const TextStyle(color: RestoColors.primaryDeep, fontWeight: FontWeight.w800, fontSize: 20),
            ),
          ],
        ),
        if (widget.rating != null)
          InkWell(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ItemReviewsPage(item: item, rating: widget.rating),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Wrap(
                spacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  StarRow(rating: widget.rating!.average, size: 18),
                  Text(
                    '${widget.rating!.average}/5 · ${t.reviewsCount(widget.rating!.count)}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  StatusPill(label: t.satisfiedPercent(widget.rating!.satisfied), color: const Color(0xFF2E9E5B), dense: true),
                ],
              ),
            ),
          ),
        if ((item.description ?? '').isNotEmpty) ...[
          const SizedBox(height: 12),
          SoftCard(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: RestoColors.primarySoft, borderRadius: BorderRadius.circular(6)),
                  child: Text(
                    t.storyLabel,
                    style: const TextStyle(color: RestoColors.primaryDeep, fontSize: 11, fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(height: 6),
                Text(tr(item.translations, locale, item.description!, 'description'), style: const TextStyle(height: 1.4)),
              ],
            ),
          ),
        ],
        if (item.variants.length > 1) ...[
          const SizedBox(height: 18),
          Text(t.sizesLabel, style: serifTitle(context, size: 22)),
          const SizedBox(height: 8),
          Row(
            children: [
              for (final v in item.variants)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: GestureDetector(
                      onTap: () => setState(() => _variant = v),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 160),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          gradient: v.id == _variant.id ? RestoColors.brandGradient : null,
                          color: v.id == _variant.id ? null : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: RestoColors.primary.withValues(alpha: v.id == _variant.id ? 0 : 0.5)),
                        ),
                        child: Column(
                          children: [
                            Text(
                              tr(v.translations, locale, v.name),
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                                color: v.id == _variant.id ? Colors.white : RestoColors.ink,
                              ),
                            ),
                            Text(
                              _money(context, v.priceFor(_channel) ?? 0, currency),
                              style: TextStyle(fontSize: 12, color: v.id == _variant.id ? Colors.white : RestoColors.muted),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
        for (final g in item.groups) ...[
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(child: Text(tr(g.translations, locale, g.name), style: serifTitle(context, size: 22))),
              if (g.minSelect > 0) StatusPill(label: t.requiredLabel, color: RestoColors.primaryDeep, dense: true),
            ],
          ),
          const SizedBox(height: 4),
          for (final m in g.modifiers)
            Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: RestoColors.line),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(tr(m.translations, locale, m.name), style: const TextStyle(fontWeight: FontWeight.w500)),
                  ),
                  if (m.priceFor(_channel) > 0)
                    Text(
                      '+ ${_money(context, m.priceFor(_channel), currency)}',
                      style: const TextStyle(color: RestoColors.primaryDeep, fontWeight: FontWeight.w600),
                    ),
                  Switch(
                    value: _chosen[g.id]?.contains(m.id) ?? false,
                    activeTrackColor: RestoColors.primary,
                    onChanged: (_) => _toggle(g, m),
                  ),
                ],
              ),
            ),
        ],
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(child: Text(t.quantity, style: serifTitle(context, size: 22))),
            Container(
              decoration: BoxDecoration(gradient: RestoColors.brandGradient, borderRadius: BorderRadius.circular(24)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
                    icon: const Icon(Icons.remove_rounded, color: Colors.white),
                  ),
                  Text(
                    '$_quantity',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 17),
                  ),
                  IconButton(
                    onPressed: _quantity < 50 ? () => setState(() => _quantity++) : null,
                    icon: const Icon(Icons.add_rounded, color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            for (final a in item.allergens)
              Chip(avatar: const Icon(Icons.warning_amber_rounded, size: 16), label: Text(allergenLabel(t, a))),
            if ((item.prepMinutes ?? widget.menu.prepMinutes) != null)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.schedule_rounded, size: 16, color: RestoColors.primaryDeep),
                  Text(
                    ' ${t.prepMinutesShort(item.prepMinutes ?? widget.menu.prepMinutes!)}',
                    style: const TextStyle(color: RestoColors.muted),
                  ),
                ],
              ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _note,
          maxLength: 200,
          decoration: InputDecoration(labelText: t.noteForKitchen, hintText: t.noteForKitchenHint),
        ),
        FutureBuilder<List<ItemReview>>(
          future: _reviews,
          builder: (context, snap) {
            final reviews = snap.data ?? const <ItemReview>[];
            if (reviews.isEmpty && widget.rating == null) return const SizedBox.shrink();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(child: Text(t.customerReviews(widget.rating?.count ?? reviews.length), style: serifTitle(context, size: 22))),
                    TextButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ItemReviewsPage(item: item, rating: widget.rating),
                        ),
                      ),
                      child: Text(t.seeAll),
                    ),
                  ],
                ),
                PillBar<String>(
                  dense: true,
                  items: [PillItem('helpful', t.sortHelpful), PillItem('recent', t.sortRecent), PillItem('best', t.sortBestRated)],
                  selected: _sort,
                  onSelected: (v) => setState(() {
                    _sort = v;
                    _reviews = _loadReviews();
                  }),
                ),
                const SizedBox(height: 8),
                for (final r in reviews)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: ReviewTile(review: r),
                  ),
              ],
            );
          },
        ),
      ],
    );
    return Scaffold(
      appBar: AppBar(
        title: Text(t.productDetails, style: const TextStyle(fontSize: 16)),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: t.saveDishAction,
            onPressed: () => saveDishSheet(context, itemId: item.id, itemName: tr(item.translations, locale, item.name)),
            icon: const Icon(Icons.favorite_border_rounded, color: RestoColors.primaryDeep),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: wide ? 760 : double.infinity),
          child: content,
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 12),
          child: Center(
            heightFactor: 1,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: GoldButton(
                label: canOrder
                    ? '${CustomerScope.cart(context).groupToken != null ? t.addToGroup : t.addToCart} · ${_money(context, _unit * _quantity, currency)}'
                    : t.onlineOrdersUnavailable,
                icon: Icons.shopping_cart_outlined,
                onPressed: canOrder && !item.soldOut ? _add : null,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Panier et commande

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  /// Livraison souhaitée (sinon à emporter) pour les restaurants qui livrent.
  bool _delivery = false;
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _address = TextEditingController();
  final _instructions = TextEditingController();
  final _note = TextEditingController();
  List<CustomerAddress> _addresses = const [];
  bool _prefilled = false;
  final String _checkoutId = uuidV4();
  final Map<String, String> _clientIds = {};

  /// Heure souhaitée (commande programmée) ; null = dès que possible.
  DateTime? _scheduledFor;

  String _channelOf(CustomerCart cart, CartGroup g) {
    if (cart.tableToken != null && cart.tableBranchId == g.branchId) return 'dine_in';
    return _delivery && g.menu.acceptsDelivery ? 'delivery' : 'takeaway';
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_prefilled) {
      _prefilled = true;
      _prefill();
    }
  }

  Future<void> _schedule() async {
    final now = DateTime.now();
    final day = await showDatePicker(context: context, firstDate: now, lastDate: now.add(const Duration(days: 13)), initialDate: now);
    if (day == null || !mounted) return;
    final time = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(now.add(const Duration(hours: 1))));
    if (time == null) return;
    final at = DateTime(day.year, day.month, day.day, time.hour, time.minute);
    if (at.isBefore(now.add(const Duration(minutes: 15)))) {
      if (mounted) showInfo(context, context.t.scheduleTooSoon);
      return;
    }
    setState(() => _scheduledFor = at);
  }

  Future<void> _prefill() async {
    final api = AppScope.read(context).api!.customer;
    if (api.user == null) return;
    try {
      final r = await Future.wait<dynamic>([api.profile(), api.addresses()]);
      final p = r[0] as CustomerProfile;
      if (!mounted) return;
      setState(() {
        if (_name.text.isEmpty) _name.text = p.fullName ?? '';
        if (_phone.text.isEmpty) _phone.text = p.phone ?? '';
        _addresses = r[1] as List<CustomerAddress>;
        if (_address.text.isEmpty && _addresses.isNotEmpty) _address.text = _addresses.first.address;
      });
    } catch (_) {}
  }

  @override
  void dispose() {
    for (final c in [_name, _phone, _address, _instructions, _note]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _order() async {
    final t = context.t;
    final cart = CustomerScope.cart(context);
    final anyDelivery = cart.groups.any((g) => _channelOf(cart, g) == 'delivery');
    if (anyDelivery && (_address.text.trim().length < 5 || _phone.text.trim().length < 6)) {
      showInfo(context, t.deliveryDetailsRequired);
      return;
    }
    if (!await ensureCustomerSignedIn(context)) return;
    if (!mounted) return;
    final api = AppScope.read(context).api!.customer;
    final names = {for (final g in cart.groups) g.branchId: g.menu.brandName};
    try {
      final results = await api.placeCheckout(
        checkoutId: _checkoutId,
        parts: [
          for (final g in cart.groups)
            CheckoutPart(
              branchId: g.branchId,
              channel: _channelOf(cart, g),
              lines: g.lines,
              tableToken: _channelOf(cart, g) == 'dine_in' ? cart.tableToken : null,
              note: _note.text,
              clientId: _clientIds.putIfAbsent(g.branchId, uuidV4),
            ),
        ],
        phone: _phone.text,
        name: _name.text,
        address: anyDelivery ? _address.text : null,
        instructions: anyDelivery ? _instructions.text : null,
        scheduledFor: _scheduledFor,
      );
      // Commandes venues d'un contenu du fil « Découvrir » : rattachées à la campagne.
      for (final r in results) {
        final campaign = cart.adSource[r.$1];
        if (campaign != null) api.attributeAdOrder(r.$2, campaign);
      }
      cart.clear();
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => results.length == 1
              ? CustomerOrderDetail(orderId: results.first.$2, justPlaced: true)
              : CheckoutDoneScreen(orders: [for (final r in results) (names[r.$1] ?? '', r.$2, r.$3)]),
        ),
      );
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final cart = CustomerScope.cart(context);
    final api = AppScope.read(context).api!.customer;
    return ListenableBuilder(
      listenable: cart,
      builder: (context, _) {
        if (cart.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: Text(t.myCart)),
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: EmptyState(icon: Icons.shopping_cart_outlined, title: t.cartEmpty),
            ),
          );
        }
        final currency = cart.currency;
        var grand = 0;
        var belowMin = false;
        final groupCards = <Widget>[];
        for (final g in cart.groups) {
          final channel = _channelOf(cart, g);
          final sub = g.total(channel);
          final fee = channel == 'delivery' ? g.menu.deliveryFeeMinor : 0;
          final under = channel != 'dine_in' && sub < g.menu.minOrderMinor;
          belowMin = belowMin || under;
          grand += sub + fee;
          final m = g.menu;
          groupCards.add(
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: GoldHeaderCard(
                title: m.brandName,
                titleIcon: Icons.storefront_rounded,
                badge: HeaderBadge(
                  text: channel == 'dine_in' ? t.channelDineIn : (channel == 'delivery' ? t.channelDelivery : t.channelTakeaway),
                  icon: channel == 'delivery' ? Icons.delivery_dining_rounded : Icons.shopping_bag_outlined,
                ),
                info: _delivery && channel == 'takeaway' && cart.tableBranchId != g.branchId ? Text(t.noDeliveryHere) : null,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final l in g.lines)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: SizedBox(
                                width: 56,
                                height: 50,
                                child: NetImage(l.item.imagePath == null ? null : api.imageUrl(l.item.imagePath!)),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    [l.item.name, if (l.variant.name.isNotEmpty) '(${l.variant.name})'].join(' '),
                                    style: const TextStyle(fontWeight: FontWeight.w700),
                                  ),
                                  if (l.modifiers.isNotEmpty)
                                    Text(
                                      l.modifiers.map((x) => '+ ${x.name}').join(' '),
                                      style: const TextStyle(color: RestoColors.muted, fontSize: 12),
                                    ),
                                  Text(
                                    _money(context, l.unitPrice(channel) * l.quantity, m.currency),
                                    style: const TextStyle(color: RestoColors.primaryDeep, fontWeight: FontWeight.w700),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () => cart.setQuantity(l, l.quantity - 1),
                              icon: const Icon(Icons.remove_circle_outline_rounded),
                            ),
                            Text('${l.quantity}', style: const TextStyle(fontWeight: FontWeight.w800)),
                            IconButton(
                              onPressed: () => cart.setQuantity(l, l.quantity + 1),
                              icon: const Icon(Icons.add_circle_outline_rounded),
                            ),
                          ],
                        ),
                      ),
                    const Divider(height: 14),
                    _TotalRow(label: t.subtotal, value: _money(context, sub, m.currency)),
                    if (fee > 0) _TotalRow(label: t.deliveryFee, value: _money(context, fee, m.currency)),
                    if (under)
                      Text(
                        t.minimumOrderNotReached(_money(context, m.minOrderMinor, m.currency)),
                        style: const TextStyle(color: Color(0xFFD9363E), fontSize: 12.5),
                      ),
                  ],
                ),
              ),
            ),
          );
        }
        final canDeliver = cart.groups.any((g) => g.menu.acceptsDelivery && cart.tableBranchId != g.branchId);
        final df = DateFormat.MMMEd(Localizations.localeOf(context).toString()).add_Hm();
        return Scaffold(
          appBar: AppBar(title: Text(t.myCart, style: serifTitle(context, size: 26))),
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 130),
                children: [
                  if (cart.groups.length > 1)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: SoftCard(
                        color: RestoColors.primarySoft,
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline_rounded, color: RestoColors.primaryDeep),
                            const SizedBox(width: 10),
                            Expanded(child: Text(t.multiRestaurantNote(cart.groups.length))),
                          ],
                        ),
                      ),
                    ),
                  ...groupCards,
                  Text(t.howDoYouWant, style: serifTitle(context, size: 22)),
                  const SizedBox(height: 8),
                  if (cart.tableToken != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: StatusPill(
                        label: t.orderingAtTable(cart.tableLabel ?? ''),
                        color: RestoColors.primaryDeep,
                        icon: Icons.table_restaurant_rounded,
                      ),
                    ),
                  if (canDeliver)
                    PillBar<bool>(
                      items: [
                        PillItem(false, t.channelTakeaway, icon: Icons.shopping_bag_outlined),
                        PillItem(true, t.channelDelivery, icon: Icons.delivery_dining_rounded),
                      ],
                      selected: _delivery,
                      onSelected: (v) => setState(() => _delivery = v),
                    ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      GoldPill(
                        label: t.asSoonAsPossible,
                        icon: Icons.bolt_rounded,
                        dense: true,
                        selected: _scheduledFor == null,
                        onTap: () => setState(() => _scheduledFor = null),
                      ),
                      GoldPill(
                        label: _scheduledFor == null ? t.scheduleOrder : df.format(_scheduledFor!),
                        icon: Icons.event_rounded,
                        dense: true,
                        selected: _scheduledFor != null,
                        onTap: _schedule,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _name,
                    maxLength: 120,
                    decoration: InputDecoration(labelText: t.yourName),
                  ),
                  TextField(
                    controller: _phone,
                    maxLength: 32,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(labelText: t.phone),
                  ),
                  if (_delivery && canDeliver) ...[
                    if (_addresses.isNotEmpty)
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final a in _addresses)
                            GoldPill(
                              label: a.label ?? a.address,
                              dense: true,
                              selected: _address.text == a.address,
                              onTap: () => setState(() {
                                _address.text = a.address;
                                _instructions.text = a.instructions ?? '';
                              }),
                            ),
                        ],
                      ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _address,
                      maxLength: 500,
                      maxLines: 2,
                      minLines: 1,
                      decoration: InputDecoration(labelText: t.deliveryAddress),
                    ),
                    TextField(
                      controller: _instructions,
                      maxLength: 500,
                      decoration: InputDecoration(labelText: t.deliveryInstructions),
                    ),
                  ],
                  TextField(
                    controller: _note,
                    maxLength: 500,
                    decoration: InputDecoration(labelText: t.orderNoteOptional),
                  ),
                  if (currency != null) ...[
                    const SizedBox(height: 10),
                    SoftCard(
                      child: _TotalRow(label: t.total, value: _money(context, grand, currency), strong: true),
                    ),
                  ],
                ],
              ),
            ),
          ),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 12),
              child: Center(
                heightFactor: 1,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 760),
                  child: GoldButton(
                    label: currency == null
                        ? (cart.groups.length > 1 ? t.placeOrders(cart.groups.length) : t.placeOrder)
                        : '${cart.groups.length > 1 ? t.placeOrders(cart.groups.length) : t.placeOrder} · ${_money(context, grand, currency)}',
                    icon: Icons.check_circle_outline_rounded,
                    onPressed: belowMin ? null : _order,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Après un panier multi-restaurants : une commande par restaurant, chacune suivie à part.
class CheckoutDoneScreen extends StatelessWidget {
  const CheckoutDoneScreen({super.key, required this.orders});

  /// (restaurant, commande, numéro)
  final List<(String, String, int)> orders;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return Scaffold(
      appBar: AppBar(title: Text(t.ordersSent, style: serifTitle(context, size: 24))),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              SoftCard(
                color: RestoColors.primarySoft,
                child: Row(
                  children: [
                    const GoldIcon(Icons.check_rounded, size: 46, filled: true),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(t.ordersSentHint(orders.length), style: const TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              for (final (brand, id, number) in orders)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: SoftCard(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CustomerOrderDetail(orderId: id))),
                    child: Row(
                      children: [
                        const GoldIcon(Icons.storefront_rounded, size: 40),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text('$brand · #$number', style: const TextStyle(fontWeight: FontWeight.w700)),
                        ),
                        Text(
                          t.trackOrder,
                          style: const TextStyle(color: RestoColors.primaryDeep, fontWeight: FontWeight.w600),
                        ),
                        const Icon(Icons.chevron_right_rounded, color: RestoColors.primaryDeep),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TotalRow extends StatelessWidget {
  const _TotalRow({required this.label, required this.value, this.strong = false});
  final String label;
  final String value;
  final bool strong;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(fontWeight: strong ? FontWeight.w800 : FontWeight.w500, fontSize: strong ? 17 : 14),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: strong ? RestoColors.primaryDeep : RestoColors.ink,
            fontSize: strong ? 18 : 14,
          ),
        ),
      ],
    ),
  );
}
