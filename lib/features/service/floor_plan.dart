import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../data/models.dart';
import '../../data/order_models.dart';
import '../../data/reservations_api.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/common.dart';
import '../../ui/theme.dart';
import 'service_labels.dart';

/// État d'une table à un instant donné.
enum TableKind { free, occupied, ready, toPay, reserved, reservedSoon }

class TableInfo {
  TableInfo(this.table, this.kind, {this.order, this.current, this.next});
  final DiningTable table;
  final TableKind kind;

  /// Commande en cours sur la table.
  final Order? order;

  /// Réservation en cours (clients attendus ou installés).
  final Reservation? current;

  /// Prochaine réservation du jour.
  final Reservation? next;
}

/// Une réservation est « bientôt » si elle commence dans moins de 90 minutes.
const soonMinutes = 90;

Map<String, TableInfo> tableInfos(List<ServiceArea> areas, List<Order> orders, List<Reservation> reservations,
    [DateTime? at]) {
  final now = at ?? DateTime.now();
  final byTable = {for (final o in orders.where((o) => o.isOpen && o.tableId != null)) o.tableId!: o};
  final result = <String, TableInfo>{};
  for (final a in areas) {
    for (final tb in a.tables) {
      final mine = reservations.where((r) => r.tableIds.contains(tb.id)).toList()
        ..sort((x, y) => x.startsAt.compareTo(y.startsAt));
      final current = mine
          .where((r) => (r.status == 'confirmed' || r.status == 'seated') && !r.startsAt.isAfter(now) && r.endsAt.isAfter(now))
          .firstOrNull;
      final next = mine.where((r) => r.status == 'confirmed' && r.startsAt.isAfter(now)).firstOrNull;
      final order = byTable[tb.id];
      final kind = order != null
          ? switch (order.stage) {
              OrderStage.ready => TableKind.ready,
              OrderStage.toPay => TableKind.toPay,
              _ => TableKind.occupied,
            }
          : current != null
              ? TableKind.reserved
              : (next != null && next.startsAt.difference(now).inMinutes <= soonMinutes)
                  ? TableKind.reservedSoon
                  : TableKind.free;
      result[tb.id] = TableInfo(tb, kind, order: order, current: current, next: next);
    }
  }
  return result;
}

Color tableColor(TableKind k) => switch (k) {
      TableKind.free => StatusColors.free,
      TableKind.occupied => StatusColors.occupied,
      TableKind.ready => StatusColors.ready,
      TableKind.toPay => StatusColors.toPay,
      TableKind.reserved || TableKind.reservedSoon => StatusColors.reserved,
    };

String tableKindLabel(AppLocalizations t, TableKind k) => switch (k) {
      TableKind.free => t.tableFree,
      TableKind.occupied => t.tableOccupied,
      TableKind.ready => t.stageReady,
      TableKind.toPay => t.stageToPay,
      TableKind.reserved => t.tableReservedNow,
      TableKind.reservedSoon => t.tableReservedSoon,
    };

/// Ligne d'état sous le nom de la table : durée, montant, heure de réservation.
String tableStatusLine(BuildContext context, TableInfo info, String Function(int) money) {
  final t = context.t;
  final o = info.order;
  if (o != null) {
    final mins = DateTime.now().difference(o.openedAt).inMinutes;
    return '${durationText(mins)} · ${money(o.totalMinor)}';
  }
  final r = info.current ?? info.next;
  if (r != null && info.kind != TableKind.free) return '${hm(context, r.startsAt)} · ${r.customerName}';
  if (info.next != null) return t.reservedAt(hm(context, info.next!.startsAt));
  return t.seatsCount(info.table.seats);
}

/// Légende des couleurs de la salle.
class FloorLegend extends StatelessWidget {
  const FloorLegend({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return Wrap(spacing: 8, runSpacing: 6, children: [
      for (final k in [TableKind.free, TableKind.occupied, TableKind.ready, TableKind.toPay, TableKind.reserved])
        StatusPill(label: tableKindLabel(t, k), color: tableColor(k), dense: true),
    ]);
  }
}

/// Taille d'une table sur la grille (en cases), selon sa forme et ses places.
(int, int) tableCells(DiningTable tb) {
  final n = tb.seats;
  if (tb.shape == 'rect') return (math.max(6, math.min(14, (n / 2).ceil() * 2 + 2)), 4);
  final s = n <= 2 ? 3 : n <= 4 ? 4 : n <= 6 ? 5 : 6;
  return (s, s);
}

/// Grille du plan : 40 colonnes, la taille d'une case suit la largeur.
const planColumns = 40;

/// Positions effectives : celles enregistrées, sinon placement automatique en lignes.
Map<String, (int, int)> layoutTables(List<DiningTable> tables) {
  final pos = <String, (int, int)>{};
  var x = 1, y = 1, rowH = 0;
  for (final tb in tables) {
    if (tb.posX != null && tb.posY != null) {
      pos[tb.id] = (tb.posX!, tb.posY!);
    }
  }
  final placedBottom = pos.isEmpty
      ? 0
      : tables.where((tb) => pos.containsKey(tb.id)).map((tb) => pos[tb.id]!.$2 + tableCells(tb).$2).reduce(math.max);
  y = placedBottom == 0 ? 1 : placedBottom + 2;
  for (final tb in tables) {
    if (pos.containsKey(tb.id)) continue;
    final (w, h) = tableCells(tb);
    if (x + w > planColumns - 1) {
      x = 1;
      y += rowH + 2;
      rowH = 0;
    }
    pos[tb.id] = (x, y);
    x += w + 2;
    rowH = math.max(rowH, h);
  }
  return pos;
}

/// Plan d'une zone. En mode édition, les tables se déplacent au doigt.
class FloorPlanCanvas extends StatefulWidget {
  const FloorPlanCanvas({
    super.key,
    required this.tables,
    required this.infos,
    required this.money,
    required this.onTap,
    this.editing = false,
    this.onMoved,
  });

