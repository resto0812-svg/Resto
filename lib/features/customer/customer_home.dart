import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../app_state.dart';
import '../../core/money.dart';
import '../../data/customer_api.dart';
import '../../ui/common.dart';
import '../../ui/files.dart';
import '../../ui/kit.dart';
import '../../ui/location.dart';
import '../../ui/theme.dart';
import 'customer_account.dart';
import 'customer_shell.dart';
import 'feed_page.dart';
import 'loyalty_pages.dart';
import 'restaurant_page.dart';

/// Ville choisie par le client (partagée entre Accueil et Recherche).
final customerCity = ValueNotifier<String?>(null);

/// Position du client (latitude, longitude), connue seulement avec son accord.
final customerPosition = ValueNotifier<(double, double)?>(null);

/// Distance à vol d'oiseau (formule de haversine), en kilomètres.
double distanceKm(double lat1, double lng1, double lat2, double lng2) {
  const r = 6371.0;
  double rad(double d) => d * pi / 180;
  final dLat = rad(lat2 - lat1);
  final dLng = rad(lng2 - lng1);
  final a = sin(dLat / 2) * sin(dLat / 2) + cos(rad(lat1)) * cos(rad(lat2)) * sin(dLng / 2) * sin(dLng / 2);
  return r * 2 * atan2(sqrt(a), sqrt(1 - a));
}

String distanceText(double km) => km < 1 ? '${(km * 1000).round()} m' : '${km.toStringAsFixed(km < 10 ? 1 : 0)} km';

void openRestaurant(BuildContext context, String branchId, {String? itemId}) {
  final scope = CustomerScope.of(context);
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => CustomerScope(
        cart: scope.notifier!,
        openTab: scope.openTab,
        child: RestaurantPage(branchId: branchId, openItemId: itemId),
      ),
    ),
  );
}

/// Image publique (photo de plat, logo, média publicitaire) avec repli élégant.
class NetImage extends StatelessWidget {
  const NetImage(this.url, {super.key, this.icon = Icons.restaurant_rounded, this.fit = BoxFit.cover});
  final String? url;
  final IconData icon;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFFF6ECD4), Color(0xFFE9D6A8)])),
      child: Center(child: Icon(icon, size: 36, color: RestoColors.primaryDeep.withValues(alpha: 0.6))),
    );
    if (url == null) return placeholder;
    return Image.network(url!, fit: fit, errorBuilder: (_, _, _) => placeholder);
  }
}

// ---------------------------------------------------------------------------
// Accueil

class CustomerHome extends StatefulWidget {
  const CustomerHome({super.key});

  @override
  State<CustomerHome> createState() => _CustomerHomeState();
}

class _HomeData {
  _HomeData(this.ads, this.cards, this.catalog, this.cities, this.home, this.mine);
  final List<PublicAd> ads;
  final List<BranchCard> cards;
  final List<CatalogItem> catalog;
  final List<(String, int)> cities;
  final PublicHome home;
  final MyHome mine;
}

class _CustomerHomeState extends State<CustomerHome> {
  late Future<_HomeData> _data = _load();
  bool _locating = false;

  Future<_HomeData> _load() async {
    final api = AppScope.read(context).api!.customer;
    final cities = await api.cities();
    // Par défaut, le client voit les restaurants de toutes les villes ; il peut
    // ensuite en choisir une.
    final city = customerCity.value;
    // Position enregistrée dans le profil (client connecté), si elle n'est pas déjà connue.
    if (customerPosition.value == null && api.user != null) {
      try {
        final p = await api.profile();
        if (p.homeLatitude != null && p.homeLongitude != null) customerPosition.value = (p.homeLatitude!, p.homeLongitude!);
      } catch (_) {}
    }
    final r = await Future.wait<dynamic>([
      api.ads(),
      api.cards(city: city),
      api.catalog(city: city),
      api.home(city: city).catchError((_) => PublicHome.fromJson(const {})),
      api.myHome().catchError((_) => MyHome.empty()),
    ]);
    return _HomeData(
      r[0] as List<PublicAd>,
      r[1] as List<BranchCard>,
      r[2] as List<CatalogItem>,
      cities,
      r[3] as PublicHome,
      r[4] as MyHome,
    );
  }

  void _reload() => setState(() => _data = _load());

  /// « Me localiser » : demandée seulement quand le client le souhaite ;
  /// refusée, on propose de choisir la ville à la main.
  Future<void> _locate(List<(String, int)> cities) async {
    final t = context.t;
    setState(() => _locating = true);
    final r = await currentLocation();
    if (!mounted) return;
    setState(() => _locating = false);
    if (r.issue != null) {
      showInfo(context, r.issue == LocationIssue.serviceDisabled ? t.locationServiceDisabled : t.locationRefusedChooseCity);
      if (cities.isNotEmpty) await _chooseCity(cities);
      return;
    }
    customerPosition.value = (r.latitude!, r.longitude!);
    final api = AppScope.read(context).api!.customer;
    if (api.user != null) api.saveHomeLocation(r.latitude!, r.longitude!).catchError((_) {});
    setState(() {});
  }

