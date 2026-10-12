import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_setup.dart' show readViewerKey;

/// Espace client : catalogue public (sans compte), commandes en ligne,
/// suivi, avis, favoris, adresses, réservations, fidélité.

/// Texte traduit : traduction de la langue demandée si elle existe.
String tr(Map<String, dynamic>? translations, String locale, String base, [String field = 'name']) {
  final t = translations?[locale];
  if (t is String && t.isNotEmpty) return t;
  if (t is Map && (t[field] as String?)?.isNotEmpty == true) return t[field] as String;
  return base;
}

class BranchSummary {
  BranchSummary.fromJson(Map<String, dynamic> j)
    : branchId = j['branch_id'] as String,
      branchName = j['branch_name'] as String,
      brandName = j['brand_name'] as String,
      city = j['city'] as String,
      address = j['address_line1'] as String?,
      cuisines = ((j['cuisines'] as List?) ?? const []).cast<String>(),
      priceLevel = (j['price_level'] as num?)?.toInt(),
      description = j['description'] as String?,
      rating = (j['rating'] as num?)?.toDouble(),
      reviewsCount = (j['reviews_count'] as num? ?? 0).toInt(),
      openNow = j['open_now'] as bool? ?? false,
      acceptsOnlineOrders = j['accepts_online_orders'] as bool? ?? false,
      acceptsDelivery = j['accepts_delivery'] as bool? ?? false;
  final String branchId;
  final String branchName;
  final String brandName;
  final String city;
  final String? address;
  final List<String> cuisines;
  final int? priceLevel;
  final String? description;
  final double? rating;
  final int reviewsCount;
  final bool openNow;
  final bool acceptsOnlineOrders;
  final bool acceptsDelivery;
}

class PublicModifier {
  PublicModifier.fromJson(Map<String, dynamic> j)
    : id = j['id'] as String,
      name = j['name'] as String,
      translations = (j['translations'] as Map?)?.cast<String, dynamic>() ?? const {},
      prices = {for (final e in ((j['prices'] as Map?) ?? const {}).entries) e.key as String: (e.value as num).toInt()};
  final String id;
  final String name;
  final Map<String, dynamic> translations;
  final Map<String, int> prices;
  int priceFor(String channel) => prices[channel] ?? prices['default'] ?? 0;
}

class PublicGroup {
  PublicGroup.fromJson(Map<String, dynamic> j)
    : id = j['id'] as String,
      name = j['name'] as String,
      minSelect = (j['min_select'] as num).toInt(),
      maxSelect = (j['max_select'] as num?)?.toInt(),
      translations = (j['translations'] as Map?)?.cast<String, dynamic>() ?? const {},
      modifiers = [for (final m in (j['modifiers'] as List? ?? const [])) PublicModifier.fromJson((m as Map).cast())];
  final String id;
  final String name;
  final int minSelect;
  final int? maxSelect;
  final Map<String, dynamic> translations;
  final List<PublicModifier> modifiers;
}

class PublicVariant {
  PublicVariant.fromJson(Map<String, dynamic> j)
    : id = j['id'] as String,
      name = j['name'] as String,
      translations = (j['translations'] as Map?)?.cast<String, dynamic>() ?? const {},
      prices = {for (final e in ((j['prices'] as Map?) ?? const {}).entries) e.key as String: (e.value as num).toInt()};
  final String id;
  final String name;
  final Map<String, dynamic> translations;
  final Map<String, int> prices;
  int? priceFor(String channel) => prices[channel] ?? prices['default'];
}

class PublicItem {
  PublicItem.fromJson(Map<String, dynamic> j)
    : id = j['id'] as String,
      name = j['name'] as String,
      description = j['description'] as String?,
      kind = j['kind'] as String,
      imagePath = j['image_path'] as String?,
      galleryPaths = ((j['gallery_paths'] as List?) ?? const []).cast<String>(),
      videoPath = j['video_path'] as String?,
      prepMinutes = (j['prep_minutes'] as num?)?.toInt(),
      soldOut = j['sold_out'] as bool? ?? false,
      allergens = ((j['allergens'] as List?) ?? const []).cast<String>(),
      tags = ((j['tags'] as List?) ?? const []).cast<String>(),
      sold30d = (j['sold_30d'] as num? ?? 0).toInt(),
      bestSeller = j['best_seller'] as bool? ?? false,
      favorites = (j['favorites'] as num? ?? 0).toInt(),
      rating = (j['rating'] as num?)?.toDouble(),
      reviewsCount = (j['reviews_count'] as num? ?? 0).toInt(),
      translations = (j['translations'] as Map?)?.cast<String, dynamic>() ?? const {},
      variants = [for (final v in (j['variants'] as List? ?? const [])) PublicVariant.fromJson((v as Map).cast())],
      groups = [for (final g in (j['groups'] as List? ?? const [])) PublicGroup.fromJson((g as Map).cast())];
  final String id;
  final String name;
  final String? description;
  final String kind;
  final String? imagePath;
  final List<String> galleryPaths;
  final String? videoPath;
  final int? prepMinutes;
  final bool soldOut;
  final List<String> allergens;

  /// Étiquettes créées par le restaurant (« Piment doux », « Halal », « Sans alcool »…) : filtres de la carte.
  final List<String> tags;
  final int sold30d;
  final bool bestSeller;

  /// Clients qui ont ce plat en favori.
  final int favorites;
  final double? rating;
  final int reviewsCount;

  List<String> get photos => [?imagePath, ...galleryPaths];

  /// Prix le plus bas (canal donné, sinon prix de base).
  int? fromPrice(String channel) {
    final prices = [for (final v in variants) ?v.priceFor(channel)];
    return prices.isEmpty ? null : prices.reduce((a, b) => a < b ? a : b);
  }

  final Map<String, dynamic> translations;
  final List<PublicVariant> variants;
  final List<PublicGroup> groups;
}

class PublicCategory {
  PublicCategory.fromJson(Map<String, dynamic> j)
    : id = j['id'] as String,
      name = j['name'] as String,
      description = j['description'] as String?,
      translations = (j['translations'] as Map?)?.cast<String, dynamic>() ?? const {},
      items = [for (final i in (j['items'] as List? ?? const [])) PublicItem.fromJson((i as Map).cast())];
  final String id;
  final String name;
  final String? description;
  final Map<String, dynamic> translations;
  final List<PublicItem> items;
}

class PublicMenu {
  PublicMenu.fromJson(Map<String, dynamic> j)
    : branch = (j['branch'] as Map).cast<String, dynamic>(),
      brand = (j['brand'] as Map?)?.cast<String, dynamic>() ?? const {},
      hours = [
        for (final h in (j['hours'] as List? ?? const []))
          (((h as Map)['weekday'] as num).toInt(), (h['opens_at'] as String).substring(0, 5), (h['closes_at'] as String).substring(0, 5)),
      ],
      rating = ((j['rating'] as Map?)?['average'] as num?)?.toDouble(),
      reviewsCount = ((j['rating'] as Map?)?['count'] as num? ?? 0).toInt(),
      categories = [for (final c in (j['categories'] as List? ?? const [])) PublicCategory.fromJson((c as Map).cast())];
  final Map<String, dynamic> branch;
  final Map<String, dynamic> brand;
  final List<(int, String, String)> hours;
  final double? rating;
  final int reviewsCount;
  final List<PublicCategory> categories;

