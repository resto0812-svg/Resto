import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

import '../../app_state.dart';
import '../../data/api.dart';
import '../../data/cash_api.dart';
import '../../data/menu_models.dart';
import '../../data/models.dart';
import '../../data/supabase_setup.dart' show readTicketPrefs;
import '../../l10n/app_localizations.dart';
import '../../data/order_models.dart';
import '../../pdf/cash_pdf.dart';
import '../../pdf/ticket_branding.dart';
import '../../pdf/tickets.dart';
import '../branches/online_tab.dart' show branchPublicUrl;
import '../../ui/branch_scope.dart';
import '../../ui/common.dart';
import '../../ui/image_compress.dart' show ticketThumbnail;
import '../../ui/theme.dart';
import '../service/service_actions.dart' show askReason;

CashDocContext _doc(
  BuildContext context,
  BranchContext scope,
  Map<String, String> staff, [
  TicketBranding branding = TicketBranding.none,
]) => CashDocContext(
  t: context.t,
  locale: Localizations.localeOf(context).toString(),
  minorUnit: scope.minorUnit,
  branch: scope.branch,
  staff: staff,
  branding: branding,
);

/// Identité des tickets clients : nom, slogan et logo de la marque, QR code
/// selon les réglages de l'établissement, rouleau de l'imprimante de cet
/// appareil, description et photo des articles de [order].
Future<TicketBranding> ticketBranding(Api api, AppLocalizations t, Branch b, {Order? order}) async {
  final prefs = await readTicketPrefs();
  final ids = order == null ? const <String>[] : [for (final l in order.lines) ?l.itemId];
  final r = await Future.wait<dynamic>([
    api.brandLogo(b.brandId),
    api.brandName(b.brandId),
    api.brandSlogan(b.brandId),
    api.menu.ticketItems(ids, photos: prefs.$2, thumb: ticketThumbnail),
  ]);
  final custom = b.receiptQrUrl?.isNotEmpty == true;
  final url = !b.receiptQr ? null : (custom ? b.receiptQrUrl! : branchPublicUrl(b.id!));
  final items = r[3] as Map<String, (String?, Uint8List?)>;
  String? own(String? v) => v?.trim().isNotEmpty == true ? v!.trim() : null;
  return TicketBranding(
    logo: r[0] as Uint8List?,
    brandName: own(b.receiptTitle) ?? r[1] as String?,
    subtitle: own(b.receiptSubtitle),
    slogan: own(b.receiptSlogan) ?? r[2] as String?,
    farewell: own(b.receiptFarewell),
    website: own(b.website) ?? (custom ? b.receiptQrUrl!.replaceFirst(RegExp(r'^https?://'), '').replaceFirst(RegExp(r'/$'), '') : null),
    qrUrl: url,
    qrTitle: url == null ? null : (own(b.receiptQrTitle) ?? (custom ? null : t.receiptLoyaltyTitle)),
    qrCaption: url == null ? null : (own(b.receiptQrCaption) ?? (custom ? t.receiptQrCaption : t.receiptLoyaltyCaption)),
    paperMm: prefs.$1,
    items: {for (final e in items.entries) e.key: TicketItemInfo(description: e.value.$1, photo: e.value.$2)},
  );
}

