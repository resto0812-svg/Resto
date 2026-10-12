import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';

import '../../app_state.dart';
import '../../data/cash_api.dart';
import '../../data/models.dart';
import '../../data/purchases_api.dart';
import '../../data/stock_api.dart';
import '../../pdf/purchase_pdf.dart';
import '../../ui/branch_scope.dart';
import '../../ui/common.dart';
import '../../ui/files.dart';
import '../../ui/header_slot.dart';
import '../../ui/kit.dart';
import '../cash/cash_labels.dart';
import '../menus/menu_widgets.dart';
import '../stock/stock_widgets.dart';
import 'purchase_widgets.dart';
import 'purchases_overview.dart';
import 'supplier_sheet.dart';

/// Achats : fournisseurs, bons de commande, réceptions (entrées en stock),
/// factures fournisseurs et leurs paiements.
class PurchasesScreen extends StatelessWidget {
  const PurchasesScreen({super.key, required this.membership});
  final Membership membership;

  @override
  Widget build(BuildContext context) =>
      BranchScope(membership: membership, builder: (context, scope) => _PurchasesBody(scope: scope));
}

class _Shared {
  _Shared(this.suppliers, this.ingredients, this.units, this.locations);
  final List<Supplier> suppliers;
  final List<Ingredient> ingredients;
  final List<Unit> units;
  final List<StockLocation> locations;
  String supplierName(String id) => suppliers.where((s) => s.id == id).firstOrNull?.name ?? '';
}

class _PurchasesBody extends StatefulWidget {
  const _PurchasesBody({required this.scope});
  final BranchContext scope;

  @override
  State<_PurchasesBody> createState() => _PurchasesBodyState();
}

class _PurchasesBodyState extends State<_PurchasesBody> {
  Key _key = UniqueKey();
  BranchContext get s => widget.scope;

  void _reload() => setState(() => _key = UniqueKey());

  Future<_Shared> _load() async {
    final api = AppScope.read(context).api!;
    final r = await Future.wait<dynamic>([
      api.purchases.suppliers(s.orgId),
      api.stock.ingredients(s.orgId),
      api.stock.units(),
      api.stock.locations(s.branchId),
    ]);
    return _Shared(r[0] as List<Supplier>, r[1] as List<Ingredient>, r[2] as List<Unit>, r[3] as List<StockLocation>);
  }

  int _tab = 0;

  @override
  void dispose() {
    HeaderSlot.clear(this);
    super.dispose();
  }

  Future<void> _openInvoice(_Shared d, SupplierInvoice inv) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _InvoiceSheet(scope: s, shared: d, invoice: inv),
    );
    _reload();
  }

  Future<void> _editSupplier([Supplier? sup]) async {
    final values = await showDialog<Map<String, dynamic>>(context: context, builder: (_) => _SupplierDialog(supplier: sup));
    if (values == null || !mounted) return;
    try {
      await AppScope.read(context).api!.purchases.saveSupplier(s.orgId, sup?.id, values);
      _reload();
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  void _openSupplier(_Shared d, Supplier sup) => showSupplierSheet(
        context,
        scope: s,
        supplier: sup,
        onEdit: () => _editSupplier(sup),
        onOpenInvoice: (inv) => _openInvoice(d, inv),
      );

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    // Onglets dans l'en-tête, à côté du titre (comme les autres modules).
    HeaderSlot.show(
      this,
      'purchases',
      PillBar<int>(
        dense: true,
        items: [
          PillItem(0, t.dashTabOverview, icon: Icons.space_dashboard_outlined),
          PillItem(1, t.purchaseOrdersTab, icon: Icons.assignment_outlined),
          PillItem(2, t.receiptsTab, icon: Icons.move_to_inbox_outlined),
          PillItem(3, t.invoicesTab, icon: Icons.description_outlined),
          PillItem(4, t.suppliersTab, icon: Icons.local_shipping_outlined),
        ],
        selected: _tab,
        onSelected: (i) => setState(() => _tab = i),
      ),
    );
    return Loader<_Shared>(
      key: _key,
      load: _load,
      builder: (context, d, _) => IndexedStack(index: _tab, children: [
        PurchasesOverview(
          scope: s,
          suppliers: d.suppliers,
          onOpenInvoice: (inv) => _openInvoice(d, inv),
          onOpenSupplier: (sup) => _openSupplier(d, sup),
        ),
        _OrdersTab(scope: s, shared: d),
        _ReceiptsTab(scope: s, shared: d),
        _InvoicesTab(scope: s, shared: d),
        _SuppliersTab(scope: s, shared: d, onNew: () => _editSupplier(), onOpen: (sup) => _openSupplier(d, sup)),
      ]),
    );
  }
}
// =============================================================================
// Fournisseurs
// =============================================================================
class _SuppliersTab extends StatelessWidget {
  const _SuppliersTab({required this.scope, required this.shared, required this.onNew, required this.onOpen});
  final BranchContext scope;
  final _Shared shared;
  final VoidCallback onNew;
  final ValueChanged<Supplier> onOpen;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return Scaffold(
      floatingActionButton:
          FloatingActionButton.extended(onPressed: onNew, icon: const Icon(Icons.add), label: Text(t.newSupplier)),
      body: shared.suppliers.isEmpty
          ? Center(child: Padding(padding: const EdgeInsets.all(24), child: Text(t.noSuppliersYet, textAlign: TextAlign.center)))
          : ListView(padding: const EdgeInsets.fromLTRB(16, 12, 16, 96), children: [
              for (final sup in shared.suppliers)
                FormWidth(
                  maxWidth: 900,
                  child: ListTile(
                    leading: const Icon(Icons.local_shipping_outlined),
                    title: Text(sup.active ? sup.name : '${sup.name} · ${t.inactive}'),
                    subtitle: Text([?sup.contactName, ?sup.phone, if (sup.paymentTermsDays > 0) t.paymentTerms(sup.paymentTermsDays)].join(' · ')),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => onOpen(sup),
                  ),
                ),
            ]),
    );
  }
}