  String get branchId => branch['id'] as String;
  String get currency => branch['currency'] as String;
  bool get acceptsOnlineOrders => branch['accepts_online_orders'] as bool? ?? false;
  bool get acceptsDelivery => branch['accepts_delivery'] as bool? ?? false;
  int get deliveryFeeMinor => (branch['delivery_fee_minor'] as num? ?? 0).toInt();
  int get minOrderMinor => (branch['min_order_minor'] as num? ?? 0).toInt();
  bool get openNow => branch['open_now'] as bool? ?? false;
  String get brandName => brand['name'] as String? ?? '';
  String? get slogan => brand['slogan'] as String?;
  String? get logoPath => brand['logo_path'] as String?;
  int? get prepMinutes => (branch['prep_minutes'] as num?)?.toInt();
  bool get vacationMode => branch['vacation_mode'] as bool? ?? false;
  double? get latitude => (branch['latitude'] as num?)?.toDouble();
  double? get longitude => (branch['longitude'] as num?)?.toDouble();
  String get branchName => branch['name'] as String? ?? '';
  String? get coverPath => branch['cover_path'] as String?;
  String? get address => branch['address_line1'] as String?;
  String get city => branch['city'] as String? ?? '';
  String? get phone => branch['phone'] as String?;
  String? get whatsapp => branch['whatsapp'] as String?;
  String? get deliveryZone => branch['delivery_zone'] as String?;
  bool get acceptsReservations => branch['accepts_reservations'] as bool? ?? false;
  String? get brandDescription => brand['description'] as String?;
  List<String> get cuisines => ((brand['cuisines'] as List?) ?? const []).cast<String>();
}

/// Carte d'un restaurant dans la vitrine.
class BranchCard {
  BranchCard.fromJson(Map<String, dynamic> j)
    : branchId = j['branch_id'] as String,
      branchName = j['branch_name'] as String,
      brandName = j['brand_name'] as String,
      slogan = j['slogan'] as String?,
      logoPath = j['logo_path'] as String?,
      coverPath = j['cover_path'] as String?,
      city = j['city'] as String,
      address = j['address_line1'] as String?,
      cuisines = ((j['cuisines'] as List?) ?? const []).cast<String>(),
      priceLevel = (j['price_level'] as num?)?.toInt(),
      currency = j['currency'] as String? ?? '',
      latitude = (j['latitude'] as num?)?.toDouble(),
      longitude = (j['longitude'] as num?)?.toDouble(),
      prepMinutes = (j['prep_minutes'] as num?)?.toInt(),
      acceptsOnlineOrders = j['accepts_online_orders'] as bool? ?? false,
      acceptsDelivery = j['accepts_delivery'] as bool? ?? false,
      deliveryFeeMinor = (j['delivery_fee_minor'] as num? ?? 0).toInt(),
      openNow = j['open_now'] as bool? ?? false,
      rating = (j['rating'] as num?)?.toDouble(),
      reviewsCount = (j['reviews_count'] as num? ?? 0).toInt();
  final String branchId;
  final String branchName;
  final String brandName;
  final String? slogan;
  final String? logoPath;
  final String? coverPath;
  final String city;
  final String? address;
  final List<String> cuisines;
  final int? priceLevel;
  final String currency;
  final double? latitude;
  final double? longitude;
  final int? prepMinutes;
  final bool acceptsOnlineOrders;
  final bool acceptsDelivery;
  final int deliveryFeeMinor;
  final bool openNow;
  final double? rating;
  final int reviewsCount;
}

/// Plat du catalogue global.
class CatalogItem {
  CatalogItem.fromJson(Map<String, dynamic> j)
    : itemId = j['item_id'] as String,
      name = j['name'] as String,
      description = j['description'] as String?,
      imagePath = j['image_path'] as String?,
      branchId = j['branch_id'] as String,
      brandName = j['brand_name'] as String,
      currency = j['currency'] as String? ?? '',
      priceMinor = (j['price_minor'] as num?)?.toInt(),
      soldOut = j['sold_out'] as bool? ?? false;
  final String itemId;
  final String name;
  final String? description;
  final String? imagePath;
  final String branchId;
  final String brandName;
  final String currency;
  final int? priceMinor;
  final bool soldOut;
}

/// Publicité sponsorisée affichée aux clients.
class PublicAd {
  PublicAd.fromJson(Map<String, dynamic> j)
    : id = j['id'] as String,
      format = j['format'] as String,
      title = j['title'] as String,
      body = j['body'] as String?,
      ctaLabel = j['cta_label'] as String?,
      ctaUrl = j['cta_url'] as String?,
      media = [for (final m in (j['media'] as List? ?? const [])) ((m as Map)['path'] as String, m['kind'] as String? ?? 'image')],
      brandName = j['brand_name'] as String? ?? '',
      logoPath = j['logo_path'] as String?,
      branchId = j['branch_id'] as String?,
      views = (j['views'] as num? ?? 0).toInt(),
      likes = (j['likes'] as num? ?? 0).toInt(),
      comments = (j['comments'] as num? ?? 0).toInt(),
      saves = (j['saves'] as num? ?? 0).toInt();
  final String id;
  final String format;
  final String title;
  final String? body;
  final String? ctaLabel;
  final String? ctaUrl;
  final List<(String, String)> media;
  final String brandName;
  final String? logoPath;
  final String? branchId;

  /// Compteurs publics (mettent en avant ce qui plaît).
  final int views;
  final int likes;
  final int comments;
  final int saves;
}

/// Contenu du fil « Découvrir » (vidéo, carrousel, story, plats mis en avant, annonce).
class FeedPost {
  FeedPost.fromJson(Map<String, dynamic> j)
    : id = j['id'] as String,
      format = j['format'] as String,
      title = j['title'] as String,
      body = j['body'] as String?,
      ctaLabel = j['cta_label'] as String?,
      ctaUrl = j['cta_url'] as String?,
      media = [for (final m in (j['media'] as List? ?? const [])) ((m as Map)['path'] as String, m['kind'] as String? ?? 'image')],
      sponsored = j['sponsored'] as bool? ?? false,
      views = (j['views'] as num? ?? 0).toInt(),
      likes = (j['likes'] as num? ?? 0).toInt(),
      comments = (j['comments'] as num? ?? 0).toInt(),
      saves = (j['saves'] as num? ?? 0).toInt(),
      shares = (j['shares'] as num? ?? 0).toInt(),
      liked = j['liked'] as bool? ?? false,
      saved = j['saved'] as bool? ?? false,
      brandName = j['brand_name'] as String? ?? '',
      logoPath = j['logo_path'] as String?,
      branchId = j['branch_id'] as String,
      acceptsReservations = j['accepts_reservations'] as bool? ?? false,
      items = [
        for (final i in (j['items'] as List? ?? const []))
          ((i as Map)['item_id'] as String, i['name'] as String, i['image_path'] as String?),
      ],
      priceMinor = null,
      currency = null;

