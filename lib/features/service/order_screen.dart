import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show RealtimeChannel;

import '../../app_state.dart';
import '../../core/errors.dart';
import '../../data/api.dart';
import '../../data/cash_api.dart';
import '../../data/menu_models.dart';
import '../../data/models.dart';
import '../../data/order_models.dart';
import '../../data/orders_api.dart';
import '../../pdf/tickets.dart';
import '../../ui/branch_scope.dart';
import '../../ui/common.dart';
import '../../ui/theme.dart';
import '../cash/cash_labels.dart';
import '../cash/order_documents.dart';
import '../menus/menu_widgets.dart';
import '../orders/item_choice_dialog.dart';
import 'order_discounts.dart';
import 'order_info.dart';
import 'service_actions.dart';
import 'service_labels.dart';

/// Une commande : la carte (en photos) pour ajouter, le ticket pour suivre
/// chaque article de la prise de commande au service, et le paiement.
class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key, required this.scope, required this.orderId, this.tables = const []});
  final BranchContext scope;
  final String orderId;

  /// Tables de l'établissement (nom affiché, changement de table).
  final List<DiningTable> tables;

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  Order? _order;
  BrandMenu? _menu;
  BranchMenuState? _branchState;
  List<Payment> _payments = const [];
  Object? _error;
  bool _busy = false;
  RealtimeChannel? _channel;
  late final Api _api = AppScope.read(context).api!;

  BranchContext get scope => widget.scope;
  bool get _seesPayments => scope.can('cash.operate') || scope.can('finance.read');

  String? get _tableLabel {
    final id = _order?.tableId;
    if (id == null) return null;
    return widget.tables.where((x) => x.id == id).firstOrNull?.label;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _load();
      _channel = _api.customer.watchOrder(widget.orderId, _refresh);
    });
  }

  @override
  void dispose() {
    if (_channel != null) _api.customer.unwatch(_channel!);
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final r = await Future.wait<dynamic>([
        _api.orders.order(widget.orderId),
        _api.menu.load(scope.branch.brandId),
        _api.menu.branchState(scope.branchId),
        _seesPayments ? _api.cash.payments(widget.orderId) : Future.value(<Payment>[]),
      ]);
      if (!mounted) return;
      setState(() {
        _order = r[0] as Order;
        _menu = r[1] as BrandMenu;
        _branchState = r[2] as BranchMenuState;
        _payments = r[3] as List<Payment>;
        _error = null;
      });
    } catch (e) {
      if (mounted) setState(() => _error = e);
    }
  }

  Future<void> _refresh() async {
    try {
      final order = await _api.orders.order(widget.orderId);
      final payments = _seesPayments ? await _api.cash.payments(widget.orderId) : <Payment>[];
      if (mounted) {
        setState(() {
          _order = order;
          _payments = payments;
        });
      }
    } catch (_) {}
  }

  /// Exécute une action puis relit la commande (le serveur fait foi).
  Future<void> _run(Future<Object?> Function() action) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await action();
      await _refresh();
    } catch (e) {
      if (mounted) showError(context, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _money(int minor) => scope.money(context, minor);

  int? _priceOf(String id) {
    final s = _branchState!;
    return s.prices[(id, _order!.channel)] ?? s.prices[(id, 'default')];
  }

  Future<void> _pick(MenuItem item) async {
    final t = context.t;
    if (_branchState!.offered[item.id] == false) {
      showInfo(context, t.itemSoldOut(item.name));
      return;
    }
    final variants = item.variants.where((v) => v.active && _priceOf(v.id) != null).toList();
    final groups = _menu!.groups.where((g) => g.active && item.groupIds.contains(g.id)).toList();
    if (variants.length == 1 && groups.isEmpty) {
      await _run(() => _api.orders.addItem(
          orderId: widget.orderId, variantId: variants.first.id, quantity: 1, modifierIds: const [], clientId: uuidV4()));
      return;
    }
    final choice = await showDialog<ItemChoice>(
      context: context,
      builder: (_) => ItemChoiceDialog(item: item, variants: variants, groups: groups, priceOf: _priceOf, money: _money),
    );
    if (choice == null) return;
    await _run(() => _api.orders.addItem(
          orderId: widget.orderId,
          variantId: choice.variantId,
          quantity: choice.quantity,
          modifierIds: choice.modifierIds,
          note: choice.note,
          clientId: uuidV4(),
        ));
  }

  Future<void> _collect({bool thenSend = false}) async {
    final t = context.t;
    final result = await ServiceActions(context, scope).collect(_order!, place: orderPlace(t, _order!, _tableLabel));
    if (result == null || !mounted) return;
    if (thenSend && result.dueMinor <= 0 && _order!.pendingCount > 0) {
      await _run(() => _api.orders.send(widget.orderId));
    } else {
      await _refresh();
    }
    if (!mounted) return;
    if (result.closed && _order!.stage == OrderStage.done) {
      showInfo(context, t.orderPaidClosed);
      Navigator.pop(context);
    }
  }

  Future<void> _voidPayment(Payment p) async {
    final reason = await askReason(context, context.t.voidPayment);
    if (reason == null) return;
    await _run(() => _api.cash.voidPayment(p.id, reason));
  }

  Future<void> _cancelOrder() async {
    final t = context.t;
    final order = _order!;
    String? reason;
    if (order.hasSentLines) {
      reason = await askReason(context, t.cancelOrder);
      if (reason == null) return;
    } else if (!await confirm(context, t.cancelOrderConfirm, action: t.cancelOrder)) {
      return;
    }
    if (!mounted) return;
    try {
      await _api.orders.cancel(order.id, reason);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  Future<void> _moveTable() async {
    final t = context.t;
    final busy = (await _api.orders.openOrders(scope.branchId)).map((o) => o.tableId).whereType<String>().toSet();
    if (!mounted) return;
    final free = widget.tables.where((x) => x.active && !busy.contains(x.id)).toList();
    final picked = await showDialog<DiningTable>(
      context: context,
      builder: (c) => SimpleDialog(
        title: Text(t.moveTable),
        children: [
          if (free.isEmpty) Padding(padding: const EdgeInsets.all(24), child: Text(t.noFreeTable)),
          for (final tb in free)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(c, tb),
              child: Row(children: [
                const Icon(Icons.table_restaurant_rounded, size: 18, color: StatusColors.free),
                const SizedBox(width: 8),
                Expanded(child: Text(tb.label)),
                Text(t.seatsCount(tb.seats)),
              ]),
            ),
        ],
      ),
    );
    if (picked == null) return;
    await _run(() => _api.orders.moveTable(widget.orderId, picked.id));
  }

  Future<void> _print(bool kitchen) async {
    final t = context.t;
    final o = _order!;
    if (!kitchen) return printBillFor(context, scope, o, orderPlace(t, o, _tableLabel));
    final ctx = TicketContext(
      t: t,
      locale: Localizations.localeOf(context).toString(),
      minorUnit: scope.minorUnit,
      branchName: scope.branch.name,
      branchAddress: [scope.branch.addressLine1, scope.branch.city].whereType<String>().where((s) => s.isNotEmpty).join(', '),
      branchPhone: scope.branch.phone,
      place: orderPlace(t, o, _tableLabel),
    );
    try {
      final bytes = await kitchenTicketPdf(ctx, o);
      await printTicket(bytes, 'cuisine-${o.number}.pdf');
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final order = _order;
    if (order == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: _error == null
              ? const CircularProgressIndicator()
              : Column(mainAxisSize: MainAxisSize.min, children: [
                  Text(errorText(t, _error!)),
                  const SizedBox(height: 12),
                  OutlinedButton(onPressed: _load, child: Text(t.retry)),
                ]),
        ),
      );
    }
    final canWrite = scope.can('orders.write') && order.isOpen;
    final wide = MediaQuery.sizeOf(context).width >= 980;
    final stage = order.stage;
    final menu = MenuPicker(
      menu: _menu!,
      branchState: _branchState!,
      priceOf: _priceOf,
      money: _money,
      imageUrl: _api.customer.imageUrl,
      inOrder: {
        for (final l in order.lines.where((l) => !l.cancelled && l.itemId != null))
          l.itemId!: (order.lines.where((x) => x.itemId == l.itemId && !x.cancelled).fold<int>(0, (a, x) => a + x.quantity)),
      },
      onPick: canWrite ? _pick : null,
    );
    final ticket = _TicketPanel(
      order: order,
      scope: scope,
      tableLabel: _tableLabel,
      busy: _busy,
      payments: _payments,
      api: _api.orders,
      run: _run,
      onEdit: canWrite
          ? () async {
              final saved = await showDialog<bool>(context: context, builder: (_) => OrderDetailsDialog(order: order, scope: scope));
              if (saved == true) await _refresh();
            }
          : null,
      onCollect: scope.can('cash.operate') && order.dueMinor > 0 && order.activeLines.isNotEmpty ? _collect : null,
      onVoidPayment: scope.can('payments.refund') && order.isOpen ? _voidPayment : null,
    );

    final scaffold = Scaffold(
      appBar: AppBar(
        titleSpacing: 8,
        title: Row(children: [
          Icon(channelIcon(order.channel), color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Flexible(child: Text('${orderPlace(t, order, _tableLabel)} · #${order.number}', overflow: TextOverflow.ellipsis)),
          const SizedBox(width: 10),
          if (wide) StatusPill(label: stageLabel(t, stage, order.channel), color: stageColor(stage), icon: stageIcon(stage)),
        ]),
        actions: [
          IconButton(tooltip: t.refresh, onPressed: () => _run(() async => null), icon: const Icon(Icons.refresh_rounded)),
          PopupMenuButton<String>(
            tooltip: t.print,
            icon: const Icon(Icons.print_rounded),
            onSelected: (v) => _print(v == 'kitchen'),
            itemBuilder: (_) => [
              PopupMenuItem(value: 'kitchen', child: Text(t.printKitchenTicket)),
              PopupMenuItem(value: 'bill', child: Text(t.printBill)),
            ],
          ),
          PopupMenuButton<String>(
            onSelected: (v) async {
              switch (v) {
                case 'move':
                  await _moveTable();
                case 'delay':
                  if (await ServiceActions(context, scope).setDelay(order)) await _refresh();
                case 'history':
                  if (context.mounted) showOrderHistory(context, _api.orders, order, scope);
                case 'cancel':
                  await _cancelOrder();
              }
            },
            itemBuilder: (_) => [
              if (canWrite && order.channel == 'dine_in')
                PopupMenuItem(value: 'move', child: ListTile(leading: const Icon(Icons.swap_horiz_rounded), title: Text(t.moveTable))),
              if (canWrite && order.channel != 'dine_in')
                PopupMenuItem(value: 'delay', child: ListTile(leading: const Icon(Icons.timer_outlined), title: Text(t.announcedDelay))),
              PopupMenuItem(value: 'history', child: ListTile(leading: const Icon(Icons.history_rounded), title: Text(t.orderHistory))),
              if (canWrite)
                PopupMenuItem(
                  value: 'cancel',
                  child: ListTile(leading: const Icon(Icons.cancel_outlined, color: StatusColors.late), title: Text(t.cancelOrder)),
                ),
            ],
          ),
        ],
        bottom: wide
            ? null
            : TabBar(tabs: [Tab(text: t.menuTab), Tab(text: t.ticketTab(order.activeLines.length))]),
      ),
      body: wide
          ? Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Expanded(child: menu),
              const VerticalDivider(width: 1),
              SizedBox(width: 460, child: ticket),
            ])
          : TabBarView(children: [menu, ticket]),
    );
    return wide ? scaffold : DefaultTabController(length: 2, initialIndex: order.activeLines.isEmpty ? 0 : 1, child: scaffold);
  }
}

