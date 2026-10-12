import 'package:flutter/material.dart';

import '../../app_state.dart';
import '../../data/cash_api.dart';
import '../../data/order_models.dart';
import '../../data/orders_api.dart';
import '../../ui/branch_scope.dart';
import '../../ui/common.dart';
import '../cash/payment_screen.dart';
import 'service_labels.dart';

/// Actions du service, identiques depuis le suivi, la salle ou la commande.
/// Chaque action renvoie true si elle a abouti (l'écran se met alors à jour).
class ServiceActions {
  ServiceActions(this.context, this.scope);
  final BuildContext context;
  final BranchContext scope;

  OrdersApi get _orders => AppScope.read(context).api!.orders;

  Future<bool> _run(Future<void> Function() action, {String? done}) async {
    try {
      await action();
      if (done != null && context.mounted) showInfo(context, done);
      return true;
    } catch (e) {
      if (context.mounted) showError(context, e);
      return false;
    }
  }

  /// Accepter une commande client en annonçant un délai.
  Future<bool> accept(Order o) async {
    final t = context.t;
    final target = scope.branch.targetPrepMinutes;
    final options = {10, 15, 20, 30, 45, 60, target}.toList()..sort();
    final minutes = await showDialog<int>(
      context: context,
      builder: (c) => SimpleDialog(
        title: Text(t.acceptWithDelay),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
            child: Text(o.scheduledFor != null ? t.scheduledFor(hm(c, o.scheduledFor!)) : t.delayAnnounced),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Wrap(spacing: 8, runSpacing: 8, children: [
              for (final m in options)
                ChoiceChip(
                  label: Text(durationText(m)),
                  selected: m == target,
                  onSelected: (_) => Navigator.pop(c, m),
                ),
            ]),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
    if (minutes == null) return false;
    return _run(() => _orders.accept(o.id, minutes: minutes), done: t.orderAccepted);
  }

  Future<bool> reject(Order o) async {
    final reason = await askReason(context, context.t.rejectOrder, hint: context.t.rejectReasonHint);
    if (reason == null) return false;
    return _run(() => _orders.reject(o.id, reason));
  }

  Future<bool> send(Order o) async {
    final t = context.t;
    return _run(() async {
      final n = await _orders.send(o.id);
      if (context.mounted) showInfo(context, t.sentToKitchen(n));
    });
  }

  Future<bool> fire(Order o) {
    final t = context.t;
    return _run(() async {
      final n = await _orders.fireHeld(o.id);
      if (context.mounted) showInfo(context, t.sentToKitchen(n));
    });
  }

  Future<bool> serve(Order o) => _run(
        () => _orders.setPrepStatus([for (final l in o.lines.where((l) => l.ready)) l.id], 'served'),
        done: servedAction(context.t, o.channel),
      );

  /// Encaissement : choix de la caisse ouverte puis écran de paiement.
  /// Renvoie le résultat du paiement (null si abandonné).
  Future<PaymentResult?> collect(Order o, {String? place}) async {
    final t = context.t;
    try {
      final session = await pickOpenSession(context, scope);
      if (session == null || !context.mounted) return null;
      final result = await Navigator.push<PaymentResult>(
        context,
        MaterialPageRoute(
          fullscreenDialog: true,
          builder: (_) => PaymentScreen(scope: scope, orderId: o.id, session: session, place: place ?? orderPlace(t, o, null)),
        ),
      );
      return result;
    } catch (e) {
      if (context.mounted) showError(context, e);
      return null;
    }
  }

  Future<bool> setDelay(Order o) async {
    final t = context.t;
    final minutes = await showDialog<int>(
      context: context,
      builder: (c) => SimpleDialog(
        title: Text(t.announcedDelay),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Wrap(spacing: 8, runSpacing: 8, children: [
              for (final m in const [5, 10, 15, 20, 30, 45, 60, 90])
                ActionChip(label: Text(durationText(m)), onPressed: () => Navigator.pop(c, m)),
            ]),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
    if (minutes == null) return false;
    return _run(() => _orders.setPromised(o.id, minutes), done: t.saved);
  }
}

/// Motif obligatoire (3 caractères au moins).
Future<String?> askReason(BuildContext context, String title, {String? hint}) {
  final controller = TextEditingController();
  return showDialog<String>(
    context: context,
    builder: (c) => AlertDialog(
      title: Text(title),
      content: TextField(
        controller: controller,
        autofocus: true,
        maxLength: 500,
        decoration: InputDecoration(labelText: c.t.reason, hintText: hint),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(c), child: Text(c.t.cancel)),
        FilledButton(
          onPressed: () {
            if (controller.text.trim().length < 3) return;
            Navigator.pop(c, controller.text.trim());
          },
          child: Text(c.t.confirm),
        ),
      ],
    ),
  ).whenComplete(controller.dispose);
}
