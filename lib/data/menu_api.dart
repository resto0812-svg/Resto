import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'menu_models.dart';

/// Accès aux menus. Catalogue : écritures sous RLS (menus.manage sur toute
/// l'organisation) ; prix : uniquement par la fonction set_price (historique).
class MenuApi {
  MenuApi(this._db);
  final SupabaseClient _db;

  Future<List<Brand>> brands(String orgId) async {
    final rows = await _db.from('brands').select('id, name').eq('organization_id', orgId).eq('status', 'active').order('created_at');
    return [for (final r in rows) Brand(r['id'] as String, r['name'] as String)];
  }

  Future<BrandMenu> load(String brandId) async {
    final r = await Future.wait<dynamic>([
      _db
          .from('menu_categories')
          .select('*, menu_category_translations(locale, name, description)')
          .eq('brand_id', brandId)
          .order('sort_order')
          .order('name'),
      _db
          .from('menu_items')
          .select(
            '*, item_variants(*, item_variant_translations(locale, name)), item_modifier_groups(group_id), '
            'item_allergens(allergen_code), menu_item_translations(locale, name, description)',
          )
          .eq('brand_id', brandId)
          .order('sort_order')
          .order('name'),
      _db
          .from('modifier_groups')
          .select('*, modifiers(*, modifier_translations(locale, name)), modifier_group_translations(locale, name)')
          .eq('brand_id', brandId)
          .order('sort_order')
          .order('name'),
    ]);
    return BrandMenu(
      [for (final c in r[0] as List) MenuCategory.fromJson((c as Map).cast<String, dynamic>())],
      [for (final i in r[1] as List) MenuItem.fromJson((i as Map).cast<String, dynamic>())],
      [for (final g in r[2] as List) ModifierGroup.fromJson((g as Map).cast<String, dynamic>())],
    );
  }

  // ------------------------------------------------------------ catégories

  Future<void> saveCategory({
    required String orgId,
    required String brandId,
    String? id,
    required String name,
    String? description,
    int? sortOrder,
    bool active = true,
  }) {
    final values = {'name': name.trim(), 'description': _blank(description), 'active': active, 'sort_order': ?sortOrder};
    if (id == null) {
      return _db.from('menu_categories').insert({...values, 'organization_id': orgId, 'brand_id': brandId});
    }
    return _db.from('menu_categories').update(values).eq('id', id);
  }

  // ------------------------------------------------------------ articles

  Future<String> createItem(String categoryId, String name, String? description, String kind) async => await _db.rpc(
    'create_menu_item',
    params: {'p_category': categoryId, 'p_name': name.trim(), 'p_description': _blank(description), 'p_kind': kind},
  ) as String;

  Future<void> updateItem(
    String id, {
    required String categoryId,
    required String name,
    String? description,
    required String kind,
    required bool active,
  }) => _db
      .from('menu_items')
      .update({'category_id': categoryId, 'name': name.trim(), 'description': _blank(description), 'kind': kind, 'active': active})
      .eq('id', id);

  Future<void> saveVariant({
    required String orgId,
    required String brandId,
    required String itemId,
    String? id,
    String? newId,
    required String name,
    bool active = true,
  }) {
    if (id == null) {
      return _db.from('item_variants').insert({
        'id': ?newId,
        'organization_id': orgId,
        'brand_id': brandId,
        'item_id': itemId,
        'name': name.trim(),
        'active': active,
      });
    }
    return _db.from('item_variants').update({'name': name.trim(), 'active': active}).eq('id', id);
  }

  Future<List<(String, String)>> variantsOf(String itemId) async {
    final rows = await _db.from('item_variants').select('id, name').eq('item_id', itemId).order('sort_order');
    return [for (final r in rows) (r['id'] as String, r['name'] as String)];
  }