/// La carte en photos : recherche, type (plats, boissons…), catégories.
class MenuPicker extends StatefulWidget {
  const MenuPicker({
    super.key,
    required this.menu,
    required this.branchState,
    required this.priceOf,
    required this.money,
    required this.imageUrl,
    required this.inOrder,
    required this.onPick,
  });

  final BrandMenu menu;
  final BranchMenuState branchState;
  final int? Function(String) priceOf;
  final String Function(int) money;
  final String Function(String path) imageUrl;

  /// itemId → quantité déjà dans la commande.
  final Map<String, int> inOrder;
  final void Function(MenuItem)? onPick;

  @override
  State<MenuPicker> createState() => _MenuPickerState();
}

class _MenuPickerState extends State<MenuPicker> {
  String? _category;
  String _kind = 'all';
  String _query = '';

  bool _sellable(MenuItem i) =>
      i.active && widget.branchState.offered.containsKey(i.id) && i.variants.any((v) => v.active && widget.priceOf(v.id) != null);

  String _price(BuildContext context, MenuItem i) {
    final prices = i.variants.where((v) => v.active).map((v) => widget.priceOf(v.id)).whereType<int>().toList()..sort();
    if (prices.isEmpty) return '';
    return prices.length > 1 ? context.t.fromPrice(widget.money(prices.first)) : widget.money(prices.first);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    final q = _query.trim().toLowerCase();
    final all = widget.menu.items.where(_sellable).toList();
    final categories = widget.menu.categories.where((c) => c.active && all.any((i) => i.categoryId == c.id)).toList();
    if (categories.isEmpty) {
      return Center(child: Padding(padding: const EdgeInsets.all(24), child: Text(t.nothingToSell, textAlign: TextAlign.center)));
    }
    final selected = categories.any((c) => c.id == _category) ? _category : null;
    bool match(MenuItem i) =>
        (_kind == 'all' || i.kind == _kind) &&
        (q.isEmpty || i.name.toLowerCase().contains(q) || (i.description ?? '').toLowerCase().contains(q));
    final shown = (selected == null ? categories : categories.where((c) => c.id == selected))
        .map((c) => (c, all.where((i) => i.categoryId == c.id && match(i)).toList()))
        .where((e) => e.$2.isNotEmpty)
        .toList();
    final kinds = {for (final i in all) i.kind};

    return Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
        child: Row(children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(isDense: true, prefixIcon: const Icon(Icons.search_rounded), hintText: t.searchDish),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          if (kinds.length > 1) ...[
            const SizedBox(width: 10),
            SegmentedButton<String>(
              showSelectedIcon: false,
              segments: [
                ButtonSegment(value: 'all', label: Text(t.allCategories)),
                for (final k in ['food', 'drink', 'other'].where(kinds.contains))
                  ButtonSegment(value: k, label: Text(kindLabel(t, k)), icon: Icon(_kindIcon(k), size: 18)),
              ],
              selected: {_kind},
              onSelectionChanged: (s) => setState(() => _kind = s.first),
            ),
          ],
        ]),
      ),
      SizedBox(
        height: 52,
        child: ListView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), children: [
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 8),
            child: ChoiceChip(label: Text(t.allCategories), selected: selected == null, onSelected: (_) => setState(() => _category = null)),
          ),
          for (final c in categories)
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 8),
              child: ChoiceChip(label: Text(c.name), selected: selected == c.id, onSelected: (_) => setState(() => _category = c.id)),
            ),
        ]),
      ),
      Expanded(
        child: shown.isEmpty
            ? Center(child: Text(t.noResults))
            : ListView(padding: const EdgeInsets.fromLTRB(16, 0, 16, 24), children: [
                for (final (c, items) in shown) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(2, 14, 2, 10),
                    child: Text(c.name, style: theme.textTheme.titleMedium),
                  ),
                  LayoutBuilder(builder: (context, box) {
                    final cols = (box.maxWidth / 190).floor().clamp(2, 6);
                    final w = (box.maxWidth - (cols - 1) * 12) / cols;
                    return Wrap(spacing: 12, runSpacing: 12, children: [
                      for (final i in items)
                        SizedBox(
                          width: w,
                          child: _DishCard(
                            item: i,
                            price: _price(context, i),
                            soldOut: widget.branchState.offered[i.id] == false,
                            imageUrl: i.imagePath == null ? null : widget.imageUrl(i.imagePath!),
                            count: widget.inOrder[i.id] ?? 0,
                            onTap: widget.onPick == null ? null : () => widget.onPick!(i),
                          ),
                        ),
                    ]);
                  }),
                ],
              ]),
      ),
    ]);
  }
}

