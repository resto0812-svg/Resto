import 'package:flutter/material.dart';

import '../../data/cash_api.dart';
import '../../pdf/cash_pdf.dart';
import '../../pdf/tickets.dart' show printTicket;
import '../../ui/common.dart';
import '../../ui/theme.dart';
import '../service/service_actions.dart' show askReason;
import '../service/service_labels.dart';
import 'cash_context.dart';

/// Clôtures : comptages en attente de validation et historique des Z.
class ClosingsTab extends StatefulWidget {
  const ClosingsTab({super.key, required this.ctx});
  final CashContext ctx;

  @override
  State<ClosingsTab> createState() => _ClosingsTabState();
}

class _ClosingsTabState extends State<ClosingsTab> {
  Key _key = UniqueKey();
  CashContext get ctx => widget.ctx;

  Future<void> _print(CashSession s) async {
    try {
      final r = await Future.wait<dynamic>([ctx.cash.summary(s.id), ctx.cash.movements(s.id)]);
      if (!mounted) return;
      final bytes = await zReportPdf(
        CashDocContext(
          t: context.t,
          locale: Localizations.localeOf(context).toString(),
          minorUnit: ctx.scope.minorUnit,
          branch: ctx.scope.branch,
          staff: ctx.staff,
        ),
        s,
        r[0] as SessionSummary,
        register: ctx.registerName(s.registerId),
        movements: r[1] as List<CashMovement>,
      );
      await printTicket(bytes, s.zNumber != null ? 'z-${s.zNumber}.pdf' : 'comptage.pdf');
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  Future<void> _validate(CashSession s) async {
    final t = context.t;
    String? note;
    if ((s.differenceMinor ?? 0) != 0 && (s.countNote ?? '').length < 3) {
      note = await askReason(context, t.validateClosing, hint: t.differenceReasonHint);
      if (note == null) return;
    } else if (!await confirm(context, t.validateClosingConfirm, action: t.validate)) {
      return;
    }
    try {
      await ctx.cash.validate(s.id, note);
      if (mounted) showInfo(context, t.closingValidated);
      setState(() => _key = UniqueKey());
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    String m(int v) => ctx.scope.money(context, v);
    return Loader<List<CashSession>>(
      key: _key,
      load: () => ctx.cash.closings(ctx.scope.branchId),
      builder: (context, sessions, reload) {
        final pending = sessions.where((s) => s.status == 'counted').toList();
        final closed = sessions.where((s) => s.status == 'closed').toList();
        Widget tile(CashSession s) {
          final diff = s.differenceMinor ?? 0;
          final color = diff == 0 ? StatusColors.free : StatusColors.late;
          return Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: (s.zNumber != null ? RestoColors.primary : StatusColors.toValidate).withValues(alpha: 0.18),
                child: Text(
                  s.zNumber != null ? 'Z${s.zNumber}' : '…',
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: RestoColors.ink),
                ),
              ),
              title: Text('${ctx.registerName(s.registerId)} · ${dayLabel(context, s.openedAt)}'),
              subtitle: Text(
                [
                  '${hm(context, s.openedAt)} → ${s.countedAt == null ? '…' : hm(context, s.countedAt!)}',
                  '${t.expectedCashLabel} ${m(s.expectedCashMinor ?? 0)}',
                  '${t.countedAmountLabel} ${m(s.countedCashMinor ?? 0)}',
                  if (s.validatedBy != null) '${t.validatedLabel} : ${ctx.staffName(s.validatedBy)}',
                ].join(' · '),
              ),
              trailing: Wrap(
                spacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  StatusPill(label: m(diff), color: color, dense: true),
                  IconButton(tooltip: t.print, onPressed: () => _print(s), icon: const Icon(Icons.print_rounded)),
                  if (s.status == 'counted' && ctx.scope.can('cash.close'))
                    FilledButton(onPressed: () => _validate(s), child: Text(t.validate)),
                ],
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async => reload(),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 40),
            children: [
              if (pending.isNotEmpty) ...[
                Text(t.awaitingValidationTitle, style: theme.textTheme.titleMedium),
                const SizedBox(height: 6),
                for (final s in pending) tile(s),
                const SizedBox(height: 16),
              ],
              Text(t.zHistory, style: theme.textTheme.titleMedium),
              const SizedBox(height: 6),
              if (closed.isEmpty) Text(t.noClosings, style: theme.textTheme.bodySmall),
              for (final s in closed) tile(s),
            ],
          ),
        );
      },
    );
  }
}
