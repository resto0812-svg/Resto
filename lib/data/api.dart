import 'dart:math';
import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'ads_api.dart';
import 'cash_api.dart';
import 'customer_api.dart';
import 'dashboard_api.dart';
import 'prefs_api.dart';
import 'loyalty_api.dart';
import '../core/push_service.dart';
import 'menu_api.dart';
import 'orders_api.dart';
import 'purchases_api.dart';
import 'reservations_api.dart';
import 'stock_api.dart';
import 'models.dart';

/// Accès aux données. Les lectures passent par la RLS ; les opérations
/// sensibles par les fonctions RPC (droits vérifiés par le serveur).
class Api {
  Api(this._db);

  final SupabaseClient _db;

  /// Menus (catalogue, suppléments, prix).
  late final MenuApi menu = MenuApi(_db);

  /// Commandes.
  late final OrdersApi orders = OrdersApi(_db);

  /// Caisse.
  late final CashApi cash = CashApi(_db);

  /// Stocks et fiches techniques.
  late final StockApi stock = StockApi(_db);

  /// Achats, dépenses, rapport financier.
  late final PurchasesApi purchases = PurchasesApi(_db);

  /// Réservations (côté restaurant).
  late final ReservationsApi reservations = ReservationsApi(_db);

  /// Promotions, fidélité, avis (côté restaurant).
  late final LoyaltyApi loyalty = LoyaltyApi(_db);

  /// Espace client (catalogue public, commandes en ligne, réservations).
  late final CustomerApi customer = CustomerApi(_db);

  /// Publicité (campagnes, médiathèque, statistiques).
  late final AdsApi ads = AdsApi(_db);

  /// Tableau de bord d'un établissement.
  late final DashboardApi dashboard = DashboardApi(_db);

  /// Préférences du membre connecté (notifications, sons).
  late final PrefsApi prefs = PrefsApi(_db);

  GoTrueClient get auth => _db.auth;
  User? get user => _db.auth.currentUser;

  // ------------------------------------------------------------ compte

  Future<void> signUp({
    required String email,
    required String password,
    required String name,
    required String locale,
    required String accountType,
  }) => _db.auth.signUp(email: email, password: password, data: {'display_name': name, 'locale': locale, 'account_type': accountType});

  /// Type de compte choisi à l'inscription : « customer » (client) ou « business » (entreprise).
  /// Sert seulement à ouvrir la bonne interface ; les droits restent vérifiés par le serveur.
  String? get accountType => user?.userMetadata?['account_type'] as String?;

  Future<void> setAccountType(String type) => _db.auth.updateUser(UserAttributes(data: {'account_type': type}));

  Future<void> signIn(String email, String password) => _db.auth.signInWithPassword(email: email, password: password);

  Future<void> verifyCode(String email, String code, OtpType type) => _db.auth.verifyOTP(email: email, token: code, type: type);

  Future<void> resendSignupCode(String email) => _db.auth.resend(type: OtpType.signup, email: email);

  /// Même réponse que le compte existe ou non (pas d'énumération des comptes).
  Future<void> sendPasswordReset(String email) => _db.auth.resetPasswordForEmail(email);

  Future<void> setPassword(String password) => _db.auth.updateUser(UserAttributes(password: password));

  /// Déconnexion : l'appareil cesse d'abord de recevoir les notifications du compte.
  Future<void> signOut() async {
    await PushService.instance.unregister(this);
    await _db.auth.signOut();
  }

  /// Appareil qui reçoit les notifications push du compte connecté.
  Future<void> registerPushDevice(String token, String platform, String locale) =>
      _db.rpc('register_push_device', params: {'p_token': token, 'p_platform': platform, 'p_locale': locale});

  Future<void> unregisterPushDevice(String token) => _db.rpc('unregister_push_device', params: {'p_token': token});

