import 'package:flutter/material.dart';

import '../../app_state.dart';
import '../../data/order_models.dart';
import '../../ui/common.dart';
import '../../ui/theme.dart';
import 'service_hub.dart';
import 'service_labels.dart';

/// Toutes les commandes d'une journée de service, avec filtres et résumé.
class HistoryTab extends StatefulWidget {
  const HistoryTab({super.key, required this.hub, required this.onOpen});
  final ServiceHub hub;
  final void Function(Order) onOpen;

  @override
  State<HistoryTab> createState() => _HistoryTabState();
}

class _HistoryTabState extends State<HistoryTab> {
  DateTime _day = DateTime.now();
  String _filter = 'all';
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    final hub = widget.hub;
    final labels = hub.tableLabels;
    final today = DateTime.now();
    final isToday = _day.year == today.year && _day.month == today.month && _day.day == today.day;
    return Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
        child: Wrap(spacing: 8, runSpacing: 8, crossAxisAlignment: WrapCrossAlignment.center, children: [
          IconButton.outlined(
            onPressed: () => setState(() => _day = _day.subtract(const Duration(days: 1))),
            icon: const Icon(Icons.chevron_left),
          ),
          TextButton(
            onPressed: () async {
              final d = await showDatePicker(
                context: context,
                initialDate: _day,
                firstDate: DateTime(2024),
                lastDate: today,
              );
              if (d != null) setState(() => _day = d);
            },
            child: Text(isToday ? '${t.today} · ${dayLabel(context, _day)}' : dayLabel(context, _day), style: theme.textTheme.titleMedium),
          ),
          IconButton.outlined(
            onPressed: isToday ? null : () => setState(() => _day = _day.add(const Duration(days: 1))),
            icon: const Icon(Icons.chevron_right),
          ),
          SizedBox(
            width: 220,
            child: TextField(
              decoration: InputDecoration(isDense: true, prefixIcon: const Icon(Icons.search_rounded, size: 20), hintText: t.searchOrderHint),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
        ]),
      ),
      Expanded(
        child: Loader<List<Order>>(
          key: ValueKey('${_day.year}-${_day.month}-${_day.day}-${hub.orders.length}'),
          load: () => AppScope.read(context).api!.orders.history(hub.scope.branchId, _day),
          builder: (context, all, reload) {
            final closed = all.where((o) => o.status == 'closed').toList();
            final cancelled = all.where((o) => o.status == 'cancelled').length;
            final sales = closed.fold<int>(0, (a, o) => a + o.totalMinor);
            final avg = closed.isEmpty ? 0 : sales ~/ closed.length;
            final q = _query.trim().toLowerCase();
            final list = all.where((o) {
              final okFilter = switch (_filter) {
                'paid' => o.status == 'closed',
                'open' => o.status == 'open',
                'cancelled' => o.status == 'cancelled',
                'dine_in' || 'takeaway' || 'delivery' => o.channel == _filter,
                _ => true,
              };
              if (!okFilter) return false;
              if (q.isEmpty) return true;
              return '${o.number}'.contains(q) ||
                  (o.customerName ?? '').toLowerCase().contains(q) ||
                  (labels[o.tableId] ?? '').toLowerCase().contains(q);
            }).toList();
            return RefreshIndicator(
              onRefresh: () async => reload(),
              child: ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 32), children: [
                Wrap(spacing: 10, runSpacing: 10, children: [
                  _Kpi(label: t.salesTotal, value: hub.scope.money(context, sales), color: RestoColors.primary),
                  _Kpi(label: t.ordersClosedCount, value: '${closed.length}', color: StatusColors.free),
                  _Kpi(label: t.averageTicket, value: hub.scope.money(context, avg), color: StatusColors.ready),
                  _Kpi(label: t.stageCancelled, value: '$cancelled', color: StatusColors.late),
                ]),
                const SizedBox(height: 12),
                Wrap(spacing: 8, runSpacing: 8, children: [
                  for (final (v, label) in [
                    ('all', t.allOrders),
                    ('paid', t.paidShort),
                    ('open', t.columnInProgress),
                    ('cancelled', t.stageCancelled),
                    ('dine_in', t.channelDineIn),
                    ('takeaway', t.channelTakeaway),
                    ('delivery', t.channelDelivery),
                  ])
                    ChoiceChip(label: Text(label), selected: _filter == v, onSelected: (_) => setState(() => _filter = v)),
                ]),
                const SizedBox(height: 12),
                if (list.isEmpty) Padding(padding: const EdgeInsets.all(24), child: Center(child: Text(t.noEntries))),
                for (final o in list)
                  Card(
                    child: ListTile(
                      onTap: () => widget.onOpen(o),
                      leading: CircleAvatar(
                        backgroundColor: stageColor(o.stage).withValues(alpha: 0.15),
                        child: Icon(channelIcon(o.channel), color: stageColor(o.stage)),
                      ),
                      title: Text('#${o.number} · ${orderPlace(t, o, labels[o.tableId])}'),
                      subtitle: Text([
                        hm(context, o.openedAt),
                        sourceLabel(t, o.source),
                        if (o.customerName != null) o.customerName!,
                        t.itemsCountLabel(o.itemsCount),
                        if (o.cancelReason != null) o.cancelReason!,
                      ].join(' · ')),
                      trailing: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end, children: [
                        Text(hub.scope.money(context, o.totalMinor), style: theme.textTheme.titleSmall),
                        const SizedBox(height: 2),
                        StatusPill(label: stageLabel(t, o.stage, o.channel), color: stageColor(o.stage), dense: true),
                      ]),
                    ),
                  ),
              ]),
            );
          },
        ),
      ),
    ]);
  }
}

class _Kpi extends StatelessWidget {
  const _Kpi({required this.label, required this.value, required this.color});
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        width: 190,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 4),
          Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(color: color)),
        ]),
      );
}
