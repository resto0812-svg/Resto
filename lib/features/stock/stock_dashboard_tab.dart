import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../app_state.dart';
import '../../data/stock_api.dart';
import '../../ui/common.dart';
import '../../ui/kit.dart';
import '../../ui/theme.dart';
import 'stock_screen.dart';
import 'stock_widgets.dart';

/// Tableau de bord du stock : valeur, alertes, consommation, pertes,
/// réceptions, écarts d'inventaire, lots à surveiller, articles à commander.
class StockDashboardTab extends StatefulWidget {
  const StockDashboardTab({super.key, required this.stock, required this.onOpenTab});
  final StockContext stock;
  final ValueChanged<int> onOpenTab;

  @override
  State<StockDashboardTab> createState() => _StockDashboardTabState();
}

class _StockDashboardTabState extends State<StockDashboardTab> {
  int _days = 30;
  late Future<(StockDashboard, List<ExpiringLot>)> _data = _load();

  StockContext get s => widget.stock;

  Future<(StockDashboard, List<ExpiringLot>)> _load() async {
    final api = AppScope.read(context).api!.stock;
    final now = DateTime.now();
    final r = await Future.wait<dynamic>([
      api.dashboard(s.branch.id!, now.subtract(Duration(days: _days - 1)), now),
      api.expiring(s.branch.id!, days: 7),
    ]);
    return (r[0] as StockDashboard, r[1] as List<ExpiringLot>);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final side = MediaQuery.sizeOf(context).width < 600 ? 16.0 : 22.0;
    return FutureBuilder(
      future: _data,
      builder: (context, snap) {
        if (snap.hasError) return Center(child: TextButton(onPressed: () => setState(() => _data = _load()), child: Text(t.retry)));
        if (!snap.hasData) return const Center(child: CircularProgressIndicator());
        final (d, lots) = snap.data!;
        String money(int v) => s.money(context, v);
        final wasteRate = d.consumptionMinor + d.wasteMinor == 0 ? null : d.wasteMinor * 100 / (d.consumptionMinor + d.wasteMinor);
        final alerts = s.data.overview.where((l) => l.belowMin || (l.quantity <= 0 && l.minQuantity > 0)).toList();
        final kpis = [
          KpiCard(icon: Icons.account_balance_wallet_outlined, label: t.stockValueLabel, value: money(d.valueMinor),
              footer: Text(t.articlesCount(d.items), style: const TextStyle(color: RestoColors.muted, fontSize: 12))),
          KpiCard(icon: Icons.restaurant_outlined, label: t.consumptionLabel, value: money(d.consumptionMinor)),
          KpiCard(icon: Icons.delete_outline_rounded, label: t.wasteLabel, value: money(d.wasteMinor),
              trend: wasteRate == null ? null : '${wasteRate.toStringAsFixed(1)} %', trendUp: false),
          KpiCard(icon: Icons.local_shipping_outlined, label: t.receiptsLabel, value: money(d.receiptsMinor)),
          KpiCard(icon: Icons.warning_amber_rounded, label: t.belowThresholdLabel, value: '${d.belowMin}', onTap: () => widget.onOpenTab(1)),
          KpiCard(icon: Icons.remove_shopping_cart_outlined, label: t.outOfStockLabel, value: '${d.outOfStock}', onTap: () => widget.onOpenTab(1)),
          KpiCard(icon: Icons.event_busy_outlined, label: t.expiringSoonLabel, value: '${d.expiring}'),
          KpiCard(icon: Icons.fact_check_outlined, label: t.inventoryVarianceLabel, value: money(d.inventoryVarianceMinor),
              onTap: () => widget.onOpenTab(4)),
        ];
        return RefreshIndicator(
          onRefresh: () async => setState(() => _data = _load()),
          child: ListView(padding: EdgeInsets.fromLTRB(side, 6, side, 40), children: [
            Row(children: [
              Expanded(child: Text(t.stockDashboardTitle, style: serifTitle(context, size: 26))),
              PillBar<int>(
                dense: true,
                items: [PillItem(7, t.daysCount(7)), PillItem(30, t.daysCount(30)), PillItem(90, t.daysCount(90))],
                selected: _days,
                onSelected: (v) => setState(() {
                  _days = v;
                  _data = _load();
                }),
              ),
            ]),
            const SizedBox(height: 12),
            LayoutBuilder(builder: (context, box) {
              final cols = box.maxWidth >= 1100 ? 4 : (box.maxWidth >= 560 ? 2 : 1);
              final w = (box.maxWidth - (cols - 1) * 14) / cols;
              return Wrap(spacing: 14, runSpacing: 14, children: [for (final k in kpis) SizedBox(width: w, child: k)]);
            }),
            const SizedBox(height: 18),
            LayoutBuilder(builder: (context, box) {
              final wide = box.maxWidth >= 900;
              final chart = SoftCard(child: _DayChart(dashboard: d, money: money));
              final side = Column(children: [
                _TopCard(dashboard: d, money: money),
                const SizedBox(height: 14),
                _WasteCard(dashboard: d, money: money),
              ]);
              return wide
                  ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Expanded(flex: 3, child: chart),
                      const SizedBox(width: 14),
                      Expanded(flex: 2, child: side),
                    ])
                  : Column(children: [chart, const SizedBox(height: 14), side]);
            }),
            const SizedBox(height: 18),
            LayoutBuilder(builder: (context, box) {
              final wide = box.maxWidth >= 900;
              final expiring = GoldHeaderCard(
                title: t.expiringLotsTitle,
                titleIcon: Icons.event_busy_outlined,
                badge: HeaderBadge(text: '${lots.length}'),
                child: lots.isEmpty
                    ? Text(t.noExpiringLots, style: const TextStyle(color: RestoColors.muted))
                    : Column(children: [for (final l in lots.take(8)) _LotRow(lot: l, money: money)]),
              );
              final toOrder = GoldHeaderCard(
                title: t.toReorderTitle,
                titleIcon: Icons.shopping_cart_checkout_rounded,
                badge: HeaderBadge(text: '${alerts.length}'),
                action: alerts.isEmpty
                    ? null
                    : GoldButton(label: t.prepareOrder, icon: Icons.local_shipping_outlined, onPressed: () async => widget.onOpenTab(5)),
                child: alerts.isEmpty
                    ? Text(t.noAlerts, style: const TextStyle(color: RestoColors.muted))
                    : Column(children: [
                        for (final l in alerts.take(8))
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(children: [
                              Icon(l.quantity <= 0 ? Icons.error_outline_rounded : Icons.warning_amber_rounded,
                                  size: 18, color: l.quantity <= 0 ? const Color(0xFFC0392B) : StatusColors.toValidate),
                              const SizedBox(width: 8),
                              Expanded(child: Text(l.name, maxLines: 1, overflow: TextOverflow.ellipsis)),
                              Text('${formatQty(context, l.quantity)} / ${formatQty(context, l.minQuantity)} ${unitLabel(t, l.unitCode)}',
                                  style: const TextStyle(fontWeight: FontWeight.w600)),
                            ]),
                          ),
                      ]),
              );
              return wide
                  ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Expanded(child: expiring),
                      const SizedBox(width: 14),
                      Expanded(child: toOrder),
                    ])
                  : Column(children: [expiring, const SizedBox(height: 14), toOrder]);
            }),
          ]),
        );
      },
    );
  }
}

