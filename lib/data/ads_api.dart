import 'dart:math';
import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

int _int(Object? v) => (v as num? ?? 0).toInt();

/// Formats de publicité proposés.
const adFormats = ['video', 'carousel', 'story', 'sponsored_menu', 'push', 'classified'];

/// Moments de diffusion.
const adMoments = ['morning', 'noon', 'afternoon', 'evening', 'night'];

/// Média d'une campagne (photo ou vidéo de la médiathèque).
class AdMedia {
  const AdMedia(this.path, this.kind);
  final String path;

  /// image | video
  final String kind;

  bool get isVideo => kind == 'video';
  Map<String, String> toJson() => {'path': path, 'kind': kind};
}

class AdCampaign {
  AdCampaign({
    this.id,
    required this.organizationId,
    required this.brandId,
    this.format = 'carousel',
    this.title = '',
    this.body,
    this.ctaLabel,
    this.ctaUrl,
    this.media = const [],
    this.itemIds = const [],
    this.branchIds = const [],
    this.targetAreas = const [],
    this.moments = const [],
    this.dailyBudgetMinor,
    this.currency,
    DateTime? startsAt,
    this.endsAt,
    this.status = 'draft',
    this.views = 0,
    this.clicks = 0,
    this.orders = 0,
    this.revenueMinor = 0,
    this.likes = 0,
    this.saves = 0,
    this.comments = 0,
    this.shares = 0,
    this.reach = 0,
    this.createdAt,
  }) : startsAt = startsAt ?? DateTime.now();

  factory AdCampaign.fromJson(Map<String, dynamic> j) => AdCampaign(
        id: j['id'] as String,
        organizationId: j['organization_id'] as String,
        brandId: j['brand_id'] as String,
        format: j['format'] as String,
        title: j['title'] as String,
        body: j['body'] as String?,
        ctaLabel: j['cta_label'] as String?,
        ctaUrl: j['cta_url'] as String?,
        media: [
          for (final m in (j['media'] as List? ?? const []))
            AdMedia((m as Map)['path'] as String, m['kind'] as String? ?? 'image'),
        ],
        itemIds: [for (final i in (j['item_ids'] as List? ?? const [])) i as String],
        branchIds: [for (final b in (j['branch_ids'] as List? ?? const [])) b as String],
        targetAreas: [for (final a in (j['target_areas'] as List? ?? const [])) a as String],
        moments: [for (final m in (j['moments'] as List? ?? const [])) m as String],
        dailyBudgetMinor: (j['daily_budget_minor'] as num?)?.toInt(),
        currency: j['currency'] as String?,
        startsAt: DateTime.parse(j['starts_at'] as String),
        endsAt: j['ends_at'] == null ? null : DateTime.parse(j['ends_at'] as String),
        status: j['status'] as String,
        views: _int(j['views']),
        clicks: _int(j['clicks']),
        orders: _int(j['orders']),
        revenueMinor: _int(j['revenue_minor']),
        likes: _int(j['likes']),
        saves: _int(j['saves']),
        comments: _int(j['comments']),
        shares: _int(j['shares']),
        reach: _int(j['reach']),
        createdAt: j['created_at'] == null ? null : DateTime.parse(j['created_at'] as String),
      );

  String? id;
  final String organizationId;
  final String brandId;
  String format;
  String title;
  String? body;
  String? ctaLabel;
  String? ctaUrl;
  List<AdMedia> media;
  List<String> itemIds;
  List<String> branchIds;
  List<String> targetAreas;
  List<String> moments;
  int? dailyBudgetMinor;
  String? currency;
  DateTime startsAt;
  DateTime? endsAt;
  String status;
  final int views;
  final int clicks;
  final int orders;
  final int revenueMinor;
  final int likes;
  final int saves;
  final int comments;
  final int shares;

  /// Visiteurs uniques.
  final int reach;
  final DateTime? createdAt;

  /// Interactions (J'aime, commentaires, enregistrements, partages).
  int get engagements => likes + comments + saves + shares;

  /// Taux d'engagement (%) rapporté à la portée.
  double get engagementRate => reach == 0 ? 0 : engagements * 100 / reach;

  /// État affiché : brouillon, programmée, active, en pause, terminée.
  String get displayStatus {
    final now = DateTime.now();
    if (status == 'draft' || status == 'paused') return status;
    if (status == 'ended' || (endsAt != null && endsAt!.isBefore(now))) return 'ended';
    if (startsAt.isAfter(now)) return 'scheduled';
    return 'active';
  }

  /// Taux de clic (%).
  double get clickRate => views == 0 ? 0 : clicks * 100 / views;

  /// Avancement de la période de diffusion (0–1), null sans date de fin.
  double? get progress {
    if (endsAt == null) return null;
    final total = endsAt!.difference(startsAt).inSeconds;
    if (total <= 0) return 1;
    return (DateTime.now().difference(startsAt).inSeconds / total).clamp(0, 1).toDouble();
  }

  /// Budget prévu sur toute la période (budget journalier × jours).
  int? get plannedBudget {
    if (dailyBudgetMinor == null || endsAt == null) return null;
    final days = max(1, (endsAt!.difference(startsAt).inHours / 24).ceil());
    return dailyBudgetMinor! * days;
  }

