import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app_state.dart';
import '../../data/models.dart';
import '../../data/reservations_api.dart';
import '../../ui/common.dart';
import '../../ui/qr_view.dart';
import '../../ui/theme.dart';
import '../branches/online_tab.dart' show tablePublicUrl;
import 'floor_plan.dart';
import 'reservations_tab.dart';
import 'service_hub.dart';
import 'service_labels.dart';

/// La salle en direct : chaque table avec son état (libre, occupée, prête,
/// à encaisser, réservée). Mode « Modifier la salle » pour créer zones et
/// tables, les nommer et les placer sur le plan.
class SalleTab extends StatefulWidget {
  const SalleTab({super.key, required this.hub, required this.onOpenOrder, required this.onNewOrder});
  final ServiceHub hub;
  final void Function(String orderId) onOpenOrder;
  final void Function(DiningTable table) onNewOrder;

  @override
  State<SalleTab> createState() => _SalleTabState();
}

class _SalleTabState extends State<SalleTab> {
  bool? _plan;
  bool _editing = false;
  String? _area;

  ServiceHub get hub => widget.hub;
  bool get _canManage => hub.scope.can('branches.manage');

  Future<void> _editArea([ServiceArea? area]) async {
    final saved = await showDialog<bool>(context: context, builder: (_) => AreaDialog(hub: hub, area: area));
    if (saved == true) await hub.load();
  }

  Future<void> _editTable([DiningTable? table]) async {
    if (hub.areas.isEmpty) {
      await _editArea();
      return;
    }
    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => TableDialog(hub: hub, table: table, areaId: _area ?? hub.areas.first.id),
    );
    if (saved == true) await hub.load();
  }

  Future<void> _moved(DiningTable tb, int x, int y) async {
    try {
      await AppScope.read(context).api!.placeTable(tb.id, x, y);
      await hub.load();
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    final infos = tableInfos(hub.areas, hub.orders, hub.reservations);
    final wide = MediaQuery.sizeOf(context).width >= 760;
    final plan = _plan ?? wide;
    final areas = hub.areas.where((a) => (a.active || _editing) && (_area == null || a.id == _area)).toList();
    String money(int v) => hub.scope.money(context, v);

    final free = infos.values.where((i) => i.kind == TableKind.free && i.table.active).length;
    final busy = infos.values.where((i) => i.order != null).length;
    final reserved = infos.values.where((i) => i.kind == TableKind.reserved || i.kind == TableKind.reservedSoon).length;

    final toolbar = Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Wrap(spacing: 10, runSpacing: 10, crossAxisAlignment: WrapCrossAlignment.center, children: [
        _Counter(label: t.tableFree, value: free, color: StatusColors.free),
        _Counter(label: t.tableOccupied, value: busy, color: StatusColors.occupied),
        _Counter(label: t.reservationsTitle, value: reserved, color: StatusColors.reserved),
        if (hub.areas.length > 1)
          DropdownButton<String?>(
            value: _area,
            underline: const SizedBox.shrink(),
            items: [
              DropdownMenuItem(value: null, child: Text(t.allAreas)),
              for (final a in hub.areas) DropdownMenuItem(value: a.id, child: Text(a.name)),
            ],
            onChanged: (v) => setState(() => _area = v),
          ),
        SegmentedButton<bool>(
          showSelectedIcon: false,
          segments: [
            ButtonSegment(value: true, icon: const Icon(Icons.map_outlined, size: 18), label: Text(t.planView)),
            ButtonSegment(value: false, icon: const Icon(Icons.grid_view_rounded, size: 18), label: Text(t.cardsView)),
          ],
          selected: {plan},
          onSelectionChanged: (s) => setState(() => _plan = s.first),
        ),
        if (_canManage && !_editing)
          OutlinedButton.icon(
            onPressed: () => setState(() {
              _editing = true;
              _plan = true;
            }),
            icon: const Icon(Icons.edit_location_alt_outlined),
            label: Text(t.editFloor),
          ),
        if (_editing) ...[
          OutlinedButton.icon(onPressed: () => _editArea(), icon: const Icon(Icons.add), label: Text(t.newArea)),
          OutlinedButton.icon(onPressed: () => _editTable(), icon: const Icon(Icons.table_restaurant_rounded), label: Text(t.newTable)),
          FilledButton.icon(onPressed: () => setState(() => _editing = false), icon: const Icon(Icons.check), label: Text(t.done)),
        ],
      ]),
    );

    if (hub.areas.isEmpty) {
      return ListView(children: [
        toolbar,
        Padding(
          padding: const EdgeInsets.all(24),
          child: FormWidth(
            child: Column(children: [
              Icon(Icons.table_restaurant_rounded, size: 56, color: theme.colorScheme.outline),
              const SizedBox(height: 12),
              Text(t.floorEmptyTitle, style: theme.textTheme.titleLarge, textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text(t.floorEmptyHint, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              if (_canManage) FilledButton.icon(onPressed: () => _editArea(), icon: const Icon(Icons.add), label: Text(t.newArea)),
            ]),
          ),
        ),
      ]);
    }

    return ListView(padding: const EdgeInsets.only(bottom: 32), children: [
      toolbar,
      if (_editing)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(t.editFloorHint, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.primary)),
        ),
      if (!_editing) const Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: FloorLegend()),
      for (final a in areas)
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text(a.name, style: theme.textTheme.titleMedium),
              const SizedBox(width: 8),
              Text('· ${t.tablesCount(a.tables.where((x) => x.active).length)}${a.active ? '' : ' · ${t.inactive}'}',
                  style: theme.textTheme.bodySmall),
              if (_editing) IconButton(tooltip: t.edit, onPressed: () => _editArea(a), icon: const Icon(Icons.edit_outlined, size: 18)),
            ]),
            const SizedBox(height: 8),
            if (a.tables.isEmpty)
              Text(_canManage ? t.noTablesInArea : t.noTablesYet, style: theme.textTheme.bodySmall)
            else if (plan)
              FloorPlanCanvas(
                tables: a.tables,
                infos: infos,
                money: money,
                editing: _editing,
                onMoved: _moved,
                onTap: (tb) => _editing ? _editTable(tb) : _tableSheet(tb, infos[tb.id]!),
              )
            else
              FloorCards(tables: a.tables, infos: infos, money: money, onTap: (tb) => _tableSheet(tb, infos[tb.id]!)),
          ]),
        ),
    ]);
  }

  Future<void> _tableSheet(DiningTable tb, TableInfo info) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (c) => _TableSheet(
        hub: hub,
        info: info,
        onOpenOrder: (id) {
          Navigator.pop(c);
          widget.onOpenOrder(id);
        },
        onNewOrder: () {
          Navigator.pop(c);
          widget.onNewOrder(tb);
        },
      ),
    );
  }
}

