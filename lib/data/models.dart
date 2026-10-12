/// Modèles lus depuis Supabase. Les règles (droits, contrôles) restent côté
/// serveur ; ces classes ne servent qu'à l'affichage et à la saisie.
library;

class Membership {
  Membership({
    required this.id,
    required this.organizationId,
    required this.organizationName,
    required this.organizationStatus,
    required this.role,
    required this.allBranches,
    required this.branchIds,
    required this.permissions,
  });

  factory Membership.fromJson(Map<String, dynamic> j) => Membership(
    id: j['membership_id'] as String,
    organizationId: j['organization_id'] as String,
    organizationName: j['organization_name'] as String,
    organizationStatus: j['organization_status'] as String,
    role: j['role'] as String,
    allBranches: j['all_branches'] as bool,
    branchIds: (j['branch_ids'] as List).cast<String>(),
    permissions: (j['permissions'] as List).cast<String>().toSet(),
  );

  final String id;
  final String organizationId;
  final String organizationName;
  final String organizationStatus;
  final String role;
  final bool allBranches;
  final List<String> branchIds;
  final Set<String> permissions;

  bool can(String permission) => organizationStatus == 'active' && permissions.contains(permission);

  /// Permissions de portée organisation : effectives seulement sur toute l'organisation.
  bool canOrg(String permission) => allBranches && can(permission);
}

class Country {
  const Country(this.code, this.name);
  final String code;
  final String name;
}

class Currency {
  const Currency(this.code, this.name, this.minorUnit);
  final String code;
  final String name;
  final int minorUnit;
}

class References {
  const References({required this.countries, required this.currencies, required this.timezones});
  final List<Country> countries;
  final List<Currency> currencies;
  final List<String> timezones;
}

class Branch {
  Branch({
    this.id,
    required this.organizationId,
    required this.brandId,
    this.name = '',
    this.slug = '',
    this.countryCode = '',
    this.addressLine1,
    this.addressLine2,
    this.city = '',
    this.region,
    this.postalCode,
    this.phone,
    this.email,
    this.timezone = '',
    this.currency = '',
    this.defaultLocale = 'fr',
    this.status = 'active',
    this.isPublished = false,
    this.languages = const [],
    this.taxRate = 0,
    this.pricesIncludeTax = true,
    this.acceptsOnlineOrders = false,
    this.acceptsDelivery = false,
    this.deliveryFeeMinor = 0,
    this.minOrderMinor = 0,
    this.acceptsReservations = false,
    this.reservationMinutes = 90,
    this.maxPartySize = 12,
    this.targetPrepMinutes = 15,
    this.payFirstTakeaway = true,
    this.legalName,
    this.taxIdentifier,
    this.receiptFooter,
    this.tipsEnabled = true,
    this.tipPresets = const [5, 10, 15],
    this.invoicePrefix = 'FA-',
    this.invoiceFooter,
    this.receiptQr = true,
    this.receiptQrUrl,
    this.registrationNumber,
    this.whatsapp,
    this.latitude,
    this.longitude,
    this.deliveryZone,
    this.vacationMode = false,
    this.vacationMessage,
    this.targetFoodCostPercent = 30,
    this.coverPath,
    this.receiptTitle,
    this.receiptSubtitle,
    this.receiptSlogan,
    this.website,
    this.receiptQrTitle,
    this.receiptQrCaption,
    this.receiptFarewell,
    this.hasTicketTexts = false,
  });

