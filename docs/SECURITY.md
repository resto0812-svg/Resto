# Resto — Sécurité

## 1. Principes

1. PostgreSQL est la seule source de vérité ; l'application n'est jamais
   considérée comme fiable.
2. **RLS activée sur toutes les tables** du schéma `public` ; aucune table
   sans politique explicite.
3. Lectures par politiques RLS ; **écritures sensibles uniquement par RPC**
   `security definer` (`set search_path = ''`), qui vérifient les droits,
   valident, verrouillent, journalisent.
4. Isolation des organisations garantie deux fois : RLS **et** clés
   étrangères composites `(organization_id, …)` (ADR-003).
5. Clé publique Supabase seule côté client. Secrets (prestataires de
   paiement, Brevo, `service_role`) uniquement dans les secrets des Edge
   Functions ou le Vault.
6. Fonctions d'aide dans le schéma `app_private` (non exposé par l'API) ;
   droits d'exécution révoqués pour `public` / `anon` puis accordés au cas par
   cas.
7. Appels de fonctions dans les politiques toujours encapsulés dans
   `(select …)` pour une évaluation unique par requête.
   Une politique de **lecture** ne doit jamais dépendre (même via une
   fonction) de la table qu'elle protège : lors d'un `insert … returning`, la
   nouvelle ligne n'est pas encore visible et l'insertion est refusée
   (correctif 002 sur `branches`).
8. Aucune suppression d'opération financière ou de mouvement de stock
   validé ; `audit_log` non modifiable par quiconque (même propriétaire).

## 2. Rôles d'organisation

| Code | Libellé | Portée |
|---|---|---|
| `owner` | Propriétaire | organisation entière ; seul à pouvoir transférer la propriété ou supprimer l'organisation |
| `admin` | Administrateur | organisation entière |
| `manager` | Responsable d'établissement | établissements attribués |
| `cashier` | Caissier | établissements attribués |
| `waiter` | Serveur | établissements attribués |
| `kitchen` | Cuisine / bar | établissements attribués |
| `stock_keeper` | Magasinier | établissements attribués |
| `accountant` | Comptable | établissements attribués (ou tous) |
| `viewer` | Lecteur | établissements attribués (ou tous) |

Une permission de **portée organisation** n'est effective que si l'adhésion
couvre tous les établissements (`all_branches = true`).

## 3. Matrice des permissions

Légende : ● accordé · — refusé. *(org)* = portée organisation.

| Permission | owner | admin | manager | cashier | waiter | kitchen | stock_keeper | accountant | viewer |
|---|---|---|---|---|---|---|---|---|---|
| `org.manage` *(org)* paramètres, marques | ● | ● | — | — | — | — | — | — | — |
| `members.manage` *(org)* employés et rôles | ● | ● | — | — | — | — | — | — | — |
| `billing.manage` *(org)* abonnement | ● | ● | — | — | — | — | — | — | — |
| `audit.read` *(org)* journal d'audit | ● | ● | — | — | — | — | — | ● | — |
| `branches.manage` établissement, salle, horaires | ● | ● | ● | — | — | — | — | — | — |
| `menus.manage` | ● | ● | ● | — | — | — | — | — | — |
| `orders.read` | ● | ● | ● | ● | ● | ● | — | ● | ● |
| `orders.write` créer / modifier avant validation | ● | ● | ● | ● | ● | — | — | — | — |
| `orders.void` annuler après validation | ● | ● | ● | — | — | — | — | — | — |
| `kitchen.operate` statuts de préparation | ● | ● | ● | — | — | ● | — | — | — |
| `reservations.manage` | ● | ● | ● | ● | ● | — | — | — | — |
| `cash.operate` ouvrir caisse, encaisser | ● | ● | ● | ● | — | — | — | — | — |
| `cash.close` valider une clôture et ses écarts | ● | ● | ● | — | — | — | — | — | — |
| `payments.refund` | ● | ● | ● | — | — | — | — | — | — |
| `stock.read` | ● | ● | ● | — | — | ● | ● | ● | ● |
| `stock.write` réceptions, pertes, transferts | ● | ● | ● | — | — | — | ● | — | — |
| `stock.adjust` valider inventaires et ajustements | ● | ● | ● | — | — | — | — | — | — |
| `purchases.manage` fournisseurs, achats | ● | ● | ● | — | — | — | ● | ● | — |
| `expenses.manage` | ● | ● | ● | — | — | — | — | ● | — |
| `finance.read` rapports financiers | ● | ● | ● | — | — | — | — | ● | ● |
| `customers.manage` fidélité, promotions | ● | ● | ● | — | — | — | — | — | — |