class _LotRow extends StatelessWidget {
  const _LotRow({required this.lot, required this.money});
  final ExpiringLot lot;
  final String Function(int) money;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final days = lot.daysLeft;
    final color = days < 0 ? const Color(0xFFC0392B) : (days <= 2 ? StatusColors.toValidate : RestoColors.primaryDeep);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [
        Container(
          width: 46,
          padding: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
          child: Text(days < 0 ? t.expiredShort : t.daysLeftShort(days),
              textAlign: TextAlign.center, style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 12)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(lot.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600)),
            Text(
              [
                '${formatQty(context, lot.remaining)} ${unitLabel(t, lot.unitCode)}',
                if (lot.batch != null) t.batchShort(lot.batch!),
                DateFormat.yMMMd(Localizations.localeOf(context).toString()).format(lot.expiresOn),
              ].join(' · '),
              style: const TextStyle(color: RestoColors.muted, fontSize: 12),
            ),
          ]),
        ),
        Text(money(lot.valueMinor), style: const TextStyle(fontWeight: FontWeight.w700)),
      ]),
    );
  }
}

/// Consommation et pertes par jour (barres) ; réceptions en surimpression.
class _DayChart extends StatelessWidget {
  const _DayChart({required this.dashboard, required this.money});
  final StockDashboard dashboard;
  final String Function(int) money;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final days = dashboard.byDay;
    final locale = Localizations.localeOf(context).toString();
    final maxY = days.fold<int>(1, (a, d) => max(a, d.$2 + d.$3)).toDouble();
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      SectionHeading(title: t.consumptionByDay, icon: Icons.bar_chart_rounded),
      const SizedBox(height: 8),
      Wrap(spacing: 14, children: [
        _Legend(color: RestoColors.primary, label: t.consumptionLabel),
        _Legend(color: const Color(0xFFC0392B), label: t.wasteLabel),
      ]),
      const SizedBox(height: 12),
      if (days.isEmpty)
        SizedBox(height: 200, child: Center(child: Text(t.noMovementsPeriod, style: const TextStyle(color: RestoColors.muted))))
      else
        SizedBox(
          height: 240,
          child: BarChart(BarChartData(
            maxY: maxY * 1.15,
            gridData: FlGridData(drawVerticalLine: false, getDrawingHorizontalLine: (_) => const FlLine(color: RestoColors.line, strokeWidth: 1)),
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              topTitles: const AxisTitles(),
              rightTitles: const AxisTitles(),
              leftTitles: const AxisTitles(),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 26,
                  getTitlesWidget: (v, _) {
                    final i = v.toInt();
                    if (i < 0 || i >= days.length || (days.length > 14 && i % (days.length ~/ 7) != 0)) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(DateFormat.Md(locale).format(days[i].$1), style: const TextStyle(fontSize: 10, color: RestoColors.muted)),
                    );
                  },
                ),
              ),
            ),
            barTouchData: BarTouchData(
              touchTooltipData: BarTouchTooltipData(
                getTooltipItem: (g, _, r, _) => BarTooltipItem(
                  '${DateFormat.MMMd(locale).format(days[g.x].$1)}\n${t.consumptionLabel} : ${money(days[g.x].$2)}\n${t.wasteLabel} : ${money(days[g.x].$3)}',
                  const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
            barGroups: [
              for (var i = 0; i < days.length; i++)
                BarChartGroupData(x: i, barRods: [
                  BarChartRodData(
                    toY: (days[i].$2 + days[i].$3).toDouble(),
                    width: days.length > 40 ? 5 : (days.length > 14 ? 9 : 16),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                    rodStackItems: [
                      BarChartRodStackItem(0, days[i].$2.toDouble(), RestoColors.primary),
                      BarChartRodStackItem(days[i].$2.toDouble(), (days[i].$2 + days[i].$3).toDouble(), const Color(0xFFC0392B)),
                    ],
                  ),
                ]),
            ],
          )),
        ),
    ]);
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12, color: RestoColors.muted)),
      ]);
}

