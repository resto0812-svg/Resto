import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../app_state.dart';
import '../../config/env.dart';
import '../../core/money.dart';
import '../../data/customer_api.dart';
import '../../ui/common.dart';
import '../../ui/kit.dart';
import '../../ui/qr_view.dart';
import '../../ui/theme.dart';
import 'customer_account.dart';
import 'customer_shell.dart';
import 'restaurant_page.dart';

/// Lien d'invitation à une commande groupée (jeton secret, aucune donnée personnelle).
String groupOrderUrl(String token) => '${Env.siteUrl}/?g=$token';

/// Démarre une commande groupée dans ce restaurant et ouvre son écran.
Future<void> startGroupOrder(BuildContext context, String branchId) async {
  if (!await ensureCustomerSignedIn(context) || !context.mounted) return;
  final api = AppScope.read(context).api!.customer;
  try {
    String? name;
    try {
      name = (await api.profile()).fullName?.split(' ').first;
    } catch (_) {}
    final token = await api.createGroupOrder(branchId, name);
    if (!context.mounted) return;
    final scope = CustomerScope.of(context);
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CustomerScope(
          cart: scope.notifier!,
          openTab: scope.openTab,
          child: GroupOrderScreen(token: token),
        ),
      ),
    );
  } catch (e) {
    if (context.mounted) showError(context, e);
  }
}

class GroupOrderScreen extends StatefulWidget {
  const GroupOrderScreen({super.key, required this.token});
  final String token;

  @override
  State<GroupOrderScreen> createState() => _GroupOrderScreenState();
}

