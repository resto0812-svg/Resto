import 'dart:async';

import 'package:flutter/material.dart';

import '../../app_state.dart';
import '../../core/push_service.dart';
import '../../data/customer_api.dart' show CustomerNotification;
import '../../data/models.dart';
import '../../ui/brand_logo.dart';
import '../../ui/common.dart';
import '../../ui/header_slot.dart';
import '../../ui/kit.dart';
import '../../ui/neu.dart';
import '../../ui/theme.dart';
import '../account/account_screen.dart';
import '../ads/ads_screen.dart';
import '../audit/audit_screen.dart';
import '../branches/branches_screen.dart';
import '../cash/cash_screen.dart';
import '../customer/loyalty_pages.dart' show NotificationBell;
import '../customers/customers_screen.dart';
import '../expenses/expenses_screen.dart';
import '../kitchen/kitchen_screen.dart';
import '../menus/menus_screen.dart';
import '../purchases/purchases_screen.dart';
import '../reports/reports_screen.dart';
import '../service/service_screen.dart';
import '../settings/settings_screen.dart';
import '../stock/stock_screen.dart';
import '../team/team_screen.dart';
import 'getting_started.dart';

class _Section {
  const _Section(this.id, this.group, this.icon, this.label, this.build);

  /// Identifiant stable (ouverture depuis l'accueil : « orders », « cash »…).
  final String id;

  /// -1 accueil, 0 service, 1 gestion, 2 organisation, 3 compte.
  final int group;
  final IconData icon;
  final String label;
  final Widget Function() build;
}