  factory Branch.fromJson(Map<String, dynamic> j) => Branch(
    id: j['id'] as String,
    organizationId: j['organization_id'] as String,
    brandId: j['brand_id'] as String,
    name: j['name'] as String,
    slug: j['slug'] as String,
    countryCode: j['country_code'] as String,
    addressLine1: j['address_line1'] as String?,
    addressLine2: j['address_line2'] as String?,
    city: j['city'] as String,
    region: j['region'] as String?,
    postalCode: j['postal_code'] as String?,
    phone: j['phone'] as String?,
    email: j['email'] as String?,
    timezone: j['timezone'] as String,
    currency: j['currency'] as String,
    defaultLocale: j['default_locale'] as String,
    status: j['status'] as String,
    isPublished: j['is_published'] as bool,
    taxRate: (j['tax_rate'] as num? ?? 0).toDouble(),
    pricesIncludeTax: j['prices_include_tax'] as bool? ?? true,
    acceptsOnlineOrders: j['accepts_online_orders'] as bool? ?? false,
    acceptsDelivery: j['accepts_delivery'] as bool? ?? false,
    deliveryFeeMinor: (j['delivery_fee_minor'] as num? ?? 0).toInt(),
    minOrderMinor: (j['min_order_minor'] as num? ?? 0).toInt(),
    acceptsReservations: j['accepts_reservations'] as bool? ?? false,
    reservationMinutes: (j['reservation_minutes'] as num? ?? 90).toInt(),
    maxPartySize: (j['max_party_size'] as num? ?? 12).toInt(),
    targetPrepMinutes: (j['target_prep_minutes'] as num? ?? 15).toInt(),
    payFirstTakeaway: j['pay_first_takeaway'] as bool? ?? true,
    legalName: j['legal_name'] as String?,
    taxIdentifier: j['tax_identifier'] as String?,
    receiptFooter: j['receipt_footer'] as String?,
    tipsEnabled: j['tips_enabled'] as bool? ?? true,
    tipPresets: [
      for (final p in (j['tip_presets'] as List? ?? const [5, 10, 15])) (p as num).toInt(),
    ],
    invoicePrefix: j['invoice_prefix'] as String? ?? 'FA-',
    invoiceFooter: j['invoice_footer'] as String?,
    receiptQr: j['receipt_qr'] as bool? ?? true,
    receiptQrUrl: j['receipt_qr_url'] as String?,
    registrationNumber: j['registration_number'] as String?,
    whatsapp: j['whatsapp'] as String?,
    latitude: (j['latitude'] as num?)?.toDouble(),
    longitude: (j['longitude'] as num?)?.toDouble(),
    deliveryZone: j['delivery_zone'] as String?,
    vacationMode: j['vacation_mode'] as bool? ?? false,
    vacationMessage: j['vacation_message'] as String?,
    targetFoodCostPercent: (j['target_food_cost_percent'] as num? ?? 30).toDouble(),
    coverPath: j['cover_path'] as String?,
    receiptTitle: j['receipt_title'] as String?,
    receiptSubtitle: j['receipt_subtitle'] as String?,
    receiptSlogan: j['receipt_slogan'] as String?,
    website: j['website'] as String?,
    receiptQrTitle: j['receipt_qr_title'] as String?,
    receiptQrCaption: j['receipt_qr_caption'] as String?,
    receiptFarewell: j['receipt_farewell'] as String?,
    hasTicketTexts: j.containsKey('receipt_title'),
    languages: [for (final l in (j['branch_languages'] as List? ?? const [])) (l as Map)['locale'] as String],
  );

  String? id;
  final String organizationId;
  final String brandId;
  String name;
  String slug;
  String countryCode;
  String? addressLine1;
  String? addressLine2;
  String city;
  String? region;
  String? postalCode;
  String? phone;
  String? email;
  String timezone;
  String currency;
  String defaultLocale;
  String status;
  bool isPublished;
  List<String> languages;
  double taxRate;
  bool pricesIncludeTax;
  bool acceptsOnlineOrders;
  bool acceptsDelivery;
  int deliveryFeeMinor;
  int minOrderMinor;
  bool acceptsReservations;
  int reservationMinutes;
  int maxPartySize;

  /// Temps de préparation visé (minutes) : au-delà, la commande est « en retard ».
  int targetPrepMinutes;

  /// Vente à emporter : paiement avant la préparation.
  bool payFirstTakeaway;

  /// Mentions du ticket : raison sociale, n° d'identification fiscale, pied de ticket.
  String? legalName;
  String? taxIdentifier;
  String? receiptFooter;

  /// Pourboires proposés à l'encaissement (pourcentages suggérés).
  bool tipsEnabled;
  List<int> tipPresets;

  /// Factures : préfixe du numéro (« FA- »), mentions de bas de facture (conditions, coordonnées bancaires).
  String invoicePrefix;
  String? invoiceFooter;

  /// QR code en bas du ticket : affiché ou non, lien libre (site, avis) sinon la page du restaurant.
  bool receiptQr;
  String? receiptQrUrl;

  /// Profil : n° d'immatriculation (registre du commerce du pays), WhatsApp,
  /// position GPS, zone de livraison, fermeture temporaire (mode vacances).
  String? registrationNumber;
  String? whatsapp;
  double? latitude;
  double? longitude;
  String? deliveryZone;
  bool vacationMode;
  String? vacationMessage;

  /// Objectif de coût matière (% du prix de vente), modifié depuis le module Stock.
  double targetFoodCostPercent;

  /// Photo d'ambiance (bucket « menu-images »), envoyée depuis Paramètres.
  String? coverPath;

  /// Textes du ticket de caisse (vides : nom et slogan de la marque, textes par défaut).
  String? receiptTitle;
  String? receiptSubtitle;
  String? receiptSlogan;
  String? website;
  String? receiptQrTitle;
  String? receiptQrCaption;
  String? receiptFarewell;

  /// La base connaît déjà ces textes (migration 027 appliquée) : ils sont alors enregistrés.
  final bool hasTicketTexts;

