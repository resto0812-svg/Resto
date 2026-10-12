# Resto — Hors ligne et synchronisation

Implémentation : **Phase 6**. Les choix ci-dessous s'imposent dès la Phase 1
pour ne pas avoir à refaire le modèle.

## 1. Ce qui fonctionne hors ligne

| Fonction | Hors ligne | Remarque |
|---|---|---|
| Consultation des menus et prix de l'établissement | oui | cache local, version de menu horodatée |
| Prise de commande sur place, envoi en cuisine local | oui | KDS sur le même réseau local (Phase 6) |
| Encaissement espèces | oui | si la politique de l'établissement l'autorise |
| Encaissement carte / Mobile Money | **non confirmé** | « en attente » tant que le prestataire n'a pas validé |
| Clôture de caisse | non | exige le serveur (calcul théorique de référence) |
| Mouvements de stock | oui (saisie) | appliqués à la synchronisation, jamais « dernier gagnant » |
| Réservations, paiements en ligne, abonnements | non | contrôles transactionnels serveur |

## 2. Données locales

- Base locale chiffrée (SQLite + SQLCipher ou équivalent vérifié en Phase 6),
  clé dans le Keystore / Keychain. Sur le Web : hors ligne limité (cache des
  menus), pas de caisse hors ligne.
- Durée de conservation limitée (ex. 7 jours de commandes synchronisées).
- À la révocation de l'appareil ou de l'adhésion : purge au prochain
  démarrage, refus serveur de tout événement de cet appareil.

## 3. Événements à synchroniser

Chaque opération hors ligne est un événement de la file locale :

| Champ | Rôle |
|---|---|
| `client_event_id` (UUID) | identifiant unique généré localement |
| `device_id` | appareil enregistré (`devices`) |
| `organization_id`, `branch_id` | périmètre |
| `type` | ex. `order.create`, `order.add_items`, `payment.cash`, `stock.waste` |
| `payload` | données de l'opération, ids d'objets générés localement |
| `base_version` | version de l'objet connue au moment de l'opération |
| `occurred_at` | horodatage local + décalage horloge mesuré |
| `state` | `pending` → `sent` → `applied` / `rejected` / `conflict` |

Côté serveur, la RPC `sync_apply(event)` est **idempotente** : la contrainte
`unique (device_id, client_event_id)` garantit qu'un événement rejoué ne
s'applique qu'une fois ; la réponse renvoie le résultat déjà calculé.

## 4. Résolution des conflits par domaine

| Domaine | Règle |
|---|---|
| Commande créée hors ligne | toujours acceptée (id local unique) ; numéro de ticket définitif attribué par le serveur, numéro provisoire préfixé par l'appareil |
| Ajout d'articles | fusion (ajouts commutatifs) ; refus si commande clôturée → conflit à traiter par un responsable |
| Modification / annulation d'article | acceptée si `base_version` à jour, sinon conflit |
| Paiement espèces | accepté et rattaché ; si le total dépasse le dû → excédent signalé, jamais perdu |
| Paiement électronique | jamais confirmé hors ligne ; réconcilié avec le prestataire |
| Stock | les mouvements sont des deltas append-only : tous appliqués ; écarts traités par inventaire, pas par écrasement |
| Caisse | session ouverte sur un seul appareil (verrou serveur) ; mouvements hors ligne rattachés à cette session |
| Données de référence (menus, prix) | le serveur gagne ; la commande garde l'instantané pris hors ligne et le signale si le prix a changé |

## 5. Indicateurs visibles

Pastille d'état (en ligne / hors ligne / n événements en attente / conflit),
liste des événements rejetés avec motif, action « réessayer ».