  /// Ajoute au panier les plats d'une commande passée encore disponibles.
  Future<void> _reorder(ReorderOrder order) async {
    final t = context.t;
    final scope = CustomerScope.of(context);
    final cart = scope.notifier!;
    try {
      final menu = await AppScope.read(context).api!.customer.menu(order.branchId);
      var added = 0;
      for (final l in order.lines) {
        final item = menu.categories.expand((c) => c.items).where((i) => i.id == l.itemId && !i.soldOut).firstOrNull;
        final variant = item?.variants.where((v) => v.id == l.variantId).firstOrNull;
        if (item == null || variant == null) continue;
        final mods = [
          for (final g in item.groups)
            for (final m in g.modifiers)
              if (l.modifierIds.contains(m.id)) m,
        ];
        cart.add(menu, CartLine(item: item, variant: variant, modifiers: mods, quantity: l.quantity));
        added++;
      }
      if (!mounted) return;
      if (added == 0) {
        showInfo(context, t.reorderUnavailable);
        return;
      }
      if (added < order.lines.length) showInfo(context, t.reorderPartial);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CustomerScope(cart: cart, openTab: scope.openTab, child: const CartScreen()),
        ),
      );
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  double? _distance(double? lat, double? lng) {
    final p = customerPosition.value;
    if (p == null || lat == null || lng == null) return null;
    return distanceKm(p.$1, p.$2, lat, lng);
  }