class _Counter extends StatelessWidget {
  const _Counter({required this.label, required this.value, required this.color});
  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text('$value', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: color)),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
        ]),
      );
}

/// Fiche d'une table : commande en cours, réservations du jour, actions.
class _TableSheet extends StatelessWidget {
  const _TableSheet({required this.hub, required this.info, required this.onOpenOrder, required this.onNewOrder});
  final ServiceHub hub;
  final TableInfo info;
  final void Function(String) onOpenOrder;
  final VoidCallback onNewOrder;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    final tb = info.table;
    final o = info.order;
    final color = tableColor(info.kind);
    final today = hub.reservations.where((r) => r.tableIds.contains(tb.id)).toList()..sort((a, b) => a.startsAt.compareTo(b.startsAt));
    final canWrite = hub.scope.can('orders.write');
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      maxChildSize: 0.92,
      builder: (context, controller) => ListView(controller: controller, padding: const EdgeInsets.fromLTRB(20, 0, 20, 24), children: [
        Row(children: [
          Expanded(child: Text(tb.label, style: theme.textTheme.headlineSmall)),
          StatusPill(label: tableKindLabel(t, info.kind), color: color),
        ]),
        Text(t.seatsCount(tb.seats), style: theme.textTheme.bodyMedium),
        const SizedBox(height: 16),
        if (o != null)
          Card(
            child: ListTile(
              leading: Icon(stageIcon(o.stage), color: stageColor(o.stage)),
              title: Text('#${o.number} · ${stageLabel(t, o.stage, o.channel)}'),
              subtitle: Text([
                t.openedAt(hm(context, o.openedAt)),
                durationText(DateTime.now().difference(o.openedAt).inMinutes),
                if (o.guests != null) t.guestsCount(o.guests!),
                if (o.customerName != null) o.customerName!,
              ].join(' · ')),
              trailing: Text(hub.scope.money(context, o.totalMinor), style: theme.textTheme.titleMedium),
              onTap: () => onOpenOrder(o.id),
            ),
          )
        else if (canWrite)
          FilledButton.icon(onPressed: onNewOrder, icon: const Icon(Icons.add_rounded), label: Text(t.newOrderAtTable)),
        if (o != null) ...[
          const SizedBox(height: 8),
          FilledButton.icon(onPressed: () => onOpenOrder(o.id), icon: const Icon(Icons.receipt_long_rounded), label: Text(t.openOrder)),
        ],
        const SizedBox(height: 20),
        if (hub.canReservations) ...[
          Row(children: [
            Expanded(child: Text(t.reservationsToday, style: theme.textTheme.titleMedium)),
            TextButton.icon(
              onPressed: () async {
                final ok = await showDialog<bool>(context: context, builder: (_) => ReservationDialog(hub: hub, table: tb));
                if (ok == true) await hub.load();
              },
              icon: const Icon(Icons.event_rounded),
              label: Text(t.reserveTable),
            ),
          ]),
          if (today.isEmpty) Text(t.noReservationToday, style: theme.textTheme.bodySmall),
          for (final r in today)
            ReservationTile(
              reservation: r,
              hub: hub,
              onSeated: onOpenOrder,
            ),
        ],
        const SizedBox(height: 20),
        if (tb.qrToken != null)
          OutlinedButton.icon(
            onPressed: () => showTableQr(context, tb),
            icon: const Icon(Icons.qr_code_2_rounded),
            label: Text(t.tableQrCode),
          ),
      ]),
    );
  }
}

