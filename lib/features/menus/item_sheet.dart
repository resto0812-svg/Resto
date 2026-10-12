import 'package:flutter/material.dart';

import '../../app_state.dart';
import '../../core/money.dart';
import '../../data/menu_models.dart';
import '../../ui/common.dart';
import '../../ui/files.dart';
import '../../ui/image_compress.dart';
import '../../ui/kit.dart';
import '../../ui/theme.dart';
import 'menu_widgets.dart';
import 'menus_screen.dart';
import 'options_screen.dart';

/// Une taille / un format de l'article en cours de saisie, avec ses prix
/// pour l'établissement affiché (prix de base + prix éventuels par service).
class _SizeDraft {
  _SizeDraft({this.id, String name = '', Map<String, String> prices = const {}})
      : name = TextEditingController(text: name),
        prices = {for (final c in priceChannels) c: TextEditingController(text: prices[c] ?? '')},
        showChannels = priceChannels.skip(1).any((c) => (prices[c] ?? '').isNotEmpty);

  String? id;
  final TextEditingController name;
  final Map<String, TextEditingController> prices;
  bool active = true;
  bool showChannels;

  void dispose() {
    name.dispose();
    for (final c in prices.values) {
      c.dispose();
    }
  }
}

/// Photo de l'article : déjà en ligne (chemin) ou choisie, pas encore envoyée.
class _Photo {
  _Photo.saved(this.path) : picked = null;
  _Photo.picked(this.picked) : path = null;
  final String? path;
  final PickedDocument? picked;
}

const _maxPhotos = 5;

/// Fiche article : informations, photos et vidéo, prix et tailles, vente,
/// stock, options, allergènes, jours de vente ; aperçu côté client en direct.
/// Tout s'enregistre en une fois (« Publier »).
class ItemSheet extends StatefulWidget {
  const ItemSheet({super.key, required this.board, this.item, this.categoryId});
  final MenuBoardContext board;
  final MenuItem? item;
  final String? categoryId;

  @override
  State<ItemSheet> createState() => _ItemSheetState();
}

class _ItemSheetState extends State<ItemSheet> {
  final _form = GlobalKey<FormState>();
  late final MenuBoardContext b = widget.board;
  late final MenuItem? item = widget.item;
  late List<ModifierGroup> _groups = b.menu.groups;

  late final _name = TextEditingController(text: item?.name);
  late final _description = TextEditingController(text: item?.description);
  late String _kind = item?.kind ?? 'food';
  late String? _categoryId = item?.categoryId ?? widget.categoryId ?? (b.menu.categories.isEmpty ? null : b.menu.categories.first.id);
  late bool _visible = item?.active ?? true;
  late final Set<String> _groupIds = {...?item?.groupIds};
  late final Set<String> _allergens = {...?item?.allergens};

  late final List<_SizeDraft> _sizes = _initialSizes();
  late bool _multi = _sizes.length > 1 || (_sizes.length == 1 && _sizes.first.name.text.isNotEmpty);

  // Médias
  late final List<_Photo> _photos = [for (final p in item?.photos ?? const <String>[]) _Photo.saved(p)];
  late String? _video = item?.videoPath;
  PickedDocument? _newVideo;
  final List<String> _removed = [];

  // Service
  late final _prep = TextEditingController(text: item?.prepMinutes?.toString() ?? '');
  late final Set<int> _days = {...(item?.availableDays ?? const [1, 2, 3, 4, 5, 6, 7])};
  late final List<String> _tags = [...?item?.tags];
  final _tagInput = TextEditingController();

  /// Étiquettes des autres plats de la carte (proposées d'un toucher).
  List<String> get _tagSuggestions {
    final seen = <String>{for (final x in _tags) x.toLowerCase()};
    final out = <String>[];
    for (final i in b.menu.items) {
      for (final tag in i.tags) {
        if (seen.add(tag.toLowerCase())) out.add(tag);
      }
    }
    return out.take(16).toList();
  }
  late final _stock = TextEditingController(text: item == null ? '' : (b.state.stock[item!.id]?.$1.toString() ?? ''));

  // Établissement affiché (modification) ou établissements choisis (création).
  late bool _soldHere = item == null || b.state.offered.containsKey(item!.id);
  late bool _soldOut = item != null && b.state.offered[item!.id] == false;
  late final Set<String> _soldIn = {for (final br in b.manageableBranches) br.id!};
  String? _categoryError;

