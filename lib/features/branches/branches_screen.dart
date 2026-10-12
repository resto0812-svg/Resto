import 'package:flutter/material.dart';

import '../../app_state.dart';
import '../../core/locales.dart';
import '../../data/models.dart';
import '../../ui/common.dart';
import 'online_tab.dart';
import 'hours_tab.dart';

class BranchesScreen extends StatefulWidget {
  const BranchesScreen({super.key, required this.membership});
  final Membership membership;

  @override
  State<BranchesScreen> createState() => _BranchesScreenState();
}

class _BranchesScreenState extends State<BranchesScreen> {
  Key _loaderKey = UniqueKey();

  void _refresh() => setState(() => _loaderKey = UniqueKey());

  Future<void> _create() async {
    final api = AppScope.read(context).api!;
    try {
      final brandId = await api.firstBrandId(widget.membership.organizationId);
      if (brandId == null || !mounted) return;
      final saved = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (_) => BranchDetailScreen(
            membership: widget.membership,
            branch: Branch(organizationId: widget.membership.organizationId, brandId: brandId),
          ),
        ),
      );
      if (saved == true) _refresh();
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final api = AppScope.of(context).api!;
    final m = widget.membership;
    return Scaffold(
      floatingActionButton: m.canOrg('org.manage')
          ? FloatingActionButton.extended(onPressed: _create, icon: const Icon(Icons.add), label: Text(t.newBranch))
          : null,
      body: Loader<List<Branch>>(
        key: _loaderKey,
        load: () => api.branches(m.organizationId),
        builder: (context, branches, reload) {
          if (branches.isEmpty) return Center(child: Text(t.noBranches));
          return RefreshIndicator(
            onRefresh: () async => reload(),
            child: ListView.separated(
              padding: const EdgeInsets.only(bottom: 88),
              itemCount: branches.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final b = branches[i];
                return ListTile(
                  leading: Icon(b.status == 'active' ? Icons.storefront : Icons.inventory_2_outlined),
                  title: Text(b.name),
                  subtitle: Text([b.city, b.currency, b.timezone, if (b.status != 'active') t.archived].join(' · ')),
                  trailing: b.isPublished ? Tooltip(message: t.published, child: const Icon(Icons.public)) : null,
                  onTap: () async {
                    await Navigator.push(
                        context, MaterialPageRoute(builder: (_) => BranchDetailScreen(membership: m, branch: b)));
                    _refresh();
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}

/// Établissement : informations, horaires, service et clients (les tables se
/// gèrent dans Commandes › Salle › « Modifier la salle »).
class BranchDetailScreen extends StatelessWidget {
  const BranchDetailScreen({super.key, required this.membership, required this.branch});
  final Membership membership;
  final Branch branch;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final canEdit = membership.can('branches.manage') &&
        (membership.allBranches || (branch.id != null && membership.branchIds.contains(branch.id)));
    final info = BranchInfoForm(membership: membership, branch: branch, canEdit: canEdit || branch.id == null);
    if (branch.id == null) {
      return Scaffold(appBar: AppBar(title: Text(t.newBranch)), body: info);
    }
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(branch.name),
          bottom: TabBar(tabs: [Tab(text: t.branchInfo), Tab(text: t.openingHours), Tab(text: t.serviceAndCustomers)]),
        ),
        body: TabBarView(children: [
          info,
          HoursTab(branchId: branch.id!, canEdit: canEdit),
          OnlineTab(membership: membership, branch: branch, canEdit: canEdit),
        ]),
      ),
    );
  }
}

class BranchInfoForm extends StatefulWidget {
  const BranchInfoForm({super.key, required this.membership, required this.branch, required this.canEdit});
  final Membership membership;
  final Branch branch;
  final bool canEdit;

  @override
  State<BranchInfoForm> createState() => _BranchInfoFormState();
}

class _BranchInfoFormState extends State<BranchInfoForm> with AutomaticKeepAliveClientMixin {
  final _form = GlobalKey<FormState>();
  late final Branch b = widget.branch;
  bool _tried = false;

  @override
  bool get wantKeepAlive => true;

  static String _formatRate(double r) => r == r.roundToDouble() ? r.toStringAsFixed(0) : '$r';

  /// « 19,25 » ou « 19.25 » → 19.25 ; vide → 0 ; 3 décimales au plus, de 0 à moins de 100.
  static double? _parseRate(String? v) {
    final s = (v ?? '').trim().replaceAll(',', '.');
    if (s.isEmpty) return 0;
    if (!RegExp(r'^\d{1,2}(\.\d{1,3})?$').hasMatch(s)) return null;
    return double.parse(s);
  }

  Future<void> _save() async {
    setState(() => _tried = true);
    if (!_form.currentState!.validate() || b.countryCode.isEmpty || b.currency.isEmpty || b.timezone.isEmpty) return;
    _form.currentState!.save();
    final isNew = b.id == null;
    try {
      await AppScope.read(context).api!.saveBranch(b);
      if (!mounted) return;
      showInfo(context, context.t.saved);
      if (isNew) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  Widget _text(String label, String? value, void Function(String?) onSaved,
      {bool required = false, int max = 120, TextInputType? keyboard}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: TextFormField(
        initialValue: value,
        enabled: widget.canEdit,
        decoration: InputDecoration(labelText: label, counterText: ''),
        maxLength: max,
        keyboardType: keyboard,
        validator: required ? (v) => (v == null || v.trim().isEmpty) ? context.t.fieldRequired : null : null,
        onSaved: onSaved,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final t = context.t;
    final state = AppScope.of(context);
    final req = t.fieldRequired;
    return Loader<References>(
      load: state.references,
      builder: (context, refs, _) => SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: FormWidth(
          child: Form(
            key: _form,
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              _text(t.name, b.name, (v) => b.name = v!.trim(), required: true),
              _text(t.addressLine1, b.addressLine1, (v) => b.addressLine1 = v, max: 200),
              _text(t.addressLine2, b.addressLine2, (v) => b.addressLine2 = v, max: 200),
              _text(t.city, b.city, (v) => b.city = v!.trim(), required: true),
              _text(t.region, b.region, (v) => b.region = v),
              _text(t.postalCode, b.postalCode, (v) => b.postalCode = v, max: 20),
              _text(t.phone, b.phone, (v) => b.phone = v, max: 32, keyboard: TextInputType.phone),
              _text(t.email, b.email, (v) => b.email = v, max: 254, keyboard: TextInputType.emailAddress),
              const SizedBox(height: 12),
              SearchSelect(
                label: t.country,
                value: b.countryCode.isEmpty ? null : b.countryCode,
                enabled: widget.canEdit,
                entries: [for (final c in refs.countries) (c.code, '${c.name} (${c.code})')],
                onChanged: (v) => setState(() => b.countryCode = v ?? ''),
                errorText: _tried && b.countryCode.isEmpty ? req : null,
              ),
              const SizedBox(height: 16),
              SearchSelect(
                label: t.currency,
                value: b.currency.isEmpty ? null : b.currency,
                enabled: widget.canEdit,
                entries: [for (final c in refs.currencies) (c.code, '${c.code} — ${c.name}')],
                onChanged: (v) => setState(() => b.currency = v ?? ''),
                errorText: _tried && b.currency.isEmpty ? req : null,
              ),
              const SizedBox(height: 16),
              SearchSelect(
                label: t.timezone,
                value: b.timezone.isEmpty ? null : b.timezone,
                enabled: widget.canEdit,
                entries: [for (final z in refs.timezones) (z, z)],
                onChanged: (v) => setState(() => b.timezone = v ?? ''),
                errorText: _tried && b.timezone.isEmpty ? req : null,
              ),
              const SizedBox(height: 16),
              SearchSelect(
                label: t.defaultLanguage,
                value: b.defaultLocale,
                enabled: widget.canEdit,
                entries: [for (final e in languageNames.entries) (e.key, e.value)],
                onChanged: (v) => setState(() => b.defaultLocale = v ?? b.defaultLocale),
              ),
              const SizedBox(height: 16),
              Text(t.offeredLanguages, style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              Wrap(spacing: 8, runSpacing: 8, children: [
                for (final e in languageNames.entries)
                  FilterChip(
                    label: Text(e.value),
                    selected: e.key == b.defaultLocale || b.languages.contains(e.key),
                    onSelected: !widget.canEdit || e.key == b.defaultLocale
                        ? null
                        : (on) => setState(() {
                              b.languages = on ? [...b.languages, e.key] : b.languages.where((l) => l != e.key).toList();
                            }),
                  ),
              ]),
              const SizedBox(height: 16),
              Text(t.taxTitle, style: Theme.of(context).textTheme.titleSmall),
              TextFormField(
                initialValue: _formatRate(b.taxRate),
                enabled: widget.canEdit,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(labelText: t.taxRate, suffixText: '%', hintText: t.taxRateHint),
                validator: (v) => _parseRate(v) == null ? t.errorInvalidTaxRate : null,
                onSaved: (v) => b.taxRate = _parseRate(v)!,
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(t.pricesIncludeTax),
                value: b.pricesIncludeTax,
                onChanged: widget.canEdit ? (v) => setState(() => b.pricesIncludeTax = v) : null,
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(t.published),
                value: b.isPublished,
                onChanged: widget.canEdit ? (v) => setState(() => b.isPublished = v) : null,
              ),
              if (b.id != null)
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(t.archived),
                  value: b.status == 'archived',
                  onChanged: widget.canEdit ? (v) => setState(() => b.status = v ? 'archived' : 'active') : null,
                ),
              const SizedBox(height: 16),
              if (widget.canEdit) BusyButton(label: t.save, onPressed: _save) else Text(t.readOnly),
            ]),
          ),
        ),
      ),
    );
  }
}
