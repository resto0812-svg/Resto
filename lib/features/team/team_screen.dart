import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../app_state.dart';
import '../../data/models.dart';
import '../../ui/common.dart';

/// Équipe : membres, rôles, établissements attribués, invitations.
class TeamScreen extends StatefulWidget {
  const TeamScreen({super.key, required this.membership});
  final Membership membership;

  @override
  State<TeamScreen> createState() => _TeamScreenState();
}

class _TeamData {
  _TeamData(this.members, this.invitations, this.branches);
  final List<Member> members;
  final List<Invitation> invitations;
  final List<Branch> branches;
}

class _TeamScreenState extends State<TeamScreen> {
  Key _key = UniqueKey();

  void _refresh() => setState(() => _key = UniqueKey());

  String get _orgId => widget.membership.organizationId;
  bool get _isOwner => widget.membership.role == 'owner';

  Future<_TeamData> _load() async {
    final api = AppScope.read(context).api!;
    final r = await Future.wait([api.members(_orgId), api.pendingInvitations(_orgId), api.branches(_orgId)]);
    return _TeamData(r[0] as List<Member>, r[1] as List<Invitation>, r[2] as List<Branch>);
  }

  List<String> get _assignableRoles => roleCodes.where((r) => r != 'owner' || _isOwner).toList();

