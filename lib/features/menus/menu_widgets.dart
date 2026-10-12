import 'dart:math';

import 'package:flutter/material.dart';

import '../../core/locales.dart';
import '../../core/money.dart';
import '../../data/menu_models.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/common.dart';

String kindLabel(AppLocalizations t, String kind) => switch (kind) {
      'food' => t.kindFood,
      'drink' => t.kindDrink,
      'dessert' => t.kindDessert,
      'menu' => t.kindMenu,
      _ => t.kindOther,
    };

String channelLabel(AppLocalizations t, String channel) => switch (channel) {
      'dine_in' => t.channelDineIn,
      'takeaway' => t.channelTakeaway,
      'delivery' => t.channelDelivery,
      _ => t.channelDefault,
    };

String allergenLabel(AppLocalizations t, String code) => switch (code) {
      'gluten' => t.allergenGluten,
      'crustaceans' => t.allergenCrustaceans,
      'eggs' => t.allergenEggs,
      'fish' => t.allergenFish,
      'peanuts' => t.allergenPeanuts,
      'soybeans' => t.allergenSoybeans,
      'milk' => t.allergenMilk,
      'nuts' => t.allergenNuts,
      'celery' => t.allergenCelery,
      'mustard' => t.allergenMustard,
      'sesame' => t.allergenSesame,
      'sulphites' => t.allergenSulphites,
      'lupin' => t.allergenLupin,
      'molluscs' => t.allergenMolluscs,
      _ => code,
    };

/// Règles de choix d'un groupe d'options, en langage courant.
enum OptionRule {
  requiredOne(1, 1),
  optionalOne(0, 1),
  optionalMany(0, null),
  requiredMany(1, null);

  const OptionRule(this.min, this.max);
  final int min;
  final int? max;

  static OptionRule? of(int min, int? max) {
    for (final r in values) {
      if (r.min == min && r.max == max) return r;
    }
    return null;
  }
}

String optionRuleLabel(AppLocalizations t, int min, int? max) => switch (OptionRule.of(min, max)) {
      OptionRule.requiredOne => t.ruleRequiredOne,
      OptionRule.optionalOne => t.ruleOptionalOne,
      OptionRule.optionalMany => t.ruleOptionalMany,
      OptionRule.requiredMany => t.ruleRequiredMany,
      null => t.selectionRule(min, max?.toString() ?? '∞'),
    };

/// Identifiant UUID v4 généré localement (création d'une ligne dont on a
/// besoin de l'identifiant tout de suite, par exemple une nouvelle taille).
String uuidV4() {
  final r = Random.secure();
  final b = List<int>.generate(16, (_) => r.nextInt(256));
  b[6] = (b[6] & 0x0f) | 0x40;
  b[8] = (b[8] & 0x3f) | 0x80;
  final h = b.map((x) => x.toRadixString(16).padLeft(2, '0')).join();
  return '${h.substring(0, 8)}-${h.substring(8, 12)}-${h.substring(12, 16)}-${h.substring(16, 20)}-${h.substring(20)}';
}

/// Montant saisi → unités mineures ; null si vide ; lève FormatException si invalide.
int? parseAmount(String text, String currency, int minorUnit) {
  final raw = text.trim().replaceAll(RegExp(r'[\s  ]'), '');
  if (raw.isEmpty) return null;
  final value = Money.parse(raw, currency, minorUnit).minor;
  if (value < 0) throw const FormatException('negative');
  return value;
}

String amountText(int? minor, String currency, int minorUnit) =>
    minor == null ? '' : Money(minor, currency).toDecimalString(minorUnit);

/// Champ de montant (sans enregistrement automatique : la fiche enregistre tout).
class AmountField extends StatelessWidget {
  const AmountField({
    super.key,
    required this.controller,
    required this.label,
    required this.currency,
    required this.minorUnit,
    this.enabled = true,
    this.width = 170,
  });

  final TextEditingController controller;
  final String label;
  final String currency;
  final int minorUnit;
  final bool enabled;
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: TextFormField(
        controller: controller,
        enabled: enabled,
        keyboardType: TextInputType.numberWithOptions(decimal: minorUnit > 0),
        textAlign: TextAlign.end,
        decoration: InputDecoration(isDense: true, labelText: label, suffixText: currency),
        validator: (v) {
          try {
            parseAmount(v ?? '', currency, minorUnit);
            return null;
          } on Object {
            return context.t.errorInvalidPrice;
          }
        },
      ),
    );
  }
}

/// Traductions d'un contenu, langue par langue. Un nom vide supprime la
/// traduction. Renvoie les langues modifiées : locale → (nom, description).
Future<Map<String, (String, String?)>?> editTranslations(
  BuildContext context, {
  required String title,
  required Map<String, ContentTranslation> current,
  bool withDescription = false,
}) {
  return showDialog<Map<String, (String, String?)>>(
    context: context,
    builder: (_) => _TranslationsDialog(title: title, current: current, withDescription: withDescription),
  );
}

class _TranslationsDialog extends StatefulWidget {
  const _TranslationsDialog({required this.title, required this.current, required this.withDescription});
  final String title;
  final Map<String, ContentTranslation> current;
  final bool withDescription;

  @override
  State<_TranslationsDialog> createState() => _TranslationsDialogState();
}

class _TranslationsDialogState extends State<_TranslationsDialog> {
  late final Map<String, TextEditingController> _names = {
    for (final l in languageNames.keys) l: TextEditingController(text: widget.current[l]?.name ?? ''),
  };
  late final Map<String, TextEditingController> _descriptions = {
    for (final l in languageNames.keys) l: TextEditingController(text: widget.current[l]?.description ?? ''),
  };

  @override
  void dispose() {
    for (final c in [..._names.values, ..._descriptions.values]) {
      c.dispose();
    }
    super.dispose();
  }

  void _save() {
    final changed = <String, (String, String?)>{};
    for (final l in languageNames.keys) {
      final name = _names[l]!.text.trim();
      final description = _descriptions[l]!.text.trim();
      final before = widget.current[l];
      if (name != (before?.name ?? '') || (widget.withDescription && description != (before?.description ?? ''))) {
        changed[l] = (name, description.isEmpty ? null : description);
      }
    }
    Navigator.pop(context, changed);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return AlertDialog(
      title: Text('${t.translations} · ${widget.title}'),
      content: SizedBox(
        width: 520,
        child: ListView(shrinkWrap: true, children: [
          for (final e in languageNames.entries) ...[
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(e.value, style: Theme.of(context).textTheme.titleSmall),
            ),
            Directionality(
              textDirection: e.key == 'ar' ? TextDirection.rtl : TextDirection.ltr,
              child: Column(children: [
                TextField(controller: _names[e.key], maxLength: 120, decoration: InputDecoration(labelText: t.name)),
                if (widget.withDescription)
                  TextField(
                    controller: _descriptions[e.key],
                    maxLines: 3,
                    minLines: 1,
                    maxLength: 2000,
                    decoration: InputDecoration(labelText: t.description),
                  ),
              ]),
            ),
          ],
        ]),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(t.cancel)),
        FilledButton(onPressed: _save, child: Text(t.save)),
      ],
    );
  }
}
