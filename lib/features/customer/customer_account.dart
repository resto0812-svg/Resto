import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show RealtimeChannel;

import '../../app_state.dart';
import '../../core/locales.dart';
import '../../core/money.dart';
import '../../data/customer_api.dart';
import '../../data/menu_models.dart' show allergenCodes;
import '../../l10n/app_localizations.dart';
import '../../ui/app_version.dart';
import '../../ui/common.dart';
import '../../ui/kit.dart';
import '../../ui/theme.dart';
import '../menus/menu_widgets.dart' show allergenLabel, channelLabel;
import 'customer_home.dart';
import 'customer_shell.dart';
import 'reviews.dart';

String _money(BuildContext context, int minor, String currency) =>
    Money(minor, currency).format(Localizations.localeOf(context).toString(), minorUnitOf(currency));

// ---------------------------------------------------------------------------
// Mes commandes

class CustomerOrders extends StatefulWidget {
  const CustomerOrders({super.key});

  @override
  State<CustomerOrders> createState() => _CustomerOrdersState();
}

class _CustomerOrdersState extends State<CustomerOrders> {
  Future<List<CustomerOrder>>? _orders;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final api = AppScope.of(context).api!.customer;
    final wide = MediaQuery.sizeOf(context).width >= 900;
    if (api.user == null) {
      return customerSignInPrompt(
        context,
        icon: Icons.shopping_bag_outlined,
        title: t.customerOrders,
        message: t.ordersSignIn,
        onDone: () => setState(() {}),
      );
    }
    _orders ??= api.myOrders();
    return RefreshIndicator(
      onRefresh: () async => setState(() => _orders = api.myOrders()),
      child: FutureBuilder<List<CustomerOrder>>(
        future: _orders,
        builder: (context, snap) {
          final list = snap.data ?? const [];
          return ListView(
            padding: EdgeInsets.fromLTRB(wide ? 32 : 16, 12, wide ? 32 : 16, 170),
            children: [
              Text(t.customerOrders, style: serifTitle(context, size: 32)),
              const SizedBox(height: 12),
              if (!snap.hasData)
                const Center(
                  child: Padding(padding: EdgeInsets.all(30), child: CircularProgressIndicator()),
                )
              else if (list.isEmpty)
                EmptyState(
                  icon: Icons.receipt_long_outlined,
                  title: t.noCustomerOrders,
                  action: GoldButton(
                    label: t.discoverRestaurants,
                    expand: false,
                    onPressed: () async => CustomerScope.of(context).openTab(0),
                  ),
                )
              else
                for (final o in list)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: GoldHeaderCard(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CustomerOrderDetail(orderId: o.orderId))),
                      title: '${o.brandName} · #${o.number}',
                      titleIcon: Icons.storefront_rounded,
                      badge: HeaderBadge(text: DateFormat.MMMd(Localizations.localeOf(context).toString()).format(o.openedAt.toLocal())),
                      headerColor: o.acceptance == 'rejected' || o.status == 'cancelled' ? RestoColors.muted : null,
                      info: Text('${channelLabel(t, o.channel)} · ${_statusText(t, o.status, o.acceptance)}'),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(o.branchName, style: const TextStyle(color: RestoColors.muted)),
                          ),
                          Text(
                            _money(context, o.totalMinor, o.currency),
                            style: const TextStyle(fontWeight: FontWeight.w800, color: RestoColors.primaryDeep),
                          ),
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

String _statusText(AppLocalizations t, String status, String acceptance) {
  if (acceptance == 'rejected') return t.orderRejected;
  if (status == 'cancelled') return t.orderCancelled;
  if (status == 'closed') return t.orderDone;
  if (acceptance == 'pending') return t.orderWaitingConfirmation;
  return t.orderInProgress;
}

/// Suivi d'une commande en direct : envoyée, acceptée, en préparation, prête, terminée.
class CustomerOrderDetail extends StatefulWidget {
  const CustomerOrderDetail({super.key, required this.orderId, this.justPlaced = false});
  final String orderId;
  final bool justPlaced;

  @override
  State<CustomerOrderDetail> createState() => _CustomerOrderDetailState();
}

class _CustomerOrderDetailState extends State<CustomerOrderDetail> {
  Map<String, dynamic>? _order;
  RealtimeChannel? _channel;
  Object? _error;

  /// Lignes déjà notées par le client → note.
  Map<String, int> _reviewed = const {};

  Future<void> _loadReviewed() async {
    try {
      final r = await AppScope.read(context).api!.customer.myReviewedLines();
      if (mounted) setState(() => _reviewed = r);
    } catch (_) {}
  }

  Future<void> _rate(Map line) async {
    final ok = await writeItemReview(
      context,
      orderItemId: line['id'] as String,
      itemName: line['item_name'] as String,
      current: _reviewed[line['id']],
    );
    if (ok) _loadReviewed();
  }

  @override
  void initState() {
    super.initState();
    _load();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadReviewed());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _channel = AppScope.read(context).api!.customer.watchOrder(widget.orderId, _load);
    });
  }

  @override
  void dispose() {
    if (_channel != null) AppScope.read(context).api!.customer.unwatch(_channel!);
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final o = await AppScope.read(context).api!.customer.order(widget.orderId);
      if (mounted) setState(() => _order = o);
    } catch (e) {
      if (mounted) setState(() => _error = e);
    }
  }

