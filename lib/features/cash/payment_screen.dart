import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

import '../../app_state.dart';
import '../../core/errors.dart';
import '../../core/money.dart';
import '../../data/cash_api.dart';
import '../../data/order_models.dart';
import '../../pdf/cash_pdf.dart';
import '../../pdf/ticket_branding.dart';
import '../../pdf/tickets.dart' show printTicket;
import '../../ui/branch_scope.dart';
import '../../ui/common.dart';
import '../../ui/files.dart';
import '../../ui/theme.dart';
import '../menus/menu_widgets.dart';
import 'cash_labels.dart';
import 'order_documents.dart' show invoiceFor, ticketBranding;

/// Caisse ouverte de l'établissement ; choix si plusieurs. null = aucune.
Future<CashSession?> pickOpenSession(BuildContext context, BranchContext scope) async {
  final t = context.t;
  final cash = AppScope.read(context).api!.cash;
  final sessions = await cash.openSessions(scope.branchId);
  if (!context.mounted) return null;
  if (sessions.isEmpty) {
    showInfo(context, t.openCashFirst);
    return null;
  }
  if (sessions.length == 1) return sessions.first;
  final registers = {for (final r in await cash.registers(scope.branchId)) r.id: r.name};
  if (!context.mounted) return null;
  return showDialog<CashSession>(
    context: context,
    builder: (c) => SimpleDialog(
      title: Text(t.chooseRegister),
      children: [
        for (final s in sessions) SimpleDialogOption(onPressed: () => Navigator.pop(c, s), child: Text(registers[s.registerId] ?? '—')),
      ],
    ),
  );
}

/// Encaissement plein écran : partage de la note, mode de paiement de
/// l'organisation, pourboire, clavier, monnaie, puis ticket.
class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key, required this.scope, required this.orderId, required this.session, required this.place});
  final BranchContext scope;
  final String orderId;
  final CashSession session;

  /// « VIP 1 », « À emporter »… (en-tête et ticket).
  final String place;

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

enum _Split { all, parts, items, custom }

enum _Field { amount, tendered, tip }

class _PaymentScreenState extends State<PaymentScreen> {
  late final CashApi _cash = AppScope.read(context).api!.cash;
  Order? _order;
  List<PaymentMethod> _methods = const [];
  List<Denomination> _denoms = const [];
  List<Payment> _payments = const [];
  Map<String, String> _staff = const {};
  Object? _error;

  PaymentMethod? _method;
  _Split _split = _Split.all;
  int _parts = 2;
  final Set<String> _items = {};
  String _amountText = '';
  String _tenderedText = '';
  String _tipText = '';
  int? _tipPercent;
  _Field _field = _Field.tendered;
  final _reference = TextEditingController();
  String _clientId = uuidV4();
  bool _busy = false;
  PaymentResult? _last;
  bool _done = false;

