import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:resto/ui/kit.dart';
import 'package:resto/ui/theme.dart';

Widget _page(Widget child) => MaterialApp(
      theme: restoTheme(Brightness.light, fonts: false),
      home: Scaffold(body: ListView(padding: const EdgeInsets.all(16), children: [child])),
    );

void main() {
  for (final width in [360.0, 1280.0]) {
    testWidgets('composants « Ivoire & Or » sans débordement ($width px)', (tester) async {
      tester.view.physicalSize = Size(width, 2400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      await tester.pumpWidget(_page(Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        const ScreenTitle(title: 'Rapports DELICES', subtitle: 'DELICES · Propriétaire'),
        PillBar<int>(
          items: const [
            PillItem(0, 'Toutes', count: 12),
            PillItem(1, 'En attente', icon: Icons.schedule_rounded, count: 3),
            PillItem(2, 'En préparation', count: 4),
            PillItem(3, 'Prêtes'),
            PillItem(4, 'Livrées'),
            PillItem(5, 'Annulées'),
          ],
          selected: 1,
          onSelected: (_) {},
        ),
        const Wrap(spacing: 10, runSpacing: 10, children: [
          CounterTile(icon: Icons.receipt_long_rounded, value: '12', label: 'aujourd\'hui', highlight: true),
          CounterTile(icon: Icons.schedule_rounded, value: '4', label: 'en cours'),
        ]),
        const KpiCard(icon: Icons.payments_outlined, label: 'CA du jour', value: '425 000 FCFA', trend: '+12 %'),
        GoldHeaderCard(
          title: 'Table 5 · #12',
          titleIcon: Icons.table_restaurant_rounded,
          badge: const HeaderBadge(text: '12 min', icon: Icons.schedule_rounded),
          info: const Text('Prise en salle · 2 personnes'),
          action: GoldButton(label: 'Voir détails', onPressed: () async {}),
          child: const Text('1 × Ndolé (Gros)'),
        ),
        Wrap(spacing: 8, children: [
          GoldButton(label: 'Court', expand: false, onPressed: () async {}),
          GoldButton(label: 'Contour', outlined: true, expand: false, onPressed: () async {}),
        ]),
        const DashedBox(child: Text('Télécharger le logo')),
        const EmptyState(icon: Icons.check_rounded, title: 'Rien à encaisser pour le moment.', message: 'Tout est à jour.'),
      ])));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      // Un bouton non étiré reste à la taille de son libellé.
      expect(tester.getSize(find.ancestor(of: find.text('Court'), matching: find.byType(Container)).first).width, lessThan(width - 40));
    });
  }
}
