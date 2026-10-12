import 'package:flutter_test/flutter_test.dart';
import 'package:resto/data/customer_api.dart';
import 'package:resto/data/dashboard_api.dart';
import 'package:resto/data/purchases_api.dart';
import 'package:resto/data/stock_api.dart';
import 'package:resto/features/reports/insights_widgets.dart';

RecipeCost _cost(String name, int cost) =>
    RecipeCost.fromJson({'variant_id': name, 'item_name': name, 'variant_name': '', 'cost_minor': cost, 'price_minor': null, 'has_recipe': true});

void main() {
  group('ingénierie de menu', () {
    test('quatre familles selon popularité et marge', () {
      final items = [
        const SoldItem('a', 'Poulet DG', 100, 500000), // 5 000 l'unité, coût 2 000 → marge 3 000, très vendu
        const SoldItem('b', 'Riz sauté', 90, 180000), // 2 000 l'unité, coût 1 500 → marge 500, très vendu
        const SoldItem('c', 'Homard', 5, 75000), // 15 000 l'unité, coût 6 000 → marge 9 000, peu vendu
        const SoldItem('d', 'Soupe', 4, 4000), // 1 000 l'unité, coût 900 → marge 100, peu vendu
        const SoldItem('e', 'Jus maison', 50, 50000), // sans fiche technique
      ];
      final costs = [_cost('Poulet DG', 2000), _cost('Riz sauté', 1500), _cost('Homard', 6000), _cost('Soupe', 900)];
      final (groups, noRecipe) = classifyMenu(items, costs);
      expect(groups['stars']!.map((r) => r.$1.name), ['Poulet DG']);
      expect(groups['plowhorses']!.map((r) => r.$1.name), ['Riz sauté']);
      expect(groups['puzzles']!.map((r) => r.$1.name), ['Homard']);
      expect(groups['dogs']!.map((r) => r.$1.name), ['Soupe']);
      expect(noRecipe, 1);
    });

    test('aucune fiche technique : rien n\'est classé', () {
      final (groups, noRecipe) = classifyMenu([const SoldItem('a', 'Plat', 3, 3000)], const []);
      expect(groups.values.every((g) => g.isEmpty), isTrue);
      expect(noRecipe, 1);
    });
  });

  test('indicateurs détaillés : lecture et panier par couvert', () {
    final i = Insights.fromJson({
      'orders_by_day': [
        {'day': '2026-10-12', 'count': 3, 'total': 45000},
      ],
      'covers': 6,
      'dine_in_sales': 30000,
      'payments_by_method': [
        {'name': 'Espèces', 'kind': 'cash', 'total': 45000, 'count': 3, 'tips': 1000},
      ],
      'cancellations': {
        'orders': 1,
        'orders_amount': 5000,
        'items': 2,
        'items_amount': 3000,
        'reasons': [
          {'reason': 'Client parti', 'count': 1},
        ],
      },
      'items': [
        {'item_id': 'x', 'name': 'Ndolé', 'quantity': 4, 'total': 20000},
      ],
      'staff': [
        {'name': 'Awa', 'orders': 3, 'sales': 45000, 'tips': 1000},
      ],
      'service': {'prep_minutes': 12.5, 'serve_minutes': 3, 'table_minutes': 55},
      'heatmap': [
        {'dow': 1, 'hour': 12, 'count': 2},
      ],
    });
    expect(i.perCover, 5000);
    expect(i.payments.single.$3, 45000);
    expect(i.cancelReasons.single.$1, 'Client parti');
    expect(i.heatmap[(1, 12)], 2);
    expect(i.prepMinutes, 12.5);
  });

  test('dépense récurrente : due tant qu\'elle n\'est pas générée ce mois-ci', () {
    final now = DateTime.now();
    Map<String, dynamic> base(String? last, {bool active = true}) => {
          'id': 't',
          'category_id': 'c',
          'description': 'Loyer',
          'amount_minor': 100,
          'day_of_month': 5,
          'active': active,
          'last_month': last,
        };
    final thisMonth = '${now.year}-${now.month.toString().padLeft(2, '0')}-01';
    expect(ExpenseTemplate.fromJson(base(null)).dueThisMonth, isTrue);
    expect(ExpenseTemplate.fromJson(base('2020-01-01')).dueThisMonth, isTrue);
    expect(ExpenseTemplate.fromJson(base(thisMonth)).dueThisMonth, isFalse);
    expect(ExpenseTemplate.fromJson(base(null, active: false)).dueThisMonth, isFalse);
  });

  test('tables côté client : état et libération estimée', () {
    final s = TablesStatus.fromJson({
      'at': '2026-10-12T12:00:00Z',
      'reservation_minutes': 90,
      'accepts_reservations': true,
      'max_party_size': 12,
      'areas': [
        {
          'id': 'a',
          'name': 'Salle',
          'tables': [
            {'id': 't1', 'label': 'T1', 'seats': 4, 'status': 'occupied', 'free_at': '2026-10-12T13:00:00Z'},
            {'id': 't2', 'label': 'T2', 'seats': 2, 'status': 'free', 'next_reserved_at': '2026-10-12T20:00:00Z'},
          ],
        },
      ],
    });
    final tables = s.areas.single.$2;
    expect(s.isEmpty, isFalse);
    expect(tables.first.isFree, isFalse);
    expect(tables.first.freeAt, isNotNull);
    expect(tables.last.isFree, isTrue);
    expect(tables.last.nextReservedAt, isNotNull);
  });
}
