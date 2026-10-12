import 'dart:math';
import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

/// Stocks et fiches techniques : lectures sous RLS (stock.read), écritures
/// par les fonctions du serveur (mouvements jamais modifiés).
class Unit {
  const Unit(this.code, this.dimension, this.factor);
  final String code;
  final String dimension;
  final double factor;
}

class Ingredient {
  Ingredient.fromJson(Map<String, dynamic> j)
      : id = j['id'] as String,
        name = j['name'] as String,
        kind = j['kind'] as String,
        unitCode = j['unit_code'] as String,
        active = j['active'] as bool,
        imagePath = j['image_path'] as String?,
        barcode = j['barcode'] as String?,
        storage = j['storage'] as String? ?? 'ambient',
        purchaseUnitLabel = j['purchase_unit_label'] as String?,
        purchaseUnitQty = (j['purchase_unit_qty'] as num?)?.toDouble(),
        preferredSupplierId = j['preferred_supplier_id'] as String?,
        shelfLifeDays = (j['shelf_life_days'] as num?)?.toInt();
  final String id;
  final String name;
  final String kind;
  final String unitCode;
  final bool active;
  final String? imagePath;
  final String? barcode;

  /// ambient | chilled | frozen
  final String storage;

  /// Unité d'achat (« Sac de 5 kg ») et sa contenance dans l'unité de stock.
  final String? purchaseUnitLabel;
  final double? purchaseUnitQty;
  final String? preferredSupplierId;
  final int? shelfLifeDays;
}

/// Valeurs d'une fiche article à enregistrer.
class IngredientDraft {
  IngredientDraft({
    required this.name,
    required this.kind,
    required this.unit,
    this.active = true,
    this.imagePath,
    this.barcode,
    this.storage = 'ambient',
    this.purchaseUnitLabel,
    this.purchaseUnitQty,
    this.preferredSupplierId,
    this.shelfLifeDays,
  });
  String name;
  String kind;
  String unit;
  bool active;
  String? imagePath;
  String? barcode;
  String storage;
  String? purchaseUnitLabel;
  double? purchaseUnitQty;
  String? preferredSupplierId;
  int? shelfLifeDays;

  static String? _blank(String? s) => (s == null || s.trim().isEmpty) ? null : s.trim();

  Map<String, dynamic> toJson() => {
        'name': name.trim(),
        'kind': kind,
        'unit_code': unit,
        'active': active,
        'image_path': imagePath,
        'barcode': _blank(barcode),
        'storage': storage,
        'purchase_unit_label': _blank(purchaseUnitLabel),
        'purchase_unit_qty': purchaseUnitQty,
        'preferred_supplier_id': preferredSupplierId,
        'shelf_life_days': shelfLifeDays,
      };
}

/// Tableau de bord du stock d'une période.
class StockDashboard {
  StockDashboard.fromJson(Map<String, dynamic> j)
      : valueMinor = _int(j['value_minor']),
        items = _int(j['items']),
        belowMin = _int(j['below_min']),
        outOfStock = _int(j['out_of_stock']),
        expiring = _int(j['expiring']),
        consumptionMinor = _int(j['consumption_minor']),
        wasteMinor = _int(j['waste_minor']),
        receiptsMinor = _int(j['receipts_minor']),
        inventoryVarianceMinor = _int(j['inventory_variance_minor']),
        byDay = [
          for (final d in (j['by_day'] as List? ?? const []))
            (DateTime.parse((d as Map)['day'] as String), _int(d['consumption']), _int(d['waste']), _int(d['receipts'])),
        ],
        topConsumed = [
          for (final d in (j['top_consumed'] as List? ?? const []))
            ((d as Map)['name'] as String, d['unit_code'] as String, (d['quantity'] as num).toDouble(), _int(d['value'])),
        ],
        wasteReasons = [for (final d in (j['waste_reasons'] as List? ?? const [])) ((d as Map)['reason'] as String, _int(d['value']))];
  final int valueMinor;
  final int items;
  final int belowMin;
  final int outOfStock;
  final int expiring;
  final int consumptionMinor;
  final int wasteMinor;
  final int receiptsMinor;
  final int inventoryVarianceMinor;

