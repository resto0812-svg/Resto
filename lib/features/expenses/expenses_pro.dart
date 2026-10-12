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
import '../cash/cash_labels.dart' show paymentMethodLabel;
import '../reports/insights_widgets.dart' show StatTile;
import 'expenses_screen.dart' show expenseCategoryLabel;

const _palette = [
  Color(0xFFC69C3A), Color(0xFF8C2D3A), Color(0xFF2F6FB0), Color(0xFF2E9E5B), Color(0xFFB7791F),
  Color(0xFF7B5EA7), Color(0xFF3F8F8F), Color(0xFFC0392B), Color(0xFF6E665C), Color(0xFFE2C26F),
];

/// Vue d'ensemble des dépenses : mois en cours comparé au précédent,
/// répartition par catégorie, six derniers mois, budgets et récurrentes.
class ExpensesOverview extends StatelessWidget {
  const ExpensesOverview({super.key, required this.scope, required this.month, required this.onGenerated});
  final BranchContext scope;
  final DateTime month;
  final VoidCallback onGenerated;

  Future<void> _generate(BuildContext context) async {
    final t = context.t;
    try {
      final n = await AppScope.read(context).api!.purchases.generateRecurringExpenses(scope.branchId);
      if (!context.mounted) return;
      showInfo(context, t.recurringGenerated(n));
      onGenerated();
    } catch (e) {
      if (context.mounted) showError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final api = AppScope.of(context).api!.purchases;
    final locale = Localizations.localeOf(context).toString();
    String money(int v) => scope.money(context, v);
    final from = DateTime(month.year, month.month - 5);
    final to = DateTime(month.year, month.month + 1, 0);
    final side = MediaQuery.sizeOf(context).width < 600 ? 16.0 : 22.0;
    return FutureBuilder<List<dynamic>>(
      future: Future.wait<dynamic>([
        api.expenses(scope.branchId, from, to),
        api.categories(scope.orgId),
        api.expenseBudgets(scope.branchId),
        api.expenseTemplates(scope.branchId),
      ]),
      builder: (context, snap) {
        if (snap.hasError) return Center(child: Text(t.retry));
        if (!snap.hasData) return const Center(child: CircularProgressIndicator());
        final all = (snap.data![0] as List<Expense>).where((e) => e.status == 'recorded').toList();
        final cats = {for (final c in snap.data![1] as List<ExpenseCategory>) c.id: c};
        final budgets = snap.data![2] as Map<String, int>;
        final templates = snap.data![3] as List<ExpenseTemplate>;
        final due = templates.where((x) => x.dueThisMonth).toList();
        bool inMonth(Expense e, DateTime m) => e.expenseDate.year == m.year && e.expenseDate.month == m.month;
        final current = all.where((e) => inMonth(e, month)).toList();
        final prevMonth = DateTime(month.year, month.month - 1);
        final total = current.fold<int>(0, (a, e) => a + e.amountMinor);
        final prev = all.where((e) => inMonth(e, prevMonth)).fold<int>(0, (a, e) => a + e.amountMinor);
        final trend = prev == 0 ? null : (total - prev) * 100 / prev;
        final byCat = <String, int>{};
        for (final e in current) {
          byCat[e.categoryId] = (byCat[e.categoryId] ?? 0) + e.amountMinor;
        }
        final split = byCat.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
        final months = [for (var k = 5; k >= 0; k--) DateTime(month.year, month.month - k)];
        final byMonth = [for (final m in months) all.where((e) => inMonth(e, m)).fold<int>(0, (a, e) => a + e.amountMinor)];
        final maxMonth = byMonth.fold<int>(1, max);
        String catName(String id) => expenseCategoryLabel(t, cats[id]?.code, cats[id]?.name ?? '');
        final over = budgets.entries.where((b) => (byCat[b.key] ?? 0) > b.value).length;

        Widget grid(List<Widget> cards, double minWidth) => LayoutBuilder(builder: (context, box) {
              final cols = max(1, min(cards.length, (box.maxWidth / minWidth).floor()));
              final w = (box.maxWidth - (cols - 1) * 14) / cols;
              return Wrap(spacing: 14, runSpacing: 14, children: [for (final c in cards) SizedBox(width: w, child: c)]);
            });

        return ListView(padding: EdgeInsets.fromLTRB(side, 6, side, 40), children: [
          if (due.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: SoftCard(
                color: RestoColors.primarySoft,
                child: Row(children: [
                  const GoldIcon(Icons.autorenew_rounded, size: 40),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(t.recurringDue(due.length, money(due.fold<int>(0, (a, x) => a + x.amountMinor))),
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(width: 8),
                  GoldButton(label: t.generateNow, icon: Icons.check_rounded, expand: false, onPressed: () => _generate(context)),
                ]),
              ),
            ),
          grid([
            StatTile(
              icon: Icons.receipt_long_outlined,
              label: t.expensesOfMonth,
              value: money(total),
              sub: trend == null ? null : t.vsLastMonth('${trend >= 0 ? '+' : ''}${trend.toStringAsFixed(0)} %'),
            ),
            StatTile(icon: Icons.history_rounded, label: t.lastMonthLabel, value: money(prev)),
            StatTile(icon: Icons.autorenew_rounded, label: t.recurringTab, value: '${templates.where((x) => x.active).length}',
                sub: money(templates.where((x) => x.active).fold<int>(0, (a, x) => a + x.amountMinor))),
            StatTile(icon: Icons.warning_amber_rounded, label: t.budgetsExceeded, value: '$over'),
          ], 220),
          const SizedBox(height: 16),
          grid([
            SoftCard(
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                SectionHeading(title: t.expensesByCategory, icon: Icons.donut_large_rounded),
                const SizedBox(height: 10),
                if (split.isEmpty)
                  Padding(padding: const EdgeInsets.symmetric(vertical: 16), child: Text(t.noExpenses, style: const TextStyle(color: RestoColors.muted)))
                else
                  Row(children: [
                    SizedBox(
                      width: 130,
                      height: 130,
                      child: PieChart(PieChartData(
                        centerSpaceRadius: 32,
                        sectionsSpace: 2,
                        sections: [
                          for (var k = 0; k < split.length; k++)
                            PieChartSectionData(
                              value: split[k].value.toDouble(),
                              color: _palette[k % _palette.length],
                              radius: 28,
                              title: total == 0 ? '' : '${(split[k].value * 100 / total).round()}%',
                              titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white),
                            ),
                        ],
                      )),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        for (var k = 0; k < split.length; k++)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Row(children: [
                              Container(width: 10, height: 10, decoration: BoxDecoration(color: _palette[k % _palette.length], shape: BoxShape.circle)),
                              const SizedBox(width: 6),
                              Expanded(child: Text(catName(split[k].key), maxLines: 1, overflow: TextOverflow.ellipsis)),
                              Text(money(split[k].value), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5)),
                            ]),
                          ),
                      ]),
                    ),
                  ]),
              ]),
            ),
            SoftCard(
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                SectionHeading(title: t.expensesSixMonths, icon: Icons.bar_chart_rounded),
                const SizedBox(height: 14),
                SizedBox(
                  height: 160,
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
                          BarChartRodData(toY: byMonth[k].toDouble(), width: 22, borderRadius: BorderRadius.circular(6), gradient: RestoColors.brandGradient),
                        ]),
                    ],
                  )),
                ),
              ]),
            ),
            SoftCard(
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                SectionHeading(title: t.budgetsTab, icon: Icons.savings_outlined),
                const SizedBox(height: 10),
                if (budgets.isEmpty)
                  Padding(padding: const EdgeInsets.symmetric(vertical: 12), child: Text(t.noBudgetsYet, style: const TextStyle(color: RestoColors.muted)))
                else
                  for (final b in budgets.entries)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                        Row(children: [
                          Expanded(child: Text(catName(b.key), style: const TextStyle(fontWeight: FontWeight.w600))),
                          Text('${money(byCat[b.key] ?? 0)} / ${money(b.value)}',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: (byCat[b.key] ?? 0) > b.value ? const Color(0xFFC0392B) : RestoColors.ink,
                              )),
                        ]),
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            minHeight: 8,
                            value: b.value == 0 ? 1 : min(1, (byCat[b.key] ?? 0) / b.value),
                            backgroundColor: RestoColors.band,
                            color: (byCat[b.key] ?? 0) > b.value ? const Color(0xFFC0392B) : RestoColors.primary,
                          ),
                        ),
                      ]),
                    ),
              ]),
            ),
          ], 380),
        ]);
      },
    );
  }
}

