import 'dart:math';

import 'package:flutter/material.dart';

import '../app_state.dart';
import '../core/money.dart';
import '../data/models.dart';
import 'common.dart';
import 'theme.dart';

/// Établissement choisi et ce qu'il faut pour afficher ses montants.
class BranchContext {
  BranchContext(this.membership, this.branch, this.minorUnit);
  final Membership membership;
  final Branch branch;
  final int minorUnit;

  String get orgId => membership.organizationId;
  String get branchId => branch.id!;
  String get currency => branch.currency;

  bool can(String p) => membership.can(p) && (membership.allBranches || membership.branchIds.contains(branch.id));

  String money(BuildContext context, num minor) =>
      Money(minor.round(), currency).format(Localizations.localeOf(context).toString(), minorUnit);

  /// Montant saisi en unités principales (« 2 500 », « 2,50 ») → unités mineures (peut être fractionnaire).
  double toMinor(double major) => major * pow(10, minorUnit);

  /// Unités mineures → texte saisissable en unités principales.
  String toMajorText(double minor) {
    final v = minor / pow(10, minorUnit);
    return v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(minorUnit + 2).replaceAll(RegExp(r'0+$'), '');
  }
}

/// Sélecteur d'établissement (parmi ceux du membre) puis contenu.
class BranchScope extends StatefulWidget {
  const BranchScope({super.key, required this.membership, required this.builder});
  final Membership membership;
  final Widget Function(BuildContext context, BranchContext scope) builder;

  @override
  State<BranchScope> createState() => _BranchScopeState();
}

class _BranchScopeState extends State<BranchScope> {
  /// Dernier établissement choisi par organisation (partagé entre les modules).
  static final Map<String, String> _last = {};

  String? get _branchId => _last[widget.membership.organizationId];

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final state = AppScope.of(context);
    final m = widget.membership;
    return Loader<(List<Branch>, Map<String, int>)>(
      load: () async {
        final branches = (await state.api!.branches(m.organizationId))
            .where((b) => b.status == 'active')
            .where((b) => m.allBranches || m.branchIds.contains(b.id))
            .toList();
        final refs = await state.references();
        return (branches, {for (final c in refs.currencies) c.code: c.minorUnit});
      },
      builder: (context, data, _) {
        final (branches, units) = data;
        if (branches.isEmpty) return Center(child: Text(t.noBranches));
        final branch = branches.firstWhere((b) => b.id == _branchId, orElse: () => branches.first);
        final scope = BranchContext(m, branch, units[branch.currency] ?? 2);
        final side = MediaQuery.sizeOf(context).width < 600 ? 16.0 : 22.0;
        // Un seul établissement : pas de sélecteur (place gagnée en haut de l'écran).
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (branches.length > 1)
          Padding(
            padding: EdgeInsets.fromLTRB(side, 0, side, 2),
            child: _BranchPill(
              branch: branch,
              branches: branches,
              onChanged: (id) => setState(() => _last[m.organizationId] = id),
            ),
          ),
          Expanded(child: KeyedSubtree(key: ValueKey(branch.id), child: widget.builder(context, scope))),
        ]);
      },
    );
  }
}

/// « Établissement · DELICE » : pastille, menu de choix s'il y en a plusieurs.
class _BranchPill extends StatelessWidget {
  const _BranchPill({required this.branch, required this.branches, required this.onChanged});
  final Branch branch;
  final List<Branch> branches;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final several = branches.length > 1;
    final pill = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: RestoColors.primary.withValues(alpha: 0.35)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.storefront_rounded, size: 17, color: RestoColors.primaryDeep),
        const SizedBox(width: 7),
        Text('${t.branchLabel} · ', style: const TextStyle(color: RestoColors.muted, fontSize: 13)),
        Flexible(
          child: Text(branch.name,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: RestoColors.ink, fontWeight: FontWeight.w700, fontSize: 13)),
        ),
        if (several) ...[const SizedBox(width: 4), const Icon(Icons.expand_more_rounded, size: 18, color: RestoColors.muted)],
      ]),
    );
    if (!several) return pill;
    return PopupMenuButton<String>(
      tooltip: t.navBranches,
      initialValue: branch.id,
      onSelected: onChanged,
      itemBuilder: (_) => [for (final b in branches) PopupMenuItem(value: b.id, child: Text(b.name))],
      child: pill,
    );
  }
}
