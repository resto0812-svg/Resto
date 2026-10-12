import 'dart:math';

import 'package:flutter/material.dart';

import '../../app_state.dart';
import '../../core/errors.dart';
import '../../data/customer_api.dart';
import '../../ui/common.dart';
import '../../ui/kit.dart';
import '../../ui/theme.dart';
import '../service/service_labels.dart' show dayLabel, hm;
import 'reservation_sheet.dart';

/// Onglet « Tables » de la page d'un restaurant : le client voit les tables
/// libres, occupées (avec l'heure estimée de libération) ou réservées, à
/// l'instant ou au moment qu'il choisit, et réserve en touchant ses tables.
class TablesTab extends StatefulWidget {
  const TablesTab({super.key, required this.branchId, required this.restaurantName});
  final String branchId;
  final String restaurantName;

  @override
  State<TablesTab> createState() => _TablesTabState();
}

class _TablesTabState extends State<TablesTab> {
  /// null = maintenant.
  DateTime? _at;
  int _party = 2;
  final Set<String> _selected = {};
  late Future<TablesStatus> _status = _load();

  Future<TablesStatus> _load() => AppScope.read(context).api!.customer.tableStatus(widget.branchId, at: _at);

  void _reload() => setState(() {
        _selected.clear();
        _status = _load();
      });

  /// Prochain créneau réservable (au moins 20 minutes à l'avance, à la demi-heure).
  static DateTime _nextSlot() {
    final n = DateTime.now().add(const Duration(minutes: 20));
    return DateTime(n.year, n.month, n.day, n.hour, n.minute <= 30 ? 30 : 0).add(Duration(hours: n.minute <= 30 ? 0 : 1));
  }

  Future<void> _pickMoment() async {
    final base = _at ?? _nextSlot();
    final d = await showDatePicker(
      context: context,
      initialDate: base,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (d == null || !mounted) return;
    final time = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(base));
    if (time == null) return;
    _at = DateTime(d.year, d.month, d.day, time.hour, time.minute);
    _reload();
  }

  Future<void> _reserve(TablesStatus s, List<PublicTable> chosen) async {
    final ok = await requestTableReservation(
      context,
      branchId: widget.branchId,
      restaurantName: widget.restaurantName,
      start: _at != null && _at!.isAfter(DateTime.now().add(const Duration(minutes: 15))) ? _at : _nextSlot(),
      party: _party,
      tables: [for (final tb in chosen) (tb.id, tb.label)],
    );
    if (ok && mounted) _reload();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: FutureBuilder<TablesStatus>(
        future: _status,
        builder: (context, snap) {
          if (snap.hasError) {
            return Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Text(errorText(t, snap.error!), textAlign: TextAlign.center, style: const TextStyle(color: RestoColors.muted)),
                TextButton(onPressed: _reload, child: Text(t.retry)),
              ]),
            );
          }
          if (!snap.hasData) {
            return const Padding(padding: EdgeInsets.all(40), child: Center(child: CircularProgressIndicator()));
          }
          final s = snap.data!;
          if (s.isEmpty) return EmptyState(icon: Icons.table_restaurant_outlined, title: t.tablesEmpty);
          final all = [for (final a in s.areas) ...a.$2];
          final chosen = all.where((tb) => _selected.contains(tb.id)).toList();
          final seats = chosen.fold<int>(0, (a, tb) => a + tb.seats);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Moment et groupe.
              Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  GoldPill(
                    label: t.tablesNow,
                    icon: Icons.bolt_rounded,
                    selected: _at == null,
                    onTap: () {
                      _at = null;
                      _reload();
                    },
                  ),
                  GoldPill(
                    label: _at == null ? t.tablesLater : '${dayLabel(context, _at!)} · ${hm(context, _at!)}',
                    icon: Icons.event_rounded,
                    selected: _at != null,
                    onTap: _pickMoment,
                  ),
                  SoftCard(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        onPressed: _party > 1 ? () => setState(() => _party--) : null,
                        icon: const Icon(Icons.remove_rounded, size: 18),
                      ),
                      const Icon(Icons.groups_2_outlined, size: 18, color: RestoColors.primaryDeep),
                      const SizedBox(width: 4),
                      Text('$_party', style: const TextStyle(fontWeight: FontWeight.w800)),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        onPressed: _party < s.maxPartySize ? () => setState(() => _party++) : null,
                        icon: const Icon(Icons.add_rounded, size: 18),
                      ),
                    ]),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Légende.
              Wrap(spacing: 14, runSpacing: 6, children: [
                _Legend(color: StatusColors.free, label: t.tableFree),
                _Legend(color: StatusColors.occupied, label: t.tableLegendOccupied),
                _Legend(color: StatusColors.reserved, label: t.tableLegendReserved),
                if (s.acceptsReservations) _Legend(color: RestoColors.primary, label: t.tableLegendChosen),
              ]),
              const SizedBox(height: 14),
              for (final (name, tables) in s.areas)
                if (tables.isNotEmpty) ...[
                  Text(name, style: serifTitle(context, size: 20)),
                  const SizedBox(height: 8),
                  _AreaView(
                    tables: tables,
                    selected: _selected,
                    party: _party,
                    canPick: s.acceptsReservations,
                    onTap: (tb) => setState(() => _selected.contains(tb.id) ? _selected.remove(tb.id) : _selected.add(tb.id)),
                  ),
                  const SizedBox(height: 18),
                ],
              if (s.acceptsReservations) ...[
                Text(
                  chosen.isEmpty ? t.tablesSelectHint : t.tablesSeatsChosen(seats, _party),
                  style: TextStyle(
                    color: chosen.isNotEmpty && seats < _party ? const Color(0xFFC0392B) : RestoColors.muted,
                    fontWeight: chosen.isEmpty ? FontWeight.w400 : FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                GoldButton(
                  label: chosen.isEmpty ? t.reserveTable : t.reserveTablesAction(chosen.map((tb) => tb.label).join(', ')),
                  icon: Icons.event_available_rounded,
                  onPressed: chosen.isEmpty || seats < _party ? null : () => _reserve(s, chosen),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4))),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12.5, color: RestoColors.muted)),
      ]);
}

