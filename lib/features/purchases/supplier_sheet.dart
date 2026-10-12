import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';

import '../../app_state.dart';
import '../../data/purchases_api.dart';
import '../../pdf/purchase_pdf.dart';
import '../../ui/branch_scope.dart';
import '../../ui/common.dart';
import '../../ui/kit.dart';
import '../../ui/theme.dart';

/// Fiche d'un fournisseur : coordonnées, conditions de paiement, solde dû,
/// historique (commandes, réceptions, factures) et relevé de compte en PDF.
Future<void> showSupplierSheet(
  BuildContext context, {
  required BranchContext scope,
  required Supplier supplier,
  required VoidCallback onEdit,
  required ValueChanged<SupplierInvoice> onOpenInvoice,
}) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _SupplierSheet(scope: scope, supplier: supplier, onEdit: onEdit, onOpenInvoice: onOpenInvoice),
    );

class _SupplierSheet extends StatelessWidget {
  const _SupplierSheet({required this.scope, required this.supplier, required this.onEdit, required this.onOpenInvoice});
  final BranchContext scope;
  final Supplier supplier;
  final VoidCallback onEdit;
  final ValueChanged<SupplierInvoice> onOpenInvoice;

  Future<void> _statement(BuildContext context, List<SupplierInvoice> invoices) async {
    try {
      final bytes = await supplierStatementPdf(
        PurchaseDocContext(
          t: context.t,
          locale: Localizations.localeOf(context).toString(),
          money: (v) => scope.money(context, v),
          branch: scope.branch,
        ),
        supplier: supplier,
        invoices: invoices,
      );
      await Printing.sharePdf(bytes: bytes, filename: 'releve-${supplier.name.replaceAll(RegExp(r'[^A-Za-z0-9]+'), '-')}.pdf');
    } catch (e) {
      if (context.mounted) showError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final api = AppScope.of(context).api!.purchases;
    final day = DateFormat.yMMMd(Localizations.localeOf(context).toString());
    String money(int v) => scope.money(context, v);
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.85,
      child: FutureBuilder<List<dynamic>>(
        future: Future.wait<dynamic>([api.invoices(scope.branchId), api.purchaseOrders(scope.branchId), api.receipts(scope.branchId)]),
        builder: (context, snap) {
          final invoices = snap.hasData
              ? (snap.data![0] as List<SupplierInvoice>).where((i) => i.supplierId == supplier.id).toList()
              : <SupplierInvoice>[];
          final orders = snap.hasData ? (snap.data![1] as List<PurchaseOrder>).where((o) => o.supplierId == supplier.id).toList() : <PurchaseOrder>[];
          final receipts = snap.hasData ? (snap.data![2] as List<GoodsReceipt>).where((r) => r.supplierId == supplier.id).toList() : <GoodsReceipt>[];
          final due = invoices.where((i) => i.status == 'open').fold<int>(0, (a, i) => a + i.dueMinor);
          final bought = receipts.fold<int>(0, (a, r) => a + r.totalMinor);
          return ListView(padding: const EdgeInsets.fromLTRB(20, 0, 20, 30), children: [
            Row(children: [
              GoldIcon(Icons.local_shipping_outlined, size: 46),
              const SizedBox(width: 12),
              Expanded(child: Text(supplier.name, style: serifTitle(context, size: 26))),
              IconButton(tooltip: t.edit, onPressed: () {
                Navigator.pop(context);
                onEdit();
              }, icon: const Icon(Icons.edit_outlined)),
            ]),
            const SizedBox(height: 6),
            Wrap(spacing: 8, runSpacing: 6, children: [
              for (final (icon, text) in [
                (Icons.person_outline_rounded, supplier.contactName),
                (Icons.phone_outlined, supplier.phone),
                (Icons.mail_outline_rounded, supplier.email),
                (Icons.place_outlined, supplier.address),
              ])
                if (text != null && text.isNotEmpty) Chip(avatar: Icon(icon, size: 16), label: Text(text)),
              if (supplier.paymentTermsDays > 0) Chip(avatar: const Icon(Icons.schedule_rounded, size: 16), label: Text(t.paymentTerms(supplier.paymentTermsDays))),
            ]),
            const SizedBox(height: 14),
            Row(children: [
              Expanded(
                child: SoftCard(
                  padding: const EdgeInsets.all(14),
                  color: due > 0 ? RestoColors.primarySoft : null,
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(t.balanceDue, style: const TextStyle(color: RestoColors.muted, fontSize: 12.5)),
                    Text(money(due), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 20)),
                  ]),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SoftCard(
                  padding: const EdgeInsets.all(14),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(t.totalPurchased, style: const TextStyle(color: RestoColors.muted, fontSize: 12.5)),
                    Text(money(bought), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 20)),
                  ]),
                ),
              ),
            ]),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: snap.hasData ? () => _statement(context, invoices) : null,
              icon: const Icon(Icons.picture_as_pdf_outlined),
              label: Text(t.supplierStatementTitle),
            ),
            if (!snap.hasData) const Padding(padding: EdgeInsets.all(24), child: Center(child: CircularProgressIndicator())),
            if (snap.hasData) ...[
              const SizedBox(height: 16),
              Text(t.invoicesTab, style: Theme.of(context).textTheme.titleMedium),
              if (invoices.isEmpty) Text(t.noEntries, style: const TextStyle(color: RestoColors.muted)),
              for (final i in invoices.take(12))
                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  onTap: () => onOpenInvoice(i),
                  title: Text('${i.number} · ${day.format(i.invoiceDate)}'),
                  subtitle: Text(switch (i.status) {
                    'paid' => t.invoicePaid,
                    'cancelled' => t.invoiceCancelled,
                    _ => t.remaining(money(i.dueMinor)),
                  }),
                  trailing: Text(money(i.totalMinor), style: const TextStyle(fontWeight: FontWeight.w700)),
                ),
              const SizedBox(height: 12),
              Text(t.purchaseOrdersTab, style: Theme.of(context).textTheme.titleMedium),
              if (orders.isEmpty) Text(t.noEntries, style: const TextStyle(color: RestoColors.muted)),
              for (final o in orders.take(8))
                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: Text(t.poNumber(o.number)),
                  trailing: Text(money(o.totalMinor)),
                ),
              const SizedBox(height: 12),
              Text(t.receiptsTab, style: Theme.of(context).textTheme.titleMedium),
              if (receipts.isEmpty) Text(t.noEntries, style: const TextStyle(color: RestoColors.muted)),
              for (final r in receipts.take(8))
                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: Text(day.format(r.receivedAt.toLocal())),
                  subtitle: r.reference == null ? null : Text(r.reference!),
                  trailing: Text(money(r.totalMinor)),
                ),
            ],
          ]);
        },
      ),
    );
  }
}