  /// 0 envoyée, 1 acceptée, 2 en préparation, 3 prête, 4 terminée.
  int _step(Map<String, dynamic> o) {
    if (o['status'] == 'closed') return 4;
    final items = (o['order_items'] as List? ?? const []).where((i) => (i as Map)['prep_status'] != 'cancelled').toList();
    if (o['acceptance'] == 'pending') return 0;
    if (items.isNotEmpty && items.every((i) => ['ready', 'served'].contains((i as Map)['prep_status']))) {
      return items.every((i) => (i as Map)['prep_status'] == 'served') ? 4 : 3;
    }
    if (items.any((i) => ['sent', 'preparing', 'ready'].contains((i as Map)['prep_status']))) return 2;
    return 1;
  }

  Future<void> _review() async {
    final t = context.t;
    var rating = 5;
    final comment = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (d) => StatefulBuilder(
        builder: (d, set) => AlertDialog(
          title: Text(t.rateOrder),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var s = 1; s <= 5; s++)
                    IconButton(
                      onPressed: () => set(() => rating = s),
                      icon: Icon(Icons.star_rounded, size: 34, color: s <= rating ? RestoColors.primary : RestoColors.line),
                    ),
                ],
              ),
              TextField(
                controller: comment,
                maxLength: 1000,
                maxLines: 3,
                decoration: InputDecoration(labelText: t.reviewComment),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(d, false), child: Text(t.cancel)),
            FilledButton(onPressed: () => Navigator.pop(d, true), child: Text(t.send)),
          ],
        ),
      ),
    );
    if (ok != true || !mounted) return;
    try {
      await AppScope.read(context).api!.customer.review(widget.orderId, rating, comment.text.trim().isEmpty ? null : comment.text.trim());
      if (mounted) showInfo(context, t.thanksForReview);
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final o = _order;
    return Scaffold(
      appBar: AppBar(title: Text(o == null ? t.customerOrders : t.orderNumber(o['number'] as int), style: serifTitle(context, size: 24))),
      body: o == null
          ? Center(child: _error == null ? const CircularProgressIndicator() : Text(t.errorUnknown))
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
                  children: [
                    if (widget.justPlaced)
                      SoftCard(
                        color: RestoColors.primarySoft,
                        child: Row(
                          children: [
                            const GoldIcon(Icons.check_rounded, size: 46, filled: true),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(t.orderSentToRestaurant, style: const TextStyle(fontWeight: FontWeight.w600)),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 14),
                    if (o['acceptance'] == 'rejected' || o['status'] == 'cancelled')
                      EmptyState(
                        icon: Icons.block_rounded,
                        title: o['acceptance'] == 'rejected' ? t.orderRejected : t.orderCancelled,
                        message: o['reject_reason'] as String?,
                      )
                    else
                      _Stepper(step: _step(o)),
                    const SizedBox(height: 16),
                    SoftCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SectionHeading(title: t.orderSummary, icon: Icons.receipt_long_rounded),
                          const SizedBox(height: 10),
                          for (final i in (o['order_items'] as List? ?? const []))
                            if ((i as Map)['prep_status'] != 'cancelled')
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 3),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        '${i['quantity']} × ${i['item_name']}${(i['variant_name'] as String? ?? '').isEmpty ? '' : ' (${i['variant_name']})'}',
                                      ),
                                    ),
                                    Text(_money(context, (i['line_total_minor'] as num).toInt(), o['currency'] as String)),
                                    if (o['status'] == 'closed' || i['prep_status'] == 'served') ...[
                                      const SizedBox(width: 6),
                                      TextButton.icon(
                                        onPressed: () => _rate(i),
                                        icon: Icon(
                                          _reviewed.containsKey(i['id']) ? Icons.star_rounded : Icons.star_outline_rounded,
                                          size: 18,
                                          color: RestoColors.primary,
                                        ),
                                        label: Text(_reviewed.containsKey(i['id']) ? '${_reviewed[i['id']]}/5' : t.rateShort),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                          const Divider(height: 18),
                          Row(
                            children: [
                              Expanded(
                                child: Text(t.total, style: const TextStyle(fontWeight: FontWeight.w800)),
                              ),
                              Text(
                                _money(context, (o['total_minor'] as num).toInt(), o['currency'] as String),
                                style: const TextStyle(fontWeight: FontWeight.w800, color: RestoColors.primaryDeep, fontSize: 17),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (o['acceptance'] == 'pending' && o['status'] == 'open')
                      GoldButton(
                        label: t.cancelOrder,
                        outlined: true,
                        onPressed: () async {
                          if (!await confirm(context, t.cancelOrderConfirm)) return;
                          try {
                            if (!context.mounted) return;
                            await AppScope.read(context).api!.customer.cancelOrder(widget.orderId);
                            await _load();
                          } catch (e) {
                            if (context.mounted) showError(context, e);
                          }
                        },
                      ),
                    if (o['status'] == 'closed') GoldButton(label: t.rateOrder, icon: Icons.star_rounded, onPressed: _review),
                  ],
                ),
              ),
            ),
    );
  }
}

