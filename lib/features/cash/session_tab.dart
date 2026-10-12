import 'package:flutter/material.dart';

import '../../data/cash_api.dart';
import '../../pdf/cash_pdf.dart';
import '../../pdf/tickets.dart' show printTicket;
import '../../ui/common.dart';
import '../../ui/theme.dart';
import '../menus/menu_widgets.dart';
import '../service/service_actions.dart' show askReason;
import '../service/service_labels.dart';
import 'cash_context.dart';
import 'cash_labels.dart';

/// Ma caisse : ouverture (fond compté), suivi en direct, mouvements,
/// lecture X, clôture à l'aveugle puis validation (Z numéroté).
class SessionTab extends StatefulWidget {
  const SessionTab({super.key, required this.ctx});
  final CashContext ctx;

  @override
  State<SessionTab> createState() => _SessionTabState();
}

class _SessionTabState extends State<SessionTab> {
  Key _key = UniqueKey();
  CashContext get ctx => widget.ctx;

  void _reload() => setState(() => _key = UniqueKey());

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final active = ctx.registers.where((r) => r.active).toList();
    if (active.isEmpty) return Center(child: Text(t.noActiveRegister));
    return Column(
      children: [
        if (active.length > 1)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Wrap(
              spacing: 8,
              children: [
                for (final r in active)
                  ChoiceChip(
                    avatar: const Icon(Icons.point_of_sale_rounded, size: 16),
                    label: Text(r.name),
                    selected: r.id == ctx.registerId,
                    onSelected: (_) {
                      ctx.selectRegister(r.id);
                      _reload();
                    },
                  ),
              ],
            ),
          ),
        Expanded(
          child: Loader<CashSession?>(
            key: ValueKey('${ctx.registerId}$_key'),
            load: () => ctx.cash.activeSession(ctx.registerId!),
            builder: (context, session, _) {
              if (session == null) return _OpenRegister(ctx: ctx, onOpened: _reload);
              return _SessionView(ctx: ctx, session: session, onChanged: _reload);
            },
          ),
        ),
      ],
    );
  }
}

class _OpenRegister extends StatefulWidget {
  const _OpenRegister({required this.ctx, required this.onOpened});
  final CashContext ctx;
  final VoidCallback onOpened;

  @override
  State<_OpenRegister> createState() => _OpenRegisterState();
}