  /// Plat d'un restaurant présenté dans le fil (contenu non sponsorisé).
  FeedPost.dish(HomeItem i)
    : id = 'dish-${i.itemId}',
      format = 'dish',
      title = i.name,
      body = i.description,
      ctaLabel = null,
      ctaUrl = null,
      media = [if (i.imagePath != null) (i.imagePath!, 'menu')],
      sponsored = false,
      views = 0,
      likes = 0,
      comments = 0,
      saves = 0,
      shares = 0,
      liked = false,
      saved = false,
      brandName = i.brandName,
      logoPath = null,
      branchId = i.branchId,
      acceptsReservations = false,
      items = [(i.itemId, i.name, i.imagePath)],
      priceMinor = i.priceMinor,
      currency = i.currency;
  final String id;
  final String format;
  final String title;
  final String? body;
  final String? ctaLabel;
  final String? ctaUrl;
  final List<(String, String)> media;
  final bool sponsored;
  final int views;
  int likes;
  int comments;
  int saves;
  int shares;
  bool liked;
  bool saved;
  final String brandName;
  final String? logoPath;
  final String branchId;
  final bool acceptsReservations;

  /// Plats liés : (id, nom, photo).
  final List<(String, String, String?)> items;

  /// Prix d'un plat (contenu « dish »).
  final int? priceMinor;
  final String? currency;

  bool get isDish => format == 'dish';

  (String, String)? get video => media.where((m) => m.$2 == 'video').firstOrNull;
  List<String> get images => [
    for (final m in media)
      if (m.$2 == 'image') m.$1,
  ];
}

/// Commentaire publié sous un contenu du fil.
/// Réactions d'un plat (façon Facebook) : compteurs publics et réactions du
/// client connecté.
class ItemSocial {
  ItemSocial({this.views = 0, this.likes = 0, this.comments = 0, this.favorites = 0, this.liked = false, this.favorite = false});

  factory ItemSocial.fromJson(Map<String, dynamic> j) => ItemSocial(
        views: (j['views'] as num? ?? 0).toInt(),
        likes: (j['likes'] as num? ?? 0).toInt(),
        comments: (j['comments'] as num? ?? 0).toInt(),
        favorites: (j['favorites'] as num? ?? 0).toInt(),
        liked: j['liked'] as bool? ?? false,
        favorite: j['favorite'] as bool? ?? false,
      );

  int views;
  int likes;
  int comments;
  int favorites;
  bool liked;
  bool favorite;
}

/// Tables d'un restaurant vues par le client (sans donnée personnelle).
class TablesStatus {
  TablesStatus.fromJson(Map<String, dynamic> j)
      : at = DateTime.parse(j['at'] as String).toLocal(),
        reservationMinutes = (j['reservation_minutes'] as num? ?? 90).toInt(),
        acceptsReservations = j['accepts_reservations'] as bool? ?? false,
        maxPartySize = (j['max_party_size'] as num? ?? 12).toInt(),
        areas = [
          for (final a in (j['areas'] as List? ?? const []))
            (
              (a as Map)['name'] as String? ?? '',
              [for (final x in (a['tables'] as List? ?? const [])) PublicTable.fromJson((x as Map).cast<String, dynamic>())],
            ),
        ];
  final DateTime at;
  final int reservationMinutes;
  final bool acceptsReservations;
  final int maxPartySize;

  /// (nom de la zone, tables).
  final List<(String, List<PublicTable>)> areas;

  bool get isEmpty => areas.every((a) => a.$2.isEmpty);
}

class PublicTable {
  PublicTable.fromJson(Map<String, dynamic> j)
      : id = j['id'] as String,
        label = j['label'] as String? ?? '',
        seats = (j['seats'] as num? ?? 2).toInt(),
        shape = j['shape'] as String? ?? 'square',
        posX = (j['pos_x'] as num?)?.toInt(),
        posY = (j['pos_y'] as num?)?.toInt(),
        status = j['status'] as String? ?? 'free',
        reservedFrom = _date(j['reserved_from']),
        reservedUntil = _date(j['reserved_until']),
        freeAt = _date(j['free_at']),
        nextReservedAt = _date(j['next_reserved_at']);

  static DateTime? _date(Object? v) => v == null ? null : DateTime.parse(v as String).toLocal();

  final String id;
  final String label;
  final int seats;
  final String shape;
  final int? posX;
  final int? posY;

  /// free, occupied, reserved.
  final String status;
  final DateTime? reservedFrom;
  final DateTime? reservedUntil;
  final DateTime? freeAt;
  final DateTime? nextReservedAt;

  bool get isFree => status == 'free';
}

class FeedComment {
  FeedComment.fromJson(Map<String, dynamic> j)
    : id = j['id'] as String,
      author = j['author'] as String? ?? '',
      body = j['body'] as String,
      createdAt = DateTime.parse(j['created_at'] as String),
      mine = j['mine'] as bool? ?? false;
  final String id;
  final String author;
  final String body;
  final DateTime createdAt;
  final bool mine;
}

/// Plat enregistré (favori ou liste) : disponible ou non aujourd'hui.
class SavedItem {
  SavedItem.fromJson(Map<String, dynamic> j)
    : itemId = j['item_id'] as String,
      name = j['name'] as String,
      imagePath = j['image_path'] as String?,
      branchId = j['branch_id'] as String?,
      brandName = j['brand_name'] as String? ?? '',
      currency = j['currency'] as String? ?? '',
      priceMinor = (j['price_minor'] as num?)?.toInt(),
      rating = (j['rating'] as num?)?.toDouble(),
      available = j['available'] as bool? ?? false;
  final String itemId;
  final String name;
  final String? imagePath;
  final String? branchId;
  final String brandName;
  final String currency;
  final int? priceMinor;
  final double? rating;
  final bool available;
}

/// Liste personnelle de plats (« À tester », « Déjeuners du bureau »…).
class CustomerList {
  CustomerList.fromJson(Map<String, dynamic> j)
    : id = j['id'] as String,
      name = j['name'] as String,
      items = [for (final i in (j['items'] as List? ?? const [])) SavedItem.fromJson((i as Map).cast())];
  final String id;
  final String name;
  final List<SavedItem> items;
}

/// Coupon enregistré dans le portefeuille du client.
class WalletCoupon {
  WalletCoupon.fromJson(Map<String, dynamic> j)
    : id = j['id'] as String,
      name = j['name'] as String,
      kind = j['kind'] as String,
      percent = (j['percent'] as num?)?.toDouble(),
      amountMinor = (j['amount_minor'] as num?)?.toInt(),
      code = j['code'] as String?,
      minOrderMinor = (j['min_order_minor'] as num? ?? 0).toInt(),
      endsAt = j['ends_at'] == null ? null : DateTime.parse(j['ends_at'] as String),
      usable = j['usable'] as bool? ?? false,
      used = (j['used'] as num? ?? 0).toInt(),
      branchId = j['branch_id'] as String?,
      brandName = j['brand_name'] as String? ?? '',
      logoPath = j['logo_path'] as String?,
      currency = j['currency'] as String? ?? '';
  final String id;
  final String name;
  final String kind;
  final double? percent;
  final int? amountMinor;
  final String? code;
  final int minOrderMinor;
  final DateTime? endsAt;
  final bool usable;
  final int used;
  final String? branchId;
  final String brandName;
  final String? logoPath;
  final String currency;
}

/// Notification du client (texte composé dans sa langue à partir du type et des données).
class CustomerNotification {
  CustomerNotification.fromJson(Map<String, dynamic> j)
    : id = j['id'] as String,
      kind = j['kind'] as String,
      data = ((j['data'] as Map?) ?? const {}).cast<String, dynamic>(),
      readAt = j['read_at'] == null ? null : DateTime.parse(j['read_at'] as String),
      createdAt = DateTime.parse(j['created_at'] as String);
  final String id;
  final String kind;
  final Map<String, dynamic> data;
  final DateTime? readAt;
  final DateTime createdAt;
}

