import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show SignOutScope;

import '../../app_state.dart';
import '../../data/models.dart';
import '../../data/prefs_api.dart';
import '../../ui/branch_scope.dart';
import '../../ui/brand_logo.dart';
import '../../ui/common.dart';
import '../../ui/files.dart';
import '../../ui/image_compress.dart';
import '../../ui/kit.dart';
import '../../ui/location.dart';
import '../../ui/qr_view.dart';
import '../../ui/theme.dart';
import '../auth/auth_screens.dart';
import '../branches/hours_tab.dart';
import '../branches/online_tab.dart' show branchPublicUrl;
import '../cash/cash_context.dart';
import '../cash/cash_settings_tab.dart';
import '../menus/menu_widgets.dart';
import '../team/team_screen.dart';

enum _Page { profile, contact, hours, delivery, payments, team, notifications, security }

/// Paramètres : navigation à gauche (Profil, Contact & localisation,
/// Horaires, Livraison & commandes, Paiement & facturation, Équipe & rôles,
/// Notifications, Sécurité), formulaire à droite ; sur téléphone, la liste
/// puis la page choisie.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, required this.membership});
  final Membership membership;

  @override
  Widget build(BuildContext context) =>
      BranchScope(membership: membership, builder: (context, scope) => _Settings(scope: scope));
}

class _Settings extends StatefulWidget {
  const _Settings({required this.scope});
  final BranchContext scope;

  @override
  State<_Settings> createState() => _SettingsState();
}

class _SettingsState extends State<_Settings> {
  _Page _page = _Page.profile;
  bool _open = false; // téléphone : page affichée

  BranchContext get scope => widget.scope;

  List<_Page> get _pages => [
        _Page.profile,
        _Page.contact,
        _Page.hours,
        _Page.delivery,
        if (scope.can('cash.operate') || scope.membership.canOrg('org.manage')) _Page.payments,
        if (scope.membership.canOrg('members.manage')) _Page.team,
        _Page.notifications,
        _Page.security,
      ];

  (IconData, String, String) _meta(_Page p) {
    final t = context.t;
    return switch (p) {
      _Page.profile => (Icons.storefront_rounded, t.settingsProfile, t.settingsProfileHint),
      _Page.contact => (Icons.location_on_outlined, t.settingsContact, t.settingsContactHint),
      _Page.hours => (Icons.schedule_rounded, t.settingsHours, t.settingsHoursHint),
      _Page.delivery => (Icons.delivery_dining_outlined, t.settingsDelivery, t.settingsDeliveryHint),
      _Page.payments => (Icons.credit_card_rounded, t.settingsPayments, t.settingsPaymentsHint),
      _Page.team => (Icons.groups_outlined, t.settingsTeam, t.settingsTeamHint),
      _Page.notifications => (Icons.notifications_none_rounded, t.settingsNotifications, t.settingsNotificationsHint),
      _Page.security => (Icons.shield_outlined, t.settingsSecurity, t.settingsSecurityHint),
    };
  }

  Widget _content(_Page p) => switch (p) {
        _Page.profile => _ProfilePage(key: ValueKey('p${scope.branchId}'), scope: scope),
        _Page.contact => _ContactPage(key: ValueKey('c${scope.branchId}'), scope: scope),
        _Page.hours => _HoursPage(key: ValueKey('h${scope.branchId}'), scope: scope),
        _Page.delivery => _DeliveryPage(key: ValueKey('d${scope.branchId}'), scope: scope),
        _Page.payments => _PaymentsPage(key: ValueKey('pay${scope.branchId}'), scope: scope),
        _Page.team => TeamScreen(membership: scope.membership),
        _Page.notifications => _NotificationsPage(scope: scope),
        _Page.security => const _SecurityPage(),
      };

  Widget _nav({required bool wide}) {
    final t = context.t;
    return Container(
      width: wide ? 270 : null,
      margin: EdgeInsets.fromLTRB(wide ? 22 : 16, 10, wide ? 8 : 16, 22),
      padding: const EdgeInsets.fromLTRB(14, 18, 14, 18),
      decoration: BoxDecoration(
        color: const Color(0xFFF3EADB),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: RestoColors.line),
      ),
      child: ListView(shrinkWrap: !wide, children: [
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: RestoColors.primarySoft, borderRadius: BorderRadius.circular(8)),
            child: Text(t.navSettings.toUpperCase(),
                style: const TextStyle(color: RestoColors.primaryDeep, fontWeight: FontWeight.w700, fontSize: 11.5, letterSpacing: 1)),
          ),
        ),
        const SizedBox(height: 12),
        for (final p in _pages) _NavItem(
          icon: _meta(p).$1,
          label: _meta(p).$2,
          selected: wide && p == _page,
          onTap: () => setState(() {
            _page = p;
            _open = true;
          }),
        ),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 900;
    final pages = _pages;
    if (!pages.contains(_page)) _page = pages.first;
    final (_, title, hint) = _meta(_page);
    final page = Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Padding(
        padding: EdgeInsets.fromLTRB(wide ? 18 : 16, 10, 22, 4),
        child: Row(children: [
          if (!wide)
            IconButton(onPressed: () => setState(() => _open = false), icon: const Icon(Icons.arrow_back_rounded)),
          Expanded(child: ScreenTitle(title: title, subtitle: hint)),
        ]),
      ),
      Expanded(child: _content(_page)),
    ]);
    if (wide) return Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [_nav(wide: true), Expanded(child: page)]);
    return _open ? page : SingleChildScrollView(child: _nav(wide: false));
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({required this.icon, required this.label, required this.selected, required this.onTap});
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Ink(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            decoration: BoxDecoration(
              gradient: selected ? RestoColors.brandGradient : null,
              borderRadius: BorderRadius.circular(16),
              boxShadow: selected ? [BoxShadow(color: RestoColors.primary.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 5))] : null,
            ),
            child: Row(children: [
              Icon(icon, size: 22, color: selected ? Colors.white : RestoColors.primaryDeep),
              const SizedBox(width: 14),
              Expanded(
                child: Text(label,
                    style: TextStyle(
                        color: selected ? Colors.white : RestoColors.ink, fontWeight: selected ? FontWeight.w700 : FontWeight.w500, fontSize: 14.5)),
              ),
              Icon(Icons.chevron_right_rounded, size: 18, color: selected ? Colors.white : RestoColors.muted),
            ]),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Briques communes des pages