/// QR code d'une table : le client le scanne pour voir la carte et commander.
Future<void> showTableQr(BuildContext context, DiningTable tb) {
  final url = tablePublicUrl(tb.qrToken!);
  return showDialog<void>(
    context: context,
    builder: (c) => AlertDialog(
      title: Text('${c.t.tableQrCode} · ${tb.label}'),
      content: SizedBox(
        width: 320,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          QrView(data: url, size: 240),
          const SizedBox(height: 12),
          Text(c.t.tableQrHint, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          SelectableText(url, style: Theme.of(c).textTheme.bodySmall, textAlign: TextAlign.center),
        ]),
      ),
      actions: [
        TextButton.icon(
          onPressed: () async {
            await Clipboard.setData(ClipboardData(text: url));
            if (c.mounted) showInfo(c, c.t.copied);
          },
          icon: const Icon(Icons.copy, size: 18),
          label: Text(c.t.copyLink),
        ),
        FilledButton(onPressed: () => Navigator.pop(c), child: Text(c.t.close)),
      ],
    ),
  );
}

/// Zone de la salle (Salle, Terrasse, VIP, Étage…).
class AreaDialog extends StatefulWidget {
  const AreaDialog({super.key, required this.hub, this.area});
  final ServiceHub hub;
  final ServiceArea? area;

  @override
  State<AreaDialog> createState() => _AreaDialogState();
}

class _AreaDialogState extends State<AreaDialog> {
  late final _name = TextEditingController(text: widget.area?.name ?? '');
  late bool _active = widget.area?.active ?? true;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_name.text.trim().isEmpty) return;
    final s = widget.hub.scope;
    try {
      await AppScope.read(context).api!.saveArea(orgId: s.orgId, branchId: s.branchId, id: widget.area?.id, name: _name.text, active: _active);
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return AlertDialog(
      title: Text(widget.area == null ? t.newArea : t.edit),
      content: SizedBox(
        width: 380,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(
            controller: _name,
            autofocus: true,
            maxLength: 60,
            decoration: InputDecoration(labelText: t.areaName, hintText: t.areaNameHint),
          ),
          if (widget.area != null)
            SwitchListTile(contentPadding: EdgeInsets.zero, title: Text(t.active), value: _active, onChanged: (v) => setState(() => _active = v)),
        ]),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(t.cancel)),
        FilledButton(onPressed: _save, child: Text(t.save)),
      ],
    );
  }
}

/// Table : nom libre (Table 1, VIP 1, Bar 3…), places, forme, zone.
class TableDialog extends StatefulWidget {
  const TableDialog({super.key, required this.hub, this.table, required this.areaId});
  final ServiceHub hub;
  final DiningTable? table;
  final String areaId;

