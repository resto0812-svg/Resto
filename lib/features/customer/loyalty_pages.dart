import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show RealtimeChannel;

import '../../app_state.dart';
import '../../core/money.dart';
import '../../data/customer_api.dart';
import '../../ui/common.dart';
import '../../ui/kit.dart';
import '../../ui/theme.dart';
import 'customer_account.dart';
import 'customer_home.dart';
import 'customer_shell.dart';
import 'group_order.dart';

// ---------------------------------------------------------------------------
// Anniversaire

Future<void> showBirthdayGifts(BuildContext context, List<(String, int)> gifts) => showDialog<void>(
  context: context,
  builder: (d) {
    final t = d.t;
    return AlertDialog(
      contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const GoldIcon(Icons.cake_rounded, size: 76, filled: true),
          const SizedBox(height: 14),
          Text(t.happyBirthday, textAlign: TextAlign.center, style: serifTitle(d, size: 28)),
          const SizedBox(height: 8),
          for (final (name, points) in gifts)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(t.birthdayGift(name, points), textAlign: TextAlign.center),
            ),
        ],
      ),
      actions: [TextButton(onPressed: () => Navigator.pop(d), child: Text(t.thanksAction))],
    );
  },
);

// ---------------------------------------------------------------------------
// Notifications

/// Texte d'une notification dans la langue du client.
(IconData, String, String) notificationText(BuildContext context, CustomerNotification n) {
  final t = context.t;
  final d = n.data;
  final brand = d['brand_name'] as String? ?? '';
  final number = '${d['number'] ?? ''}';
  String date() {
    final s = d['starts_at'] as String?;
    if (s == null) return '';
    return DateFormat.MMMEd(Localizations.localeOf(context).toString()).add_Hm().format(DateTime.parse(s).toLocal());
  }

  return switch (n.kind) {
    'order_accepted' => (Icons.check_circle_outline_rounded, t.notifOrderAcceptedTitle, t.notifOrderAccepted(brand, number)),
    'order_ready' =>
      d['channel'] == 'delivery'
          ? (Icons.delivery_dining_rounded, t.notifOrderReadyTitle, t.notifOrderOnTheWay(brand, number))
          : (Icons.shopping_bag_outlined, t.notifOrderReadyTitle, t.notifOrderReady(brand, number)),
    'order_rejected' => (
      Icons.cancel_outlined,
      t.notifOrderRejectedTitle,
      t.notifOrderRejected(brand, number, d['reason'] as String? ?? ''),
    ),
    'reservation_confirmed' => (
      Icons.event_available_rounded,
      t.notifReservationConfirmedTitle,
      t.notifReservationConfirmed(brand, date()),
    ),
    'reservation_declined' => (
      Icons.event_busy_rounded,
      t.notifReservationDeclinedTitle,
      t.notifReservationDeclined(brand, date(), d['reason'] as String? ?? ''),
    ),
    'birthday_reward' => (
      Icons.cake_rounded,
      t.happyBirthday,
      t.birthdayGift(d['organization_name'] as String? ?? '', (d['points'] as num? ?? 0).toInt()),
    ),
    'group_joined' => (Icons.group_add_outlined, t.groupOrderTitle, t.notifGroupJoined(d['participant_name'] as String? ?? '', brand)),
    'promotion' => (Icons.local_offer_outlined, '$brand · ${d['title'] ?? ''}', d['body'] as String? ?? ''),
    'staff_new_order' => (
      Icons.receipt_long_rounded,
      t.notifStaffNewOrderTitle,
      t.notifStaffNewOrder(number, (d['customer_name'] as String? ?? '').isEmpty ? '' : '· ${d['customer_name']}', d['branch_name'] as String? ?? ''),
    ),
    'staff_order_ready' => (
      Icons.room_service_outlined,
      t.notifStaffOrderReadyTitle,
      t.notifStaffOrderReady(number, d['branch_name'] as String? ?? ''),
    ),
    'staff_new_reservation' => (
      Icons.event_seat_outlined,
      t.notifStaffReservationTitle,
      t.notifStaffReservation(d['customer_name'] as String? ?? '', (d['party_size'] as num? ?? 0).toInt(), date()),
    ),
    'staff_new_review' => (
      Icons.rate_review_outlined,
      t.notifStaffReviewTitle,
      t.notifStaffReview(d['author'] as String? ?? '', d['item_name'] as String? ?? ''),
    ),
    _ => (Icons.groups_2_outlined, t.groupOrderTitle, t.notifGroupPlaced(d['host_name'] as String? ?? '', brand, number)),
  };
}

