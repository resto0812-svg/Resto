import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../core/money.dart';
import '../data/cash_api.dart';
import '../data/models.dart';
import '../data/order_models.dart';
import '../l10n/app_localizations.dart';
import 'pdf_fonts.dart';
import 'ticket_branding.dart';

/// Documents de caisse : ticket client (rouleau 80 mm), Z / X de caisse
/// (rouleau 80 mm), rapport de période (A4).
class CashDocContext {
  CashDocContext({
    required this.t,
    required this.locale,
    required this.minorUnit,
    required this.branch,
    this.staff = const {},
    this.branding = TicketBranding.none,
  });
  final AppLocalizations t;
  final String locale;
  final int minorUnit;
  final Branch branch;

  /// Utilisateur → nom affiché.
  final Map<String, String> staff;

  /// Logo en filigrane et QR code (tickets clients).
  final TicketBranding branding;

  String money(int minor) => pdfText(Money(minor, branch.currency).format(locale, minorUnit));
  String dateTime(DateTime d) => pdfText(DateFormat.yMd(locale).add_Hm().format(d.toLocal()));
  String name(String? id) => id == null ? '—' : (staff[id] ?? '—');
}

pw.Widget _row(String left, String right, {bool bold = false, double size = 9}) => pw.Row(
  children: [
    pw.Expanded(
      child: pw.Text(
        pdfText(left),
        style: pw.TextStyle(fontSize: size, fontWeight: bold ? pw.FontWeight.bold : null),
      ),
    ),
    pw.Text(
      pdfText(right),
      style: pw.TextStyle(fontSize: size, fontWeight: bold ? pw.FontWeight.bold : null),
    ),
  ],
);

pw.Widget _rule() => pw.Padding(
  padding: const pw.EdgeInsets.symmetric(vertical: 4),
  child: pw.Container(height: 0.6, color: PdfColors.grey600),
);

pw.Widget _center(String s, {double size = 9, bool bold = false}) => pw.Center(
  child: pw.Text(
    pdfText(s),
    textAlign: pw.TextAlign.center,
    style: pw.TextStyle(fontSize: size, fontWeight: bold ? pw.FontWeight.bold : null),
  ),
);

List<pw.Widget> _header(CashDocContext c) {
  final b = c.branch;
  final address = [b.addressLine1, b.city].whereType<String>().where((s) => s.isNotEmpty).join(', ');
  return [
    _center(b.legalName?.isNotEmpty == true ? b.legalName! : b.name, size: 13, bold: true),
    if (b.legalName?.isNotEmpty == true) _center(b.name),
    if (address.isNotEmpty) _center(address, size: 8),
    if (b.phone != null) _center(b.phone!, size: 8),
    if (b.taxIdentifier?.isNotEmpty == true) _center(c.t.receiptTaxId(b.taxIdentifier!), size: 8),
  ];
}

String _rate(double r) => r == r.roundToDouble() ? r.toStringAsFixed(0) : '$r';

