import 'dart:math';

import 'package:flutter/material.dart';

import '../../data/order_models.dart';
import '../../ui/common.dart';
import '../../ui/kit.dart';
import '../../ui/theme.dart';
import 'order_card.dart';
import 'service_hub.dart';
import 'service_labels.dart';

/// Étapes du suivi : chaque commande avance de « à valider » à « à encaisser ».
enum BoardColumn { toValidate, inProgress, ready, toPay }

BoardColumn? boardColumnOf(Order o) => switch (o.stage) {
      OrderStage.toValidate => BoardColumn.toValidate,
      OrderStage.draft || OrderStage.cooking => BoardColumn.inProgress,
      OrderStage.ready => BoardColumn.ready,
      OrderStage.toPay => BoardColumn.toPay,
      _ => null,
    };

/// Commandes en cours (maquette « Commandes ») : compteurs, pastilles
/// d'étape (Toutes, À valider, En préparation, Prêtes, À encaisser),
/// canaux, recherche, grille de cartes à bandeau or.
class BoardTab extends StatefulWidget {
  const BoardTab({super.key, required this.hub, required this.onOpen, this.initialColumn});
  final ServiceHub hub;
  final void Function(Order) onOpen;
  final BoardColumn? initialColumn;

  @override
  State<BoardTab> createState() => _BoardTabState();
}

class _BoardTabState extends State<BoardTab> {
  String _channel = 'all';
  String _query = '';
  bool _searching = false;

  /// null = toutes les étapes.
  late BoardColumn? _column = widget.initialColumn;

  String _title(BuildContext context, BoardColumn c) {
    final t = context.t;
    return switch (c) {
      BoardColumn.toValidate => t.stageToValidate,
      BoardColumn.inProgress => t.columnInProgress,
      BoardColumn.ready => t.columnReady,
      BoardColumn.toPay => t.stageToPay,
    };
  }

  String _hint(BuildContext context, BoardColumn? c) {
    final t = context.t;
    return switch (c) {
      BoardColumn.toValidate => t.columnToValidateHint,
      BoardColumn.inProgress || null => t.columnInProgressHint,
      BoardColumn.ready => t.columnReadyHint,
      BoardColumn.toPay => t.columnToPayHint,
    };
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final hub = widget.hub;
    final labels = hub.tableLabels;
    final q = _query.trim().toLowerCase();
    final byChannel = hub.orders.where((o) => _channel == 'all' || o.channel == _channel).where((o) {
      if (q.isEmpty) return true;
      return '${o.number}'.contains(q) ||
          (o.customerName ?? '').toLowerCase().contains(q) ||
          (labels[o.tableId] ?? '').toLowerCase().contains(q) ||
          (o.contactPhone ?? '').contains(q);
    }).toList();
    final counts = {for (final c in BoardColumn.values) c: byChannel.where((o) => boardColumnOf(o) == c).length};
    final shown = byChannel.where((o) => boardColumnOf(o) != null && (_column == null || boardColumnOf(o) == _column)).toList()
      // Les plus urgentes d'abord : à valider, puis la plus ancienne.
      ..sort((a, b) {
        final ca = boardColumnOf(a)!.index, cb = boardColumnOf(b)!.index;
        if (_column == null && (ca == 0) != (cb == 0)) return ca == 0 ? -1 : 1;
        return (a.promisedAt ?? a.scheduledFor ?? a.openedAt).compareTo(b.promisedAt ?? b.scheduledFor ?? b.openedAt);
      });
    final late = hub.orders.where((o) {
      final k = o.minutesInKitchen;
      return k != null && o.stage == OrderStage.cooking && k >= hub.scope.branch.targetPrepMinutes;
    }).length;
    final side = MediaQuery.sizeOf(context).width < 600 ? 16.0 : 22.0;

    final steps = [
      PillItem<BoardColumn?>(null, t.allOrders, count: byChannel.where((o) => boardColumnOf(o) != null).length),
      if (counts[BoardColumn.toValidate]! > 0 || hub.orders.any((o) => o.fromCustomer))
        PillItem(BoardColumn.toValidate, _title(context, BoardColumn.toValidate), count: counts[BoardColumn.toValidate]),
      PillItem(BoardColumn.inProgress, _title(context, BoardColumn.inProgress), count: counts[BoardColumn.inProgress]),
      PillItem(BoardColumn.ready, _title(context, BoardColumn.ready), count: counts[BoardColumn.ready]),
      PillItem(BoardColumn.toPay, _title(context, BoardColumn.toPay), count: counts[BoardColumn.toPay]),
    ];

    final channels = [
      ('all', t.allChannels, Icons.apps_rounded),
      ('dine_in', t.channelDineIn, channelIcon('dine_in')),
      ('takeaway', t.channelTakeaway, channelIcon('takeaway')),
      ('delivery', t.channelDelivery, channelIcon('delivery')),
    ];
    final channel = channels.firstWhere((c) => c.$1 == _channel);

    // Comme le module Menus : une ligne d'étapes qui défile, canal et
    // recherche en boutons ronds (la recherche s'ouvre à la demande).
    return ListView(padding: EdgeInsets.fromLTRB(side, 2, side, 90), children: [
      Row(children: [
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(children: [
              for (final s in steps)
                Padding(
                  padding: const EdgeInsetsDirectional.only(end: 8),
                  child: GoldPill(
                      label: s.label, count: s.count, dense: true, selected: _column == s.value, onTap: () => setState(() => _column = s.value)),
                ),
              if (late > 0) StatusPill(label: '$late ${t.lateCount}', color: const Color(0xFFC0392B), icon: Icons.alarm_rounded, dense: true),
            ]),
          ),
        ),
        const SizedBox(width: 8),
        PopupMenuButton<String>(
          tooltip: channel.$2,
          initialValue: _channel,
          onSelected: (v) => setState(() => _channel = v),
          itemBuilder: (_) => [
            for (final (v, label, icon) in channels)
              PopupMenuItem(value: v, child: Row(children: [Icon(icon, size: 18), const SizedBox(width: 10), Text(label)])),
          ],
          child: IgnorePointer(child: RoundIconButton(icon: channel.$3, gold: _channel != 'all', tooltip: channel.$2, onTap: () {})),
        ),
        const SizedBox(width: 6),
        RoundIconButton(
          icon: _searching ? Icons.close_rounded : Icons.search_rounded,
          tooltip: t.searchOrderHint,
          onTap: () => setState(() {
            _searching = !_searching;
            if (!_searching) _query = '';
          }),
        ),
      ]),
      if (_searching)
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: TextField(
            autofocus: true,
            decoration: InputDecoration(
              isDense: true,
              fillColor: Colors.white,
              prefixIcon: const Icon(Icons.search_rounded, size: 18),
              hintText: t.searchOrderHint,
            ),
            onChanged: (v) => setState(() => _query = v),
          ),
        ),
      const SizedBox(height: 12),      if (shown.isEmpty)
        EmptyState(icon: Icons.check_rounded, title: t.noOrdersHere, message: _hint(context, _column))
      else
        LayoutBuilder(builder: (context, box) {
          final cols = max(1, (box.maxWidth / 330).floor());
          final w = (box.maxWidth - (cols - 1) * 14) / cols;
          return Wrap(spacing: 14, runSpacing: 14, children: [
            for (final o in shown)
              SizedBox(
                width: w,
                child: OrderCard(
                  key: ValueKey(o.id),
                  order: o,
                  scope: hub.scope,
                  tableLabel: labels[o.tableId],
                  onOpen: () => widget.onOpen(o),
                  onChanged: hub.load,
                ),
              ),
          ]);
        }),
    ]);
  }
}
