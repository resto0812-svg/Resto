import 'package:flutter/material.dart';

import '../../app_state.dart';
import '../../data/stock_api.dart';
import '../../ui/common.dart';
import '../../ui/files.dart';
import '../../ui/image_compress.dart';
import '../../ui/kit.dart';
import '../../ui/theme.dart';
import '../customer/customer_home.dart' show NetImage;
import 'stock_screen.dart';
import 'stock_widgets.dart';

/// Articles de stock : catalogue de l'organisation avec photo, conservation,
/// unité d'achat, fournisseur habituel, durée de conservation, code-barres.
class ArticlesTab extends StatefulWidget {
  const ArticlesTab({super.key, required this.stock});
  final StockContext stock;

  @override
  State<ArticlesTab> createState() => _ArticlesTabState();
}

class _ArticlesTabState extends State<ArticlesTab> {
  String _query = '';
  String _kind = 'all';
  bool _inactive = false;

  StockContext get s => widget.stock;

  Future<void> _edit([Ingredient? ing]) async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) => ArticleSheet(stock: s, ingredient: ing),
    );
    if (saved == true) s.reload();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final side = MediaQuery.sizeOf(context).width < 600 ? 16.0 : 22.0;
    final canEdit = s.membership.canOrg('stock.write');
    final q = _query.trim().toLowerCase();
    final list = s.data.ingredients
        .where((i) => _inactive || i.active)
        .where((i) => _kind == 'all' || i.kind == _kind)
        .where((i) => q.isEmpty || i.name.toLowerCase().contains(q) || (i.barcode ?? '').contains(q))
        .toList();
    return ListView(padding: EdgeInsets.fromLTRB(side, 6, side, 40), children: [
      Wrap(spacing: 10, runSpacing: 10, crossAxisAlignment: WrapCrossAlignment.center, children: [
        SizedBox(
          width: 260,
          child: TextField(
            onChanged: (v) => setState(() => _query = v),
            decoration: InputDecoration(isDense: true, fillColor: Colors.white, hintText: t.searchArticle, prefixIcon: const Icon(Icons.search_rounded, size: 20)),
          ),
        ),
        PillBar<String>(
          dense: true,
          items: [
            PillItem('all', t.allFilter),
            for (final k in ingredientKinds) PillItem(k, ingredientKindLabel(t, k), icon: ingredientKindIcon(k)),
          ],
          selected: _kind,
          onSelected: (v) => setState(() => _kind = v),
        ),
        FilterChip(label: Text(t.showInactive), selected: _inactive, onSelected: (v) => setState(() => _inactive = v)),
        if (canEdit) GoldButton(label: t.newArticle, icon: Icons.add_rounded, expand: false, onPressed: () async => _edit()),
      ]),
      const SizedBox(height: 14),
      if (list.isEmpty)
        EmptyState(icon: Icons.category_outlined, title: t.noIngredientsYet, message: t.articlesEmptyHint)
      else
        LayoutBuilder(builder: (context, box) {
          final cols = (box.maxWidth / 230).floor().clamp(2, 6);
          final w = (box.maxWidth - (cols - 1) * 12) / cols;
          return Wrap(spacing: 12, runSpacing: 12, children: [
            for (final i in list) SizedBox(width: w, child: _ArticleCard(stock: s, ingredient: i, onTap: canEdit ? () => _edit(i) : null)),
          ]);
        }),
    ]);
  }
}