/// Ticket client : numéro légal, détail des articles (photo, quantité, prix
/// unitaire), réductions, taxes, paiements, monnaie. Sert aussi d'addition tant
/// que la commande n'est pas soldée (pas encore de n° légal).
Future<Uint8List> receiptPdf(CashDocContext c, Order o, List<Payment> payments, {required String place}) {
  final t = c.t;
  final b = c.branch;
  final ok = payments.where((p) => p.confirmed).toList();
  final title = (c.branding.brandName?.trim().isNotEmpty == true) ? c.branding.brandName!.trim() : b.name;
  final subtitle = c.branding.subtitle?.trim().isNotEmpty == true ? c.branding.subtitle!.trim() : (b.name != title ? b.name : null);
  final cityLine = [b.postalCode, b.city].whereType<String>().where((s) => s.isNotEmpty).join(' ');
  final online = o.source == 'app' || o.source == 'web';
  final methods = {for (final p in ok) p.methodName}.join(', ');
  final taxRate = _rate(o.taxRate);
  final hasTax = o.taxMinor > 0;
  return customerTicketPdf(
    TicketContent(
      title: title,
      subtitle: subtitle,
      address: [
        if (b.addressLine1?.isNotEmpty == true) b.addressLine1!,
        if (b.addressLine2?.isNotEmpty == true) b.addressLine2!,
        if (cityLine.isNotEmpty) cityLine,
      ],
      phone: b.phone?.isNotEmpty == true ? b.phone : null,
      email: b.email?.isNotEmpty == true ? b.email : null,
      legalLines: [
        if (b.legalName?.isNotEmpty == true) b.legalName!,
        if (b.taxIdentifier?.isNotEmpty == true) t.receiptTaxId(b.taxIdentifier!),
      ],
      heading: o.receiptNumberOrNull == null ? t.billTitle : null,
      info: [
        TicketRow(t.branchLabel, b.name),
        TicketRow(t.dateLabel, c.dateTime(o.closedAt ?? DateTime.now())),
        if (o.receiptNumberOrNull != null) TicketRow(t.receiptTicketNo, '${o.receiptNumberOrNull}', TicketRowKind.strong),
        TicketRow(t.receiptOrderNo, '#${o.number}'),
        TicketRow(t.receiptChannel, online ? '${t.sourceApp} · $place' : place),
        if (o.customerName?.isNotEmpty == true) TicketRow(t.customerLabel, o.customerName!),
        if (ok.isNotEmpty) TicketRow(t.cashierLabel, c.name(ok.last.createdBy)),
        if (methods.isNotEmpty) TicketRow(t.paymentMethodLabel, methods),
      ],
      columns: (t.articleLabel, t.receiptQtyShort, t.unitPriceShort, t.total),
      items: [
        for (final l in o.lines.where((l) => !l.cancelled))
          TicketItem(
            l.title,
            c.money(l.lineTotalMinor),
            quantity: l.quantity,
            unitPrice: c.money(l.lineTotalMinor ~/ (l.quantity == 0 ? 1 : l.quantity)),
            options: [for (final opt in l.options) opt.name],
            description: c.branding.items[l.itemId]?.description,
            photo: c.branding.items[l.itemId]?.photo,
          ),
      ],
      extras: [
        for (final a in o.adjustments) TicketRow(a.label, '- ${c.money(a.appliedMinor)}'),
        if (o.deliveryFeeMinor > 0) TicketRow(t.deliveryFee, c.money(o.deliveryFeeMinor)),
        if (hasTax && o.pricesIncludeTax) TicketRow(t.receiptTotalExclTax, c.money(o.totalMinor - o.taxMinor)),
        if (!o.pricesIncludeTax) TicketRow(t.subtotal, c.money(o.subtotalMinor)),
        if (hasTax) TicketRow(t.taxLine(taxRate), c.money(o.taxMinor)),
      ],
      totalLabel: hasTax ? t.receiptTotalInclTax : t.total,
      totalAmount: c.money(o.totalMinor),
      payments: [
        for (final p in ok)
          TicketPayment(
            method: p.method,
            label: p.methodName,
            amount: c.money(p.amountMinor),
            reference: p.reference,
            details: [
              if (p.tipMinor > 0) TicketRow(t.tipLabel, c.money(p.tipMinor)),
              if (p.tenderedMinor != null) TicketRow(t.receiptTendered, c.money(p.tenderedMinor!)),
              if (p.changeMinor > 0) TicketRow(t.receiptChange, c.money(p.changeMinor)),
            ],
          ),
      ],
      paymentNotes: [if (o.dueMinor > 0 && ok.isNotEmpty) TicketRow(t.remainingDue, c.money(o.dueMinor), TicketRowKind.strong)],
      approvedLabel: t.receiptApproved,
      referenceLabel: t.receiptRef('{ref}'),
      footer: b.receiptFooter?.isNotEmpty == true ? b.receiptFooter! : t.thankYou,
      seeYou: c.branding.farewell ?? t.receiptSeeYou(title),
      recycle: t.receiptRecycle,
    ),
    c.branding,
  );
}

