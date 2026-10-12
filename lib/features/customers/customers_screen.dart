import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../app_state.dart';
import '../../core/money.dart';
import '../../data/models.dart';
import '../../ui/common.dart';
import '../../ui/kit.dart';
import '../../ui/theme.dart';
import '../menus/menu_widgets.dart' show allergenLabel, channelLabel;
import 'offers_tab.dart';

/// Clients du restaurant : fiche propre à l'organisation (jamais leur activité
/// chez un autre restaurant), commandes, dépenses, allergies partagées, notes.
class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key, required this.membership});
  final Membership membership;

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  late Future<(List<Map<String, dynamic>>, Map<String, int>)> _data = _load();
  String _query = '';
  String _sort = 'recent';
  int _tab = 0;

  Future<(List<Map<String, dynamic>>, Map<String, int>)> _load() async {
    final state = AppScope.read(context);
    final r = await Future.wait<dynamic>([state.api!.restaurantCustomers(widget.membership.organizationId), state.references()]);
    return (r[0] as List<Map<String, dynamic>>, {for (final c in (r[1] as References).currencies) c.code: c.minorUnit});
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final side = MediaQuery.sizeOf(context).width < 600 ? 16.0 : 22.0;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Padding(
        padding: EdgeInsets.fromLTRB(side, 8, side, 6),
        child: PillBar<int>(
          items: [
            PillItem(0, t.customersTab, icon: Icons.people_alt_outlined),
            PillItem(1, t.offersTab, icon: Icons.local_offer_outlined),
            PillItem(2, t.loyaltyTab, icon: Icons.workspace_premium_outlined),
          ],
          selected: _tab,
          onSelected: (i) => setState(() => _tab = i),
        ),
      ),
      Expanded(
        child: switch (_tab) {
          1 => OffersTab(membership: widget.membership),
          2 => LoyaltyTab(membership: widget.membership),
          _ => _customers(context, side),
        },
      ),
    ]);
  }

  Widget _customers(BuildContext context, double side) {
    final t = context.t;
    return FutureBuilder(
      future: _data,
      builder: (context, snap) {
        if (snap.hasError) return Center(child: TextButton(onPressed: () => setState(() => _data = _load()), child: Text(t.retry)));
        if (!snap.hasData) return const Center(child: CircularProgressIndicator());
        final (all, units) = snap.data!;
        final q = _query.trim().toLowerCase();
        final list = all
            .where((c) => q.isEmpty || '${c['display_name'] ?? ''} ${c['phone'] ?? ''}'.toLowerCase().contains(q))
            .toList()
          ..sort((a, b) => switch (_sort) {
                'orders' => (b['orders_count'] as num).compareTo(a['orders_count'] as num),
                'spent' => (b['total_spent_minor'] as num).compareTo(a['total_spent_minor'] as num),
                _ => (b['last_order_at'] as String).compareTo(a['last_order_at'] as String),
              });
        final regulars = all.where((c) => (c['orders_count'] as num) >= 3).length;
        return RefreshIndicator(
          onRefresh: () async => setState(() => _data = _load()),
          child: ListView(padding: EdgeInsets.fromLTRB(side, 8, side, 40), children: [
            Wrap(spacing: 12, runSpacing: 10, children: [
              CounterTile(icon: Icons.groups_rounded, value: '${all.length}', label: t.customersCount, highlight: true),
              CounterTile(icon: Icons.workspace_premium_outlined, value: '$regulars', label: t.regularCustomers),
            ]),
            const SizedBox(height: 14),
            Wrap(spacing: 10, runSpacing: 10, crossAxisAlignment: WrapCrossAlignment.center, children: [
              SizedBox(
                width: 280,
                child: TextField(
                  onChanged: (v) => setState(() => _query = v),
                  decoration: InputDecoration(
                    isDense: true,
                    fillColor: Colors.white,
                    hintText: t.searchCustomer,
                    prefixIcon: const Icon(Icons.search_rounded, size: 20),
                  ),
                ),
              ),
              PillBar<String>(
                dense: true,
                items: [PillItem('recent', t.sortRecentVisit), PillItem('orders', t.sortMostOrders), PillItem('spent', t.sortBiggestSpenders)],
                selected: _sort,
                onSelected: (v) => setState(() => _sort = v),
              ),
            ]),
            const SizedBox(height: 14),
            if (list.isEmpty)
              EmptyState(icon: Icons.people_outline_rounded, title: t.noCustomersYet, message: t.noCustomersYetHint)
            else
              LayoutBuilder(builder: (context, box) {
                final cols = (box.maxWidth / 340).floor().clamp(1, 4);
                final w = (box.maxWidth - (cols - 1) * 12) / cols;
                return Wrap(spacing: 12, runSpacing: 12, children: [
                  for (final c in list)
                    SizedBox(width: w, child: _CustomerCard(customer: c, minorUnit: units[c['currency']] ?? 2, onOpen: () => _open(c, units))),
                ]);
              }),
          ]),
        );
      },
    );
  }

  Future<void> _open(Map<String, dynamic> c, Map<String, int> units) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => _CustomerDetail(
          membership: widget.membership,
          customer: c,
          minorUnit: units[c['currency']] ?? 2,
        ),
      ),
    );
    if (changed == true) setState(() => _data = _load());
  }
}

