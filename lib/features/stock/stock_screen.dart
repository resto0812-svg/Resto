import 'package:flutter/material.dart';

import '../../app_state.dart';
import '../../core/money.dart';
import '../../data/models.dart';
import '../../data/purchases_api.dart';
import '../../data/stock_api.dart';
import '../../ui/common.dart';
import '../../ui/kit.dart';
import 'articles_tab.dart';
import 'inventory_screen.dart';
import 'movements_tab.dart';
import 'recipe_editor.dart';
import 'reorder_tab.dart';
import 'stock_dashboard_tab.dart';
import 'stock_levels_tab.dart';
import 'stock_reports_tab.dart';

/// Stock professionnel d'un établissement : tableau de bord, état du stock,
/// articles, fiches recettes, inventaires, commandes suggérées, mouvements,
/// rapports PDF.
class StockScreen extends StatefulWidget {
  const StockScreen({super.key, required this.membership});
  final Membership membership;

  @override
  State<StockScreen> createState() => _StockScreenState();
}

class _StockScreenState extends State<StockScreen> {
  String? _branchId;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final state = AppScope.of(context);
    final m = widget.membership;
    return Loader<(List<Branch>, Map<String, int>)>(
      load: () async {
        final branches = (await state.api!.branches(m.organizationId))
            .where((b) => b.status == 'active')
            .where((b) => m.allBranches || m.branchIds.contains(b.id))
            .toList();
        final refs = await state.references();
        return (branches, {for (final c in refs.currencies) c.code: c.minorUnit});
      },
      builder: (context, data, _) {
        final (branches, units) = data;
        if (branches.isEmpty) return Center(child: Text(t.noBranches));
        final branch = branches.firstWhere((b) => b.id == _branchId, orElse: () => branches.first);
        return _BranchStock(
          key: ValueKey(branch.id),
          membership: m,
          branch: branch,
          branches: branches,
          minorUnit: units[branch.currency] ?? 2,
          onBranch: (id) => setState(() => _branchId = id),
        );
      },
    );
  }
}

/// Données communes aux onglets du module.
class StockData {
  StockData(this.units, this.ingredients, this.locations, this.overview, [this.suppliers = const []]);
  final List<Unit> units;
  final List<Ingredient> ingredients;
  final List<StockLocation> locations;
  final List<StockLine> overview;
  final List<Supplier> suppliers;

  Ingredient? ingredient(String id) => ingredients.where((i) => i.id == id).firstOrNull;
  StockLine? line(String id) => overview.where((l) => l.ingredientId == id).firstOrNull;
  String? supplierName(String? id) => id == null ? null : suppliers.where((s) => s.id == id).firstOrNull?.name;
}

/// Contexte partagé par les onglets : établissement, droits, monnaie, rechargement.
class StockContext {
  StockContext({required this.membership, required this.branch, required this.minorUnit, required this.data, required this.reload});
  final Membership membership;
  final Branch branch;
  final int minorUnit;
  final StockData data;
  final VoidCallback reload;

  bool can(String p) => membership.can(p) && (membership.allBranches || membership.branchIds.contains(branch.id));

  String money(BuildContext context, num minor) =>
      Money(minor.round(), branch.currency).format(Localizations.localeOf(context).toString(), minorUnit);
}

class _BranchStock extends StatefulWidget {
  const _BranchStock({
    super.key,
    required this.membership,
    required this.branch,
    required this.branches,
    required this.minorUnit,
    required this.onBranch,
  });
  final Membership membership;
  final Branch branch;
  final List<Branch> branches;
  final int minorUnit;
  final ValueChanged<String> onBranch;

  @override
  State<_BranchStock> createState() => _BranchStockState();
}

class _BranchStockState extends State<_BranchStock> {
  late Future<StockData> _data = _load();
  int _tab = 0;

  Future<StockData> _load() async {
    final api = AppScope.read(context).api!;
    final r = await Future.wait<dynamic>([
      api.stock.units(),
      api.stock.ingredients(widget.membership.organizationId),
      api.stock.locations(widget.branch.id!),
      api.stock.overview(widget.branch.id!),
      api.purchases.suppliers(widget.membership.organizationId).catchError((_) => <Supplier>[]),
    ]);
    return StockData(r[0] as List<Unit>, r[1] as List<Ingredient>, r[2] as List<StockLocation>, r[3] as List<StockLine>,
        r[4] as List<Supplier>);
  }

  void _reload() => setState(() => _data = _load());

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final side = MediaQuery.sizeOf(context).width < 600 ? 16.0 : 22.0;
    return FutureBuilder<StockData>(
      future: _data,
      builder: (context, snap) {
        if (snap.hasError) return Center(child: TextButton(onPressed: _reload, child: Text(t.retry)));
        if (!snap.hasData) return const Center(child: CircularProgressIndicator());
        final d = snap.data!;
        final s = StockContext(membership: widget.membership, branch: widget.branch, minorUnit: widget.minorUnit, data: d, reload: _reload);
        final alerts = d.overview.where((l) => l.belowMin).length;
        final body = switch (_tab) {
          0 => StockDashboardTab(stock: s, onOpenTab: (i) => setState(() => _tab = i)),
          1 => StockLevelsTab(stock: s),
          2 => ArticlesTab(stock: s),
          3 => RecipesTab(
              membership: widget.membership,
              branch: widget.branch,
              data: d,
              money: (v) => s.money(context, v),
              onChanged: _reload,
            ),
          4 => InventoriesTab(membership: widget.membership, branch: widget.branch, data: d, onChanged: _reload),
          5 => ReorderTab(stock: s),
          6 => MovementsTab(stock: s),
          _ => StockReportsTab(stock: s),
        };
        return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Padding(
            padding: EdgeInsets.fromLTRB(side, 8, side, 6),
            child: Row(children: [
              Expanded(
                child: PillBar<int>(
                  items: [
                    PillItem(0, t.stockDashboardTab, icon: Icons.insights_rounded),
                    PillItem(1, t.stockLevels, icon: Icons.inventory_2_outlined, count: alerts == 0 ? null : alerts),
                    PillItem(2, t.stockArticlesTab, icon: Icons.category_outlined),
                    PillItem(3, t.recipesTab, icon: Icons.menu_book_outlined),
                    PillItem(4, t.inventoriesTab, icon: Icons.fact_check_outlined),
                    PillItem(5, t.stockOrdersTab, icon: Icons.local_shipping_outlined),
                    PillItem(6, t.movementsTab, icon: Icons.swap_vert_rounded),
                    PillItem(7, t.stockReportsTab, icon: Icons.picture_as_pdf_outlined),
                  ],
                  selected: _tab,
                  onSelected: (i) => setState(() => _tab = i),
                ),
              ),
              if (widget.branches.length > 1) ...[
                const SizedBox(width: 10),
                PopupMenuButton<String>(
                  tooltip: t.navBranches,
                  onSelected: widget.onBranch,
                  itemBuilder: (_) => [
                    for (final b in widget.branches) CheckedPopupMenuItem(value: b.id, checked: b.id == widget.branch.id, child: Text(b.name)),
                  ],
                  child: Chip(avatar: const Icon(Icons.storefront_outlined, size: 18), label: Text(widget.branch.name)),
                ),
              ],
            ]),
          ),
          Expanded(child: body),
        ]);
      },
    );
  }
}