class _TopCard extends StatelessWidget {
  const _TopCard({required this.dashboard, required this.money});
  final StockDashboard dashboard;
  final String Function(int) money;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final top = dashboard.topConsumed;
    final maxV = top.fold<int>(1, (a, e) => max(a, e.$4));
    return SoftCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        SectionHeading(title: t.topConsumedTitle, icon: Icons.local_fire_department_outlined),
        const SizedBox(height: 10),
        if (top.isEmpty) Text(t.noMovementsPeriod, style: const TextStyle(color: RestoColors.muted)),
        for (final (name, unit, qty, value) in top)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Row(children: [
                Expanded(child: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600))),
                Text('${formatQty(context, qty)} ${unitLabel(t, unit)} · ${money(value)}', style: const TextStyle(fontSize: 12.5)),
              ]),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: LinearProgressIndicator(value: value / maxV, minHeight: 6, color: RestoColors.primary, backgroundColor: RestoColors.primarySoft),
              ),
            ]),
          ),
      ]),
    );
  }
}

class _WasteCard extends StatelessWidget {
  const _WasteCard({required this.dashboard, required this.money});
  final StockDashboard dashboard;
  final String Function(int) money;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final reasons = dashboard.wasteReasons;
    return SoftCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        SectionHeading(title: t.wasteByReason, icon: Icons.delete_sweep_outlined),
        const SizedBox(height: 10),
        if (reasons.isEmpty) Text(t.noWastePeriod, style: const TextStyle(color: RestoColors.muted)),
        for (final (reason, value) in reasons)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Row(children: [
              const Icon(Icons.circle, size: 8, color: Color(0xFFC0392B)),
              const SizedBox(width: 8),
              Expanded(child: Text(reason, maxLines: 1, overflow: TextOverflow.ellipsis)),
              Text(money(value), style: const TextStyle(fontWeight: FontWeight.w700)),
            ]),
          ),
      ]),
    );
  }
}