class _ArticleCard extends StatelessWidget {
  const _ArticleCard({required this.stock, required this.ingredient, this.onTap});
  final StockContext stock;
  final Ingredient ingredient;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final i = ingredient;
    final api = AppScope.read(context).api!.stock;
    final line = stock.data.line(i.id);
    final supplier = stock.data.supplierName(i.preferredSupplierId);
    return Opacity(
      opacity: i.active ? 1 : 0.55,
      child: SoftCard(
        padding: EdgeInsets.zero,
        radius: 18,
        onTap: onTap,
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            child: AspectRatio(
              aspectRatio: 1.5,
              child: Stack(fit: StackFit.expand, children: [
                if (i.imagePath != null)
                  NetImage(api.imageUrl(i.imagePath!))
                else
                  Container(
                    decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFFF6ECD4), Color(0xFFE9D6A8)])),
                    child: Icon(ingredientKindIcon(i.kind), size: 40, color: RestoColors.primaryDeep.withValues(alpha: 0.7)),
                  ),
                Positioned(left: 8, top: 8, child: HeaderBadge(text: storageLabel(t, i.storage), icon: storageIcon(i.storage))),
                if (line != null && line.belowMin)
                  const Positioned(right: 8, top: 8, child: Icon(Icons.warning_amber_rounded, color: Color(0xFFE67E22))),
              ]),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(i.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700)),
              Text(
                [ingredientKindLabel(t, i.kind), '${t.stockUnit} : ${unitLabel(t, i.unitCode)}'].join(' · '),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: RestoColors.muted, fontSize: 12),
              ),
              if (i.purchaseUnitLabel != null || supplier != null) ...[
                const SizedBox(height: 4),
                Text(
                  [?i.purchaseUnitLabel, ?supplier].join(' · '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: RestoColors.primaryDeep, fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ],
              if (line != null) ...[
                const SizedBox(height: 6),
                Text('${formatQty(context, line.quantity)} ${unitLabel(t, i.unitCode)}', style: serifTitle(context, size: 20)),
              ],
            ]),
          ),
        ]),
      ),
    );
  }
}

/// Fiche article : une seule feuille, un seul bouton Enregistrer.
class ArticleSheet extends StatefulWidget {
  const ArticleSheet({super.key, required this.stock, this.ingredient});
  final StockContext stock;
  final Ingredient? ingredient;

  @override
  State<ArticleSheet> createState() => _ArticleSheetState();
}

class _ArticleSheetState extends State<ArticleSheet> {
  final _form = GlobalKey<FormState>();
  Ingredient? get i => widget.ingredient;
  late final _name = TextEditingController(text: i?.name);
  late final _barcode = TextEditingController(text: i?.barcode);
  late final _purchaseLabel = TextEditingController(text: i?.purchaseUnitLabel);
  late final _purchaseQty = TextEditingController(text: i?.purchaseUnitQty == null ? '' : formatQty(context, i!.purchaseUnitQty!));
  late final _shelfLife = TextEditingController(text: i?.shelfLifeDays?.toString() ?? '');
  late final _threshold = TextEditingController(
      text: (widget.stock.data.line(i?.id ?? '')?.minQuantity ?? 0) == 0 ? '' : formatQty(context, widget.stock.data.line(i!.id)!.minQuantity));
  late String _kind = i?.kind ?? 'raw';
  late String _unit = i?.unitCode ?? 'kg';
  late String _storage = i?.storage ?? 'ambient';
  late String? _supplier = i?.preferredSupplierId;
  late bool _active = i?.active ?? true;
  late String? _imagePath = i?.imagePath;
  PickedDocument? _newImage;

