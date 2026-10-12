import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:intl/date_symbol_data_local.dart';
import 'package:resto/data/cash_api.dart';
import 'package:resto/data/models.dart';
import 'package:resto/data/order_models.dart';
import 'package:resto/l10n/app_localizations.dart';
import 'package:resto/pdf/cash_pdf.dart';
import 'package:resto/pdf/ticket_branding.dart';

Uint8List _logo() {
  final im = img.Image(width: 240, height: 240, numChannels: 4);
  img.fillCircle(im, x: 120, y: 120, radius: 110, color: img.ColorRgba8(201, 161, 59, 255));
  img.fillCircle(im, x: 120, y: 120, radius: 70, color: img.ColorRgba8(31, 42, 68, 255));
  return img.encodePng(im);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() => initializeDateFormatting('fr'));
  final t = lookupAppLocalizations(const Locale('fr'));
  final branch = Branch.fromJson({
    'id': 'b1',
    'organization_id': 'o1',
    'brand_id': 'br1',
    'name': 'Douala',
    'slug': 'chez-awa',
    'country_code': 'CM',
    'city': 'Douala',
    'timezone': 'Africa/Douala',
    'currency': 'XAF',
    'default_locale': 'fr',
    'status': 'active',
    'is_published': true,
  });
  final order = Order.fromJson({
    'id': 'c1',
    'branch_id': 'b1',
    'number': 42,
    'channel': 'dine_in',
    'status': 'closed',
    'currency': 'XAF',
    'prices_include_tax': true,
    'tax_rate': 19.25,
    'subtotal_minor': 8000,
    'tax_minor': 1291,
    'total_minor': 8000,
    'paid_minor': 8000,
    'opened_at': '2026-10-11T12:00:00Z',
    'receipt_number': 17,
    'order_items': [
      {
        'id': 'l1',
        'item_name': 'Ndolé',
        'variant_name': 'Standard',
        'quantity': 2,
        'order_item_modifiers': [
          {'group_name': 'Accompagnement', 'modifier_name': 'Riz', 'price_minor': 0},
        ],
        'unit_price_minor': 4000,
        'line_total_minor': 8000,
        'prep_status': 'served',
        'added_at': '2026-10-11T12:01:00Z',
      },
    ],
  });
  final payments = [
    Payment.fromJson({
      'id': 'p1',
      'order_id': 'c1',
      'session_id': 's1',
      'method': 'mobile_money',
      'reference': '690909090',
      'payment_methods': {'name': 'Paiement mobile'},
      'amount_minor': 8000,
      'tip_minor': 750,
      'created_by': 'u1',
      'status': 'confirmed',
      'created_at': '2026-10-11T12:30:00Z',
    }),
  ];

  CashDocContext doc(TicketBranding b) =>
      CashDocContext(t: t, locale: 'fr', minorUnit: 0, branch: branch, branding: b, staff: const {'u1': 'Awa'});

  test('ticket : logo en filigrane et QR code ajoutés au PDF', () async {
    final plain = await receiptPdf(doc(TicketBranding.none), order, payments, place: 'VIP 1');
    final branded = await receiptPdf(
      doc(TicketBranding(logo: _logo(), brandName: 'Délice', qrUrl: 'https://resto.app/?r=b1', qrCaption: t.receiptQrCaption)),
      order,
      payments,
      place: 'VIP 1',
    );
    expect(branded.length, greaterThan(plain.length));
    final out = Platform.environment['RESTO_PDF_OUT'];
    if (out != null) File(out).writeAsBytesSync(branded);
  });

  test('logo illisible : ticket imprimé quand même, sans filigrane', () async {
    final bytes = await receiptPdf(
      doc(TicketBranding(logo: Uint8List.fromList([1, 2, 3]))),
      order,
      payments,
      place: 'VIP 1',
    );
    expect(bytes, isNotEmpty);
  });
}