  /// Remplace l'ensemble des groupes d'options proposés sur l'article.
  Future<void> setItemGroups({
    required String orgId,
    required String brandId,
    required String itemId,
    required Set<String> current,
    required Set<String> wanted,
  }) async {
    final remove = current.difference(wanted);
    final add = wanted.difference(current);
    if (remove.isNotEmpty) {
      await _db.from('item_modifier_groups').delete().eq('item_id', itemId).inFilter('group_id', remove.toList());
    }
    if (add.isNotEmpty) {
      await _db.from('item_modifier_groups').insert([
        for (final g in add) {'organization_id': orgId, 'brand_id': brandId, 'item_id': itemId, 'group_id': g},
      ]);
    }
  }

  Future<void> setAllergens({
    required String orgId,
    required String itemId,
    required Set<String> current,
    required Set<String> wanted,
  }) async {
    final remove = current.difference(wanted);
    final add = wanted.difference(current);
    if (remove.isNotEmpty) {
      await _db.from('item_allergens').delete().eq('item_id', itemId).inFilter('allergen_code', remove.toList());
    }
    if (add.isNotEmpty) {
      await _db.from('item_allergens').insert([
        for (final a in add) {'organization_id': orgId, 'item_id': itemId, 'allergen_code': a},
      ]);
    }
  }

  // ------------------------------------------------------------ suppléments

  Future<void> saveGroup({
    required String orgId,
    required String brandId,
    String? id,
    String? newId,
    required String name,
    required int minSelect,
    int? maxSelect,
    bool active = true,
  }) {
    final values = {'name': name.trim(), 'min_select': minSelect, 'max_select': maxSelect, 'active': active};
    if (id == null) {
      return _db.from('modifier_groups').insert({...values, 'id': ?newId, 'organization_id': orgId, 'brand_id': brandId});
    }
    return _db.from('modifier_groups').update(values).eq('id', id);
  }

  Future<void> saveModifier({
    required String orgId,
    required String brandId,
    required String groupId,
    String? id,
    String? newId,
    required String name,
    bool active = true,
  }) {
    if (id == null) {
      return _db.from('modifiers').insert({
        'id': ?newId,
        'organization_id': orgId,
        'brand_id': brandId,
        'group_id': groupId,
        'name': name.trim(),
        'active': active,
      });
    }
    return _db.from('modifiers').update({'name': name.trim(), 'active': active}).eq('id', id);
  }

  // ------------------------------------------------------------ traductions

  /// table : menu_category_translations, menu_item_translations,
  /// item_variant_translations, modifier_group_translations, modifier_translations.
  Future<void> saveTranslation({
    required String table,
    required String keyColumn,
    required String orgId,
    required String entityId,
    required String locale,
    required String? name,
    String? description,
    bool withDescription = false,
  }) {
    if (name == null || name.trim().isEmpty) {
      return _db.from(table).delete().eq(keyColumn, entityId).eq('locale', locale);
    }
    return _db.from(table).upsert({
      'organization_id': orgId,
      keyColumn: entityId,
      'locale': locale,
      'name': name.trim(),
      if (withDescription) 'description': _blank(description),
    }, onConflict: '$keyColumn,locale');
  }

  // ------------------------------------------------------------ établissement

  Future<BranchMenuState> branchState(String branchId) async {
    final r = await Future.wait<dynamic>([
      _db.from('menu_item_branches').select('*').eq('branch_id', branchId),
      _db.from('prices').select('variant_id, modifier_id, channel, amount_minor').eq('branch_id', branchId).isFilter('valid_to', null),
    ]);
    return BranchMenuState(
      {for (final o in r[0] as List) o['item_id'] as String: o['available'] as bool},
      stock: {
        for (final o in r[0] as List)
          if (o['stock_qty'] != null)
            o['item_id'] as String: ((o['stock_qty'] as num).toInt(), (o['low_stock_threshold'] as num? ?? 5).toInt()),
      },
      {
        for (final p in r[1] as List)
          ((p['variant_id'] ?? p['modifier_id']) as String, p['channel'] as String): (p['amount_minor'] as num).toInt(),
      },
    );
  }

