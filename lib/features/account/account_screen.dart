import 'package:flutter/material.dart';

import '../../ui/app_version.dart';

import '../../app_state.dart';
import '../../core/locales.dart';
import '../../ui/common.dart';
import '../auth/auth_screens.dart';
import '../org/onboarding_screen.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final _name = TextEditingController();
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    _loaded = true;
    AppScope.read(context).api!.myProfile().then((p) {
      if (mounted) _name.text = (p?['display_name'] as String?) ?? '';
    }).catchError((Object _) {});
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final state = AppScope.of(context);
    final api = state.api!;
    return ListView(padding: const EdgeInsets.all(24), children: [
      FormWidth(
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text(api.user?.email ?? '', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          TextField(controller: _name, maxLength: 120, decoration: InputDecoration(labelText: t.displayName)),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: BusyButton(
              label: t.save,
              onPressed: () async {
                if (_name.text.trim().isEmpty) return;
                try {
                  await api.saveDisplayName(_name.text);
                  if (context.mounted) showInfo(context, t.saved);
                } catch (e) {
                  if (context.mounted) showError(context, e);
                }
              },
            ),
          ),
          const SizedBox(height: 24),
          SearchSelect(
            label: t.languageLabel,
            value: state.locale == null ? '' : refLocaleCode(state.locale!),
            entries: [('', t.systemLanguage), for (final e in languageNames.entries) (e.key, e.value)],
            onChanged: (code) async {
              try {
                await state.setLocale(localeFromRef(code));
              } catch (e) {
                if (context.mounted) showError(context, e);
              }
            },
          ),
          const SizedBox(height: 24),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.group_add),
            title: Text(t.joinTeam),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (c) => Scaffold(
                  appBar: AppBar(title: Text(t.joinTeam)),
                  body: JoinTeamForm(onJoined: () => Navigator.pop(c)),
                ),
              ),
            ),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.password),
            title: Text(t.changePassword),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NewPasswordScreen())),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.logout),
            title: Text(t.signOut),
            onTap: api.signOut,
          ),
        ]),
      ),
      const AppVersionLabel(),
    ]);
  }
}