class _OpenRegisterState extends State<_OpenRegister> {
  final Map<int, int> _counts = {};
  late bool _detail = widget.ctx.denominations.isNotEmpty;
  final _amount = TextEditingController();
  final _clientId = uuidV4();
  bool _busy = false;

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  Future<void> _open() async {
    final ctx = widget.ctx;
    int? total;
    if (_detail) {
      total = DenominationCounter.total(_counts);
    } else {
      try {
        total = parseAmount(_amount.text, ctx.scope.currency, ctx.scope.minorUnit) ?? 0;
      } on Object {
        return showInfo(context, context.t.errorInvalidAmount);
      }
    }
    setState(() => _busy = true);
    try {
      await ctx.cash.openSession(ctx.registerId!, total, _clientId, detail: _detail ? _counts : null);
      widget.onOpened();
    } catch (e) {
      if (mounted) showError(context, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    final ctx = widget.ctx;
    String m(int v) => ctx.scope.money(context, v);
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        FormWidth(
          maxWidth: 820,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(t.openRegisterTitle(ctx.register?.name ?? ''), style: theme.textTheme.headlineSmall),
              const SizedBox(height: 4),
              Text(t.openRegisterHint, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              const SizedBox(height: 16),
              if (ctx.denominations.isNotEmpty)
                SegmentedButton<bool>(
                  showSelectedIcon: false,
                  segments: [
                    ButtonSegment(value: true, icon: const Icon(Icons.grid_view_rounded, size: 18), label: Text(t.countByDenomination)),
                    ButtonSegment(value: false, icon: const Icon(Icons.edit_rounded, size: 18), label: Text(t.enterAmount)),
                  ],
                  selected: {_detail},
                  onSelectionChanged: (s) => setState(() => _detail = s.first),
                ),
              const SizedBox(height: 12),
              if (_detail)
                DenominationCounter(denominations: ctx.denominations, counts: _counts, money: m, onChanged: () => setState(() {}))
              else
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: AmountField(
                    controller: _amount,
                    label: t.openingFloat,
                    currency: ctx.scope.currency,
                    minorUnit: ctx.scope.minorUnit,
                    width: 260,
                  ),
                ),
              const SizedBox(height: 20),
              SizedBox(
                height: 54,
                child: FilledButton.icon(
                  onPressed: _busy ? null : _open,
                  icon: const Icon(Icons.lock_open_rounded),
                  label: Text(t.openRegister(ctx.register?.name ?? '')),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SessionView extends StatelessWidget {
  const _SessionView({required this.ctx, required this.session, required this.onChanged});
  final CashContext ctx;
  final CashSession session;
  final VoidCallback onChanged;

  Future<void> _movement(BuildContext context, String kind) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => _MovementDialog(ctx: ctx, session: session, kind: kind),
    );
    if (ok == true) onChanged();
  }

  Future<void> _xReport(BuildContext context, SessionSummary sum, List<CashMovement> moves) async {
    final fileName = session.zNumber != null ? 'z-${session.zNumber}.pdf' : 'x-${hm(context, DateTime.now())}.pdf';
    try {
      final bytes = await zReportPdf(
        CashDocContext(
          t: context.t,
          locale: Localizations.localeOf(context).toString(),
          minorUnit: ctx.scope.minorUnit,
          branch: ctx.scope.branch,
          staff: ctx.staff,
        ),
        session,
        sum,
        register: ctx.registerName(session.registerId),
        movements: moves,
      );
      await printTicket(bytes, fileName);
    } catch (e) {
      if (context.mounted) showError(context, e);
    }
  }

  Future<void> _count(BuildContext context) async {
    final done = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => CountScreen(ctx: ctx, session: session),
      ),
    );
    if (done == true) onChanged();
  }

  Future<void> _validate(BuildContext context) async {
    final t = context.t;
    String? note;
    if ((session.differenceMinor ?? 0) != 0 && (session.countNote ?? '').length < 3) {
      note = await askReason(context, t.validateClosing, hint: t.differenceReasonHint);
      if (note == null) return;
    } else if (!await confirm(context, t.validateClosingConfirm, action: t.validate)) {
      return;
    }
    try {
      await ctx.cash.validate(session.id, note);
      if (context.mounted) showInfo(context, t.closingValidated);
      onChanged();
    } catch (e) {
      if (context.mounted) showError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    String m(int v) => ctx.scope.money(context, v);
    return Loader<(SessionSummary, List<CashMovement>, List<Payment>)>(
      load: () async {
        final r = await Future.wait<dynamic>([
          ctx.cash.summary(session.id),
          ctx.cash.movements(session.id),
          ctx.cash.sessionPayments(session.id),
        ]);
        return (r[0] as SessionSummary, r[1] as List<CashMovement>, r[2] as List<Payment>);
      },
      builder: (context, data, reload) {
        final (sum, moves, payments) = data;
        final counted = session.status == 'counted';
        final canClose = ctx.scope.can('cash.close');
        return RefreshIndicator(
          onRefresh: () async => reload(),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 40),
            children: [
              Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(color: counted ? StatusColors.toValidate : StatusColors.free, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${ctx.registerName(session.registerId)} · ${counted ? t.sessionAwaitingValidation : t.registerOpenSince(hm(context, session.openedAt))} · ${ctx.staffName(session.openedBy)}',
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                  IconButton(tooltip: t.refresh, onPressed: reload, icon: const Icon(Icons.refresh_rounded)),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  CashKpi(label: t.openingFloat, value: m(sum.openingFloat), icon: Icons.savings_rounded),
                  CashKpi(label: t.collectedTotal, value: m(sum.collected), icon: Icons.point_of_sale_rounded, color: StatusColors.free),
                  CashKpi(label: t.tipsTotal, value: m(sum.tips), icon: Icons.volunteer_activism_rounded, color: StatusColors.reserved),
                  CashKpi(
                    label: t.expectedCashLabel,
                    value: m(sum.expectedCash),
                    icon: Icons.payments_rounded,
                    color: RestoColors.primaryDeep,
                  ),
                  CashKpi(label: t.paymentsCountShort, value: '${sum.paymentsCount}', icon: Icons.receipt_long_rounded),
                ],
              ),
              if (counted) ...[
                const SizedBox(height: 14),
                Card(
                  color: StatusColors.toValidate.withValues(alpha: 0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(t.sessionAwaitingValidation, style: theme.textTheme.titleMedium),
                        const SizedBox(height: 8),
                        Text(
                          '${t.expectedCashLabel} : ${m(session.expectedCashMinor ?? 0)} · ${t.countedAmountLabel} : ${m(session.countedCashMinor ?? 0)}',
                        ),
                        Text(
                          '${t.differenceLabel} : ${m(session.differenceMinor ?? 0)}',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: (session.differenceMinor ?? 0) == 0 ? StatusColors.free : StatusColors.late,
                          ),
                        ),
                        if (session.countNote != null) Text('« ${session.countNote} »'),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 10,
                          children: [
                            if (canClose)
                              FilledButton.icon(
                                onPressed: () => _validate(context),
                                icon: const Icon(Icons.verified_rounded),
                                label: Text(t.validateClosing),
                              )
                            else
                              Text(t.managerMustValidate, style: theme.textTheme.bodySmall),
                            OutlinedButton.icon(
                              onPressed: () => _xReport(context, sum, moves),
                              icon: const Icon(Icons.print_rounded),
                              label: Text(t.printCountReport),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              LayoutBuilder(
                builder: (context, box) {
                  final wide = box.maxWidth >= 900;
                  final methods = Card(
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(t.salesByMethod, style: theme.textTheme.titleMedium),
                          const SizedBox(height: 8),
                          if (sum.byMethod.isEmpty) Text(t.noPaymentsYet, style: theme.textTheme.bodySmall),
                          for (final x in sum.byMethod)
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              dense: true,
                              leading: Icon(paymentKindIcon(x.kind), color: RestoColors.primaryDeep),
                              title: Text('${x.name} · ${x.count}'),
                              subtitle: x.tips > 0 ? Text('${t.tipLabel} : ${m(x.tips)}') : null,
                              trailing: Text(m(x.total), style: theme.textTheme.titleSmall),
                            ),
                          if (sum.refunds > 0)
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              dense: true,
                              leading: const Icon(Icons.undo_rounded, color: StatusColors.late),
                              title: Text(t.refundsLabel),
                              trailing: Text('− ${m(sum.refunds)}', style: theme.textTheme.titleSmall),
                            ),
                        ],
                      ),
                    ),
                  );
                  final movesCard = Card(
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(child: Text(t.cashMovementsTitle, style: theme.textTheme.titleMedium)),
                              if (session.isOpen) ...[
                                TextButton.icon(
                                  onPressed: () => _movement(context, 'in'),
                                  icon: const Icon(Icons.add_circle_outline),
                                  label: Text(t.cashIn),
                                ),
                                TextButton.icon(
                                  onPressed: () => _movement(context, 'out'),
                                  icon: const Icon(Icons.remove_circle_outline),
                                  label: Text(t.cashOut),
                                ),
                              ],
                            ],
                          ),
                          if (moves.isEmpty) Text(t.noMovements, style: theme.textTheme.bodySmall),
                          for (final mv in moves)
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              dense: true,
                              leading: Icon(
                                mv.kind == 'in' ? Icons.south_west_rounded : Icons.north_east_rounded,
                                color: mv.kind == 'in' ? StatusColors.free : StatusColors.late,
                              ),
                              title: Text(mv.reason),
                              subtitle: Text('${hm(context, mv.createdAt)} · ${ctx.staffName(mv.createdBy)}'),
                              trailing: Text('${mv.kind == 'in' ? '+' : '−'} ${m(mv.amountMinor)}', style: theme.textTheme.titleSmall),
                            ),
                        ],
                      ),
                    ),
                  );
                  return wide
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: methods),
                            const SizedBox(width: 12),
                            Expanded(child: movesCard),
                          ],
                        )
                      : Column(children: [methods, const SizedBox(height: 12), movesCard]);
                },
              ),
              const SizedBox(height: 12),
              Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(t.lastPayments, style: theme.textTheme.titleMedium),
                      const SizedBox(height: 6),
                      if (payments.isEmpty) Text(t.noPaymentsYet, style: theme.textTheme.bodySmall),
                      for (final p in payments.take(30))
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                          leading: Icon(paymentKindIcon(p.method), color: p.confirmed ? RestoColors.primaryDeep : StatusColors.done),
                          title: Text(
                            '${p.receiptNumber != null ? t.receiptNumberLabel(p.receiptNumber!) : t.orderNumber(p.orderNumber ?? 0)} · ${p.methodName}',
                            style: p.confirmed ? null : const TextStyle(decoration: TextDecoration.lineThrough),
                          ),
                          subtitle: Text(
                            [
                              hm(context, p.createdAt),
                              ctx.staffName(p.createdBy),
                              if (p.tipMinor > 0) '${t.tipLabel} ${m(p.tipMinor)}',
                              ?p.reference,
                            ].join(' · '),
                          ),
                          trailing: Text(m(p.amountMinor), style: theme.textTheme.titleSmall),
                        ),
                    ],
                  ),
                ),
              ),
              if (session.isOpen) ...[
                const SizedBox(height: 18),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => _xReport(context, sum, moves),
                      icon: const Icon(Icons.print_rounded),
                      label: Text(t.xReading),
                    ),
                    FilledButton.icon(onPressed: () => _count(context), icon: const Icon(Icons.lock_rounded), label: Text(t.closeRegister)),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _MovementDialog extends StatefulWidget {
  const _MovementDialog({required this.ctx, required this.session, required this.kind});
  final CashContext ctx;
  final CashSession session;
  final String kind;

  @override
  State<_MovementDialog> createState() => _MovementDialogState();
}

