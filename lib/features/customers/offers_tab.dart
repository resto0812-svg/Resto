import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../app_state.dart';
import '../../core/money.dart';
import '../../data/loyalty_api.dart';
import '../../data/models.dart';
import '../../ui/branch_scope.dart';
import '../../ui/common.dart';
import '../../ui/kit.dart';
import '../../ui/theme.dart';
import '../menus/menu_widgets.dart' show amountText, parseAmount;

/// Offres du restaurant : remises, codes promo et coupons publics (visibles dans
/// l'application, que les clients enregistrent dans leur portefeuille).
class OffersTab extends StatelessWidget {
  const OffersTab({super.key, required this.membership});
  final Membership membership;

  @override
  Widget build(BuildContext context) => BranchScope(membership: membership, builder: (context, scope) => _Offers(scope: scope));
}

class _Offers extends StatefulWidget {
  const _Offers({required this.scope});
  final BranchContext scope;

  @override
  State<_Offers> createState() => _OffersState();
}

class _OffersState extends State<_Offers> {
  late Future<List<Promotion>> _data = _load();

  Future<List<Promotion>> _load() => AppScope.read(context).api!.loyalty.promotions(widget.scope.orgId);

  void _reload() => setState(() => _data = _load());

  Future<void> _edit([Promotion? p]) async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _OfferSheet(scope: widget.scope, initial: p),
    );
    if (saved == true) _reload();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final side = MediaQuery.sizeOf(context).width < 600 ? 16.0 : 22.0;
    final canEdit = widget.scope.membership.can('customers.manage');
    return FutureBuilder(
      future: _data,
      builder: (context, snap) {
        if (snap.hasError) return Center(child: TextButton(onPressed: _reload, child: Text(t.retry)));
        if (!snap.hasData) return const Center(child: CircularProgressIndicator());
        final list = snap.data!;
        final live = list.where((p) => p.usableNow).length;
        final public = list.where((p) => p.isPublic && p.usableNow).length;
        final uses = list.fold<int>(0, (a, p) => a + p.usesCount);
        return RefreshIndicator(
          onRefresh: () async => _reload(),
          child: ListView(padding: EdgeInsets.fromLTRB(side, 8, side, 40), children: [
            Wrap(spacing: 12, runSpacing: 10, crossAxisAlignment: WrapCrossAlignment.center, children: [
              CounterTile(icon: Icons.local_offer_outlined, value: '$live', label: t.activeOffers, highlight: true),
              CounterTile(icon: Icons.confirmation_number_outlined, value: '$public', label: t.publicCoupons),
              CounterTile(icon: Icons.shopping_bag_outlined, value: '$uses', label: t.totalUses),
              if (canEdit) GoldButton(label: t.newOffer, icon: Icons.add_rounded, expand: false, onPressed: () async => _edit()),
            ]),
            const SizedBox(height: 16),
            if (list.isEmpty)
              EmptyState(icon: Icons.local_offer_outlined, title: t.offersEmpty, message: t.offersEmptyHint)
            else
              LayoutBuilder(builder: (context, box) {
                final cols = (box.maxWidth / 360).floor().clamp(1, 4);
                final w = (box.maxWidth - (cols - 1) * 12) / cols;
                return Wrap(spacing: 12, runSpacing: 12, children: [
                  for (final p in list)
                    SizedBox(width: w, child: _OfferCard(promo: p, scope: widget.scope, onTap: canEdit ? () => _edit(p) : null)),
                ]);
              }),
          ]),
        );
      },
    );
  }
}