/// Commande groupée : un lien partagé, chacun ajoute ses plats, l'organisateur valide.
class GroupOrder {
  GroupOrder.fromJson(Map<String, dynamic> j)
    : id = j['id'] as String,
      token = j['token'] as String,
      branchId = j['branch_id'] as String,
      hostName = j['host_name'] as String,
      isHost = j['is_host'] as bool? ?? false,
      status = j['status'] as String,
      expiresAt = DateTime.parse(j['expires_at'] as String),
      orderId = j['order_id'] as String?,
      brandName = j['brand_name'] as String? ?? '',
      lines = [for (final l in (j['lines'] as List? ?? const [])) GroupLine.fromJson((l as Map).cast())];
  final String id;
  final String token;
  final String branchId;
  final String hostName;
  final bool isHost;

  /// open | placed | cancelled | expired
  final String status;
  final DateTime expiresAt;
  final String? orderId;
  final String brandName;
  final List<GroupLine> lines;

  bool get open => status == 'open';
}

class GroupLine {
  GroupLine.fromJson(Map<String, dynamic> j)
    : id = j['id'] as String,
      participantName = j['participant_name'] as String,
      variantId = j['variant_id'] as String,
      itemId = j['item_id'] as String,
      quantity = (j['quantity'] as num).toInt(),
      modifierIds = [for (final m in (j['modifier_ids'] as List? ?? const [])) m as String],
      note = j['note'] as String?,
      mine = j['mine'] as bool? ?? false;
  final String id;
  final String participantName;
  final String variantId;
  final String itemId;
  final int quantity;
  final List<String> modifierIds;
  final String? note;
  final bool mine;
}

/// Plat mis en avant sur l'accueil (populaire, nouveau, suggéré).
class HomeItem {
  HomeItem.fromJson(Map<String, dynamic> j)
    : itemId = j['item_id'] as String,
      name = j['name'] as String,
      description = j['description'] as String?,
      imagePath = j['image_path'] as String?,
      branchId = j['branch_id'] as String,
      brandName = j['brand_name'] as String? ?? '',
      currency = j['currency'] as String? ?? '',
      priceMinor = (j['price_minor'] as num?)?.toInt(),
      rating = (j['rating'] as num?)?.toDouble(),
      reviews = (j['reviews'] as num? ?? 0).toInt(),
      latitude = (j['latitude'] as num?)?.toDouble(),
      longitude = (j['longitude'] as num?)?.toDouble();
  final String itemId;
  final String name;
  final String? description;
  final String? imagePath;
  final String branchId;
  final String brandName;
  final String currency;
  final int? priceMinor;
  final double? rating;
  final int reviews;
  final double? latitude;
  final double? longitude;
}

/// Promotion publiée par un restaurant.
class PublicPromo {
  PublicPromo.fromJson(Map<String, dynamic> j)
    : id = j['id'] as String,
      name = j['name'] as String,
      kind = j['kind'] as String,
      percent = (j['percent'] as num?)?.toDouble(),
      amountMinor = (j['amount_minor'] as num?)?.toInt(),
      code = j['code'] as String?,
      minOrderMinor = (j['min_order_minor'] as num? ?? 0).toInt(),
      endsAt = j['ends_at'] == null ? null : DateTime.parse(j['ends_at'] as String),
      branchId = j['branch_id'] as String?,
      brandName = j['brand_name'] as String? ?? '',
      logoPath = j['logo_path'] as String?,
      currency = j['currency'] as String? ?? '';
  final String id;
  final String name;
  final String kind;
  final double? percent;
  final int? amountMinor;
  final String? code;
  final int minOrderMinor;
  final DateTime? endsAt;
  final String? branchId;
  final String brandName;
  final String? logoPath;
  final String currency;
}

class PublicHome {
  PublicHome.fromJson(Map<String, dynamic> j)
    : popular = [for (final i in (j['popular'] as List? ?? const [])) HomeItem.fromJson((i as Map).cast())],
      newItems = [for (final i in (j['new_items'] as List? ?? const [])) HomeItem.fromJson((i as Map).cast())],
      promos = [for (final p in (j['promos'] as List? ?? const [])) PublicPromo.fromJson((p as Map).cast())];
  final List<HomeItem> popular;
  final List<HomeItem> newItems;
  final List<PublicPromo> promos;
}

/// Commande en cours affichée sur l'accueil du client.
class ActiveOrder {
  ActiveOrder.fromJson(Map<String, dynamic> j)
    : orderId = j['order_id'] as String,
      number = (j['number'] as num).toInt(),
      branchId = j['branch_id'] as String,
      brandName = j['brand_name'] as String? ?? '',
      channel = j['channel'] as String,
      acceptance = j['acceptance'] as String,
      totalMinor = (j['total_minor'] as num).toInt(),
      currency = j['currency'] as String,
      ready = j['ready'] as bool? ?? false;
  final String orderId;
  final int number;
  final String branchId;
  final String brandName;
  final String channel;
  final String acceptance;
  final int totalMinor;
  final String currency;
  final bool ready;
}

/// Commande passée, à « recommander ».
class ReorderOrder {
  ReorderOrder.fromJson(Map<String, dynamic> j)
    : orderId = j['order_id'] as String,
      branchId = j['branch_id'] as String,
      brandName = j['brand_name'] as String? ?? '',
      logoPath = j['logo_path'] as String?,
      totalMinor = (j['total_minor'] as num).toInt(),
      currency = j['currency'] as String,
      lines = [
        for (final l in (j['lines'] as List? ?? const []))
          ReorderLine(
            (l as Map)['item_id'] as String,
            l['variant_id'] as String,
            l['name'] as String,
            (l['quantity'] as num).toInt(),
            ((l['modifier_ids'] as List?) ?? const []).cast<String>(),
          ),
      ];
  final String orderId;
  final String branchId;
  final String brandName;
  final String? logoPath;
  final int totalMinor;
  final String currency;
  final List<ReorderLine> lines;
}

class ReorderLine {
  const ReorderLine(this.itemId, this.variantId, this.name, this.quantity, this.modifierIds);
  final String itemId;
  final String variantId;
  final String name;
  final int quantity;
  final List<String> modifierIds;
}

class MyHome {
  MyHome.fromJson(Map<String, dynamic> j)
    : active = [for (final o in (j['active'] as List? ?? const [])) ActiveOrder.fromJson((o as Map).cast())],
      reorder = [for (final o in (j['reorder'] as List? ?? const [])) ReorderOrder.fromJson((o as Map).cast())],
      suggested = [for (final i in (j['suggested'] as List? ?? const [])) HomeItem.fromJson((i as Map).cast())];
  MyHome.empty() : active = const [], reorder = const [], suggested = const [];
  final List<ActiveOrder> active;
  final List<ReorderOrder> reorder;
  final List<HomeItem> suggested;
}

/// Note d'un plat : moyenne, nombre d'avis, % de clients satisfaits.
class ItemRating {
  const ItemRating(this.average, this.count, this.satisfied);
  final double average;
  final int count;
  final int satisfied;
}

