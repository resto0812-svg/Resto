import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../app_state.dart';
import 'theme.dart';

/// Logo du restaurant (première marque de l'organisation) dans un médaillon
/// cerclé d'or ; à défaut, l'initiale. Rafraîchi après un changement de logo.
class BrandLogo extends StatelessWidget {
  const BrandLogo({super.key, required this.orgId, required this.fallback, this.size = 48});
  final String orgId;
  final String fallback;
  final double size;

  /// Incrémenté quand le logo change (Paramètres).
  static final version = ValueNotifier<int>(0);
  static final Map<String, Future<Uint8List?>> _cache = {};

  static void refresh() {
    _cache.clear();
    version.value++;
  }

  static Future<Uint8List?> _load(BuildContext context, String orgId) {
    final api = AppScope.read(context).api;
    if (api == null) return Future.value(null);
    return _cache[orgId] ??= () async {
      final brandId = await api.firstBrandId(orgId);
      return brandId == null ? null : api.brandLogo(brandId);
    }();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: version,
      builder: (context, _, _) => FutureBuilder<Uint8List?>(
        future: _load(context, orgId),
        builder: (context, snap) {
          final bytes = snap.data;
          return Container(
            width: size,
            height: size,
            padding: EdgeInsets.all(bytes == null ? 0 : size * 0.1),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: RestoColors.primary, width: 1.6),
              boxShadow: RestoColors.softShadow(4),
            ),
            alignment: Alignment.center,
            child: bytes == null
                ? Text(fallback.isEmpty ? 'R' : fallback.characters.first.toUpperCase(),
                    style: serifTitle(context, size: size * 0.46, color: RestoColors.primaryDeep))
                : ClipOval(child: Image.memory(bytes, fit: BoxFit.contain)),
          );
        },
      ),
    );
  }
}
