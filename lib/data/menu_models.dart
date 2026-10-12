/// Menus : catalogue d'une marque et données propres à un établissement.
library;

/// Traduction d'un contenu (nom, éventuellement description) dans une langue.
class ContentTranslation {
  const ContentTranslation(this.name, [this.description]);
  final String name;
  final String? description;
}

Map<String, ContentTranslation> _translations(Object? rows) => {
      for (final r in (rows as List? ?? const []))
        (r as Map)['locale'] as String: ContentTranslation(r['name'] as String, r['description'] as String?),
    };

class MenuCategory {
  MenuCategory.fromJson(Map<String, dynamic> j)
      : id = j['id'] as String,
        brandId = j['brand_id'] as String,
        name = j['name'] as String,
        description = j['description'] as String?,
        sortOrder = (j['sort_order'] as num).toInt(),
        active = j['active'] as bool,
        translations = _translations(j['menu_category_translations']);

  final String id;
  final String brandId;
  final String name;
  final String? description;
  final int sortOrder;
  final bool active;
  final Map<String, ContentTranslation> translations;
}

class ItemVariant {
  ItemVariant.fromJson(Map<String, dynamic> j)
      : id = j['id'] as String,
        name = j['name'] as String,
        sortOrder = (j['sort_order'] as num).toInt(),
        active = j['active'] as bool,
        translations = _translations(j['item_variant_translations']);

  final String id;
  final String name;
  final int sortOrder;
  final bool active;
  final Map<String, ContentTranslation> translations;
}

class MenuItem {
  MenuItem.fromJson(Map<String, dynamic> j)
      : id = j['id'] as String,
        brandId = j['brand_id'] as String,
        categoryId = j['category_id'] as String,
        name = j['name'] as String,
        description = j['description'] as String?,
        kind = j['kind'] as String,
        sortOrder = (j['sort_order'] as num).toInt(),
        active = j['active'] as bool,
        imagePath = j['image_path'] as String?,
        galleryPaths = [for (final p in (j['gallery_paths'] as List? ?? const [])) p as String],
        videoPath = j['video_path'] as String?,
        prepMinutes = (j['prep_minutes'] as num?)?.toInt(),
        availableDays = (j['available_days'] as List?)?.map((d) => (d as num).toInt()).toList(),
        tags = ((j['tags'] as List?) ?? const []).cast<String>(),
        variants = [
          for (final v in (j['item_variants'] as List? ?? const []))
            ItemVariant.fromJson((v as Map).cast<String, dynamic>()),
        ]..sort((a, b) => a.sortOrder != b.sortOrder ? a.sortOrder - b.sortOrder : a.name.compareTo(b.name)),
        groupIds = {for (final g in (j['item_modifier_groups'] as List? ?? const [])) (g as Map)['group_id'] as String},
        allergens = {for (final a in (j['item_allergens'] as List? ?? const [])) (a as Map)['allergen_code'] as String},
        translations = _translations(j['menu_item_translations']);

  final String id;
  final String brandId;
  final String categoryId;
  final String name;
  final String? description;
  final String kind;
  final int sortOrder;
  final bool active;

  /// Photo principale (bucket public « menu-images »).
  final String? imagePath;

  /// Autres photos (4 au plus) et vidéo de présentation.
  final List<String> galleryPaths;
  final String? videoPath;

  /// Temps de préparation (minutes) et jours de vente (1 = lundi … 7 ; null = tous).
  final int? prepMinutes;
  final List<int>? availableDays;

  /// Étiquettes libres du restaurant (filtres de la carte côté client).
  final List<String> tags;

  /// Toutes les photos, la principale en premier.
  List<String> get photos => [?imagePath, ...galleryPaths];
  final List<ItemVariant> variants;
  final Set<String> groupIds;
  final Set<String> allergens;
  final Map<String, ContentTranslation> translations;
}