  BranchContext get scope => widget.scope;
  String get _currency => scope.currency;
  int get _unit => scope.minorUnit;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _reference.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final api = AppScope.read(context).api!;
      final r = await Future.wait<dynamic>([
        api.orders.order(widget.orderId),
        _cash.paymentMethods(scope.orgId),
        _cash.denominations(_currency),
        _cash.payments(widget.orderId),
        _cash.staff(scope.orgId),
      ]);
      if (!mounted) return;
      setState(() {
        _order = r[0] as Order;
        _methods = (r[1] as List<PaymentMethod>).where((m) => m.availableIn(scope.branchId)).toList();
        _denoms = r[2] as List<Denomination>;
        _payments = r[3] as List<Payment>;
        _staff = r[4] as Map<String, String>;
        _method ??= _methods.where((m) => m.isCash).firstOrNull ?? _methods.firstOrNull;
        _done = _order!.dueMinor <= 0 && _payments.any((p) => p.confirmed);
        _error = null;
      });
    } catch (e) {
      if (mounted) setState(() => _error = e);
    }
  }

  int? _parse(String s) {
    if (s.trim().isEmpty) return null;
    try {
      return parseAmount(s, _currency, _unit);
    } on Object {
      return null;
    }
  }

  String _m(int minor) => scope.money(context, minor);

  int get _due => _order?.dueMinor ?? 0;

  int get _amount {
    final o = _order;
    if (o == null) return 0;
    final due = _due;
    switch (_split) {
      case _Split.all:
        return due;
      case _Split.parts:
        return due <= 0 ? 0 : Money(due, _currency).allocate(List.filled(_parts, 1)).first.minor;
      case _Split.items:
        final itemsTotal = o.activeLines.fold<int>(0, (a, l) => a + l.lineTotalMinor);
        final selected = o.activeLines.where((l) => _items.contains(l.id)).fold<int>(0, (a, l) => a + l.lineTotalMinor);
        if (itemsTotal == 0 || selected == 0) return 0;
        return math.min(due, (selected * o.totalMinor / itemsTotal).round());
      case _Split.custom:
        return math.min(due, _parse(_amountText) ?? 0);
    }
  }

  int get _tip {
    if (!scope.branch.tipsEnabled) return 0;
    if (_tipPercent != null) return (_amount * _tipPercent! / 100).round();
    return _parse(_tipText) ?? 0;
  }

  int? get _tendered => _method?.isCash == true ? _parse(_tenderedText) : null;

  int get _change {
    final t = _tendered;
    if (t == null) return 0;
    return math.max(0, t - _amount - _tip);
  }

  /// Sommes rapides : le montant exact, puis les arrondis aux billets.
  List<int> get _quickTenders {
    final target = _amount + _tip;
    if (target <= 0) return const [];
    final values = <int>{target};
    for (final d in _denoms.where((d) => d.isNote).toList().reversed) {
      final v = ((target + d.valueMinor - 1) ~/ d.valueMinor) * d.valueMinor;
      if (v > target) values.add(v);
    }
    final list = values.toList()..sort();
    return list.take(5).toList();
  }

  void _key(String k) {
    String edit(String s) {
      if (k == '⌫') return s.isEmpty ? s : s.substring(0, s.length - 1);
      if (k == 'C') return '';
      if (k == ',' && (s.contains(',') || _unit == 0)) return s;
      return s + k;
    }

    setState(() {
      switch (_field) {
        case _Field.amount:
          _split = _Split.custom;
          _amountText = edit(_amountText);
        case _Field.tendered:
          _tenderedText = edit(_tenderedText);
        case _Field.tip:
          _tipPercent = null;
          _tipText = edit(_tipText);
      }
    });
  }

  Future<void> _pay() async {
    final t = context.t;
    final m = _method;
    final amount = _amount;
    if (m == null) return showInfo(context, t.choosePaymentMethod);
    if (amount <= 0) return showInfo(context, t.errorInvalidAmount);
    if (m.requiresReference && _reference.text.trim().length < 3) return showInfo(context, t.errorReferenceRequired);
    final tendered = _tendered;
    if (m.isCash && tendered != null && tendered < amount + _tip) return showInfo(context, t.errorTenderedTooLow);
    setState(() => _busy = true);
    final api = AppScope.read(context).api!;
    try {
      final result = await _cash.take(
        orderId: widget.orderId,
        sessionId: widget.session.id,
        methodId: m.id,
        amountMinor: amount,
        tipMinor: _tip,
        tenderedMinor: m.isCash ? tendered : null,
        reference: _reference.text.trim().isEmpty ? null : _reference.text.trim(),
        clientId: _clientId,
      );
      _clientId = uuidV4();
      _last = result;
      final order = await api.orders.order(widget.orderId);
      final payments = await _cash.payments(widget.orderId);
      if (!mounted) return;
      setState(() {
        _order = order;
        _payments = payments;
        _done = result.dueMinor <= 0;
        _split = _Split.all;
        _items.clear();
        _amountText = '';
        _tenderedText = '';
        _tipText = '';
        _tipPercent = null;
        _reference.clear();
      });
      if (!_done) showInfo(context, t.partialPaymentDone);
    } catch (e) {
      if (mounted) showError(context, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  CashDocContext _docContext(TicketBranding branding) => CashDocContext(
    t: context.t,
    locale: Localizations.localeOf(context).toString(),
    minorUnit: _unit,
    branch: scope.branch,
    staff: _staff,
    branding: branding,
  );

  Future<void> _printReceipt({bool share = false}) async {
    try {
      final branding = await ticketBranding(AppScope.read(context).api!, context.t, scope.branch, order: _order);
      if (!mounted) return;
      final bytes = await receiptPdf(_docContext(branding), _order!, _payments, place: widget.place);
      final name = 'ticket-${_order!.receiptNumberOrNull ?? _order!.number}.pdf';
      if (share) {
        await Printing.sharePdf(bytes: bytes, filename: name);
      } else {
        await printTicket(bytes, name, format: branding.pageFormat);
      }
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  void _whatsapp() {
    final o = _order!;
    final t = context.t;
    final phone = (o.contactPhone ?? '').replaceAll(RegExp(r'[^0-9]'), '');
    final text = [
      scope.branch.legalName?.isNotEmpty == true ? scope.branch.legalName! : scope.branch.name,
      if (o.receiptNumberOrNull != null) t.receiptNumberLabel(o.receiptNumberOrNull!),
      '${t.total} : ${_m(o.totalMinor)}',
      for (final p in _payments.where((p) => p.confirmed)) '${p.methodName} : ${_m(p.amountMinor)}',
      scope.branch.receiptFooter?.isNotEmpty == true ? scope.branch.receiptFooter! : t.thankYou,
    ].join('\n');
    openLink('https://wa.me/$phone?text=${Uri.encodeComponent(text)}');
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final o = _order;
    if (o == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: _error == null
              ? const CircularProgressIndicator()
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(errorText(t, _error!)),
                    const SizedBox(height: 12),
                    OutlinedButton(onPressed: _load, child: Text(t.retry)),
                  ],
                ),
        ),
      );
    }
    final wide = MediaQuery.sizeOf(context).width >= 1000;
    final summary = _Summary(order: o, payments: _payments, money: _m, place: widget.place);
    final body = _done ? _success(context, o) : _form(context, o);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.pop(context, _last)),
        title: Text('${t.collectPayment} · ${widget.place} · #${o.number}'),
      ),
      body: wide
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(width: 380, child: summary),
                const VerticalDivider(width: 1),
                Expanded(child: body),
              ],
            )
          : ListView(
              children: [
                ExpansionTile(
                  title: Text(t.orderDetails),
                  children: [SizedBox(height: 320, child: summary)],
                ),
                body,
              ],
            ),
    );
  }

  Widget _form(BuildContext context, Order o) {
    final t = context.t;
    final theme = Theme.of(context);
    final m = _method;
    final amount = _amount;
    final tip = _tip;
    final tendered = _tendered;
    final wide = MediaQuery.sizeOf(context).width >= 1000;

    Widget field(_Field f, String label, String value, {String? hint}) {
      final active = _field == f;
      return InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => setState(() => _field = f),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: active ? RestoColors.primary : theme.colorScheme.outlineVariant, width: active ? 2 : 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              Text(value.isEmpty ? (hint ?? '—') : value, style: theme.textTheme.headlineSmall),
            ],
          ),
        ),
      );
    }

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(gradient: RestoColors.brandGradient, borderRadius: BorderRadius.circular(20)),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(t.remainingDue, style: theme.textTheme.titleSmall?.copyWith(color: RestoColors.onPrimary.withValues(alpha: 0.8))),
                    Text(_m(_due), style: theme.textTheme.displaySmall?.copyWith(color: RestoColors.onPrimary)),
                  ],
                ),
              ),
              if (o.paidMinor > 0)
                Text('${t.paid} : ${_m(o.paidMinor)}', style: theme.textTheme.titleSmall?.copyWith(color: RestoColors.onPrimary)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SegmentedButton<_Split>(
          showSelectedIcon: false,
          segments: [
            ButtonSegment(value: _Split.all, label: Text(t.splitAll)),
            ButtonSegment(value: _Split.parts, label: Text(t.splitByParts)),
            ButtonSegment(value: _Split.items, label: Text(t.splitByItems)),
            ButtonSegment(value: _Split.custom, label: Text(t.splitCustom)),
          ],
          selected: {_split},
          onSelectionChanged: (s) => setState(() {
            _split = s.first;
            if (_split == _Split.custom) _field = _Field.amount;
          }),
        ),
        if (_split == _Split.parts)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Row(
              children: [
                Text(t.splitParts(_parts)),
                const Spacer(),
                IconButton.outlined(onPressed: _parts > 2 ? () => setState(() => _parts--) : null, icon: const Icon(Icons.remove)),
                const SizedBox(width: 8),
                IconButton.outlined(onPressed: _parts < 50 ? () => setState(() => _parts++) : null, icon: const Icon(Icons.add)),
              ],
            ),
          ),
        if (_split == _Split.items)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final l in o.activeLines)
                  FilterChip(
                    label: Text('${l.quantity} × ${l.title} · ${_m(l.lineTotalMinor)}'),
                    selected: _items.contains(l.id),
                    onSelected: (on) => setState(() => on ? _items.add(l.id) : _items.remove(l.id)),
                  ),
              ],
            ),
          ),
        const SizedBox(height: 14),
        Text(t.paymentMethodLabel, style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        if (_methods.isEmpty) Text(t.noPaymentMethod, style: TextStyle(color: theme.colorScheme.error)),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final pm in _methods)
              _MethodTile(
                method: pm,
                selected: pm.id == m?.id,
                onTap: () => setState(() {
                  _method = pm;
                  _field = pm.isCash ? _Field.tendered : (_split == _Split.custom ? _Field.amount : _Field.tip);
                }),
              ),
          ],
        ),
        const SizedBox(height: 14),
        if (scope.branch.tipsEnabled) ...[
          Text(t.tipLabel, style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ChoiceChip(
                label: Text(t.noTip),
                selected: _tipPercent == null && _tipText.isEmpty,
                onSelected: (_) => setState(() {
                  _tipPercent = null;
                  _tipText = '';
                }),
              ),
              for (final p in scope.branch.tipPresets)
                ChoiceChip(
                  label: Text('$p %'),
                  selected: _tipPercent == p,
                  onSelected: (_) => setState(() {
                    _tipPercent = p;
                    _tipText = '';
                  }),
                ),
              ChoiceChip(
                label: Text(_tipPercent == null && _tipText.isNotEmpty ? _m(tip) : t.otherAmount),
                selected: _tipPercent == null && _tipText.isNotEmpty,
                onSelected: (_) => setState(() {
                  _tipPercent = null;
                  _field = _Field.tip;
                }),
              ),
            ],
          ),
          const SizedBox(height: 14),
        ],
        Row(
          children: [
            Expanded(child: field(_Field.amount, t.amountToCollect, _m(amount))),
            const SizedBox(width: 10),
            if (m?.isCash == true)
              Expanded(child: field(_Field.tendered, t.cashTendered, tendered == null ? '' : _m(tendered), hint: t.exactAmount))
            else if (scope.branch.tipsEnabled)
              Expanded(child: field(_Field.tip, t.tipLabel, tip == 0 ? '' : _m(tip))),
          ],
        ),
        if (m?.isCash == true && _quickTenders.isNotEmpty) ...[
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final v in _quickTenders)
                ActionChip(
                  avatar: const Icon(Icons.payments_rounded, size: 16),
                  label: Text(_m(v)),
                  onPressed: () => setState(() => _tenderedText = amountText(v, _currency, _unit)),
                ),
            ],
          ),
        ],
        if (m != null && !m.isCash) ...[
          const SizedBox(height: 12),
          TextField(
            controller: _reference,
            maxLength: 120,
            decoration: InputDecoration(
              labelText: m.requiresReference ? t.transactionReferenceRequired : t.transactionReference,
              prefixIcon: const Icon(Icons.tag_rounded),
              counterText: '',
            ),
          ),
        ],
        if (_change > 0) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: StatusColors.free.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(16)),
            child: Row(
              children: [
                const Icon(Icons.currency_exchange_rounded, color: StatusColors.free),
                const SizedBox(width: 10),
                Expanded(child: Text(t.giveChange, style: theme.textTheme.titleMedium)),
                Text(_m(_change), style: theme.textTheme.headlineSmall?.copyWith(color: StatusColors.free)),
              ],
            ),
          ),
        ],
        const SizedBox(height: 14),
        _Keypad(onKey: _key, decimal: _unit > 0),
        const SizedBox(height: 14),
        SizedBox(
          height: 58,
          child: FilledButton.icon(
            onPressed: _busy || m == null || amount <= 0 ? null : _pay,
            icon: _busy
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : Icon(paymentKindIcon(m?.kind ?? 'cash')),
            label: Text(
              tip > 0 ? t.collectWithTip(_m(amount), _m(tip)) : t.collectAmount(_m(amount)),
              style: const TextStyle(fontSize: 17),
            ),
          ),
        ),
      ],
    );
    return wide
        ? SingleChildScrollView(
            padding: const EdgeInsets.all(22),
            child: FormWidth(maxWidth: 720, child: content),
          )
        : Padding(padding: const EdgeInsets.all(16), child: content);
  }

  Widget _success(BuildContext context, Order o) {
    final t = context.t;
    final theme = Theme.of(context);
    final last = _last;
    final cashPaid = _payments.where((p) => p.confirmed).lastOrNull;
    final change = last?.changeMinor ?? cashPaid?.changeMinor ?? 0;
    final tips = _payments.where((p) => p.confirmed).fold<int>(0, (a, p) => a + p.tipMinor);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: FormWidth(
          maxWidth: 520,
          child: Column(
            children: [
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  gradient: RestoColors.brandGradient,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: RestoColors.primary.withValues(alpha: 0.4), blurRadius: 30, offset: const Offset(0, 12))],
                ),
                child: const Icon(Icons.check_rounded, size: 64, color: RestoColors.onPrimary),
              ),
              const SizedBox(height: 22),
              Text(t.paymentComplete, style: theme.textTheme.headlineMedium, textAlign: TextAlign.center),
              const SizedBox(height: 6),
              Text(
                [
                  if (o.receiptNumberOrNull != null) t.receiptNumberLabel(o.receiptNumberOrNull!),
                  '${t.total} : ${_m(o.totalMinor)}',
                  if (tips > 0) '${t.tipLabel} : ${_m(tips)}',
                ].join(' · '),
                textAlign: TextAlign.center,
              ),
              if (change > 0) ...[
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(color: StatusColors.free.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
                  child: Column(
                    children: [
                      Text(t.giveChange, style: theme.textTheme.titleMedium),
                      Text(_m(change), style: theme.textTheme.displaySmall?.copyWith(color: StatusColors.free)),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: [
                  FilledButton.icon(onPressed: _printReceipt, icon: const Icon(Icons.print_rounded), label: Text(t.printReceipt)),
                  OutlinedButton.icon(
                    onPressed: () => _printReceipt(share: true),
                    icon: const Icon(Icons.ios_share_rounded),
                    label: Text(t.shareReceipt),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => invoiceFor(context, scope, o),
                    icon: const Icon(Icons.description_rounded),
                    label: Text(t.issueInvoice),
                  ),
                  if ((o.contactPhone ?? '').isNotEmpty)
                    OutlinedButton.icon(onPressed: _whatsapp, icon: const Icon(Icons.chat_rounded), label: Text(t.sendWhatsApp)),
                ],
              ),
              const SizedBox(height: 14),
              TextButton(onPressed: () => Navigator.pop(context, _last), child: Text(t.done)),
            ],
          ),
        ),
      ),
    );
  }
}

