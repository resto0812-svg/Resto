import 'package:flutter/material.dart';

import '../../data/cash_api.dart';
import '../../pdf/cash_pdf.dart';
import '../../pdf/ticket_branding.dart';
import '../../pdf/tickets.dart' show printTicket;
import '../../ui/common.dart';
import '../../ui/files.dart';
import '../../ui/theme.dart';
import '../menus/menu_widgets.dart';
import '../service/service_actions.dart' show askReason;
import '../service/service_labels.dart';
import 'cash_context.dart';
import 'cash_labels.dart';
import 'order_documents.dart' show ticketBranding;
import 'payment_screen.dart' show pickOpenSession;

/// Réimpression du ticket d'une commande (ticket légal si elle est clôturée).
Future<void> reprintReceipt(BuildContext context, CashContext ctx, String orderId) async {
  try {
    final t = context.t;
    final order = await ctx.api.orders.order(orderId);
    final r = await Future.wait<dynamic>([ctx.cash.payments(orderId), ticketBranding(ctx.api, t, ctx.scope.branch, order: order)]);
    if (!context.mounted) return;
    final branding = r[1] as TicketBranding;
    final bytes = await receiptPdf(
      CashDocContext(
        t: context.t,
        locale: Localizations.localeOf(context).toString(),
        minorUnit: ctx.scope.minorUnit,
        branch: ctx.scope.branch,
        staff: ctx.staff,
        branding: branding,
      ),
      order,
      r[0] as List<Payment>,
      place: orderPlace(context.t, order, ctx.tableLabels[order.tableId]),
    );
    await printTicket(bytes, 'ticket-${order.receiptNumberOrNull ?? order.number}.pdf', format: branding.pageFormat);
  } catch (e) {
    if (context.mounted) showError(context, e);
  }
}

/// Remboursement d'un paiement (dans une caisse ouverte, motif obligatoire).
Future<bool> refundPayment(BuildContext context, CashContext ctx, Payment p) async {
  final session = await pickOpenSession(context, ctx.scope);
  if (session == null || !context.mounted) return false;
  final ok = await showDialog<bool>(
    context: context,
    builder: (_) => _RefundDialog(ctx: ctx, payment: p, sessionId: session.id),
  );
  return ok == true;
}

class _RefundDialog extends StatefulWidget {
  const _RefundDialog({required this.ctx, required this.payment, required this.sessionId});
  final CashContext ctx;
  final Payment payment;
  final String sessionId;

  @override
  State<_RefundDialog> createState() => _RefundDialogState();
}

class _RefundDialogState extends State<_RefundDialog> {
  final _form = GlobalKey<FormState>();
  late final _amount = TextEditingController(
    text: amountText(widget.payment.refundable, widget.ctx.scope.currency, widget.ctx.scope.minorUnit),
  );
  final _reason = TextEditingController();
  final _clientId = uuidV4();

  @override
  void dispose() {
    _amount.dispose();
    _reason.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    final ctx = widget.ctx;
    final amount = parseAmount(_amount.text, ctx.scope.currency, ctx.scope.minorUnit) ?? 0;
    try {
      await ctx.cash.refund(widget.payment.id, widget.sessionId, amount, _reason.text.trim(), _clientId);
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final ctx = widget.ctx;
    final p = widget.payment;
    return AlertDialog(
      title: Text(t.refundTitle),
      content: SizedBox(
        width: 420,
        child: Form(
          key: _form,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${p.methodName} · ${ctx.scope.money(context, p.amountMinor)} · ${t.refundableAmount(ctx.scope.money(context, p.refundable))}',
              ),
              const SizedBox(height: 12),
              AmountField(controller: _amount, label: t.amount, currency: ctx.scope.currency, minorUnit: ctx.scope.minorUnit, width: 240),
              const SizedBox(height: 12),
              TextFormField(
                controller: _reason,
                maxLength: 500,
                decoration: InputDecoration(labelText: t.reason, hintText: t.refundReasonHint),
                validator: (v) => (v ?? '').trim().length < 3 ? t.errorReasonRequired : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(t.cancel)),
        FilledButton(onPressed: _save, child: Text(t.refundAction)),
      ],
    );
  }
}

/// Transactions : paiements d'une période, filtres, totaux, export, actions.
class TransactionsTab extends StatefulWidget {
  const TransactionsTab({super.key, required this.ctx});
  final CashContext ctx;

