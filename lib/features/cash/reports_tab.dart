import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';

import '../../data/cash_api.dart';
import '../../pdf/cash_pdf.dart';
import '../../ui/common.dart';
import '../../ui/files.dart';
import '../../ui/theme.dart';
import '../menus/menu_widgets.dart';
import '../service/service_labels.dart';
import 'cash_context.dart';
import 'cash_labels.dart';

/// Rapports de caisse : indicateurs, encaissements par heure et par jour,
/// par mode, par serveur, par caisse, sessions ; export PDF et tableur.
class CashReportsTab extends StatefulWidget {
  const CashReportsTab({super.key, required this.ctx});
  final CashContext ctx;

  @override
  State<CashReportsTab> createState() => _CashReportsTabState();
}

class _CashReportsTabState extends State<CashReportsTab> {
  String _preset = 'today';
  late DateTimeRange _range = _presetRange('today');

  CashContext get ctx => widget.ctx;

  static DateTimeRange _presetRange(String p) {
    final n = DateTime.now();
    final d = DateTime(n.year, n.month, n.day);
    return switch (p) {
      'yesterday' => DateTimeRange(start: d.subtract(const Duration(days: 1)), end: d.subtract(const Duration(days: 1))),
      'week' => DateTimeRange(start: d.subtract(const Duration(days: 6)), end: d),
      'month' => DateTimeRange(start: DateTime(d.year, d.month), end: d),
      'lastMonth' => DateTimeRange(start: DateTime(d.year, d.month - 1), end: DateTime(d.year, d.month, 0)),
      _ => DateTimeRange(start: d, end: d),
    };
  }