  Widget _row(List<Widget> children, {double height = 252, double width = 200}) => SizedBox(
    height: height,
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: children.length,
      separatorBuilder: (_, _) => const SizedBox(width: 12),
      itemBuilder: (context, i) => SizedBox(width: width, child: children[i]),
    ),
  );

  Future<void> _chooseCity(List<(String, int)> cities) async {
    final t = context.t;
    final city = await showModalBottomSheet<String>(
      context: context,
      builder: (c) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
              child: Text(t.chooseCity, style: serifTitle(context, size: 24)),
            ),
            ListTile(
              leading: const Icon(Icons.public_rounded, color: RestoColors.primaryDeep),
              title: Text(t.allCities),
              trailing: Text('${cities.fold<int>(0, (s, c) => s + c.$2)}', style: const TextStyle(color: RestoColors.muted)),
              selected: customerCity.value == null,
              onTap: () => Navigator.pop(c, ''),
            ),
            for (final (name, count) in cities)
              ListTile(
                leading: const Icon(Icons.location_on_outlined, color: RestoColors.primaryDeep),
                title: Text(name),
                trailing: Text('$count', style: const TextStyle(color: RestoColors.muted)),
                selected: name.toLowerCase() == customerCity.value?.toLowerCase(),
                onTap: () => Navigator.pop(c, name),
              ),
          ],
        ),
      ),
    );
    if (city != null) {
      // Chaîne vide : « Toutes les villes ».
      customerCity.value = city.isEmpty ? null : city;
      _reload();
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final api = AppScope.of(context).api!;
    final wide = MediaQuery.sizeOf(context).width >= 900;
    return FutureBuilder(
      future: _data,
      builder: (context, snap) {
        if (snap.hasError) {
          return Center(
            child: TextButton(onPressed: _reload, child: Text(t.retry)),
          );
        }
        if (!snap.hasData) return const Center(child: CircularProgressIndicator());
        final d = snap.data!;
        final (ads, catalog, cities) = (d.ads, d.catalog, d.cities);
        final near = customerPosition.value != null;
        // Près de vous : tri par distance quand la position est connue.
        final cards = [...d.cards]
          ..sort((a, b) {
            final da = _distance(a.latitude, a.longitude) ?? double.infinity;
            final db = _distance(b.latitude, b.longitude) ?? double.infinity;
            if (da != db) return da.compareTo(db);
            return (b.openNow ? 1 : 0) - (a.openNow ? 1 : 0);
          });
        final openCards = cards.where((c) => c.openNow).toList();
        Widget itemCard(HomeItem i) => HomeItemCard(item: i, distanceKm: _distance(i.latitude, i.longitude));
        final user = api.user;
        final list = RefreshIndicator(
          onRefresh: () async => _reload(),
          child: ListView(
            padding: EdgeInsets.fromLTRB(wide ? 32 : 16, 12, wide ? 32 : 16, 170),
            children: [
              // ----------------------------------------------- ville, profil
              Row(
                children: [
                  const Icon(Icons.location_on_outlined, color: RestoColors.primaryDeep, size: 30),
                  const SizedBox(width: 6),
                  Expanded(
                    child: InkWell(
                      onTap: cities.isEmpty ? null : () => _chooseCity(cities),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(child: Text(customerCity.value ?? t.allCities, style: serifTitle(context, size: 28))),
                              const Icon(Icons.expand_more_rounded, color: RestoColors.primaryDeep),
                            ],
                          ),
                          Text(t.changeCity, style: const TextStyle(color: RestoColors.primaryDeep, fontSize: 12.5)),
                        ],
                      ),
                    ),
                  ),
                  if (!wide && (user == null || api.accountType == 'business'))
                    TextButton(
                      onPressed: () => AppScope.read(context).setCustomerMode(false),
                      child: Text(t.restaurantSpace, style: const TextStyle(fontSize: 12)),
                    ),
                  if (user != null) const NotificationBell(),
                  GestureDetector(
                    onTap: () => CustomerScope.of(context).openTab(4),
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: RestoColors.brandGradient,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: RestoColors.softShadow(6),
                      ),
                      alignment: Alignment.center,
                      child: user == null
                          ? const Icon(Icons.person_outline_rounded, color: Colors.white)
                          : Text(
                              (user.email ?? '?').characters.first.toUpperCase(),
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18),
                            ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              // ----------------------------------------------- recherche
              GestureDetector(
                onTap: () => openCustomerSearch(context),
                child: AbsorbPointer(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: t.searchRestaurantsHint,
                      prefixIcon: const Icon(Icons.search_rounded, color: RestoColors.primaryDeep),
                      fillColor: Colors.white,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: RestoColors.primary.withValues(alpha: 0.5)),
                      ),
                    ),
                  ),
                ),
              ),
              // ----------------------------------------------- stories des restaurants
              const StoriesBar(),
              // ----------------------------------------------- position
              const SizedBox(height: 14),
              if (!near)
                SoftCard(
                  padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
                  child: Row(
                    children: [
                      const GoldIcon(Icons.near_me_outlined, size: 44),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(t.nearYouTitle, style: const TextStyle(fontWeight: FontWeight.w700)),
                            Text(t.nearYouHint, style: const TextStyle(color: RestoColors.muted, fontSize: 12.5)),
                          ],
                        ),
                      ),
                      if (_locating)
                        const SizedBox.square(dimension: 24, child: CircularProgressIndicator(strokeWidth: 2))
                      else
                        GoldButton(label: t.locateMe, icon: Icons.my_location_rounded, expand: false, onPressed: () => _locate(cities)),
                    ],
                  ),
                )
              else
                Row(
                  children: [
                    const Icon(Icons.near_me_rounded, size: 18, color: RestoColors.primaryDeep),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        t.locatedNearYou,
                        style: const TextStyle(color: RestoColors.primaryDeep, fontWeight: FontWeight.w600),
                      ),
                    ),
                    TextButton(onPressed: _locating ? null : () => _locate(cities), child: Text(t.refreshLocation)),
                  ],
                ),
              // ----------------------------------------------- commandes en cours
              if (d.mine.active.isNotEmpty) ...[
                const SizedBox(height: 18),
                _SectionTitle(title: t.ordersInProgressTitle, icon: Icons.delivery_dining_rounded),
                const SizedBox(height: 8),
                _row([for (final o in d.mine.active) _ActiveOrderCard(order: o)], height: 96, width: 260),
              ],
              // ----------------------------------------------- publicités
              if (ads.isNotEmpty) ...[
                const SizedBox(height: 22),
                _SectionTitle(title: t.sponsoredAds, icon: Icons.auto_awesome_rounded),
                const SizedBox(height: 10),
                _AdsCarousel(ads: ads, wide: wide),
              ],
              // ----------------------------------------------- promotions
              if (d.home.promos.isNotEmpty) ...[
                const SizedBox(height: 22),
                _SectionTitle(title: t.promotionsTitle, icon: Icons.local_offer_outlined),
                const SizedBox(height: 8),
                _row([for (final p in d.home.promos) _PromoCard(promo: p)], height: 132, width: 270),
              ],
              // ----------------------------------------------- restaurants
              const SizedBox(height: 22),
              _SectionTitle(
                title: near ? t.nearYouRestaurants : t.allRestaurants,
                trailing: TextButton(onPressed: () => openCustomerSearch(context), child: Text(t.seeAll)),
              ),
              const SizedBox(height: 8),
              if (cards.isEmpty)
                EmptyState(icon: Icons.storefront_outlined, title: t.noRestaurantsYet)
              else
                _row([for (final c in cards) RestaurantCard(card: c, distanceKm: _distance(c.latitude, c.longitude))]),
              // ----------------------------------------------- ouverts maintenant
              if (openCards.isNotEmpty && openCards.length < cards.length) ...[
                const SizedBox(height: 22),
                _SectionTitle(title: t.openNowTitle, icon: Icons.schedule_rounded),
                const SizedBox(height: 8),
                _row([for (final c in openCards) RestaurantCard(card: c, distanceKm: _distance(c.latitude, c.longitude))]),
              ],
              // ----------------------------------------------- populaires
              if (d.home.popular.isNotEmpty) ...[
                const SizedBox(height: 22),
                _SectionTitle(title: near ? t.popularNearYou : t.popularDishes, icon: Icons.local_fire_department_outlined),
                const SizedBox(height: 8),
                _row([for (final i in d.home.popular) itemCard(i)], height: 236, width: 190),
              ],
              // ----------------------------------------------- pour vous
              if (d.mine.suggested.isNotEmpty) ...[
                const SizedBox(height: 22),
                _SectionTitle(title: t.forYou, icon: Icons.favorite_outline_rounded),
                const SizedBox(height: 8),
                _row([for (final i in d.mine.suggested) itemCard(i)], height: 236, width: 190),
              ],
              // ----------------------------------------------- recommander
              if (d.mine.reorder.isNotEmpty) ...[
                const SizedBox(height: 22),
                _SectionTitle(title: t.orderAgain, icon: Icons.replay_rounded),
                const SizedBox(height: 8),
                _row([for (final o in d.mine.reorder) _ReorderCard(order: o, onReorder: () => _reorder(o))], height: 150, width: 280),
              ],
              // ----------------------------------------------- nouveautés
              if (d.home.newItems.isNotEmpty) ...[
                const SizedBox(height: 22),
                _SectionTitle(title: t.newOnMenus, icon: Icons.fiber_new_outlined),
                const SizedBox(height: 8),
                _row([for (final i in d.home.newItems) itemCard(i)], height: 236, width: 190),
              ],
              // ----------------------------------------------- catalogue global
              if (catalog.isNotEmpty) ...[
                const SizedBox(height: 22),
                _SectionTitle(title: t.globalCatalog),
                const SizedBox(height: 8),
                LayoutBuilder(
                  builder: (context, box) {
                    final cols = box.maxWidth >= 1100 ? 3 : (box.maxWidth >= 700 ? 2 : 1);
                    final w = (box.maxWidth - (cols - 1) * 12) / cols;
                    return Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        for (final it in catalog)
                          SizedBox(
                            width: w,
                            child: CatalogRow(item: it),
                          ),
                      ],
                    );
                  },
                ),
              ],
              // ----------------------------------------------- carte
              if (cards.any((c) => c.latitude != null)) ...[
                const SizedBox(height: 22),
                _MapCard(cards: cards.where((c) => c.latitude != null).toList(), city: customerCity.value),
              ],
            ],
          ),
        );
        final cart = CustomerScope.cart(context);
        return Stack(
          children: [
            Positioned.fill(child: list),
            // Petites annonces flottantes (accueil seulement), au-dessus de la barre du panier.
            PositionedDirectional(
              end: wide ? 32 : 12,
              start: wide ? null : 12,
              bottom: cart.isEmpty ? 96 : 160,
              child: const Align(alignment: AlignmentDirectional.bottomEnd, child: FloatingClassifieds()),
            ),
          ],
        );
      },
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, this.icon, this.trailing});
  final String title;
  final IconData? icon;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      if (icon != null) ...[Icon(icon, color: RestoColors.primary, size: 22), const SizedBox(width: 6)],
      Expanded(child: Text(title, style: serifTitle(context, size: 24))),
      ?trailing,
    ],
  );
}