  @override
  State<TransactionsTab> createState() => _TransactionsTabState();
}

class _TransactionsTabState extends State<TransactionsTab> {
  late DateTimeRange _range = () {
    final n = DateTime.now();
    final d = DateTime(n.year, n.month, n.day);
    return DateTimeRange(start: d, end: d);
  }();
  String? _methodName;
  String _status = 'all';
  String _query = '';
  Key _key = UniqueKey();

  CashContext get ctx => widget.ctx;

  void _reload() => setState(() => _key = UniqueKey());

  Future<void> _details(Payment p) async {
    final t = context.t;
    await showModalBottomSheet<void>(
      context: context,
      builder: (c) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          children: [
            Text(
              p.receiptNumber != null ? t.receiptNumberLabel(p.receiptNumber!) : t.orderNumber(p.orderNumber ?? 0),
              style: Theme.of(c).textTheme.headlineSmall,
            ),
            const SizedBox(height: 6),
            Text(
              [
                p.methodName,
                ctx.scope.money(c, p.amountMinor),
                if (p.tipMinor > 0) '${t.tipLabel} ${ctx.scope.money(c, p.tipMinor)}',
                if (p.refunded > 0) '${t.refundsLabel} ${ctx.scope.money(c, p.refunded)}',
                ?p.reference,
              ].join(' · '),
            ),
            Text('${dayLabel(c, p.createdAt)} ${hm(c, p.createdAt)} · ${ctx.staffName(p.createdBy)}'),
            if (p.voidReason != null) Text('${t.voided} : ${p.voidReason}'),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                FilledButton.icon(
                  onPressed: () {
                    Navigator.pop(c);
                    reprintReceipt(context, ctx, p.orderId);
                  },
                  icon: const Icon(Icons.print_rounded),
                  label: Text(t.printReceipt),
                ),
                if (p.confirmed && ctx.scope.can('payments.refund') && p.refundable > 0)
                  OutlinedButton.icon(
                    onPressed: () async {
                      Navigator.pop(c);
                      if (await refundPayment(context, ctx, p)) {
                        if (mounted) showInfo(context, t.refundDone);
                        _reload();
                      }
                    },
                    icon: const Icon(Icons.undo_rounded),
                    label: Text(t.refundAction),
                  ),
                if (p.confirmed && p.refunded == 0 && ctx.scope.can('payments.refund'))
                  OutlinedButton.icon(
                    onPressed: () async {
                      Navigator.pop(c);
                      final reason = await askReason(context, t.voidPayment);
                      if (reason == null) return;
                      try {
                        await ctx.cash.voidPayment(p.id, reason);
                        _reload();
                      } catch (e) {
                        if (mounted) showError(context, e);
                      }
                    },
                    icon: const Icon(Icons.block_rounded),
                    label: Text(t.voidPayment),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
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
              ActionChip(
                avatar: const Icon(Icons.date_range_rounded, size: 18),
                label: Text(
                  _range.start == _range.end
                      ? dayLabel(context, _range.start)
                      : '${dayLabel(context, _range.start)} → ${dayLabel(context, _range.end)}',
                ),
                onPressed: () async {
                  final r = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime(2024),
                    lastDate: DateTime.now(),
                    initialDateRange: _range,
                  );
                  if (r != null) setState(() => _range = r);
                },
              ),
              DropdownButton<String?>(
                value: _methodName,
                underline: const SizedBox.shrink(),
                items: [
                  DropdownMenuItem(value: null, child: Text(t.allMethods)),
                  for (final pm in ctx.methods) DropdownMenuItem(value: pm.name, child: Text(pm.name)),
                ],
                onChanged: (v) => setState(() => _methodName = v),
              ),
              for (final (v, label) in [
                ('all', t.allOrders),
                ('confirmed', t.paidShort),
                ('voided', t.voided),
                ('refunded', t.refundsLabel),
              ])
                ChoiceChip(label: Text(label), selected: _status == v, onSelected: (_) => setState(() => _status = v)),
              SizedBox(
                width: 200,
                child: TextField(
                  decoration: InputDecoration(
                    isDense: true,
                    prefixIcon: const Icon(Icons.search_rounded, size: 20),
                    hintText: t.ticketOrOrderNumber,
                  ),
                  onChanged: (v) => setState(() => _query = v.trim()),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Loader<List<Payment>>(
            key: ValueKey('${_range.start}${_range.end}$_key'),
            load: () => ctx.cash.transactions(ctx.scope.branchId, _range.start, _range.end),
            builder: (context, all, reload) {
              final list = all.where((p) {
                if (_methodName != null && p.methodName != _methodName) return false;
                if (_status == 'confirmed' && !p.confirmed) return false;
                if (_status == 'voided' && p.confirmed) return false;
                if (_status == 'refunded' && p.refunded == 0) return false;
                if (_query.isNotEmpty && '${p.receiptNumber ?? ''}' != _query && '${p.orderNumber ?? ''}' != _query) return false;
                return true;
              }).toList();
              final ok = list.where((p) => p.confirmed);
              final total = ok.fold<int>(0, (a, p) => a + p.amountMinor) - ok.fold<int>(0, (a, p) => a + p.refunded);
              final tips = ok.fold<int>(0, (a, p) => a + p.tipMinor);
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        CashKpi(label: t.collectedTotal, value: m(total), icon: Icons.point_of_sale_rounded, color: StatusColors.free),
                        CashKpi(label: t.tipsTotal, value: m(tips), icon: Icons.volunteer_activism_rounded, color: StatusColors.reserved),
                        CashKpi(label: t.paymentsCountShort, value: '${list.length}', icon: Icons.receipt_long_rounded),
                        OutlinedButton.icon(
                          onPressed: () async {
                            final csv = toCsv(
                              [
                                t.dateLabel,
                                t.receiptShort,
                                t.orderShort,
                                t.paymentMethodLabel,
                                t.amount,
                                t.tipLabel,
                                t.refundsLabel,
                                t.statusLabel,
                                t.staffLabel,
                                t.transactionReference,
                              ],
                              [
                                for (final p in list)
                                  [
                                    p.createdAt.toIso8601String(),
                                    p.receiptNumber,
                                    p.orderNumber,
                                    p.methodName,
                                    amountText(p.amountMinor, ctx.scope.currency, ctx.scope.minorUnit),
                                    amountText(p.tipMinor, ctx.scope.currency, ctx.scope.minorUnit),
                                    amountText(p.refunded, ctx.scope.currency, ctx.scope.minorUnit),
                                    p.status,
                                    ctx.staffName(p.createdBy),
                                    p.reference,
                                  ],
                              ],
                            );
                            final downloaded = await exportText('transactions.csv', csv, 'text/csv');
                            if (context.mounted) showInfo(context, downloaded ? t.exportDownloaded : t.exportCopied);
                          },
                          icon: const Icon(Icons.download_rounded),
                          label: Text(t.exportExcel),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: list.isEmpty
                        ? Center(child: Text(t.noEntries))
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
                            itemCount: list.length,
                            separatorBuilder: (_, _) => const Divider(height: 1),
                            itemBuilder: (context, i) {
                              final p = list[i];
                              return ListTile(
                                onTap: () => _details(p),
                                leading: Icon(paymentKindIcon(p.method), color: p.confirmed ? RestoColors.primaryDeep : StatusColors.done),
                                title: Text(
                                  '${p.receiptNumber != null ? t.receiptNumberLabel(p.receiptNumber!) : t.orderNumber(p.orderNumber ?? 0)} · ${p.methodName}',
                                  style: p.confirmed ? null : const TextStyle(decoration: TextDecoration.lineThrough),
                                ),
                                subtitle: Text(
                                  [
                                    '${dayLabel(context, p.createdAt)} ${hm(context, p.createdAt)}',
                                    ctx.staffName(p.createdBy),
                                    if (p.tipMinor > 0) '${t.tipLabel} ${m(p.tipMinor)}',
                                    if (p.refunded > 0) '${t.refundsLabel} ${m(p.refunded)}',
                                  ].join(' · '),
                                ),
                                trailing: Text(m(p.amountMinor), style: theme.textTheme.titleSmall),
                              );
                            },
                          ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
