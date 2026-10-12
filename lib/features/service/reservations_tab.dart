import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app_state.dart';
import '../../data/models.dart';
import '../../data/reservations_api.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/common.dart';
import '../../ui/files.dart';
import '../../ui/theme.dart';
import '../menus/menu_widgets.dart';
import 'salle_tab.dart' show ReservationTile;
import 'service_actions.dart';
import 'service_hub.dart';
import 'reservation_table_picker.dart';
import 'service_labels.dart';

String reservationStatusLabel(AppLocalizations t, String s) => switch (s) {
      'requested' => t.resRequested,
      'confirmed' => t.resConfirmed,
      'seated' => t.resSeated,
      'completed' => t.resCompleted,
      'no_show' => t.resNoShow,
      'declined' => t.resDeclined,
      _ => t.resCancelled,
    };

Color reservationColor(String s) => switch (s) {
      'requested' => StatusColors.toValidate,
      'confirmed' => StatusColors.reserved,
      'seated' => StatusColors.occupied,
      'completed' => StatusColors.done,
      _ => StatusColors.late,
    };

/// Réservations : planning de la journée table par table, demandes des
/// clients à traiter, nouvelle réservation (téléphone, sur place).
class ReservationsTab extends StatefulWidget {
  const ReservationsTab({super.key, required this.hub, required this.onOpenOrder});
  final ServiceHub hub;
  final void Function(String orderId) onOpenOrder;

  @override
  State<ReservationsTab> createState() => _ReservationsTabState();
}

class _ReservationsTabState extends State<ReservationsTab> {
  DateTime _day = _today();
  bool? _timeline;
  Key _key = UniqueKey();

  static DateTime _today() {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }

  bool get _isToday => _day == _today();
  ServiceHub get hub => widget.hub;