  Future<void> _invite(List<Branch> branches) async {
    final result = await showDialog<_RoleChoice>(
      context: context,
      builder: (_) => _RoleDialog(roles: _assignableRoles, branches: branches, askEmail: true),
    );
    if (result == null || !mounted) return;
    final t = context.t;
    try {
      final code = await AppScope.read(context)
          .api!
          .invite(_orgId, result.email!, result.role, result.allBranches, result.branchIds);
      if (!mounted) return;
      _refresh();
      final message = t.invitationMessage(widget.membership.organizationName, code);
      await showDialog<void>(
        context: context,
        builder: (c) => AlertDialog(
          title: Text(t.invitationCreatedTitle),
          content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(t.invitationCreatedBody(result.email!)),
            const SizedBox(height: 12),
            SelectableText(code, style: const TextStyle(fontFamily: 'monospace')),
          ]),
          actions: [
            TextButton(
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: message));
                if (c.mounted) showInfo(c, t.copied);
              },
              child: Text(t.copyMessage),
            ),
            FilledButton(onPressed: () => Navigator.pop(c), child: Text(t.close)),
          ],
        ),
      );
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  Future<void> _edit(Member member, List<Branch> branches) async {
    final result = await showDialog<_RoleChoice>(
      context: context,
      builder: (_) => _RoleDialog(
        roles: _assignableRoles,
        branches: branches,
        initialRole: member.role,
        initialAll: member.allBranches,
        initialBranches: member.branchIds,
      ),
    );
    if (result == null || !mounted) return;
    try {
      await AppScope.read(context).api!.updateMembership(member.membershipId, result.role, result.allBranches, result.branchIds);
      await _afterChange(member);
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  Future<void> _revoke(Member member) async {
    final t = context.t;
    final name = member.displayName.isEmpty ? member.email : member.displayName;
    if (!await confirm(context, t.revokeConfirm(name), action: t.revoke) || !mounted) return;
    try {
      await AppScope.read(context).api!.revokeMembership(member.membershipId);
      await _afterChange(member);
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  /// Un changement me concernant modifie mes droits : on les relit.
  Future<void> _afterChange(Member member) async {
    final state = AppScope.read(context);
    if (member.userId == state.api!.user?.id) {
      await state.refreshMemberships();
    } else {
      _refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final me = AppScope.of(context).api!.user?.id;
    final dateFormat = DateFormat.yMMMd(Localizations.localeOf(context).toLanguageTag());
    return Loader<_TeamData>(
      key: _key,
      load: _load,
      builder: (context, data, reload) {
        final names = {for (final b in data.branches) b.id: b.name};
        final active = data.members.where((m) => m.status == 'active').toList();
        return Scaffold(
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _invite(data.branches),
            icon: const Icon(Icons.person_add),
            label: Text(t.invite),
          ),
          body: RefreshIndicator(
            onRefresh: () async => reload(),
            child: ListView(padding: const EdgeInsets.only(bottom: 88), children: [
              for (final m in active)
                ListTile(
                  leading: const Icon(Icons.person),
                  title: Text([
                    if (m.displayName.isNotEmpty) m.displayName else m.email,
                    if (m.userId == me) '(${t.you})',
                  ].join(' ')),
                  subtitle: Text([
                    roleLabel(t, m.role),
                    if (m.displayName.isNotEmpty) m.email,
                    if (m.allBranches) t.allBranches else m.branchIds.map((id) => names[id] ?? '?').join(', '),
                  ].join(' · ')),
                  trailing: (m.role == 'owner' && !_isOwner)
                      ? null
                      : PopupMenuButton<String>(
                          onSelected: (a) => a == 'edit' ? _edit(m, data.branches) : _revoke(m),
                          itemBuilder: (_) => [
                            PopupMenuItem(value: 'edit', child: Text(t.changeRole)),
                            PopupMenuItem(value: 'revoke', child: Text(t.revoke)),
                          ],
                        ),
                ),
              if (data.invitations.isNotEmpty) ...[
                const Divider(),
                ListTile(title: Text(t.pendingInvitations, style: Theme.of(context).textTheme.titleSmall)),
                for (final i in data.invitations)
                  ListTile(
                    leading: const Icon(Icons.mail_outline),
                    title: Text(i.email),
                    subtitle: Text('${roleLabel(t, i.role)} · ${t.expiresOn(dateFormat.format(i.expiresAt.toLocal()))}'),
                    trailing: IconButton(
                      tooltip: t.revoke,
                      icon: const Icon(Icons.cancel_outlined),
                      onPressed: () async {
                        try {
                          await AppScope.read(context).api!.revokeInvitation(i.id);
                          _refresh();
                        } catch (e) {
                          if (context.mounted) showError(context, e);
                        }
                      },
                    ),
                  ),
              ],
            ]),
          ),
        );
      },
    );
  }
}

class _RoleChoice {
  _RoleChoice(this.email, this.role, this.allBranches, this.branchIds);
  final String? email;
  final String role;
  final bool allBranches;
  final List<String> branchIds;
}

/// Choix du rôle et des établissements (et de l'e-mail pour une invitation).
class _RoleDialog extends StatefulWidget {
  const _RoleDialog({
    required this.roles,
    required this.branches,
    this.askEmail = false,
    this.initialRole,
    this.initialAll = true,
    this.initialBranches = const [],
  });

  final List<String> roles;
  final List<Branch> branches;
  final bool askEmail;
  final String? initialRole;
  final bool initialAll;
  final List<String> initialBranches;

  @override
  State<_RoleDialog> createState() => _RoleDialogState();
}

class _RoleDialogState extends State<_RoleDialog> {
  final _email = TextEditingController();
  late String _role = widget.initialRole ?? 'waiter';
  late bool _all = widget.initialAll;
  late final Set<String> _branches = {...widget.initialBranches};
  String? _error;

  /// Propriétaire et administrateur couvrent toujours toute l'organisation.
  bool get _forcedAll => _role == 'owner' || _role == 'admin';

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  void _submit() {
    final t = context.t;
    final email = _email.text.trim().toLowerCase();
    if (widget.askEmail && !emailPattern.hasMatch(email)) {
      setState(() => _error = t.errorInvalidEmail);
      return;
    }
    final all = _forcedAll || _all;
    if (!all && _branches.isEmpty) {
      setState(() => _error = t.errorBranchesRequired);
      return;
    }
    Navigator.pop(context, _RoleChoice(widget.askEmail ? email : null, _role, all, all ? [] : _branches.toList()));
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final roles = widget.roles.contains(_role) ? widget.roles : [_role, ...widget.roles];
    return AlertDialog(
      title: Text(widget.askEmail ? t.invite : t.changeRole),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (widget.askEmail)
              TextField(
                controller: _email,
                autofocus: true,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(labelText: t.email),
              ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _role,
              decoration: InputDecoration(labelText: t.role),
              items: [for (final r in roles) DropdownMenuItem(value: r, child: Text(roleLabel(t, r)))],
              onChanged: (v) => setState(() => _role = v ?? _role),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(t.allBranches),
              value: _forcedAll || _all,
              onChanged: _forcedAll ? null : (v) => setState(() => _all = v),
            ),
            if (!_forcedAll && !_all)
              for (final b in widget.branches)
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(b.name),
                  value: _branches.contains(b.id),
                  onChanged: (v) => setState(() => v == true ? _branches.add(b.id!) : _branches.remove(b.id)),
                ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
              ),
          ]),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(t.cancel)),
        FilledButton(onPressed: _submit, child: Text(widget.askEmail ? t.invite : t.save)),
      ],
    );
  }
}