/// Page de formulaire : défilement, largeur lisible, bouton d'enregistrement en bas.
class _FormPage extends StatelessWidget {
  const _FormPage({required this.children, this.onSave});
  final List<Widget> children;
  final Future<void> Function()? onSave;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return ListView(padding: const EdgeInsets.fromLTRB(16, 8, 22, 40), children: [
      Align(
        alignment: AlignmentDirectional.topStart,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 980),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            ...children,
            if (onSave != null) ...[
              const SizedBox(height: 22),
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: GoldButton(label: t.saveChanges, icon: Icons.check_rounded, expand: false, onPressed: onSave),
              ),
            ],
          ]),
        ),
      ),
    ]);
  }
}

/// Deux colonnes sur grand écran, une sur téléphone.
class _Columns extends StatelessWidget {
  const _Columns({required this.left, required this.right});
  final List<Widget> left;
  final List<Widget> right;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, box) {
      if (box.maxWidth < 700) return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [...left, ...right]);
      return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: left)),
        const SizedBox(width: 20),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: right)),
      ]);
    });
  }
}

/// Champ avec libellé au-dessus (style des maquettes).
class _Field extends StatelessWidget {
  const _Field({
    required this.label,
    required this.controller,
    this.hint,
    this.enabled = true,
    this.maxLength,
    this.maxLines = 1,
    this.keyboard,
    this.icon,
    this.validator,
    this.suffix,
  });
  final String label;
  final TextEditingController controller;
  final String? hint;
  final bool enabled;
  final int? maxLength;
  final int maxLines;
  final TextInputType? keyboard;
  final IconData? icon;
  final String? Function(String?)? validator;
  final String? suffix;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5, color: RestoColors.ink)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          enabled: enabled,
          maxLength: maxLength,
          maxLines: maxLines,
          minLines: 1,
          keyboardType: keyboard,
          validator: validator,
          decoration: InputDecoration(
            isDense: true,
            counterText: '',
            hintText: hint,
            prefixIcon: icon == null ? null : Icon(icon, size: 19, color: RestoColors.primaryDeep),
            suffixText: suffix,
            fillColor: Colors.white,
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: RestoColors.line)),
            disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: RestoColors.line)),
          ),
        ),
      ]),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({required this.title, this.subtitle, required this.value, required this.onChanged});
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: SoftCard(
        padding: const EdgeInsets.fromLTRB(16, 10, 10, 10),
        child: Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
              if (subtitle != null) Text(subtitle!, style: const TextStyle(color: RestoColors.muted, fontSize: 12.5)),
            ]),
          ),
          Switch(value: value, onChanged: onChanged, activeTrackColor: RestoColors.primary),
        ]),
      ),
    );
  }
}

Future<void> _saveBranch(BuildContext context, Branch b) async {
  try {
    await AppScope.read(context).api!.saveBranch(b);
    if (context.mounted) showInfo(context, context.t.saved);
  } catch (e) {
    if (context.mounted) showError(context, e);
  }
}

// ---------------------------------------------------------------------------
// Profil de l'établissement

class _ProfilePage extends StatefulWidget {
  const _ProfilePage({super.key, required this.scope});
  final BranchContext scope;