class _Stepper extends StatelessWidget {
  const _Stepper({required this.step});
  final int step;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final steps = [
      (Icons.send_rounded, t.stepSent),
      (Icons.thumb_up_alt_outlined, t.stepAccepted),
      (Icons.soup_kitchen_outlined, t.stepPreparing),
      (Icons.room_service_outlined, t.stepReady),
      (Icons.check_circle_outline_rounded, t.stepDone),
    ];
    return SoftCard(
      child: Column(
        children: [
          for (var i = 0; i < steps.length; i++)
            Row(
              children: [
                Column(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: i <= step ? RestoColors.brandGradient : null,
                        color: i <= step ? null : RestoColors.sunken,
                      ),
                      child: Icon(steps[i].$1, size: 18, color: i <= step ? Colors.white : RestoColors.muted),
                    ),
                    if (i < steps.length - 1) Container(width: 2, height: 20, color: i < step ? RestoColors.primary : RestoColors.line),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: i < steps.length - 1 ? 20 : 0),
                    child: Text(
                      steps[i].$2,
                      style: TextStyle(
                        fontWeight: i == step ? FontWeight.w800 : FontWeight.w500,
                        color: i <= step ? RestoColors.ink : RestoColors.muted,
                      ),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Profil personnel

class CustomerProfilePage extends StatefulWidget {
  const CustomerProfilePage({super.key});

  @override
  State<CustomerProfilePage> createState() => _CustomerProfilePageState();
}

class _CustomerProfilePageState extends State<CustomerProfilePage> {
  Future<(CustomerProfile, List<CustomerAddress>, List<LoyaltyBalance>)>? _data;
  final _name = TextEditingController();
  final _phone = TextEditingController();
  CustomerProfile? _profile;

  Future<(CustomerProfile, List<CustomerAddress>, List<LoyaltyBalance>)> _load() async {
    final api = AppScope.read(context).api!.customer;
    final r = await Future.wait<dynamic>([api.profile(), api.addresses(), api.loyalty().catchError((_) => <LoyaltyBalance>[])]);
    final p = r[0] as CustomerProfile;
    _profile = p;
    _name.text = p.fullName ?? '';
    _phone.text = p.phone ?? '';
    return (p, r[1] as List<CustomerAddress>, r[2] as List<LoyaltyBalance>);
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final p = _profile!;
    p
      ..fullName = _name.text
      ..phone = _phone.text;
    try {
      await AppScope.read(context).api!.customer.saveProfile(p);
      if (mounted) showInfo(context, context.t.saved);
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  Future<void> _addAddress() async {
    final t = context.t;
    final label = TextEditingController();
    final address = TextEditingController();
    final instructions = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (d) => AlertDialog(
        title: Text(t.addAddress),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: label,
                maxLength: 60,
                decoration: InputDecoration(labelText: t.addressLabel, hintText: t.addressLabelHint),
              ),
              TextField(
                controller: address,
                maxLength: 500,
                maxLines: 2,
                minLines: 1,
                decoration: InputDecoration(labelText: t.deliveryAddress),
              ),
              TextField(
                controller: instructions,
                maxLength: 500,
                decoration: InputDecoration(labelText: t.deliveryInstructions),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(d, false), child: Text(t.cancel)),
          FilledButton(onPressed: () => Navigator.pop(d, true), child: Text(t.save)),
        ],
      ),
    );
    if (ok != true || address.text.trim().length < 3 || !mounted) return;
    try {
      await AppScope.read(context).api!.customer.saveAddress(
        address.text.trim(),
        label.text.trim().isEmpty ? null : label.text.trim(),
        instructions.text.trim().isEmpty ? null : instructions.text.trim(),
      );
      setState(() => _data = _load());
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final state = AppScope.of(context);
    final api = state.api!;
    final wide = MediaQuery.sizeOf(context).width >= 900;
    if (api.user == null) {
      return customerSignInPrompt(
        context,
        icon: Icons.person_outline_rounded,
        title: t.customerProfile,
        message: t.profileSignIn,
        onDone: () => setState(() {}),
      );
    }
    _data ??= _load();
    return FutureBuilder(
      future: _data,
      builder: (context, snap) {
        if (snap.hasError) {
          return Center(
            child: TextButton(onPressed: () => setState(() => _data = _load()), child: Text(t.retry)),
          );
        }
        if (!snap.hasData) return const Center(child: CircularProgressIndicator());
        final (p, addresses, loyalty) = snap.data!;
        final email = api.user!.email ?? '';
        final df = DateFormat.yMMMMd(Localizations.localeOf(context).toString());
        final identity = SoftCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: const BoxDecoration(gradient: RestoColors.brandGradient, shape: BoxShape.circle),
                    alignment: Alignment.center,
                    child: Text(
                      (p.fullName ?? email).isEmpty ? '?' : (p.fullName ?? email).characters.first.toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text((p.fullName ?? '').isEmpty ? email : p.fullName!, style: serifTitle(context, size: 24)),
                        Text(email, style: const TextStyle(color: RestoColors.muted)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _name,
                maxLength: 120,
                decoration: InputDecoration(labelText: t.fullName, prefixIcon: const Icon(Icons.badge_outlined)),
              ),
              TextField(
                controller: _phone,
                maxLength: 32,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(labelText: t.phone, prefixIcon: const Icon(Icons.call_outlined)),
              ),
              OutlinedButton.icon(
                onPressed: () async {
                  final d = await showDatePicker(
                    context: context,
                    initialDate: p.birthday ?? DateTime(1990),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  if (d != null) setState(() => p.birthday = d);
                },
                icon: const Icon(Icons.cake_outlined, size: 18),
                label: Text(p.birthday == null ? t.birthday : '${t.birthday} : ${df.format(p.birthday!)}'),
              ),
            ],
          ),
        );
        final addressesCard = SoftCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SectionHeading(
                title: t.myAddresses,
                icon: Icons.home_outlined,
                trailing: TextButton.icon(onPressed: _addAddress, icon: const Icon(Icons.add_rounded, size: 18), label: Text(t.add)),
              ),
              const SizedBox(height: 8),
              if (addresses.isEmpty) Text(t.noAddresses, style: const TextStyle(color: RestoColors.muted)),
              for (final a in addresses)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.location_on_outlined, color: RestoColors.primaryDeep),
                  title: Text(a.label ?? a.address, style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: a.label == null ? null : Text(a.address),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline_rounded),
                    onPressed: () async {
                      await AppScope.read(context).api!.customer.deleteAddress(a.id);
                      setState(() => _data = _load());
                    },
                  ),
                ),
            ],
          ),
        );
        final paymentCard = SoftCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SectionHeading(title: t.preferredPayment, icon: Icons.account_balance_wallet_outlined, subtitle: t.preferredPaymentHint),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final (v, label, icon) in [
                    ('cash', t.payCash, Icons.payments_outlined),
                    ('card', t.payCard, Icons.credit_card_rounded),
                    ('mobile_wallet', t.payMobileWallet, Icons.phone_iphone_rounded),
                    ('transfer', t.payTransfer, Icons.account_balance_outlined),
                  ])
                    GoldPill(
                      label: label,
                      icon: icon,
                      dense: true,
                      selected: p.preferredPayment == v,
                      onTap: () => setState(() => p.preferredPayment = v),
                    ),
                ],
              ),
            ],
          ),
        );
        final loyaltyCard = SoftCard(
          color: RestoColors.primarySoft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SectionHeading(title: t.loyaltyProgram, icon: Icons.workspace_premium_outlined),
              const SizedBox(height: 8),
              if (loyalty.isEmpty) Text(t.noLoyaltyYet, style: const TextStyle(color: RestoColors.muted)),
              for (final l in loyalty) ...[
                Row(
                  children: [
                    Expanded(
                      child: Text(l.organizationName, style: const TextStyle(fontWeight: FontWeight.w600)),
                    ),
                    Text(t.loyaltyPoints(l.points), style: serifTitle(context, size: 22)),
                  ],
                ),
                if (l.rewardPoints != null && l.rewardPoints! > 0) ...[
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: (l.points / l.rewardPoints!).clamp(0, 1).toDouble(),
                      minHeight: 8,
                      color: RestoColors.primary,
                      backgroundColor: Colors.white,
                    ),
                  ),
                  if (l.rewardMinor != null)
                    Text(
                      t.loyaltyNextReward(l.rewardPoints!, _money(context, l.rewardMinor!, l.currency)),
                      style: const TextStyle(color: RestoColors.muted, fontSize: 12),
                    ),
                ],
                const SizedBox(height: 10),
              ],
            ],
          ),
        );
        final healthCard = SoftCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SectionHeading(title: t.healthAllergies, icon: Icons.health_and_safety_outlined),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final a in allergenCodes)
                    FilterChip(
                      label: Text(allergenLabel(t, a)),
                      selected: p.allergies.contains(a),
                      onSelected: (on) => setState(() => p.allergies = on ? [...p.allergies, a] : ([...p.allergies]..remove(a))),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(t.spiceLevel, style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              PillBar<int?>(
                dense: true,
                items: [PillItem(0, t.spiceNone), PillItem(1, t.spiceMild), PillItem(2, t.spiceMedium), PillItem(3, t.spiceHot)],
                selected: p.spiceLevel,
                onSelected: (v) => setState(() => p.spiceLevel = v),
              ),
            ],
          ),
        );
        final notifCard = SoftCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SectionHeading(title: t.settingsNotifications, icon: Icons.notifications_none_rounded),
              for (final (k, label) in [
                ('order_updates', t.notifOrderUpdates),
                ('promotions', t.notifPromotions),
                ('reservation_reminders', t.notifReservationReminders),
              ])
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(label),
                  value: p.pref(k),
                  activeTrackColor: RestoColors.primary,
                  onChanged: (v) => setState(() => p.prefs[k] = v),
                ),
            ],
          ),
        );
        final prefsCard = SoftCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SectionHeading(title: t.preferences, icon: Icons.tune_rounded),
              const SizedBox(height: 10),
              Text(t.languageLabel, style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final e in languageNames.entries)
                    GoldPill(
                      label: e.value,
                      dense: true,
                      selected: state.locale != null && refLocaleCode(state.locale!) == e.key,
                      onTap: () => state.setLocale(localeFromRef(e.key)),
                    ),
                ],
              ),
            ],
          ),
        );
        final left = [
          identity,
          const SizedBox(height: 14),
          addressesCard,
          const SizedBox(height: 14),
          paymentCard,
          const SizedBox(height: 14),
          loyaltyCard,
        ];
        final right = [healthCard, const SizedBox(height: 14), notifCard, const SizedBox(height: 14), prefsCard];
        return ListView(
          padding: EdgeInsets.fromLTRB(wide ? 32 : 16, 12, wide ? 32 : 16, 170),
          children: [
            Text(t.personalProfile, style: serifTitle(context, size: 32)),
            Text(t.personalProfileHint, style: const TextStyle(color: RestoColors.muted)),
            const SizedBox(height: 14),
            if (wide)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: left),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: right),
                  ),
                ],
              )
            else ...[
              ...left,
              const SizedBox(height: 14),
              ...right,
            ],
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: GoldButton(
                    label: t.signOut,
                    icon: Icons.logout_rounded,
                    outlined: true,
                    onPressed: () async {
                      await api.signOut();
                      // Retour à l'écran de connexion (choix Client / Entreprise à l'inscription).
                      state.setCustomerMode(false);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GoldButton(label: t.saveChanges, icon: Icons.check_rounded, onPressed: _save),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (api.accountType == 'business')
              Center(
                child: TextButton.icon(
                  onPressed: () => state.setCustomerMode(false),
                  icon: const Icon(Icons.storefront_rounded, size: 18),
                  label: Text(t.restaurantSpace),
                ),
              ),
            const AppVersionLabel(),
          ],
        );
      },
    );
  }
}
