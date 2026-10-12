import 'dart:math';

import 'package:flutter/material.dart';

import '../../app_state.dart';
import '../../core/money.dart';
import '../../data/menu_models.dart';
import '../../data/models.dart';
import '../../ui/common.dart';
import '../../ui/dish_card.dart';
import '../../ui/header_slot.dart';
import '../../ui/kit.dart';
import '../../ui/theme.dart';
import 'item_sheet.dart';
import 'menu_widgets.dart';
import 'options_screen.dart';

/// Tout ce qu'il faut pour afficher et modifier le menu d'un établissement.
class MenuBoardContext {
  MenuBoardContext({
    required this.membership,
    required this.brand,
    required this.menu,
    required this.branches,
    required this.branch,
    required this.minorUnit,
    required this.state,
    this.stats = const {},
  });

  final Membership membership;
  final Brand brand;
  final BrandMenu menu;

  /// Établissements actifs de la marque visibles par le membre.
  final List<Branch> branches;
  final Branch branch;
  final int minorUnit;
  final BranchMenuState state;

  /// Avis, favoris et ventes de chaque article (vide si non disponible).
  final Map<String, ItemStats> stats;

  String get orgId => membership.organizationId;
  String get currency => branch.currency;

  /// Catalogue de la marque : droit sur toute l'organisation.
  bool get canCatalog => membership.canOrg('menus.manage');

  bool canManageBranch(Branch b) => membership.can('menus.manage') && (membership.allBranches || membership.branchIds.contains(b.id));

  bool get canBranch => canManageBranch(branch);

  List<Branch> get manageableBranches => branches.where(canManageBranch).toList();
}

class MenusScreen extends StatefulWidget {
  const MenusScreen({super.key, required this.membership});
  final Membership membership;

  @override
  State<MenusScreen> createState() => _MenusScreenState();
}

class _BoardData {
  _BoardData(this.brands, this.branches, this.minorUnits);
  final List<Brand> brands;
  final List<Branch> branches;
  final Map<String, int> minorUnits;
}

class _MenusScreenState extends State<MenusScreen> {
  String? _brandId;
  String? _branchId;

