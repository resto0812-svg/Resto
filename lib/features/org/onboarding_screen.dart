import 'package:flutter/material.dart';

import '../../app_state.dart';
import '../../core/locales.dart';
import '../../data/models.dart';
import '../../ui/common.dart';

/// Premier écran d'un compte sans organisation : créer son restaurant ou
/// rejoindre une équipe avec un code d'invitation.
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(t.welcomeTitle),
          actions: [
            TextButton.icon(
              onPressed: () => AppScope.read(context).setCustomerMode(true),
              icon: const Icon(Icons.storefront_rounded, size: 18),
              label: Text(t.customerSpaceLink),
            ),
            const LanguageMenuButton(),
            IconButton(
              tooltip: t.signOut,
              icon: const Icon(Icons.logout),
              onPressed: () => AppScope.read(context).api!.signOut(),
            ),
          ],
          bottom: TabBar(tabs: [Tab(text: t.createRestaurant), Tab(text: t.joinTeam)]),
        ),
        body: const TabBarView(children: [CreateOrganizationForm(), JoinTeamForm()]),
      ),
    );
  }
}

class CreateOrganizationForm extends StatefulWidget {
  const CreateOrganizationForm({super.key});

  @override
  State<CreateOrganizationForm> createState() => _CreateOrganizationFormState();
}

class _CreateOrganizationFormState extends State<CreateOrganizationForm> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _brand = TextEditingController();
  final _city = TextEditingController();
  final _branch = TextEditingController();
  String? _country;
  String? _currency;
  String? _timezone;
  String? _locale;
  bool _tried = false;

  @override
  void dispose() {
    for (final c in [_name, _brand, _city, _branch]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _tried = true);
    final formOk = _form.currentState!.validate();
    if (!formOk || _country == null || _currency == null || _timezone == null) return;
    final state = AppScope.read(context);
    try {
      await state.api!.createOrganization(
        name: _name.text.trim(),
        country: _country!,
        currency: _currency!,
        locale: _locale ?? refLocaleCode(Localizations.localeOf(context)),
        timezone: _timezone!,
        city: _city.text.trim(),
        brandName: _brand.text.trim().isEmpty ? null : _brand.text.trim(),
        branchName: _branch.text.trim().isEmpty ? null : _branch.text.trim(),
      );
      await state.refreshMemberships();
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final state = AppScope.of(context);
    final required = t.fieldRequired;
    return Loader<References>(
      load: state.references,
      builder: (context, refs, _) => SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: FormWidth(
          child: Form(
            key: _form,
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              TextFormField(
                controller: _name,
                decoration: InputDecoration(labelText: t.organizationName),
                maxLength: 120,
                validator: (v) => (v == null || v.trim().length < 2) ? required : null,
              ),
              TextFormField(
                controller: _brand,
                decoration: InputDecoration(labelText: t.brandNameOptional),
                maxLength: 120,
              ),
              SearchSelect(
                label: t.country,
                value: _country,
                entries: [for (final c in refs.countries) (c.code, '${c.name} (${c.code})')],
                onChanged: (v) => setState(() => _country = v),
                errorText: _tried && _country == null ? required : null,
              ),
              const SizedBox(height: 16),
              SearchSelect(
                label: t.currency,
                value: _currency,
                entries: [for (final c in refs.currencies) (c.code, '${c.code} — ${c.name}')],
                onChanged: (v) => setState(() => _currency = v),
                errorText: _tried && _currency == null ? required : null,
              ),
              const SizedBox(height: 16),
              SearchSelect(
                label: t.timezone,
                value: _timezone,
                entries: [for (final z in refs.timezones) (z, z)],
                onChanged: (v) => setState(() => _timezone = v),
                errorText: _tried && _timezone == null ? required : null,
              ),
              const SizedBox(height: 16),
              SearchSelect(
                label: t.defaultLanguage,
                value: _locale ?? refLocaleCode(Localizations.localeOf(context)),
                entries: [for (final e in languageNames.entries) (e.key, e.value)],
                onChanged: (v) => setState(() => _locale = v),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _city,
                decoration: InputDecoration(labelText: t.city),
                maxLength: 120,
                validator: (v) => (v == null || v.trim().isEmpty) ? required : null,
              ),
              TextFormField(
                controller: _branch,
                decoration: InputDecoration(labelText: t.branchNameOptional),
                maxLength: 120,
              ),
              const SizedBox(height: 16),
              BusyButton(label: t.create, onPressed: _submit),
            ]),
          ),
        ),
      ),
    );
  }
}

class JoinTeamForm extends StatefulWidget {
  const JoinTeamForm({super.key, this.onJoined});
  final VoidCallback? onJoined;

  @override
  State<JoinTeamForm> createState() => _JoinTeamFormState();
}

class _JoinTeamFormState extends State<JoinTeamForm> {
  final _code = TextEditingController();

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  Future<void> _join() async {
    final code = _code.text.trim();
    if (code.isEmpty) return;
    final state = AppScope.read(context);
    try {
      final orgId = await state.api!.acceptInvitation(code);
      await state.refreshMemberships();
      state.selectOrganization(orgId);
      widget.onJoined?.call();
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: FormWidth(
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          TextField(
            controller: _code,
            decoration: InputDecoration(labelText: t.invitationCode),
            onSubmitted: (_) => _join(),
          ),
          const SizedBox(height: 16),
          BusyButton(label: t.join, onPressed: _join),
        ]),
      ),
    );
  }
}