  Future<void> _new({DiningTable? table, DateTime? start}) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => ReservationDialog(hub: hub, table: table, start: start ?? (_isToday ? null : _day.add(const Duration(hours: 20)))),
    );
    if (ok == true) _reload();
  }

  void _reload() {
    hub.load();
    setState(() => _key = UniqueKey());
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    final wide = MediaQuery.sizeOf(context).width >= 760;
    final timeline = _timeline ?? wide;

    Widget content(List<Reservation> list) {
      final active = list.where((r) => r.status != 'cancelled' && r.status != 'declined').toList();
      final covers = active.fold<int>(0, (a, r) => a + r.partySize);
      return ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 40), children: [
        if (hub.requests.isNotEmpty) ...[
          Card(
            color: StatusColors.toValidate.withValues(alpha: 0.08),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  const Icon(Icons.notifications_active_rounded, color: StatusColors.toValidate),
                  const SizedBox(width: 8),
                  Text(t.reservationRequests(hub.requests.length), style: theme.textTheme.titleMedium),
                ]),
                const SizedBox(height: 4),
                Text(t.reservationRequestsHint, style: theme.textTheme.bodySmall),
                const SizedBox(height: 8),
                for (final r in hub.requests)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text('${dayLabel(context, r.startsAt)} · ${hm(context, r.startsAt)}'),
                    subtitle: Text([r.customerName, t.guestsCount(r.partySize), ?r.contactPhone, ?r.note].join(' · ')),
                    trailing: Wrap(spacing: 6, children: [
                      TextButton(
                        onPressed: () async {
                          final reason = await askReason(context, t.declineReservation);
                          if (reason == null || !context.mounted) return;
                          try {
                            await AppScope.read(context).api!.reservations.setStatus(r.id, 'declined', reason);
                            _reload();
                          } catch (e) {
                            if (context.mounted) showError(context, e);
                          }
                        },
                        child: Text(t.reject),
                      ),
                      FilledButton(
                        onPressed: () async {
                          if (await confirmWithTables(context, hub, r)) _reload();
                        },
                        child: Text(t.confirmReservation),
                      ),
                    ]),
                  ),
              ]),
            ),
          ),
          const SizedBox(height: 8),
        ],
        Wrap(spacing: 10, runSpacing: 10, children: [
          StatusPill(label: t.reservationsCount(active.length), color: StatusColors.reserved),
          StatusPill(label: t.coversCount(covers), color: StatusColors.occupied),
        ]),
        const SizedBox(height: 12),
        if (timeline && hub.allTables.isNotEmpty) ...[
          if (list.isEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(t.timelineEmptyHint, style: theme.textTheme.bodySmall),
            ),
          ReservationTimeline(
            hub: hub,
            day: _day,
            reservations: list,
            onTap: (r) async {
              await showReservationActions(context, hub, r, onSeated: widget.onOpenOrder);
              _reload();
            },
            onEmpty: (tb, start) => _new(table: tb, start: start),
          ),
        ] else if (list.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: Column(children: [
              Icon(Icons.event_available_rounded, size: 48, color: theme.colorScheme.outline),
              const SizedBox(height: 8),
              Text(t.noReservationsDay, textAlign: TextAlign.center),
            ]),
          )
        else
          for (final r in list) ReservationTile(reservation: r, hub: hub, onSeated: widget.onOpenOrder),
      ]);
    }

    return Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
        child: Wrap(spacing: 8, runSpacing: 8, crossAxisAlignment: WrapCrossAlignment.center, children: [
          IconButton.outlined(
            onPressed: () => setState(() {
              _day = _day.subtract(const Duration(days: 1));
              _key = UniqueKey();
            }),
            icon: const Icon(Icons.chevron_left),
          ),
          TextButton(
            onPressed: () async {
              final d = await showDatePicker(
                context: context,
                initialDate: _day,
                firstDate: _today().subtract(const Duration(days: 365)),
                lastDate: _today().add(const Duration(days: 365)),
              );
              if (d != null) setState(() => _day = d);
            },
            child: Text(_isToday ? '${t.today} · ${dayLabel(context, _day)}' : dayLabel(context, _day),
                style: theme.textTheme.titleMedium),
          ),
          IconButton.outlined(
            onPressed: () => setState(() {
              _day = _day.add(const Duration(days: 1));
              _key = UniqueKey();
            }),
            icon: const Icon(Icons.chevron_right),
          ),
          if (!_isToday) TextButton(onPressed: () => setState(() => _day = _today()), child: Text(t.today)),
          SegmentedButton<bool>(
            showSelectedIcon: false,
            segments: [
              ButtonSegment(value: true, icon: const Icon(Icons.view_timeline_outlined, size: 18), label: Text(t.timelineView)),
              ButtonSegment(value: false, icon: const Icon(Icons.view_list_rounded, size: 18), label: Text(t.listView)),
            ],
            selected: {timeline},
            onSelectionChanged: (s) => setState(() => _timeline = s.first),
          ),
          FilledButton.icon(onPressed: () => _new(), icon: const Icon(Icons.add), label: Text(t.newReservation)),
        ]),
      ),
      Expanded(
        child: _isToday
            ? content(hub.reservations)
            : Loader<List<Reservation>>(
                key: ValueKey('$_day$_key'),
                load: () => AppScope.read(context).api!.reservations.day(hub.scope.branchId, _day),
                builder: (context, list, _) => content(list),
              ),
      ),
    ]);
  }
}

/// Planning chronologique : une ligne par table, une barre par réservation.
class ReservationTimeline extends StatelessWidget {
  const ReservationTimeline({
    super.key,
    required this.hub,
    required this.day,
    required this.reservations,
    required this.onTap,
    required this.onEmpty,
  });
  final ServiceHub hub;
  final DateTime day;
  final List<Reservation> reservations;
  final void Function(Reservation) onTap;
  final void Function(DiningTable, DateTime) onEmpty;

