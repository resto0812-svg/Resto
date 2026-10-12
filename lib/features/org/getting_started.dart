import 'package:flutter/material.dart';

import '../../app_state.dart';
import '../../data/models.dart';
import '../../data/supabase_setup.dart' show hideStartGuide, readStartGuideHidden;
import '../../ui/common.dart';
import '../../ui/kit.dart';
import '../../ui/theme.dart';

/// Guide « Bien démarrer » sur l'accueil du restaurant (propriétaire et
/// administrateurs) : six étapes cochées automatiquement quand elles sont
/// faites, chacune ouvre le module concerné. Masquable.
class GettingStartedCard extends StatefulWidget {
  const GettingStartedCard({super.key, required this.membership, required this.onOpenId});
  final Membership membership;
  final ValueChanged<String> onOpenId;

  @override
  State<GettingStartedCard> createState() => _GettingStartedCardState();
}

class _GettingStartedCardState extends State<GettingStartedCard> {
  late final Future<(bool, Set<String>)> _state = _load();

  Future<(bool, Set<String>)> _load() async {
    final orgId = widget.membership.organizationId;
    final hidden = await readStartGuideHidden(orgId);
    if (hidden || !mounted) return (true, <String>{});
    return (false, await AppScope.read(context).api!.gettingStartedDone(orgId));
  }

  bool _gone = false;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    if (_gone || !widget.membership.canOrg('org.manage')) return const SizedBox.shrink();
    return FutureBuilder<(bool, Set<String>)>(
      future: _state,
      builder: (context, snap) {
        final data = snap.data;
        if (data == null || data.$1) return const SizedBox.shrink();
        final done = data.$2;
        final steps = [
          ('profile', Icons.storefront_outlined, t.startProfile, 'settings'),
          ('dishes', Icons.restaurant_menu_rounded, t.startDishes, 'menus'),
          ('tables', Icons.table_restaurant_outlined, t.startTables, 'branches'),
          ('payments', Icons.point_of_sale_rounded, t.startPayments, 'cash'),
          ('team', Icons.groups_2_outlined, t.startTeam, 'team'),
          ('published', Icons.public_rounded, t.startPublish, 'branches'),
        ];
        final count = steps.where((s) => done.contains(s.$1)).length;
        if (count == steps.length) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: SoftCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Row(children: [
                const GoldIcon(Icons.flag_outlined, size: 40),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(t.startTitle, style: serifTitle(context, size: 22)),
                    Text(t.startProgress(count, steps.length), style: const TextStyle(color: RestoColors.muted, fontSize: 12.5)),
                  ]),
                ),
                TextButton(
                  onPressed: () {
                    hideStartGuide(widget.membership.organizationId);
                    setState(() => _gone = true);
                  },
                  child: Text(t.hideAction),
                ),
              ]),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  minHeight: 7,
                  value: count / steps.length,
                  backgroundColor: RestoColors.band,
                  color: RestoColors.primary,
                ),
              ),
              const SizedBox(height: 8),
              for (final (key, icon, label, section) in steps)
                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    done.contains(key) ? Icons.check_circle_rounded : icon,
                    color: done.contains(key) ? const Color(0xFF2E9E5B) : RestoColors.primaryDeep,
                  ),
                  title: Text(
                    label,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: done.contains(key) ? RestoColors.muted : RestoColors.ink,
                      decoration: done.contains(key) ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  trailing: done.contains(key) ? null : const Icon(Icons.chevron_right_rounded),
                  onTap: done.contains(key) ? null : () => widget.onOpenId(section),
                ),
            ]),
          ),
        );
      },
    );
  }
}