class _SupplierDialog extends StatefulWidget {
  const _SupplierDialog({this.supplier});
  final Supplier? supplier;

  @override
  State<_SupplierDialog> createState() => _SupplierDialogState();
}

class _SupplierDialogState extends State<_SupplierDialog> {
  late final _name = TextEditingController(text: widget.supplier?.name);
  late final _contact = TextEditingController(text: widget.supplier?.contactName);
  late final _phone = TextEditingController(text: widget.supplier?.phone);
  late final _email = TextEditingController(text: widget.supplier?.email);
  late final _taxId = TextEditingController(text: widget.supplier?.taxId);
  late final _address = TextEditingController(text: widget.supplier?.address);
  late final _terms = TextEditingController(text: '${widget.supplier?.paymentTermsDays ?? 0}');
  late bool _active = widget.supplier?.active ?? true;

  @override
  void dispose() {
    for (final c in [_name, _contact, _phone, _email, _taxId, _address, _terms]) {
      c.dispose();
    }
    super.dispose();
  }

  String? _v(TextEditingController c) => c.text.trim().isEmpty ? null : c.text.trim();

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return AlertDialog(
      title: Text(widget.supplier == null ? t.newSupplier : t.edit),
      content: SizedBox(
        width: 460,
        child: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: _name, autofocus: true, maxLength: 120, decoration: InputDecoration(labelText: t.name)),
            TextField(controller: _contact, maxLength: 120, decoration: InputDecoration(labelText: t.contactName)),
            TextField(controller: _phone, maxLength: 40, keyboardType: TextInputType.phone, decoration: InputDecoration(labelText: t.phone)),
            TextField(controller: _email, maxLength: 254, keyboardType: TextInputType.emailAddress, decoration: InputDecoration(labelText: t.email)),
            TextField(controller: _taxId, maxLength: 60, decoration: InputDecoration(labelText: t.taxId)),
            TextField(controller: _address, maxLength: 300, decoration: InputDecoration(labelText: t.addressLine1)),
            TextField(
              controller: _terms,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: t.paymentTermsLabel, suffixText: t.days),
            ),
            if (widget.supplier != null)
              SwitchListTile(contentPadding: EdgeInsets.zero, title: Text(t.active), value: _active, onChanged: (v) => setState(() => _active = v)),
          ]),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(t.cancel)),
        FilledButton(
          onPressed: () {
            final terms = int.tryParse(_terms.text.trim()) ?? -1;
            if (_name.text.trim().isEmpty || terms < 0 || terms > 365) return;
            Navigator.pop(context, {
              'name': _name.text.trim(),
              'contact_name': _v(_contact),
              'phone': _v(_phone),
              'email': _v(_email),
              'tax_id': _v(_taxId),
              'address': _v(_address),
              'payment_terms_days': terms,
              'active': _active,
            });
          },
          child: Text(t.save),
        ),
      ],
    );
  }
}