  Future<void> setOffered({
    required String orgId,
    required String brandId,
    required String itemId,
    required String branchId,
    required bool offered,
  }) {
    if (!offered) {
      return _db.from('menu_item_branches').delete().eq('item_id', itemId).eq('branch_id', branchId);
    }
    return _db.from('menu_item_branches').insert({
      'organization_id': orgId,
      'brand_id': brandId,
      'item_id': itemId,
      'branch_id': branchId,
      'available': true,
    });
  }

  Future<void> setAvailable(String itemId, String branchId, bool available) =>
      _db.from('menu_item_branches').update({'available': available}).eq('item_id', itemId).eq('branch_id', branchId);

  /// amountMinor null = retirer le prix (il reste dans l'historique).
  Future<void> setPrice({
    required String branchId,
    String? variantId,
    String? modifierId,
    required String channel,
    required int? amountMinor,
  }) => _db.rpc(
    'set_price',
    params: {'p_branch': branchId, 'p_variant': variantId, 'p_modifier': modifierId, 'p_channel': channel, 'p_amount': amountMinor},
  );

  // ------------------------------------------------------------ médias, stock, copie

  static const imageBucket = 'menu-images';
  static const videoBucket = 'menu-videos';

  String imageUrl(String path) => _db.storage.from(imageBucket).getPublicUrl(path);
  String videoUrl(String path) => _db.storage.from(videoBucket).getPublicUrl(path);

  /// Envoie une photo de l'article ({organisation}/{article}/…) ; renvoie son chemin.
  Future<String> uploadItemImage(String orgId, String itemId, Uint8List bytes, String extension) async {
    final ext = extension.toLowerCase() == 'jpg' ? 'jpeg' : extension.toLowerCase();
    final path = '$orgId/$itemId/${DateTime.now().millisecondsSinceEpoch}.${ext == 'jpeg' ? 'jpg' : ext}';
    await _db.storage.from(imageBucket).uploadBinary(path, bytes, fileOptions: FileOptions(contentType: 'image/$ext'));
    return path;
  }

  Future<String> uploadItemVideo(String orgId, String itemId, Uint8List bytes, String extension) async {
    final ext = extension.toLowerCase();
    final type = switch (ext) {
      'webm' => 'video/webm',
      'mov' => 'video/quicktime',
      _ => 'video/mp4',
    };
    final path = '$orgId/$itemId/${DateTime.now().millisecondsSinceEpoch}.$ext';
    await _db.storage.from(videoBucket).uploadBinary(path, bytes, fileOptions: FileOptions(contentType: type));
    return path;
  }

  /// Photo principale + galerie (4 au plus) + vidéo ; supprime les fichiers retirés.
  Future<void> setItemMedia(
    String itemId, {
    String? imagePath,
    List<String> gallery = const [],
    String? videoPath,
    List<String> removed = const [],
  }) async {
    await _db
        .from('menu_items')
        .update({'image_path': imagePath, 'gallery_paths': gallery.take(4).toList(), 'video_path': videoPath})
        .eq('id', itemId);
    final images = removed.where((p) => !p.endsWith('.mp4') && !p.endsWith('.webm') && !p.endsWith('.mov')).toList();
    final videos = removed.where((p) => !images.contains(p)).toList();
    if (images.isNotEmpty) await _db.storage.from(imageBucket).remove(images).catchError((_) => <FileObject>[]);
    if (videos.isNotEmpty) await _db.storage.from(videoBucket).remove(videos).catchError((_) => <FileObject>[]);
  }

  /// Avis des clients sur un article (y compris masqués), pour la modération.
  Future<List<Map<String, dynamic>>> itemReviews(String itemId) async =>
      (await _db
              .from('item_reviews')
              .select('id, rating, comment, photo_paths, author_name, helpful_count, reports_count, status, hidden_reason, created_at')
              .eq('item_id', itemId)
              .order('created_at', ascending: false)
              .limit(100))
          .cast<Map<String, dynamic>>();

  Future<void> moderateReview(String reviewId, bool hidden, {String? reason}) =>
      _db.rpc('moderate_item_review', params: {'p_review': reviewId, 'p_hidden': hidden, 'p_reason': reason});

