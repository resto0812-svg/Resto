import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../app_state.dart';
import '../../core/locales.dart';
import '../../data/cash_api.dart';
import '../../data/models.dart';
import '../../data/supabase_setup.dart' show readTicketPrefs, writeTicketPrefs;
import '../../ui/common.dart';
import '../../ui/files.dart';
import '../../ui/image_compress.dart';
import '../../ui/theme.dart';
import 'cash_context.dart';
import 'cash_labels.dart';
import 'order_documents.dart' show printTestTicket;

/// Réglages de la caisse : modes de paiement (adaptés au pays, entièrement
/// paramétrables), caisses, mentions du ticket, pourboires.
class CashSettingsTab extends StatefulWidget {
  const CashSettingsTab({super.key, required this.ctx});
  final CashContext ctx;

  @override
  State<CashSettingsTab> createState() => _CashSettingsTabState();
}

class _CashSettingsTabState extends State<CashSettingsTab> {
  CashContext get ctx => widget.ctx;
  bool get _canMethods => ctx.scope.membership.canOrg('org.manage');
  bool get _canBranch => ctx.scope.can('branches.manage');

  Future<void> _addMethod() async {
    final added = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) => FractionallySizedBox(heightFactor: 0.88, child: _AddMethodSheet(ctx: ctx)),
    );
    if (added == true) await ctx.load();
  }

  Future<void> _editMethod(PaymentMethod pm) async {
    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => _MethodDialog(ctx: ctx, method: pm),
    );
    if (saved == true) await ctx.load();
  }

  Future<void> _editRegister([CashRegister? r]) async {
    final t = context.t;
    final name = TextEditingController(text: r?.name ?? '');
    var active = r?.active ?? true;
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => StatefulBuilder(
        builder: (c, setLocal) => AlertDialog(
          title: Text(r == null ? t.newRegister : r.name),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: name,
                autofocus: true,
                maxLength: 60,
                decoration: InputDecoration(labelText: t.name, hintText: t.registerNameHint),
              ),
              if (r != null)
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(t.active),
                  value: active,
                  onChanged: (v) => setLocal(() => active = v),
                ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(c), child: Text(t.cancel)),
            FilledButton(onPressed: () => Navigator.pop(c, true), child: Text(t.save)),
          ],
        ),
      ),
    );
    if (ok != true || name.text.trim().isEmpty) return;
    try {
      await ctx.cash.saveRegister(orgId: ctx.scope.orgId, branchId: ctx.scope.branchId, id: r?.id, name: name.text, active: active);
      await ctx.load();
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    return ListenableBuilder(
      listenable: ctx,
      builder: (context, _) => ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 40),
        children: [
          FormWidth(
            maxWidth: 900,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(child: Text(t.paymentMethodsTitle, style: theme.textTheme.titleLarge)),
                    if (_canMethods)
                      FilledButton.icon(onPressed: _addMethod, icon: const Icon(Icons.add_rounded), label: Text(t.addPaymentMethod)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(t.paymentMethodsHint, style: theme.textTheme.bodySmall),
                const SizedBox(height: 8),
                for (final pm in ctx.methods)
                  Card(
                    child: ListTile(
                      onTap: _canMethods ? () => _editMethod(pm) : null,
                      leading: CircleAvatar(
                        backgroundColor: RestoColors.primary.withValues(alpha: pm.active ? 0.18 : 0.06),
                        child: Icon(paymentKindIcon(pm.kind), color: pm.active ? RestoColors.primaryDeep : StatusColors.done),
                      ),
                      title: Text(pm.name, style: pm.active ? null : const TextStyle(decoration: TextDecoration.lineThrough)),
                      subtitle: Text(
                        [
                          paymentKindLabel(t, pm.kind),
                          if (pm.requiresReference) t.referenceRequiredShort,
                          if (pm.feePercent > 0)
                            t.feeShort(pm.feePercent.toStringAsFixed(pm.feePercent == pm.feePercent.roundToDouble() ? 0 : 2)),
                          if (pm.branchIds.isNotEmpty) t.someBranchesOnly(pm.branchIds.length),
                        ].join(' · '),
                      ),
                      trailing: Switch(
                        value: pm.active,
                        onChanged: _canMethods
                            ? (v) async {
                                try {
                                  await ctx.cash.updatePaymentMethod(
                                    pm.id,
                                    name: pm.name,
                                    requiresReference: pm.requiresReference,
                                    feePercent: pm.feePercent,
                                    branchIds: pm.branchIds,
                                    active: v,
                                    sortOrder: pm.sortOrder,
                                  );
                                  await ctx.load();
                                } catch (e) {
                                  if (context.mounted) showError(context, e);
                                }
                              }
                            : null,
                      ),
                    ),
                  ),
                const SizedBox(height: 26),
                Row(
                  children: [
                    Expanded(child: Text(t.registersTitle, style: theme.textTheme.titleLarge)),
                    if (_canBranch)
                      OutlinedButton.icon(
                        onPressed: () => _editRegister(),
                        icon: const Icon(Icons.add_rounded),
                        label: Text(t.newRegister),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                for (final r in ctx.registers)
                  Card(
                    child: ListTile(
                      leading: Icon(Icons.point_of_sale_rounded, color: r.active ? RestoColors.primaryDeep : StatusColors.done),
                      title: Text(r.name),
                      subtitle: Text(r.active ? t.active : t.inactive),
                      trailing: _canBranch ? IconButton(onPressed: () => _editRegister(r), icon: const Icon(Icons.edit_outlined)) : null,
                    ),
                  ),
                const SizedBox(height: 26),
                _ReceiptSettings(ctx: ctx, canEdit: _canBranch),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReceiptSettings extends StatefulWidget {
  const _ReceiptSettings({required this.ctx, required this.canEdit});
  final CashContext ctx;
  final bool canEdit;

  @override
  State<_ReceiptSettings> createState() => _ReceiptSettingsState();
}

class _ReceiptSettingsState extends State<_ReceiptSettings> {
  late final Branch b = widget.ctx.scope.branch;
  late final _legal = TextEditingController(text: b.legalName ?? '');
  late final _tax = TextEditingController(text: b.taxIdentifier ?? '');
  late final _footer = TextEditingController(text: b.receiptFooter ?? '');
  late final _presets = TextEditingController(text: b.tipPresets.join(', '));
  late final _invoicePrefix = TextEditingController(text: b.invoicePrefix);
  late final _invoiceFooter = TextEditingController(text: b.invoiceFooter ?? '');
  late bool _tips = b.tipsEnabled;
  late bool _qr = b.receiptQr;
  late final _qrUrl = TextEditingController(text: b.receiptQrUrl ?? '');
  late final _title = TextEditingController(text: b.receiptTitle ?? '');
  late final _subtitle = TextEditingController(text: b.receiptSubtitle ?? '');
  late final _slogan = TextEditingController(text: b.receiptSlogan ?? '');
  late final _address = TextEditingController(text: b.addressLine1 ?? '');
  late final _postal = TextEditingController(text: b.postalCode ?? '');
  late final _city = TextEditingController(text: b.city);
  late final _phone = TextEditingController(text: b.phone ?? '');
  late final _website = TextEditingController(text: b.website ?? '');
  late final _qrTitle = TextEditingController(text: b.receiptQrTitle ?? '');
  late final _qrCaption = TextEditingController(text: b.receiptQrCaption ?? '');
  late final _farewell = TextEditingController(text: b.receiptFarewell ?? '');

  @override
  void dispose() {
    for (final c in [
      _legal,
      _tax,
      _footer,
      _presets,
      _invoicePrefix,
      _invoiceFooter,
      _qrUrl,
      _title,
      _subtitle,
      _slogan,
      _address,
      _postal,
      _city,
      _phone,
      _website,
      _qrTitle,
      _qrCaption,
      _farewell,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    final t = context.t;
    final presets = [
      for (final s in _presets.text.split(RegExp(r'[,; ]+')))
        if (int.tryParse(s.trim()) != null) int.parse(s.trim()),
    ].where((p) => p > 0 && p <= 50).take(6).toList();
    final qrUrl = _qrUrl.text.trim();
    if (qrUrl.isNotEmpty && !RegExp(r'^https?://\S+$').hasMatch(qrUrl)) {
      showInfo(context, t.receiptQrUrlInvalid);
      return;
    }
    b.receiptQr = _qr;
    b.receiptQrUrl = qrUrl;
    b.legalName = _legal.text;
    b.taxIdentifier = _tax.text;
    b.receiptFooter = _footer.text;
    b.receiptTitle = _title.text;
    b.receiptSubtitle = _subtitle.text;
    b.receiptSlogan = _slogan.text;
    b.addressLine1 = _address.text.trim().isEmpty ? null : _address.text.trim();
    b.postalCode = _postal.text.trim().isEmpty ? null : _postal.text.trim();
    if (_city.text.trim().isNotEmpty) b.city = _city.text.trim();
    b.phone = _phone.text.trim().isEmpty ? null : _phone.text.trim();
    b.website = _website.text;
    b.receiptQrTitle = _qrTitle.text;
    b.receiptQrCaption = _qrCaption.text;
    b.receiptFarewell = _farewell.text;
    b.tipsEnabled = _tips;
    b.tipPresets = presets;
    b.invoicePrefix = _invoicePrefix.text.trim();
    b.invoiceFooter = _invoiceFooter.text;
    try {
      await AppScope.read(context).api!.saveBranch(b);
      if (mounted) showInfo(context, t.saved);
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    final edit = widget.canEdit;
    // Textes propres au ticket : enregistrables une fois la migration 027 appliquée.
    Widget field(
      TextEditingController c,
      String label,
      int max, {
      String? hint,
      bool texts = false,
      int lines = 1,
      TextInputType? keyboard,
    }) => Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: TextField(
        controller: c,
        enabled: edit && (!texts || b.hasTicketTexts),
        maxLength: max,
        maxLines: lines,
        minLines: 1,
        keyboardType: keyboard,
        decoration: InputDecoration(labelText: label, hintText: hint),
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(t.receiptSettingsTitle, style: theme.textTheme.titleLarge),
        const SizedBox(height: 4),
        Text(t.receiptSettingsHint, style: theme.textTheme.bodySmall),
        const SizedBox(height: 12),
        TextField(
          controller: _legal,
          enabled: edit,
          maxLength: 160,
          decoration: InputDecoration(labelText: t.legalNameLabel),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _tax,
          enabled: edit,
          maxLength: 60,
          decoration: InputDecoration(labelText: t.taxIdLabel, hintText: t.taxIdHint),
        ),
        const SizedBox(height: 6),
        _BrandLogoField(ctx: widget.ctx),
        const SizedBox(height: 14),
        Text(t.receiptHeaderSection, style: theme.textTheme.titleMedium),
        const SizedBox(height: 10),
        field(_title, t.receiptTitleLabel, 80, hint: t.receiptTitleHint, texts: true),
        field(_subtitle, t.receiptSubtitleLabel, 80, hint: t.receiptSubtitleHint, texts: true),
        field(_slogan, t.receiptSloganLabel, 160, hint: t.receiptSloganHint, texts: true),
        field(_address, t.addressLine1, 200),
        Row(
          children: [
            SizedBox(width: 130, child: field(_postal, t.postalCode, 20)),
            const SizedBox(width: 10),
            Expanded(child: field(_city, t.city, 120)),
          ],
        ),
        field(_phone, t.phone, 30, keyboard: TextInputType.phone),
        field(_website, t.websiteLabel, 200, hint: t.websiteHint, texts: true, keyboard: TextInputType.url),
        const SizedBox(height: 6),
        Text(t.receiptFooterSection, style: theme.textTheme.titleMedium),
        const SizedBox(height: 6),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(t.receiptQrLabel),
          value: _qr,
          onChanged: edit ? (v) => setState(() => _qr = v) : null,
        ),
        if (_qr)
          TextField(
            controller: _qrUrl,
            enabled: edit,
            maxLength: 300,
            keyboardType: TextInputType.url,
            decoration: InputDecoration(labelText: t.receiptQrUrlLabel, hintText: t.receiptQrUrlHint),
          ),
        if (_qr) ...[
          field(_qrTitle, t.receiptQrTitleLabel, 80, hint: t.receiptLoyaltyTitle, texts: true),
          field(_qrCaption, t.receiptQrCaptionLabel, 200, hint: t.receiptLoyaltyCaption, texts: true, lines: 2),
        ],
        field(_footer, t.receiptFooterLabel, 300, hint: t.receiptFooterHint, lines: 2),
        field(_farewell, t.receiptFarewellLabel, 160, hint: t.receiptFarewellHint, texts: true),
        const SizedBox(height: 10),
        _PrinterSettings(ctx: widget.ctx),
        const SizedBox(height: 16),
        Text(t.invoiceSettingsTitle, style: theme.textTheme.titleLarge),
        const SizedBox(height: 8),
        TextField(
          controller: _invoicePrefix,
          enabled: edit,
          maxLength: 20,
          decoration: InputDecoration(labelText: t.invoicePrefixLabel, hintText: t.invoicePrefixHint),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _invoiceFooter,
          enabled: edit,
          maxLength: 600,
          maxLines: 3,
          decoration: InputDecoration(labelText: t.invoiceFooterLabel, hintText: t.invoiceFooterHint),
        ),
        const SizedBox(height: 16),
        Text(t.tipsTitle, style: theme.textTheme.titleLarge),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(t.tipsEnabledLabel),
          subtitle: Text(t.tipsEnabledHint),
          value: _tips,
          onChanged: edit ? (v) => setState(() => _tips = v) : null,
        ),
        if (_tips)
          TextField(
            controller: _presets,
            enabled: edit,
            decoration: InputDecoration(labelText: t.tipPresetsLabel, hintText: '5, 10, 15', suffixText: '%'),
          ),
        const SizedBox(height: 16),
        if (edit)
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: BusyButton(label: t.save, onPressed: _save),
          ),
      ],
    );
  }
}

/// Imprimante de tickets de cet appareil (rouleau 80 ou 58 mm, photos des
/// plats) et ticket d'essai. Réglage local, ouvert à toute l'équipe.
class _PrinterSettings extends StatefulWidget {
  const _PrinterSettings({required this.ctx});
  final CashContext ctx;

  @override
  State<_PrinterSettings> createState() => _PrinterSettingsState();
}

class _PrinterSettingsState extends State<_PrinterSettings> {
  int _paper = 80;
  bool _photos = true;

  @override
  void initState() {
    super.initState();
    readTicketPrefs().then((p) {
      if (mounted) {
        setState(() {
          _paper = p.$1;
          _photos = p.$2;
        });
      }
    });
  }

  void _set(int paper, bool photos) {
    setState(() {
      _paper = paper;
      _photos = photos;
    });
    writeTicketPrefs(paper, photos);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
      decoration: BoxDecoration(
        color: RestoColors.primarySoft.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: RestoColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.print_rounded, color: RestoColors.primaryDeep, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(t.receiptPaperLabel, style: const TextStyle(fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SegmentedButton<int>(
            segments: [
              ButtonSegment(value: 80, label: Text(t.receiptPaper80)),
              ButtonSegment(value: 58, label: Text(t.receiptPaper58)),
            ],
            selected: {_paper},
            onSelectionChanged: (v) => _set(v.first, _photos),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(t.receiptPhotosLabel),
            value: _photos,
            onChanged: (v) => _set(_paper, v),
          ),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: OutlinedButton.icon(
              onPressed: () => printTestTicket(context, widget.ctx.api, widget.ctx.scope),
              icon: const Icon(Icons.receipt_long_rounded, size: 18),
              label: Text(t.receiptTestPrint),
            ),
          ),
        ],
      ),
    );
  }
}

/// Logo du restaurant (marque) : imprimé en filigrane sur les tickets. Modifiable par un responsable.
class _BrandLogoField extends StatefulWidget {
  const _BrandLogoField({required this.ctx});
  final CashContext ctx;

  @override
  State<_BrandLogoField> createState() => _BrandLogoFieldState();
}

class _BrandLogoFieldState extends State<_BrandLogoField> {
  Uint8List? _bytes;
  bool _busy = true;

  String get _brandId => widget.ctx.scope.branch.brandId;
  bool get _canEdit => widget.ctx.scope.membership.canOrg('org.manage');

  @override
  void initState() {
    super.initState();
    widget.ctx.api.brandLogo(_brandId).then((b) {
      if (mounted) {
        setState(() {
          _bytes = b;
          _busy = false;
        });
      }
    });
  }

  Future<void> _pick() async {
    final t = context.t;
    final original = await pickImage();
    if (original == null || !mounted) return;
    final f = await compressPhoto(original, maxSide: 800);
    if (!mounted) return;
    if (f.bytes.length > maxLogoBytes) {
      showInfo(context, t.logoTooBig);
      return;
    }
    setState(() => _busy = true);
    try {
      await widget.ctx.api.uploadBrandLogo(widget.ctx.scope.orgId, _brandId, f.bytes, f.extension);
      if (mounted) setState(() => _bytes = f.bytes);
    } catch (e) {
      if (mounted) showError(context, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _remove() async {
    setState(() => _busy = true);
    try {
      await widget.ctx.api.removeBrandLogo(_brandId);
      if (mounted) setState(() => _bytes = null);
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
    return Row(
      children: [
        Container(
          width: 84,
          height: 84,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: RestoColors.line),
          ),
          child: _busy
              ? const Center(child: SizedBox.square(dimension: 22, child: CircularProgressIndicator(strokeWidth: 2)))
              : _bytes == null
              ? const Icon(Icons.storefront_outlined, size: 34, color: RestoColors.muted)
              : Image.memory(_bytes!, fit: BoxFit.contain),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(t.restaurantLogo, style: theme.textTheme.titleSmall),
              const SizedBox(height: 2),
              Text(t.restaurantLogoHint, style: theme.textTheme.bodySmall),
              if (_canEdit) ...[
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    OutlinedButton.icon(
                      onPressed: _busy ? null : _pick,
                      icon: const Icon(Icons.upload_outlined, size: 18),
                      label: Text(_bytes == null ? t.chooseLogo : t.replaceLogo),
                    ),
                    if (_bytes != null) TextButton(onPressed: _busy ? null : _remove, child: Text(t.removeLogo)),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _MethodDialog extends StatefulWidget {
  const _MethodDialog({required this.ctx, required this.method});
  final CashContext ctx;
  final PaymentMethod method;

  @override
  State<_MethodDialog> createState() => _MethodDialogState();
}

class _MethodDialogState extends State<_MethodDialog> {
  late final pm = widget.method;
  late final _name = TextEditingController(text: pm.name);
  late final _fee = TextEditingController(text: pm.feePercent == 0 ? '' : '${pm.feePercent}');
  late final _order = TextEditingController(text: '${pm.sortOrder}');
  late bool _ref = pm.requiresReference;
  late bool _active = pm.active;
  late final Set<String> _branches = {...pm.branchIds};

  @override
  void dispose() {
    for (final c in [_name, _fee, _order]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (_name.text.trim().isEmpty) return;
    final fee = double.tryParse(_fee.text.trim().replaceAll(',', '.')) ?? 0;
    try {
      await widget.ctx.cash.updatePaymentMethod(
        pm.id,
        name: _name.text,
        requiresReference: _ref,
        feePercent: fee.clamp(0, 100).toDouble(),
        branchIds: _branches.toList(),
        active: _active,
        sortOrder: int.tryParse(_order.text.trim()) ?? pm.sortOrder,
      );
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return AlertDialog(
      title: Row(
        children: [
          Icon(paymentKindIcon(pm.kind)),
          const SizedBox(width: 10),
          Expanded(child: Text(pm.name)),
        ],
      ),
      content: SizedBox(
        width: 460,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _name,
                maxLength: 60,
                decoration: InputDecoration(labelText: t.name),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(t.requireReferenceLabel),
                subtitle: Text(t.requireReferenceHint),
                value: _ref,
                onChanged: (v) => setState(() => _ref = v),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _fee,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(labelText: t.feePercentLabel, suffixText: '%', hintText: '0'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 120,
                    child: TextField(
                      controller: _order,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: t.displayOrder),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(t.availableInBranches),
              const SizedBox(height: 6),
              Loader<List<Branch>>(
                load: () => AppScope.read(context).api!.branches(widget.ctx.scope.orgId),
                builder: (context, branches, _) => Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ChoiceChip(label: Text(t.allBranches), selected: _branches.isEmpty, onSelected: (_) => setState(_branches.clear)),
                    for (final b in branches.where((b) => b.status == 'active'))
                      FilterChip(
                        label: Text(b.name),
                        selected: _branches.contains(b.id),
                        onSelected: (on) => setState(() => on ? _branches.add(b.id!) : _branches.remove(b.id)),
                      ),
                  ],
                ),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(t.active),
                value: _active,
                onChanged: (v) => setState(() => _active = v),
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

/// Ajout d'un mode : courants dans le pays, valables partout, tout le
/// catalogue mondial (recherche), ou mode personnalisé.
class _AddMethodSheet extends StatefulWidget {
  const _AddMethodSheet({required this.ctx});
  final CashContext ctx;

  @override
  State<_AddMethodSheet> createState() => _AddMethodSheetState();
}

class _AddMethodSheetState extends State<_AddMethodSheet> {
  String _query = '';
  final _custom = TextEditingController();
  String _kind = 'other';
  bool _ref = false;

  @override
  void dispose() {
    _custom.dispose();
    super.dispose();
  }

  Future<void> _add({String? refCode, required String name, required String kind, required bool requiresReference}) async {
    try {
      await widget.ctx.cash.addPaymentMethod(
        orgId: widget.ctx.scope.orgId,
        refCode: refCode,
        name: name,
        kind: kind,
        requiresReference: requiresReference,
        sortOrder: 50 + widget.ctx.methods.length,
      );
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    final ctx = widget.ctx;
    final locale = refLocaleCode(Localizations.localeOf(context));
    final country = ctx.scope.branch.countryCode;
    final have = {for (final m in ctx.methods) m.refCode, for (final m in ctx.methods) m.name.toLowerCase()};
    return Loader<List<RefPaymentMethod>>(
      load: ctx.cash.catalog,
      builder: (context, catalog, _) {
        final available = catalog.where((r) => !have.contains(r.code) && !have.contains(r.label(locale).toLowerCase())).toList();
        final q = _query.trim().toLowerCase();
        final local = available.where((r) => r.commonIn(country)).toList();
        final world = available.where((r) => r.worldwide()).toList();
        final others = available
            .where((r) => !r.commonIn(country) && !r.worldwide())
            .where((r) => q.isEmpty || r.label(locale).toLowerCase().contains(q) || r.countries.any((c) => c.toLowerCase() == q))
            .toList();
        Widget tile(RefPaymentMethod r) => ListTile(
          leading: Icon(paymentKindIcon(r.kind), color: RestoColors.primaryDeep),
          title: Text(r.label(locale)),
          subtitle: Text([paymentKindLabel(t, r.kind), if (r.countries.isNotEmpty) r.countries.join(', ')].join(' · ')),
          trailing: const Icon(Icons.add_circle_outline_rounded),
          onTap: () => _add(refCode: r.code, name: r.label(locale), kind: r.kind, requiresReference: r.requiresReference),
        );
        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          children: [
            Text(t.addPaymentMethod, style: theme.textTheme.headlineSmall),
            const SizedBox(height: 14),
            if (local.isNotEmpty) ...[
              Text(t.commonInCountry(country), style: theme.textTheme.titleMedium),
              for (final r in local) tile(r),
              const SizedBox(height: 10),
            ],
            if (world.isNotEmpty) ...[
              Text(t.availableWorldwide, style: theme.textTheme.titleMedium),
              for (final r in world) tile(r),
              const SizedBox(height: 10),
            ],
            Text(t.otherCountries, style: theme.textTheme.titleMedium),
            const SizedBox(height: 6),
            TextField(
              decoration: InputDecoration(isDense: true, prefixIcon: const Icon(Icons.search_rounded), hintText: t.searchMethodOrCountry),
              onChanged: (v) => setState(() => _query = v),
            ),
            for (final r in others.take(q.isEmpty ? 8 : 40)) tile(r),
            const SizedBox(height: 18),
            Text(t.customMethod, style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            TextField(
              controller: _custom,
              maxLength: 60,
              decoration: InputDecoration(labelText: t.name, hintText: t.customMethodHint),
            ),
            DropdownButtonFormField<String>(
              initialValue: _kind,
              decoration: InputDecoration(labelText: t.methodKind),
              items: [for (final k in paymentKinds) DropdownMenuItem(value: k, child: Text(paymentKindLabel(t, k)))],
              onChanged: (v) => setState(() => _kind = v ?? _kind),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(t.requireReferenceLabel),
              value: _ref,
              onChanged: (v) => setState(() => _ref = v),
            ),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: FilledButton(
                onPressed: () {
                  if (_custom.text.trim().isEmpty) return;
                  _add(name: _custom.text.trim(), kind: _kind, requiresReference: _ref);
                },
                child: Text(t.addPaymentMethod),
              ),
            ),
          ],
        );
      },
    );
  }
}