  /// (jour, consommation, pertes, réceptions)
  final List<(DateTime, int, int, int)> byDay;

  /// (nom, unité, quantité, valeur)
  final List<(String, String, double, int)> topConsumed;
  final List<(String, int)> wasteReasons;
}

int _int(Object? v) => (v as num? ?? 0).round();

/// Lot encore en stock dont la date limite approche.
class ExpiringLot {
  ExpiringLot.fromJson(Map<String, dynamic> j)
      : ingredientId = j['ingredient_id'] as String,
        name = j['name'] as String,
        unitCode = j['unit_code'] as String,
        batch = j['batch'] as String?,
        expiresOn = DateTime.parse(j['expires_on'] as String),
        remaining = (j['remaining'] as num).toDouble(),
        valueMinor = _int(j['value_minor']);
  final String ingredientId;
  final String name;
  final String unitCode;
  final String? batch;
  final DateTime expiresOn;
  final double remaining;
  final int valueMinor;

  int get daysLeft => expiresOn.difference(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day)).inDays;
}

/// Ligne de commande suggérée.
class ReorderSuggestion {
  ReorderSuggestion.fromJson(Map<String, dynamic> j)
      : ingredientId = j['ingredient_id'] as String,
        name = j['name'] as String,
        unitCode = j['unit_code'] as String,
        quantity = (j['quantity'] as num).toDouble(),
        minQuantity = (j['min_quantity'] as num).toDouble(),
        dailyUse = (j['daily_use'] as num? ?? 0).toDouble(),
        daysLeft = (j['days_left'] as num?)?.toDouble(),
        suggested = (j['suggested'] as num).toDouble(),
        purchaseUnitLabel = j['purchase_unit_label'] as String?,
        purchaseUnitQty = (j['purchase_unit_qty'] as num?)?.toDouble(),
        supplierId = j['supplier_id'] as String?,
        supplierName = j['supplier_name'] as String?,
        lastUnitCost = (j['last_unit_cost'] as num? ?? 0).toDouble();
  final String ingredientId;
  final String name;
  final String unitCode;
  final double quantity;
  final double minQuantity;
  final double dailyUse;
  final double? daysLeft;
  final double suggested;
  final String? purchaseUnitLabel;
  final double? purchaseUnitQty;
  final String? supplierId;
  final String? supplierName;

  /// Coût par unité de stock (unités mineures).
  final double lastUnitCost;
}

class StockLocation {
  StockLocation(this.id, this.name, this.active);
  final String id;
  final String name;
  final bool active;
}

class StockLine {
  StockLine.fromJson(Map<String, dynamic> j)
      : ingredientId = j['ingredient_id'] as String,
        name = j['name'] as String,
        kind = j['kind'] as String,
        unitCode = j['unit_code'] as String,
        quantity = (j['quantity'] as num).toDouble(),
        minQuantity = (j['min_quantity'] as num).toDouble(),
        avgUnitCost = (j['avg_unit_cost'] as num).toDouble(),
        valueMinor = (j['value_minor'] as num).toInt(),
        belowMin = j['below_min'] as bool;
  final String ingredientId;
  final String name;
  final String kind;
  final String unitCode;
  final double quantity;
  final double minQuantity;
  final double avgUnitCost;
  final int valueMinor;
  final bool belowMin;
}

class StockMovement {
  StockMovement.fromJson(Map<String, dynamic> j)
      : kind = j['kind'] as String,
        quantity = (j['quantity'] as num).toDouble(),
        unitCost = (j['unit_cost'] as num? ?? 0).toDouble(),
        ingredientId = j['ingredient_id'] as String? ?? '',
        batch = j['batch'] as String?,
        expiresOn = j['expires_on'] == null ? null : DateTime.parse(j['expires_on'] as String),
        reason = j['reason'] as String?,
        ingredientName = (j['ingredients'] as Map?)?['name'] as String? ?? '',
        unitCode = (j['ingredients'] as Map?)?['unit_code'] as String? ?? '',
        locationName = (j['stock_locations'] as Map?)?['name'] as String? ?? '',
        createdAt = DateTime.parse(j['created_at'] as String);
  final String kind;
  final double quantity;
  final double unitCost;
  final String ingredientId;
  final String? batch;
  final DateTime? expiresOn;
  final String? reason;
  final String ingredientName;

