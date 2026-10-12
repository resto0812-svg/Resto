import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../app_state.dart';
import '../../data/models.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/common.dart';

/// Journal d'audit de l'organisation (lecture seule, jamais modifiable).
class AuditScreen extends StatefulWidget {
  const AuditScreen({super.key, required this.membership});
  final Membership membership;

  @override
  State<AuditScreen> createState() => _AuditScreenState();
}

class _AuditScreenState extends State<AuditScreen> {
  final _entries = <AuditEntry>[];
  bool _loading = false;
  bool _end = false;
  Object? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _more());
  }

  Future<void> _more() async {
    if (_loading || _end) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final page = await AppScope.read(context)
          .api!
          .audit(widget.membership.organizationId, before: _entries.isEmpty ? null : _entries.last.id);
      setState(() {
        _entries.addAll(page);
        _end = page.length < 50;
      });
    } catch (e) {
      setState(() => _error = e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  static String _entity(AppLocalizations t, String table) => switch (table) {
        'organizations' => t.entityOrganization,
        'memberships' || 'membership_branches' => t.entityMembership,
        'invitations' || 'invitation_branches' => t.entityInvitation,
        'brands' => t.entityBrand,
        'branches' || 'branch_languages' => t.entityBranch,
        'branch_opening_hours' => t.openingHours,
        'service_areas' => t.entityArea,
        'dining_tables' => t.entityTable,
        'menu_categories' => t.category,
        'menu_items' || 'menu_item_branches' => t.entityItem,
        'item_variants' => t.entityVariant,
        'modifier_groups' || 'modifiers' || 'item_modifier_groups' => t.entityModifier,
        'item_allergens' => t.allergens,
        'prices' => t.entityPrice,
        _ when table.endsWith('_translations') => t.translations,
        _ => table,
      };

  static String _action(AppLocalizations t, String action) => switch (action) {
        'insert' => t.actionInsert,
        'update' => t.actionUpdate,
        'delete' => t.actionDelete,
        _ => action,
      };

  /// Champs modifiés (« status : active → revoked »), sans valeurs techniques longues.
  static String _changes(AuditEntry e) {
    final newValues = (e.details['new'] as Map?) ?? const {};
    final oldValues = (e.details['old'] as Map?) ?? const {};
    if (e.action != 'update') {
      final source = newValues.isNotEmpty ? newValues : oldValues;
      return source['name']?.toString() ?? source['label']?.toString() ?? source['email']?.toString() ?? '';
    }
    return newValues.keys
        .where((k) => !k.toString().endsWith('_id') && k != 'id')
        .map((k) => '$k : ${oldValues[k] ?? '∅'} → ${newValues[k] ?? '∅'}')
        .join(' ; ');
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final format = DateFormat.yMd(Localizations.localeOf(context).toLanguageTag()).add_Hm();
    if (_entries.isEmpty && _error != null) {
      return Center(child: OutlinedButton(onPressed: _more, child: Text(t.retry)));
    }
    if (_entries.isEmpty && !_loading && _end) return Center(child: Text(t.noEntries));
    return ListView.separated(
      itemCount: _entries.length + 1,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, i) {
        if (i == _entries.length) {
          if (_end) return const SizedBox(height: 24);
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: _loading
                  ? const CircularProgressIndicator()
                  : OutlinedButton(onPressed: _more, child: Text(_error == null ? t.loadMore : t.retry)),
            ),
          );
        }
        final e = _entries[i];
        final changes = _changes(e);
        return ListTile(
          dense: true,
          title: Text('${_action(t, e.action)} · ${_entity(t, e.entity)}${changes.isEmpty ? '' : ' — $changes'}',
              maxLines: 3, overflow: TextOverflow.ellipsis),
          subtitle: Text('${format.format(e.createdAt.toLocal())} · ${e.actorName.isEmpty ? '—' : e.actorName}'),
        );
      },
    );
  }
}
