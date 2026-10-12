import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../app_state.dart';
import '../../core/money.dart';
import '../../data/ads_api.dart';
import '../../data/menu_models.dart';
import '../../data/models.dart';
import '../../ui/branch_scope.dart';
import '../../ui/common.dart';
import '../../ui/files.dart';
import '../../ui/header_slot.dart';
import '../../ui/image_compress.dart';
import '../../ui/kit.dart';
import '../../ui/theme.dart';
import '../menus/menu_widgets.dart';

/// Publicité : créer une pub (6 formats), mes
/// campagnes (statistiques, booster), bibliothèque (photos, vidéos),
/// statistiques. Les budgets sont des budgets prévus : la diffusion payante
/// sera facturée par la plateforme.
class AdsScreen extends StatelessWidget {
  const AdsScreen({super.key, required this.membership});
  final Membership membership;

  @override
  Widget build(BuildContext context) => BranchScope(
    membership: membership,
    builder: (context, scope) => _Ads(scope: scope),
  );
}

/// Données communes du module.
class _AdsData {
  _AdsData(this.campaigns, this.items, this.branches, this.brandId, this.brandName);
  final List<AdCampaign> campaigns;
  final List<MenuItem> items;
  final List<Branch> branches;
  final String brandId;
  final String brandName;
}

class _Ads extends StatefulWidget {
  const _Ads({required this.scope});
  final BranchContext scope;

  @override
  State<_Ads> createState() => _AdsState();
}

class _AdsState extends State<_Ads> {
  int _tab = 0;
  AdCampaign? _editing;
  late Future<_AdsData> _data = _load();

  BranchContext get scope => widget.scope;

  Future<_AdsData> _load() async {
    final api = AppScope.read(context).api!;
    final brandId = scope.branch.brandId;
    final r = await Future.wait<dynamic>([
      api.ads.campaigns(scope.orgId),
      api.menu.load(brandId),
      api.branches(scope.orgId),
      api.brandName(brandId),
    ]);
    return _AdsData(
      r[0] as List<AdCampaign>,
      (r[1] as BrandMenu).items.where((i) => i.active).toList(),
      (r[2] as List<Branch>).where((b) => b.status == 'active').toList(),
      brandId,
      (r[3] as String?) ?? scope.membership.organizationName,
    );
  }

  void _reload() => setState(() => _data = _load());

  @override
  void dispose() {
    HeaderSlot.clear(this);
    super.dispose();
  }

