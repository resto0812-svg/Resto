import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../app_state.dart';
import '../../data/dashboard_api.dart';
import '../../data/models.dart';
import '../../data/purchases_api.dart';
import '../../data/stock_api.dart';
import '../../ui/branch_scope.dart';
import '../../ui/common.dart';
import '../../ui/files.dart';
import '../../ui/kit.dart';
import '../../ui/theme.dart';
import '../cash/cash_labels.dart';
import '../expenses/expenses_screen.dart';
import '../menus/menu_widgets.dart' show channelLabel;

/// Rapport financier d'une période : chiffre d'affaires, encaissements, coût
/// des ventes, marge, pertes, dépenses, résultat estimé, dettes ; exports.
/// Chaque indicateur explique sa règle de calcul (ⓘ).
class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key, required this.membership});
  final Membership membership;

  @override
  Widget build(BuildContext context) =>
      BranchScope(membership: membership, builder: (context, scope) => _ReportsBody(scope: scope));
}

enum _Period { today, last7, month, lastMonth, custom }

class _ReportsBody extends StatefulWidget {
  const _ReportsBody({required this.scope});
  final BranchContext scope;

  @override
  State<_ReportsBody> createState() => _ReportsBodyState();
}

class _ReportsBodyState extends State<_ReportsBody> {
  _Period _period = _Period.month;
  late DateTimeRange _custom = DateTimeRange(start: DateTime.now().subtract(const Duration(days: 30)), end: DateTime.now());

  DateTimeRange get _range {
    final now = DateUtils.dateOnly(DateTime.now());
    return switch (_period) {
      _Period.today => DateTimeRange(start: now, end: now),
      _Period.last7 => DateTimeRange(start: now.subtract(const Duration(days: 6)), end: now),
      _Period.month => DateTimeRange(start: DateTime(now.year, now.month), end: now),
      _Period.lastMonth => DateTimeRange(start: DateTime(now.year, now.month - 1), end: DateTime(now.year, now.month, 0)),
      _Period.custom => _custom,
    };
  }

