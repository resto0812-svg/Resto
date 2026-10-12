import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show RealtimeChannel;

import '../../app_state.dart';
import '../../data/menu_models.dart';
import '../../data/models.dart';
import '../../data/orders_api.dart';
import '../../ui/branch_scope.dart';
import '../../ui/chime.dart';
import '../../ui/common.dart';
import '../../ui/kit.dart';
import '../../ui/theme.dart';
import '../menus/menu_widgets.dart';
import '../service/service_labels.dart';

/// Écran de préparation (cuisine, bar) : un ticket par commande, les plus
/// anciens d'abord. « Tout est prêt » prévient la salle : la commande passe
/// dans « Prêtes à servir » chez les serveurs (ou « à remettre » pour la
/// vente à emporter et la livraison), avec une sonnerie.
class KitchenScreen extends StatelessWidget {
  const KitchenScreen({super.key, required this.membership});
  final Membership membership;

  @override
  Widget build(BuildContext context) =>
      BranchScope(membership: membership, builder: (context, scope) => KitchenBoard(key: ValueKey(scope.branchId), scope: scope));
}

class KitchenBoard extends StatefulWidget {
  const KitchenBoard({super.key, required this.scope, this.fullScreen = false});
  final BranchContext scope;
  final bool fullScreen;

  @override
  State<KitchenBoard> createState() => _KitchenBoardState();
}

class _KitchenBoardState extends State<KitchenBoard> {
  List<PrepStation> _stations = const [];
  List<KitchenLine> _lines = const [];
  String? _stationId; // null = tous les postes
  bool _summary = false;
  bool _loading = true;
  Object? _error;
  RealtimeChannel? _channel;
  late final OrdersApi _api = AppScope.read(context).api!.orders;
  Timer? _timer;
  Timer? _debounce;
  Set<String>? _knownSent;