/// Avis vérifié sur un plat.
class ItemReview {
  ItemReview.fromJson(Map<String, dynamic> j)
    : id = j['id'] as String,
      rating = (j['rating'] as num).toInt(),
      comment = j['comment'] as String?,
      photos = ((j['photos'] as List?) ?? (j['photo_paths'] as List?) ?? const []).cast<String>(),
      author = (j['author'] ?? j['author_name']) as String? ?? '',
      helpful = ((j['helpful'] ?? j['helpful_count']) as num? ?? 0).toInt(),
      createdAt = DateTime.parse(j['created_at'] as String),
      voted = j['voted'] as bool? ?? false,
      mine = j['mine'] as bool? ?? false,
      status = j['status'] as String? ?? 'published',
      hiddenReason = j['hidden_reason'] as String?,
      reports = (j['reports_count'] as num? ?? 0).toInt();
  final String id;
  final int rating;
  final String? comment;
  final List<String> photos;
  final String author;
  int helpful;
  final DateTime createdAt;
  bool voted;
  final bool mine;
  final String status;
  final String? hiddenReason;
  final int reports;
}

/// Profil du client connecté (aucune donnée de carte ou de compte).
class CustomerProfile {
  CustomerProfile({
    this.fullName,
    this.phone,
    this.birthday,
    this.allergies = const [],
    this.spiceLevel,
    this.preferredPayment,
    this.homeLatitude,
    this.homeLongitude,
    this.homeLabel,
    this.shareAllergies = true,
    Map<String, dynamic>? prefs,
  }) : prefs = prefs ?? {};

  factory CustomerProfile.fromJson(Map<String, dynamic> j) => CustomerProfile(
    fullName: j['full_name'] as String?,
    phone: j['phone'] as String?,
    birthday: j['birthday'] == null ? null : DateTime.parse(j['birthday'] as String),
    allergies: ((j['allergies'] as List?) ?? const []).cast<String>(),
    spiceLevel: (j['spice_level'] as num?)?.toInt(),
    preferredPayment: j['preferred_payment'] as String?,
    homeLatitude: (j['home_latitude'] as num?)?.toDouble(),
    homeLongitude: (j['home_longitude'] as num?)?.toDouble(),
    homeLabel: j['home_label'] as String?,
    shareAllergies: j['share_allergies'] as bool? ?? true,
    prefs: ((j['prefs'] as Map?) ?? const {}).cast<String, dynamic>(),
  );

  String? fullName;
  String? phone;
  DateTime? birthday;
  List<String> allergies;
  int? spiceLevel;
  String? preferredPayment;
  double? homeLatitude;
  double? homeLongitude;
  String? homeLabel;
  bool shareAllergies;
  final Map<String, dynamic> prefs;

  bool pref(String key) => prefs[key] as bool? ?? true;

  Map<String, dynamic> toJson(String userId) => {
    'user_id': userId,
    'full_name': (fullName ?? '').trim().isEmpty ? null : fullName!.trim(),
    'phone': (phone ?? '').trim().isEmpty ? null : phone!.trim(),
    'birthday': birthday == null
        ? null
        : '${birthday!.year.toString().padLeft(4, '0')}-${birthday!.month.toString().padLeft(2, '0')}-${birthday!.day.toString().padLeft(2, '0')}',
    'allergies': allergies,
    'spice_level': spiceLevel,
    'preferred_payment': preferredPayment,
    'home_latitude': homeLatitude,
    'home_longitude': homeLongitude,
    'home_label': (homeLabel ?? '').trim().isEmpty ? null : homeLabel!.trim(),
    'share_allergies': shareAllergies,
    'prefs': prefs,
  };
}

class CustomerOrder {
  CustomerOrder.fromJson(Map<String, dynamic> j)
    : orderId = j['order_id'] as String,
      number = (j['number'] as num).toInt(),
      branchId = j['branch_id'] as String,
      branchName = j['branch_name'] as String,
      brandName = j['brand_name'] as String,
      channel = j['channel'] as String,
      status = j['status'] as String,
      acceptance = j['acceptance'] as String,
      totalMinor = (j['total_minor'] as num).toInt(),
      currency = j['currency'] as String,
      openedAt = DateTime.parse(j['opened_at'] as String),
      hasReview = j['has_review'] as bool? ?? false,
      rejectReason = j['reject_reason'] as String?;
  final String orderId;
  final int number;
  final String branchId;
  final String branchName;
  final String brandName;
  final String channel;
  final String status;
  final String acceptance;
  final int totalMinor;
  final String currency;
  final DateTime openedAt;
  final bool hasReview;
  final String? rejectReason;
}

class CustomerReservation {
  CustomerReservation.fromJson(Map<String, dynamic> j)
    : id = j['reservation_id'] as String,
      branchName = j['branch_name'] as String,
      brandName = j['brand_name'] as String,
      startsAt = DateTime.parse(j['starts_at'] as String),
      partySize = (j['party_size'] as num).toInt(),
      status = j['status'] as String,
      reason = j['reason'] as String?;
  final String id;
  final String branchName;
  final String brandName;
  final DateTime startsAt;
  final int partySize;
  final String status;
  final String? reason;
}

class LoyaltyBalance {
  LoyaltyBalance.fromJson(Map<String, dynamic> j)
    : organizationName = j['organization_name'] as String,
      points = (j['points'] as num).toInt(),
      rewardPoints = (j['reward_points'] as num?)?.toInt(),
      rewardMinor = (j['reward_minor'] as num?)?.toInt(),
      currency = j['currency'] as String;
  final String organizationName;
  final int points;
  final int? rewardPoints;
  final int? rewardMinor;
  final String currency;
}

class CustomerAddress {
  CustomerAddress.fromJson(Map<String, dynamic> j)
    : id = j['id'] as String,
      label = j['label'] as String?,
      address = j['address'] as String,
      instructions = j['instructions'] as String?,
      latitude = (j['latitude'] as num?)?.toDouble(),
      longitude = (j['longitude'] as num?)?.toDouble();
  final String id;
  final String? label;
  final String address;
  final String? instructions;
  final double? latitude;
  final double? longitude;
}

class CartLine {
  CartLine({required this.item, required this.variant, required this.modifiers, required this.quantity, this.note});
  final PublicItem item;
  final PublicVariant variant;
  final List<PublicModifier> modifiers;
  int quantity;
  final String? note;

  int unitPrice(String channel) => (variant.priceFor(channel) ?? 0) + modifiers.fold<int>(0, (a, m) => a + m.priceFor(channel));

  Map<String, dynamic> toJson() => {
    'variant_id': variant.id,
    'quantity': quantity,
    'modifier_ids': [for (final m in modifiers) m.id],
    'note': ?note,
  };
}

/// Part d'un restaurant dans un panier multi-restaurants.
class CheckoutPart {
  CheckoutPart({required this.branchId, required this.channel, required this.lines, required this.clientId, this.tableToken, this.note});
  final String branchId;
  final String channel;
  final List<CartLine> lines;
  final String clientId;
  final String? tableToken;
  final String? note;

  Map<String, dynamic> toJson() => {
    'branch_id': branchId,
    'channel': channel,
    'client_id': clientId,
    'items': [for (final l in lines) l.toJson()],
    'table_token': ?tableToken,
    if (note != null && note!.trim().isNotEmpty) 'note': note!.trim(),
  };
}

class CustomerApi {
  CustomerApi(this._db);
  final SupabaseClient _db;

