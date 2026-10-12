import 'package:supabase_flutter/supabase_flutter.dart';

import 'order_models.dart';

/// Commandes : lectures sous RLS (orders.read), écritures par les fonctions
/// open_order, add_order_item… (prix et options vérifiés par le serveur).
/// Chaque création porte un identifiant généré ici : un appel rejoué après
/// une coupure ne crée pas de doublon.
class OrdersApi {
  OrdersApi(this._db);

  /// Accès pour les extensions (cuisine).
  SupabaseClient get db => _db;
  final SupabaseClient _db;

  static const _orderColumns =
      '*, order_items(*, order_item_modifiers(group_name, modifier_name, price_minor)), order_adjustments(id, kind, label, percent, applied_minor, created_at)';

  Future<List<Order>> openOrders(String branchId) async {
    final rows = await _db
        .from('orders')
        .select(_orderColumns)
        .eq('branch_id', branchId)
        .eq('status', 'open')
        .order('opened_at');
    return [for (final r in rows) Order.fromJson(r)];
  }

  Future<Order> order(String id) async => Order.fromJson(await _db.from('orders').select(_orderColumns).eq('id', id).single());

  /// Suivi du service : commandes ouvertes, et commandes payées d'avance
  /// encore en préparation ou pas encore remises (12 dernières heures).
  Future<List<Order>> board(String branchId) async {
    final since = DateTime.now().subtract(const Duration(hours: 12)).toUtc().toIso8601String();
    final rows = await _db
        .from('orders')
        .select(_orderColumns)
        .eq('branch_id', branchId)
        .or('status.eq.open,and(status.eq.closed,served_at.is.null,closed_at.gt.$since)')
        .order('opened_at');
    return [for (final r in rows) Order.fromJson(r)];
  }

  /// Historique d'une journée de service (toutes les commandes).
  Future<List<Order>> history(String branchId, DateTime day) async {
    final d = '${day.year.toString().padLeft(4, '0')}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
    final rows = await _db
        .from('orders')
        .select(_orderColumns)
        .eq('branch_id', branchId)
        .eq('business_date', d)
        .order('number', ascending: false);
    return [for (final r in rows) Order.fromJson(r)];
  }

  /// Journal de la commande (qui a fait quoi, quand).
  Future<List<OrderEvent>> events(String orderId) async {
    final rows = await _db.from('order_events').select().eq('order_id', orderId).order('id');
    return [for (final r in rows) OrderEvent.fromJson(r)];
  }

  /// Nouvelle commande complète (serveur, comptoir, téléphone).
  Future<String> create({
    required String branchId,
    required String channel,
    String? tableId,
    int? guests,
    String source = 'staff',
    String? customerName,
    String? phone,
    String? address,
    String? instructions,
    DateTime? scheduledFor,
    String? note,
    required String clientId,
  }) async =>
      await _db.rpc('create_order', params: {
        'p_branch': branchId,
        'p_channel': channel,
        'p_table': tableId,
        'p_guests': guests,
        'p_source': source,
        'p_customer_name': customerName,
        'p_contact_phone': phone,
        'p_delivery_address': address,
        'p_delivery_instructions': instructions,
        'p_scheduled_for': scheduledFor?.toUtc().toIso8601String(),
        'p_note': note,
        'p_client_id': clientId,
      }) as String;

  Future<void> updateDetails(
    String orderId, {
    int? guests,
    String? customerName,
    String? phone,
    String? address,
    String? instructions,
    DateTime? scheduledFor,
    String? note,
    int? deliveryFeeMinor,
  }) =>
      _db.rpc('update_order_details', params: {
        'p_order': orderId,
        'p_guests': guests,
        'p_customer_name': customerName,
        'p_contact_phone': phone,
        'p_delivery_address': address,
        'p_delivery_instructions': instructions,
        'p_scheduled_for': scheduledFor?.toUtc().toIso8601String(),
        'p_note': note,
        'p_delivery_fee': deliveryFeeMinor,
      });

  Future<void> moveTable(String orderId, String tableId) =>
      _db.rpc('move_order_table', params: {'p_order': orderId, 'p_table': tableId});

