import 'package:flutter/material.dart';

import '../../app_state.dart';
import '../../data/loyalty_api.dart';
import '../../data/order_models.dart';
import '../../data/orders_api.dart';
import '../../ui/branch_scope.dart';
import '../../ui/common.dart';
import '../menus/menu_widgets.dart';

/// Totaux : articles, réductions, livraison, taxes, total, payé, reste.
class OrderTotals extends StatelessWidget {
  const OrderTotals({super.key, required this.order, required this.scope, required this.run});
  final Order order;
  final BranchContext scope;
  final Future<void> Function(Future<Object?> Function()) run;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    final o = order;
    String m(int v) => scope.money(context, v);
    final itemsTotal = o.activeLines.fold<int>(0, (a, l) => a + l.lineTotalMinor);
    final canRemove = scope.can('orders.void') && o.isOpen;
    Widget row(String label, String value, {bool bold = false, Widget? trailing, Color? color}) {
      final style = (bold ? theme.textTheme.titleMedium : theme.textTheme.bodyMedium)?.copyWith(color: color);
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(children: [
          Expanded(child: Text(label, style: style)),
          Text(value, style: style),
          ?trailing,
        ]),
      );
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      if (o.adjustments.isNotEmpty || o.deliveryFeeMinor > 0) row(t.itemsTotal, m(itemsTotal)),
      for (final a in o.adjustments)
        row(
          a.percent != null ? '${a.label} (−${_pct(a.percent!)} %)' : a.label,
          '− ${m(a.appliedMinor)}',
          color: theme.colorScheme.primary,
          trailing: canRemove
              ? IconButton(
                  visualDensity: VisualDensity.compact,
                  tooltip: t.removeDiscount,
                  icon: const Icon(Icons.close_rounded, size: 18),
                  onPressed: () => run(() => AppScope.read(context).api!.orders.removeAdjustment(a.id)),
                )
              : null,
        ),
      if (o.deliveryFeeMinor > 0) row(t.deliveryFee, m(o.deliveryFeeMinor)),
      if (!o.pricesIncludeTax) ...[
        row(t.subtotal, m(o.subtotalMinor)),
        row(t.taxLine(_pct(o.taxRate)), m(o.taxMinor)),
      ],
      row(t.total, m(o.totalMinor), bold: true),
      if (o.pricesIncludeTax && o.taxMinor > 0)
        Text(t.taxIncluded(_pct(o.taxRate), m(o.taxMinor)), style: theme.textTheme.bodySmall),
      if (o.paidMinor > 0) ...[
        row(t.paid, m(o.paidMinor)),
        row(t.remainingDue, m(o.dueMinor), bold: true),
      ],
    ]);
  }

  static String _pct(double r) => r == r.roundToDouble() ? r.toStringAsFixed(0) : '$r';
}

