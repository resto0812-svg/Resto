import 'package:flutter_test/flutter_test.dart';
import 'package:resto/data/cash_api.dart';
import 'package:resto/features/cash/cash_context.dart';

void main() {
  test('total compté billet par billet', () {
    expect(DenominationCounter.total({10000: 1, 5000: 1, 2000: 2, 500: 1}), 19500);
    expect(DenominationCounter.total({}), 0);
  });

  test('mode de paiement : actif et limité à certains établissements', () {
    final all = PaymentMethod.fromJson({'id': 'm1', 'name': 'Espèces', 'kind': 'cash', 'branch_ids': <String>[], 'active': true});
    final some = PaymentMethod.fromJson({'id': 'm2', 'name': 'Pix', 'kind': 'instant_transfer', 'branch_ids': ['b1'], 'active': true});
    final off = PaymentMethod.fromJson({'id': 'm3', 'name': 'Chèque', 'kind': 'cheque', 'active': false});
    expect(all.availableIn('b2'), isTrue);
    expect(all.isCash, isTrue);
    expect(some.availableIn('b1'), isTrue);
    expect(some.availableIn('b2'), isFalse);
    expect(off.availableIn('b1'), isFalse);
  });

  test('session : détail des coupures et numéro de Z', () {
    final s = CashSession.fromJson({
      'id': 's1',
      'register_id': 'r1',
      'branch_id': 'b1',
      'currency': 'XAF',
      'status': 'closed',
      'opening_float_minor': 15000,
      'opened_at': '2026-10-11T08:00:00Z',
      'count_detail': {'10000': 1, '500': 3},
      'z_number': 7,
    });
    expect(s.countDetail, {10000: 1, 500: 3});
    expect(s.zNumber, 7);
    expect(s.isOpen, isFalse);
  });

  test('paiement : montant remboursable après remboursements partiels', () {
    final p = Payment.fromJson({
      'id': 'p1',
      'order_id': 'o1',
      'session_id': 's1',
      'method': 'card',
      'payment_methods': {'name': 'Carte'},
      'amount_minor': 8000,
      'tip_minor': 500,
      'change_minor': 0,
      'status': 'confirmed',
      'created_at': '2026-10-11T12:00:00Z',
      'refunds': [
        {'amount_minor': 3000},
      ],
    });
    expect(p.methodName, 'Carte');
    expect(p.refundable, 5000);
  });
}
