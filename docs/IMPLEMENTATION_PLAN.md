# Resto — Plan de réalisation et suivi

Légende : ✅ fait et vérifié · 🟡 écrit, vérification en attente · ⬜ à faire.

Chaque phase se termine par : tests passés, documentation à jour, liste
explicite de ce qui reste incomplet.

## Phase 0 — Audit et conception

| Élément | État |
|---|---|
| État des lieux ([AUDIT.md](AUDIT.md)) | ✅ |
| Spécification ([PRODUCT_SPEC.md](PRODUCT_SPEC.md)) | ✅ |
| Architecture et ADR ([ARCHITECTURE.md](ARCHITECTURE.md)) | ✅ — ADR-001 (Flutter unique) **à confirmer** |
| Modèle de données + ERD Phase 1 ([DATA_MODEL.md](DATA_MODEL.md)) | ✅ |
| Sécurité + matrice des permissions ([SECURITY.md](SECURITY.md)) | ✅ |
| Hors ligne ([OFFLINE_SYNC.md](OFFLINE_SYNC.md)) | ✅ |
| Registre des risques ([RISKS.md](RISKS.md)) | ✅ |

## Phase 1 — Fondations

| Élément | État |
|---|---|
| Projet Flutter (Android, iOS, Web), Git, `.gitignore`, `env/example.json` ; build Web vérifié | ✅ |
| Infrastructure de traduction : fr (source), en, de, es, pt, ar (RTL), zh-Hans, zh-Hant | ✅ |
| `Money` (unités mineures, arrondis, répartition) + tests | ✅ |
| Migration `001_fondations.sql` : référentiels, profils, organisations, rôles/permissions, adhésions, invitations, marques, établissements, horaires, salle, audit, RLS, RPC | ✅ appliquée (2026-10-10) |
| Correctif `002_correctif_lecture_etablissements.sql` (1er essai des tests : refus RLS sur `insert … returning` d'un établissement) | ✅ appliqué (2026-10-10) |
| Tests SQL d'isolation `001_fondations_tests.sql` | ✅ 46 contrôles passés (2026-10-10) |
| Générateur de référentiels ISO (`tool/generer_referentiels.dart`) → `supabase/seed/ref_iso.sql` | ✅ appliqué (vérifié : 249 pays, 165 monnaies) |
| Migration `003_ecrans_fondations.sql` (fuseaux, horaires d'un bloc, journal lisible) + `003_ecrans_tests.sql` (11 contrôles) | ✅ appliquée, 11 contrôles passés (2026-10-10) |
| Écrans : connexion / inscription / code de confirmation / mot de passe oublié (modèles `docs/AUTH_EMAILS.md`) | ✅ essayé par l'utilisateur sur le Web (2026-10-10) |
| Écrans : créer l'organisation / rejoindre par code, établissements, langues, horaires, salle (zones, tables) | ✅ idem |
| Écrans : équipe (inviter avec code à transmettre, rôle, établissements, retirer), journal d'audit, compte | ✅ idem — envoi automatique des invitations par e-mail : ⬜ (Edge Function + Brevo) |
| Choix de langue (détection + manuel, droite à gauche), bandeau d'environnement | ✅ (mémorisée dans le profil et pour les e-mails) |

**Prérequis utilisateur** : créer un projet Supabase dédié « resto-dev »,
fournir l'URL et la clé publique (`env/dev.json`), coller 001 puis le seed,
puis les tests.

## Phase 2 — Commandes (premier module de bout en bout)

| Élément | État |
|---|---|
| Couleurs de la marque (bordeaux #5A1523, vin #8C2D3A, or #C99B3D, crème #F1DFC1, brun #2A1E1F), thème clair et sombre | ✅ |
| Migration `004_menus.sql` : catégories, articles, variantes, groupes de suppléments, allergènes (14), traductions du contenu, articles proposés et disponibilité par établissement, prix par canal avec historique (`set_price`), monnaie figée dès qu'il existe des prix + `004_menus_tests.sql` (27 contrôles) | ✅ appliquée, écrans essayés par l'utilisateur (2026-10-10) |
| Écrans Menus v1 (onglets Articles / Suppléments / Prix) | ✅ fonctionnels mais jugés difficiles à comprendre par l'utilisateur |
| Écrans Menus v2 simplifiés : liste unique avec prix et « Épuisé », fiche article unique (prix, tailles, vente, options, allergènes) enregistrée en une fois, options en langage courant avec prix des choix | ✅ (2026-10-10) |
| Photos des articles (stockage) | ⬜ reporté à la phase 4 (espace client) |
| Plages horaires de disponibilité par catégorie (petit-déjeuner…) | ⬜ |
| Migration `005_commandes.sql` : taxe par établissement (taux, prix TTC ou HT), commandes (sur place / à emporter, numéro du jour, une seule commande ouverte par table), lignes avec nom et prix figés, options choisies, historique immuable ; prix et règles d'options imposés par le serveur ; ligne envoyée jamais effacée (annulation avec motif, orders.void) ; appels rejouables sans doublon + `005_commandes_tests.sql` (31 contrôles) | ✅ appliquée, contrôles passés (2026-10-10) |
| Écrans Commandes : salle (tables libres / occupées, montant, ancienneté), vente à emporter, commande (carte + ticket, choix taille / options / quantité / remarque, +/−, envoi en cuisine, annulation avec motif), taxe dans la fiche établissement | ✅ essayés par l'utilisateur (2026-10-10) |
| Taxes par juridiction (profils, plusieurs taux, exonérations) | ⬜ phase 5 |
| Migration `007_cuisine.sql` : postes de préparation (Cuisine / Bar par défaut), répartition par type à l'envoi, suivi envoyé → en préparation → prêt → servi, temps réel + `007_cuisine_tests.sql` (10 contrôles) ; écran Cuisine (tickets par commande, retard ≥ 15 min, « Tout est prêt », « Servi »), « Servi » dans le ticket | ✅ appliquée (2026-10-10) |
| Migration `006_caisse.sql` : caisses, sessions (fond, comptage, écart, validation cash.close), paiements enregistrés (espèces / carte / Mobile Money / virement / autre), monnaie rendue, trop-perçu refusé, clôture automatique de la commande payée, annulation et remboursement tracés, entrées / sorties, rapport de session et du jour + `006_caisse_tests.sql` (32 contrôles) ; écrans Caisse et Encaisser (partage de l'addition) | ✅ appliquée (2026-10-10) |

## Phase 3 — Gestion complète

| Élément | État |
|---|---|
| Navigation regroupée (Service / Gestion / Organisation), menu latéral ou escamotable | ✅ |
| Migration `008_stocks.sql` : ingrédients, unités et conversions, emplacements, mouvements immuables, coût moyen pondéré, fiches techniques versionnées (plats, options, préparations maison), consommation à la clôture des commandes, production, transferts, inventaires et écarts, seuils d'alerte + `008_stocks_tests.sql` (23 contrôles) ; écran Stocks (état, ingrédients, fiches techniques avec coût en direct, inventaires, mouvements) | ✅ appliquée (2026-10-10) |
| Migration `009_achats_depenses.sql` : fournisseurs, bons de commande, réceptions (entrée en stock valorisée), factures fournisseurs (anti-doublon), paiements (éventuellement depuis la caisse), dettes, catégories et dépenses, justificatifs en stockage privé, rapport financier par période + `009_achats_depenses_tests.sql` (24 contrôles) ; écrans Achats, Dépenses, Rapports (indicateurs expliqués, marges par plat, exports CSV) | ✅ appliquée (2026-10-10) |
| Exports PDF et Excel natifs | ⬜ (CSV disponible, ouvrable dans Excel) |
| Lots et dates de péremption : saisie présente dans les mouvements, alertes de péremption | ⬜ |

## Refonte premium du service (2026-10-10, à la demande de l'utilisateur)

| Élément | État |
|---|---|
| Identité « Grand Cru » : grenat, bordeaux nuit, or champagne, ivoire ; couleurs d'état communes (libre, réservée, occupée, à valider, en préparation, prête, à encaisser, en retard) ; Playfair Display + Plus Jakarta Sans ; menu latéral sombre | ✅ |
| Écrans de compte en « soft UI » (référence fournie par l'utilisateur) : carte en relief, champs creusés, médaillon, carte « Créer un compte » derrière ; vitrine de la marque sur grand écran | ✅ |
| Migration `013_service.sql` : forme et position des tables (plan de salle), commande complète dès la création (type, origine téléphone, client, téléphone, adresse, heure souhaitée, frais de livraison), articles « à suivre » et « Lancer la suite », heure promise au client (acceptation avec délai), heures « prête » et « servie », changement de table, installation d'une réservation (commande ouverte sur sa table), réservation terminée et table libérée à la fin du repas ; temps de préparation visé et paiement d'avance à emporter par établissement + `013_service_tests.sql` (27 contrôles) | ✅ appliquée avec le correctif 014, 27 contrôles passés (2026-10-11) |
| Module Commandes : suivi en direct en colonnes (À valider → En cours → Prêtes à servir → À encaisser) avec sonnerie, filtres et recherche ; nouvelle commande en une fiche (sur place / à emporter / livraison, téléphone) ; fiche commande (carte en photos, ticket par étape, informations client, réductions, encaisser puis envoyer, impression bon cuisine et addition en PDF, journal) | ✅ écrit |
| Salle : plan dessiné (tables rondes, carrées, rectangulaires avec chaises), état en direct, « Modifier la salle » (zones, tables nommées librement, glisser-déposer), fiche de table, QR code par table | ✅ écrit |
| Réservations : planning par table (chronologie), liste, demandes des clients, nouvelle réservation avec tables libres, installer / absents / annuler | ✅ écrit |
| Historique des commandes par journée (indicateurs, filtres) | ✅ écrit |
| Cuisine : un ticket par commande (table, à emporter, livraison, client, heure), chronomètre coloré selon le temps visé, bandeau « Prêtes — la salle est prévenue », vue cumulée, plein écran sombre | ✅ écrit |
| Migration `015_caisse_pro.sql` : catalogue mondial des modes de paiement (pays, noms traduits), modes propres à chaque organisation (référence obligatoire, commission, établissements), pourboires à part attribués au serveur, n° de ticket légal à la clôture, mentions du ticket, coupures de 25 monnaies, comptage billet par billet, Z numéroté, rapport de caisse par période, annuaire de l'équipe + tests (25) | ✅ appliquée, 25 contrôles passés (2026-10-11) |
| Module Caisse (7 onglets) : Encaisser (file des commandes, écran plein écran : partage tout / parts / articles / montant libre, modes en tuiles, pourboire, clavier, sommes rapides, monnaie, ticket PDF, partage, WhatsApp), Ma caisse (fond compté, suivi en direct, mouvements, lecture X, clôture à l'aveugle), Clôtures (validation, Z PDF), Transactions (filtres, export, réimpression, annulation, remboursement), Remboursements, Rapports (graphiques par heure / jour, par mode, serveur, caisse, sessions, PDF), Réglages (modes de paiement par pays, caisses, mentions du ticket, pourboires) | ✅ écrit |
| Factures clients (`016_factures.sql`) : facture A4 numérotée par établissement (préfixe réglable), client / société / n° fiscal / adresse, figée après émission, annulation motivée puis réémission ; documents visibles dans chaque commande (Addition, Ticket de caisse, Facture), bouton Facture après encaissement, onglet Caisse › Factures + tests (11) | ⏳ à appliquer |
| Logo du restaurant et ticket « maison » (`017_logo_ticket.sql`) + tests (8) | ⏳ à appliquer |
| Identité « Ivoire & Or » (maquettes DELICES) : fond ivoire, cartes blanches, or, titres Playfair ; accueil avec indicateurs du jour ; Commandes, Cuisine, Caisse, Rapports restylés | ✅ écrit |
| `018_vitrine_publicite.sql` : profil complet (slogan, immatriculation, WhatsApp, GPS, zone, vacances), préférences, articles (5 photos, vidéo, préparation, jours, desserts/formules, stock du jour, duplication), Publicité (6 formats, médiathèque, ciblage, statistiques), tableau de bord + tests (22) ; modules Paramètres, Menus (grille produits, fiche avec aperçu en direct), Publicité | ✅ appliquée (2026-10-11) |
| `019_espace_client_premium.sql` : profil client, vitrine (cartes, villes, catalogue), carte enrichie, vacances + tests (9) ; espace client (accueil, recherche, favoris, commandes en direct, profil, panier) | ✅ appliquée, 9 contrôles passés (2026-10-11) |
| `020_accueil_avis.sql` : accueil personnalisé (position avec accord, près de vous, populaires, nouveautés, promotions, commandes en cours, recommander), avis vérifiés par plat (photos, utile, signalement, modération), classement de popularité + tests (20) | ✅ appliquée, contrôles passés (2026-10-11) |
| `021_panier_multi_clients.sql` : panier multi-restaurants (une commande indépendante par restaurant, tout ou rien, commande programmée), fiche client propre à chaque restaurant (module Clients) + tests (10) | ✅ appliquée, contrôles passés (2026-10-11) |
| `022_fil_decouverte.sql` : fil « Découvrir » plein écran (vidéos, carrousels, annonces, sponsorisés signalés), J'aime / commentaires modérés / enregistrements / partages, vues dédoublonnées et portée, commandes attribuées à la publicité, annonces flottantes de l'accueil, réservation depuis le fil + tests (14) | ✅ appliquée, contrôles passés (2026-10-11) |
| `023_fidelisation.sql` + correctif `024_correctif_limites_favoris.sql` : notifications dans l'application (en direct), plats favoris et listes, portefeuille de coupons publics, points d'anniversaire, commande groupée par lien ; onglets Offres et Fidélité du module Clients + tests (20) | ✅ appliquée, contrôles passés (2026-10-11) |
| Notifications push (téléphone fermé) | ⬜ demande des comptes Firebase / Apple |
| `025_stock_pro.sql` : fiche article (photo, conservation, unité d'achat, fournisseur habituel, durée de conservation, code-barres), objectif de coût matière, tableau de bord du stock, lots proches de la date limite (FIFO), commande suggérée + tests (12) ; module Stock pro (8 onglets : tableau de bord, stock, articles, fiches recettes, inventaires, commandes, mouvements, rapports PDF) | ⏳ à appliquer |

## Phase 4 — Espace client

Demande de l'utilisateur (2026-10-11) : le client voit les tables (libres, occupées, réservées) avec une estimation de l'heure à laquelle elles se libèrent, en plus des plats ; il réserve en choisissant sa table. Base déjà prête : `slotAvailability` (lib/features/service/reservation_table_picker.dart), à exposer par une fonction publique sans données personnelles.

Recherche (pays, ville, spécialité, prix, note, ouverture), menus publics sans
compte, panier, commandes en ligne et programmées, réservations
(anti-chevauchement), notifications, historique, avis vérifiés, fidélité.
Site public SEO si ADR-001 le retient. ⬜

## Phase 5 — International et monétisation

Profils fiscaux par juridiction, numérotations, arrondis, taux de change
historisés, formules et abonnements, commissions figées par transaction,
connecteurs de paiement (un premier prestataire en mode test), reversements,
console plateforme, accès d'assistance. ⬜

## Phase 6 — Hors ligne

Base locale chiffrée, file d'événements, `sync_apply` idempotent, conflits
par domaine, reprise, impression ESC/POS. ⬜

## Phase 7 — Durcissement et lancement

Tests fonctionnels, sécurité, charge, restauration de sauvegarde,
accessibilité, compatibilité ; 2FA ; pilote avec un restaurant réel avant
ouverture. ⬜

## Fonctionnalités encore incomplètes

Tout ce qui est marqué ⬜ ou 🟡 ci-dessus. Au 2026-10-10 : fondations, menus et
prise de commande fonctionnent ; encaissement, clôture, caisse, cuisine (KDS),
stocks, achats, espace client, abonnements et hors ligne restent à faire.