/// Plat mis en avant (populaire, nouveau, suggéré) : photo, note, prix, distance.
class HomeItemCard extends StatelessWidget {
  const HomeItemCard({super.key, required this.item, this.distanceKm});
  final HomeItem item;
  final double? distanceKm;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final api = AppScope.read(context).api!.customer;
    final locale = Localizations.localeOf(context).toString();
    return SoftCard(
      padding: EdgeInsets.zero,
      radius: 18,
      onTap: () => openRestaurant(context, item.branchId, itemId: item.itemId),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            child: AspectRatio(
              aspectRatio: 1.35,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  NetImage(item.imagePath == null ? null : api.imageUrl(item.imagePath!)),
                  if (distanceKm != null)
                    Positioned(
                      left: 8,
                      top: 8,
                      child: HeaderBadge(text: distanceText(distanceKm!), icon: Icons.near_me_rounded),
                    ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                Text(
                  item.brandName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: RestoColors.muted, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (item.rating != null) ...[
                      const Icon(Icons.star_rounded, size: 15, color: RestoColors.primary),
                      Text(' ${item.rating} (${item.reviews})', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    ] else
                      Text(t.newRestaurant, style: const TextStyle(fontSize: 12, color: RestoColors.muted)),
                    const Spacer(),
                    if (item.priceMinor != null)
                      Text(
                        Money(item.priceMinor!, item.currency).format(locale, minorUnitOf(item.currency)),
                        style: const TextStyle(color: RestoColors.primaryDeep, fontWeight: FontWeight.w800, fontSize: 13),
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

/// Commande en cours (accueil) : restaurant, numéro, état ; ouvre le suivi.
class _ActiveOrderCard extends StatelessWidget {
  const _ActiveOrderCard({required this.order});
  final ActiveOrder order;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final (label, color) = order.acceptance == 'pending'
        ? (t.orderWaitingConfirmation, StatusColors.toValidate)
        : (order.ready ? (t.stepReady, StatusColors.ready) : (t.stepPreparing, StatusColors.cooking));
    return SoftCard(
      padding: const EdgeInsets.all(12),
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CustomerOrderDetail(orderId: order.orderId))),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: const BoxDecoration(gradient: RestoColors.brandGradient, shape: BoxShape.circle),
            child: const Icon(Icons.receipt_long_rounded, color: Colors.white),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${order.brandName} · #${order.number}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                StatusPill(label: label, color: color, dense: true),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: RestoColors.muted),
        ],
      ),
    );
  }
}

/// Promotion d'un restaurant : remise, nom, code, conditions.
class _PromoCard extends StatelessWidget {
  const _PromoCard({required this.promo});
  final PublicPromo promo;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final locale = Localizations.localeOf(context).toString();
    String money(int v) => Money(v, promo.currency).format(locale, minorUnitOf(promo.currency));
    final value = promo.kind == 'percent'
        ? '-${promo.percent!.toStringAsFixed(promo.percent! == promo.percent!.roundToDouble() ? 0 : 1)} %'
        : '-${money(promo.amountMinor ?? 0)}';
    return GestureDetector(
      onTap: promo.branchId == null ? null : () => openRestaurant(context, promo.branchId!),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF2B2014), Color(0xFF5A4318)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: RestoColors.softShadow(8),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(value, style: serifTitle(context, size: 30, color: RestoColors.primaryBright)),
                  Text(
                    promo.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    [promo.brandName, if (promo.minOrderMinor > 0) t.fromAmount(money(promo.minOrderMinor))].join(' · '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
            if (promo.code != null)
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      border: Border.all(color: RestoColors.primaryBright),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      promo.code!,
                      style: const TextStyle(color: RestoColors.primaryBright, fontWeight: FontWeight.w800, letterSpacing: 1),
                    ),
                  ),
                  const SizedBox(height: 4),
                  InkWell(
                    onTap: () => saveCouponFlow(context, promo.id),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.bookmark_add_outlined, size: 15, color: Colors.white70),
                          const SizedBox(width: 3),
                          Text(t.saveCouponAction, style: const TextStyle(color: Colors.white70, fontSize: 11.5)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

/// Commande passée : plats, montant, « Recommander ».
class _ReorderCard extends StatelessWidget {
  const _ReorderCard({required this.order, required this.onReorder});
  final ReorderOrder order;
  final Future<void> Function() onReorder;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final locale = Localizations.localeOf(context).toString();
    return SoftCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  order.brandName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              Text(
                Money(order.totalMinor, order.currency).format(locale, minorUnitOf(order.currency)),
                style: const TextStyle(color: RestoColors.primaryDeep, fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Expanded(
            child: Text(
              order.lines.map((l) => '${l.quantity} × ${l.name}').join(', '),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: RestoColors.muted, fontSize: 12.5),
            ),
          ),
          GoldButton(label: t.orderAgainAction, icon: Icons.replay_rounded, onPressed: onReorder),
        ],
      ),
    );
  }
}

/// Carrousel des publicités sponsorisées (défilement automatique).
class _AdsCarousel extends StatefulWidget {
  const _AdsCarousel({required this.ads, required this.wide});
  final List<PublicAd> ads;
  final bool wide;

