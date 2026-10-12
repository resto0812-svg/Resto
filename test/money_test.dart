import 'package:flutter_test/flutter_test.dart';
import 'package:resto/core/money.dart';

String _spaces(String s) => s.replaceAll(' ', ' ').replaceAll(' ', ' ');

void main() {
  group('Money', () {
    test('addition et soustraction exactes dans la même monnaie', () {
      expect(Money(1050, 'EUR') + Money(250, 'EUR'), Money(1300, 'EUR'));
      expect(Money(1000, 'XAF') - Money(1500, 'XAF'), Money(-500, 'XAF'));
    });

    test('refuse de mélanger deux monnaies', () {
      expect(() => Money(1, 'EUR') + Money(1, 'USD'), throwsA(isA<CurrencyMismatchError>()));
      expect(() => Money(1, 'EUR').compareTo(Money(1, 'XAF')), throwsA(isA<CurrencyMismatchError>()));
    });

    test('code monnaie et bornes exactes contrôlés', () {
      expect(() => Money(1, 'eur'), throwsArgumentError);
      expect(() => Money(Money.maxMinor, 'EUR') + Money(1, 'EUR'), throwsRangeError);
      expect(() => Money(Money.maxMinor, 'EUR').times(2), throwsRangeError);
    });

    test('lecture décimale selon les décimales de la monnaie', () {
      expect(Money.parse('12.5', 'EUR', 2), Money(1250, 'EUR'));
      expect(Money.parse('1500', 'XAF', 0), Money(1500, 'XAF'));
      expect(Money.parse('1,234', 'KWD', 3), Money(1234, 'KWD'));
      expect(Money.parse('-0.01', 'EUR', 2), Money(-1, 'EUR'));
      expect(() => Money.parse('12.345', 'EUR', 2), throwsFormatException);
      expect(Money.parse('12.345', 'EUR', 2, rounding: RoundingMode.halfEven), Money(1234, 'EUR'));
      expect(() => Money.parse('1e3', 'EUR', 2), throwsFormatException);
    });

    test('écriture décimale exacte', () {
      expect(Money(5, 'EUR').toDecimalString(2), '0.05');
      expect(Money(-123456, 'KWD').toDecimalString(3), '-123.456');
      expect(Money(1500, 'XAF').toDecimalString(0), '1500');
    });

    test('pourcentage avec arrondi configurable', () {
      // 19,25 % de 1 000 XAF = 192,5 → 193 (halfUp) / 192 (halfEven)
      expect(Money(1000, 'XAF').percent('19.25'), Money(193, 'XAF'));
      expect(Money(1000, 'XAF').percent('19.25', rounding: RoundingMode.halfEven), Money(192, 'XAF'));
      expect(Money(-1000, 'XAF').percent('19.25'), Money(-193, 'XAF'));
      expect(Money(999, 'EUR').percent('10', rounding: RoundingMode.down), Money(99, 'EUR'));
      expect(Money(991, 'EUR').percent('10', rounding: RoundingMode.up), Money(100, 'EUR'));
    });

    test('répartition : la somme des parts égale toujours le total', () {
      final parts = Money(1000, 'XAF').allocate([1, 1, 1]);
      expect(parts.map((m) => m.minor), [334, 333, 333]);
      expect(parts.fold<int>(0, (a, m) => a + m.minor), 1000);

      final weighted = Money(10001, 'EUR').allocate([50, 30, 20]);
      expect(weighted.fold<int>(0, (a, m) => a + m.minor), 10001);

      final negative = Money(-100, 'EUR').allocate([1, 2]);
      expect(negative.fold<int>(0, (a, m) => a + m.minor), -100);
      expect(() => Money(1, 'EUR').allocate([0, 0]), throwsArgumentError);
    });

    test('affichage localisé selon les décimales de la monnaie', () {
      expect(_spaces(Money(150000, 'XAF').format('fr', 0)), contains('150 000'));
      expect(_spaces(Money(150000, 'XAF').format('fr', 0)), isNot(contains(',')));
      expect(_spaces(Money(123456, 'EUR').format('de', 2)), contains('1.234,56'));
      expect(Money(1234567, 'KWD').format('en', 3), contains('1,234.567'));
      // Au-delà de la zone d'affichage exacte : repli décimal exact.
      expect(Money(Money.maxMinor, 'EUR').format('fr', 2), '90071992547409.91 EUR');
    });
  });

  group('divideRounded', () {
    test('demi-unités et négatifs', () {
      BigInt d(int n, int den, RoundingMode m) => divideRounded(BigInt.from(n), BigInt.from(den), m);
      expect(d(5, 2, RoundingMode.halfUp), BigInt.from(3));
      expect(d(-5, 2, RoundingMode.halfUp), BigInt.from(-3));
      expect(d(5, 2, RoundingMode.halfEven), BigInt.from(2));
      expect(d(7, 2, RoundingMode.halfEven), BigInt.from(4));
      expect(d(-7, 2, RoundingMode.down), BigInt.from(-3));
      expect(d(7, -2, RoundingMode.up), BigInt.from(-4));
    });
  });
}