class _CustomerCard extends StatelessWidget {
  const _CustomerCard({required this.customer, required this.minorUnit, required this.onOpen});
  final Map<String, dynamic> customer;
  final int minorUnit;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final c = customer;
    final locale = Localizations.localeOf(context).toString();
    final name = (c['display_name'] as String?) ?? '—';
    final allergies = ((c['allergies'] as List?) ?? const []).cast<String>();
    final last = DateTime.parse(c['last_order_at'] as String).toLocal();
    return SoftCard(
      onTap: onOpen,
      padding: const EdgeInsets.all(14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(gradient: RestoColors.brandGradient, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Text(name.characters.first.toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700)),
              if (c['phone'] != null) Text(c['phone'] as String, style: const TextStyle(color: RestoColors.muted, fontSize: 12.5)),
            ]),
          ),
          if ((c['orders_count'] as num) >= 3) StatusPill(label: t.regularBadge, color: RestoColors.primaryDeep, dense: true),
        ]),
        const SizedBox(height: 10),
        Wrap(spacing: 14, runSpacing: 4, children: [
          _Stat(icon: Icons.receipt_long_outlined, text: t.ordersCountShort((c['orders_count'] as num).toInt())),
          if (c['currency'] != null)
            _Stat(icon: Icons.payments_outlined, text: Money((c['total_spent_minor'] as num).toInt(), c['currency'] as String).format(locale, minorUnit)),
          _Stat(icon: Icons.schedule_rounded, text: DateFormat.yMMMd(locale).format(last)),
        ]),
        if (allergies.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(spacing: 6, runSpacing: 6, children: [
            for (final a in allergies)
              StatusPill(label: allergenLabel(t, a), color: StatusColors.late, icon: Icons.warning_amber_rounded, dense: true),
          ]),
        ],
      ]),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 15, color: RestoColors.primaryDeep),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 12.5)),
      ]);
}

class _CustomerDetail extends StatefulWidget {
  const _CustomerDetail({required this.membership, required this.customer, required this.minorUnit});
  final Membership membership;
  final Map<String, dynamic> customer;
  final int minorUnit;

  @override
  State<_CustomerDetail> createState() => _CustomerDetailState();
}

class _CustomerDetailState extends State<_CustomerDetail> {
  late final _notes = TextEditingController(text: widget.customer['notes'] as String? ?? '');
  late final Future<List<Map<String, dynamic>>> _orders =
      AppScope.read(context).api!.customerOrders(widget.membership.organizationId, widget.customer['user_id'] as String);

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final c = widget.customer;
    final locale = Localizations.localeOf(context).toString();
    final canEdit = widget.membership.canOrg('customers.manage') || widget.membership.can('customers.manage');
    return Scaffold(
      appBar: AppBar(title: Text((c['display_name'] as String?) ?? '—', style: serifTitle(context, size: 26))),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 820),
          child: ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 40), children: [
            _CustomerCard(customer: c, minorUnit: widget.minorUnit, onOpen: () {}),
            const SizedBox(height: 14),
            SoftCard(
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                SectionHeading(title: t.teamNotes, icon: Icons.sticky_note_2_outlined, subtitle: t.teamNotesHint),
                const SizedBox(height: 10),
                TextField(controller: _notes, enabled: canEdit, maxLength: 1000, maxLines: 4, minLines: 2,
                    decoration: InputDecoration(hintText: t.teamNotesExample)),
                if (canEdit)
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: GoldButton(
                      label: t.save,
                      icon: Icons.check_rounded,
                      expand: false,
                      onPressed: () async {
                        try {
                          await AppScope.read(context).api!.saveCustomerNotes(c['id'] as String, _notes.text);
                          if (context.mounted) {
                            showInfo(context, t.saved);
                            Navigator.pop(context, true);
                          }
                        } catch (e) {
                          if (context.mounted) showError(context, e);
                        }
                      },
                    ),
                  ),
              ]),
            ),
            const SizedBox(height: 14),
            SoftCard(
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                SectionHeading(title: t.customerOrdersHere, icon: Icons.receipt_long_rounded),
                const SizedBox(height: 8),
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: _orders,
                  builder: (context, snap) {
                    if (!snap.hasData) return const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator()));
                    final list = snap.data!;
                    if (list.isEmpty) return Text(t.noCustomerOrders, style: const TextStyle(color: RestoColors.muted));
                    return Column(children: [
                      for (final o in list)
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.receipt_outlined, color: RestoColors.primaryDeep),
                          title: Text('#${o['number']} · ${channelLabel(t, o['channel'] as String)}'),
                          subtitle: Text(DateFormat.yMMMd(locale).add_Hm().format(DateTime.parse(o['opened_at'] as String).toLocal())),
                          trailing: Text(
                            Money((o['total_minor'] as num).toInt(), o['currency'] as String).format(locale, widget.minorUnit),
                            style: const TextStyle(fontWeight: FontWeight.w700, color: RestoColors.primaryDeep),
                          ),
                        ),
                    ]);
                  },
                ),
              ]),
            ),
            const SizedBox(height: 10),
            Text(t.customerPrivacyNote, style: const TextStyle(color: RestoColors.muted, fontSize: 12)),
          ]),
        ),
      ),
    );
  }
}