  final List<DiningTable> tables;
  final Map<String, TableInfo> infos;
  final String Function(int) money;
  final void Function(DiningTable) onTap;
  final bool editing;
  final void Function(DiningTable table, int x, int y)? onMoved;

  @override
  State<FloorPlanCanvas> createState() => _FloorPlanCanvasState();
}

class _FloorPlanCanvasState extends State<FloorPlanCanvas> {
  final Map<String, Offset> _drag = {};
  final Map<String, (int, int)> _moved = {};

  @override
  void didUpdateWidget(covariant FloorPlanCanvas old) {
    super.didUpdateWidget(old);
    _moved.removeWhere((id, p) {
      final tb = widget.tables.where((x) => x.id == id).firstOrNull;
      return tb == null || (tb.posX == p.$1 && tb.posY == p.$2);
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tables = widget.tables.where((tb) => tb.active || widget.editing).toList();
    final layout = {...layoutTables(tables), ..._moved};
    return LayoutBuilder(builder: (context, c) {
      final cell = c.maxWidth / planColumns;
      var rows = 10;
      for (final tb in tables) {
        rows = math.max(rows, layout[tb.id]!.$2 + tableCells(tb).$2 + 1);
      }
      return Container(
        height: rows * cell,
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: widget.editing ? scheme.primary : scheme.outlineVariant, width: widget.editing ? 1.5 : 1),
        ),
        child: Stack(clipBehavior: Clip.none, children: [
          if (widget.editing) Positioned.fill(child: CustomPaint(painter: _GridPainter(cell, scheme.outlineVariant))),
          for (final tb in tables) _positioned(context, tb, layout[tb.id]!, cell),
        ]),
      );
    });
  }

  Widget _positioned(BuildContext context, DiningTable tb, (int, int) p, double cell) {
    final (w, h) = tableCells(tb);
    final drag = _drag[tb.id] ?? Offset.zero;
    final info = widget.infos[tb.id];
    final tile = TableShape(
      table: tb,
      info: info,
      width: w * cell,
      height: h * cell,
      statusLine: info == null ? '' : tableStatusLine(context, info, widget.money),
      dimmed: !tb.active,
    );
    return Positioned(
      left: p.$1 * cell + drag.dx,
      top: p.$2 * cell + drag.dy,
      child: widget.editing
          ? GestureDetector(
              onTap: () => widget.onTap(tb),
              onPanUpdate: (d) => setState(() => _drag[tb.id] = (_drag[tb.id] ?? Offset.zero) + d.delta),
              onPanEnd: (_) {
                final off = _drag.remove(tb.id) ?? Offset.zero;
                final nx = (p.$1 + (off.dx / cell).round()).clamp(0, planColumns - w);
                final ny = math.max(0, p.$2 + (off.dy / cell).round()).clamp(0, 59);
                setState(() => _moved[tb.id] = (nx, ny));
                widget.onMoved?.call(tb, nx, ny);
              },
              child: MouseRegion(cursor: SystemMouseCursors.move, child: tile),
            )
          : GestureDetector(onTap: () => widget.onTap(tb), child: MouseRegion(cursor: SystemMouseCursors.click, child: tile)),
    );
  }
}

class _GridPainter extends CustomPainter {
  _GridPainter(this.cell, this.color);
  final double cell;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = color;
    for (var x = cell; x < size.width; x += cell) {
      for (var y = cell; y < size.height; y += cell) {
        canvas.drawCircle(Offset(x, y), 0.9, p);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _GridPainter old) => old.cell != cell || old.color != color;
}

/// Table dessinée : plateau coloré selon l'état, chaises autour.
class TableShape extends StatelessWidget {
  const TableShape({
    super.key,
    required this.table,
    required this.info,
    required this.width,
    required this.height,
    required this.statusLine,
    this.dimmed = false,
  });

