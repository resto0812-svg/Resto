import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../app_state.dart';
import '../../data/purchases_api.dart';
import '../../ui/branch_scope.dart';
import '../../ui/common.dart';
import '../../ui/kit.dart';
import '../../ui/theme.dart';
import '../reports/insights_widgets.dart' show StatTile;

/// Vue d'ensemble des achats : chiffres clés, échéancier des factures,
/// achats des six derniers mois, principaux fournisseurs.
class PurchasesOverview extends StatelessWidget {
  const PurchasesOverview({
    super.key,
    required this.scope,
    required this.suppliers,
    required this.onOpenInvoice,
    required this.onOpenSupplier,
  });
  final BranchContext scope;
  final List<Supplier> suppliers;
  final ValueChanged<SupplierInvoice> onOpenInvoice;
  final ValueChanged<Supplier> onOpenSupplier;

  String _name(String id) => suppliers.where((s) => s.id == id).firstOrNull?.name ?? '';

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final api = AppScope.of(context).api!.purchases;
    final locale = Localizations.localeOf(context).toString();
    final day = DateFormat.yMMMd(locale);
    String money(int v) => scope.money(context, v);
    final side = MediaQuery.sizeOf(context).width < 600 ? 16.0 : 22.0;
    return FutureBuilder<List<dynamic>>(
      future: Future.wait<dynamic>([
        api.invoices(scope.branchId),
        api.receipts(scope.branchId),
        api.purchaseOrders(scope.branchId),
      ]),
      builder: (context, snap) {
        if (snap.hasError) return Center(child: Text(context.t.retry));
        if (!snap.hasData) return const Center(child: CircularProgressIndicator());
        final invoices = (snap.data![0] as List<SupplierInvoice>).where((i) => i.status != 'cancelled').toList();
        final receipts = snap.data![1] as List<GoodsReceipt>;
        final orders = snap.data![2] as List<PurchaseOrder>;
        final now = DateTime.now();
        final today = DateUtils.dateOnly(now);
        final monthStart = DateTime(now.year, now.month);
        final open = invoices.where((i) => i.status == 'open').toList();
        final debt = open.fold<int>(0, (a, i) => a + i.dueMinor);
        final overdue = open.where((i) => i.dueDate != null && i.dueDate!.isBefore(today)).toList();
        final soon = open.where((i) => i.dueDate != null && !i.dueDate!.isBefore(today) && i.dueDate!.isBefore(today.add(const Duration(days: 8)))).toList();
        final monthPurchases = receipts.where((r) => !r.receivedAt.toLocal().isBefore(monthStart)).fold<int>(0, (a, r) => a + r.totalMinor);
        final pendingOrders = orders.where((o) => const ['draft', 'sent', 'partially_received'].contains(o.status)).length;

        // Achats par mois (six derniers mois, d'après les réceptions).
        final months = [for (var k = 5; k >= 0; k--) DateTime(now.year, now.month - k)];
        final byMonth = {for (final m in months) m: 0};
        for (final r in receipts) {
          final d = r.receivedAt.toLocal();
          final key = DateTime(d.year, d.month);
          if (byMonth.containsKey(key)) byMonth[key] = byMonth[key]! + r.totalMinor;
        }
        final maxMonth = byMonth.values.fold<int>(1, max);

        // Principaux fournisseurs (90 derniers jours).
        final since = today.subtract(const Duration(days: 90));
        final bySupplier = <String, int>{};
        for (final r in receipts.where((r) => r.receivedAt.toLocal().isAfter(since))) {
          bySupplier[r.supplierId] = (bySupplier[r.supplierId] ?? 0) + r.totalMinor;
        }
        final top = bySupplier.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

        final schedule = [...overdue, ...soon, ...open.where((i) => !overdue.contains(i) && !soon.contains(i))]
          ..sort((a, b) => (a.dueDate ?? DateTime(2100)).compareTo(b.dueDate ?? DateTime(2100)));

        Widget grid(List<Widget> cards, double minWidth) => LayoutBuilder(builder: (context, box) {
              final cols = max(1, min(cards.length, (box.maxWidth / minWidth).floor()));
              final w = (box.maxWidth - (cols - 1) * 14) / cols;
              return Wrap(spacing: 14, runSpacing: 14, children: [for (final c in cards) SizedBox(width: w, child: c)]);
            });

        return ListView(padding: EdgeInsets.fromLTRB(side, 6, side, 40), children: [
          grid([
            StatTile(icon: Icons.shopping_bag_outlined, label: t.purchasesThisMonth, value: money(monthPurchases)),
            StatTile(icon: Icons.account_balance_wallet_outlined, label: t.supplierDebtShort, value: money(debt),
                sub: t.openInvoicesCount(open.length)),
            StatTile(
              icon: Icons.warning_amber_rounded,
              label: t.overdueInvoices,
              value: '${overdue.length}',
              sub: money(overdue.fold<int>(0, (a, i) => a + i.dueMinor)),
            ),
            StatTile(icon: Icons.event_note_outlined, label: t.dueWithinWeek, value: '${soon.length}',
                sub: money(soon.fold<int>(0, (a, i) => a + i.dueMinor))),
            StatTile(icon: Icons.local_shipping_outlined, label: t.pendingPurchaseOrders, value: '$pendingOrders'),
          ], 220),
          const SizedBox(height: 16),
          grid([
            // Échéancier.
            SoftCard(
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                SectionHeading(title: t.paymentSchedule, icon: Icons.calendar_month_outlined),
                const SizedBox(height: 8),
                if (schedule.isEmpty)
                  Padding(padding: const EdgeInsets.symmetric(vertical: 16), child: Text(t.nothingToPay, style: const TextStyle(color: RestoColors.muted)))
                else
                  for (final i in schedule.take(10))
                    ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      onTap: () => onOpenInvoice(i),
                      leading: Icon(
                        overdue.contains(i) ? Icons.error_outline_rounded : Icons.schedule_rounded,
                        color: overdue.contains(i) ? const Color(0xFFC0392B) : RestoColors.primaryDeep,
                      ),
                      title: Text('${_name(i.supplierId)} · ${i.number}', maxLines: 1, overflow: TextOverflow.ellipsis),
                      subtitle: Text(i.dueDate == null ? t.noDueDate : t.dueOn(day.format(i.dueDate!)),
                          style: TextStyle(color: overdue.contains(i) ? const Color(0xFFC0392B) : RestoColors.muted)),
                      trailing: Text(money(i.dueMinor), style: const TextStyle(fontWeight: FontWeight.w700)),
                    ),
              ]),
            ),
            // Achats par mois.
            SoftCard(
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                SectionHeading(title: t.purchasesByMonth, icon: Icons.bar_chart_rounded),
                const SizedBox(height: 14),
                SizedBox(
                  height: 170,
                  child: BarChart(BarChartData(
                    maxY: maxMonth * 1.15,
                    gridData: const FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    titlesData: FlTitlesData(
                      leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (v, _) => Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(DateFormat.MMM(locale).format(months[v.toInt()]),
                                style: const TextStyle(fontSize: 11, color: RestoColors.muted)),
                          ),
                        ),
                      ),
                    ),
                    barTouchData: BarTouchData(
                      touchTooltipData: BarTouchTooltipData(
                        getTooltipItem: (g, _, rod, _) => BarTooltipItem(money(rod.toY.round()), const TextStyle(color: Colors.white, fontSize: 12)),
                      ),
                    ),
                    barGroups: [
                      for (var k = 0; k < months.length; k++)
                        BarChartGroupData(x: k, barRods: [
                          BarChartRodData(
                            toY: byMonth[months[k]]!.toDouble(),
                            width: 22,
                            borderRadius: BorderRadius.circular(6),
                            gradient: RestoColors.brandGradient,
                          ),
                        ]),
                    ],
                  )),
                ),
              ]),
            ),
            // Principaux fournisseurs.
            SoftCard(
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                SectionHeading(title: t.topSuppliers, icon: Icons.local_shipping_outlined),
                const SizedBox(height: 8),
                if (top.isEmpty)
                  Padding(padding: const EdgeInsets.symmetric(vertical: 16), child: Text(t.noPurchasesYet, style: const TextStyle(color: RestoColors.muted)))
                else
                  for (final e in top.take(6))
                    ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      onTap: () {
                        final s = suppliers.where((x) => x.id == e.key).firstOrNull;
                        if (s != null) onOpenSupplier(s);
                      },
                      leading: CircleAvatar(
                        radius: 16,
                        backgroundColor: RestoColors.primarySoft,
                        child: Text(_name(e.key).isEmpty ? '?' : _name(e.key)[0].toUpperCase(),
                            style: const TextStyle(color: RestoColors.primaryDeep, fontWeight: FontWeight.w700)),
                      ),
                      title: Text(_name(e.key), maxLines: 1, overflow: TextOverflow.ellipsis),
                      trailing: Text(money(e.value), style: const TextStyle(fontWeight: FontWeight.w700)),
                    ),
              ]),
            ),
          ], 380),
        ]);
      },
    );
  }
}
