# Resto

Plateforme internationale de restauration : espace client, espace restaurant,
console de la plateforme. Flutter (Android, iOS, Web) + Supabase dédié.

Documentation : [docs/](docs/) — commencer par
[IMPLEMENTATION_PLAN.md](docs/IMPLEMENTATION_PLAN.md).

## Base de données (projet Supabase dédié)

Dans le SQL Editor, dans cet ordre :

1. `supabase/migrations/001_fondations.sql`
2. `supabase/migrations/002_correctif_lecture_etablissements.sql`
3. `supabase/seed/ref_iso.sql` (pays et monnaies ISO ; rejouable)
4. `supabase/tests/001_fondations_tests.sql` → doit finir par
   « TOUS LES CONTRÔLES 001 SONT PASSÉS » (aucune donnée conservée)
5. `supabase/migrations/003_ecrans_fondations.sql`
6. `supabase/tests/003_ecrans_tests.sql` → « TOUS LES CONTRÔLES 003 SONT PASSÉS »
7. `supabase/migrations/004_menus.sql`
8. `supabase/tests/004_menus_tests.sql` → « TOUS LES CONTRÔLES 004 SONT PASSÉS (27) »
9. `supabase/migrations/005_commandes.sql`
10. `supabase/tests/005_commandes_tests.sql` → « TOUS LES CONTRÔLES 005 SONT PASSÉS (31) »
11. `supabase/migrations/006_caisse.sql` puis `supabase/tests/006_caisse_tests.sql` (32)
12. `supabase/migrations/007_cuisine.sql` puis `supabase/tests/007_cuisine_tests.sql` (10)
13. `supabase/migrations/008_stocks.sql` puis `supabase/tests/008_stocks_tests.sql` (23)
14. `supabase/migrations/009_achats_depenses.sql` puis `supabase/tests/009_achats_depenses_tests.sql`
15. `supabase/migrations/010_espace_client.sql` puis `supabase/tests/010_espace_client_tests.sql`
16. `supabase/migrations/011_reservations.sql` puis `supabase/tests/011_reservations_tests.sql`
17. `supabase/migrations/012_fidelite_promotions.sql` puis `supabase/tests/012_fidelite_promotions_tests.sql`
18. `supabase/migrations/013_service.sql`
19. `supabase/migrations/014_correctif_creation_commande.sql` puis `supabase/tests/013_service_tests.sql` (27)
20. `supabase/migrations/015_caisse_pro.sql` puis `supabase/tests/015_caisse_pro_tests.sql` (25)
21. `supabase/migrations/016_factures.sql` puis `supabase/tests/016_factures_tests.sql` (11)
22. `supabase/migrations/017_logo_ticket.sql` puis `supabase/tests/017_logo_ticket_tests.sql` (8)
23. `supabase/migrations/018_vitrine_publicite.sql` puis `supabase/tests/018_vitrine_publicite_tests.sql` (22)
24. `supabase/migrations/019_espace_client_premium.sql` puis `supabase/tests/019_espace_client_premium_tests.sql` (9)
25. `supabase/migrations/020_accueil_avis.sql` puis `supabase/tests/020_accueil_avis_tests.sql` (20)
26. `supabase/migrations/021_panier_multi_clients.sql` puis `supabase/tests/021_panier_multi_clients_tests.sql` (10)
27. `supabase/migrations/022_fil_decouverte.sql` puis `supabase/tests/022_fil_decouverte_tests.sql` (14)
28. `supabase/migrations/023_fidelisation.sql`, puis `supabase/migrations/024_correctif_limites_favoris.sql`, puis `supabase/tests/023_fidelisation_tests.sql` (20)
29. `supabase/migrations/025_stock_pro.sql` puis `supabase/tests/025_stock_pro_tests.sql` (12)
30. `supabase/migrations/026_carte_client.sql` puis `supabase/tests/026_carte_client_tests.sql` (10)
31. `supabase/migrations/027_ticket_parametres.sql` puis `supabase/tests/027_ticket_parametres_tests.sql` (4)
32. `supabase/migrations/028_stats_publiques_pubs.sql` puis `supabase/tests/028_stats_publiques_pubs_tests.sql` (2)
33. `supabase/migrations/029_favoris_carte_publique.sql` puis `supabase/tests/029_favoris_carte_publique_tests.sql` (2)
34. `supabase/migrations/030_social_plats.sql` puis `supabase/tests/030_social_plats_tests.sql` (9)
35. `supabase/migrations/031_notifications_push.sql` puis `supabase/tests/031_notifications_push_tests.sql` (9) — puis déployer la fonction Edge `supabase/functions/send-push` (secret FCM_SERVICE_ACCOUNT, « Verify JWT » désactivé)
36. `supabase/migrations/032_adresse_fonction_push.sql` (adresse de la fonction « send-push- »)
37. `supabase/migrations/033_tables_client.sql` puis `supabase/tests/033_tables_client_tests.sql` (11)

E-mails d'authentification (codes) : voir [docs/AUTH_EMAILS.md](docs/AUTH_EMAILS.md).

Une migration appliquée n'est jamais modifiée : on ajoute la suivante.
Référentiels à jour : `dart run tool/generer_referentiels.dart`
(ou, derrière un proxy, avec les deux fichiers sources téléchargés en
arguments).

## Application

```
copy env\example.json env\dev.json   (puis renseigner URL + clé publique)
flutter run --dart-define-from-file=env/dev.json
flutter test
flutter build web --release --no-web-resources-cdn --dart-define-from-file=env/dev.json
```

Jamais de clé `service_role` ni de secret dans `env/*.json` ou dans le code.