IconData _kindIcon(String k) => switch (k) {
      'drink' => Icons.local_bar_rounded,
      'food' => Icons.restaurant_rounded,
      _ => Icons.bakery_dining_rounded,
    };

class _DishCard extends StatelessWidget {
  const _DishCard({
    required this.item,
    required this.price,
    required this.soldOut,
    required this.imageUrl,
    required this.count,
    required this.onTap,
  });
  final MenuItem item;
  final String price;
  final bool soldOut;
  final String? imageUrl;
  final int count;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final placeholder = Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: item.kind == 'drink'
              ? [const Color(0xFF475569), const Color(0xFF94A3B8)]
              : [RestoColors.primaryDeep, RestoColors.primaryBright],
        ),
      ),
      child: Center(child: Icon(_kindIcon(item.kind), size: 34, color: Colors.white.withValues(alpha: 0.85))),
    );
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          AspectRatio(
            aspectRatio: 16 / 10,
            child: Stack(fit: StackFit.expand, children: [
              if (imageUrl != null)
                Image.network(imageUrl!, fit: BoxFit.cover, errorBuilder: (_, _, _) => placeholder)
              else
                placeholder,
              if (soldOut)
                Container(
                  color: Colors.black54,
                  alignment: Alignment.center,
                  child: Text(context.t.soldOut.toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, letterSpacing: 1)),
                ),
              if (count > 0)
                PositionedDirectional(
                  top: 8,
                  end: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                    decoration: BoxDecoration(color: RestoColors.primary, borderRadius: BorderRadius.circular(20)),
                    child: Text('× $count', style: const TextStyle(fontWeight: FontWeight.w800, color: RestoColors.onPrimary)),
                  ),
                ),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(item.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: theme.textTheme.titleSmall),
              const SizedBox(height: 4),
              Text(price, style: theme.textTheme.labelLarge?.copyWith(color: scheme.primary)),
            ]),
          ),
        ]),
      ),
    );
  }
}