  String imageUrl(String path) => _db.storage.from('menu-images').getPublicUrl(path);
  String videoUrl(String path) => _db.storage.from('menu-videos').getPublicUrl(path);
  String logoUrl(String path) => _db.storage.from('brand-logos').getPublicUrl(path);
  String adMediaUrl(String path) => _db.storage.from('marketing-media').getPublicUrl(path);

  User? get user => _db.auth.currentUser;

  Future<List<BranchCard>> cards({String? query, String? city}) async {
    final rows = await _db.rpc('public_branch_cards', params: {'p_query': query, 'p_city': city}) as List;
    return [for (final r in rows) BranchCard.fromJson((r as Map).cast())];
  }

  Future<List<(String, int)>> cities() async {
    final rows = await _db.rpc('public_cities') as List;
    return [for (final r in rows) ((r as Map)['city'] as String, (r['count'] as num).toInt())];
  }

  Future<List<CatalogItem>> catalog({String? city, String? query}) async {
    final rows = await _db.rpc('public_catalog', params: {'p_city': city, 'p_query': query}) as List;
    return [for (final r in rows) CatalogItem.fromJson((r as Map).cast())];
  }

  Future<List<PublicAd>> ads({String? branchId}) async {
    final rows = await _db.rpc('public_ads', params: {'p_branch': branchId}) as List;
    return [for (final r in rows) PublicAd.fromJson((r as Map).cast())];
  }

  /// Vue ou clic sur une publicité (sans effet si elle n'est plus diffusée).
  Future<void> recordAd(String campaignId, String event) =>
      _db.rpc('record_ad_event', params: {'p_campaign': campaignId, 'p_event': event}).catchError((_) => null);

  // --- Fil « Découvrir »

  /// Identifiant anonyme de l'appareil, gardé d'une ouverture à l'autre (vues
  /// dédoublonnées sans compte) ; aucune donnée personnelle.
  static Future<String>? _viewerKey;

  Future<String?> _viewer() async =>
      _db.auth.currentUser != null ? null : await (_viewerKey ??= readViewerKey());

  Future<List<FeedPost>> feed({String? city, int offset = 0, int limit = 12}) async {
    final rows = await _db.rpc('public_feed', params: {'p_city': city, 'p_limit': limit, 'p_offset': offset}) as List;
    return [for (final r in rows) FeedPost.fromJson((r as Map).cast())];
  }

  /// Vue comptée une fois par jour et par visiteur.
  Future<void> recordFeedView(String campaignId) async {
    try {
      await _db.rpc('record_ad_view', params: {'p_campaign': campaignId, 'p_viewer': await _viewer()});
    } catch (_) {}
  }

  Future<(bool, int)> toggleFeedLike(String campaignId) async {
    final r = (await _db.rpc('toggle_ad_like', params: {'p_campaign': campaignId}) as Map).cast<String, dynamic>();
    return (r['liked'] as bool, (r['likes'] as num).toInt());
  }

  Future<(bool, int)> toggleFeedSave(String campaignId) async {
    final r = (await _db.rpc('toggle_ad_save', params: {'p_campaign': campaignId}) as Map).cast<String, dynamic>();
    return (r['saved'] as bool, (r['saves'] as num).toInt());
  }

  Future<void> recordFeedShare(String campaignId) => _db.rpc('record_ad_share', params: {'p_campaign': campaignId}).catchError((_) => null);

  Future<List<FeedComment>> feedComments(String campaignId) async {
    final rows = await _db.rpc('public_ad_comments', params: {'p_campaign': campaignId}) as List;
    return [for (final r in rows) FeedComment.fromJson((r as Map).cast())];
  }

  Future<void> addFeedComment(String campaignId, String body) =>
      _db.rpc('add_ad_comment', params: {'p_campaign': campaignId, 'p_body': body});

  /// Compteurs et réactions des plats d'un établissement (vide si la base ne les expose pas encore).
  Future<Map<String, ItemSocial>> itemSocial(String branchId) async {
    try {
      final r = await _db.rpc('public_item_social', params: {'p_branch': branchId});
      return {for (final e in (r as Map).entries) e.key as String: ItemSocial.fromJson((e.value as Map).cast())};
    } on PostgrestException {
      return {};
    }
  }

  /// Vues des plats affichés (une par jour et par visiteur, comptée par le serveur).
  Future<void> recordItemViews(List<String> itemIds) async {
    if (itemIds.isEmpty) return;
    try {
      await _db.rpc('record_item_views', params: {
        'p_items': itemIds.take(100).toList(),
        'p_viewer': await _viewer(),
      });
    } catch (_) {}
  }

  Future<(bool, int)> toggleItemLike(String itemId) async {
    final r = (await _db.rpc('toggle_item_like', params: {'p_item': itemId}) as Map).cast<String, dynamic>();
    return (r['liked'] as bool, (r['likes'] as num).toInt());
  }

  Future<List<FeedComment>> itemComments(String itemId) async {
    final rows = await _db.rpc('public_item_comments', params: {'p_item': itemId}) as List;
    return [for (final r in rows) FeedComment.fromJson((r as Map).cast())];
  }

  Future<void> addItemComment(String itemId, String body) =>
      _db.rpc('add_item_comment', params: {'p_item': itemId, 'p_body': body});

  /// Rattache une commande passée depuis le fil à la campagne (statistiques du restaurant).
  Future<void> attributeAdOrder(String orderId, String campaignId) =>
      _db.rpc('attribute_ad_order', params: {'p_order': orderId, 'p_campaign': campaignId}).catchError((_) => false);

  // --- Fidélisation : plats favoris, listes, coupons, notifications, anniversaire

  Future<(List<SavedItem>, List<CustomerList>)> savedItems() async {
    final r = (await _db.rpc('my_saved_items') as Map).cast<String, dynamic>();
    return (
      [for (final i in (r['favorites'] as List? ?? const [])) SavedItem.fromJson((i as Map).cast())],
      [for (final l in (r['lists'] as List? ?? const [])) CustomerList.fromJson((l as Map).cast())],
    );
  }

  Future<Set<String>> favoriteItemIds() async {
    if (_db.auth.currentUser == null) return {};
    final rows = await _db.from('customer_item_favorites').select('item_id');
    return {for (final r in rows) r['item_id'] as String};
  }

  Future<void> setItemFavorite(String itemId, bool on) => on
      ? _db.from('customer_item_favorites').upsert({'item_id': itemId}, onConflict: 'user_id,item_id', ignoreDuplicates: true)
      : _db.from('customer_item_favorites').delete().eq('item_id', itemId);

  Future<List<(String, String, Set<String>)>> lists() async {
    final rows = await _db.from('customer_lists').select('id, name, customer_list_items(item_id)').order('created_at');
    return [
      for (final r in rows)
        (
          r['id'] as String,
          r['name'] as String,
          {for (final i in (r['customer_list_items'] as List? ?? const [])) (i as Map)['item_id'] as String},
        ),
    ];
  }

  Future<String> createList(String name) async =>
      (await _db.from('customer_lists').insert({'name': name.trim()}).select('id').single())['id'] as String;

  Future<void> renameList(String id, String name) => _db.from('customer_lists').update({'name': name.trim()}).eq('id', id);

  Future<void> deleteList(String id) => _db.from('customer_lists').delete().eq('id', id);

  Future<void> setInList(String listId, String itemId, bool on) => on
      ? _db
            .from('customer_list_items')
            .upsert({'list_id': listId, 'item_id': itemId}, onConflict: 'list_id,item_id', ignoreDuplicates: true)
      : _db.from('customer_list_items').delete().eq('list_id', listId).eq('item_id', itemId);

