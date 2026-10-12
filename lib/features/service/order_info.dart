import 'package:flutter/material.dart';

import '../../app_state.dart';
import '../../data/order_models.dart';
import '../../data/orders_api.dart';
import '../../ui/branch_scope.dart';
import '../../ui/common.dart';
import '../../ui/theme.dart';
import '../menus/menu_widgets.dart';
import 'service_labels.dart';

/// En-tête de la commande : où, qui, comment, quand.
class OrderInfoHeader extends StatelessWidget {
  const OrderInfoHeader({super.key, required this.order, required this.scope, required this.tableLabel, this.onEdit});
  final Order order;
  final BranchContext scope;
  final String? tableLabel;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    final o = order;
    final stage = o.stage;
    final rows = <(IconData, String)>[
      (sourceIcon(o.source), '${sourceLabel(t, o.source)} · ${t.openedAt(hm(context, o.openedAt))}'),
      if (o.guests != null) (Icons.groups_2_outlined, t.guestsCount(o.guests!)),
      if (o.customerName != null) (Icons.person_outline_rounded, o.customerName!),
      if (o.contactPhone != null) (Icons.phone_outlined, o.contactPhone!),
      if (o.deliveryAddress != null) (Icons.place_outlined, o.deliveryAddress!),
      if (o.deliveryInstructions != null) (Icons.info_outline_rounded, o.deliveryInstructions!),
      if (o.scheduledFor != null) (Icons.schedule_rounded, t.forTime(hm(context, o.scheduledFor!))),
      if (o.promisedAt != null) (Icons.timer_outlined, t.promisedFor(hm(context, o.promisedAt!))),
      if (o.reservationId != null) (Icons.event_available_rounded, t.fromReservation),
      if (o.note != null) (Icons.sticky_note_2_outlined, o.note!),
    ];
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 6, 12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(channelIcon(o.channel), color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Expanded(child: Text(orderPlace(t, o, tableLabel), style: theme.textTheme.titleLarge)),
            if (onEdit != null)
              IconButton(tooltip: t.editOrderDetails, onPressed: onEdit, icon: const Icon(Icons.edit_outlined)),
          ]),
          const SizedBox(height: 4),
          StatusPill(label: stageLabel(t, stage, o.channel), color: stageColor(stage), icon: stageIcon(stage)),
          const SizedBox(height: 8),
          for (final (icon, text) in rows)
            Padding(
              padding: const EdgeInsets.only(bottom: 3, right: 8),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Icon(icon, size: 16, color: theme.colorScheme.onSurfaceVariant),
                const SizedBox(width: 6),
                Expanded(child: Text(text, style: theme.textTheme.bodyMedium)),
              ]),
            ),
        ]),
      ),
    );
  }
}

/// Modification des informations de la commande.
class OrderDetailsDialog extends StatefulWidget {
  const OrderDetailsDialog({super.key, required this.order, required this.scope});
  final Order order;
  final BranchContext scope;

  @override
  State<OrderDetailsDialog> createState() => _OrderDetailsDialogState();
}

class _OrderDetailsDialogState extends State<OrderDetailsDialog> {
  final _form = GlobalKey<FormState>();
  late final o = widget.order;
  late final _name = TextEditingController(text: o.customerName ?? '');
  late final _phone = TextEditingController(text: o.contactPhone ?? '');
  late final _address = TextEditingController(text: o.deliveryAddress ?? '');
  late final _instructions = TextEditingController(text: o.deliveryInstructions ?? '');
  late final _note = TextEditingController(text: o.note ?? '');
  late final _fee = TextEditingController(text: amountText(o.deliveryFeeMinor, o.currency, widget.scope.minorUnit));
  late int? _guests = o.guests;
  late DateTime? _scheduled = o.scheduledFor?.toLocal();