  @override
  State<TableDialog> createState() => _TableDialogState();
}

class _TableDialogState extends State<TableDialog> {
  late final _label = TextEditingController(text: widget.table?.label ?? _suggestLabel());
  late int _seats = widget.table?.seats ?? 4;
  late String _shape = widget.table?.shape ?? 'square';
  late String _areaId = widget.table?.areaId ?? widget.areaId;
  late bool _active = widget.table?.active ?? true;

  String _suggestLabel() {
    final n = widget.hub.allTables.length + 1;
    return 'Table $n';
  }

  @override
  void dispose() {
    _label.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_label.text.trim().isEmpty) return;
    final s = widget.hub.scope;
    try {
      await AppScope.read(context).api!.saveTable(
            orgId: s.orgId,
            branchId: s.branchId,
            id: widget.table?.id,
            areaId: _areaId,
            label: _label.text,
            seats: _seats,
            active: _active,
            shape: _shape,
          );
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    return AlertDialog(
      title: Text(widget.table == null ? t.newTable : widget.table!.label),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            TextField(
              controller: _label,
              autofocus: widget.table == null,
              maxLength: 30,
              decoration: InputDecoration(labelText: t.tableLabel, hintText: t.tableLabelHint),
            ),
            Row(children: [
              Expanded(child: Text(t.seats, style: theme.textTheme.titleSmall)),
              IconButton.outlined(onPressed: _seats > 1 ? () => setState(() => _seats--) : null, icon: const Icon(Icons.remove)),
              SizedBox(width: 44, child: Text('$_seats', textAlign: TextAlign.center, style: theme.textTheme.titleLarge)),
              IconButton.outlined(onPressed: _seats < 100 ? () => setState(() => _seats++) : null, icon: const Icon(Icons.add)),
            ]),
            const SizedBox(height: 16),
            Text(t.tableShape, style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(spacing: 8, children: [
              for (final (v, label, icon) in [
                ('square', t.shapeSquare, Icons.crop_square_rounded),
                ('round', t.shapeRound, Icons.circle_outlined),
                ('rect', t.shapeRect, Icons.crop_16_9_rounded),
              ])
                ChoiceChip(avatar: Icon(icon, size: 18), label: Text(label), selected: _shape == v, onSelected: (_) => setState(() => _shape = v)),
            ]),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _areaId,
              decoration: InputDecoration(labelText: t.areaName),
              items: [for (final a in widget.hub.areas) DropdownMenuItem(value: a.id, child: Text(a.name))],
              onChanged: (v) => setState(() => _areaId = v ?? _areaId),
            ),
            if (widget.table != null)
              SwitchListTile(contentPadding: EdgeInsets.zero, title: Text(t.active), value: _active, onChanged: (v) => setState(() => _active = v)),
            if (widget.table?.qrToken != null)
              TextButton.icon(
                onPressed: () => showTableQr(context, widget.table!),
                icon: const Icon(Icons.qr_code_2_rounded),
                label: Text(t.tableQrCode),
              ),
          ]),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(t.cancel)),
        FilledButton(onPressed: _save, child: Text(t.save)),
      ],
    );
  }
}

/// Une réservation dans une liste, avec les actions du moment.
class ReservationTile extends StatelessWidget {
  const ReservationTile({super.key, required this.reservation, required this.hub, this.onSeated});
  final Reservation reservation;
  final ServiceHub hub;
  final void Function(String orderId)? onSeated;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final r = reservation;
    final labels = hub.tableLabels;
    final color = reservationColor(r.status);
    return Card(
      child: ListTile(
        leading: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(hm(context, r.startsAt), style: const TextStyle(fontWeight: FontWeight.w800)),
          Text(hm(context, r.endsAt), style: Theme.of(context).textTheme.bodySmall),
        ]),
        title: Text('${r.customerName} · ${t.guestsCount(r.partySize)}'),
        subtitle: Text([
          if (r.tableIds.isNotEmpty) r.tableIds.map((id) => labels[id] ?? '?').join(', '),
          ?r.contactPhone,
          ?r.note,
        ].join(' · ')),
        trailing: StatusPill(label: reservationStatusLabel(t, r.status), color: color, dense: true),
        onTap: () => showReservationActions(context, hub, r, onSeated: onSeated),
      ),
    );
  }
}