  BranchContext get scope => widget.scope;
  bool get _canOperate => scope.can('kitchen.operate');
  bool get _canServe => _canOperate || scope.can('orders.write');
  bool get _canManage => scope.can('branches.manage');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _load();
      _channel = _api.watchBranch(scope.branchId, _scheduleReload);
    });
    _timer = Timer.periodic(const Duration(seconds: 20), (_) => _load());
  }

  @override
  void dispose() {
    _timer?.cancel();
    _debounce?.cancel();
    if (_channel != null) _api.unwatch(_channel!);
    super.dispose();
  }

  void _scheduleReload() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), _load);
  }

  Future<void> _load() async {
    if (!mounted) return;
    try {
      final r = await Future.wait<dynamic>([_api.stations(scope.branchId), _api.kitchenQueue(scope.branchId)]);
      if (!mounted) return;
      final lines = r[1] as List<KitchenLine>;
      final sent = {for (final l in lines.where((l) => l.line.prepStatus == 'sent')) l.line.id};
      if (_knownSent != null && sent.difference(_knownSent!).isNotEmpty) playChime();
      _knownSent = sent;
      setState(() {
        _stations = r[0] as List<PrepStation>;
        _lines = lines;
        _loading = false;
        _error = null;
      });
    } catch (e) {
      if (mounted) setState(() => _error = e);
    }
  }

  Future<void> _advance(List<KitchenLine> lines, String status) async {
    if (lines.isEmpty) return;
    try {
      await _api.setPrepStatus([for (final l in lines) l.line.id], status);
      await _load();
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  Future<void> _editStation([PrepStation? s]) async {
    final result = await showDialog<(String, List<String>, bool)>(context: context, builder: (_) => _StationDialog(station: s));
    if (result == null || !mounted) return;
    try {
      await _api.saveStation(
        orgId: scope.orgId,
        branchId: scope.branchId,
        id: s?.id,
        name: result.$1,
        kinds: result.$2,
        active: result.$3,
      );
      await _load();
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  void _openFullScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (c) => Scaffold(
          appBar: AppBar(title: Text(c.t.navKitchen, style: serifTitle(c, size: 28))),
          body: KitchenBoard(scope: scope, fullScreen: true),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    if (_loading && _error == null) return const Center(child: CircularProgressIndicator());
    if (_error != null && _lines.isEmpty) {
      return Center(child: OutlinedButton(onPressed: _load, child: Text(t.retry)));
    }
    final shown = _lines.where((l) => _stationId == null || l.stationId == null || l.stationId == _stationId).toList();
    final byOrder = <String, List<KitchenLine>>{};
    for (final l in shown) {
      byOrder.putIfAbsent(l.orderId, () => []).add(l);
    }
    final target = scope.branch.targetPrepMinutes;
    final cooking = byOrder.entries.where((e) => e.value.any((l) => l.line.prepStatus != 'ready')).toList();
    final ready = byOrder.entries.where((e) => e.value.every((l) => l.line.prepStatus == 'ready')).toList();
    final lateCount = cooking.where((e) => DateTime.now().difference(e.value.first.sentAt).inMinutes >= target).length;

    final side = MediaQuery.sizeOf(context).width < 600 ? 16.0 : 22.0;
    final toolbar = Padding(
      padding: EdgeInsets.fromLTRB(side, 2, side, 6),
      child: Wrap(spacing: 6, runSpacing: 6, crossAxisAlignment: WrapCrossAlignment.center, children: [
        GoldPill(
          label: t.allStations,
          icon: Icons.check_rounded,
          dense: true,
          selected: _stationId == null,
          onTap: () => setState(() => _stationId = null),
        ),
        for (final s in _stations.where((s) => s.active))
          GoldPill(label: s.name, dense: true, selected: _stationId == s.id, onTap: () => setState(() => _stationId = s.id)),
        if (_canManage)
          PopupMenuButton<String>(
            tooltip: t.stations,
            icon: const Icon(Icons.tune_rounded, color: RestoColors.primaryDeep),
            onSelected: (id) => id.isEmpty ? _editStation() : _editStation(_stations.firstWhere((s) => s.id == id)),
            itemBuilder: (_) => [
              for (final s in _stations) PopupMenuItem(value: s.id, child: Text(s.active ? s.name : '${s.name} · ${t.inactive}')),
              PopupMenuItem(value: '', child: Text(t.newStation)),
            ],
          ),
        _CountChip(icon: Icons.soup_kitchen_outlined, text: t.kdsToPrepare(cooking.length)),
        if (lateCount > 0) _CountChip(icon: Icons.alarm_rounded, text: t.kdsLate(lateCount), alert: true),
        _CountChip(icon: Icons.room_service_outlined, text: t.kdsReadyCount(ready.length)),
        GoldPill(
          label: t.kdsTickets,
          icon: Icons.receipt_rounded,
          dense: true,
          selected: !_summary,
          onTap: () => setState(() => _summary = false),
        ),
        GoldPill(
          label: t.kdsSummary,
          icon: Icons.summarize_outlined,
          dense: true,
          selected: _summary,
          onTap: () => setState(() => _summary = true),
        ),
        if (!widget.fullScreen)
          IconButton(tooltip: t.kdsFullScreen, onPressed: _openFullScreen, icon: const Icon(Icons.fullscreen_rounded)),
      ]),
    );

    // Barre d'outils alignée à gauche (et non centrée).
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      toolbar,
      Expanded(
        child: cooking.isEmpty
            ? ListView(padding: EdgeInsets.fromLTRB(side, 10, side, 24), children: [
                EmptyState(icon: Icons.soup_kitchen_outlined, title: t.kitchenEmpty, message: t.kdsFlowHint),
              ])
            : _summary
                ? _Summary(lines: [for (final e in cooking) ...e.value.where((l) => l.line.prepStatus != 'ready')])
                : RefreshIndicator(
                    onRefresh: _load,
                    child: ListView(padding: EdgeInsets.fromLTRB(side, 4, side, 16), children: [
                      LayoutBuilder(builder: (context, box) {
                        final cols = (box.maxWidth / 320).floor().clamp(1, 6);
                        final w = (box.maxWidth - (cols - 1) * 14) / cols;
                        return Wrap(spacing: 14, runSpacing: 14, children: [
                          for (final e in cooking)
                            SizedBox(width: w, child: _Ticket(lines: e.value, target: target, canOperate: _canOperate, onAdvance: _advance)),
                        ]);
                      }),
                    ]),
                  ),
      ),
      if (ready.isNotEmpty)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
          decoration: BoxDecoration(
            color: StatusColors.ready.withValues(alpha: 0.10),
            border: const Border(top: BorderSide(color: StatusColors.ready, width: 2)),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Icon(Icons.room_service_rounded, color: StatusColors.ready),
              const SizedBox(width: 8),
              Expanded(child: Text(t.kdsReadyStrip, style: theme.textTheme.titleSmall?.copyWith(color: StatusColors.ready))),
            ]),
            const SizedBox(height: 8),
            SizedBox(
              height: 64,
              child: ListView(scrollDirection: Axis.horizontal, children: [
                for (final e in ready)
                  _ReadyChip(
                    lines: e.value,
                    canOperate: _canOperate,
                    canServe: _canServe,
                    onRecall: () => _advance(e.value, 'preparing'),
                    onServed: () => _advance(e.value, 'served'),
                  ),
              ]),
            ),
          ]),
        ),
    ]);
  }
}