  @override
  State<_AdsCarousel> createState() => _AdsCarouselState();
}

class _AdsCarouselState extends State<_AdsCarousel> {
  late final PageController _page = PageController(viewportFraction: widget.wide ? 0.42 : 0.92);
  int _index = 0;
  Timer? _timer;
  final Set<String> _seen = {};

  @override
  void initState() {
    super.initState();
    _view(0);
    _timer = Timer.periodic(const Duration(seconds: 6), (_) {
      if (!mounted || widget.ads.length < 2 || !_page.hasClients) return;
      _page.animateToPage((_index + 1) % widget.ads.length, duration: const Duration(milliseconds: 500), curve: Curves.easeOut);
    });
  }

  void _view(int i) {
    final ad = widget.ads[i];
    if (_seen.add(ad.id)) AppScope.read(context).api!.customer.recordAd(ad.id, 'view');
  }

  @override
  void dispose() {
    _timer?.cancel();
    _page.dispose();
    super.dispose();
  }

  void _open(PublicAd ad) {
    final api = AppScope.read(context).api!.customer;
    api.recordAd(ad.id, 'click');
    if (ad.ctaUrl != null) {
      openLink(ad.ctaUrl!);
    } else if (ad.branchId != null) {
      openRestaurant(context, ad.branchId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final api = AppScope.read(context).api!.customer;
    return Column(
      children: [
        SizedBox(
          height: widget.wide ? 220 : 170,
          child: PageView.builder(
            controller: _page,
            itemCount: widget.ads.length,
            onPageChanged: (i) {
              setState(() => _index = i);
              _view(i);
            },
            itemBuilder: (context, i) {
              final ad = widget.ads[i];
              final image = ad.media.where((m) => m.$2 == 'image').firstOrNull;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: GestureDetector(
                  onTap: () => _open(ad),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        if (image != null)
                          NetImage(api.adMediaUrl(image.$1))
                        else if (ad.logoPath != null)
                          Container(
                            color: const Color(0xFF2B2014),
                            child: NetImage(api.logoUrl(ad.logoPath!), fit: BoxFit.contain),
                          )
                        else
                          Container(decoration: const BoxDecoration(gradient: RestoColors.brandGradient)),
                        const DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [Color(0xE6000000), Color(0x22000000)],
                            ),
                          ),
                        ),
                        Positioned(
                          left: 10,
                          top: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(color: RestoColors.primary, borderRadius: BorderRadius.circular(6)),
                            child: Text(
                              t.adSponsored.toUpperCase(),
                              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.5),
                            ),
                          ),
                        ),
                        if (ad.views + ad.likes + ad.comments > 0)
                          Positioned(
                            right: 10,
                            top: 10,
                            child: AdSocialStats(views: ad.views, likes: ad.likes, comments: ad.comments),
                          ),
                        Positioned(
                          left: 16,
                          right: 16,
                          bottom: 14,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ad.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: serifTitle(context, size: 26, color: RestoColors.primaryBright),
                              ),
                              if (ad.body != null)
                                Text(
                                  ad.body!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(color: Colors.white, fontSize: 13),
                                ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      ad.brandName,
                                      style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                                    decoration: BoxDecoration(gradient: RestoColors.brandGradient, borderRadius: BorderRadius.circular(10)),
                                    child: Text(
                                      ad.ctaLabel ?? t.adCtaDefault,
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12.5),
                                    ),
                                  ),
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
            },
          ),
        ),
        if (widget.ads.length > 1) ...[
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < widget.ads.length; i++)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: i == _index ? 18 : 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: i == _index ? RestoColors.primary : RestoColors.primarySoft,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

/// Carte d'un restaurant : photo, nom, note, temps, cuisine, ouvert/fermé, favori.
class RestaurantCard extends StatelessWidget {
  const RestaurantCard({super.key, required this.card, this.favorite, this.onFavorite, this.distanceKm});

