# Resto — Spécification produit

Resto est une plateforme SaaS internationale de restauration réunissant trois
espaces : **Client**, **Restaurant**, **Console de la plateforme**. Ce document
fixe le périmètre, les acteurs, les parcours et les règles métier non
négociables. Le cahier des charges complet de l'utilisateur fait foi ; ce
document en est la version de travail.

## 1. Acteurs

| Acteur | Description | Espace |
|---|---|---|
| Visiteur | Consulte restaurants et menus sans compte | Client |
| Client | Compte personnel : commandes, réservations, paiements, avis, fidélité | Client |
| Propriétaire (owner) | Détient une organisation ; tous les droits sur celle-ci | Restaurant |
| Administrateur d'organisation | Gère l'organisation sans pouvoir la supprimer ni retirer le dernier propriétaire | Restaurant |
| Responsable d'établissement | Gère un ou plusieurs établissements | Restaurant |
| Caissier, serveur, cuisine/bar, magasinier, comptable, lecteur | Rôles opérationnels limités à leurs établissements | Restaurant |
| Personnel plateforme | Support, finance, modération, super-administrateur | Console |

Un même compte peut être client et membre de plusieurs organisations.
Le personnel plateforme **n'a pas** d'accès automatique aux données privées
des restaurants (voir [SECURITY.md](SECURITY.md) §5).

## 2. Hiérarchie

Organisation → Marque (restaurant) → Établissement → Zone de service →
Table / équipement (poste KDS, imprimante, caisse).

Chaque établissement porte ses propres : pays, adresse, fuseau IANA, monnaie,
langues, horaires, profil fiscal, moyens de paiement, canaux, zones de
livraison. Menus, prix, stocks, équipes et caisses peuvent varier par
établissement ; le partage (menu de marque, catalogue d'ingrédients) est
explicite.

## 3. Parcours clés (critères d'acceptation)

1. **Création d'une organisation** : un utilisateur connecté crée son
   organisation, sa marque et son premier établissement en une seule
   opération atomique ; il en devient propriétaire.
2. **Invitation d'un employé** : le responsable invite par e-mail avec un rôle
   et des établissements ; l'invité accepte avec son propre compte ; il ne
   voit que ce que son rôle autorise.
3. **Commande sur place** : serveur ou QR code → articles avec variantes,
   suppléments, instructions → envoi en cuisine (KDS par poste) → service →
   addition (partagée possible) → paiements (fractionnés possibles) → clôture.
4. **Commande en ligne** : client → panier → paiement confirmé par le
   prestataire (webhook vérifié) → préparation → retrait / livraison → reçu.
5. **Réservation** : créneau + couverts → contrôle transactionnel anti
   double-réservation → confirmation → arrivée / retard / annulation.
6. **Caisse** : ouverture avec fond initial → encaissements par moyen →
   entrées / sorties justifiées → clôture : théorique vs compté, écart validé.
7. **Stock** : vente → consommation théorique selon la version de recette ;
   inventaire physique → écarts ; aucun mouvement validé n'est supprimé.
8. **Achat** : commande fournisseur → réception (partielle) → facture → dette
   → paiement.
9. **Multi-établissements** : le propriétaire consolide ses résultats, **par
   monnaie** ou après conversion explicite (taux, source, date conservés).
10. **Monétisation** : abonnement (formule, limites, modules) et commission
    figée sur chaque transaction ; reversement = brut − remboursements −
    commission − frais = net.

## 4. Règles métier non négociables

- Une commande confirmée conserve un **instantané** (libellés, prix, taxes,
  recette applicable) ; les changements ultérieurs ne la modifient pas.
- Statuts **séparés** : commercial, préparation (par article), livraison,
  paiement (dérivé des paiements), table.
- Paiement électronique ≠ espèces. Un paiement en ligne n'est « confirmé »
  qu'après validation serveur du prestataire.
- Aucune suppression d'opération financière ou de mouvement de stock validé :
  annulation / contre-passation tracée avec motif et auteur.
- Montants en **unités mineures entières** avec la monnaie ; jamais de
  flottant ; jamais d'addition de monnaies différentes.
- Chiffre d'affaires ≠ encaissements ≠ achats ≠ consommation ≠ résultat.
- Fiscalité configurée par juridiction, jamais supposée mondiale.
- Fonctions réglementées (paiements, reversements) activées pays par pays
  après validation de disponibilité et de conformité.

## 5. Hors périmètre initial (décisions à prendre plus tard)

- Conservation de fonds / paiements fractionnés par la plateforme (dépend du
  prestataire et de la réglementation : non simulé).
- Intégrations d'agrégateurs de livraison tiers (interface prévue, pas de
  connecteur avant contrat).
- Traduction automatique des menus (séparée de l'interface, validation par le
  restaurant obligatoire).

## 6. Langues de l'interface

Français (source), anglais, allemand, espagnol, portugais, arabe (RTL),
chinois simplifié et traditionnel. Ajout d'une langue = un fichier ARB, sans
modification du code.