  /// Colonnes modifiables (identiques aux droits accordés par la migration 001).
  Map<String, dynamic> editableJson() => {
    'name': name.trim(),
    'slug': slug,
    'country_code': countryCode,
    'address_line1': _blank(addressLine1),
    'address_line2': _blank(addressLine2),
    'city': city.trim(),
    'region': _blank(region),
    'postal_code': _blank(postalCode),
    'phone': _blank(phone),
    'email': _blank(email),
    'timezone': timezone,
    'currency': currency,
    'default_locale': defaultLocale,
    'status': status,
    'is_published': isPublished,
    'tax_rate': taxRate,
    'prices_include_tax': pricesIncludeTax,
    'accepts_online_orders': acceptsOnlineOrders,
    'accepts_delivery': acceptsDelivery,
    'delivery_fee_minor': deliveryFeeMinor,
    'min_order_minor': minOrderMinor,
    'accepts_reservations': acceptsReservations,
    'reservation_minutes': reservationMinutes,
    'max_party_size': maxPartySize,
    'target_prep_minutes': targetPrepMinutes,
    'pay_first_takeaway': payFirstTakeaway,
    'legal_name': _blank(legalName),
    'tax_identifier': _blank(taxIdentifier),
    'receipt_footer': _blank(receiptFooter),
    'tips_enabled': tipsEnabled,
    'tip_presets': tipPresets,
    'invoice_prefix': invoicePrefix.trim(),
    'invoice_footer': _blank(invoiceFooter),
    'receipt_qr': receiptQr,
    'receipt_qr_url': _blank(receiptQrUrl),
    'registration_number': _blank(registrationNumber),
    'whatsapp': _blank(whatsapp),
    'latitude': latitude,
    'longitude': longitude,
    'delivery_zone': _blank(deliveryZone),
    'vacation_mode': vacationMode,
    'vacation_message': _blank(vacationMessage),
    if (hasTicketTexts) ...{
      'receipt_title': _blank(receiptTitle),
      'receipt_subtitle': _blank(receiptSubtitle),
      'receipt_slogan': _blank(receiptSlogan),
      'website': _blank(website)?.replaceAll(RegExp(r'\s'), ''),
      'receipt_qr_title': _blank(receiptQrTitle),
      'receipt_qr_caption': _blank(receiptQrCaption),
      'receipt_farewell': _blank(receiptFarewell),
    },
  };

  static String? _blank(String? s) => (s == null || s.trim().isEmpty) ? null : s.trim();
}

class OpeningHour {
  OpeningHour(this.weekday, this.opensAt, this.closesAt);
  final int weekday; // 1 = lundi … 7 = dimanche
  final String opensAt; // HH:MM
  final String closesAt;

  Map<String, dynamic> toJson() => {'weekday': weekday, 'opens_at': opensAt, 'closes_at': closesAt};
}

class ServiceArea {
  ServiceArea(this.id, this.name, this.active, this.tables);
  final String id;
  final String name;
  final bool active;
  final List<DiningTable> tables;
}

class DiningTable {
  DiningTable(this.id, this.areaId, this.label, this.seats, this.active, {this.shape = 'square', this.posX, this.posY, this.qrToken});
  final String id;
  final String areaId;
  final String label;
  final int seats;
  final bool active;

  /// square, round, rect (plan de salle).
  final String shape;

  /// Position sur la grille du plan (null = placement automatique).
  final int? posX;
  final int? posY;

  /// Jeton du QR code de la table (commande sur place par le client).
  final String? qrToken;
}

class Member {
  Member.fromJson(Map<String, dynamic> j)
    : membershipId = j['membership_id'] as String,
      userId = j['user_id'] as String,
      email = j['email'] as String? ?? '',
      displayName = j['display_name'] as String? ?? '',
      role = j['role_code'] as String,
      allBranches = j['all_branches'] as bool,
      status = j['status'] as String,
      branchIds = ((j['branch_ids'] as List?) ?? const []).cast<String>();

  final String membershipId;
  final String userId;
  final String email;
  final String displayName;
  final String role;
  final bool allBranches;
  final String status;
  final List<String> branchIds;
}

class Invitation {
  Invitation.fromJson(Map<String, dynamic> j)
    : id = j['id'] as String,
      email = j['email'] as String,
      role = j['role_code'] as String,
      expiresAt = DateTime.parse(j['expires_at'] as String);

  final String id;
  final String email;
  final String role;
  final DateTime expiresAt;
}

class AuditEntry {
  AuditEntry.fromJson(Map<String, dynamic> j)
    : id = (j['id'] as num).toInt(),
      createdAt = DateTime.parse(j['created_at'] as String),
      actorName = j['actor_name'] as String? ?? '',
      action = j['action'] as String,
      entity = j['entity'] as String,
      details = (j['details'] as Map?)?.cast<String, dynamic>() ?? const {};

  final int id;
  final DateTime createdAt;
  final String actorName;
  final String action;
  final String entity;
  final Map<String, dynamic> details;
}

/// Rôles proposés à l'invitation, du plus large au plus limité.
const roleCodes = ['owner', 'admin', 'manager', 'accountant', 'cashier', 'stock_keeper', 'waiter', 'kitchen', 'viewer'];