  /// Étapes du guide « Bien démarrer » déjà faites (organisation).
  Future<Set<String>> gettingStartedDone(String orgId) async {
    Future<bool> any(String table, {bool active = false}) async {
      try {
        var q = _db.from(table).select('id').eq('organization_id', orgId);
        if (active) q = q.eq('active', true);
        return (await q.limit(1)).isNotEmpty;
      } catch (_) {
        return false;
      }
    }

    final r = await Future.wait<dynamic>([
      branches(orgId),
      any('menu_items'),
      any('dining_tables', active: true),
      any('payment_methods', active: true),
      _db.from('memberships').select('id').eq('organization_id', orgId).eq('status', 'active').limit(2).then((v) => v.length > 1, onError: (_) => false),
    ]);
    final list = (r[0] as List<Branch>).where((b) => b.status == 'active').toList();
    return {
      if (list.any((b) => (b.addressLine1 ?? '').isNotEmpty && (b.phone ?? '').isNotEmpty)) 'profile',
      if (r[1] as bool) 'dishes',
      if (r[2] as bool) 'tables',
      if (r[3] as bool) 'payments',
      if (r[4] as bool) 'team',
      if (list.any((b) => b.isPublished)) 'published',
    };
  }

  Future<Map<String, dynamic>?> myProfile() async {
    if (user == null) return null;
    return _db.from('profiles').select('display_name, locale, country_code, phone').eq('id', user!.id).maybeSingle();
  }

  /// Langue enregistrée dans le profil et dans les métadonnées du compte
  /// (utilisées par les modèles d'e-mails d'authentification).
  Future<void> saveLocale(String locale) async {
    if (user == null) return;
    await _db.from('profiles').update({'locale': locale}).eq('id', user!.id);
    await _db.auth.updateUser(UserAttributes(data: {'locale': locale}));
  }

  Future<void> savePhone(String phone) =>
      _db.from('profiles').update({'phone': phone.trim().isEmpty ? null : phone.trim()}).eq('id', user!.id);

  Future<void> saveDisplayName(String name) async {
    await _db.from('profiles').update({'display_name': name.trim()}).eq('id', user!.id);
    await _db.auth.updateUser(UserAttributes(data: {'display_name': name.trim()}));
  }

  // ------------------------------------------------------------ référentiels

  Future<References> references() async {
    final results = await Future.wait<dynamic>([
      _db.from('ref_countries').select('code, name').eq('active', true).order('name'),
      _db.from('ref_currencies').select('code, name, minor_unit').eq('active', true).order('code'),
      _db.rpc('list_timezones'),
    ]);
    return References(
      countries: [for (final r in results[0] as List) Country(r['code'] as String, r['name'] as String)],
      currencies: [
        for (final r in results[1] as List) Currency(r['code'] as String, r['name'] as String, (r['minor_unit'] as num).toInt()),
      ],
      timezones: (results[2] as List).cast<String>(),
    );
  }

  // ------------------------------------------------------------ organisations

  Future<List<Membership>> myMemberships() async {
    final data = await _db.rpc('my_memberships') as List;
    return [for (final m in data) Membership.fromJson((m as Map).cast<String, dynamic>())];
  }

  Future<void> createOrganization({
    required String name,
    required String country,
    required String currency,
    required String locale,
    required String timezone,
    required String city,
    String? brandName,
    String? branchName,
  }) => _db.rpc(
    'create_organization',
    params: {
      'p_name': name,
      'p_country': country,
      'p_currency': currency,
      'p_locale': locale,
      'p_timezone': timezone,
      'p_city': city,
      'p_brand_name': brandName,
      'p_branch_name': branchName,
    },
  );

  Future<String> acceptInvitation(String token) async => await _db.rpc('accept_invitation', params: {'p_token': token.trim()}) as String;

  // ------------------------------------------------------------ établissements

  static const _branchColumns = '*, branch_languages(locale)';

  Future<List<Branch>> branches(String orgId) async {
    final data = await _db.from('branches').select(_branchColumns).eq('organization_id', orgId).order('name');
    return [for (final b in data) Branch.fromJson(b)];
  }

  /// Fiche publique de la marque (nom, slogan, description, cuisines, gamme de prix, logo).
  Future<Map<String, dynamic>> brand(String brandId) => _db.from('brands').select('*').eq('id', brandId).single();

  /// Identité de la marque (Paramètres › Profil de l'établissement).
  Future<void> saveBrandIdentity(
    String brandId, {
    required String name,
    String? slogan,
    String? description,
    required List<String> cuisines,
    int? priceLevel,
  }) => _db
      .from('brands')
      .update({
        'name': name.trim(),
        'slogan': (slogan == null || slogan.trim().isEmpty) ? null : slogan.trim(),
        'description': (description == null || description.trim().isEmpty) ? null : description.trim(),
        'cuisines': cuisines,
        'price_level': priceLevel,
      })
      .eq('id', brandId);