  List<_SizeDraft> _initialSizes() {
    final variants = item?.variants.where((v) => v.active).toList() ?? const <ItemVariant>[];
    if (variants.isEmpty) return [_SizeDraft()];
    return [
      for (final v in variants)
        _SizeDraft(id: v.id, name: v.name, prices: {
          for (final c in priceChannels) c: amountText(b.state.prices[(v.id, c)], b.currency, b.minorUnit),
        }),
    ];
  }

  @override
  void initState() {
    super.initState();
    for (final c in [_name, _description]) {
      c.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    for (final c in [_name, _description, _prep, _stock, _tagInput]) {
      c.dispose();
    }
    for (final s in _sizes) {
      s.dispose();
    }
    super.dispose();
  }

  Future<void> _manageOptions() async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => OptionsScreen(board: b)));
    if (!mounted) return;
    try {
      final menu = await AppScope.read(context).api!.menu.load(b.brand.id);
      if (mounted) setState(() => _groups = menu.groups);
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  Future<void> _translate() async {
    final changes = await editTranslations(context, title: item!.name, current: item!.translations, withDescription: true);
    if (changes == null || changes.isEmpty || !mounted) return;
    final api = AppScope.read(context).api!.menu;
    try {
      for (final e in changes.entries) {
        await api.saveTranslation(
          table: 'menu_item_translations',
          keyColumn: 'item_id',
          orgId: b.orgId,
          entityId: item!.id,
          locale: e.key,
          name: e.value.$1,
          description: e.value.$2,
          withDescription: true,
        );
      }
      if (mounted) showInfo(context, context.t.saved);
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  Future<void> _addPhotos() async {
    final t = context.t;
    final picked = await pickMedia(videos: false, multiple: true);
    if (picked.isEmpty || !mounted) return;
    // Photos de téléphone réduites automatiquement sous la limite.
    final files = [for (final f in picked) await compressPhoto(f)];
    if (!mounted) return;
    setState(() {
      for (final f in files) {
        if (_photos.length >= _maxPhotos) break;
        if (f.bytes.length > maxPhotoBytes) {
          showInfo(context, t.fileTooBig(f.name));
          continue;
        }
        _photos.add(_Photo.picked(f));
      }
    });
  }

  Future<void> _pickVideo() async {
    final t = context.t;
    final files = await pickMedia(images: false, multiple: false);
    if (files.isEmpty || !mounted) return;
    if (files.first.bytes.length > 30 * 1024 * 1024) {
      showInfo(context, t.fileTooBig(files.first.name));
      return;
    }
    setState(() {
      if (_video != null) _removed.add(_video!);
      _video = null;
      _newVideo = files.first;
    });
  }

  void _removePhoto(_Photo p) => setState(() {
        _photos.remove(p);
        if (p.path != null) _removed.add(p.path!);
      });

  void _makeMain(_Photo p) => setState(() {
        _photos
          ..remove(p)
          ..insert(0, p);
      });

  Future<void> _save() async {
    final t = context.t;
    setState(() => _categoryError = _categoryId == null ? t.fieldRequired : null);
    if (!_form.currentState!.validate() || _categoryId == null) return;
    if (_multi && _sizes.where((s) => s.active).any((s) => s.name.text.trim().isEmpty)) {
      showInfo(context, t.sizeNameRequired);
      return;
    }
    final prep = _prep.text.trim().isEmpty ? null : int.tryParse(_prep.text.trim());
    if (_prep.text.trim().isNotEmpty && (prep == null || prep < 1 || prep > 240)) {
      showInfo(context, t.errorBetween(1, 240));
      return;
    }
    if (_days.isEmpty) {
      showInfo(context, t.saleDaysRequired);
      return;
    }
    final api = AppScope.read(context).api!.menu;
    final isNew = item == null;
    try {
      var itemId = item?.id;

      // 1. Catalogue (droit sur toute l'organisation)
      if (b.canCatalog) {
        if (isNew) {
          itemId = await api.createItem(_categoryId!, _name.text, _description.text, _kind);
          // La variante unique créée par le serveur devient la première taille.
          _sizes.first.id = (await api.variantsOf(itemId)).first.$1;
          if (!_visible) await api.setItemActive(itemId, false);
        } else {
          await api.updateItem(itemId!,
              categoryId: _categoryId!, name: _name.text, description: _description.text, kind: _kind, active: _visible);
        }
        await _saveSizes(itemId);
        await api.setItemGroups(
            orgId: b.orgId, brandId: b.brand.id, itemId: itemId, current: {...?item?.groupIds}, wanted: _groupIds);
        await api.setAllergens(orgId: b.orgId, itemId: itemId, current: {...?item?.allergens}, wanted: _allergens);

        // Photos (la première est la principale), vidéo, préparation, jours de vente.
        final paths = <String>[];
        for (final p in _photos) {
          paths.add(p.path ?? await api.uploadItemImage(b.orgId, itemId, p.picked!.bytes, p.picked!.extension));
        }
        var video = _video;
        if (_newVideo != null) video = await api.uploadItemVideo(b.orgId, itemId, _newVideo!.bytes, _newVideo!.extension);
        await api.setItemMedia(itemId,
            imagePath: paths.firstOrNull, gallery: paths.skip(1).toList(), videoPath: video, removed: _removed);
        await api.setItemService(itemId,
            prepMinutes: prep, availableDays: _days.toList()..sort(), tags: _tags);
      }

      // 2. Établissements où l'article est vendu, puis prix
      final targets = <String>[];
      if (isNew) {
        for (final branchId in _soldIn) {
          await api.setOffered(orgId: b.orgId, brandId: b.brand.id, itemId: itemId!, branchId: branchId, offered: true);
          targets.add(branchId);
        }
      } else if (b.canBranch) {
        final wasSold = b.state.offered.containsKey(itemId);
        if (_soldHere != wasSold) {
          await api.setOffered(
              orgId: b.orgId, brandId: b.brand.id, itemId: itemId!, branchId: b.branch.id!, offered: _soldHere);
        }
        if (_soldHere && wasSold && _soldOut != (b.state.offered[itemId] == false)) {
          await api.setAvailable(itemId!, b.branch.id!, !_soldOut);
        }
        if (_soldHere) targets.add(b.branch.id!);
      }
      for (final branchId in targets) {
        for (final s in _sizes.where((s) => s.active && s.id != null)) {
          for (final c in priceChannels) {
            if (c != 'default' && !s.showChannels && !(b.state.prices.containsKey((s.id!, c)))) continue;
            final amount = parseAmount(s.prices[c]!.text, b.currency, b.minorUnit);
            final before = branchId == b.branch.id ? b.state.prices[(s.id!, c)] : null;
            if (amount == before) continue;
            await api.setPrice(branchId: branchId, variantId: s.id, channel: c, amountMinor: amount);
          }
        }
      }

      // 3. Stock du jour dans l'établissement affiché
      if (targets.contains(b.branch.id)) {
        final qty = int.tryParse(_stock.text.trim());
        final before = isNew ? null : b.state.stock[itemId]?.$1;
        if (qty != before) await api.setStock(itemId!, b.branch.id!, qty);
      }
      if (!mounted) return;
      showInfo(context, t.saved);
      Navigator.pop(context, true);
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  /// Tailles : une seule (sans nom) ou plusieurs (nommées). Une taille
  /// retirée est désactivée, jamais supprimée (les commandes y font référence).
  Future<void> _saveSizes(String itemId) async {
    final api = AppScope.read(context).api!.menu;
    final existing = item?.variants ?? const <ItemVariant>[];
    if (!_multi) {
      final single = _sizes.first;
      if (single.id == null) {
        single.id = uuidV4();
        await api.saveVariant(orgId: b.orgId, brandId: b.brand.id, itemId: itemId, newId: single.id, name: '');
      } else if (existing.any((v) => v.id == single.id && (v.name.isNotEmpty || !v.active))) {
        await api.saveVariant(orgId: b.orgId, brandId: b.brand.id, itemId: itemId, id: single.id, name: '');
      }
      for (final v in existing.where((v) => v.active && v.id != single.id)) {
        await api.saveVariant(orgId: b.orgId, brandId: b.brand.id, itemId: itemId, id: v.id, name: v.name, active: false);
      }
      return;
    }
    for (final s in _sizes) {
      final before = existing.where((v) => v.id == s.id).firstOrNull;
      if (s.id != null && (before != null || item == null)) {
        if (before == null || before.name != s.name.text.trim() || before.active != s.active) {
          await api.saveVariant(
              orgId: b.orgId, brandId: b.brand.id, itemId: itemId, id: s.id, name: s.name.text, active: s.active);
        }
      } else if (s.active) {
        s.id = uuidV4();
        await api.saveVariant(orgId: b.orgId, brandId: b.brand.id, itemId: itemId, newId: s.id, name: s.name.text);
      }
    }
  }

  Widget _card(String title, IconData icon, List<Widget> children, {Widget? action}) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: SoftCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            SectionHeading(title: title, icon: icon, trailing: action),
            const SizedBox(height: 14),
            ...children,
          ]),
        ),
      );

  Widget _sizeRow(_SizeDraft s, bool canPrice) {
    final t = context.t;
    final canCatalog = b.canCatalog;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Wrap(spacing: 12, runSpacing: 8, crossAxisAlignment: WrapCrossAlignment.center, children: [
          if (_multi)
            SizedBox(
              width: 200,
              child: TextField(
                controller: s.name,
                enabled: canCatalog,
                maxLength: 80,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(isDense: true, counterText: '', labelText: t.sizeName, hintText: t.sizeExamples),
              ),
            ),
          AmountField(
            controller: s.prices['default']!,
            label: t.price,
            currency: b.currency,
            minorUnit: b.minorUnit,
            enabled: canPrice,
          ),
          if (_multi && canCatalog && _sizes.where((x) => x.active).length > 1)
            IconButton(
              tooltip: t.removeSize,
              icon: const Icon(Icons.remove_circle_outline),
              onPressed: () => setState(() => s.active = false),
            ),
        ]),
        if (canPrice && !s.showChannels)
          TextButton(onPressed: () => setState(() => s.showChannels = true), child: Text(t.otherChannels)),
        if (s.showChannels)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Wrap(spacing: 12, runSpacing: 8, children: [
              for (final c in priceChannels.skip(1))
                AmountField(
                  controller: s.prices[c]!,
                  label: channelLabel(t, c),
                  currency: b.currency,
                  minorUnit: b.minorUnit,
                  enabled: canPrice,
                ),
            ]),
          ),
      ]),
    );
  }

  Widget _photoTile(_Photo p, int index) {
    final t = context.t;
    final menu = AppScope.read(context).api!.menu;
    final image = p.path != null
        ? Image.network(menu.imageUrl(p.path!), fit: BoxFit.cover)
        : Image.memory(p.picked!.bytes, fit: BoxFit.cover);
    return SizedBox(
      width: 108,
      height: 108,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Stack(fit: StackFit.expand, children: [
          image,
          if (index == 0)
            Positioned(left: 6, bottom: 6, child: HeaderBadge(text: t.mainPhoto, icon: Icons.star_rounded))
          else if (b.canCatalog)
            Positioned(
              left: 4,
              bottom: 4,
              child: Material(
                color: Colors.white,
                shape: const CircleBorder(),
                child: IconButton(
                  tooltip: t.makeMainPhoto,
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.star_outline_rounded, size: 18, color: RestoColors.primaryDeep),
                  onPressed: () => _makeMain(p),
                ),
              ),
            ),
          if (b.canCatalog)
            Positioned(
              right: 4,
              top: 4,
              child: GestureDetector(
                onTap: () => _removePhoto(p),
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: const Icon(Icons.close_rounded, size: 16, color: RestoColors.ink),
                ),
              ),
            ),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final canCatalog = b.canCatalog;
    final isNew = item == null;
    final canPrice = isNew ? _soldIn.isNotEmpty : (b.canBranch && _soldHere);
    final activeSizes = _sizes.where((s) => s.active).toList();
    final wide = MediaQuery.sizeOf(context).width >= 1150;

    final form = Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      // ------------------------------------------------ photos & vidéo
      _card(t.productPhotos, Icons.photo_camera_outlined, [
        if (canCatalog && _photos.length < _maxPhotos)
          DashedBox(
            onTap: _addPhotos,
            child: Column(children: [
              const Icon(Icons.cloud_upload_outlined, color: RestoColors.primaryDeep, size: 30),
              const SizedBox(height: 4),
              Text(t.addPhotos, style: const TextStyle(color: RestoColors.primaryDeep, fontWeight: FontWeight.w700)),
              Text(t.photosHint(_maxPhotos), style: const TextStyle(color: RestoColors.muted, fontSize: 12)),
            ]),
          ),
        if (_photos.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(spacing: 10, runSpacing: 10, children: [for (var i = 0; i < _photos.length; i++) _photoTile(_photos[i], i)]),
        ],
        const SizedBox(height: 12),
        Row(children: [
          const Icon(Icons.movie_outlined, color: RestoColors.primaryDeep, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _newVideo != null ? _newVideo!.name : (_video != null ? t.videoAdded : t.videoOptional),
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          if (_video != null)
            IconButton(
              tooltip: t.play,
              icon: const Icon(Icons.play_circle_outline_rounded),
              onPressed: () => openLink(AppScope.read(context).api!.menu.videoUrl(_video!)),
            ),
          if (canCatalog) TextButton(onPressed: _pickVideo, child: Text(_video == null && _newVideo == null ? t.add : t.replace)),
          if (canCatalog && (_video != null || _newVideo != null))
            IconButton(
              tooltip: t.delete,
              icon: const Icon(Icons.delete_outline_rounded),
              onPressed: () => setState(() {
                if (_video != null) _removed.add(_video!);
                _video = null;
                _newVideo = null;
              }),
            ),
        ]),
      ]),

      // ------------------------------------------------ informations
      _card(t.productInfo, Icons.auto_awesome_outlined, [
        TextFormField(
          controller: _name,
          enabled: canCatalog,
          maxLength: 120,
          decoration: InputDecoration(labelText: t.itemName, hintText: t.itemExamples),
          validator: (v) => (v == null || v.trim().isEmpty) ? t.fieldRequired : null,
        ),
        DropdownButtonFormField<String>(
          initialValue: _categoryId,
          decoration: InputDecoration(labelText: t.category, errorText: _categoryError),
          items: [for (final c in b.menu.categories) DropdownMenuItem(value: c.id, child: Text(c.name))],
          onChanged: canCatalog ? (v) => setState(() => _categoryId = v) : null,
        ),
        const SizedBox(height: 12),
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (final k in itemKinds)
            GoldPill(label: kindLabel(t, k), selected: _kind == k, dense: true, onTap: canCatalog ? () => setState(() => _kind = k) : () {}),
        ]),
        const SizedBox(height: 12),
        TextFormField(
          controller: _description,
          enabled: canCatalog,
          maxLength: 2000,
          maxLines: 4,
          minLines: 2,
          decoration: InputDecoration(labelText: t.descriptionOptional, hintText: t.itemDescriptionHint),
        ),
      ]),

      // ------------------------------------------------ prix & tailles
      _card(isNew ? t.priceTitle : t.priceAt(b.branch.name), Icons.sell_outlined, [
        if (canCatalog)
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(t.severalSizes),
            value: _multi,
            onChanged: (v) => setState(() {
              _multi = v;
              if (v && activeSizes.length == 1) _sizes.add(_SizeDraft());
            }),
          ),
        for (final s in (_multi ? activeSizes : activeSizes.take(1))) _sizeRow(s, canPrice),
        if (_multi && canCatalog)
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton.icon(
              onPressed: () => setState(() => _sizes.add(_SizeDraft())),
              icon: const Icon(Icons.add),
              label: Text(t.addSize),
            ),
          ),
        if (isNew && b.manageableBranches.length > 1) Text(t.samePriceEverywhere),
      ]),

      // ------------------------------------------------ stock & temps
      _card(t.stockAndTime, Icons.timer_outlined, [
        Wrap(spacing: 14, runSpacing: 12, children: [
          SizedBox(
            width: 200,
            child: TextField(
              controller: _stock,
              enabled: canPrice,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: t.stockQuantity, hintText: t.stockNotTracked),
            ),
          ),
          SizedBox(
            width: 200,
            child: TextField(
              controller: _prep,
              enabled: canCatalog,
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(labelText: t.prepTime, suffixText: t.minutesShort),
            ),
          ),
        ]),
        const SizedBox(height: 14),
        Text(t.saleDays, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (var d = 1; d <= 7; d++)
            GoldPill(
              label: weekdayName(t, d),
              selected: _days.contains(d),
              dense: true,
              onTap: canCatalog ? () => setState(() => _days.contains(d) ? _days.remove(d) : _days.add(d)) : () {},
            ),
        ]),
        const SizedBox(height: 14),
        Text(t.itemTagsLabel, style: Theme.of(context).textTheme.titleSmall),
        Text(t.itemTagsHint, style: const TextStyle(color: RestoColors.muted, fontSize: 12)),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 8, crossAxisAlignment: WrapCrossAlignment.center, children: [
          for (final tag in _tags)
            GoldPill(
              label: tag,
              icon: Icons.close_rounded,
              selected: true,
              dense: true,
              onTap: canCatalog ? () => setState(() => _tags.remove(tag)) : () {},
            ),
          // Étiquettes déjà utilisées sur d'autres plats de la carte.
          for (final tag in _tagSuggestions)
            GoldPill(
              label: tag,
              icon: Icons.add_rounded,
              selected: false,
              dense: true,
              onTap: canCatalog && _tags.length < 10 ? () => setState(() => _tags.add(tag)) : () {},
            ),
          if (canCatalog && _tags.length < 10)
            SizedBox(
              width: 220,
              child: TextField(
                controller: _tagInput,
                maxLength: 30,
                decoration: InputDecoration(isDense: true, counterText: '', hintText: t.addTagHint),
                onSubmitted: (v) {
                  final tag = v.trim().replaceAll(RegExp(r'\s+'), ' ');
                  if (tag.isEmpty || _tags.any((x) => x.toLowerCase() == tag.toLowerCase())) return;
                  setState(() {
                    _tags.add(tag);
                    _tagInput.clear();
                  });
                },
              ),
            ),
        ]),
      ]),

      // ------------------------------------------------ vente
      _card(t.salesTitle, Icons.storefront_outlined, [
        if (isNew)
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final br in b.manageableBranches)
              FilterChip(
                label: Text(br.name),
                selected: _soldIn.contains(br.id),
                onSelected: (on) => setState(() => on ? _soldIn.add(br.id!) : _soldIn.remove(br.id)),
              ),
          ])
        else ...[
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(t.soldAt(b.branch.name)),
            value: _soldHere,
            onChanged: b.canBranch ? (v) => setState(() => _soldHere = v) : null,
          ),
          if (_soldHere)
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(t.soldOutToday),
              value: _soldOut,
              onChanged: b.canBranch ? (v) => setState(() => _soldOut = v) : null,
            ),
        ],
        if (canCatalog)
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(t.activeLabel),
            subtitle: Text(t.visibleOnMenu),
            value: _visible,
            activeTrackColor: RestoColors.primary,
            onChanged: (v) => setState(() => _visible = v),
          ),
      ]),

      // ------------------------------------------------ options
      _card(
        t.optionsForItem,
        Icons.add_circle_outline_rounded,
        [
          if (_groups.isEmpty) Text(t.noOptionsYet),
          for (final g in _groups.where((g) => g.active || _groupIds.contains(g.id)))
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(g.name),
              subtitle: Text('${optionRuleLabel(t, g.minSelect, g.maxSelect)} : '
                  '${g.modifiers.where((m) => m.active).map((m) => m.name).join(', ')}'),
              value: _groupIds.contains(g.id),
              onChanged: canCatalog ? (on) => setState(() => on == true ? _groupIds.add(g.id) : _groupIds.remove(g.id)) : null,
            ),
        ],
        action: canCatalog ? TextButton(onPressed: _manageOptions, child: Text(t.manageOptions)) : null,
      ),

      // ------------------------------------------------ allergènes
      _card(t.allergens, Icons.health_and_safety_outlined, [
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (final a in allergenCodes)
            FilterChip(
              label: Text(allergenLabel(t, a)),
              selected: _allergens.contains(a),
              onSelected: canCatalog ? (on) => setState(() => on ? _allergens.add(a) : _allergens.remove(a)) : null,
            ),
        ]),
      ]),

      if (!isNew) _ItemReviewsCard(itemId: item!.id, canModerate: b.membership.can('customers.manage')),

      const SizedBox(height: 8),
      if (canCatalog || b.canBranch)
        GoldButton(label: t.publish, icon: Icons.check_circle_outline_rounded, onPressed: _save)
      else
        Text(t.readOnly),
    ]);

    final preview = _LivePreview(
      board: b,
      name: _name.text,
      description: _description.text,
      categoryName: b.menu.categories.where((c) => c.id == _categoryId).firstOrNull?.name,
      photo: _photos.firstOrNull,
      photoCount: _photos.length,
      sizes: [
        for (final s in (_multi ? activeSizes : activeSizes.take(1)))
          (s.name.text, parseAmount(s.prices['default']!.text, b.currency, b.minorUnit)),
      ],
      supplements: [
        for (final g in _groups.where((g) => _groupIds.contains(g.id)))
          for (final m in g.modifiers.where((m) => m.active)) m.name,
      ],
      allergens: [for (final a in _allergens) allergenLabel(t, a)],
      prepMinutes: int.tryParse(_prep.text.trim()),
      days: _days.toList()..sort(),
      active: _visible,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(isNew ? t.addProduct : item!.name, style: serifTitle(context, size: 26)),
        actions: [
          if (!isNew && canCatalog)
            IconButton(tooltip: t.translations, icon: const Icon(Icons.translate), onPressed: _translate),
          const SizedBox(width: 8),
        ],
      ),
      body: Form(
        key: _form,
        child: wide
            ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(child: ListView(padding: const EdgeInsets.fromLTRB(24, 8, 12, 40), children: [form])),
                SizedBox(
                  width: 400,
                  child: ListView(padding: const EdgeInsets.fromLTRB(12, 8, 24, 40), children: [preview]),
                ),
              ])
            : ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 40), children: [form, const SizedBox(height: 20), preview]),
      ),
    );
  }
}

