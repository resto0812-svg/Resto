import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

/// Types de modes de paiement (le nom affiché est celui choisi par l'organisation).
const paymentKinds = [
  'cash',
  'card',
  'mobile_wallet',
  'instant_transfer',
  'bank_transfer',
  'voucher',
  'cheque',
  'customer_account',
  'other',
];

IconData paymentKindIcon(String kind) => switch (kind) {
  'cash' => Icons.payments_rounded,
  'card' => Icons.credit_card_rounded,
  'mobile_wallet' || 'mobile_money' => Icons.phone_iphone_rounded,
  'instant_transfer' => Icons.bolt_rounded,
  'bank_transfer' || 'transfer' => Icons.account_balance_rounded,
  'voucher' => Icons.confirmation_number_rounded,
  'cheque' => Icons.receipt_long_rounded,
  'customer_account' => Icons.badge_rounded,
  _ => Icons.more_horiz_rounded,
};

String paymentKindLabel(AppLocalizations t, String kind) => switch (kind) {
  'cash' => t.payCash,
  'card' => t.payCard,
  'mobile_wallet' || 'mobile_money' => t.payKindWallet,
  'instant_transfer' => t.payKindInstant,
  'bank_transfer' || 'transfer' => t.payTransfer,
  'voucher' => t.payKindVoucher,
  'cheque' => t.payKindCheque,
  'customer_account' => t.payKindAccount,
  _ => t.payOther,
};

/// Compatibilité : anciens écrans qui affichent un type de paiement.
IconData paymentMethodIcon(String kind) => paymentKindIcon(kind);
String paymentMethodLabel(AppLocalizations t, String kind) => paymentKindLabel(t, kind);