String _place(BuildContext context, KitchenLine l) {
  final t = context.t;
  return switch (l.channel) {
    'dine_in' => l.tableLabel ?? t.channelDineIn,
    'delivery' => t.channelDelivery,
    _ => t.channelTakeaway,
  };
}

class _Ticket extends StatelessWidget {
  const _Ticket({required this.lines, required this.target, required this.canOperate, required this.onAdvance});
  final List<KitchenLine> lines;
  final int target;
  final bool canOperate;
  final Future<void> Function(List<KitchenLine>, String) onAdvance;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final first = lines.first;
    final minutes = DateTime.now().difference(lines.map((l) => l.sentAt).reduce((a, b) => a.isBefore(b) ? a : b)).inMinutes;
    final late = minutes >= target;
    final sent = lines.where((l) => l.line.prepStatus == 'sent').toList();
    final notReady = lines.where((l) => l.line.prepStatus != 'ready').toList();
    final info = <(IconData, String)>[
      (sourceIcon(first.source), sourceLabel(t, first.source)),
      if (first.customerName != null) (Icons.person_rounded, first.customerName!),
      if (first.guests != null) (Icons.groups_2_rounded, t.guestsCount(first.guests!)),
      if (first.scheduledFor != null) (Icons.schedule_rounded, t.forTime(hm(context, first.scheduledFor!))),
      if (first.promisedAt != null && first.scheduledFor == null) (Icons.timer_outlined, t.promisedFor(hm(context, first.promisedAt!))),
    ];
    return GoldHeaderCard(
      title: '${_place(context, first)} · #${first.orderNumber}',
      titleIcon: channelIcon(first.channel),
      headerColor: late ? StatusColors.late : null,
      badge: HeaderBadge(text: durationText(minutes), icon: Icons.schedule_rounded),
      info: Wrap(spacing: 12, runSpacing: 2, children: [
        for (final (icon, text) in info)
          Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, size: 14, color: RestoColors.primaryDeep),
            const SizedBox(width: 4),
            Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
          ]),
      ]),
      action: canOperate
          ? Row(children: [
              if (sent.isNotEmpty) ...[
                Expanded(child: GoldButton(label: t.kdsStart, outlined: true, onPressed: () => onAdvance(sent, 'preparing'))),
                const SizedBox(width: 8),
              ],
              Expanded(
                flex: 2,
                child: GoldButton(
                  label: t.allReady,
                  icon: Icons.check_rounded,
                  onPressed: notReady.isEmpty ? null : () => onAdvance(notReady, 'ready'),
                ),
              ),
            ])
          : null,
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        if (first.orderNote != null)
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: StatusColors.cooking.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
            child: Text(first.orderNote!, style: const TextStyle(fontWeight: FontWeight.w700)),
          ),
        for (final l in lines)
          InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: switch (l.line.prepStatus) {
              'sent' when canOperate => () => onAdvance([l], 'preparing'),
              'preparing' when canOperate => () => onAdvance([l], 'ready'),
              'ready' when canOperate => () => onAdvance([l], 'preparing'),
              _ => null,
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('${l.line.quantity} × ${l.line.title}',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          decoration: l.line.prepStatus == 'ready' ? TextDecoration.lineThrough : null,
                        )),
                    for (final o in l.line.options)
                      Text('+ ${o.name}', style: const TextStyle(fontSize: 13.5, color: RestoColors.muted)),
                    if (l.line.note != null)
                      Container(
                        margin: const EdgeInsets.only(top: 3),
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: StatusColors.late.withValues(alpha: 0.10), borderRadius: BorderRadius.circular(6)),
                        child: Text('» ${l.line.note}', style: const TextStyle(fontWeight: FontWeight.w700, color: StatusColors.late)),
                      ),
                  ]),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: switch (l.line.prepStatus) {
                      'ready' => StatusColors.ready.withValues(alpha: 0.14),
                      _ => RestoColors.band,
                    },
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    prepStatusLabel(t, l.line.prepStatus),
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: l.line.prepStatus == 'ready' ? StatusColors.ready : const Color(0xFF8A6A1F),
                    ),
                  ),
                ),
              ]),
            ),
          ),
      ]),
    );
  }
}