/// Z de caisse (session validée) ou X (lecture provisoire d'une session ouverte).
Future<Uint8List> zReportPdf(
  CashDocContext c,
  CashSession s,
  SessionSummary sum, {
  required String register,
  List<CashMovement> movements = const [],
}) async {
  final fonts = await PdfFonts.load();
  final t = c.t;
  final title = s.zNumber != null ? t.zReportTitle(s.zNumber!) : t.xReportTitle;
  final detail = s.countDetail;
  final doc = pw.Document(theme: fonts.theme());
  doc.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.roll80,
      margin: const pw.EdgeInsets.all(10),
      build: (_) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          ..._header(c),
          pw.SizedBox(height: 6),
          _center(title.toUpperCase(), size: 12, bold: true),
          _row(t.registerLabel, register),
          _row(t.openedLabel, '${c.dateTime(s.openedAt)} · ${c.name(s.openedBy)}'),
          if (s.countedAt != null) _row(t.countedLabel, '${c.dateTime(s.countedAt!)} · ${c.name(s.countedBy)}'),
          if (s.validatedAt != null) _row(t.validatedLabel, '${c.dateTime(s.validatedAt!)} · ${c.name(s.validatedBy)}'),
          _rule(),
          pw.Text(pdfText(t.salesByMethod), style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
          for (final m in sum.byMethod) _row('${m.name} (${m.count})', c.money(m.total)),
          _row(t.collectedTotal, c.money(sum.collected), bold: true),
          _row(t.tipsTotal, c.money(sum.tips)),
          if (sum.refunds > 0) _row(t.refundsLabel, c.money(sum.refunds)),
          if (sum.voidedCount > 0) _row(t.voidedPayments, '${sum.voidedCount}'),
          _rule(),
          pw.Text(pdfText(t.cashDrawer), style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
          _row(t.openingFloat, c.money(sum.openingFloat)),
          _row(t.cashIn, c.money(sum.movementsIn)),
          _row(t.cashOut, c.money(sum.movementsOut)),
          for (final mv in movements)
            pw.Text(
              pdfText('   ${mv.kind == 'in' ? '+' : '−'} ${c.money(mv.amountMinor)} · ${mv.reason}'),
              style: const pw.TextStyle(fontSize: 7.5),
            ),
          _row(t.expectedCashLabel, c.money(s.expectedCashMinor ?? sum.expectedCash), bold: true),
          if (s.countedCashMinor != null) ...[
            _row(t.countedAmountLabel, c.money(s.countedCashMinor!), bold: true),
            _row(t.differenceLabel, c.money(s.differenceMinor ?? 0), bold: true),
          ],
          if (detail != null && detail.isNotEmpty) ...[
            _rule(),
            pw.Text(pdfText(t.countDetailTitle), style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
            for (final e in (detail.entries.toList()..sort((a, b) => b.key.compareTo(a.key))))
              _row('${e.value} × ${c.money(e.key)}', c.money(e.key * e.value), size: 8),
          ],
          if ((s.countNote ?? s.validationNote) != null) ...[
            _rule(),
            pw.Text(pdfText([s.countNote, s.validationNote].whereType<String>().join(' · ')), style: const pw.TextStyle(fontSize: 8)),
          ],
          pw.SizedBox(height: 24),
          _row(t.signatureCashier, t.signatureManager, size: 8),
          pw.SizedBox(height: 30),
        ],
      ),
    ),
  );
  return doc.save();
}

