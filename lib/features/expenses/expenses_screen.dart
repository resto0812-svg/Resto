import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../app_state.dart';
import '../../data/cash_api.dart';
import '../../data/models.dart';
import '../../data/purchases_api.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/branch_scope.dart';
import '../../ui/common.dart';
import '../../ui/files.dart';
import '../cash/cash_labels.dart';
import '../menus/menu_widgets.dart';
import '../stock/stock_widgets.dart';

String expenseCategoryLabel(AppLocalizations t, String? code, String name) => switch (code) {
      'rent' => t.expRent,
      'electricity' => t.expElectricity,
      'water' => t.expWater,
      'gas' => t.expGas,
      'salaries' => t.expSalaries,
      'transport' => t.expTransport,
      'maintenance' => t.expMaintenance,
      'marketing' => t.expMarketing,
      'supplies' => t.expSupplies,
      'taxes' => t.expTaxes,
      'bank_fees' => t.expBankFees,
      'other' => t.expOther,
      _ => name,
    };

/// Dépenses d'un établissement par mois : saisie (avec justificatif, payée
/// éventuellement depuis la caisse), annulation tracée.
class ExpensesScreen extends StatelessWidget {
  const ExpensesScreen({super.key, required this.membership});
  final Membership membership;

  @override
  Widget build(BuildContext context) =>
      BranchScope(membership: membership, builder: (context, scope) => _ExpensesBody(scope: scope));
}

class _ExpensesBody extends StatefulWidget {
  const _ExpensesBody({required this.scope});
  final BranchContext scope;

  @override
  State<_ExpensesBody> createState() => _ExpensesBodyState();
}

class _ExpensesBodyState extends State<_ExpensesBody> {
  DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);
  Key _key = UniqueKey();

  void _reload() => setState(() => _key = UniqueKey());

  Future<(List<Expense>, List<ExpenseCategory>, List<Supplier>)> _load() async {
    final api = AppScope.read(context).api!.purchases;
    final r = await Future.wait<dynamic>([
      api.expenses(widget.scope.branchId, _month, DateTime(_month.year, _month.month + 1, 0)),
      api.categories(widget.scope.orgId),
      api.suppliers(widget.scope.orgId),
    ]);
    return (r[0] as List<Expense>, r[1] as List<ExpenseCategory>, r[2] as List<Supplier>);
  }

  Future<void> _new(List<ExpenseCategory> cats, List<Supplier> suppliers) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => _ExpenseDialog(scope: widget.scope, categories: cats, suppliers: suppliers),
    );
    if (ok == true) _reload();
  }

  Future<void> _cancel(Expense e) async {
    final t = context.t;
    final c = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (dc) => AlertDialog(
        title: Text(t.cancelExpense),
        content: TextField(controller: c, autofocus: true, maxLength: 500, decoration: InputDecoration(labelText: t.reason)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dc), child: Text(t.cancel)),
          FilledButton(
            onPressed: () {
              if (c.text.trim().length >= 3) Navigator.pop(dc, c.text.trim());
            },
            child: Text(t.confirm),
          ),
        ],
      ),
    );
    c.dispose();
    if (reason == null || !mounted) return;
    try {
      await AppScope.read(context).api!.purchases.cancelExpense(e.id, reason);
      _reload();
    } catch (err) {
      if (mounted) showError(context, err);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final s = widget.scope;
    final month = DateFormat.yMMMM(Localizations.localeOf(context).toString());
    final day = DateFormat.yMMMd(Localizations.localeOf(context).toString());
    final api = AppScope.of(context).api!.purchases;
    return Loader<(List<Expense>, List<ExpenseCategory>, List<Supplier>)>(
      key: _key,
      load: _load,
      builder: (context, data, _) {
        final (list, cats, suppliers) = data;
        final catOf = {for (final c in cats) c.id: c};
        final recorded = list.where((e) => e.status == 'recorded');
        final total = recorded.fold<int>(0, (a, e) => a + e.amountMinor);
        final tax = recorded.fold<int>(0, (a, e) => a + e.taxMinor);
        return Scaffold(
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _new(cats, suppliers),
            icon: const Icon(Icons.add),
            label: Text(t.newExpense),
          ),
          body: ListView(padding: const EdgeInsets.fromLTRB(16, 12, 16, 96), children: [
            FormWidth(
              maxWidth: 900,
              child: Row(children: [
                IconButton(
                  tooltip: t.previousMonth,
                  onPressed: () => setState(() {
                    _month = DateTime(_month.year, _month.month - 1);
                    _key = UniqueKey();
                  }),
                  icon: const Icon(Icons.chevron_left),
                ),
                Text(month.format(_month), style: Theme.of(context).textTheme.titleMedium),
                IconButton(
                  tooltip: t.nextMonth,
                  onPressed: () => setState(() {
                    _month = DateTime(_month.year, _month.month + 1);
                    _key = UniqueKey();
                  }),
                  icon: const Icon(Icons.chevron_right),
                ),
                const Spacer(),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text(t.totalAmount(s.money(context, total)), style: Theme.of(context).textTheme.titleMedium),
                  if (tax > 0) Text(t.includingTax(s.money(context, tax)), style: Theme.of(context).textTheme.bodySmall),
                ]),
              ]),
            ),
            if (list.isEmpty) FormWidth(maxWidth: 900, child: Padding(padding: const EdgeInsets.only(top: 24), child: Text(t.noExpenses))),
            for (final e in list)
              FormWidth(
                maxWidth: 900,
                child: ListTile(
                  leading: Icon(paymentMethodIcon(e.method)),
                  title: Text(
                    e.description,
                    style: e.status == 'cancelled' ? const TextStyle(decoration: TextDecoration.lineThrough) : null,
                  ),
                  subtitle: Text([
                    day.format(e.expenseDate),
                    expenseCategoryLabel(t, catOf[e.categoryId]?.code, catOf[e.categoryId]?.name ?? ''),
                    if (e.status == 'cancelled') '${t.cancelledLabel} : ${e.cancelReason ?? ''}',
                  ].join(' · ')),
                  trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                    Text(s.money(context, e.amountMinor)),
                    PopupMenuButton<String>(
                      onSelected: (a) async {
                        if (a == 'doc' && e.attachmentPath != null) {
                          try {
                            await openLink(await api.documentUrl(e.attachmentPath!));
                          } catch (err) {
                            if (context.mounted) showError(context, err);
                          }
                        } else if (a == 'cancel') {
                          await _cancel(e);
                        }
                      },
                      itemBuilder: (_) => [
                        if (e.attachmentPath != null) PopupMenuItem(value: 'doc', child: Text(t.viewDocument)),
                        if (e.status == 'recorded') PopupMenuItem(value: 'cancel', child: Text(t.cancelExpense)),
                      ],
                    ),
                  ]),
                ),
              ),
          ]),
        );
      },
    );
  }
}

