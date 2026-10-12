import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show RealtimeChannel;

import '../../data/cash_api.dart';
import '../../data/order_models.dart';
import '../../data/orders_api.dart';
import '../../ui/common.dart';
import '../../ui/kit.dart';
import '../../ui/theme.dart';
import '../service/service_labels.dart';
import 'cash_context.dart';
import 'payment_screen.dart';

/// File des commandes à encaisser : à table, à emporter, livraisons.
/// Les commandes entièrement servies passent en premier.
class CollectTab extends StatefulWidget {
  const CollectTab({super.key, required this.ctx, required this.onOpenSession});
  final CashContext ctx;
  final VoidCallback onOpenSession;

  @override
  State<CollectTab> createState() => _CollectTabState();
}

class _CollectTabState extends State<CollectTab> {
  List<Order>? _orders;
  CashSession? _session;
  Object? _error;
  String _channel = 'all';
  String _query = '';
  RealtimeChannel? _channelRt;
  Timer? _timer;
  Timer? _debounce;

  CashContext get ctx => widget.ctx;

  @override
  void initState() {
    super.initState();
    _load();
    _channelRt = ctx.api.orders.watchService(ctx.scope.branchId, () {
      _debounce?.cancel();
      _debounce = Timer(const Duration(milliseconds: 400), _load);
    });
    _timer = Timer.periodic(const Duration(seconds: 30), (_) => _load());
    ctx.addListener(_load);
  }

  @override
  void dispose() {
    ctx.removeListener(_load);
    _timer?.cancel();
    _debounce?.cancel();
    if (_channelRt != null) ctx.api.orders.unwatch(_channelRt!);
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final r = await Future.wait<dynamic>([
        ctx.api.orders.openOrders(ctx.scope.branchId),
        ctx.registerId == null ? Future.value(null) : ctx.cash.activeSession(ctx.registerId!),
      ]);
      if (!mounted) return;
      setState(() {
        _orders = (r[0] as List<Order>).where((o) => o.dueMinor > 0 && o.activeLines.isNotEmpty).toList()
          ..sort((a, b) {
            final ra = a.stage == OrderStage.toPay ? 0 : 1;
            final rb = b.stage == OrderStage.toPay ? 0 : 1;
            return ra != rb ? ra - rb : a.openedAt.compareTo(b.openedAt);
          });
        _session = r[1] as CashSession?;
        _error = null;
      });
    } catch (e) {
      if (mounted) setState(() => _error = e);
    }
  }

  Future<void> _collect(Order o) async {
    final session = _session;
    if (session == null || !session.isOpen) {
      showInfo(context, context.t.openCashFirst);
      widget.onOpenSession();
      return;
    }
    await Navigator.push(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) =>
            PaymentScreen(scope: ctx.scope, orderId: o.id, session: session, place: orderPlace(context.t, o, ctx.tableLabels[o.tableId])),
      ),
    );
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    final orders = _orders;
    if (orders == null) {
      return Center(
        child: _error == null ? const CircularProgressIndicator() : OutlinedButton(onPressed: _load, child: Text(t.retry)),
      );
    }
    final q = _query.trim().toLowerCase();
    final shown = orders.where((o) {
      if (_channel != 'all' && o.channel != _channel) return false;
      if (q.isEmpty) return true;
      return '${o.number}'.contains(q) ||
          (o.customerName ?? '').toLowerCase().contains(q) ||
          (ctx.tableLabels[o.tableId] ?? '').toLowerCase().contains(q);
    }).toList();
    final totalDue = shown.fold<int>(0, (a, o) => a + o.dueMinor);
    final session = _session;
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
        children: [
          if (session == null || !session.isOpen)
            Card(
              color: StatusColors.toValidate.withValues(alpha: 0.12),
              child: ListTile(
                leading: const Icon(Icons.lock_clock_rounded, color: StatusColors.toValidate),
                title: Text(session?.status == 'counted' ? t.sessionAwaitingValidation : t.registerClosedTitle),
                subtitle: Text(t.registerClosedHint),
                trailing: FilledButton(onPressed: widget.onOpenSession, child: Text(t.openRegisterShort)),
              ),
            ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              for (final (v, label, icon) in [
                ('all', t.allOrders, Icons.check_rounded),
                ('dine_in', t.channelDineIn, channelIcon('dine_in')),
                ('takeaway', t.channelTakeaway, channelIcon('takeaway')),
                ('delivery', t.channelDelivery, channelIcon('delivery')),
              ])
                GoldPill(label: label, icon: icon, dense: true, selected: _channel == v, onTap: () => setState(() => _channel = v)),
              SizedBox(
                width: 260,
                child: TextField(
                  decoration: InputDecoration(
                    isDense: true,
                    fillColor: Colors.white,
                    prefixIcon: const Icon(Icons.search_rounded, size: 20),
                    hintText: t.searchOrderHint,
                  ),
                  onChanged: (v) => setState(() => _query = v),
                ),
              ),
              StatusPill(
                label: '${t.toCollectTotal} : ${ctx.scope.money(context, totalDue)}',
                color: StatusColors.toPay,
                icon: Icons.payments_outlined,
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (shown.isEmpty) EmptyState(icon: Icons.check_rounded, title: t.nothingToCollect, message: t.nothingToCollectHint),
          LayoutBuilder(
            builder: (context, box) {
              final cols = (box.maxWidth / 300).floor().clamp(1, 4);
              final w = (box.maxWidth - (cols - 1) * 12) / cols;
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  for (final o in shown)
                    SizedBox(
                      width: w,
                      child: Card(
                        margin: EdgeInsets.zero,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(18),
                          onTap: () => _collect(o),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(channelIcon(o.channel), color: RestoColors.primaryDeep),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        orderPlace(t, o, ctx.tableLabels[o.tableId]),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: theme.textTheme.titleMedium,
                                      ),
                                    ),
                                    Text(
                                      '#${o.number}',
                                      style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  [
                                    hm(context, o.openedAt),
                                    t.itemsCountLabel(o.itemsCount),
                                    if (o.customerName != null) o.customerName!,
                                  ].join(' · '),
                                  style: theme.textTheme.bodySmall,
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    StatusPill(label: stageLabel(t, o.stage, o.channel), color: stageColor(o.stage), dense: true),
                                    const Spacer(),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          ctx.scope.money(context, o.dueMinor),
                                          style: theme.textTheme.titleLarge?.copyWith(color: StatusColors.toPay),
                                        ),
                                        if (o.paidMinor > 0)
                                          Text('${t.paid} : ${ctx.scope.money(context, o.paidMinor)}', style: theme.textTheme.bodySmall),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
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