  void _edit(AdCampaign c) => setState(() {
    _editing = c;
    _tab = 0;
  });

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return FutureBuilder<_AdsData>(
      future: _data,
      builder: (context, snap) {
        if (snap.hasError) {
          return Center(
            child: TextButton(onPressed: _reload, child: Text(t.retry)),
          );
        }
        if (!snap.hasData) return const Center(child: CircularProgressIndicator());
        final data = snap.data!;
        final body = switch (_tab) {
          0 => _CreateTab(
            key: ValueKey(_editing?.id ?? 'new'),
            scope: scope,
            data: data,
            initial: _editing,
            onSaved: () {
              _editing = null;
              _tab = 1;
              _reload();
            },
          ),
          1 => _CampaignsTab(scope: scope, data: data, onEdit: _edit, onChanged: _reload),
          2 => _LibraryTab(scope: scope),
          3 => _StatsTab(scope: scope, data: data),
          _ => _CommentsTab(scope: scope, data: data),
        };
        // Onglets dans l'en-tête, juste à côté du titre « Publicité ».
        HeaderSlot.show(
          this,
          'ads',
          PillBar<int>(
            dense: true,
            items: [
              PillItem(0, _editing == null ? t.adsCreate : t.adsEdit, icon: Icons.auto_awesome_rounded),
              PillItem(1, t.adsCampaigns, icon: Icons.campaign_outlined, count: data.campaigns.length),
              PillItem(2, t.adsLibrary, icon: Icons.photo_library_outlined),
              PillItem(3, t.adsStats, icon: Icons.insights_rounded),
              PillItem(4, t.commentsTitle, icon: Icons.mode_comment_outlined, count: data.campaigns.fold<int>(0, (a, c) => a + c.comments)),
            ],
            selected: _tab,
            onSelected: (i) => setState(() {
              if (i == 0 && _tab == 0) _editing = null;
              _tab = i;
            }),
          ),
        );
        return body;
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Libellés

String adFormatLabel(BuildContext context, String f) {
  final t = context.t;
  return switch (f) {
    'video' => t.adFormatVideo,
    'carousel' => t.adFormatCarousel,
    'story' => t.adFormatStory,
    'sponsored_menu' => t.adFormatSponsoredMenu,
    'push' => t.adFormatPush,
    _ => t.adFormatClassified,
  };
}

String adFormatHint(BuildContext context, String f) {
  final t = context.t;
  return switch (f) {
    'video' => t.adFormatVideoHint,
    'carousel' => t.adFormatCarouselHint,
    'story' => t.adFormatStoryHint,
    'sponsored_menu' => t.adFormatSponsoredMenuHint,
    'push' => t.adFormatPushHint,
    _ => t.adFormatClassifiedHint,
  };
}

IconData adFormatIcon(String f) => switch (f) {
  'video' => Icons.play_circle_outline_rounded,
  'carousel' => Icons.collections_outlined,
  'story' => Icons.auto_awesome_outlined,
  'sponsored_menu' => Icons.restaurant_menu_rounded,
  'push' => Icons.notifications_active_outlined,
  _ => Icons.article_outlined,
};

String _momentLabel(BuildContext context, String m) {
  final t = context.t;
  return switch (m) {
    'morning' => t.momentMorning,
    'noon' => t.momentNoon,
    'afternoon' => t.momentAfternoon,
    'evening' => t.momentEvening,
    _ => t.momentNight,
  };
}

(String, Color) _statusInfo(BuildContext context, String s) {
  final t = context.t;
  return switch (s) {
    'active' => (t.adStatusActive, const Color(0xFF2E9E5B)),
    'scheduled' => (t.adStatusScheduled, StatusColors.reserved),
    'paused' => (t.adStatusPaused, StatusColors.toValidate),
    'ended' => (t.adStatusEnded, StatusColors.done),
    _ => (t.adStatusDraft, RestoColors.muted),
  };
}

// ---------------------------------------------------------------------------
// Créer / modifier une publicité

class _CreateTab extends StatefulWidget {
  const _CreateTab({super.key, required this.scope, required this.data, required this.initial, required this.onSaved});
  final BranchContext scope;
  final _AdsData data;
  final AdCampaign? initial;
  final VoidCallback onSaved;

  @override
  State<_CreateTab> createState() => _CreateTabState();
}

class _CreateTabState extends State<_CreateTab> {
  late final AdCampaign c =
      widget.initial ??
      AdCampaign(
        organizationId: widget.scope.orgId,
        brandId: widget.data.brandId,
        currency: widget.scope.currency,
        endsAt: DateTime.now().add(const Duration(days: 7)),
      );
  late final _title = TextEditingController(text: c.title);
  late final _body = TextEditingController(text: c.body ?? '');
  late final _cta = TextEditingController(text: c.ctaLabel ?? '');
  late final _url = TextEditingController(text: c.ctaUrl ?? '');
  late final _budget = TextEditingController(
    text: c.dailyBudgetMinor == null ? '' : amountText(c.dailyBudgetMinor!, widget.scope.currency, widget.scope.minorUnit),
  );
  final _area = TextEditingController();

  /// Fichiers en cours d'envoi (indicateur).
  int _uploading = 0;

  @override
  void initState() {
    super.initState();
    for (final ctl in [_title, _body, _cta]) {
      ctl.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    for (final ctl in [_title, _body, _cta, _url, _budget, _area]) {
      ctl.dispose();
    }
    super.dispose();
  }

  List<String> get _areaSuggestions {
    final zones = <String>{};
    for (final b in widget.data.branches) {
      for (final z in (b.deliveryZone ?? '').split(RegExp(r'[,;\n]'))) {
        if (z.trim().isNotEmpty && z.trim().length <= 40) zones.add(z.trim());
      }
      if (b.city.isNotEmpty) zones.add(b.city);
    }
    return zones.where((z) => !c.targetAreas.contains(z)).take(12).toList();
  }

  Future<void> _addMedia({required bool fromLibrary}) async {
    final t = context.t;
    final api = AppScope.read(context).api!.ads;
    final videos = c.format == 'video' || c.format == 'story';
    final images = c.format != 'video';
    if (fromLibrary) {
      final picked = await showDialog<List<AdMedia>>(
        context: context,
        builder: (_) => _LibraryPicker(orgId: widget.scope.orgId, videos: videos, images: images),
      );
      if (picked != null && mounted) setState(() => c.media = [...c.media, ...picked].take(10).toList());
      return;
    }
    final files = await pickMedia(videos: videos, images: images, multiple: c.format == 'carousel');
    if (files.isEmpty || !mounted) return;
    setState(() => _uploading = files.length);
    try {
      final added = <AdMedia>[];
      for (final picked in files) {
        final video = isVideoName(picked.name);
        // Photos de téléphone : réduites automatiquement sous la limite.
        final f = video ? picked : await compressPhoto(picked);
        if (f.bytes.length > (video ? maxVideoBytes : maxPhotoBytes)) {
          if (mounted) showInfo(context, video ? t.adVideoTooBig(picked.name) : t.fileTooBig(picked.name));
          continue;
        }
        added.add(AdMedia(await api.upload(widget.scope.orgId, f.bytes, f.extension), video ? 'video' : 'image'));
        if (mounted) setState(() => c.media = [...c.media, added.last].take(10).toList());
      }
      if (added.isNotEmpty && mounted) showInfo(context, t.adMediaAdded(added.length));
    } catch (e) {
      if (mounted) showError(context, e);
    } finally {
      if (mounted) setState(() => _uploading = 0);
    }
  }

  Future<void> _pickDate({required bool start}) async {
    final now = DateTime.now();
    final initial = start ? c.startsAt : (c.endsAt ?? c.startsAt.add(const Duration(days: 7)));
    final d = await showDatePicker(
      context: context,
      initialDate: initial.isBefore(now) ? now : initial,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: now.add(const Duration(days: 730)),
    );
    if (d == null) return;
    setState(() {
      if (start) {
        c.startsAt = DateTime(d.year, d.month, d.day, now.hour, now.minute);
        if (c.endsAt != null && !c.endsAt!.isAfter(c.startsAt)) c.endsAt = c.startsAt.add(const Duration(days: 7));
      } else {
        c.endsAt = DateTime(d.year, d.month, d.day, 23, 59);
      }
    });
  }

  Future<void> _save({required bool publish}) async {
    final t = context.t;
    if (_title.text.trim().isEmpty) {
      showInfo(context, t.adTitleRequired);
      return;
    }
    if (publish) {
      final hasVideo = c.media.any((m) => m.isVideo);
      final message = switch (c.format) {
        'video' when !hasVideo => t.adNeedVideo,
        'carousel' || 'story' when c.media.isEmpty => t.adNeedMedia,
        'sponsored_menu' when c.itemIds.isEmpty => t.adNeedItems,
        _ => null,
      };
      if (message != null) {
        showInfo(context, message);
        return;
      }
    }
    final url = _url.text.trim();
    if (url.isNotEmpty && !RegExp(r'^https?://\S+$').hasMatch(url)) {
      showInfo(context, t.receiptQrUrlInvalid);
      return;
    }
    c
      ..title = _title.text
      ..body = _body.text
      ..ctaLabel = _cta.text
      ..ctaUrl = url
      ..dailyBudgetMinor = parseAmount(_budget.text, widget.scope.currency, widget.scope.minorUnit)
      ..currency = widget.scope.currency
      ..status = publish ? 'active' : (c.status == 'active' ? 'active' : 'draft');
    if (!publish && c.status == 'draft') c.status = 'draft';
    try {
      await AppScope.read(context).api!.ads.save(c);
      if (!mounted) return;
      showInfo(context, publish ? t.adPublished : t.saved);
      widget.onSaved();
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  /// Clé de la section « Contenu » : on y descend après le choix du format.
  final _contentKey = GlobalKey();

  /// Choix du format : ouvre directement l'ajout des photos / vidéos quand le
  /// format en demande, puis amène l'écran sur la section « Contenu ».
  Future<void> _chooseFormat(String f) async {
    setState(() {
      c.format = f;
      if (f == 'video') c.media = c.media.where((m) => m.isVideo).toList();
    });
    await Future<void>.delayed(const Duration(milliseconds: 60));
    final ctx = _contentKey.currentContext;
    if (ctx != null && ctx.mounted) {
      await Scrollable.ensureVisible(ctx, duration: const Duration(milliseconds: 350), curve: Curves.easeOut, alignment: 0.05);
    }
    final needsFiles = f == 'video' ? !c.media.any((m) => m.isVideo) : (f == 'carousel' || f == 'story') && c.media.isEmpty;
    if (needsFiles && mounted) await _addMedia(fromLibrary: false);
  }

  Widget _formatGrid() {
    return LayoutBuilder(
      builder: (context, box) {
        final cols = box.maxWidth >= 640 ? 3 : 2;
        final w = (box.maxWidth - (cols - 1) * 12) / cols;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final f in adFormats)
              SizedBox(
                width: w,
                child: SoftCard(
                  onTap: () => _chooseFormat(f),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  color: c.format == f ? RestoColors.primarySoft : null,
                  child: Column(
                    children: [
                      Icon(adFormatIcon(f), size: 34, color: RestoColors.primaryDeep),
                      const SizedBox(height: 8),
                      Text(
                        adFormatLabel(context, f),
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        adFormatHint(context, f),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        style: const TextStyle(color: RestoColors.muted, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _mediaStrip() {
    final t = context.t;
    final api = AppScope.read(context).api!.ads;
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (final m in c.media)
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 96,
                  height: 96,
                  child: _MediaThumb(url: api.publicUrl(m.path), video: m.isVideo),
                ),
              ),
              Positioned(
                right: 4,
                top: 4,
                child: GestureDetector(
                  onTap: () => setState(() => c.media = [...c.media]..remove(m)),
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    child: const Icon(Icons.close_rounded, size: 16, color: RestoColors.ink),
                  ),
                ),
              ),
            ],
          ),
        if (_uploading > 0)
          SizedBox(
            width: 96,
            height: 96,
            child: DashedBox(
              padding: EdgeInsets.zero,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox.square(dimension: 26, child: CircularProgressIndicator(strokeWidth: 2.5)),
                    const SizedBox(height: 6),
                    Text(t.uploadingLabel, style: const TextStyle(color: RestoColors.primaryDeep, fontSize: 11.5)),
                  ],
                ),
              ),
            ),
          )
        else if (c.media.length < 10)
          SizedBox(
            width: 200,
            height: 96,
            child: DashedBox(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              onTap: () => _addMedia(fromLibrary: false),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      c.format == 'video' ? Icons.video_call_outlined : Icons.add_photo_alternate_outlined,
                      color: RestoColors.primaryDeep,
                      size: 28,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      c.format == 'video' ? t.adAddVideo : t.adsUpload,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: RestoColors.primaryDeep, fontSize: 12.5, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ),
          ),
        if (c.media.length < 10)
          TextButton.icon(
            onPressed: () => _addMedia(fromLibrary: true),
            icon: const Icon(Icons.photo_library_outlined, size: 18),
            label: Text(t.adsFromLibrary),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    final df = DateFormat.yMMMd(Localizations.localeOf(context).toString());
    final needsMedia = c.format != 'push' && c.format != 'classified' && c.format != 'sponsored_menu';
    final form = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(t.adsCreateTitle, style: serifTitle(context, size: 30)),
        Text(t.adsCreateHint, style: const TextStyle(color: RestoColors.muted)),
        const SizedBox(height: 14),
        _formatGrid(),
        const SizedBox(height: 20),
        SoftCard(
          key: _contentKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SectionHeading(title: t.adsContent, icon: adFormatIcon(c.format), subtitle: adFormatLabel(context, c.format)),
              const SizedBox(height: 14),
              TextField(
                controller: _title,
                maxLength: 120,
                decoration: InputDecoration(labelText: t.adTitle, hintText: t.adTitleHint),
              ),
              TextField(
                controller: _body,
                maxLength: c.format == 'push' ? 180 : 1000,
                maxLines: 4,
                minLines: 2,
                decoration: InputDecoration(labelText: t.adText, hintText: t.adTextHint),
              ),
              if (needsMedia || c.format == 'classified') ...[
                const SizedBox(height: 6),
                Text(c.format == 'video' ? t.adVideoHelp : t.adMediaHelp, style: const TextStyle(color: RestoColors.muted, fontSize: 12.5)),
                const SizedBox(height: 8),
                _mediaStrip(),
              ],
              if (c.format == 'sponsored_menu') ...[
                const SizedBox(height: 8),
                Text(t.adChooseItems, style: theme.textTheme.titleSmall),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final i in widget.data.items)
                      FilterChip(
                        label: Text(i.name),
                        selected: c.itemIds.contains(i.id),
                        onSelected: (on) => setState(() => c.itemIds = on ? [...c.itemIds, i.id] : ([...c.itemIds]..remove(i.id))),
                      ),
                  ],
                ),
              ],
              if (c.format != 'push') ...[
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _cta,
                        maxLength: 40,
                        decoration: InputDecoration(labelText: t.adCta, hintText: t.adCtaHint),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _url,
                        maxLength: 300,
                        keyboardType: TextInputType.url,
                        decoration: InputDecoration(labelText: t.adLink, hintText: 'https://'),
                      ),
                    ),
                  ],
                ),
              ],
              if (c.format == 'push')
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(t.adPushNote, style: const TextStyle(color: RestoColors.muted, fontSize: 12.5)),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SoftCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SectionHeading(title: t.adsBudgetTargeting, icon: Icons.track_changes_rounded),
              const SizedBox(height: 14),
              Wrap(
                spacing: 16,
                runSpacing: 12,
                crossAxisAlignment: WrapCrossAlignment.end,
                children: [
                  AmountField(
                    controller: _budget,
                    label: t.adDailyBudget,
                    currency: widget.scope.currency,
                    minorUnit: widget.scope.minorUnit,
                    width: 220,
                  ),
                  OutlinedButton.icon(
                    onPressed: () => _pickDate(start: true),
                    icon: const Icon(Icons.event_rounded, size: 18),
                    label: Text('${t.adStart} : ${df.format(c.startsAt)}'),
                  ),
                  if (c.format != 'story')
                    OutlinedButton.icon(
                      onPressed: () => _pickDate(start: false),
                      icon: const Icon(Icons.event_available_rounded, size: 18),
                      label: Text('${t.adEnd} : ${c.endsAt == null ? '—' : df.format(c.endsAt!)}'),
                    )
                  else
                    StatusPill(label: t.adStory24h, color: RestoColors.primaryDeep, icon: Icons.timelapse_rounded),
                ],
              ),
              const SizedBox(height: 6),
              Text(t.adBudgetNote, style: const TextStyle(color: RestoColors.muted, fontSize: 12)),
              const SizedBox(height: 16),
              Text(t.adTargetAreas, style: theme.textTheme.titleSmall),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final a in c.targetAreas)
                    GoldPill(
                      label: a,
                      selected: true,
                      dense: true,
                      onTap: () => setState(() => c.targetAreas = [...c.targetAreas]..remove(a)),
                    ),
                  for (final a in _areaSuggestions)
                    GoldPill(label: a, selected: false, dense: true, onTap: () => setState(() => c.targetAreas = [...c.targetAreas, a])),
                  SizedBox(
                    width: 200,
                    child: TextField(
                      controller: _area,
                      decoration: InputDecoration(isDense: true, hintText: t.adAddArea),
                      onSubmitted: (v) {
                        if (v.trim().isEmpty || c.targetAreas.contains(v.trim())) return;
                        setState(() {
                          c.targetAreas = [...c.targetAreas, v.trim()];
                          _area.clear();
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(t.adMoments, style: theme.textTheme.titleSmall),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final m in adMoments)
                    GoldPill(
                      label: _momentLabel(context, m),
                      selected: c.moments.contains(m),
                      dense: true,
                      onTap: () => setState(() => c.moments = c.moments.contains(m) ? ([...c.moments]..remove(m)) : [...c.moments, m]),
                    ),
                ],
              ),
              if (widget.data.branches.length > 1) ...[
                const SizedBox(height: 16),
                Text(t.adBranches, style: theme.textTheme.titleSmall),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final b in widget.data.branches)
                      FilterChip(
                        label: Text(b.name),
                        selected: c.branchIds.isEmpty || c.branchIds.contains(b.id),
                        onSelected: (on) => setState(() {
                          final all = widget.data.branches.map((x) => x.id!).toList();
                          final current = c.branchIds.isEmpty ? all : [...c.branchIds];
                          on ? current.add(b.id!) : current.remove(b.id);
                          c.branchIds = current.toSet().length == all.length ? [] : current.toSet().toList();
                        }),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: GoldButton(label: t.adSaveDraft, outlined: true, onPressed: () => _save(publish: false)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GoldButton(label: t.adPublish, icon: Icons.rocket_launch_rounded, onPressed: () => _save(publish: true)),
            ),
          ],
        ),
      ],
    );
    final side = MediaQuery.sizeOf(context).width < 600 ? 16.0 : 22.0;
    return ListView(
      padding: EdgeInsets.fromLTRB(side, 6, side, 40),
      children: [
        Center(
          child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 1100), child: form),
        ),
      ],
    );
  }
}