  /// Valeur signée du mouvement (unités mineures).
  double get value => quantity * unitCost;
  final String unitCode;
  final String locationName;
  final DateTime createdAt;
}

class RecipeLine {
  RecipeLine(this.ingredientId, this.quantity, this.unit, this.wastePercent);
  final String ingredientId;
  final double quantity;
  final String unit;
  final double wastePercent;

  Map<String, dynamic> toJson() =>
      {'ingredient_id': ingredientId, 'quantity': quantity, 'unit': unit, 'waste_percent': wastePercent};
}

class Recipe {
  Recipe(this.yieldQuantity, this.lines, this.notes);
  final double yieldQuantity;
  final List<RecipeLine> lines;
  final String? notes;
}

class RecipeCost {
  RecipeCost.fromJson(Map<String, dynamic> j)
      : variantId = j['variant_id'] as String,
        itemName = j['item_name'] as String,
        variantName = j['variant_name'] as String,
        costMinor = (j['cost_minor'] as num?)?.toInt(),
        priceMinor = (j['price_minor'] as num?)?.toInt(),
        hasRecipe = j['has_recipe'] as bool;
  final String variantId;
  final String itemName;
  final String variantName;
  final int? costMinor;
  final int? priceMinor;
  final bool hasRecipe;
}

class InventoryCount {
  InventoryCount.fromJson(Map<String, dynamic> j)
      : id = j['id'] as String,
        locationId = j['location_id'] as String,
        status = j['status'] as String,
        startedAt = DateTime.parse(j['started_at'] as String),
        lines = {
          for (final l in (j['inventory_count_lines'] as List? ?? const []))
            (l as Map)['ingredient_id'] as String: (
              (l['counted_quantity'] as num).toDouble(),
              (l['difference'] as num?)?.toDouble(),
            ),
        };
  final String id;
  final String locationId;
  final String status;
  final DateTime startedAt;
  final Map<String, (double, double?)> lines;
}

const ingredientKinds = ['raw', 'beverage', 'packaging', 'semi_finished', 'consumable'];

class StockApi {
  StockApi(this._db);
  final SupabaseClient _db;

  Future<List<Unit>> units() async {
    final rows = await _db.from('ref_units').select().order('sort_order');
    return [for (final r in rows) Unit(r['code'] as String, r['dimension'] as String, (r['factor'] as num).toDouble())];
  }

  Future<List<Ingredient>> ingredients(String orgId) async {
    final rows = await _db.from('ingredients').select().eq('organization_id', orgId).order('name');
    return [for (final r in rows) Ingredient.fromJson(r)];
  }

  Future<void> saveIngredient({required String orgId, String? id, required String name, required String kind, required String unit, required bool active}) {
    final values = {'name': name.trim(), 'kind': kind, 'unit_code': unit, 'active': active};
    if (id == null) return _db.from('ingredients').insert({...values, 'organization_id': orgId});
    return _db.from('ingredients').update(values).eq('id', id);
  }

  /// Fiche article complète (création ou modification).
  Future<void> saveArticle(String orgId, String? id, IngredientDraft d) {
    if (id == null) return _db.from('ingredients').insert({...d.toJson(), 'organization_id': orgId});
    return _db.from('ingredients').update(d.toJson()).eq('id', id);
  }

  static const imageBucket = 'stock-images';

  String imageUrl(String path) => _db.storage.from(imageBucket).getPublicUrl(path);