/// Le ticket : informations, articles par étape, totaux, paiements, actions.
class _TicketPanel extends StatelessWidget {
  const _TicketPanel({
    required this.order,
    required this.scope,
    required this.tableLabel,
    required this.busy,
    required this.payments,
    required this.api,
    required this.run,
    required this.onEdit,
    required this.onCollect,
    required this.onVoidPayment,
  });

  final Order order;
  final BranchContext scope;
  final String? tableLabel;
  final bool busy;
  final List<Payment> payments;
  final OrdersApi api;
  final Future<void> Function(Future<Object?> Function()) run;
  final VoidCallback? onEdit;
  final Future<void> Function({bool thenSend})? onCollect;
  final void Function(Payment)? onVoidPayment;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    final o = order;
    final canWrite = scope.can('orders.write') && o.isOpen;
    final canWriteLines = scope.can('orders.write') && o.status != 'cancelled';
    final canVoid = scope.can('orders.void') && o.isOpen;
    final actions = ServiceActions(context, scope);
    String m(int v) => scope.money(context, v);

    final groups = <(String, Color, List<OrderLine>)>[
      (t.groupToSend, StatusColors.done, o.lines.where((l) => l.pending && !l.held).toList()),
      (t.groupHeld, StatusColors.reserved, o.lines.where((l) => l.pending && l.held).toList()),
      (t.groupCooking, StatusColors.cooking, o.lines.where((l) => l.inKitchen).toList()),
      (t.groupReady, StatusColors.ready, o.lines.where((l) => l.ready).toList()),
      (t.groupServed, StatusColors.free, o.lines.where((l) => l.served).toList()),
      (t.groupCancelled, StatusColors.late, o.lines.where((l) => l.cancelled).toList()),
    ];