/// Une zone : plan de salle si les tables sont placées, sinon une grille.
class _AreaView extends StatelessWidget {
  const _AreaView({required this.tables, required this.selected, required this.party, required this.canPick, required this.onTap});
  final List<PublicTable> tables;
  final Set<String> selected;
  final int party;
  final bool canPick;
  final ValueChanged<PublicTable> onTap;

  @override
  Widget build(BuildContext context) {
    final placed = tables.where((tb) => tb.posX != null && tb.posY != null).toList();
    if (placed.length < tables.length || placed.isEmpty) {
      return LayoutBuilder(builder: (context, box) {
        final cols = max(2, (box.maxWidth / 150).floor());
        final w = (box.maxWidth - (cols - 1) * 10) / cols;
        return Wrap(spacing: 10, runSpacing: 10, children: [
          for (final tb in tables) SizedBox(width: w, height: 104, child: _tile(context, tb)),
        ]);
      });
    }
    // Plan : grille de 60 × 60 cases, recadrée sur les tables placées.
    final minX = placed.map((tb) => tb.posX!).reduce(min);
    final minY = placed.map((tb) => tb.posY!).reduce(min);
    final maxX = placed.map((tb) => tb.posX!).reduce(max) + 4;
    final maxY = placed.map((tb) => tb.posY!).reduce(max) + 4;
    return LayoutBuilder(builder: (context, box) {
      final cell = box.maxWidth / max(1, maxX - minX);
      final size = (cell * 4).clamp(64.0, 120.0);
      return Container(
        height: (maxY - minY) * cell + 8,
        decoration: BoxDecoration(color: RestoColors.band.withValues(alpha: 0.45), borderRadius: BorderRadius.circular(18)),
        child: Stack(children: [
          for (final tb in placed)
            Positioned(
              left: ((tb.posX! - minX) * cell).clamp(0, box.maxWidth - size),
              top: (tb.posY! - minY) * cell + 4,
              width: tb.shape == 'rect' ? min(size * 1.5, box.maxWidth) : size,
              height: size,
              child: _tile(context, tb, round: tb.shape == 'round'),
            ),
        ]),
      );
    });
  }

  Widget _tile(BuildContext context, PublicTable tb, {bool round = false}) {
    final t = context.t;
    final chosen = selected.contains(tb.id);
    final color = chosen
        ? RestoColors.primary
        : switch (tb.status) {
            'occupied' => StatusColors.occupied,
            'reserved' => StatusColors.reserved,
            _ => StatusColors.free,
          };
    final detail = switch (tb.status) {
      'occupied' => tb.freeAt == null ? t.tableLegendOccupied : t.tableOccupiedUntil(hm(context, tb.freeAt!)),
      'reserved' => tb.reservedFrom == null
          ? t.tableLegendReserved
          : t.tableReservedSlot(hm(context, tb.reservedFrom!), hm(context, tb.reservedUntil ?? tb.reservedFrom!)),
      _ => tb.nextReservedAt == null ? t.tableFree : t.tableFreeUntil(hm(context, tb.nextReservedAt!)),
    };
    final pickable = canPick && tb.isFree;
    return Tooltip(
      message: '${tb.label} · ${t.seatsCount(tb.seats)} · $detail',
      child: Material(
        color: color.withValues(alpha: chosen ? 1 : 0.12),
        shape: round
            ? CircleBorder(side: BorderSide(color: color, width: 2))
            : RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: color, width: 2)),
        child: InkWell(
          customBorder: round ? const CircleBorder() : RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          onTap: pickable ? () => onTap(tb) : null,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Text(tb.label,
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: chosen ? Colors.white : RestoColors.ink)),
                Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.event_seat_outlined, size: 13, color: chosen ? Colors.white : RestoColors.muted),
                  const SizedBox(width: 3),
                  Text('${tb.seats}', style: TextStyle(fontSize: 12, color: chosen ? Colors.white : RestoColors.muted)),
                  if (tb.seats < party && tb.isFree) ...[
                    const SizedBox(width: 4),
                    Icon(Icons.info_outline_rounded, size: 12, color: chosen ? Colors.white : RestoColors.muted),
                  ],
                ]),
                const SizedBox(height: 3),
                Text(detail,
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: chosen ? Colors.white : color)),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