/// Ticket d'essai : vraie présentation (marque, adresse, QR code, rouleau de
/// cet appareil) avec trois articles de la carte, pour régler l'imprimante.
Future<void> printTestTicket(BuildContext context, Api api, BranchContext scope) async {
  final t = context.t;
  final locale = Localizations.localeOf(context).toString();
  try {
    final b = scope.branch;
    final r = await Future.wait<dynamic>([api.menu.load(b.brandId), api.menu.branchState(b.id!)]);
    final menu = r[0] as BrandMenu;
    final state = r[1] as BranchMenuState;
    final sample = <(MenuItem, int)>[];
    for (final i in menu.items.where((i) => i.active)) {
      final price = [for (final v in i.variants.where((v) => v.active)) ?state.prices[(v.id, 'default')]].firstOrNull;
      if (price != null) sample.add((i, price));
      if (sample.length == 3) break;
    }
    final prefs = await readTicketPrefs();
    final details = await api.menu.ticketItems([for (final s in sample) s.$1.id], photos: prefs.$2, thumb: ticketThumbnail);
    final branding = await ticketBranding(api, t, b);
    if (!context.mounted) return;
    final doc = CashDocContext(t: t, locale: locale, minorUnit: scope.minorUnit, branch: b, branding: branding);
    final total = sample.fold<int>(0, (a, s) => a + s.$2);
    final tax = b.taxRate <= 0
        ? 0
        : (b.pricesIncludeTax ? (total - total / (1 + b.taxRate / 100)).round() : (total * b.taxRate / 100).round());
    final grand = b.pricesIncludeTax ? total : total + tax;
    final title = branding.brandName?.trim().isNotEmpty == true ? branding.brandName!.trim() : b.name;
    final city = [b.postalCode, b.city].whereType<String>().where((s) => s.isNotEmpty).join(' ');
    final rate = b.taxRate == b.taxRate.roundToDouble() ? b.taxRate.toStringAsFixed(0) : '${b.taxRate}';
    final bytes = await customerTicketPdf(
      TicketContent(
        title: title,
        subtitle: branding.subtitle ?? (b.name != title ? b.name : null),
        address: [if (b.addressLine1?.isNotEmpty == true) b.addressLine1!, if (city.isNotEmpty) city],
        phone: b.phone?.isNotEmpty == true ? b.phone : null,
        email: b.email?.isNotEmpty == true ? b.email : null,
        heading: t.receiptTestTitle,
        info: [
          TicketRow(t.branchLabel, b.name),
          TicketRow(t.dateLabel, doc.dateTime(DateTime.now())),
          TicketRow(t.receiptOrderNo, '#0000'),
        ],
        columns: (t.articleLabel, t.receiptQtyShort, t.unitPriceShort, t.total),
        items: [
          for (final s in sample)
            TicketItem(
              s.$1.name,
              doc.money(s.$2),
              unitPrice: doc.money(s.$2),
              description: details[s.$1.id]?.$1,
              photo: details[s.$1.id]?.$2,
            ),
        ],
        extras: [
          if (tax > 0 && b.pricesIncludeTax) TicketRow(t.receiptTotalExclTax, doc.money(grand - tax)),
          if (tax > 0 && !b.pricesIncludeTax) TicketRow(t.subtotal, doc.money(total)),
          if (tax > 0) TicketRow(t.taxLine(rate), doc.money(tax)),
        ],
        totalLabel: tax > 0 ? t.receiptTotalInclTax : t.total,
        totalAmount: doc.money(grand),
        footer: b.receiptFooter?.isNotEmpty == true ? b.receiptFooter! : t.thankYou,
        seeYou: branding.farewell ?? t.receiptSeeYou(title),
        recycle: t.receiptRecycle,
      ),
      branding,
    );
    await printTicket(bytes, 'ticket-essai.pdf', format: branding.pageFormat);
  } catch (e) {
    if (context.mounted) showError(context, e);
  }
}

/// Addition (avant paiement) : même présentation que le ticket de caisse, sans n° légal.
Future<void> printBillFor(BuildContext context, BranchContext scope, Order o, String place) =>
    printReceiptFor(context, scope, o, place, fileName: 'addition-${o.number}.pdf');