// =============================================================================
// Bons de commande
// =============================================================================
class _OrdersTab extends StatefulWidget {
  const _OrdersTab({required this.scope, required this.shared});
  final BranchContext scope;
  final _Shared shared;

  @override
  State<_OrdersTab> createState() => _OrdersTabState();
}

class _OrdersTabState extends State<_OrdersTab> {
  Key _key = UniqueKey();
  void _reload() => setState(() => _key = UniqueKey());

  Future<void> _open({PurchaseOrder? po, bool receive = false}) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => receive
            ? _ReceiptEditor(scope: widget.scope, shared: widget.shared, po: po)
            : _OrderEditor(scope: widget.scope, shared: widget.shared, po: po),
      ),
    );
    if (changed == true) _reload();
  }

  /// Bon de commande en PDF, à envoyer au fournisseur (WhatsApp, e-mail…).
  Future<void> _pdf(PurchaseOrder po) async {
    final t = context.t;
    final sup = widget.shared.suppliers.where((x) => x.id == po.supplierId).firstOrNull;
    if (sup == null) return;
    try {
      final bytes = await purchaseOrderPdf(
        PurchaseDocContext(
          t: t,
          locale: Localizations.localeOf(context).toString(),
          money: (v) => widget.scope.money(context, v),
          branch: widget.scope.branch,
        ),
        po: po,
        supplier: sup,
        itemName: (id) => widget.shared.ingredients.where((i) => i.id == id).firstOrNull?.name ?? '',
        unitName: (code) => unitLabel(t, code),
      );
      await Printing.sharePdf(bytes: bytes, filename: 'bon-de-commande-${po.number}.pdf');
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  Future<void> _status(PurchaseOrder po, String status) async {
    final t = context.t;
    if (status == 'cancelled' && !await confirm(context, t.cancelPoConfirm, action: t.poCancel)) return;
    if (!mounted) return;
    try {
      await AppScope.read(context).api!.purchases.setPurchaseOrderStatus(po.id, status);
      _reload();
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final api = AppScope.of(context).api!.purchases;
    final date = DateFormat.yMMMd(Localizations.localeOf(context).toString());
    return Scaffold(
      floatingActionButton: widget.shared.suppliers.isEmpty
          ? null
          : FloatingActionButton.extended(onPressed: () => _open(), icon: const Icon(Icons.add), label: Text(t.newPurchaseOrder)),
      body: Loader<List<PurchaseOrder>>(
        key: _key,
        load: () => api.purchaseOrders(widget.scope.branchId),
        builder: (context, list, _) => list.isEmpty
            ? Center(child: Padding(padding: const EdgeInsets.all(24), child: Text(widget.shared.suppliers.isEmpty ? t.addSupplierFirst : t.noPurchaseOrders, textAlign: TextAlign.center)))
            : ListView(padding: const EdgeInsets.fromLTRB(16, 12, 16, 96), children: [
                for (final po in list)
                  FormWidth(
                    maxWidth: 900,
                    child: Card(
                      child: ListTile(
                        title: Text('${t.poNumber(po.number)} · ${widget.shared.supplierName(po.supplierId)}'),
                        subtitle: Text([
                          purchaseStatusLabel(context, po.status),
                          widget.scope.money(context, po.totalMinor),
                          if (po.expectedOn != null) t.expectedOn(date.format(po.expectedOn!)),
                        ].join(' · ')),
                        trailing: PopupMenuButton<String>(
                          onSelected: (a) => switch (a) {
                            'pdf' => _pdf(po),
                            'edit' => _open(po: po),
                            'send' => _status(po, 'sent'),
                            'receive' => _open(po: po, receive: true),
                            _ => _status(po, 'cancelled'),
                          },
                          itemBuilder: (_) => [
                            PopupMenuItem(value: 'pdf', child: Text(t.purchaseOrderPdf)),
                            if (po.status == 'draft') PopupMenuItem(value: 'edit', child: Text(t.edit)),
                            if (po.status == 'draft') PopupMenuItem(value: 'send', child: Text(t.poMarkSent)),
                            if (const ['draft', 'sent', 'partially_received'].contains(po.status))
                              PopupMenuItem(value: 'receive', child: Text(t.poReceive)),
                            if (const ['draft', 'sent'].contains(po.status)) PopupMenuItem(value: 'cancel', child: Text(t.poCancel)),
                          ],
                        ),
                      ),
                    ),
                  ),
              ]),
      ),
    );
  }
}

class _OrderEditor extends StatefulWidget {
  const _OrderEditor({required this.scope, required this.shared, this.po});
  final BranchContext scope;
  final _Shared shared;
  final PurchaseOrder? po;

  @override
  State<_OrderEditor> createState() => _OrderEditorState();
}

class _OrderEditorState extends State<_OrderEditor> {
  late String? _supplier = widget.po?.supplierId;
  late DateTime? _expected = widget.po?.expectedOn;
  late final _note = TextEditingController(text: widget.po?.note);
  late final List<PurchaseLineDraft> _lines = widget.po == null
      ? [PurchaseLineDraft()]
      : [
          for (final l in widget.po!.lines)
            PurchaseLineDraft(
              ingredientId: l.ingredientId,
              unit: l.unitCode,
              qty: formatQtyPlain(l.quantity),
              price: widget.scope.toMajorText(l.unitPrice),
            ),
        ];

  @override
  void dispose() {
    _note.dispose();
    for (final l in _lines) {
      l.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    final t = context.t;
    final lines = [for (final l in _lines) l.toJson(widget.scope)];
    if (_supplier == null || lines.isEmpty || lines.any((l) => l == null)) {
      showInfo(context, t.errorInvalidPurchase);
      return;
    }
    try {
      await AppScope.read(context).api!.purchases.savePurchaseOrder(
            id: widget.po?.id,
            branchId: widget.scope.branchId,
            supplierId: _supplier!,
            expectedOn: _expected,
            note: _note.text.trim().isEmpty ? null : _note.text.trim(),
            lines: [for (final l in lines) l!],
          );
      if (!mounted) return;
      showInfo(context, t.saved);
      Navigator.pop(context, true);
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final date = DateFormat.yMMMd(Localizations.localeOf(context).toString());
    return Scaffold(
      appBar: AppBar(title: Text(widget.po == null ? t.newPurchaseOrder : t.poNumber(widget.po!.number))),
      body: ListView(padding: const EdgeInsets.fromLTRB(24, 16, 24, 32), children: [
        FormWidth(
          maxWidth: 860,
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            SearchSelect(
              label: t.supplier,
              value: _supplier,
              entries: [for (final sp in widget.shared.suppliers.where((x) => x.active || x.id == _supplier)) (sp.id, sp.name)],
              onChanged: (v) => setState(() => _supplier = v),
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.event),
              title: Text(_expected == null ? t.expectedDateOptional : t.expectedOn(date.format(_expected!))),
              onTap: () async {
                final d = await showDatePicker(
                  context: context,
                  initialDate: _expected ?? DateTime.now(),
                  firstDate: DateTime.now().subtract(const Duration(days: 365)),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (d != null) setState(() => _expected = d);
              },
            ),
            const SizedBox(height: 8),
            PurchaseLinesEditor(lines: _lines, ingredients: widget.shared.ingredients, units: widget.shared.units, scope: widget.scope),
            TextField(controller: _note, maxLength: 500, decoration: InputDecoration(labelText: t.descriptionOptional)),
            const SizedBox(height: 16),
            BusyButton(label: t.save, onPressed: _save),
          ]),
        ),
      ]),
    );
  }
}

String formatQtyPlain(double q) => q == q.roundToDouble() ? q.toStringAsFixed(0) : '$q';

// =============================================================================
// Réceptions
// =============================================================================
class _ReceiptsTab extends StatefulWidget {
  const _ReceiptsTab({required this.scope, required this.shared});
  final BranchContext scope;
  final _Shared shared;

  @override
  State<_ReceiptsTab> createState() => _ReceiptsTabState();
}

class _ReceiptsTabState extends State<_ReceiptsTab> {
  Key _key = UniqueKey();

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final api = AppScope.of(context).api!.purchases;
    final date = DateFormat.yMMMd(Localizations.localeOf(context).toString()).add_Hm();
    return Scaffold(
      floatingActionButton: widget.shared.suppliers.isEmpty
          ? null
          : FloatingActionButton.extended(
              onPressed: () async {
                final changed = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(builder: (_) => _ReceiptEditor(scope: widget.scope, shared: widget.shared)),
                );
                if (changed == true) setState(() => _key = UniqueKey());
              },
              icon: const Icon(Icons.add),
              label: Text(t.newReceipt),
            ),
      body: Loader<List<GoodsReceipt>>(
        key: _key,
        load: () => api.receipts(widget.scope.branchId),
        builder: (context, list, _) => list.isEmpty
            ? Center(child: Padding(padding: const EdgeInsets.all(24), child: Text(t.receiptsIntro, textAlign: TextAlign.center)))
            : ListView(padding: const EdgeInsets.fromLTRB(16, 12, 16, 96), children: [
                for (final r in list)
                  FormWidth(
                    maxWidth: 900,
                    child: ListTile(
                      leading: const Icon(Icons.inventory),
                      title: Text('${widget.shared.supplierName(r.supplierId)}${r.reference == null ? '' : ' · ${r.reference}'}'),
                      subtitle: Text(date.format(r.receivedAt.toLocal())),
                      trailing: Text(widget.scope.money(context, r.totalMinor)),
                    ),
                  ),
              ]),
      ),
    );
  }
}

