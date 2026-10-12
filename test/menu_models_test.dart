import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:resto/data/menu_models.dart';
import 'package:resto/features/menus/menu_widgets.dart';
import 'package:resto/l10n/app_localizations.dart';

void main() {
  test('article lu avec variantes triées, suppléments, allergènes et traductions', () {
    final item = MenuItem.fromJson({
      'id': 'i1',
      'brand_id': 'b1',
      'category_id': 'c1',
      'name': 'Ndolé',
      'description': null,
      'kind': 'food',
      'sort_order': 0,
      'active': true,
      'item_variants': [
        {'id': 'v2', 'name': 'Grande', 'sort_order': 1, 'active': true, 'item_variant_translations': []},
        {
          'id': 'v1',
          'name': '',
          'sort_order': 0,
          'active': true,
          'item_variant_translations': [
            {'locale': 'en', 'name': 'Regular'},
          ],
        },
      ],
      'item_modifier_groups': [
        {'group_id': 'g1'},
      ],
      'item_allergens': [
        {'allergen_code': 'crustaceans'},
      ],
      'menu_item_translations': [
        {'locale': 'en', 'name': 'Ndole', 'description': 'With shrimps'},
      ],
    });
    expect(item.variants.map((v) => v.id), ['v1', 'v2']);
    expect(item.variants.first.translations['en']!.name, 'Regular');
    expect(item.groupIds, {'g1'});
    expect(item.allergens, {'crustaceans'});
    expect(item.translations['en']!.description, 'With shrimps');
  });

  test('libellés traduits pour tous les canaux, types et allergènes', () async {
    for (final locale in AppLocalizations.supportedLocales) {
      final t = await AppLocalizations.delegate.load(locale);
      for (final c in priceChannels) {
        expect(channelLabel(t, c), isNotEmpty);
      }
      for (final k in itemKinds) {
        expect(kindLabel(t, k), isNotEmpty);
      }
      for (final a in allergenCodes) {
        expect(allergenLabel(t, a), isNot(a), reason: '$locale $a');
      }
    }
    final ar = await AppLocalizations.delegate.load(const Locale('ar'));
    expect(ar.selectionRule(1, '∞'), contains('1'));
  });

  test('règles d\'options en langage courant ↔ minimum / maximum', () {
    expect(OptionRule.of(1, 1), OptionRule.requiredOne);
    expect(OptionRule.of(0, null), OptionRule.optionalMany);
    expect(OptionRule.of(2, 3), isNull);
  });

  test('saisie des prix selon les décimales de la monnaie', () {
    expect(parseAmount('2 500', 'XAF', 0), 2500);
    expect(parseAmount('12,5', 'EUR', 2), 1250);
    expect(parseAmount('', 'EUR', 2), isNull);
    expect(() => parseAmount('-3', 'EUR', 2), throwsFormatException);
    expect(() => parseAmount('1.234', 'EUR', 2), throwsFormatException);
    expect(amountText(1250, 'EUR', 2), '12.50');
  });

  test('identifiants UUID v4 valides et uniques', () {
    final re = RegExp(r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$');
    final ids = List.generate(200, (_) => uuidV4());
    expect(ids.every(re.hasMatch), isTrue);
    expect(ids.toSet().length, 200);
  });
}