/// Structure principale « Ivoire & Or » : sur grand écran, un dock blanc
/// (logo du restaurant, un bouton par module) et un grand titre à
/// empattements ; sur téléphone, une barre flottante en bas. Les modules
/// suivent les droits du membre (le serveur reste seul juge).
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;
  StreamSubscription<Map<String, dynamic>>? _pushTaps;

  @override
  void initState() {
    super.initState();
    // Notification touchée (push) : ouvre le module concerné.
    _pushTaps = PushService.instance.taps.stream.listen(_openNotification);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final pending = PushService.instance.pendingTap;
      if (pending != null && mounted) {
        PushService.instance.pendingTap = null;
        _openNotification(pending);
      }
    });
  }

  @override
  void dispose() {
    _pushTaps?.cancel();
    super.dispose();
  }

  /// Commande ou réservation → Commandes ; avis → Menus.
  void _openNotification(Map<String, dynamic> data) {
    if (!mounted) return;
    final id = switch (data['kind']) {
      'staff_new_order' || 'staff_order_ready' || 'staff_new_reservation' => 'orders',
      'staff_new_review' => 'menus',
      _ => null,
    };
    final m = AppScope.read(context).current;
    if (id == null || m == null) return;
    final i = _sections(context, m).indexWhere((s) => s.id == id);
    if (i >= 0) setState(() => _index = i);
  }

  List<_Section> _sections(BuildContext context, Membership m) {
    final t = context.t;
    final o = m.organizationId;
    late final List<_Section> all;
    void open(String id) {
      final i = all.indexWhere((s) => s.id == id);
      if (i >= 0) setState(() => _index = i);
    }

    all = [
      _Section(
        'home',
        -1,
        Icons.space_dashboard_rounded,
        t.navHome,
        () => _Launcher(membership: m, sections: all, onOpen: (i) => setState(() => _index = i), onOpenId: open),
      ),
      if (m.can('orders.read'))
        _Section('orders', 0, Icons.receipt_long_rounded, t.navOrders, () => ServiceScreen(key: ValueKey('o$o'), membership: m)),
      if (m.can('kitchen.operate'))
        _Section('kitchen', 0, Icons.soup_kitchen_rounded, t.navKitchen, () => KitchenScreen(key: ValueKey('k$o'), membership: m)),
      if (m.can('cash.operate') || m.can('finance.read'))
        _Section('cash', 0, Icons.point_of_sale_rounded, t.navCash, () => CashScreen(key: ValueKey('c$o'), membership: m)),
      if (m.can('menus.manage'))
        _Section('menus', 1, Icons.restaurant_menu_rounded, t.navMenus, () => MenusScreen(key: ValueKey('m$o'), membership: m)),
      if (m.can('stock.read'))
        _Section('stock', 1, Icons.inventory_2_rounded, t.navStock, () => StockScreen(key: ValueKey('s$o'), membership: m)),
      if (m.can('purchases.manage'))
        _Section('purchases', 1, Icons.shopping_bag_rounded, t.navPurchases, () => PurchasesScreen(key: ValueKey('p$o'), membership: m)),
      if (m.can('expenses.manage'))
        _Section('expenses', 1, Icons.receipt_rounded, t.navExpenses, () => ExpensesScreen(key: ValueKey('e$o'), membership: m)),
      if (m.can('finance.read'))
        _Section('reports', 1, Icons.insights_rounded, t.navReports, () => ReportsScreen(key: ValueKey('r$o'), membership: m)),
      if (m.can('orders.read'))
        _Section('customers', 1, Icons.people_alt_rounded, t.navCustomers, () => CustomersScreen(key: ValueKey('cu$o'), membership: m)),
      if (m.canOrg('marketing.manage'))
        _Section('ads', 1, Icons.campaign_rounded, t.navAds, () => AdsScreen(key: ValueKey('ad$o'), membership: m)),
      _Section('branches', 2, Icons.storefront_rounded, t.navBranches, () => BranchesScreen(key: ValueKey('b$o'), membership: m)),
      if (m.canOrg('members.manage'))
        _Section('team', 2, Icons.groups_rounded, t.navTeam, () => TeamScreen(key: ValueKey('t$o'), membership: m)),
      if (m.canOrg('audit.read'))
        _Section('audit', 2, Icons.history_rounded, t.navAudit, () => AuditScreen(key: ValueKey('a$o'), membership: m)),
      _Section('settings', 2, Icons.settings_rounded, t.navSettings, () => SettingsScreen(key: ValueKey('st$o'), membership: m)),
      _Section('account', 3, Icons.person_rounded, t.navAccount, () => const AccountScreen()),
    ];
    return all;
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final state = AppScope.of(context);
    final m = state.current!;
    final sections = _sections(context, m);
    final index = _index.clamp(0, sections.length - 1);
    final current = sections[index];
    final wide = MediaQuery.sizeOf(context).width >= 900;
    final accountIndex = sections.indexWhere((s) => s.group == 3);
    final settingsIndex = sections.indexWhere((s) => s.id == 'settings');
    final content = Column(
      children: [
        if (m.organizationStatus != 'active') MaterialBanner(content: Text(t.orgSuspended), actions: const [SizedBox.shrink()]),
        Expanded(
          child: KeyedSubtree(key: ValueKey(index), child: current.build()),
        ),
      ],
    );
    final header = _Header(
      section: current,
      state: state,
      membership: m,
      compact: !wide,
      onAccount: () => setState(() => _index = accountIndex),
      onSettings: () => setState(() => _index = settingsIndex),
      onNotification: (n) => _openNotification({...n.data, 'kind': n.kind}),
    );

    if (wide) {
      return Scaffold(
        body: Row(
          children: [
            _Dock(membership: m, sections: sections, index: index, onSelect: (i) => setState(() => _index = i)),
            Expanded(
              child: Column(
                children: [
                  header,
                  Expanded(child: content),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Téléphone : barre flottante (accueil + 3 modules + « Plus »).
    final primary = [
      0,
      ...List.generate(sections.length, (i) => i).where((i) => sections[i].group == 0 || sections[i].group == 1),
    ].take(4).toList();
    return Scaffold(
      extendBody: true,
      body: Column(
        children: [
          header,
          Expanded(
            child: Padding(padding: const EdgeInsets.only(bottom: 88), child: content),
          ),
        ],
      ),
      bottomNavigationBar: _FloatingBar(
        sections: sections,
        primary: primary,
        index: index,
        onSelect: (i) => setState(() => _index = i),
        onMore: () => showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          builder: (c) => SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: _ModuleGrid(
                sections: sections,
                onOpen: (i) {
                  Navigator.pop(c);
                  setState(() => _index = i);
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Dock blanc : logo du restaurant, un bouton par module (or quand choisi).
class _Dock extends StatelessWidget {
  const _Dock({required this.membership, required this.sections, required this.index, required this.onSelect});
  final Membership membership;
  final List<_Section> sections;
  final int index;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final p = NeuPalette.of(context);
    final items = <Widget>[];
    var lastGroup = -2;
    for (var i = 0; i < sections.length; i++) {
      final s = sections[i];
      if (s.group == 3) continue;
      if (lastGroup != -2 && s.group != lastGroup) {
        items.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 26),
            child: Container(
              height: 1.5,
              decoration: BoxDecoration(color: RestoColors.line, borderRadius: BorderRadius.circular(2)),
            ),
          ),
        );
      }
      lastGroup = s.group;
      items.add(_DockButton(section: s, selected: i == index, onTap: () => onSelect(i)));
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 18, 6, 18),
      child: Container(
        width: 82,
        decoration: BoxDecoration(color: p.card, borderRadius: BorderRadius.circular(30), boxShadow: p.raised(10)),
        child: Column(
          children: [
            const SizedBox(height: 18),
            BrandLogo(orgId: membership.organizationId, fallback: membership.organizationName, size: 52),
            const SizedBox(height: 14),
            Expanded(
              child: ListView(padding: const EdgeInsets.symmetric(vertical: 6), children: items),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class _DockButton extends StatefulWidget {
  const _DockButton({required this.section, required this.selected, required this.onTap});
  final _Section section;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_DockButton> createState() => _DockButtonState();
}

class _DockButtonState extends State<_DockButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final selected = widget.selected;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Tooltip(
        message: widget.section.label,
        preferBelow: false,
        verticalOffset: 0,
        margin: const EdgeInsets.only(left: 76),
        waitDuration: const Duration(milliseconds: 250),
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) => setState(() => _hover = true),
          onExit: (_) => setState(() => _hover = false),
          child: GestureDetector(
            onTap: widget.onTap,
            child: Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(17),
                  gradient: selected ? RestoColors.brandGradient : null,
                  color: selected ? null : (_hover ? RestoColors.primarySoft : Colors.transparent),
                  boxShadow: selected
                      ? [BoxShadow(color: RestoColors.primary.withValues(alpha: 0.35), blurRadius: 14, offset: const Offset(0, 6))]
                      : null,
                ),
                child: Icon(
                  widget.section.icon,
                  size: 24,
                  color: selected ? Colors.white : (_hover ? RestoColors.primaryDeep : RestoColors.primaryDeep.withValues(alpha: 0.75)),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// En-tête : grand titre à empattements, organisation et rôle, langue,
/// paramètres, compte (unique accès).
class _Header extends StatelessWidget {
  const _Header({
    required this.section,
    required this.state,
    required this.membership,
    required this.onAccount,
    required this.onSettings,
    required this.onNotification,
    this.compact = false,
  });
  final _Section section;
  final AppState state;
  final Membership membership;
  final VoidCallback onAccount;
  final VoidCallback onSettings;
  final ValueChanged<CustomerNotification> onNotification;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    final m = membership;
    final org = Text(
      m.organizationName,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: theme.textTheme.bodyMedium?.copyWith(color: RestoColors.primaryDeep),
    );
    final orgLine = state.memberships.length > 1
        ? PopupMenuButton<String>(
            tooltip: t.switchOrganization,
            initialValue: m.organizationId,
            onSelected: state.selectOrganization,
            itemBuilder: (_) => [
              for (final x in state.memberships)
                PopupMenuItem(value: x.organizationId, child: Text('${x.organizationName} · ${roleLabel(t, x.role)}')),
            ],
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(child: org),
                const Icon(Icons.expand_more_rounded, size: 16, color: RestoColors.primaryDeep),
              ],
            ),
          )
        : org;
    // En-tête compact : titre et organisation sur une seule ligne. Un module
    // peut placer ses propres commandes à côté du titre (HeaderSlot).
    return ValueListenableBuilder<(String, Widget)?>(
      valueListenable: HeaderSlot.notifier,
      builder: (context, slotValue, _) {
        final slot = slotValue != null && slotValue.$1 == section.id ? slotValue.$2 : null;
        final title = Text(
          section.id == 'home' ? t.navHome : section.label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: serifTitle(context, size: compact ? 21 : 27),
        );
        return SafeArea(
          bottom: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(compact ? 14 : 22, compact ? 6 : 10, compact ? 10 : 22, 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    if (compact) ...[BrandLogo(orgId: m.organizationId, fallback: m.organizationName, size: 34), const SizedBox(width: 10)],
                    Expanded(
                      child: compact
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [title, if (slot == null) orgLine],
                            )
                          : Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                if (slot == null) ...[
                                  Flexible(child: title),
                                  const SizedBox(width: 14),
                                  Flexible(child: orgLine),
                                ] else ...[
                                  title,
                                  const SizedBox(width: 18),
                                  Expanded(child: slot),
                                ],
                              ],
                            ),
                    ),
                    NotificationBell(staff: true, onStaffOpen: onNotification),
                    const LanguageMenuButton(),
                    if (!compact) IconButton(tooltip: t.navSettings, onPressed: onSettings, icon: const Icon(Icons.settings_outlined)),
                    const SizedBox(width: 6),
                    PopupMenuButton<String>(
                      tooltip: t.navAccount,
                      offset: const Offset(0, 44),
                      onSelected: (v) {
                        if (v == 'account') onAccount();
                        if (v == 'settings') onSettings();
                        if (v == 'signout') state.api?.signOut();
                      },
                      itemBuilder: (_) => [
                        PopupMenuItem(
                          value: 'account',
                          child: ListTile(leading: const Icon(Icons.person_outline_rounded), title: Text(t.myAccount)),
                        ),
                        PopupMenuItem(
                          value: 'settings',
                          child: ListTile(leading: const Icon(Icons.settings_outlined), title: Text(t.navSettings)),
                        ),
                        if (!state.previewLayout)
                          PopupMenuItem(
                            value: 'signout',
                            child: ListTile(leading: const Icon(Icons.logout_rounded), title: Text(t.signOut)),
                          ),
                      ],
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          gradient: RestoColors.brandGradient,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: RestoColors.primary.withValues(alpha: 0.35), blurRadius: 10, offset: const Offset(0, 4)),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          roleLabel(t, m.role).characters.first.toUpperCase(),
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15),
                        ),
                      ),
                    ),
                  ],
                ),
                if (compact && slot != null) Padding(padding: const EdgeInsets.only(top: 6), child: slot),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Barre flottante blanche (téléphone).
class _FloatingBar extends StatelessWidget {
  const _FloatingBar({required this.sections, required this.primary, required this.index, required this.onSelect, required this.onMore});
  final List<_Section> sections;
  final List<int> primary;
  final int index;
  final ValueChanged<int> onSelect;
  final VoidCallback onMore;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final p = NeuPalette.of(context);
    Widget item(IconData icon, String label, bool selected, VoidCallback onTap) => Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), color: selected ? RestoColors.primarySoft : null),
              child: Icon(icon, size: 23, color: selected ? RestoColors.primaryDeep : RestoColors.muted),
            ),
            const SizedBox(height: 3),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                maxLines: 1,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected ? RestoColors.primaryDeep : RestoColors.muted,
                ),
              ),
            ),
          ],
        ),
      ),
    );
    final inPrimary = primary.contains(index);
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
        child: Container(
          height: 70,
          padding: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(color: p.card, borderRadius: BorderRadius.circular(26), boxShadow: p.raised(9)),
          child: Row(
            children: [
              for (final i in primary) item(sections[i].icon, sections[i].label, i == index, () => onSelect(i)),
              item(Icons.apps_rounded, t.moreModules, !inPrimary, onMore),
            ],
          ),
        ),
      ),
    );
  }
}