/// Vignette d'un média (image, ou vidéo représentée par un lecteur).
class _MediaThumb extends StatelessWidget {
  const _MediaThumb({required this.url, required this.video});
  final String url;
  final bool video;

  @override
  Widget build(BuildContext context) {
    if (video) {
      return Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [Color(0xFF3A2A12), Color(0xFF6B4E1E)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        ),
        child: Center(
          child: IconButton(
            onPressed: () => openLink(url),
            icon: const Icon(Icons.play_circle_fill_rounded, color: Colors.white, size: 40),
          ),
        ),
      );
    }
    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => Container(
        color: RestoColors.sunken,
        child: const Icon(Icons.broken_image_outlined, color: RestoColors.muted),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Mes campagnes

class _CampaignsTab extends StatelessWidget {
  const _CampaignsTab({required this.scope, required this.data, required this.onEdit, required this.onChanged});
  final BranchContext scope;
  final _AdsData data;
  final ValueChanged<AdCampaign> onEdit;
  final VoidCallback onChanged;

  /// Budget engagé à ce jour (budget journalier × jours écoulés).
  static int spentSoFar(AdCampaign c) {
    if (c.dailyBudgetMinor == null || c.status == 'draft') return 0;
    final end = c.endsAt != null && c.endsAt!.isBefore(DateTime.now()) ? c.endsAt! : DateTime.now();
    if (end.isBefore(c.startsAt)) return 0;
    final days = max(1, (end.difference(c.startsAt).inHours / 24).ceil());
    return c.dailyBudgetMinor! * days;
  }

  Future<void> _boost(BuildContext context, AdCampaign c) async {
    final t = context.t;
    final days = await showDialog<int>(
      context: context,
      builder: (d) => SimpleDialog(
        title: Text(t.adBoostTitle),
        children: [
          for (final n in [3, 7, 14, 30]) SimpleDialogOption(onPressed: () => Navigator.pop(d, n), child: Text(t.adBoostDays(n))),
        ],
      ),
    );
    if (days == null || !context.mounted) return;
    final base = c.endsAt == null || c.endsAt!.isBefore(DateTime.now()) ? DateTime.now() : c.endsAt!;
    c
      ..endsAt = base.add(Duration(days: days))
      ..status = 'active';
    if (c.format == 'story') c.startsAt = DateTime.now();
    try {
      await AppScope.read(context).api!.ads.save(c);
      if (context.mounted) showInfo(context, t.adBoosted);
      onChanged();
    } catch (e) {
      if (context.mounted) showError(context, e);
    }
  }

  Future<void> _action(BuildContext context, AdCampaign c, String a) async {
    final t = context.t;
    final api = AppScope.read(context).api!.ads;
    try {
      switch (a) {
        case 'pause':
          await api.setStatus(c.id!, 'paused');
        case 'resume':
          await api.setStatus(c.id!, 'active');
        case 'end':
          await api.setStatus(c.id!, 'ended');
        case 'delete':
          if (!await confirm(context, t.adDeleteConfirm)) return;
          await api.delete(c.id!);
      }
      onChanged();
    } catch (e) {
      if (context.mounted) showError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final locale = Localizations.localeOf(context).toString();
    String money(int v) => Money(v, scope.currency).format(locale, scope.minorUnit);
    final side = MediaQuery.sizeOf(context).width < 600 ? 16.0 : 22.0;
    if (data.campaigns.isEmpty) {
      return ListView(
        padding: EdgeInsets.fromLTRB(side, 10, side, 40),
        children: [EmptyState(icon: Icons.campaign_outlined, title: t.adsEmpty, message: t.adsEmptyHint)],
      );
    }
    final revenue = data.campaigns.fold<int>(0, (a, c) => a + c.revenueMinor);
    final spent = data.campaigns.fold<int>(0, (a, c) => a + spentSoFar(c));
    final roi = spent == 0 ? null : (revenue - spent) * 100 / spent;
    final api = AppScope.read(context).api!;
    final active = data.campaigns.where((c) => c.displayStatus == 'active').length;
    return ListView(
      padding: EdgeInsets.fromLTRB(side, 6, side, 40),
      children: [
        SoftCard(
          child: Row(
            children: [
              const GoldIcon(Icons.trending_up_rounded, size: 64, filled: true),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(t.adRoi, style: const TextStyle(color: RestoColors.muted)),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: AlignmentDirectional.centerStart,
                      child: Text(money(revenue), style: serifTitle(context, size: 34)),
                    ),
                    Text(t.adRoiDetail(money(spent)), style: const TextStyle(color: RestoColors.muted, fontSize: 13)),
                  ],
                ),
              ),
              if (roi != null) TrendChip(text: '${roi >= 0 ? '+' : ''}${roi.toStringAsFixed(0)} %', up: roi >= 0),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(child: Text(t.adsActiveCampaigns, style: serifTitle(context, size: 24))),
            Text(t.adsCampaignCount(active), style: const TextStyle(color: RestoColors.muted)),
          ],
        ),
        const SizedBox(height: 10),
        LayoutBuilder(
          builder: (context, box) {
            final cols = box.maxWidth >= 1100 ? 3 : (box.maxWidth >= 720 ? 2 : 1);
            final w = (box.maxWidth - (cols - 1) * 14) / cols;
            return Wrap(
              spacing: 14,
              runSpacing: 14,
              children: [
                for (final c in data.campaigns)
                  SizedBox(
                    width: w,
                    child: SoftCard(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: SizedBox(
                                  width: 84,
                                  height: 84,
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      if (c.media.isNotEmpty)
                                        _MediaThumb(url: api.ads.publicUrl(c.media.first.path), video: c.media.first.isVideo)
                                      else
                                        Container(
                                          decoration: const BoxDecoration(gradient: RestoColors.brandGradient),
                                          child: Icon(adFormatIcon(c.format), color: Colors.white, size: 34),
                                        ),
                                      Positioned(
                                        left: 4,
                                        top: 4,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withValues(alpha: 0.92),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(adFormatIcon(c.format), size: 11, color: RestoColors.primaryDeep),
                                              const SizedBox(width: 3),
                                              Text(
                                                adFormatLabel(context, c.format).split(' ').first,
                                                style: const TextStyle(
                                                  fontSize: 10,
                                                  color: RestoColors.primaryDeep,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            c.title,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                                          ),
                                        ),
                                        StatusPill(
                                          label: _statusInfo(context, c.displayStatus).$1,
                                          color: _statusInfo(context, c.displayStatus).$2,
                                          dense: true,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Wrap(
                                      spacing: 10,
                                      runSpacing: 4,
                                      children: [
                                        _Stat(icon: Icons.visibility_outlined, text: t.adViews(c.views)),
                                        if (c.likes > 0) _Stat(icon: Icons.favorite_border_rounded, text: '${c.likes}'),
                                        if (c.comments > 0) _Stat(icon: Icons.mode_comment_outlined, text: '${c.comments}'),
                                        _Stat(icon: Icons.shopping_bag_outlined, text: t.adOrders(c.orders)),
                                        if (c.views > 0) _Stat(icon: Icons.ads_click_rounded, text: '${c.clickRate.toStringAsFixed(1)} %'),
                                      ],
                                    ),
                                    if (c.progress != null) ...[
                                      const SizedBox(height: 8),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(6),
                                        child: LinearProgressIndicator(
                                          value: c.progress,
                                          minHeight: 7,
                                          color: RestoColors.primary,
                                          backgroundColor: RestoColors.primarySoft,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: GoldButton(
                                  label: t.adDetails,
                                  icon: Icons.tune_rounded,
                                  outlined: true,
                                  onPressed: () async => onEdit(c),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: GoldButton(label: t.adBoost, icon: Icons.bolt_rounded, onPressed: () => _boost(context, c)),
                              ),
                              PopupMenuButton<String>(
                                onSelected: (a) => _action(context, c, a),
                                itemBuilder: (_) => [
                                  if (c.status == 'active') PopupMenuItem(value: 'pause', child: Text(t.adPause)),
                                  if (c.status == 'paused' || c.status == 'draft') PopupMenuItem(value: 'resume', child: Text(t.adResume)),
                                  if (c.status != 'ended') PopupMenuItem(value: 'end', child: Text(t.adEndNow)),
                                  PopupMenuItem(value: 'delete', child: Text(t.delete)),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 15, color: RestoColors.primaryDeep),
      const SizedBox(width: 4),
      Text(text, style: const TextStyle(fontSize: 12.5, color: RestoColors.ink)),
    ],
  );
}

// ---------------------------------------------------------------------------
// Bibliothèque (médiathèque)

class _LibraryTab extends StatefulWidget {
  const _LibraryTab({required this.scope});
  final BranchContext scope;

  @override
  State<_LibraryTab> createState() => _LibraryTabState();
}

class _LibraryTabState extends State<_LibraryTab> {
  late Future<List<LibraryFile>> _files = _load();
  bool _uploading = false;

  Future<List<LibraryFile>> _load() => AppScope.read(context).api!.ads.library(widget.scope.orgId);

  Future<void> _upload() async {
    final t = context.t;
    final api = AppScope.read(context).api!.ads;
    final files = await pickMedia();
    if (files.isEmpty || !mounted) return;
    setState(() => _uploading = true);
    try {
      for (final picked in files) {
        final video = isVideoName(picked.name);
        final f = video ? picked : await compressPhoto(picked);
        if (f.bytes.length > (video ? maxVideoBytes : maxPhotoBytes)) {
          if (mounted) showInfo(context, video ? t.adVideoTooBig(picked.name) : t.fileTooBig(picked.name));
          continue;
        }
        await api.upload(widget.scope.orgId, f.bytes, f.extension);
      }
    } catch (e) {
      if (mounted) showError(context, e);
    }
    if (mounted) {
      setState(() {
        _uploading = false;
        _files = _load();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final api = AppScope.read(context).api!.ads;
    final side = MediaQuery.sizeOf(context).width < 600 ? 16.0 : 22.0;
    final canEdit = widget.scope.membership.canOrg('marketing.manage');
    return FutureBuilder<List<LibraryFile>>(
      future: _files,
      builder: (context, snap) {
        final files = snap.data ?? const [];
        return ListView(
          padding: EdgeInsets.fromLTRB(side, 6, side, 40),
          children: [
            if (canEdit)
              DashedBox(
                onTap: _uploading ? null : _upload,
                child: Row(
                  children: [
                    const GoldIcon(Icons.cloud_upload_outlined, size: 48),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t.adsUpload,
                            style: const TextStyle(color: RestoColors.primaryDeep, fontWeight: FontWeight.w700, fontSize: 16),
                          ),
                          Text(t.adsUploadHint, style: const TextStyle(color: RestoColors.muted, fontSize: 12.5)),
                        ],
                      ),
                    ),
                    if (_uploading) const SizedBox.square(dimension: 24, child: CircularProgressIndicator(strokeWidth: 2)),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            if (snap.connectionState != ConnectionState.done)
              const Center(
                child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()),
              )
            else if (files.isEmpty)
              EmptyState(icon: Icons.photo_library_outlined, title: t.adsLibraryEmpty)
            else
              LayoutBuilder(
                builder: (context, box) {
                  final cols = max(2, (box.maxWidth / 180).floor());
                  final w = (box.maxWidth - (cols - 1) * 12) / cols;
                  return Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      for (final f in files)
                        SizedBox(
                          width: w,
                          height: w,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                _MediaThumb(url: api.publicUrl(f.path), video: f.isVideo),
                                if (canEdit)
                                  Positioned(
                                    right: 6,
                                    top: 6,
                                    child: Material(
                                      color: Colors.white,
                                      shape: const CircleBorder(),
                                      child: IconButton(
                                        tooltip: t.delete,
                                        icon: const Icon(Icons.delete_outline_rounded, size: 18),
                                        onPressed: () async {
                                          if (!await confirm(context, t.adsDeleteFile)) return;
                                          try {
                                            await api.removeFile(f.path);
                                            if (mounted) setState(() => _files = _load());
                                          } catch (e) {
                                            if (context.mounted) showError(context, e);
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
          ],
        );
      },
    );
  }
}

/// Choix de médias dans la bibliothèque.
class _LibraryPicker extends StatefulWidget {
  const _LibraryPicker({required this.orgId, required this.videos, required this.images});
  final String orgId;
  final bool videos;
  final bool images;

  @override
  State<_LibraryPicker> createState() => _LibraryPickerState();
}

class _LibraryPickerState extends State<_LibraryPicker> {
  final Set<String> _chosen = {};
  late final Future<List<LibraryFile>> _files = AppScope.read(context).api!.ads.library(widget.orgId);

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final api = AppScope.read(context).api!.ads;
    return AlertDialog(
      title: Text(t.adsLibrary),
      content: SizedBox(
        width: 640,
        height: 440,
        child: FutureBuilder<List<LibraryFile>>(
          future: _files,
          builder: (context, snap) {
            if (!snap.hasData) return const Center(child: CircularProgressIndicator());
            final files = snap.data!.where((f) => f.isVideo ? widget.videos : widget.images).toList();
            if (files.isEmpty) return Center(child: Text(t.adsLibraryEmpty));
            return GridView.count(
              crossAxisCount: 4,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              children: [
                for (final f in files)
                  GestureDetector(
                    onTap: () => setState(() => _chosen.contains(f.path) ? _chosen.remove(f.path) : _chosen.add(f.path)),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          _MediaThumb(url: api.publicUrl(f.path), video: f.isVideo),
                          if (_chosen.contains(f.path))
                            Container(
                              color: RestoColors.primary.withValues(alpha: 0.35),
                              child: const Icon(Icons.check_circle_rounded, color: Colors.white, size: 36),
                            ),
                        ],
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(t.cancel)),
        FilledButton(
          onPressed: _chosen.isEmpty
              ? null
              : () => Navigator.pop(context, [for (final p in _chosen) AdMedia(p, isVideoName(p) ? 'video' : 'image')]),
          child: Text(t.add),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Statistiques

class _StatsTab extends StatelessWidget {
  const _StatsTab({required this.scope, required this.data});
  final BranchContext scope;
  final _AdsData data;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final locale = Localizations.localeOf(context).toString();
    String money(int v) => Money(v, scope.currency).format(locale, scope.minorUnit);
    final list = data.campaigns.where((c) => c.status != 'draft').toList();
    final views = list.fold<int>(0, (a, c) => a + c.views);
    final clicks = list.fold<int>(0, (a, c) => a + c.clicks);
    final orders = list.fold<int>(0, (a, c) => a + c.orders);
    final revenue = list.fold<int>(0, (a, c) => a + c.revenueMinor);
    final side = MediaQuery.sizeOf(context).width < 600 ? 16.0 : 22.0;
    final kpis = [
      KpiCard(icon: Icons.visibility_outlined, label: t.adStatViews, value: '$views'),
      KpiCard(
        icon: Icons.ads_click_rounded,
        label: t.adStatClickRate,
        value: views == 0 ? '—' : '${(clicks * 100 / views).toStringAsFixed(1)} %',
      ),
      KpiCard(icon: Icons.shopping_bag_outlined, label: t.adStatOrders, value: '$orders'),
      KpiCard(icon: Icons.payments_outlined, label: t.adStatRevenue, value: money(revenue)),
    ];
    final reach = list.fold<int>(0, (a, c) => a + c.reach);
    final engagements = list.fold<int>(0, (a, c) => a + c.engagements);
    final social = [
      KpiCard(icon: Icons.groups_2_outlined, label: t.adStatReach, value: '$reach'),
      KpiCard(
        icon: Icons.bolt_rounded,
        label: t.adStatEngagement,
        value: reach == 0 ? '—' : '${(engagements * 100 / reach).toStringAsFixed(1)} %',
      ),
      KpiCard(icon: Icons.favorite_border_rounded, label: t.adStatLikes, value: '${list.fold<int>(0, (a, c) => a + c.likes)}'),
      KpiCard(icon: Icons.mode_comment_outlined, label: t.commentsTitle, value: '${list.fold<int>(0, (a, c) => a + c.comments)}'),
      KpiCard(icon: Icons.bookmark_border_rounded, label: t.adStatSaves, value: '${list.fold<int>(0, (a, c) => a + c.saves)}'),
      KpiCard(icon: Icons.reply_rounded, label: t.adStatShares, value: '${list.fold<int>(0, (a, c) => a + c.shares)}'),
    ];
    final top = [...list]..sort((a, b) => b.views.compareTo(a.views));
    final shown = top.take(8).toList();
    final maxViews = shown.fold<int>(1, (a, c) => max(a, c.views));
    return ListView(
      padding: EdgeInsets.fromLTRB(side, 6, side, 40),
      children: [
        LayoutBuilder(
          builder: (context, box) {
            final cols = box.maxWidth >= 1000 ? 4 : 2;
            final w = (box.maxWidth - (cols - 1) * 14) / cols;
            return Wrap(
              spacing: 14,
              runSpacing: 14,
              children: [for (final k in kpis) SizedBox(width: w, child: k)],
            );
          },
        ),
        const SizedBox(height: 14),
        LayoutBuilder(
          builder: (context, box) {
            final cols = box.maxWidth >= 1000 ? 6 : (box.maxWidth >= 600 ? 3 : 2);
            final w = (box.maxWidth - (cols - 1) * 14) / cols;
            return Wrap(
              spacing: 14,
              runSpacing: 14,
              children: [for (final k in social) SizedBox(width: w, child: k)],
            );
          },
        ),
        const SizedBox(height: 18),
        SoftCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SectionHeading(title: t.adStatByCampaign, icon: Icons.bar_chart_rounded),
              const SizedBox(height: 16),
              if (shown.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Center(child: Text(t.adsEmpty)),
                )
              else
                SizedBox(
                  height: 260,
                  child: BarChart(
                    BarChartData(
                      maxY: maxViews * 1.15,
                      gridData: FlGridData(
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (_) => const FlLine(color: RestoColors.line, strokeWidth: 1),
                      ),
                      borderData: FlBorderData(show: false),
                      titlesData: FlTitlesData(
                        topTitles: const AxisTitles(),
                        rightTitles: const AxisTitles(),
                        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 34,
                            getTitlesWidget: (v, _) {
                              final i = v.toInt();
                              if (i < 0 || i >= shown.length) return const SizedBox.shrink();
                              final title = shown[i].title;
                              return Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(
                                  title.length > 12 ? '${title.substring(0, 11)}…' : title,
                                  style: const TextStyle(fontSize: 10.5, color: RestoColors.muted),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      barTouchData: BarTouchData(
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipItem: (g, _, r, _) => BarTooltipItem(
                            '${shown[g.x].title}\n${t.adViews(shown[g.x].views)} · ${t.adOrders(shown[g.x].orders)}',
                            const TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),
                      ),
                      barGroups: [
                        for (var i = 0; i < shown.length; i++)
                          BarChartGroupData(
                            x: i,
                            barRods: [
                              BarChartRodData(
                                toY: shown[i].views.toDouble(),
                                width: 22,
                                gradient: const LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [RestoColors.primaryDeep, RestoColors.primaryBright],
                                ),
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        SoftCard(
          padding: const EdgeInsets.fromLTRB(4, 12, 4, 8),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingTextStyle: const TextStyle(color: RestoColors.muted, fontWeight: FontWeight.w600, fontSize: 12.5),
              columns: [
                DataColumn(label: Text(t.adTitle)),
                DataColumn(label: Text(t.adFormat)),
                DataColumn(label: Text(t.adStatViews), numeric: true),
                DataColumn(label: Text(t.adStatReach), numeric: true),
                DataColumn(label: Text(t.adStatLikes), numeric: true),
                DataColumn(label: Text(t.commentsTitle), numeric: true),
                DataColumn(label: Text(t.adStatSaves), numeric: true),
                DataColumn(label: Text(t.adStatShares), numeric: true),
                DataColumn(label: Text(t.adStatClicks), numeric: true),
                DataColumn(label: Text(t.adStatOrders), numeric: true),
                DataColumn(label: Text(t.adStatRevenue), numeric: true),
              ],
              rows: [
                for (final c in top)
                  DataRow(
                    cells: [
                      DataCell(Text(c.title)),
                      DataCell(Text(adFormatLabel(context, c.format))),
                      DataCell(Text('${c.views}')),
                      DataCell(Text('${c.reach}')),
                      DataCell(Text('${c.likes}')),
                      DataCell(Text('${c.comments}')),
                      DataCell(Text('${c.saves}')),
                      DataCell(Text('${c.shares}')),
                      DataCell(Text('${c.clicks}')),
                      DataCell(Text('${c.orders}')),
                      DataCell(Text(money(c.revenueMinor))),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Commentaires des clients (modération)

class _CommentsTab extends StatefulWidget {
  const _CommentsTab({required this.scope, required this.data});
  final BranchContext scope;
  final _AdsData data;

  @override
  State<_CommentsTab> createState() => _CommentsTabState();
}

class _CommentsTabState extends State<_CommentsTab> {
  late Future<List<AdComment>> _list = _load();
  String _filter = 'all';

  Future<List<AdComment>> _load() => AppScope.read(context).api!.ads.comments(widget.scope.orgId);

  Future<void> _moderate(AdComment c) async {
    final t = context.t;
    final api = AppScope.read(context).api!.ads;
    try {
      if (c.hidden) {
        await api.moderateComment(c.id, false);
      } else {
        final reason = TextEditingController();
        final ok = await showDialog<bool>(
          context: context,
          builder: (d) => AlertDialog(
            title: Text(t.hideComment),
            content: TextField(
              controller: reason,
              autofocus: true,
              maxLength: 300,
              decoration: InputDecoration(labelText: t.hideReviewReason, hintText: t.moderationReasonExample),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(d, false), child: Text(t.cancel)),
              FilledButton(onPressed: () => Navigator.pop(d, true), child: Text(t.hideComment)),
            ],
          ),
        );
        if (ok != true) return;
        await api.moderateComment(c.id, true, reason.text.trim());
      }
      if (mounted) setState(() => _list = _load());
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final locale = Localizations.localeOf(context).toString();
    final side = MediaQuery.sizeOf(context).width < 600 ? 16.0 : 22.0;
    final titles = {for (final c in widget.data.campaigns) c.id: c.title};
    return FutureBuilder(
      future: _list,
      builder: (context, snap) {
        if (snap.hasError) {
          return Center(
            child: TextButton(onPressed: () => setState(() => _list = _load()), child: Text(t.retry)),
          );
        }
        if (!snap.hasData) return const Center(child: CircularProgressIndicator());
        final all = snap.data!;
        final shown = [
          for (final c in all)
            if (_filter == 'all' || (_filter == 'hidden') == c.hidden) c,
        ];
        return ListView(
          padding: EdgeInsets.fromLTRB(side, 6, side, 40),
          children: [
            Wrap(
              spacing: 14,
              runSpacing: 14,
              children: [
                SizedBox(
                  width: 220,
                  child: CounterTile(icon: Icons.mode_comment_outlined, label: t.commentsTitle, value: '${all.length}'),
                ),
                SizedBox(
                  width: 220,
                  child: CounterTile(
                    icon: Icons.visibility_off_outlined,
                    label: t.hiddenComments,
                    value: '${all.where((c) => c.hidden).length}',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            PillBar<String>(
              items: [PillItem('all', t.allFilter), PillItem('published', t.publishedComments), PillItem('hidden', t.hiddenComments)],
              selected: _filter,
              onSelected: (v) => setState(() => _filter = v),
            ),
            const SizedBox(height: 12),
            if (shown.isEmpty) EmptyState(icon: Icons.mode_comment_outlined, title: t.noCommentsYet, message: t.adCommentsHint),
            for (final c in shown)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: SoftCard(
                  padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: RestoColors.primarySoft,
                        child: Text(
                          c.author.characters.first.toUpperCase(),
                          style: const TextStyle(color: RestoColors.primaryDeep, fontWeight: FontWeight.w700),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              spacing: 8,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Text(c.author, style: const TextStyle(fontWeight: FontWeight.w700)),
                                Text(
                                  DateFormat.yMMMd(locale).add_Hm().format(c.createdAt.toLocal()),
                                  style: const TextStyle(color: RestoColors.muted, fontSize: 12),
                                ),
                                if (c.hidden) StatusPill(label: t.hiddenBadge, color: StatusColors.toValidate, dense: true),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(titles[c.campaignId] ?? '', style: const TextStyle(color: RestoColors.primaryDeep, fontSize: 12.5)),
                            const SizedBox(height: 6),
                            Text(c.body, style: TextStyle(color: c.hidden ? RestoColors.muted : RestoColors.ink)),
                            if (c.hidden && c.hiddenReason != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                t.hiddenBecause(c.hiddenReason!),
                                style: const TextStyle(color: RestoColors.muted, fontSize: 12, fontStyle: FontStyle.italic),
                              ),
                            ],
                          ],
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () => _moderate(c),
                        icon: Icon(c.hidden ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 18),
                        label: Text(c.hidden ? t.republishReview : t.hideComment),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