  Future<void> setHeld(String lineId, bool held) => _db.rpc('set_item_held', params: {'p_item': lineId, 'p_held': held});

  Future<int> fireHeld(String orderId) async => (await _db.rpc('fire_held', params: {'p_order': orderId}) as num).toInt();

  Future<void> setPromised(String orderId, int minutes) =>
      _db.rpc('set_promised_time', params: {'p_order': orderId, 'p_minutes': minutes});

  Future<String> seatReservation(String reservationId) async =>
      await _db.rpc('seat_reservation', params: {'p_reservation': reservationId}) as String;

  Future<String> open({
    required String branchId,
    required String channel,
    String? tableId,
    int? guests,
    required String clientId,
  }) async =>
      await _db.rpc('open_order', params: {
        'p_branch': branchId,
        'p_channel': channel,
        'p_table': tableId,
        'p_guests': guests,
        'p_client_id': clientId,
      }) as String;

  Future<void> addItem({
    required String orderId,
    required String variantId,
    required int quantity,
    required List<String> modifierIds,
    String? note,
    required String clientId,
  }) =>
      _db.rpc('add_order_item', params: {
        'p_order': orderId,
        'p_variant': variantId,
        'p_quantity': quantity,
        'p_modifiers': modifierIds,
        'p_note': note,
        'p_client_id': clientId,
      });

  Future<void> updateItem(String lineId, int quantity, String? note) =>
      _db.rpc('update_order_item', params: {'p_item': lineId, 'p_quantity': quantity, 'p_note': note});

  Future<void> removeItem(String lineId) => _db.rpc('remove_order_item', params: {'p_item': lineId});

  Future<int> send(String orderId) async => (await _db.rpc('send_order', params: {'p_order': orderId}) as num).toInt();

  Future<void> cancelItem(String lineId, String reason) =>
      _db.rpc('cancel_order_item', params: {'p_item': lineId, 'p_reason': reason});

  Future<void> cancel(String orderId, String? reason) =>
      _db.rpc('cancel_order', params: {'p_order': orderId, 'p_reason': reason});
}

/// Poste de préparation (Cuisine, Bar…) et types d'articles qu'il prépare.
class PrepStation {
  PrepStation.fromJson(Map<String, dynamic> j)
      : id = j['id'] as String,
        name = j['name'] as String,
        kinds = (j['kinds'] as List).cast<String>(),
        active = j['active'] as bool;
  final String id;
  final String name;
  final List<String> kinds;
  final bool active;
}

/// Ligne à préparer, avec ce qu'il faut savoir de sa commande.
class KitchenLine {
  KitchenLine.fromJson(Map<String, dynamic> j)
      : line = OrderLine.fromJson(j),
        stationId = j['station_id'] as String?,
        sentAt = DateTime.parse(j['sent_at'] as String),
        readyAt = j['ready_at'] == null ? null : DateTime.parse(j['ready_at'] as String),
        orderId = j['order_id'] as String,
        orderNumber = ((j['orders'] as Map)['number'] as num).toInt(),
        tableId = (j['orders'] as Map)['table_id'] as String?,
        tableLabel = ((j['orders'] as Map)['dining_tables'] as Map?)?['label'] as String?,
        channel = (j['orders'] as Map)['channel'] as String,
        source = (j['orders'] as Map)['source'] as String? ?? 'staff',
        customerName = (j['orders'] as Map)['customer_name'] as String?,
        guests = ((j['orders'] as Map)['guests'] as num?)?.toInt(),
        orderNote = (j['orders'] as Map)['note'] as String?,
        scheduledFor = _date((j['orders'] as Map)['scheduled_for']),
        promisedAt = _date((j['orders'] as Map)['promised_at']);
  final OrderLine line;
  final String? stationId;
  final DateTime sentAt;
  final DateTime? readyAt;
  final String orderId;
  final int orderNumber;
  final String? tableId;
  final String? tableLabel;
  final String channel;
  final String source;
  final String? customerName;
  final int? guests;
  final String? orderNote;
  final DateTime? scheduledFor;
  final DateTime? promisedAt;