class _ReceiptEditor extends StatefulWidget {
  const _ReceiptEditor({required this.scope, required this.shared, this.po});
  final BranchContext scope;
  final _Shared shared;
  final PurchaseOrder? po;

  @override
  State<_ReceiptEditor> createState() => _ReceiptEditorState();
}

class _ReceiptEditorState extends State<_ReceiptEditor> {
  late String? _supplier = widget.po?.supplierId;
  late String? _location = widget.shared.locations.where((l) => l.active).firstOrNull?.id;
  final _reference = TextEditingController();
  final String _clientId = uuidV4();
  // Bon de commande : le reste à recevoir est proposé (modifiable).
  late final List<PurchaseLineDraft> _lines = widget.po == null
      ? [PurchaseLineDraft()]
      : [
          for (final l in widget.po!.lines.where((l) => l.receivedQuantity < l.quantity))
            PurchaseLineDraft(
              ingredientId: l.ingredientId,
              unit: l.unitCode,
              qty: formatQtyPlain(l.quantity - l.receivedQuantity),
              price: widget.scope.toMajorText(l.unitPrice),
              poLineId: l.id,
            ),
        ];

  @override
  void dispose() {
    _reference.dispose();
    for (final l in _lines) {
      l.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    final t = context.t;
    final lines = [for (final l in _lines) l.toJson(widget.scope)];
    if (_supplier == null || _location == null || lines.isEmpty || lines.any((l) => l == null)) {
      showInfo(context, t.errorInvalidPurchase);
      return;
    }
    try {
      await AppScope.read(context).api!.purchases.recordReceipt(
            branchId: widget.scope.branchId,
            locationId: _location!,
            supplierId: _supplier!,
            poId: widget.po?.id,
            reference: _reference.text.trim().isEmpty ? null : _reference.text.trim(),
            lines: [for (final l in lines) l!],
            clientId: _clientId,
          );
      if (!mounted) return;
      showInfo(context, t.receiptRecorded);
      Navigator.pop(context, true);
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return Scaffold(
      appBar: AppBar(title: Text(widget.po == null ? t.newReceipt : t.receiveOrder(widget.po!.number))),
      body: ListView(padding: const EdgeInsets.fromLTRB(24, 16, 24, 32), children: [
        FormWidth(
          maxWidth: 860,
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text(t.receiptHint, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 12),
            SearchSelect(
              label: t.supplier,
              value: _supplier,
              enabled: widget.po == null,
              entries: [for (final sp in widget.shared.suppliers) (sp.id, sp.name)],
              onChanged: (v) => setState(() => _supplier = v),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _location,
              decoration: InputDecoration(labelText: t.toLocation),
              items: [for (final l in widget.shared.locations.where((l) => l.active)) DropdownMenuItem(value: l.id, child: Text(l.name))],
              onChanged: (v) => setState(() => _location = v),
            ),
            TextField(controller: _reference, maxLength: 80, decoration: InputDecoration(labelText: t.deliveryNoteNumber)),
            const SizedBox(height: 8),
            PurchaseLinesEditor(lines: _lines, ingredients: widget.shared.ingredients, units: widget.shared.units, scope: widget.scope),
            const SizedBox(height: 16),
            BusyButton(label: t.recordReceipt, onPressed: _save),
          ]),
        ),
      ]),
    );
  }
}