  Future<void> _pdf(CashReport r) async {
    try {
      final bytes = await cashPeriodPdf(
        CashDocContext(
          t: context.t,
          locale: Localizations.localeOf(context).toString(),
          minorUnit: ctx.scope.minorUnit,
          branch: ctx.scope.branch,
          staff: ctx.staff,
        ),
        r,
        _range.start,
        _range.end,
      );
      if (!mounted) return;
      final f = DateFormat('yyyyMMdd');
      await Printing.sharePdf(bytes: bytes, filename: 'rapport-caisse-${f.format(_range.start)}-${f.format(_range.end)}.pdf');
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  Future<void> _csv(CashReport r) async {
    final t = context.t;
    String a(int v) => amountText(v, ctx.scope.currency, ctx.scope.minorUnit);
    final csv = toCsv(
      [t.paymentMethodLabel, t.paymentsCountShort, t.amount, t.tipLabel],
      [
        for (final m in r.byMethod) [m.name, m.count, a(m.total), a(m.tips)],
      ],
    );
    final downloaded = await exportText('modes-de-paiement.csv', csv, 'text/csv');
    if (mounted) showInfo(context, downloaded ? t.exportDownloaded : t.exportCopied);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    String m(int v) => ctx.scope.money(context, v);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              for (final (v, label) in [
                ('today', t.periodToday),
                ('yesterday', t.periodYesterday),
                ('week', t.periodLast7),
                ('month', t.periodMonth),
                ('lastMonth', t.periodLastMonth),
              ])
                ChoiceChip(
                  label: Text(label),
                  selected: _preset == v,
                  onSelected: (_) => setState(() {
                    _preset = v;
                    _range = _presetRange(v);
                  }),
                ),
              ActionChip(
                avatar: const Icon(Icons.date_range_rounded, size: 18),
                label: Text(_preset == 'custom' ? '${dayLabel(context, _range.start)} → ${dayLabel(context, _range.end)}' : t.periodCustom),
                onPressed: () async {
                  final r = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime(2024),
                    lastDate: DateTime.now(),
                    initialDateRange: _range,
                  );
                  if (r != null) {
                    setState(() {
                      _preset = 'custom';
                      _range = r;
                    });
                  }
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: Loader<CashReport>(
            key: ValueKey('${_range.start}${_range.end}'),
            load: () => ctx.cash.report(ctx.scope.branchId, _range.start, _range.end),
            builder: (context, r, reload) => ListView(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 40),
              children: [
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    CashKpi(label: t.salesTotal, value: m(r.salesTotal), icon: Icons.trending_up_rounded, color: RestoColors.primaryDeep),
                    CashKpi(label: t.collectedTotal, value: m(r.collected), icon: Icons.point_of_sale_rounded, color: StatusColors.free),
                    CashKpi(label: t.tipsTotal, value: m(r.tips), icon: Icons.volunteer_activism_rounded, color: StatusColors.reserved),
                    CashKpi(label: t.averageTicket, value: m(r.averageTicket), icon: Icons.receipt_rounded),
                    CashKpi(label: t.ordersClosedCount, value: '${r.ordersClosed}', icon: Icons.check_circle_rounded),
                    CashKpi(label: t.discountsTotal, value: m(r.discounts), icon: Icons.local_offer_rounded),
                    CashKpi(
                      label: t.refundsLabel,
                      value: '${m(r.refunds)} (${r.refundsCount})',
                      icon: Icons.undo_rounded,
                      color: StatusColors.late,
                    ),
                    CashKpi(label: t.feesEstimate, value: m(r.fees), icon: Icons.percent_rounded),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  children: [
                    FilledButton.icon(onPressed: () => _pdf(r), icon: const Icon(Icons.picture_as_pdf_rounded), label: Text(t.exportPdf)),
                    OutlinedButton.icon(onPressed: () => _csv(r), icon: const Icon(Icons.table_view_rounded), label: Text(t.exportExcel)),
                  ],
                ),
                const SizedBox(height: 16),
                LayoutBuilder(
                  builder: (context, box) {
                    final wide = box.maxWidth >= 980;
                    final hours = _ChartCard(
                      title: t.collectedByHour,
                      child: _Bars(
                        values: {for (var h = 0; h < 24; h++) h: r.byHour[h] ?? 0},
                        label: (k) => '${k.toString().padLeft(2, '0')}h',
                        money: m,
                        skipLabels: 3,
                      ),
                    );
                    final days = _ChartCard(
                      title: t.collectedByDay,
                      child: _Bars(
                        values: {
                          for (var d = _range.start; !d.isAfter(_range.end); d = d.add(const Duration(days: 1)))
                            d.difference(_range.start).inDays: r.byDay[DateTime(d.year, d.month, d.day)] ?? 0,
                        },
                        label: (k) => DateFormat.Md(Localizations.localeOf(context).toString()).format(_range.start.add(Duration(days: k))),
                        money: m,
                        skipLabels: math.max(1, (_range.duration.inDays / 8).ceil()),
                      ),
                    );
                    return wide
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: hours),
                              const SizedBox(width: 12),
                              Expanded(child: days),
                            ],
                          )
                        : Column(children: [hours, const SizedBox(height: 12), days]);
                  },
                ),
                const SizedBox(height: 12),
                _ChartCard(
                  title: t.salesByMethod,
                  child: r.byMethod.isEmpty
                      ? Text(t.noPaymentsYet, style: theme.textTheme.bodySmall)
                      : Column(
                          children: [
                            for (final x in r.byMethod)
                              _HBar(
                                icon: paymentKindIcon(x.kind),
                                label: '${x.name} · ${x.count}',
                                value: x.total,
                                max: r.byMethod.map((e) => e.total).reduce(math.max),
                                trailing: x.tips > 0 ? '${m(x.total)} · ${t.tipLabel} ${m(x.tips)}' : m(x.total),
                              ),
                          ],
                        ),
                ),
                const SizedBox(height: 12),
                LayoutBuilder(
                  builder: (context, box) {
                    final wide = box.maxWidth >= 980;
                    final staff = _ChartCard(
                      title: t.salesByStaff,
                      child: r.byStaff.isEmpty
                          ? Text(t.noEntries, style: theme.textTheme.bodySmall)
                          : Column(
                              children: [
                                for (final s in r.byStaff)
                                  _HBar(
                                    icon: Icons.person_rounded,
                                    label: '${ctx.staffName(s.$1)} · ${t.ordersCountShort(s.$2)}',
                                    value: s.$3,
                                    max: r.byStaff.map((e) => e.$3).reduce(math.max),
                                    trailing: s.$4 > 0 ? '${m(s.$3)} · ${t.tipLabel} ${m(s.$4)}' : m(s.$3),
                                  ),
                              ],
                            ),
                    );
                    final registers = _ChartCard(
                      title: t.salesByRegister,
                      child: r.byRegister.isEmpty
                          ? Text(t.noEntries, style: theme.textTheme.bodySmall)
                          : Column(
                              children: [
                                for (final x in r.byRegister)
                                  _HBar(
                                    icon: Icons.point_of_sale_rounded,
                                    label: x.$1,
                                    value: x.$2,
                                    max: r.byRegister.map((e) => e.$2).reduce(math.max),
                                    trailing: m(x.$2),
                                  ),
                              ],
                            ),
                    );
                    return wide
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: staff),
                              const SizedBox(width: 12),
                              Expanded(child: registers),
                            ],
                          )
                        : Column(children: [staff, const SizedBox(height: 12), registers]);
                  },
                ),
                const SizedBox(height: 12),
                _ChartCard(
                  title: t.closingsTab,
                  child: r.sessions.isEmpty
                      ? Text(t.noClosings, style: theme.textTheme.bodySmall)
                      : Column(
                          children: [
                            for (final s in r.sessions)
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                dense: true,
                                leading: Text(
                                  s['z_number'] == null ? '—' : 'Z${s['z_number']}',
                                  style: const TextStyle(fontWeight: FontWeight.w800),
                                ),
                                title: Text('${s['register']} · ${dayLabel(context, DateTime.parse(s['opened_at'] as String).toLocal())}'),
                                trailing: s['difference'] == null
                                    ? null
                                    : StatusPill(
                                        label: m((s['difference'] as num).toInt()),
                                        color: (s['difference'] as num) == 0 ? StatusColors.free : StatusColors.late,
                                        dense: true,
                                      ),
                              ),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ChartCard extends StatelessWidget {
  const _ChartCard({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) => Card(
    margin: EdgeInsets.zero,
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          child,
        ],
      ),
    ),
  );
}