  Future<void> saveBrandProfile(String brandId, {String? description, required List<String> cuisines, int? priceLevel}) => _db
      .from('brands')
      .update({
        'description': (description == null || description.trim().isEmpty) ? null : description.trim(),
        'cuisines': cuisines,
        'price_level': priceLevel,
      })
      .eq('id', brandId);

  // --- Logo du restaurant (bucket public « brand-logos », dossier de l'organisation)

  static final _logoBytes = <String, Uint8List>{};

  Future<String?> brandLogoPath(String brandId) async {
    final row = await _db.from('brands').select('logo_path').eq('id', brandId).maybeSingle();
    return row?['logo_path'] as String?;
  }

  Future<String?> brandName(String brandId) async {
    try {
      final row = await _db.from('brands').select('name').eq('id', brandId).maybeSingle();
      return row?['name'] as String?;
    } catch (_) {
      return null;
    }
  }

  Future<String?> brandSlogan(String brandId) async {
    try {
      final row = await _db.from('brands').select('slogan').eq('id', brandId).maybeSingle();
      return row?['slogan'] as String?;
    } catch (_) {
      return null;
    }
  }

  String brandLogoUrl(String path) => _db.storage.from('brand-logos').getPublicUrl(path);

  /// Octets du logo pour les tickets (mis en cache) ; null s'il n'y en a pas ou s'il est illisible.
  Future<Uint8List?> brandLogo(String brandId) async {
    try {
      final path = await brandLogoPath(brandId);
      if (path == null) return null;
      return _logoBytes[path] ??= await _db.storage.from('brand-logos').download(path);
    } catch (_) {
      return null;
    }
  }

  /// Remplace le logo : nouveau fichier (nom unique, pas de cache périmé), puis suppression de l'ancien.
  /// Photo d'ambiance d'un établissement ({organisation}/covers/…, bucket des photos de la carte).
  Future<String> uploadBranchCover(String orgId, String branchId, Uint8List bytes, String extension) async {
    final ext = extension.toLowerCase() == 'jpg' ? 'jpeg' : extension.toLowerCase();
    final path = '$orgId/covers/$branchId-${DateTime.now().millisecondsSinceEpoch}.${ext == 'jpeg' ? 'jpg' : ext}';
    await _db.storage.from('menu-images').uploadBinary(path, bytes, fileOptions: FileOptions(contentType: 'image/$ext'));
    await _db.from('branches').update({'cover_path': path}).eq('id', branchId);
    return path;
  }

  Future<void> removeBranchCover(String branchId) => _db.from('branches').update({'cover_path': null}).eq('id', branchId);

  String menuImageUrl(String path) => _db.storage.from('menu-images').getPublicUrl(path);

  Future<String> uploadBrandLogo(String orgId, String brandId, Uint8List bytes, String extension) async {
    final ext = extension == 'jpg' ? 'jpeg' : extension;
    final path = '$orgId/$brandId/logo-${DateTime.now().millisecondsSinceEpoch}.$ext';
    final old = await brandLogoPath(brandId);
    await _db.storage.from('brand-logos').uploadBinary(path, bytes, fileOptions: FileOptions(contentType: 'image/$ext'));
    await _db.from('brands').update({'logo_path': path}).eq('id', brandId);
    _logoBytes[path] = bytes;
    if (old != null) await _db.storage.from('brand-logos').remove([old]).catchError((_) => <FileObject>[]);
    return path;
  }

  Future<void> removeBrandLogo(String brandId) async {
    final old = await brandLogoPath(brandId);
    await _db.from('brands').update({'logo_path': null}).eq('id', brandId);
    if (old != null) {
      _logoBytes.remove(old);
      await _db.storage.from('brand-logos').remove([old]).catchError((_) => <FileObject>[]);
    }
  }

  // --- Clients du restaurant (fiche propre à l'organisation)

  Future<List<Map<String, dynamic>>> restaurantCustomers(String orgId) async =>
      (await _db.from('restaurant_customers').select().eq('organization_id', orgId).order('last_order_at', ascending: false).limit(500))
          .cast<Map<String, dynamic>>();

  Future<void> saveCustomerNotes(String id, String notes) =>
      _db.from('restaurant_customers').update({'notes': notes.trim().isEmpty ? null : notes.trim()}).eq('id', id);