  static const hourWidth = 92.0;
  static const rowHeight = 46.0;
  static const labelWidth = 110.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = context.t;
    var startHour = 10, endHour = 24;
    for (final r in reservations) {
      startHour = math.min(startHour, r.startsAt.hour);
      endHour = math.max(endHour, math.min(30, r.endsAt.difference(day).inMinutes ~/ 60 + 1));
    }
    final dayStart = day.add(Duration(hours: startHour));
    final width = (endHour - startHour) * hourWidth;
    final rows = <(String?, DiningTable?)>[
      for (final a in hub.areas.where((a) => a.active && a.tables.any((x) => x.active))) ...[
        (a.name, null),
        for (final tb in a.tables.where((x) => x.active)) (null, tb),
      ],
    ];
    final now = DateTime.now();
    final showNow = now.isAfter(dayStart) && now.isBefore(dayStart.add(Duration(hours: endHour - startHour)));
    double x(DateTime d) => d.difference(dayStart).inMinutes / 60 * hourWidth;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(14),
        color: theme.colorScheme.surfaceContainerLowest,
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(
          width: labelWidth,
          child: Column(children: [
            const SizedBox(height: 32),
            for (final (area, tb) in rows)
              Container(
                height: area != null ? 28 : rowHeight,
                alignment: AlignmentDirectional.centerStart,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                color: area != null ? theme.colorScheme.surfaceContainer : null,
                child: Text(area ?? '${tb!.label} · ${tb.seats}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: area != null ? theme.textTheme.labelSmall : theme.textTheme.labelLarge),
              ),
          ]),
        ),
        const VerticalDivider(width: 1),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: width,
              child: Stack(children: [
                Column(children: [
                  SizedBox(
                    height: 32,
                    child: Row(children: [
                      for (var h = startHour; h < endHour; h++)
                        SizedBox(
                          width: hourWidth,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 4, top: 8),
                            child: Text('${(h % 24).toString().padLeft(2, '0')}:00', style: theme.textTheme.labelSmall),
                          ),
                        ),
                    ]),
                  ),
                  for (final (area, tb) in rows)
                    if (area != null)
                      Container(height: 28, color: theme.colorScheme.surfaceContainer)
                    else
                      SizedBox(
                        height: rowHeight,
                        child: Stack(children: [
                          Row(children: [
                            for (var h = startHour; h < endHour; h++)
                              GestureDetector(
                                onTap: () => onEmpty(tb!, dayStart.add(Duration(hours: h - startHour))),
                                child: Container(
                                  width: hourWidth,
                                  decoration: BoxDecoration(
                                    border: Border(
                                      left: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6)),
                                      bottom: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4)),
                                    ),
                                  ),
                                ),
                              ),
                          ]),
                          for (final r in reservations.where((r) => r.tableIds.contains(tb!.id)))
                            Positioned(
                              left: math.max(0, x(r.startsAt)),
                              top: 5,
                              width: math.max(24, x(r.endsAt) - math.max(0, x(r.startsAt))),
                              height: rowHeight - 10,
                              child: _Block(reservation: r, onTap: () => onTap(r)),
                            ),
                        ]),
                      ),
                ]),
                if (showNow)
                  Positioned(
                    left: x(now),
                    top: 0,
                    bottom: 0,
                    child: Container(width: 2, color: StatusColors.late),
                  ),
                if (showNow)
                  Positioned(
                    left: x(now) + 4,
                    top: 2,
                    child: Text(t.nowLabel, style: const TextStyle(color: StatusColors.late, fontWeight: FontWeight.w800, fontSize: 11)),
                  ),
              ]),
            ),
          ),
        ),
      ]),
    );
  }
}