/// Histogramme à une seule série (or foncé), infobulle au survol, grille discrète.
class _Bars extends StatelessWidget {
  const _Bars({required this.values, required this.label, required this.money, this.skipLabels = 1});
  final Map<int, int> values;
  final String Function(int) label;
  final String Function(int) money;
  final int skipLabels;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maxV = values.values.fold<int>(0, math.max);
    if (maxV == 0) {
      return SizedBox(
        height: 60,
        child: Center(child: Text(context.t.noPaymentsYet, style: theme.textTheme.bodySmall)),
      );
    }
    final keys = values.keys.toList()..sort();
    return SizedBox(
      height: 220,
      child: BarChart(
        BarChartData(
          maxY: maxV * 1.15,
          alignment: BarChartAlignment.spaceAround,
          gridData: FlGridData(
            drawVerticalLine: false,
            horizontalInterval: maxV / 4,
            getDrawingHorizontalLine: (_) => FlLine(color: theme.colorScheme.outlineVariant, strokeWidth: 1),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(),
            rightTitles: const AxisTitles(),
            leftTitles: const AxisTitles(),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 24,
                getTitlesWidget: (v, meta) {
                  final k = v.toInt();
                  if (k % skipLabels != 0) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(label(k), style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                  );
                },
              ),
            ),
          ),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => RestoColors.ink,
              getTooltipItem: (group, _, rod, _) => BarTooltipItem(
                '${label(group.x)}\n${money(rod.toY.round())}',
                const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          barGroups: [
            for (final k in keys)
              BarChartGroupData(
                x: k,
                barRods: [
                  BarChartRodData(
                    toY: values[k]!.toDouble(),
                    width: math.max(4, math.min(18, 300 / keys.length)),
                    color: RestoColors.primaryDeep,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

/// Barre horizontale libellée (comparaison de catégories nommées).
class _HBar extends StatelessWidget {
  const _HBar({required this.icon, required this.label, required this.value, required this.max, required this.trailing});
  final IconData icon;
  final String label;
  final int value;
  final int max;
  final String trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: theme.colorScheme.onSurfaceVariant),
              const SizedBox(width: 8),
              Expanded(child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis)),
              Text(trailing, style: theme.textTheme.titleSmall),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: max == 0 ? 0 : value / max,
              minHeight: 10,
              backgroundColor: theme.colorScheme.surfaceContainerHigh,
              color: RestoColors.primaryDeep,
            ),
          ),
        ],
      ),
    );
  }
}