  /// Commandes d'un client dans les établissements visibles par le membre.
  Future<List<Map<String, dynamic>>> customerOrders(String orgId, String userId) async =>
      (await _db
              .from('orders')
              .select('id, number, business_date, total_minor, currency, status, channel, opened_at')
              .eq('organization_id', orgId)
              .eq('customer_user_id', userId)
              .order('opened_at', ascending: false)
              .limit(30))
          .cast<Map<String, dynamic>>();

  Future<String?> firstBrandId(String orgId) async {
    final row = await _db.from('brands').select('id').eq('organization_id', orgId).order('created_at').limit(1).maybeSingle();
    return row?['id'] as String?;
  }

  /// Crée ou met à jour l'établissement puis ses langues proposées.
  Future<Branch> saveBranch(Branch b) async {
    if (b.id == null) {
      final base = slugify(b.name).isEmpty ? 'site' : slugify(b.name);
      b.slug = base;
      Map<String, dynamic> row;
      try {
        row = await _insertBranch(b);
      } on PostgrestException catch (e) {
        if (e.code != '23505') rethrow;
        b.slug = '${base.length > 50 ? base.substring(0, 50) : base}-${_randomSuffix()}';
        row = await _insertBranch(b);
      }
      b.id = row['id'] as String;
    } else {
      await _db.from('branches').update(b.editableJson()).eq('id', b.id!);
    }
    await _saveLanguages(b);
    return b;
  }

  Future<Map<String, dynamic>> _insertBranch(Branch b) =>
      _db.from('branches').insert({...b.editableJson(), 'organization_id': b.organizationId, 'brand_id': b.brandId}).select('id').single();

  Future<void> _saveLanguages(Branch b) async {
    final current = await _db.from('branch_languages').select('locale').eq('branch_id', b.id!);
    final existing = {for (final r in current) r['locale'] as String};
    final wanted = {...b.languages, b.defaultLocale};
    final toRemove = existing.difference(wanted);
    final toAdd = wanted.difference(existing);
    if (toRemove.isNotEmpty) {
      await _db.from('branch_languages').delete().eq('branch_id', b.id!).inFilter('locale', toRemove.toList());
    }
    if (toAdd.isNotEmpty) {
      await _db.from('branch_languages').insert([
        for (final l in toAdd) {'organization_id': b.organizationId, 'branch_id': b.id, 'locale': l},
      ]);
    }
  }

  Future<List<OpeningHour>> openingHours(String branchId) async {
    final data = await _db
        .from('branch_opening_hours')
        .select('weekday, opens_at, closes_at')
        .eq('branch_id', branchId)
        .order('weekday')
        .order('opens_at');
    return [
      for (final r in data)
        OpeningHour((r['weekday'] as num).toInt(), (r['opens_at'] as String).substring(0, 5), (r['closes_at'] as String).substring(0, 5)),
    ];
  }

  Future<void> setOpeningHours(String branchId, List<OpeningHour> hours) => _db.rpc(
    'set_opening_hours',
    params: {
      'p_branch': branchId,
      'p_hours': [for (final h in hours) h.toJson()],
    },
  );

  // ------------------------------------------------------------ salle

  Future<List<ServiceArea>> floor(String branchId) async {
    final data = await _db
        .from('service_areas')
        .select(
          'id, name, active, sort_order, '
          'dining_tables(id, service_area_id, label, seats, active, shape, pos_x, pos_y, qr_token)',
        )
        .eq('branch_id', branchId)
        .order('sort_order')
        .order('name');
    return [
      for (final a in data)
        ServiceArea(
          a['id'] as String,
          a['name'] as String,
          a['active'] as bool,
          [
            for (final t in (a['dining_tables'] as List))
              DiningTable(
                t['id'] as String,
                t['service_area_id'] as String,
                t['label'] as String,
                (t['seats'] as num).toInt(),
                t['active'] as bool,
                shape: t['shape'] as String? ?? 'square',
                posX: (t['pos_x'] as num?)?.toInt(),
                posY: (t['pos_y'] as num?)?.toInt(),
                qrToken: t['qr_token'] as String?,
              ),
          ]..sort((x, y) => _naturalCompare(x.label, y.label)),
        ),
    ];
  }

  Future<void> saveArea({required String orgId, required String branchId, String? id, required String name, bool active = true}) {
    if (id == null) {
      return _db.from('service_areas').insert({'organization_id': orgId, 'branch_id': branchId, 'name': name.trim()});
    }
    return _db.from('service_areas').update({'name': name.trim(), 'active': active}).eq('id', id);
  }

