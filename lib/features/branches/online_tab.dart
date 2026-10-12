import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app_state.dart';
import '../../config/env.dart';
import '../../data/models.dart';
import '../../ui/common.dart';
import '../../ui/qr_view.dart';
import '../menus/menu_widgets.dart';

/// Adresse de la page publique d'un établissement (lien et QR code).
String branchPublicUrl(String branchId) => '${Env.siteUrl}/?r=$branchId';

/// Adresse ouverte par le QR code d'une table (commande sur place).
String tablePublicUrl(String token) => '${Env.siteUrl}/?t=$token';

/// Clients : vente en ligne, livraison, réservations et fiche publique.
class OnlineTab extends StatefulWidget {
  const OnlineTab({super.key, required this.membership, required this.branch, required this.canEdit});
  final Membership membership;
  final Branch branch;
  final bool canEdit;

  @override
  State<OnlineTab> createState() => _OnlineTabState();
}

class _OnlineTabState extends State<OnlineTab> with AutomaticKeepAliveClientMixin {
  final _form = GlobalKey<FormState>();
  late final Branch b = widget.branch;
  final _fee = TextEditingController();
  final _minimum = TextEditingController();
  final _minutes = TextEditingController();
  final _party = TextEditingController();
  final _target = TextEditingController();
  final _description = TextEditingController();
  final _cuisines = TextEditingController();
  int? _priceLevel;
  int _minorUnit = 2;
  late final Future<void> _loading = _load();

  bool get _canEditBrand => widget.canEdit && widget.membership.canOrg('org.manage');

  @override
  bool get wantKeepAlive => true;

  Future<void> _load() async {
    final state = AppScope.read(context);
    final refs = await state.references();
    _minorUnit = refs.currencies.where((c) => c.code == b.currency).firstOrNull?.minorUnit ?? 2;
    _fee.text = amountText(b.deliveryFeeMinor, b.currency, _minorUnit);
    _minimum.text = amountText(b.minOrderMinor, b.currency, _minorUnit);
    _minutes.text = '${b.reservationMinutes}';
    _party.text = '${b.maxPartySize}';
    _target.text = '${b.targetPrepMinutes}';
    final brand = await state.api!.brand(b.brandId);
    _description.text = (brand['description'] as String?) ?? '';
    _cuisines.text = ((brand['cuisines'] as List?) ?? const []).join(', ');
    _priceLevel = (brand['price_level'] as num?)?.toInt();
  }