class _MovementDialogState extends State<_MovementDialog> {
  final _form = GlobalKey<FormState>();
  final _amount = TextEditingController();
  final _reason = TextEditingController();
  final _clientId = uuidV4();

  @override
  void dispose() {
    _amount.dispose();
    _reason.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    final ctx = widget.ctx;
    final amount = parseAmount(_amount.text, ctx.scope.currency, ctx.scope.minorUnit) ?? 0;
    try {
      await ctx.cash.movement(widget.session.id, widget.kind, amount, _reason.text.trim(), _clientId);
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final ctx = widget.ctx;
    final reasons = widget.kind == 'in'
        ? [t.reasonChangeFloat, t.reasonOtherIn]
        : [t.reasonSafeDrop, t.reasonSmallPurchase, t.reasonTipsPaid, t.reasonOtherOut];
    return AlertDialog(
      title: Text(widget.kind == 'in' ? t.cashIn : t.cashOut),
      content: SizedBox(
        width: 420,
        child: Form(
          key: _form,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AmountField(controller: _amount, label: t.amount, currency: ctx.scope.currency, minorUnit: ctx.scope.minorUnit, width: 240),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [for (final r in reasons) ActionChip(label: Text(r), onPressed: () => setState(() => _reason.text = r))],
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _reason,
                maxLength: 300,
                decoration: InputDecoration(labelText: t.reason),
                validator: (v) => (v ?? '').trim().length < 3 ? t.errorReasonRequired : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(t.cancel)),
        FilledButton(onPressed: _save, child: Text(t.save)),
      ],
    );
  }
}

/// Clôture : comptage à l'aveugle (l'attendu n'est montré qu'après), puis écart.
class CountScreen extends StatefulWidget {
  const CountScreen({super.key, required this.ctx, required this.session});
  final CashContext ctx;
  final CashSession session;

