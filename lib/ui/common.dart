import 'package:flutter/material.dart';

import '../app_state.dart';
import '../core/errors.dart';
import '../core/locales.dart';
import '../l10n/app_localizations.dart';

extension L10nContext on BuildContext {
  AppLocalizations get t => AppLocalizations.of(this);
}

void showError(BuildContext context, Object error) {
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorText(context.t, error))));
}

void showInfo(BuildContext context, String message) {
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

Future<bool> confirm(BuildContext context, String message, {String? action}) async {
  final t = context.t;
  final ok = await showDialog<bool>(
    context: context,
    builder: (c) => AlertDialog(
      content: Text(message),
      actions: [
        TextButton(onPressed: () => Navigator.pop(c, false), child: Text(t.cancel)),
        FilledButton(onPressed: () => Navigator.pop(c, true), child: Text(action ?? t.confirm)),
      ],
    ),
  );
  return ok ?? false;
}

/// Bouton qui se désactive et affiche une roue pendant l'opération.
class BusyButton extends StatefulWidget {
  const BusyButton({super.key, required this.label, required this.onPressed, this.icon});
  final String label;
  final Future<void> Function()? onPressed;
  final IconData? icon;

  @override
  State<BusyButton> createState() => _BusyButtonState();
}

class _BusyButtonState extends State<BusyButton> {
  bool _busy = false;

  Future<void> _run() async {
    setState(() => _busy = true);
    try {
      await widget.onPressed!();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final child = _busy
        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
        : Text(widget.label);
    final onPressed = (_busy || widget.onPressed == null) ? null : _run;
    return widget.icon == null
        ? FilledButton(onPressed: onPressed, child: child)
        : FilledButton.icon(onPressed: onPressed, icon: Icon(widget.icon), label: child);
  }
}

/// Liste déroulante avec recherche par saisie (pays, monnaies, fuseaux…).
class SearchSelect extends StatelessWidget {
  const SearchSelect({
    super.key,
    required this.label,
    required this.value,
    required this.entries,
    required this.onChanged,
    this.errorText,
    this.enabled = true,
  });

  final String label;
  final String? value;
  final List<(String, String)> entries; // (valeur, libellé)
  final ValueChanged<String?> onChanged;
  final String? errorText;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return DropdownMenu<String>(
      key: ValueKey('$label|$value|${entries.length}'),
      label: Text(label),
      initialSelection: value,
      enabled: enabled,
      enableFilter: true,
      requestFocusOnTap: true,
      expandedInsets: EdgeInsets.zero,
      menuHeight: 320,
      errorText: errorText,
      onSelected: onChanged,
      dropdownMenuEntries: [for (final (v, l) in entries) DropdownMenuEntry(value: v, label: l)],
    );
  }
}

/// Choix de la langue de l'interface (disponible même sans être connecté).
class LanguageMenuButton extends StatelessWidget {
  const LanguageMenuButton({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final state = AppScope.of(context);
    return PopupMenuButton<String>(
      tooltip: t.languageLabel,
      icon: const Icon(Icons.translate),
      initialValue: state.locale == null ? '' : refLocaleCode(state.locale!),
      onSelected: (code) async {
        try {
          await state.setLocale(localeFromRef(code));
        } catch (e) {
          if (context.mounted) showError(context, e);
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(value: '', child: Text(t.systemLanguage)),
        for (final e in languageNames.entries) PopupMenuItem(value: e.key, child: Text(e.value)),
      ],
    );
  }
}

/// Charge une donnée et affiche chargement / erreur avec « Réessayer ».
class Loader<T> extends StatefulWidget {
  const Loader({super.key, required this.load, required this.builder});
  final Future<T> Function() load;
  final Widget Function(BuildContext context, T data, VoidCallback reload) builder;

  @override
  State<Loader<T>> createState() => _LoaderState<T>();
}

class _LoaderState<T> extends State<Loader<T>> {
  late Future<T> _future = widget.load();

  void _reload() => setState(() => _future = widget.load());

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: _future,
      builder: (context, snap) {
        if (snap.hasError) {
          return Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text(errorText(context.t, snap.error!), textAlign: TextAlign.center),
              const SizedBox(height: 12),
              OutlinedButton(onPressed: _reload, child: Text(context.t.retry)),
            ]),
          );
        }
        if (snap.connectionState != ConnectionState.done) return const Center(child: CircularProgressIndicator());
        return widget.builder(context, snap.data as T, _reload);
      },
    );
  }
}

/// Contenu centré à largeur lisible sur grand écran.
class FormWidth extends StatelessWidget {
  const FormWidth({super.key, required this.child, this.maxWidth = 640});
  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) => Center(
        child: ConstrainedBox(constraints: BoxConstraints(maxWidth: maxWidth), child: child),
      );
}

String roleLabel(AppLocalizations t, String code) => switch (code) {
      'owner' => t.roleOwner,
      'admin' => t.roleAdmin,
      'manager' => t.roleManager,
      'accountant' => t.roleAccountant,
      'cashier' => t.roleCashier,
      'stock_keeper' => t.roleStockKeeper,
      'waiter' => t.roleWaiter,
      'kitchen' => t.roleKitchen,
      'viewer' => t.roleViewer,
      _ => code,
    };

String weekdayName(AppLocalizations t, int weekday) =>
    [t.weekday1, t.weekday2, t.weekday3, t.weekday4, t.weekday5, t.weekday6, t.weekday7][weekday - 1];

final emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