La matrice fait foi dans la table `role_permissions` (migration 001) ; ce
tableau doit rester identique (contrôlé par `supabase/tests/001_fondations_tests.sql`).

## 4. Règles d'adhésion

- Création d'organisation : RPC `create_organization`, limitée à 3 créations
  par compte et par 24 h (anti-abus).
- Invitation : RPC `invite_member` (`members.manage`) ; jeton aléatoire de
  32 octets, seul son SHA-256 est stocké ; valable 7 jours, usage unique ;
  l'adresse du compte qui accepte doit correspondre à l'invitation.
- Un `admin` ne peut ni nommer ni modifier un `owner`. Le dernier `owner`
  actif ne peut être retiré ni rétrogradé.
- Révocation : `revoke_membership` ; effet immédiat sur la RLS (les droits
  sont relus à chaque requête, pas mis en cache dans le JWT).

## 5. Personnel de la plateforme

- `platform_staff` est géré uniquement en SQL par le super-administrateur
  (pas d'auto-inscription).
- Il voit les métadonnées nécessaires à son rôle (organisations, statut,
  abonnements, transactions plateforme) via des vues/RPC dédiées.
- Il **ne lit pas** les commandes, clients, stocks ou finances d'un
  restaurant. Exception future (Phase 5) : *accès d'assistance* accordé par
  le propriétaire, limité dans le temps, en lecture seule, journalisé.

## 6. Données personnelles

Collecte minimale (nom affiché, e-mail du compte, téléphone si nécessaire à
la commande/livraison). Documents sensibles dans des buckets **privés**
servis par URL signées courtes. Purge / anonymisation à la suppression du
compte, en conservant les pièces comptables exigées (anonymisées).

## 7. Paiements

- Aucune donnée de carte stockée ni transitant par nos serveurs
  (formulaires hébergés / SDK du prestataire).
- Webhooks : signature vérifiée côté Edge Function ; enregistrement brut ;
  idempotence par `unique (provider, provider_event_id)` ; transition de
  statut par RPC.
- Un paiement en ligne n'est jamais déclaré confirmé par le client.

## 8. Abus, sessions, sauvegardes

- Limitation : compteurs en base pour les RPC sensibles ; captcha
  (Turnstile) sur l'inscription et la récupération de compte (Phase 1, web).
- Sessions : stockage sécurisé (Keychain / Keystore ; IndexedDB sur Web) ;
  déconnexion à la révocation ; 2FA TOTP pour owner/admin et personnel
  plateforme (Phase 7, possible plus tôt).
- Sauvegardes : sauvegardes Supabase + export chiffré périodique ; **test de
  restauration documenté** avant lancement (Phase 7).

## 9. Liste de contrôle avant de déclarer une fonctionnalité terminée

1. Toutes les nouvelles tables ont RLS + politiques + tests multi-organisations.
2. Écritures sensibles par RPC avec contrôle de permission et audit.
3. Contraintes `check` / clés étrangères / unicité couvrant les invariants.
4. Idempotence pour toute opération rejouable (réseau, webhook, hors ligne).
5. Aucun secret ni donnée personnelle superflue dans le code ou les logs.
6. Fonctionne à l'identique sur mobile et web.