  Future<void> _export(String kind) async {
    final t = context.t;
    final api = AppScope.read(context).api!.purchases;
    final s = widget.scope;
    final r = _range;
    final day = DateFormat('yyyy-MM-dd');
    try {
      String csv;
      if (kind == 'orders') {
        final rows = await api.ordersForExport(s.branchId, r.start, r.end);
        csv = toCsv(
          ['numero', 'date', 'canal', 'statut', 'sous_total', 'taxe', 'total', 'paye', 'ouverte', 'cloturee', 'monnaie'],
          [
            for (final o in rows)
              [o['number'], o['business_date'], o['channel'], o['status'], _major(o['subtotal_minor']), _major(o['tax_minor']),
                _major(o['total_minor']), _major(o['paid_minor']), o['opened_at'], o['closed_at'], s.currency],
          ],
        );
      } else if (kind == 'payments') {
        final rows = await api.paymentsForExport(s.branchId, r.start, r.end);
        csv = toCsv(
          ['date', 'commande', 'moyen', 'montant', 'statut', 'reference', 'monnaie'],
          [
            for (final p in rows)
              [p['created_at'], (p['orders'] as Map?)?['number'], p['method'], _major(p['amount_minor']), p['status'], p['reference'], s.currency],
          ],
        );
      } else {
        final list = await api.expenses(s.branchId, r.start, r.end);
        final cats = {for (final c in await api.categories(s.orgId)) c.id: c};
        if (!mounted) return;
        csv = toCsv(
          ['date', 'categorie', 'description', 'montant_ttc', 'taxe', 'moyen', 'statut', 'monnaie'],
          [
            for (final e in list)
              [day.format(e.expenseDate), expenseCategoryLabel(t, cats[e.categoryId]?.code, cats[e.categoryId]?.name ?? ''), e.description,
                _major(e.amountMinor), _major(e.taxMinor), e.method, e.status, s.currency],
          ],
        );
      }
      final name = 'resto_${kind}_${day.format(r.start)}_${day.format(r.end)}.csv';
      final downloaded = await exportText(name, csv, 'text/csv');
      if (mounted) showInfo(context, downloaded ? t.exportDownloaded : t.exportCopied);
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  /// Montant en unités principales pour les tableurs (point décimal).
  String _major(Object? minor) {
    final v = (minor as num? ?? 0) / BranchMath.pow10(widget.scope.minorUnit);
    return v.toStringAsFixed(widget.scope.minorUnit);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final s = widget.scope;
    final api = AppScope.of(context).api!;
    final range = _range;
    final fmt = DateFormat.yMMMd(Localizations.localeOf(context).toString());
    final side = MediaQuery.sizeOf(context).width < 600 ? 16.0 : 22.0;
    return ListView(padding: EdgeInsets.fromLTRB(side, 6, side, 32), children: [
      SoftCard(
        color: const Color(0xFFF3EADB),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(children: [
          Text('${t.periodLabel} :', style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(width: 12),
          Expanded(
            child: PillBar<_Period>(
              dense: true,
              items: [
                PillItem(_Period.today, t.periodToday),
                PillItem(_Period.last7, t.periodLast7),
                PillItem(_Period.month, t.periodMonth),
                PillItem(_Period.lastMonth, t.periodLastMonth),
                PillItem(_Period.custom, _period == _Period.custom ? '${fmt.format(range.start)} – ${fmt.format(range.end)}' : t.periodCustom),
              ],
              selected: _period,
              onSelected: (p) async {
                if (p == _Period.custom) {
                  final r = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                    initialDateRange: _custom,
                  );
                  if (r == null) return;
                  _custom = r;
                }
                setState(() => _period = p);
              },
            ),
          ),
        ]),
      ),
      const SizedBox(height: 16),
      Loader<Dashboard>(
        key: ValueKey('d${range.start}|${range.end}|${s.branchId}'),
        load: () => api.dashboard.load(s.branchId, range.start, range.end),
        builder: (context, d, _) => _DashboardCards(scope: s, d: d, singleDay: range.start == range.end),
      ),
      const SizedBox(height: 24),
      Text(t.financialResult, style: serifTitle(context, size: 26)),
      const SizedBox(height: 10),
      Loader<FinanceSummary>(
        key: ValueKey('${range.start}|${range.end}|${s.branchId}'),
        load: () => api.purchases.finance(s.branchId, range.start, range.end),
        builder: (context, f, _) => Align(
          alignment: AlignmentDirectional.topStart,
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Wrap(spacing: 12, runSpacing: 12, children: [
              _Kpi(t.salesInclTax, s.money(context, f.salesTtc), t.ruleSales, sub: t.ordersCountShort(f.ordersClosed)),
              _Kpi(t.salesExclTax, s.money(context, f.salesHt), t.ruleSalesHt, sub: t.includingTax(s.money(context, f.salesTax))),
              _Kpi(t.collected, s.money(context, f.collected), t.ruleCollected),
              _Kpi(t.costOfSales, s.money(context, f.cogs), t.ruleCogs),
              _Kpi(
                t.grossMargin,
                s.money(context, f.grossMargin),
                t.ruleGrossMargin,
                sub: f.salesHt > 0 ? t.marginPercent((f.grossMargin * 100 / f.salesHt).round()) : null,
              ),
              _Kpi(t.lossesValue, s.money(context, f.losses), t.ruleLosses),
              _Kpi(t.expensesExclTax, s.money(context, f.expensesHt), t.ruleExpenses),
              _Kpi(t.estimatedResult, s.money(context, f.estimatedResult), t.ruleResult, highlight: true, negative: f.estimatedResult < 0),
              _Kpi(t.purchasesValue, s.money(context, f.purchases), t.rulePurchases),
              _Kpi(t.supplierDebtShort, s.money(context, f.supplierDebt), t.ruleDebt),
            ]),
            if (f.expensesByCategory.isNotEmpty) ...[
              const SizedBox(height: 20),
              Text(t.expensesByCategory, style: Theme.of(context).textTheme.titleMedium),
              for (final (code, name, total) in f.expensesByCategory)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(children: [Expanded(child: Text(expenseCategoryLabel(t, code, name))), Text(s.money(context, total))]),
                ),
            ],
            const SizedBox(height: 12),
            Text(t.resultDisclaimer, style: Theme.of(context).textTheme.bodySmall),
          ]),
        ),
      ),
      const SizedBox(height: 24),
      SoftCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          SectionHeading(title: t.exportsTitle, icon: Icons.download_rounded),
          const SizedBox(height: 12),
          Wrap(spacing: 8, runSpacing: 8, children: [
            OutlinedButton.icon(onPressed: () => _export('orders'), icon: const Icon(Icons.download), label: Text(t.exportOrders)),
            OutlinedButton.icon(onPressed: () => _export('payments'), icon: Icon(paymentMethodIcon('card')), label: Text(t.exportPayments)),
            OutlinedButton.icon(onPressed: () => _export('expenses'), icon: const Icon(Icons.receipt_outlined), label: Text(t.exportExpenses)),
          ]),
        ]),
      ),
      const SizedBox(height: 16),
      SoftCard(child: _Margins(scope: s)),
    ]);
  }
}