  /// Indicateurs des articles d'un établissement (avis, favoris, ventes).
  /// Vide tant que la base n'expose pas encore ces indicateurs.
  Future<Map<String, ItemStats>> itemStats(String branchId) async {
    try {
      final r = await _db.rpc('menu_item_stats', params: {'p_branch': branchId});
      return {for (final e in (r as Map).entries) e.key as String: ItemStats.fromJson((e.value as Map).cast<String, dynamic>())};
    } on PostgrestException {
      return const {};
    }
  }

  static final _thumbs = <String, Uint8List?>{};

  /// Description et photo (téléchargée une fois) des articles d'un ticket.
  /// [thumb] réduit la photo ; un article illisible reste sans photo.
  Future<Map<String, (String?, Uint8List?)>> ticketItems(
    Iterable<String> ids, {
    required bool photos,
    required Future<Uint8List?> Function(Uint8List) thumb,
  }) async {
    final list = ids.toSet().toList();
    if (list.isEmpty) return const {};
    try {
      final rows = (await _db.from('menu_items').select('id, description, image_path').inFilter('id', list)).cast<Map<String, dynamic>>();
      final out = <String, (String?, Uint8List?)>{};
      await Future.wait(
        rows.map((r) async {
          final path = r['image_path'] as String?;
          Uint8List? photo;
          if (photos && path != null) {
            if (_thumbs.containsKey(path)) {
              photo = _thumbs[path];
            } else {
              try {
                final raw = await _db.storage.from(imageBucket).download(path).timeout(const Duration(seconds: 6));
                photo = _thumbs[path] = await thumb(raw);
              } catch (_) {
                photo = null;
              }
            }
          }
          out[r['id'] as String] = (r['description'] as String?, photo);
        }),
      );
      return out;
    } catch (_) {
      return const {};
    }
  }

  /// Avis libres des clients sur un article (y compris masqués), pour la modération.
  Future<List<Map<String, dynamic>>> itemComments(String itemId) async {
    try {
      return (await _db
              .from('item_comments')
              .select('id, author_name, body, status, hidden_reason, created_at')
              .eq('item_id', itemId)
              .order('created_at', ascending: false)
              .limit(100))
          .cast<Map<String, dynamic>>();
    } on PostgrestException {
      return const [];
    }
  }

  Future<void> moderateItemComment(String commentId, bool hidden, {String? reason}) =>
      _db.rpc('moderate_item_comment', params: {'p_comment': commentId, 'p_hidden': hidden, 'p_reason': reason});

  /// Article visible ou masqué sur la carte.
  Future<void> setItemActive(String itemId, bool active) => _db.from('menu_items').update({'active': active}).eq('id', itemId);

  /// Temps de préparation et jours de vente (null = tous les jours).
  Future<void> setItemService(String itemId, {int? prepMinutes, List<int>? availableDays, List<String> tags = const []}) => _db
      .from('menu_items')
      .update({
        'prep_minutes': prepMinutes,
        'tags': tags,
        'available_days': (availableDays == null || availableDays.length == 7) ? null : availableDays,
      })
      .eq('id', itemId);

  /// Stock du jour dans un établissement (null = non suivi).
  Future<void> setStock(String itemId, String branchId, int? quantity, {int? threshold}) {
    final values = <String, dynamic>{'stock_qty': quantity, 'low_stock_threshold': ?threshold};
    if (quantity != null) values['available'] = quantity > 0;
    return _db.from('menu_item_branches').update(values).eq('item_id', itemId).eq('branch_id', branchId);
  }

  /// Copie de l'article (masquée jusqu'à relecture) ; renvoie son identifiant.
  Future<String> duplicate(String itemId, String suffix) async =>
      await _db.rpc('duplicate_menu_item', params: {'p_item': itemId, 'p_suffix': suffix}) as String;

  static String? _blank(String? s) => (s == null || s.trim().isEmpty) ? null : s.trim();
}