    final payFirst = scope.branch.payFirstTakeaway && o.channel == 'takeaway' && o.dueMinor > 0 && o.pendingCount > 0;
    final buttons = <Widget>[
      if (o.awaitingAcceptance && canWrite) ...[
        Row(children: [
          Expanded(child: OutlinedButton(onPressed: busy ? null : () => run(() => actions.reject(o)), child: Text(t.reject))),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(backgroundColor: StatusColors.toValidate),
              onPressed: busy ? null : () => run(() => actions.accept(o)),
              icon: const Icon(Icons.check_rounded),
              label: Text(t.accept),
            ),
          ),
        ]),
      ] else ...[
        if (payFirst && onCollect != null)
          FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: StatusColors.toPay),
            onPressed: busy ? null : () => onCollect!(thenSend: true),
            icon: const Icon(Icons.point_of_sale_rounded),
            label: Text(t.collectThenSend(m(o.dueMinor))),
          ),
        if (canWrite && o.pendingCount > 0)
          (payFirst ? OutlinedButton.icon : FilledButton.icon)(
            onPressed: busy ? null : () => run(() => actions.send(o)),
            icon: const Icon(Icons.send_rounded),
            label: Text(t.sendToKitchen(o.pendingCount)),
          ),
        if (canWrite && o.heldCount > 0)
          OutlinedButton.icon(
            onPressed: busy ? null : () => run(() => actions.fire(o)),
            icon: const Icon(Icons.play_arrow_rounded),
            label: Text(t.fireNextCount(o.heldCount)),
          ),
        if (canWriteLines && o.readyCount > 0)
          FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: StatusColors.ready),
            onPressed: busy ? null : () => run(() => actions.serve(o)),
            icon: const Icon(Icons.room_service_rounded),
            label: Text('${servedAction(t, o.channel)} (${o.readyCount})'),
          ),
        if (onCollect != null && !payFirst)
          FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: StatusColors.toPay, foregroundColor: Colors.white),
            onPressed: busy ? null : () => onCollect!(),
            icon: const Icon(Icons.point_of_sale_rounded),
            label: Text(t.collectAmount(m(o.dueMinor))),
          ),
      ],
    ];

    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      if (busy) const LinearProgressIndicator(minHeight: 2) else const SizedBox(height: 2),
      Expanded(
        child: ListView(padding: const EdgeInsets.fromLTRB(14, 10, 14, 10), children: [
          OrderInfoHeader(order: o, scope: scope, tableLabel: tableLabel, onEdit: onEdit),
          if (o.awaitingAcceptance)
            Card(
              color: StatusColors.toValidate.withValues(alpha: 0.10),
              child: ListTile(
                leading: const Icon(Icons.notifications_active_rounded, color: StatusColors.toValidate),
                title: Text(t.customerOrderToValidate),
                subtitle: Text(t.customerOrderToValidateHint),
              ),
            ),
          if (payFirst)
            Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 4),
              child: Text(t.payFirstHint, style: theme.textTheme.bodySmall?.copyWith(color: StatusColors.toPay)),
            ),
          if (o.lines.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Column(children: [
                Icon(Icons.restaurant_menu_rounded, size: 40, color: theme.colorScheme.outline),
                const SizedBox(height: 8),
                Text(t.emptyTicket, textAlign: TextAlign.center),
              ]),
            ),
          for (final (title, color, lines) in groups)
            if (lines.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 4),
                child: Row(children: [
                  Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                  const SizedBox(width: 6),
                  Text(title.toUpperCase(), style: theme.textTheme.labelSmall?.copyWith(letterSpacing: 1.1, color: color)),
                ]),
              ),
              for (final l in lines)
                _LineTile(
                  line: l,
                  money: m,
                  canWrite: canWrite,
                  canVoid: canVoid,
                  onLess: () => run(() => l.quantity > 1 ? api.updateItem(l.id, l.quantity - 1, l.note) : api.removeItem(l.id)),
                  onMore: () => run(() => api.updateItem(l.id, l.quantity + 1, l.note)),
                  onHold: () => run(() => api.setHeld(l.id, !l.held)),
                  onNote: () async {
                    final note = await _askNote(context, l.note);
                    if (note != null) await run(() => api.updateItem(l.id, l.quantity, note.isEmpty ? null : note));
                  },
                  onCancel: () async {
                    final reason = await askReason(context, t.cancelLine);
                    if (reason != null) await run(() => api.cancelItem(l.id, reason));
                  },
                ),
            ],
          const SizedBox(height: 8),
          if (o.activeLines.isNotEmpty) ...[
            const Divider(),
            OrderTotals(order: o, scope: scope, run: run),
            if (o.isOpen && o.activeLines.isNotEmpty)
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: DiscountButton(order: o, scope: scope, run: run),
              ),
          ],
          for (final p in payments)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(children: [
                Icon(paymentMethodIcon(p.method), size: 16),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    [p.methodName, if (p.tipMinor > 0) '${t.tipLabel} ${m(p.tipMinor)}', ?p.reference, if (p.status == 'voided') t.voided].join(' · '),
                    style: p.status == 'voided' ? const TextStyle(decoration: TextDecoration.lineThrough) : null,
                  ),
                ),
                Text(m(p.amountMinor)),
                if (onVoidPayment != null && p.status == 'confirmed')
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    tooltip: t.voidPayment,
                    icon: const Icon(Icons.undo, size: 18),
                    onPressed: () => onVoidPayment!(p),
                  ),
              ]),
            ),
          if (o.activeLines.isNotEmpty && o.status != 'cancelled')
            Padding(
              padding: const EdgeInsets.only(top: 14),
              child: OrderDocuments(scope: scope, order: o, place: orderPlace(t, o, tableLabel)),
            ),
          if (o.status != 'open')
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: StatusPill(
                label: o.status == 'closed' ? (o.stage == OrderStage.done ? t.stageDone : t.paidShort) : t.stageCancelled,
                color: o.status == 'closed' ? StatusColors.free : StatusColors.late,
              ),
            ),
        ]),
      ),
      if (buttons.isNotEmpty)
        Container(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerLowest,
            border: Border(top: BorderSide(color: theme.colorScheme.outlineVariant)),
          ),
          child: SafeArea(
            top: false,
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              for (var i = 0; i < buttons.length; i++) ...[if (i > 0) const SizedBox(height: 8), buttons[i]],
            ]),
          ),
        ),
    ]);
  }

  static Future<String?> _askNote(BuildContext context, String? current) {
    final controller = TextEditingController(text: current ?? '');
    return showDialog<String>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(c.t.kitchenNote),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 300,
          decoration: InputDecoration(hintText: c.t.kitchenNoteExamples),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: Text(c.t.cancel)),
          FilledButton(onPressed: () => Navigator.pop(c, controller.text.trim()), child: Text(c.t.save)),
        ],
      ),
    ).whenComplete(controller.dispose);
  }
}