  Map<String, dynamic> toJson() => {
        'format': format,
        'title': title.trim(),
        'body': _blank(body),
        'cta_label': _blank(ctaLabel),
        'cta_url': _blank(ctaUrl),
        'media': [for (final m in media) m.toJson()],
        'item_ids': itemIds,
        'branch_ids': branchIds,
        'target_areas': targetAreas,
        'moments': moments,
        'daily_budget_minor': dailyBudgetMinor,
        'currency': currency,
        'starts_at': startsAt.toUtc().toIso8601String(),
        'ends_at': format == 'story' ? null : endsAt?.toUtc().toIso8601String(),
        'status': status,
      };

  static String? _blank(String? s) => (s == null || s.trim().isEmpty) ? null : s.trim();
}

/// Commentaire d'un client sous une campagne (modérable).
class AdComment {
  AdComment.fromJson(Map<String, dynamic> j)
      : id = j['id'] as String,
        campaignId = j['campaign_id'] as String,
        author = j['author_name'] as String,
        body = j['body'] as String,
        hidden = j['status'] == 'hidden',
        hiddenReason = j['hidden_reason'] as String?,
        createdAt = DateTime.parse(j['created_at'] as String);
  final String id;
  final String campaignId;
  final String author;
  final String body;
  final bool hidden;
  final String? hiddenReason;
  final DateTime createdAt;
}

/// Fichier de la médiathèque publicitaire.
class LibraryFile {
  const LibraryFile(this.path, this.name, this.size, this.createdAt);
  final String path;
  final String name;
  final int size;
  final DateTime? createdAt;

  bool get isVideo => const ['mp4', 'webm', 'mov'].contains(name.split('.').last.toLowerCase());
}

class AdsApi {
  AdsApi(this._db);
  final SupabaseClient _db;
  static const bucket = 'marketing-media';

  Future<List<AdCampaign>> campaigns(String orgId) async {
    final rows = await _db.from('ad_campaigns').select().eq('organization_id', orgId).order('created_at', ascending: false);
    return [for (final r in rows) AdCampaign.fromJson(r)];
  }

  Future<AdCampaign> save(AdCampaign c) async {
    final row = c.id == null
        ? await _db
            .from('ad_campaigns')
            .insert({...c.toJson(), 'organization_id': c.organizationId, 'brand_id': c.brandId})
            .select()
            .single()
        : await _db.from('ad_campaigns').update(c.toJson()).eq('id', c.id!).select().single();
    return AdCampaign.fromJson(row);
  }

  /// Nombre de clients qui recevraient une offre « Notification » ; null si
  /// l'information n'est pas disponible (indicatif seulement).
  Future<int?> audienceCount(String brandId, List<String> branchIds) async {
    try {
      final r = await _db.rpc('promotion_audience_count', params: {'p_brand': brandId, 'p_branch_ids': branchIds});
      return (r as num).toInt();
    } catch (_) {
      return null;
    }
  }

  Future<void> setStatus(String id, String status) => _db.from('ad_campaigns').update({'status': status}).eq('id', id);

  Future<void> delete(String id) => _db.from('ad_campaigns').delete().eq('id', id);

  /// Derniers commentaires des campagnes de l'organisation.
  Future<List<AdComment>> comments(String orgId) async {
    final rows = await _db
        .from('ad_comments')
        .select('id, campaign_id, author_name, body, status, hidden_reason, created_at')
        .eq('organization_id', orgId)
        .order('created_at', ascending: false)
        .limit(200);
    return [for (final r in rows) AdComment.fromJson(r)];
  }

  /// Masquer (avec un motif) ou republier un commentaire.
  Future<void> moderateComment(String id, bool hidden, [String? reason]) =>
      _db.rpc('moderate_ad_comment', params: {'p_comment': id, 'p_hidden': hidden, 'p_reason': reason});

  // --- Médiathèque : {organisation}/{fichier}

  String publicUrl(String path) => _db.storage.from(bucket).getPublicUrl(path);

  Future<List<LibraryFile>> library(String orgId) async {
    final files = await _db.storage.from(bucket).list(
          path: orgId,
          searchOptions: const SearchOptions(limit: 500, sortBy: SortBy(column: 'created_at', order: 'desc')),
        );
    return [
      for (final f in files)
        if (f.id != null)
          LibraryFile('$orgId/${f.name}', f.name, (f.metadata?['size'] as num? ?? 0).toInt(),
              f.createdAt == null ? null : DateTime.tryParse(f.createdAt!)),
    ];
  }

  Future<String> upload(String orgId, Uint8List bytes, String extension) async {
    final ext = extension.toLowerCase() == 'jpg' ? 'jpeg' : extension.toLowerCase();
    final type = switch (ext) {
      'mp4' => 'video/mp4',
      'webm' => 'video/webm',
      'mov' => 'video/quicktime',
      _ => 'image/$ext',
    };
    // 1 << 32 vaut 0 dans un navigateur (opérations sur 32 bits) : nextInt échouait sur le Web.
    final rnd = Random.secure().nextInt(0x3fffffff).toRadixString(36);
    final path = '$orgId/${DateTime.now().millisecondsSinceEpoch}-$rnd.${ext == 'jpeg' ? 'jpg' : ext}';
    await _db.storage.from(bucket).uploadBinary(path, bytes, fileOptions: FileOptions(contentType: type));
    return path;
  }

  Future<void> removeFile(String path) => _db.storage.from(bucket).remove([path]);
}
