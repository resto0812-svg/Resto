// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appName => 'Resto';

  @override
  String environmentBanner(String env) {
    return 'Environnement : $env';
  }

  @override
  String get configMissingTitle => 'Configuration manquante';

  @override
  String get configMissingBody =>
      'L\'adresse du serveur et la clé publique ne sont pas fournies (fichier env/<environnement>.json).';

  @override
  String get languageLabel => 'Langue';

  @override
  String get systemLanguage => 'Langue de l\'appareil';

  @override
  String pendingSyncEvents(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count opérations en attente',
      one: '1 opération en attente',
      zero: 'Tout est synchronisé',
    );
    return '$_temp0';
  }

  @override
  String get errorNotAuthenticated => 'Veuillez vous connecter.';

  @override
  String get errorForbidden =>
      'Vous n\'avez pas le droit d\'effectuer cette action.';

  @override
  String get errorOwnerOnly =>
      'Seul un propriétaire peut effectuer cette action.';

  @override
  String get errorRateLimited => 'Trop de demandes. Réessayez plus tard.';

  @override
  String get errorInvalidTimezone => 'Fuseau horaire inconnu.';

  @override
  String get errorInvalidRole => 'Rôle inconnu.';

  @override
  String get errorInvalidEmail => 'Adresse e-mail invalide.';

  @override
  String get errorInvalidBranch =>
      'Établissement introuvable dans cette organisation.';

  @override
  String get errorBranchesRequired => 'Choisissez au moins un établissement.';

  @override
  String get errorAlreadyMember =>
      'Cette personne fait déjà partie de l\'organisation.';

  @override
  String get errorInvitationInvalid =>
      'Invitation invalide, expirée ou déjà utilisée.';

  @override
  String get errorInvitationWrongAccount =>
      'Cette invitation est destinée à une autre adresse e-mail.';

  @override
  String get errorLastOwner =>
      'L\'organisation doit garder au moins un propriétaire.';

  @override
  String get errorMembershipRevoked =>
      'Ce membre a été retiré de l\'organisation.';

  @override
  String get errorNetwork =>
      'Connexion impossible. Vérifiez votre accès à Internet.';

  @override
  String get errorUnknown => 'Une erreur inattendue s\'est produite.';

  @override
  String get welcomeTitle => 'Bienvenue sur Resto';

  @override
  String get signInTitle => 'Connexion';

  @override
  String get signIn => 'Se connecter';

  @override
  String get signOut => 'Se déconnecter';

  @override
  String get createAccount => 'Créer un compte';

  @override
  String get forgotPassword => 'Mot de passe oublié';

  @override
  String get email => 'E-mail';

  @override
  String get password => 'Mot de passe';

  @override
  String get passwordConfirm => 'Confirmer le mot de passe';

  @override
  String get passwordTooShort => '8 caractères minimum.';

  @override
  String get passwordsDiffer => 'Les mots de passe ne correspondent pas.';

  @override
  String get passwordChanged => 'Mot de passe modifié.';

  @override
  String get newPasswordTitle => 'Nouveau mot de passe';

  @override
  String get changePassword => 'Changer le mot de passe';

  @override
  String get displayName => 'Nom';

  @override
  String get fieldRequired => 'Champ obligatoire';

  @override
  String get verifyEmailTitle => 'Confirmer votre adresse e-mail';

  @override
  String codeSentTo(String email) {
    return 'Code envoyé à $email.';
  }

  @override
  String get code => 'Code';

  @override
  String get verify => 'Valider';

  @override
  String get resendCode => 'Renvoyer le code';

  @override
  String get codeResent => 'Un nouveau code a été envoyé.';

  @override
  String get sendCode => 'Envoyer le code';

  @override
  String get authInvalidCredentials => 'E-mail ou mot de passe incorrect.';

  @override
  String get authEmailNotConfirmed => 'Adresse e-mail non confirmée.';

  @override
  String get authUserExists => 'Un compte existe déjà avec cette adresse.';

  @override
  String get authWeakPassword => 'Mot de passe trop faible.';

  @override
  String get authCodeInvalid => 'Code invalide ou expiré.';

  @override
  String get authSamePassword =>
      'Le nouveau mot de passe doit être différent de l\'ancien.';

  @override
  String get errorDuplicate => 'Cette valeur existe déjà.';

  @override
  String get errorInvalidHours => 'Horaires invalides.';

  @override
  String get createRestaurant => 'Créer mon restaurant';

  @override
  String get joinTeam => 'Rejoindre une équipe';

  @override
  String get organizationName => 'Nom de l\'organisation';

  @override
  String get brandNameOptional => 'Nom commercial (facultatif)';

  @override
  String get branchNameOptional => 'Nom de l\'établissement (facultatif)';

  @override
  String get country => 'Pays';

  @override
  String get currency => 'Monnaie';

  @override
  String get timezone => 'Fuseau horaire';

  @override
  String get defaultLanguage => 'Langue principale';

  @override
  String get city => 'Ville';

  @override
  String get create => 'Créer';

  @override
  String get invitationCode => 'Code d\'invitation';

  @override
  String get join => 'Rejoindre';

  @override
  String get navBranches => 'Établissements';

  @override
  String get navTeam => 'Équipe';

  @override
  String get navAudit => 'Journal';

  @override
  String get navAccount => 'Compte';

  @override
  String get switchOrganization => 'Changer d\'organisation';

  @override
  String get orgSuspended =>
      'Organisation suspendue : consultation uniquement.';

  @override
  String get newBranch => 'Nouvel établissement';

  @override
  String get noBranches => 'Aucun établissement.';

  @override
  String get branchInfo => 'Informations';

  @override
  String get openingHours => 'Horaires';

  @override
  String get floor => 'Salle';

  @override
  String get name => 'Nom';

  @override
  String get addressLine1 => 'Adresse';

  @override
  String get addressLine2 => 'Complément d\'adresse';

  @override
  String get region => 'Région';

  @override
  String get postalCode => 'Code postal';

  @override
  String get phone => 'Téléphone';

  @override
  String get offeredLanguages => 'Langues proposées';

  @override
  String get published => 'Visible par les clients';

  @override
  String get archived => 'Archivé';

  @override
  String get readOnly => 'Consultation uniquement';

  @override
  String get save => 'Enregistrer';

  @override
  String get saved => 'Enregistré.';

  @override
  String get cancel => 'Annuler';

  @override
  String get confirm => 'Confirmer';

  @override
  String get close => 'Fermer';

  @override
  String get edit => 'Modifier';

  @override
  String get retry => 'Réessayer';

  @override
  String get closed => 'Fermé';

  @override
  String get addSlot => 'Ajouter une plage';

  @override
  String get opensAt => 'Ouverture';

  @override
  String get closesAt => 'Fermeture';

  @override
  String get nextDay => 'lendemain';

  @override
  String get weekday1 => 'Lundi';

  @override
  String get weekday2 => 'Mardi';

  @override
  String get weekday3 => 'Mercredi';

  @override
  String get weekday4 => 'Jeudi';

  @override
  String get weekday5 => 'Vendredi';

  @override
  String get weekday6 => 'Samedi';

  @override
  String get weekday7 => 'Dimanche';

  @override
  String get newArea => 'Nouvelle zone';

  @override
  String get areaName => 'Zone';

  @override
  String get noAreas => 'Aucune zone pour l\'instant.';

  @override
  String get newTable => 'Nouvelle table';

  @override
  String get tableLabel => 'Nom de la table';

  @override
  String get seats => 'Places';

  @override
  String get active => 'Actif';

  @override
  String get inactive => 'désactivé';

  @override
  String tablesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tables',
      one: '1 table',
      zero: 'aucune table',
    );
    return '$_temp0';
  }

  @override
  String seatsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count places',
      one: '1 place',
    );
    return '$_temp0';
  }

  @override
  String get invite => 'Inviter';

  @override
  String get role => 'Rôle';

  @override
  String get allBranches => 'Tous les établissements';

  @override
  String get pendingInvitations => 'Invitations en attente';

  @override
  String expiresOn(String date) {
    return 'Expire le $date';
  }

  @override
  String get revoke => 'Retirer';

  @override
  String revokeConfirm(String name) {
    return 'Retirer $name de l\'organisation ?';
  }

  @override
  String get changeRole => 'Modifier le rôle';

  @override
  String get you => 'vous';

  @override
  String get invitationCreatedTitle => 'Invitation créée';

  @override
  String invitationCreatedBody(String email) {
    return 'Transmettez ce code à $email. Il est valable 7 jours et ne fonctionne qu\'avec cette adresse.';
  }

  @override
  String invitationMessage(String organization, String code) {
    return 'Vous êtes invité(e) à rejoindre « $organization » sur Resto. Créez votre compte avec cette adresse e-mail, puis saisissez ce code dans « Rejoindre une équipe » : $code';
  }

  @override
  String get copyMessage => 'Copier le message';

  @override
  String get copied => 'Copié.';

  @override
  String get roleOwner => 'Propriétaire';

  @override
  String get roleAdmin => 'Administrateur';

  @override
  String get roleManager => 'Responsable';

  @override
  String get roleAccountant => 'Comptable';

  @override
  String get roleCashier => 'Caissier';

  @override
  String get roleStockKeeper => 'Magasinier';

  @override
  String get roleWaiter => 'Serveur';

  @override
  String get roleKitchen => 'Cuisine / bar';

  @override
  String get roleViewer => 'Lecteur';

  @override
  String get loadMore => 'Afficher plus';

  @override
  String get noEntries => 'Aucune opération enregistrée.';

  @override
  String get actionInsert => 'Création';

  @override
  String get actionUpdate => 'Modification';

  @override
  String get actionDelete => 'Suppression';

  @override
  String get entityOrganization => 'Organisation';

  @override
  String get entityMembership => 'Membre';

  @override
  String get entityInvitation => 'Invitation';

  @override
  String get entityBrand => 'Marque';

  @override
  String get entityBranch => 'Établissement';

  @override
  String get entityArea => 'Zone';

  @override
  String get entityTable => 'Table';

  @override
  String get navMenus => 'Menus';

  @override
  String get brand => 'Marque';

  @override
  String get category => 'Catégorie';

  @override
  String get description => 'Description';

  @override
  String get newCategory => 'Nouvelle catégorie';

  @override
  String get kindFood => 'Plat';

  @override
  String get kindDrink => 'Boisson';

  @override
  String get kindOther => 'Autre';

  @override
  String selectionRule(int min, String max) {
    return 'Choix : de $min à $max';
  }

  @override
  String get allergens => 'Allergènes';

  @override
  String get allergenGluten => 'Gluten';

  @override
  String get allergenCrustaceans => 'Crustacés';

  @override
  String get allergenEggs => 'Œufs';

  @override
  String get allergenFish => 'Poisson';

  @override
  String get allergenPeanuts => 'Arachides';

  @override
  String get allergenSoybeans => 'Soja';

  @override
  String get allergenMilk => 'Lait';

  @override
  String get allergenNuts => 'Fruits à coque';

  @override
  String get allergenCelery => 'Céleri';

  @override
  String get allergenMustard => 'Moutarde';

  @override
  String get allergenSesame => 'Sésame';

  @override
  String get allergenSulphites => 'Sulfites';

  @override
  String get allergenLupin => 'Lupin';

  @override
  String get allergenMolluscs => 'Mollusques';

  @override
  String get translations => 'Traductions';

  @override
  String get soldOut => 'Épuisé';

  @override
  String get channelDefault => 'Prix de base';

  @override
  String get channelDineIn => 'Sur place';

  @override
  String get channelTakeaway => 'À emporter';

  @override
  String get channelDelivery => 'Livraison';

  @override
  String get otherChannels => 'Prix par canal';

  @override
  String get noPrice => 'Sans prix';

  @override
  String get errorInvalidPrice => 'Prix invalide.';

  @override
  String get errorCurrencyLocked =>
      'La monnaie ne peut plus changer : des prix existent déjà dans cet établissement.';

  @override
  String get entityItem => 'Article';

  @override
  String get entityVariant => 'Variante';

  @override
  String get entityModifier => 'Supplément';

  @override
  String get entityPrice => 'Prix';

  @override
  String get menuOfBranch => 'Menu de l\'établissement';

  @override
  String get menuEmptyTitle => 'Votre menu est vide';

  @override
  String get menuEmptyHint =>
      'Commencez par créer une catégorie (par exemple Plats, Boissons, Desserts), puis ajoutez-y vos articles avec leur prix.';

  @override
  String get categoryExamples => 'Ex. : Plats, Boissons, Desserts';

  @override
  String get descriptionOptional => 'Description (facultatif)';

  @override
  String get visibleOnMenu => 'Visible sur la carte';

  @override
  String get hidden => 'masqué';

  @override
  String get addItem => 'Ajouter un article';

  @override
  String addItemIn(String category) {
    return 'Ajouter un article dans « $category »';
  }

  @override
  String get notSoldHere => 'Pas vendu dans cet établissement';

  @override
  String get itemName => 'Nom de l\'article';

  @override
  String get itemExamples => 'Ex. : Ndolé, Poulet DG, Jus de bissap';

  @override
  String get priceTitle => 'Prix';

  @override
  String priceAt(String branch) {
    return 'Prix à $branch';
  }

  @override
  String get price => 'Prix';

  @override
  String get severalSizes =>
      'Cet article existe en plusieurs tailles ou formats';

  @override
  String get sizeName => 'Taille / format';

  @override
  String get sizeExamples => 'Ex. : Petite, 33 cl';

  @override
  String get addSize => 'Ajouter une taille';

  @override
  String get removeSize => 'Retirer cette taille';

  @override
  String get sizeNameRequired =>
      'Donnez un nom à chaque taille (par exemple Petite, Grande).';

  @override
  String get samePriceEverywhere =>
      'Ce prix s\'appliquera dans tous les établissements choisis ci-dessous ; vous pourrez l\'adapter ensuite pour chacun.';

  @override
  String get salesTitle => 'Vente';

  @override
  String soldAt(String branch) {
    return 'Vendu à $branch';
  }

  @override
  String get soldOutToday => 'Épuisé pour le moment';

  @override
  String get optionsForItem => 'Options proposées au client';

  @override
  String get manageOptions => 'Gérer les options';

  @override
  String get noOptionsYet =>
      'Aucune option pour l\'instant (accompagnement, cuisson, sauce…).';

  @override
  String get optionsTitle => 'Options et suppléments';

  @override
  String get optionsIntro =>
      'Une option est un choix que le client fait en commandant un article : son accompagnement, la cuisson, une sauce, un supplément payant…';

  @override
  String get newOptionGroup => 'Nouvelle option';

  @override
  String get optionGroupName => 'Nom de l\'option';

  @override
  String get optionGroupExamples => 'Ex. : Accompagnement, Cuisson, Piment';

  @override
  String get customerMust => 'Le client :';

  @override
  String get ruleRequiredOne => 'doit faire 1 choix (obligatoire)';

  @override
  String get ruleOptionalOne => 'peut faire 1 choix (facultatif)';

  @override
  String get ruleOptionalMany => 'peut faire plusieurs choix (facultatif)';

  @override
  String get ruleRequiredMany =>
      'doit faire au moins 1 choix, plusieurs possibles';

  @override
  String get choices => 'Choix proposés';

  @override
  String choicePriceHint(String branch) {
    return 'Laissez le prix vide ou à 0 si le choix est gratuit. Prix pour $branch.';
  }

  @override
  String get choiceName => 'Choix';

  @override
  String get choiceExamples => 'Ex. : Miondo, Riz';

  @override
  String get extraPrice => 'Prix en plus';

  @override
  String get addChoice => 'Ajouter un choix';

  @override
  String get removeChoice => 'Retirer ce choix';

  @override
  String get choicesRequired => 'Ajoutez au moins un choix.';

  @override
  String get navOrders => 'Commandes';

  @override
  String openOrdersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count commandes en cours',
      one: '1 commande en cours',
      zero: 'Aucune commande en cours',
    );
    return '$_temp0';
  }

  @override
  String get refresh => 'Actualiser';

  @override
  String get newTakeaway => 'Vente à emporter';

  @override
  String get takeawayOrders => 'À emporter en cours';

  @override
  String orderNumber(int number) {
    return 'Commande n° $number';
  }

  @override
  String minutesAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'il y a $count min',
      one: 'il y a 1 min',
      zero: 'à l\'instant',
    );
    return '$_temp0';
  }

  @override
  String get noTablesYet =>
      'Aucune table : créez la salle dans Établissements → Salle. Les ventes à emporter restent possibles.';

  @override
  String get tableFree => 'Libre';

  @override
  String get toSend => 'Articles à envoyer en cuisine';

  @override
  String tableName(String label) {
    return 'Table $label';
  }

  @override
  String get menuTab => 'Carte';

  @override
  String ticketTab(int count) {
    return 'Commande ($count)';
  }

  @override
  String get allCategories => 'Tout';

  @override
  String get nothingToSell =>
      'Rien à vendre pour l\'instant : ajoutez des articles avec un prix dans Menus.';

  @override
  String fromPrice(String price) {
    return 'dès $price';
  }

  @override
  String itemSoldOut(String name) {
    return '$name est épuisé.';
  }

  @override
  String get emptyTicket => 'Touchez un article de la carte pour l\'ajouter.';

  @override
  String get less => 'Un de moins';

  @override
  String get more => 'Un de plus';

  @override
  String get cancelLine => 'Annuler cette ligne';

  @override
  String get cancelOrder => 'Annuler la commande';

  @override
  String get cancelOrderConfirm =>
      'Annuler cette commande ? Rien n\'est encore parti en cuisine.';

  @override
  String get reason => 'Motif';

  @override
  String get subtotal => 'Sous-total';

  @override
  String taxLine(String rate) {
    return 'Taxe ($rate %)';
  }

  @override
  String get total => 'Total';

  @override
  String taxIncluded(String rate, String amount) {
    return 'dont taxe $rate % : $amount';
  }

  @override
  String sendToKitchen(int count) {
    return 'Envoyer en cuisine ($count)';
  }

  @override
  String sentToKitchen(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count articles envoyés en cuisine',
      one: '1 article envoyé en cuisine',
    );
    return '$_temp0';
  }

  @override
  String get prepPending => 'À envoyer';

  @override
  String get prepSent => 'En cuisine';

  @override
  String get prepPreparing => 'En préparation';

  @override
  String get prepReady => 'Prêt';

  @override
  String get prepServed => 'Servi';

  @override
  String get prepCancelled => 'Annulé';

  @override
  String get noneOption => 'Aucun';

  @override
  String get kitchenNote => 'Remarque pour la cuisine (facultatif)';

  @override
  String get kitchenNoteExamples => 'Ex. : sans oignon, bien cuit';

  @override
  String get quantity => 'Quantité';

  @override
  String addForPrice(String price) {
    return 'Ajouter · $price';
  }

  @override
  String get taxTitle => 'Taxe';

  @override
  String get taxRate => 'Taux de taxe';

  @override
  String get taxRateHint => 'Ex. : 19,25 (0 si aucune taxe)';

  @override
  String get pricesIncludeTax => 'Les prix affichés incluent la taxe';

  @override
  String get errorInvalidTaxRate => 'Taux invalide (de 0 à 99,999).';

  @override
  String get errorOrderNotOpen => 'Cette commande n\'est plus ouverte.';

  @override
  String get errorItemUnavailable =>
      'Cet article n\'est pas disponible dans cet établissement.';

  @override
  String get errorNoPrice =>
      'Cet article n\'a pas de prix dans cet établissement.';

  @override
  String get errorOptionsInvalid =>
      'Les options choisies ne respectent pas les règles de l\'article.';

  @override
  String get errorInvalidQuantity => 'Quantité invalide.';

  @override
  String get errorItemAlreadySent =>
      'Cette ligne est déjà partie en cuisine : elle ne peut plus être modifiée.';

  @override
  String get errorReasonRequired => 'Indiquez un motif.';

  @override
  String get errorInvalidOrder => 'Commande invalide.';

  @override
  String get errorBranchInactive => 'Cet établissement est archivé.';

  @override
  String get navCash => 'Caisse';

  @override
  String get amount => 'Montant';

  @override
  String get registerClosed => 'fermée';

  @override
  String get openRegisterShort => 'Ouvrir la caisse';

  @override
  String openRegister(String name) {
    return 'Ouvrir $name';
  }

  @override
  String get openingFloat => 'Fond de caisse (monnaie de départ)';

  @override
  String registerOpenSince(String time) {
    return 'ouverte depuis $time';
  }

  @override
  String expectedCash(String amount) {
    return 'Espèces attendues : $amount';
  }

  @override
  String cashBreakdown(String float, String inAmount, String outAmount) {
    return 'Fond $float · entrées $inAmount · sorties $outAmount';
  }

  @override
  String paymentsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count paiements',
      one: '1 paiement',
      zero: 'aucun paiement',
    );
    return '$_temp0';
  }

  @override
  String get cashIn => 'Entrée d\'argent';

  @override
  String get cashOut => 'Sortie d\'argent';

  @override
  String get movementExamples => 'Ex. : achat de gaz, apport de monnaie';

  @override
  String get closeRegister => 'Fermer la caisse';

  @override
  String get countedCash => 'Espèces comptées dans le tiroir';

  @override
  String get countInfo =>
      'Comptez les billets et pièces du tiroir, fond de caisse compris.';

  @override
  String get countResult => 'Résultat du comptage';

  @override
  String countedCashValue(String amount) {
    return 'Compté : $amount';
  }

  @override
  String get noDifference => 'Aucun écart';

  @override
  String differenceValue(String amount) {
    return 'Écart : $amount';
  }

  @override
  String get awaitingValidation =>
      'Un responsable doit maintenant valider cette clôture.';

  @override
  String get awaitingValidationTitle => 'Clôtures à valider';

  @override
  String get validateClosing => 'Valider la clôture';

  @override
  String get validate => 'Valider';

  @override
  String get comment => 'Commentaire';

  @override
  String get closedSessions => 'Dernières clôtures';

  @override
  String get dailyReport => 'Rapport du jour';

  @override
  String get previousDay => 'Jour précédent';

  @override
  String get nextDayButton => 'Jour suivant';

  @override
  String get salesTotal => 'Chiffre d\'affaires';

  @override
  String get ordersClosedCount => 'Commandes payées';

  @override
  String get averageTicket => 'Ticket moyen';

  @override
  String get taxCollected => 'Taxe collectée';

  @override
  String get paymentsReceived => 'Encaissements par moyen de paiement';

  @override
  String ordersStillOpen(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count commandes encore en cours',
      one: '1 commande encore en cours',
      zero: 'aucune commande en cours',
    );
    return '$_temp0';
  }

  @override
  String ordersCancelledCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count annulées',
      one: '1 annulée',
      zero: 'aucune annulée',
    );
    return '$_temp0';
  }

  @override
  String linesCancelledCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lignes annulées',
      one: '1 ligne annulée',
      zero: 'aucune ligne annulée',
    );
    return '$_temp0';
  }

  @override
  String refundsTotal(String amount) {
    return 'remboursé : $amount';
  }

  @override
  String get topItems => 'Articles les plus vendus';

  @override
  String get payCash => 'Espèces';

  @override
  String get payCard => 'Carte';

  @override
  String get payMobileMoney => 'Mobile Money';

  @override
  String get payTransfer => 'Virement';

  @override
  String get payOther => 'Autre';

  @override
  String get collectPayment => 'Encaisser';

  @override
  String collectAmount(String amount) {
    return 'Encaisser $amount';
  }

  @override
  String amountDue(String amount) {
    return 'Reste à payer : $amount';
  }

  @override
  String get splitBill => 'Partager l\'addition';

  @override
  String splitParts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count parts',
      one: '1 part',
    );
    return '$_temp0';
  }

  @override
  String get amountToCollect => 'Montant encaissé';

  @override
  String get cashTendered => 'Somme remise par le client (facultatif)';

  @override
  String changeToGive(String amount) {
    return 'À rendre : $amount';
  }

  @override
  String get giveChange => 'Monnaie à rendre';

  @override
  String get transactionReference => 'N° de transaction (facultatif)';

  @override
  String get manualPaymentNote =>
      'Carte et Mobile Money : vérifiez que le paiement est bien reçu avant de valider.';

  @override
  String get openCashFirst => 'Ouvrez d\'abord la caisse (section Caisse).';

  @override
  String get chooseRegister => 'Choisir la caisse';

  @override
  String get orderPaidClosed => 'Commande payée et clôturée.';

  @override
  String get paid => 'Déjà payé';

  @override
  String get remainingDue => 'Reste à payer';

  @override
  String get voided => 'annulé';

  @override
  String get voidPayment => 'Annuler ce paiement';

  @override
  String get orderClosed => 'Commande payée et clôturée';

  @override
  String get orderCancelled => 'Commande annulée';

  @override
  String get errorNoOpenSession =>
      'Aucune caisse ouverte pour cet encaissement.';

  @override
  String get errorSessionAlreadyOpen => 'Cette caisse est déjà ouverte.';

  @override
  String get errorRegisterInactive => 'Cette caisse est désactivée.';

  @override
  String get errorInvalidAmount => 'Montant invalide.';

  @override
  String get errorNotEnoughCash =>
      'Il n\'y a pas assez d\'espèces dans la caisse.';

  @override
  String get errorOverpayment => 'Le montant dépasse le reste à payer.';

  @override
  String get errorTenderedTooLow =>
      'La somme remise est inférieure au montant.';

  @override
  String get errorOrderHasPayments =>
      'Cette commande a déjà des paiements : annulez ou remboursez-les d\'abord.';

  @override
  String get errorPendingLines =>
      'Des articles n\'ont pas encore été envoyés en cuisine.';

  @override
  String get errorNotFullyPaid => 'La commande n\'est pas entièrement payée.';

  @override
  String get errorSessionNotCounted =>
      'Cette caisse n\'a pas encore été comptée.';

  @override
  String get navKitchen => 'Cuisine';

  @override
  String get allStations => 'Tous les postes';

  @override
  String get stations => 'Postes de préparation';

  @override
  String get newStation => 'Nouveau poste';

  @override
  String get stationExamples => 'Ex. : Cuisine, Bar, Grillades';

  @override
  String get stationPrepares => 'Ce poste prépare :';

  @override
  String get kitchenEmpty => 'Rien à préparer pour le moment.';

  @override
  String get allReady => 'Tout est prêt';

  @override
  String get markServed => 'Servi';

  @override
  String get errorInvalidStatus => 'Ce changement d\'état n\'est pas possible.';

  @override
  String get navStock => 'Stocks';

  @override
  String get stockLevels => 'État des stocks';

  @override
  String get ingredientsTab => 'Ingrédients';

  @override
  String get recipesTab => 'Fiches techniques';

  @override
  String get inventoriesTab => 'Inventaires';

  @override
  String get movementsTab => 'Mouvements';

  @override
  String stockValue(String amount) {
    return 'Valeur du stock : $amount';
  }

  @override
  String lowStockCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ingrédients sous le seuil',
      one: '1 ingrédient sous le seuil',
    );
    return '$_temp0';
  }

  @override
  String actionsAt(String location) {
    return 'Mouvements à : $location';
  }

  @override
  String get newLocation => 'Nouvel emplacement';

  @override
  String get locationExamples => 'Ex. : Chambre froide, Cave, Cuisine';

  @override
  String get chooseLocation => 'Choisir l\'emplacement';

  @override
  String get toLocation => 'Vers l\'emplacement';

  @override
  String get noIngredientsYet =>
      'Aucun ingrédient pour l\'instant : ajoutez-en dans l\'onglet Ingrédients.';

  @override
  String alertAt(String qty) {
    return 'alerte à $qty';
  }

  @override
  String avgCost(String amount, String unit) {
    return 'coût moyen $amount / $unit';
  }

  @override
  String get alertThreshold => 'Seuil d\'alerte';

  @override
  String get alertBelow => 'Alerter en dessous de';

  @override
  String get produce => 'Produire';

  @override
  String get adjustmentQuantity => 'Correction (+ ou −)';

  @override
  String unitCost(String unit) {
    return 'Coût par $unit';
  }

  @override
  String get unitPiece => 'pièce';

  @override
  String get unitDozen => 'douzaine';

  @override
  String get newIngredient => 'Nouvel ingrédient';

  @override
  String get ingredientExamples =>
      'Ex. : Poulet, Huile de palme, Bouteille de Coca 33 cl';

  @override
  String get ingredientKind => 'Type';

  @override
  String get stockUnit => 'Unité de stock';

  @override
  String get ingRaw => 'Matière première';

  @override
  String get ingBeverage => 'Boisson';

  @override
  String get ingPackaging => 'Emballage';

  @override
  String get ingSemiFinished => 'Préparation maison';

  @override
  String get ingConsumable => 'Consommable';

  @override
  String get mvOpening => 'Stock initial';

  @override
  String get mvReceipt => 'Entrée (achat)';

  @override
  String get mvSale => 'Vente';

  @override
  String get mvProductionIn => 'Production';

  @override
  String get mvProductionOut => 'Utilisé en production';

  @override
  String get mvWaste => 'Perte / casse';

  @override
  String get mvStaffMeal => 'Repas du personnel';

  @override
  String get mvReturn => 'Retour fournisseur';

  @override
  String get mvTransferIn => 'Transfert reçu';

  @override
  String get mvTransferOut => 'Transfert';

  @override
  String get mvAdjustment => 'Ajustement';

  @override
  String get mvInventory => 'Écart d\'inventaire';

  @override
  String get recipesIntro =>
      'Une fiche technique indique les ingrédients d\'un plat : le stock baisse automatiquement à chaque vente payée et le coût de revient est calculé.';

  @override
  String get noRecipe => 'Sans fiche';

  @override
  String costPrice(String amount) {
    return 'Coût de revient : $amount';
  }

  @override
  String sellingPrice(String amount) {
    return 'prix $amount';
  }

  @override
  String marginPercent(int percent) {
    return 'marge $percent %';
  }

  @override
  String recipeOf(String name) {
    return 'Fiche : $name';
  }

  @override
  String get portions => 'Nombre de portions';

  @override
  String get yieldQuantity => 'Quantité obtenue';

  @override
  String get ingredient => 'Ingrédient';

  @override
  String get wastePercent => 'Perte';

  @override
  String get removeLine => 'Retirer la ligne';

  @override
  String get addIngredientLine => 'Ajouter un ingrédient';

  @override
  String get preparationNotes => 'Notes de préparation (facultatif)';

  @override
  String get newInventory => 'Nouvel inventaire';

  @override
  String get inventoriesIntro =>
      'Un inventaire compare le stock compté au stock calculé ; les écarts sont enregistrés après validation par un responsable.';

  @override
  String inventoryValidated(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'validé, $count écarts',
      one: 'validé, 1 écart',
      zero: 'validé, aucun écart',
    );
    return '$_temp0';
  }

  @override
  String inventoryDraft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'en cours, $count lignes comptées',
      one: 'en cours, 1 ligne comptée',
      zero: 'en cours, rien de compté',
    );
    return '$_temp0';
  }

  @override
  String inventoryOf(String location) {
    return 'Inventaire : $location';
  }

  @override
  String get inventoryHint =>
      'Saisissez ce que vous comptez réellement. Les lignes laissées vides ne sont pas modifiées.';

  @override
  String inventoryDifference(String qty) {
    return 'écart $qty';
  }

  @override
  String get search => 'Rechercher';

  @override
  String get validateInventory => 'Valider l\'inventaire';

  @override
  String get validateInventoryConfirm =>
      'Valider cet inventaire ? Les écarts seront enregistrés dans le stock et l\'inventaire ne pourra plus être modifié.';

  @override
  String inventoryAdjustments(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Inventaire validé : $count écarts enregistrés',
      one: 'Inventaire validé : 1 écart enregistré',
      zero: 'Inventaire validé : aucun écart',
    );
    return '$_temp0';
  }

  @override
  String get errorInvalidMovement => 'Mouvement de stock invalide.';

  @override
  String get errorUnitLocked =>
      'L\'unité de stock ne peut plus changer : cet ingrédient a déjà des mouvements.';

  @override
  String get errorNoRecipe => 'Cette préparation n\'a pas de fiche technique.';

  @override
  String get errorInvalidRecipe =>
      'Fiche technique invalide : vérifiez les ingrédients, quantités et unités.';

  @override
  String get errorInventoryClosed => 'Cet inventaire est déjà validé.';

  @override
  String get navGroupService => 'Service';

  @override
  String get navGroupManagement => 'Gestion';

  @override
  String get navGroupOrganization => 'Organisation';

  @override
  String get navPurchases => 'Achats';

  @override
  String get navExpenses => 'Dépenses';

  @override
  String get navReports => 'Rapports';

  @override
  String get invoicesTab => 'Factures';

  @override
  String get purchaseOrdersTab => 'Bons de commande';

  @override
  String get receiptsTab => 'Réceptions';

  @override
  String get suppliersTab => 'Fournisseurs';

  @override
  String get newSupplier => 'Nouveau fournisseur';

  @override
  String get noSuppliersYet =>
      'Aucun fournisseur pour l\'instant. Ajoutez vos fournisseurs habituels (marché, grossiste, brasserie…).';

  @override
  String get addSupplierFirst =>
      'Ajoutez d\'abord un fournisseur (onglet Fournisseurs).';

  @override
  String get contactName => 'Personne à contacter';

  @override
  String get taxId => 'N° contribuable / fiscal';

  @override
  String get paymentTermsLabel => 'Délai de paiement';

  @override
  String get days => 'jours';

  @override
  String paymentTerms(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'paiement à $days jours',
      one: 'paiement à 1 jour',
    );
    return '$_temp0';
  }

  @override
  String get supplier => 'Fournisseur';

  @override
  String get supplierOptional => 'Fournisseur (facultatif)';

  @override
  String get newPurchaseOrder => 'Nouveau bon de commande';

  @override
  String get noPurchaseOrders =>
      'Aucun bon de commande. Un bon de commande prépare un achat ; à la livraison, « Réceptionner » fait entrer la marchandise en stock.';

  @override
  String poNumber(int number) {
    return 'Bon n° $number';
  }

  @override
  String get poDraft => 'brouillon';

  @override
  String get poSent => 'envoyé';

  @override
  String get poPartial => 'reçu en partie';

  @override
  String get poReceived => 'reçu';

  @override
  String get poCancelled => 'annulé';

  @override
  String get poMarkSent => 'Marquer comme envoyé';

  @override
  String get poReceive => 'Réceptionner';

  @override
  String get poCancel => 'Annuler le bon';

  @override
  String get cancelPoConfirm => 'Annuler ce bon de commande ?';

  @override
  String expectedOn(String date) {
    return 'livraison prévue le $date';
  }

  @override
  String get expectedDateOptional => 'Date de livraison prévue (facultatif)';

  @override
  String unitPrice(String unit) {
    return 'Prix par $unit';
  }

  @override
  String totalAmount(String amount) {
    return 'Total : $amount';
  }

  @override
  String get newReceipt => 'Nouvelle réception';

  @override
  String get receiptsIntro =>
      'Une réception enregistre la marchandise livrée : le stock et le coût moyen sont mis à jour automatiquement.';

  @override
  String receiveOrder(int number) {
    return 'Réception du bon n° $number';
  }

  @override
  String get receiptHint =>
      'Indiquez les quantités réellement livrées et leur prix ; elles entrent en stock dès l\'enregistrement.';

  @override
  String get deliveryNoteNumber => 'N° du bon de livraison (facultatif)';

  @override
  String get recordReceipt => 'Enregistrer la réception';

  @override
  String get receiptRecorded => 'Réception enregistrée : le stock est à jour.';

  @override
  String get newInvoice => 'Nouvelle facture';

  @override
  String get invoicesIntro =>
      'Enregistrez ici les factures de vos fournisseurs pour suivre ce que vous leur devez et vos paiements.';

  @override
  String supplierDebt(String amount) {
    return 'Total dû aux fournisseurs : $amount';
  }

  @override
  String dueOn(String date) {
    return 'échéance le $date';
  }

  @override
  String remaining(String amount) {
    return 'reste $amount';
  }

  @override
  String get invoicePaid => 'payée';

  @override
  String get invoiceCancelled => 'annulée';

  @override
  String get invoiceNumber => 'N° de facture du fournisseur';

  @override
  String invoiceDateValue(String date) {
    return 'Facture du $date';
  }

  @override
  String get dueDateOptional => 'Échéance (facultatif : délai du fournisseur)';

  @override
  String get amountExclTax => 'Montant hors taxe';

  @override
  String get taxAmount => 'Taxe';

  @override
  String get linkedReceipts => 'Réceptions concernées';

  @override
  String get attachDocument => 'Joindre un justificatif (PDF ou photo)';

  @override
  String get fileTooLarge => 'Fichier trop volumineux (5 Mo au plus).';

  @override
  String get viewDocument => 'Voir le justificatif';

  @override
  String get payInvoice => 'Payer';

  @override
  String get cancelInvoice => 'Annuler la facture';

  @override
  String get paidFromRegister => 'Payé avec l\'argent de la caisse';

  @override
  String get newExpense => 'Nouvelle dépense';

  @override
  String get noExpenses => 'Aucune dépense ce mois-ci.';

  @override
  String get previousMonth => 'Mois précédent';

  @override
  String get nextMonth => 'Mois suivant';

  @override
  String includingTax(String amount) {
    return 'dont taxe $amount';
  }

  @override
  String get cancelledLabel => 'annulée';

  @override
  String get cancelExpense => 'Annuler la dépense';

  @override
  String get expenseExamples =>
      'Ex. : facture d\'électricité d\'octobre, réparation du congélateur';

  @override
  String get amountInclTax => 'Montant payé';

  @override
  String get includedTaxOptional => 'Dont taxe (facultatif)';

  @override
  String get expRent => 'Loyer';

  @override
  String get expElectricity => 'Électricité';

  @override
  String get expWater => 'Eau';

  @override
  String get expGas => 'Gaz';

  @override
  String get expSalaries => 'Salaires';

  @override
  String get expTransport => 'Transport';

  @override
  String get expMaintenance => 'Entretien et réparations';

  @override
  String get expMarketing => 'Publicité';

  @override
  String get expSupplies => 'Fournitures';

  @override
  String get expTaxes => 'Impôts et taxes';

  @override
  String get expBankFees => 'Frais bancaires';

  @override
  String get expOther => 'Autres';

  @override
  String get periodToday => 'Aujourd\'hui';

  @override
  String get periodLast7 => '7 derniers jours';

  @override
  String get periodMonth => 'Ce mois-ci';

  @override
  String get periodLastMonth => 'Mois dernier';

  @override
  String get periodCustom => 'Autre période…';

  @override
  String get salesInclTax => 'Chiffre d\'affaires TTC';

  @override
  String get salesExclTax => 'Chiffre d\'affaires HT';

  @override
  String get collected => 'Encaissements';

  @override
  String get costOfSales => 'Coût des ventes';

  @override
  String get grossMargin => 'Marge brute';

  @override
  String get lossesValue => 'Pertes et écarts';

  @override
  String get expensesExclTax => 'Dépenses HT';

  @override
  String get estimatedResult => 'Résultat estimé';

  @override
  String get purchasesValue => 'Achats (factures HT)';

  @override
  String get supplierDebtShort => 'Dû aux fournisseurs';

  @override
  String ordersCountShort(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count commandes',
      one: '1 commande',
      zero: 'aucune commande',
    );
    return '$_temp0';
  }

  @override
  String get ruleSales =>
      'Total des commandes payées et clôturées sur la période (date de service).';

  @override
  String get ruleSalesHt => 'Chiffre d\'affaires TTC moins la taxe collectée.';

  @override
  String get ruleCollected =>
      'Argent réellement reçu sur la période, tous moyens confondus, moins les remboursements. Peut différer du chiffre d\'affaires (acomptes, commandes encore ouvertes).';

  @override
  String get ruleCogs =>
      'Valeur des ingrédients consommés par les ventes, d\'après les fiches techniques et le coût moyen d\'achat. Les plats sans fiche n\'y figurent pas.';

  @override
  String get ruleGrossMargin =>
      'Chiffre d\'affaires HT moins le coût des ventes.';

  @override
  String get ruleLosses =>
      'Valeur des pertes, repas du personnel, ajustements et écarts d\'inventaire.';

  @override
  String get ruleExpenses =>
      'Dépenses enregistrées sur la période, hors taxe (les dépenses annulées sont exclues).';

  @override
  String get ruleResult =>
      'Marge brute moins pertes et dépenses. Estimation de gestion, sans les amortissements ni les charges non saisies : ce n\'est pas un résultat comptable.';

  @override
  String get rulePurchases =>
      'Factures fournisseurs (hors taxe) datées dans la période. Les achats entrent en stock : ils ne sont pas une charge tant qu\'ils ne sont pas consommés.';

  @override
  String get ruleDebt =>
      'Reste à payer sur les factures fournisseurs ouvertes, à ce jour.';

  @override
  String get expensesByCategory => 'Dépenses par catégorie (HT)';

  @override
  String get resultDisclaimer =>
      'Ces chiffres sont calculés à partir des opérations enregistrées dans Resto : ventes, encaissements, consommations théoriques, dépenses. Survolez ⓘ pour la règle de chaque indicateur.';

  @override
  String get exportsTitle => 'Exports (fichiers CSV, ouvrables dans Excel)';

  @override
  String get exportOrders => 'Commandes';

  @override
  String get exportPayments => 'Paiements';

  @override
  String get exportExpenses => 'Dépenses';

  @override
  String get exportDownloaded => 'Fichier téléchargé.';

  @override
  String get exportCopied => 'Données copiées : collez-les dans un tableur.';

  @override
  String get marginsByItem => 'Marge par plat';

  @override
  String marginsHint(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count plats n\'ont pas encore de fiche technique (Stocks → Fiches techniques).',
      one: '1 plat n\'a pas encore de fiche technique (Stocks → Fiches techniques).',
      zero: 'Tous les plats vendus ont une fiche technique.',
    );
    return '$_temp0';
  }

  @override
  String get errorInvalidPurchase =>
      'Achat incomplet : vérifiez le fournisseur, les ingrédients, quantités, unités et prix.';

  @override
  String get errorPurchaseNotDraft =>
      'Ce bon de commande n\'est plus modifiable.';

  @override
  String get errorDuplicateInvoice =>
      'Cette facture de ce fournisseur est déjà enregistrée.';

  @override
  String get errorInvoiceNotOpen => 'Cette facture n\'est plus ouverte.';

  @override
  String get errorInvoiceHasPayments =>
      'Cette facture a des paiements : annulez-les d\'abord.';

  @override
  String get errorInvalidExpense =>
      'Dépense incomplète : catégorie, description et montant sont obligatoires ; la taxe ne peut dépasser le montant.';

  @override
  String get errorInvalidAttachment => 'Justificatif refusé.';

  @override
  String get errorInvalidPeriod => 'Période invalide.';

  @override
  String get errorBelowMinimum => 'Montant minimum de commande non atteint.';

  @override
  String get errorDeliveryUnavailable =>
      'Livraison impossible : vérifiez l\'adresse et le téléphone, ou choisissez « À emporter ».';

  @override
  String get errorInvalidImage =>
      'Photo refusée (format ou emplacement non valide).';

  @override
  String get errorNotFound => 'Introuvable.';

  @override
  String get errorOnlineOrdersClosed =>
      'Ce restaurant ne prend pas de commandes en ligne pour le moment.';

  @override
  String get errorTooLateToCancel =>
      'Trop tard : le restaurant a déjà pris la commande en charge.';

  @override
  String get errorReviewNotAllowed =>
      'Avis impossible : seule une commande payée, de moins de 30 jours, peut être notée une fois.';

  @override
  String get errorReservationsClosed =>
      'Ce restaurant ne prend pas de réservations en ligne.';

  @override
  String get errorInvalidPartySize =>
      'Nombre de personnes non accepté pour une réservation en ligne.';

  @override
  String get errorInvalidReservationTime =>
      'Horaire non valide : au moins 15 minutes à l\'avance et au plus 90 jours.';

  @override
  String get errorInvalidReservation =>
      'Réservation incomplète : nom, téléphone et nombre de personnes sont nécessaires.';

  @override
  String get errorTablesRequired => 'Choisissez au moins une table.';

  @override
  String get errorNotEnoughSeats =>
      'Pas assez de places sur les tables choisies.';

  @override
  String get errorTableUnavailable =>
      'Cette table est déjà réservée sur ce créneau.';

  @override
  String get errorPromotionUnavailable => 'Promotion ou code non valable.';

  @override
  String get errorPromotionLimit =>
      'Ce client a déjà utilisé cette promotion le nombre de fois permis.';

  @override
  String get errorPromotionAlreadyApplied => 'Déjà appliquée à cette commande.';

  @override
  String get errorNotEnoughPoints => 'Pas assez de points de fidélité.';

  @override
  String get errorAddressRequired => 'Adresse de livraison obligatoire.';

  @override
  String get errorTableBusy => 'Cette table a déjà une commande en cours.';

  @override
  String errorBetween(int min, int max) {
    return 'Entre $min et $max';
  }

  @override
  String get notPublishedHint =>
      'Cet établissement n\'est pas encore visible des clients : activez « Publié » dans l\'onglet Informations.';

  @override
  String get onlineOrdersTitle => 'Commandes en ligne';

  @override
  String get acceptOnlineOrders => 'Accepter les commandes des clients';

  @override
  String get acceptOnlineOrdersHint =>
      'Depuis l\'application, le site ou le QR code des tables. Chaque commande arrive dans « Commandes » pour être acceptée.';

  @override
  String get acceptDelivery => 'Proposer la livraison';

  @override
  String get deliveryFee => 'Frais de livraison';

  @override
  String get minimumOrder => 'Commande minimum';

  @override
  String get reservationsTitle => 'Réservations';

  @override
  String get acceptReservations => 'Accepter les réservations en ligne';

  @override
  String get reservationDuration => 'Durée d\'une réservation';

  @override
  String get minutesShort => 'min';

  @override
  String get maxPartySize => 'Personnes au maximum';

  @override
  String get publicProfileTitle => 'Fiche publique du restaurant';

  @override
  String get publicDescription => 'Présentation';

  @override
  String get publicDescriptionHint =>
      'Ex. : cuisine camerounaise généreuse, poissons braisés du jour, terrasse ombragée.';

  @override
  String get cuisinesLabel => 'Types de cuisine';

  @override
  String get cuisinesHint =>
      'Ex. : africaine, grillades, fruits de mer (séparés par des virgules)';

  @override
  String get priceLevel => 'Gamme de prix';

  @override
  String get publicPageTitle => 'Page du restaurant';

  @override
  String get publicPageHint =>
      'À partager (réseaux sociaux, WhatsApp) ou à imprimer : les clients y voient la carte et commandent.';

  @override
  String get copyLink => 'Copier le lien';

  @override
  String get sourcePhone => 'Par téléphone';

  @override
  String get sourceQr => 'QR code de la table';

  @override
  String get sourceApp => 'Application client';

  @override
  String get sourcePartner => 'Partenaire';

  @override
  String get sourceStaff => 'Prise en salle';

  @override
  String get stageToValidate => 'À valider';

  @override
  String get stageDraft => 'Pas encore envoyée';

  @override
  String get stageCooking => 'En préparation';

  @override
  String get stageReady => 'Prête à servir';

  @override
  String get stageReadyTakeaway => 'Prête à remettre';

  @override
  String get stageReadyDelivery => 'Prête pour le livreur';

  @override
  String get stageToPay => 'À encaisser';

  @override
  String get stageDone => 'Terminée';

  @override
  String get stageCancelled => 'Annulée';

  @override
  String get handToCustomer => 'Remise au client';

  @override
  String get handToCourier => 'Remise au livreur';

  @override
  String guestsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count personnes',
      one: '1 personne',
    );
    return '$_temp0';
  }

  @override
  String forTime(String time) {
    return 'Pour $time';
  }

  @override
  String get billTitle => 'Addition';

  @override
  String get thankYou => 'Merci de votre visite !';

  @override
  String kdsToPrepare(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count commandes à préparer',
      one: '1 commande à préparer',
      zero: 'Rien à préparer',
    );
    return '$_temp0';
  }

  @override
  String kdsLate(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count en retard',
      one: '1 en retard',
    );
    return '$_temp0';
  }

  @override
  String kdsReadyCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count prêtes',
      one: '1 prête',
      zero: 'Aucune prête',
    );
    return '$_temp0';
  }

  @override
  String get kdsTickets => 'Tickets';

  @override
  String get kdsSummary => 'Cumul';

  @override
  String get kdsFullScreen => 'Plein écran (mode cuisine)';

  @override
  String get kdsFlowHint =>
      'Les commandes envoyées par la salle arrivent ici avec une sonnerie. Touchez un article pour le passer « en préparation » puis « prêt ». « Tout est prêt » prévient aussitôt les serveurs.';

  @override
  String get kdsReadyStrip =>
      'Prêtes — la salle est prévenue (colonne « Prêtes à servir »), en attente de service';

  @override
  String get kdsStart => 'Commencer';

  @override
  String kdsWaitingService(String time) {
    return 'attend depuis $time';
  }

  @override
  String get kdsRecall => 'Rappeler (pas encore prête)';

  @override
  String get serviceAndCustomers => 'Service & clients';

  @override
  String get serviceSettingsTitle => 'Service';

  @override
  String get targetPrepTime => 'Temps de préparation visé';

  @override
  String get targetPrepTimeHint =>
      'Au-delà, la commande passe en rouge (en retard).';

  @override
  String get payFirstTakeaway =>
      'Vente à emporter : faire payer avant la préparation';

  @override
  String get payFirstTakeawayHint =>
      'Le bouton « Encaisser puis envoyer » apparaît sur les commandes à emporter.';

  @override
  String get tableOccupied => 'Occupée';

  @override
  String get tableReservedNow => 'Réservée maintenant';

  @override
  String get tableReservedSoon => 'Réservée bientôt';

  @override
  String reservedAt(String time) {
    return 'Réservée à $time';
  }

  @override
  String get acceptWithDelay => 'Accepter la commande';

  @override
  String scheduledFor(String time) {
    return 'Demandée pour $time';
  }

  @override
  String get delayAnnounced =>
      'Dans combien de temps sera-t-elle prête ? Le client est prévenu.';

  @override
  String get orderAccepted => 'Commande acceptée : elle part en préparation.';

  @override
  String get rejectOrder => 'Refuser la commande';

  @override
  String get rejectReasonHint =>
      'Ex. : rupture de poisson, livreur indisponible';

  @override
  String get paymentDone => 'Paiement enregistré.';

  @override
  String get partialPaymentDone => 'Paiement partiel enregistré.';

  @override
  String get announcedDelay => 'Délai annoncé au client';

  @override
  String promisedFor(String time) {
    return 'Promise pour $time';
  }

  @override
  String get heldShort => 'à suivre';

  @override
  String moreItems(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '+ $count autres articles',
      one: '+ 1 autre article',
    );
    return '$_temp0';
  }

  @override
  String get paidShort => 'Payée';

  @override
  String get partlyPaid => 'Payée en partie';

  @override
  String get notPaid => 'Non payée';

  @override
  String get reject => 'Refuser';

  @override
  String get accept => 'Accepter';

  @override
  String get sendShort => 'Envoyer';

  @override
  String get fireNext => 'Lancer la suite';

  @override
  String get collectShort => 'Encaisser';

  @override
  String get columnInProgress => 'En cours';

  @override
  String get columnReady => 'Prêtes à servir';

  @override
  String get columnToValidateHint =>
      'Les commandes passées par les clients (application, site, QR code des tables) arrivent ici avec une sonnerie. Acceptez-les en annonçant un délai.';

  @override
  String get columnInProgressHint =>
      'Commandes prises et en préparation. « Envoyer » fait partir les articles en cuisine et au bar.';

  @override
  String get columnReadyHint =>
      'Quand la cuisine appuie sur « Tout est prêt », la commande arrive ici (avec une sonnerie) : à servir à table, à remettre au client ou au livreur.';

  @override
  String get columnToPayHint =>
      'Tout est servi : il reste à encaisser. Une fois payée, la commande se termine et la table se libère.';

  @override
  String get allOrders => 'Toutes';

  @override
  String get searchOrderHint => 'N°, client, table, téléphone';

  @override
  String get chooseTable => 'Choisissez la table';

  @override
  String get tableHasOrder =>
      'Cette table a déjà une commande en cours : elle va s\'ouvrir.';

  @override
  String tableReservationWarning(String time, String name, int count) {
    return 'Attention : réservée à $time · $name · $count pers.';
  }

  @override
  String get guestsLabel => 'Nombre de personnes';

  @override
  String get receivedByPhone => 'Commande reçue par téléphone';

  @override
  String get customerName => 'Nom du client';

  @override
  String get customerNameOptional => 'Nom du client (facultatif)';

  @override
  String get phoneOptional => 'Téléphone (facultatif)';

  @override
  String get deliveryAddress => 'Adresse de livraison';

  @override
  String get deliveryAddressHint =>
      'Quartier, rue, repère (ex. : Bonamoussadi, près de la pharmacie)';

  @override
  String get deliveryInstructions => 'Indications pour le livreur';

  @override
  String get deliveryInstructionsHint =>
      'Ex. : immeuble jaune, 2e étage, appeler en arrivant';

  @override
  String get deliveryTime => 'Heure de livraison';

  @override
  String get pickupTime => 'Heure de retrait';

  @override
  String get asap => 'Dès que possible';

  @override
  String get atFixedTime => 'À une heure précise';

  @override
  String atTime(String time) {
    return 'À $time';
  }

  @override
  String get newOrder => 'Nouvelle commande';

  @override
  String get orderTypeQuestion => 'Quel type de commande ?';

  @override
  String get dineInHint => 'Client installé à une table';

  @override
  String get takeawayHint => 'Le client repart avec sa commande';

  @override
  String get deliveryHint => 'Livrée à une adresse';

  @override
  String get orderNote => 'Remarque sur la commande (facultatif)';

  @override
  String get orderNoteHint =>
      'Ex. : anniversaire, client pressé, allergie aux arachides';

  @override
  String get continueToMenu => 'Continuer : choisir les plats';

  @override
  String get moveTable => 'Changer de table';

  @override
  String get noFreeTable => 'Aucune table libre pour le moment.';

  @override
  String get print => 'Imprimer';

  @override
  String get printKitchenTicket => 'Bon de préparation (cuisine)';

  @override
  String get printBill => 'Addition (client)';

  @override
  String get orderHistory => 'Historique de la commande';

  @override
  String get searchDish => 'Rechercher un plat, une boisson…';

  @override
  String get noResults => 'Aucun résultat.';

  @override
  String get groupToSend => 'À envoyer';

  @override
  String get groupHeld => 'À suivre (envoyés plus tard)';

  @override
  String get groupCooking => 'En préparation';

  @override
  String get groupReady => 'Prêts à servir';

  @override
  String get groupServed => 'Servis';

  @override
  String get groupCancelled => 'Annulés';

  @override
  String collectThenSend(String amount) {
    return 'Encaisser $amount puis envoyer';
  }

  @override
  String fireNextCount(int count) {
    return 'Lancer la suite ($count)';
  }

  @override
  String get customerOrderToValidate => 'Commande d\'un client à valider';

  @override
  String get customerOrderToValidateHint =>
      'Vérifiez les articles puis acceptez (avec un délai) ou refusez. Le client est prévenu.';

  @override
  String get payFirstHint =>
      'Vente à emporter : paiement avant la préparation (réglage de l\'établissement).';

  @override
  String get addedByCustomer => 'ajouté par le client';

  @override
  String get sendWithOrder => 'Envoyer avec le reste';

  @override
  String get holdForLater => 'Mettre « à suivre » (envoyé plus tard)';

  @override
  String openedAt(String time) {
    return 'ouverte à $time';
  }

  @override
  String get fromReservation => 'Clients installés (réservation)';

  @override
  String get editOrderDetails => 'Modifier les informations';

  @override
  String get evOpened => 'Commande ouverte';

  @override
  String evItemAdded(String item) {
    return 'Ajout : $item';
  }

  @override
  String get evItemUpdated => 'Article modifié';

  @override
  String get evItemRemoved => 'Article retiré';

  @override
  String evSent(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Envoyé en cuisine ($count articles)',
      one: 'Envoyé en cuisine (1 article)',
    );
    return '$_temp0';
  }

  @override
  String get evItemCancelled => 'Article annulé';

  @override
  String get evCancelled => 'Commande annulée';

  @override
  String get evClosed => 'Commande terminée';

  @override
  String evPayment(String amount) {
    return 'Paiement de $amount';
  }

  @override
  String get evRefund => 'Remboursement';

  @override
  String get evDetailsUpdated => 'Informations modifiées';

  @override
  String get itemsTotal => 'Articles';

  @override
  String get removeDiscount => 'Retirer la réduction';

  @override
  String get addDiscount => 'Ajouter une réduction';

  @override
  String get applyPromotion => 'Appliquer une promotion';

  @override
  String get promoCode => 'Code promo';

  @override
  String get promoCodeHint => 'Ex. : BIENVENUE10';

  @override
  String get manualDiscount => 'Remise (geste commercial)';

  @override
  String get useLoyalty => 'Utiliser les points de fidélité';

  @override
  String get noActivePromotion =>
      'Aucune promotion en cours. Créez-en dans « Clients & fidélité ».';

  @override
  String get inPercent => 'En %';

  @override
  String get inAmount => 'En montant';

  @override
  String get percentValue => 'Pourcentage';

  @override
  String get manualDiscountHint => 'Ex. : attente trop longue, client fidèle';

  @override
  String get apply => 'Appliquer';

  @override
  String get allAreas => 'Toutes les zones';

  @override
  String get planView => 'Plan';

  @override
  String get cardsView => 'Cartes';

  @override
  String get editFloor => 'Modifier la salle';

  @override
  String get done => 'Terminé';

  @override
  String get floorEmptyTitle => 'Créez votre salle';

  @override
  String get floorEmptyHint =>
      'Ajoutez d\'abord vos zones (Salle, Terrasse, VIP…), puis vos tables avec le nom que vous voulez (Table 1, VIP 1, Bar 2…). Vous verrez ensuite en direct quelles tables sont libres, occupées ou réservées.';

  @override
  String get editFloorHint =>
      'Faites glisser les tables pour reproduire votre salle. Touchez une table pour la renommer, changer ses places ou sa forme.';

  @override
  String get noTablesInArea =>
      'Aucune table dans cette zone : « Modifier la salle » puis « Nouvelle table ».';

  @override
  String get newOrderAtTable => 'Nouvelle commande à cette table';

  @override
  String get openOrder => 'Ouvrir la commande';

  @override
  String get reservationsToday => 'Réservations du jour';

  @override
  String get reserveTable => 'Réserver';

  @override
  String get noReservationToday =>
      'Aucune réservation aujourd\'hui pour cette table.';

  @override
  String get tableQrCode => 'QR code de la table';

  @override
  String get tableQrHint =>
      'À imprimer et poser sur la table : le client scanne, voit la carte avec les photos et commande. La commande arrive dans « À valider ».';

  @override
  String get areaNameHint => 'Ex. : Salle, Terrasse, VIP, Étage';

  @override
  String get tableLabelHint => 'Ex. : Table 1, VIP 1, Bar 2';

  @override
  String get tableShape => 'Forme';

  @override
  String get shapeSquare => 'Carrée';

  @override
  String get shapeRound => 'Ronde';

  @override
  String get shapeRect => 'Rectangulaire';

  @override
  String get resRequested => 'Demandée';

  @override
  String get resConfirmed => 'Confirmée';

  @override
  String get resSeated => 'Installés';

  @override
  String get resCompleted => 'Terminée';

  @override
  String get resNoShow => 'Absents';

  @override
  String get resDeclined => 'Refusée';

  @override
  String get resCancelled => 'Annulée';

  @override
  String reservationRequests(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count demandes de réservation à traiter',
      one: '1 demande de réservation à traiter',
    );
    return '$_temp0';
  }

  @override
  String get reservationRequestsHint =>
      'Demandes faites par les clients en ligne : confirmez en choisissant les tables, ou refusez avec un motif. Le client est prévenu.';

  @override
  String get declineReservation => 'Refuser la réservation';

  @override
  String get confirmReservation => 'Confirmer';

  @override
  String reservationsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count réservations',
      one: '1 réservation',
      zero: 'Aucune réservation',
    );
    return '$_temp0';
  }

  @override
  String coversCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count couverts',
      one: '1 couvert',
      zero: '0 couvert',
    );
    return '$_temp0';
  }

  @override
  String get noReservationsDay => 'Aucune réservation ce jour-là.';

  @override
  String get today => 'Aujourd\'hui';

  @override
  String get timelineView => 'Planning';

  @override
  String get listView => 'Liste';

  @override
  String get newReservation => 'Nouvelle réservation';

  @override
  String get nowLabel => 'maintenant';

  @override
  String get seatGuests => 'Installer les clients';

  @override
  String get changeTables => 'Changer de tables';

  @override
  String get markNoShow => 'Absents';

  @override
  String get cancelReservation => 'Annuler la réservation';

  @override
  String get markCompleted => 'Terminée';

  @override
  String get chooseTables => 'Tables';

  @override
  String seatsForParty(int seats, int party) {
    return '$seats places choisies pour $party personnes';
  }

  @override
  String get reservationNoteHint =>
      'Ex. : anniversaire, chaise bébé, près de la fenêtre';

  @override
  String get noFreeTableSlot =>
      'Aucune table libre sur ce créneau : changez l\'heure ou la durée.';

  @override
  String itemsCountLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count articles',
      one: '1 article',
      zero: 'aucun article',
    );
    return '$_temp0';
  }

  @override
  String get alertNewCustomerOrder =>
      'Nouvelle commande d\'un client à valider';

  @override
  String get alertOrderReady => 'Une commande est prête à servir';

  @override
  String get view => 'Voir';

  @override
  String ordersToValidateBanner(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count commandes clients attendent votre validation',
      one: '1 commande client attend votre validation',
    );
    return '$_temp0';
  }

  @override
  String get tabInProgress => 'En cours';

  @override
  String get historyTab => 'Historique';

  @override
  String get newShort => 'Nouvelle';

  @override
  String get brandPoint1 =>
      'Commandes en salle, à emporter, en livraison et en ligne';

  @override
  String get brandPoint2 => 'Cuisine et bar en direct, salle et réservations';

  @override
  String get brandPoint3 => 'Caisse, stocks, achats et dépenses';

  @override
  String get brandPoint4 => 'Tableaux de bord et rapports professionnels';

  @override
  String get authWelcome => 'Bienvenue';

  @override
  String get authWelcomeSub => 'Connectez-vous pour retrouver votre restaurant';

  @override
  String get noAccountYet => 'Pas encore de compte ?';

  @override
  String get alreadyAccount => 'Déjà un compte ?';

  @override
  String get authSignUpSub =>
      'Quelques secondes pour commencer, sans engagement';

  @override
  String get authForgotSub =>
      'Recevez un code par e-mail pour choisir un nouveau mot de passe';

  @override
  String get authNewPasswordSub => 'Au moins 8 caractères';

  @override
  String get navHome => 'Accueil';

  @override
  String get greetingDay => 'Bonjour';

  @override
  String get greetingEvening => 'Bonsoir';

  @override
  String get moreModules => 'Plus';

  @override
  String freeTablesCount(int free, int total) {
    return '$free tables libres sur $total';
  }

  @override
  String suggestedTable(String label, int seats) {
    return 'Suggestion : $label ($seats places)';
  }

  @override
  String get slotFreeSoon => 'Libre avant l\'heure';

  @override
  String get slotReserved => 'Réservée sur ce créneau';

  @override
  String freeAround(String time) {
    return 'libre vers $time';
  }

  @override
  String get timelineEmptyHint =>
      'Aucune réservation ce jour-là. Touchez une heure sur la ligne d\'une table pour la réserver.';

  @override
  String get myAccount => 'Mon compte';

  @override
  String get brandTagline => 'La gestion de restaurant, fluide et limpide.';

  @override
  String get addPaymentMethod => 'Ajouter un mode';

  @override
  String get allMethods => 'Tous les modes';

  @override
  String get availableInBranches => 'Disponible dans';

  @override
  String get availableWorldwide => 'Valables partout';

  @override
  String get blindCountHint =>
      'Comptez le tiroir sans regarder l\'attendu : l\'écart s\'affiche une fois le comptage enregistré.';

  @override
  String get cashDrawer => 'Tiroir-caisse';

  @override
  String get cashMovementsTitle => 'Entrées et sorties d\'espèces';

  @override
  String get cashReportTitle => 'Rapport de caisse';

  @override
  String get cashierLabel => 'Caissier';

  @override
  String get choosePaymentMethod => 'Choisissez le mode de paiement.';

  @override
  String get closingValidated => 'Clôture validée : Z numéroté.';

  @override
  String get closingsTab => 'Clôtures';

  @override
  String get coinsLabel => 'Pièces';

  @override
  String get collectTab => 'Encaisser';

  @override
  String collectWithTip(String amount, String tip) {
    return 'Encaisser $amount + $tip';
  }

  @override
  String get collectedByDay => 'Encaissé par jour';

  @override
  String get collectedByHour => 'Encaissé par heure';

  @override
  String get collectedTotal => 'Encaissé';

  @override
  String commonInCountry(String country) {
    return 'Courants dans votre pays ($country)';
  }

  @override
  String get countByDenomination => 'Billet par billet';

  @override
  String countConfirm(String amount) {
    return 'Confirmer le comptage : $amount ?';
  }

  @override
  String get countDetailTitle => 'Détail du comptage';

  @override
  String get countRecorded => 'Comptage enregistré';

  @override
  String get countedLabel => 'Comptée';

  @override
  String get countedTotal => 'Total compté';

  @override
  String get customMethod => 'Mode personnalisé';

  @override
  String get customMethodHint =>
      'Ex. : bon maison, carte fidélité, paiement par lien';

  @override
  String get dateLabel => 'Date';

  @override
  String get differenceLabel => 'Écart';

  @override
  String get differenceReasonHint =>
      'Ex. : erreur de rendu de monnaie, billet abîmé';

  @override
  String get discountsTotal => 'Réductions';

  @override
  String get displayOrder => 'Ordre';

  @override
  String get enterAmount => 'Saisir le montant';

  @override
  String get errorPaymentMethodUnavailable =>
      'Ce mode de paiement n\'est pas disponible ici.';

  @override
  String get errorReferenceRequired =>
      'Saisissez le n° de transaction (référence du paiement).';

  @override
  String get exactAmount => 'Montant exact';

  @override
  String get exportExcel => 'Exporter (tableur)';

  @override
  String get exportPdf => 'Exporter en PDF';

  @override
  String get feePercentLabel => 'Commission prélevée';

  @override
  String feeShort(String percent) {
    return 'commission $percent %';
  }

  @override
  String get feesEstimate => 'Commissions (estimation)';

  @override
  String get findTicket => 'Retrouver un ticket';

  @override
  String get lastPayments => 'Derniers paiements';

  @override
  String get legalNameLabel => 'Raison sociale';

  @override
  String get managerMustValidate => 'Un responsable doit valider la clôture.';

  @override
  String get methodKind => 'Type';

  @override
  String get mySessionTab => 'Ma caisse';

  @override
  String get newRegister => 'Nouvelle caisse';

  @override
  String get noActiveRegister =>
      'Aucune caisse active : créez-en une dans Réglages.';

  @override
  String get noClosings => 'Aucune clôture pour l\'instant.';

  @override
  String get noMovements => 'Aucun mouvement.';

  @override
  String get noPaymentMethod =>
      'Aucun mode de paiement actif : ajoutez-en dans Réglages.';

  @override
  String get noPaymentsYet => 'Aucun paiement pour l\'instant.';

  @override
  String get noRefunds => 'Aucun remboursement ces 30 derniers jours.';

  @override
  String get noTip => 'Aucun';

  @override
  String get notesLabel => 'Billets';

  @override
  String get nothingToCollect => 'Rien à encaisser pour le moment.';

  @override
  String get openRegisterHint =>
      'Comptez le fond de caisse (la monnaie de départ) : il servira de base au comptage de fin de service.';

  @override
  String openRegisterTitle(String register) {
    return 'Ouvrir $register';
  }

  @override
  String get openedLabel => 'Ouverture';

  @override
  String get orderDetails => 'Détail de la commande';

  @override
  String get orderShort => 'Commande';

  @override
  String get otherAmount => 'Autre montant';

  @override
  String get otherCountries => 'Autres pays';

  @override
  String get payKindAccount => 'Compte client';

  @override
  String get payKindCheque => 'Chèque';

  @override
  String get payKindInstant => 'Paiement instantané';

  @override
  String get payKindVoucher => 'Titre ou bon';

  @override
  String get payKindWallet => 'Portefeuille mobile';

  @override
  String get paymentComplete => 'Paiement terminé';

  @override
  String get paymentMethodLabel => 'Mode de paiement';

  @override
  String get paymentMethodsHint =>
      'Les modes proposés à l\'encaissement. Adaptez-les à votre pays : nom, n° de transaction obligatoire, commission, établissements.';

  @override
  String get paymentMethodsTitle => 'Modes de paiement';

  @override
  String get paymentsCountShort => 'Paiements';

  @override
  String get periodYesterday => 'Hier';

  @override
  String get printCountReport => 'Imprimer le comptage';

  @override
  String get printReceipt => 'Imprimer le ticket';

  @override
  String get reasonChangeFloat => 'Apport de monnaie';

  @override
  String get reasonOtherIn => 'Autre entrée';

  @override
  String get reasonOtherOut => 'Autre sortie';

  @override
  String get reasonSafeDrop => 'Dépôt au coffre';

  @override
  String get reasonSmallPurchase => 'Petit achat';

  @override
  String get reasonTipsPaid => 'Pourboires remis à l\'équipe';

  @override
  String get receiptFooterHint =>
      'Ex. : Merci et à bientôt ! Wi-Fi : RestoInvite';

  @override
  String get receiptFooterLabel => 'Message en bas du ticket';

  @override
  String receiptNumberLabel(int number) {
    return 'Ticket n° $number';
  }

  @override
  String get receiptSettingsHint =>
      'Imprimés sur chaque ticket client et sur les Z de caisse.';

  @override
  String get receiptSettingsTitle => 'Mentions du ticket';

  @override
  String get receiptShort => 'Ticket';

  @override
  String receiptTaxId(String id) {
    return 'N° fiscal : $id';
  }

  @override
  String get recentRefunds => 'Remboursements récents';

  @override
  String get recordCount => 'Enregistrer le comptage';

  @override
  String get referenceRequiredShort => 'n° de transaction obligatoire';

  @override
  String get refundAction => 'Rembourser';

  @override
  String get refundDone => 'Remboursement enregistré.';

  @override
  String get refundReasonHint => 'Ex. : plat refusé, erreur de saisie';

  @override
  String get refundTitle => 'Rembourser le client';

  @override
  String refundableAmount(String amount) {
    return 'remboursable : $amount';
  }

  @override
  String get refundsTab => 'Remboursements';

  @override
  String get registerClosedHint =>
      'Ouvrez la caisse (fond compté) pour encaisser.';

  @override
  String get registerClosedTitle => 'Caisse fermée';

  @override
  String get registerLabel => 'Caisse';

  @override
  String get registerNameHint => 'Ex. : Comptoir, Terrasse, Bar';

  @override
  String get registersTitle => 'Caisses';

  @override
  String get reportsTab => 'Rapports';

  @override
  String get requireReferenceHint =>
      'Le caissier doit saisir le n° de transaction (rapprochement avec le relevé).';

  @override
  String get requireReferenceLabel => 'N° de transaction obligatoire';

  @override
  String get salesByDay => 'Par jour';

  @override
  String get salesByMethod => 'Par mode de paiement';

  @override
  String get salesByRegister => 'Par caisse';

  @override
  String get salesByStaff => 'Par serveur';

  @override
  String get searchAction => 'Rechercher';

  @override
  String get searchMethodOrCountry => 'Nom du mode ou code pays (ex. BR)';

  @override
  String get sendWhatsApp => 'Envoyer par WhatsApp';

  @override
  String get sessionAwaitingValidation => 'Comptée — en attente de validation';

  @override
  String get settingsTab => 'Réglages';

  @override
  String get shareReceipt => 'Partager le ticket';

  @override
  String get signatureCashier => 'Signature caissier';

  @override
  String get signatureManager => 'Signature responsable';

  @override
  String someBranchesOnly(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count établissements',
      one: '1 établissement',
    );
    return '$_temp0';
  }

  @override
  String get splitAll => 'Tout';

  @override
  String get splitByItems => 'Par articles';

  @override
  String get splitByParts => 'Par parts';

  @override
  String get splitCustom => 'Montant libre';

  @override
  String get staffLabel => 'Serveur';

  @override
  String get statusLabel => 'État';

  @override
  String get taxIdHint => 'Numéro d\'identification fiscale de votre pays';

  @override
  String get taxIdLabel => 'N° d\'identification fiscale';

  @override
  String get ticketOrOrderNumber => 'N° de ticket ou de commande';

  @override
  String get tipLabel => 'Pourboire';

  @override
  String get tipPresetsLabel => 'Pourcentages proposés';

  @override
  String get tipsEnabledHint =>
      'Proposé à l\'encaissement, compté à part du chiffre d\'affaires et attribué au serveur de la commande.';

  @override
  String get tipsEnabledLabel => 'Proposer un pourboire';

  @override
  String get tipsTitle => 'Pourboires';

  @override
  String get tipsTotal => 'Pourboires';

  @override
  String get toCollectTotal => 'À encaisser';

  @override
  String get transactionReferenceRequired => 'N° de transaction (obligatoire)';

  @override
  String get transactionsTab => 'Transactions';

  @override
  String get validateClosingConfirm =>
      'Valider cette clôture ? Le Z de caisse sera numéroté et ne pourra plus être modifié.';

  @override
  String get validateNowHint =>
      'Validez la clôture dans l\'onglet Clôtures pour obtenir le Z numéroté.';

  @override
  String get validatedLabel => 'Validée';

  @override
  String get voidedPayments => 'Paiements annulés';

  @override
  String get xReading => 'Lecture X';

  @override
  String get xReportTitle => 'Lecture X (provisoire)';

  @override
  String get zHistory => 'Historique des Z';

  @override
  String zReportTitle(int number) {
    return 'Z de caisse n° $number';
  }

  @override
  String get zShort => 'Z';

  @override
  String get expectedCashLabel => 'Espèces attendues';

  @override
  String get countedAmountLabel => 'Compté';

  @override
  String get refundsLabel => 'Remboursements';

  @override
  String get addressOptional => 'Adresse (facultatif)';

  @override
  String get billedTo => 'Facturé à';

  @override
  String get cancelInvoiceHint =>
      'Ex. : erreur de raison sociale, client erroné';

  @override
  String get chooseOrder => 'Choisissez la commande';

  @override
  String get companyOptional => 'Société (facultatif)';

  @override
  String get customerTaxIdOptional =>
      'N° d\'identification fiscale du client (facultatif)';

  @override
  String get documentsTitle => 'Documents';

  @override
  String get emailOptional => 'E-mail (facultatif)';

  @override
  String get errorCustomerNameRequired =>
      'Le nom du client est obligatoire sur une facture.';

  @override
  String get invoiceATicket => 'Facturer un ticket';

  @override
  String get invoiceCancelledMention => 'FACTURE ANNULÉE';

  @override
  String get invoiceCancelledDone =>
      'Facture annulée : vous pouvez en émettre une nouvelle.';

  @override
  String invoiceDateLabel(String date) {
    return 'Date : $date';
  }

  @override
  String get invoiceDesignation => 'Désignation';

  @override
  String invoiceEmailHint(String email) {
    return 'Pour l\'envoyer à $email : « Partager », puis choisissez votre messagerie.';
  }

  @override
  String get invoiceFooterHint =>
      'Ex. : conditions de paiement, coordonnées bancaires, mentions légales de votre pays';

  @override
  String get invoiceFooterLabel => 'Mentions en bas de facture';

  @override
  String invoiceNumberLabel(String number) {
    return 'Facture n° $number';
  }

  @override
  String get invoicePayments => 'Paiements reçus';

  @override
  String get invoicePrefixHint => 'Ex. : FA-2026-';

  @override
  String get invoicePrefixLabel => 'Préfixe du numéro de facture';

  @override
  String get invoiceSettingsTitle => 'Factures';

  @override
  String get invoiceTitle => 'Facture';

  @override
  String get invoiceUnitPrice => 'Prix unitaire';

  @override
  String get invoicedTotal => 'Facturé';

  @override
  String get invoicesCount => 'Factures';

  @override
  String get issueInvoice => 'Établir une facture';

  @override
  String get issueInvoiceAction => 'Émettre la facture';

  @override
  String get issueInvoiceHint =>
      'Une facture émise est numérotée et ne se modifie plus (en cas d\'erreur : annulation puis nouvelle facture).';

  @override
  String get noInvoices =>
      'Aucune facture sur cette période. Une facture s\'établit depuis une commande (bouton « Facture ») ou ici avec « Facturer un ticket ».';

  @override
  String get printInvoice => 'Imprimer / télécharger';

  @override
  String get receiptDocument => 'Ticket de caisse';

  @override
  String get searchInvoiceHint => 'N°, client, société';

  @override
  String get shareInvoice => 'Partager';

  @override
  String get totalExclTax => 'Total hors taxes';

  @override
  String get totalInclTax => 'Total toutes taxes comprises';

  @override
  String get receiptQrCaption => 'Scannez pour nous retrouver en ligne';

  @override
  String get receiptQrLabel => 'QR code en bas du ticket';

  @override
  String get receiptQrUrlLabel => 'Lien du QR code';

  @override
  String get receiptQrUrlHint =>
      'Vide = page du restaurant. Ex. : https://votre-site.com ou votre page d\'avis';

  @override
  String get receiptQrUrlInvalid =>
      'Le lien du QR code doit commencer par https:// (ou http://).';

  @override
  String get restaurantLogo => 'Logo du restaurant';

  @override
  String get chooseLogo => 'Choisir le logo';

  @override
  String get replaceLogo => 'Remplacer';

  @override
  String get removeLogo => 'Retirer';

  @override
  String get logoTooBig =>
      'Ce fichier dépasse 1 Mo : choisissez une image plus légère.';

  @override
  String get receiptTendered => 'Montant remis';

  @override
  String get receiptChange => 'Monnaie rendue';

  @override
  String get restaurantLogoHint =>
      'Imprimé en tête des tickets. PNG à fond transparent conseillé, 1 Mo au plus.';

  @override
  String get add => 'Ajouter';

  @override
  String get delete => 'Supprimer';

  @override
  String get branchLabel => 'Établissement';

  @override
  String get kindDessert => 'Dessert';

  @override
  String get kindMenu => 'Formule';

  @override
  String get navAds => 'Publicité';

  @override
  String get navSettings => 'Paramètres';

  @override
  String get greetingShort => 'Bonjour';

  @override
  String get homeWelcome => 'Bienvenue, voici votre activité du jour';

  @override
  String get kpiSalesToday => 'CA du jour';

  @override
  String get kpiOpenOrders => 'Commandes en cours';

  @override
  String kpiPendingCount(int count) {
    return '$count en attente';
  }

  @override
  String get kpiOccupancy => 'Taux d\'occupation';

  @override
  String kpiTablesBusy(int busy, int total) {
    return '$busy tables occupées sur $total';
  }

  @override
  String get lowStockTitle => 'Stock faible';

  @override
  String get saveChanges => 'Enregistrer les modifications';

  @override
  String get settingsProfile => 'Profil de l\'établissement';

  @override
  String get settingsProfileHint =>
      'Les informations de votre restaurant, visibles par vos clients.';

  @override
  String get settingsContact => 'Contact & localisation';

  @override
  String get settingsContactHint =>
      'Adresse, téléphones et position sur la carte.';

  @override
  String get settingsHours => 'Horaires';

  @override
  String get settingsHoursHint =>
      'Jours et heures d\'ouverture, temps de préparation, fermeture temporaire.';

  @override
  String get settingsDelivery => 'Livraison & commandes';

  @override
  String get settingsDeliveryHint =>
      'Commandes en ligne, livraison, réservations et page publique.';

  @override
  String get settingsPayments => 'Paiement & facturation';

  @override
  String get settingsPaymentsHint =>
      'Modes de paiement, caisses, ticket, factures et pourboires.';

  @override
  String get settingsTeam => 'Équipe & rôles';

  @override
  String get settingsTeamHint => 'Membres, rôles et invitations.';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get settingsNotificationsHint =>
      'Ce qui vous est signalé dans l\'application.';

  @override
  String get settingsSecurity => 'Sécurité';

  @override
  String get settingsSecurityHint => 'Mot de passe et appareils connectés.';

  @override
  String get restaurantName => 'Nom du restaurant';

  @override
  String get sloganLabel => 'Slogan';

  @override
  String get sloganHint => 'Ex. : Cuisine traditionnelle raffinée';

  @override
  String get registrationNumber => 'N° d\'immatriculation';

  @override
  String get registrationNumberHint => 'Registre du commerce de votre pays';

  @override
  String get logoUpload => 'Télécharger le logo';

  @override
  String get logoFormats =>
      'PNG, JPG ou WebP — 1 Mo au plus. Idéal : 512 × 512.';

  @override
  String get logoWhere =>
      'Le logo apparaît dans l\'application, sur votre vitrine et sur les tickets de vos clients.';

  @override
  String get whatsappLabel => 'Téléphone WhatsApp';

  @override
  String get gpsTitle => 'Coordonnées GPS / carte';

  @override
  String get latitude => 'Latitude';

  @override
  String get longitude => 'Longitude';

  @override
  String get gpsMissing => 'Position non renseignée';

  @override
  String get openInMaps => 'Ouvrir dans Maps';

  @override
  String get deliveryZoneLabel => 'Zone de livraison';

  @override
  String get deliveryZoneHint => 'Ex. : quartiers desservis ou rayon de 5 km';

  @override
  String get vacationMode => 'Mode vacances';

  @override
  String get vacationModeHint =>
      'Fermer temporairement le restaurant : il apparaît comme fermé pour vos clients.';

  @override
  String get vacationMessage => 'Message affiché aux clients';

  @override
  String get vacationMessageHint => 'Ex. : Réouverture le 15 septembre';

  @override
  String get notifSoundNewOrder => 'Son à chaque nouvelle commande';

  @override
  String get notifSoundReady => 'Son quand une commande est prête';

  @override
  String get notifLate => 'Alerte des commandes en retard';

  @override
  String get notifLowStock => 'Alerte de stock faible';

  @override
  String get notifReservations => 'Rappel des réservations de l\'heure';

  @override
  String get notifCashGap => 'Écart de caisse à la clôture';

  @override
  String get signedInAs => 'Connecté en tant que';

  @override
  String get securityTip =>
      'Utilisez un mot de passe unique d\'au moins 8 caractères.';

  @override
  String get signOutOthers => 'Déconnecter mes autres appareils';

  @override
  String get signOutOthersDone => 'Vos autres appareils sont déconnectés.';

  @override
  String get signOutAll => 'Se déconnecter partout';

  @override
  String fileTooBig(String name) {
    return '$name est trop volumineux.';
  }

  @override
  String get adsCreate => 'Créer une pub';

  @override
  String get adsEdit => 'Modifier la pub';

  @override
  String get adsCampaigns => 'Mes campagnes';

  @override
  String get adsLibrary => 'Bibliothèque';

  @override
  String get adsStats => 'Statistiques';

  @override
  String get adsCreateTitle => 'Créer';

  @override
  String get adsCreateHint => 'Choisissez le format de votre publicité.';

  @override
  String get adsContent => 'Contenu';

  @override
  String get adsBudgetTargeting => 'Budget & ciblage';

  @override
  String get adsPreview => 'Aperçu';

  @override
  String get adsPreviewHint => 'Prévisualisation sur mobile';

  @override
  String get adsPreviewSimulation => 'Cet aperçu est une simulation.';

  @override
  String get adsFromLibrary => 'Depuis la bibliothèque';

  @override
  String get adsUpload => 'Ajouter des photos ou des vidéos';

  @override
  String get adsUploadHint =>
      'JPG, PNG, WebP (5 Mo) · MP4, WebM, MOV (50 Mo) · vidéos de 15 à 30 secondes conseillées';

  @override
  String get adsLibraryEmpty => 'La bibliothèque est vide.';

  @override
  String get adsDeleteFile => 'Supprimer ce fichier de la bibliothèque ?';

  @override
  String get adsEmpty => 'Aucune campagne pour le moment.';

  @override
  String get adsEmptyHint =>
      'Créez votre première publicité : une vidéo, une story de 24 h ou un plat mis en avant.';

  @override
  String get adsActiveCampaigns => 'Campagnes';

  @override
  String adsCampaignCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count actives',
      one: '1 active',
      zero: 'aucune active',
    );
    return '$_temp0';
  }

  @override
  String get adFormat => 'Format';

  @override
  String get adFormatVideo => 'Vidéo 15–30 s';

  @override
  String get adFormatVideoHint => 'Vidéo courte pour capter l\'attention';

  @override
  String get adFormatCarousel => 'Photo carrousel';

  @override
  String get adFormatCarouselHint => 'Plusieurs images à faire défiler';

  @override
  String get adFormatStory => 'Story 24 h';

  @override
  String get adFormatStoryHint => 'Format éphémère de 24 heures';

  @override
  String get adFormatSponsoredMenu => 'Menu sponsorisé';

  @override
  String get adFormatSponsoredMenuHint => 'Mettre vos plats en avant';

  @override
  String get adFormatPush => 'Notification';

  @override
  String get adFormatPushHint => 'Prévenir vos clients directement';

  @override
  String get adFormatClassified => 'Petite annonce';

  @override
  String get adFormatClassifiedHint => 'Annonce texte simple et efficace';

  @override
  String get adTitle => 'Titre';

  @override
  String get adTitleHint => 'Ex. : Croissant au beurre';

  @override
  String get adTitleRequired => 'Donnez un titre à votre publicité.';

  @override
  String get adText => 'Texte';

  @override
  String get adTextHint =>
      'Ex. : Nouveau ! Croissant artisanal fait maison, -20 % ce soir uniquement';

  @override
  String get adMediaHelp => 'Photos ou vidéos de la publicité (10 au plus).';

  @override
  String get adVideoHelp => 'Ajoutez une vidéo courte (15 à 30 secondes).';

  @override
  String get adChooseItems => 'Plats mis en avant';

  @override
  String get adCta => 'Bouton';

  @override
  String get adCtaHint => 'Ex. : Commander maintenant';

  @override
  String get adCtaDefault => 'Commander maintenant';

  @override
  String get adLink => 'Lien du bouton (facultatif)';

  @override
  String get adPushNote =>
      'La notification sera envoyée aux clients de l\'application qui ont accepté de recevoir vos offres.';

  @override
  String get adDailyBudget => 'Budget journalier';

  @override
  String get adBudgetNote =>
      'Budget prévu : la diffusion sponsorisée sera facturée par la plateforme.';

  @override
  String get adStart => 'Début';

  @override
  String get adEnd => 'Fin';

  @override
  String get adStory24h => 'Visible 24 heures';

  @override
  String get adTargetAreas => 'Ciblage par quartier';

  @override
  String get adAddArea => 'Ajouter un quartier';

  @override
  String get adMoments => 'Moment';

  @override
  String get momentMorning => 'Matin';

  @override
  String get momentNoon => 'Midi';

  @override
  String get momentAfternoon => 'Après-midi';

  @override
  String get momentEvening => 'Soir';

  @override
  String get momentNight => 'Nuit';

  @override
  String get adBranches => 'Établissements';

  @override
  String get adSaveDraft => 'Enregistrer le brouillon';

  @override
  String get adPublish => 'Publier';

  @override
  String get adPublished => 'Publicité publiée.';

  @override
  String get adSponsored => 'Sponsorisé';

  @override
  String get adStatusActive => 'Active';

  @override
  String get adStatusScheduled => 'Programmée';

  @override
  String get adStatusPaused => 'En pause';

  @override
  String get adStatusEnded => 'Terminée';

  @override
  String get adStatusDraft => 'Brouillon';

  @override
  String get adRoi => 'Chiffre d\'affaires généré';

  @override
  String adRoiDetail(String amount) {
    return 'pour $amount de budget engagé';
  }

  @override
  String adViews(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count vues',
      one: '1 vue',
      zero: '0 vue',
    );
    return '$_temp0';
  }

  @override
  String adOrders(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count commandes',
      one: '1 commande',
      zero: '0 commande',
    );
    return '$_temp0';
  }

  @override
  String get adDetails => 'Voir détails';

  @override
  String get adBoost => 'Booster';

  @override
  String get adBoostTitle => 'Prolonger la diffusion';

  @override
  String adBoostDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count jours de plus',
      one: '1 jour de plus',
    );
    return '$_temp0';
  }

  @override
  String get adBoosted => 'Campagne prolongée.';

  @override
  String get adPause => 'Mettre en pause';

  @override
  String get adResume => 'Relancer';

  @override
  String get adEndNow => 'Terminer maintenant';

  @override
  String get adDeleteConfirm =>
      'Supprimer cette campagne et ses statistiques ?';

  @override
  String get adStatViews => 'Vues';

  @override
  String get adStatClicks => 'Clics';

  @override
  String get adStatClickRate => 'Taux de clic';

  @override
  String get adStatOrders => 'Commandes';

  @override
  String get adStatRevenue => 'Chiffre d\'affaires';

  @override
  String get adStatByCampaign => 'Vues par campagne';

  @override
  String get activeLabel => 'Actif';

  @override
  String get addPhotos => 'Ajouter des photos';

  @override
  String get addProduct => 'Ajouter un produit';

  @override
  String get allItems => 'Tous';

  @override
  String get available => 'Disponible';

  @override
  String get categories => 'Catégories';

  @override
  String get copySuffix => 'copie';

  @override
  String get customerSideView =>
      'Aperçu côté client — apparence dans le menu du restaurant';

  @override
  String get duplicate => 'Dupliquer';

  @override
  String get everyDay => 'Tous les jours';

  @override
  String get filterKind => 'Famille';

  @override
  String get itemDescriptionHint =>
      'Ex. : Feuilles de ndolé aux arachides, crevettes et plantain';

  @override
  String get itemDuplicated =>
      'Article dupliqué : la copie est masquée jusqu\'à son enregistrement.';

  @override
  String get livePreview => 'Aperçu en direct';

  @override
  String get mainPhoto => 'Principale';

  @override
  String get makeMainPhoto => 'Mettre en photo principale';

  @override
  String get markAvailable => 'Remettre disponible';

  @override
  String get markSoldOut => 'Marquer en rupture';

  @override
  String get menuProducts => 'Produits du menu';

  @override
  String get noProductsFound => 'Aucun produit ne correspond.';

  @override
  String photosHint(int count) {
    return 'Jusqu\'à $count photos · JPG, PNG, WebP · 5 Mo max';
  }

  @override
  String get play => 'Lire';

  @override
  String prepMinutesShort(int minutes) {
    return 'Préparation : $minutes min';
  }

  @override
  String get prepTime => 'Temps de préparation';

  @override
  String get productInfo => 'Informations du produit';

  @override
  String get productPhotos => 'Photos du produit';

  @override
  String productsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count produits',
      one: '1 produit',
      zero: 'Aucun produit',
    );
    return '$_temp0';
  }

  @override
  String get publish => 'Publier';

  @override
  String get replace => 'Remplacer';

  @override
  String get saleDays => 'Jours de vente';

  @override
  String get saleDaysRequired => 'Choisissez au moins un jour de vente.';

  @override
  String get searchProduct => 'Rechercher un produit, un plat…';

  @override
  String get sizesLabel => 'Tailles';

  @override
  String get sortBy => 'Trier';

  @override
  String get sortMenuOrder => 'Ordre du menu';

  @override
  String get sortName => 'Nom';

  @override
  String get sortPriceAsc => 'Prix croissant';

  @override
  String get sortPriceDesc => 'Prix décroissant';

  @override
  String get stockAlertThreshold => 'Alerte en dessous de';

  @override
  String get stockAndTime => 'Stock & temps';

  @override
  String stockLeft(int count) {
    return 'Stock : $count restants';
  }

  @override
  String stockLow(int count) {
    return 'Stock faible : $count restants';
  }

  @override
  String get stockNotTracked => 'Vide = non suivi';

  @override
  String get stockOfDay => 'Stock du jour';

  @override
  String get stockOfDayHint =>
      'Nombre de portions disponibles aujourd\'hui. Il baisse à chaque commande ; à zéro, l\'article passe en rupture. Laissez vide pour ne pas suivre.';

  @override
  String get stockQuantity => 'Quantité en stock';

  @override
  String get supplementsLabel => 'Suppléments';

  @override
  String get videoAdded => 'Vidéo de présentation ajoutée';

  @override
  String get videoOptional =>
      'Vidéo de présentation (facultatif, 30 s environ)';

  @override
  String get allChannels => 'Tous les canaux';

  @override
  String get amountLabel => 'Montant';

  @override
  String averageTicketShort(String amount) {
    return 'Panier moyen $amount';
  }

  @override
  String get customerLabel => 'Client';

  @override
  String get financialResult => 'Résultat financier';

  @override
  String get inKitchenCount => 'en préparation';

  @override
  String get inProgressCount => 'en cours';

  @override
  String get itemsLabel => 'Articles :';

  @override
  String get lateCount => 'en retard';

  @override
  String get noOrdersHere => 'Aucune commande ici';

  @override
  String get noSalesYet => 'Pas encore de ventes sur la période.';

  @override
  String get nothingToCollectHint =>
      'Aucune opération en attente : les nouveaux encaissements apparaîtront ici.';

  @override
  String get orderLabel => 'Commande';

  @override
  String get paymentLabel => 'Paiement';

  @override
  String get periodLabel => 'Période';

  @override
  String get recentTransactions => 'Transactions récentes';

  @override
  String get salesOfPeriod => 'CA de la période';

  @override
  String get salesSplit => 'Répartition des ventes';

  @override
  String get timeLabel => 'Heure';

  @override
  String get topDishes => 'Top plats';

  @override
  String get viewDetails => 'Voir détails';

  @override
  String vsPrevious(String amount) {
    return 'Période précédente : $amount';
  }

  @override
  String get addAddress => 'Ajouter une adresse';

  @override
  String get addedToCart => 'Ajouté au panier.';

  @override
  String get addressLabel => 'Nom de l\'adresse';

  @override
  String get addressLabelHint => 'Ex. : Maison, Bureau';

  @override
  String get addToCart => 'Ajouter au panier';

  @override
  String get allCities => 'Toutes les villes';

  @override
  String get allRestaurants => 'Tous les restaurants';

  @override
  String get birthday => 'Date d\'anniversaire';

  @override
  String get cartEmpty => 'Votre panier est vide.';

  @override
  String cartItems(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count articles',
      one: '1 article',
    );
    return '$_temp0';
  }

  @override
  String get changeCity => 'Modifier';

  @override
  String get chooseCity => 'Choisir la ville';

  @override
  String chooseOptionRequired(String name) {
    return 'Choisissez : $name';
  }

  @override
  String get closedNow => 'Fermé';

  @override
  String get customerFavorites => 'Favoris';

  @override
  String get customerHome => 'Accueil';

  @override
  String get customerOrders => 'Commandes';

  @override
  String get customerProfile => 'Profil';

  @override
  String customerReviews(int count) {
    return 'Avis clients ($count)';
  }

  @override
  String get customerSearch => 'Recherche';

  @override
  String get customerSpaceLink => 'Espace client · commander';

  @override
  String get deliveryDetailsRequired =>
      'Indiquez l\'adresse de livraison et un téléphone.';

  @override
  String get directions => 'Itinéraire';

  @override
  String get discoverRestaurants => 'Découvrir des restaurants';

  @override
  String get dishes => 'Plats';

  @override
  String get favoritesSignIn =>
      'Connectez-vous pour retrouver vos restaurants préférés.';

  @override
  String get fullName => 'Nom et prénom';

  @override
  String get globalCatalog => 'Catalogue global';

  @override
  String get healthAllergies => 'Santé & allergies';

  @override
  String get howDoYouWant => 'Comment souhaitez-vous être servi ?';

  @override
  String loyaltyNextReward(int points, String amount) {
    return 'Prochaine récompense à $points points : $amount';
  }

  @override
  String loyaltyPoints(int count) {
    return '$count points';
  }

  @override
  String get loyaltyProgram => 'Programme fidélité';

  @override
  String mapCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count établissements sur la carte',
      one: '1 établissement sur la carte',
    );
    return '$_temp0';
  }

  @override
  String get mapView => 'Carte';

  @override
  String minimumOrderNotReached(String amount) {
    return 'Commande minimum : $amount';
  }

  @override
  String minutesRange(int min, int max) {
    return '$min–$max min';
  }

  @override
  String get myAddresses => 'Mes adresses';

  @override
  String get myCart => 'Mon panier';

  @override
  String get newRestaurant => 'Nouveau';

  @override
  String get noAddresses => 'Aucune adresse enregistrée.';

  @override
  String get noCustomerOrders => 'Vous n\'avez pas encore commandé.';

  @override
  String get noFavorites => 'Aucun favori pour le moment.';

  @override
  String get noFavoritesHint =>
      'Touchez le cœur d\'un restaurant pour l\'ajouter.';

  @override
  String get noLoyaltyYet =>
      'Vos points apparaîtront après vos premières commandes.';

  @override
  String get noRestaurantsYet =>
      'Aucun restaurant publié dans cette ville pour le moment.';

  @override
  String get noteForKitchen => 'Précision pour la cuisine (facultatif)';

  @override
  String get noteForKitchenHint => 'Ex. : sans piment, bien cuit';

  @override
  String get notifOrderUpdates => 'Suivi de mes commandes';

  @override
  String get notifPromotions => 'Promotions & offres';

  @override
  String get notifReservationReminders => 'Rappels de réservation';

  @override
  String get onlineOrdersUnavailable =>
      'Commande en ligne indisponible pour le moment';

  @override
  String get openFullMap => 'Ouvrir la carte en plein écran';

  @override
  String get openNow => 'Ouvert';

  @override
  String get orderDone => 'Terminée';

  @override
  String orderingAtTable(String table) {
    return 'Commande à la table $table';
  }

  @override
  String get orderInProgress => 'En cours';

  @override
  String get orderNoteOptional => 'Message pour le restaurant (facultatif)';

  @override
  String get orderRejected => 'Refusée par le restaurant';

  @override
  String get orderSentToRestaurant =>
      'Commande envoyée ! Le restaurant va la confirmer : suivez-la ici en direct.';

  @override
  String get ordersSignIn => 'Connectez-vous pour suivre vos commandes.';

  @override
  String get orderSummary => 'Récapitulatif';

  @override
  String get orderWaitingConfirmation => 'En attente de confirmation';

  @override
  String get payMobileWallet => 'Portefeuille mobile';

  @override
  String get personalProfile => 'Profil personnel';

  @override
  String get personalProfileHint =>
      'Vos informations personnelles et vos préférences.';

  @override
  String get placeOrder => 'Commander';

  @override
  String get preferences => 'Préférences';

  @override
  String get preferredPayment => 'Paiement préféré';

  @override
  String get preferredPaymentHint =>
      'Indicatif : aucun numéro de carte ni de compte n\'est enregistré.';

  @override
  String get productDetails => 'Détails du produit';

  @override
  String get profileSignIn =>
      'Connectez-vous pour gérer votre profil, vos adresses et vos points.';

  @override
  String get rateOrder => 'Noter ma commande';

  @override
  String get requiredLabel => 'Obligatoire';

  @override
  String get restaurantOnVacation => 'Le restaurant est fermé temporairement.';

  @override
  String get restaurants => 'Restaurants';

  @override
  String get restaurantSpace => 'Espace restaurant';

  @override
  String get restaurantUnavailable => 'Ce restaurant n\'est pas disponible.';

  @override
  String get reviewComment => 'Votre avis (facultatif)';

  @override
  String reviewsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count avis',
      one: '1 avis',
      zero: 'aucun avis',
    );
    return '$_temp0';
  }

  @override
  String get searchRestaurantsHint =>
      'Rechercher restaurants, plats, cuisines…';

  @override
  String get seeAll => 'Voir tout';

  @override
  String get send => 'Envoyer';

  @override
  String get signInToContinue => 'Connectez-vous pour continuer';

  @override
  String get spiceHot => 'Fort';

  @override
  String get spiceLevel => 'Piment';

  @override
  String get spiceMedium => 'Moyen';

  @override
  String get spiceMild => 'Doux';

  @override
  String get spiceNone => 'Sans';

  @override
  String get sponsoredAds => 'Publicités sponsorisées';

  @override
  String get stepAccepted => 'Acceptée par le restaurant';

  @override
  String get stepDone => 'Terminée';

  @override
  String get stepPreparing => 'En préparation';

  @override
  String get stepReady => 'Prête';

  @override
  String get stepSent => 'Envoyée';

  @override
  String get storyLabel => 'Histoire';

  @override
  String get thanksForReview => 'Merci pour votre avis !';

  @override
  String get viewCart => 'Voir le panier';

  @override
  String get watchVideo => 'Vidéo';

  @override
  String get yourName => 'Votre nom';

  @override
  String get gpsHint =>
      '« Ouvrir dans Maps » enregistre automatiquement la position où vous vous trouvez : faites-le depuis l\'établissement. Vous pouvez aussi saisir les coordonnées.';

  @override
  String get locationSaved => 'Position de l\'établissement enregistrée.';

  @override
  String get locationServiceDisabled =>
      'La localisation de l\'appareil est désactivée : activez-la puis réessayez.';

  @override
  String get locationDenied =>
      'Accès à la position refusé : autorisez-le dans les réglages du navigateur ou du téléphone.';

  @override
  String get locationUnavailable =>
      'Position introuvable pour le moment : réessayez à l\'extérieur ou saisissez les coordonnées.';

  @override
  String get openMapAction => 'Ouvrir la carte';

  @override
  String get customerReviewsTitle => 'Avis clients';

  @override
  String get forYou => 'Pour vous';

  @override
  String fromAmount(String amount) {
    return 'dès $amount';
  }

  @override
  String helpfulCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Utile ($count)',
      zero: 'Utile',
    );
    return '$_temp0';
  }

  @override
  String get hideReview => 'Masquer l\'avis';

  @override
  String get hideReviewReason => 'Motif';

  @override
  String get locatedNearYou => 'Restaurants classés selon votre position';

  @override
  String get locateMe => 'Me localiser';

  @override
  String get locationRefusedChooseCity =>
      'Position non disponible : choisissez votre ville.';

  @override
  String get nearYouHint =>
      'Autorisez la localisation pour voir les restaurants et les plats les plus proches.';

  @override
  String get nearYouRestaurants => 'Près de vous';

  @override
  String get nearYouTitle => 'Les restaurants près de vous';

  @override
  String get newOnMenus => 'Nouveautés';

  @override
  String get noReviewsYet => 'Pas encore d\'avis';

  @override
  String get openNowTitle => 'Ouverts maintenant';

  @override
  String get orderAgain => 'Commander à nouveau';

  @override
  String get orderAgainAction => 'Recommander';

  @override
  String get ordersInProgressTitle => 'Vos commandes en cours';

  @override
  String get popularDishes => 'Plats populaires';

  @override
  String get popularNearYou => 'Populaires autour de vous';

  @override
  String get promotionsTitle => 'Promotions';

  @override
  String get publishReview => 'Publier mon avis';

  @override
  String rateDish(String name) {
    return 'Noter : $name';
  }

  @override
  String get rateShort => 'Noter';

  @override
  String get refreshLocation => 'Actualiser';

  @override
  String get reorderPartial =>
      'Certains plats ne sont plus disponibles : le reste a été ajouté au panier.';

  @override
  String get reorderUnavailable => 'Ces plats ne sont plus disponibles.';

  @override
  String get reportReason => 'Pourquoi cet avis est-il abusif ?';

  @override
  String get reportReview => 'Signaler';

  @override
  String reportsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count signalements',
      one: '1 signalement',
    );
    return '$_temp0';
  }

  @override
  String get reportSent => 'Merci, le signalement a été transmis.';

  @override
  String get republishReview => 'Republier';

  @override
  String get reviewCommentHint =>
      'Ex. : bien assaisonné, portion généreuse, livraison rapide';

  @override
  String satisfiedPercent(int percent) {
    return '$percent % de clients satisfaits';
  }

  @override
  String get sortBestRated => 'Meilleures notes';

  @override
  String get sortHelpful => 'Plus utiles';

  @override
  String get sortRecent => 'Plus récents';

  @override
  String get sortWorstRated => 'Notes les plus basses';

  @override
  String get verifiedPurchase => 'Achat vérifié';

  @override
  String get verifiedReviewNote =>
      'Avis vérifié : seuls les clients ayant reçu ce plat peuvent le noter.';

  @override
  String get asSoonAsPossible => 'Dès que possible';

  @override
  String get customerOrdersHere => 'Ses commandes chez vous';

  @override
  String get customerPrivacyNote =>
      'Vous ne voyez que la relation de ce client avec votre restaurant : jamais ses commandes chez d\'autres restaurants.';

  @override
  String get customersCount => 'clients';

  @override
  String multiRestaurantNote(int count) {
    return '$count restaurants dans votre panier : chacun reçoit sa propre commande, avec son numéro et son suivi.';
  }

  @override
  String get navCustomers => 'Clients';

  @override
  String get noCustomersYet => 'Pas encore de clients en ligne.';

  @override
  String get noCustomersYetHint =>
      'Chaque client qui commande depuis l\'application apparaît ici automatiquement.';

  @override
  String get noDeliveryHere =>
      'Ce restaurant ne livre pas : commande à emporter.';

  @override
  String get ordersSent => 'Commandes envoyées';

  @override
  String ordersSentHint(int count) {
    return '$count commandes envoyées, une par restaurant. Suivez chacune séparément.';
  }

  @override
  String placeOrders(int count) {
    return 'Passer les $count commandes';
  }

  @override
  String get regularBadge => 'Fidèle';

  @override
  String get regularCustomers => 'fidèles (3 commandes ou plus)';

  @override
  String restaurantsCount(int count) {
    return '$count restaurants';
  }

  @override
  String get scheduleOrder => 'Programmer';

  @override
  String get scheduleTooSoon =>
      'Choisissez une heure au moins 15 minutes plus tard.';

  @override
  String get searchCustomer => 'Nom ou téléphone';

  @override
  String get sortBiggestSpenders => 'Plus grosses dépenses';

  @override
  String get sortMostOrders => 'Plus de commandes';

  @override
  String get sortRecentVisit => 'Venus récemment';

  @override
  String get teamNotes => 'Notes de l\'équipe';

  @override
  String get teamNotesExample =>
      'Ex. : préfère la terrasse, aime la sauce piquante';

  @override
  String get teamNotesHint => 'Visibles uniquement par votre équipe.';

  @override
  String get trackOrder => 'Suivre';

  @override
  String get customerDiscover => 'Découvrir';

  @override
  String get feedEmpty => 'Rien à découvrir pour l\'instant';

  @override
  String get feedEmptyHint =>
      'Les vidéos, plats et offres des restaurants de votre ville apparaîtront ici.';

  @override
  String get feedOrder => 'Commander';

  @override
  String get feedViewDish => 'Voir le plat';

  @override
  String get feedViewRestaurant => 'Voir le restaurant';

  @override
  String get feedLike => 'J\'aime';

  @override
  String get feedSave => 'Enregistrer';

  @override
  String get feedShare => 'Partager';

  @override
  String get feedSaved => 'Enregistré dans vos contenus.';

  @override
  String get feedUnsaved => 'Retiré de vos contenus enregistrés.';

  @override
  String get feedLinkCopied => 'Lien copié : collez-le pour le partager.';

  @override
  String get commentsTitle => 'Commentaires';

  @override
  String get noCommentsYet => 'Aucun commentaire pour l\'instant.';

  @override
  String get writeComment => 'Écrire un commentaire…';

  @override
  String get adHideForever => 'Ne plus afficher';

  @override
  String reserveAt(String name) {
    return 'Réserver chez $name';
  }

  @override
  String get reservationSentHint =>
      'Demande envoyée : le restaurant vous confirmera la réservation.';

  @override
  String get reservationNoteLabel => 'Remarque (facultatif)';

  @override
  String get errorInvalidComment =>
      'Le commentaire doit contenir entre 1 et 500 caractères.';

  @override
  String get adStatReach => 'Portée';

  @override
  String get adStatEngagement => 'Engagement';

  @override
  String get adStatLikes => 'J\'aime';

  @override
  String get adStatSaves => 'Enregistrements';

  @override
  String get adStatShares => 'Partages';

  @override
  String get hideComment => 'Masquer';

  @override
  String get moderationReasonExample => 'Ex. : propos injurieux, hors sujet';

  @override
  String get hiddenBadge => 'Masqué';

  @override
  String hiddenBecause(String reason) {
    return 'Masqué : $reason';
  }

  @override
  String get allFilter => 'Tous';

  @override
  String get publishedComments => 'Publiés';

  @override
  String get hiddenComments => 'Masqués';

  @override
  String get adCommentsHint =>
      'Les commentaires des clients sur vos publicités apparaissent ici. Masquez ceux qui sont injurieux ou hors sujet.';

  @override
  String get happyBirthday => 'Joyeux anniversaire !';

  @override
  String birthdayGift(String name, int points) {
    return '$name vous offre $points points de fidélité.';
  }

  @override
  String get thanksAction => 'Merci !';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get noNotifications => 'Aucune notification';

  @override
  String get noNotificationsHint =>
      'Vous serez prévenu ici quand un restaurant accepte votre commande, quand elle est prête ou quand une réservation est confirmée.';

  @override
  String get notifOrderAcceptedTitle => 'Commande acceptée';

  @override
  String notifOrderAccepted(String brand, String number) {
    return '$brand a accepté votre commande n° $number.';
  }

  @override
  String get notifOrderReadyTitle => 'Commande prête';

  @override
  String notifOrderReady(String brand, String number) {
    return 'Votre commande n° $number est prête chez $brand : vous pouvez la retirer.';
  }

  @override
  String notifOrderOnTheWay(String brand, String number) {
    return 'Votre commande n° $number de $brand est prête et part en livraison.';
  }

  @override
  String get notifOrderRejectedTitle => 'Commande refusée';

  @override
  String notifOrderRejected(String brand, String number, String reason) {
    return '$brand n\'a pas pu accepter votre commande n° $number : $reason';
  }

  @override
  String get notifReservationConfirmedTitle => 'Réservation confirmée';

  @override
  String notifReservationConfirmed(String brand, String date) {
    return '$brand a confirmé votre réservation du $date.';
  }

  @override
  String get notifReservationDeclinedTitle => 'Réservation refusée';

  @override
  String notifReservationDeclined(String brand, String date, String reason) {
    return '$brand ne peut pas vous recevoir le $date : $reason';
  }

  @override
  String notifGroupJoined(String name, String brand) {
    return '$name a rejoint votre commande groupée chez $brand.';
  }

  @override
  String notifGroupPlaced(String host, String brand, String number) {
    return '$host a envoyé la commande groupée chez $brand (n° $number).';
  }

  @override
  String get groupOrderTitle => 'Commande groupée';

  @override
  String get groupOrderAction => 'Commande groupée';

  @override
  String get groupInviteTitle => 'Invitez vos convives';

  @override
  String get groupInviteHint =>
      'Partagez ce lien : chacun choisit ses plats sur son téléphone, puis vous envoyez une seule commande.';

  @override
  String get groupEmpty => 'Aucun plat pour l\'instant';

  @override
  String get groupEmptyHint =>
      'Ajoutez vos plats et partagez le lien avec vos convives.';

  @override
  String groupHostedBy(String name) {
    return 'Organisée par $name';
  }

  @override
  String groupStatusOpen(String time) {
    return 'Ouverte jusqu\'à $time';
  }

  @override
  String get groupStatusPlaced => 'Envoyée au restaurant';

  @override
  String get groupStatusCancelled => 'Annulée';

  @override
  String get groupStatusExpired => 'Expirée';

  @override
  String groupParticipants(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count convives',
      one: '1 convive',
    );
    return '$_temp0';
  }

  @override
  String get groupCheckoutTitle => 'Envoyer pour tout le groupe';

  @override
  String get estimatedTotal => 'Total estimé';

  @override
  String get groupPlaceOrder => 'Envoyer la commande au restaurant';

  @override
  String get cancelGroupOrder => 'Annuler la commande groupée';

  @override
  String get cancelGroupOrderConfirm =>
      'Annuler cette commande groupée ? Les plats choisis par chacun seront perdus.';

  @override
  String get groupAddMyDishes => 'Ajouter mes plats';

  @override
  String groupPlacedInfo(String name) {
    return '$name a envoyé la commande au restaurant.';
  }

  @override
  String get groupClosedInfo => 'Cette commande groupée est fermée.';

  @override
  String get groupOrderPlaced => 'Commande groupée envoyée au restaurant.';

  @override
  String get addedToGroup => 'Ajouté à la commande groupée.';

  @override
  String get addToGroup => 'Ajouter au groupe';

  @override
  String get saveDishAction => 'Enregistrer le plat';

  @override
  String saveDishTitle(String name) {
    return 'Enregistrer « $name »';
  }

  @override
  String get favoriteDishes => 'Plats favoris';

  @override
  String get myLists => 'Mes listes';

  @override
  String get myCoupons => 'Mes coupons';

  @override
  String get restaurantsSection => 'Restaurants';

  @override
  String get unavailableNow => 'Indisponible';

  @override
  String get removeAction => 'Retirer';

  @override
  String get noFavoriteDishes => 'Aucun plat favori';

  @override
  String get noFavoriteDishesHint =>
      'Touchez le cœur sur la fiche d\'un plat pour le retrouver ici.';

  @override
  String get newList => 'Nouvelle liste';

  @override
  String get noLists => 'Aucune liste';

  @override
  String get noListsHint =>
      'Créez des listes comme « À tester » ou « Déjeuners du bureau ».';

  @override
  String deleteListConfirm(String name) {
    return 'Supprimer la liste « $name » ?';
  }

  @override
  String get renameAction => 'Renommer';

  @override
  String dishesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count plats',
      one: '1 plat',
      zero: 'Aucun plat',
    );
    return '$_temp0';
  }

  @override
  String get emptyListHint =>
      'Liste vide : ajoutez des plats depuis leur fiche.';

  @override
  String get listName => 'Nom de la liste';

  @override
  String get listNameExample => 'Ex. : À tester';

  @override
  String get noCoupons => 'Aucun coupon';

  @override
  String get noCouponsHint =>
      'Enregistrez les offres des restaurants depuis l\'accueil pour les retrouver ici.';

  @override
  String get couponsHowTo =>
      'Saisissez le code dans le suivi de votre commande pour profiter de la remise.';

  @override
  String validUntil(String date) {
    return 'jusqu\'au $date';
  }

  @override
  String get couponUsed => 'Déjà utilisé';

  @override
  String get couponExpired => 'Expiré';

  @override
  String get codeCopied => 'Code copié.';

  @override
  String get couponSaved => 'Coupon enregistré dans vos favoris.';

  @override
  String get saveCouponAction => 'Enregistrer';

  @override
  String get errorLimitReached =>
      'Limite atteinte : retirez des éléments avant d\'en ajouter.';

  @override
  String get errorGroupClosed =>
      'Cette commande groupée est fermée ou a expiré.';

  @override
  String get customersTab => 'Clients';

  @override
  String get offersTab => 'Offres';

  @override
  String get loyaltyTab => 'Fidélité';

  @override
  String get activeOffers => 'Offres en cours';

  @override
  String get publicCoupons => 'Coupons publics';

  @override
  String get totalUses => 'Utilisations';

  @override
  String get newOffer => 'Nouvelle offre';

  @override
  String get editOffer => 'Modifier l\'offre';

  @override
  String get offersEmpty => 'Aucune offre';

  @override
  String get offersEmptyHint =>
      'Créez une remise, un code promo ou un coupon public pour attirer et fidéliser vos clients.';

  @override
  String get offerStatusOff => 'Désactivée';

  @override
  String get offerStatusEnded => 'Terminée';

  @override
  String get offerStatusScheduled => 'Programmée';

  @override
  String get offerStatusActive => 'En cours';

  @override
  String get publicCouponLabel => 'Coupon public';

  @override
  String get publicCouponHint =>
      'Visible dans l\'application : les clients peuvent l\'enregistrer dans leur portefeuille.';

  @override
  String get publicCouponNeedsCode => 'Un coupon public doit avoir un code.';

  @override
  String usesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count utilisations',
      one: '1 utilisation',
      zero: 'Jamais utilisée',
    );
    return '$_temp0';
  }

  @override
  String get offerName => 'Nom de l\'offre';

  @override
  String get offerNameExample => 'Ex. : Bienvenue, Happy hour';

  @override
  String get discountPercent => 'Pourcentage';

  @override
  String get discountAmount => 'Montant';

  @override
  String get offerValue => 'Remise';

  @override
  String get promoCodeLabel => 'Code (facultatif)';

  @override
  String get offerCodeHint => '3 à 30 lettres ou chiffres, ex. BIENVENUE';

  @override
  String get minOrderLabel => 'Commande minimum';

  @override
  String get maxUsesLabel => 'Utilisations max.';

  @override
  String get perCustomerLabel => 'Par client';

  @override
  String get startsLabel => 'Début';

  @override
  String get endsLabel => 'Fin';

  @override
  String get offerNow => 'maintenant';

  @override
  String get noEndDate => 'Sans fin';

  @override
  String get allBranchesLabel => 'Tous les établissements';

  @override
  String get thisBranchOnly => 'Cet établissement';

  @override
  String get offerActive => 'Offre active';

  @override
  String get loyaltyMembers => 'Membres';

  @override
  String get pointsInCirculation => 'Points en circulation';

  @override
  String get loyaltyProgramTitle => 'Programme de fidélité';

  @override
  String loyaltyExample(String amount, int points) {
    return 'Exemple : une commande de $amount rapporte $points points.';
  }

  @override
  String get loyaltyActive => 'Programme actif';

  @override
  String get amountPerPoint => 'Montant pour 1 point';

  @override
  String get rewardPointsLabel => 'Points pour une récompense';

  @override
  String get rewardValueLabel => 'Valeur de la récompense';

  @override
  String get birthdayPointsLabel => 'Points offerts à l\'anniversaire';

  @override
  String get birthdayPointsHint =>
      'Crédités automatiquement chaque année aux clients qui ont déjà commandé chez vous (0 = aucun).';

  @override
  String get stockDashboardTab => 'Tableau de bord';

  @override
  String get stockArticlesTab => 'Articles';

  @override
  String get stockOrdersTab => 'Commandes';

  @override
  String get stockReportsTab => 'Rapports';

  @override
  String get stockDashboardTitle => 'Tableau de bord du stock';

  @override
  String get stockValueLabel => 'Valeur du stock';

  @override
  String get belowThresholdLabel => 'Sous le seuil';

  @override
  String get outOfStockLabel => 'En rupture';

  @override
  String get expiringSoonLabel => 'Dates limites proches';

  @override
  String get inventoryVarianceLabel => 'Écarts d\'inventaire';

  @override
  String get consumptionLabel => 'Consommation';

  @override
  String get wasteLabel => 'Pertes';

  @override
  String get receiptsLabel => 'Réceptions';

  @override
  String articlesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count articles',
      one: '1 article',
      zero: 'Aucun article',
    );
    return '$_temp0';
  }

  @override
  String daysCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count jours',
      one: '1 jour',
    );
    return '$_temp0';
  }

  @override
  String get consumptionByDay => 'Consommation et pertes par jour';

  @override
  String get topConsumedTitle => 'Les plus consommés';

  @override
  String get wasteByReason => 'Pertes par motif';

  @override
  String get noMovementsPeriod => 'Aucun mouvement sur cette période.';

  @override
  String get noWastePeriod => 'Aucune perte sur cette période.';

  @override
  String get expiringLotsTitle => 'Lots à surveiller (dates limites)';

  @override
  String get noExpiringLots =>
      'Aucun lot n\'arrive à sa date limite dans les 7 jours.';

  @override
  String get toReorderTitle => 'À commander';

  @override
  String get noAlerts => 'Aucun article sous le seuil.';

  @override
  String get prepareOrder => 'Préparer la commande';

  @override
  String get expiredShort => 'Périmé';

  @override
  String daysLeftShort(int count) {
    return 'J-$count';
  }

  @override
  String daysLeftLong(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count jours de stock',
      one: '1 jour de stock',
      zero: 'épuisé aujourd\'hui',
    );
    return '$_temp0';
  }

  @override
  String batchShort(String batch) {
    return 'Lot $batch';
  }

  @override
  String get batchNumber => 'N° de lot';

  @override
  String get expiryDate => 'Date limite';

  @override
  String get stockEmptyHint =>
      'Créez vos articles dans l\'onglet Articles, puis enregistrez le stock de départ ou une réception.';

  @override
  String get searchArticle => 'Rechercher un article';

  @override
  String get showInactive => 'Afficher les inactifs';

  @override
  String get newArticle => 'Nouvel article';

  @override
  String get editArticle => 'Modifier l\'article';

  @override
  String get articlesEmptyHint =>
      'Ajoutez vos produits : légumes, viandes, boissons, emballages, préparations maison…';

  @override
  String get storageLabel => 'Conservation';

  @override
  String get storageAmbient => 'Ambiant';

  @override
  String get storageChilled => 'Frais';

  @override
  String get storageFrozen => 'Surgelé';

  @override
  String get purchaseUnitLabel => 'Unité d\'achat';

  @override
  String get purchaseUnitExample => 'Ex. : Sac de 5 kg, Carton de 12';

  @override
  String get purchaseUnitQty => 'Contenance';

  @override
  String get preferredSupplier => 'Fournisseur habituel';

  @override
  String get noneLabel => 'Aucun';

  @override
  String get shelfLifeDays => 'Durée de conservation';

  @override
  String get daysShort => 'jours';

  @override
  String get barcodeLabel => 'Code-barres';

  @override
  String get thresholdThisBranch => 'Seuil d\'alerte de cet établissement';

  @override
  String get reorderTitle => 'Commande suggérée';

  @override
  String get reorderHint =>
      'De quoi tenir au-dessus du seuil, d\'après la consommation des 28 derniers jours.';

  @override
  String get nothingToReorder => 'Rien à commander';

  @override
  String get nothingToReorderHint =>
      'Tous les articles suivis ont un stock suffisant pour la période choisie.';

  @override
  String get noSupplier => 'Sans fournisseur habituel';

  @override
  String get noSupplierHint =>
      'Choisissez un fournisseur habituel dans la fiche article pour créer un bon de commande.';

  @override
  String get orderFormPdf => 'Bon de commande PDF';

  @override
  String get createPurchaseOrder => 'Créer le bon de commande';

  @override
  String get purchaseOrderDraftCreated =>
      'Bon de commande créé en brouillon dans Achats.';

  @override
  String get reorderNote => 'Commande suggérée par le stock';

  @override
  String inStockShort(String qty) {
    return 'En stock : $qty';
  }

  @override
  String get entriesFilter => 'Entrées';

  @override
  String get exitsLabel => 'Sorties';

  @override
  String get transfersFilter => 'Transferts';

  @override
  String get adjustmentsFilter => 'Ajustements';

  @override
  String get movementsReportTitle => 'Mouvements de stock';

  @override
  String get wasteReportTitle => 'Pertes et casse';

  @override
  String get reportValuation => 'État du stock valorisé';

  @override
  String get reportValuationHint =>
      'Quantités, seuils, coût moyen et valeur de chaque article à l\'instant.';

  @override
  String get reportMovementsHint =>
      'Tous les mouvements de la période, avec les totaux par nature.';

  @override
  String get reportWasteHint =>
      'Pertes de la période avec leur motif et leur valeur.';

  @override
  String get reportInventory => 'Inventaire avec écarts';

  @override
  String get reportInventoryHint =>
      'Théorique, compté, écarts valorisés, avec les signatures.';

  @override
  String get reportFoodCost => 'Coût matière par plat';

  @override
  String get reportFoodCostHint =>
      'Coût de revient, prix de vente, part du prix et marge de chaque plat.';

  @override
  String get reportExpiringHint =>
      'Lots encore en stock dont la date limite tombe dans les 14 jours.';

  @override
  String get generatePdf => 'Générer le PDF';

  @override
  String get noValidatedInventory => 'Aucun inventaire validé pour l\'instant.';

  @override
  String get chooseInventory => 'Choisir l\'inventaire';

  @override
  String generatedOn(String date) {
    return 'Édité le $date';
  }

  @override
  String get articlesLabel => 'Articles';

  @override
  String get articleLabel => 'Article';

  @override
  String get avgCostShort => 'Coût moyen';

  @override
  String get valueLabel => 'Valeur';

  @override
  String get typeLabel => 'Nature';

  @override
  String get inventoryGains => 'Excédents';

  @override
  String get inventoryLosses => 'Manquants';

  @override
  String get inventoryNet => 'Écart net';

  @override
  String get theoreticalLabel => 'Théorique';

  @override
  String get countedBySignature => 'Compté par : ____________________';

  @override
  String get validatedBySignature => 'Validé par : ____________________';

  @override
  String get targetFoodCost => 'Objectif de coût matière';

  @override
  String get targetFoodCostHint =>
      'Part maximale du prix de vente que doivent représenter les ingrédients d\'un plat (souvent 25 à 35 %).';

  @override
  String targetFoodCostValue(String percent) {
    return 'Objectif coût matière : $percent %';
  }

  @override
  String get dishesWithRecipe => 'Plats avec fiche';

  @override
  String get aboveTarget => 'Au-dessus de l\'objectif';

  @override
  String get aboveTargetShort => 'trop cher';

  @override
  String get withoutRecipe => 'Sans fiche';

  @override
  String get recipeDefined => 'Fiche définie';

  @override
  String get dishLabel => 'Plat';

  @override
  String get costPriceShort => 'Coût';

  @override
  String get sellingPriceShort => 'Prix';

  @override
  String get foodCostShort => 'coût matière';

  @override
  String get marginShort => 'Marge';

  @override
  String get orderFormTitle => 'Bon de commande';

  @override
  String supplierLabelValue(String name) {
    return 'Fournisseur : $name';
  }

  @override
  String get packagingLabel => 'Conditionnement';

  @override
  String get unitPriceShort => 'Prix unitaire';

  @override
  String get orderFormFooter =>
      'Merci de confirmer la disponibilité et le délai de livraison.';

  @override
  String get accountTypeQuestion => 'Vous êtes :';

  @override
  String get accountTypeCustomer => 'Client';

  @override
  String get accountTypeCustomerHint =>
      'Découvrir les restaurants, commander, réserver';

  @override
  String get accountTypeBusiness => 'Entreprise';

  @override
  String get accountTypeBusinessHint => 'Gérer mon restaurant et mon équipe';

  @override
  String get accountTypeRequired => 'Choisissez Client ou Entreprise.';

  @override
  String get accountTypeTitle => 'Bienvenue sur Resto';

  @override
  String get accountTypeSub => 'Comment allez-vous utiliser l\'application ?';

  @override
  String get continueAction => 'Continuer';

  @override
  String adVideoTooBig(String name) {
    return '$name dépasse 50 Mo : choisissez une vidéo plus courte (30 secondes environ).';
  }

  @override
  String adMediaAdded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fichiers ajoutés.',
      one: '1 fichier ajouté.',
    );
    return '$_temp0';
  }

  @override
  String get adNeedVideo => 'Ajoutez une vidéo avant de publier ce format.';

  @override
  String get adNeedMedia =>
      'Ajoutez au moins une photo ou une vidéo avant de publier.';

  @override
  String get adNeedItems => 'Choisissez au moins un plat à mettre en avant.';

  @override
  String get uploadingLabel => 'Envoi…';

  @override
  String get errorInvalidMedia =>
      'Fichier refusé : il doit venir de votre médiathèque.';

  @override
  String get errorFileTooLarge => 'Fichier trop volumineux.';

  @override
  String get errorFileType =>
      'Format de fichier non accepté (JPG, PNG, WebP, MP4, WebM, MOV).';

  @override
  String get adAddVideo => 'Ajouter une vidéo';

  @override
  String get errorOutOfStock => 'Ce plat est épuisé pour aujourd\'hui.';

  @override
  String get errorInvalidRating => 'La note doit être comprise entre 1 et 5.';

  @override
  String get errorInvalidAllergen => 'Allergène inconnu.';

  @override
  String get bestSeller => 'Best-seller';

  @override
  String get callAction => 'Appeler';

  @override
  String get writeAction => 'Écrire';

  @override
  String get categoriesLabel => 'Catégories';

  @override
  String get filtersLabel => 'Filtres';

  @override
  String get reviewsTab => 'Avis';

  @override
  String get infosTab => 'Infos';

  @override
  String get noDishMatches => 'Aucun plat ne correspond à ces filtres.';

  @override
  String soldCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count vendus',
      one: '1 vendu',
    );
    return '$_temp0';
  }

  @override
  String get yourCart => 'Votre panier';

  @override
  String get coverPhoto => 'Photo d\'ambiance';

  @override
  String get coverPhotoHint =>
      'Grande photo en haut de votre page restaurant (salle, terrasse, façade).';

  @override
  String get changePhoto => 'Changer la photo';

  @override
  String get itemTagsLabel => 'Étiquettes (filtres de votre carte)';

  @override
  String get itemTagsHint =>
      'Créez vos propres étiquettes : vos clients pourront filtrer la carte avec. Ex. : Piment doux, Halal, Sans alcool, Fait maison.';

  @override
  String get addTagHint => 'Nouvelle étiquette + Entrée';

  @override
  String get errorInvalidTag => 'Une étiquette compte 30 caractères au plus.';

  @override
  String itemFavorites(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count clients l\'ont en favori',
      one: '1 client l\'a en favori',
      zero: 'Aucun client ne l\'a en favori',
    );
    return '$_temp0';
  }

  @override
  String get itemSold30 => 'Ventes des 30 derniers jours';

  @override
  String get receiptOrderNo => 'Commande N°';

  @override
  String get receiptTicketNo => 'Ticket N°';

  @override
  String get receiptChannel => 'Canal';

  @override
  String get receiptQtyShort => 'Qté';

  @override
  String get receiptTotalInclTax => 'Total TTC';

  @override
  String get receiptTotalExclTax => 'Total HT';

  @override
  String get receiptApproved => 'Transaction approuvée';

  @override
  String receiptRef(String ref) {
    return 'Réf. : $ref';
  }

  @override
  String receiptSeeYou(String name) {
    return 'À très bientôt chez $name';
  }

  @override
  String get receiptRecycle =>
      'Pour une planète plus verte, pensez à recycler ce ticket.';

  @override
  String get receiptLoyaltyTitle => 'Votre fidélité vous récompense !';

  @override
  String get receiptLoyaltyCaption =>
      'Scannez ce QR code pour accéder à votre espace fidélité et profiter de vos avantages.';

  @override
  String get receiptPaperLabel => 'Imprimante de tickets de cet appareil';

  @override
  String get receiptPaper80 => 'Rouleau 80 mm';

  @override
  String get receiptPaper58 => 'Rouleau 58 mm';

  @override
  String get receiptPhotosLabel => 'Photos des plats sur le ticket';

  @override
  String get receiptTestPrint => 'Imprimer un ticket d\'essai';

  @override
  String get receiptTestTitle => 'Ticket d\'essai';

  @override
  String get receiptHeaderSection => 'En-tête du ticket';

  @override
  String get receiptFooterSection => 'Bas du ticket';

  @override
  String get receiptTitleLabel => 'Nom affiché';

  @override
  String get receiptTitleHint => 'Par défaut : le nom de la marque';

  @override
  String get receiptSubtitleLabel => 'Sous-titre';

  @override
  String get receiptSubtitleHint => 'Ex. : Restaurant & Saveurs';

  @override
  String get receiptSloganLabel => 'Slogan';

  @override
  String get receiptSloganHint =>
      'Ex. : Une cuisine authentique, des saveurs du monde';

  @override
  String get websiteLabel => 'Site web';

  @override
  String get websiteHint => 'Ex. : www.monrestaurant.com';

  @override
  String get receiptQrTitleLabel => 'Titre à côté du QR code';

  @override
  String get receiptQrCaptionLabel => 'Texte à côté du QR code';

  @override
  String get receiptFarewellLabel => 'Formule d\'au revoir';

  @override
  String get receiptFarewellHint => 'Ex. : À très bientôt chez nous';

  @override
  String itemLikesTip(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count J\'aime',
      one: '1 J\'aime',
      zero: 'Aucun J\'aime',
    );
    return '$_temp0';
  }

  @override
  String get itemReviewAction => 'Avis';

  @override
  String get itemHeartAction => 'Cœur';

  @override
  String get itemCommentsTitle => 'Avis des clients';

  @override
  String get itemVerifiedReviews => 'Avis notés après une commande';

  @override
  String get notifStaffNewOrderTitle => 'Nouvelle commande';

  @override
  String notifStaffNewOrder(String number, String customer, String branch) {
    return 'Commande n° $number $customer — $branch';
  }

  @override
  String get notifStaffOrderReadyTitle => 'Commande prête à servir';

  @override
  String notifStaffOrderReady(String number, String branch) {
    return 'Commande n° $number — $branch';
  }

  @override
  String get notifStaffReservationTitle => 'Nouvelle réservation';

  @override
  String notifStaffReservation(String name, int count, String date) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count personnes',
      one: '1 personne',
    );
    return '$name · $_temp0 · $date';
  }

  @override
  String get notifStaffReviewTitle => 'Nouvel avis';

  @override
  String notifStaffReview(String author, String item) {
    return '$author sur « $item »';
  }

  @override
  String get pushNewOrder =>
      'Notification sur le téléphone : nouvelle commande d\'un client';

  @override
  String get pushOrderReady =>
      'Notification sur le téléphone : commande prête à servir';

  @override
  String get pushReservations =>
      'Notification sur le téléphone : nouvelle réservation';

  @override
  String get pushReviews =>
      'Notification sur le téléphone : nouvel avis sur un plat';

  @override
  String get tablesTab => 'Tables';

  @override
  String get tablesNow => 'Maintenant';

  @override
  String get tablesLater => 'Choisir un moment';

  @override
  String get tableLegendOccupied => 'Occupée';

  @override
  String get tableLegendReserved => 'Réservée';

  @override
  String get tableLegendChosen => 'Votre choix';

  @override
  String tableFreeUntil(String time) {
    return 'Libre jusqu\'à $time';
  }

  @override
  String tableOccupiedUntil(String time) {
    return 'Libre vers $time';
  }

  @override
  String tableReservedSlot(String from, String to) {
    return 'Réservée $from–$to';
  }

  @override
  String get tablesSelectHint =>
      'Touchez une ou plusieurs tables libres pour les réserver.';

  @override
  String tablesSeatsChosen(int seats, int party) {
    String _temp0 = intl.Intl.pluralLogic(
      seats,
      locale: localeName,
      other: '$seats places choisies',
      one: '1 place choisie',
    );
    String _temp1 = intl.Intl.pluralLogic(
      party,
      locale: localeName,
      other: '$party personnes',
      one: '1 personne',
    );
    return '$_temp0 pour $_temp1';
  }

  @override
  String reserveTablesAction(String tables) {
    return 'Réserver $tables';
  }

  @override
  String tableLabelChip(String label) {
    return 'Table $label';
  }

  @override
  String get tablesEmpty =>
      'Ce restaurant n\'a pas encore présenté ses tables.';
}