  @override
  void dispose() {
    for (final c in [_name, _barcode, _purchaseLabel, _purchaseQty, _shelfLife, _threshold]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickImage() async {
    final t = context.t;
    final picked = await pickMedia(videos: false, multiple: false);
    if (picked.isEmpty || !mounted) return;
    final files = [await compressPhoto(picked.first, maxSide: 1200)];
    if (!mounted) return;
    if (files.first.bytes.length > 2 * 1024 * 1024) {
      showInfo(context, t.fileTooBig(files.first.name));
      return;
    }
    setState(() => _newImage = files.first);
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    final s = widget.stock;
    final api = AppScope.read(context).api!.stock;
    try {
      if (_newImage != null) {
        _imagePath = await api.uploadImage(s.membership.organizationId, _newImage!.bytes, _newImage!.extension);
      }
      await api.saveArticle(
        s.membership.organizationId,
        i?.id,
        IngredientDraft(
          name: _name.text,
          kind: _kind,
          unit: _unit,
          active: _active,
          imagePath: _imagePath,
          barcode: _barcode.text,
          storage: _storage,
          purchaseUnitLabel: _purchaseLabel.text,
          purchaseUnitQty: parseQty(_purchaseQty.text),
          preferredSupplierId: _supplier,
          shelfLifeDays: int.tryParse(_shelfLife.text.trim()),
        ),
      );
      // Seuil d'alerte de cet établissement (article existant).
      final threshold = parseQty(_threshold.text.isEmpty ? '0' : _threshold.text);
      if (i != null && threshold != null && threshold != (s.data.line(i!.id)?.minQuantity ?? 0) && s.can('stock.write')) {
        await api.setThreshold(s.branch.id!, i!.id, threshold);
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final api = AppScope.read(context).api!.stock;
    final units = widget.stock.data.units;
    final suppliers = widget.stock.data.suppliers.where((s) => s.active || s.id == _supplier).toList();
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, MediaQuery.viewInsetsOf(context).bottom + 20),
      child: Form(
        key: _form,
        child: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text(i == null ? t.newArticle : t.editArticle, style: serifTitle(context, size: 24)),
            const SizedBox(height: 14),
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SizedBox(
                width: 110,
                height: 110,
                child: DashedBox(
                  padding: EdgeInsets.zero,
                  onTap: _pickImage,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: _newImage != null
                        ? Image.memory(_newImage!.bytes, fit: BoxFit.cover, width: 110, height: 110)
                        : _imagePath != null
                            ? NetImage(api.imageUrl(_imagePath!))
                            : const Center(child: Icon(Icons.add_a_photo_outlined, color: RestoColors.primaryDeep)),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(children: [
                  TextFormField(
                    controller: _name,
                    maxLength: 120,
                    decoration: InputDecoration(labelText: t.name, hintText: t.ingredientExamples, counterText: ''),
                    validator: (v) => (v ?? '').trim().isEmpty ? t.fieldRequired : null,
                  ),
                  const SizedBox(height: 10),
                  Row(children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _kind,
                        decoration: InputDecoration(labelText: t.ingredientKind),
                        items: [for (final k in ingredientKinds) DropdownMenuItem(value: k, child: Text(ingredientKindLabel(t, k)))],
                        onChanged: (v) => setState(() => _kind = v ?? _kind),
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 120,
                      child: DropdownButtonFormField<String>(
                        initialValue: _unit,
                        decoration: InputDecoration(labelText: t.stockUnit),
                        items: [for (final u in units) DropdownMenuItem(value: u.code, child: Text(unitLabel(t, u.code)))],
                        onChanged: (v) => setState(() => _unit = v ?? _unit),
                      ),
                    ),
                  ]),
                ]),
              ),
            ]),
            const SizedBox(height: 14),
            Text(t.storageLabel, style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            PillBar<String>(
              dense: true,
              items: [for (final st in const ['ambient', 'chilled', 'frozen']) PillItem(st, storageLabel(t, st), icon: storageIcon(st))],
              selected: _storage,
              onSelected: (v) => setState(() => _storage = v),
            ),
            const SizedBox(height: 14),
            Row(children: [
              Expanded(
                flex: 3,
                child: TextFormField(
                  controller: _purchaseLabel,
                  maxLength: 40,
                  decoration: InputDecoration(labelText: t.purchaseUnitLabel, hintText: t.purchaseUnitExample, counterText: ''),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: TextFormField(
                  controller: _purchaseQty,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(labelText: t.purchaseUnitQty, suffixText: unitLabel(t, _unit)),
                  validator: (v) => (v ?? '').trim().isEmpty || (parseQty(v!) ?? 0) > 0 ? null : t.errorInvalidQuantity,
                ),
              ),
            ]),
            const SizedBox(height: 10),
            DropdownButtonFormField<String?>(
              initialValue: _supplier,
              decoration: InputDecoration(labelText: t.preferredSupplier),
              items: [
                DropdownMenuItem<String?>(value: null, child: Text(t.noneLabel)),
                for (final sup in suppliers) DropdownMenuItem<String?>(value: sup.id, child: Text(sup.name)),
              ],
              onChanged: (v) => setState(() => _supplier = v),
            ),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(
                child: TextFormField(
                  controller: _shelfLife,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: t.shelfLifeDays, suffixText: t.daysShort),
                  validator: (v) {
                    if ((v ?? '').trim().isEmpty) return null;
                    final n = int.tryParse(v!.trim());
                    return n == null || n < 1 || n > 3650 ? t.errorInvalidQuantity : null;
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextFormField(
                  controller: _barcode,
                  maxLength: 60,
                  decoration: InputDecoration(labelText: t.barcodeLabel, counterText: ''),
                ),
              ),
            ]),
            if (i != null) ...[
              const SizedBox(height: 10),
              TextFormField(
                controller: _threshold,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(labelText: t.alertBelow, suffixText: unitLabel(t, _unit), helperText: t.thresholdThisBranch),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(t.active),
                value: _active,
                onChanged: (v) => setState(() => _active = v),
              ),
            ],
            const SizedBox(height: 14),
            GoldButton(label: t.save, icon: Icons.check_rounded, onPressed: _save),
          ]),
        ),
      ),
    );
  }
}