  static DateTime? _date(Object? v) => v == null ? null : DateTime.parse(v as String);
}

extension KitchenApi on OrdersApi {
  Future<List<PrepStation>> stations(String branchId) async {
    final rows = await db.from('prep_stations').select().eq('branch_id', branchId).order('sort_order').order('name');
    return [for (final r in rows) PrepStation.fromJson(r)];
  }

  Future<void> saveStation({
    required String orgId,
    required String branchId,
    String? id,
    required String name,
    required List<String> kinds,
    required bool active,
  }) {
    final values = {'name': name.trim(), 'kinds': kinds, 'active': active};
    if (id == null) {
      return db.from('prep_stations').insert({...values, 'organization_id': orgId, 'branch_id': branchId});
    }
    return db.from('prep_stations').update(values).eq('id', id);
  }

  /// Lignes envoyées, en préparation ou prêtes, les plus anciennes d'abord.
  Future<List<KitchenLine>> kitchenQueue(String branchId) async {
    final rows = await db
        .from('order_items')
        .select('*, order_item_modifiers(group_name, modifier_name, price_minor), orders(number, table_id, channel, source, customer_name, guests, note, scheduled_for, promised_at, status, dining_tables(label))')
        .eq('branch_id', branchId)
        .inFilter('prep_status', ['sent', 'preparing', 'ready'])
        .order('sent_at');
    return [for (final r in rows) KitchenLine.fromJson(r)];
  }

  Future<void> setPrepStatus(List<String> lineIds, String status) =>
      db.rpc('set_prep_status', params: {'p_items': lineIds, 'p_status': status});

  /// Abonnement en direct aux changements de lignes de l'établissement.
  RealtimeChannel watchBranch(String branchId, void Function() onChange) => db
      .channel('kitchen-$branchId-${DateTime.now().microsecondsSinceEpoch}')
      .onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'order_items',
        filter: PostgresChangeFilter(type: PostgresChangeFilterType.eq, column: 'branch_id', value: branchId),
        callback: (_) => onChange(),
      )
      .subscribe();

  Future<void> unwatch(RealtimeChannel channel) => db.removeChannel(channel);
}

/// Commandes des clients (acceptation) et réductions (promotion, remise, fidélité).
extension OnlineOrdersApi on OrdersApi {
  /// Accepte la commande d'un client ; [minutes] = délai annoncé (sinon temps visé de l'établissement).
  Future<void> accept(String orderId, {int? minutes}) =>
      db.rpc('accept_online_order', params: {'p_order': orderId, 'p_prep_minutes': minutes});

  Future<void> reject(String orderId, String reason) =>
      db.rpc('reject_online_order', params: {'p_order': orderId, 'p_reason': reason});

  Future<void> applyPromotion(String orderId, {String? promotionId, String? code}) =>
      db.rpc('apply_promotion', params: {'p_order': orderId, 'p_promotion': promotionId, 'p_code': code});

  Future<void> manualDiscount(String orderId, {double? percent, int? amountMinor, required String reason}) =>
      db.rpc('apply_manual_discount',
          params: {'p_order': orderId, 'p_percent': percent, 'p_amount': amountMinor, 'p_reason': reason});

  Future<void> removeAdjustment(String adjustmentId) =>
      db.rpc('remove_adjustment', params: {'p_adjustment': adjustmentId});

  Future<void> redeemLoyalty(String orderId) => db.rpc('redeem_loyalty', params: {'p_order': orderId});
}

/// Abonnement en direct au service d'un établissement (commandes et articles).
extension ServiceWatch on OrdersApi {
  RealtimeChannel watchService(String branchId, void Function() onChange) => db
      .channel('service-$branchId-${DateTime.now().microsecondsSinceEpoch}')
      .onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'orders',
        filter: PostgresChangeFilter(type: PostgresChangeFilterType.eq, column: 'branch_id', value: branchId),
        callback: (_) => onChange(),
      )
      .onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'order_items',
        filter: PostgresChangeFilter(type: PostgresChangeFilterType.eq, column: 'branch_id', value: branchId),
        callback: (_) => onChange(),
      )
      .subscribe();
}