class _ExpenseDialog extends StatefulWidget {
  const _ExpenseDialog({required this.scope, required this.categories, required this.suppliers});
  final BranchContext scope;
  final List<ExpenseCategory> categories;
  final List<Supplier> suppliers;

  @override
  State<_ExpenseDialog> createState() => _ExpenseDialogState();
}

class _ExpenseDialogState extends State<_ExpenseDialog> {
  final _description = TextEditingController();
  final _amount = TextEditingController();
  final _tax = TextEditingController();
  late List<ExpenseCategory> _cats = widget.categories.where((c) => c.active).toList();
  String? _category;
  String? _supplier;
  String _method = 'cash';
  DateTime _date = DateTime.now();
  bool _fromRegister = false;
  List<CashSession> _sessions = const [];
  PickedDocument? _doc;
  final String _clientId = uuidV4();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!widget.scope.can('cash.operate')) return;
      final s = await AppScope.read(context).api!.cash.openSessions(widget.scope.branchId);
      if (mounted) setState(() => _sessions = s);
    });
  }

  @override
  void dispose() {
    for (final c in [_description, _amount, _tax]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _addCategory() async {
    final t = context.t;
    final c = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (dc) => AlertDialog(
        title: Text(t.newCategory),
        content: TextField(controller: c, autofocus: true, maxLength: 80, decoration: InputDecoration(labelText: t.name)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dc), child: Text(t.cancel)),
          FilledButton(onPressed: () => Navigator.pop(dc, c.text.trim()), child: Text(t.save)),
        ],
      ),
    );
    c.dispose();
    if (name == null || name.isEmpty || !mounted) return;
    final api = AppScope.read(context).api!.purchases;
    try {
      await api.addCategory(widget.scope.orgId, name);
      final cats = await api.categories(widget.scope.orgId);
      if (mounted) {
        setState(() {
          _cats = cats.where((x) => x.active).toList();
          _category = cats.where((x) => x.name == name).firstOrNull?.id;
        });
      }
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  Future<void> _save() async {
    final t = context.t;
    final amount = parseQty(_amount.text);
    final tax = _tax.text.trim().isEmpty ? 0.0 : parseQty(_tax.text);
    if (_category == null || _description.text.trim().isEmpty || amount == null || amount <= 0 || tax == null || tax > amount) {
      showInfo(context, t.errorInvalidExpense);
      return;
    }
    final api = AppScope.read(context).api!.purchases;
    try {
      String? path;
      if (_doc != null) {
        path = await api.uploadDocument(widget.scope.orgId, widget.scope.branchId, _clientId, _doc!.extension, _doc!.bytes);
      }
      await api.recordExpense(
        branchId: widget.scope.branchId,
        categoryId: _category!,
        description: _description.text.trim(),
        date: _date,
        amountMinor: widget.scope.toMinor(amount).round(),
        taxMinor: widget.scope.toMinor(tax).round(),
        method: _method,
        supplierId: _supplier,
        cashSessionId: _method == 'cash' && _fromRegister && _sessions.isNotEmpty ? _sessions.first.id : null,
        attachmentPath: path,
        clientId: _clientId,
      );
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final date = DateFormat.yMMMd(Localizations.localeOf(context).toString());
    return AlertDialog(
      title: Text(t.newExpense),
      content: SizedBox(
        width: 480,
        child: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _category,
                  decoration: InputDecoration(labelText: t.category),
                  items: [
                    for (final c in _cats) DropdownMenuItem(value: c.id, child: Text(expenseCategoryLabel(t, c.code, c.name))),
                  ],
                  onChanged: (v) => setState(() => _category = v),
                ),
              ),
              IconButton(tooltip: t.newCategory, onPressed: _addCategory, icon: const Icon(Icons.add)),
            ]),
            TextField(
              controller: _description,
              maxLength: 300,
              decoration: InputDecoration(labelText: t.description, hintText: t.expenseExamples),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.event),
              title: Text(date.format(_date)),
              onTap: () async {
                final d = await showDatePicker(context: context, initialDate: _date, firstDate: DateTime(2020), lastDate: DateTime.now());
                if (d != null) setState(() => _date = d);
              },
            ),
            Row(children: [
              Expanded(
                child: TextField(
                  controller: _amount,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(labelText: t.amountInclTax, suffixText: widget.scope.currency),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _tax,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(labelText: t.includedTaxOptional, suffixText: widget.scope.currency),
                ),
              ),
            ]),
            const SizedBox(height: 12),
            Wrap(spacing: 8, runSpacing: 8, children: [
              for (final m in paymentMethods)
                ChoiceChip(label: Text(paymentMethodLabel(t, m)), selected: _method == m, onSelected: (_) => setState(() => _method = m)),
            ]),
            if (_method == 'cash' && _sessions.isNotEmpty)
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(t.paidFromRegister),
                value: _fromRegister,
                onChanged: (v) => setState(() => _fromRegister = v),
              ),
            if (widget.suppliers.isNotEmpty)
              DropdownButtonFormField<String?>(
                initialValue: _supplier,
                decoration: InputDecoration(labelText: t.supplierOptional),
                items: [
                  DropdownMenuItem(value: null, child: Text(t.noneOption)),
                  for (final sp in widget.suppliers.where((x) => x.active)) DropdownMenuItem(value: sp.id, child: Text(sp.name)),
                ],
                onChanged: (v) => setState(() => _supplier = v),
              ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () async {
                final d = await pickDocument();
                if (d == null || !context.mounted) return;
                if (d.bytes.length > maxDocumentBytes) {
                  showInfo(context, t.fileTooLarge);
                  return;
                }
                setState(() => _doc = d);
              },
              icon: const Icon(Icons.attach_file),
              label: Text(_doc?.name ?? t.attachDocument),
            ),
          ]),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(t.cancel)),
        BusyButton(label: t.save, onPressed: _save),
      ],
    );
  }
}