/// Réduction : promotion, code promo, geste commercial, fidélité.
class DiscountButton extends StatelessWidget {
  const DiscountButton({super.key, required this.order, required this.scope, required this.run});
  final Order order;
  final BranchContext scope;
  final Future<void> Function(Future<Object?> Function()) run;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    if (!scope.can('orders.write')) return const SizedBox.shrink();
    return PopupMenuButton<String>(
      tooltip: t.addDiscount,
      onSelected: (v) => _choose(context, v),
      itemBuilder: (_) => [
        PopupMenuItem(value: 'promo', child: ListTile(leading: const Icon(Icons.local_offer_outlined), title: Text(t.applyPromotion))),
        PopupMenuItem(value: 'code', child: ListTile(leading: const Icon(Icons.confirmation_number_outlined), title: Text(t.promoCode))),
        if (scope.can('orders.void'))
          PopupMenuItem(value: 'manual', child: ListTile(leading: const Icon(Icons.percent_rounded), title: Text(t.manualDiscount))),
        if (order.customerUserId != null)
          PopupMenuItem(value: 'loyalty', child: ListTile(leading: const Icon(Icons.card_giftcard_rounded), title: Text(t.useLoyalty))),
      ],
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.local_offer_outlined, size: 18, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 6),
          Text(t.addDiscount, style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w700)),
        ]),
      ),
    );
  }

  Future<void> _choose(BuildContext context, String v) async {
    final t = context.t;
    final api = AppScope.read(context).api!;
    final orders = api.orders;
    switch (v) {
      case 'promo':
        try {
          final promos = (await api.loyalty.promotions(scope.orgId))
              .where((p) => p.usableNow && p.code == null && (p.branchId == null || p.branchId == scope.branchId))
              .toList();
          if (!context.mounted) return;
          final picked = await showDialog<Promotion>(
            context: context,
            builder: (c) => SimpleDialog(
              title: Text(t.applyPromotion),
              children: [
                if (promos.isEmpty) Padding(padding: const EdgeInsets.all(24), child: Text(t.noActivePromotion)),
                for (final p in promos)
                  SimpleDialogOption(
                    onPressed: () => Navigator.pop(c, p),
                    child: ListTile(
                      title: Text(p.name),
                      subtitle: Text(p.kind == 'percent' ? '−${p.percent} %' : '− ${scope.money(c, p.amountMinor ?? 0)}'),
                    ),
                  ),
              ],
            ),
          );
          if (picked != null) await run(() => orders.applyPromotion(order.id, promotionId: picked.id));
        } catch (e) {
          if (context.mounted) showError(context, e);
        }
      case 'code':
        final code = await _askText(context, t.promoCode, t.promoCodeHint);
        if (code != null) await run(() => orders.applyPromotion(order.id, code: code));
      case 'manual':
        final r = await showDialog<(double?, int?, String)>(
          context: context,
          builder: (_) => _ManualDiscountDialog(currency: order.currency, minorUnit: scope.minorUnit),
        );
        if (r != null) await run(() => orders.manualDiscount(order.id, percent: r.$1, amountMinor: r.$2, reason: r.$3));
      case 'loyalty':
        await run(() => orders.redeemLoyalty(order.id));
    }
  }

  static Future<String?> _askText(BuildContext context, String title, String hint) {
    final c = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (d) => AlertDialog(
        title: Text(title),
        content: TextField(controller: c, autofocus: true, textCapitalization: TextCapitalization.characters, decoration: InputDecoration(hintText: hint)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(d), child: Text(d.t.cancel)),
          FilledButton(onPressed: () => Navigator.pop(d, c.text.trim().isEmpty ? null : c.text.trim()), child: Text(d.t.confirm)),
        ],
      ),
    ).whenComplete(c.dispose);
  }
}

class _ManualDiscountDialog extends StatefulWidget {
  const _ManualDiscountDialog({required this.currency, required this.minorUnit});
  final String currency;
  final int minorUnit;

  @override
  State<_ManualDiscountDialog> createState() => _ManualDiscountDialogState();
}

class _ManualDiscountDialogState extends State<_ManualDiscountDialog> {
  final _form = GlobalKey<FormState>();
  bool _percent = true;
  final _value = TextEditingController();
  final _reason = TextEditingController();

  @override
  void dispose() {
    _value.dispose();
    _reason.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return AlertDialog(
      title: Text(t.manualDiscount),
      content: SizedBox(
        width: 380,
        child: Form(
          key: _form,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            SegmentedButton<bool>(
              segments: [
                ButtonSegment(value: true, label: Text(t.inPercent)),
                ButtonSegment(value: false, label: Text(t.inAmount)),
              ],
              selected: {_percent},
              onSelectionChanged: (s) => setState(() => _percent = s.first),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _value,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(labelText: _percent ? t.percentValue : t.amount, suffixText: _percent ? '%' : widget.currency),
              validator: (v) {
                if (_percent) {
                  final p = double.tryParse((v ?? '').replaceAll(',', '.'));
                  return (p == null || p <= 0 || p > 100) ? t.errorInvalidAmount : null;
                }
                try {
                  final a = parseAmount(v ?? '', widget.currency, widget.minorUnit);
                  return (a == null || a <= 0) ? t.errorInvalidAmount : null;
                } on Object {
                  return t.errorInvalidAmount;
                }
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _reason,
              maxLength: 300,
              decoration: InputDecoration(labelText: t.reason, hintText: t.manualDiscountHint),
              validator: (v) => (v ?? '').trim().length < 3 ? t.errorReasonRequired : null,
            ),
          ]),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(t.cancel)),
        FilledButton(
          onPressed: () {
            if (!_form.currentState!.validate()) return;
            Navigator.pop(context, (
              _percent ? double.parse(_value.text.replaceAll(',', '.')) : null,
              _percent ? null : parseAmount(_value.text, widget.currency, widget.minorUnit),
              _reason.text.trim(),
            ));
          },
          child: Text(t.apply),
        ),
      ],
    );
  }
}