  @override
  void dispose() {
    for (final c in [_fee, _minimum, _minutes, _party, _target, _description, _cuisines]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    final api = AppScope.read(context).api!;
    b.deliveryFeeMinor = parseAmount(_fee.text, b.currency, _minorUnit) ?? 0;
    b.minOrderMinor = parseAmount(_minimum.text, b.currency, _minorUnit) ?? 0;
    b.reservationMinutes = int.parse(_minutes.text.trim());
    b.maxPartySize = int.parse(_party.text.trim());
    b.targetPrepMinutes = int.parse(_target.text.trim());
    try {
      await api.saveBranch(b);
      if (_canEditBrand) {
        await api.saveBrandProfile(
          b.brandId,
          description: _description.text,
          cuisines: [
            for (final c in _cuisines.text.split(','))
              if (c.trim().isNotEmpty) c.trim(),
          ].take(10).toList(),
          priceLevel: _priceLevel,
        );
      }
      if (mounted) showInfo(context, context.t.saved);
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  String? _intIn(String? v, int min, int max) {
    final n = int.tryParse((v ?? '').trim());
    return (n == null || n < min || n > max) ? context.t.errorBetween(min, max) : null;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final t = context.t;
    final edit = widget.canEdit;
    final title = Theme.of(context).textTheme.titleMedium;
    return FutureBuilder<void>(
      future: _loading,
      builder: (context, snap) {
        if (snap.hasError) return Center(child: Text(t.errorUnknown));
        if (snap.connectionState != ConnectionState.done) return const Center(child: CircularProgressIndicator());
        final url = branchPublicUrl(b.id!);
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: FormWidth(
            child: Form(
              key: _form,
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                if (!b.isPublished)
                  Card(
                    color: Theme.of(context).colorScheme.secondaryContainer,
                    child: Padding(padding: const EdgeInsets.all(12), child: Text(t.notPublishedHint)),
                  ),
                Text(t.serviceSettingsTitle, style: title),
                const SizedBox(height: 8),
                SizedBox(
                  width: 260,
                  child: TextFormField(
                    controller: _target,
                    enabled: edit,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                        isDense: true, labelText: t.targetPrepTime, suffixText: t.minutesShort, helperText: t.targetPrepTimeHint),
                    validator: (v) => _intIn(v, 1, 240),
                  ),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(t.payFirstTakeaway),
                  subtitle: Text(t.payFirstTakeawayHint),
                  value: b.payFirstTakeaway,
                  onChanged: edit ? (v) => setState(() => b.payFirstTakeaway = v) : null,
                ),
                const SizedBox(height: 24),
                Text(t.onlineOrdersTitle, style: title),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(t.acceptOnlineOrders),
                  subtitle: Text(t.acceptOnlineOrdersHint),
                  value: b.acceptsOnlineOrders,
                  onChanged: edit ? (v) => setState(() => b.acceptsOnlineOrders = v) : null,
                ),
                if (b.acceptsOnlineOrders) ...[
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(t.acceptDelivery),
                    value: b.acceptsDelivery,
                    onChanged: edit ? (v) => setState(() => b.acceptsDelivery = v) : null,
                  ),
                  Wrap(spacing: 16, runSpacing: 12, children: [
                    if (b.acceptsDelivery)
                      AmountField(
                          controller: _fee, label: t.deliveryFee, currency: b.currency, minorUnit: _minorUnit, enabled: edit, width: 220),
                    AmountField(
                        controller: _minimum, label: t.minimumOrder, currency: b.currency, minorUnit: _minorUnit, enabled: edit, width: 220),
                  ]),
                ],
                const SizedBox(height: 24),
                Text(t.reservationsTitle, style: title),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(t.acceptReservations),
                  value: b.acceptsReservations,
                  onChanged: edit ? (v) => setState(() => b.acceptsReservations = v) : null,
                ),
                Wrap(spacing: 16, runSpacing: 12, children: [
                  SizedBox(
                    width: 220,
                    child: TextFormField(
                      controller: _minutes,
                      enabled: edit,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(isDense: true, labelText: t.reservationDuration, suffixText: t.minutesShort),
                      validator: (v) => _intIn(v, 15, 480),
                    ),
                  ),
                  SizedBox(
                    width: 220,
                    child: TextFormField(
                      controller: _party,
                      enabled: edit,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(isDense: true, labelText: t.maxPartySize),
                      validator: (v) => _intIn(v, 1, 200),
                    ),
                  ),
                ]),
                const SizedBox(height: 24),
                Text(t.publicProfileTitle, style: title),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _description,
                  enabled: _canEditBrand,
                  maxLength: 1000,
                  maxLines: 3,
                  decoration: InputDecoration(labelText: t.publicDescription, hintText: t.publicDescriptionHint),
                ),
                TextFormField(
                  controller: _cuisines,
                  enabled: _canEditBrand,
                  decoration: InputDecoration(labelText: t.cuisinesLabel, hintText: t.cuisinesHint),
                ),
                const SizedBox(height: 12),
                Text(t.priceLevel),
                const SizedBox(height: 6),
                Wrap(spacing: 8, children: [
                  for (var i = 1; i <= 4; i++)
                    ChoiceChip(
                      label: Text('€' * i),
                      selected: _priceLevel == i,
                      onSelected: _canEditBrand ? (on) => setState(() => _priceLevel = on ? i : null) : null,
                    ),
                ]),
                const SizedBox(height: 24),
                if (edit) BusyButton(label: t.save, onPressed: _save) else Text(t.readOnly),
                const SizedBox(height: 32),
                Text(t.publicPageTitle, style: title),
                const SizedBox(height: 8),
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  QrView(data: url, size: 140),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      SelectableText(url),
                      const SizedBox(height: 8),
                      Text(t.publicPageHint, style: Theme.of(context).textTheme.bodySmall),
                      TextButton.icon(
                        onPressed: () async {
                          await Clipboard.setData(ClipboardData(text: url));
                          if (context.mounted) showInfo(context, t.copied);
                        },
                        icon: const Icon(Icons.copy, size: 18),
                        label: Text(t.copyLink),
                      ),
                    ]),
                  ),
                ]),
              ]),
            ),
          ),
        );
      },
    );
  }
}
