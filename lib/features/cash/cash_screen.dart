import 'package:flutter/material.dart';

import '../../app_state.dart';
import '../../core/errors.dart';
import '../../data/models.dart';
import '../../ui/branch_scope.dart';
import '../../ui/common.dart';
import '../../ui/kit.dart';
import 'cash_context.dart';
import 'cash_settings_tab.dart';
import 'closings_tab.dart';
import 'collect_tab.dart';
import 'invoices_tab.dart';
import 'refunds_tab.dart';
import 'reports_tab.dart';
import 'session_tab.dart';
import 'transactions_tab.dart';

/// Module Caisse : encaisser, ma caisse, clôtures, transactions,
/// remboursements, rapports, réglages (selon les droits du membre).
class CashScreen extends StatelessWidget {
  const CashScreen({super.key, required this.membership});
  final Membership membership;

  @override
  Widget build(BuildContext context) => BranchScope(
    membership: membership,
    builder: (context, scope) => _CashModule(key: ValueKey(scope.branchId), scope: scope),
  );
}

class _CashModule extends StatefulWidget {
  const _CashModule({super.key, required this.scope});
  final BranchContext scope;

  @override
  State<_CashModule> createState() => _CashModuleState();
}

class _CashModuleState extends State<_CashModule> {
  late final CashContext _ctx = CashContext(AppScope.read(context).api!, widget.scope);
  int _index = 0;
  List<(String, IconData, Widget Function())> _pages = const [];

  BranchContext get scope => widget.scope;

  @override
  void initState() {
    super.initState();
    _ctx.load();
  }

  @override
  void dispose() {
    _ctx.dispose();
    super.dispose();
  }

  void _goTo(String id) {
    final i = _pages.indexWhere((p) => p.$1 == id);
    if (i >= 0) setState(() => _index = i);
  }

  List<(String, IconData, Widget Function())> _build() {
    final operate = scope.can('cash.operate');
    final finance = scope.can('finance.read');
    final close = scope.can('cash.close');
    return [
      if (operate) ('collect', Icons.point_of_sale_rounded, () => CollectTab(ctx: _ctx, onOpenSession: () => _goTo('session'))),
      if (operate) ('session', Icons.savings_rounded, () => SessionTab(ctx: _ctx)),
      if (operate || close || finance) ('closings', Icons.lock_clock_rounded, () => ClosingsTab(ctx: _ctx)),
      if (operate || finance) ('transactions', Icons.receipt_long_rounded, () => TransactionsTab(ctx: _ctx)),
      if (operate || finance) ('invoices', Icons.description_rounded, () => InvoicesTab(ctx: _ctx)),
      if (scope.can('payments.refund')) ('refunds', Icons.undo_rounded, () => RefundsTab(ctx: _ctx)),
      if (finance || close) ('reports', Icons.insights_rounded, () => CashReportsTab(ctx: _ctx)),
      if (scope.can('branches.manage') || scope.membership.canOrg('org.manage'))
        ('settings', Icons.tune_rounded, () => CashSettingsTab(ctx: _ctx)),
    ];
  }

  String _label(BuildContext context, String id) {
    final t = context.t;
    return switch (id) {
      'collect' => t.collectTab,
      'session' => t.mySessionTab,
      'closings' => t.closingsTab,
      'transactions' => t.transactionsTab,
      'invoices' => t.invoicesTab,
      'refunds' => t.refundsTab,
      'reports' => t.reportsTab,
      _ => t.settingsTab,
    };
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return ListenableBuilder(
      listenable: _ctx,
      builder: (context, _) {
        if (!_ctx.loaded) {
          return Center(
            child: _ctx.error == null
                ? const CircularProgressIndicator()
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(errorText(t, _ctx.error!)),
                      const SizedBox(height: 12),
                      OutlinedButton(onPressed: _ctx.load, child: Text(t.retry)),
                    ],
                  ),
          );
        }
        if (_pages.isEmpty) _pages = _build();
        if (_pages.isEmpty) return Center(child: Text(t.errorForbidden));
        final index = _index.clamp(0, _pages.length - 1);
        final side = MediaQuery.sizeOf(context).width < 600 ? 16.0 : 22.0;
        return Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(side, 6, side, 6),
              child: PillBar<int>(
                dense: true,
                items: [for (var i = 0; i < _pages.length; i++) PillItem(i, _label(context, _pages[i].$1), icon: _pages[i].$2)],
                selected: index,
                onSelected: (i) => setState(() => _index = i),
              ),
            ),
            Expanded(
              child: KeyedSubtree(key: ValueKey(_pages[index].$1), child: _pages[index].$3()),
            ),
          ],
        );
      },
    );
  }
}