/// Rapport de caisse d'une période (A4).
Future<Uint8List> cashPeriodPdf(CashDocContext c, CashReport r, DateTime from, DateTime to) async {
  final fonts = await PdfFonts.load();
  final t = c.t;
  final day = DateFormat.yMMMd(c.locale);
  pw.Widget kpi(String label, String value) => pw.Container(
    width: 120,
    padding: const pw.EdgeInsets.all(8),
    decoration: pw.BoxDecoration(
      border: pw.Border.all(color: PdfColors.grey400),
      borderRadius: pw.BorderRadius.circular(6),
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(pdfText(label), style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
        pw.Text(pdfText(value), style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
      ],
    ),
  );
  pw.Widget table(List<String> head, List<List<String>> rows) => pw.TableHelper.fromTextArray(
    headers: head.map(pdfText).toList(),
    data: [for (final row in rows) row.map(pdfText).toList()],
    headerStyle: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
    cellStyle: const pw.TextStyle(fontSize: 9),
    headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
    cellAlignments: {for (var i = 1; i < head.length; i++) i: pw.Alignment.centerRight},
  );
  final doc = pw.Document(theme: fonts.theme());
  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(32),
      header: (_) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            pdfText(c.branch.legalName?.isNotEmpty == true ? c.branch.legalName! : c.branch.name),
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
          pw.Text(pdfText('${t.cashReportTitle} · ${day.format(from)} – ${day.format(to)}'), style: const pw.TextStyle(fontSize: 10)),
          pw.SizedBox(height: 12),
        ],
      ),
      footer: (ctx) => pw.Align(
        alignment: pw.Alignment.centerRight,
        child: pw.Text('${ctx.pageNumber} / ${ctx.pagesCount}', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
      ),
      build: (_) => [
        pw.Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            kpi(t.salesTotal, c.money(r.salesTotal)),
            kpi(t.collectedTotal, c.money(r.collected)),
            kpi(t.tipsTotal, c.money(r.tips)),
            kpi(t.averageTicket, c.money(r.averageTicket)),
            kpi(t.ordersClosedCount, '${r.ordersClosed}'),
            kpi(t.discountsTotal, c.money(r.discounts)),
            kpi(t.refundsLabel, c.money(r.refunds)),
            kpi(t.feesEstimate, c.money(r.fees)),
          ],
        ),
        pw.SizedBox(height: 16),
        pw.Text(pdfText(t.salesByMethod), style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 6),
        table(
          [t.paymentMethodLabel, t.paymentsCountShort, t.amount, t.tipLabel],
          [
            for (final m in r.byMethod) [m.name, '${m.count}', c.money(m.total), c.money(m.tips)],
          ],
        ),
        pw.SizedBox(height: 16),
        pw.Text(pdfText(t.salesByStaff), style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 6),
        table(
          [t.staffLabel, t.navOrders, t.salesTotal, t.tipLabel],
          [
            for (final s in r.byStaff) [c.name(s.$1), '${s.$2}', c.money(s.$3), c.money(s.$4)],
          ],
        ),
        pw.SizedBox(height: 16),
        pw.Text(pdfText(t.salesByDay), style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 6),
        table(
          [t.dateLabel, t.collectedTotal],
          [
            for (final e in (r.byDay.entries.toList()..sort((a, b) => a.key.compareTo(b.key)))) [day.format(e.key), c.money(e.value)],
          ],
        ),
        pw.SizedBox(height: 16),
        pw.Text(pdfText(t.closingsTab), style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 6),
        table(
          [t.zShort, t.registerLabel, t.openedLabel, t.expectedCashLabel, t.countedAmountLabel, t.differenceLabel],
          [
            for (final s in r.sessions)
              [
                s['z_number'] == null ? '—' : '${s['z_number']}',
                s['register'] as String,
                c.dateTime(DateTime.parse(s['opened_at'] as String)),
                s['expected'] == null ? '—' : c.money((s['expected'] as num).toInt()),
                s['counted'] == null ? '—' : c.money((s['counted'] as num).toInt()),
                s['difference'] == null ? '—' : c.money((s['difference'] as num).toInt()),
              ],
          ],
        ),
      ],
    ),
  );
  return doc.save();
}