// =============================================================================
// Factures fournisseurs
// =============================================================================
class _InvoicesTab extends StatefulWidget {
  const _InvoicesTab({required this.scope, required this.shared});
  final BranchContext scope;
  final _Shared shared;

  @override
  State<_InvoicesTab> createState() => _InvoicesTabState();
}

class _InvoicesTabState extends State<_InvoicesTab> {
  Key _key = UniqueKey();
  void _reload() => setState(() => _key = UniqueKey());

  Future<void> _new() async {
    final ok = await showDialog<bool>(context: context, builder: (_) => _InvoiceDialog(scope: widget.scope, shared: widget.shared));
    if (ok == true) _reload();
  }

  Future<void> _details(SupplierInvoice inv) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _InvoiceSheet(scope: widget.scope, shared: widget.shared, invoice: inv),
    );
    _reload();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final api = AppScope.of(context).api!.purchases;
    final date = DateFormat.yMMMd(Localizations.localeOf(context).toString());
    final today = DateUtils.dateOnly(DateTime.now());
    return Scaffold(
      floatingActionButton: widget.shared.suppliers.isEmpty
          ? null
          : FloatingActionButton.extended(onPressed: _new, icon: const Icon(Icons.add), label: Text(t.newInvoice)),
      body: Loader<List<SupplierInvoice>>(
        key: _key,
        load: () => api.invoices(widget.scope.branchId),
        builder: (context, list, _) {
          final debt = list.where((i) => i.status == 'open').fold<int>(0, (a, i) => a + i.dueMinor);
          if (list.isEmpty) {
            return Center(child: Padding(padding: const EdgeInsets.all(24), child: Text(widget.shared.suppliers.isEmpty ? t.addSupplierFirst : t.invoicesIntro, textAlign: TextAlign.center)));
          }
          return ListView(padding: const EdgeInsets.fromLTRB(16, 12, 16, 96), children: [
            FormWidth(maxWidth: 900, child: Text(t.supplierDebt(widget.scope.money(context, debt)), style: Theme.of(context).textTheme.titleMedium)),
            for (final inv in list)
              FormWidth(
                maxWidth: 900,
                child: Card(
                  child: ListTile(
                    leading: Icon(
                      inv.status == 'paid' ? Icons.check_circle_outline : (inv.status == 'cancelled' ? Icons.block : Icons.description_outlined),
                      color: inv.status == 'open' && inv.dueDate != null && inv.dueDate!.isBefore(today)
                          ? Theme.of(context).colorScheme.error
                          : null,
                    ),
                    title: Text('${widget.shared.supplierName(inv.supplierId)} · ${inv.number}'),
                    subtitle: Text([
                      date.format(inv.invoiceDate),
                      if (inv.status == 'open' && inv.dueDate != null) t.dueOn(date.format(inv.dueDate!)),
                      switch (inv.status) { 'paid' => t.invoicePaid, 'cancelled' => t.invoiceCancelled, _ => t.remaining(widget.scope.money(context, inv.dueMinor)) },
                    ].join(' · ')),
                    trailing: Text(widget.scope.money(context, inv.totalMinor)),
                    onTap: () => _details(inv),
                  ),
                ),
              ),
          ]);
        },
      ),
    );
  }
}

