import 'package:flutter/material.dart';

import '../../data/cash_api.dart';
import '../../ui/common.dart';
import '../../ui/theme.dart';
import '../service/service_labels.dart';
import 'cash_context.dart';
import 'order_documents.dart';

/// Factures clients : liste, recherche, facturation d'un ticket, réimpression, annulation.
class InvoicesTab extends StatefulWidget {
  const InvoicesTab({super.key, required this.ctx});
  final CashContext ctx;

  @override
  State<InvoicesTab> createState() => _InvoicesTabState();
}

class _InvoicesTabState extends State<InvoicesTab> {
  late DateTimeRange _range = () {
    final n = DateTime.now();
    return DateTimeRange(start: DateTime(n.year, n.month), end: DateTime(n.year, n.month, n.day));
  }();
  String _query = '';
  Key _key = UniqueKey();

  CashContext get ctx => widget.ctx;

  void _reload() => setState(() => _key = UniqueKey());

  Future<void> _invoiceTicket() async {
    final t = context.t;
    final c = TextEditingController();
    final n = await showDialog<int>(
      context: context,
      builder: (d) => AlertDialog(
        title: Text(t.invoiceATicket),
        content: TextField(
          controller: c,
          autofocus: true,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(prefixIcon: const Icon(Icons.receipt_rounded), labelText: t.ticketOrOrderNumber),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(d), child: Text(t.cancel)),
          FilledButton(onPressed: () => Navigator.pop(d, int.tryParse(c.text.trim())), child: Text(t.searchAction)),
        ],
      ),
    );
    c.dispose();
    if (n == null || !mounted) return;
    try {
      final found = (await ctx.cash.findOrders(ctx.scope.branchId, n)).where((o) => o['status'] != 'cancelled').toList();
      if (!mounted) return;
      if (found.isEmpty) return showInfo(context, t.noResults);
      var pick = found.first;
      if (found.length > 1) {
        final chosen = await showDialog<Map<String, dynamic>>(
          context: context,
          builder: (d) => SimpleDialog(
            title: Text(t.chooseOrder),
            children: [
              for (final o in found)
                SimpleDialogOption(
                  onPressed: () => Navigator.pop(d, o),
                  child: Text(
                    [
                      if (o['receipt_number'] != null) t.receiptNumberLabel((o['receipt_number'] as num).toInt()),
                      t.orderNumber((o['number'] as num).toInt()),
                      dayLabel(d, DateTime.parse(o['opened_at'] as String).toLocal()),
                      ctx.scope.money(d, (o['total_minor'] as num).toInt()),
                    ].join(' · '),
                  ),
                ),
            ],
          ),
        );
        if (chosen == null) return;
        pick = chosen;
      }
      final order = await ctx.api.orders.order(pick['id'] as String);
      if (!mounted) return;
      await invoiceFor(context, ctx.scope, order);
      _reload();
    } catch (e) {
      if (mounted) showError(context, e);
    }
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
                label: Text('${dayLabel(context, _range.start)} → ${dayLabel(context, _range.end)}'),
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
              SizedBox(
                width: 240,
                child: TextField(
                  decoration: InputDecoration(
                    isDense: true,
                    prefixIcon: const Icon(Icons.search_rounded, size: 20),
                    hintText: t.searchInvoiceHint,
                  ),
                  onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
                ),
              ),
              if (ctx.scope.can('cash.operate') || ctx.scope.can('orders.write'))
                FilledButton.icon(onPressed: _invoiceTicket, icon: const Icon(Icons.add_rounded), label: Text(t.invoiceATicket)),
            ],
          ),
        ),
        Expanded(
          child: Loader<List<CustomerInvoice>>(
            key: ValueKey('${_range.start}${_range.end}$_key'),
            load: () => ctx.cash.invoices(ctx.scope.branchId, _range.start, _range.end),
            builder: (context, all, reload) {
              final list = all.where((i) {
                if (_query.isEmpty) return true;
                return i.label.toLowerCase().contains(_query) ||
                    i.customerName.toLowerCase().contains(_query) ||
                    (i.customerCompany ?? '').toLowerCase().contains(_query) ||
                    '${i.receiptNumber ?? ''}' == _query;
              }).toList();
              final valid = list.where((i) => !i.cancelled);
              final total = valid.fold<int>(0, (a, i) => a + i.totalMinor);
              final due = valid.fold<int>(0, (a, i) => a + i.dueMinor);
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        CashKpi(label: t.invoicesCount, value: '${valid.length}', icon: Icons.description_rounded),
                        CashKpi(label: t.invoicedTotal, value: m(total), icon: Icons.summarize_rounded, color: RestoColors.primaryDeep),
                        CashKpi(
                          label: t.remainingDue,
                          value: m(due),
                          icon: Icons.pending_actions_rounded,
                          color: due > 0 ? StatusColors.late : StatusColors.free,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: list.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.description_outlined, size: 52, color: theme.colorScheme.outline),
                                  const SizedBox(height: 8),
                                  Text(t.noInvoices, textAlign: TextAlign.center),
                                ],
                              ),
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
                            itemCount: list.length,
                            separatorBuilder: (_, _) => const Divider(height: 1),
                            itemBuilder: (context, i) {
                              final inv = list[i];
                              return ListTile(
                                onTap: () => showInvoiceActions(context, ctx.scope, inv, onChanged: _reload),
                                leading: CircleAvatar(
                                  backgroundColor: (inv.cancelled ? StatusColors.late : RestoColors.primary).withValues(alpha: 0.15),
                                  child: Icon(
                                    Icons.description_rounded,
                                    color: inv.cancelled ? StatusColors.late : RestoColors.primaryDeep,
                                  ),
                                ),
                                title: Text(
                                  '${inv.label} · ${inv.customerCompany ?? inv.customerName}',
                                  style: inv.cancelled ? const TextStyle(decoration: TextDecoration.lineThrough) : null,
                                ),
                                subtitle: Text(
                                  [
                                    dayLabel(context, inv.issuedAt),
                                    if (inv.receiptNumber != null) t.receiptNumberLabel(inv.receiptNumber!),
                                    ctx.staffName(inv.issuedBy),
                                    if (inv.cancelled) t.invoiceCancelledMention,
                                  ].join(' · '),
                                ),
                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(m(inv.totalMinor), style: theme.textTheme.titleSmall),
                                    if (!inv.cancelled)
                                      StatusPill(
                                        label: inv.dueMinor > 0 ? t.notPaid : t.paidShort,
                                        color: inv.dueMinor > 0 ? StatusColors.late : StatusColors.free,
                                        dense: true,
                                      ),
                                  ],
                                ),
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
