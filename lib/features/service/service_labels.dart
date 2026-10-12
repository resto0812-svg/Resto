import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/order_models.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/theme.dart';

/// Libellés, icônes et couleurs communs au service (commandes, salle, cuisine).

IconData channelIcon(String channel) => switch (channel) {
      'dine_in' => Icons.table_restaurant_rounded,
      'delivery' => Icons.delivery_dining_rounded,
      _ => Icons.shopping_bag_rounded,
    };

/// « VIP 1 », « À emporter », « Livraison » : ce que l'on voit en premier.
String orderPlace(AppLocalizations t, Order o, String? tableLabel) => switch (o.channel) {
      'dine_in' => tableLabel ?? t.channelDineIn,
      'delivery' => t.channelDelivery,
      _ => t.channelTakeaway,
    };

String sourceLabel(AppLocalizations t, String source) => switch (source) {
      'phone' => t.sourcePhone,
      'qr' => t.sourceQr,
      'app' || 'web' => t.sourceApp,
      'partner' => t.sourcePartner,
      _ => t.sourceStaff,
    };

IconData sourceIcon(String source) => switch (source) {
      'phone' => Icons.phone_in_talk_rounded,
      'qr' => Icons.qr_code_2_rounded,
      'app' || 'web' => Icons.smartphone_rounded,
      'partner' => Icons.handshake_rounded,
      _ => Icons.person_rounded,
    };

String stageLabel(AppLocalizations t, OrderStage s, String channel) => switch (s) {
      OrderStage.toValidate => t.stageToValidate,
      OrderStage.draft => t.stageDraft,
      OrderStage.cooking => t.stageCooking,
      OrderStage.ready => switch (channel) {
          'delivery' => t.stageReadyDelivery,
          'takeaway' => t.stageReadyTakeaway,
          _ => t.stageReady,
        },
      OrderStage.toPay => t.stageToPay,
      OrderStage.done => t.stageDone,
      OrderStage.cancelled => t.stageCancelled,
    };

Color stageColor(OrderStage s) => switch (s) {
      OrderStage.toValidate => StatusColors.toValidate,
      OrderStage.draft => StatusColors.done,
      OrderStage.cooking => StatusColors.cooking,
      OrderStage.ready => StatusColors.ready,
      OrderStage.toPay => StatusColors.toPay,
      OrderStage.done => StatusColors.free,
      OrderStage.cancelled => StatusColors.late,
    };

IconData stageIcon(OrderStage s) => switch (s) {
      OrderStage.toValidate => Icons.notifications_active_rounded,
      OrderStage.draft => Icons.edit_note_rounded,
      OrderStage.cooking => Icons.local_fire_department_rounded,
      OrderStage.ready => Icons.room_service_rounded,
      OrderStage.toPay => Icons.payments_rounded,
      OrderStage.done => Icons.check_circle_rounded,
      OrderStage.cancelled => Icons.cancel_rounded,
    };

/// Libellé du bouton « servi » selon le type de commande.
String servedAction(AppLocalizations t, String channel) => switch (channel) {
      'delivery' => t.handToCourier,
      'takeaway' => t.handToCustomer,
      _ => t.markServed,
    };

String hm(BuildContext context, DateTime d) => DateFormat.Hm(Localizations.localeOf(context).toString()).format(d.toLocal());

String dayLabel(BuildContext context, DateTime d) =>
    DateFormat.yMMMMEEEEd(Localizations.localeOf(context).toString()).format(d);

/// Couleur du chronomètre : vert, puis orange, puis rouge après le temps visé.
Color timerColor(int minutes, int target) {
  if (minutes >= target) return StatusColors.late;
  if (minutes >= (target * 0.7).round()) return StatusColors.cooking;
  return StatusColors.free;
}

/// Durée lisible : « 8 min », « 1 h 05 ».
String durationText(int minutes) {
  if (minutes < 60) return '$minutes min';
  final h = minutes ~/ 60;
  final m = minutes % 60;
  return '$h h ${m.toString().padLeft(2, '0')}';
}

String prepStatusLabel(AppLocalizations t, String s) => switch (s) {
      'pending' => t.prepPending,
      'sent' => t.prepSent,
      'preparing' => t.prepPreparing,
      'ready' => t.prepReady,
      'served' => t.prepServed,
      _ => t.prepCancelled,
    };
