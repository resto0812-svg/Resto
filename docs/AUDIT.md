# Resto — État des lieux (Phase 0)

Date : 2026-10-10.

## 1. Dépôt

Le dossier ouvert dans Claude Code (`C:\dev\immo`) est l'application **Immo**
(gestion locative, Flutter + Supabase), sans rapport avec la restauration.
Construire Resto à l'intérieur aurait mélangé deux produits, deux bases de
données et deux cycles de publication. **Resto est donc un projet neuf et
séparé** : `C:\dev\resto`, dépôt Git propre, projet Supabase dédié (même
démarche que Néo dans `C:\dev\paiements`).

Contenu initial de `C:\dev\resto` : squelette `flutter create` (Android, iOS,
Web), aucun code métier, aucune donnée.

## 2. Outils présents sur le poste

| Outil | État | Conséquence |
|---|---|---|
| Flutter 3.47.5 / Dart 3.13 (stable) | installé | base mobile + web |
| Git 2.55 | installé | dépôt local, pas de dépôt distant pour l'instant |
| Node.js / npm | **absent** | Next.js impossible à construire ici sans installation |
| Supabase CLI / Docker / PostgreSQL local | **absents** | migrations appliquées en collant le SQL dans l'éditeur SQL Supabase (méthode déjà utilisée pour Immo et Néo) ; tests SQL exécutés de la même façon |

## 3. Acquis réutilisables (Immo et Néo)

Ces éléments ont déjà fait leurs preuves en production chez l'utilisateur et
sont repris comme conventions, **sans copier de code métier** :

- Sécurité « by design » : RLS sur toutes les tables, écritures sensibles
  uniquement via fonctions RPC atomiques, journal d'audit immuable, clé
  publique seule côté client, aucune `service_role` livrée.
- Performance RLS : appels de fonctions encapsulés dans `(select …)` pour
  être évalués une fois par requête (incident Néo 017).
- Tests SQL de sécurité exécutés dans une transaction annulée
  (`supabase/tests/*.sql`, « OK n » / « ÉCHEC n »).
- Configuration par `--dart-define-from-file=env/<env>.json`, fichiers
  d'environnement exclus de Git.
- Traductions `gen-l10n` (ARB), arabe de droite à gauche (déjà fait dans Immo).
- Sessions stockées de façon sécurisée (pas de `SharedPreferences` pour les
  jetons), e-mails d'authentification via Brevo (SMTP Supabase).
- Publication web Flutter sur Cloudflare (Néo Web, Immo Web).

## 4. Problèmes et écarts identifiés

1. **Next.js demandé, mais Node absent et double base de code.** Voir
   décision ADR-001 dans [ARCHITECTURE.md](ARCHITECTURE.md) : Flutter unique
   (mobile + tablette + web) pour toutes les interfaces applicatives ;
   Next.js réservé, plus tard, au site public référencé (SEO), si confirmé.
2. **Pas de base locale de test** : aucune migration ne peut être exécutée
   sur ce poste ; chaque migration est livrée avec un script de contrôle à
   lancer dans Supabase.
3. **Référentiels internationaux** (ISO 3166, ISO 4217, IANA) : ne pas les
   saisir à la main. Fuseaux : `pg_timezone_names` (IANA, intégré à
   PostgreSQL). Pays et monnaies : générés depuis des sources maintenues par
   un outil Dart (`tool/generer_referentiels.dart`), voir
   [DATA_MODEL.md](DATA_MODEL.md) §2.
4. **Paiements réels, reversements, conservation de fonds** : dépendent du
   prestataire et du pays ; aucun connecteur ne sera présenté comme
   fonctionnel avant un compte de test réel.

## 5. Éléments manquants (tout le produit)

Tout reste à construire ; l'ordre est donné dans
[IMPLEMENTATION_PLAN.md](IMPLEMENTATION_PLAN.md).