class _OfferCard extends StatelessWidget {
  const _OfferCard({required this.promo, required this.scope, this.onTap});
  final Promotion promo;
  final BranchContext scope;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final p = promo;
    final locale = Localizations.localeOf(context).toString();
    String money(int v) => Money(v, scope.currency).format(locale, scope.minorUnit);
    final value = p.kind == 'percent'
        ? '-${p.percent!.toStringAsFixed(p.percent! == p.percent!.roundToDouble() ? 0 : 1)} %'
        : '-${money(p.amountMinor ?? 0)}';
    final now = DateTime.now();
    final (status, color) = !p.active
        ? (t.offerStatusOff, RestoColors.muted)
        : (p.endsAt != null && !now.isBefore(p.endsAt!)) || (p.maxUses != null && p.usesCount >= p.maxUses!)
            ? (t.offerStatusEnded, StatusColors.done)
            : (p.startsAt != null && now.isBefore(p.startsAt!))
                ? (t.offerStatusScheduled, StatusColors.reserved)
                : (t.offerStatusActive, const Color(0xFF2E9E5B));
    final dates = [
      if (p.startsAt != null) DateFormat.yMMMd(locale).format(p.startsAt!.toLocal()),
      if (p.endsAt != null) DateFormat.yMMMd(locale).format(p.endsAt!.toLocal()),
    ].join(' → ');
    return SoftCard(
      padding: EdgeInsets.zero,
      onTap: onTap,
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [Color(0xFF2B2014), Color(0xFF5A4318)], begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Row(children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(value, style: serifTitle(context, size: 30, color: RestoColors.primaryBright)),
                Text(p.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
              ]),
            ),
            if (p.code != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(border: Border.all(color: RestoColors.primaryBright), borderRadius: BorderRadius.circular(10)),
                child: Text(p.code!, style: const TextStyle(color: RestoColors.primaryBright, fontWeight: FontWeight.w800, letterSpacing: 1)),
              ),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
          child: Wrap(spacing: 8, runSpacing: 6, crossAxisAlignment: WrapCrossAlignment.center, children: [
            StatusPill(label: status, color: color, dense: true),
            if (p.isPublic) StatusPill(label: t.publicCouponLabel, color: RestoColors.primaryDeep, icon: Icons.public_rounded, dense: true),
            Text(t.usesCount(p.usesCount), style: const TextStyle(color: RestoColors.muted, fontSize: 12.5)),
            if (p.minOrderMinor > 0) Text(t.fromAmount(money(p.minOrderMinor)), style: const TextStyle(color: RestoColors.muted, fontSize: 12.5)),
            if (dates.isNotEmpty) Text(dates, style: const TextStyle(color: RestoColors.muted, fontSize: 12.5)),
          ]),
        ),
      ]),
    );
  }
}

class _OfferSheet extends StatefulWidget {
  const _OfferSheet({required this.scope, this.initial});
  final BranchContext scope;
  final Promotion? initial;

  @override
  State<_OfferSheet> createState() => _OfferSheetState();
}

class _OfferSheetState extends State<_OfferSheet> {
  final _form = GlobalKey<FormState>();
  late final Promotion _p = widget.initial ??
      Promotion(organizationId: widget.scope.orgId);
  late final _name = TextEditingController(text: _p.name);
  late final _value = TextEditingController(
      text: _p.kind == 'percent'
          ? (_p.percent == null ? '' : _p.percent!.toStringAsFixed(_p.percent! == _p.percent!.roundToDouble() ? 0 : 1))
          : amountText(_p.amountMinor, widget.scope.currency, widget.scope.minorUnit));
  late final _code = TextEditingController(text: _p.code ?? '');
  late final _min = TextEditingController(text: _p.minOrderMinor == 0 ? '' : amountText(_p.minOrderMinor, widget.scope.currency, widget.scope.minorUnit));
  late final _maxUses = TextEditingController(text: _p.maxUses?.toString() ?? '');
  late final _perCustomer = TextEditingController(text: _p.perCustomerLimit?.toString() ?? '');
  late bool _allBranches = _p.branchId == null;

  bool get _isNew => _p.id == null;

