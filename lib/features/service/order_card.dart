import 'package:flutter/material.dart';

import '../../data/order_models.dart';
import '../../ui/branch_scope.dart';
import '../../ui/common.dart';
import '../../ui/kit.dart';
import '../../ui/theme.dart';
import 'service_actions.dart';
import 'service_labels.dart';

/// Carte d'une commande (maquette « Commandes ») : bandeau or « TABLE 5 · #12 »
/// avec le temps écoulé, bandeau d'informations, articles, état, montant,
/// puis l'action suivante (ou « Voir détails »).
class OrderCard extends StatelessWidget {
  const OrderCard({
    super.key,
    required this.order,
    required this.scope,
    required this.tableLabel,
    required this.onOpen,
    required this.onChanged,
  });

  final Order order;
  final BranchContext scope;
  final String? tableLabel;
  final VoidCallback onOpen;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final o = order;
    final theme = Theme.of(context);
    final stage = o.stage;
    final kitchen = o.minutesInKitchen;
    final elapsed = kitchen ?? DateTime.now().difference(o.openedAt).inMinutes;
    final late = kitchen != null && stage == OrderStage.cooking && kitchen >= scope.branch.targetPrepMinutes;
    final lines = o.activeLines;
    final actions = ServiceActions(context, scope);

    Future<void> act(Future<Object?> Function() f) async {
      final r = await f();
      if (r != null && r != false) onChanged();
    }

    final info = <(IconData, String)>[
      (sourceIcon(o.source), sourceLabel(t, o.source)),
      if (o.customerName != null) (Icons.person_outline_rounded, o.customerName!),
      if (o.guests != null) (Icons.groups_2_outlined, t.guestsCount(o.guests!)),
      if (o.contactPhone != null) (Icons.phone_outlined, o.contactPhone!),
    ];
    final primary = _primary(context, stage, actions, act);

    return GoldHeaderCard(
      onTap: onOpen,
      title: '${orderPlace(t, o, tableLabel)} · #${o.number}',
      titleIcon: channelIcon(o.channel),
      headerColor: late ? StatusColors.late : (stage == OrderStage.toValidate ? StatusColors.toValidate : null),
      badge: HeaderBadge(text: durationText(elapsed), icon: Icons.schedule_rounded),
      info: Wrap(spacing: 12, runSpacing: 2, children: [
        for (final (icon, text) in info)
          Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, size: 14, color: RestoColors.primaryDeep),
            const SizedBox(width: 4),
            Text(text),
          ]),
      ]),
      action: Row(children: [
        Expanded(
          child: primary ?? GoldButton(label: t.viewDetails, icon: Icons.visibility_outlined, outlined: true, onPressed: () async => onOpen()),
        ),
        if (primary != null) ...[
          const SizedBox(width: 8),
          IconButton.outlined(tooltip: t.viewDetails, onPressed: onOpen, icon: const Icon(Icons.visibility_outlined, size: 20)),
        ],
      ]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.access_time_rounded, size: 16, color: RestoColors.primaryDeep),
          const SizedBox(width: 5),
          Text(hm(context, o.scheduledFor ?? o.openedAt), style: const TextStyle(fontWeight: FontWeight.w600)),
          if (o.promisedAt != null && o.scheduledFor == null) ...[
            const SizedBox(width: 10),
            const Icon(Icons.timer_outlined, size: 15, color: RestoColors.muted),
            const SizedBox(width: 3),
            Text(t.promisedFor(hm(context, o.promisedAt!)), style: theme.textTheme.bodySmall),
          ],
        ]),
        if (o.channel == 'delivery' && o.deliveryAddress != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(children: [
              const Icon(Icons.place_outlined, size: 14, color: RestoColors.muted),
              const SizedBox(width: 3),
              Expanded(child: Text(o.deliveryAddress!, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodySmall)),
            ]),
          ),
        const SizedBox(height: 8),
        Text(t.itemsLabel, style: theme.textTheme.bodySmall?.copyWith(color: RestoColors.muted)),
        const SizedBox(height: 2),
        for (final l in lines.take(5))
          Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: Row(children: [
              Icon(Icons.circle, size: 7, color: _lineColor(l)),
              const SizedBox(width: 6),
              Expanded(
                child: Text('${l.quantity} × ${l.title}${l.held ? ' · ${t.heldShort}' : ''}',
                    maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w500)),
              ),
            ]),
          ),
        if (lines.length > 5) Text(t.moreItems(lines.length - 5), style: theme.textTheme.bodySmall?.copyWith(color: RestoColors.muted)),
        if (lines.isEmpty) Text(t.emptyTicket, style: theme.textTheme.bodySmall),
        if (o.note != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text('« ${o.note} »', style: theme.textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic)),
          ),
        const SizedBox(height: 10),
        Wrap(spacing: 8, runSpacing: 6, crossAxisAlignment: WrapCrossAlignment.center, children: [
          StatusPill(label: stageLabel(t, stage, o.channel), color: stageColor(stage), dense: true),
          StatusPill(
            label: o.isPaid ? t.paidShort : (o.paidMinor > 0 ? t.partlyPaid : t.notPaid),
            color: o.isPaid ? StatusColors.free : (o.paidMinor > 0 ? StatusColors.cooking : StatusColors.done),
            dense: true,
          ),
          Text(scope.money(context, o.totalMinor), style: const TextStyle(fontWeight: FontWeight.w700, color: RestoColors.primaryDeep)),
        ]),
      ]),
    );
  }

  /// Action suivante de la commande (null s'il n'y en a pas).
  Widget? _primary(BuildContext context, OrderStage stage, ServiceActions a, Future<void> Function(Future<Object?> Function()) act) {
    final t = context.t;
    final o = order;
    final canWrite = scope.can('orders.write');
    Widget button(String label, IconData icon, Future<Object?> Function() f) =>
        GoldButton(label: label, icon: icon, onPressed: () => act(f));
    if (!canWrite && stage != OrderStage.toPay) return null;
    return switch (stage) {
      OrderStage.toValidate => Row(children: [
          Expanded(child: GoldButton(label: t.reject, outlined: true, onPressed: () => act(() => a.reject(o)))),
          const SizedBox(width: 8),
          Expanded(child: button(t.accept, Icons.check_rounded, () => a.accept(o))),
        ]),
      OrderStage.draft when o.pendingCount > 0 => button(t.sendShort, Icons.send_rounded, () => a.send(o)),
      OrderStage.draft when o.heldCount > 0 => button(t.fireNext, Icons.play_arrow_rounded, () => a.fire(o)),
      OrderStage.cooking when o.pendingCount > 0 => button(t.sendShort, Icons.send_rounded, () => a.send(o)),
      OrderStage.ready => button(servedAction(t, o.channel), Icons.room_service_rounded, () => a.serve(o)),
      OrderStage.toPay when o.heldCount > 0 && canWrite => button(t.fireNext, Icons.play_arrow_rounded, () => a.fire(o)),
      OrderStage.toPay when scope.can('cash.operate') && o.dueMinor > 0 =>
        button(t.collectShort, Icons.point_of_sale_rounded, () => a.collect(o, place: orderPlace(t, o, tableLabel))),
      _ => null,
    };
  }

  static Color _lineColor(OrderLine l) => switch (l.prepStatus) {
        'pending' => l.held ? StatusColors.reserved : StatusColors.done,
        'sent' || 'preparing' => StatusColors.cooking,
        'ready' => StatusColors.ready,
        'served' => StatusColors.free,
        _ => StatusColors.late,
      };
}