  @override
  void dispose() {
    for (final c in [_name, _phone, _address, _instructions, _note, _fee]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    String? v(TextEditingController c) => c.text.trim().isEmpty ? null : c.text.trim();
    try {
      await AppScope.read(context).api!.orders.updateDetails(
            o.id,
            guests: _guests,
            customerName: v(_name),
            phone: v(_phone),
            address: v(_address),
            instructions: v(_instructions),
            scheduledFor: _scheduled,
            note: v(_note),
            deliveryFeeMinor: o.channel == 'delivery' ? parseAmount(_fee.text, o.currency, widget.scope.minorUnit) : null,
          );
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final delivery = o.channel == 'delivery';
    return AlertDialog(
      title: Text(t.editOrderDetails),
      content: SizedBox(
        width: 460,
        child: Form(
          key: _form,
          child: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              if (o.channel == 'dine_in')
                Row(children: [
                  Expanded(child: Text(t.guestsLabel)),
                  IconButton(onPressed: (_guests ?? 1) > 1 ? () => setState(() => _guests = (_guests ?? 2) - 1) : null, icon: const Icon(Icons.remove)),
                  Text('${_guests ?? '—'}', style: Theme.of(context).textTheme.titleMedium),
                  IconButton(onPressed: () => setState(() => _guests = (_guests ?? 0) + 1), icon: const Icon(Icons.add)),
                ]),
              TextFormField(controller: _name, maxLength: 120, decoration: InputDecoration(labelText: t.customerName, counterText: '')),
              const SizedBox(height: 10),
              TextFormField(
                controller: _phone,
                maxLength: 40,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(labelText: t.phone, counterText: ''),
              ),
              if (delivery) ...[
                const SizedBox(height: 10),
                TextFormField(
                  controller: _address,
                  maxLength: 500,
                  maxLines: 2,
                  decoration: InputDecoration(labelText: t.deliveryAddress, counterText: ''),
                  validator: (v) => (v ?? '').trim().length < 3 ? t.fieldRequired : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _instructions,
                  maxLength: 500,
                  decoration: InputDecoration(labelText: t.deliveryInstructions, counterText: ''),
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: AmountField(controller: _fee, label: t.deliveryFee, currency: o.currency, minorUnit: widget.scope.minorUnit, width: 220),
                ),
              ],
              if (o.channel != 'dine_in') ...[
                const SizedBox(height: 10),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.schedule_rounded),
                  title: Text(_scheduled == null ? t.asap : t.atTime(hm(context, _scheduled!))),
                  trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                    if (_scheduled != null) IconButton(onPressed: () => setState(() => _scheduled = null), icon: const Icon(Icons.close)),
                    IconButton(
                      icon: const Icon(Icons.edit_calendar_outlined),
                      onPressed: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(_scheduled ?? DateTime.now().add(const Duration(minutes: 30))),
                        );
                        if (picked == null) return;
                        final now = DateTime.now();
                        var d = DateTime(now.year, now.month, now.day, picked.hour, picked.minute);
                        if (d.isBefore(now.subtract(const Duration(minutes: 30)))) d = d.add(const Duration(days: 1));
                        setState(() => _scheduled = d);
                      },
                    ),
                  ]),
                ),
              ],
              const SizedBox(height: 10),
              TextFormField(controller: _note, maxLength: 500, decoration: InputDecoration(labelText: t.orderNote, counterText: '')),
            ]),
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(t.cancel)),
        FilledButton(onPressed: _save, child: Text(t.save)),
      ],
    );
  }
}

/// Journal de la commande : chaque étape, à l'heure près.
Future<void> showOrderHistory(BuildContext context, OrdersApi api, Order order, BranchContext scope) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (c) => FractionallySizedBox(
      heightFactor: 0.8,
      child: Loader<List<OrderEvent>>(
        load: () => api.events(order.id),
        builder: (context, events, _) {
          final t = context.t;
          return ListView(padding: const EdgeInsets.fromLTRB(20, 0, 20, 24), children: [
            Text(t.orderHistory, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            for (final e in events)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  radius: 16,
                  backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                  child: Icon(_eventIcon(e.event), size: 16),
                ),
                title: Text(_eventLabel(context, e, scope)),
                trailing: Text(hm(context, e.createdAt)),
              ),
          ]);
        },
      ),
    ),
  );
}

IconData _eventIcon(String e) => switch (e) {
      'opened' => Icons.add_circle_outline,
      'item_added' => Icons.add_shopping_cart_rounded,
      'item_updated' => Icons.edit_outlined,
      'item_removed' || 'item_cancelled' => Icons.remove_circle_outline,
      'sent' || 'fired' => Icons.send_rounded,
      'prep_status' => Icons.soup_kitchen_outlined,
      'payment' => Icons.payments_outlined,
      'payment_voided' || 'refund' => Icons.undo_rounded,
      'closed' => Icons.check_circle_outline,
      'cancelled' => Icons.cancel_outlined,
      'accepted' => Icons.thumb_up_alt_outlined,
      'table_moved' => Icons.swap_horiz_rounded,
      'seated' => Icons.event_available_rounded,
      _ => Icons.circle_outlined,
    };

String _eventLabel(BuildContext context, OrderEvent e, BranchContext scope) {
  final t = context.t;
  final d = e.detail;
  return switch (e.event) {
    'opened' => t.evOpened,
    'item_added' => t.evItemAdded('${d['quantity'] ?? 1} × ${d['name'] ?? ''}'),
    'item_updated' => t.evItemUpdated,
    'item_removed' => t.evItemRemoved,
    'sent' => t.evSent((d['lines'] as num?)?.toInt() ?? 0),
    'item_cancelled' => t.evItemCancelled,
    'cancelled' => t.evCancelled,
    'closed' => t.evClosed,
    'prep_status' => prepStatusLabel(t, d['status'] as String? ?? ''),
    'payment' => t.evPayment(scope.money(context, (d['amount'] as num?) ?? 0)),
    'payment_voided' => t.voidPayment,
    'refund' => t.evRefund,
    'details_updated' => t.evDetailsUpdated,
    'table_moved' => t.moveTable,
    'accepted' => t.orderAccepted,
    'fired' => t.fireNext,
    'held' => (d['held'] == true) ? t.holdForLater : t.sendWithOrder,
    'promised' => t.announcedDelay,
    'seated' => t.fromReservation,
    _ => e.event,
  };
}
