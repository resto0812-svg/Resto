import 'package:flutter_test/flutter_test.dart';
import 'package:resto/data/models.dart';
import 'package:resto/data/order_models.dart';
import 'package:resto/data/reservations_api.dart';
import 'package:resto/features/service/floor_plan.dart';
import 'package:resto/features/service/reservation_table_picker.dart';

Map<String, dynamic> _line(String id, String status, {bool held = false}) => {
      'id': id,
      'item_id': 'i-$id',
      'item_name': 'Ndolé',
      'variant_name': '',
      'quantity': 1,
      'unit_price_minor': 4000,
      'line_total_minor': 4000,
      'prep_status': status,
      'held': held,
      'added_at': '2026-10-10T12:00:00Z',
      if (status != 'pending') 'sent_at': '2026-10-10T12:01:00Z',
    };

Order _order(List<Map<String, dynamic>> lines,
        {String status = 'open', String acceptance = 'accepted', String? table, int paid = 0, int total = 4000}) =>
    Order.fromJson({
      'id': 'o1',
      'branch_id': 'b1',
      'number': 12,
      'channel': table == null ? 'takeaway' : 'dine_in',
      'table_id': table,
      'status': status,
      'acceptance': acceptance,
      'currency': 'XAF',
      'prices_include_tax': true,
      'tax_rate': 0,
      'subtotal_minor': total,
      'tax_minor': 0,
      'total_minor': total,
      'paid_minor': paid,
      'opened_at': '2026-10-10T12:00:00Z',
      'order_items': lines,
    });

void main() {
  group('étape d\'une commande', () {
    test('commande client en attente : à valider', () {
      expect(_order([_line('a', 'pending')], acceptance: 'pending').stage, OrderStage.toValidate);
    });
    test('rien envoyé : pas encore envoyée', () {
      expect(_order([_line('a', 'pending')]).stage, OrderStage.draft);
    });
    test('en cuisine, puis prête dès qu\'un article est prêt', () {
      expect(_order([_line('a', 'sent'), _line('b', 'preparing')]).stage, OrderStage.cooking);
      expect(_order([_line('a', 'ready'), _line('b', 'preparing')]).stage, OrderStage.ready);
    });
    test('tout servi : à encaisser ; payée et close : terminée', () {
      expect(_order([_line('a', 'served')]).stage, OrderStage.toPay);
      expect(_order([_line('a', 'served')], status: 'closed', paid: 4000).stage, OrderStage.done);
    });
    test('vente à emporter payée d\'avance encore en cuisine : reste en préparation', () {
      expect(_order([_line('a', 'preparing')], status: 'closed', paid: 4000).stage, OrderStage.cooking);
    });
    test('articles « à suivre » comptés à part', () {
      final o = _order([_line('a', 'pending'), _line('b', 'pending', held: true)]);
      expect(o.pendingCount, 1);
      expect(o.heldCount, 1);
    });
  });

  group('salle', () {
    final t1 = DiningTable('t1', 'a1', 'Table 1', 4, true);
    final vip = DiningTable('t2', 'a1', 'VIP 1', 6, true, shape: 'round');
    final areas = [ServiceArea('a1', 'Salle', true, [t1, vip])];
    final now = DateTime(2026, 10, 10, 19, 0);

    Reservation res(String table, DateTime start, String status) => Reservation.fromJson({
          'id': 'r-$table',
          'customer_name': 'Ekwalla',
          'party_size': 4,
          'starts_at': start.toUtc().toIso8601String(),
          'ends_at': start.add(const Duration(minutes: 90)).toUtc().toIso8601String(),
          'status': status,
          'source': 'staff',
          'reservation_tables': [
            {'table_id': table},
          ],
        });

    test('table avec commande : occupée ; plat prêt : « prête »', () {
      expect(tableInfos(areas, [_order([_line('a', 'sent')], table: 't1')], const [], now)['t1']!.kind, TableKind.occupied);
      expect(tableInfos(areas, [_order([_line('a', 'ready')], table: 't1')], const [], now)['t1']!.kind, TableKind.ready);
    });
    test('réservation en cours : réservée ; dans moins de 90 min : bientôt ; sinon libre', () {
      expect(tableInfos(areas, const [], [res('t1', now.subtract(const Duration(minutes: 10)), 'confirmed')], now)['t1']!.kind,
          TableKind.reserved);
      expect(tableInfos(areas, const [], [res('t1', now.add(const Duration(minutes: 45)), 'confirmed')], now)['t1']!.kind,
          TableKind.reservedSoon);
      final later = tableInfos(areas, const [], [res('t1', now.add(const Duration(hours: 3)), 'confirmed')], now)['t1']!;
      expect(later.kind, TableKind.free);
      expect(later.next, isNotNull);
    });
    test('réservation annulée : ignorée', () {
      expect(tableInfos(areas, const [], [res('t2', now, 'cancelled')], now)['t2']!.kind, TableKind.free);
    });
    test('créneau : réservée si chevauchement, la réservation modifiée ne se bloque pas elle-même', () {
      final start = now.add(const Duration(hours: 1));
      final r = res('t1', start.subtract(const Duration(minutes: 30)), 'confirmed');
      final slots = slotAvailability(
          areas: areas, orders: const [], reservations: [r], start: start, end: start.add(const Duration(minutes: 90)), mealMinutes: 90);
      expect(slots['t1']!.state, SlotState.reserved);
      expect(slots['t2']!.state, SlotState.free);
      final own = slotAvailability(
          areas: areas,
          orders: const [],
          reservations: [r],
          start: start,
          end: start.add(const Duration(minutes: 90)),
          mealMinutes: 90,
          excludeReservationId: r.id);
      expect(own['t1']!.state, SlotState.free);
    });
    test('plan : positions enregistrées respectées, les autres placées sans dépasser la grille', () {
      final placed = DiningTable('t3', 'a1', 'Bar', 2, true, posX: 10, posY: 2);
      final pos = layoutTables([placed, t1, vip]);
      expect(pos['t3'], (10, 2));
      for (final tb in [t1, vip]) {
        expect(pos[tb.id]!.$1 + tableCells(tb).$1, lessThanOrEqualTo(planColumns));
        expect(pos[tb.id]!.$2, greaterThan(2));
      }
    });
  });
}