/// Dépenses récurrentes : modèles (montant, catégorie, jour du mois), actifs ou non.
class ExpenseTemplatesTab extends StatefulWidget {
  const ExpenseTemplatesTab({super.key, required this.scope});
  final BranchContext scope;

  @override
  State<ExpenseTemplatesTab> createState() => _ExpenseTemplatesTabState();
}

class _ExpenseTemplatesTabState extends State<ExpenseTemplatesTab> {
  Key _key = UniqueKey();
  void _reload() => setState(() => _key = UniqueKey());

  Future<void> _edit(List<ExpenseCategory> cats, [ExpenseTemplate? x]) async {
    final values = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => _TemplateDialog(scope: widget.scope, categories: cats, template: x),
    );
    if (values == null || !mounted) return;
    final api = AppScope.read(context).api!.purchases;
    try {
      if (values['_delete'] == true) {
        await api.deleteExpenseTemplate(x!.id);
      } else {
        await api.saveExpenseTemplate(widget.scope.orgId, widget.scope.branchId, x?.id, values);
      }
      _reload();
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final s = widget.scope;
    final api = AppScope.of(context).api!.purchases;
    final side = MediaQuery.sizeOf(context).width < 600 ? 16.0 : 22.0;
    return Loader<(List<ExpenseTemplate>, List<ExpenseCategory>)>(
      key: _key,
      load: () async => (await api.expenseTemplates(s.branchId), await api.categories(s.orgId)),
      builder: (context, d, _) {
        final (list, cats) = d;
        final catOf = {for (final c in cats) c.id: c};
        return Scaffold(
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _edit(cats.where((c) => c.active).toList()),
            icon: const Icon(Icons.add),
            label: Text(t.newRecurringExpense),
          ),
          body: ListView(padding: EdgeInsets.fromLTRB(side, 6, side, 96), children: [
            Text(t.recurringHint, style: const TextStyle(color: RestoColors.muted)),
            const SizedBox(height: 12),
            if (list.isEmpty) EmptyState(icon: Icons.autorenew_rounded, title: t.noRecurringYet),
            for (final x in list)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: SoftCard(
                  onTap: () => _edit(cats.where((c) => c.active).toList(), x),
                  padding: const EdgeInsets.all(14),
                  child: Row(children: [
                    GoldIcon(Icons.autorenew_rounded, size: 40, filled: x.active),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(x.description, style: TextStyle(fontWeight: FontWeight.w700, color: x.active ? RestoColors.ink : RestoColors.muted)),
                        Text('${expenseCategoryLabel(t, catOf[x.categoryId]?.code, catOf[x.categoryId]?.name ?? '')} · ${t.everyMonthOn(x.dayOfMonth)}',
                            style: const TextStyle(color: RestoColors.muted, fontSize: 12.5)),
                      ]),
                    ),
                    Text(s.money(context, x.amountMinor), style: const TextStyle(fontWeight: FontWeight.w800)),
                  ]),
                ),
              ),
          ]),
        );
      },
    );
  }
}