class _InvoiceDialog extends StatefulWidget {
  const _InvoiceDialog({required this.scope, required this.shared});
  final BranchContext scope;
  final _Shared shared;

  @override
  State<_InvoiceDialog> createState() => _InvoiceDialogState();
}

class _InvoiceDialogState extends State<_InvoiceDialog> {
  String? _supplier;
  final _number = TextEditingController();
  final _subtotal = TextEditingController();
  final _tax = TextEditingController();
  DateTime _date = DateTime.now();
  DateTime? _due;
  final Set<String> _receipts = {};
  List<GoodsReceipt> _available = const [];
  PickedDocument? _doc;
  final String _clientId = uuidV4();

  @override
  void dispose() {
    for (final c in [_number, _subtotal, _tax]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _loadReceipts() async {
    if (_supplier == null) return;
    final all = await AppScope.read(context).api!.purchases.receipts(widget.scope.branchId);
    if (mounted) setState(() => _available = all.where((r) => r.supplierId == _supplier).toList());
  }

  Future<void> _save() async {
    final t = context.t;
    final sub = parseQty(_subtotal.text);
    final tax = _tax.text.trim().isEmpty ? 0.0 : parseQty(_tax.text);
    if (_supplier == null || _number.text.trim().isEmpty || sub == null || tax == null) {
      showInfo(context, t.errorInvalidPurchase);
      return;
    }
    final api = AppScope.read(context).api!.purchases;
    try {
      String? path;
      if (_doc != null) {
        path = await api.uploadDocument(widget.scope.orgId, widget.scope.branchId, _clientId, _doc!.extension, _doc!.bytes);
      }
      await api.recordInvoice(
        branchId: widget.scope.branchId,
        supplierId: _supplier!,
        number: _number.text.trim(),
        date: _date,
        dueDate: _due,
        subtotalMinor: widget.scope.toMinor(sub).round(),
        taxMinor: widget.scope.toMinor(tax).round(),
        receiptIds: _receipts.toList(),
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
      title: Text(t.newInvoice),
      content: SizedBox(
        width: 480,
        child: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            SearchSelect(
              label: t.supplier,
              value: _supplier,
              entries: [for (final sp in widget.shared.suppliers.where((x) => x.active)) (sp.id, sp.name)],
              onChanged: (v) {
                setState(() {
                  _supplier = v;
                  _receipts.clear();
                });
                _loadReceipts();
              },
            ),
            TextField(controller: _number, maxLength: 60, decoration: InputDecoration(labelText: t.invoiceNumber)),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.event),
              title: Text(t.invoiceDateValue(date.format(_date))),
              onTap: () async {
                final d = await showDatePicker(context: context, initialDate: _date, firstDate: DateTime(2020), lastDate: DateTime.now());
                if (d != null) setState(() => _date = d);
              },
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.event_available),
              title: Text(_due == null ? t.dueDateOptional : t.dueOn(date.format(_due!))),
              onTap: () async {
                final d = await showDatePicker(context: context, initialDate: _due ?? _date, firstDate: _date, lastDate: DateTime(2100));
                if (d != null) setState(() => _due = d);
              },
            ),
            Row(children: [
              Expanded(
                child: TextField(
                  controller: _subtotal,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(labelText: t.amountExclTax, suffixText: widget.scope.currency),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _tax,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(labelText: t.taxAmount, suffixText: widget.scope.currency),
                ),
              ),
            ]),
            if (_available.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(t.linkedReceipts, style: Theme.of(context).textTheme.titleSmall),
              for (final r in _available)
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  value: _receipts.contains(r.id),
                  title: Text('${date.format(r.receivedAt.toLocal())}${r.reference == null ? '' : ' · ${r.reference}'}'),
                  subtitle: Text(widget.scope.money(context, r.totalMinor)),
                  onChanged: (v) => setState(() => v == true ? _receipts.add(r.id) : _receipts.remove(r.id)),
                ),
            ],
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

class _InvoiceSheet extends StatefulWidget {
  const _InvoiceSheet({required this.scope, required this.shared, required this.invoice});
  final BranchContext scope;
  final _Shared shared;
  final SupplierInvoice invoice;

  @override
  State<_InvoiceSheet> createState() => _InvoiceSheetState();
}

class _InvoiceSheetState extends State<_InvoiceSheet> {
  late SupplierInvoice inv = widget.invoice;

  Future<void> _refresh() async {
    final list = await AppScope.read(context).api!.purchases.invoices(widget.scope.branchId);
    if (mounted) setState(() => inv = list.firstWhere((x) => x.id == inv.id));
  }

  Future<String?> _reason(String title) async {
    final c = TextEditingController();
    final r = await showDialog<String>(
      context: context,
      builder: (dc) => AlertDialog(
        title: Text(title),
        content: TextField(controller: c, autofocus: true, maxLength: 500, decoration: InputDecoration(labelText: dc.t.reason)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dc), child: Text(dc.t.cancel)),
          FilledButton(
            onPressed: () {
              if (c.text.trim().length >= 3) Navigator.pop(dc, c.text.trim());
            },
            child: Text(dc.t.confirm),
          ),
        ],
      ),
    );
    c.dispose();
    return r;
  }

  Future<void> _pay() async {
    final ok = await showDialog<bool>(context: context, builder: (_) => _SupplierPaymentDialog(scope: widget.scope, invoice: inv));
    if (ok == true) await _refresh();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final s = widget.scope;
    final date = DateFormat.yMMMd(Localizations.localeOf(context).toString());
    final api = AppScope.of(context).api!.purchases;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(24, 16, 24, 24 + MediaQuery.viewInsetsOf(context).bottom),
        child: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text('${widget.shared.supplierName(inv.supplierId)} · ${inv.number}', style: Theme.of(context).textTheme.titleLarge),
            Text(t.invoiceDateValue(date.format(inv.invoiceDate))),
            const SizedBox(height: 12),
            Text(t.totalAmount(s.money(context, inv.totalMinor))),
            Text(t.paid),
            Text(s.money(context, inv.paidMinor), style: Theme.of(context).textTheme.titleMedium),
            if (inv.status == 'open') Text(t.remaining(s.money(context, inv.dueMinor)), style: Theme.of(context).textTheme.titleMedium),
            const Divider(),
            for (final p in inv.payments)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(paymentMethodIcon(p.method)),
                title: Text('${paymentMethodLabel(t, p.method)} · ${date.format(p.paidOn)}${p.status == 'voided' ? ' · ${t.voided}' : ''}'),
                trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text(s.money(context, p.amountMinor)),
                  if (p.status == 'confirmed')
                    IconButton(
                      tooltip: t.voidPayment,
                      icon: const Icon(Icons.undo),
                      onPressed: () async {
                        final r = await _reason(t.voidPayment);
                        if (r == null || !context.mounted) return;
                        try {
                          await api.voidSupplierPayment(p.id, r);
                          await _refresh();
                        } catch (e) {
                          if (context.mounted) showError(context, e);
                        }
                      },
                    ),
                ]),
              ),
            const SizedBox(height: 12),
            Wrap(spacing: 8, runSpacing: 8, children: [
              if (inv.status == 'open') FilledButton.icon(onPressed: _pay, icon: const Icon(Icons.payments_outlined), label: Text(t.payInvoice)),
              if (inv.attachmentPath != null)
                OutlinedButton.icon(
                  onPressed: () async {
                    try {
                      await openLink(await api.documentUrl(inv.attachmentPath!));
                    } catch (e) {
                      if (context.mounted) showError(context, e);
                    }
                  },
                  icon: const Icon(Icons.visibility_outlined),
                  label: Text(t.viewDocument),
                ),
              if (inv.status == 'open' && inv.paidMinor == 0)
                TextButton(
                  onPressed: () async {
                    final r = await _reason(t.cancelInvoice);
                    if (r == null || !context.mounted) return;
                    try {
                      await api.cancelInvoice(inv.id, r);
                      if (context.mounted) Navigator.pop(context);
                    } catch (e) {
                      if (context.mounted) showError(context, e);
                    }
                  },
                  child: Text(t.cancelInvoice),
                ),
            ]),
          ]),
        ),
      ),
    );
  }
}

