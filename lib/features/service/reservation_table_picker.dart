import 'package:flutter/material.dart';

import '../../data/models.dart';
import '../../data/order_models.dart';
import '../../data/reservations_api.dart';
import '../../ui/common.dart';
import '../../ui/theme.dart';
import 'service_hub.dart';
import 'service_labels.dart';

/// Disponibilité d'une table sur un créneau.
enum SlotState { free, freeSoon, reserved, occupied }

class SlotInfo {
  SlotInfo(this.table, this.state, {this.conflict, this.freeAt});
  final DiningTable table;
  final SlotState state;

  /// Réservation qui chevauche le créneau.
  final Reservation? conflict;

  /// Heure estimée de libération (table occupée par une commande en cours).
  final DateTime? freeAt;

  bool get selectable => state == SlotState.free || state == SlotState.freeSoon;
}

/// Disponibilité de chaque table active sur [start, end[ :
/// réservée (une réservation confirmée ou installée chevauche le créneau),
/// occupée (commande en cours dont la fin estimée dépasse le début du
/// créneau), libre bientôt (occupée mais libérée avant le début), libre.
/// La durée d'un repas sert d'estimation : début de la commande + [mealMinutes].
Map<String, SlotInfo> slotAvailability({
  required List<ServiceArea> areas,
  required List<Order> orders,
  required List<Reservation> reservations,
  required DateTime start,
  required DateTime end,
  required int mealMinutes,
  String? excludeReservationId,
}) {
  final byTable = {for (final o in orders.where((o) => o.isOpen && o.tableId != null)) o.tableId!: o};
  final result = <String, SlotInfo>{};
  for (final a in areas.where((a) => a.active)) {
    for (final tb in a.tables.where((x) => x.active)) {
      final conflict = reservations
          .where((r) =>
              r.id != excludeReservationId &&
              (r.status == 'confirmed' || r.status == 'seated') &&
              r.tableIds.contains(tb.id) &&
              r.startsAt.isBefore(end) &&
              r.endsAt.isAfter(start))
          .firstOrNull;
      final order = byTable[tb.id];
      final freeAt = order?.openedAt.toLocal().add(Duration(minutes: mealMinutes));
      final state = conflict != null
          ? SlotState.reserved
          : order == null || !start.isBefore(DateTime.now().add(const Duration(hours: 12)))
              ? SlotState.free
              : freeAt!.isAfter(start)
                  ? SlotState.occupied
                  : SlotState.freeSoon;
      result[tb.id] = SlotInfo(tb, state, conflict: conflict, freeAt: order == null ? null : freeAt);
    }
  }
  return result;
}

Color slotColor(SlotState s) => switch (s) {
      SlotState.free => StatusColors.free,
      SlotState.freeSoon => StatusColors.cooking,
      SlotState.reserved => StatusColors.reserved,
      SlotState.occupied => StatusColors.occupied,
    };

/// Toutes les tables, zone par zone, avec leur disponibilité sur le créneau ;
/// une table libre adaptée au nombre de personnes est suggérée.
class ReservationTablePicker extends StatelessWidget {
  const ReservationTablePicker({
    super.key,
    required this.hub,
    required this.start,
    required this.end,
    required this.partySize,
    required this.reservations,
    required this.selected,
    required this.onChanged,
    this.excludeReservationId,
  });

