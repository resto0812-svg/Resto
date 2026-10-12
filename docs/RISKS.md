# Resto — Registre des risques

Échelle : probabilité / impact — Faible, Moyen, Élevé.

| # | Risque | P | I | Réponse |
|---|---|---|---|---|
| R1 | Fuite de données entre organisations (politique RLS erronée) | M | É | double barrière RLS + FK composites ; tests multi-organisations à chaque migration |
| R2 | Double comptabilisation d'un paiement (webhook rejoué, réseau, hors ligne) | M | É | clés d'idempotence, contraintes d'unicité, transitions de statut par RPC |
| R3 | Erreurs d'arrondi / monnaies mélangées | M | É | entiers en unités mineures, `minor_unit` ISO, aucun total multi-monnaie sans conversion tracée |
| R4 | Périmètre trop large pour une petite équipe | É | É | phases courtes, un module complet de bout en bout avant le suivant, liste « incomplet » tenue à jour |
| R5 | Prestataires de paiement indisponibles ou non conformes dans certains pays | É | M | connecteurs modulaires, activation pays par pays, pas de simulation en production |
| R6 | Obligations fiscales locales (facturation certifiée, caisse enregistreuse homologuée) | É | É | fiscalité configurable par juridiction ; fonctions réglementées désactivées tant que non validées localement |
| R7 | Conflits hors ligne sur stock / caisse | M | M | deltas append-only, verrou de session de caisse, règles par domaine ([OFFLINE_SYNC.md](OFFLINE_SYNC.md)) |
| R8 | Performance RLS sur gros volumes | M | M | fonctions en `(select …)`, index sur `(organization_id, branch_id, …)`, tests de charge Phase 7 |
| R9 | Flutter Web peu référencé (découverte des restaurants) | M | M | ADR-001 : site public Next.js en lecture seule si nécessaire |
| R10 | Données personnelles (RGPD et lois locales) | M | É | minimisation, buckets privés, anonymisation à la suppression du compte |
| R11 | Perte de données | F | É | sauvegardes Supabase + export chiffré, test de restauration avant lancement |
| R12 | Abus (créations massives, spam d'invitations) | M | M | quotas en base, captcha, limitation par compte |
| R13 | Absence d'environnement local de test SQL | É | M | scripts de contrôle transactionnels annulés, projet « resto-dev » séparé de la production |