/// Facture client (A4) : émetteur, client, articles, totaux, paiements.
Future<Uint8List> invoicePdf(CashDocContext c, CustomerInvoice inv) async {
  final fonts = await PdfFonts.load();
  final t = c.t;
  final b = c.branch;
  final day = DateFormat.yMMMMd(c.locale);
  String m(int v) => pdfText(Money(v, inv.currency).format(c.locale, c.minorUnit));
  const grey = PdfColors.grey700;
  final cityLine = [b.postalCode, b.city].whereType<String>().where((s) => s.isNotEmpty).join(' ');
  final address = [b.addressLine1, b.addressLine2, cityLine].whereType<String>().where((s) => s.isNotEmpty).toList();
  final itemsTotal = inv.lines.fold<int>(0, (a, l) => a + ((l['total'] as num?) ?? 0).toInt());
  final ht = inv.pricesIncludeTax ? inv.totalMinor - inv.taxMinor : inv.subtotalMinor;
  pw.Widget totalRow(String label, String value, {bool bold = false, PdfColor? color}) => pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 2),
    child: pw.Row(
      mainAxisSize: pw.MainAxisSize.min,
      children: [
        pw.SizedBox(
          width: 160,
          child: pw.Text(pdfText(label), style: pw.TextStyle(fontSize: 10, fontWeight: bold ? pw.FontWeight.bold : null)),
        ),
        pw.SizedBox(
          width: 110,
          child: pw.Text(
            value,
            textAlign: pw.TextAlign.right,
            style: pw.TextStyle(fontSize: bold ? 12 : 10, fontWeight: bold ? pw.FontWeight.bold : null, color: color),
          ),
        ),
      ],
    ),
  );
  String lineName(Map<String, dynamic> l) {
    final variant = l['variant'] as String? ?? '';
    final name = variant.isEmpty ? l['name'] as String : '${l['name']} ($variant)';
    final options = [for (final o in (l['options'] as List? ?? const [])) '  + $o'];
    return pdfText([name, ...options].join('\n'));
  }

  final doc = pw.Document(theme: fonts.theme());
  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.fromLTRB(40, 40, 40, 36),
      footer: (ctx) => pw.Column(
        children: [
          if (b.invoiceFooter?.isNotEmpty == true)
            pw.Text(
              pdfText(b.invoiceFooter!),
              textAlign: pw.TextAlign.center,
              style: const pw.TextStyle(fontSize: 8, color: grey),
            ),
          pw.SizedBox(height: 4),
          pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Text(
              '${pdfText(inv.label)} · ${ctx.pageNumber} / ${ctx.pagesCount}',
              style: const pw.TextStyle(fontSize: 8, color: grey),
            ),
          ),
        ],
      ),
      build: (_) => [
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    pdfText(b.legalName?.isNotEmpty == true ? b.legalName! : b.name),
                    style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
                  ),
                  if (b.legalName?.isNotEmpty == true) pw.Text(pdfText(b.name), style: const pw.TextStyle(fontSize: 10)),
                  for (final a in address) pw.Text(pdfText(a), style: const pw.TextStyle(fontSize: 9)),
                  if (b.phone != null) pw.Text(pdfText(b.phone!), style: const pw.TextStyle(fontSize: 9)),
                  if (b.email != null) pw.Text(pdfText(b.email!), style: const pw.TextStyle(fontSize: 9)),
                  if (b.taxIdentifier?.isNotEmpty == true)
                    pw.Text(pdfText(t.receiptTaxId(b.taxIdentifier!)), style: const pw.TextStyle(fontSize: 9)),
                ],
              ),
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text(pdfText(t.invoiceTitle.toUpperCase()), style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
                pw.Text(pdfText(t.invoiceNumberLabel(inv.label)), style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                pw.Text(pdfText(t.invoiceDateLabel(day.format(inv.issuedAt))), style: const pw.TextStyle(fontSize: 9)),
                if (inv.orderNumber != null) pw.Text(pdfText(t.orderNumber(inv.orderNumber!)), style: const pw.TextStyle(fontSize: 9)),
                if (inv.receiptNumber != null)
                  pw.Text(pdfText(t.receiptNumberLabel(inv.receiptNumber!)), style: const pw.TextStyle(fontSize: 9)),
                if (inv.cancelled)
                  pw.Padding(
                    padding: const pw.EdgeInsets.only(top: 6),
                    child: pw.Text(
                      pdfText(t.invoiceCancelledMention),
                      style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.red800),
                    ),
                  ),
              ],
            ),
          ],
        ),
        pw.SizedBox(height: 22),
        pw.Container(
          width: 280,
          padding: const pw.EdgeInsets.all(10),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey500),
            borderRadius: pw.BorderRadius.circular(6),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(pdfText(t.billedTo), style: const pw.TextStyle(fontSize: 8, color: grey)),
              if (inv.customerCompany != null)
                pw.Text(pdfText(inv.customerCompany!), style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
              pw.Text(
                pdfText(inv.customerName),
                style: pw.TextStyle(fontSize: 10, fontWeight: inv.customerCompany == null ? pw.FontWeight.bold : null),
              ),
              if (inv.customerAddress != null) pw.Text(pdfText(inv.customerAddress!), style: const pw.TextStyle(fontSize: 9)),
              if (inv.customerTaxId != null) pw.Text(pdfText(t.receiptTaxId(inv.customerTaxId!)), style: const pw.TextStyle(fontSize: 9)),
              if (inv.customerEmail != null) pw.Text(pdfText(inv.customerEmail!), style: const pw.TextStyle(fontSize: 9)),
            ],
          ),
        ),
        pw.SizedBox(height: 18),
        pw.TableHelper.fromTextArray(
          headers: [t.invoiceDesignation, t.quantity, t.invoiceUnitPrice, t.total].map(pdfText).toList(),
          data: [
            for (final l in inv.lines)
              [lineName(l), '${l['quantity']}', m(((l['unit'] as num?) ?? 0).toInt()), m(((l['total'] as num?) ?? 0).toInt())],
          ],
          headerStyle: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
          cellStyle: const pw.TextStyle(fontSize: 9),
          headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
          columnWidths: {
            0: const pw.FlexColumnWidth(5),
            1: const pw.FlexColumnWidth(1),
            2: const pw.FlexColumnWidth(2),
            3: const pw.FlexColumnWidth(2),
          },
          cellAlignments: {1: pw.Alignment.centerRight, 2: pw.Alignment.centerRight, 3: pw.Alignment.centerRight},
        ),
        pw.SizedBox(height: 12),
        pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              if (inv.adjustments.isNotEmpty || inv.deliveryFeeMinor > 0) totalRow(t.itemsTotal, m(itemsTotal)),
              for (final a in inv.adjustments) totalRow(a['label'] as String, '- ${m(((a['amount'] as num?) ?? 0).toInt())}'),
              if (inv.deliveryFeeMinor > 0) totalRow(t.deliveryFee, m(inv.deliveryFeeMinor)),
              totalRow(t.totalExclTax, m(ht)),
              totalRow(t.taxLine(_rate(inv.taxRate)), m(inv.taxMinor)),
              totalRow(t.totalInclTax, m(inv.totalMinor), bold: true),
              if (inv.paidMinor > 0) totalRow(t.paid, m(inv.paidMinor)),
              totalRow(t.remainingDue, m(inv.dueMinor), bold: true, color: inv.dueMinor > 0 ? PdfColors.red800 : PdfColors.green800),
            ],
          ),
        ),
        if (inv.payments.isNotEmpty) ...[
          pw.SizedBox(height: 16),
          pw.Text(pdfText(t.invoicePayments), style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 4),
          for (final p in inv.payments)
            pw.Text(
              pdfText(
                [
                  DateFormat.yMd(c.locale).add_Hm().format(DateTime.parse(p['at'] as String).toLocal()),
                  p['method'] as String,
                  m(((p['amount'] as num?) ?? 0).toInt()),
                  if (p['reference'] != null) p['reference'] as String,
                ].join(' · '),
              ),
              style: const pw.TextStyle(fontSize: 9),
            ),
        ],
        if (inv.cancelled && inv.cancelReason != null) ...[
          pw.SizedBox(height: 14),
          pw.Text(
            pdfText('${t.invoiceCancelledMention} : ${inv.cancelReason}'),
            style: const pw.TextStyle(fontSize: 9, color: PdfColors.red800),
          ),
        ],
      ],
    ),
  );
  return doc.save();
}
