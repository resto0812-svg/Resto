import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/dashboard_api.dart';
import '../../data/stock_api.dart';
import '../../ui/common.dart';
import '../../ui/kit.dart';
import '../../ui/theme.dart';

/// Montant formaté dans la monnaie de l'établissement.
typedef MoneyText = String Function(int minor);

Widget _empty(BuildContext context) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Text(context.t.noSalesYet, style: const TextStyle(color: RestoColors.muted)),
    );

/// Petite tuile chiffrée (couverts, panier par couvert, temps…).
class StatTile extends StatelessWidget {
  const StatTile({super.key, required this.icon, required this.label, required this.value, this.sub});
  final IconData icon;
  final String label;
  final String value;
  final String? sub;

  @override
  Widget build(BuildContext context) => SoftCard(
        padding: const EdgeInsets.all(14),
        child: Row(children: [
          GoldIcon(icon, size: 40),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: RestoColors.muted, fontSize: 12.5)),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: AlignmentDirectional.centerStart,
                child: Text(value, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 20, color: RestoColors.ink)),
              ),
              if (sub != null)
                Text(sub!, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: RestoColors.muted, fontSize: 11.5)),
            ]),
          ),
        ]),
      );
}

/// Barres horizontales dorées (libellé, valeur, texte à droite).
class _Bars extends StatelessWidget {
  const _Bars({required this.rows});
  final List<(String, int, String)> rows;

  @override
  Widget build(BuildContext context) {
    final maxV = rows.fold<int>(1, (a, r) => max(a, r.$2));
    return Column(children: [
      for (final r in rows)
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(children: [
            SizedBox(
              width: 118,
              child: Text(r.$1, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600)),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: LayoutBuilder(
                builder: (context, box) => Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Container(
                    height: 14,
                    width: max(6, box.maxWidth * r.$2 / maxV),
                    decoration: BoxDecoration(gradient: RestoColors.brandGradient, borderRadius: BorderRadius.circular(5)),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(r.$3, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5)),
          ]),
        ),
    ]);
  }
}

/// Encaissements par moyen de paiement (montant, nombre, pourboires).
class PaymentsByMethodCard extends StatelessWidget {
  const PaymentsByMethodCard({super.key, required this.insights, required this.money});
  final Insights insights;
  final MoneyText money;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return SoftCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        SectionHeading(title: t.paymentsByMethod, icon: Icons.payments_outlined),
        const SizedBox(height: 14),
        if (insights.payments.isEmpty)
          _empty(context)
        else
          _Bars(rows: [for (final p in insights.payments) (p.$1, p.$3, money(p.$3))]),
      ]),
    );
  }
}

/// Affluence : commandes par jour de la semaine et par heure (carte de chaleur).
class HeatmapCard extends StatelessWidget {
  const HeatmapCard({super.key, required this.insights});
  final Insights insights;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final locale = Localizations.localeOf(context).toString();
    final h = insights.heatmap;
    final hours = h.keys.map((k) => k.$2).toList();
    final first = hours.isEmpty ? 8 : hours.reduce(min);
    final last = hours.isEmpty ? 22 : hours.reduce(max);
    final maxV = h.values.fold<int>(1, max);
    // 2026-10-12 est un lundi : sert à nommer les jours dans la langue choisie.
    String day(int dow) => DateFormat.E(locale).format(DateTime(2026, 10, 11 + dow));
    return SoftCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        SectionHeading(title: t.busyHours, icon: Icons.grid_on_rounded),
        const SizedBox(height: 12),
        if (h.isEmpty)
          _empty(context)
        else
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const SizedBox(width: 42),
                for (var hr = first; hr <= last; hr++)
                  SizedBox(
                    width: 26,
                    child: Text('$hr', textAlign: TextAlign.center, style: const TextStyle(fontSize: 10.5, color: RestoColors.muted)),
                  ),
              ]),
              for (var dow = 1; dow <= 7; dow++)
                Row(children: [
                  SizedBox(width: 42, child: Text(day(dow), style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600))),
                  for (var hr = first; hr <= last; hr++)
                    Tooltip(
                      message: '${day(dow)} $hr h · ${t.ordersCountShort(h[(dow, hr)] ?? 0)}',
                      child: Container(
                        width: 24,
                        height: 22,
                        margin: const EdgeInsets.all(1),
                        decoration: BoxDecoration(
                          color: (h[(dow, hr)] ?? 0) == 0
                              ? RestoColors.band.withValues(alpha: 0.5)
                              : RestoColors.primary.withValues(alpha: 0.18 + 0.82 * (h[(dow, hr)]! / maxV)),
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ),
                ]),
            ]),
          ),
      ]),
    );
  }
}