class _TemplateDialog extends StatefulWidget {
  const _TemplateDialog({required this.scope, required this.categories, this.template});
  final BranchContext scope;
  final List<ExpenseCategory> categories;
  final ExpenseTemplate? template;

  @override
  State<_TemplateDialog> createState() => _TemplateDialogState();
}

class _TemplateDialogState extends State<_TemplateDialog> {
  late final _description = TextEditingController(text: widget.template?.description);
  late final _amount = TextEditingController(
    text: widget.template == null ? '' : (widget.template!.amountMinor / pow(10, widget.scope.minorUnit)).toStringAsFixed(widget.scope.minorUnit),
  );
  late String? _category = widget.template?.categoryId ?? widget.categories.firstOrNull?.id;
  late int _day = widget.template?.dayOfMonth ?? 1;
  late String _method = widget.template?.method ?? 'transfer';
  late bool _active = widget.template?.active ?? true;

  @override
  void dispose() {
    _description.dispose();
    _amount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return AlertDialog(
      title: Text(widget.template == null ? t.newRecurringExpense : t.edit),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: _description, maxLength: 300, decoration: InputDecoration(labelText: t.description, hintText: t.recurringExample)),
            DropdownButtonFormField<String>(
              initialValue: _category,
              decoration: InputDecoration(labelText: t.expenseCategoryField),
              items: [
                for (final c in widget.categories) DropdownMenuItem(value: c.id, child: Text(expenseCategoryLabel(t, c.code, c.name))),
              ],
              onChanged: (v) => setState(() => _category = v),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _amount,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(labelText: t.amountLabel, suffixText: widget.scope.currency),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<int>(
              initialValue: _day,
              decoration: InputDecoration(labelText: t.dayOfMonthLabel),
              items: [for (var d = 1; d <= 28; d++) DropdownMenuItem(value: d, child: Text('$d'))],
              onChanged: (v) => setState(() => _day = v ?? 1),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              initialValue: _method,
              decoration: InputDecoration(labelText: t.paymentMethodLabel),
              items: [
                for (final m in const ['transfer', 'cash', 'card', 'mobile_money', 'other'])
                  DropdownMenuItem(value: m, child: Text(paymentMethodLabel(t, m))),
              ],
              onChanged: (v) => setState(() => _method = v ?? 'transfer'),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(t.activeLabel),
              value: _active,
              onChanged: (v) => setState(() => _active = v),
            ),
          ]),
        ),
      ),
      actions: [
        if (widget.template != null)
          TextButton(onPressed: () => Navigator.pop(context, {'_delete': true}), child: Text(t.delete, style: const TextStyle(color: Color(0xFFC0392B)))),
        TextButton(onPressed: () => Navigator.pop(context), child: Text(t.cancel)),
        FilledButton(
          onPressed: () {
            final amount = double.tryParse(_amount.text.trim().replaceAll(',', '.').replaceAll(' ', ''));
            if (_description.text.trim().isEmpty || _category == null || amount == null || amount <= 0) return;
            Navigator.pop(context, {
              'description': _description.text.trim(),
              'category_id': _category,
              'amount_minor': (amount * pow(10, widget.scope.minorUnit)).round(),
              'day_of_month': _day,
              'method': _method,
              'active': _active,
            });
          },
          child: Text(t.save),
        ),
      ],
    );
  }
}