class _SupplierPaymentDialog extends StatefulWidget {
  const _SupplierPaymentDialog({required this.scope, required this.invoice});
  final BranchContext scope;
  final SupplierInvoice invoice;

  @override
  State<_SupplierPaymentDialog> createState() => _SupplierPaymentDialogState();
}

class _SupplierPaymentDialogState extends State<_SupplierPaymentDialog> {
  late final _amount = TextEditingController(text: widget.scope.toMajorText(widget.invoice.dueMinor.toDouble()));
  final _reference = TextEditingController();
  String _method = 'transfer';
  bool _fromRegister = false;
  List<CashSession> _sessions = const [];
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
    _amount.dispose();
    _reference.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final t = context.t;
    final v = parseQty(_amount.text);
    if (v == null || v <= 0) {
      showInfo(context, t.errorInvalidAmount);
      return;
    }
    try {
      await AppScope.read(context).api!.purchases.payInvoice(
            widget.invoice.id,
            widget.scope.toMinor(v).round(),
            _method,
            DateTime.now(),
            _reference.text.trim().isEmpty ? null : _reference.text.trim(),
            _method == 'cash' && _fromRegister && _sessions.isNotEmpty ? _sessions.first.id : null,
            _clientId,
          );
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return AlertDialog(
      title: Text(t.payInvoice),
      content: SizedBox(
        width: 420,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final m in paymentMethods)
              ChoiceChip(label: Text(paymentMethodLabel(t, m)), selected: _method == m, onSelected: (_) => setState(() => _method = m)),
          ]),
          TextField(
            controller: _amount,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(labelText: t.amount, suffixText: widget.scope.currency),
          ),
          TextField(controller: _reference, maxLength: 120, decoration: InputDecoration(labelText: t.transactionReference)),
          if (_method == 'cash' && _sessions.isNotEmpty)
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(t.paidFromRegister),
              value: _fromRegister,
              onChanged: (v) => setState(() => _fromRegister = v),
            ),
        ]),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(t.cancel)),
        BusyButton(label: t.confirm, onPressed: _save),
      ],
    );
  }
}