  @override
  void dispose() {
    for (final c in [_name, _value, _code, _min, _maxUses, _perCustomer]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickDate(bool start) async {
    final current = start ? _p.startsAt : _p.endsAt;
    final d = await showDatePicker(
      context: context,
      initialDate: current ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );
    if (d == null) return;
    setState(() {
      if (start) {
        _p.startsAt = DateTime(d.year, d.month, d.day);
      } else {
        _p.endsAt = DateTime(d.year, d.month, d.day, 23, 59);
      }
    });
  }

  Future<void> _save() async {
    final t = context.t;
    if (!_form.currentState!.validate()) return;
    final code = _code.text.trim().toUpperCase();
    if (_p.isPublic && (_isNew ? code.isEmpty : _p.code == null)) {
      showInfo(context, t.publicCouponNeedsCode);
      return;
    }
    _p
      ..name = _name.text.trim()
      ..percent = _p.kind == 'percent' ? double.tryParse(_value.text.replaceAll(',', '.')) : null
      ..amountMinor = _p.kind == 'amount' ? parseAmount(_value.text, widget.scope.currency, widget.scope.minorUnit) : null
      ..minOrderMinor = parseAmount(_min.text, widget.scope.currency, widget.scope.minorUnit) ?? 0
      ..maxUses = int.tryParse(_maxUses.text.trim())
      ..perCustomerLimit = int.tryParse(_perCustomer.text.trim());
    if (_isNew) {
      _p
        ..code = code.isEmpty ? null : code
        ..branchId = _allBranches ? null : widget.scope.branchId;
    }
    try {
      await AppScope.read(context).api!.loyalty.savePromotion(_p);
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final locale = Localizations.localeOf(context).toString();
    String date(DateTime? d) => d == null ? t.noEndDate : DateFormat.yMMMd(locale).format(d.toLocal());
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, MediaQuery.viewInsetsOf(context).bottom + 20),
      child: Form(
        key: _form,
        child: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text(_isNew ? t.newOffer : t.editOffer, style: serifTitle(context, size: 24)),
            const SizedBox(height: 12),
            TextFormField(
              controller: _name,
              maxLength: 120,
              decoration: InputDecoration(labelText: t.offerName, hintText: t.offerNameExample, counterText: ''),
              validator: (v) => (v ?? '').trim().isEmpty ? t.fieldRequired : null,
            ),
            const SizedBox(height: 10),
            if (_isNew)
              PillBar<String>(
                dense: true,
                items: [PillItem('percent', t.discountPercent), PillItem('amount', t.discountAmount)],
                selected: _p.kind,
                onSelected: (v) => setState(() => _p.kind = v),
              ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _value,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(labelText: t.offerValue, suffixText: _p.kind == 'percent' ? '%' : widget.scope.currency),
              validator: (v) {
                if (_p.kind == 'percent') {
                  final n = double.tryParse((v ?? '').replaceAll(',', '.'));
                  return n == null || n <= 0 || n > 100 ? t.fieldRequired : null;
                }
                final n = parseAmount(v ?? '', widget.scope.currency, widget.scope.minorUnit);
                return n == null || n <= 0 ? t.fieldRequired : null;
              },
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _code,
              enabled: _isNew,
              maxLength: 30,
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(labelText: t.promoCodeLabel, hintText: t.offerCodeHint, counterText: ''),
              validator: (v) {
                final s = (v ?? '').trim().toUpperCase();
                return s.isEmpty || RegExp(r'^[A-Z0-9_-]{3,30}$').hasMatch(s) ? null : t.offerCodeHint;
              },
            ),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(
                child: TextFormField(
                  controller: _min,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(labelText: t.minOrderLabel, suffixText: widget.scope.currency),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextFormField(
                  controller: _maxUses,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: t.maxUsesLabel),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextFormField(
                  controller: _perCustomer,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: t.perCustomerLabel),
                ),
              ),
            ]),
            const SizedBox(height: 10),
            Wrap(spacing: 8, runSpacing: 8, children: [
              ActionChip(
                avatar: const Icon(Icons.play_arrow_rounded, size: 16),
                label: Text('${t.startsLabel} : ${_p.startsAt == null ? t.offerNow : date(_p.startsAt)}'),
                onPressed: () => _pickDate(true),
              ),
              ActionChip(
                avatar: const Icon(Icons.stop_rounded, size: 16),
                label: Text('${t.endsLabel} : ${date(_p.endsAt)}'),
                onPressed: () => _pickDate(false),
              ),
              if (_p.endsAt != null)
                ActionChip(label: Text(t.noEndDate), onPressed: () => setState(() => _p.endsAt = null)),
            ]),
            if (_isNew) ...[
              const SizedBox(height: 6),
              PillBar<bool>(
                dense: true,
                items: [PillItem(true, t.allBranchesLabel), PillItem(false, t.thisBranchOnly)],
                selected: _allBranches,
                onSelected: (v) => setState(() => _allBranches = v),
              ),
            ],
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(t.publicCouponLabel),
              subtitle: Text(t.publicCouponHint),
              value: _p.isPublic,
              onChanged: (v) => setState(() => _p.isPublic = v),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(t.offerActive),
              value: _p.active,
              onChanged: (v) => setState(() => _p.active = v),
            ),
            const SizedBox(height: 10),
            GoldButton(label: t.save, icon: Icons.check_rounded, onPressed: _save),
          ]),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Programme de fidélité

class LoyaltyTab extends StatelessWidget {
  const LoyaltyTab({super.key, required this.membership});
  final Membership membership;

  @override
  Widget build(BuildContext context) => BranchScope(membership: membership, builder: (context, scope) => _Loyalty(scope: scope));
}

class _Loyalty extends StatefulWidget {
  const _Loyalty({required this.scope});
  final BranchContext scope;

  @override
  State<_Loyalty> createState() => _LoyaltyState();
}