  Future<_BoardData> _load() async {
    final state = AppScope.read(context);
    final orgId = widget.membership.organizationId;
    final r = await Future.wait<dynamic>([state.api!.menu.brands(orgId), state.api!.branches(orgId), state.references()]);
    final refs = r[2] as References;
    return _BoardData(r[0] as List<Brand>, (r[1] as List<Branch>).where((b) => b.status == 'active').toList(), {
      for (final c in refs.currencies) c.code: c.minorUnit,
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return Loader<_BoardData>(
      load: _load,
      builder: (context, data, _) {
        if (data.brands.isEmpty) return Center(child: Text(t.noEntries));
        final brand = data.brands.firstWhere((b) => b.id == _brandId, orElse: () => data.brands.first);
        final branches = data.branches.where((b) => b.brandId == brand.id).toList();
        if (branches.isEmpty) return Center(child: Text(t.noBranches));
        final branch = branches.firstWhere((b) => b.id == _branchId, orElse: () => branches.first);
        return Column(
          children: [
            if (data.brands.length > 1 || branches.length > 1)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: FormWidth(
                  maxWidth: 900,
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      if (data.brands.length > 1)
                        SizedBox(
                          width: 280,
                          child: SearchSelect(
                            label: t.brand,
                            value: brand.id,
                            entries: [for (final b in data.brands) (b.id, b.name)],
                            onChanged: (v) => setState(() => _brandId = v),
                          ),
                        ),
                      if (branches.length > 1)
                        SizedBox(
                          width: 280,
                          child: SearchSelect(
                            label: t.menuOfBranch,
                            value: branch.id,
                            entries: [for (final b in branches) (b.id!, b.name)],
                            onChanged: (v) => setState(() => _branchId = v),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            Expanded(
              child: _Board(
                key: ValueKey('${brand.id}|${branch.id}'),
                membership: widget.membership,
                brand: brand,
                branches: branches,
                branch: branch,
                minorUnit: data.minorUnits[branch.currency] ?? 2,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _Board extends StatefulWidget {
  const _Board({
    super.key,
    required this.membership,
    required this.brand,
    required this.branches,
    required this.branch,
    required this.minorUnit,
  });

  final Membership membership;
  final Brand brand;
  final List<Branch> branches;
  final Branch branch;
  final int minorUnit;

  @override
  State<_Board> createState() => _BoardState();
}

class _BoardState extends State<_Board> {
  Key _key = UniqueKey();

  void _reload() => setState(() => _key = UniqueKey());

  Future<MenuBoardContext> _load() async {
    final api = AppScope.read(context).api!.menu;
    final r = await Future.wait<dynamic>([api.load(widget.brand.id), api.branchState(widget.branch.id!), api.itemStats(widget.branch.id!)]);
    return MenuBoardContext(
      membership: widget.membership,
      brand: widget.brand,
      menu: r[0] as BrandMenu,
      branches: widget.branches,
      branch: widget.branch,
      minorUnit: widget.minorUnit,
      state: r[1] as BranchMenuState,
      stats: r[2] as Map<String, ItemStats>,
    );
  }

  Future<void> _editCategory(MenuBoardContext ctx, [MenuCategory? category]) async {
    final result = await showDialog<_CategoryResult>(
      context: context,
      builder: (_) => _CategoryDialog(category: category),
    );
    if (result == null || !mounted) return;
    try {
      await AppScope.read(context).api!.menu.saveCategory(
        orgId: ctx.orgId,
        brandId: ctx.brand.id,
        id: category?.id,
        name: result.name,
        description: result.description,
        active: result.active,
        sortOrder: category == null ? ctx.menu.categories.length : null,
      );
      _reload();
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  Future<void> _translateCategory(MenuBoardContext ctx, MenuCategory c) async {
    final changes = await editTranslations(context, title: c.name, current: c.translations, withDescription: true);
    if (changes == null || changes.isEmpty || !mounted) return;
    final api = AppScope.read(context).api!.menu;
    try {
      for (final e in changes.entries) {
        await api.saveTranslation(
          table: 'menu_category_translations',
          keyColumn: 'category_id',
          orgId: ctx.orgId,
          entityId: c.id,
          locale: e.key,
          name: e.value.$1,
          description: e.value.$2,
          withDescription: true,
        );
      }
      _reload();
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  Future<void> _openItem(MenuBoardContext ctx, {MenuItem? item, String? categoryId}) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => ItemSheet(board: ctx, item: item, categoryId: categoryId),
      ),
    );
    if (changed == true) _reload();
  }

  Future<void> _openOptions(MenuBoardContext ctx) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => OptionsScreen(board: ctx)));
    _reload();
  }

  Future<void> _toggleSoldOut(MenuBoardContext ctx, MenuItem item, bool soldOut) async {
    try {
      await AppScope.read(context).api!.menu.setAvailable(item.id, ctx.branch.id!, !soldOut);
      _reload();
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  Future<void> _setActive(MenuItem item, bool active) async {
    try {
      await AppScope.read(context).api!.menu.setItemActive(item.id, active);
      _reload();
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  Future<void> _editStock(MenuBoardContext ctx, MenuItem item) async {
    final t = context.t;
    final current = ctx.state.stock[item.id];
    final qty = TextEditingController(text: current == null ? '' : '${current.$1}');
    final threshold = TextEditingController(text: '${current?.$2 ?? 5}');
    final ok = await showDialog<bool>(
      context: context,
      builder: (d) => AlertDialog(
        title: Text(t.stockOfDay),
        content: SizedBox(
          width: 360,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(t.stockOfDayHint, style: const TextStyle(color: RestoColors.muted, fontSize: 13)),
              const SizedBox(height: 12),
              TextField(
                controller: qty,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: t.stockQuantity),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: threshold,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: t.stockAlertThreshold),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(d, false), child: Text(t.cancel)),
          FilledButton(onPressed: () => Navigator.pop(d, true), child: Text(t.save)),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    try {
      await AppScope.read(context).api!.menu
          .setStock(item.id, ctx.branch.id!, int.tryParse(qty.text.trim()), threshold: int.tryParse(threshold.text.trim()));
      _reload();
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Loader<MenuBoardContext>(
      key: _key,
      load: _load,
      builder: (context, ctx, _) => _ProductBoard(
        ctx: ctx,
        onAddItem: (categoryId) => _openItem(ctx, categoryId: categoryId),
        onOpenItem: (i) => _openItem(ctx, item: i),
        onActive: _setActive,
        onSoldOut: (i, v) => _toggleSoldOut(ctx, i, v),
        onStock: (i) => _editStock(ctx, i),
        onCategory: (c) => _editCategory(ctx, c),
        onTranslateCategory: (c) => _translateCategory(ctx, c),
        onOptions: () => _openOptions(ctx),
      ),
    );
  }
}

/// Produits du menu : les catégories (et les commandes du module) sont dans
/// l'en-tête, à côté du titre ; la grille montre les cartes produit.
class _ProductBoard extends StatefulWidget {
  const _ProductBoard({
    required this.ctx,
    required this.onAddItem,
    required this.onOpenItem,
    required this.onActive,
    required this.onSoldOut,
    required this.onStock,
    required this.onCategory,
    required this.onTranslateCategory,
    required this.onOptions,
  });
  final MenuBoardContext ctx;
  final ValueChanged<String?> onAddItem;
  final ValueChanged<MenuItem> onOpenItem;
  final void Function(MenuItem, bool) onActive;
  final void Function(MenuItem, bool) onSoldOut;
  final ValueChanged<MenuItem> onStock;
  final ValueChanged<MenuCategory?> onCategory;
  final ValueChanged<MenuCategory> onTranslateCategory;
  final VoidCallback onOptions;

  @override
  State<_ProductBoard> createState() => _ProductBoardState();
}

class _ProductBoardState extends State<_ProductBoard> {
  /// null = toutes ; « __soldout » = en rupture ; « __low » = stock faible.
  String? _category;
  String _query = '';
  bool _searching = false;
  final _search = TextEditingController();

  MenuBoardContext get ctx => widget.ctx;

  @override
  void dispose() {
    HeaderSlot.clear(this);
    _search.dispose();
    super.dispose();
  }

  int? _basePrice(MenuItem i) {
    final prices = [for (final v in i.variants.where((v) => v.active)) ?ctx.state.prices[(v.id, 'default')]];
    return prices.isEmpty ? null : prices.reduce(min);
  }

  bool _isLow(MenuItem i) {
    final s = ctx.state.stock[i.id];
    return s != null && s.$1 <= s.$2;
  }

  List<MenuItem> get _items {
    var list = ctx.menu.items.toList();
    if (_category == '__soldout') {
      list = list.where((i) => ctx.state.offered[i.id] == false).toList();
    } else if (_category == '__low') {
      list = list.where(_isLow).toList();
    } else if (_category != null) {
      list = list.where((i) => i.categoryId == _category).toList();
    }
    final q = _query.trim().toLowerCase();
    if (q.isNotEmpty) {
      list = list.where((i) => i.name.toLowerCase().contains(q) || (i.description ?? '').toLowerCase().contains(q)).toList();
    }
    return list;
  }

  Future<void> _categoryMenu(MenuCategory c, Offset at) async {
    final t = context.t;
    final a = await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(at.dx, at.dy, at.dx, at.dy),
      items: [
        PopupMenuItem(value: 'edit', child: Text(t.edit)),
        PopupMenuItem(value: 'translate', child: Text(t.translations)),
      ],
    );
    if (a == 'edit') widget.onCategory(c);
    if (a == 'translate') widget.onTranslateCategory(c);
  }

  void _toggleSearch() => setState(() {
    _searching = !_searching;
    if (!_searching) {
      _search.clear();
      _query = '';
    }
  });

  /// Ligne de l'en-tête : catégories défilantes, recherche, options, « + ».
  Widget _headerBar() {
    final t = context.t;
    final items = ctx.menu.items;
    final soldOut = items.where((i) => ctx.state.offered[i.id] == false).length;
    final low = items.where(_isLow).length;
    Widget pill(String? id, String label, int count, {MenuCategory? category, IconData? icon}) {
      Widget p = GoldPill(
        label: label,
        icon: icon,
        count: count,
        dense: true,
        selected: _category == id,
        onTap: () => setState(() => _category = id),
      );
      if (category != null && ctx.canCatalog) {
        p = GestureDetector(
          onLongPressStart: (d) => _categoryMenu(category, d.globalPosition),
          onSecondaryTapDown: (d) => _categoryMenu(category, d.globalPosition),
          child: p,
        );
      }
      return Padding(padding: const EdgeInsetsDirectional.only(end: 8), child: p);
    }

    return Row(
      children: [
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                pill(null, t.allItems, items.length),
                for (final c in ctx.menu.categories)
                  pill(c.id, c.active ? c.name : '${c.name} · ${t.hidden}', ctx.menu.itemsOf(c.id).length, category: c),
                if (soldOut > 0) pill('__soldout', t.soldOut, soldOut, icon: Icons.block_rounded),
                if (low > 0) pill('__low', t.lowStockTitle, low, icon: Icons.warning_amber_rounded),
                if (ctx.canCatalog)
                  Tooltip(
                    message: t.newCategory,
                    child: _RoundButton(icon: Icons.create_new_folder_outlined, onTap: () => widget.onCategory(null)),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        Tooltip(
          message: t.searchProduct,
          child: _RoundButton(icon: _searching ? Icons.close_rounded : Icons.search_rounded, onTap: _toggleSearch),
        ),
        const SizedBox(width: 6),
        Tooltip(
          message: t.optionsTitle,
          child: _RoundButton(icon: Icons.tune_rounded, onTap: widget.onOptions),
        ),
        if (ctx.canCatalog && ctx.menu.categories.isNotEmpty) ...[
          const SizedBox(width: 6),
          Tooltip(
            message: t.addProduct,
            child: _RoundButton(
              icon: Icons.add_rounded,
              gold: true,
              onTap: () => widget.onAddItem(_category != null && !_category!.startsWith('__') ? _category : null),
            ),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final side = MediaQuery.sizeOf(context).width < 600 ? 16.0 : 22.0;
    final items = _items;
    HeaderSlot.show(this, 'menus', _headerBar());
    final grid = LayoutBuilder(
      builder: (context, box) {
        final cols = max(2, (box.maxWidth / 220).floor());
        final gap = box.maxWidth < 500 ? 10.0 : 14.0;
        final w = (box.maxWidth - (cols - 1) * gap) / cols;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final i in items)
              SizedBox(
                width: w,
                child: _ProductCard(
                  ctx: ctx,
                  item: i,
                  basePrice: _basePrice(i),
                  onOpen: () => widget.onOpenItem(i),
                  onActive: ctx.canCatalog ? (v) => widget.onActive(i, v) : null,
                  onSoldOut: ctx.canBranch && ctx.state.offered.containsKey(i.id) ? (v) => widget.onSoldOut(i, v) : null,
                  onStock: ctx.canBranch && ctx.state.offered.containsKey(i.id) ? () => widget.onStock(i) : null,
                ),
              ),
          ],
        );
      },
    );
    return ListView(
      padding: EdgeInsets.fromLTRB(side, 6, side, 40),
      children: [
        if (_searching)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: SizedBox(
                width: 360,
                child: TextField(
                  controller: _search,
                  autofocus: true,
                  onChanged: (v) => setState(() => _query = v),
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: t.searchProduct,
                    prefixIcon: const Icon(Icons.search_rounded, size: 20),
                    fillColor: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        if (ctx.menu.categories.isEmpty)
          EmptyState(
            icon: Icons.restaurant_menu_rounded,
            title: t.menuEmptyTitle,
            message: t.menuEmptyHint,
            action: ctx.canCatalog
                ? GoldButton(label: t.newCategory, icon: Icons.add_rounded, expand: false, onPressed: () async => widget.onCategory(null))
                : null,
          )
        else if (items.isEmpty)
          EmptyState(icon: Icons.search_off_rounded, title: t.noProductsFound)
        else
          grid,
      ],
    );
  }
}

/// Petit bouton rond de l'en-tête (blanc, ou or pour l'ajout d'un produit).
class _RoundButton extends StatelessWidget {
  const _RoundButton({required this.icon, required this.onTap, this.gold = false});
  final IconData icon;
  final VoidCallback onTap;
  final bool gold;

  @override
  Widget build(BuildContext context) => MouseRegion(
    cursor: SystemMouseCursors.click,
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        width: gold ? 38 : 34,
        height: gold ? 38 : 34,
        decoration: BoxDecoration(
          gradient: gold ? RestoColors.brandGradient : null,
          color: gold ? null : Colors.white,
          shape: BoxShape.circle,
          border: gold ? null : Border.all(color: RestoColors.primary.withValues(alpha: 0.40)),
          boxShadow: gold
              ? [BoxShadow(color: RestoColors.primary.withValues(alpha: 0.35), blurRadius: 10, offset: const Offset(0, 4))]
              : null,
        ),
        child: Icon(icon, size: gold ? 24 : 18, color: gold ? Colors.white : RestoColors.primaryDeep),
      ),
    ),
  );
}

/// Carte produit (modèle commun avec la carte côté client) : photo, état,
/// prix, note, compteurs ; le bouton rond ouvre les actions (modifier,
/// rupture, stock du jour, visible sur la carte).
class _ProductCard extends StatelessWidget {
  const _ProductCard({
    required this.ctx,
    required this.item,
    required this.basePrice,
    required this.onOpen,
    this.onActive,
    this.onSoldOut,
    this.onStock,
  });
  final MenuBoardContext ctx;
  final MenuItem item;
  final int? basePrice;
  final VoidCallback onOpen;
  final ValueChanged<bool>? onActive;
  final ValueChanged<bool>? onSoldOut;
  final VoidCallback? onStock;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final menu = AppScope.read(context).api!.menu;
    final locale = Localizations.localeOf(context).toString();
    final offered = ctx.state.offered.containsKey(item.id);
    final soldOut = ctx.state.offered[item.id] == false;
    final stock = ctx.state.stock[item.id];
    final stats = ctx.stats[item.id] ?? const ItemStats();
    final hidden = t.hidden.isEmpty ? t.hidden : '${t.hidden[0].toUpperCase()}${t.hidden.substring(1)}';
    final (statusLabel, statusColor) = !item.active
        ? (hidden, RestoColors.muted)
        : !offered
            ? (t.notSoldHere, RestoColors.muted)
            : soldOut
                ? (t.soldOut, const Color(0xFFD9363E))
                : (stock != null && stock.$1 <= stock.$2)
                    ? (t.stockLow(stock.$1), const Color(0xFFB7791F))
                    : (t.available, const Color(0xFF2E9E5B));
    return DishCard(
      image: item.imagePath != null
          ? Image.network(menu.imageUrl(item.imagePath!), fit: BoxFit.cover,
              errorBuilder: (_, _, _) => _PhotoPlaceholder(kind: item.kind))
          : _PhotoPlaceholder(kind: item.kind),
      name: item.name,
      statusLabel: statusLabel,
      statusColor: statusColor,
      price: basePrice == null ? null : Money(basePrice!, ctx.currency).format(locale, ctx.minorUnit),
      rating: stats.rating,
      reviews: stats.reviews,
      likes: stats.likes,
      favorites: stats.favorites,
      comments: stats.comments,
      views: stats.views,
      dimmed: !item.active || soldOut,
      video: item.videoPath != null,
      onTap: onOpen,
      action: PopupMenuButton<String>(
        tooltip: t.edit,
        onSelected: (a) => switch (a) {
          'edit' => onOpen(),
          'soldout' => onSoldOut?.call(!soldOut),
          'stock' => onStock?.call(),
          _ => onActive?.call(!item.active),
        },
        itemBuilder: (_) => [
          PopupMenuItem(value: 'edit', child: Text(t.edit)),
          if (onSoldOut != null) PopupMenuItem(value: 'soldout', child: Text(soldOut ? t.markAvailable : t.markSoldOut)),
          if (onStock != null) PopupMenuItem(value: 'stock', child: Text(t.stockOfDay)),
          if (onActive != null) CheckedPopupMenuItem(value: 'active', checked: item.active, child: Text(t.visibleOnMenu)),
        ],
        child: IgnorePointer(child: DishRoundButton(icon: Icons.edit_outlined, tooltip: t.edit, onPressed: () {})),
      ),
    );
  }
}
/// Visuel par défaut d'un article sans photo.
class _PhotoPlaceholder extends StatelessWidget {
  const _PhotoPlaceholder({required this.kind});
  final String kind;

  @override
  Widget build(BuildContext context) => Container(
    decoration: const BoxDecoration(
      gradient: LinearGradient(colors: [Color(0xFFF6ECD4), Color(0xFFEBD9B0)], begin: Alignment.topLeft, end: Alignment.bottomRight),
    ),
    child: Icon(
      switch (kind) {
        'drink' => Icons.local_bar_rounded,
        'dessert' => Icons.cake_outlined,
        'menu' => Icons.inventory_2_outlined,
        _ => Icons.restaurant_rounded,
      },
      size: 46,
      color: RestoColors.primaryDeep.withValues(alpha: 0.6),
    ),
  );
}

class _CategoryResult {
  _CategoryResult(this.name, this.description, this.active);
  final String name;
  final String? description;
  final bool active;
}

class _CategoryDialog extends StatefulWidget {
  const _CategoryDialog({this.category});
  final MenuCategory? category;

  @override
  State<_CategoryDialog> createState() => _CategoryDialogState();
}

class _CategoryDialogState extends State<_CategoryDialog> {
  late final _name = TextEditingController(text: widget.category?.name);
  late final _description = TextEditingController(text: widget.category?.description);
  late bool _visible = widget.category?.active ?? true;

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return AlertDialog(
      title: Text(widget.category == null ? t.newCategory : t.edit),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _name,
              autofocus: true,
              maxLength: 120,
              decoration: InputDecoration(labelText: t.name, hintText: t.categoryExamples),
            ),
            TextField(
              controller: _description,
              maxLength: 1000,
              maxLines: 3,
              minLines: 1,
              decoration: InputDecoration(labelText: t.descriptionOptional),
            ),
            if (widget.category != null)
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(t.visibleOnMenu),
                value: _visible,
                onChanged: (v) => setState(() => _visible = v),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(t.cancel)),
        FilledButton(
          onPressed: () {
            if (_name.text.trim().isEmpty) return;
            final d = _description.text.trim();
            Navigator.pop(context, _CategoryResult(_name.text.trim(), d.isEmpty ? null : d, _visible));
          },
          child: Text(t.save),
        ),
      ],
    );
  }
}