  Future<void> saveTable({
    required String orgId,
    required String branchId,
    String? id,
    required String areaId,
    required String label,
    required int seats,
    bool active = true,
    String shape = 'square',
  }) {
    final values = {'service_area_id': areaId, 'label': label.trim(), 'seats': seats, 'active': active, 'shape': shape};
    if (id == null) {
      return _db.from('dining_tables').insert({...values, 'organization_id': orgId, 'branch_id': branchId});
    }
    return _db.from('dining_tables').update(values).eq('id', id);
  }

  /// Position d'une table sur le plan de salle (cases de la grille).
  Future<void> placeTable(String id, int x, int y) =>
      _db.from('dining_tables').update({'pos_x': x.clamp(0, 59), 'pos_y': y.clamp(0, 59)}).eq('id', id);

  // ------------------------------------------------------------ équipe

  Future<List<Member>> members(String orgId) async {
    final data = await _db.rpc('org_members', params: {'p_org': orgId}) as List;
    return [for (final m in data) Member.fromJson((m as Map).cast<String, dynamic>())];
  }

  Future<List<Invitation>> pendingInvitations(String orgId) async {
    final data = await _db
        .from('invitations')
        .select('id, email, role_code, expires_at')
        .eq('organization_id', orgId)
        .eq('status', 'pending')
        .gt('expires_at', DateTime.now().toUtc().toIso8601String())
        .order('created_at', ascending: false);
    return [for (final i in data) Invitation.fromJson(i)];
  }

  /// Renvoie le code d'invitation, à transmettre une seule fois à l'invité.
  Future<String> invite(String orgId, String email, String role, bool allBranches, List<String> branchIds) async => await _db.rpc(
    'invite_member',
    params: {'p_org': orgId, 'p_email': email, 'p_role': role, 'p_all_branches': allBranches, 'p_branch_ids': branchIds},
  ) as String;

  Future<void> revokeInvitation(String id) => _db.rpc('revoke_invitation', params: {'p_invitation': id});

  Future<void> updateMembership(String membershipId, String role, bool allBranches, List<String> branchIds) => _db.rpc(
    'update_membership',
    params: {'p_membership': membershipId, 'p_role': role, 'p_all_branches': allBranches, 'p_branch_ids': branchIds},
  );

  Future<void> revokeMembership(String membershipId) => _db.rpc('revoke_membership', params: {'p_membership': membershipId});

  // ------------------------------------------------------------ audit

  Future<List<AuditEntry>> audit(String orgId, {int? before}) async {
    final data = await _db.rpc('audit_entries', params: {'p_org': orgId, 'p_before': before, 'p_limit': 50}) as List;
    return [for (final a in data) AuditEntry.fromJson((a as Map).cast<String, dynamic>())];
  }
}

/// « Chez Léa — Akwa » → « chez-lea-akwa » (même règle que app_private.slugify).
String slugify(String input) {
  const from = 'àâäáãåçéèêëíìîïñóòôöõúùûüýÿ';
  const to = 'aaaaaaceeeeiiiinooooouuuuyy';
  final lower = input.toLowerCase();
  final b = StringBuffer();
  for (final ch in lower.split('')) {
    final i = from.indexOf(ch);
    b.write(i >= 0 ? to[i] : ch);
  }
  final slug = b.toString().replaceAll(RegExp('[^a-z0-9]+'), '-').replaceAll(RegExp(r'^-+|-+$'), '');
  return slug.length > 50 ? slug.substring(0, 50).replaceAll(RegExp(r'-+$'), '') : slug;
}

String _randomSuffix() {
  final r = Random.secure();
  return List.generate(4, (_) => 'abcdefghijkmnpqrstuvwxyz23456789'[r.nextInt(32)]).join();
}

/// « T2 » avant « T10 ».
int _naturalCompare(String a, String b) {
  final re = RegExp(r'(\d+)|(\D+)');
  final pa = re.allMatches(a).map((m) => m[0]!).toList();
  final pb = re.allMatches(b).map((m) => m[0]!).toList();
  for (var i = 0; i < pa.length && i < pb.length; i++) {
    final na = int.tryParse(pa[i]);
    final nb = int.tryParse(pb[i]);
    final c = (na != null && nb != null) ? na.compareTo(nb) : pa[i].compareTo(pb[i]);
    if (c != 0) return c;
  }
  return pa.length.compareTo(pb.length);
}