/// Ingénierie de menu : popularité × marge (méthode des quatre familles).
/// Popularité : au moins 70 % de la vente moyenne par plat. Rentabilité :
/// marge unitaire au moins égale à la marge moyenne pondérée.
class MenuEngineeringCard extends StatelessWidget {
  const MenuEngineeringCard({super.key, required this.items, required this.costs, required this.money});
  final List<SoldItem> items;
  final List<RecipeCost> costs;
  final MoneyText money;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    // Coût unitaire moyen par plat (variantes ayant une fiche technique).
    final byName = <String, List<int>>{};
    for (final c in costs.where((c) => c.hasRecipe && c.costMinor != null)) {
      byName.putIfAbsent(c.itemName, () => []).add(c.costMinor!);
    }
    final rows = <(SoldItem, int)>[];
    var noRecipe = 0;
    for (final it in items.where((i) => i.quantity > 0)) {
      final list = byName[it.name];
      if (list == null) {
        noRecipe++;
        continue;
      }
      final unitCost = list.reduce((a, b) => a + b) ~/ list.length;
      rows.add((it, it.total ~/ it.quantity - unitCost));
    }
    final groups = <String, List<(SoldItem, int)>>{'stars': [], 'plowhorses': [], 'puzzles': [], 'dogs': []};
    if (rows.isNotEmpty) {
      final totalQty = rows.fold<int>(0, (a, r) => a + r.$1.quantity);
      final popularity = 0.7 * totalQty / rows.length;
      final avgMargin = rows.fold<int>(0, (a, r) => a + r.$2 * r.$1.quantity) / max(1, totalQty);
      for (final r in rows) {
        final pop = r.$1.quantity >= popularity;
        final profit = r.$2 >= avgMargin;
        groups[pop ? (profit ? 'stars' : 'plowhorses') : (profit ? 'puzzles' : 'dogs')]!.add(r);
      }
    }
    Widget quadrant(String key, IconData icon, String title, String hint, Color color) {
      final list = groups[key]!..sort((a, b) => b.$1.quantity.compareTo(a.$1.quantity));
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.35)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 6),
            Expanded(child: Text('$title · ${list.length}', style: TextStyle(fontWeight: FontWeight.w800, color: color))),
          ]),
          Text(hint, style: const TextStyle(color: RestoColors.muted, fontSize: 11.5)),
          const SizedBox(height: 6),
          for (final r in list.take(5))
            Text('• ${r.$1.name} — ${r.$1.quantity} · ${money(r.$2)}',
                maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12.5)),
        ]),
      );
    }

    return SoftCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        SectionHeading(title: t.menuEngineering, icon: Icons.auto_graph_rounded, subtitle: t.menuEngineeringHint),
        const SizedBox(height: 12),
        if (rows.isEmpty)
          _empty(context)
        else
          LayoutBuilder(builder: (context, box) {
            final w = box.maxWidth >= 640 ? (box.maxWidth - 10) / 2 : box.maxWidth;
            return Wrap(spacing: 10, runSpacing: 10, children: [
              SizedBox(width: w, child: quadrant('stars', Icons.star_rounded, t.engStars, t.engStarsHint, const Color(0xFF2E9E5B))),
              SizedBox(width: w, child: quadrant('plowhorses', Icons.trending_flat_rounded, t.engPlowhorses, t.engPlowhorsesHint, const Color(0xFFB7791F))),
              SizedBox(width: w, child: quadrant('puzzles', Icons.campaign_outlined, t.engPuzzles, t.engPuzzlesHint, const Color(0xFF2F6FB0))),
              SizedBox(width: w, child: quadrant('dogs', Icons.report_gmailerrorred_rounded, t.engDogs, t.engDogsHint, const Color(0xFFC0392B))),
            ]);
          }),
        if (noRecipe > 0) ...[
          const SizedBox(height: 8),
          Text(t.engNoRecipe(noRecipe), style: const TextStyle(color: RestoColors.muted, fontSize: 12)),
        ],
      ]),
    );
  }
}

