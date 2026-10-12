import 'dart:async';

import 'package:flutter/material.dart';

import '../../app_state.dart';
import '../../core/errors.dart';
import '../../data/models.dart';
import '../../data/order_models.dart';
import '../../ui/branch_scope.dart';
import '../../ui/common.dart';
import '../../ui/header_slot.dart';
import '../../ui/kit.dart';
import '../../ui/theme.dart';
import 'board_tab.dart';
import 'history_tab.dart';
import 'new_order_screen.dart';
import 'order_screen.dart';
import 'reservations_tab.dart';
import 'salle_tab.dart';
import 'service_hub.dart';

/// Module « Commandes » : suivi en direct, salle, réservations, historique.
class ServiceScreen extends StatelessWidget {
  const ServiceScreen({super.key, required this.membership});
  final Membership membership;

  @override
  Widget build(BuildContext context) =>
      BranchScope(membership: membership, builder: (context, scope) => _ServiceModule(key: ValueKey(scope.branchId), scope: scope));
}

class _ServiceModule extends StatefulWidget {
  const _ServiceModule({super.key, required this.scope});
  final BranchContext scope;

  @override
  State<_ServiceModule> createState() => _ServiceModuleState();
}

class _ServiceModuleState extends State<_ServiceModule> {
  late final ServiceHub _hub = ServiceHub(AppScope.read(context).api!, widget.scope);
  final _tabs = _TabIndex();
  StreamSubscription<ServiceAlert>? _alerts;
  BoardColumn? _boardColumn;

  @override
  void initState() {
    super.initState();
    _hub.start();
    _alerts = _hub.alerts.listen((a) {
      if (!mounted) return;
      final t = context.t;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: a == ServiceAlert.newCustomerOrder ? StatusColors.toValidate : StatusColors.ready,
        content: Text(a == ServiceAlert.newCustomerOrder ? t.alertNewCustomerOrder : t.alertOrderReady,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        action: SnackBarAction(
          label: t.view,
          textColor: Colors.white,
          onPressed: () => setState(() {
            _boardColumn = a == ServiceAlert.newCustomerOrder ? BoardColumn.toValidate : BoardColumn.ready;
            _tabs.index = 0;
          }),
        ),
      ));
    });
  }

  @override
  void dispose() {
    HeaderSlot.clear(this);
    _alerts?.cancel();
    _hub.dispose();
    super.dispose();
  }

  Future<void> _openOrder(String orderId) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => OrderScreen(scope: widget.scope, orderId: orderId, tables: _hub.allTables)),
    );
    _hub.load();
  }

  Future<void> _newOrder({DiningTable? table}) async {
    final id = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => NewOrderScreen(hub: _hub, table: table)),
    );
    if (id == null) return;
    await _hub.load();
    await _openOrder(id);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return ListenableBuilder(
      listenable: _hub,
      builder: (context, _) {
        if (!_hub.loaded) {
          return Center(
            child: _hub.error == null
                ? const CircularProgressIndicator()
                : Column(mainAxisSize: MainAxisSize.min, children: [
                    Text(errorText(t, _hub.error!)),
                    const SizedBox(height: 12),
                    OutlinedButton(onPressed: _hub.load, child: Text(t.retry)),
                  ]),
          );
        }
        final toValidate = _hub.toValidateCount;
        final canWrite = widget.scope.can('orders.write');
        // Onglets et « + » (nouvelle commande) dans l'en-tête, à côté du titre.
        HeaderSlot.show(
          this,
          'orders',
          Row(children: [
            Expanded(
              child: PillBar<int>(
                dense: true,
                items: [
                  PillItem(0, t.tabInProgress,
                      icon: Icons.view_kanban_rounded, count: _hub.orders.where((o) => o.stage != OrderStage.done).length),
                  PillItem(1, t.floor, icon: Icons.table_restaurant_rounded),
                  if (_hub.canReservations)
                    PillItem(2, t.reservationsTitle,
                        icon: Icons.event_rounded, count: _hub.requests.isEmpty ? null : _hub.requests.length),
                  PillItem(_hub.canReservations ? 3 : 2, t.historyTab, icon: Icons.history_rounded),
                ],
                selected: _tabs.index,
                onSelected: (i) => setState(() => _tabs.index = i),
              ),
            ),
            if (canWrite) ...[
              const SizedBox(width: 8),
              RoundIconButton(icon: Icons.add_rounded, gold: true, tooltip: t.newOrder, onTap: () => _newOrder()),
            ],
          ]),
        );
        return Column(children: [
          if (toValidate > 0)
            Material(
              color: StatusColors.toValidate,
              child: InkWell(
                onTap: () => setState(() {
                  _boardColumn = BoardColumn.toValidate;
                  _tabs.index = 0;
                }),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(children: [
                    const Icon(Icons.notifications_active_rounded, color: Colors.white),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(t.ordersToValidateBanner(toValidate),
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                    ),
                    const Icon(Icons.chevron_right, color: Colors.white),
                  ]),
                ),
              ),
            ),
          Expanded(
            child: IndexedStack(index: _tabs.index, children: [
              BoardTab(
                key: ValueKey(_boardColumn),
                hub: _hub,
                initialColumn: _boardColumn,
                onOpen: (o) => _openOrder(o.id),
              ),
              SalleTab(hub: _hub, onOpenOrder: _openOrder, onNewOrder: (tb) => _newOrder(table: tb)),
              if (_hub.canReservations) ReservationsTab(hub: _hub, onOpenOrder: _openOrder),
              HistoryTab(hub: _hub, onOpen: (o) => _openOrder(o.id)),
            ]),
          ),
        ]);
      },
    );
  }
}

/// Onglet affiché (pastilles du haut).
class _TabIndex {
  int index = 0;
}