/// Ticket de caisse (paiements, n° de ticket légal une fois la commande payée).
Future<void> printReceiptFor(BuildContext context, BranchContext scope, Order o, String place, {String? fileName}) async {
  final api = AppScope.read(context).api!;
  final cash = api.cash;
  try {
    final r = await Future.wait<dynamic>([
      cash.payments(o.id),
      cash.staff(scope.orgId),
      ticketBranding(api, context.t, scope.branch, order: o),
    ]);
    if (!context.mounted) return;
    final bytes = await receiptPdf(
      _doc(context, scope, r[1] as Map<String, String>, r[2] as TicketBranding),
      o,
      r[0] as List<Payment>,
      place: place,
    );
    await printTicket(bytes, fileName ?? 'ticket-${o.receiptNumberOrNull ?? o.number}.pdf', format: (r[2] as TicketBranding).pageFormat);
  } catch (e) {
    if (context.mounted) showError(context, e);
  }
}

/// Facture : celle déjà émise pour la commande, sinon saisie du client puis émission.
Future<void> invoiceFor(BuildContext context, BranchContext scope, Order o) async {
  final cash = AppScope.read(context).api!.cash;
  try {
    var inv = await cash.invoiceForOrder(o.id);
    if (!context.mounted) return;
    if (inv == null) {
      final issued = await showDialog<CustomerInvoice>(
        context: context,
        builder: (_) => _InvoiceDialog(order: o),
      );
      if (issued == null || !context.mounted) return;
      inv = issued;
    }
    await showInvoiceActions(context, scope, inv);
  } catch (e) {
    if (context.mounted) showError(context, e);
  }
}

/// Imprimer, partager, annuler une facture.
Future<void> showInvoiceActions(BuildContext context, BranchContext scope, CustomerInvoice inv, {VoidCallback? onChanged}) {
  final cash = AppScope.read(context).api!.cash;
  Future<Uint8List?> bytes(BuildContext c) async {
    final staff = await cash.staff(scope.orgId);
    if (!c.mounted) return null;
    return invoicePdf(_doc(c, scope, staff), inv);
  }

  return showModalBottomSheet<void>(
    context: context,
    builder: (c) {
      final t = c.t;
      final theme = Theme.of(c);
      return SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          children: [
            Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(gradient: RestoColors.brandGradient, borderRadius: BorderRadius.circular(14)),
                  child: const Icon(Icons.description_rounded, color: RestoColors.onPrimary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(t.invoiceNumberLabel(inv.label), style: theme.textTheme.titleLarge),
                      Text([inv.customerCompany, inv.customerName].whereType<String>().join(' · '), style: theme.textTheme.bodySmall),
                    ],
                  ),
                ),
                if (inv.cancelled) StatusPill(label: t.invoiceCancelledMention, color: StatusColors.late),
              ],
            ),
            const SizedBox(height: 8),
            Text('${t.totalInclTax} : ${scope.money(c, inv.totalMinor)} · ${t.remainingDue} : ${scope.money(c, inv.dueMinor)}'),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                FilledButton.icon(
                  onPressed: () async {
                    final b = await bytes(c);
                    if (b == null) return;
                    await Printing.layoutPdf(onLayout: (_) async => b, name: '${inv.label}.pdf', format: PdfPageFormat.a4);
                  },
                  icon: const Icon(Icons.print_rounded),
                  label: Text(t.printInvoice),
                ),
                OutlinedButton.icon(
                  onPressed: () async {
                    final b = await bytes(c);
                    if (b == null) return;
                    await Printing.sharePdf(bytes: b, filename: '${inv.label}.pdf');
                  },
                  icon: const Icon(Icons.ios_share_rounded),
                  label: Text(t.shareInvoice),
                ),
                if (!inv.cancelled && scope.can('cash.close'))
                  OutlinedButton.icon(
                    onPressed: () async {
                      final reason = await askReason(c, t.cancelInvoice, hint: t.cancelInvoiceHint);
                      if (reason == null) return;
                      try {
                        await cash.cancelInvoice(inv.id, reason);
                        if (c.mounted) {
                          Navigator.pop(c);
                          showInfo(context, t.invoiceCancelledDone);
                        }
                        onChanged?.call();
                      } catch (e) {
                        if (c.mounted) showError(c, e);
                      }
                    },
                    icon: const Icon(Icons.block_rounded, color: StatusColors.late),
                    label: Text(t.cancelInvoice),
                  ),
              ],
            ),
            if (inv.customerEmail != null) ...[
              const SizedBox(height: 10),
              Text(t.invoiceEmailHint(inv.customerEmail!), style: theme.textTheme.bodySmall),
            ],
          ],
        ),
      );
    },
  );
}