/// Cloche avec le nombre de notifications non lues (mise à jour en direct).
class NotificationBell extends StatefulWidget {
  const NotificationBell({super.key, this.staff = false, this.onStaffOpen});

  /// Notifications du restaurant (équipe) plutôt que celles du client.
  final bool staff;
  final ValueChanged<CustomerNotification>? onStaffOpen;

  @override
  State<NotificationBell> createState() => _NotificationBellState();
}

class _NotificationBellState extends State<NotificationBell> {
  int _unread = 0;
  RealtimeChannel? _channel;
  String? _user;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final api = AppScope.of(context).api!.customer;
    final user = api.user?.id;
    if (user == _user) return;
    _user = user;
    _unsubscribe();
    if (user != null) {
      _channel = api.watchNotifications(_refresh);
      _refresh();
    } else {
      _unread = 0;
    }
  }

  void _unsubscribe() {
    final c = _channel;
    _channel = null;
    if (c != null) AppScope.read(context).api!.customer.unwatch(c);
  }

  Future<void> _refresh() async {
    try {
      final n = await AppScope.read(context).api!.customer.unreadNotifications(staff: widget.staff);
      if (mounted) setState(() => _unread = n);
    } catch (_) {}
  }

  @override
  void dispose() {
    final c = _channel;
    if (c != null) AppScope.read(context).api!.customer.unwatch(c);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return IconButton(
      tooltip: t.notificationsTitle,
      onPressed: () async {
        if (widget.staff) {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => NotificationsPage(staff: true, onStaffOpen: widget.onStaffOpen)),
          );
          _refresh();
          return;
        }
        if (!await ensureCustomerSignedIn(context) || !context.mounted) return;
        final scope = CustomerScope.of(context);
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CustomerScope(cart: scope.notifier!, openTab: scope.openTab, child: const NotificationsPage()),
          ),
        );
        _refresh();
      },
      icon: Badge(
        isLabelVisible: _unread > 0,
        backgroundColor: RestoColors.primary,
        label: Text(_unread > 99 ? '99+' : '$_unread'),
        child: const Icon(Icons.notifications_none_rounded, color: RestoColors.primaryDeep, size: 28),
      ),
    );
  }
}

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key, this.staff = false, this.onStaffOpen});
  final bool staff;
  final ValueChanged<CustomerNotification>? onStaffOpen;

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  late Future<List<CustomerNotification>> _list = _load();

  Future<List<CustomerNotification>> _load() async {
    final api = AppScope.read(context).api!.customer;
    final list = await api.notifications(staff: widget.staff);
    final unread = [for (final n in list) if (n.readAt == null) n.id];
    if (unread.isNotEmpty) api.markNotificationsRead(unread).catchError((_) {});
    return list;
  }

  void _open(CustomerNotification n) {
    if (widget.staff) {
      Navigator.pop(context);
      widget.onStaffOpen?.call(n);
      return;
    }
    if (n.kind == 'promotion' && n.data['branch_id'] != null) {
      openRestaurant(context, n.data['branch_id'] as String);
      return;
    }
    final scope = CustomerScope.of(context);
    Widget? page;
    final orderId = n.data['order_id'] as String?;
    if (orderId != null && n.kind.startsWith('order_')) page = CustomerOrderDetail(orderId: orderId);
    if (n.kind == 'group_joined' && n.data['token'] != null) page = GroupOrderScreen(token: n.data['token'] as String);
    if (n.kind.startsWith('reservation_')) {
      Navigator.pop(context);
      scope.openTab(3);
      return;
    }
    if (page == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CustomerScope(cart: scope.notifier!, openTab: scope.openTab, child: page!),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final locale = Localizations.localeOf(context).toString();
    return Scaffold(
      appBar: AppBar(title: Text(t.notificationsTitle, style: serifTitle(context, size: 24))),
      body: FutureBuilder(
        future: _list,
        builder: (context, snap) {
          if (snap.hasError) {
            return Center(
              child: TextButton(onPressed: () => setState(() => _list = _load()), child: Text(t.retry)),
            );
          }
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final list = snap.data!;
          return RefreshIndicator(
            onRefresh: () async => setState(() => _list = _load()),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
                  children: [
                    if (list.isEmpty)
                      EmptyState(icon: Icons.notifications_none_rounded, title: t.noNotifications, message: t.noNotificationsHint),
                    for (final n in list)
                      Builder(
                        builder: (context) {
                          final (icon, title, body) = notificationText(context, n);
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: SoftCard(
                              padding: const EdgeInsets.all(14),
                              color: n.readAt == null ? RestoColors.primarySoft : null,
                              onTap: () => _open(n),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  GoldIcon(icon, size: 42, filled: n.readAt == null),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
                                            ),
                                            Text(
                                              DateFormat.MMMd(locale).add_Hm().format(n.createdAt.toLocal()),
                                              style: const TextStyle(color: RestoColors.muted, fontSize: 11.5),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 3),
                                        Text(body, style: const TextStyle(height: 1.35)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Plats favoris et listes

/// Fiche d'un plat enregistré : photo, restaurant, prix ; indisponible grisé.
class SavedItemCard extends StatelessWidget {
  const SavedItemCard({super.key, required this.item, required this.onRemove});
  final SavedItem item;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final api = AppScope.read(context).api!.customer;
    final locale = Localizations.localeOf(context).toString();
    return SoftCard(
      padding: EdgeInsets.zero,
      radius: 18,
      onTap: item.available && item.branchId != null ? () => openRestaurant(context, item.branchId!, itemId: item.itemId) : null,
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
                  Opacity(
                    opacity: item.available ? 1 : 0.45,
                    child: NetImage(item.imagePath == null ? null : api.imageUrl(item.imagePath!)),
                  ),
                  if (!item.available)
                    Center(
                      child: StatusPill(label: t.unavailableNow, color: RestoColors.muted, dense: true),
                    ),
                  Positioned(
                    right: 6,
                    top: 6,
                    child: Material(
                      color: Colors.white,
                      shape: const CircleBorder(),
                      child: IconButton(
                        tooltip: t.removeAction,
                        visualDensity: VisualDensity.compact,
                        onPressed: onRemove,
                        icon: const Icon(Icons.favorite_rounded, color: RestoColors.primary, size: 20),
                      ),
                    ),
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
                      Text(' ${item.rating}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    ],
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

Widget _grid(List<Widget> children) => LayoutBuilder(
  builder: (context, box) {
    final cols = (box.maxWidth / 210).floor().clamp(2, 6);
    final w = (box.maxWidth - (cols - 1) * 12) / cols;
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [for (final c in children) SizedBox(width: w, child: c)],
    );
  },
);

/// Plats favoris du client.
class SavedDishesView extends StatefulWidget {
  const SavedDishesView({super.key});

  @override
  State<SavedDishesView> createState() => _SavedDishesViewState();
}

class _SavedDishesViewState extends State<SavedDishesView> {
  late Future<(List<SavedItem>, List<CustomerList>)> _data = AppScope.read(context).api!.customer.savedItems();

  void _reload() => setState(() => _data = AppScope.read(context).api!.customer.savedItems());

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return FutureBuilder(
      future: _data,
      builder: (context, snap) {
        if (snap.hasError) {
          return Center(
            child: TextButton(onPressed: _reload, child: Text(t.retry)),
          );
        }
        if (!snap.hasData) {
          return const Padding(
            padding: EdgeInsets.all(30),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final (favorites, _) = snap.data!;
        if (favorites.isEmpty) {
          return EmptyState(icon: Icons.ramen_dining_outlined, title: t.noFavoriteDishes, message: t.noFavoriteDishesHint);
        }
        return _grid([
          for (final i in favorites)
            SavedItemCard(
              item: i,
              onRemove: () async {
                try {
                  await AppScope.read(context).api!.customer.setItemFavorite(i.itemId, false);
                  _reload();
                } catch (e) {
                  if (context.mounted) showError(context, e);
                }
              },
            ),
        ]);
      },
    );
  }
}

/// Listes personnelles (créer, renommer, supprimer, retirer un plat).
class ListsView extends StatefulWidget {
  const ListsView({super.key});

  @override
  State<ListsView> createState() => _ListsViewState();
}

class _ListsViewState extends State<ListsView> {
  late Future<(List<SavedItem>, List<CustomerList>)> _data = AppScope.read(context).api!.customer.savedItems();

  void _reload() => setState(() => _data = AppScope.read(context).api!.customer.savedItems());

  Future<void> _run(Future<void> Function() f) async {
    try {
      await f();
      _reload();
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final api = AppScope.read(context).api!.customer;
    return FutureBuilder(
      future: _data,
      builder: (context, snap) {
        if (snap.hasError) {
          return Center(
            child: TextButton(onPressed: _reload, child: Text(t.retry)),
          );
        }
        if (!snap.hasData) {
          return const Padding(
            padding: EdgeInsets.all(30),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final (_, lists) = snap.data!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: GoldButton(
                label: t.newList,
                icon: Icons.playlist_add_rounded,
                expand: false,
                onPressed: () async {
                  final name = await askListName(context);
                  if (name != null) await _run(() => api.createList(name));
                },
              ),
            ),
            const SizedBox(height: 14),
            if (lists.isEmpty) EmptyState(icon: Icons.playlist_play_rounded, title: t.noLists, message: t.noListsHint),
            for (final l in lists) ...[
              GoldHeaderCard(
                title: l.name,
                titleIcon: Icons.playlist_play_rounded,
                badge: PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert_rounded, color: Colors.white),
                  onSelected: (v) async {
                    if (v == 'rename') {
                      final name = await askListName(context, initial: l.name);
                      if (name != null) await _run(() => api.renameList(l.id, name));
                    } else if (await confirm(context, t.deleteListConfirm(l.name))) {
                      await _run(() => api.deleteList(l.id));
                    }
                  },
                  itemBuilder: (_) => [
                    PopupMenuItem(value: 'rename', child: Text(t.renameAction)),
                    PopupMenuItem(value: 'delete', child: Text(t.delete)),
                  ],
                ),
                info: Text(t.dishesCount(l.items.length)),
                child: l.items.isEmpty
                    ? Text(t.emptyListHint, style: const TextStyle(color: RestoColors.muted))
                    : _grid([
                        for (final i in l.items) SavedItemCard(item: i, onRemove: () => _run(() => api.setInList(l.id, i.itemId, false))),
                      ]),
              ),
              const SizedBox(height: 14),
            ],
          ],
        );
      },
    );
  }
}

Future<String?> askListName(BuildContext context, {String? initial}) async {
  final t = context.t;
  final c = TextEditingController(text: initial);
  final name = await showDialog<String>(
    context: context,
    builder: (d) => AlertDialog(
      title: Text(initial == null ? t.newList : t.renameAction),
      content: TextField(
        controller: c,
        autofocus: true,
        maxLength: 60,
        decoration: InputDecoration(labelText: t.listName, hintText: t.listNameExample),
        onSubmitted: (v) => Navigator.pop(d, v),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(d), child: Text(t.cancel)),
        FilledButton(onPressed: () => Navigator.pop(d, c.text), child: Text(t.save)),
      ],
    ),
  );
  final v = name?.trim() ?? '';
  return v.isEmpty ? null : v;
}

/// Ajouter un plat à ses favoris ou à une liste (feuille du bas).
Future<void> saveDishSheet(BuildContext context, {required String itemId, required String itemName}) async {
  if (!await ensureCustomerSignedIn(context) || !context.mounted) return;
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => _SaveDishSheet(itemId: itemId, itemName: itemName),
  );
}

class _SaveDishSheet extends StatefulWidget {
  const _SaveDishSheet({required this.itemId, required this.itemName});
  final String itemId;
  final String itemName;

  @override
  State<_SaveDishSheet> createState() => _SaveDishSheetState();
}

class _SaveDishSheetState extends State<_SaveDishSheet> {
  late Future<(Set<String>, List<(String, String, Set<String>)>)> _data = _load();

  Future<(Set<String>, List<(String, String, Set<String>)>)> _load() async {
    final api = AppScope.read(context).api!.customer;
    final r = await Future.wait<dynamic>([api.favoriteItemIds(), api.lists()]);
    return (r[0] as Set<String>, r[1] as List<(String, String, Set<String>)>);
  }

  Future<void> _run(Future<void> Function() f) async {
    try {
      await f();
      if (mounted) setState(() => _data = _load());
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final api = AppScope.read(context).api!.customer;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 0, 20, MediaQuery.viewInsetsOf(context).bottom + 16),
        child: FutureBuilder(
          future: _data,
          builder: (context, snap) {
            if (!snap.hasData) {
              return const Padding(
                padding: EdgeInsets.all(30),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            final (favorites, lists) = snap.data!;
            final fav = favorites.contains(widget.itemId);
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(t.saveDishTitle(widget.itemName), style: serifTitle(context, size: 22)),
                const SizedBox(height: 10),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  secondary: Icon(fav ? Icons.favorite_rounded : Icons.favorite_border_rounded, color: RestoColors.primary),
                  title: Text(t.favoriteDishes),
                  value: fav,
                  onChanged: (v) => _run(() => api.setItemFavorite(widget.itemId, v ?? false)),
                ),
                for (final (id, name, items) in lists)
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    secondary: const Icon(Icons.playlist_play_rounded, color: RestoColors.primaryDeep),
                    title: Text(name),
                    value: items.contains(widget.itemId),
                    onChanged: (v) => _run(() => api.setInList(id, widget.itemId, v ?? false)),
                  ),
                const SizedBox(height: 6),
                OutlinedButton.icon(
                  onPressed: () async {
                    final name = await askListName(context);
                    if (name == null) return;
                    await _run(() async {
                      final id = await api.createList(name);
                      await api.setInList(id, widget.itemId, true);
                    });
                  },
                  icon: const Icon(Icons.playlist_add_rounded),
                  label: Text(t.newList),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Coupons

String couponValue(BuildContext context, String kind, double? percent, int? amountMinor, String currency) {
  if (kind == 'percent') {
    final p = percent ?? 0;
    return '-${p.toStringAsFixed(p == p.roundToDouble() ? 0 : 1)} %';
  }
  final locale = Localizations.localeOf(context).toString();
  return '-${Money(amountMinor ?? 0, currency).format(locale, minorUnitOf(currency))}';
}

/// Portefeuille de coupons : code à copier, conditions, validité.
class CouponsView extends StatefulWidget {
  const CouponsView({super.key});

  @override
  State<CouponsView> createState() => _CouponsViewState();
}

class _CouponsViewState extends State<CouponsView> {
  late Future<List<WalletCoupon>> _data = AppScope.read(context).api!.customer.coupons();

  void _reload() => setState(() => _data = AppScope.read(context).api!.customer.coupons());

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final locale = Localizations.localeOf(context).toString();
    final api = AppScope.read(context).api!.customer;
    return FutureBuilder(
      future: _data,
      builder: (context, snap) {
        if (snap.hasError) {
          return Center(
            child: TextButton(onPressed: _reload, child: Text(t.retry)),
          );
        }
        if (!snap.hasData) {
          return const Padding(
            padding: EdgeInsets.all(30),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final list = snap.data!;
        if (list.isEmpty) return EmptyState(icon: Icons.confirmation_number_outlined, title: t.noCoupons, message: t.noCouponsHint);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(t.couponsHowTo, style: const TextStyle(color: RestoColors.muted)),
            const SizedBox(height: 12),
            for (final c in list)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Opacity(
                  opacity: c.usable ? 1 : 0.55,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2B2014), Color(0xFF5A4318)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: RestoColors.softShadow(8),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                couponValue(context, c.kind, c.percent, c.amountMinor, c.currency),
                                style: serifTitle(context, size: 30, color: RestoColors.primaryBright),
                              ),
                              Text(
                                c.name,
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                              ),
                              Text(
                                [
                                  c.brandName,
                                  if (c.minOrderMinor > 0)
                                    t.fromAmount(Money(c.minOrderMinor, c.currency).format(locale, minorUnitOf(c.currency))),
                                  if (c.endsAt != null) t.validUntil(DateFormat.yMMMd(locale).format(c.endsAt!.toLocal())),
                                ].join(' · '),
                                style: const TextStyle(color: Colors.white70, fontSize: 12),
                              ),
                              if (!c.usable)
                                Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: StatusPill(label: c.used > 0 ? t.couponUsed : t.couponExpired, color: Colors.white70, dense: true),
                                ),
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            if (c.code != null)
                              InkWell(
                                onTap: () async {
                                  await Clipboard.setData(ClipboardData(text: c.code!));
                                  if (context.mounted) showInfo(context, t.codeCopied);
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: RestoColors.primaryBright),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        c.code!,
                                        style: const TextStyle(
                                          color: RestoColors.primaryBright,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 1,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      const Icon(Icons.copy_rounded, size: 15, color: RestoColors.primaryBright),
                                    ],
                                  ),
                                ),
                              ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (c.usable && c.branchId != null)
                                  TextButton(
                                    onPressed: () => openRestaurant(context, c.branchId!),
                                    child: Text(t.feedOrder, style: const TextStyle(color: Colors.white)),
                                  ),
                                IconButton(
                                  tooltip: t.removeAction,
                                  onPressed: () async {
                                    try {
                                      await api.removeCoupon(c.id);
                                      _reload();
                                    } catch (e) {
                                      if (context.mounted) showError(context, e);
                                    }
                                  },
                                  icon: const Icon(Icons.delete_outline_rounded, color: Colors.white70),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

/// « Enregistrer » un coupon public (accueil) dans le portefeuille.
Future<void> saveCouponFlow(BuildContext context, String promotionId) async {
  final t = context.t;
  if (!await ensureCustomerSignedIn(context) || !context.mounted) return;
  try {
    await AppScope.read(context).api!.customer.saveCoupon(promotionId);
    if (context.mounted) showInfo(context, t.couponSaved);
  } catch (e) {
    if (context.mounted) showError(context, e);
  }
}