class _LineTile extends StatelessWidget {
  const _LineTile({
    required this.line,
    required this.money,
    required this.canWrite,
    required this.canVoid,
    required this.onLess,
    required this.onMore,
    required this.onHold,
    required this.onNote,
    required this.onCancel,
  });

  final OrderLine line;
  final String Function(int) money;
  final bool canWrite;
  final bool canVoid;
  final VoidCallback onLess;
  final VoidCallback onMore;
  final VoidCallback onHold;
  final VoidCallback onNote;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    final l = line;
    final struck = l.cancelled ? TextStyle(decoration: TextDecoration.lineThrough, color: theme.colorScheme.onSurfaceVariant) : null;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: canWrite && l.pending ? onNote : null,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('${l.quantity} × ${l.title}', style: (theme.textTheme.titleSmall ?? const TextStyle()).merge(struck)),
              for (final o in l.options)
                Text('+ ${o.name}${o.priceMinor > 0 ? ' (${money(o.priceMinor)})' : ''}', style: theme.textTheme.bodySmall?.merge(struck)),
              if (l.note != null)
                Container(
                  margin: const EdgeInsets.only(top: 3),
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: StatusColors.cooking.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text('» ${l.note}', style: theme.textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic)),
                ),
              if (l.addedVia == 'customer')
                Text(t.addedByCustomer, style: theme.textTheme.labelSmall?.copyWith(color: StatusColors.toValidate)),
              if (l.cancelled && l.cancelReason != null) Text(l.cancelReason!, style: theme.textTheme.bodySmall),
            ]),
          ),
        ),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(money(l.lineTotalMinor), style: struck),
          if (l.pending && canWrite)
            Row(mainAxisSize: MainAxisSize.min, children: [
              IconButton(
                visualDensity: VisualDensity.compact,
                tooltip: l.held ? t.sendWithOrder : t.holdForLater,
                isSelected: l.held,
                icon: const Icon(Icons.schedule_rounded, size: 20),
                selectedIcon: const Icon(Icons.schedule_rounded, size: 20, color: StatusColors.reserved),
                onPressed: onHold,
              ),
              IconButton(visualDensity: VisualDensity.compact, tooltip: t.less, icon: const Icon(Icons.remove), onPressed: onLess),
              IconButton(visualDensity: VisualDensity.compact, tooltip: t.more, icon: const Icon(Icons.add), onPressed: onMore),
            ])
          else if (!l.pending && !l.cancelled && canVoid)
            IconButton(
              visualDensity: VisualDensity.compact,
              tooltip: t.cancelLine,
              icon: const Icon(Icons.remove_circle_outline, size: 20),
              onPressed: onCancel,
            ),
        ]),
      ]),
    );
  }
}