/// Cartes du tableau de bord : chiffre d'affaires (courbe, tendance),
/// meilleurs plats, répartition par canal, transactions récentes.
class _DashboardCards extends StatelessWidget {
  const _DashboardCards({required this.scope, required this.d, required this.singleDay});
  final BranchContext scope;
  final Dashboard d;
  final bool singleDay;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final locale = Localizations.localeOf(context).toString();
    String money(int v) => scope.money(context, v);
    final trend = d.salesTrend;

    // Courbe : par heure pour une journée, par jour sinon.
    final points = singleDay
        ? [for (var h = 0; h < 24; h++) FlSpot(h.toDouble(), (d.byHour[h] ?? 0).toDouble())]
        : [for (var i = 0; i < d.byDay.length; i++) FlSpot(i.toDouble(), d.byDay[i].$2.toDouble())];
    final sales = SoftCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const GoldIcon(Icons.trending_up_rounded, size: 40),
          const SizedBox(width: 10),
          Expanded(child: Text(singleDay ? t.kpiSalesToday : t.salesOfPeriod, style: const TextStyle(color: RestoColors.muted))),
          if (trend != null) TrendChip(text: '${trend >= 0 ? '+' : ''}${trend.toStringAsFixed(0)} %', up: trend >= 0),
        ]),
        const SizedBox(height: 8),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: AlignmentDirectional.centerStart,
          child: Text(money(d.sales ?? 0), style: serifTitle(context, size: 38)),
        ),
        Text('${t.ordersCountShort(d.ordersClosed)} · ${t.averageTicketShort(money(d.averageTicket))}',
            style: const TextStyle(color: RestoColors.muted, fontSize: 12.5)),
        if (d.prevSales != null)
          Text(t.vsPrevious(money(d.prevSales!)), style: const TextStyle(color: RestoColors.muted, fontSize: 12.5)),
        const SizedBox(height: 10),
        SizedBox(
          height: 90,
          child: points.every((p) => p.y == 0)
              ? const SizedBox.shrink()
              : LineChart(LineChartData(
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  titlesData: const FlTitlesData(show: false),
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (spots) => [
                        for (final s in spots)
                          LineTooltipItem(
                            '${singleDay ? '${s.x.toInt()} h' : DateFormat.MMMd(locale).format(d.byDay[s.x.toInt()].$1)}\n${money(s.y.round())}',
                            const TextStyle(color: Colors.white, fontSize: 12),
                          ),
                      ],
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: points,
                      isCurved: true,
                      curveSmoothness: 0.25,
                      color: RestoColors.primary,
                      barWidth: 2,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [RestoColors.primary.withValues(alpha: 0.28), RestoColors.primary.withValues(alpha: 0.0)],
                        ),
                      ),
                    ),
                  ],
                )),
        ),
      ]),
    );

    final maxQty = d.topItems.fold<int>(1, (a, x) => max(a, x.quantity));
    final top = SoftCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        SectionHeading(title: t.topDishes, icon: Icons.bar_chart_rounded),
        const SizedBox(height: 14),
        if (d.topItems.isEmpty)
          Padding(padding: const EdgeInsets.symmetric(vertical: 20), child: Text(t.noSalesYet, style: const TextStyle(color: RestoColors.muted)))
        else
          for (final it in d.topItems.take(5))
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(children: [
                SizedBox(width: 110, child: Text(it.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600))),
                const SizedBox(width: 8),
                Expanded(
                  child: LayoutBuilder(builder: (context, box) {
                    return Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Container(
                        height: 16,
                        width: max(8, box.maxWidth * it.quantity / maxQty),
                        decoration: BoxDecoration(gradient: RestoColors.brandGradient, borderRadius: BorderRadius.circular(5)),
                      ),
                    );
                  }),
                ),
                const SizedBox(width: 8),
                Text('${it.quantity}', style: const TextStyle(fontWeight: FontWeight.w700)),
              ]),
            ),
      ]),
    );

    final channelColors = {
      'dine_in': RestoColors.primary,
      'delivery': const Color(0xFFE2C26F),
      'takeaway': const Color(0xFF9A741F),
    };
    final totalChannels = d.byChannel.values.fold<int>(0, (a, v) => a + v.$1);
    final split = SoftCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        SectionHeading(title: t.salesSplit, icon: Icons.donut_large_rounded),
        const SizedBox(height: 10),
        if (totalChannels == 0)
          Padding(padding: const EdgeInsets.symmetric(vertical: 20), child: Text(t.noSalesYet, style: const TextStyle(color: RestoColors.muted)))
        else
          Row(children: [
            SizedBox(
              width: 120,
              height: 120,
              child: PieChart(PieChartData(
                centerSpaceRadius: 30,
                sectionsSpace: 2,
                sections: [
                  for (final e in d.byChannel.entries)
                    PieChartSectionData(
                      value: e.value.$1.toDouble(),
                      color: channelColors[e.key] ?? RestoColors.muted,
                      radius: 26,
                      title: '${(e.value.$1 * 100 / totalChannels).round()} %',
                      titleStyle: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Colors.white),
                    ),
                ],
              )),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                for (final e in d.byChannel.entries)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Row(children: [
                      Container(width: 10, height: 10, decoration: BoxDecoration(color: channelColors[e.key], shape: BoxShape.circle)),
                      const SizedBox(width: 6),
                      Expanded(child: Text('${channelLabel(t, e.key)} ${(e.value.$1 * 100 / totalChannels).round()} %')),
                    ]),
                  ),
              ]),
            ),
          ]),
      ]),
    );

    final recent = SoftCard(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 10),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        SectionHeading(title: t.recentTransactions, icon: Icons.receipt_long_rounded),
        const SizedBox(height: 8),
        if (d.recent.isEmpty)
          Padding(padding: const EdgeInsets.symmetric(vertical: 16), child: Text(t.noSalesYet, style: const TextStyle(color: RestoColors.muted)))
        else
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowHeight: 40,
              headingRowColor: WidgetStatePropertyAll(RestoColors.band.withValues(alpha: 0.6)),
              headingTextStyle: const TextStyle(color: RestoColors.muted, fontWeight: FontWeight.w600, fontSize: 12.5),
              columns: [
                DataColumn(label: Text(t.timeLabel)),
                DataColumn(label: Text(t.orderLabel)),
                DataColumn(label: Text(t.customerLabel)),
                DataColumn(label: Text(t.paymentLabel)),
                DataColumn(label: Text(t.amountLabel), numeric: true),
                DataColumn(label: Text(t.statusLabel)),
              ],
              rows: [
                for (final r in d.recent)
                  DataRow(cells: [
                    DataCell(Text(DateFormat.Hm(locale).format(r.at.toLocal()))),
                    DataCell(Text('#${r.orderNumber}')),
                    DataCell(Text(r.customer ?? channelLabel(t, r.channel))),
                    DataCell(Text(r.method)),
                    DataCell(Text(money(r.amount), style: const TextStyle(fontWeight: FontWeight.w700))),
                    DataCell(StatusPill(
                      label: r.orderStatus == 'closed' ? t.paidShort : t.partlyPaid,
                      color: r.orderStatus == 'closed' ? const Color(0xFF2E9E5B) : StatusColors.cooking,
                      dense: true,
                    )),
                  ]),
              ],
            ),
          ),
      ]),
    );

    return LayoutBuilder(builder: (context, box) {
      final cols = box.maxWidth >= 1050 ? 3 : (box.maxWidth >= 680 ? 2 : 1);
      final w = (box.maxWidth - (cols - 1) * 14) / cols;
      return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Wrap(spacing: 14, runSpacing: 14, children: [
          SizedBox(width: w, child: sales),
          SizedBox(width: w, child: top),
          SizedBox(width: w, child: split),
        ]),
        const SizedBox(height: 14),
        recent,
      ]);
    });
  }
}