class _InvoiceDialog extends StatefulWidget {
  const _InvoiceDialog({required this.order});
  final Order order;

  @override
  State<_InvoiceDialog> createState() => _InvoiceDialogState();
}

class _InvoiceDialogState extends State<_InvoiceDialog> {
  final _form = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.order.customerName ?? '');
  final _company = TextEditingController();
  final _tax = TextEditingController();
  late final _address = TextEditingController(text: widget.order.deliveryAddress ?? '');
  final _email = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    for (final c in [_name, _company, _tax, _address, _email]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _issue() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _busy = true);
    String? v(TextEditingController c) => c.text.trim().isEmpty ? null : c.text.trim();
    try {
      final inv = await AppScope.read(context).api!.cash.issueInvoice(
        orderId: widget.order.id,
        customerName: _name.text.trim(),
        company: v(_company),
        taxId: v(_tax),
        address: v(_address),
        email: v(_email),
      );
      if (mounted) Navigator.pop(context, inv);
    } catch (e) {
      if (mounted) showError(context, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return AlertDialog(
      title: Text(t.issueInvoice),
      content: SizedBox(
        width: 480,
        child: Form(
          key: _form,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(t.issueInvoiceHint, style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _name,
                  autofocus: true,
                  maxLength: 160,
                  decoration: InputDecoration(labelText: t.customerName, counterText: ''),
                  validator: (v) => (v ?? '').trim().isEmpty ? t.fieldRequired : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _company,
                  maxLength: 160,
                  decoration: InputDecoration(labelText: t.companyOptional, counterText: ''),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _tax,
                  maxLength: 60,
                  decoration: InputDecoration(labelText: t.customerTaxIdOptional, counterText: ''),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _address,
                  maxLength: 500,
                  maxLines: 2,
                  decoration: InputDecoration(labelText: t.addressOptional, counterText: ''),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _email,
                  maxLength: 254,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(labelText: t.emailOptional, counterText: ''),
                  validator: (v) => (v ?? '').trim().isEmpty || emailPattern.hasMatch(v!.trim()) ? null : t.errorInvalidEmail,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(t.cancel)),
        FilledButton.icon(onPressed: _busy ? null : _issue, icon: const Icon(Icons.description_rounded), label: Text(t.issueInvoiceAction)),
      ],
    );
  }
}

/// Rangée « Documents » d'une commande : addition, ticket de caisse, facture.
class OrderDocuments extends StatelessWidget {
  const OrderDocuments({super.key, required this.scope, required this.order, required this.place});
  final BranchContext scope;
  final Order order;
  final String place;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final o = order;
    if (o.activeLines.isEmpty || o.status == 'cancelled') return const SizedBox.shrink();
    final paidSomething = o.paidMinor > 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(t.documentsTitle, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            if (o.dueMinor > 0)
              OutlinedButton.icon(
                onPressed: () => printBillFor(context, scope, o, place),
                icon: const Icon(Icons.request_quote_rounded),
                label: Text(t.billTitle),
              ),
            if (paidSomething)
              OutlinedButton.icon(
                onPressed: () => printReceiptFor(context, scope, o, place),
                icon: const Icon(Icons.receipt_rounded),
                label: Text(t.receiptDocument),
              ),
            OutlinedButton.icon(
              onPressed: () => invoiceFor(context, scope, o),
              icon: const Icon(Icons.description_rounded),
              label: Text(t.invoiceTitle),
            ),
          ],
        ),
      ],
    );
  }
}