class Modifier {
  Modifier.fromJson(Map<String, dynamic> j)
      : id = j['id'] as String,
        groupId = j['group_id'] as String,
        name = j['name'] as String,
        sortOrder = (j['sort_order'] as num).toInt(),
        active = j['active'] as bool,
        translations = _translations(j['modifier_translations']);

  final String id;
  final String groupId;
  final String name;
  final int sortOrder;
  final bool active;
  final Map<String, ContentTranslation> translations;
}

class ModifierGroup {
  ModifierGroup.fromJson(Map<String, dynamic> j)
      : id = j['id'] as String,
        brandId = j['brand_id'] as String,
        name = j['name'] as String,
        minSelect = (j['min_select'] as num).toInt(),
        maxSelect = (j['max_select'] as num?)?.toInt(),
        sortOrder = (j['sort_order'] as num).toInt(),
        active = j['active'] as bool,
        modifiers = [
          for (final m in (j['modifiers'] as List? ?? const [])) Modifier.fromJson((m as Map).cast<String, dynamic>()),
        ]..sort((a, b) => a.sortOrder != b.sortOrder ? a.sortOrder - b.sortOrder : a.name.compareTo(b.name)),
        translations = _translations(j['modifier_group_translations']);

  final String id;
  final String brandId;
  final String name;
  final int minSelect;
  final int? maxSelect;
  final int sortOrder;
  final bool active;
  final List<Modifier> modifiers;
  final Map<String, ContentTranslation> translations;
}

/// Catalogue complet d'une marque.
class BrandMenu {
  BrandMenu(this.categories, this.items, this.groups);
  final List<MenuCategory> categories;
  final List<MenuItem> items;
  final List<ModifierGroup> groups;

  List<MenuItem> itemsOf(String categoryId) => items.where((i) => i.categoryId == categoryId).toList();
}

/// Indicateurs d'un article pour l'équipe : note des avis vérifiés,
/// clients qui l'ont en favori, ventes des 30 derniers jours.
class ItemStats {
  const ItemStats({this.rating, this.reviews = 0, this.favorites = 0, this.sold30d = 0, this.views = 0, this.likes = 0, this.comments = 0});

  factory ItemStats.fromJson(Map<String, dynamic> j) => ItemStats(
        rating: (j['rating'] as num?)?.toDouble(),
        reviews: (j['reviews'] as num?)?.toInt() ?? 0,
        favorites: (j['favorites'] as num?)?.toInt() ?? 0,
        sold30d: (j['sold_30d'] as num?)?.toInt() ?? 0,
        views: (j['views'] as num?)?.toInt() ?? 0,
        likes: (j['likes'] as num?)?.toInt() ?? 0,
        comments: (j['comments'] as num?)?.toInt() ?? 0,
      );

  final double? rating;
  final int reviews;
  final int favorites;
  final int sold30d;
  final int views;
  final int likes;
  final int comments;
}

/// Prix et disponibilité d'un établissement.
class BranchMenuState {
  BranchMenuState(this.offered, this.prices, {this.stock = const {}});

  /// itemId → (stock du jour, seuil d'alerte) pour les articles suivis.
  final Map<String, (int, int)> stock;

  /// itemId → disponible (absent = article non proposé dans l'établissement).
  final Map<String, bool> offered;

  /// (variantId ou modifierId, canal) → montant en unités mineures.
  final Map<(String, String), int> prices;
}

class Brand {
  const Brand(this.id, this.name);
  final String id;
  final String name;
}

const priceChannels = ['default', 'dine_in', 'takeaway', 'delivery'];
const itemKinds = ['food', 'drink', 'dessert', 'menu', 'other'];
const allergenCodes = [
  'gluten', 'crustaceans', 'eggs', 'fish', 'peanuts', 'soybeans', 'milk', //
  'nuts', 'celery', 'mustard', 'sesame', 'sulphites', 'lupin', 'molluscs',
];