  Future<List<WalletCoupon>> coupons() async {
    final rows = await _db.rpc('my_coupons') as List;
    return [for (final r in rows) WalletCoupon.fromJson((r as Map).cast())];
  }

  Future<Set<String>> savedCouponIds() async {
    if (_db.auth.currentUser == null) return {};
    final rows = await _db.from('customer_coupons').select('promotion_id');
    return {for (final r in rows) r['promotion_id'] as String};
  }

  Future<void> saveCoupon(String promotionId) => _db.rpc('save_coupon', params: {'p_promotion': promotionId});

  Future<void> removeCoupon(String promotionId) => _db.from('customer_coupons').delete().eq('promotion_id', promotionId);

  /// Notifications du compte : celles du client, ou celles du restaurant ([staff]).
  Future<List<CustomerNotification>> notifications({bool staff = false}) async {
    var q = _db.from('customer_notifications').select();
    q = staff ? q.like('kind', 'staff_%') : q.not('kind', 'like', 'staff_%');
    final rows = await q.order('created_at', ascending: false).limit(100);
    return [for (final r in rows) CustomerNotification.fromJson(r)];
  }

  Future<int> unreadNotifications({bool staff = false}) async {
    if (_db.auth.currentUser == null) return 0;
    var q = _db.from('customer_notifications').select('id').isFilter('read_at', null);
    q = staff ? q.like('kind', 'staff_%') : q.not('kind', 'like', 'staff_%');
    return (await q.limit(100)).length;
  }

  Future<void> markNotificationsRead([List<String>? ids]) => _db.rpc('mark_notifications_read', params: {'p_ids': ids});

  RealtimeChannel watchNotifications(void Function() onChange) => _db
      .channel('notifications-${DateTime.now().microsecondsSinceEpoch}')
      .onPostgresChanges(
        event: PostgresChangeEvent.insert,
        schema: 'public',
        table: 'customer_notifications',
        filter: PostgresChangeFilter(type: PostgresChangeFilterType.eq, column: 'user_id', value: _db.auth.currentUser!.id),
        callback: (_) => onChange(),
      )
      .subscribe();

  /// Points d'anniversaire dus (restaurant, points), crédités une fois par an.
  Future<List<(String, int)>> claimBirthdayRewards() async {
    if (_db.auth.currentUser == null) return const [];
    final rows = await _db.rpc('claim_birthday_rewards') as List;
    return [for (final r in rows) ((r as Map)['organization_name'] as String, (r['points'] as num).toInt())];
  }

  // --- Commande groupée

  Future<String> createGroupOrder(String branchId, String? name) async =>
      ((await _db.rpc('create_group_order', params: {'p_branch': branchId, 'p_name': name}) as Map)['token']) as String;

  Future<GroupOrder> groupOrder(String token) async =>
      GroupOrder.fromJson((await _db.rpc('group_order', params: {'p_token': token}) as Map).cast());

  Future<void> addGroupLines(String token, List<CartLine> lines, {String? name}) => _db.rpc(
    'add_group_lines',
    params: {
      'p_token': token,
      'p_items': [for (final l in lines) l.toJson()],
      'p_name': name,
    },
  );

  Future<void> removeGroupLine(String lineId) => _db.rpc('remove_group_line', params: {'p_line': lineId});

  Future<void> cancelGroupOrder(String token) => _db.rpc('cancel_group_order', params: {'p_token': token});

  Future<Map<String, dynamic>> placeGroupOrder({
    required String token,
    required String channel,
    String? phone,
    String? name,
    String? address,
    String? instructions,
    DateTime? scheduledFor,
    String? note,
  }) async => (await _db.rpc(
    'place_group_order',
    params: {
      'p_token': token,
      'p_channel': channel,
      'p_contact_phone': phone,
      'p_customer_name': name,
      'p_delivery_address': address,
      'p_delivery_instructions': instructions,
      'p_scheduled_for': scheduledFor?.toUtc().toIso8601String(),
      'p_note': note,
    },
  ) as Map).cast();

  Future<CustomerProfile> profile() async {
    final row = await _db.from('customer_profiles').select().maybeSingle();
    return row == null ? CustomerProfile() : CustomerProfile.fromJson(row);
  }

  Future<void> saveProfile(CustomerProfile p) =>
      _db.from('customer_profiles').upsert(p.toJson(_db.auth.currentUser!.id), onConflict: 'user_id');

  Future<List<BranchSummary>> search({String? query, String? city}) async {
    final rows = await _db.rpc('public_search_branches', params: {'p_query': query, 'p_city': city}) as List;
    return [for (final r in rows) BranchSummary.fromJson((r as Map).cast())];
  }

  Future<PublicMenu> menu(String branchId) async =>
      PublicMenu.fromJson((await _db.rpc('public_branch_menu', params: {'p_branch': branchId}) as Map).cast());

  Future<Map<String, dynamic>?> table(String token) async {
    final r = await _db.rpc('public_table', params: {'p_token': token});
    return r == null ? null : (r as Map).cast<String, dynamic>();
  }

  Future<Map<String, dynamic>?> reservationSettings(String branchId) async {
    final r = await _db.rpc('public_reservation_settings', params: {'p_branch': branchId});
    return r == null ? null : (r as Map).cast<String, dynamic>();
  }

  Future<List<(int, String?, String, DateTime)>> reviews(String branchId) async {
    final rows = await _db.rpc('public_reviews', params: {'p_branch': branchId}) as List;
    return [
      for (final r in rows)
        ((r['rating'] as num).toInt(), r['comment'] as String?, r['author'] as String, DateTime.parse(r['created_at'] as String)),
    ];
  }

  Future<Map<String, dynamic>> placeOrder({
    required String branchId,
    required String channel,
    required List<CartLine> lines,
    String? tableToken,
    DateTime? scheduledFor,
    String? address,
    String? instructions,
    String? phone,
    String? name,
    String? note,
    required String clientId,
  }) async => (await _db.rpc(
    'place_online_order',
    params: {
      'p_branch': branchId,
      'p_channel': channel,
      'p_items': [for (final l in lines) l.toJson()],
      'p_table_token': tableToken,
      'p_scheduled_for': scheduledFor?.toUtc().toIso8601String(),
      'p_delivery_address': address,
      'p_delivery_instructions': instructions,
      'p_contact_phone': phone,
      'p_customer_name': name,
      'p_note': note,
      'p_client_id': clientId,
    },
  ) as Map).cast();

  /// Panier multi-restaurants : une commande indépendante par restaurant, en une
  /// seule validation (tout ou rien). Renvoie (restaurant, commande, numéro).
  Future<List<(String, String, int)>> placeCheckout({
    required String checkoutId,
    required List<CheckoutPart> parts,
    String? phone,
    String? name,
    String? address,
    String? instructions,
    DateTime? scheduledFor,
  }) async {
    final rows = await _db.rpc(
      'place_checkout',
      params: {
        'p_checkout': checkoutId,
        'p_orders': [for (final p in parts) p.toJson()],
        'p_contact_phone': phone,
        'p_customer_name': name,
        'p_delivery_address': address,
        'p_delivery_instructions': instructions,
        'p_scheduled_for': scheduledFor?.toUtc().toIso8601String(),
      },
    ) as List;
    return [for (final r in rows) ((r as Map)['branch_id'] as String, r['order_id'] as String, (r['number'] as num).toInt())];
  }