class _LoyaltyState extends State<_Loyalty> {
  late Future<(LoyaltyProgram, (int, int))> _data = _load();
  final _perPoint = TextEditingController();
  final _rewardPoints = TextEditingController();
  final _rewardValue = TextEditingController();
  final _birthday = TextEditingController();
  LoyaltyProgram? _program;

  Future<(LoyaltyProgram, (int, int))> _load() async {
    final api = AppScope.read(context).api!.loyalty;
    final r = await Future.wait<dynamic>([api.program(widget.scope.orgId), api.loyaltyMembers(widget.scope.orgId)]);
    final p = r[0] as LoyaltyProgram;
    _program = p;
    _perPoint.text = amountText(p.amountPerPointMinor, widget.scope.currency, widget.scope.minorUnit);
    _rewardPoints.text = '${p.rewardPoints}';
    _rewardValue.text = amountText(p.rewardMinor, widget.scope.currency, widget.scope.minorUnit);
    _birthday.text = '${p.birthdayPoints}';
    return (p, r[1] as (int, int));
  }

  @override
  void dispose() {
    for (final c in [_perPoint, _rewardPoints, _rewardValue, _birthday]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    final t = context.t;
    final p = _program!;
    final s = widget.scope;
    final perPoint = parseAmount(_perPoint.text, s.currency, s.minorUnit);
    final rewardPoints = int.tryParse(_rewardPoints.text.trim());
    final rewardValue = parseAmount(_rewardValue.text, s.currency, s.minorUnit);
    final birthday = int.tryParse(_birthday.text.trim()) ?? 0;
    if (perPoint == null || perPoint <= 0 || rewardPoints == null || rewardPoints <= 0 || rewardValue == null || rewardValue <= 0 || birthday < 0) {
      showInfo(context, t.fieldRequired);
      return;
    }
    p
      ..amountPerPointMinor = perPoint
      ..rewardPoints = rewardPoints
      ..rewardMinor = rewardValue
      ..birthdayPoints = birthday;
    try {
      await AppScope.read(context).api!.loyalty.saveProgram(s.orgId, p);
      if (!mounted) return;
      showInfo(context, t.saved);
      setState(() => _data = _load());
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final s = widget.scope;
    final locale = Localizations.localeOf(context).toString();
    String money(int v) => Money(v, s.currency).format(locale, s.minorUnit);
    final side = MediaQuery.sizeOf(context).width < 600 ? 16.0 : 22.0;
    final canEdit = s.membership.can('customers.manage');
    return FutureBuilder(
      future: _data,
      builder: (context, snap) {
        if (snap.hasError) return Center(child: TextButton(onPressed: () => setState(() => _data = _load()), child: Text(t.retry)));
        if (!snap.hasData) return const Center(child: CircularProgressIndicator());
        final (p, (members, points)) = snap.data!;
        final example = p.amountPerPointMinor * 10;
        return ListView(padding: EdgeInsets.fromLTRB(side, 8, side, 40), children: [
          Wrap(spacing: 12, runSpacing: 10, children: [
            CounterTile(icon: Icons.card_membership_rounded, value: '$members', label: t.loyaltyMembers, highlight: true),
            CounterTile(icon: Icons.stars_rounded, value: NumberFormat.decimalPattern(locale).format(points), label: t.pointsInCirculation),
          ]),
          const SizedBox(height: 16),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: GoldHeaderCard(
                title: t.loyaltyProgramTitle,
                titleIcon: Icons.workspace_premium_outlined,
                info: Text(t.loyaltyExample(money(example), 10)),
                action: canEdit ? GoldButton(label: t.save, icon: Icons.check_rounded, onPressed: _save) : null,
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(t.loyaltyActive),
                    value: p.active,
                    onChanged: canEdit ? (v) => setState(() => p.active = v) : null,
                  ),
                  const SizedBox(height: 6),
                  Row(children: [
                    Expanded(
                      child: TextField(
                        controller: _perPoint,
                        enabled: canEdit,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(labelText: t.amountPerPoint, suffixText: s.currency),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _rewardPoints,
                        enabled: canEdit,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(labelText: t.rewardPointsLabel),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _rewardValue,
                        enabled: canEdit,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(labelText: t.rewardValueLabel, suffixText: s.currency),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 16),
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const GoldIcon(Icons.cake_rounded, size: 44),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _birthday,
                        enabled: canEdit,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(labelText: t.birthdayPointsLabel, helperText: t.birthdayPointsHint, helperMaxLines: 3),
                      ),
                    ),
                  ]),
                ]),
              ),
            ),
          ),
        ]);
      },
    );
  }
}
