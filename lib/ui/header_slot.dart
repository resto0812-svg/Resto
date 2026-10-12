import 'package:flutter/widgets.dart';

/// Contenu qu'un module place dans l'en-tête, à côté de son titre
/// (ex. : les catégories du module Menus).
class HeaderSlot {
  HeaderSlot._();

  static final ValueNotifier<(String, Widget)?> notifier = ValueNotifier(null);
  static Object? _owner;

  /// Affiche [child] dans l'en-tête de la section [sectionId].
  static void show(Object owner, String sectionId, Widget child) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _owner = owner;
      notifier.value = (sectionId, child);
    });
  }

  static void clear(Object owner) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_owner != owner) return;
      _owner = null;
      notifier.value = null;
    });
  }
}
