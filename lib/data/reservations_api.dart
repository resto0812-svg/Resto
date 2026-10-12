import 'package:supabase_flutter/supabase_flutter.dart';

/// Réservations côté restaurant (reservations.manage). Le chevauchement de
/// deux réservations sur une même table est refusé par la base.

class Reservation {
  Reservation.fromJson(Map<String, dynamic> j)
      : id = j['id'] as String,
        customerName = j['customer_name'] as String,
        contactPhone = j['contact_phone'] as String?,
        partySize = (j['party_size'] as num).toInt(),
        startsAt = DateTime.parse(j['starts_at'] as String).toLocal(),
        endsAt = DateTime.parse(j['ends_at'] as String).toLocal(),
        status = j['status'] as String,
        source = j['source'] as String,
        note = j['note'] as String?,
        reason = j['reason'] as String?,
        tableIds = [for (final t in (j['reservation_tables'] as List? ?? const [])) (t as Map)['table_id'] as String];
  final String id;
  final String customerName;
  final String? contactPhone;
  final int partySize;
  final DateTime startsAt;
  final DateTime endsAt;
  final String status;
  final String source;
  final String? note;
  final String? reason;
  final List<String> tableIds;
}

class FreeTable {
  FreeTable(this.id, this.label, this.seats, this.areaName);
  final String id;
  final String label;
  final int seats;
  final String areaName;
}

class ReservationsApi {
  ReservationsApi(this._db);
  final SupabaseClient _db;

  /// Réservations d'une journée (heure locale de l'appareil).
  Future<List<Reservation>> day(String branchId, DateTime day) async {
    final from = DateTime(day.year, day.month, day.day);
    final to = from.add(const Duration(days: 1));
    final rows = await _db
        .from('reservations')
        .select('*, reservation_tables(table_id)')
        .eq('branch_id', branchId)
        .gte('starts_at', from.toUtc().toIso8601String())
        .lt('starts_at', to.toUtc().toIso8601String())
        .order('starts_at');
    return [for (final r in rows) Reservation.fromJson(r)];
  }

  /// Demandes des clients en attente de réponse (toutes dates à venir).
  Future<List<Reservation>> requests(String branchId) async {
    final rows = await _db
        .from('reservations')
        .select('*, reservation_tables(table_id)')
        .eq('branch_id', branchId)
        .eq('status', 'requested')
        .order('starts_at');
    return [for (final r in rows) Reservation.fromJson(r)];
  }

  Future<List<FreeTable>> freeTables(String branchId, DateTime from, DateTime to) async {
    final rows = await _db.rpc('available_tables', params: {
      'p_branch': branchId,
      'p_starts_at': from.toUtc().toIso8601String(),
      'p_ends_at': to.toUtc().toIso8601String(),
    }) as List;
    return [
      for (final r in rows)
        FreeTable(r['table_id'] as String, r['label'] as String, (r['seats'] as num).toInt(), r['area_name'] as String),
    ];
  }

  Future<void> create({
    required String branchId,
    required DateTime startsAt,
    required int minutes,
    required int partySize,
    required String name,
    String? phone,
    required List<String> tableIds,
    String? note,
    required String clientId,
  }) =>
      _db.rpc('staff_create_reservation', params: {
        'p_branch': branchId,
        'p_starts_at': startsAt.toUtc().toIso8601String(),
        'p_minutes': minutes,
        'p_party_size': partySize,
        'p_name': name,
        'p_phone': phone,
        'p_tables': tableIds,
        'p_note': note,
        'p_client_id': clientId,
      });

  Future<void> confirm(String id, List<String> tableIds) =>
      _db.rpc('confirm_reservation', params: {'p_reservation': id, 'p_tables': tableIds});

  Future<void> setStatus(String id, String status, [String? reason]) =>
      _db.rpc('set_reservation_status', params: {'p_reservation': id, 'p_status': status, 'p_reason': reason});
}