/// Accueil : bandeau « Bonjour », puis tous les modules en une grille d'icônes.
class _Launcher extends StatelessWidget {
  const _Launcher({required this.membership, required this.sections, required this.onOpen, required this.onOpenId});
  final Membership membership;
  final List<_Section> sections;
  final ValueChanged<int> onOpen;
  final ValueChanged<String> onOpenId;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    final small = MediaQuery.sizeOf(context).width < 600;
    final side = small ? 16.0 : 22.0;
    return ListView(
      padding: EdgeInsets.fromLTRB(side, 4, side + 4, 40),
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: small ? 16 : 22, vertical: small ? 12 : 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [Color(0xFFC79A34), Color(0xFFE2C26F), Color(0xFFF5E7C4)],
            ),
            boxShadow: [BoxShadow(color: RestoColors.primary.withValues(alpha: 0.22), blurRadius: 14, offset: const Offset(0, 6))],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.greetingShort,
                      style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                    Text(
                      membership.organizationName.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: serifTitle(context, size: small ? 24 : 30, color: const Color(0xFF3A2A12), weight: FontWeight.w500),
                    ),
                    Text(
                      t.homeWelcome,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(color: const Color(0xFF4A3818)),
                    ),
                  ],
                ),
              ),
              Container(
                width: small ? 44 : 52,
                height: small ? 44 : 52,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: RestoColors.primary, width: 1.6),
                ),
                child: Icon(Icons.restaurant_rounded, size: small ? 22 : 26, color: RestoColors.primaryDeep),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        GettingStartedCard(membership: membership, onOpenId: onOpenId),
        _ModuleGrid(sections: sections, onOpen: onOpen),
      ],
    );
  }
}