  /// Distance depuis la position du client, si elle est connue.
  final double? distanceKm;
  final BranchCard card;
  final bool? favorite;
  final VoidCallback? onFavorite;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final api = AppScope.read(context).api!.customer;
    final cover = card.coverPath != null ? api.imageUrl(card.coverPath!) : (card.logoPath != null ? api.logoUrl(card.logoPath!) : null);
    return SoftCard(
      padding: EdgeInsets.zero,
      radius: 18,
      onTap: () => openRestaurant(context, card.branchId),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            child: AspectRatio(
              aspectRatio: 1.45,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  NetImage(cover, icon: Icons.storefront_rounded),
                  if (favorite != null)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Material(
                        color: Colors.white,
                        shape: const CircleBorder(),
                        child: IconButton(
                          visualDensity: VisualDensity.compact,
                          onPressed: onFavorite,
                          icon: Icon(
                            favorite! ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                            size: 18,
                            color: favorite! ? const Color(0xFFD9363E) : RestoColors.primaryDeep,
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    left: 8,
                    bottom: 8,
                    child: StatusPill(
                      label: card.openNow ? t.openNow : t.closedNow,
                      color: card.openNow ? const Color(0xFF2E9E5B) : RestoColors.muted,
                      dense: true,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  card.brandName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.star_rounded, size: 16, color: RestoColors.primary),
                    const SizedBox(width: 2),
                    Text(
                      card.rating == null ? t.newRestaurant : '${card.rating} (${card.reviewsCount})',
                      style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  [
                    if (distanceKm != null) distanceText(distanceKm!),
                    if (card.prepMinutes != null) t.minutesRange(card.prepMinutes!, card.prepMinutes! + 15),
                    ...card.cuisines.take(2),
                    if (card.priceLevel != null) '\$' * card.priceLevel!,
                  ].join(' · '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: RestoColors.muted, fontSize: 11.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Ligne du catalogue global : photo, nom, description, prix, bouton +.
class CatalogRow extends StatelessWidget {
  const CatalogRow({super.key, required this.item});
  final CatalogItem item;

  @override
  Widget build(BuildContext context) {
    final api = AppScope.read(context).api!.customer;
    final locale = Localizations.localeOf(context).toString();
    return SoftCard(
      padding: const EdgeInsets.all(10),
      onTap: () => openRestaurant(context, item.branchId, itemId: item.itemId),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(width: 92, height: 72, child: NetImage(item.imagePath == null ? null : api.imageUrl(item.imagePath!))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                ),
                Text(
                  item.description ?? item.brandName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: RestoColors.muted, fontSize: 12.5),
                ),
                Text(
                  item.brandName,
                  style: const TextStyle(color: RestoColors.primaryDeep, fontSize: 11.5, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          if (item.priceMinor != null)
            Text(
              Money(item.priceMinor!, item.currency).format(locale, minorUnitOf(item.currency)),
              style: const TextStyle(color: RestoColors.primaryDeep, fontWeight: FontWeight.w800),
            ),
          const SizedBox(width: 8),
          Container(
            width: 34,
            height: 34,
            decoration: const BoxDecoration(gradient: RestoColors.brandGradient, shape: BoxShape.circle),
            child: const Icon(Icons.add_rounded, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

/// Carte des établissements : liste avec itinéraire (application de cartes).
class _MapCard extends StatelessWidget {
  const _MapCard({required this.cards, required this.city});
  final List<BranchCard> cards;
  final String? city;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionHeading(title: t.mapView, icon: Icons.map_outlined, subtitle: t.mapCount(cards.length)),
          const SizedBox(height: 10),
          for (final c in cards.take(6))
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.location_on_rounded, color: RestoColors.primary),
              title: Text(c.brandName, style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text(c.address ?? c.city),
              trailing: TextButton(
                onPressed: () => openLink('https://www.google.com/maps/dir/?api=1&destination=${c.latitude},${c.longitude}'),
                child: Text(t.directions),
              ),
            ),
          const SizedBox(height: 6),
          GoldButton(
            label: t.openFullMap,
            icon: Icons.open_in_new_rounded,
            outlined: true,
            onPressed: () async =>
                openLink('https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent('restaurant ${city ?? ''}')}'),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Recherche

/// Ouvre la recherche (depuis le champ de l'accueil).
void openCustomerSearch(BuildContext context) {
  final scope = CustomerScope.of(context);
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => CustomerScope(
        cart: scope.notifier!,
        openTab: scope.openTab,
        child: Scaffold(
          appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
          body: const CustomerSearch(autofocus: true),
        ),
      ),
    ),
  );
}

class CustomerSearch extends StatefulWidget {
  const CustomerSearch({super.key, this.autofocus = false});
  final bool autofocus;

  @override
  State<CustomerSearch> createState() => _CustomerSearchState();
}

class _CustomerSearchState extends State<CustomerSearch> {
  final _query = TextEditingController();
  Timer? _debounce;
  Future<(List<BranchCard>, List<CatalogItem>)>? _results;

  @override
  void initState() {
    super.initState();
    _search();
  }

  void _search() {
    final api = AppScope.read(context).api!.customer;
    final q = _query.text.trim();
    setState(() {
      _results = () async {
        final r = await Future.wait<dynamic>([
          api.cards(query: q, city: customerCity.value),
          if (q.isNotEmpty) api.catalog(query: q, city: customerCity.value) else Future.value(<CatalogItem>[]),
        ]);
        return (r[0] as List<BranchCard>, r[1] as List<CatalogItem>);
      }();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _query.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final wide = MediaQuery.sizeOf(context).width >= 900;
    return ListView(
      padding: EdgeInsets.fromLTRB(wide ? 32 : 16, 12, wide ? 32 : 16, 170),
      children: [
        Text(t.customerSearch, style: serifTitle(context, size: 32)),
        const SizedBox(height: 12),
        TextField(
          controller: _query,
          autofocus: widget.autofocus,
          onChanged: (_) {
            _debounce?.cancel();
            _debounce = Timer(const Duration(milliseconds: 350), _search);
          },
          decoration: InputDecoration(
            hintText: t.searchRestaurantsHint,
            prefixIcon: const Icon(Icons.search_rounded, color: RestoColors.primaryDeep),
            fillColor: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        FutureBuilder(
          future: _results,
          builder: (context, snap) {
            if (!snap.hasData) {
              return const Center(
                child: Padding(padding: EdgeInsets.all(30), child: CircularProgressIndicator()),
              );
            }
            final (cards, dishes) = snap.data!;
            if (cards.isEmpty && dishes.isEmpty) return EmptyState(icon: Icons.search_off_rounded, title: t.noResults);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (dishes.isNotEmpty) ...[
                  Text(t.dishes, style: serifTitle(context, size: 22)),
                  const SizedBox(height: 8),
                  for (final d in dishes.take(10))
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: CatalogRow(item: d),
                    ),
                  const SizedBox(height: 10),
                ],
                if (cards.isNotEmpty) ...[
                  Text(t.restaurants, style: serifTitle(context, size: 22)),
                  const SizedBox(height: 8),
                  LayoutBuilder(
                    builder: (context, box) {
                      final cols = (box.maxWidth / 220).floor().clamp(2, 6);
                      final w = (box.maxWidth - (cols - 1) * 12) / cols;
                      return Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          for (final c in cards)
                            SizedBox(
                              width: w,
                              child: RestaurantCard(card: c),
                            ),
                        ],
                      );
                    },
                  ),
                ],
              ],
            );
          },
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Favoris

class CustomerFavorites extends StatefulWidget {
  const CustomerFavorites({super.key});

  @override
  State<CustomerFavorites> createState() => _CustomerFavoritesState();
}

class _CustomerFavoritesState extends State<CustomerFavorites> {
  Future<(Set<String>, List<BranchCard>)>? _data;
  String _section = 'restaurants';

  Future<(Set<String>, List<BranchCard>)> _load() async {
    final api = AppScope.read(context).api!.customer;
    final r = await Future.wait<dynamic>([api.favorites(), api.cards()]);
    return (r[0] as Set<String>, r[1] as List<BranchCard>);
  }

  Future<void> _toggle(String branchId, bool on) async {
    try {
      await AppScope.read(context).api!.customer.setFavorite(branchId, on);
      setState(() => _data = _load());
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final api = AppScope.of(context).api!;
    final wide = MediaQuery.sizeOf(context).width >= 900;
    if (api.user == null) {
      return _SignInPrompt(
        icon: Icons.favorite_border_rounded,
        title: t.customerFavorites,
        message: t.favoritesSignIn,
        onDone: () => setState(() {}),
      );
    }
    _data ??= _load();
    return FutureBuilder(
      future: _data,
      builder: (context, snap) {
        if (!snap.hasData) return const Center(child: CircularProgressIndicator());
        final (favorites, cards) = snap.data!;
        final mine = cards.where((c) => favorites.contains(c.branchId)).toList();
        final others = cards.where((c) => !favorites.contains(c.branchId)).toList();
        final head = [
          Text(t.customerFavorites, style: serifTitle(context, size: 32)),
          const SizedBox(height: 12),
          PillBar<String>(
            items: [
              PillItem('restaurants', t.restaurantsSection, icon: Icons.storefront_outlined),
              PillItem('dishes', t.favoriteDishes, icon: Icons.ramen_dining_outlined),
              PillItem('lists', t.myLists, icon: Icons.playlist_play_rounded),
              PillItem('coupons', t.myCoupons, icon: Icons.confirmation_number_outlined),
            ],
            selected: _section,
            onSelected: (v) => setState(() => _section = v),
          ),
          const SizedBox(height: 14),
        ];
        if (_section != 'restaurants') {
          return ListView(
            padding: EdgeInsets.fromLTRB(wide ? 32 : 16, 12, wide ? 32 : 16, 170),
            children: [
              ...head,
              switch (_section) {
                'dishes' => const SavedDishesView(),
                'lists' => const ListsView(),
                _ => const CouponsView(),
              },
            ],
          );
        }
        return ListView(
          padding: EdgeInsets.fromLTRB(wide ? 32 : 16, 12, wide ? 32 : 16, 170),
          children: [
            ...head,
            if (mine.isEmpty) EmptyState(icon: Icons.favorite_border_rounded, title: t.noFavorites, message: t.noFavoritesHint),
            LayoutBuilder(
              builder: (context, box) {
                final cols = (box.maxWidth / 220).floor().clamp(2, 6);
                final w = (box.maxWidth - (cols - 1) * 12) / cols;
                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    for (final c in mine)
                      SizedBox(
                        width: w,
                        child: RestaurantCard(card: c, favorite: true, onFavorite: () => _toggle(c.branchId, false)),
                      ),
                  ],
                );
              },
            ),
            if (others.isNotEmpty) ...[
              const SizedBox(height: 22),
              Text(t.discoverRestaurants, style: serifTitle(context, size: 22)),
              const SizedBox(height: 8),
              LayoutBuilder(
                builder: (context, box) {
                  final cols = (box.maxWidth / 220).floor().clamp(2, 6);
                  final w = (box.maxWidth - (cols - 1) * 12) / cols;
                  return Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      for (final c in others.take(8))
                        SizedBox(
                          width: w,
                          child: RestaurantCard(card: c, favorite: false, onFavorite: () => _toggle(c.branchId, true)),
                        ),
                    ],
                  );
                },
              ),
            ],
          ],
        );
      },
    );
  }
}

/// Invitation à se connecter (favoris, commandes, profil).
class _SignInPrompt extends StatelessWidget {
  const _SignInPrompt({required this.icon, required this.title, required this.message, required this.onDone});
  final IconData icon;
  final String title;
  final String message;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 170),
      children: [
        Text(title, style: serifTitle(context, size: 32)),
        const SizedBox(height: 16),
        EmptyState(
          icon: icon,
          title: t.signInToContinue,
          message: message,
          action: GoldButton(
            label: t.signIn,
            icon: Icons.login_rounded,
            expand: false,
            onPressed: () async {
              if (await ensureCustomerSignedIn(context)) onDone();
            },
          ),
        ),
      ],
    );
  }
}

/// Invitation réutilisée par Commandes et Profil.
Widget customerSignInPrompt(
  BuildContext context, {
  required IconData icon,
  required String title,
  required String message,
  required VoidCallback onDone,
}) => _SignInPrompt(icon: icon, title: title, message: message, onDone: onDone);
