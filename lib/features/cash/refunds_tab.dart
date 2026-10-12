import 'package:flutter/material.dart';

import '../../data/cash_api.dart';
import '../../ui/common.dart';
import '../../ui/theme.dart';
import '../service/service_labels.dart';
import 'cash_context.dart';
import 'cash_labels.dart';
import 'transactions_tab.dart' show refundPayment, reprintReceipt;

/// Remboursements : retrouver un ticket, rembourser tout ou partie, historique.
class RefundsTab extends StatefulWidget {
  const RefundsTab({super.key, required this.ctx});
  final CashContext ctx;

  @override
  State<RefundsTab> createState() => _RefundsTabState();
}

class _RefundsTabState extends State<RefundsTab> {
  final _search = TextEditingController();
  List<(Map<String, dynamic>, List<Payment>)>? _found;
  bool _searching = false;
  Key _historyKey = UniqueKey();

  CashContext get ctx => widget.ctx;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _find() async {
    final n = int.tryParse(_search.text.trim());
    if (n == null) return;
    setState(() => _searching = true);
    try {
      final orders = await ctx.cash.findOrders(ctx.scope.branchId, n);
      final payments = await Future.wait([for (final o in orders) ctx.cash.payments(o['id'] as String)]);
      if (mounted) setState(() => _found = [for (var i = 0; i < orders.length; i++) (orders[i], payments[i])]);
    } catch (e) {
      if (mounted) showError(context, e);
    } finally {
      if (mounted) setState(() => _searching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    String m(int v) => ctx.scope.money(context, v);
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 40),
      children: [
        FormWidth(
          maxWidth: 900,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(t.findTicket, style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _search,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(prefixIcon: const Icon(Icons.receipt_rounded), hintText: t.ticketOrOrderNumber),
                      onSubmitted: (_) => _find(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  FilledButton.icon(
                    onPressed: _searching ? null : _find,
                    icon: const Icon(Icons.search_rounded),
                    label: Text(t.searchAction),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (_found != null && _found!.isEmpty) Text(t.noResults),
              for (final (o, payments) in _found ?? const <(Map<String, dynamic>, List<Payment>)>[])
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                [
                                  if (o['receipt_number'] != null) t.receiptNumberLabel((o['receipt_number'] as num).toInt()),
                                  t.orderNumber((o['number'] as num).toInt()),
                                  dayLabel(context, DateTime.parse(o['opened_at'] as String).toLocal()),
                                ].join(' · '),
                                style: theme.textTheme.titleSmall,
                              ),
                            ),
                            Text(m((o['total_minor'] as num).toInt()), style: theme.textTheme.titleMedium),
                            IconButton(
                              tooltip: t.printReceipt,
                              onPressed: () => reprintReceipt(context, ctx, o['id'] as String),
                              icon: const Icon(Icons.print_rounded),
                            ),
                          ],
                        ),
                        for (final p in payments)
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            dense: true,
                            leading: Icon(paymentKindIcon(p.method), color: RestoColors.primaryDeep),
                            title: Text(
                              '${p.methodName} · ${m(p.amountMinor)}',
                              style: p.confirmed ? null : const TextStyle(decoration: TextDecoration.lineThrough),
                            ),
                            subtitle: Text(
                              [
                                hm(context, p.createdAt),
                                if (p.refunded > 0) '${t.refundsLabel} ${m(p.refunded)}',
                                if (!p.confirmed) t.voided,
                              ].join(' · '),
                            ),
                            trailing: p.refundable > 0 && ctx.scope.can('payments.refund')
                                ? OutlinedButton(
                                    onPressed: () async {
                                      if (await refundPayment(context, ctx, p)) {
                                        if (!context.mounted) return;
                                        showInfo(context, t.refundDone);
                                        setState(() => _historyKey = UniqueKey());
                                        _find();
                                      }
                                    },
                                    child: Text(t.refundAction),
                                  )
                                : null,
                          ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 22),
              Text(t.recentRefunds, style: theme.textTheme.titleMedium),
              const SizedBox(height: 6),
              Loader<List<Refund>>(
                key: _historyKey,
                load: () => ctx.cash.recentRefunds(ctx.scope.branchId),
                builder: (context, refunds, _) => refunds.isEmpty
                    ? Text(t.noRefunds, style: theme.textTheme.bodySmall)
                    : Column(
                        children: [
                          for (final r in refunds)
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: const Icon(Icons.undo_rounded, color: StatusColors.late),
                              title: Text(
                                [
                                  if (r.receiptNumber != null)
                                    t.receiptNumberLabel(r.receiptNumber!)
                                  else
                                    t.orderNumber(r.orderNumber ?? 0),
                                  r.reason,
                                ].join(' · '),
                              ),
                              subtitle: Text(
                                '${dayLabel(context, r.createdAt)} ${hm(context, r.createdAt)} · ${ctx.staffName(r.createdBy)}',
                              ),
                              trailing: Text('− ${m(r.amountMinor)}', style: theme.textTheme.titleSmall),
                            ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