  Future<String> uploadImage(String orgId, Uint8List bytes, String extension) async {
    final ext = extension.toLowerCase() == 'jpg' ? 'jpeg' : extension.toLowerCase();
    // 1 << 32 vaut 0 dans un navigateur (opérations sur 32 bits) : nextInt échouait sur le Web.
    final rnd = Random.secure().nextInt(0x3fffffff).toRadixString(36);
    final path = '$orgId/${DateTime.now().millisecondsSinceEpoch}-$rnd.${ext == 'jpeg' ? 'jpg' : ext}';
    await _db.storage.from(imageBucket).uploadBinary(path, bytes, fileOptions: FileOptions(contentType: 'image/$ext'));
    return path;
  }

  Future<StockDashboard> dashboard(String branchId, DateTime from, DateTime to) async => StockDashboard.fromJson(
      (await _db.rpc('stock_dashboard', params: {'p_branch': branchId, 'p_from': _day(from), 'p_to': _day(to)}) as Map).cast());

  Future<List<ExpiringLot>> expiring(String branchId, {int days = 7}) async {
    final rows = await _db.rpc('stock_expiring', params: {'p_branch': branchId, 'p_days': days}) as List;
    return [for (final r in rows) ExpiringLot.fromJson((r as Map).cast())];
  }

  Future<List<ReorderSuggestion>> reorder(String branchId, {int coverDays = 7}) async {
    final rows = await _db.rpc('reorder_suggestions', params: {'p_branch': branchId, 'p_cover_days': coverDays}) as List;
    return [for (final r in rows) ReorderSuggestion.fromJson((r as Map).cast())];
  }

  /// Mouvements d'une période (rapports), du plus récent au plus ancien.
  Future<List<StockMovement>> movementsBetween(String branchId, DateTime from, DateTime to, {List<String>? kinds}) async {
    var q = _db
        .from('stock_movements')
        .select('kind, quantity, unit_cost, ingredient_id, batch, expires_on, reason, created_at, ingredients(name, unit_code), stock_locations(name)')
        .eq('branch_id', branchId)
        .gte('created_at', DateTime(from.year, from.month, from.day).toUtc().toIso8601String())
        .lt('created_at', DateTime(to.year, to.month, to.day + 1).toUtc().toIso8601String());
    if (kinds != null && kinds.isNotEmpty) q = q.inFilter('kind', kinds);
    final rows = await q.order('created_at', ascending: false).limit(5000);
    return [for (final r in rows) StockMovement.fromJson(r)];
  }

  Future<void> setTargetFoodCost(String branchId, double percent) =>
      _db.from('branches').update({'target_food_cost_percent': percent}).eq('id', branchId);

