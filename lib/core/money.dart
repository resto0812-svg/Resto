import 'package:intl/intl.dart';

/// Règles d'arrondi configurables par juridiction.
enum RoundingMode {
  /// 0,5 s'éloigne de zéro (arrondi commercial courant).
  halfUp,

  /// 0,5 vers le chiffre pair (arrondi bancaire).
  halfEven,

  /// Vers zéro (troncature).
  down,

  /// S'éloigne de zéro dès qu'il y a un reste.
  up,
}

class CurrencyMismatchError extends ArgumentError {
  CurrencyMismatchError(String a, String b) : super('Monnaies différentes : $a / $b');
}

/// Montant exact en unités mineures entières (centimes, fils…) avec sa monnaie
/// ISO 4217. Jamais de flottant dans les calculs (ADR-002).
///
/// Sur le Web, les entiers Dart sont des nombres JavaScript : seuls les
/// entiers jusqu'à 2^53 − 1 sont exacts, d'où la borne [maxMinor].
class Money implements Comparable<Money> {
  static const int maxMinor = 9007199254740991; // 2^53 − 1
  static final RegExp _currencyCode = RegExp(r'^[A-Z]{3}$');

  final int minor;
  final String currency;

  Money(this.minor, this.currency) {
    if (!_currencyCode.hasMatch(currency)) {
      throw ArgumentError.value(currency, 'currency', 'code ISO 4217 attendu');
    }
    _checkRange(minor);
  }

  Money.zero(String currency) : this(0, currency);

  static int _checkRange(int value) {
    if (value > maxMinor || value < -maxMinor) {
      throw RangeError('Montant hors limites exactes : $value');
    }
    return value;
  }

  void _same(Money other) {
    if (other.currency != currency) throw CurrencyMismatchError(currency, other.currency);
  }

  bool get isZero => minor == 0;
  bool get isNegative => minor < 0;

  Money operator +(Money other) {
    _same(other);
    return Money(_checkRange(minor + other.minor), currency);
  }

  Money operator -(Money other) {
    _same(other);
    return Money(_checkRange(minor - other.minor), currency);
  }

  Money operator -() => Money(-minor, currency);

  /// Prix unitaire × quantité entière.
  Money times(int quantity) {
    final product = BigInt.from(minor) * BigInt.from(quantity);
    return Money(_checkRange(_toInt(product)), currency);
  }

  /// Applique un taux décimal exprimé en pourcentage (« 19.25 » = 19,25 %),
  /// avec l'arrondi demandé. Le calcul de référence reste celui du serveur.
  Money percent(String rate, {RoundingMode rounding = RoundingMode.halfUp}) {
    final (numerator, scale) = _parseDecimal(rate);
    final denominator = BigInt.from(100) * BigInt.from(10).pow(scale);
    final result = divideRounded(BigInt.from(minor) * numerator, denominator, rounding);
    return Money(_checkRange(_toInt(result)), currency);
  }

  /// Répartit le montant selon des poids (addition partagée, paiements
  /// fractionnés) : la somme des parts est toujours égale au total ; les
  /// unités restantes vont aux plus grands restes, puis aux premiers.
  List<Money> allocate(List<int> weights) {
    if (weights.isEmpty || weights.any((w) => w < 0) || weights.every((w) => w == 0)) {
      throw ArgumentError.value(weights, 'weights', 'poids positifs, au moins un non nul');
    }
    final total = BigInt.from(weights.fold<int>(0, (a, b) => a + b));
    final amount = BigInt.from(minor.abs());
    final shares = <BigInt>[];
    final remainders = <BigInt>[];
    for (final w in weights) {
      final product = amount * BigInt.from(w);
      shares.add(product ~/ total);
      remainders.add(product.remainder(total));
    }
    var left = amount - shares.fold(BigInt.zero, (a, b) => a + b);
    final order = List<int>.generate(weights.length, (i) => i)
      ..sort((a, b) {
        final c = remainders[b].compareTo(remainders[a]);
        return c != 0 ? c : a.compareTo(b);
      });
    for (final i in order) {
      if (left == BigInt.zero) break;
      shares[i] += BigInt.one;
      left -= BigInt.one;
    }
    final sign = minor < 0 ? -1 : 1;
    return [for (final s in shares) Money(sign * _toInt(s), currency)];
  }