/// Plats les plus vendus et ceux qui se vendent le moins.
class SoldItemsCard extends StatelessWidget {
  const SoldItemsCard({super.key, required this.items, required this.money, this.slow = false});
  final List<SoldItem> items;
  final MoneyText money;
  final bool slow;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final list = slow ? (items.toList()..sort((a, b) => a.quantity.compareTo(b.quantity))).take(8).toList() : items.take(10).toList();
    return SoftCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        SectionHeading(title: slow ? t.slowSellers : t.topDishes, icon: slow ? Icons.trending_down_rounded : Icons.bar_chart_rounded),
        const SizedBox(height: 14),
        if (list.isEmpty) _empty(context) else _Bars(rows: [for (final i in list) (i.name, i.quantity, '${i.quantity} · ${money(i.total)}')]),
      ]),
    );
  }
}

/// Équipe : commandes, ventes et pourboires par membre.
class StaffCard extends StatelessWidget {
  const StaffCard({super.key, required this.insights, required this.money});
  final Insights insights;
  final MoneyText money;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return SoftCard(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 10),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        SectionHeading(title: t.teamPerformance, icon: Icons.groups_2_outlined),
        const SizedBox(height: 8),
        if (insights.staff.isEmpty)
          _empty(context)
        else
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowHeight: 40,
              headingRowColor: WidgetStatePropertyAll(RestoColors.band.withValues(alpha: 0.6)),
              headingTextStyle: const TextStyle(color: RestoColors.muted, fontWeight: FontWeight.w600, fontSize: 12.5),
              columns: [
                DataColumn(label: Text(t.memberLabel)),
                DataColumn(label: Text(t.staffOrders), numeric: true),
                DataColumn(label: Text(t.staffSales), numeric: true),
                DataColumn(label: Text(t.staffTips), numeric: true),
              ],
              rows: [
                for (final s in insights.staff)
                  DataRow(cells: [
                    DataCell(Text(s.$1, style: const TextStyle(fontWeight: FontWeight.w600))),
                    DataCell(Text('${s.$2}')),
                    DataCell(Text(money(s.$3), style: const TextStyle(fontWeight: FontWeight.w700))),
                    DataCell(Text(money(s.$4))),
                  ]),
              ],
            ),
          ),
      ]),
    );
  }
}

/// Temps moyens : préparation, mise sur table, durée à table.
class ServiceTimesCard extends StatelessWidget {
  const ServiceTimesCard({super.key, required this.insights, required this.targetPrep});
  final Insights insights;
  final int targetPrep;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    String v(double? m) => m == null ? '—' : t.minutesValue(m.round());
    return LayoutBuilder(builder: (context, box) {
      final cols = box.maxWidth >= 700 ? 3 : 1;
      final w = (box.maxWidth - (cols - 1) * 12) / cols;
      return Wrap(spacing: 12, runSpacing: 12, children: [
        SizedBox(
          width: w,
          child: StatTile(
            icon: Icons.soup_kitchen_outlined,
            label: t.prepTime,
            value: v(insights.prepMinutes),
            sub: t.targetMinutes(targetPrep),
          ),
        ),
        SizedBox(width: w, child: StatTile(icon: Icons.room_service_outlined, label: t.serveTime, value: v(insights.serveMinutes))),
        SizedBox(width: w, child: StatTile(icon: Icons.table_restaurant_outlined, label: t.tableTime, value: v(insights.tableMinutes))),
      ]);
    });
  }
}

/// Annulations : commandes, articles envoyés, montants et motifs.
class CancellationsCard extends StatelessWidget {
  const CancellationsCard({super.key, required this.insights, required this.money});
  final Insights insights;
  final MoneyText money;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final i = insights;
    return SoftCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        SectionHeading(title: t.cancellationsTitle, icon: Icons.block_rounded),
        const SizedBox(height: 10),
        Text('${t.cancelledOrdersCount(i.cancelledOrders)} · ${money(i.cancelledOrdersAmount)}',
            style: const TextStyle(fontWeight: FontWeight.w600)),
        Text('${t.cancelledItemsCount(i.cancelledItems)} · ${money(i.cancelledItemsAmount)}',
            style: const TextStyle(fontWeight: FontWeight.w600)),
        if (i.cancelReasons.isNotEmpty) ...[
          const SizedBox(height: 10),
          Text(t.cancelReasonsTitle, style: const TextStyle(color: RestoColors.muted, fontSize: 12.5)),
          const SizedBox(height: 4),
          for (final r in i.cancelReasons)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(children: [
                Expanded(child: Text('• ${r.$1}', maxLines: 1, overflow: TextOverflow.ellipsis)),
                Text('${r.$2}', style: const TextStyle(fontWeight: FontWeight.w700)),
              ]),
            ),
        ],
      ]),
    );
  }
}