/// Avis des clients sur l'article : avis notés vérifiés et avis libres, avec
/// modération (masquer avec un motif, ou republier).
class _ItemReviewsCard extends StatefulWidget {
  const _ItemReviewsCard({required this.itemId, required this.canModerate});
  final String itemId;
  final bool canModerate;

  @override
  State<_ItemReviewsCard> createState() => _ItemReviewsCardState();
}

class _ItemReviewsCardState extends State<_ItemReviewsCard> {
  late Future<List<Map<String, dynamic>>> _reviews = _load();

  /// Avis notés puis avis libres (marqués « kind » = comment), les plus récents d'abord.
  Future<List<Map<String, dynamic>>> _load() async {
    final api = AppScope.read(context).api!.menu;
    final r = await Future.wait([api.itemReviews(widget.itemId), api.itemComments(widget.itemId)]);
    return [...r[0], for (final c in r[1]) {...c, 'kind': 'comment', 'comment': c['body']}]
      ..sort((a, b) => (b['created_at'] as String).compareTo(a['created_at'] as String));
  }

  Future<void> _moderate(Map<String, dynamic> r, bool hide) async {
    final t = context.t;
    String? reason;
    if (hide) {
      final ctl = TextEditingController();
      final ok = await showDialog<bool>(
        context: context,
        builder: (d) => AlertDialog(
          title: Text(t.hideReview),
          content: TextField(controller: ctl, maxLength: 300, decoration: InputDecoration(labelText: t.hideReviewReason)),
          actions: [
            TextButton(onPressed: () => Navigator.pop(d, false), child: Text(t.cancel)),
            FilledButton(onPressed: () => Navigator.pop(d, true), child: Text(t.hideReview)),
          ],
        ),
      );
      if (ok != true) return;
      reason = ctl.text.trim();
    }
    if (!mounted) return;
    try {
      final api = AppScope.read(context).api!.menu;
      if (r['kind'] == 'comment') {
        await api.moderateItemComment(r['id'] as String, hide, reason: reason);
      } else {
        await api.moderateReview(r['id'] as String, hide, reason: reason);
      }
      setState(() => _reviews = _load());
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _reviews,
      builder: (context, snap) {
        final list = snap.data ?? const <Map<String, dynamic>>[];
        final published = list.where((r) => r['status'] == 'published' && r['kind'] != 'comment').toList();
        final avg = published.isEmpty ? null : published.fold<int>(0, (a, r) => a + (r['rating'] as num).toInt()) / published.length;
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: SoftCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              SectionHeading(
                title: t.customerReviewsTitle,
                icon: Icons.rate_review_outlined,
                subtitle: avg == null ? t.noReviewsYet : '${avg.toStringAsFixed(1)}/5 · ${t.reviewsCount(published.length)}',
              ),
              const SizedBox(height: 10),
              for (final r in list.take(20))
                Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: r['status'] == 'hidden' ? RestoColors.sunken : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: RestoColors.line),
                  ),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      if (r['kind'] == 'comment')
                        const Icon(Icons.mode_comment_outlined, size: 16, color: RestoColors.primaryDeep)
                      else
                        for (var s = 1; s <= 5; s++)
                          Icon(Icons.star_rounded, size: 15, color: s <= (r['rating'] as num) ? RestoColors.primary : RestoColors.line),
                      const SizedBox(width: 8),
                      Expanded(child: Text(r['author_name'] as String? ?? '', style: const TextStyle(fontWeight: FontWeight.w600))),
                      if ((r['reports_count'] as num? ?? 0) > 0)
                        StatusPill(label: t.reportsCount((r['reports_count'] as num).toInt()), color: StatusColors.late, dense: true),
                      if (r['status'] == 'hidden') ...[
                        const SizedBox(width: 6),
                        StatusPill(label: t.hidden, color: RestoColors.muted, dense: true),
                      ],
                    ]),
                    if ((r['comment'] as String? ?? '').isNotEmpty) Text(r['comment'] as String),
                    if (r['status'] == 'hidden' && r['hidden_reason'] != null)
                      Text('${t.hideReviewReason} : ${r['hidden_reason']}', style: const TextStyle(color: RestoColors.muted, fontSize: 12)),
                    if (widget.canModerate)
                      Align(
                        alignment: AlignmentDirectional.centerEnd,
                        child: TextButton(
                          onPressed: () => _moderate(r, r['status'] != 'hidden'),
                          child: Text(r['status'] == 'hidden' ? t.republishReview : t.hideReview),
                        ),
                      ),
                  ]),
                ),
            ]),
          ),
        );
      },
    );
  }
}