  @override
  State<_ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<_ProfilePage> {
  final _form = GlobalKey<FormState>();
  late final Branch b = widget.scope.branch;
  final _name = TextEditingController();
  final _slogan = TextEditingController();
  final _description = TextEditingController();
  final _cuisine = TextEditingController();
  late final _registration = TextEditingController(text: b.registrationNumber ?? '');
  late final _legal = TextEditingController(text: b.legalName ?? '');
  late final _tax = TextEditingController(text: b.taxIdentifier ?? '');
  List<String> _cuisines = [];
  int? _priceLevel;
  late final Future<void> _loading = _load();

  bool get _canBrand => widget.scope.membership.canOrg('org.manage');
  bool get _canBranch => widget.scope.can('branches.manage');

  Future<void> _load() async {
    final brand = await AppScope.read(context).api!.brand(b.brandId);
    _name.text = brand['name'] as String? ?? '';
    _slogan.text = brand['slogan'] as String? ?? '';
    _description.text = brand['description'] as String? ?? '';
    _cuisines = [for (final c in (brand['cuisines'] as List? ?? const [])) c as String];
    _priceLevel = (brand['price_level'] as num?)?.toInt();
  }

  @override
  void dispose() {
    for (final c in [_name, _slogan, _description, _cuisine, _registration, _legal, _tax]) {
      c.dispose();
    }
    super.dispose();
  }

  void _addCuisine() {
    final v = _cuisine.text.trim();
    if (v.isEmpty || _cuisines.contains(v) || _cuisines.length >= 10) return;
    setState(() {
      _cuisines = [..._cuisines, v];
      _cuisine.clear();
    });
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    final api = AppScope.read(context).api!;
    try {
      if (_canBrand) {
        await api.saveBrandIdentity(b.brandId,
            name: _name.text, slogan: _slogan.text, description: _description.text, cuisines: _cuisines, priceLevel: _priceLevel);
      }
      if (_canBranch) {
        b.registrationNumber = _registration.text;
        b.legalName = _legal.text;
        b.taxIdentifier = _tax.text;
        await api.saveBranch(b);
      }
      if (mounted) showInfo(context, context.t.saved);
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return FutureBuilder<void>(
      future: _loading,
      builder: (context, snap) {
        if (snap.hasError) return Center(child: Text(t.errorUnknown));
        if (snap.connectionState != ConnectionState.done) return const Center(child: CircularProgressIndicator());
        return Form(
          key: _form,
          child: _FormPage(
            onSave: (_canBrand || _canBranch) ? _save : null,
            children: [
              SectionHeading(title: t.restaurantLogo, icon: Icons.workspace_premium_outlined),
              const SizedBox(height: 10),
              LogoDropZone(orgId: widget.scope.orgId, brandId: b.brandId, canEdit: _canBrand),
              const SizedBox(height: 22),
              SectionHeading(title: t.coverPhoto, icon: Icons.landscape_outlined, subtitle: t.coverPhotoHint),
              const SizedBox(height: 10),
              CoverPhotoZone(orgId: widget.scope.orgId, branch: b, canEdit: _canBranch),
              const SizedBox(height: 22),
              _Columns(
                left: [
                  _Field(
                    label: t.restaurantName,
                    controller: _name,
                    enabled: _canBrand,
                    maxLength: 120,
                    validator: (v) => (v == null || v.trim().isEmpty) ? t.fieldRequired : null,
                  ),
                  _Field(label: t.sloganLabel, controller: _slogan, hint: t.sloganHint, enabled: _canBrand, maxLength: 160),
                  _Field(
                      label: t.publicDescription,
                      controller: _description,
                      hint: t.publicDescriptionHint,
                      enabled: _canBrand,
                      maxLength: 1000,
                      maxLines: 4),
                ],
                right: [
                  Text(t.cuisinesLabel, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5)),
                  const SizedBox(height: 6),
                  Wrap(spacing: 8, runSpacing: 8, children: [
                    for (final c in _cuisines)
                      InputChip(
                        label: Text(c),
                        onDeleted: _canBrand ? () => setState(() => _cuisines = [..._cuisines]..remove(c)) : null,
                      ),
                  ]),
                  if (_canBrand) ...[
                    const SizedBox(height: 6),
                    TextField(
                      controller: _cuisine,
                      onSubmitted: (_) => _addCuisine(),
                      decoration: InputDecoration(
                        isDense: true,
                        hintText: t.cuisinesHint,
                        fillColor: Colors.white,
                        suffixIcon: IconButton(onPressed: _addCuisine, icon: const Icon(Icons.add_rounded)),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Text(t.priceLevel, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5)),
                  const SizedBox(height: 6),
                  PillBar<int?>(
                    dense: true,
                    items: [for (var i = 1; i <= 4; i++) PillItem<int?>(i, '\$' * i)],
                    selected: _priceLevel,
                    onSelected: _canBrand ? (v) => setState(() => _priceLevel = v == _priceLevel ? null : v) : (_) {},
                  ),
                  const SizedBox(height: 16),
                  _Field(
                      label: t.registrationNumber,
                      controller: _registration,
                      hint: t.registrationNumberHint,
                      enabled: _canBranch,
                      maxLength: 60),
                  _Field(label: t.legalNameLabel, controller: _legal, enabled: _canBranch, maxLength: 160),
                  _Field(label: t.taxIdLabel, controller: _tax, hint: t.taxIdHint, enabled: _canBranch, maxLength: 60),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Photo d'ambiance de l'établissement (bandeau de la page restaurant côté client).
class CoverPhotoZone extends StatefulWidget {
  const CoverPhotoZone({super.key, required this.orgId, required this.branch, required this.canEdit});
  final String orgId;
  final Branch branch;
  final bool canEdit;

  @override
  State<CoverPhotoZone> createState() => _CoverPhotoZoneState();
}

class _CoverPhotoZoneState extends State<CoverPhotoZone> {
  bool _busy = false;
  Uint8List? _bytes;

  Future<void> _pick() async {
    final files = await pickMedia(videos: false, multiple: false);
    if (files.isEmpty || !mounted) return;
    final api = AppScope.read(context).api!;
    setState(() => _busy = true);
    try {
      final f = await compressPhoto(files.first, maxSide: 1800);
      final path = await api.uploadBranchCover(widget.orgId, widget.branch.id!, f.bytes, f.extension);
      widget.branch.coverPath = path;
      if (mounted) setState(() => _bytes = f.bytes);
    } catch (e) {
      if (mounted) showError(context, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final api = AppScope.read(context).api!;
    final path = widget.branch.coverPath;
    final image = _bytes != null
        ? Image.memory(_bytes!, fit: BoxFit.cover)
        : path != null
            ? Image.network(api.menuImageUrl(path), fit: BoxFit.cover, errorBuilder: (_, _, _) => const SizedBox.shrink())
            : null;
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: AspectRatio(
          aspectRatio: 16 / 7,
          child: DashedBox(
            padding: EdgeInsets.zero,
            onTap: widget.canEdit && !_busy ? _pick : null,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(fit: StackFit.expand, children: [
                ?image,
                if (image == null || _busy)
                  Center(
                    child: _busy
                        ? const CircularProgressIndicator()
                        : Column(mainAxisSize: MainAxisSize.min, children: [
                            const Icon(Icons.add_photo_alternate_outlined, color: RestoColors.primaryDeep, size: 30),
                            const SizedBox(height: 6),
                            Text(t.coverPhoto, style: const TextStyle(color: RestoColors.primaryDeep, fontWeight: FontWeight.w700)),
                          ]),
                  ),
                if (image != null && widget.canEdit && !_busy)
                  Positioned(
                    right: 8,
                    bottom: 8,
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(backgroundColor: Colors.black54, foregroundColor: Colors.white),
                      onPressed: _pick,
                      icon: const Icon(Icons.photo_camera_outlined, size: 18),
                      label: Text(t.changePhoto),
                    ),
                  ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

/// Logo du restaurant : zone en pointillés, aperçu, envoi, remplacement, retrait.
class LogoDropZone extends StatefulWidget {
  const LogoDropZone({super.key, required this.orgId, required this.brandId, required this.canEdit});
  final String orgId;
  final String brandId;
  final bool canEdit;

  @override
  State<LogoDropZone> createState() => _LogoDropZoneState();
}

class _LogoDropZoneState extends State<LogoDropZone> {
  Uint8List? _bytes;
  bool _busy = true;

  @override
  void initState() {
    super.initState();
    AppScope.read(context).api!.brandLogo(widget.brandId).then((b) {
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
      await AppScope.read(context).api!.uploadBrandLogo(widget.orgId, widget.brandId, f.bytes, f.extension);
      BrandLogo.refresh();
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
      await AppScope.read(context).api!.removeBrandLogo(widget.brandId);
      BrandLogo.refresh();
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
    final zone = DashedBox(
      onTap: widget.canEdit && !_busy ? _pick : null,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      child: Row(children: [
        Container(
          width: 96,
          height: 96,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: RestoColors.primary, width: 1.4),
          ),
          child: _busy
              ? const Center(child: SizedBox.square(dimension: 24, child: CircularProgressIndicator(strokeWidth: 2)))
              : _bytes == null
                  ? const Icon(Icons.restaurant_rounded, size: 38, color: RestoColors.primaryDeep)
                  : ClipOval(child: Image.memory(_bytes!, fit: BoxFit.contain)),
        ),
        const SizedBox(width: 18),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(_bytes == null ? t.logoUpload : t.replaceLogo,
                style: const TextStyle(color: RestoColors.primaryDeep, fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(height: 4),
            Text(t.logoFormats, style: const TextStyle(color: RestoColors.muted, fontSize: 12.5)),
            if (widget.canEdit) ...[
              const SizedBox(height: 10),
              Wrap(spacing: 8, runSpacing: 6, children: [
                GoldButton(label: _bytes == null ? t.chooseLogo : t.replaceLogo, icon: Icons.upload_rounded, expand: false, onPressed: _busy ? null : _pick),
                if (_bytes != null) GoldButton(label: t.removeLogo, outlined: true, expand: false, onPressed: _busy ? null : _remove),
              ]),
            ],
          ]),
        ),
      ]),
    );
    return LayoutBuilder(builder: (context, box) {
      final note = Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Icon(Icons.info_outline_rounded, size: 18, color: RestoColors.primaryDeep),
        const SizedBox(width: 8),
        Expanded(child: Text(t.logoWhere, style: const TextStyle(color: RestoColors.muted, fontSize: 12.5))),
      ]);
      if (box.maxWidth < 760) return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [zone, const SizedBox(height: 10), note]);
      return Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        Expanded(flex: 3, child: zone),
        const SizedBox(width: 20),
        Expanded(flex: 2, child: note),
      ]);
    });
  }
}

// ---------------------------------------------------------------------------
// Contact & localisation

class _ContactPage extends StatefulWidget {
  const _ContactPage({super.key, required this.scope});
  final BranchContext scope;

  @override
  State<_ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<_ContactPage> {
  final _form = GlobalKey<FormState>();
  late final Branch b = widget.scope.branch;
  late final _address1 = TextEditingController(text: b.addressLine1 ?? '');
  late final _address2 = TextEditingController(text: b.addressLine2 ?? '');
  late final _city = TextEditingController(text: b.city);
  late final _region = TextEditingController(text: b.region ?? '');
  late final _postal = TextEditingController(text: b.postalCode ?? '');
  late final _phone = TextEditingController(text: b.phone ?? '');
  late final _whatsapp = TextEditingController(text: b.whatsapp ?? '');
  late final _email = TextEditingController(text: b.email ?? '');
  late final _lat = TextEditingController(text: b.latitude?.toString() ?? '');
  late final _lng = TextEditingController(text: b.longitude?.toString() ?? '');

  bool get _edit => widget.scope.can('branches.manage');

  @override
  void dispose() {
    for (final c in [_address1, _address2, _city, _region, _postal, _phone, _whatsapp, _email, _lat, _lng]) {
      c.dispose();
    }
    super.dispose();
  }

  double? _num(String s) => double.tryParse(s.trim().replaceAll(',', '.'));

  /// Coller « 4.0511, 9.7679 » dans la latitude remplit les deux champs.
  void _splitPasted(String v) {
    final parts = v.split(RegExp(r'[,;\s]+')).where((p) => p.isNotEmpty).toList();
    if (parts.length == 2 && _num(parts[0]) != null && _num(parts[1]) != null) {
      _lat.text = parts[0];
      _lng.text = parts[1];
      setState(() {});
    }
  }

  /// « Ouvrir dans Maps » : prend la position actuelle de l'appareil,
  /// l'enregistre comme position de l'établissement, puis ouvre la carte.
  Future<void> _locateAndOpen() async {
    final t = context.t;
    String mapUrl() {
      final lat = _num(_lat.text);
      final lng = _num(_lng.text);
      return lat != null && lng != null
          ? 'https://www.google.com/maps/search/?api=1&query=$lat,$lng'
          : 'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent([_address1.text, _city.text].where((s) => s.trim().isNotEmpty).join(', '))}';
    }

    if (!_edit) {
      await openLink(mapUrl());
      return;
    }
    final started = DateTime.now();
    final r = await currentLocation();
    if (!mounted) return;
    if (r.issue != null) {
      showInfo(context, switch (r.issue!) {
        LocationIssue.serviceDisabled => t.locationServiceDisabled,
        LocationIssue.denied || LocationIssue.deniedForever => t.locationDenied,
        LocationIssue.unavailable => t.locationUnavailable,
      });
      return;
    }
    _lat.text = '${r.latitude}';
    _lng.text = '${r.longitude}';
    final before = (b.latitude, b.longitude);
    b
      ..latitude = r.latitude
      ..longitude = r.longitude;
    try {
      await AppScope.read(context).api!.saveBranch(b);
    } catch (e) {
      b
        ..latitude = before.$1
        ..longitude = before.$2;
      if (mounted) showError(context, e);
      return;
    }
    if (!mounted) return;
    setState(() {});
    // Un navigateur n'ouvre un nouvel onglet que juste après le clic : si
    // l'accord de localisation a pris du temps, la carte s'ouvre depuis le message.
    if (DateTime.now().difference(started) < const Duration(seconds: 4)) {
      showInfo(context, t.locationSaved);
      await openLink(mapUrl());
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(t.locationSaved),
        duration: const Duration(seconds: 8),
        action: SnackBarAction(label: t.openMapAction, onPressed: () => openLink(mapUrl())),
      ));
    }
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    b
      ..addressLine1 = _address1.text
      ..addressLine2 = _address2.text
      ..city = _city.text.trim()
      ..region = _region.text
      ..postalCode = _postal.text
      ..phone = _phone.text
      ..whatsapp = _whatsapp.text
      ..email = _email.text
      ..latitude = _num(_lat.text)
      ..longitude = _num(_lng.text);
    await _saveBranch(context, b);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final lat = _num(_lat.text);
    final lng = _num(_lng.text);
    final hasGps = lat != null && lng != null;
    return Form(
      key: _form,
      child: _FormPage(
        onSave: _edit ? _save : null,
        children: [
          _Columns(
            left: [
              _Field(label: t.addressLine1, controller: _address1, enabled: _edit, maxLength: 200, icon: Icons.place_outlined),
              _Field(label: t.addressLine2, controller: _address2, enabled: _edit, maxLength: 200),
              _Field(
                label: t.city,
                controller: _city,
                enabled: _edit,
                maxLength: 120,
                validator: (v) => (v == null || v.trim().isEmpty) ? t.fieldRequired : null,
              ),
              _Field(label: t.region, controller: _region, enabled: _edit, maxLength: 120),
              _Field(label: t.postalCode, controller: _postal, enabled: _edit, maxLength: 20),
            ],
            right: [
              _Field(label: t.phone, controller: _phone, enabled: _edit, maxLength: 32, keyboard: TextInputType.phone, icon: Icons.call_outlined),
              _Field(
                  label: t.whatsappLabel,
                  controller: _whatsapp,
                  enabled: _edit,
                  maxLength: 30,
                  keyboard: TextInputType.phone,
                  icon: Icons.chat_outlined),
              _Field(
                label: t.email,
                controller: _email,
                enabled: _edit,
                maxLength: 254,
                keyboard: TextInputType.emailAddress,
                icon: Icons.alternate_email_rounded,
                validator: (v) => (v == null || v.trim().isEmpty || emailPattern.hasMatch(v.trim())) ? null : t.errorInvalidEmail,
              ),
            ],
          ),
          const SizedBox(height: 8),
          SectionHeading(title: t.gpsTitle, icon: Icons.map_outlined, subtitle: t.gpsHint),
          const SizedBox(height: 12),
          _Columns(
            left: [
              Row(children: [
                Expanded(
                  child: Focus(
                    onFocusChange: (f) {
                      if (!f) _splitPasted(_lat.text);
                    },
                    child: _Field(
                      label: t.latitude,
                      controller: _lat,
                      enabled: _edit,
                      keyboard: const TextInputType.numberWithOptions(decimal: true, signed: true),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return null;
                        final n = _num(v);
                        return (n == null || n < -90 || n > 90) ? t.errorBetween(-90, 90) : null;
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _Field(
                    label: t.longitude,
                    controller: _lng,
                    enabled: _edit,
                    keyboard: const TextInputType.numberWithOptions(decimal: true, signed: true),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return null;
                      final n = _num(v);
                      return (n == null || n < -180 || n > 180) ? t.errorBetween(-180, 180) : null;
                    },
                  ),
                ),
              ]),
            ],
            right: [
              SoftCard(
                padding: const EdgeInsets.all(14),
                child: Row(children: [
                  Container(
                    width: 120,
                    height: 76,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: const LinearGradient(colors: [Color(0xFFEDE6D6), Color(0xFFE2EBDD)]),
                    ),
                    child: CustomPaint(painter: _MapPainter(), child: const Center(child: Icon(Icons.location_on_rounded, color: RestoColors.primaryDeep, size: 30))),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(_city.text.isEmpty ? '—' : _city.text, style: const TextStyle(fontWeight: FontWeight.w700)),
                      Text(hasGps ? '${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}' : t.gpsMissing,
                          style: const TextStyle(color: RestoColors.muted, fontSize: 12.5)),
                      const SizedBox(height: 8),
                      GoldButton(
                        label: t.openInMaps,
                        icon: Icons.my_location_rounded,
                        outlined: true,
                        expand: false,
                        onPressed: _locateAndOpen,
                      ),
                    ]),
                  ),
                ]),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Fond de carte stylisé (rues) sous l'épingle.
class _MapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final road = Paint()
      ..color = Colors.white.withValues(alpha: 0.9)
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke;
    final minor = Paint()
      ..color = Colors.white.withValues(alpha: 0.7)
      ..strokeWidth = 2.5;
    canvas.drawLine(Offset(0, size.height * 0.62), Offset(size.width, size.height * 0.38), road);
    canvas.drawLine(Offset(size.width * 0.35, 0), Offset(size.width * 0.5, size.height), road);
    canvas.drawLine(Offset(0, size.height * 0.2), Offset(size.width, size.height * 0.25), minor);
    canvas.drawLine(Offset(size.width * 0.8, 0), Offset(size.width * 0.7, size.height), minor);
  }

  @override
  bool shouldRepaint(_MapPainter old) => false;
}

// ---------------------------------------------------------------------------
// Horaires, préparation, mode vacances

class _HoursPage extends StatefulWidget {
  const _HoursPage({super.key, required this.scope});
  final BranchContext scope;

  @override
  State<_HoursPage> createState() => _HoursPageState();
}

class _HoursPageState extends State<_HoursPage> {
  late final Branch b = widget.scope.branch;
  late final _prep = TextEditingController(text: '${b.targetPrepMinutes}');
  late final _message = TextEditingController(text: b.vacationMessage ?? '');

  bool get _edit => widget.scope.can('branches.manage');

  @override
  void dispose() {
    _prep.dispose();
    _message.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final t = context.t;
    final prep = int.tryParse(_prep.text.trim());
    if (prep == null || prep < 1 || prep > 240) {
      showInfo(context, t.errorBetween(1, 240));
      return;
    }
    b
      ..targetPrepMinutes = prep
      ..vacationMessage = _message.text;
    await _saveBranch(context, b);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final wide = MediaQuery.sizeOf(context).width >= 1100;
    final service = ListView(padding: const EdgeInsets.fromLTRB(16, 8, 22, 40), children: [
      SoftCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          SectionHeading(title: t.targetPrepTime, icon: Icons.timer_outlined),
          const SizedBox(height: 12),
          _Field(
            label: t.targetPrepTime,
            controller: _prep,
            enabled: _edit,
            keyboard: TextInputType.number,
            suffix: t.minutesShort,
            hint: t.targetPrepTimeHint,
          ),
          const SizedBox(height: 4),
          _SwitchRow(
            title: t.vacationMode,
            subtitle: t.vacationModeHint,
            value: b.vacationMode,
            onChanged: _edit ? (v) => setState(() => b.vacationMode = v) : null,
          ),
          if (b.vacationMode)
            _Field(label: t.vacationMessage, controller: _message, hint: t.vacationMessageHint, enabled: _edit, maxLength: 200),
          if (_edit)
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: GoldButton(label: t.saveChanges, icon: Icons.check_rounded, expand: false, onPressed: _save),
            ),
        ]),
      ),
      if (!wide) ...[
        const SizedBox(height: 18),
        SizedBox(height: 620, child: HoursTab(branchId: widget.scope.branchId, canEdit: _edit)),
      ],
    ]);
    if (!wide) return service;
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Expanded(flex: 5, child: HoursTab(branchId: widget.scope.branchId, canEdit: _edit)),
      Expanded(flex: 4, child: service),
    ]);
  }
}

// ---------------------------------------------------------------------------
// Livraison & commandes

class _DeliveryPage extends StatefulWidget {
  const _DeliveryPage({super.key, required this.scope});
  final BranchContext scope;

  @override
  State<_DeliveryPage> createState() => _DeliveryPageState();
}

class _DeliveryPageState extends State<_DeliveryPage> {
  final _form = GlobalKey<FormState>();
  late final Branch b = widget.scope.branch;
  late final int _unit = widget.scope.minorUnit;
  late final _fee = TextEditingController(text: amountText(b.deliveryFeeMinor, b.currency, _unit));
  late final _minimum = TextEditingController(text: amountText(b.minOrderMinor, b.currency, _unit));
  late final _zone = TextEditingController(text: b.deliveryZone ?? '');
  late final _minutes = TextEditingController(text: '${b.reservationMinutes}');
  late final _party = TextEditingController(text: '${b.maxPartySize}');

  bool get _edit => widget.scope.can('branches.manage');

  @override
  void dispose() {
    for (final c in [_fee, _minimum, _zone, _minutes, _party]) {
      c.dispose();
    }
    super.dispose();
  }

  String? _intIn(String? v, int min, int max) {
    final n = int.tryParse((v ?? '').trim());
    return (n == null || n < min || n > max) ? context.t.errorBetween(min, max) : null;
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    b
      ..deliveryFeeMinor = parseAmount(_fee.text, b.currency, _unit) ?? 0
      ..minOrderMinor = parseAmount(_minimum.text, b.currency, _unit) ?? 0
      ..deliveryZone = _zone.text
      ..reservationMinutes = int.parse(_minutes.text.trim())
      ..maxPartySize = int.parse(_party.text.trim());
    await _saveBranch(context, b);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final url = branchPublicUrl(b.id!);
    return Form(
      key: _form,
      child: _FormPage(
        onSave: _edit ? _save : null,
        children: [
          _Columns(
            left: [
              SectionHeading(title: t.onlineOrdersTitle, icon: Icons.shopping_bag_outlined),
              const SizedBox(height: 10),
              _SwitchRow(
                title: t.acceptOnlineOrders,
                subtitle: t.acceptOnlineOrdersHint,
                value: b.acceptsOnlineOrders,
                onChanged: _edit ? (v) => setState(() => b.acceptsOnlineOrders = v) : null,
              ),
              _SwitchRow(
                title: t.acceptDelivery,
                value: b.acceptsDelivery,
                onChanged: _edit && b.acceptsOnlineOrders ? (v) => setState(() => b.acceptsDelivery = v) : null,
              ),
              _SwitchRow(
                title: t.payFirstTakeaway,
                subtitle: t.payFirstTakeawayHint,
                value: b.payFirstTakeaway,
                onChanged: _edit ? (v) => setState(() => b.payFirstTakeaway = v) : null,
              ),
              const SizedBox(height: 6),
              Wrap(spacing: 14, runSpacing: 12, children: [
                AmountField(controller: _fee, label: t.deliveryFee, currency: b.currency, minorUnit: _unit, enabled: _edit, width: 210),
                AmountField(controller: _minimum, label: t.minimumOrder, currency: b.currency, minorUnit: _unit, enabled: _edit, width: 210),
              ]),
              const SizedBox(height: 14),
              _Field(label: t.deliveryZoneLabel, controller: _zone, hint: t.deliveryZoneHint, enabled: _edit, maxLength: 300, maxLines: 2),
            ],
            right: [
              SectionHeading(title: t.reservationsTitle, icon: Icons.event_seat_outlined),
              const SizedBox(height: 10),
              _SwitchRow(
                title: t.acceptReservations,
                value: b.acceptsReservations,
                onChanged: _edit ? (v) => setState(() => b.acceptsReservations = v) : null,
              ),
              Row(children: [
                Expanded(
                  child: _Field(
                    label: t.reservationDuration,
                    controller: _minutes,
                    enabled: _edit,
                    keyboard: TextInputType.number,
                    suffix: t.minutesShort,
                    validator: (v) => _intIn(v, 15, 480),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _Field(
                    label: t.maxPartySize,
                    controller: _party,
                    enabled: _edit,
                    keyboard: TextInputType.number,
                    validator: (v) => _intIn(v, 1, 200),
                  ),
                ),
              ]),
              const SizedBox(height: 8),
              SectionHeading(title: t.publicPageTitle, icon: Icons.public_rounded),
              const SizedBox(height: 10),
              _SwitchRow(
                title: t.published,
                subtitle: b.isPublished ? null : t.notPublishedHint,
                value: b.isPublished,
                onChanged: _edit ? (v) => setState(() => b.isPublished = v) : null,
              ),
              SoftCard(
                padding: const EdgeInsets.all(14),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  QrView(data: url, size: 110),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      SelectableText(url, style: const TextStyle(fontSize: 12.5)),
                      const SizedBox(height: 6),
                      Text(t.publicPageHint, style: const TextStyle(color: RestoColors.muted, fontSize: 12)),
                      TextButton.icon(
                        onPressed: () async {
                          await Clipboard.setData(ClipboardData(text: url));
                          if (context.mounted) showInfo(context, t.copied);
                        },
                        icon: const Icon(Icons.copy_rounded, size: 18),
                        label: Text(t.copyLink),
                      ),
                    ]),
                  ),
                ]),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Paiement & facturation (réglages de la caisse)

class _PaymentsPage extends StatefulWidget {
  const _PaymentsPage({super.key, required this.scope});
  final BranchContext scope;

  @override
  State<_PaymentsPage> createState() => _PaymentsPageState();
}

class _PaymentsPageState extends State<_PaymentsPage> {
  late final CashContext _ctx = CashContext(AppScope.read(context).api!, widget.scope)..load();

  @override
  void dispose() {
    _ctx.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _ctx,
      builder: (context, _) {
        if (_ctx.error != null) {
          return Center(
            child: TextButton(onPressed: _ctx.load, child: Text(context.t.retry)),
          );
        }
        if (!_ctx.loaded) return const Center(child: CircularProgressIndicator());
        return CashSettingsTab(ctx: _ctx);
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Notifications (préférences du membre)

class _NotificationsPage extends StatefulWidget {
  const _NotificationsPage({required this.scope});
  final BranchContext scope;

  @override
  State<_NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<_NotificationsPage> {
  MemberPrefs? _prefs;

  @override
  void initState() {
    super.initState();
    AppScope.read(context).api!.prefs.load(widget.scope.orgId).then((p) {
      if (mounted) setState(() => _prefs = p);
    }).catchError((Object e) {
      if (mounted) setState(() => _prefs = MemberPrefs({}));
    });
  }

  String _label(String key) {
    final t = context.t;
    return switch (key) {
      'sound_new_order' => t.notifSoundNewOrder,
      'sound_ready' => t.notifSoundReady,
      'alert_late' => t.notifLate,
      'alert_low_stock' => t.notifLowStock,
      'alert_reservations' => t.notifReservations,
      'push_new_order' => t.pushNewOrder,
      'push_order_ready' => t.pushOrderReady,
      'push_reservations' => t.pushReservations,
      'push_reviews' => t.pushReviews,
      _ => t.notifCashGap,
    };
  }

  @override
  Widget build(BuildContext context) {
    final prefs = _prefs;
    if (prefs == null) return const Center(child: CircularProgressIndicator());
    return _FormPage(
      onSave: () async {
        try {
          await AppScope.read(context).api!.prefs.save(widget.scope.orgId, prefs);
          if (context.mounted) showInfo(context, context.t.saved);
        } catch (e) {
          if (context.mounted) showError(context, e);
        }
      },
      children: [
        for (final k in MemberPrefs.flags)
          _SwitchRow(title: _label(k), value: prefs.flag(k), onChanged: (v) => setState(() => prefs.set(k, v))),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Sécurité

class _SecurityPage extends StatelessWidget {
  const _SecurityPage();

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final api = AppScope.of(context).api!;
    Widget action(IconData icon, String title, String? subtitle, VoidCallback onTap) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: SoftCard(
            onTap: onTap,
            padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
            child: Row(children: [
              GoldIcon(icon, size: 40),
              const SizedBox(width: 14),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                  if (subtitle != null) Text(subtitle, style: const TextStyle(color: RestoColors.muted, fontSize: 12.5)),
                ]),
              ),
              const Icon(Icons.chevron_right_rounded, color: RestoColors.muted),
            ]),
          ),
        );
    return _FormPage(children: [
      SoftCard(
        child: Row(children: [
          const GoldIcon(Icons.verified_user_outlined, size: 48, filled: true),
          const SizedBox(width: 16),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(t.signedInAs, style: const TextStyle(color: RestoColors.muted, fontSize: 12.5)),
              Text(api.user?.email ?? '—', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              const SizedBox(height: 4),
              Text(t.securityTip, style: const TextStyle(color: RestoColors.muted, fontSize: 12.5)),
            ]),
          ),
        ]),
      ),
      const SizedBox(height: 16),
      action(Icons.password_rounded, t.changePassword, null,
          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NewPasswordScreen()))),
      action(Icons.devices_other_rounded, t.signOutOthers, null, () async {
        try {
          await api.auth.signOut(scope: SignOutScope.others);
          if (context.mounted) showInfo(context, t.signOutOthersDone);
        } catch (e) {
          if (context.mounted) showError(context, e);
        }
      }),
      action(Icons.logout_rounded, t.signOutAll, null, () async {
        if (!await confirm(context, t.signOutAll)) return;
        await api.auth.signOut(scope: SignOutScope.global);
      }),
    ]);
  }
}