/// Compteur discret de la barre de cuisine (« 3 commandes à préparer »).
class _CountChip extends StatelessWidget {
  const _CountChip({required this.icon, required this.text, this.alert = false});
  final IconData icon;
  final String text;
  final bool alert;

  @override
  Widget build(BuildContext context) {
    final color = alert ? StatusColors.late : RestoColors.primaryDeep;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: alert ? StatusColors.late.withValues(alpha: 0.10) : RestoColors.primarySoft,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Text(text, style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 12.5)),
      ]),
    );
  }
}

class _ReadyChip extends StatelessWidget {
  const _ReadyChip({required this.lines, required this.canOperate, required this.canServe, required this.onRecall, required this.onServed});
  final List<KitchenLine> lines;
  final bool canOperate;
  final bool canServe;
  final VoidCallback onRecall;
  final VoidCallback onServed;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final first = lines.first;
    final readyAt = lines.map((l) => l.readyAt).whereType<DateTime>().fold<DateTime?>(null, (a, b) => a == null || b.isAfter(a) ? b : a);
    final waiting = readyAt == null ? 0 : DateTime.now().difference(readyAt).inMinutes;
    return Container(
      margin: const EdgeInsetsDirectional.only(end: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: StatusColors.ready),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(channelIcon(first.channel), color: StatusColors.ready),
        const SizedBox(width: 8),
        Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('${_place(context, first)} · #${first.orderNumber}', style: const TextStyle(fontWeight: FontWeight.w800)),
          Text(t.kdsWaitingService(durationText(waiting)), style: Theme.of(context).textTheme.bodySmall),
        ]),
        const SizedBox(width: 8),
        if (canOperate) IconButton(tooltip: t.kdsRecall, onPressed: onRecall, icon: const Icon(Icons.undo_rounded)),
        if (canServe)
          IconButton.filled(
            style: IconButton.styleFrom(backgroundColor: StatusColors.ready),
            tooltip: servedAction(t, first.channel),
            onPressed: onServed,
            icon: const Icon(Icons.room_service_rounded, color: Colors.white),
          ),
      ]),
    );
  }
}

/// Cumul : combien de chaque plat lancer en même temps.
class _Summary extends StatelessWidget {
  const _Summary({required this.lines});
  final List<KitchenLine> lines;

  @override
  Widget build(BuildContext context) {
    final totals = <String, int>{};
    for (final l in lines) {
      final key = [l.line.title, ...l.line.options.map((o) => '+ ${o.name}')].join('  ');
      totals[key] = (totals[key] ?? 0) + l.line.quantity;
    }
    final entries = totals.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 24), children: [
      for (final e in entries)
        Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: StatusColors.cooking.withValues(alpha: 0.15),
              child: Text('${e.value}', style: const TextStyle(fontWeight: FontWeight.w900, color: StatusColors.cooking)),
            ),
            title: Text(e.key, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          ),
        ),
    ]);
  }
}

class _StationDialog extends StatefulWidget {
  const _StationDialog({this.station});
  final PrepStation? station;

  @override
  State<_StationDialog> createState() => _StationDialogState();
}

class _StationDialogState extends State<_StationDialog> {
  late final _name = TextEditingController(text: widget.station?.name);
  late final Set<String> _kinds = {...?widget.station?.kinds};
  late bool _active = widget.station?.active ?? true;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return AlertDialog(
      title: Text(widget.station == null ? t.newStation : t.edit),
      content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        TextField(
          controller: _name,
          autofocus: true,
          maxLength: 60,
          decoration: InputDecoration(labelText: t.name, hintText: t.stationExamples),
        ),
        Text(t.stationPrepares),
        Wrap(spacing: 8, children: [
          for (final k in itemKinds)
            FilterChip(
              label: Text(kindLabel(t, k)),
              selected: _kinds.contains(k),
              onSelected: (on) => setState(() => on ? _kinds.add(k) : _kinds.remove(k)),
            ),
        ]),
        if (widget.station != null)
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(t.active),
            value: _active,
            onChanged: (v) => setState(() => _active = v),
          ),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(t.cancel)),
        FilledButton(
          onPressed: () {
            if (_name.text.trim().isEmpty || _kinds.isEmpty) return;
            Navigator.pop(context, (_name.text.trim(), _kinds.toList(), _active));
          },
          child: Text(t.save),
        ),
      ],
    );
  }
}