  final DiningTable table;
  final TableInfo? info;
  final double width;
  final double height;
  final String statusLine;
  final bool dimmed;

  @override
  Widget build(BuildContext context) {
    final kind = info?.kind ?? TableKind.free;
    final color = tableColor(kind);
    final scheme = Theme.of(context).colorScheme;
    final chair = math.max(5.0, math.min(width, height) * 0.13);
    final round = table.shape == 'round';
    final big = math.min(width, height) > 70;
    return Opacity(
      opacity: dimmed ? 0.4 : 1,
      child: SizedBox(
        width: width,
        height: height,
        child: CustomPaint(
          painter: _ChairsPainter(table.seats, round, chair, color.withValues(alpha: 0.55)),
          child: Padding(
            padding: EdgeInsets.all(chair + 2),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Color.alphaBlend(color.withValues(alpha: kind == TableKind.free ? 0.10 : 0.20), scheme.surfaceContainerLowest),
                shape: round ? BoxShape.circle : BoxShape.rectangle,
                borderRadius: round ? null : BorderRadius.circular(10),
                border: Border.all(color: color, width: kind == TableKind.free ? 1.4 : 2.2),
                boxShadow: [BoxShadow(color: color.withValues(alpha: 0.18), blurRadius: 8, offset: const Offset(0, 2))],
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Text(table.label,
                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: big ? 15 : 12, color: scheme.onSurface)),
                      if (big && statusLine.isNotEmpty)
                        Text(statusLine, style: TextStyle(fontSize: 10.5, color: color, fontWeight: FontWeight.w700)),
                      if (info?.order?.awaitingAcceptance == true || (info?.order?.readyCount ?? 0) > 0)
                        Icon(info!.order!.awaitingAcceptance ? Icons.notifications_active_rounded : Icons.room_service_rounded,
                            size: 14, color: color),
                    ]),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ChairsPainter extends CustomPainter {
  _ChairsPainter(this.seats, this.round, this.chair, this.color);
  final int seats;
  final bool round;
  final double chair;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = color;
    final n = seats.clamp(1, 16);
    void chairAt(Offset c) =>
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: c, width: chair * 1.5, height: chair * 1.5), Radius.circular(chair * 0.5)), p);
    if (round) {
      final center = size.center(Offset.zero);
      final r = math.min(size.width, size.height) / 2 - chair * 0.8;
      for (var i = 0; i < n; i++) {
        final a = -math.pi / 2 + i * 2 * math.pi / n;
        chairAt(center + Offset(math.cos(a) * r, math.sin(a) * r));
      }
      return;
    }
    // Rectangle / carré : moitié en haut, moitié en bas ; une chaise en bout si impair.
    final top = n ~/ 2;
    final bottom = n - top - (n.isOdd && n > 2 ? 1 : 0);
    final inner = size.width - chair * 4;
    for (var i = 0; i < top; i++) {
      chairAt(Offset(chair * 2 + inner * (i + 0.5) / top, chair * 0.8));
    }
    for (var i = 0; i < bottom; i++) {
      chairAt(Offset(chair * 2 + inner * (i + 0.5) / bottom, size.height - chair * 0.8));
    }
    if (n.isOdd && n > 2) chairAt(Offset(size.width - chair * 0.8, size.height / 2));
  }

  @override
  bool shouldRepaint(covariant _ChairsPainter old) =>
      old.seats != seats || old.round != round || old.chair != chair || old.color != color;
}

/// Vue en cartes (téléphone, ou au choix) : une carte par table.
class FloorCards extends StatelessWidget {
  const FloorCards({super.key, required this.tables, required this.infos, required this.money, required this.onTap});
  final List<DiningTable> tables;
  final Map<String, TableInfo> infos;
  final String Function(int) money;
  final void Function(DiningTable) onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final scheme = Theme.of(context).colorScheme;
    return Wrap(spacing: 10, runSpacing: 10, children: [
      for (final tb in tables.where((x) => x.active))
        Builder(builder: (context) {
          final info = infos[tb.id]!;
          final color = tableColor(info.kind);
          return SizedBox(
            width: 158,
            height: 112,
            child: Material(
              color: Color.alphaBlend(color.withValues(alpha: info.kind == TableKind.free ? 0.05 : 0.12), scheme.surfaceContainerLowest),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: color, width: 1.4)),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => onTap(tb),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Expanded(
                        child: Text(tb.label,
                            maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.titleMedium),
                      ),
                      Icon(tb.shape == 'round' ? Icons.circle_outlined : Icons.crop_square_rounded, size: 16, color: color),
                    ]),
                    const Spacer(),
                    StatusPill(label: tableKindLabel(t, info.kind), color: color, dense: true),
                    const SizedBox(height: 4),
                    Text(tableStatusLine(context, info, money),
                        maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodySmall),
                  ]),
                ),
              ),
            ),
          );
        }),
    ]);
  }
}