/// Tous les modules dans une seule grille régulière (ordre du menu), sans titres de famille.
class _ModuleGrid extends StatelessWidget {
  const _ModuleGrid({required this.sections, required this.onOpen});
  final List<_Section> sections;
  final ValueChanged<int> onOpen;

  @override
  Widget build(BuildContext context) {
    final modules = [
      for (var i = 0; i < sections.length; i++)
        if (sections[i].group >= 0 && sections[i].group <= 2) i,
    ];
    return LayoutBuilder(
      builder: (context, box) {
        final cols = box.maxWidth >= 1100 ? 8 : (box.maxWidth >= 760 ? 6 : (box.maxWidth >= 520 ? 5 : 4));
        const gap = 10.0;
        final w = (box.maxWidth - (cols - 1) * gap) / cols;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final i in modules)
              SizedBox(
                width: w,
                child: _ModuleTile(section: sections[i], onTap: () => onOpen(i)),
              ),
          ],
        );
      },
    );
  }
}

class _ModuleTile extends StatefulWidget {
  const _ModuleTile({required this.section, required this.onTap});
  final _Section section;
  final VoidCallback onTap;

  @override
  State<_ModuleTile> createState() => _ModuleTileState();
}

class _ModuleTileState extends State<_ModuleTile> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final small = MediaQuery.sizeOf(context).width < 600;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          height: small ? 84 : 92,
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
          transform: Matrix4.translationValues(0, _hover ? -3 : 0, 0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _hover ? RestoColors.primary.withValues(alpha: 0.5) : Colors.transparent),
            boxShadow: RestoColors.softShadow(_hover ? 10 : 5),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GoldIcon(widget.section.icon, size: small ? 36 : 40, filled: true),
              const SizedBox(height: 7),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  widget.section.label,
                  maxLines: 1,
                  style: theme.textTheme.bodySmall?.copyWith(color: RestoColors.ink, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