class _GroupOrderScreenState extends State<GroupOrderScreen> {
  GroupOrder? _group;
  PublicMenu? _menu;
  Object? _error;
  Timer? _timer;
  String _channel = 'takeaway';
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _address = TextEditingController();
  final _instructions = TextEditingController();
  final _form = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());
  }

  Future<void> _start() async {
    if (!await ensureCustomerSignedIn(context) || !mounted) {
      if (mounted) Navigator.pop(context);
      return;
    }
    final api = AppScope.read(context).api!.customer;
    api
        .profile()
        .then((p) {
          if (_name.text.isEmpty) _name.text = p.fullName ?? '';
          if (_phone.text.isEmpty) _phone.text = p.phone ?? '';
        })
        .catchError((_) {});
    await _load();
    // Les plats des convives arrivent en direct (toutes les 8 secondes tant que la commande est ouverte).
    _timer = Timer.periodic(const Duration(seconds: 8), (_) {
      if (mounted && (_group?.open ?? false)) _load();
    });
  }

  Future<void> _load() async {
    final api = AppScope.read(context).api!.customer;
    try {
      final g = await api.groupOrder(widget.token);
      final m = _menu ?? await api.menu(g.branchId);
      if (mounted) {
        setState(() {
          _group = g;
          _menu = m;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _error = e);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in [_name, _phone, _address, _instructions]) {
      c.dispose();
    }
    super.dispose();
  }

  /// Ouvre la carte du restaurant : les plats choisis rejoignent la commande groupée.
  Future<void> _addDishes() async {
    final scope = CustomerScope.of(context);
    final cart = CustomerCart()..groupToken = widget.token;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CustomerScope(
          cart: cart,
          openTab: scope.openTab,
          child: RestaurantPage(branchId: _group!.branchId),
        ),
      ),
    );
    cart.dispose();
    _load();
  }

  Future<void> _remove(GroupLine l) async {
    try {
      await AppScope.read(context).api!.customer.removeGroupLine(l.id);
      _load();
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  Future<void> _place() async {
    final t = context.t;
    if (!_form.currentState!.validate()) return;
    try {
      final r = await AppScope.read(context).api!.customer.placeGroupOrder(
        token: widget.token,
        channel: _channel,
        phone: _phone.text.trim(),
        name: _name.text.trim(),
        address: _channel == 'delivery' ? _address.text.trim() : null,
        instructions: _channel == 'delivery' ? _instructions.text.trim() : null,
      );
      if (!mounted) return;
      showInfo(context, t.groupOrderPlaced);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => CustomerOrderDetail(orderId: r['order_id'] as String, justPlaced: true)),
      );
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  Future<void> _cancel() async {
    final t = context.t;
    if (!await confirm(context, t.cancelGroupOrderConfirm)) return;
    if (!mounted) return;
    try {
      await AppScope.read(context).api!.customer.cancelGroupOrder(widget.token);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final g = _group;
    final m = _menu;
    Widget body;
    if (g == null || m == null) {
      body = _error != null
          ? Center(
              child: TextButton(onPressed: _load, child: Text(t.retry)),
            )
          : const Center(child: CircularProgressIndicator());
    } else {
      body = _content(context, g, m);
    }
    return Scaffold(
      appBar: AppBar(title: Text(t.groupOrderTitle, style: serifTitle(context, size: 24))),
      body: body,
    );
  }

  Widget _content(BuildContext context, GroupOrder g, PublicMenu m) {
    final t = context.t;
    final locale = Localizations.localeOf(context).toString();
    String money(int v) => Money(v, m.currency).format(locale, minorUnitOf(m.currency));
    final items = {for (final i in m.categories.expand((c) => c.items)) i.id: i};
    // Prix d'une ligne d'après la carte (à emporter / en livraison).
    (String, String, int) describe(GroupLine l) {
      final item = items[l.itemId];
      if (item == null) return ('—', '', 0);
      final variant = item.variants.where((v) => v.id == l.variantId).firstOrNull;
      final mods = [
        for (final gr in item.groups)
          for (final mo in gr.modifiers)
            if (l.modifierIds.contains(mo.id)) mo,
      ];
      final unit = (variant?.priceFor('takeaway') ?? 0) + mods.fold<int>(0, (a, mo) => a + mo.priceFor('takeaway'));
      final title = [item.name, if (variant != null && variant.name.isNotEmpty && item.variants.length > 1) variant.name].join(' · ');
      final detail = [for (final mo in mods) mo.name, if (l.note != null) '« ${l.note} »'].join(', ');
      return (title, detail, unit * l.quantity);
    }

    final byPerson = <String, List<GroupLine>>{};
    for (final l in g.lines) {
      byPerson.putIfAbsent(l.participantName, () => []).add(l);
    }
    final total = g.lines.fold<int>(0, (a, l) => a + describe(l).$3);
    final url = groupOrderUrl(g.token);
    final wide = MediaQuery.sizeOf(context).width >= 900;

    final share = SoftCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          QrView(data: url, size: 104),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t.groupInviteTitle, style: serifTitle(context, size: 20)),
                const SizedBox(height: 4),
                Text(t.groupInviteHint, style: const TextStyle(color: RestoColors.muted, fontSize: 12.5)),
                const SizedBox(height: 8),
                GoldButton(
                  label: t.copyLink,
                  icon: Icons.link_rounded,
                  expand: false,
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: url));
                    if (context.mounted) showInfo(context, t.feedLinkCopied);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );

    final lines = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (g.lines.isEmpty) EmptyState(icon: Icons.restaurant_menu_rounded, title: t.groupEmpty, message: t.groupEmptyHint),
        for (final e in byPerson.entries) ...[
          GoldHeaderCard(
            title: e.key,
            titleIcon: Icons.person_outline_rounded,
            badge: HeaderBadge(text: money(e.value.fold<int>(0, (a, l) => a + describe(l).$3))),
            child: Column(
              children: [
                for (final l in e.value)
                  Builder(
                    builder: (context) {
                      final (title, detail, price) = describe(l);
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Text(
                              '${l.quantity} ×',
                              style: const TextStyle(fontWeight: FontWeight.w800, color: RestoColors.primaryDeep),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                                  if (detail.isNotEmpty) Text(detail, style: const TextStyle(color: RestoColors.muted, fontSize: 12)),
                                ],
                              ),
                            ),
                            Text(money(price), style: const TextStyle(fontWeight: FontWeight.w700)),
                            if (g.open && (l.mine || g.isHost))
                              IconButton(
                                tooltip: t.removeAction,
                                visualDensity: VisualDensity.compact,
                                onPressed: () => _remove(l),
                                icon: const Icon(Icons.close_rounded, size: 18, color: RestoColors.muted),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
      ],
    );

    final header = SoftCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const GoldIcon(Icons.groups_2_rounded, size: 54, filled: true),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(g.brandName, style: serifTitle(context, size: 24)),
                Text(t.groupHostedBy(g.hostName), style: const TextStyle(color: RestoColors.muted)),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    StatusPill(
                      label: switch (g.status) {
                        'open' => t.groupStatusOpen(DateFormat.Hm(locale).format(g.expiresAt.toLocal())),
                        'placed' => t.groupStatusPlaced,
                        'cancelled' => t.groupStatusCancelled,
                        _ => t.groupStatusExpired,
                      },
                      color: g.open ? const Color(0xFF2E9E5B) : RestoColors.muted,
                      dense: true,
                    ),
                    StatusPill(label: t.groupParticipants(byPerson.length), color: RestoColors.primaryDeep, dense: true),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );

    final checkout = g.isHost && g.open
        ? SoftCard(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _form,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SectionHeading(title: t.groupCheckoutTitle, icon: Icons.receipt_long_rounded),
                  const SizedBox(height: 10),
                  if (m.acceptsDelivery)
                    PillBar<String>(
                      dense: true,
                      items: [PillItem('takeaway', t.channelTakeaway), PillItem('delivery', t.channelDelivery)],
                      selected: _channel,
                      onSelected: (v) => setState(() => _channel = v),
                    ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _name,
                    maxLength: 120,
                    decoration: InputDecoration(labelText: t.yourName, counterText: ''),
                    validator: (v) => (v ?? '').trim().isEmpty ? t.fieldRequired : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _phone,
                    maxLength: 32,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(labelText: t.phone, counterText: ''),
                    validator: (v) => _channel == 'delivery' && (v ?? '').trim().length < 6 ? t.fieldRequired : null,
                  ),
                  if (_channel == 'delivery') ...[
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _address,
                      maxLength: 300,
                      decoration: InputDecoration(labelText: t.deliveryAddress, counterText: ''),
                      validator: (v) => (v ?? '').trim().length < 5 ? t.fieldRequired : null,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _instructions,
                      maxLength: 300,
                      decoration: InputDecoration(labelText: t.deliveryInstructions, counterText: ''),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Text(t.estimatedTotal, style: const TextStyle(fontWeight: FontWeight.w600)),
                      ),
                      Text(money(total + (_channel == 'delivery' ? m.deliveryFeeMinor : 0)), style: serifTitle(context, size: 26)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  GoldButton(label: t.groupPlaceOrder, icon: Icons.send_rounded, onPressed: g.lines.isEmpty ? null : _place),
                  TextButton(onPressed: _cancel, child: Text(t.cancelGroupOrder)),
                ],
              ),
            ),
          )
        : null;

    final actions = g.open
        ? GoldButton(label: t.groupAddMyDishes, icon: Icons.add_rounded, outlined: !g.isHost || g.lines.isNotEmpty, onPressed: _addDishes)
        : SoftCard(
            color: RestoColors.primarySoft,
            padding: const EdgeInsets.all(14),
            child: Text(g.status == 'placed' ? t.groupPlacedInfo(g.hostName) : t.groupClosedInfo),
          );

    final left = [header, const SizedBox(height: 14), actions, const SizedBox(height: 14), lines];
    final right = [
      share,
      if (checkout != null) ...[const SizedBox(height: 14), checkout],
    ];
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: EdgeInsets.fromLTRB(wide ? 32 : 16, 8, wide ? 32 : 16, 40),
        children: [
          if (wide)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: left),
                ),
                const SizedBox(width: 20),
                Expanded(
                  flex: 2,
                  child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: right),
                ),
              ],
            )
          else ...[
            ...left,
            if (g.open) ...[const SizedBox(height: 14), ...right],
          ],
        ],
      ),
    );
  }
}
