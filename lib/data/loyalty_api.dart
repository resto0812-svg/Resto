import 'package:supabase_flutter/supabase_flutter.dart';

/// Côté restaurant : promotions, programme de fidélité, avis des clients.
/// Écritures sous RLS (customers.manage) ou par les fonctions du serveur.

class Promotion {
  Promotion({
    this.id,
    required this.organizationId,
    this.branchId,
    this.name = '',
    this.kind = 'percent',
    this.percent,
    this.amountMinor,
    this.code,
    this.startsAt,
    this.endsAt,
    this.minOrderMinor = 0,
    this.maxUses,
    this.usesCount = 0,
    this.perCustomerLimit,
    this.active = true,
    this.isPublic = false,
  });

  factory Promotion.fromJson(Map<String, dynamic> j) => Promotion(
        id: j['id'] as String,
        organizationId: j['organization_id'] as String,
        branchId: j['branch_id'] as String?,
        name: j['name'] as String,
        kind: j['kind'] as String,
        percent: (j['percent'] as num?)?.toDouble(),
        amountMinor: (j['amount_minor'] as num?)?.toInt(),
        code: j['code'] as String?,
        startsAt: j['starts_at'] == null ? null : DateTime.parse(j['starts_at'] as String),
        endsAt: j['ends_at'] == null ? null : DateTime.parse(j['ends_at'] as String),
        minOrderMinor: (j['min_order_minor'] as num? ?? 0).toInt(),
        maxUses: (j['max_uses'] as num?)?.toInt(),
        usesCount: (j['uses_count'] as num? ?? 0).toInt(),
        perCustomerLimit: (j['per_customer_limit'] as num?)?.toInt(),
        active: j['active'] as bool,
        isPublic: j['is_public'] as bool? ?? false,
      );

  String? id;
  final String organizationId;
  String? branchId;
  String name;
  String kind; // percent, amount
  double? percent;
  int? amountMinor;
  String? code;
  DateTime? startsAt;
  DateTime? endsAt;
  int minOrderMinor;
  int? maxUses;
  int usesCount;
  int? perCustomerLimit;
  bool active;

  /// Coupon public : affiché aux clients de l'application, qui peuvent l'enregistrer.
  bool isPublic;

  /// Utilisable maintenant (dates, limite d'utilisations).
  bool get usableNow {
    final now = DateTime.now();
    return active &&
        (startsAt == null || !now.isBefore(startsAt!)) &&
        (endsAt == null || now.isBefore(endsAt!)) &&
        (maxUses == null || usesCount < maxUses!);
  }

  Map<String, dynamic> _editable() => {
        'name': name.trim(),
        'percent': kind == 'percent' ? percent : null,
        'amount_minor': kind == 'amount' ? amountMinor : null,
        'starts_at': startsAt?.toUtc().toIso8601String(),
        'ends_at': endsAt?.toUtc().toIso8601String(),
        'min_order_minor': minOrderMinor,
        'max_uses': maxUses,
        'per_customer_limit': perCustomerLimit,
        'active': active,
        'is_public': isPublic,
      };
}

class LoyaltyProgram {
  LoyaltyProgram({
    this.active = false,
    this.amountPerPointMinor = 1000,
    this.rewardPoints = 100,
    this.rewardMinor = 1000,
    this.birthdayPoints = 0,
    this.exists = false,
  });

  factory LoyaltyProgram.fromJson(Map<String, dynamic> j) => LoyaltyProgram(
        active: j['active'] as bool,
        amountPerPointMinor: (j['amount_per_point_minor'] as num).toInt(),
        rewardPoints: (j['reward_points'] as num).toInt(),
        rewardMinor: (j['reward_minor'] as num).toInt(),
        birthdayPoints: (j['birthday_points'] as num? ?? 0).toInt(),
        exists: true,
      );

  bool active;
  int amountPerPointMinor;
  int rewardPoints;
  int rewardMinor;

  /// Points offerts pour l'anniversaire des clients (0 = aucun).
  int birthdayPoints;
  final bool exists;
}

class Review {
  Review.fromJson(Map<String, dynamic> j)
      : id = j['id'] as String,
        branchId = j['branch_id'] as String,
        rating = (j['rating'] as num).toInt(),
        comment = j['comment'] as String?,
        status = j['status'] as String,
        hiddenReason = j['hidden_reason'] as String?,
        createdAt = DateTime.parse(j['created_at'] as String);
  final String id;
  final String branchId;
  final int rating;
  final String? comment;
  final String status;
  final String? hiddenReason;
  final DateTime createdAt;
}

class LoyaltyApi {
  LoyaltyApi(this._db);
  final SupabaseClient _db;

  Future<List<Promotion>> promotions(String orgId) async {
    final rows = await _db.from('promotions').select().eq('organization_id', orgId).order('created_at', ascending: false);
    return [for (final r in rows) Promotion.fromJson(r)];
  }

  Future<void> savePromotion(Promotion p) async {
    if (p.id == null) {
      await _db.from('promotions').insert({
        ..._editableWithKind(p),
        'organization_id': p.organizationId,
        'branch_id': p.branchId,
        'code': (p.code == null || p.code!.trim().isEmpty) ? null : p.code!.trim().toUpperCase(),
      });
    } else {
      await _db.from('promotions').update(p._editable()).eq('id', p.id!);
    }
  }

  Map<String, dynamic> _editableWithKind(Promotion p) => {...p._editable(), 'kind': p.kind};

  /// Membres du programme : nombre de clients ayant un compte de points, et points en circulation.
  Future<(int, int)> loyaltyMembers(String orgId) async {
    final rows = await _db.from('loyalty_accounts').select('points').eq('organization_id', orgId);
    return (rows.length, rows.fold<int>(0, (a, r) => a + (r['points'] as num).toInt()));
  }

  Future<LoyaltyProgram> program(String orgId) async {
    final row = await _db.from('loyalty_programs').select().eq('organization_id', orgId).maybeSingle();
    return row == null ? LoyaltyProgram() : LoyaltyProgram.fromJson(row);
  }

  /// Insertion la première fois, puis mise à jour (droits par colonne).
  Future<void> saveProgram(String orgId, LoyaltyProgram p) {
    final values = {
      'active': p.active,
      'amount_per_point_minor': p.amountPerPointMinor,
      'reward_points': p.rewardPoints,
      'reward_minor': p.rewardMinor,
      'birthday_points': p.birthdayPoints,
    };
    return p.exists
        ? _db.from('loyalty_programs').update(values).eq('organization_id', orgId)
        : _db.from('loyalty_programs').insert({...values, 'organization_id': orgId});
  }

  /// Points du client d'une commande (null si aucun compte de fidélité).
  Future<int?> customerPoints(String orgId, String userId) async {
    final row = await _db
        .from('loyalty_accounts')
        .select('points')
        .eq('organization_id', orgId)
        .eq('user_id', userId)
        .maybeSingle();
    return (row?['points'] as num?)?.toInt();
  }

  Future<List<Review>> reviews(String branchId) async {
    final rows = await _db.from('reviews').select().eq('branch_id', branchId).order('created_at', ascending: false).limit(200);
    return [for (final r in rows) Review.fromJson(r)];
  }

  Future<void> hideReview(String id, String reason) =>
      _db.rpc('hide_review', params: {'p_review': id, 'p_reason': reason});
}