  static String _day(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<List<StockLocation>> locations(String branchId) async {
    final rows = await _db.from('stock_locations').select('id, name, active').eq('branch_id', branchId).order('sort_order').order('created_at');
    return [for (final r in rows) StockLocation(r['id'] as String, r['name'] as String, r['active'] as bool)];
  }

  Future<void> addLocation(String orgId, String branchId, String name) =>
      _db.from('stock_locations').insert({'organization_id': orgId, 'branch_id': branchId, 'name': name.trim()});

  Future<List<StockLine>> overview(String branchId) async {
    final rows = await _db.rpc('stock_overview', params: {'p_branch': branchId}) as List;
    return [for (final r in rows) StockLine.fromJson((r as Map).cast())];
  }

  Future<List<StockMovement>> movements(String branchId, {int limit = 100}) async {
    final rows = await _db
        .from('stock_movements')
        .select('kind, quantity, unit_cost, ingredient_id, batch, expires_on, reason, created_at, ingredients(name, unit_code), stock_locations(name)')
        .eq('branch_id', branchId)
        .order('created_at', ascending: false)
        .limit(limit);
    return [for (final r in rows) StockMovement.fromJson(r)];
  }

  Future<void> movement({
    required String branchId,
    required String locationId,
    required String ingredientId,
    required String kind,
    required double quantity,
    required String unit,
    double unitCost = 0,
    String? reason,
    String? batch,
    DateTime? expiresOn,
    required String clientId,
  }) =>
      _db.rpc('record_stock_movement', params: {
        'p_batch': batch,
        'p_expires_on': expiresOn == null ? null : _day(expiresOn),
        'p_branch': branchId,
        'p_location': locationId,
        'p_ingredient': ingredientId,
        'p_kind': kind,
        'p_quantity': quantity,
        'p_unit': unit,
        'p_unit_cost': unitCost,
        'p_reason': reason,
        'p_client_id': clientId,
      });

  Future<void> transfer(String fromLocation, String toLocation, String ingredientId, double quantity, String unit,
          String? reason, String clientId) =>
      _db.rpc('transfer_stock', params: {
        'p_from_location': fromLocation,
        'p_to_location': toLocation,
        'p_ingredient': ingredientId,
        'p_quantity': quantity,
        'p_unit': unit,
        'p_reason': reason,
        'p_client_id': clientId,
      });

  Future<void> produce(String branchId, String locationId, String ingredientId, double quantity, String clientId) =>
      _db.rpc('record_production', params: {
        'p_branch': branchId,
        'p_location': locationId,
        'p_ingredient': ingredientId,
        'p_quantity': quantity,
        'p_client_id': clientId,
      });

  Future<void> setThreshold(String branchId, String ingredientId, double min) =>
      _db.rpc('set_stock_threshold', params: {'p_branch': branchId, 'p_ingredient': ingredientId, 'p_min': min});

  /// Fiche en vigueur d'une variante, d'une option ou d'une préparation.
  Future<Recipe?> currentRecipe({String? variantId, String? modifierId, String? ingredientId}) async {
    var q = _db.from('recipe_versions').select('yield_quantity, notes, recipe_lines(ingredient_id, quantity, unit_code, waste_percent, sort_order)').isFilter('valid_to', null);
    if (variantId != null) q = q.eq('variant_id', variantId);
    if (modifierId != null) q = q.eq('modifier_id', modifierId);
    if (ingredientId != null) q = q.eq('ingredient_id', ingredientId);
    final row = await q.maybeSingle();
    if (row == null) return null;
    final lines = (row['recipe_lines'] as List).cast<Map<String, dynamic>>()
      ..sort((a, b) => (a['sort_order'] as num).compareTo(b['sort_order'] as num));
    return Recipe(
      (row['yield_quantity'] as num).toDouble(),
      [
        for (final l in lines)
          RecipeLine(l['ingredient_id'] as String, (l['quantity'] as num).toDouble(), l['unit_code'] as String,
              (l['waste_percent'] as num).toDouble()),
      ],
      row['notes'] as String?,
    );
  }

  Future<void> saveRecipe({String? variantId, String? modifierId, String? ingredientId, required double yieldQuantity, required List<RecipeLine> lines, String? notes}) =>
      _db.rpc('save_recipe', params: {
        'p_variant': variantId,
        'p_modifier': modifierId,
        'p_ingredient': ingredientId,
        'p_yield': yieldQuantity,
        'p_lines': [for (final l in lines) l.toJson()],
        'p_notes': notes,
      });

  Future<List<RecipeCost>> recipeCosts(String branchId) async {
    final rows = await _db.rpc('recipe_costs', params: {'p_branch': branchId}) as List;
    return [for (final r in rows) RecipeCost.fromJson((r as Map).cast())];
  }

  Future<List<InventoryCount>> inventories(String branchId) async {
    final rows = await _db
        .from('inventory_counts')
        .select('id, location_id, status, started_at, inventory_count_lines(ingredient_id, counted_quantity, difference)')
        .eq('branch_id', branchId)
        .neq('status', 'cancelled')
        .order('started_at', ascending: false)
        .limit(20);
    return [for (final r in rows) InventoryCount.fromJson(r)];
  }

  Future<String> startInventory(String locationId, String clientId) async =>
      await _db.rpc('start_inventory', params: {'p_location': locationId, 'p_client_id': clientId}) as String;

  Future<void> countLine(String countId, String ingredientId, double counted, String unit) => _db.rpc('save_inventory_line',
      params: {'p_count': countId, 'p_ingredient': ingredientId, 'p_counted': counted, 'p_unit': unit});

  Future<int> validateInventory(String countId) async =>
      (await _db.rpc('validate_inventory', params: {'p_count': countId}) as num).toInt();
}