class _Block extends StatelessWidget {
  const _Block({required this.reservation, required this.onTap});
  final Reservation reservation;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final r = reservation;
    final color = reservationColor(r.status);
    final faded = r.status == 'completed' || r.status == 'cancelled' || r.status == 'no_show' || r.status == 'declined';
    return Material(
      color: color.withValues(alpha: faded ? 0.10 : 0.85),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Row(children: [
            Expanded(
              child: Text(
                '${hm(context, r.startsAt)} ${r.customerName} · ${r.partySize}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: faded ? color : Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  decoration: r.status == 'cancelled' || r.status == 'declined' ? TextDecoration.lineThrough : null,
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

/// Actions sur une réservation selon son état.
Future<void> showReservationActions(BuildContext context, ServiceHub hub, Reservation r, {void Function(String orderId)? onSeated}) {
  return showModalBottomSheet<void>(
    context: context,
    builder: (c) {
      final t = c.t;
      final api = AppScope.read(c).api!;
      Future<void> run(Future<void> Function() f) async {
        try {
          await f();
          await hub.load();
          if (c.mounted) Navigator.pop(c);
        } catch (e) {
          if (c.mounted) showError(c, e);
        }
      }

      final labels = hub.tableLabels;
      final order = hub.orders.where((o) => o.reservationId == r.id && o.isOpen).firstOrNull;
      return SafeArea(
        child: ListView(shrinkWrap: true, padding: const EdgeInsets.fromLTRB(20, 0, 20, 20), children: [
          Row(children: [
            Expanded(child: Text(r.customerName, style: Theme.of(c).textTheme.headlineSmall)),
            StatusPill(label: reservationStatusLabel(t, r.status), color: reservationColor(r.status)),
          ]),
          const SizedBox(height: 6),
          Text('${dayLabel(c, r.startsAt)} · ${hm(c, r.startsAt)} – ${hm(c, r.endsAt)} · ${t.guestsCount(r.partySize)}'),
          if (r.tableIds.isNotEmpty) Text(r.tableIds.map((id) => labels[id] ?? '?').join(', ')),
          if (r.note != null) Text('« ${r.note} »', style: const TextStyle(fontStyle: FontStyle.italic)),
          if (r.reason != null) Text(r.reason!, style: Theme.of(c).textTheme.bodySmall),
          const SizedBox(height: 16),
          Wrap(spacing: 8, runSpacing: 8, children: [
            if (r.contactPhone != null)
              OutlinedButton.icon(
                onPressed: () => openLink('tel:${r.contactPhone!.replaceAll(' ', '')}'),
                icon: const Icon(Icons.call_rounded),
                label: Text(r.contactPhone!),
              ),
            if (r.status == 'requested') ...[
              FilledButton(
                onPressed: () async {
                  if (await confirmWithTables(c, hub, r) && c.mounted) Navigator.pop(c);
                },
                child: Text(t.confirmReservation),
              ),
              OutlinedButton(
                onPressed: () async {
                  final reason = await askReason(c, t.declineReservation);
                  if (reason != null) await run(() => api.reservations.setStatus(r.id, 'declined', reason));
                },
                child: Text(t.reject),
              ),
            ],
            if (r.status == 'confirmed') ...[
              FilledButton.icon(
                onPressed: () => run(() async {
                  final id = await api.orders.seatReservation(r.id);
                  onSeated?.call(id);
                }),
                icon: const Icon(Icons.event_seat_rounded),
                label: Text(t.seatGuests),
              ),
              OutlinedButton(
                onPressed: () async {
                  if (await confirmWithTables(c, hub, r) && c.mounted) Navigator.pop(c);
                },
                child: Text(t.changeTables),
              ),
              OutlinedButton(onPressed: () => run(() => api.reservations.setStatus(r.id, 'no_show')), child: Text(t.markNoShow)),
              OutlinedButton(
                onPressed: () async {
                  final reason = await askReason(c, t.cancelReservation);
                  if (reason != null) await run(() => api.reservations.setStatus(r.id, 'cancelled', reason));
                },
                child: Text(t.cancelReservation),
              ),
            ],
            if (r.status == 'seated') ...[
              if (order != null)
                FilledButton.icon(
                  onPressed: () {
                    Navigator.pop(c);
                    onSeated?.call(order.id);
                  },
                  icon: const Icon(Icons.receipt_long_rounded),
                  label: Text(t.openOrder),
                ),
              OutlinedButton(onPressed: () => run(() => api.reservations.setStatus(r.id, 'completed')), child: Text(t.markCompleted)),
            ],
          ]),
        ]),
      );
    },
  );
}

/// Réservations du jour d'un créneau (celles de l'écran si c'est aujourd'hui).
Future<List<Reservation>> _reservationsOf(BuildContext context, ServiceHub hub, DateTime start) async {
  final now = DateTime.now();
  if (start.year == now.year && start.month == now.month && start.day == now.day) return hub.reservations;
  return AppScope.read(context).api!.reservations.day(hub.scope.branchId, start);
}

/// Confirmation (ou changement de tables) d'une réservation : toutes les
/// tables, avec leur disponibilité sur le créneau.
Future<bool> confirmWithTables(BuildContext context, ServiceHub hub, Reservation r) async {
  final api = AppScope.read(context).api!;
  try {
    final dayList = await _reservationsOf(context, hub, r.startsAt);
    if (!context.mounted) return false;
    final selected = {...r.tableIds};
    final picked = await showDialog<List<String>>(
      context: context,
      builder: (c) => StatefulBuilder(
        builder: (c, setState) => AlertDialog(
          title: Text('${c.t.chooseTables} · ${r.customerName}'),
          content: SizedBox(
            width: 640,
            child: SingleChildScrollView(
              child: ReservationTablePicker(
                hub: hub,
                start: r.startsAt,
                end: r.endsAt,
                partySize: r.partySize,
                reservations: dayList,
                excludeReservationId: r.id,
                selected: selected,
                onChanged: () => setState(() {}),
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(c), child: Text(c.t.cancel)),
            FilledButton(onPressed: selected.isEmpty ? null : () => Navigator.pop(c, selected.toList()), child: Text(c.t.confirm)),
          ],
        ),
      ),
    );
    if (picked == null) return false;
    await api.reservations.confirm(r.id, picked);
    await hub.load();
    return true;
  } catch (e) {
    if (context.mounted) showError(context, e);
    return false;
  }
}

/// Nouvelle réservation (prise par l'équipe : confirmée d'emblée).
class ReservationDialog extends StatefulWidget {
  const ReservationDialog({super.key, required this.hub, this.table, this.start});
  final ServiceHub hub;
  final DiningTable? table;
  final DateTime? start;

  @override
  State<ReservationDialog> createState() => _ReservationDialogState();
}

class _ReservationDialogState extends State<ReservationDialog> {
  final _form = GlobalKey<FormState>();
  late DateTime _start = widget.start ?? _nextSlot();
  late int _minutes = widget.hub.scope.branch.reservationMinutes;
  late int _party = math.min(widget.table?.seats ?? 2, 4);
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _note = TextEditingController();
  late final Set<String> _tables = {?widget.table?.id};
  List<Reservation>? _dayList;
  final _clientId = uuidV4();
  bool _busy = false;
  bool _tried = false;

  static DateTime _nextSlot() {
    final n = DateTime.now().add(const Duration(minutes: 60));
    return DateTime(n.year, n.month, n.day, n.hour, n.minute < 30 ? 30 : 0).add(Duration(hours: n.minute < 30 ? 0 : 1));
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadDay());
  }

  @override
  void dispose() {
    for (final c in [_name, _phone, _note]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _loadDay() async {
    setState(() => _dayList = null);
    try {
      final list = await _reservationsOf(context, widget.hub, _start);
      if (mounted) setState(() => _dayList = list);
    } catch (e) {
      if (mounted) {
        setState(() => _dayList = const []);
        showError(context, e);
      }
    }
  }

  Future<void> _save() async {
    setState(() => _tried = true);
    if (!_form.currentState!.validate() || _tables.isEmpty) return;
    setState(() => _busy = true);
    try {
      await AppScope.read(context).api!.reservations.create(
            branchId: widget.hub.scope.branchId,
            startsAt: _start,
            minutes: _minutes,
            partySize: _party,
            name: _name.text.trim(),
            phone: _phone.text.trim().isEmpty ? null : _phone.text.trim(),
            tableIds: _tables.toList(),
            note: _note.text.trim().isEmpty ? null : _note.text.trim(),
            clientId: _clientId,
          );
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) showError(context, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    return AlertDialog(
      title: Text(t.newReservation),
      content: SizedBox(
        width: 680,
        child: Form(
          key: _form,
          child: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Wrap(spacing: 8, runSpacing: 8, crossAxisAlignment: WrapCrossAlignment.center, children: [
                ActionChip(
                  avatar: const Icon(Icons.calendar_today_rounded, size: 16),
                  label: Text(dayLabel(context, _start)),
                  onPressed: () async {
                    final d = await showDatePicker(
                      context: context,
                      initialDate: _start,
                      firstDate: DateTime.now().subtract(const Duration(days: 1)),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (d == null) return;
                    setState(() => _start = DateTime(d.year, d.month, d.day, _start.hour, _start.minute));
                    _loadDay();
                  },
                ),
                ActionChip(
                  avatar: const Icon(Icons.schedule_rounded, size: 16),
                  label: Text(hm(context, _start)),
                  onPressed: () async {
                    final p = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(_start));
                    if (p == null) return;
                    setState(() => _start = DateTime(_start.year, _start.month, _start.day, p.hour, p.minute));
                  },
                ),
                DropdownButton<int>(
                  value: _minutes,
                  underline: const SizedBox.shrink(),
                  items: [
                    for (final m in {60, 90, 120, 150, 180, 240, widget.hub.scope.branch.reservationMinutes}.toList()..sort())
                      DropdownMenuItem(value: m, child: Text(durationText(m))),
                  ],
                  onChanged: (v) => setState(() => _minutes = v ?? _minutes),
                ),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: Text(t.guestsLabel, style: theme.textTheme.titleSmall)),
                IconButton.outlined(onPressed: _party > 1 ? () => setState(() => _party--) : null, icon: const Icon(Icons.remove)),
                SizedBox(width: 44, child: Text('$_party', textAlign: TextAlign.center, style: theme.textTheme.titleLarge)),
                IconButton.outlined(onPressed: _party < 200 ? () => setState(() => _party++) : null, icon: const Icon(Icons.add)),
              ]),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(
                  child: TextFormField(
                    controller: _name,
                    maxLength: 120,
                    decoration: InputDecoration(labelText: t.customerName, counterText: ''),
                    validator: (v) => (v ?? '').trim().isEmpty ? t.fieldRequired : null,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: _phone,
                    maxLength: 40,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(labelText: t.phone, counterText: ''),
                  ),
                ),
              ]),
              const SizedBox(height: 10),
              TextFormField(
                controller: _note,
                maxLength: 500,
                decoration: InputDecoration(labelText: t.orderNote, hintText: t.reservationNoteHint, counterText: ''),
              ),
              const SizedBox(height: 16),
              Text(t.chooseTables, style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              if (_dayList == null)
                const LinearProgressIndicator()
              else
                ReservationTablePicker(
                  hub: widget.hub,
                  start: _start,
                  end: _start.add(Duration(minutes: _minutes)),
                  partySize: _party,
                  reservations: _dayList!,
                  selected: _tables,
                  onChanged: () => setState(() {}),
                ),
              if (_tried && _tables.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(t.errorTablesRequired, style: TextStyle(color: theme.colorScheme.error)),
                ),
            ]),
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(t.cancel)),
        FilledButton(onPressed: _busy ? null : _save, child: Text(t.save)),
      ],
    );
  }
}