  Future<void> applyCode(String orderId, String code) => _db.rpc('customer_apply_code', params: {'p_order': orderId, 'p_code': code});

  Future<List<CustomerOrder>> myOrders() async {
    final rows = await _db.rpc('my_customer_orders') as List;
    return [for (final r in rows) CustomerOrder.fromJson((r as Map).cast())];
  }

  Future<Map<String, dynamic>> order(String id) async => await _db
      .from('orders')
      .select('*, order_items(*, order_item_modifiers(group_name, modifier_name, price_minor)), order_adjustments(label, applied_minor)')
      .eq('id', id)
      .single();

  RealtimeChannel watchOrder(String orderId, void Function() onChange) => _db
      .channel('order-$orderId-${DateTime.now().microsecondsSinceEpoch}')
      .onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'orders',
        filter: PostgresChangeFilter(type: PostgresChangeFilterType.eq, column: 'id', value: orderId),
        callback: (_) => onChange(),
      )
      .onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'order_items',
        filter: PostgresChangeFilter(type: PostgresChangeFilterType.eq, column: 'order_id', value: orderId),
        callback: (_) => onChange(),
      )
      .subscribe();

  Future<void> unwatch(RealtimeChannel c) => _db.removeChannel(c);

  Future<void> cancelOrder(String id) => _db.rpc('customer_cancel_order', params: {'p_order': id});

  Future<void> review(String orderId, int rating, String? comment) =>
      _db.rpc('submit_review', params: {'p_order': orderId, 'p_rating': rating, 'p_comment': comment});

  Future<Set<String>> favorites() async {
    if (_db.auth.currentUser == null) return {};
    final rows = await _db.from('customer_favorites').select('branch_id');
    return {for (final r in rows) r['branch_id'] as String};
  }

  Future<void> setFavorite(String branchId, bool on) => on
      ? _db.from('customer_favorites').insert({'branch_id': branchId})
      : _db.from('customer_favorites').delete().eq('branch_id', branchId);

  Future<List<CustomerAddress>> addresses() async {
    final rows = await _db.from('customer_addresses').select().order('created_at', ascending: false);
    return [for (final r in rows) CustomerAddress.fromJson(r)];
  }

  Future<void> saveAddress(String address, String? label, String? instructions, {double? latitude, double? longitude}) => _db
      .from('customer_addresses')
      .insert({'address': address, 'label': label, 'instructions': instructions, 'latitude': ?latitude, 'longitude': ?longitude});

  // --- Accueil personnalisé

  Future<PublicHome> home({String? city}) async =>
      PublicHome.fromJson((await _db.rpc('public_home', params: {'p_city': city}) as Map).cast());

  Future<MyHome> myHome() async {
    if (_db.auth.currentUser == null) return MyHome.empty();
    return MyHome.fromJson((await _db.rpc('my_home') as Map).cast());
  }

  /// Position du client (domicile) : enregistrée dans son profil.
  Future<void> saveHomeLocation(double latitude, double longitude) async {
    final p = await profile();
    p
      ..homeLatitude = latitude
      ..homeLongitude = longitude;
    await saveProfile(p);
  }

  // --- Avis vérifiés par plat

  String reviewPhotoUrl(String path) => _db.storage.from('review-photos').getPublicUrl(path);

  Future<Map<String, ItemRating>> itemRatings(String branchId) async {
    final r = (await _db.rpc('public_item_ratings', params: {'p_branch': branchId}) as Map).cast<String, dynamic>();
    return {
      for (final e in r.entries)
        e.key: ItemRating(
          ((e.value as Map)['average'] as num).toDouble(),
          (e.value['count'] as num).toInt(),
          (e.value['satisfied'] as num).toInt(),
        ),
    };
  }

  Future<List<ItemReview>> itemReviews(String itemId, {String sort = 'recent', int offset = 0, int limit = 20}) async {
    final rows =
        await _db.rpc('public_item_reviews', params: {'p_item': itemId, 'p_sort': sort, 'p_limit': limit, 'p_offset': offset}) as List;
    return [for (final r in rows) ItemReview.fromJson((r as Map).cast())];
  }

  Future<String> uploadReviewPhoto(Uint8List bytes, String extension) async {
    final ext = extension.toLowerCase() == 'jpg' ? 'jpeg' : extension.toLowerCase();
    final path = '${_db.auth.currentUser!.id}/${DateTime.now().millisecondsSinceEpoch}.${ext == 'jpeg' ? 'jpg' : ext}';
    await _db.storage.from('review-photos').uploadBinary(path, bytes, fileOptions: FileOptions(contentType: 'image/$ext'));
    return path;
  }

  Future<void> submitItemReview(String orderItemId, int rating, String? comment, List<String> photos) =>
      _db.rpc('submit_item_review', params: {'p_order_item': orderItemId, 'p_rating': rating, 'p_comment': comment, 'p_photos': photos});

  Future<int> voteReview(String reviewId, bool helpful) async =>
      (await _db.rpc('vote_item_review', params: {'p_review': reviewId, 'p_helpful': helpful}) as num).toInt();

  Future<void> reportReview(String reviewId, String reason) =>
      _db.rpc('report_item_review', params: {'p_review': reviewId, 'p_reason': reason});

  /// Mes avis (pour savoir quels plats j'ai déjà notés).
  Future<Map<String, int>> myReviewedLines() async {
    final rows = await _db.from('item_reviews').select('order_item_id, rating').eq('user_id', _db.auth.currentUser!.id);
    return {for (final r in rows) r['order_item_id'] as String: (r['rating'] as num).toInt()};
  }

  Future<void> deleteAddress(String id) => _db.from('customer_addresses').delete().eq('id', id);

  Future<void> requestReservation({
    required String branchId,
    required DateTime startsAt,
    required int partySize,
    required String name,
    required String phone,
    String? note,
    required String clientId,
    List<String> tableIds = const [],
  }) => _db.rpc(
    tableIds.isEmpty ? 'request_reservation' : 'request_reservation_tables',
    params: {
      'p_branch': branchId,
      'p_starts_at': startsAt.toUtc().toIso8601String(),
      'p_party_size': partySize,
      'p_name': name,
      'p_phone': phone,
      'p_note': note,
      'p_client_id': clientId,
      if (tableIds.isNotEmpty) 'p_tables': tableIds,
    },
  );

  /// État des tables d'un restaurant à un moment donné (maintenant par défaut).
  Future<TablesStatus> tableStatus(String branchId, {DateTime? at}) async {
    final r = await _db.rpc('public_table_status', params: {'p_branch': branchId, 'p_at': at?.toUtc().toIso8601String()});
    return TablesStatus.fromJson((r as Map).cast<String, dynamic>());
  }

  Future<List<CustomerReservation>> myReservations() async {
    final rows = await _db.rpc('my_reservations') as List;
    return [for (final r in rows) CustomerReservation.fromJson((r as Map).cast())];
  }

  Future<void> cancelReservation(String id) => _db.rpc('customer_cancel_reservation', params: {'p_reservation': id});

  Future<List<LoyaltyBalance>> loyalty() async {
    final rows = await _db.rpc('my_loyalty') as List;
    return [for (final r in rows) LoyaltyBalance.fromJson((r as Map).cast())];
  }
}