  @override
  State<CountScreen> createState() => _CountScreenState();
}

class _CountScreenState extends State<CountScreen> {
  final Map<int, int> _counts = {};
  late bool _detail = widget.ctx.denominations.isNotEmpty;
  final _amount = TextEditingController();
  final _note = TextEditingController();
  Map<String, dynamic>? _result;
  bool _busy = false;

  @override
  void dispose() {
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final ctx = widget.ctx;
    int total;
    if (_detail) {
      total = DenominationCounter.total(_counts);
    } else {
      try {
        total = parseAmount(_amount.text, ctx.scope.currency, ctx.scope.minorUnit) ?? 0;
      } on Object {
        return showInfo(context, context.t.errorInvalidAmount);
      }
    }
    if (!await confirm(context, context.t.countConfirm(ctx.scope.money(context, total)), action: context.t.confirm)) return;
    setState(() => _busy = true);
    try {
      final r = await ctx.cash.count(
        widget.session.id,
        total,
        _note.text.trim().isEmpty ? null : _note.text.trim(),
        detail: _detail ? _counts : null,
      );
      if (mounted) setState(() => _result = r);
    } catch (e) {
      if (mounted) showError(context, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    final ctx = widget.ctx;
    String m(int v) => ctx.scope.money(context, v);
    final r = _result;
    return Scaffold(
      appBar: AppBar(title: Text('${t.closeRegister} · ${ctx.registerName(widget.session.registerId)}')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          FormWidth(
            maxWidth: 820,
            child: r != null
                ? Column(
                    children: [
                      const SizedBox(height: 20),
                      Icon(
                        (r['difference'] as num) == 0 ? Icons.verified_rounded : Icons.error_outline_rounded,
                        size: 72,
                        color: (r['difference'] as num) == 0 ? StatusColors.free : StatusColors.late,
                      ),
                      const SizedBox(height: 12),
                      Text(t.countRecorded, style: theme.textTheme.headlineSmall),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        alignment: WrapAlignment.center,
                        children: [
                          CashKpi(label: t.expectedCashLabel, value: m((r['expected'] as num).toInt())),
                          CashKpi(label: t.countedAmountLabel, value: m((r['counted'] as num).toInt())),
                          CashKpi(
                            label: t.differenceLabel,
                            value: m((r['difference'] as num).toInt()),
                            color: (r['difference'] as num) == 0 ? StatusColors.free : StatusColors.late,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(ctx.scope.can('cash.close') ? t.validateNowHint : t.managerMustValidate, textAlign: TextAlign.center),
                      const SizedBox(height: 20),
                      FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(t.done)),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(t.blindCountHint, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                      const SizedBox(height: 14),
                      if (ctx.denominations.isNotEmpty)
                        SegmentedButton<bool>(
                          showSelectedIcon: false,
                          segments: [
                            ButtonSegment(
                              value: true,
                              icon: const Icon(Icons.grid_view_rounded, size: 18),
                              label: Text(t.countByDenomination),
                            ),
                            ButtonSegment(value: false, icon: const Icon(Icons.edit_rounded, size: 18), label: Text(t.enterAmount)),
                          ],
                          selected: {_detail},
                          onSelectionChanged: (s) => setState(() => _detail = s.first),
                        ),
                      const SizedBox(height: 12),
                      if (_detail)
                        DenominationCounter(denominations: ctx.denominations, counts: _counts, money: m, onChanged: () => setState(() {}))
                      else
                        Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: AmountField(
                            controller: _amount,
                            label: t.countedCash,
                            currency: ctx.scope.currency,
                            minorUnit: ctx.scope.minorUnit,
                            width: 260,
                          ),
                        ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: _note,
                        maxLength: 500,
                        decoration: InputDecoration(labelText: t.comment),
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        height: 54,
                        child: FilledButton.icon(
                          onPressed: _busy ? null : _submit,
                          icon: const Icon(Icons.lock_rounded),
                          label: Text(t.recordCount),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