  /// « 12.5 » → 1250 (2 décimales). Refuse plus de décimales que la monnaie
  /// n'en possède, sauf si un arrondi est fourni.
  static Money parse(String value, String currency, int minorUnit, {RoundingMode? rounding}) {
    final (numerator, scale) = _parseDecimal(value);
    BigInt result;
    if (scale <= minorUnit) {
      result = numerator * BigInt.from(10).pow(minorUnit - scale);
    } else if (rounding == null) {
      throw FormatException('Trop de décimales pour $currency ($minorUnit)', value);
    } else {
      result = divideRounded(numerator, BigInt.from(10).pow(scale - minorUnit), rounding);
    }
    return Money(_checkRange(_toInt(result)), currency);
  }

  /// Représentation décimale exacte, point comme séparateur (« 12.50 »).
  String toDecimalString(int minorUnit) {
    final digits = minor.abs().toString().padLeft(minorUnit + 1, '0');
    final sign = minor < 0 ? '-' : '';
    if (minorUnit == 0) return '$sign$digits';
    final cut = digits.length - minorUnit;
    return '$sign${digits.substring(0, cut)}.${digits.substring(cut)}';
  }

  /// Affichage localisé. Le passage par un double est réservé à l'affichage
  /// et n'est utilisé que lorsqu'il est exact (|montant| < 2^37 unités
  /// principales) ; au-delà, repli sur la forme décimale exacte.
  String format(String locale, int minorUnit) {
    final limit = 137438953472 * _pow10(minorUnit); // 2^37 × 10^minorUnit
    if (minor.abs() >= limit) return '${toDecimalString(minorUnit)} $currency';
    final f = NumberFormat.simpleCurrency(locale: locale, name: currency, decimalDigits: minorUnit);
    return f.format(minor / _pow10(minorUnit));
  }

  static int _pow10(int n) {
    var r = 1;
    for (var i = 0; i < n; i++) {
      r *= 10;
    }
    return r;
  }

  static int _toInt(BigInt value) {
    if (value > BigInt.from(maxMinor) || value < BigInt.from(-maxMinor)) {
      throw RangeError('Montant hors limites exactes : $value');
    }
    return value.toInt();
  }

  /// « -12.345 » → (-12345, 3).
  static (BigInt, int) _parseDecimal(String value) {
    final m = RegExp(r'^\s*([+-]?)(\d+)(?:[.,](\d+))?\s*$').firstMatch(value);
    if (m == null) throw FormatException('Nombre décimal invalide', value);
    final fraction = m.group(3) ?? '';
    var n = BigInt.parse('${m.group(2)}$fraction');
    if (m.group(1) == '-') n = -n;
    return (n, fraction.length);
  }

  @override
  int compareTo(Money other) {
    _same(other);
    return minor.compareTo(other.minor);
  }

  @override
  bool operator ==(Object other) => other is Money && other.minor == minor && other.currency == currency;

  @override
  int get hashCode => Object.hash(minor, currency);

  @override
  String toString() => '$minor $currency (unités mineures)';
}

/// Division entière avec arrondi, correcte pour les nombres négatifs.
BigInt divideRounded(BigInt numerator, BigInt denominator, RoundingMode mode) {
  if (denominator == BigInt.zero) throw ArgumentError('Division par zéro');
  if (denominator.isNegative) {
    numerator = -numerator;
    denominator = -denominator;
  }
  final negative = numerator.isNegative;
  final n = numerator.abs();
  var q = n ~/ denominator;
  final r = n.remainder(denominator);
  if (r != BigInt.zero) {
    final twice = r * BigInt.two;
    final roundAway = switch (mode) {
      RoundingMode.down => false,
      RoundingMode.up => true,
      RoundingMode.halfUp => twice >= denominator,
      RoundingMode.halfEven => twice > denominator || (twice == denominator && q.isOdd),
    };
    if (roundAway) q += BigInt.one;
  }
  return negative ? -q : q;
}
