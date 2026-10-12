import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'common.dart';
import 'theme.dart';

/// « Resto · version 1.1.0 (2) » : numéro de la version installée, pour savoir
/// quelle version chacun utilise (assistance, mises à jour).
class AppVersionLabel extends StatelessWidget {
  const AppVersionLabel({super.key});

  static final Future<PackageInfo> _info = PackageInfo.fromPlatform();

  @override
  Widget build(BuildContext context) => FutureBuilder<PackageInfo>(
        future: _info,
        builder: (context, snap) {
          final i = snap.data;
          if (i == null) return const SizedBox.shrink();
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              context.t.appVersion(i.version, i.buildNumber),
              textAlign: TextAlign.center,
              style: const TextStyle(color: RestoColors.muted, fontSize: 12),
            ),
          );
        },
      );
}