abstract final class BranchMath {
  static double pow10(int n) {
    var r = 1.0;
    for (var i = 0; i < n; i++) {
      r *= 10;
    }
    return r;
  }
}

class _Kpi extends StatelessWidget {
  const _Kpi(this.label, this.value, this.rule, {this.sub, this.highlight = false, this.negative = false});
  final String label;
  final String value;
  final String rule;
  final String? sub;
  final bool highlight;
  final bool negative;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: 230,
      child: SoftCard(
        color: highlight ? RestoColors.primarySoft : null,
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Text(label, style: const TextStyle(color: RestoColors.muted, fontSize: 12.5))),
            Tooltip(message: rule, child: const Icon(Icons.info_outline, size: 16, color: RestoColors.primaryDeep)),
          ]),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: AlignmentDirectional.centerStart,
            child: Text(value,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(color: negative ? scheme.error : null, fontWeight: FontWeight.w700)),
          ),
          if (sub != null) Text(sub!, style: Theme.of(context).textTheme.bodySmall),
        ]),
      ),
    );
  }
}

/// Marges par plat (fiche technique en vigueur et coûts moyens actuels).
class _Margins extends StatelessWidget {
  const _Margins({required this.scope});
  final BranchContext scope;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final api = AppScope.of(context).api!.stock;
    return Loader<List<RecipeCost>>(
      load: () => api.recipeCosts(scope.branchId),
      builder: (context, list, _) {
        final withRecipe = list.where((c) => c.hasRecipe && c.priceMinor != null && c.priceMinor! > 0).toList()
          ..sort((a, b) => ((a.priceMinor! - (a.costMinor ?? 0)) / a.priceMinor!).compareTo((b.priceMinor! - (b.costMinor ?? 0)) / b.priceMinor!));
        return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text(t.marginsByItem, style: Theme.of(context).textTheme.titleMedium),
          Text(t.marginsHint(list.where((c) => !c.hasRecipe).length), style: Theme.of(context).textTheme.bodySmall),
          for (final c in withRecipe)
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: Text(c.variantName.isEmpty ? c.itemName : '${c.itemName} (${c.variantName})'),
              subtitle: Text('${t.costPrice(scope.money(context, c.costMinor ?? 0))} · ${t.sellingPrice(scope.money(context, c.priceMinor!))}'),
              trailing: Text(t.marginPercent(((c.priceMinor! - (c.costMinor ?? 0)) * 100 / c.priceMinor!).round()),
                  style: const TextStyle(fontWeight: FontWeight.w600)),
            ),
        ]);
      },
    );
  }
}