  final ServiceHub hub;
  final DateTime start;
  final DateTime end;
  final int partySize;
  final List<Reservation> reservations;
  final Set<String> selected;
  final VoidCallback onChanged;
  final String? excludeReservationId;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    final infos = slotAvailability(
      areas: hub.areas,
      orders: hub.orders,
      reservations: reservations,
      start: start,
      end: end,
      mealMinutes: hub.scope.branch.reservationMinutes,
      excludeReservationId: excludeReservationId,
    );
    if (infos.isEmpty) return Text(t.floorEmptyHint, style: theme.textTheme.bodySmall);
    final seats = infos.values.where((i) => selected.contains(i.table.id)).fold<int>(0, (a, i) => a + i.table.seats);
    final candidates = infos.values.where((i) => i.selectable && i.table.seats >= partySize).toList()
      ..sort((a, b) => a.table.seats != b.table.seats ? a.table.seats - b.table.seats : a.state.index - b.state.index);
    final suggestion = candidates.firstOrNull;
    final freeCount = infos.values.where((i) => i.selectable).length;

    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Wrap(spacing: 8, runSpacing: 8, crossAxisAlignment: WrapCrossAlignment.center, children: [
        StatusPill(
          label: t.seatsForParty(seats, partySize),
          color: seats >= partySize ? StatusColors.free : StatusColors.late,
          icon: Icons.event_seat_rounded,
        ),
        StatusPill(label: t.freeTablesCount(freeCount, infos.length), color: StatusColors.free, dense: true),
        if (suggestion != null && !selected.contains(suggestion.table.id))
          ActionChip(
            avatar: const Icon(Icons.auto_awesome_rounded, size: 16, color: RestoColors.primary),
            label: Text(t.suggestedTable(suggestion.table.label, suggestion.table.seats)),
            onPressed: () {
              selected
                ..clear()
                ..add(suggestion.table.id);
              onChanged();
            },
          ),
      ]),
      const SizedBox(height: 10),
      Wrap(spacing: 10, runSpacing: 6, children: [
        for (final s in SlotState.values) StatusPill(label: _stateLabel(context, s), color: slotColor(s), dense: true),
      ]),
      for (final a in hub.areas.where((a) => a.active && a.tables.any((x) => x.active))) ...[
        Padding(
          padding: const EdgeInsets.only(top: 14, bottom: 8),
          child: Text(a.name.toUpperCase(),
              style: theme.textTheme.labelSmall?.copyWith(letterSpacing: 1.4, color: theme.colorScheme.onSurfaceVariant)),
        ),
        Wrap(spacing: 10, runSpacing: 10, children: [
          for (final tb in a.tables.where((x) => x.active))
            _TableTile(
              info: infos[tb.id]!,
              selected: selected.contains(tb.id),
              suggested: suggestion?.table.id == tb.id,
              onTap: () {
                selected.contains(tb.id) ? selected.remove(tb.id) : selected.add(tb.id);
                onChanged();
              },
            ),
        ]),
      ],
    ]);
  }

  String _stateLabel(BuildContext context, SlotState s) {
    final t = context.t;
    return switch (s) {
      SlotState.free => t.tableFree,
      SlotState.freeSoon => t.slotFreeSoon,
      SlotState.reserved => t.slotReserved,
      SlotState.occupied => t.tableOccupied,
    };
  }
}

class _TableTile extends StatelessWidget {
  const _TableTile({required this.info, required this.selected, required this.suggested, required this.onTap});
  final SlotInfo info;
  final bool selected;
  final bool suggested;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final color = slotColor(info.state);
    final tb = info.table;
    final detail = switch (info.state) {
      SlotState.reserved =>
        '${hm(context, info.conflict!.startsAt)}–${hm(context, info.conflict!.endsAt)} · ${info.conflict!.customerName}',
      SlotState.occupied || SlotState.freeSoon => t.freeAround(hm(context, info.freeAt!)),
      SlotState.free => t.seatsCount(tb.seats),
    };
    // Une table réservée sur le créneau ne peut pas être choisie (refus du serveur) ;
    // une table occupée reste possible : l'estimation peut être prudente.
    final enabled = info.state != SlotState.reserved || selected;
    return Opacity(
      opacity: enabled ? 1 : 0.55,
      child: SizedBox(
        width: 148,
        height: 98,
        child: Material(
          color: selected
              ? RestoColors.primary.withValues(alpha: 0.16)
              : Color.alphaBlend(color.withValues(alpha: 0.07), scheme.surfaceContainerLowest),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: selected ? RestoColors.primary : color.withValues(alpha: 0.7), width: selected ? 2.4 : 1.2),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: enabled ? onTap : null,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Icon(
                    tb.shape == 'round'
                        ? Icons.circle_outlined
                        : tb.shape == 'rect'
                            ? Icons.crop_16_9_rounded
                            : Icons.crop_square_rounded,
                    size: 18,
                    color: color,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(tb.label, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.titleSmall),
                  ),
                  if (selected)
                    const Icon(Icons.check_circle_rounded, size: 20, color: RestoColors.primary)
                  else if (suggested)
                    const Icon(Icons.auto_awesome_rounded, size: 16, color: RestoColors.primary),
                ]),
                Text(t.seatsCount(tb.seats), style: theme.textTheme.bodySmall),
                const Spacer(),
                Text(detail,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall?.copyWith(color: color, fontWeight: FontWeight.w700)),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