/// Budgets mensuels par catégorie (vide = pas de budget).
class ExpenseBudgetsTab extends StatefulWidget {
  const ExpenseBudgetsTab({super.key, required this.scope});
  final BranchContext scope;

  @override
  State<ExpenseBudgetsTab> createState() => _ExpenseBudgetsTabState();
}

class _ExpenseBudgetsTabState extends State<ExpenseBudgetsTab> {
  final Map<String, TextEditingController> _fields = {};

  @override
  void dispose() {
    for (final c in _fields.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save(List<ExpenseCategory> cats) async {
    final t = context.t;
    final s = widget.scope;
    final api = AppScope.read(context).api!.purchases;
    try {
      for (final c in cats) {
        final text = _fields[c.id]?.text.trim().replaceAll(',', '.').replaceAll(' ', '') ?? '';
        final v = double.tryParse(text);
        await api.setExpenseBudget(s.orgId, s.branchId, c.id, text.isEmpty || v == null ? null : (v * pow(10, s.minorUnit)).round());
      }
      if (mounted) showInfo(context, t.saved);
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final s = widget.scope;
    final api = AppScope.of(context).api!.purchases;
    final side = MediaQuery.sizeOf(context).width < 600 ? 16.0 : 22.0;
    return Loader<(List<ExpenseCategory>, Map<String, int>)>(
      load: () async => ((await api.categories(s.orgId)).where((c) => c.active).toList(), await api.expenseBudgets(s.branchId)),
      builder: (context, d, _) {
        final (cats, budgets) = d;
        for (final c in cats) {
          _fields.putIfAbsent(
            c.id,
            () => TextEditingController(
              text: budgets[c.id] == null ? '' : (budgets[c.id]! / pow(10, s.minorUnit)).toStringAsFixed(s.minorUnit),
            ),
          );
        }
        return ListView(padding: EdgeInsets.fromLTRB(side, 6, side, 40), children: [
          Text(t.budgetsHint, style: const TextStyle(color: RestoColors.muted)),
          const SizedBox(height: 12),
          FormWidth(
            maxWidth: 640,
            child: SoftCard(
              child: Column(children: [
                for (final c in cats)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(children: [
                      Expanded(child: Text(expenseCategoryLabel(t, c.code, c.name), style: const TextStyle(fontWeight: FontWeight.w600))),
                      SizedBox(
                        width: 160,
                        child: TextField(
                          controller: _fields[c.id],
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          textAlign: TextAlign.end,
                          decoration: InputDecoration(isDense: true, suffixText: s.currency, hintText: '—'),
                        ),
                      ),
                    ]),
                  ),
                const SizedBox(height: 12),
                Align(alignment: AlignmentDirectional.centerEnd, child: BusyButton(label: t.save, onPressed: () => _save(cats))),
              ]),
            ),
          ),
        ]);
      },
    );
  }
}