class _MethodTile extends StatelessWidget {
  const _MethodTile({required this.method, required this.selected, required this.onTap});
  final PaymentMethod method;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 128,
      height: 84,
      child: Material(
        color: selected ? RestoColors.primarySoft : theme.colorScheme.surfaceContainerLowest,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: selected ? RestoColors.primary : theme.colorScheme.outlineVariant, width: selected ? 2 : 1),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(paymentKindIcon(method.kind), color: selected ? RestoColors.primaryDeep : theme.colorScheme.onSurfaceVariant),
                const SizedBox(height: 6),
                Text(
                  method.name,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelLarge,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Keypad extends StatelessWidget {
  const _Keypad({required this.onKey, required this.decimal});
  final void Function(String) onKey;
  final bool decimal;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final keys = ['1', '2', '3', '4', '5', '6', '7', '8', '9', decimal ? ',' : '00', '0', '⌫'];
    return LayoutBuilder(
      builder: (context, c) {
        final w = (math.min(c.maxWidth, 420) - 20) / 3;
        return Center(
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final k in keys)
                SizedBox(
                  width: w,
                  height: 54,
                  child: Material(
                    color: theme.colorScheme.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(14),
                    elevation: 1,
                    shadowColor: RestoColors.shadowDark,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () => onKey(k),
                      onLongPress: k == '⌫' ? () => onKey('C') : null,
                      child: Center(
                        child: k == '⌫'
                            ? const Icon(Icons.backspace_outlined)
                            : Text(k, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

/// Récapitulatif de la commande et des paiements déjà faits.
class _Summary extends StatelessWidget {
  const _Summary({required this.order, required this.payments, required this.money, required this.place});
  final Order order;
  final List<Payment> payments;
  final String Function(int) money;
  final String place;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    final o = order;
    Widget row(String l, String r, {bool bold = false}) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(child: Text(l, style: bold ? theme.textTheme.titleMedium : null)),
          Text(r, style: bold ? theme.textTheme.titleMedium : null),
        ],
      ),
    );
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        Text(place, style: theme.textTheme.titleLarge),
        Text('${t.orderNumber(o.number)}${o.customerName == null ? '' : ' · ${o.customerName}'}', style: theme.textTheme.bodySmall),
        const SizedBox(height: 12),
        for (final l in o.activeLines) ...[
          row('${l.quantity} × ${l.title}', money(l.lineTotalMinor)),
          for (final opt in l.options) Text('   + ${opt.name}', style: theme.textTheme.bodySmall),
        ],
        const Divider(height: 24),
        for (final a in o.adjustments) row(a.label, '− ${money(a.appliedMinor)}'),
        if (o.deliveryFeeMinor > 0) row(t.deliveryFee, money(o.deliveryFeeMinor)),
        row(t.total, money(o.totalMinor), bold: true),
        if (payments.isNotEmpty) ...[
          const Divider(height: 24),
          for (final p in payments)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                children: [
                  Icon(paymentKindIcon(p.method), size: 16, color: theme.colorScheme.onSurfaceVariant),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      [p.methodName, if (p.tipMinor > 0) '${t.tipLabel} ${money(p.tipMinor)}', if (!p.confirmed) t.voided].join(' · '),
                      style: p.confirmed ? null : const TextStyle(decoration: TextDecoration.lineThrough),
                    ),
                  ),
                  Text(money(p.amountMinor)),
                ],
              ),
            ),
          row(t.remainingDue, money(o.dueMinor), bold: true),
        ],
      ],
    );
  }
}