/// Aperçu en direct : l'article tel que le client le verra.
class _LivePreview extends StatelessWidget {
  const _LivePreview({
    required this.board,
    required this.name,
    required this.description,
    required this.categoryName,
    required this.photo,
    required this.photoCount,
    required this.sizes,
    required this.supplements,
    required this.allergens,
    required this.prepMinutes,
    required this.days,
    required this.active,
  });
  final MenuBoardContext board;
  final String name;
  final String description;
  final String? categoryName;
  final _Photo? photo;
  final int photoCount;
  final List<(String, int?)> sizes;
  final List<String> supplements;
  final List<String> allergens;
  final int? prepMinutes;
  final List<int> days;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final locale = Localizations.localeOf(context).toString();
    final menu = AppScope.read(context).api!.menu;
    String money(int v) => Money(v, board.currency).format(locale, board.minorUnit);
    final prices = [for (final s in sizes) ?s.$2];
    final from = prices.isEmpty ? null : prices.reduce((a, b) => a < b ? a : b);
    Widget tag(String text, {IconData? icon}) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: RestoColors.primary.withValues(alpha: 0.4)),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            if (icon != null) ...[Icon(icon, size: 13, color: RestoColors.primaryDeep), const SizedBox(width: 4)],
            Text(text, style: const TextStyle(fontSize: 12)),
          ]),
        );
    final allDays = days.length == 7;
    return SoftCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        SectionHeading(title: t.livePreview, icon: Icons.visibility_outlined),
        const SizedBox(height: 14),
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: AspectRatio(
            aspectRatio: 4 / 3,
            child: Stack(fit: StackFit.expand, children: [
              if (photo == null)
                Container(
                  decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFFF6ECD4), Color(0xFFEBD9B0)])),
                  child: const Icon(Icons.restaurant_rounded, size: 56, color: RestoColors.primaryDeep),
                )
              else if (photo!.path != null)
                Image.network(menu.imageUrl(photo!.path!), fit: BoxFit.cover)
              else
                Image.memory(photo!.picked!.bytes, fit: BoxFit.cover),
              Positioned(
                right: 8,
                top: 8,
                child: StatusPill(
                  label: active ? t.activeLabel : t.hidden,
                  color: active ? const Color(0xFF2E9E5B) : RestoColors.muted,
                  dense: true,
                ),
              ),
              if (photoCount > 1) Positioned(left: 8, bottom: 8, child: HeaderBadge(text: '1/$photoCount', icon: Icons.photo_library_outlined)),
            ]),
          ),
        ),
        const SizedBox(height: 12),
        if (categoryName != null) Align(alignment: AlignmentDirectional.centerStart, child: tag(categoryName!)),
        const SizedBox(height: 8),
        Text(name.isEmpty ? t.itemName : name, style: serifTitle(context, size: 26)),
        if (description.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(description, maxLines: 4, overflow: TextOverflow.ellipsis, style: const TextStyle(color: RestoColors.muted, fontSize: 13)),
        ],
        const SizedBox(height: 10),
        Text(from == null ? t.noPrice : money(from),
            style: const TextStyle(color: RestoColors.primaryDeep, fontWeight: FontWeight.w800, fontSize: 22)),
        if (sizes.length > 1 || (sizes.length == 1 && sizes.first.$1.isNotEmpty)) ...[
          const SizedBox(height: 12),
          Text(t.sizesLabel, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Wrap(spacing: 6, runSpacing: 6, children: [
            for (final s in sizes) tag('${s.$1.isEmpty ? '—' : s.$1} · ${s.$2 == null ? t.noPrice : money(s.$2!)}'),
          ]),
        ],
        if (supplements.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(t.supplementsLabel, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Wrap(spacing: 6, runSpacing: 6, children: [for (final s in supplements.take(8)) tag(s, icon: Icons.add_rounded)]),
        ],
        if (allergens.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(t.allergens, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Wrap(spacing: 6, runSpacing: 6, children: [for (final a in allergens) tag(a, icon: Icons.warning_amber_rounded)]),
        ],
        const Divider(height: 26),
        Row(children: [
          const Icon(Icons.schedule_rounded, size: 16, color: RestoColors.primaryDeep),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              [
                if (prepMinutes != null) t.prepMinutesShort(prepMinutes!),
                allDays ? t.everyDay : days.map((d) => weekdayName(t, d).substring(0, 3)).join(', '),
              ].join(' · '),
              style: const TextStyle(fontSize: 12.5, color: RestoColors.muted),
            ),
          ),
        ]),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(color: RestoColors.band, borderRadius: BorderRadius.circular(10)),
          child: Text(t.customerSideView, textAlign: TextAlign.center, style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 12)),
        ),
      ]),
    );
  }
}
