import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('pt'),
    Locale('zh'),
    Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
  ];

  /// No description provided for @appName.
  ///
  /// In fr, this message translates to:
  /// **'Resto'**
  String get appName;

  /// No description provided for @environmentBanner.
  ///
  /// In fr, this message translates to:
  /// **'Environnement : {env}'**
  String environmentBanner(String env);

  /// No description provided for @configMissingTitle.
  ///
  /// In fr, this message translates to:
  /// **'Configuration manquante'**
  String get configMissingTitle;

  /// No description provided for @configMissingBody.
  ///
  /// In fr, this message translates to:
  /// **'L\'adresse du serveur et la clé publique ne sont pas fournies (fichier env/<environnement>.json).'**
  String get configMissingBody;

  /// No description provided for @languageLabel.
  ///
  /// In fr, this message translates to:
  /// **'Langue'**
  String get languageLabel;

  /// No description provided for @systemLanguage.
  ///
  /// In fr, this message translates to:
  /// **'Langue de l\'appareil'**
  String get systemLanguage;

  /// No description provided for @pendingSyncEvents.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Tout est synchronisé} =1{1 opération en attente} other{{count} opérations en attente}}'**
  String pendingSyncEvents(int count);

  /// No description provided for @errorNotAuthenticated.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez vous connecter.'**
  String get errorNotAuthenticated;

  /// No description provided for @errorForbidden.
  ///
  /// In fr, this message translates to:
  /// **'Vous n\'avez pas le droit d\'effectuer cette action.'**
  String get errorForbidden;

  /// No description provided for @errorOwnerOnly.
  ///
  /// In fr, this message translates to:
  /// **'Seul un propriétaire peut effectuer cette action.'**
  String get errorOwnerOnly;

  /// No description provided for @errorRateLimited.
  ///
  /// In fr, this message translates to:
  /// **'Trop de demandes. Réessayez plus tard.'**
  String get errorRateLimited;

  /// No description provided for @errorInvalidTimezone.
  ///
  /// In fr, this message translates to:
  /// **'Fuseau horaire inconnu.'**
  String get errorInvalidTimezone;

  /// No description provided for @errorInvalidRole.
  ///
  /// In fr, this message translates to:
  /// **'Rôle inconnu.'**
  String get errorInvalidRole;

  /// No description provided for @errorInvalidEmail.
  ///
  /// In fr, this message translates to:
  /// **'Adresse e-mail invalide.'**
  String get errorInvalidEmail;

  /// No description provided for @errorInvalidBranch.
  ///
  /// In fr, this message translates to:
  /// **'Établissement introuvable dans cette organisation.'**
  String get errorInvalidBranch;

  /// No description provided for @errorBranchesRequired.
  ///
  /// In fr, this message translates to:
  /// **'Choisissez au moins un établissement.'**
  String get errorBranchesRequired;

  /// No description provided for @errorAlreadyMember.
  ///
  /// In fr, this message translates to:
  /// **'Cette personne fait déjà partie de l\'organisation.'**
  String get errorAlreadyMember;

  /// No description provided for @errorInvitationInvalid.
  ///
  /// In fr, this message translates to:
  /// **'Invitation invalide, expirée ou déjà utilisée.'**
  String get errorInvitationInvalid;

  /// No description provided for @errorInvitationWrongAccount.
  ///
  /// In fr, this message translates to:
  /// **'Cette invitation est destinée à une autre adresse e-mail.'**
  String get errorInvitationWrongAccount;

  /// No description provided for @errorLastOwner.
  ///
  /// In fr, this message translates to:
  /// **'L\'organisation doit garder au moins un propriétaire.'**
  String get errorLastOwner;

  /// No description provided for @errorMembershipRevoked.
  ///
  /// In fr, this message translates to:
  /// **'Ce membre a été retiré de l\'organisation.'**
  String get errorMembershipRevoked;

  /// No description provided for @errorNetwork.
  ///
  /// In fr, this message translates to:
  /// **'Connexion impossible. Vérifiez votre accès à Internet.'**
  String get errorNetwork;

  /// No description provided for @errorUnknown.
  ///
  /// In fr, this message translates to:
  /// **'Une erreur inattendue s\'est produite.'**
  String get errorUnknown;

  /// No description provided for @welcomeTitle.
  ///
  /// In fr, this message translates to:
  /// **'Bienvenue sur Resto'**
  String get welcomeTitle;

  /// No description provided for @signInTitle.
  ///
  /// In fr, this message translates to:
  /// **'Connexion'**
  String get signInTitle;

  /// No description provided for @signIn.
  ///
  /// In fr, this message translates to:
  /// **'Se connecter'**
  String get signIn;

  /// No description provided for @signOut.
  ///
  /// In fr, this message translates to:
  /// **'Se déconnecter'**
  String get signOut;

  /// No description provided for @createAccount.
  ///
  /// In fr, this message translates to:
  /// **'Créer un compte'**
  String get createAccount;

  /// No description provided for @forgotPassword.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe oublié'**
  String get forgotPassword;

  /// No description provided for @email.
  ///
  /// In fr, this message translates to:
  /// **'E-mail'**
  String get email;

  /// No description provided for @password.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe'**
  String get password;

  /// No description provided for @passwordConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer le mot de passe'**
  String get passwordConfirm;

  /// No description provided for @passwordTooShort.
  ///
  /// In fr, this message translates to:
  /// **'8 caractères minimum.'**
  String get passwordTooShort;

  /// No description provided for @passwordsDiffer.
  ///
  /// In fr, this message translates to:
  /// **'Les mots de passe ne correspondent pas.'**
  String get passwordsDiffer;

  /// No description provided for @passwordChanged.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe modifié.'**
  String get passwordChanged;

  /// No description provided for @newPasswordTitle.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau mot de passe'**
  String get newPasswordTitle;

  /// No description provided for @changePassword.
  ///
  /// In fr, this message translates to:
  /// **'Changer le mot de passe'**
  String get changePassword;

  /// No description provided for @displayName.
  ///
  /// In fr, this message translates to:
  /// **'Nom'**
  String get displayName;

  /// No description provided for @fieldRequired.
  ///
  /// In fr, this message translates to:
  /// **'Champ obligatoire'**
  String get fieldRequired;

  /// No description provided for @verifyEmailTitle.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer votre adresse e-mail'**
  String get verifyEmailTitle;

  /// No description provided for @codeSentTo.
  ///
  /// In fr, this message translates to:
  /// **'Code envoyé à {email}.'**
  String codeSentTo(String email);

  /// No description provided for @code.
  ///
  /// In fr, this message translates to:
  /// **'Code'**
  String get code;

  /// No description provided for @verify.
  ///
  /// In fr, this message translates to:
  /// **'Valider'**
  String get verify;

  /// No description provided for @resendCode.
  ///
  /// In fr, this message translates to:
  /// **'Renvoyer le code'**
  String get resendCode;

  /// No description provided for @codeResent.
  ///
  /// In fr, this message translates to:
  /// **'Un nouveau code a été envoyé.'**
  String get codeResent;

  /// No description provided for @sendCode.
  ///
  /// In fr, this message translates to:
  /// **'Envoyer le code'**
  String get sendCode;

  /// No description provided for @authInvalidCredentials.
  ///
  /// In fr, this message translates to:
  /// **'E-mail ou mot de passe incorrect.'**
  String get authInvalidCredentials;

  /// No description provided for @authEmailNotConfirmed.
  ///
  /// In fr, this message translates to:
  /// **'Adresse e-mail non confirmée.'**
  String get authEmailNotConfirmed;

  /// No description provided for @authUserExists.
  ///
  /// In fr, this message translates to:
  /// **'Un compte existe déjà avec cette adresse.'**
  String get authUserExists;

  /// No description provided for @authWeakPassword.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe trop faible.'**
  String get authWeakPassword;

  /// No description provided for @authCodeInvalid.
  ///
  /// In fr, this message translates to:
  /// **'Code invalide ou expiré.'**
  String get authCodeInvalid;

  /// No description provided for @authSamePassword.
  ///
  /// In fr, this message translates to:
  /// **'Le nouveau mot de passe doit être différent de l\'ancien.'**
  String get authSamePassword;

  /// No description provided for @errorDuplicate.
  ///
  /// In fr, this message translates to:
  /// **'Cette valeur existe déjà.'**
  String get errorDuplicate;

  /// No description provided for @errorInvalidHours.
  ///
  /// In fr, this message translates to:
  /// **'Horaires invalides.'**
  String get errorInvalidHours;

  /// No description provided for @createRestaurant.
  ///
  /// In fr, this message translates to:
  /// **'Créer mon restaurant'**
  String get createRestaurant;

  /// No description provided for @joinTeam.
  ///
  /// In fr, this message translates to:
  /// **'Rejoindre une équipe'**
  String get joinTeam;

  /// No description provided for @organizationName.
  ///
  /// In fr, this message translates to:
  /// **'Nom de l\'organisation'**
  String get organizationName;

  /// No description provided for @brandNameOptional.
  ///
  /// In fr, this message translates to:
  /// **'Nom commercial (facultatif)'**
  String get brandNameOptional;

  /// No description provided for @branchNameOptional.
  ///
  /// In fr, this message translates to:
  /// **'Nom de l\'établissement (facultatif)'**
  String get branchNameOptional;

  /// No description provided for @country.
  ///
  /// In fr, this message translates to:
  /// **'Pays'**
  String get country;

  /// No description provided for @currency.
  ///
  /// In fr, this message translates to:
  /// **'Monnaie'**
  String get currency;

  /// No description provided for @timezone.
  ///
  /// In fr, this message translates to:
  /// **'Fuseau horaire'**
  String get timezone;

  /// No description provided for @defaultLanguage.
  ///
  /// In fr, this message translates to:
  /// **'Langue principale'**
  String get defaultLanguage;

  /// No description provided for @city.
  ///
  /// In fr, this message translates to:
  /// **'Ville'**
  String get city;

  /// No description provided for @create.
  ///
  /// In fr, this message translates to:
  /// **'Créer'**
  String get create;

  /// No description provided for @invitationCode.
  ///
  /// In fr, this message translates to:
  /// **'Code d\'invitation'**
  String get invitationCode;

  /// No description provided for @join.
  ///
  /// In fr, this message translates to:
  /// **'Rejoindre'**
  String get join;

  /// No description provided for @navBranches.
  ///
  /// In fr, this message translates to:
  /// **'Établissements'**
  String get navBranches;

  /// No description provided for @navTeam.
  ///
  /// In fr, this message translates to:
  /// **'Équipe'**
  String get navTeam;

  /// No description provided for @navAudit.
  ///
  /// In fr, this message translates to:
  /// **'Journal'**
  String get navAudit;

  /// No description provided for @navAccount.
  ///
  /// In fr, this message translates to:
  /// **'Compte'**
  String get navAccount;

  /// No description provided for @switchOrganization.
  ///
  /// In fr, this message translates to:
  /// **'Changer d\'organisation'**
  String get switchOrganization;

  /// No description provided for @orgSuspended.
  ///
  /// In fr, this message translates to:
  /// **'Organisation suspendue : consultation uniquement.'**
  String get orgSuspended;

  /// No description provided for @newBranch.
  ///
  /// In fr, this message translates to:
  /// **'Nouvel établissement'**
  String get newBranch;

  /// No description provided for @noBranches.
  ///
  /// In fr, this message translates to:
  /// **'Aucun établissement.'**
  String get noBranches;

  /// No description provided for @branchInfo.
  ///
  /// In fr, this message translates to:
  /// **'Informations'**
  String get branchInfo;

  /// No description provided for @openingHours.
  ///
  /// In fr, this message translates to:
  /// **'Horaires'**
  String get openingHours;

  /// No description provided for @floor.
  ///
  /// In fr, this message translates to:
  /// **'Salle'**
  String get floor;

  /// No description provided for @name.
  ///
  /// In fr, this message translates to:
  /// **'Nom'**
  String get name;

  /// No description provided for @addressLine1.
  ///
  /// In fr, this message translates to:
  /// **'Adresse'**
  String get addressLine1;

  /// No description provided for @addressLine2.
  ///
  /// In fr, this message translates to:
  /// **'Complément d\'adresse'**
  String get addressLine2;

  /// No description provided for @region.
  ///
  /// In fr, this message translates to:
  /// **'Région'**
  String get region;

  /// No description provided for @postalCode.
  ///
  /// In fr, this message translates to:
  /// **'Code postal'**
  String get postalCode;

  /// No description provided for @phone.
  ///
  /// In fr, this message translates to:
  /// **'Téléphone'**
  String get phone;

  /// No description provided for @offeredLanguages.
  ///
  /// In fr, this message translates to:
  /// **'Langues proposées'**
  String get offeredLanguages;

  /// No description provided for @published.
  ///
  /// In fr, this message translates to:
  /// **'Visible par les clients'**
  String get published;

  /// No description provided for @archived.
  ///
  /// In fr, this message translates to:
  /// **'Archivé'**
  String get archived;

  /// No description provided for @readOnly.
  ///
  /// In fr, this message translates to:
  /// **'Consultation uniquement'**
  String get readOnly;

  /// No description provided for @save.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer'**
  String get save;

  /// No description provided for @saved.
  ///
  /// In fr, this message translates to:
  /// **'Enregistré.'**
  String get saved;

  /// No description provided for @cancel.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer'**
  String get confirm;

  /// No description provided for @close.
  ///
  /// In fr, this message translates to:
  /// **'Fermer'**
  String get close;

  /// No description provided for @edit.
  ///
  /// In fr, this message translates to:
  /// **'Modifier'**
  String get edit;

  /// No description provided for @retry.
  ///
  /// In fr, this message translates to:
  /// **'Réessayer'**
  String get retry;

  /// No description provided for @closed.
  ///
  /// In fr, this message translates to:
  /// **'Fermé'**
  String get closed;

  /// No description provided for @addSlot.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter une plage'**
  String get addSlot;

  /// No description provided for @opensAt.
  ///
  /// In fr, this message translates to:
  /// **'Ouverture'**
  String get opensAt;

  /// No description provided for @closesAt.
  ///
  /// In fr, this message translates to:
  /// **'Fermeture'**
  String get closesAt;

  /// No description provided for @nextDay.
  ///
  /// In fr, this message translates to:
  /// **'lendemain'**
  String get nextDay;

  /// No description provided for @weekday1.
  ///
  /// In fr, this message translates to:
  /// **'Lundi'**
  String get weekday1;

  /// No description provided for @weekday2.
  ///
  /// In fr, this message translates to:
  /// **'Mardi'**
  String get weekday2;

  /// No description provided for @weekday3.
  ///
  /// In fr, this message translates to:
  /// **'Mercredi'**
  String get weekday3;

  /// No description provided for @weekday4.
  ///
  /// In fr, this message translates to:
  /// **'Jeudi'**
  String get weekday4;

  /// No description provided for @weekday5.
  ///
  /// In fr, this message translates to:
  /// **'Vendredi'**
  String get weekday5;

  /// No description provided for @weekday6.
  ///
  /// In fr, this message translates to:
  /// **'Samedi'**
  String get weekday6;

  /// No description provided for @weekday7.
  ///
  /// In fr, this message translates to:
  /// **'Dimanche'**
  String get weekday7;

  /// No description provided for @newArea.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle zone'**
  String get newArea;

  /// No description provided for @areaName.
  ///
  /// In fr, this message translates to:
  /// **'Zone'**
  String get areaName;

  /// No description provided for @noAreas.
  ///
  /// In fr, this message translates to:
  /// **'Aucune zone pour l\'instant.'**
  String get noAreas;

  /// No description provided for @newTable.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle table'**
  String get newTable;

  /// No description provided for @tableLabel.
  ///
  /// In fr, this message translates to:
  /// **'Nom de la table'**
  String get tableLabel;

  /// No description provided for @seats.
  ///
  /// In fr, this message translates to:
  /// **'Places'**
  String get seats;

  /// No description provided for @active.
  ///
  /// In fr, this message translates to:
  /// **'Actif'**
  String get active;

  /// No description provided for @inactive.
  ///
  /// In fr, this message translates to:
  /// **'désactivé'**
  String get inactive;

  /// No description provided for @tablesCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{aucune table} =1{1 table} other{{count} tables}}'**
  String tablesCount(int count);

  /// No description provided for @seatsCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{1 place} other{{count} places}}'**
  String seatsCount(int count);

  /// No description provided for @invite.
  ///
  /// In fr, this message translates to:
  /// **'Inviter'**
  String get invite;

  /// No description provided for @role.
  ///
  /// In fr, this message translates to:
  /// **'Rôle'**
  String get role;

  /// No description provided for @allBranches.
  ///
  /// In fr, this message translates to:
  /// **'Tous les établissements'**
  String get allBranches;

  /// No description provided for @pendingInvitations.
  ///
  /// In fr, this message translates to:
  /// **'Invitations en attente'**
  String get pendingInvitations;

  /// No description provided for @expiresOn.
  ///
  /// In fr, this message translates to:
  /// **'Expire le {date}'**
  String expiresOn(String date);

  /// No description provided for @revoke.
  ///
  /// In fr, this message translates to:
  /// **'Retirer'**
  String get revoke;

  /// No description provided for @revokeConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Retirer {name} de l\'organisation ?'**
  String revokeConfirm(String name);

  /// No description provided for @changeRole.
  ///
  /// In fr, this message translates to:
  /// **'Modifier le rôle'**
  String get changeRole;

  /// No description provided for @you.
  ///
  /// In fr, this message translates to:
  /// **'vous'**
  String get you;

  /// No description provided for @invitationCreatedTitle.
  ///
  /// In fr, this message translates to:
  /// **'Invitation créée'**
  String get invitationCreatedTitle;

  /// No description provided for @invitationCreatedBody.
  ///
  /// In fr, this message translates to:
  /// **'Transmettez ce code à {email}. Il est valable 7 jours et ne fonctionne qu\'avec cette adresse.'**
  String invitationCreatedBody(String email);

  /// No description provided for @invitationMessage.
  ///
  /// In fr, this message translates to:
  /// **'Vous êtes invité(e) à rejoindre « {organization} » sur Resto. Créez votre compte avec cette adresse e-mail, puis saisissez ce code dans « Rejoindre une équipe » : {code}'**
  String invitationMessage(String organization, String code);

  /// No description provided for @copyMessage.
  ///
  /// In fr, this message translates to:
  /// **'Copier le message'**
  String get copyMessage;

  /// No description provided for @copied.
  ///
  /// In fr, this message translates to:
  /// **'Copié.'**
  String get copied;

  /// No description provided for @roleOwner.
  ///
  /// In fr, this message translates to:
  /// **'Propriétaire'**
  String get roleOwner;

  /// No description provided for @roleAdmin.
  ///
  /// In fr, this message translates to:
  /// **'Administrateur'**
  String get roleAdmin;

  /// No description provided for @roleManager.
  ///
  /// In fr, this message translates to:
  /// **'Responsable'**
  String get roleManager;

  /// No description provided for @roleAccountant.
  ///
  /// In fr, this message translates to:
  /// **'Comptable'**
  String get roleAccountant;

  /// No description provided for @roleCashier.
  ///
  /// In fr, this message translates to:
  /// **'Caissier'**
  String get roleCashier;

  /// No description provided for @roleStockKeeper.
  ///
  /// In fr, this message translates to:
  /// **'Magasinier'**
  String get roleStockKeeper;

  /// No description provided for @roleWaiter.
  ///
  /// In fr, this message translates to:
  /// **'Serveur'**
  String get roleWaiter;

  /// No description provided for @roleKitchen.
  ///
  /// In fr, this message translates to:
  /// **'Cuisine / bar'**
  String get roleKitchen;

  /// No description provided for @roleViewer.
  ///
  /// In fr, this message translates to:
  /// **'Lecteur'**
  String get roleViewer;

  /// No description provided for @loadMore.
  ///
  /// In fr, this message translates to:
  /// **'Afficher plus'**
  String get loadMore;

  /// No description provided for @noEntries.
  ///
  /// In fr, this message translates to:
  /// **'Aucune opération enregistrée.'**
  String get noEntries;

  /// No description provided for @actionInsert.
  ///
  /// In fr, this message translates to:
  /// **'Création'**
  String get actionInsert;

  /// No description provided for @actionUpdate.
  ///
  /// In fr, this message translates to:
  /// **'Modification'**
  String get actionUpdate;

  /// No description provided for @actionDelete.
  ///
  /// In fr, this message translates to:
  /// **'Suppression'**
  String get actionDelete;

  /// No description provided for @entityOrganization.
  ///
  /// In fr, this message translates to:
  /// **'Organisation'**
  String get entityOrganization;

  /// No description provided for @entityMembership.
  ///
  /// In fr, this message translates to:
  /// **'Membre'**
  String get entityMembership;

  /// No description provided for @entityInvitation.
  ///
  /// In fr, this message translates to:
  /// **'Invitation'**
  String get entityInvitation;

  /// No description provided for @entityBrand.
  ///
  /// In fr, this message translates to:
  /// **'Marque'**
  String get entityBrand;

  /// No description provided for @entityBranch.
  ///
  /// In fr, this message translates to:
  /// **'Établissement'**
  String get entityBranch;

  /// No description provided for @entityArea.
  ///
  /// In fr, this message translates to:
  /// **'Zone'**
  String get entityArea;

  /// No description provided for @entityTable.
  ///
  /// In fr, this message translates to:
  /// **'Table'**
  String get entityTable;

  /// No description provided for @navMenus.
  ///
  /// In fr, this message translates to:
  /// **'Menus'**
  String get navMenus;

  /// No description provided for @brand.
  ///
  /// In fr, this message translates to:
  /// **'Marque'**
  String get brand;

  /// No description provided for @category.
  ///
  /// In fr, this message translates to:
  /// **'Catégorie'**
  String get category;

  /// No description provided for @description.
  ///
  /// In fr, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @newCategory.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle catégorie'**
  String get newCategory;

  /// No description provided for @kindFood.
  ///
  /// In fr, this message translates to:
  /// **'Plat'**
  String get kindFood;

  /// No description provided for @kindDrink.
  ///
  /// In fr, this message translates to:
  /// **'Boisson'**
  String get kindDrink;

  /// No description provided for @kindOther.
  ///
  /// In fr, this message translates to:
  /// **'Autre'**
  String get kindOther;

  /// No description provided for @selectionRule.
  ///
  /// In fr, this message translates to:
  /// **'Choix : de {min} à {max}'**
  String selectionRule(int min, String max);

  /// No description provided for @allergens.
  ///
  /// In fr, this message translates to:
  /// **'Allergènes'**
  String get allergens;

  /// No description provided for @allergenGluten.
  ///
  /// In fr, this message translates to:
  /// **'Gluten'**
  String get allergenGluten;

  /// No description provided for @allergenCrustaceans.
  ///
  /// In fr, this message translates to:
  /// **'Crustacés'**
  String get allergenCrustaceans;

  /// No description provided for @allergenEggs.
  ///
  /// In fr, this message translates to:
  /// **'Œufs'**
  String get allergenEggs;

  /// No description provided for @allergenFish.
  ///
  /// In fr, this message translates to:
  /// **'Poisson'**
  String get allergenFish;

  /// No description provided for @allergenPeanuts.
  ///
  /// In fr, this message translates to:
  /// **'Arachides'**
  String get allergenPeanuts;

  /// No description provided for @allergenSoybeans.
  ///
  /// In fr, this message translates to:
  /// **'Soja'**
  String get allergenSoybeans;

  /// No description provided for @allergenMilk.
  ///
  /// In fr, this message translates to:
  /// **'Lait'**
  String get allergenMilk;

  /// No description provided for @allergenNuts.
  ///
  /// In fr, this message translates to:
  /// **'Fruits à coque'**
  String get allergenNuts;

  /// No description provided for @allergenCelery.
  ///
  /// In fr, this message translates to:
  /// **'Céleri'**
  String get allergenCelery;

  /// No description provided for @allergenMustard.
  ///
  /// In fr, this message translates to:
  /// **'Moutarde'**
  String get allergenMustard;

  /// No description provided for @allergenSesame.
  ///
  /// In fr, this message translates to:
  /// **'Sésame'**
  String get allergenSesame;

  /// No description provided for @allergenSulphites.
  ///
  /// In fr, this message translates to:
  /// **'Sulfites'**
  String get allergenSulphites;

  /// No description provided for @allergenLupin.
  ///
  /// In fr, this message translates to:
  /// **'Lupin'**
  String get allergenLupin;

  /// No description provided for @allergenMolluscs.
  ///
  /// In fr, this message translates to:
  /// **'Mollusques'**
  String get allergenMolluscs;

  /// No description provided for @translations.
  ///
  /// In fr, this message translates to:
  /// **'Traductions'**
  String get translations;

  /// No description provided for @soldOut.
  ///
  /// In fr, this message translates to:
  /// **'Épuisé'**
  String get soldOut;

  /// No description provided for @channelDefault.
  ///
  /// In fr, this message translates to:
  /// **'Prix de base'**
  String get channelDefault;

  /// No description provided for @channelDineIn.
  ///
  /// In fr, this message translates to:
  /// **'Sur place'**
  String get channelDineIn;

  /// No description provided for @channelTakeaway.
  ///
  /// In fr, this message translates to:
  /// **'À emporter'**
  String get channelTakeaway;

  /// No description provided for @channelDelivery.
  ///
  /// In fr, this message translates to:
  /// **'Livraison'**
  String get channelDelivery;

  /// No description provided for @otherChannels.
  ///
  /// In fr, this message translates to:
  /// **'Prix par canal'**
  String get otherChannels;

  /// No description provided for @noPrice.
  ///
  /// In fr, this message translates to:
  /// **'Sans prix'**
  String get noPrice;

  /// No description provided for @errorInvalidPrice.
  ///
  /// In fr, this message translates to:
  /// **'Prix invalide.'**
  String get errorInvalidPrice;

  /// No description provided for @errorCurrencyLocked.
  ///
  /// In fr, this message translates to:
  /// **'La monnaie ne peut plus changer : des prix existent déjà dans cet établissement.'**
  String get errorCurrencyLocked;

  /// No description provided for @entityItem.
  ///
  /// In fr, this message translates to:
  /// **'Article'**
  String get entityItem;

  /// No description provided for @entityVariant.
  ///
  /// In fr, this message translates to:
  /// **'Variante'**
  String get entityVariant;

  /// No description provided for @entityModifier.
  ///
  /// In fr, this message translates to:
  /// **'Supplément'**
  String get entityModifier;

  /// No description provided for @entityPrice.
  ///
  /// In fr, this message translates to:
  /// **'Prix'**
  String get entityPrice;

  /// No description provided for @menuOfBranch.
  ///
  /// In fr, this message translates to:
  /// **'Menu de l\'établissement'**
  String get menuOfBranch;

  /// No description provided for @menuEmptyTitle.
  ///
  /// In fr, this message translates to:
  /// **'Votre menu est vide'**
  String get menuEmptyTitle;

  /// No description provided for @menuEmptyHint.
  ///
  /// In fr, this message translates to:
  /// **'Commencez par créer une catégorie (par exemple Plats, Boissons, Desserts), puis ajoutez-y vos articles avec leur prix.'**
  String get menuEmptyHint;

  /// No description provided for @categoryExamples.
  ///
  /// In fr, this message translates to:
  /// **'Ex. : Plats, Boissons, Desserts'**
  String get categoryExamples;

  /// No description provided for @descriptionOptional.
  ///
  /// In fr, this message translates to:
  /// **'Description (facultatif)'**
  String get descriptionOptional;

  /// No description provided for @visibleOnMenu.
  ///
  /// In fr, this message translates to:
  /// **'Visible sur la carte'**
  String get visibleOnMenu;

  /// No description provided for @hidden.
  ///
  /// In fr, this message translates to:
  /// **'masqué'**
  String get hidden;

  /// No description provided for @addItem.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un article'**
  String get addItem;

  /// No description provided for @addItemIn.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un article dans « {category} »'**
  String addItemIn(String category);

  /// No description provided for @notSoldHere.
  ///
  /// In fr, this message translates to:
  /// **'Pas vendu dans cet établissement'**
  String get notSoldHere;

  /// No description provided for @itemName.
  ///
  /// In fr, this message translates to:
  /// **'Nom de l\'article'**
  String get itemName;

  /// No description provided for @itemExamples.
  ///
  /// In fr, this message translates to:
  /// **'Ex. : Ndolé, Poulet DG, Jus de bissap'**
  String get itemExamples;

  /// No description provided for @priceTitle.
  ///
  /// In fr, this message translates to:
  /// **'Prix'**
  String get priceTitle;

  /// No description provided for @priceAt.
  ///
  /// In fr, this message translates to:
  /// **'Prix à {branch}'**
  String priceAt(String branch);

  /// No description provided for @price.
  ///
  /// In fr, this message translates to:
  /// **'Prix'**
  String get price;

  /// No description provided for @severalSizes.
  ///
  /// In fr, this message translates to:
  /// **'Cet article existe en plusieurs tailles ou formats'**
  String get severalSizes;

  /// No description provided for @sizeName.
  ///
  /// In fr, this message translates to:
  /// **'Taille / format'**
  String get sizeName;

  /// No description provided for @sizeExamples.
  ///
  /// In fr, this message translates to:
  /// **'Ex. : Petite, 33 cl'**
  String get sizeExamples;

  /// No description provided for @addSize.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter une taille'**
  String get addSize;

  /// No description provided for @removeSize.
  ///
  /// In fr, this message translates to:
  /// **'Retirer cette taille'**
  String get removeSize;

  /// No description provided for @sizeNameRequired.
  ///
  /// In fr, this message translates to:
  /// **'Donnez un nom à chaque taille (par exemple Petite, Grande).'**
  String get sizeNameRequired;

  /// No description provided for @samePriceEverywhere.
  ///
  /// In fr, this message translates to:
  /// **'Ce prix s\'appliquera dans tous les établissements choisis ci-dessous ; vous pourrez l\'adapter ensuite pour chacun.'**
  String get samePriceEverywhere;

  /// No description provided for @salesTitle.
  ///
  /// In fr, this message translates to:
  /// **'Vente'**
  String get salesTitle;

  /// No description provided for @soldAt.
  ///
  /// In fr, this message translates to:
  /// **'Vendu à {branch}'**
  String soldAt(String branch);

  /// No description provided for @soldOutToday.
  ///
  /// In fr, this message translates to:
  /// **'Épuisé pour le moment'**
  String get soldOutToday;

  /// No description provided for @optionsForItem.
  ///
  /// In fr, this message translates to:
  /// **'Options proposées au client'**
  String get optionsForItem;

  /// No description provided for @manageOptions.
  ///
  /// In fr, this message translates to:
  /// **'Gérer les options'**
  String get manageOptions;

  /// No description provided for @noOptionsYet.
  ///
  /// In fr, this message translates to:
  /// **'Aucune option pour l\'instant (accompagnement, cuisson, sauce…).'**
  String get noOptionsYet;

  /// No description provided for @optionsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Options et suppléments'**
  String get optionsTitle;

  /// No description provided for @optionsIntro.
  ///
  /// In fr, this message translates to:
  /// **'Une option est un choix que le client fait en commandant un article : son accompagnement, la cuisson, une sauce, un supplément payant…'**
  String get optionsIntro;

  /// No description provided for @newOptionGroup.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle option'**
  String get newOptionGroup;

  /// No description provided for @optionGroupName.
  ///
  /// In fr, this message translates to:
  /// **'Nom de l\'option'**
  String get optionGroupName;

  /// No description provided for @optionGroupExamples.
  ///
  /// In fr, this message translates to:
  /// **'Ex. : Accompagnement, Cuisson, Piment'**
  String get optionGroupExamples;

  /// No description provided for @customerMust.
  ///
  /// In fr, this message translates to:
  /// **'Le client :'**
  String get customerMust;

  /// No description provided for @ruleRequiredOne.
  ///
  /// In fr, this message translates to:
  /// **'doit faire 1 choix (obligatoire)'**
  String get ruleRequiredOne;

  /// No description provided for @ruleOptionalOne.
  ///
  /// In fr, this message translates to:
  /// **'peut faire 1 choix (facultatif)'**
  String get ruleOptionalOne;

  /// No description provided for @ruleOptionalMany.
  ///
  /// In fr, this message translates to:
  /// **'peut faire plusieurs choix (facultatif)'**
  String get ruleOptionalMany;

  /// No description provided for @ruleRequiredMany.
  ///
  /// In fr, this message translates to:
  /// **'doit faire au moins 1 choix, plusieurs possibles'**
  String get ruleRequiredMany;

  /// No description provided for @choices.
  ///
  /// In fr, this message translates to:
  /// **'Choix proposés'**
  String get choices;

  /// No description provided for @choicePriceHint.
  ///
  /// In fr, this message translates to:
  /// **'Laissez le prix vide ou à 0 si le choix est gratuit. Prix pour {branch}.'**
  String choicePriceHint(String branch);

  /// No description provided for @choiceName.
  ///
  /// In fr, this message translates to:
  /// **'Choix'**
  String get choiceName;

  /// No description provided for @choiceExamples.
  ///
  /// In fr, this message translates to:
  /// **'Ex. : Miondo, Riz'**
  String get choiceExamples;

  /// No description provided for @extraPrice.
  ///
  /// In fr, this message translates to:
  /// **'Prix en plus'**
  String get extraPrice;

  /// No description provided for @addChoice.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un choix'**
  String get addChoice;

  /// No description provided for @removeChoice.
  ///
  /// In fr, this message translates to:
  /// **'Retirer ce choix'**
  String get removeChoice;

  /// No description provided for @choicesRequired.
  ///
  /// In fr, this message translates to:
  /// **'Ajoutez au moins un choix.'**
  String get choicesRequired;

  /// No description provided for @navOrders.
  ///
  /// In fr, this message translates to:
  /// **'Commandes'**
  String get navOrders;

  /// No description provided for @openOrdersCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Aucune commande en cours} =1{1 commande en cours} other{{count} commandes en cours}}'**
  String openOrdersCount(int count);

  /// No description provided for @refresh.
  ///
  /// In fr, this message translates to:
  /// **'Actualiser'**
  String get refresh;

  /// No description provided for @newTakeaway.
  ///
  /// In fr, this message translates to:
  /// **'Vente à emporter'**
  String get newTakeaway;

  /// No description provided for @takeawayOrders.
  ///
  /// In fr, this message translates to:
  /// **'À emporter en cours'**
  String get takeawayOrders;

  /// No description provided for @orderNumber.
  ///
  /// In fr, this message translates to:
  /// **'Commande n° {number}'**
  String orderNumber(int number);

  /// No description provided for @minutesAgo.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{à l\'instant} =1{il y a 1 min} other{il y a {count} min}}'**
  String minutesAgo(int count);

  /// No description provided for @noTablesYet.
  ///
  /// In fr, this message translates to:
  /// **'Aucune table : créez la salle dans Établissements → Salle. Les ventes à emporter restent possibles.'**
  String get noTablesYet;

  /// No description provided for @tableFree.
  ///
  /// In fr, this message translates to:
  /// **'Libre'**
  String get tableFree;

  /// No description provided for @toSend.
  ///
  /// In fr, this message translates to:
  /// **'Articles à envoyer en cuisine'**
  String get toSend;

  /// No description provided for @tableName.
  ///
  /// In fr, this message translates to:
  /// **'Table {label}'**
  String tableName(String label);

  /// No description provided for @menuTab.
  ///
  /// In fr, this message translates to:
  /// **'Carte'**
  String get menuTab;

  /// No description provided for @ticketTab.
  ///
  /// In fr, this message translates to:
  /// **'Commande ({count})'**
  String ticketTab(int count);

  /// No description provided for @allCategories.
  ///
  /// In fr, this message translates to:
  /// **'Tout'**
  String get allCategories;

  /// No description provided for @nothingToSell.
  ///
  /// In fr, this message translates to:
  /// **'Rien à vendre pour l\'instant : ajoutez des articles avec un prix dans Menus.'**
  String get nothingToSell;

  /// No description provided for @fromPrice.
  ///
  /// In fr, this message translates to:
  /// **'dès {price}'**
  String fromPrice(String price);

  /// No description provided for @itemSoldOut.
  ///
  /// In fr, this message translates to:
  /// **'{name} est épuisé.'**
  String itemSoldOut(String name);

  /// No description provided for @emptyTicket.
  ///
  /// In fr, this message translates to:
  /// **'Touchez un article de la carte pour l\'ajouter.'**
  String get emptyTicket;

  /// No description provided for @less.
  ///
  /// In fr, this message translates to:
  /// **'Un de moins'**
  String get less;

  /// No description provided for @more.
  ///
  /// In fr, this message translates to:
  /// **'Un de plus'**
  String get more;

  /// No description provided for @cancelLine.
  ///
  /// In fr, this message translates to:
  /// **'Annuler cette ligne'**
  String get cancelLine;

  /// No description provided for @cancelOrder.
  ///
  /// In fr, this message translates to:
  /// **'Annuler la commande'**
  String get cancelOrder;

  /// No description provided for @cancelOrderConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Annuler cette commande ? Rien n\'est encore parti en cuisine.'**
  String get cancelOrderConfirm;

  /// No description provided for @reason.
  ///
  /// In fr, this message translates to:
  /// **'Motif'**
  String get reason;

  /// No description provided for @subtotal.
  ///
  /// In fr, this message translates to:
  /// **'Sous-total'**
  String get subtotal;

  /// No description provided for @taxLine.
  ///
  /// In fr, this message translates to:
  /// **'Taxe ({rate} %)'**
  String taxLine(String rate);

  /// No description provided for @total.
  ///
  /// In fr, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @taxIncluded.
  ///
  /// In fr, this message translates to:
  /// **'dont taxe {rate} % : {amount}'**
  String taxIncluded(String rate, String amount);

  /// No description provided for @sendToKitchen.
  ///
  /// In fr, this message translates to:
  /// **'Envoyer en cuisine ({count})'**
  String sendToKitchen(int count);

  /// No description provided for @sentToKitchen.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{1 article envoyé en cuisine} other{{count} articles envoyés en cuisine}}'**
  String sentToKitchen(int count);

  /// No description provided for @prepPending.
  ///
  /// In fr, this message translates to:
  /// **'À envoyer'**
  String get prepPending;

  /// No description provided for @prepSent.
  ///
  /// In fr, this message translates to:
  /// **'En cuisine'**
  String get prepSent;

  /// No description provided for @prepPreparing.
  ///
  /// In fr, this message translates to:
  /// **'En préparation'**
  String get prepPreparing;

  /// No description provided for @prepReady.
  ///
  /// In fr, this message translates to:
  /// **'Prêt'**
  String get prepReady;

  /// No description provided for @prepServed.
  ///
  /// In fr, this message translates to:
  /// **'Servi'**
  String get prepServed;

  /// No description provided for @prepCancelled.
  ///
  /// In fr, this message translates to:
  /// **'Annulé'**
  String get prepCancelled;

  /// No description provided for @noneOption.
  ///
  /// In fr, this message translates to:
  /// **'Aucun'**
  String get noneOption;

  /// No description provided for @kitchenNote.
  ///
  /// In fr, this message translates to:
  /// **'Remarque pour la cuisine (facultatif)'**
  String get kitchenNote;

  /// No description provided for @kitchenNoteExamples.
  ///
  /// In fr, this message translates to:
  /// **'Ex. : sans oignon, bien cuit'**
  String get kitchenNoteExamples;

  /// No description provided for @quantity.
  ///
  /// In fr, this message translates to:
  /// **'Quantité'**
  String get quantity;

  /// No description provided for @addForPrice.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter · {price}'**
  String addForPrice(String price);

  /// No description provided for @taxTitle.
  ///
  /// In fr, this message translates to:
  /// **'Taxe'**
  String get taxTitle;

  /// No description provided for @taxRate.
  ///
  /// In fr, this message translates to:
  /// **'Taux de taxe'**
  String get taxRate;

  /// No description provided for @taxRateHint.
  ///
  /// In fr, this message translates to:
  /// **'Ex. : 19,25 (0 si aucune taxe)'**
  String get taxRateHint;

  /// No description provided for @pricesIncludeTax.
  ///
  /// In fr, this message translates to:
  /// **'Les prix affichés incluent la taxe'**
  String get pricesIncludeTax;

  /// No description provided for @errorInvalidTaxRate.
  ///
  /// In fr, this message translates to:
  /// **'Taux invalide (de 0 à 99,999).'**
  String get errorInvalidTaxRate;

  /// No description provided for @errorOrderNotOpen.
  ///
  /// In fr, this message translates to:
  /// **'Cette commande n\'est plus ouverte.'**
  String get errorOrderNotOpen;

  /// No description provided for @errorItemUnavailable.
  ///
  /// In fr, this message translates to:
  /// **'Cet article n\'est pas disponible dans cet établissement.'**
  String get errorItemUnavailable;

  /// No description provided for @errorNoPrice.
  ///
  /// In fr, this message translates to:
  /// **'Cet article n\'a pas de prix dans cet établissement.'**
  String get errorNoPrice;

  /// No description provided for @errorOptionsInvalid.
  ///
  /// In fr, this message translates to:
  /// **'Les options choisies ne respectent pas les règles de l\'article.'**
  String get errorOptionsInvalid;

  /// No description provided for @errorInvalidQuantity.
  ///
  /// In fr, this message translates to:
  /// **'Quantité invalide.'**
  String get errorInvalidQuantity;

  /// No description provided for @errorItemAlreadySent.
  ///
  /// In fr, this message translates to:
  /// **'Cette ligne est déjà partie en cuisine : elle ne peut plus être modifiée.'**
  String get errorItemAlreadySent;

  /// No description provided for @errorReasonRequired.
  ///
  /// In fr, this message translates to:
  /// **'Indiquez un motif.'**
  String get errorReasonRequired;

  /// No description provided for @errorInvalidOrder.
  ///
  /// In fr, this message translates to:
  /// **'Commande invalide.'**
  String get errorInvalidOrder;

  /// No description provided for @errorBranchInactive.
  ///
  /// In fr, this message translates to:
  /// **'Cet établissement est archivé.'**
  String get errorBranchInactive;

  /// No description provided for @navCash.
  ///
  /// In fr, this message translates to:
  /// **'Caisse'**
  String get navCash;

  /// No description provided for @amount.
  ///
  /// In fr, this message translates to:
  /// **'Montant'**
  String get amount;

  /// No description provided for @registerClosed.
  ///
  /// In fr, this message translates to:
  /// **'fermée'**
  String get registerClosed;

  /// No description provided for @openRegisterShort.
  ///
  /// In fr, this message translates to:
  /// **'Ouvrir la caisse'**
  String get openRegisterShort;

  /// No description provided for @openRegister.
  ///
  /// In fr, this message translates to:
  /// **'Ouvrir {name}'**
  String openRegister(String name);

  /// No description provided for @openingFloat.
  ///
  /// In fr, this message translates to:
  /// **'Fond de caisse (monnaie de départ)'**
  String get openingFloat;

  /// No description provided for @registerOpenSince.
  ///
  /// In fr, this message translates to:
  /// **'ouverte depuis {time}'**
  String registerOpenSince(String time);

  /// No description provided for @expectedCash.
  ///
  /// In fr, this message translates to:
  /// **'Espèces attendues : {amount}'**
  String expectedCash(String amount);

  /// No description provided for @cashBreakdown.
  ///
  /// In fr, this message translates to:
  /// **'Fond {float} · entrées {inAmount} · sorties {outAmount}'**
  String cashBreakdown(String float, String inAmount, String outAmount);

  /// No description provided for @paymentsCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{aucun paiement} =1{1 paiement} other{{count} paiements}}'**
  String paymentsCount(int count);

  /// No description provided for @cashIn.
  ///
  /// In fr, this message translates to:
  /// **'Entrée d\'argent'**
  String get cashIn;

  /// No description provided for @cashOut.
  ///
  /// In fr, this message translates to:
  /// **'Sortie d\'argent'**
  String get cashOut;

  /// No description provided for @movementExamples.
  ///
  /// In fr, this message translates to:
  /// **'Ex. : achat de gaz, apport de monnaie'**
  String get movementExamples;

  /// No description provided for @closeRegister.
  ///
  /// In fr, this message translates to:
  /// **'Fermer la caisse'**
  String get closeRegister;

  /// No description provided for @countedCash.
  ///
  /// In fr, this message translates to:
  /// **'Espèces comptées dans le tiroir'**
  String get countedCash;

  /// No description provided for @countInfo.
  ///
  /// In fr, this message translates to:
  /// **'Comptez les billets et pièces du tiroir, fond de caisse compris.'**
  String get countInfo;

  /// No description provided for @countResult.
  ///
  /// In fr, this message translates to:
  /// **'Résultat du comptage'**
  String get countResult;

  /// No description provided for @countedCashValue.
  ///
  /// In fr, this message translates to:
  /// **'Compté : {amount}'**
  String countedCashValue(String amount);

  /// No description provided for @noDifference.
  ///
  /// In fr, this message translates to:
  /// **'Aucun écart'**
  String get noDifference;

  /// No description provided for @differenceValue.
  ///
  /// In fr, this message translates to:
  /// **'Écart : {amount}'**
  String differenceValue(String amount);

  /// No description provided for @awaitingValidation.
  ///
  /// In fr, this message translates to:
  /// **'Un responsable doit maintenant valider cette clôture.'**
  String get awaitingValidation;

  /// No description provided for @awaitingValidationTitle.
  ///
  /// In fr, this message translates to:
  /// **'Clôtures à valider'**
  String get awaitingValidationTitle;

  /// No description provided for @validateClosing.
  ///
  /// In fr, this message translates to:
  /// **'Valider la clôture'**
  String get validateClosing;

  /// No description provided for @validate.
  ///
  /// In fr, this message translates to:
  /// **'Valider'**
  String get validate;

  /// No description provided for @comment.
  ///
  /// In fr, this message translates to:
  /// **'Commentaire'**
  String get comment;

  /// No description provided for @closedSessions.
  ///
  /// In fr, this message translates to:
  /// **'Dernières clôtures'**
  String get closedSessions;

  /// No description provided for @dailyReport.
  ///
  /// In fr, this message translates to:
  /// **'Rapport du jour'**
  String get dailyReport;

  /// No description provided for @previousDay.
  ///
  /// In fr, this message translates to:
  /// **'Jour précédent'**
  String get previousDay;

  /// No description provided for @nextDayButton.
  ///
  /// In fr, this message translates to:
  /// **'Jour suivant'**
  String get nextDayButton;

  /// No description provided for @salesTotal.
  ///
  /// In fr, this message translates to:
  /// **'Chiffre d\'affaires'**
  String get salesTotal;

  /// No description provided for @ordersClosedCount.
  ///
  /// In fr, this message translates to:
  /// **'Commandes payées'**
  String get ordersClosedCount;

  /// No description provided for @averageTicket.
  ///
  /// In fr, this message translates to:
  /// **'Ticket moyen'**
  String get averageTicket;

  /// No description provided for @taxCollected.
  ///
  /// In fr, this message translates to:
  /// **'Taxe collectée'**
  String get taxCollected;

  /// No description provided for @paymentsReceived.
  ///
  /// In fr, this message translates to:
  /// **'Encaissements par moyen de paiement'**
  String get paymentsReceived;

  /// No description provided for @ordersStillOpen.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{aucune commande en cours} =1{1 commande encore en cours} other{{count} commandes encore en cours}}'**
  String ordersStillOpen(int count);

  /// No description provided for @ordersCancelledCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{aucune annulée} =1{1 annulée} other{{count} annulées}}'**
  String ordersCancelledCount(int count);

  /// No description provided for @linesCancelledCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{aucune ligne annulée} =1{1 ligne annulée} other{{count} lignes annulées}}'**
  String linesCancelledCount(int count);

  /// No description provided for @refundsTotal.
  ///
  /// In fr, this message translates to:
  /// **'remboursé : {amount}'**
  String refundsTotal(String amount);

  /// No description provided for @topItems.
  ///
  /// In fr, this message translates to:
  /// **'Articles les plus vendus'**
  String get topItems;

  /// No description provided for @payCash.
  ///
  /// In fr, this message translates to:
  /// **'Espèces'**
  String get payCash;

  /// No description provided for @payCard.
  ///
  /// In fr, this message translates to:
  /// **'Carte'**
  String get payCard;

  /// No description provided for @payMobileMoney.
  ///
  /// In fr, this message translates to:
  /// **'Mobile Money'**
  String get payMobileMoney;

  /// No description provided for @payTransfer.
  ///
  /// In fr, this message translates to:
  /// **'Virement'**
  String get payTransfer;

  /// No description provided for @payOther.
  ///
  /// In fr, this message translates to:
  /// **'Autre'**
  String get payOther;

  /// No description provided for @collectPayment.
  ///
  /// In fr, this message translates to:
  /// **'Encaisser'**
  String get collectPayment;

  /// No description provided for @collectAmount.
  ///
  /// In fr, this message translates to:
  /// **'Encaisser {amount}'**
  String collectAmount(String amount);

  /// No description provided for @amountDue.
  ///
  /// In fr, this message translates to:
  /// **'Reste à payer : {amount}'**
  String amountDue(String amount);

  /// No description provided for @splitBill.
  ///
  /// In fr, this message translates to:
  /// **'Partager l\'addition'**
  String get splitBill;

  /// No description provided for @splitParts.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{1 part} other{{count} parts}}'**
  String splitParts(int count);

  /// No description provided for @amountToCollect.
  ///
  /// In fr, this message translates to:
  /// **'Montant encaissé'**
  String get amountToCollect;

  /// No description provided for @cashTendered.
  ///
  /// In fr, this message translates to:
  /// **'Somme remise par le client (facultatif)'**
  String get cashTendered;

  /// No description provided for @changeToGive.
  ///
  /// In fr, this message translates to:
  /// **'À rendre : {amount}'**
  String changeToGive(String amount);

  /// No description provided for @giveChange.
  ///
  /// In fr, this message translates to:
  /// **'Monnaie à rendre'**
  String get giveChange;

  /// No description provided for @transactionReference.
  ///
  /// In fr, this message translates to:
  /// **'N° de transaction (facultatif)'**
  String get transactionReference;

  /// No description provided for @manualPaymentNote.
  ///
  /// In fr, this message translates to:
  /// **'Carte et Mobile Money : vérifiez que le paiement est bien reçu avant de valider.'**
  String get manualPaymentNote;

  /// No description provided for @openCashFirst.
  ///
  /// In fr, this message translates to:
  /// **'Ouvrez d\'abord la caisse (section Caisse).'**
  String get openCashFirst;

  /// No description provided for @chooseRegister.
  ///
  /// In fr, this message translates to:
  /// **'Choisir la caisse'**
  String get chooseRegister;

  /// No description provided for @orderPaidClosed.
  ///
  /// In fr, this message translates to:
  /// **'Commande payée et clôturée.'**
  String get orderPaidClosed;

  /// No description provided for @paid.
  ///
  /// In fr, this message translates to:
  /// **'Déjà payé'**
  String get paid;

  /// No description provided for @remainingDue.
  ///
  /// In fr, this message translates to:
  /// **'Reste à payer'**
  String get remainingDue;

  /// No description provided for @voided.
  ///
  /// In fr, this message translates to:
  /// **'annulé'**
  String get voided;

  /// No description provided for @voidPayment.
  ///
  /// In fr, this message translates to:
  /// **'Annuler ce paiement'**
  String get voidPayment;

  /// No description provided for @orderClosed.
  ///
  /// In fr, this message translates to:
  /// **'Commande payée et clôturée'**
  String get orderClosed;

  /// No description provided for @orderCancelled.
  ///
  /// In fr, this message translates to:
  /// **'Commande annulée'**
  String get orderCancelled;

  /// No description provided for @errorNoOpenSession.
  ///
  /// In fr, this message translates to:
  /// **'Aucune caisse ouverte pour cet encaissement.'**
  String get errorNoOpenSession;

  /// No description provided for @errorSessionAlreadyOpen.
  ///
  /// In fr, this message translates to:
  /// **'Cette caisse est déjà ouverte.'**
  String get errorSessionAlreadyOpen;

  /// No description provided for @errorRegisterInactive.
  ///
  /// In fr, this message translates to:
  /// **'Cette caisse est désactivée.'**
  String get errorRegisterInactive;

  /// No description provided for @errorInvalidAmount.
  ///
  /// In fr, this message translates to:
  /// **'Montant invalide.'**
  String get errorInvalidAmount;

  /// No description provided for @errorNotEnoughCash.
  ///
  /// In fr, this message translates to:
  /// **'Il n\'y a pas assez d\'espèces dans la caisse.'**
  String get errorNotEnoughCash;

  /// No description provided for @errorOverpayment.
  ///
  /// In fr, this message translates to:
  /// **'Le montant dépasse le reste à payer.'**
  String get errorOverpayment;

  /// No description provided for @errorTenderedTooLow.
  ///
  /// In fr, this message translates to:
  /// **'La somme remise est inférieure au montant.'**
  String get errorTenderedTooLow;

  /// No description provided for @errorOrderHasPayments.
  ///
  /// In fr, this message translates to:
  /// **'Cette commande a déjà des paiements : annulez ou remboursez-les d\'abord.'**
  String get errorOrderHasPayments;

  /// No description provided for @errorPendingLines.
  ///
  /// In fr, this message translates to:
  /// **'Des articles n\'ont pas encore été envoyés en cuisine.'**
  String get errorPendingLines;

  /// No description provided for @errorNotFullyPaid.
  ///
  /// In fr, this message translates to:
  /// **'La commande n\'est pas entièrement payée.'**
  String get errorNotFullyPaid;

  /// No description provided for @errorSessionNotCounted.
  ///
  /// In fr, this message translates to:
  /// **'Cette caisse n\'a pas encore été comptée.'**
  String get errorSessionNotCounted;

  /// No description provided for @navKitchen.
  ///
  /// In fr, this message translates to:
  /// **'Cuisine'**
  String get navKitchen;

  /// No description provided for @allStations.
  ///
  /// In fr, this message translates to:
  /// **'Tous les postes'**
  String get allStations;

  /// No description provided for @stations.
  ///
  /// In fr, this message translates to:
  /// **'Postes de préparation'**
  String get stations;

  /// No description provided for @newStation.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau poste'**
  String get newStation;

  /// No description provided for @stationExamples.
  ///
  /// In fr, this message translates to:
  /// **'Ex. : Cuisine, Bar, Grillades'**
  String get stationExamples;

  /// No description provided for @stationPrepares.
  ///
  /// In fr, this message translates to:
  /// **'Ce poste prépare :'**
  String get stationPrepares;

  /// No description provided for @kitchenEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Rien à préparer pour le moment.'**
  String get kitchenEmpty;

  /// No description provided for @allReady.
  ///
  /// In fr, this message translates to:
  /// **'Tout est prêt'**
  String get allReady;

  /// No description provided for @markServed.
  ///
  /// In fr, this message translates to:
  /// **'Servi'**
  String get markServed;

  /// No description provided for @errorInvalidStatus.
  ///
  /// In fr, this message translates to:
  /// **'Ce changement d\'état n\'est pas possible.'**
  String get errorInvalidStatus;

  /// No description provided for @navStock.
  ///
  /// In fr, this message translates to:
  /// **'Stocks'**
  String get navStock;

  /// No description provided for @stockLevels.
  ///
  /// In fr, this message translates to:
  /// **'État des stocks'**
  String get stockLevels;

  /// No description provided for @ingredientsTab.
  ///
  /// In fr, this message translates to:
  /// **'Ingrédients'**
  String get ingredientsTab;

  /// No description provided for @recipesTab.
  ///
  /// In fr, this message translates to:
  /// **'Fiches techniques'**
  String get recipesTab;

  /// No description provided for @inventoriesTab.
  ///
  /// In fr, this message translates to:
  /// **'Inventaires'**
  String get inventoriesTab;

  /// No description provided for @movementsTab.
  ///
  /// In fr, this message translates to:
  /// **'Mouvements'**
  String get movementsTab;

  /// No description provided for @stockValue.
  ///
  /// In fr, this message translates to:
  /// **'Valeur du stock : {amount}'**
  String stockValue(String amount);

  /// No description provided for @lowStockCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{1 ingrédient sous le seuil} other{{count} ingrédients sous le seuil}}'**
  String lowStockCount(int count);

  /// No description provided for @actionsAt.
  ///
  /// In fr, this message translates to:
  /// **'Mouvements à : {location}'**
  String actionsAt(String location);

  /// No description provided for @newLocation.
  ///
  /// In fr, this message translates to:
  /// **'Nouvel emplacement'**
  String get newLocation;

  /// No description provided for @locationExamples.
  ///
  /// In fr, this message translates to:
  /// **'Ex. : Chambre froide, Cave, Cuisine'**
  String get locationExamples;

  /// No description provided for @chooseLocation.
  ///
  /// In fr, this message translates to:
  /// **'Choisir l\'emplacement'**
  String get chooseLocation;

  /// No description provided for @toLocation.
  ///
  /// In fr, this message translates to:
  /// **'Vers l\'emplacement'**
  String get toLocation;

  /// No description provided for @noIngredientsYet.
  ///
  /// In fr, this message translates to:
  /// **'Aucun ingrédient pour l\'instant : ajoutez-en dans l\'onglet Ingrédients.'**
  String get noIngredientsYet;

  /// No description provided for @alertAt.
  ///
  /// In fr, this message translates to:
  /// **'alerte à {qty}'**
  String alertAt(String qty);

  /// No description provided for @avgCost.
  ///
  /// In fr, this message translates to:
  /// **'coût moyen {amount} / {unit}'**
  String avgCost(String amount, String unit);

  /// No description provided for @alertThreshold.
  ///
  /// In fr, this message translates to:
  /// **'Seuil d\'alerte'**
  String get alertThreshold;

  /// No description provided for @alertBelow.
  ///
  /// In fr, this message translates to:
  /// **'Alerter en dessous de'**
  String get alertBelow;

  /// No description provided for @produce.
  ///
  /// In fr, this message translates to:
  /// **'Produire'**
  String get produce;

  /// No description provided for @adjustmentQuantity.
  ///
  /// In fr, this message translates to:
  /// **'Correction (+ ou −)'**
  String get adjustmentQuantity;

  /// No description provided for @unitCost.
  ///
  /// In fr, this message translates to:
  /// **'Coût par {unit}'**
  String unitCost(String unit);

  /// No description provided for @unitPiece.
  ///
  /// In fr, this message translates to:
  /// **'pièce'**
  String get unitPiece;

  /// No description provided for @unitDozen.
  ///
  /// In fr, this message translates to:
  /// **'douzaine'**
  String get unitDozen;

  /// No description provided for @newIngredient.
  ///
  /// In fr, this message translates to:
  /// **'Nouvel ingrédient'**
  String get newIngredient;

  /// No description provided for @ingredientExamples.
  ///
  /// In fr, this message translates to:
  /// **'Ex. : Poulet, Huile de palme, Bouteille de Coca 33 cl'**
  String get ingredientExamples;

  /// No description provided for @ingredientKind.
  ///
  /// In fr, this message translates to:
  /// **'Type'**
  String get ingredientKind;

  /// No description provided for @stockUnit.
  ///
  /// In fr, this message translates to:
  /// **'Unité de stock'**
  String get stockUnit;

  /// No description provided for @ingRaw.
  ///
  /// In fr, this message translates to:
  /// **'Matière première'**
  String get ingRaw;

  /// No description provided for @ingBeverage.
  ///
  /// In fr, this message translates to:
  /// **'Boisson'**
  String get ingBeverage;

  /// No description provided for @ingPackaging.
  ///
  /// In fr, this message translates to:
  /// **'Emballage'**
  String get ingPackaging;

  /// No description provided for @ingSemiFinished.
  ///
  /// In fr, this message translates to:
  /// **'Préparation maison'**
  String get ingSemiFinished;

  /// No description provided for @ingConsumable.
  ///
  /// In fr, this message translates to:
  /// **'Consommable'**
  String get ingConsumable;

  /// No description provided for @mvOpening.
  ///
  /// In fr, this message translates to:
  /// **'Stock initial'**
  String get mvOpening;

  /// No description provided for @mvReceipt.
  ///
  /// In fr, this message translates to:
  /// **'Entrée (achat)'**
  String get mvReceipt;

  /// No description provided for @mvSale.
  ///
  /// In fr, this message translates to:
  /// **'Vente'**
  String get mvSale;

  /// No description provided for @mvProductionIn.
  ///
  /// In fr, this message translates to:
  /// **'Production'**
  String get mvProductionIn;

  /// No description provided for @mvProductionOut.
  ///
  /// In fr, this message translates to:
  /// **'Utilisé en production'**
  String get mvProductionOut;

  /// No description provided for @mvWaste.
  ///
  /// In fr, this message translates to:
  /// **'Perte / casse'**
  String get mvWaste;

  /// No description provided for @mvStaffMeal.
  ///
  /// In fr, this message translates to:
  /// **'Repas du personnel'**
  String get mvStaffMeal;

  /// No description provided for @mvReturn.
  ///
  /// In fr, this message translates to:
  /// **'Retour fournisseur'**
  String get mvReturn;

  /// No description provided for @mvTransferIn.
  ///
  /// In fr, this message translates to:
  /// **'Transfert reçu'**
  String get mvTransferIn;

  /// No description provided for @mvTransferOut.
  ///
  /// In fr, this message translates to:
  /// **'Transfert'**
  String get mvTransferOut;

  /// No description provided for @mvAdjustment.
  ///
  /// In fr, this message translates to:
  /// **'Ajustement'**
  String get mvAdjustment;

  /// No description provided for @mvInventory.
  ///
  /// In fr, this message translates to:
  /// **'Écart d\'inventaire'**
  String get mvInventory;

  /// No description provided for @recipesIntro.
  ///
  /// In fr, this message translates to:
  /// **'Une fiche technique indique les ingrédients d\'un plat : le stock baisse automatiquement à chaque vente payée et le coût de revient est calculé.'**
  String get recipesIntro;

  /// No description provided for @noRecipe.
  ///
  /// In fr, this message translates to:
  /// **'Sans fiche'**
  String get noRecipe;

  /// No description provided for @costPrice.
  ///
  /// In fr, this message translates to:
  /// **'Coût de revient : {amount}'**
  String costPrice(String amount);

  /// No description provided for @sellingPrice.
  ///
  /// In fr, this message translates to:
  /// **'prix {amount}'**
  String sellingPrice(String amount);

  /// No description provided for @marginPercent.
  ///
  /// In fr, this message translates to:
  /// **'marge {percent} %'**
  String marginPercent(int percent);

  /// No description provided for @recipeOf.
  ///
  /// In fr, this message translates to:
  /// **'Fiche : {name}'**
  String recipeOf(String name);

  /// No description provided for @portions.
  ///
  /// In fr, this message translates to:
  /// **'Nombre de portions'**
  String get portions;

  /// No description provided for @yieldQuantity.
  ///
  /// In fr, this message translates to:
  /// **'Quantité obtenue'**
  String get yieldQuantity;

  /// No description provided for @ingredient.
  ///
  /// In fr, this message translates to:
  /// **'Ingrédient'**
  String get ingredient;

  /// No description provided for @wastePercent.
  ///
  /// In fr, this message translates to:
  /// **'Perte'**
  String get wastePercent;

  /// No description provided for @removeLine.
  ///
  /// In fr, this message translates to:
  /// **'Retirer la ligne'**
  String get removeLine;

  /// No description provided for @addIngredientLine.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un ingrédient'**
  String get addIngredientLine;

  /// No description provided for @preparationNotes.
  ///
  /// In fr, this message translates to:
  /// **'Notes de préparation (facultatif)'**
  String get preparationNotes;

  /// No description provided for @newInventory.
  ///
  /// In fr, this message translates to:
  /// **'Nouvel inventaire'**
  String get newInventory;

  /// No description provided for @inventoriesIntro.
  ///
  /// In fr, this message translates to:
  /// **'Un inventaire compare le stock compté au stock calculé ; les écarts sont enregistrés après validation par un responsable.'**
  String get inventoriesIntro;

  /// No description provided for @inventoryValidated.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{validé, aucun écart} =1{validé, 1 écart} other{validé, {count} écarts}}'**
  String inventoryValidated(int count);

  /// No description provided for @inventoryDraft.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{en cours, rien de compté} =1{en cours, 1 ligne comptée} other{en cours, {count} lignes comptées}}'**
  String inventoryDraft(int count);

  /// No description provided for @inventoryOf.
  ///
  /// In fr, this message translates to:
  /// **'Inventaire : {location}'**
  String inventoryOf(String location);

  /// No description provided for @inventoryHint.
  ///
  /// In fr, this message translates to:
  /// **'Saisissez ce que vous comptez réellement. Les lignes laissées vides ne sont pas modifiées.'**
  String get inventoryHint;

  /// No description provided for @inventoryDifference.
  ///
  /// In fr, this message translates to:
  /// **'écart {qty}'**
  String inventoryDifference(String qty);

  /// No description provided for @search.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher'**
  String get search;

  /// No description provided for @validateInventory.
  ///
  /// In fr, this message translates to:
  /// **'Valider l\'inventaire'**
  String get validateInventory;

  /// No description provided for @validateInventoryConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Valider cet inventaire ? Les écarts seront enregistrés dans le stock et l\'inventaire ne pourra plus être modifié.'**
  String get validateInventoryConfirm;

  /// No description provided for @inventoryAdjustments.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Inventaire validé : aucun écart} =1{Inventaire validé : 1 écart enregistré} other{Inventaire validé : {count} écarts enregistrés}}'**
  String inventoryAdjustments(int count);

  /// No description provided for @errorInvalidMovement.
  ///
  /// In fr, this message translates to:
  /// **'Mouvement de stock invalide.'**
  String get errorInvalidMovement;

  /// No description provided for @errorUnitLocked.
  ///
  /// In fr, this message translates to:
  /// **'L\'unité de stock ne peut plus changer : cet ingrédient a déjà des mouvements.'**
  String get errorUnitLocked;

  /// No description provided for @errorNoRecipe.
  ///
  /// In fr, this message translates to:
  /// **'Cette préparation n\'a pas de fiche technique.'**
  String get errorNoRecipe;

  /// No description provided for @errorInvalidRecipe.
  ///
  /// In fr, this message translates to:
  /// **'Fiche technique invalide : vérifiez les ingrédients, quantités et unités.'**
  String get errorInvalidRecipe;

  /// No description provided for @errorInventoryClosed.
  ///
  /// In fr, this message translates to:
  /// **'Cet inventaire est déjà validé.'**
  String get errorInventoryClosed;

  /// No description provided for @navGroupService.
  ///
  /// In fr, this message translates to:
  /// **'Service'**
  String get navGroupService;

  /// No description provided for @navGroupManagement.
  ///
  /// In fr, this message translates to:
  /// **'Gestion'**
  String get navGroupManagement;

  /// No description provided for @navGroupOrganization.
  ///
  /// In fr, this message translates to:
  /// **'Organisation'**
  String get navGroupOrganization;

  /// No description provided for @navPurchases.
  ///
  /// In fr, this message translates to:
  /// **'Achats'**
  String get navPurchases;

  /// No description provided for @navExpenses.
  ///
  /// In fr, this message translates to:
  /// **'Dépenses'**
  String get navExpenses;

  /// No description provided for @navReports.
  ///
  /// In fr, this message translates to:
  /// **'Rapports'**
  String get navReports;

  /// No description provided for @invoicesTab.
  ///
  /// In fr, this message translates to:
  /// **'Factures'**
  String get invoicesTab;

  /// No description provided for @purchaseOrdersTab.
  ///
  /// In fr, this message translates to:
  /// **'Bons de commande'**
  String get purchaseOrdersTab;

  /// No description provided for @receiptsTab.
  ///
  /// In fr, this message translates to:
  /// **'Réceptions'**
  String get receiptsTab;

  /// No description provided for @suppliersTab.
  ///
  /// In fr, this message translates to:
  /// **'Fournisseurs'**
  String get suppliersTab;

  /// No description provided for @newSupplier.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau fournisseur'**
  String get newSupplier;

  /// No description provided for @noSuppliersYet.
  ///
  /// In fr, this message translates to:
  /// **'Aucun fournisseur pour l\'instant. Ajoutez vos fournisseurs habituels (marché, grossiste, brasserie…).'**
  String get noSuppliersYet;

  /// No description provided for @addSupplierFirst.
  ///
  /// In fr, this message translates to:
  /// **'Ajoutez d\'abord un fournisseur (onglet Fournisseurs).'**
  String get addSupplierFirst;

  /// No description provided for @contactName.
  ///
  /// In fr, this message translates to:
  /// **'Personne à contacter'**
  String get contactName;

  /// No description provided for @taxId.
  ///
  /// In fr, this message translates to:
  /// **'N° contribuable / fiscal'**
  String get taxId;

  /// No description provided for @paymentTermsLabel.
  ///
  /// In fr, this message translates to:
  /// **'Délai de paiement'**
  String get paymentTermsLabel;

  /// No description provided for @days.
  ///
  /// In fr, this message translates to:
  /// **'jours'**
  String get days;

  /// No description provided for @paymentTerms.
  ///
  /// In fr, this message translates to:
  /// **'{days, plural, =1{paiement à 1 jour} other{paiement à {days} jours}}'**
  String paymentTerms(int days);

  /// No description provided for @supplier.
  ///
  /// In fr, this message translates to:
  /// **'Fournisseur'**
  String get supplier;

  /// No description provided for @supplierOptional.
  ///
  /// In fr, this message translates to:
  /// **'Fournisseur (facultatif)'**
  String get supplierOptional;

  /// No description provided for @newPurchaseOrder.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau bon de commande'**
  String get newPurchaseOrder;

  /// No description provided for @noPurchaseOrders.
  ///
  /// In fr, this message translates to:
  /// **'Aucun bon de commande. Un bon de commande prépare un achat ; à la livraison, « Réceptionner » fait entrer la marchandise en stock.'**
  String get noPurchaseOrders;

  /// No description provided for @poNumber.
  ///
  /// In fr, this message translates to:
  /// **'Bon n° {number}'**
  String poNumber(int number);

  /// No description provided for @poDraft.
  ///
  /// In fr, this message translates to:
  /// **'brouillon'**
  String get poDraft;

  /// No description provided for @poSent.
  ///
  /// In fr, this message translates to:
  /// **'envoyé'**
  String get poSent;

  /// No description provided for @poPartial.
  ///
  /// In fr, this message translates to:
  /// **'reçu en partie'**
  String get poPartial;

  /// No description provided for @poReceived.
  ///
  /// In fr, this message translates to:
  /// **'reçu'**
  String get poReceived;

  /// No description provided for @poCancelled.
  ///
  /// In fr, this message translates to:
  /// **'annulé'**
  String get poCancelled;

  /// No description provided for @poMarkSent.
  ///
  /// In fr, this message translates to:
  /// **'Marquer comme envoyé'**
  String get poMarkSent;

  /// No description provided for @poReceive.
  ///
  /// In fr, this message translates to:
  /// **'Réceptionner'**
  String get poReceive;

  /// No description provided for @poCancel.
  ///
  /// In fr, this message translates to:
  /// **'Annuler le bon'**
  String get poCancel;

  /// No description provided for @cancelPoConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Annuler ce bon de commande ?'**
  String get cancelPoConfirm;

  /// No description provided for @expectedOn.
  ///
  /// In fr, this message translates to:
  /// **'livraison prévue le {date}'**
  String expectedOn(String date);

  /// No description provided for @expectedDateOptional.
  ///
  /// In fr, this message translates to:
  /// **'Date de livraison prévue (facultatif)'**
  String get expectedDateOptional;

  /// No description provided for @unitPrice.
  ///
  /// In fr, this message translates to:
  /// **'Prix par {unit}'**
  String unitPrice(String unit);

  /// No description provided for @totalAmount.
  ///
  /// In fr, this message translates to:
  /// **'Total : {amount}'**
  String totalAmount(String amount);

  /// No description provided for @newReceipt.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle réception'**
  String get newReceipt;

  /// No description provided for @receiptsIntro.
  ///
  /// In fr, this message translates to:
  /// **'Une réception enregistre la marchandise livrée : le stock et le coût moyen sont mis à jour automatiquement.'**
  String get receiptsIntro;

  /// No description provided for @receiveOrder.
  ///
  /// In fr, this message translates to:
  /// **'Réception du bon n° {number}'**
  String receiveOrder(int number);

  /// No description provided for @receiptHint.
  ///
  /// In fr, this message translates to:
  /// **'Indiquez les quantités réellement livrées et leur prix ; elles entrent en stock dès l\'enregistrement.'**
  String get receiptHint;

  /// No description provided for @deliveryNoteNumber.
  ///
  /// In fr, this message translates to:
  /// **'N° du bon de livraison (facultatif)'**
  String get deliveryNoteNumber;

  /// No description provided for @recordReceipt.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer la réception'**
  String get recordReceipt;

  /// No description provided for @receiptRecorded.
  ///
  /// In fr, this message translates to:
  /// **'Réception enregistrée : le stock est à jour.'**
  String get receiptRecorded;

  /// No description provided for @newInvoice.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle facture'**
  String get newInvoice;

  /// No description provided for @invoicesIntro.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrez ici les factures de vos fournisseurs pour suivre ce que vous leur devez et vos paiements.'**
  String get invoicesIntro;

  /// No description provided for @supplierDebt.
  ///
  /// In fr, this message translates to:
  /// **'Total dû aux fournisseurs : {amount}'**
  String supplierDebt(String amount);

  /// No description provided for @dueOn.
  ///
  /// In fr, this message translates to:
  /// **'échéance le {date}'**
  String dueOn(String date);

  /// No description provided for @remaining.
  ///
  /// In fr, this message translates to:
  /// **'reste {amount}'**
  String remaining(String amount);

  /// No description provided for @invoicePaid.
  ///
  /// In fr, this message translates to:
  /// **'payée'**
  String get invoicePaid;

  /// No description provided for @invoiceCancelled.
  ///
  /// In fr, this message translates to:
  /// **'annulée'**
  String get invoiceCancelled;

  /// No description provided for @invoiceNumber.
  ///
  /// In fr, this message translates to:
  /// **'N° de facture du fournisseur'**
  String get invoiceNumber;

  /// No description provided for @invoiceDateValue.
  ///
  /// In fr, this message translates to:
  /// **'Facture du {date}'**
  String invoiceDateValue(String date);

  /// No description provided for @dueDateOptional.
  ///
  /// In fr, this message translates to:
  /// **'Échéance (facultatif : délai du fournisseur)'**
  String get dueDateOptional;

  /// No description provided for @amountExclTax.
  ///
  /// In fr, this message translates to:
  /// **'Montant hors taxe'**
  String get amountExclTax;

  /// No description provided for @taxAmount.
  ///
  /// In fr, this message translates to:
  /// **'Taxe'**
  String get taxAmount;

  /// No description provided for @linkedReceipts.
  ///
  /// In fr, this message translates to:
  /// **'Réceptions concernées'**
  String get linkedReceipts;

  /// No description provided for @attachDocument.
  ///
  /// In fr, this message translates to:
  /// **'Joindre un justificatif (PDF ou photo)'**
  String get attachDocument;

  /// No description provided for @fileTooLarge.
  ///
  /// In fr, this message translates to:
  /// **'Fichier trop volumineux (5 Mo au plus).'**
  String get fileTooLarge;

  /// No description provided for @viewDocument.
  ///
  /// In fr, this message translates to:
  /// **'Voir le justificatif'**
  String get viewDocument;

  /// No description provided for @payInvoice.
  ///
  /// In fr, this message translates to:
  /// **'Payer'**
  String get payInvoice;

  /// No description provided for @cancelInvoice.
  ///
  /// In fr, this message translates to:
  /// **'Annuler la facture'**
  String get cancelInvoice;

  /// No description provided for @paidFromRegister.
  ///
  /// In fr, this message translates to:
  /// **'Payé avec l\'argent de la caisse'**
  String get paidFromRegister;

  /// No description provided for @newExpense.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle dépense'**
  String get newExpense;

  /// No description provided for @noExpenses.
  ///
  /// In fr, this message translates to:
  /// **'Aucune dépense ce mois-ci.'**
  String get noExpenses;

  /// No description provided for @previousMonth.
  ///
  /// In fr, this message translates to:
  /// **'Mois précédent'**
  String get previousMonth;

  /// No description provided for @nextMonth.
  ///
  /// In fr, this message translates to:
  /// **'Mois suivant'**
  String get nextMonth;

  /// No description provided for @includingTax.
  ///
  /// In fr, this message translates to:
  /// **'dont taxe {amount}'**
  String includingTax(String amount);

  /// No description provided for @cancelledLabel.
  ///
  /// In fr, this message translates to:
  /// **'annulée'**
  String get cancelledLabel;

  /// No description provided for @cancelExpense.
  ///
  /// In fr, this message translates to:
  /// **'Annuler la dépense'**
  String get cancelExpense;

  /// No description provided for @expenseExamples.
  ///
  /// In fr, this message translates to:
  /// **'Ex. : facture d\'électricité d\'octobre, réparation du congélateur'**
  String get expenseExamples;

  /// No description provided for @amountInclTax.
  ///
  /// In fr, this message translates to:
  /// **'Montant payé'**
  String get amountInclTax;

  /// No description provided for @includedTaxOptional.
  ///
  /// In fr, this message translates to:
  /// **'Dont taxe (facultatif)'**
  String get includedTaxOptional;

  /// No description provided for @expRent.
  ///
  /// In fr, this message translates to:
  /// **'Loyer'**
  String get expRent;

  /// No description provided for @expElectricity.
  ///
  /// In fr, this message translates to:
  /// **'Électricité'**
  String get expElectricity;

  /// No description provided for @expWater.
  ///
  /// In fr, this message translates to:
  /// **'Eau'**
  String get expWater;

  /// No description provided for @expGas.
  ///
  /// In fr, this message translates to:
  /// **'Gaz'**
  String get expGas;

  /// No description provided for @expSalaries.
  ///
  /// In fr, this message translates to:
  /// **'Salaires'**
  String get expSalaries;

  /// No description provided for @expTransport.
  ///
  /// In fr, this message translates to:
  /// **'Transport'**
  String get expTransport;

  /// No description provided for @expMaintenance.
  ///
  /// In fr, this message translates to:
  /// **'Entretien et réparations'**
  String get expMaintenance;

  /// No description provided for @expMarketing.
  ///
  /// In fr, this message translates to:
  /// **'Publicité'**
  String get expMarketing;

  /// No description provided for @expSupplies.
  ///
  /// In fr, this message translates to:
  /// **'Fournitures'**
  String get expSupplies;

  /// No description provided for @expTaxes.
  ///
  /// In fr, this message translates to:
  /// **'Impôts et taxes'**
  String get expTaxes;

  /// No description provided for @expBankFees.
  ///
  /// In fr, this message translates to:
  /// **'Frais bancaires'**
  String get expBankFees;

  /// No description provided for @expOther.
  ///
  /// In fr, this message translates to:
  /// **'Autres'**
  String get expOther;

  /// No description provided for @periodToday.
  ///
  /// In fr, this message translates to:
  /// **'Aujourd\'hui'**
  String get periodToday;

  /// No description provided for @periodLast7.
  ///
  /// In fr, this message translates to:
  /// **'7 derniers jours'**
  String get periodLast7;

  /// No description provided for @periodMonth.
  ///
  /// In fr, this message translates to:
  /// **'Ce mois-ci'**
  String get periodMonth;

  /// No description provided for @periodLastMonth.
  ///
  /// In fr, this message translates to:
  /// **'Mois dernier'**
  String get periodLastMonth;

  /// No description provided for @periodCustom.
  ///
  /// In fr, this message translates to:
  /// **'Autre période…'**
  String get periodCustom;

  /// No description provided for @salesInclTax.
  ///
  /// In fr, this message translates to:
  /// **'Chiffre d\'affaires TTC'**
  String get salesInclTax;

  /// No description provided for @salesExclTax.
  ///
  /// In fr, this message translates to:
  /// **'Chiffre d\'affaires HT'**
  String get salesExclTax;

  /// No description provided for @collected.
  ///
  /// In fr, this message translates to:
  /// **'Encaissements'**
  String get collected;

  /// No description provided for @costOfSales.
  ///
  /// In fr, this message translates to:
  /// **'Coût des ventes'**
  String get costOfSales;

  /// No description provided for @grossMargin.
  ///
  /// In fr, this message translates to:
  /// **'Marge brute'**
  String get grossMargin;

  /// No description provided for @lossesValue.
  ///
  /// In fr, this message translates to:
  /// **'Pertes et écarts'**
  String get lossesValue;

  /// No description provided for @expensesExclTax.
  ///
  /// In fr, this message translates to:
  /// **'Dépenses HT'**
  String get expensesExclTax;

  /// No description provided for @estimatedResult.
  ///
  /// In fr, this message translates to:
  /// **'Résultat estimé'**
  String get estimatedResult;

  /// No description provided for @purchasesValue.
  ///
  /// In fr, this message translates to:
  /// **'Achats (factures HT)'**
  String get purchasesValue;

  /// No description provided for @supplierDebtShort.
  ///
  /// In fr, this message translates to:
  /// **'Dû aux fournisseurs'**
  String get supplierDebtShort;

  /// No description provided for @ordersCountShort.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{aucune commande} =1{1 commande} other{{count} commandes}}'**
  String ordersCountShort(int count);

  /// No description provided for @ruleSales.
  ///
  /// In fr, this message translates to:
  /// **'Total des commandes payées et clôturées sur la période (date de service).'**
  String get ruleSales;

  /// No description provided for @ruleSalesHt.
  ///
  /// In fr, this message translates to:
  /// **'Chiffre d\'affaires TTC moins la taxe collectée.'**
  String get ruleSalesHt;

  /// No description provided for @ruleCollected.
  ///
  /// In fr, this message translates to:
  /// **'Argent réellement reçu sur la période, tous moyens confondus, moins les remboursements. Peut différer du chiffre d\'affaires (acomptes, commandes encore ouvertes).'**
  String get ruleCollected;

  /// No description provided for @ruleCogs.
  ///
  /// In fr, this message translates to:
  /// **'Valeur des ingrédients consommés par les ventes, d\'après les fiches techniques et le coût moyen d\'achat. Les plats sans fiche n\'y figurent pas.'**
  String get ruleCogs;

  /// No description provided for @ruleGrossMargin.
  ///
  /// In fr, this message translates to:
  /// **'Chiffre d\'affaires HT moins le coût des ventes.'**
  String get ruleGrossMargin;

  /// No description provided for @ruleLosses.
  ///
  /// In fr, this message translates to:
  /// **'Valeur des pertes, repas du personnel, ajustements et écarts d\'inventaire.'**
  String get ruleLosses;

  /// No description provided for @ruleExpenses.
  ///
  /// In fr, this message translates to:
  /// **'Dépenses enregistrées sur la période, hors taxe (les dépenses annulées sont exclues).'**
  String get ruleExpenses;

  /// No description provided for @ruleResult.
  ///
  /// In fr, this message translates to:
  /// **'Marge brute moins pertes et dépenses. Estimation de gestion, sans les amortissements ni les charges non saisies : ce n\'est pas un résultat comptable.'**
  String get ruleResult;

  /// No description provided for @rulePurchases.
  ///
  /// In fr, this message translates to:
  /// **'Factures fournisseurs (hors taxe) datées dans la période. Les achats entrent en stock : ils ne sont pas une charge tant qu\'ils ne sont pas consommés.'**
  String get rulePurchases;

  /// No description provided for @ruleDebt.
  ///
  /// In fr, this message translates to:
  /// **'Reste à payer sur les factures fournisseurs ouvertes, à ce jour.'**
  String get ruleDebt;

  /// No description provided for @expensesByCategory.
  ///
  /// In fr, this message translates to:
  /// **'Dépenses par catégorie (HT)'**
  String get expensesByCategory;

  /// No description provided for @resultDisclaimer.
  ///
  /// In fr, this message translates to:
  /// **'Ces chiffres sont calculés à partir des opérations enregistrées dans Resto : ventes, encaissements, consommations théoriques, dépenses. Survolez ⓘ pour la règle de chaque indicateur.'**
  String get resultDisclaimer;

  /// No description provided for @exportsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Exports (fichiers CSV, ouvrables dans Excel)'**
  String get exportsTitle;

  /// No description provided for @exportOrders.
  ///
  /// In fr, this message translates to:
  /// **'Commandes'**
  String get exportOrders;

  /// No description provided for @exportPayments.
  ///
  /// In fr, this message translates to:
  /// **'Paiements'**
  String get exportPayments;

  /// No description provided for @exportExpenses.
  ///
  /// In fr, this message translates to:
  /// **'Dépenses'**
  String get exportExpenses;

  /// No description provided for @exportDownloaded.
  ///
  /// In fr, this message translates to:
  /// **'Fichier téléchargé.'**
  String get exportDownloaded;

  /// No description provided for @exportCopied.
  ///
  /// In fr, this message translates to:
  /// **'Données copiées : collez-les dans un tableur.'**
  String get exportCopied;

  /// No description provided for @marginsByItem.
  ///
  /// In fr, this message translates to:
  /// **'Marge par plat'**
  String get marginsByItem;

  /// No description provided for @marginsHint.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Tous les plats vendus ont une fiche technique.} =1{1 plat n\'a pas encore de fiche technique (Stocks → Fiches techniques).} other{{count} plats n\'ont pas encore de fiche technique (Stocks → Fiches techniques).}}'**
  String marginsHint(int count);

  /// No description provided for @errorInvalidPurchase.
  ///
  /// In fr, this message translates to:
  /// **'Achat incomplet : vérifiez le fournisseur, les ingrédients, quantités, unités et prix.'**
  String get errorInvalidPurchase;

  /// No description provided for @errorPurchaseNotDraft.
  ///
  /// In fr, this message translates to:
  /// **'Ce bon de commande n\'est plus modifiable.'**
  String get errorPurchaseNotDraft;

  /// No description provided for @errorDuplicateInvoice.
  ///
  /// In fr, this message translates to:
  /// **'Cette facture de ce fournisseur est déjà enregistrée.'**
  String get errorDuplicateInvoice;

  /// No description provided for @errorInvoiceNotOpen.
  ///
  /// In fr, this message translates to:
  /// **'Cette facture n\'est plus ouverte.'**
  String get errorInvoiceNotOpen;

  /// No description provided for @errorInvoiceHasPayments.
  ///
  /// In fr, this message translates to:
  /// **'Cette facture a des paiements : annulez-les d\'abord.'**
  String get errorInvoiceHasPayments;

  /// No description provided for @errorInvalidExpense.
  ///
  /// In fr, this message translates to:
  /// **'Dépense incomplète : catégorie, description et montant sont obligatoires ; la taxe ne peut dépasser le montant.'**
  String get errorInvalidExpense;

  /// No description provided for @errorInvalidAttachment.
  ///
  /// In fr, this message translates to:
  /// **'Justificatif refusé.'**
  String get errorInvalidAttachment;

  /// No description provided for @errorInvalidPeriod.
  ///
  /// In fr, this message translates to:
  /// **'Période invalide.'**
  String get errorInvalidPeriod;

  /// No description provided for @errorBelowMinimum.
  ///
  /// In fr, this message translates to:
  /// **'Montant minimum de commande non atteint.'**
  String get errorBelowMinimum;

  /// No description provided for @errorDeliveryUnavailable.
  ///
  /// In fr, this message translates to:
  /// **'Livraison impossible : vérifiez l\'adresse et le téléphone, ou choisissez « À emporter ».'**
  String get errorDeliveryUnavailable;

  /// No description provided for @errorInvalidImage.
  ///
  /// In fr, this message translates to:
  /// **'Photo refusée (format ou emplacement non valide).'**
  String get errorInvalidImage;

  /// No description provided for @errorNotFound.
  ///
  /// In fr, this message translates to:
  /// **'Introuvable.'**
  String get errorNotFound;

  /// No description provided for @errorOnlineOrdersClosed.
  ///
  /// In fr, this message translates to:
  /// **'Ce restaurant ne prend pas de commandes en ligne pour le moment.'**
  String get errorOnlineOrdersClosed;

  /// No description provided for @errorTooLateToCancel.
  ///
  /// In fr, this message translates to:
  /// **'Trop tard : le restaurant a déjà pris la commande en charge.'**
  String get errorTooLateToCancel;

  /// No description provided for @errorReviewNotAllowed.
  ///
  /// In fr, this message translates to:
  /// **'Avis impossible : seule une commande payée, de moins de 30 jours, peut être notée une fois.'**
  String get errorReviewNotAllowed;

  /// No description provided for @errorReservationsClosed.
  ///
  /// In fr, this message translates to:
  /// **'Ce restaurant ne prend pas de réservations en ligne.'**
  String get errorReservationsClosed;

  /// No description provided for @errorInvalidPartySize.
  ///
  /// In fr, this message translates to:
  /// **'Nombre de personnes non accepté pour une réservation en ligne.'**
  String get errorInvalidPartySize;

  /// No description provided for @errorInvalidReservationTime.
  ///
  /// In fr, this message translates to:
  /// **'Horaire non valide : au moins 15 minutes à l\'avance et au plus 90 jours.'**
  String get errorInvalidReservationTime;

  /// No description provided for @errorInvalidReservation.
  ///
  /// In fr, this message translates to:
  /// **'Réservation incomplète : nom, téléphone et nombre de personnes sont nécessaires.'**
  String get errorInvalidReservation;

  /// No description provided for @errorTablesRequired.
  ///
  /// In fr, this message translates to:
  /// **'Choisissez au moins une table.'**
  String get errorTablesRequired;

  /// No description provided for @errorNotEnoughSeats.
  ///
  /// In fr, this message translates to:
  /// **'Pas assez de places sur les tables choisies.'**
  String get errorNotEnoughSeats;

  /// No description provided for @errorTableUnavailable.
  ///
  /// In fr, this message translates to:
  /// **'Cette table est déjà réservée sur ce créneau.'**
  String get errorTableUnavailable;

  /// No description provided for @errorPromotionUnavailable.
  ///
  /// In fr, this message translates to:
  /// **'Promotion ou code non valable.'**
  String get errorPromotionUnavailable;

  /// No description provided for @errorPromotionLimit.
  ///
  /// In fr, this message translates to:
  /// **'Ce client a déjà utilisé cette promotion le nombre de fois permis.'**
  String get errorPromotionLimit;

  /// No description provided for @errorPromotionAlreadyApplied.
  ///
  /// In fr, this message translates to:
  /// **'Déjà appliquée à cette commande.'**
  String get errorPromotionAlreadyApplied;

  /// No description provided for @errorNotEnoughPoints.
  ///
  /// In fr, this message translates to:
  /// **'Pas assez de points de fidélité.'**
  String get errorNotEnoughPoints;

  /// No description provided for @errorAddressRequired.
  ///
  /// In fr, this message translates to:
  /// **'Adresse de livraison obligatoire.'**
  String get errorAddressRequired;

  /// No description provided for @errorTableBusy.
  ///
  /// In fr, this message translates to:
  /// **'Cette table a déjà une commande en cours.'**
  String get errorTableBusy;

  /// No description provided for @errorBetween.
  ///
  /// In fr, this message translates to:
  /// **'Entre {min} et {max}'**
  String errorBetween(int min, int max);

  /// No description provided for @notPublishedHint.
  ///
  /// In fr, this message translates to:
  /// **'Cet établissement n\'est pas encore visible des clients : activez « Publié » dans l\'onglet Informations.'**
  String get notPublishedHint;

  /// No description provided for @onlineOrdersTitle.
  ///
  /// In fr, this message translates to:
  /// **'Commandes en ligne'**
  String get onlineOrdersTitle;

  /// No description provided for @acceptOnlineOrders.
  ///
  /// In fr, this message translates to:
  /// **'Accepter les commandes des clients'**
  String get acceptOnlineOrders;

  /// No description provided for @acceptOnlineOrdersHint.
  ///
  /// In fr, this message translates to:
  /// **'Depuis l\'application, le site ou le QR code des tables. Chaque commande arrive dans « Commandes » pour être acceptée.'**
  String get acceptOnlineOrdersHint;

  /// No description provided for @acceptDelivery.
  ///
  /// In fr, this message translates to:
  /// **'Proposer la livraison'**
  String get acceptDelivery;

  /// No description provided for @deliveryFee.
  ///
  /// In fr, this message translates to:
  /// **'Frais de livraison'**
  String get deliveryFee;

  /// No description provided for @minimumOrder.
  ///
  /// In fr, this message translates to:
  /// **'Commande minimum'**
  String get minimumOrder;

  /// No description provided for @reservationsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Réservations'**
  String get reservationsTitle;

  /// No description provided for @acceptReservations.
  ///
  /// In fr, this message translates to:
  /// **'Accepter les réservations en ligne'**
  String get acceptReservations;

  /// No description provided for @reservationDuration.
  ///
  /// In fr, this message translates to:
  /// **'Durée d\'une réservation'**
  String get reservationDuration;

  /// No description provided for @minutesShort.
  ///
  /// In fr, this message translates to:
  /// **'min'**
  String get minutesShort;

  /// No description provided for @maxPartySize.
  ///
  /// In fr, this message translates to:
  /// **'Personnes au maximum'**
  String get maxPartySize;

  /// No description provided for @publicProfileTitle.
  ///
  /// In fr, this message translates to:
  /// **'Fiche publique du restaurant'**
  String get publicProfileTitle;

  /// No description provided for @publicDescription.
  ///
  /// In fr, this message translates to:
  /// **'Présentation'**
  String get publicDescription;

  /// No description provided for @publicDescriptionHint.
  ///
  /// In fr, this message translates to:
  /// **'Ex. : cuisine camerounaise généreuse, poissons braisés du jour, terrasse ombragée.'**
  String get publicDescriptionHint;

  /// No description provided for @cuisinesLabel.
  ///
  /// In fr, this message translates to:
  /// **'Types de cuisine'**
  String get cuisinesLabel;

  /// No description provided for @cuisinesHint.
  ///
  /// In fr, this message translates to:
  /// **'Ex. : africaine, grillades, fruits de mer (séparés par des virgules)'**
  String get cuisinesHint;

  /// No description provided for @priceLevel.
  ///
  /// In fr, this message translates to:
  /// **'Gamme de prix'**
  String get priceLevel;

  /// No description provided for @publicPageTitle.
  ///
  /// In fr, this message translates to:
  /// **'Page du restaurant'**
  String get publicPageTitle;

  /// No description provided for @publicPageHint.
  ///
  /// In fr, this message translates to:
  /// **'À partager (réseaux sociaux, WhatsApp) ou à imprimer : les clients y voient la carte et commandent.'**
  String get publicPageHint;

  /// No description provided for @copyLink.
  ///
  /// In fr, this message translates to:
  /// **'Copier le lien'**
  String get copyLink;

  /// No description provided for @sourcePhone.
  ///
  /// In fr, this message translates to:
  /// **'Par téléphone'**
  String get sourcePhone;

  /// No description provided for @sourceQr.
  ///
  /// In fr, this message translates to:
  /// **'QR code de la table'**
  String get sourceQr;

  /// No description provided for @sourceApp.
  ///
  /// In fr, this message translates to:
  /// **'Application client'**
  String get sourceApp;

  /// No description provided for @sourcePartner.
  ///
  /// In fr, this message translates to:
  /// **'Partenaire'**
  String get sourcePartner;

  /// No description provided for @sourceStaff.
  ///
  /// In fr, this message translates to:
  /// **'Prise en salle'**
  String get sourceStaff;

  /// No description provided for @stageToValidate.
  ///
  /// In fr, this message translates to:
  /// **'À valider'**
  String get stageToValidate;

  /// No description provided for @stageDraft.
  ///
  /// In fr, this message translates to:
  /// **'Pas encore envoyée'**
  String get stageDraft;

  /// No description provided for @stageCooking.
  ///
  /// In fr, this message translates to:
  /// **'En préparation'**
  String get stageCooking;

  /// No description provided for @stageReady.
  ///
  /// In fr, this message translates to:
  /// **'Prête à servir'**
  String get stageReady;

  /// No description provided for @stageReadyTakeaway.
  ///
  /// In fr, this message translates to:
  /// **'Prête à remettre'**
  String get stageReadyTakeaway;

  /// No description provided for @stageReadyDelivery.
  ///
  /// In fr, this message translates to:
  /// **'Prête pour le livreur'**
  String get stageReadyDelivery;

  /// No description provided for @stageToPay.
  ///
  /// In fr, this message translates to:
  /// **'À encaisser'**
  String get stageToPay;

  /// No description provided for @stageDone.
  ///
  /// In fr, this message translates to:
  /// **'Terminée'**
  String get stageDone;

  /// No description provided for @stageCancelled.
  ///
  /// In fr, this message translates to:
  /// **'Annulée'**
  String get stageCancelled;

  /// No description provided for @handToCustomer.
  ///
  /// In fr, this message translates to:
  /// **'Remise au client'**
  String get handToCustomer;

  /// No description provided for @handToCourier.
  ///
  /// In fr, this message translates to:
  /// **'Remise au livreur'**
  String get handToCourier;

  /// No description provided for @guestsCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{1 personne} other{{count} personnes}}'**
  String guestsCount(int count);

  /// No description provided for @forTime.
  ///
  /// In fr, this message translates to:
  /// **'Pour {time}'**
  String forTime(String time);

  /// No description provided for @billTitle.
  ///
  /// In fr, this message translates to:
  /// **'Addition'**
  String get billTitle;

  /// No description provided for @thankYou.
  ///
  /// In fr, this message translates to:
  /// **'Merci de votre visite !'**
  String get thankYou;

  /// No description provided for @kdsToPrepare.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Rien à préparer} =1{1 commande à préparer} other{{count} commandes à préparer}}'**
  String kdsToPrepare(int count);

  /// No description provided for @kdsLate.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{1 en retard} other{{count} en retard}}'**
  String kdsLate(int count);

  /// No description provided for @kdsReadyCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Aucune prête} =1{1 prête} other{{count} prêtes}}'**
  String kdsReadyCount(int count);

  /// No description provided for @kdsTickets.
  ///
  /// In fr, this message translates to:
  /// **'Tickets'**
  String get kdsTickets;

  /// No description provided for @kdsSummary.
  ///
  /// In fr, this message translates to:
  /// **'Cumul'**
  String get kdsSummary;

  /// No description provided for @kdsFullScreen.
  ///
  /// In fr, this message translates to:
  /// **'Plein écran (mode cuisine)'**
  String get kdsFullScreen;

  /// No description provided for @kdsFlowHint.
  ///
  /// In fr, this message translates to:
  /// **'Les commandes envoyées par la salle arrivent ici avec une sonnerie. Touchez un article pour le passer « en préparation » puis « prêt ». « Tout est prêt » prévient aussitôt les serveurs.'**
  String get kdsFlowHint;

  /// No description provided for @kdsReadyStrip.
  ///
  /// In fr, this message translates to:
  /// **'Prêtes — la salle est prévenue (colonne « Prêtes à servir »), en attente de service'**
  String get kdsReadyStrip;

  /// No description provided for @kdsStart.
  ///
  /// In fr, this message translates to:
  /// **'Commencer'**
  String get kdsStart;

  /// No description provided for @kdsWaitingService.
  ///
  /// In fr, this message translates to:
  /// **'attend depuis {time}'**
  String kdsWaitingService(String time);

  /// No description provided for @kdsRecall.
  ///
  /// In fr, this message translates to:
  /// **'Rappeler (pas encore prête)'**
  String get kdsRecall;

  /// No description provided for @serviceAndCustomers.
  ///
  /// In fr, this message translates to:
  /// **'Service & clients'**
  String get serviceAndCustomers;

  /// No description provided for @serviceSettingsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Service'**
  String get serviceSettingsTitle;

  /// No description provided for @targetPrepTime.
  ///
  /// In fr, this message translates to:
  /// **'Temps de préparation visé'**
  String get targetPrepTime;

  /// No description provided for @targetPrepTimeHint.
  ///
  /// In fr, this message translates to:
  /// **'Au-delà, la commande passe en rouge (en retard).'**
  String get targetPrepTimeHint;

  /// No description provided for @payFirstTakeaway.
  ///
  /// In fr, this message translates to:
  /// **'Vente à emporter : faire payer avant la préparation'**
  String get payFirstTakeaway;

  /// No description provided for @payFirstTakeawayHint.
  ///
  /// In fr, this message translates to:
  /// **'Le bouton « Encaisser puis envoyer » apparaît sur les commandes à emporter.'**
  String get payFirstTakeawayHint;

  /// No description provided for @tableOccupied.
  ///
  /// In fr, this message translates to:
  /// **'Occupée'**
  String get tableOccupied;

  /// No description provided for @tableReservedNow.
  ///
  /// In fr, this message translates to:
  /// **'Réservée maintenant'**
  String get tableReservedNow;

  /// No description provided for @tableReservedSoon.
  ///
  /// In fr, this message translates to:
  /// **'Réservée bientôt'**
  String get tableReservedSoon;

  /// No description provided for @reservedAt.
  ///
  /// In fr, this message translates to:
  /// **'Réservée à {time}'**
  String reservedAt(String time);

  /// No description provided for @acceptWithDelay.
  ///
  /// In fr, this message translates to:
  /// **'Accepter la commande'**
  String get acceptWithDelay;

  /// No description provided for @scheduledFor.
  ///
  /// In fr, this message translates to:
  /// **'Demandée pour {time}'**
  String scheduledFor(String time);

  /// No description provided for @delayAnnounced.
  ///
  /// In fr, this message translates to:
  /// **'Dans combien de temps sera-t-elle prête ? Le client est prévenu.'**
  String get delayAnnounced;

  /// No description provided for @orderAccepted.
  ///
  /// In fr, this message translates to:
  /// **'Commande acceptée : elle part en préparation.'**
  String get orderAccepted;

  /// No description provided for @rejectOrder.
  ///
  /// In fr, this message translates to:
  /// **'Refuser la commande'**
  String get rejectOrder;

  /// No description provided for @rejectReasonHint.
  ///
  /// In fr, this message translates to:
  /// **'Ex. : rupture de poisson, livreur indisponible'**
  String get rejectReasonHint;

  /// No description provided for @paymentDone.
  ///
  /// In fr, this message translates to:
  /// **'Paiement enregistré.'**
  String get paymentDone;

  /// No description provided for @partialPaymentDone.
  ///
  /// In fr, this message translates to:
  /// **'Paiement partiel enregistré.'**
  String get partialPaymentDone;

  /// No description provided for @announcedDelay.
  ///
  /// In fr, this message translates to:
  /// **'Délai annoncé au client'**
  String get announcedDelay;

  /// No description provided for @promisedFor.
  ///
  /// In fr, this message translates to:
  /// **'Promise pour {time}'**
  String promisedFor(String time);

  /// No description provided for @heldShort.
  ///
  /// In fr, this message translates to:
  /// **'à suivre'**
  String get heldShort;

  /// No description provided for @moreItems.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{+ 1 autre article} other{+ {count} autres articles}}'**
  String moreItems(int count);

  /// No description provided for @paidShort.
  ///
  /// In fr, this message translates to:
  /// **'Payée'**
  String get paidShort;

  /// No description provided for @partlyPaid.
  ///
  /// In fr, this message translates to:
  /// **'Payée en partie'**
  String get partlyPaid;

  /// No description provided for @notPaid.
  ///
  /// In fr, this message translates to:
  /// **'Non payée'**
  String get notPaid;

  /// No description provided for @reject.
  ///
  /// In fr, this message translates to:
  /// **'Refuser'**
  String get reject;

  /// No description provided for @accept.
  ///
  /// In fr, this message translates to:
  /// **'Accepter'**
  String get accept;

  /// No description provided for @sendShort.
  ///
  /// In fr, this message translates to:
  /// **'Envoyer'**
  String get sendShort;

  /// No description provided for @fireNext.
  ///
  /// In fr, this message translates to:
  /// **'Lancer la suite'**
  String get fireNext;

  /// No description provided for @collectShort.
  ///
  /// In fr, this message translates to:
  /// **'Encaisser'**
  String get collectShort;

  /// No description provided for @columnInProgress.
  ///
  /// In fr, this message translates to:
  /// **'En cours'**
  String get columnInProgress;

  /// No description provided for @columnReady.
  ///
  /// In fr, this message translates to:
  /// **'Prêtes à servir'**
  String get columnReady;

  /// No description provided for @columnToValidateHint.
  ///
  /// In fr, this message translates to:
  /// **'Les commandes passées par les clients (application, site, QR code des tables) arrivent ici avec une sonnerie. Acceptez-les en annonçant un délai.'**
  String get columnToValidateHint;

  /// No description provided for @columnInProgressHint.
  ///
  /// In fr, this message translates to:
  /// **'Commandes prises et en préparation. « Envoyer » fait partir les articles en cuisine et au bar.'**
  String get columnInProgressHint;

  /// No description provided for @columnReadyHint.
  ///
  /// In fr, this message translates to:
  /// **'Quand la cuisine appuie sur « Tout est prêt », la commande arrive ici (avec une sonnerie) : à servir à table, à remettre au client ou au livreur.'**
  String get columnReadyHint;

  /// No description provided for @columnToPayHint.
  ///
  /// In fr, this message translates to:
  /// **'Tout est servi : il reste à encaisser. Une fois payée, la commande se termine et la table se libère.'**
  String get columnToPayHint;

  /// No description provided for @allOrders.
  ///
  /// In fr, this message translates to:
  /// **'Toutes'**
  String get allOrders;

  /// No description provided for @searchOrderHint.
  ///
  /// In fr, this message translates to:
  /// **'N°, client, table, téléphone'**
  String get searchOrderHint;

  /// No description provided for @chooseTable.
  ///
  /// In fr, this message translates to:
  /// **'Choisissez la table'**
  String get chooseTable;

  /// No description provided for @tableHasOrder.
  ///
  /// In fr, this message translates to:
  /// **'Cette table a déjà une commande en cours : elle va s\'ouvrir.'**
  String get tableHasOrder;

  /// No description provided for @tableReservationWarning.
  ///
  /// In fr, this message translates to:
  /// **'Attention : réservée à {time} · {name} · {count} pers.'**
  String tableReservationWarning(String time, String name, int count);

  /// No description provided for @guestsLabel.
  ///
  /// In fr, this message translates to:
  /// **'Nombre de personnes'**
  String get guestsLabel;

  /// No description provided for @receivedByPhone.
  ///
  /// In fr, this message translates to:
  /// **'Commande reçue par téléphone'**
  String get receivedByPhone;

  /// No description provided for @customerName.
  ///
  /// In fr, this message translates to:
  /// **'Nom du client'**
  String get customerName;

  /// No description provided for @customerNameOptional.
  ///
  /// In fr, this message translates to:
  /// **'Nom du client (facultatif)'**
  String get customerNameOptional;

  /// No description provided for @phoneOptional.
  ///
  /// In fr, this message translates to:
  /// **'Téléphone (facultatif)'**
  String get phoneOptional;

  /// No description provided for @deliveryAddress.
  ///
  /// In fr, this message translates to:
  /// **'Adresse de livraison'**
  String get deliveryAddress;

  /// No description provided for @deliveryAddressHint.
  ///
  /// In fr, this message translates to:
  /// **'Quartier, rue, repère (ex. : Bonamoussadi, près de la pharmacie)'**
  String get deliveryAddressHint;

  /// No description provided for @deliveryInstructions.
  ///
  /// In fr, this message translates to:
  /// **'Indications pour le livreur'**
  String get deliveryInstructions;

  /// No description provided for @deliveryInstructionsHint.
  ///
  /// In fr, this message translates to:
  /// **'Ex. : immeuble jaune, 2e étage, appeler en arrivant'**
  String get deliveryInstructionsHint;

  /// No description provided for @deliveryTime.
  ///
  /// In fr, this message translates to:
  /// **'Heure de livraison'**
  String get deliveryTime;

  /// No description provided for @pickupTime.
  ///
  /// In fr, this message translates to:
  /// **'Heure de retrait'**
  String get pickupTime;

  /// No description provided for @asap.
  ///
  /// In fr, this message translates to:
  /// **'Dès que possible'**
  String get asap;

  /// No description provided for @atFixedTime.
  ///
  /// In fr, this message translates to:
  /// **'À une heure précise'**
  String get atFixedTime;

  /// No description provided for @atTime.
  ///
  /// In fr, this message translates to:
  /// **'À {time}'**
  String atTime(String time);

  /// No description provided for @newOrder.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle commande'**
  String get newOrder;

  /// No description provided for @orderTypeQuestion.
  ///
  /// In fr, this message translates to:
  /// **'Quel type de commande ?'**
  String get orderTypeQuestion;

  /// No description provided for @dineInHint.
  ///
  /// In fr, this message translates to:
  /// **'Client installé à une table'**
  String get dineInHint;

  /// No description provided for @takeawayHint.
  ///
  /// In fr, this message translates to:
  /// **'Le client repart avec sa commande'**
  String get takeawayHint;

  /// No description provided for @deliveryHint.
  ///
  /// In fr, this message translates to:
  /// **'Livrée à une adresse'**
  String get deliveryHint;

  /// No description provided for @orderNote.
  ///
  /// In fr, this message translates to:
  /// **'Remarque sur la commande (facultatif)'**
  String get orderNote;

  /// No description provided for @orderNoteHint.
  ///
  /// In fr, this message translates to:
  /// **'Ex. : anniversaire, client pressé, allergie aux arachides'**
  String get orderNoteHint;

  /// No description provided for @continueToMenu.
  ///
  /// In fr, this message translates to:
  /// **'Continuer : choisir les plats'**
  String get continueToMenu;

  /// No description provided for @moveTable.
  ///
  /// In fr, this message translates to:
  /// **'Changer de table'**
  String get moveTable;

  /// No description provided for @noFreeTable.
  ///
  /// In fr, this message translates to:
  /// **'Aucune table libre pour le moment.'**
  String get noFreeTable;

  /// No description provided for @print.
  ///
  /// In fr, this message translates to:
  /// **'Imprimer'**
  String get print;

  /// No description provided for @printKitchenTicket.
  ///
  /// In fr, this message translates to:
  /// **'Bon de préparation (cuisine)'**
  String get printKitchenTicket;

  /// No description provided for @printBill.
  ///
  /// In fr, this message translates to:
  /// **'Addition (client)'**
  String get printBill;

  /// No description provided for @orderHistory.
  ///
  /// In fr, this message translates to:
  /// **'Historique de la commande'**
  String get orderHistory;

  /// No description provided for @searchDish.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher un plat, une boisson…'**
  String get searchDish;

  /// No description provided for @noResults.
  ///
  /// In fr, this message translates to:
  /// **'Aucun résultat.'**
  String get noResults;

  /// No description provided for @groupToSend.
  ///
  /// In fr, this message translates to:
  /// **'À envoyer'**
  String get groupToSend;

  /// No description provided for @groupHeld.
  ///
  /// In fr, this message translates to:
  /// **'À suivre (envoyés plus tard)'**
  String get groupHeld;

  /// No description provided for @groupCooking.
  ///
  /// In fr, this message translates to:
  /// **'En préparation'**
  String get groupCooking;

  /// No description provided for @groupReady.
  ///
  /// In fr, this message translates to:
  /// **'Prêts à servir'**
  String get groupReady;

  /// No description provided for @groupServed.
  ///
  /// In fr, this message translates to:
  /// **'Servis'**
  String get groupServed;

  /// No description provided for @groupCancelled.
  ///
  /// In fr, this message translates to:
  /// **'Annulés'**
  String get groupCancelled;

  /// No description provided for @collectThenSend.
  ///
  /// In fr, this message translates to:
  /// **'Encaisser {amount} puis envoyer'**
  String collectThenSend(String amount);

  /// No description provided for @fireNextCount.
  ///
  /// In fr, this message translates to:
  /// **'Lancer la suite ({count})'**
  String fireNextCount(int count);

  /// No description provided for @customerOrderToValidate.
  ///
  /// In fr, this message translates to:
  /// **'Commande d\'un client à valider'**
  String get customerOrderToValidate;

  /// No description provided for @customerOrderToValidateHint.
  ///
  /// In fr, this message translates to:
  /// **'Vérifiez les articles puis acceptez (avec un délai) ou refusez. Le client est prévenu.'**
  String get customerOrderToValidateHint;

  /// No description provided for @payFirstHint.
  ///
  /// In fr, this message translates to:
  /// **'Vente à emporter : paiement avant la préparation (réglage de l\'établissement).'**
  String get payFirstHint;

  /// No description provided for @addedByCustomer.
  ///
  /// In fr, this message translates to:
  /// **'ajouté par le client'**
  String get addedByCustomer;

  /// No description provided for @sendWithOrder.
  ///
  /// In fr, this message translates to:
  /// **'Envoyer avec le reste'**
  String get sendWithOrder;

  /// No description provided for @holdForLater.
  ///
  /// In fr, this message translates to:
  /// **'Mettre « à suivre » (envoyé plus tard)'**
  String get holdForLater;

  /// No description provided for @openedAt.
  ///
  /// In fr, this message translates to:
  /// **'ouverte à {time}'**
  String openedAt(String time);

  /// No description provided for @fromReservation.
  ///
  /// In fr, this message translates to:
  /// **'Clients installés (réservation)'**
  String get fromReservation;

  /// No description provided for @editOrderDetails.
  ///
  /// In fr, this message translates to:
  /// **'Modifier les informations'**
  String get editOrderDetails;

  /// No description provided for @evOpened.
  ///
  /// In fr, this message translates to:
  /// **'Commande ouverte'**
  String get evOpened;

  /// No description provided for @evItemAdded.
  ///
  /// In fr, this message translates to:
  /// **'Ajout : {item}'**
  String evItemAdded(String item);

  /// No description provided for @evItemUpdated.
  ///
  /// In fr, this message translates to:
  /// **'Article modifié'**
  String get evItemUpdated;

  /// No description provided for @evItemRemoved.
  ///
  /// In fr, this message translates to:
  /// **'Article retiré'**
  String get evItemRemoved;

  /// No description provided for @evSent.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{Envoyé en cuisine (1 article)} other{Envoyé en cuisine ({count} articles)}}'**
  String evSent(int count);

  /// No description provided for @evItemCancelled.
  ///
  /// In fr, this message translates to:
  /// **'Article annulé'**
  String get evItemCancelled;

  /// No description provided for @evCancelled.
  ///
  /// In fr, this message translates to:
  /// **'Commande annulée'**
  String get evCancelled;

  /// No description provided for @evClosed.
  ///
  /// In fr, this message translates to:
  /// **'Commande terminée'**
  String get evClosed;

  /// No description provided for @evPayment.
  ///
  /// In fr, this message translates to:
  /// **'Paiement de {amount}'**
  String evPayment(String amount);

  /// No description provided for @evRefund.
  ///
  /// In fr, this message translates to:
  /// **'Remboursement'**
  String get evRefund;

  /// No description provided for @evDetailsUpdated.
  ///
  /// In fr, this message translates to:
  /// **'Informations modifiées'**
  String get evDetailsUpdated;

  /// No description provided for @itemsTotal.
  ///
  /// In fr, this message translates to:
  /// **'Articles'**
  String get itemsTotal;

  /// No description provided for @removeDiscount.
  ///
  /// In fr, this message translates to:
  /// **'Retirer la réduction'**
  String get removeDiscount;

  /// No description provided for @addDiscount.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter une réduction'**
  String get addDiscount;

  /// No description provided for @applyPromotion.
  ///
  /// In fr, this message translates to:
  /// **'Appliquer une promotion'**
  String get applyPromotion;

  /// No description provided for @promoCode.
  ///
  /// In fr, this message translates to:
  /// **'Code promo'**
  String get promoCode;

  /// No description provided for @promoCodeHint.
  ///
  /// In fr, this message translates to:
  /// **'Ex. : BIENVENUE10'**
  String get promoCodeHint;

  /// No description provided for @manualDiscount.
  ///
  /// In fr, this message translates to:
  /// **'Remise (geste commercial)'**
  String get manualDiscount;

  /// No description provided for @useLoyalty.
  ///
  /// In fr, this message translates to:
  /// **'Utiliser les points de fidélité'**
  String get useLoyalty;

  /// No description provided for @noActivePromotion.
  ///
  /// In fr, this message translates to:
  /// **'Aucune promotion en cours. Créez-en dans « Clients & fidélité ».'**
  String get noActivePromotion;

  /// No description provided for @inPercent.
  ///
  /// In fr, this message translates to:
  /// **'En %'**
  String get inPercent;

  /// No description provided for @inAmount.
  ///
  /// In fr, this message translates to:
  /// **'En montant'**
  String get inAmount;

  /// No description provided for @percentValue.
  ///
  /// In fr, this message translates to:
  /// **'Pourcentage'**
  String get percentValue;

  /// No description provided for @manualDiscountHint.
  ///
  /// In fr, this message translates to:
  /// **'Ex. : attente trop longue, client fidèle'**
  String get manualDiscountHint;

  /// No description provided for @apply.
  ///
  /// In fr, this message translates to:
  /// **'Appliquer'**
  String get apply;

  /// No description provided for @allAreas.
  ///
  /// In fr, this message translates to:
  /// **'Toutes les zones'**
  String get allAreas;

  /// No description provided for @planView.
  ///
  /// In fr, this message translates to:
  /// **'Plan'**
  String get planView;

  /// No description provided for @cardsView.
  ///
  /// In fr, this message translates to:
  /// **'Cartes'**
  String get cardsView;

  /// No description provided for @editFloor.
  ///
  /// In fr, this message translates to:
  /// **'Modifier la salle'**
  String get editFloor;

  /// No description provided for @done.
  ///
  /// In fr, this message translates to:
  /// **'Terminé'**
  String get done;

  /// No description provided for @floorEmptyTitle.
  ///
  /// In fr, this message translates to:
  /// **'Créez votre salle'**
  String get floorEmptyTitle;

  /// No description provided for @floorEmptyHint.
  ///
  /// In fr, this message translates to:
  /// **'Ajoutez d\'abord vos zones (Salle, Terrasse, VIP…), puis vos tables avec le nom que vous voulez (Table 1, VIP 1, Bar 2…). Vous verrez ensuite en direct quelles tables sont libres, occupées ou réservées.'**
  String get floorEmptyHint;

  /// No description provided for @editFloorHint.
  ///
  /// In fr, this message translates to:
  /// **'Faites glisser les tables pour reproduire votre salle. Touchez une table pour la renommer, changer ses places ou sa forme.'**
  String get editFloorHint;

  /// No description provided for @noTablesInArea.
  ///
  /// In fr, this message translates to:
  /// **'Aucune table dans cette zone : « Modifier la salle » puis « Nouvelle table ».'**
  String get noTablesInArea;

  /// No description provided for @newOrderAtTable.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle commande à cette table'**
  String get newOrderAtTable;

  /// No description provided for @openOrder.
  ///
  /// In fr, this message translates to:
  /// **'Ouvrir la commande'**
  String get openOrder;

  /// No description provided for @reservationsToday.
  ///
  /// In fr, this message translates to:
  /// **'Réservations du jour'**
  String get reservationsToday;

  /// No description provided for @reserveTable.
  ///
  /// In fr, this message translates to:
  /// **'Réserver'**
  String get reserveTable;

  /// No description provided for @noReservationToday.
  ///
  /// In fr, this message translates to:
  /// **'Aucune réservation aujourd\'hui pour cette table.'**
  String get noReservationToday;

  /// No description provided for @tableQrCode.
  ///
  /// In fr, this message translates to:
  /// **'QR code de la table'**
  String get tableQrCode;

  /// No description provided for @tableQrHint.
  ///
  /// In fr, this message translates to:
  /// **'À imprimer et poser sur la table : le client scanne, voit la carte avec les photos et commande. La commande arrive dans « À valider ».'**
  String get tableQrHint;

  /// No description provided for @areaNameHint.
  ///
  /// In fr, this message translates to:
  /// **'Ex. : Salle, Terrasse, VIP, Étage'**
  String get areaNameHint;

  /// No description provided for @tableLabelHint.
  ///
  /// In fr, this message translates to:
  /// **'Ex. : Table 1, VIP 1, Bar 2'**
  String get tableLabelHint;

  /// No description provided for @tableShape.
  ///
  /// In fr, this message translates to:
  /// **'Forme'**
  String get tableShape;

  /// No description provided for @shapeSquare.
  ///
  /// In fr, this message translates to:
  /// **'Carrée'**
  String get shapeSquare;

  /// No description provided for @shapeRound.
  ///
  /// In fr, this message translates to:
  /// **'Ronde'**
  String get shapeRound;

  /// No description provided for @shapeRect.
  ///
  /// In fr, this message translates to:
  /// **'Rectangulaire'**
  String get shapeRect;

  /// No description provided for @resRequested.
  ///
  /// In fr, this message translates to:
  /// **'Demandée'**
  String get resRequested;

  /// No description provided for @resConfirmed.
  ///
  /// In fr, this message translates to:
  /// **'Confirmée'**
  String get resConfirmed;

  /// No description provided for @resSeated.
  ///
  /// In fr, this message translates to:
  /// **'Installés'**
  String get resSeated;

  /// No description provided for @resCompleted.
  ///
  /// In fr, this message translates to:
  /// **'Terminée'**
  String get resCompleted;

  /// No description provided for @resNoShow.
  ///
  /// In fr, this message translates to:
  /// **'Absents'**
  String get resNoShow;

  /// No description provided for @resDeclined.
  ///
  /// In fr, this message translates to:
  /// **'Refusée'**
  String get resDeclined;

  /// No description provided for @resCancelled.
  ///
  /// In fr, this message translates to:
  /// **'Annulée'**
  String get resCancelled;

  /// No description provided for @reservationRequests.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{1 demande de réservation à traiter} other{{count} demandes de réservation à traiter}}'**
  String reservationRequests(int count);

  /// No description provided for @reservationRequestsHint.
  ///
  /// In fr, this message translates to:
  /// **'Demandes faites par les clients en ligne : confirmez en choisissant les tables, ou refusez avec un motif. Le client est prévenu.'**
  String get reservationRequestsHint;

  /// No description provided for @declineReservation.
  ///
  /// In fr, this message translates to:
  /// **'Refuser la réservation'**
  String get declineReservation;

  /// No description provided for @confirmReservation.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer'**
  String get confirmReservation;

  /// No description provided for @reservationsCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Aucune réservation} =1{1 réservation} other{{count} réservations}}'**
  String reservationsCount(int count);

  /// No description provided for @coversCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{0 couvert} =1{1 couvert} other{{count} couverts}}'**
  String coversCount(int count);

  /// No description provided for @noReservationsDay.
  ///
  /// In fr, this message translates to:
  /// **'Aucune réservation ce jour-là.'**
  String get noReservationsDay;

  /// No description provided for @today.
  ///
  /// In fr, this message translates to:
  /// **'Aujourd\'hui'**
  String get today;

  /// No description provided for @timelineView.
  ///
  /// In fr, this message translates to:
  /// **'Planning'**
  String get timelineView;

  /// No description provided for @listView.
  ///
  /// In fr, this message translates to:
  /// **'Liste'**
  String get listView;

  /// No description provided for @newReservation.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle réservation'**
  String get newReservation;

  /// No description provided for @nowLabel.
  ///
  /// In fr, this message translates to:
  /// **'maintenant'**
  String get nowLabel;

  /// No description provided for @seatGuests.
  ///
  /// In fr, this message translates to:
  /// **'Installer les clients'**
  String get seatGuests;

  /// No description provided for @changeTables.
  ///
  /// In fr, this message translates to:
  /// **'Changer de tables'**
  String get changeTables;

  /// No description provided for @markNoShow.
  ///
  /// In fr, this message translates to:
  /// **'Absents'**
  String get markNoShow;

  /// No description provided for @cancelReservation.
  ///
  /// In fr, this message translates to:
  /// **'Annuler la réservation'**
  String get cancelReservation;

  /// No description provided for @markCompleted.
  ///
  /// In fr, this message translates to:
  /// **'Terminée'**
  String get markCompleted;

  /// No description provided for @chooseTables.
  ///
  /// In fr, this message translates to:
  /// **'Tables'**
  String get chooseTables;

  /// No description provided for @seatsForParty.
  ///
  /// In fr, this message translates to:
  /// **'{seats} places choisies pour {party} personnes'**
  String seatsForParty(int seats, int party);

  /// No description provided for @reservationNoteHint.
  ///
  /// In fr, this message translates to:
  /// **'Ex. : anniversaire, chaise bébé, près de la fenêtre'**
  String get reservationNoteHint;

  /// No description provided for @noFreeTableSlot.
  ///
  /// In fr, this message translates to:
  /// **'Aucune table libre sur ce créneau : changez l\'heure ou la durée.'**
  String get noFreeTableSlot;

  /// No description provided for @itemsCountLabel.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{aucun article} =1{1 article} other{{count} articles}}'**
  String itemsCountLabel(int count);

  /// No description provided for @alertNewCustomerOrder.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle commande d\'un client à valider'**
  String get alertNewCustomerOrder;

  /// No description provided for @alertOrderReady.
  ///
  /// In fr, this message translates to:
  /// **'Une commande est prête à servir'**
  String get alertOrderReady;

  /// No description provided for @view.
  ///
  /// In fr, this message translates to:
  /// **'Voir'**
  String get view;

  /// No description provided for @ordersToValidateBanner.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{1 commande client attend votre validation} other{{count} commandes clients attendent votre validation}}'**
  String ordersToValidateBanner(int count);

  /// No description provided for @tabInProgress.
  ///
  /// In fr, this message translates to:
  /// **'En cours'**
  String get tabInProgress;

  /// No description provided for @historyTab.
  ///
  /// In fr, this message translates to:
  /// **'Historique'**
  String get historyTab;

  /// No description provided for @newShort.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle'**
  String get newShort;

  /// No description provided for @brandPoint1.
  ///
  /// In fr, this message translates to:
  /// **'Commandes en salle, à emporter, en livraison et en ligne'**
  String get brandPoint1;

  /// No description provided for @brandPoint2.
  ///
  /// In fr, this message translates to:
  /// **'Cuisine et bar en direct, salle et réservations'**
  String get brandPoint2;

  /// No description provided for @brandPoint3.
  ///
  /// In fr, this message translates to:
  /// **'Caisse, stocks, achats et dépenses'**
  String get brandPoint3;

  /// No description provided for @brandPoint4.
  ///
  /// In fr, this message translates to:
  /// **'Tableaux de bord et rapports professionnels'**
  String get brandPoint4;

  /// No description provided for @authWelcome.
  ///
  /// In fr, this message translates to:
  /// **'Bienvenue'**
  String get authWelcome;

  /// No description provided for @authWelcomeSub.
  ///
  /// In fr, this message translates to:
  /// **'Connectez-vous pour retrouver votre restaurant'**
  String get authWelcomeSub;

  /// No description provided for @noAccountYet.
  ///
  /// In fr, this message translates to:
  /// **'Pas encore de compte ?'**
  String get noAccountYet;

  /// No description provided for @alreadyAccount.
  ///
  /// In fr, this message translates to:
  /// **'Déjà un compte ?'**
  String get alreadyAccount;

  /// No description provided for @authSignUpSub.
  ///
  /// In fr, this message translates to:
  /// **'Quelques secondes pour commencer, sans engagement'**
  String get authSignUpSub;

  /// No description provided for @authForgotSub.
  ///
  /// In fr, this message translates to:
  /// **'Recevez un code par e-mail pour choisir un nouveau mot de passe'**
  String get authForgotSub;

  /// No description provided for @authNewPasswordSub.
  ///
  /// In fr, this message translates to:
  /// **'Au moins 8 caractères'**
  String get authNewPasswordSub;

  /// No description provided for @navHome.
  ///
  /// In fr, this message translates to:
  /// **'Accueil'**
  String get navHome;

  /// No description provided for @greetingDay.
  ///
  /// In fr, this message translates to:
  /// **'Bonjour'**
  String get greetingDay;

  /// No description provided for @greetingEvening.
  ///
  /// In fr, this message translates to:
  /// **'Bonsoir'**
  String get greetingEvening;

  /// No description provided for @moreModules.
  ///
  /// In fr, this message translates to:
  /// **'Plus'**
  String get moreModules;

  /// No description provided for @freeTablesCount.
  ///
  /// In fr, this message translates to:
  /// **'{free} tables libres sur {total}'**
  String freeTablesCount(int free, int total);

  /// No description provided for @suggestedTable.
  ///
  /// In fr, this message translates to:
  /// **'Suggestion : {label} ({seats} places)'**
  String suggestedTable(String label, int seats);

  /// No description provided for @slotFreeSoon.
  ///
  /// In fr, this message translates to:
  /// **'Libre avant l\'heure'**
  String get slotFreeSoon;

  /// No description provided for @slotReserved.
  ///
  /// In fr, this message translates to:
  /// **'Réservée sur ce créneau'**
  String get slotReserved;

  /// No description provided for @freeAround.
  ///
  /// In fr, this message translates to:
  /// **'libre vers {time}'**
  String freeAround(String time);

  /// No description provided for @timelineEmptyHint.
  ///
  /// In fr, this message translates to:
  /// **'Aucune réservation ce jour-là. Touchez une heure sur la ligne d\'une table pour la réserver.'**
  String get timelineEmptyHint;

  /// No description provided for @myAccount.
  ///
  /// In fr, this message translates to:
  /// **'Mon compte'**
  String get myAccount;

  /// No description provided for @brandTagline.
  ///
  /// In fr, this message translates to:
  /// **'La gestion de restaurant, fluide et limpide.'**
  String get brandTagline;

  /// No description provided for @addPaymentMethod.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un mode'**
  String get addPaymentMethod;

  /// No description provided for @allMethods.
  ///
  /// In fr, this message translates to:
  /// **'Tous les modes'**
  String get allMethods;

  /// No description provided for @availableInBranches.
  ///
  /// In fr, this message translates to:
  /// **'Disponible dans'**
  String get availableInBranches;

  /// No description provided for @availableWorldwide.
  ///
  /// In fr, this message translates to:
  /// **'Valables partout'**
  String get availableWorldwide;

  /// No description provided for @blindCountHint.
  ///
  /// In fr, this message translates to:
  /// **'Comptez le tiroir sans regarder l\'attendu : l\'écart s\'affiche une fois le comptage enregistré.'**
  String get blindCountHint;

  /// No description provided for @cashDrawer.
  ///
  /// In fr, this message translates to:
  /// **'Tiroir-caisse'**
  String get cashDrawer;

  /// No description provided for @cashMovementsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Entrées et sorties d\'espèces'**
  String get cashMovementsTitle;

  /// No description provided for @cashReportTitle.
  ///
  /// In fr, this message translates to:
  /// **'Rapport de caisse'**
  String get cashReportTitle;

  /// No description provided for @cashierLabel.
  ///
  /// In fr, this message translates to:
  /// **'Caissier'**
  String get cashierLabel;

  /// No description provided for @choosePaymentMethod.
  ///
  /// In fr, this message translates to:
  /// **'Choisissez le mode de paiement.'**
  String get choosePaymentMethod;

  /// No description provided for @closingValidated.
  ///
  /// In fr, this message translates to:
  /// **'Clôture validée : Z numéroté.'**
  String get closingValidated;

  /// No description provided for @closingsTab.
  ///
  /// In fr, this message translates to:
  /// **'Clôtures'**
  String get closingsTab;

  /// No description provided for @coinsLabel.
  ///
  /// In fr, this message translates to:
  /// **'Pièces'**
  String get coinsLabel;

  /// No description provided for @collectTab.
  ///
  /// In fr, this message translates to:
  /// **'Encaisser'**
  String get collectTab;

  /// No description provided for @collectWithTip.
  ///
  /// In fr, this message translates to:
  /// **'Encaisser {amount} + {tip}'**
  String collectWithTip(String amount, String tip);

  /// No description provided for @collectedByDay.
  ///
  /// In fr, this message translates to:
  /// **'Encaissé par jour'**
  String get collectedByDay;

  /// No description provided for @collectedByHour.
  ///
  /// In fr, this message translates to:
  /// **'Encaissé par heure'**
  String get collectedByHour;

  /// No description provided for @collectedTotal.
  ///
  /// In fr, this message translates to:
  /// **'Encaissé'**
  String get collectedTotal;

  /// No description provided for @commonInCountry.
  ///
  /// In fr, this message translates to:
  /// **'Courants dans votre pays ({country})'**
  String commonInCountry(String country);

  /// No description provided for @countByDenomination.
  ///
  /// In fr, this message translates to:
  /// **'Billet par billet'**
  String get countByDenomination;

  /// No description provided for @countConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer le comptage : {amount} ?'**
  String countConfirm(String amount);

  /// No description provided for @countDetailTitle.
  ///
  /// In fr, this message translates to:
  /// **'Détail du comptage'**
  String get countDetailTitle;

  /// No description provided for @countRecorded.
  ///
  /// In fr, this message translates to:
  /// **'Comptage enregistré'**
  String get countRecorded;

  /// No description provided for @countedLabel.
  ///
  /// In fr, this message translates to:
  /// **'Comptée'**
  String get countedLabel;

  /// No description provided for @countedTotal.
  ///
  /// In fr, this message translates to:
  /// **'Total compté'**
  String get countedTotal;

  /// No description provided for @customMethod.
  ///
  /// In fr, this message translates to:
  /// **'Mode personnalisé'**
  String get customMethod;

  /// No description provided for @customMethodHint.
  ///
  /// In fr, this message translates to:
  /// **'Ex. : bon maison, carte fidélité, paiement par lien'**
  String get customMethodHint;

  /// No description provided for @dateLabel.
  ///
  /// In fr, this message translates to:
  /// **'Date'**
  String get dateLabel;

  /// No description provided for @differenceLabel.
  ///
  /// In fr, this message translates to:
  /// **'Écart'**
  String get differenceLabel;

  /// No description provided for @differenceReasonHint.
  ///
  /// In fr, this message translates to:
  /// **'Ex. : erreur de rendu de monnaie, billet abîmé'**
  String get differenceReasonHint;

  /// No description provided for @discountsTotal.
  ///
  /// In fr, this message translates to:
  /// **'Réductions'**
  String get discountsTotal;

  /// No description provided for @displayOrder.
  ///
  /// In fr, this message translates to:
  /// **'Ordre'**
  String get displayOrder;

  /// No description provided for @enterAmount.
  ///
  /// In fr, this message translates to:
  /// **'Saisir le montant'**
  String get enterAmount;

  /// No description provided for @errorPaymentMethodUnavailable.
  ///
  /// In fr, this message translates to:
  /// **'Ce mode de paiement n\'est pas disponible ici.'**
  String get errorPaymentMethodUnavailable;

  /// No description provided for @errorReferenceRequired.
  ///
  /// In fr, this message translates to:
  /// **'Saisissez le n° de transaction (référence du paiement).'**
  String get errorReferenceRequired;

  /// No description provided for @exactAmount.
  ///
  /// In fr, this message translates to:
  /// **'Montant exact'**
  String get exactAmount;

  /// No description provided for @exportExcel.
  ///
  /// In fr, this message translates to:
  /// **'Exporter (tableur)'**
  String get exportExcel;

  /// No description provided for @exportPdf.
  ///
  /// In fr, this message translates to:
  /// **'Exporter en PDF'**
  String get exportPdf;

  /// No description provided for @feePercentLabel.
  ///
  /// In fr, this message translates to:
  /// **'Commission prélevée'**
  String get feePercentLabel;

  /// No description provided for @feeShort.
  ///
  /// In fr, this message translates to:
  /// **'commission {percent} %'**
  String feeShort(String percent);

  /// No description provided for @feesEstimate.
  ///
  /// In fr, this message translates to:
  /// **'Commissions (estimation)'**
  String get feesEstimate;

  /// No description provided for @findTicket.
  ///
  /// In fr, this message translates to:
  /// **'Retrouver un ticket'**
  String get findTicket;

  /// No description provided for @lastPayments.
  ///
  /// In fr, this message translates to:
  /// **'Derniers paiements'**
  String get lastPayments;

  /// No description provided for @legalNameLabel.
  ///
  /// In fr, this message translates to:
  /// **'Raison sociale'**
  String get legalNameLabel;

  /// No description provided for @managerMustValidate.
  ///
  /// In fr, this message translates to:
  /// **'Un responsable doit valider la clôture.'**
  String get managerMustValidate;

  /// No description provided for @methodKind.
  ///
  /// In fr, this message translates to:
  /// **'Type'**
  String get methodKind;

  /// No description provided for @mySessionTab.
  ///
  /// In fr, this message translates to:
  /// **'Ma caisse'**
  String get mySessionTab;

  /// No description provided for @newRegister.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle caisse'**
  String get newRegister;

  /// No description provided for @noActiveRegister.
  ///
  /// In fr, this message translates to:
  /// **'Aucune caisse active : créez-en une dans Réglages.'**
  String get noActiveRegister;

  /// No description provided for @noClosings.
  ///
  /// In fr, this message translates to:
  /// **'Aucune clôture pour l\'instant.'**
  String get noClosings;

  /// No description provided for @noMovements.
  ///
  /// In fr, this message translates to:
  /// **'Aucun mouvement.'**
  String get noMovements;

  /// No description provided for @noPaymentMethod.
  ///
  /// In fr, this message translates to:
  /// **'Aucun mode de paiement actif : ajoutez-en dans Réglages.'**
  String get noPaymentMethod;

  /// No description provided for @noPaymentsYet.
  ///
  /// In fr, this message translates to:
  /// **'Aucun paiement pour l\'instant.'**
  String get noPaymentsYet;

  /// No description provided for @noRefunds.
  ///
  /// In fr, this message translates to:
  /// **'Aucun remboursement ces 30 derniers jours.'**
  String get noRefunds;

  /// No description provided for @noTip.
  ///
  /// In fr, this message translates to:
  /// **'Aucun'**
  String get noTip;

  /// No description provided for @notesLabel.
  ///
  /// In fr, this message translates to:
  /// **'Billets'**
  String get notesLabel;

  /// No description provided for @nothingToCollect.
  ///
  /// In fr, this message translates to:
  /// **'Rien à encaisser pour le moment.'**
  String get nothingToCollect;

  /// No description provided for @openRegisterHint.
  ///
  /// In fr, this message translates to:
  /// **'Comptez le fond de caisse (la monnaie de départ) : il servira de base au comptage de fin de service.'**
  String get openRegisterHint;

  /// No description provided for @openRegisterTitle.
  ///
  /// In fr, this message translates to:
  /// **'Ouvrir {register}'**
  String openRegisterTitle(String register);

  /// No description provided for @openedLabel.
  ///
  /// In fr, this message translates to:
  /// **'Ouverture'**
  String get openedLabel;

  /// No description provided for @orderDetails.
  ///
  /// In fr, this message translates to:
  /// **'Détail de la commande'**
  String get orderDetails;

  /// No description provided for @orderShort.
  ///
  /// In fr, this message translates to:
  /// **'Commande'**
  String get orderShort;

  /// No description provided for @otherAmount.
  ///
  /// In fr, this message translates to:
  /// **'Autre montant'**
  String get otherAmount;

  /// No description provided for @otherCountries.
  ///
  /// In fr, this message translates to:
  /// **'Autres pays'**
  String get otherCountries;

  /// No description provided for @payKindAccount.
  ///
  /// In fr, this message translates to:
  /// **'Compte client'**
  String get payKindAccount;

  /// No description provided for @payKindCheque.
  ///
  /// In fr, this message translates to:
  /// **'Chèque'**
  String get payKindCheque;

  /// No description provided for @payKindInstant.
  ///
  /// In fr, this message translates to:
  /// **'Paiement instantané'**
  String get payKindInstant;

  /// No description provided for @payKindVoucher.
  ///
  /// In fr, this message translates to:
  /// **'Titre ou bon'**
  String get payKindVoucher;

  /// No description provided for @payKindWallet.
  ///
  /// In fr, this message translates to:
  /// **'Portefeuille mobile'**
  String get payKindWallet;

  /// No description provided for @paymentComplete.
  ///
  /// In fr, this message translates to:
  /// **'Paiement terminé'**
  String get paymentComplete;

  /// No description provided for @paymentMethodLabel.
  ///
  /// In fr, this message translates to:
  /// **'Mode de paiement'**
  String get paymentMethodLabel;

  /// No description provided for @paymentMethodsHint.
  ///
  /// In fr, this message translates to:
  /// **'Les modes proposés à l\'encaissement. Adaptez-les à votre pays : nom, n° de transaction obligatoire, commission, établissements.'**
  String get paymentMethodsHint;

  /// No description provided for @paymentMethodsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Modes de paiement'**
  String get paymentMethodsTitle;

  /// No description provided for @paymentsCountShort.
  ///
  /// In fr, this message translates to:
  /// **'Paiements'**
  String get paymentsCountShort;

  /// No description provided for @periodYesterday.
  ///
  /// In fr, this message translates to:
  /// **'Hier'**
  String get periodYesterday;

  /// No description provided for @printCountReport.
  ///
  /// In fr, this message translates to:
  /// **'Imprimer le comptage'**
  String get printCountReport;

  /// No description provided for @printReceipt.
  ///
  /// In fr, this message translates to:
  /// **'Imprimer le ticket'**
  String get printReceipt;

  /// No description provided for @reasonChangeFloat.
  ///
  /// In fr, this message translates to:
  /// **'Apport de monnaie'**
  String get reasonChangeFloat;

  /// No description provided for @reasonOtherIn.
  ///
  /// In fr, this message translates to:
  /// **'Autre entrée'**
  String get reasonOtherIn;

  /// No description provided for @reasonOtherOut.
  ///
  /// In fr, this message translates to:
  /// **'Autre sortie'**
  String get reasonOtherOut;

  /// No description provided for @reasonSafeDrop.
  ///
  /// In fr, this message translates to:
  /// **'Dépôt au coffre'**
  String get reasonSafeDrop;

  /// No description provided for @reasonSmallPurchase.
  ///
  /// In fr, this message translates to:
  /// **'Petit achat'**
  String get reasonSmallPurchase;

  /// No description provided for @reasonTipsPaid.
  ///
  /// In fr, this message translates to:
  /// **'Pourboires remis à l\'équipe'**
  String get reasonTipsPaid;

  /// No description provided for @receiptFooterHint.
  ///
  /// In fr, this message translates to:
  /// **'Ex. : Merci et à bientôt ! Wi-Fi : RestoInvite'**
  String get receiptFooterHint;

  /// No description provided for @receiptFooterLabel.
  ///
  /// In fr, this message translates to:
  /// **'Message en bas du ticket'**
  String get receiptFooterLabel;

  /// No description provided for @receiptNumberLabel.
  ///
  /// In fr, this message translates to:
  /// **'Ticket n° {number}'**
  String receiptNumberLabel(int number);

  /// No description provided for @receiptSettingsHint.
  ///
  /// In fr, this message translates to:
  /// **'Imprimés sur chaque ticket client et sur les Z de caisse.'**
  String get receiptSettingsHint;

  /// No description provided for @receiptSettingsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Mentions du ticket'**
  String get receiptSettingsTitle;

  /// No description provided for @receiptShort.
  ///
  /// In fr, this message translates to:
  /// **'Ticket'**
  String get receiptShort;

  /// No description provided for @receiptTaxId.
  ///
  /// In fr, this message translates to:
  /// **'N° fiscal : {id}'**
  String receiptTaxId(String id);

  /// No description provided for @recentRefunds.
  ///
  /// In fr, this message translates to:
  /// **'Remboursements récents'**
  String get recentRefunds;

  /// No description provided for @recordCount.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer le comptage'**
  String get recordCount;

  /// No description provided for @referenceRequiredShort.
  ///
  /// In fr, this message translates to:
  /// **'n° de transaction obligatoire'**
  String get referenceRequiredShort;

  /// No description provided for @refundAction.
  ///
  /// In fr, this message translates to:
  /// **'Rembourser'**
  String get refundAction;

  /// No description provided for @refundDone.
  ///
  /// In fr, this message translates to:
  /// **'Remboursement enregistré.'**
  String get refundDone;

  /// No description provided for @refundReasonHint.
  ///
  /// In fr, this message translates to:
  /// **'Ex. : plat refusé, erreur de saisie'**
  String get refundReasonHint;

  /// No description provided for @refundTitle.
  ///
  /// In fr, this message translates to:
  /// **'Rembourser le client'**
  String get refundTitle;

  /// No description provided for @refundableAmount.
  ///
  /// In fr, this message translates to:
  /// **'remboursable : {amount}'**
  String refundableAmount(String amount);

  /// No description provided for @refundsTab.
  ///
  /// In fr, this message translates to:
  /// **'Remboursements'**
  String get refundsTab;

  /// No description provided for @registerClosedHint.
  ///
  /// In fr, this message translates to:
  /// **'Ouvrez la caisse (fond compté) pour encaisser.'**
  String get registerClosedHint;

  /// No description provided for @registerClosedTitle.
  ///
  /// In fr, this message translates to:
  /// **'Caisse fermée'**
  String get registerClosedTitle;

  /// No description provided for @registerLabel.
  ///
  /// In fr, this message translates to:
  /// **'Caisse'**
  String get registerLabel;

  /// No description provided for @registerNameHint.
  ///
  /// In fr, this message translates to:
  /// **'Ex. : Comptoir, Terrasse, Bar'**
  String get registerNameHint;

  /// No description provided for @registersTitle.
  ///
  /// In fr, this message translates to:
  /// **'Caisses'**
  String get registersTitle;

  /// No description provided for @reportsTab.
  ///
  /// In fr, this message translates to:
  /// **'Rapports'**
  String get reportsTab;

  /// No description provided for @requireReferenceHint.
  ///
  /// In fr, this message translates to:
  /// **'Le caissier doit saisir le n° de transaction (rapprochement avec le relevé).'**
  String get requireReferenceHint;

  /// No description provided for @requireReferenceLabel.
  ///
  /// In fr, this message translates to:
  /// **'N° de transaction obligatoire'**
  String get requireReferenceLabel;

  /// No description provided for @salesByDay.
  ///
  /// In fr, this message translates to:
  /// **'Par jour'**
  String get salesByDay;

  /// No description provided for @salesByMethod.
  ///
  /// In fr, this message translates to:
  /// **'Par mode de paiement'**
  String get salesByMethod;

  /// No description provided for @salesByRegister.
  ///
  /// In fr, this message translates to:
  /// **'Par caisse'**
  String get salesByRegister;

  /// No description provided for @salesByStaff.
  ///
  /// In fr, this message translates to:
  /// **'Par serveur'**
  String get salesByStaff;

  /// No description provided for @searchAction.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher'**
  String get searchAction;

  /// No description provided for @searchMethodOrCountry.
  ///
  /// In fr, this message translates to:
  /// **'Nom du mode ou code pays (ex. BR)'**
  String get searchMethodOrCountry;

  /// No description provided for @sendWhatsApp.
  ///
  /// In fr, this message translates to:
  /// **'Envoyer par WhatsApp'**
  String get sendWhatsApp;

  /// No description provided for @sessionAwaitingValidation.
  ///
  /// In fr, this message translates to:
  /// **'Comptée — en attente de validation'**
  String get sessionAwaitingValidation;

  /// No description provided for @settingsTab.
  ///
  /// In fr, this message translates to:
  /// **'Réglages'**
  String get settingsTab;

  /// No description provided for @shareReceipt.
  ///
  /// In fr, this message translates to:
  /// **'Partager le ticket'**
  String get shareReceipt;

  /// No description provided for @signatureCashier.
  ///
  /// In fr, this message translates to:
  /// **'Signature caissier'**
  String get signatureCashier;

  /// No description provided for @signatureManager.
  ///
  /// In fr, this message translates to:
  /// **'Signature responsable'**
  String get signatureManager;

  /// No description provided for @someBranchesOnly.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{1 établissement} other{{count} établissements}}'**
  String someBranchesOnly(int count);

  /// No description provided for @splitAll.
  ///
  /// In fr, this message translates to:
  /// **'Tout'**
  String get splitAll;

  /// No description provided for @splitByItems.
  ///
  /// In fr, this message translates to:
  /// **'Par articles'**
  String get splitByItems;

  /// No description provided for @splitByParts.
  ///
  /// In fr, this message translates to:
  /// **'Par parts'**
  String get splitByParts;

  /// No description provided for @splitCustom.
  ///
  /// In fr, this message translates to:
  /// **'Montant libre'**
  String get splitCustom;

  /// No description provided for @staffLabel.
  ///
  /// In fr, this message translates to:
  /// **'Serveur'**
  String get staffLabel;

  /// No description provided for @statusLabel.
  ///
  /// In fr, this message translates to:
  /// **'État'**
  String get statusLabel;

  /// No description provided for @taxIdHint.
  ///
  /// In fr, this message translates to:
  /// **'Numéro d\'identification fiscale de votre pays'**
  String get taxIdHint;

  /// No description provided for @taxIdLabel.
  ///
  /// In fr, this message translates to:
  /// **'N° d\'identification fiscale'**
  String get taxIdLabel;

  /// No description provided for @ticketOrOrderNumber.
  ///
  /// In fr, this message translates to:
  /// **'N° de ticket ou de commande'**
  String get ticketOrOrderNumber;

  /// No description provided for @tipLabel.
  ///
  /// In fr, this message translates to:
  /// **'Pourboire'**
  String get tipLabel;

  /// No description provided for @tipPresetsLabel.
  ///
  /// In fr, this message translates to:
  /// **'Pourcentages proposés'**
  String get tipPresetsLabel;

  /// No description provided for @tipsEnabledHint.
  ///
  /// In fr, this message translates to:
  /// **'Proposé à l\'encaissement, compté à part du chiffre d\'affaires et attribué au serveur de la commande.'**
  String get tipsEnabledHint;

  /// No description provided for @tipsEnabledLabel.
  ///
  /// In fr, this message translates to:
  /// **'Proposer un pourboire'**
  String get tipsEnabledLabel;

  /// No description provided for @tipsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Pourboires'**
  String get tipsTitle;

  /// No description provided for @tipsTotal.
  ///
  /// In fr, this message translates to:
  /// **'Pourboires'**
  String get tipsTotal;

  /// No description provided for @toCollectTotal.
  ///
  /// In fr, this message translates to:
  /// **'À encaisser'**
  String get toCollectTotal;

  /// No description provided for @transactionReferenceRequired.
  ///
  /// In fr, this message translates to:
  /// **'N° de transaction (obligatoire)'**
  String get transactionReferenceRequired;

  /// No description provided for @transactionsTab.
  ///
  /// In fr, this message translates to:
  /// **'Transactions'**
  String get transactionsTab;

  /// No description provided for @validateClosingConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Valider cette clôture ? Le Z de caisse sera numéroté et ne pourra plus être modifié.'**
  String get validateClosingConfirm;

  /// No description provided for @validateNowHint.
  ///
  /// In fr, this message translates to:
  /// **'Validez la clôture dans l\'onglet Clôtures pour obtenir le Z numéroté.'**
  String get validateNowHint;

  /// No description provided for @validatedLabel.
  ///
  /// In fr, this message translates to:
  /// **'Validée'**
  String get validatedLabel;

  /// No description provided for @voidedPayments.
  ///
  /// In fr, this message translates to:
  /// **'Paiements annulés'**
  String get voidedPayments;

  /// No description provided for @xReading.
  ///
  /// In fr, this message translates to:
  /// **'Lecture X'**
  String get xReading;

  /// No description provided for @xReportTitle.
  ///
  /// In fr, this message translates to:
  /// **'Lecture X (provisoire)'**
  String get xReportTitle;

  /// No description provided for @zHistory.
  ///
  /// In fr, this message translates to:
  /// **'Historique des Z'**
  String get zHistory;

  /// No description provided for @zReportTitle.
  ///
  /// In fr, this message translates to:
  /// **'Z de caisse n° {number}'**
  String zReportTitle(int number);

  /// No description provided for @zShort.
  ///
  /// In fr, this message translates to:
  /// **'Z'**
  String get zShort;

  /// No description provided for @expectedCashLabel.
  ///
  /// In fr, this message translates to:
  /// **'Espèces attendues'**
  String get expectedCashLabel;

  /// No description provided for @countedAmountLabel.
  ///
  /// In fr, this message translates to:
  /// **'Compté'**
  String get countedAmountLabel;

  /// No description provided for @refundsLabel.
  ///
  /// In fr, this message translates to:
  /// **'Remboursements'**
  String get refundsLabel;

  /// No description provided for @addressOptional.
  ///
  /// In fr, this message translates to:
  /// **'Adresse (facultatif)'**
  String get addressOptional;

  /// No description provided for @billedTo.
  ///
  /// In fr, this message translates to:
  /// **'Facturé à'**
  String get billedTo;

  /// No description provided for @cancelInvoiceHint.
  ///
  /// In fr, this message translates to:
  /// **'Ex. : erreur de raison sociale, client erroné'**
  String get cancelInvoiceHint;

  /// No description provided for @chooseOrder.
  ///
  /// In fr, this message translates to:
  /// **'Choisissez la commande'**
  String get chooseOrder;

  /// No description provided for @companyOptional.
  ///
  /// In fr, this message translates to:
  /// **'Société (facultatif)'**
  String get companyOptional;

  /// No description provided for @customerTaxIdOptional.
  ///
  /// In fr, this message translates to:
  /// **'N° d\'identification fiscale du client (facultatif)'**
  String get customerTaxIdOptional;

  /// No description provided for @documentsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Documents'**
  String get documentsTitle;

  /// No description provided for @emailOptional.
  ///
  /// In fr, this message translates to:
  /// **'E-mail (facultatif)'**
  String get emailOptional;

  /// No description provided for @errorCustomerNameRequired.
  ///
  /// In fr, this message translates to:
  /// **'Le nom du client est obligatoire sur une facture.'**
  String get errorCustomerNameRequired;

  /// No description provided for @invoiceATicket.
  ///
  /// In fr, this message translates to:
  /// **'Facturer un ticket'**
  String get invoiceATicket;

  /// No description provided for @invoiceCancelledMention.
  ///
  /// In fr, this message translates to:
  /// **'FACTURE ANNULÉE'**
  String get invoiceCancelledMention;

  /// No description provided for @invoiceCancelledDone.
  ///
  /// In fr, this message translates to:
  /// **'Facture annulée : vous pouvez en émettre une nouvelle.'**
  String get invoiceCancelledDone;

  /// No description provided for @invoiceDateLabel.
  ///
  /// In fr, this message translates to:
  /// **'Date : {date}'**
  String invoiceDateLabel(String date);

  /// No description provided for @invoiceDesignation.
  ///
  /// In fr, this message translates to:
  /// **'Désignation'**
  String get invoiceDesignation;

  /// No description provided for @invoiceEmailHint.
  ///
  /// In fr, this message translates to:
  /// **'Pour l\'envoyer à {email} : « Partager », puis choisissez votre messagerie.'**
  String invoiceEmailHint(String email);

  /// No description provided for @invoiceFooterHint.
  ///
  /// In fr, this message translates to:
  /// **'Ex. : conditions de paiement, coordonnées bancaires, mentions légales de votre pays'**
  String get invoiceFooterHint;

  /// No description provided for @invoiceFooterLabel.
  ///
  /// In fr, this message translates to:
  /// **'Mentions en bas de facture'**
  String get invoiceFooterLabel;

  /// No description provided for @invoiceNumberLabel.
  ///
  /// In fr, this message translates to:
  /// **'Facture n° {number}'**
  String invoiceNumberLabel(String number);

  /// No description provided for @invoicePayments.
  ///
  /// In fr, this message translates to:
  /// **'Paiements reçus'**
  String get invoicePayments;

  /// No description provided for @invoicePrefixHint.
  ///
  /// In fr, this message translates to:
  /// **'Ex. : FA-2026-'**
  String get invoicePrefixHint;

  /// No description provided for @invoicePrefixLabel.
  ///
  /// In fr, this message translates to:
  /// **'Préfixe du numéro de facture'**
  String get invoicePrefixLabel;

  /// No description provided for @invoiceSettingsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Factures'**
  String get invoiceSettingsTitle;

  /// No description provided for @invoiceTitle.
  ///
  /// In fr, this message translates to:
  /// **'Facture'**
  String get invoiceTitle;

  /// No description provided for @invoiceUnitPrice.
  ///
  /// In fr, this message translates to:
  /// **'Prix unitaire'**
  String get invoiceUnitPrice;

  /// No description provided for @invoicedTotal.
  ///
  /// In fr, this message translates to:
  /// **'Facturé'**
  String get invoicedTotal;

  /// No description provided for @invoicesCount.
  ///
  /// In fr, this message translates to:
  /// **'Factures'**
  String get invoicesCount;

  /// No description provided for @issueInvoice.
  ///
  /// In fr, this message translates to:
  /// **'Établir une facture'**
  String get issueInvoice;

  /// No description provided for @issueInvoiceAction.
  ///
  /// In fr, this message translates to:
  /// **'Émettre la facture'**
  String get issueInvoiceAction;

  /// No description provided for @issueInvoiceHint.
  ///
  /// In fr, this message translates to:
  /// **'Une facture émise est numérotée et ne se modifie plus (en cas d\'erreur : annulation puis nouvelle facture).'**
  String get issueInvoiceHint;

  /// No description provided for @noInvoices.
  ///
  /// In fr, this message translates to:
  /// **'Aucune facture sur cette période. Une facture s\'établit depuis une commande (bouton « Facture ») ou ici avec « Facturer un ticket ».'**
  String get noInvoices;

  /// No description provided for @printInvoice.
  ///
  /// In fr, this message translates to:
  /// **'Imprimer / télécharger'**
  String get printInvoice;

  /// No description provided for @receiptDocument.
  ///
  /// In fr, this message translates to:
  /// **'Ticket de caisse'**
  String get receiptDocument;

  /// No description provided for @searchInvoiceHint.
  ///
  /// In fr, this message translates to:
  /// **'N°, client, société'**
  String get searchInvoiceHint;

  /// No description provided for @shareInvoice.
  ///
  /// In fr, this message translates to:
  /// **'Partager'**
  String get shareInvoice;

  /// No description provided for @totalExclTax.
  ///
  /// In fr, this message translates to:
  /// **'Total hors taxes'**
  String get totalExclTax;

  /// No description provided for @totalInclTax.
  ///
  /// In fr, this message translates to:
  /// **'Total toutes taxes comprises'**
  String get totalInclTax;

  /// No description provided for @receiptQrCaption.
  ///
  /// In fr, this message translates to:
  /// **'Scannez pour nous retrouver en ligne'**
  String get receiptQrCaption;

  /// No description provided for @receiptQrLabel.
  ///
  /// In fr, this message translates to:
  /// **'QR code en bas du ticket'**
  String get receiptQrLabel;

  /// No description provided for @receiptQrUrlLabel.
  ///
  /// In fr, this message translates to:
  /// **'Lien du QR code'**
  String get receiptQrUrlLabel;

  /// No description provided for @receiptQrUrlHint.
  ///
  /// In fr, this message translates to:
  /// **'Vide = page du restaurant. Ex. : https://votre-site.com ou votre page d\'avis'**
  String get receiptQrUrlHint;

  /// No description provided for @receiptQrUrlInvalid.
  ///
  /// In fr, this message translates to:
  /// **'Le lien du QR code doit commencer par https:// (ou http://).'**
  String get receiptQrUrlInvalid;

  /// No description provided for @restaurantLogo.
  ///
  /// In fr, this message translates to:
  /// **'Logo du restaurant'**
  String get restaurantLogo;

  /// No description provided for @chooseLogo.
  ///
  /// In fr, this message translates to:
  /// **'Choisir le logo'**
  String get chooseLogo;

  /// No description provided for @replaceLogo.
  ///
  /// In fr, this message translates to:
  /// **'Remplacer'**
  String get replaceLogo;

  /// No description provided for @removeLogo.
  ///
  /// In fr, this message translates to:
  /// **'Retirer'**
  String get removeLogo;

  /// No description provided for @logoTooBig.
  ///
  /// In fr, this message translates to:
  /// **'Ce fichier dépasse 1 Mo : choisissez une image plus légère.'**
  String get logoTooBig;

  /// No description provided for @receiptTendered.
  ///
  /// In fr, this message translates to:
  /// **'Montant remis'**
  String get receiptTendered;

  /// No description provided for @receiptChange.
  ///
  /// In fr, this message translates to:
  /// **'Monnaie rendue'**
  String get receiptChange;

  /// No description provided for @restaurantLogoHint.
  ///
  /// In fr, this message translates to:
  /// **'Imprimé en tête des tickets. PNG à fond transparent conseillé, 1 Mo au plus.'**
  String get restaurantLogoHint;

  /// No description provided for @add.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter'**
  String get add;

  /// No description provided for @delete.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get delete;

  /// No description provided for @branchLabel.
  ///
  /// In fr, this message translates to:
  /// **'Établissement'**
  String get branchLabel;

  /// No description provided for @kindDessert.
  ///
  /// In fr, this message translates to:
  /// **'Dessert'**
  String get kindDessert;

  /// No description provided for @kindMenu.
  ///
  /// In fr, this message translates to:
  /// **'Formule'**
  String get kindMenu;

  /// No description provided for @navAds.
  ///
  /// In fr, this message translates to:
  /// **'Publicité'**
  String get navAds;

  /// No description provided for @navSettings.
  ///
  /// In fr, this message translates to:
  /// **'Paramètres'**
  String get navSettings;

  /// No description provided for @greetingShort.
  ///
  /// In fr, this message translates to:
  /// **'Bonjour'**
  String get greetingShort;

  /// No description provided for @homeWelcome.
  ///
  /// In fr, this message translates to:
  /// **'Bienvenue, voici votre activité du jour'**
  String get homeWelcome;

  /// No description provided for @kpiSalesToday.
  ///
  /// In fr, this message translates to:
  /// **'CA du jour'**
  String get kpiSalesToday;

  /// No description provided for @kpiOpenOrders.
  ///
  /// In fr, this message translates to:
  /// **'Commandes en cours'**
  String get kpiOpenOrders;

  /// No description provided for @kpiPendingCount.
  ///
  /// In fr, this message translates to:
  /// **'{count} en attente'**
  String kpiPendingCount(int count);

  /// No description provided for @kpiOccupancy.
  ///
  /// In fr, this message translates to:
  /// **'Taux d\'occupation'**
  String get kpiOccupancy;

  /// No description provided for @kpiTablesBusy.
  ///
  /// In fr, this message translates to:
  /// **'{busy} tables occupées sur {total}'**
  String kpiTablesBusy(int busy, int total);

  /// No description provided for @lowStockTitle.
  ///
  /// In fr, this message translates to:
  /// **'Stock faible'**
  String get lowStockTitle;

  /// No description provided for @saveChanges.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer les modifications'**
  String get saveChanges;

  /// No description provided for @settingsProfile.
  ///
  /// In fr, this message translates to:
  /// **'Profil de l\'établissement'**
  String get settingsProfile;

  /// No description provided for @settingsProfileHint.
  ///
  /// In fr, this message translates to:
  /// **'Les informations de votre restaurant, visibles par vos clients.'**
  String get settingsProfileHint;

  /// No description provided for @settingsContact.
  ///
  /// In fr, this message translates to:
  /// **'Contact & localisation'**
  String get settingsContact;

  /// No description provided for @settingsContactHint.
  ///
  /// In fr, this message translates to:
  /// **'Adresse, téléphones et position sur la carte.'**
  String get settingsContactHint;

  /// No description provided for @settingsHours.
  ///
  /// In fr, this message translates to:
  /// **'Horaires'**
  String get settingsHours;

  /// No description provided for @settingsHoursHint.
  ///
  /// In fr, this message translates to:
  /// **'Jours et heures d\'ouverture, temps de préparation, fermeture temporaire.'**
  String get settingsHoursHint;

  /// No description provided for @settingsDelivery.
  ///
  /// In fr, this message translates to:
  /// **'Livraison & commandes'**
  String get settingsDelivery;

  /// No description provided for @settingsDeliveryHint.
  ///
  /// In fr, this message translates to:
  /// **'Commandes en ligne, livraison, réservations et page publique.'**
  String get settingsDeliveryHint;

  /// No description provided for @settingsPayments.
  ///
  /// In fr, this message translates to:
  /// **'Paiement & facturation'**
  String get settingsPayments;

  /// No description provided for @settingsPaymentsHint.
  ///
  /// In fr, this message translates to:
  /// **'Modes de paiement, caisses, ticket, factures et pourboires.'**
  String get settingsPaymentsHint;

  /// No description provided for @settingsTeam.
  ///
  /// In fr, this message translates to:
  /// **'Équipe & rôles'**
  String get settingsTeam;

  /// No description provided for @settingsTeamHint.
  ///
  /// In fr, this message translates to:
  /// **'Membres, rôles et invitations.'**
  String get settingsTeamHint;

  /// No description provided for @settingsNotifications.
  ///
  /// In fr, this message translates to:
  /// **'Notifications'**
  String get settingsNotifications;

  /// No description provided for @settingsNotificationsHint.
  ///
  /// In fr, this message translates to:
  /// **'Ce qui vous est signalé dans l\'application.'**
  String get settingsNotificationsHint;

  /// No description provided for @settingsSecurity.
  ///
  /// In fr, this message translates to:
  /// **'Sécurité'**
  String get settingsSecurity;

  /// No description provided for @settingsSecurityHint.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe et appareils connectés.'**
  String get settingsSecurityHint;

  /// No description provided for @restaurantName.
  ///
  /// In fr, this message translates to:
  /// **'Nom du restaurant'**
  String get restaurantName;

  /// No description provided for @sloganLabel.
  ///
  /// In fr, this message translates to:
  /// **'Slogan'**
  String get sloganLabel;

  /// No description provided for @sloganHint.
  ///
  /// In fr, this message translates to:
  /// **'Ex. : Cuisine traditionnelle raffinée'**
  String get sloganHint;

  /// No description provided for @registrationNumber.
  ///
  /// In fr, this message translates to:
  /// **'N° d\'immatriculation'**
  String get registrationNumber;

  /// No description provided for @registrationNumberHint.
  ///
  /// In fr, this message translates to:
  /// **'Registre du commerce de votre pays'**
  String get registrationNumberHint;

  /// No description provided for @logoUpload.
  ///
  /// In fr, this message translates to:
  /// **'Télécharger le logo'**
  String get logoUpload;

  /// No description provided for @logoFormats.
  ///
  /// In fr, this message translates to:
  /// **'PNG, JPG ou WebP — 1 Mo au plus. Idéal : 512 × 512.'**
  String get logoFormats;

  /// No description provided for @logoWhere.
  ///
  /// In fr, this message translates to:
  /// **'Le logo apparaît dans l\'application, sur votre vitrine et sur les tickets de vos clients.'**
  String get logoWhere;

  /// No description provided for @whatsappLabel.
  ///
  /// In fr, this message translates to:
  /// **'Téléphone WhatsApp'**
  String get whatsappLabel;

  /// No description provided for @gpsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Coordonnées GPS / carte'**
  String get gpsTitle;

  /// No description provided for @latitude.
  ///
  /// In fr, this message translates to:
  /// **'Latitude'**
  String get latitude;

  /// No description provided for @longitude.
  ///
  /// In fr, this message translates to:
  /// **'Longitude'**
  String get longitude;

  /// No description provided for @gpsMissing.
  ///
  /// In fr, this message translates to:
  /// **'Position non renseignée'**
  String get gpsMissing;

  /// No description provided for @openInMaps.
  ///
  /// In fr, this message translates to:
  /// **'Ouvrir dans Maps'**
  String get openInMaps;

  /// No description provided for @deliveryZoneLabel.
  ///
  /// In fr, this message translates to:
  /// **'Zone de livraison'**
  String get deliveryZoneLabel;

  /// No description provided for @deliveryZoneHint.
  ///
  /// In fr, this message translates to:
  /// **'Ex. : quartiers desservis ou rayon de 5 km'**
  String get deliveryZoneHint;

  /// No description provided for @vacationMode.
  ///
  /// In fr, this message translates to:
  /// **'Mode vacances'**
  String get vacationMode;

  /// No description provided for @vacationModeHint.
  ///
  /// In fr, this message translates to:
  /// **'Fermer temporairement le restaurant : il apparaît comme fermé pour vos clients.'**
  String get vacationModeHint;

  /// No description provided for @vacationMessage.
  ///
  /// In fr, this message translates to:
  /// **'Message affiché aux clients'**
  String get vacationMessage;

  /// No description provided for @vacationMessageHint.
  ///
  /// In fr, this message translates to:
  /// **'Ex. : Réouverture le 15 septembre'**
  String get vacationMessageHint;

  /// No description provided for @notifSoundNewOrder.
  ///
  /// In fr, this message translates to:
  /// **'Son à chaque nouvelle commande'**
  String get notifSoundNewOrder;

  /// No description provided for @notifSoundReady.
  ///
  /// In fr, this message translates to:
  /// **'Son quand une commande est prête'**
  String get notifSoundReady;

  /// No description provided for @notifLate.
  ///
  /// In fr, this message translates to:
  /// **'Alerte des commandes en retard'**
  String get notifLate;

  /// No description provided for @notifLowStock.
  ///
  /// In fr, this message translates to:
  /// **'Alerte de stock faible'**
  String get notifLowStock;

  /// No description provided for @notifReservations.
  ///
  /// In fr, this message translates to:
  /// **'Rappel des réservations de l\'heure'**
  String get notifReservations;

  /// No description provided for @notifCashGap.
  ///
  /// In fr, this message translates to:
  /// **'Écart de caisse à la clôture'**
  String get notifCashGap;

  /// No description provided for @signedInAs.
  ///
  /// In fr, this message translates to:
  /// **'Connecté en tant que'**
  String get signedInAs;

  /// No description provided for @securityTip.
  ///
  /// In fr, this message translates to:
  /// **'Utilisez un mot de passe unique d\'au moins 8 caractères.'**
  String get securityTip;

  /// No description provided for @signOutOthers.
  ///
  /// In fr, this message translates to:
  /// **'Déconnecter mes autres appareils'**
  String get signOutOthers;

  /// No description provided for @signOutOthersDone.
  ///
  /// In fr, this message translates to:
  /// **'Vos autres appareils sont déconnectés.'**
  String get signOutOthersDone;

  /// No description provided for @signOutAll.
  ///
  /// In fr, this message translates to:
  /// **'Se déconnecter partout'**
  String get signOutAll;

  /// No description provided for @fileTooBig.
  ///
  /// In fr, this message translates to:
  /// **'{name} est trop volumineux.'**
  String fileTooBig(String name);

  /// No description provided for @adsCreate.
  ///
  /// In fr, this message translates to:
  /// **'Créer une pub'**
  String get adsCreate;

  /// No description provided for @adsEdit.
  ///
  /// In fr, this message translates to:
  /// **'Modifier la pub'**
  String get adsEdit;

  /// No description provided for @adsCampaigns.
  ///
  /// In fr, this message translates to:
  /// **'Mes campagnes'**
  String get adsCampaigns;

  /// No description provided for @adsLibrary.
  ///
  /// In fr, this message translates to:
  /// **'Bibliothèque'**
  String get adsLibrary;

  /// No description provided for @adsStats.
  ///
  /// In fr, this message translates to:
  /// **'Statistiques'**
  String get adsStats;

  /// No description provided for @adsCreateTitle.
  ///
  /// In fr, this message translates to:
  /// **'Créer'**
  String get adsCreateTitle;

  /// No description provided for @adsCreateHint.
  ///
  /// In fr, this message translates to:
  /// **'Choisissez le format de votre publicité.'**
  String get adsCreateHint;

  /// No description provided for @adsContent.
  ///
  /// In fr, this message translates to:
  /// **'Contenu'**
  String get adsContent;

  /// No description provided for @adsBudgetTargeting.
  ///
  /// In fr, this message translates to:
  /// **'Budget & ciblage'**
  String get adsBudgetTargeting;

  /// No description provided for @adsPreview.
  ///
  /// In fr, this message translates to:
  /// **'Aperçu'**
  String get adsPreview;

  /// No description provided for @adsPreviewHint.
  ///
  /// In fr, this message translates to:
  /// **'Prévisualisation sur mobile'**
  String get adsPreviewHint;

  /// No description provided for @adsPreviewSimulation.
  ///
  /// In fr, this message translates to:
  /// **'Cet aperçu est une simulation.'**
  String get adsPreviewSimulation;

  /// No description provided for @adsFromLibrary.
  ///
  /// In fr, this message translates to:
  /// **'Depuis la bibliothèque'**
  String get adsFromLibrary;

  /// No description provided for @adsUpload.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter des photos ou des vidéos'**
  String get adsUpload;

  /// No description provided for @adsUploadHint.
  ///
  /// In fr, this message translates to:
  /// **'JPG, PNG, WebP (5 Mo) · MP4, WebM, MOV (50 Mo) · vidéos de 15 à 30 secondes conseillées'**
  String get adsUploadHint;

  /// No description provided for @adsLibraryEmpty.
  ///
  /// In fr, this message translates to:
  /// **'La bibliothèque est vide.'**
  String get adsLibraryEmpty;

  /// No description provided for @adsDeleteFile.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer ce fichier de la bibliothèque ?'**
  String get adsDeleteFile;

  /// No description provided for @adsEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucune campagne pour le moment.'**
  String get adsEmpty;

  /// No description provided for @adsEmptyHint.
  ///
  /// In fr, this message translates to:
  /// **'Créez votre première publicité : une vidéo, une story de 24 h ou un plat mis en avant.'**
  String get adsEmptyHint;

  /// No description provided for @adsActiveCampaigns.
  ///
  /// In fr, this message translates to:
  /// **'Campagnes'**
  String get adsActiveCampaigns;

  /// No description provided for @adsCampaignCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{aucune active} =1{1 active} other{{count} actives}}'**
  String adsCampaignCount(int count);

  /// No description provided for @adFormat.
  ///
  /// In fr, this message translates to:
  /// **'Format'**
  String get adFormat;

  /// No description provided for @adFormatVideo.
  ///
  /// In fr, this message translates to:
  /// **'Vidéo 15–30 s'**
  String get adFormatVideo;

  /// No description provided for @adFormatVideoHint.
  ///
  /// In fr, this message translates to:
  /// **'Vidéo courte pour capter l\'attention'**
  String get adFormatVideoHint;

  /// No description provided for @adFormatCarousel.
  ///
  /// In fr, this message translates to:
  /// **'Photo carrousel'**
  String get adFormatCarousel;

  /// No description provided for @adFormatCarouselHint.
  ///
  /// In fr, this message translates to:
  /// **'Plusieurs images à faire défiler'**
  String get adFormatCarouselHint;

  /// No description provided for @adFormatStory.
  ///
  /// In fr, this message translates to:
  /// **'Story 24 h'**
  String get adFormatStory;

  /// No description provided for @adFormatStoryHint.
  ///
  /// In fr, this message translates to:
  /// **'Format éphémère de 24 heures'**
  String get adFormatStoryHint;

  /// No description provided for @adFormatSponsoredMenu.
  ///
  /// In fr, this message translates to:
  /// **'Menu sponsorisé'**
  String get adFormatSponsoredMenu;

  /// No description provided for @adFormatSponsoredMenuHint.
  ///
  /// In fr, this message translates to:
  /// **'Mettre vos plats en avant'**
  String get adFormatSponsoredMenuHint;

  /// No description provided for @adFormatPush.
  ///
  /// In fr, this message translates to:
  /// **'Notification'**
  String get adFormatPush;

  /// No description provided for @adFormatPushHint.
  ///
  /// In fr, this message translates to:
  /// **'Prévenir vos clients directement'**
  String get adFormatPushHint;

  /// No description provided for @adFormatClassified.
  ///
  /// In fr, this message translates to:
  /// **'Petite annonce'**
  String get adFormatClassified;

  /// No description provided for @adFormatClassifiedHint.
  ///
  /// In fr, this message translates to:
  /// **'Annonce texte simple et efficace'**
  String get adFormatClassifiedHint;

  /// No description provided for @adTitle.
  ///
  /// In fr, this message translates to:
  /// **'Titre'**
  String get adTitle;

  /// No description provided for @adTitleHint.
  ///
  /// In fr, this message translates to:
  /// **'Ex. : Croissant au beurre'**
  String get adTitleHint;

  /// No description provided for @adTitleRequired.
  ///
  /// In fr, this message translates to:
  /// **'Donnez un titre à votre publicité.'**
  String get adTitleRequired;

  /// No description provided for @adText.
  ///
  /// In fr, this message translates to:
  /// **'Texte'**
  String get adText;

  /// No description provided for @adTextHint.
  ///
  /// In fr, this message translates to:
  /// **'Ex. : Nouveau ! Croissant artisanal fait maison, -20 % ce soir uniquement'**
  String get adTextHint;

  /// No description provided for @adMediaHelp.
  ///
  /// In fr, this message translates to:
  /// **'Photos ou vidéos de la publicité (10 au plus).'**
  String get adMediaHelp;

  /// No description provided for @adVideoHelp.
  ///
  /// In fr, this message translates to:
  /// **'Ajoutez une vidéo courte (15 à 30 secondes).'**
  String get adVideoHelp;

  /// No description provided for @adChooseItems.
  ///
  /// In fr, this message translates to:
  /// **'Plats mis en avant'**
  String get adChooseItems;

  /// No description provided for @adCta.
  ///
  /// In fr, this message translates to:
  /// **'Bouton'**
  String get adCta;

  /// No description provided for @adCtaHint.
  ///
  /// In fr, this message translates to:
  /// **'Ex. : Commander maintenant'**
  String get adCtaHint;

  /// No description provided for @adCtaDefault.
  ///
  /// In fr, this message translates to:
  /// **'Commander maintenant'**
  String get adCtaDefault;

  /// No description provided for @adLink.
  ///
  /// In fr, this message translates to:
  /// **'Lien du bouton (facultatif)'**
  String get adLink;

  /// No description provided for @adDailyBudget.
  ///
  /// In fr, this message translates to:
  /// **'Budget journalier'**
  String get adDailyBudget;

  /// No description provided for @adBudgetNote.
  ///
  /// In fr, this message translates to:
  /// **'Budget prévu : la diffusion sponsorisée sera facturée par la plateforme.'**
  String get adBudgetNote;

  /// No description provided for @adStart.
  ///
  /// In fr, this message translates to:
  /// **'Début'**
  String get adStart;

  /// No description provided for @adEnd.
  ///
  /// In fr, this message translates to:
  /// **'Fin'**
  String get adEnd;

  /// No description provided for @adStory24h.
  ///
  /// In fr, this message translates to:
  /// **'Visible 24 heures'**
  String get adStory24h;

  /// No description provided for @adTargetAreas.
  ///
  /// In fr, this message translates to:
  /// **'Ciblage par quartier'**
  String get adTargetAreas;

  /// No description provided for @adAddArea.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un quartier'**
  String get adAddArea;

  /// No description provided for @adMoments.
  ///
  /// In fr, this message translates to:
  /// **'Moment'**
  String get adMoments;

  /// No description provided for @momentMorning.
  ///
  /// In fr, this message translates to:
  /// **'Matin'**
  String get momentMorning;

  /// No description provided for @momentNoon.
  ///
  /// In fr, this message translates to:
  /// **'Midi'**
  String get momentNoon;

  /// No description provided for @momentAfternoon.
  ///
  /// In fr, this message translates to:
  /// **'Après-midi'**
  String get momentAfternoon;

  /// No description provided for @momentEvening.
  ///
  /// In fr, this message translates to:
  /// **'Soir'**
  String get momentEvening;

  /// No description provided for @momentNight.
  ///
  /// In fr, this message translates to:
  /// **'Nuit'**
  String get momentNight;

  /// No description provided for @adBranches.
  ///
  /// In fr, this message translates to:
  /// **'Établissements'**
  String get adBranches;

  /// No description provided for @adSaveDraft.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer le brouillon'**
  String get adSaveDraft;

  /// No description provided for @adPublish.
  ///
  /// In fr, this message translates to:
  /// **'Publier'**
  String get adPublish;

  /// No description provided for @adPublished.
  ///
  /// In fr, this message translates to:
  /// **'Publicité publiée.'**
  String get adPublished;

  /// No description provided for @adSponsored.
  ///
  /// In fr, this message translates to:
  /// **'Sponsorisé'**
  String get adSponsored;

  /// No description provided for @adStatusActive.
  ///
  /// In fr, this message translates to:
  /// **'Active'**
  String get adStatusActive;

  /// No description provided for @adStatusScheduled.
  ///
  /// In fr, this message translates to:
  /// **'Programmée'**
  String get adStatusScheduled;

  /// No description provided for @adStatusPaused.
  ///
  /// In fr, this message translates to:
  /// **'En pause'**
  String get adStatusPaused;

  /// No description provided for @adStatusEnded.
  ///
  /// In fr, this message translates to:
  /// **'Terminée'**
  String get adStatusEnded;

  /// No description provided for @adStatusDraft.
  ///
  /// In fr, this message translates to:
  /// **'Brouillon'**
  String get adStatusDraft;

  /// No description provided for @adRoi.
  ///
  /// In fr, this message translates to:
  /// **'Chiffre d\'affaires généré'**
  String get adRoi;

  /// No description provided for @adRoiDetail.
  ///
  /// In fr, this message translates to:
  /// **'pour {amount} de budget engagé'**
  String adRoiDetail(String amount);

  /// No description provided for @adViews.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{0 vue} =1{1 vue} other{{count} vues}}'**
  String adViews(int count);

  /// No description provided for @adOrders.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{0 commande} =1{1 commande} other{{count} commandes}}'**
  String adOrders(int count);

  /// No description provided for @adDetails.
  ///
  /// In fr, this message translates to:
  /// **'Voir détails'**
  String get adDetails;

  /// No description provided for @adBoost.
  ///
  /// In fr, this message translates to:
  /// **'Booster'**
  String get adBoost;

  /// No description provided for @adBoostTitle.
  ///
  /// In fr, this message translates to:
  /// **'Prolonger la diffusion'**
  String get adBoostTitle;

  /// No description provided for @adBoostDays.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{1 jour de plus} other{{count} jours de plus}}'**
  String adBoostDays(int count);

  /// No description provided for @adBoosted.
  ///
  /// In fr, this message translates to:
  /// **'Campagne prolongée.'**
  String get adBoosted;

  /// No description provided for @adPause.
  ///
  /// In fr, this message translates to:
  /// **'Mettre en pause'**
  String get adPause;

  /// No description provided for @adResume.
  ///
  /// In fr, this message translates to:
  /// **'Relancer'**
  String get adResume;

  /// No description provided for @adEndNow.
  ///
  /// In fr, this message translates to:
  /// **'Terminer maintenant'**
  String get adEndNow;

  /// No description provided for @adDeleteConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer cette campagne et ses statistiques ?'**
  String get adDeleteConfirm;

  /// No description provided for @adStatViews.
  ///
  /// In fr, this message translates to:
  /// **'Vues'**
  String get adStatViews;

  /// No description provided for @adStatClicks.
  ///
  /// In fr, this message translates to:
  /// **'Clics'**
  String get adStatClicks;

  /// No description provided for @adStatClickRate.
  ///
  /// In fr, this message translates to:
  /// **'Taux de clic'**
  String get adStatClickRate;

  /// No description provided for @adStatOrders.
  ///
  /// In fr, this message translates to:
  /// **'Commandes'**
  String get adStatOrders;

  /// No description provided for @adStatRevenue.
  ///
  /// In fr, this message translates to:
  /// **'Chiffre d\'affaires'**
  String get adStatRevenue;

  /// No description provided for @adStatByCampaign.
  ///
  /// In fr, this message translates to:
  /// **'Vues par campagne'**
  String get adStatByCampaign;

  /// No description provided for @activeLabel.
  ///
  /// In fr, this message translates to:
  /// **'Actif'**
  String get activeLabel;

  /// No description provided for @addPhotos.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter des photos'**
  String get addPhotos;

  /// No description provided for @addProduct.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un produit'**
  String get addProduct;

  /// No description provided for @allItems.
  ///
  /// In fr, this message translates to:
  /// **'Tous'**
  String get allItems;

  /// No description provided for @available.
  ///
  /// In fr, this message translates to:
  /// **'Disponible'**
  String get available;

  /// No description provided for @categories.
  ///
  /// In fr, this message translates to:
  /// **'Catégories'**
  String get categories;

  /// No description provided for @copySuffix.
  ///
  /// In fr, this message translates to:
  /// **'copie'**
  String get copySuffix;

  /// No description provided for @customerSideView.
  ///
  /// In fr, this message translates to:
  /// **'Aperçu côté client — apparence dans le menu du restaurant'**
  String get customerSideView;

  /// No description provided for @duplicate.
  ///
  /// In fr, this message translates to:
  /// **'Dupliquer'**
  String get duplicate;

  /// No description provided for @everyDay.
  ///
  /// In fr, this message translates to:
  /// **'Tous les jours'**
  String get everyDay;

  /// No description provided for @filterKind.
  ///
  /// In fr, this message translates to:
  /// **'Famille'**
  String get filterKind;

  /// No description provided for @itemDescriptionHint.
  ///
  /// In fr, this message translates to:
  /// **'Ex. : Feuilles de ndolé aux arachides, crevettes et plantain'**
  String get itemDescriptionHint;

  /// No description provided for @itemDuplicated.
  ///
  /// In fr, this message translates to:
  /// **'Article dupliqué : la copie est masquée jusqu\'à son enregistrement.'**
  String get itemDuplicated;

  /// No description provided for @livePreview.
  ///
  /// In fr, this message translates to:
  /// **'Aperçu en direct'**
  String get livePreview;

  /// No description provided for @mainPhoto.
  ///
  /// In fr, this message translates to:
  /// **'Principale'**
  String get mainPhoto;

  /// No description provided for @makeMainPhoto.
  ///
  /// In fr, this message translates to:
  /// **'Mettre en photo principale'**
  String get makeMainPhoto;

  /// No description provided for @markAvailable.
  ///
  /// In fr, this message translates to:
  /// **'Remettre disponible'**
  String get markAvailable;

  /// No description provided for @markSoldOut.
  ///
  /// In fr, this message translates to:
  /// **'Marquer en rupture'**
  String get markSoldOut;

  /// No description provided for @menuProducts.
  ///
  /// In fr, this message translates to:
  /// **'Produits du menu'**
  String get menuProducts;

  /// No description provided for @noProductsFound.
  ///
  /// In fr, this message translates to:
  /// **'Aucun produit ne correspond.'**
  String get noProductsFound;

  /// No description provided for @photosHint.
  ///
  /// In fr, this message translates to:
  /// **'Jusqu\'à {count} photos · JPG, PNG, WebP · 5 Mo max'**
  String photosHint(int count);

  /// No description provided for @play.
  ///
  /// In fr, this message translates to:
  /// **'Lire'**
  String get play;

  /// No description provided for @prepMinutesShort.
  ///
  /// In fr, this message translates to:
  /// **'Préparation : {minutes} min'**
  String prepMinutesShort(int minutes);

  /// No description provided for @prepTime.
  ///
  /// In fr, this message translates to:
  /// **'Temps de préparation'**
  String get prepTime;

  /// No description provided for @productInfo.
  ///
  /// In fr, this message translates to:
  /// **'Informations du produit'**
  String get productInfo;

  /// No description provided for @productPhotos.
  ///
  /// In fr, this message translates to:
  /// **'Photos du produit'**
  String get productPhotos;

  /// No description provided for @productsCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Aucun produit} =1{1 produit} other{{count} produits}}'**
  String productsCount(int count);

  /// No description provided for @publish.
  ///
  /// In fr, this message translates to:
  /// **'Publier'**
  String get publish;

  /// No description provided for @replace.
  ///
  /// In fr, this message translates to:
  /// **'Remplacer'**
  String get replace;

  /// No description provided for @saleDays.
  ///
  /// In fr, this message translates to:
  /// **'Jours de vente'**
  String get saleDays;

  /// No description provided for @saleDaysRequired.
  ///
  /// In fr, this message translates to:
  /// **'Choisissez au moins un jour de vente.'**
  String get saleDaysRequired;

  /// No description provided for @searchProduct.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher un produit, un plat…'**
  String get searchProduct;

  /// No description provided for @sizesLabel.
  ///
  /// In fr, this message translates to:
  /// **'Tailles'**
  String get sizesLabel;

  /// No description provided for @sortBy.
  ///
  /// In fr, this message translates to:
  /// **'Trier'**
  String get sortBy;

  /// No description provided for @sortMenuOrder.
  ///
  /// In fr, this message translates to:
  /// **'Ordre du menu'**
  String get sortMenuOrder;

  /// No description provided for @sortName.
  ///
  /// In fr, this message translates to:
  /// **'Nom'**
  String get sortName;

  /// No description provided for @sortPriceAsc.
  ///
  /// In fr, this message translates to:
  /// **'Prix croissant'**
  String get sortPriceAsc;

  /// No description provided for @sortPriceDesc.
  ///
  /// In fr, this message translates to:
  /// **'Prix décroissant'**
  String get sortPriceDesc;

  /// No description provided for @stockAlertThreshold.
  ///
  /// In fr, this message translates to:
  /// **'Alerte en dessous de'**
  String get stockAlertThreshold;

  /// No description provided for @stockAndTime.
  ///
  /// In fr, this message translates to:
  /// **'Stock & temps'**
  String get stockAndTime;

  /// No description provided for @stockLeft.
  ///
  /// In fr, this message translates to:
  /// **'Stock : {count} restants'**
  String stockLeft(int count);

  /// No description provided for @stockLow.
  ///
  /// In fr, this message translates to:
  /// **'Stock faible : {count} restants'**
  String stockLow(int count);

  /// No description provided for @stockNotTracked.
  ///
  /// In fr, this message translates to:
  /// **'Vide = non suivi'**
  String get stockNotTracked;

  /// No description provided for @stockOfDay.
  ///
  /// In fr, this message translates to:
  /// **'Stock du jour'**
  String get stockOfDay;

  /// No description provided for @stockOfDayHint.
  ///
  /// In fr, this message translates to:
  /// **'Nombre de portions disponibles aujourd\'hui. Il baisse à chaque commande ; à zéro, l\'article passe en rupture. Laissez vide pour ne pas suivre.'**
  String get stockOfDayHint;

  /// No description provided for @stockQuantity.
  ///
  /// In fr, this message translates to:
  /// **'Quantité en stock'**
  String get stockQuantity;

  /// No description provided for @supplementsLabel.
  ///
  /// In fr, this message translates to:
  /// **'Suppléments'**
  String get supplementsLabel;

  /// No description provided for @videoAdded.
  ///
  /// In fr, this message translates to:
  /// **'Vidéo de présentation ajoutée'**
  String get videoAdded;

  /// No description provided for @videoOptional.
  ///
  /// In fr, this message translates to:
  /// **'Vidéo de présentation (facultatif, 30 s environ)'**
  String get videoOptional;

  /// No description provided for @allChannels.
  ///
  /// In fr, this message translates to:
  /// **'Tous les canaux'**
  String get allChannels;

  /// No description provided for @amountLabel.
  ///
  /// In fr, this message translates to:
  /// **'Montant'**
  String get amountLabel;

  /// No description provided for @averageTicketShort.
  ///
  /// In fr, this message translates to:
  /// **'Panier moyen {amount}'**
  String averageTicketShort(String amount);

  /// No description provided for @customerLabel.
  ///
  /// In fr, this message translates to:
  /// **'Client'**
  String get customerLabel;

  /// No description provided for @financialResult.
  ///
  /// In fr, this message translates to:
  /// **'Résultat financier'**
  String get financialResult;

  /// No description provided for @inKitchenCount.
  ///
  /// In fr, this message translates to:
  /// **'en préparation'**
  String get inKitchenCount;

  /// No description provided for @inProgressCount.
  ///
  /// In fr, this message translates to:
  /// **'en cours'**
  String get inProgressCount;

  /// No description provided for @itemsLabel.
  ///
  /// In fr, this message translates to:
  /// **'Articles :'**
  String get itemsLabel;

  /// No description provided for @lateCount.
  ///
  /// In fr, this message translates to:
  /// **'en retard'**
  String get lateCount;

  /// No description provided for @noOrdersHere.
  ///
  /// In fr, this message translates to:
  /// **'Aucune commande ici'**
  String get noOrdersHere;

  /// No description provided for @noSalesYet.
  ///
  /// In fr, this message translates to:
  /// **'Pas encore de ventes sur la période.'**
  String get noSalesYet;

  /// No description provided for @nothingToCollectHint.
  ///
  /// In fr, this message translates to:
  /// **'Aucune opération en attente : les nouveaux encaissements apparaîtront ici.'**
  String get nothingToCollectHint;

  /// No description provided for @orderLabel.
  ///
  /// In fr, this message translates to:
  /// **'Commande'**
  String get orderLabel;

  /// No description provided for @paymentLabel.
  ///
  /// In fr, this message translates to:
  /// **'Paiement'**
  String get paymentLabel;

  /// No description provided for @periodLabel.
  ///
  /// In fr, this message translates to:
  /// **'Période'**
  String get periodLabel;

  /// No description provided for @recentTransactions.
  ///
  /// In fr, this message translates to:
  /// **'Transactions récentes'**
  String get recentTransactions;

  /// No description provided for @salesOfPeriod.
  ///
  /// In fr, this message translates to:
  /// **'CA de la période'**
  String get salesOfPeriod;

  /// No description provided for @salesSplit.
  ///
  /// In fr, this message translates to:
  /// **'Répartition des ventes'**
  String get salesSplit;

  /// No description provided for @timeLabel.
  ///
  /// In fr, this message translates to:
  /// **'Heure'**
  String get timeLabel;

  /// No description provided for @topDishes.
  ///
  /// In fr, this message translates to:
  /// **'Top plats'**
  String get topDishes;

  /// No description provided for @viewDetails.
  ///
  /// In fr, this message translates to:
  /// **'Voir détails'**
  String get viewDetails;

  /// No description provided for @vsPrevious.
  ///
  /// In fr, this message translates to:
  /// **'Période précédente : {amount}'**
  String vsPrevious(String amount);

  /// No description provided for @addAddress.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter une adresse'**
  String get addAddress;

  /// No description provided for @addedToCart.
  ///
  /// In fr, this message translates to:
  /// **'Ajouté au panier.'**
  String get addedToCart;

  /// No description provided for @addressLabel.
  ///
  /// In fr, this message translates to:
  /// **'Nom de l\'adresse'**
  String get addressLabel;

  /// No description provided for @addressLabelHint.
  ///
  /// In fr, this message translates to:
  /// **'Ex. : Maison, Bureau'**
  String get addressLabelHint;

  /// No description provided for @addToCart.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter au panier'**
  String get addToCart;

  /// No description provided for @allCities.
  ///
  /// In fr, this message translates to:
  /// **'Toutes les villes'**
  String get allCities;

  /// No description provided for @allRestaurants.
  ///
  /// In fr, this message translates to:
  /// **'Tous les restaurants'**
  String get allRestaurants;

  /// No description provided for @birthday.
  ///
  /// In fr, this message translates to:
  /// **'Date d\'anniversaire'**
  String get birthday;

  /// No description provided for @cartEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Votre panier est vide.'**
  String get cartEmpty;

  /// No description provided for @cartItems.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{1 article} other{{count} articles}}'**
  String cartItems(int count);

  /// No description provided for @changeCity.
  ///
  /// In fr, this message translates to:
  /// **'Modifier'**
  String get changeCity;

  /// No description provided for @chooseCity.
  ///
  /// In fr, this message translates to:
  /// **'Choisir la ville'**
  String get chooseCity;

  /// No description provided for @chooseOptionRequired.
  ///
  /// In fr, this message translates to:
  /// **'Choisissez : {name}'**
  String chooseOptionRequired(String name);

  /// No description provided for @closedNow.
  ///
  /// In fr, this message translates to:
  /// **'Fermé'**
  String get closedNow;

  /// No description provided for @customerFavorites.
  ///
  /// In fr, this message translates to:
  /// **'Favoris'**
  String get customerFavorites;

  /// No description provided for @customerHome.
  ///
  /// In fr, this message translates to:
  /// **'Accueil'**
  String get customerHome;

  /// No description provided for @customerOrders.
  ///
  /// In fr, this message translates to:
  /// **'Commandes'**
  String get customerOrders;

  /// No description provided for @customerProfile.
  ///
  /// In fr, this message translates to:
  /// **'Profil'**
  String get customerProfile;

  /// No description provided for @customerReviews.
  ///
  /// In fr, this message translates to:
  /// **'Avis clients ({count})'**
  String customerReviews(int count);

  /// No description provided for @customerSearch.
  ///
  /// In fr, this message translates to:
  /// **'Recherche'**
  String get customerSearch;

  /// No description provided for @customerSpaceLink.
  ///
  /// In fr, this message translates to:
  /// **'Espace client · commander'**
  String get customerSpaceLink;

  /// No description provided for @deliveryDetailsRequired.
  ///
  /// In fr, this message translates to:
  /// **'Indiquez l\'adresse de livraison et un téléphone.'**
  String get deliveryDetailsRequired;

  /// No description provided for @directions.
  ///
  /// In fr, this message translates to:
  /// **'Itinéraire'**
  String get directions;

  /// No description provided for @discoverRestaurants.
  ///
  /// In fr, this message translates to:
  /// **'Découvrir des restaurants'**
  String get discoverRestaurants;

  /// No description provided for @dishes.
  ///
  /// In fr, this message translates to:
  /// **'Plats'**
  String get dishes;

  /// No description provided for @favoritesSignIn.
  ///
  /// In fr, this message translates to:
  /// **'Connectez-vous pour retrouver vos restaurants préférés.'**
  String get favoritesSignIn;

  /// No description provided for @fullName.
  ///
  /// In fr, this message translates to:
  /// **'Nom et prénom'**
  String get fullName;

  /// No description provided for @globalCatalog.
  ///
  /// In fr, this message translates to:
  /// **'Catalogue global'**
  String get globalCatalog;

  /// No description provided for @healthAllergies.
  ///
  /// In fr, this message translates to:
  /// **'Santé & allergies'**
  String get healthAllergies;

  /// No description provided for @howDoYouWant.
  ///
  /// In fr, this message translates to:
  /// **'Comment souhaitez-vous être servi ?'**
  String get howDoYouWant;

  /// No description provided for @loyaltyNextReward.
  ///
  /// In fr, this message translates to:
  /// **'Prochaine récompense à {points} points : {amount}'**
  String loyaltyNextReward(int points, String amount);

  /// No description provided for @loyaltyPoints.
  ///
  /// In fr, this message translates to:
  /// **'{count} points'**
  String loyaltyPoints(int count);

  /// No description provided for @loyaltyProgram.
  ///
  /// In fr, this message translates to:
  /// **'Programme fidélité'**
  String get loyaltyProgram;

  /// No description provided for @mapCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{1 établissement sur la carte} other{{count} établissements sur la carte}}'**
  String mapCount(int count);

  /// No description provided for @mapView.
  ///
  /// In fr, this message translates to:
  /// **'Carte'**
  String get mapView;

  /// No description provided for @minimumOrderNotReached.
  ///
  /// In fr, this message translates to:
  /// **'Commande minimum : {amount}'**
  String minimumOrderNotReached(String amount);

  /// No description provided for @minutesRange.
  ///
  /// In fr, this message translates to:
  /// **'{min}–{max} min'**
  String minutesRange(int min, int max);

  /// No description provided for @myAddresses.
  ///
  /// In fr, this message translates to:
  /// **'Mes adresses'**
  String get myAddresses;

  /// No description provided for @myCart.
  ///
  /// In fr, this message translates to:
  /// **'Mon panier'**
  String get myCart;

  /// No description provided for @newRestaurant.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau'**
  String get newRestaurant;

  /// No description provided for @noAddresses.
  ///
  /// In fr, this message translates to:
  /// **'Aucune adresse enregistrée.'**
  String get noAddresses;

  /// No description provided for @noCustomerOrders.
  ///
  /// In fr, this message translates to:
  /// **'Vous n\'avez pas encore commandé.'**
  String get noCustomerOrders;

  /// No description provided for @noFavorites.
  ///
  /// In fr, this message translates to:
  /// **'Aucun favori pour le moment.'**
  String get noFavorites;

  /// No description provided for @noFavoritesHint.
  ///
  /// In fr, this message translates to:
  /// **'Touchez le cœur d\'un restaurant pour l\'ajouter.'**
  String get noFavoritesHint;

  /// No description provided for @noLoyaltyYet.
  ///
  /// In fr, this message translates to:
  /// **'Vos points apparaîtront après vos premières commandes.'**
  String get noLoyaltyYet;

  /// No description provided for @noRestaurantsYet.
  ///
  /// In fr, this message translates to:
  /// **'Aucun restaurant publié dans cette ville pour le moment.'**
  String get noRestaurantsYet;

  /// No description provided for @noteForKitchen.
  ///
  /// In fr, this message translates to:
  /// **'Précision pour la cuisine (facultatif)'**
  String get noteForKitchen;

  /// No description provided for @noteForKitchenHint.
  ///
  /// In fr, this message translates to:
  /// **'Ex. : sans piment, bien cuit'**
  String get noteForKitchenHint;

  /// No description provided for @notifOrderUpdates.
  ///
  /// In fr, this message translates to:
  /// **'Suivi de mes commandes'**
  String get notifOrderUpdates;

  /// No description provided for @notifPromotions.
  ///
  /// In fr, this message translates to:
  /// **'Promotions & offres'**
  String get notifPromotions;

  /// No description provided for @notifReservationReminders.
  ///
  /// In fr, this message translates to:
  /// **'Rappels de réservation'**
  String get notifReservationReminders;

  /// No description provided for @onlineOrdersUnavailable.
  ///
  /// In fr, this message translates to:
  /// **'Commande en ligne indisponible pour le moment'**
  String get onlineOrdersUnavailable;

  /// No description provided for @openFullMap.
  ///
  /// In fr, this message translates to:
  /// **'Ouvrir la carte en plein écran'**
  String get openFullMap;

  /// No description provided for @openNow.
  ///
  /// In fr, this message translates to:
  /// **'Ouvert'**
  String get openNow;

  /// No description provided for @orderDone.
  ///
  /// In fr, this message translates to:
  /// **'Terminée'**
  String get orderDone;

  /// No description provided for @orderingAtTable.
  ///
  /// In fr, this message translates to:
  /// **'Commande à la table {table}'**
  String orderingAtTable(String table);

  /// No description provided for @orderInProgress.
  ///
  /// In fr, this message translates to:
  /// **'En cours'**
  String get orderInProgress;

  /// No description provided for @orderNoteOptional.
  ///
  /// In fr, this message translates to:
  /// **'Message pour le restaurant (facultatif)'**
  String get orderNoteOptional;

  /// No description provided for @orderRejected.
  ///
  /// In fr, this message translates to:
  /// **'Refusée par le restaurant'**
  String get orderRejected;

  /// No description provided for @orderSentToRestaurant.
  ///
  /// In fr, this message translates to:
  /// **'Commande envoyée ! Le restaurant va la confirmer : suivez-la ici en direct.'**
  String get orderSentToRestaurant;

  /// No description provided for @ordersSignIn.
  ///
  /// In fr, this message translates to:
  /// **'Connectez-vous pour suivre vos commandes.'**
  String get ordersSignIn;

  /// No description provided for @orderSummary.
  ///
  /// In fr, this message translates to:
  /// **'Récapitulatif'**
  String get orderSummary;

  /// No description provided for @orderWaitingConfirmation.
  ///
  /// In fr, this message translates to:
  /// **'En attente de confirmation'**
  String get orderWaitingConfirmation;

  /// No description provided for @payMobileWallet.
  ///
  /// In fr, this message translates to:
  /// **'Portefeuille mobile'**
  String get payMobileWallet;

  /// No description provided for @personalProfile.
  ///
  /// In fr, this message translates to:
  /// **'Profil personnel'**
  String get personalProfile;

  /// No description provided for @personalProfileHint.
  ///
  /// In fr, this message translates to:
  /// **'Vos informations personnelles et vos préférences.'**
  String get personalProfileHint;

  /// No description provided for @placeOrder.
  ///
  /// In fr, this message translates to:
  /// **'Commander'**
  String get placeOrder;

  /// No description provided for @preferences.
  ///
  /// In fr, this message translates to:
  /// **'Préférences'**
  String get preferences;

  /// No description provided for @preferredPayment.
  ///
  /// In fr, this message translates to:
  /// **'Paiement préféré'**
  String get preferredPayment;

  /// No description provided for @preferredPaymentHint.
  ///
  /// In fr, this message translates to:
  /// **'Indicatif : aucun numéro de carte ni de compte n\'est enregistré.'**
  String get preferredPaymentHint;

  /// No description provided for @productDetails.
  ///
  /// In fr, this message translates to:
  /// **'Détails du produit'**
  String get productDetails;

  /// No description provided for @profileSignIn.
  ///
  /// In fr, this message translates to:
  /// **'Connectez-vous pour gérer votre profil, vos adresses et vos points.'**
  String get profileSignIn;

  /// No description provided for @rateOrder.
  ///
  /// In fr, this message translates to:
  /// **'Noter ma commande'**
  String get rateOrder;

  /// No description provided for @requiredLabel.
  ///
  /// In fr, this message translates to:
  /// **'Obligatoire'**
  String get requiredLabel;

  /// No description provided for @restaurantOnVacation.
  ///
  /// In fr, this message translates to:
  /// **'Le restaurant est fermé temporairement.'**
  String get restaurantOnVacation;

  /// No description provided for @restaurants.
  ///
  /// In fr, this message translates to:
  /// **'Restaurants'**
  String get restaurants;

  /// No description provided for @restaurantSpace.
  ///
  /// In fr, this message translates to:
  /// **'Espace restaurant'**
  String get restaurantSpace;

  /// No description provided for @restaurantUnavailable.
  ///
  /// In fr, this message translates to:
  /// **'Ce restaurant n\'est pas disponible.'**
  String get restaurantUnavailable;

  /// No description provided for @reviewComment.
  ///
  /// In fr, this message translates to:
  /// **'Votre avis (facultatif)'**
  String get reviewComment;

  /// No description provided for @reviewsCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{aucun avis} =1{1 avis} other{{count} avis}}'**
  String reviewsCount(int count);

  /// No description provided for @searchRestaurantsHint.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher restaurants, plats, cuisines…'**
  String get searchRestaurantsHint;

  /// No description provided for @seeAll.
  ///
  /// In fr, this message translates to:
  /// **'Voir tout'**
  String get seeAll;

  /// No description provided for @send.
  ///
  /// In fr, this message translates to:
  /// **'Envoyer'**
  String get send;

  /// No description provided for @signInToContinue.
  ///
  /// In fr, this message translates to:
  /// **'Connectez-vous pour continuer'**
  String get signInToContinue;

  /// No description provided for @spiceHot.
  ///
  /// In fr, this message translates to:
  /// **'Fort'**
  String get spiceHot;

  /// No description provided for @spiceLevel.
  ///
  /// In fr, this message translates to:
  /// **'Piment'**
  String get spiceLevel;

  /// No description provided for @spiceMedium.
  ///
  /// In fr, this message translates to:
  /// **'Moyen'**
  String get spiceMedium;

  /// No description provided for @spiceMild.
  ///
  /// In fr, this message translates to:
  /// **'Doux'**
  String get spiceMild;

  /// No description provided for @spiceNone.
  ///
  /// In fr, this message translates to:
  /// **'Sans'**
  String get spiceNone;

  /// No description provided for @sponsoredAds.
  ///
  /// In fr, this message translates to:
  /// **'Publicités sponsorisées'**
  String get sponsoredAds;

  /// No description provided for @stepAccepted.
  ///
  /// In fr, this message translates to:
  /// **'Acceptée par le restaurant'**
  String get stepAccepted;

  /// No description provided for @stepDone.
  ///
  /// In fr, this message translates to:
  /// **'Terminée'**
  String get stepDone;

  /// No description provided for @stepPreparing.
  ///
  /// In fr, this message translates to:
  /// **'En préparation'**
  String get stepPreparing;

  /// No description provided for @stepReady.
  ///
  /// In fr, this message translates to:
  /// **'Prête'**
  String get stepReady;

  /// No description provided for @stepSent.
  ///
  /// In fr, this message translates to:
  /// **'Envoyée'**
  String get stepSent;

  /// No description provided for @storyLabel.
  ///
  /// In fr, this message translates to:
  /// **'Histoire'**
  String get storyLabel;

  /// No description provided for @thanksForReview.
  ///
  /// In fr, this message translates to:
  /// **'Merci pour votre avis !'**
  String get thanksForReview;

  /// No description provided for @viewCart.
  ///
  /// In fr, this message translates to:
  /// **'Voir le panier'**
  String get viewCart;

  /// No description provided for @watchVideo.
  ///
  /// In fr, this message translates to:
  /// **'Vidéo'**
  String get watchVideo;

  /// No description provided for @yourName.
  ///
  /// In fr, this message translates to:
  /// **'Votre nom'**
  String get yourName;

  /// No description provided for @gpsHint.
  ///
  /// In fr, this message translates to:
  /// **'« Ouvrir dans Maps » enregistre automatiquement la position où vous vous trouvez : faites-le depuis l\'établissement. Vous pouvez aussi saisir les coordonnées.'**
  String get gpsHint;

  /// No description provided for @locationSaved.
  ///
  /// In fr, this message translates to:
  /// **'Position de l\'établissement enregistrée.'**
  String get locationSaved;

  /// No description provided for @locationServiceDisabled.
  ///
  /// In fr, this message translates to:
  /// **'La localisation de l\'appareil est désactivée : activez-la puis réessayez.'**
  String get locationServiceDisabled;

  /// No description provided for @locationDenied.
  ///
  /// In fr, this message translates to:
  /// **'Accès à la position refusé : autorisez-le dans les réglages du navigateur ou du téléphone.'**
  String get locationDenied;

  /// No description provided for @locationUnavailable.
  ///
  /// In fr, this message translates to:
  /// **'Position introuvable pour le moment : réessayez à l\'extérieur ou saisissez les coordonnées.'**
  String get locationUnavailable;

  /// No description provided for @openMapAction.
  ///
  /// In fr, this message translates to:
  /// **'Ouvrir la carte'**
  String get openMapAction;

  /// No description provided for @customerReviewsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Avis clients'**
  String get customerReviewsTitle;

  /// No description provided for @forYou.
  ///
  /// In fr, this message translates to:
  /// **'Pour vous'**
  String get forYou;

  /// No description provided for @fromAmount.
  ///
  /// In fr, this message translates to:
  /// **'dès {amount}'**
  String fromAmount(String amount);

  /// No description provided for @helpfulCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Utile} other{Utile ({count})}}'**
  String helpfulCount(int count);

  /// No description provided for @hideReview.
  ///
  /// In fr, this message translates to:
  /// **'Masquer l\'avis'**
  String get hideReview;

  /// No description provided for @hideReviewReason.
  ///
  /// In fr, this message translates to:
  /// **'Motif'**
  String get hideReviewReason;

  /// No description provided for @locatedNearYou.
  ///
  /// In fr, this message translates to:
  /// **'Restaurants classés selon votre position'**
  String get locatedNearYou;

  /// No description provided for @locateMe.
  ///
  /// In fr, this message translates to:
  /// **'Me localiser'**
  String get locateMe;

  /// No description provided for @locationRefusedChooseCity.
  ///
  /// In fr, this message translates to:
  /// **'Position non disponible : choisissez votre ville.'**
  String get locationRefusedChooseCity;

  /// No description provided for @nearYouHint.
  ///
  /// In fr, this message translates to:
  /// **'Autorisez la localisation pour voir les restaurants et les plats les plus proches.'**
  String get nearYouHint;

  /// No description provided for @nearYouRestaurants.
  ///
  /// In fr, this message translates to:
  /// **'Près de vous'**
  String get nearYouRestaurants;

  /// No description provided for @nearYouTitle.
  ///
  /// In fr, this message translates to:
  /// **'Les restaurants près de vous'**
  String get nearYouTitle;

  /// No description provided for @newOnMenus.
  ///
  /// In fr, this message translates to:
  /// **'Nouveautés'**
  String get newOnMenus;

  /// No description provided for @noReviewsYet.
  ///
  /// In fr, this message translates to:
  /// **'Pas encore d\'avis'**
  String get noReviewsYet;

  /// No description provided for @openNowTitle.
  ///
  /// In fr, this message translates to:
  /// **'Ouverts maintenant'**
  String get openNowTitle;

  /// No description provided for @orderAgain.
  ///
  /// In fr, this message translates to:
  /// **'Commander à nouveau'**
  String get orderAgain;

  /// No description provided for @orderAgainAction.
  ///
  /// In fr, this message translates to:
  /// **'Recommander'**
  String get orderAgainAction;

  /// No description provided for @ordersInProgressTitle.
  ///
  /// In fr, this message translates to:
  /// **'Vos commandes en cours'**
  String get ordersInProgressTitle;

  /// No description provided for @popularDishes.
  ///
  /// In fr, this message translates to:
  /// **'Plats populaires'**
  String get popularDishes;

  /// No description provided for @popularNearYou.
  ///
  /// In fr, this message translates to:
  /// **'Populaires autour de vous'**
  String get popularNearYou;

  /// No description provided for @promotionsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Promotions'**
  String get promotionsTitle;

  /// No description provided for @publishReview.
  ///
  /// In fr, this message translates to:
  /// **'Publier mon avis'**
  String get publishReview;

  /// No description provided for @rateDish.
  ///
  /// In fr, this message translates to:
  /// **'Noter : {name}'**
  String rateDish(String name);

  /// No description provided for @rateShort.
  ///
  /// In fr, this message translates to:
  /// **'Noter'**
  String get rateShort;

  /// No description provided for @refreshLocation.
  ///
  /// In fr, this message translates to:
  /// **'Actualiser'**
  String get refreshLocation;

  /// No description provided for @reorderPartial.
  ///
  /// In fr, this message translates to:
  /// **'Certains plats ne sont plus disponibles : le reste a été ajouté au panier.'**
  String get reorderPartial;

  /// No description provided for @reorderUnavailable.
  ///
  /// In fr, this message translates to:
  /// **'Ces plats ne sont plus disponibles.'**
  String get reorderUnavailable;

  /// No description provided for @reportReason.
  ///
  /// In fr, this message translates to:
  /// **'Pourquoi cet avis est-il abusif ?'**
  String get reportReason;

  /// No description provided for @reportReview.
  ///
  /// In fr, this message translates to:
  /// **'Signaler'**
  String get reportReview;

  /// No description provided for @reportsCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{1 signalement} other{{count} signalements}}'**
  String reportsCount(int count);

  /// No description provided for @reportSent.
  ///
  /// In fr, this message translates to:
  /// **'Merci, le signalement a été transmis.'**
  String get reportSent;

  /// No description provided for @republishReview.
  ///
  /// In fr, this message translates to:
  /// **'Republier'**
  String get republishReview;

  /// No description provided for @reviewCommentHint.
  ///
  /// In fr, this message translates to:
  /// **'Ex. : bien assaisonné, portion généreuse, livraison rapide'**
  String get reviewCommentHint;

  /// No description provided for @satisfiedPercent.
  ///
  /// In fr, this message translates to:
  /// **'{percent} % de clients satisfaits'**
  String satisfiedPercent(int percent);

  /// No description provided for @sortBestRated.
  ///
  /// In fr, this message translates to:
  /// **'Meilleures notes'**
  String get sortBestRated;

  /// No description provided for @sortHelpful.
  ///
  /// In fr, this message translates to:
  /// **'Plus utiles'**
  String get sortHelpful;

  /// No description provided for @sortRecent.
  ///
  /// In fr, this message translates to:
  /// **'Plus récents'**
  String get sortRecent;

  /// No description provided for @sortWorstRated.
  ///
  /// In fr, this message translates to:
  /// **'Notes les plus basses'**
  String get sortWorstRated;

  /// No description provided for @verifiedPurchase.
  ///
  /// In fr, this message translates to:
  /// **'Achat vérifié'**
  String get verifiedPurchase;

  /// No description provided for @verifiedReviewNote.
  ///
  /// In fr, this message translates to:
  /// **'Avis vérifié : seuls les clients ayant reçu ce plat peuvent le noter.'**
  String get verifiedReviewNote;

  /// No description provided for @asSoonAsPossible.
  ///
  /// In fr, this message translates to:
  /// **'Dès que possible'**
  String get asSoonAsPossible;

  /// No description provided for @customerOrdersHere.
  ///
  /// In fr, this message translates to:
  /// **'Ses commandes chez vous'**
  String get customerOrdersHere;

  /// No description provided for @customerPrivacyNote.
  ///
  /// In fr, this message translates to:
  /// **'Vous ne voyez que la relation de ce client avec votre restaurant : jamais ses commandes chez d\'autres restaurants.'**
  String get customerPrivacyNote;

  /// No description provided for @customersCount.
  ///
  /// In fr, this message translates to:
  /// **'clients'**
  String get customersCount;

  /// No description provided for @multiRestaurantNote.
  ///
  /// In fr, this message translates to:
  /// **'{count} restaurants dans votre panier : chacun reçoit sa propre commande, avec son numéro et son suivi.'**
  String multiRestaurantNote(int count);

  /// No description provided for @navCustomers.
  ///
  /// In fr, this message translates to:
  /// **'Clients'**
  String get navCustomers;

  /// No description provided for @noCustomersYet.
  ///
  /// In fr, this message translates to:
  /// **'Pas encore de clients en ligne.'**
  String get noCustomersYet;

  /// No description provided for @noCustomersYetHint.
  ///
  /// In fr, this message translates to:
  /// **'Chaque client qui commande depuis l\'application apparaît ici automatiquement.'**
  String get noCustomersYetHint;

  /// No description provided for @noDeliveryHere.
  ///
  /// In fr, this message translates to:
  /// **'Ce restaurant ne livre pas : commande à emporter.'**
  String get noDeliveryHere;

  /// No description provided for @ordersSent.
  ///
  /// In fr, this message translates to:
  /// **'Commandes envoyées'**
  String get ordersSent;

  /// No description provided for @ordersSentHint.
  ///
  /// In fr, this message translates to:
  /// **'{count} commandes envoyées, une par restaurant. Suivez chacune séparément.'**
  String ordersSentHint(int count);

  /// No description provided for @placeOrders.
  ///
  /// In fr, this message translates to:
  /// **'Passer les {count} commandes'**
  String placeOrders(int count);

  /// No description provided for @regularBadge.
  ///
  /// In fr, this message translates to:
  /// **'Fidèle'**
  String get regularBadge;

  /// No description provided for @regularCustomers.
  ///
  /// In fr, this message translates to:
  /// **'fidèles (3 commandes ou plus)'**
  String get regularCustomers;

  /// No description provided for @restaurantsCount.
  ///
  /// In fr, this message translates to:
  /// **'{count} restaurants'**
  String restaurantsCount(int count);

  /// No description provided for @scheduleOrder.
  ///
  /// In fr, this message translates to:
  /// **'Programmer'**
  String get scheduleOrder;

  /// No description provided for @scheduleTooSoon.
  ///
  /// In fr, this message translates to:
  /// **'Choisissez une heure au moins 15 minutes plus tard.'**
  String get scheduleTooSoon;

  /// No description provided for @searchCustomer.
  ///
  /// In fr, this message translates to:
  /// **'Nom ou téléphone'**
  String get searchCustomer;

  /// No description provided for @sortBiggestSpenders.
  ///
  /// In fr, this message translates to:
  /// **'Plus grosses dépenses'**
  String get sortBiggestSpenders;

  /// No description provided for @sortMostOrders.
  ///
  /// In fr, this message translates to:
  /// **'Plus de commandes'**
  String get sortMostOrders;

  /// No description provided for @sortRecentVisit.
  ///
  /// In fr, this message translates to:
  /// **'Venus récemment'**
  String get sortRecentVisit;

  /// No description provided for @teamNotes.
  ///
  /// In fr, this message translates to:
  /// **'Notes de l\'équipe'**
  String get teamNotes;

  /// No description provided for @teamNotesExample.
  ///
  /// In fr, this message translates to:
  /// **'Ex. : préfère la terrasse, aime la sauce piquante'**
  String get teamNotesExample;

  /// No description provided for @teamNotesHint.
  ///
  /// In fr, this message translates to:
  /// **'Visibles uniquement par votre équipe.'**
  String get teamNotesHint;

  /// No description provided for @trackOrder.
  ///
  /// In fr, this message translates to:
  /// **'Suivre'**
  String get trackOrder;

  /// No description provided for @customerDiscover.
  ///
  /// In fr, this message translates to:
  /// **'Découvrir'**
  String get customerDiscover;

  /// No description provided for @feedEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Rien à découvrir pour l\'instant'**
  String get feedEmpty;

  /// No description provided for @feedEmptyHint.
  ///
  /// In fr, this message translates to:
  /// **'Les vidéos, plats et offres des restaurants de votre ville apparaîtront ici.'**
  String get feedEmptyHint;

  /// No description provided for @feedOrder.
  ///
  /// In fr, this message translates to:
  /// **'Commander'**
  String get feedOrder;

  /// No description provided for @feedViewDish.
  ///
  /// In fr, this message translates to:
  /// **'Voir le plat'**
  String get feedViewDish;

  /// No description provided for @feedViewRestaurant.
  ///
  /// In fr, this message translates to:
  /// **'Voir le restaurant'**
  String get feedViewRestaurant;

  /// No description provided for @feedLike.
  ///
  /// In fr, this message translates to:
  /// **'J\'aime'**
  String get feedLike;

  /// No description provided for @feedSave.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer'**
  String get feedSave;

  /// No description provided for @feedShare.
  ///
  /// In fr, this message translates to:
  /// **'Partager'**
  String get feedShare;

  /// No description provided for @feedSaved.
  ///
  /// In fr, this message translates to:
  /// **'Enregistré dans vos contenus.'**
  String get feedSaved;

  /// No description provided for @feedUnsaved.
  ///
  /// In fr, this message translates to:
  /// **'Retiré de vos contenus enregistrés.'**
  String get feedUnsaved;

  /// No description provided for @feedLinkCopied.
  ///
  /// In fr, this message translates to:
  /// **'Lien copié : collez-le pour le partager.'**
  String get feedLinkCopied;

  /// No description provided for @commentsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Commentaires'**
  String get commentsTitle;

  /// No description provided for @noCommentsYet.
  ///
  /// In fr, this message translates to:
  /// **'Aucun commentaire pour l\'instant.'**
  String get noCommentsYet;

  /// No description provided for @writeComment.
  ///
  /// In fr, this message translates to:
  /// **'Écrire un commentaire…'**
  String get writeComment;

  /// No description provided for @adHideForever.
  ///
  /// In fr, this message translates to:
  /// **'Ne plus afficher'**
  String get adHideForever;

  /// No description provided for @reserveAt.
  ///
  /// In fr, this message translates to:
  /// **'Réserver chez {name}'**
  String reserveAt(String name);

  /// No description provided for @reservationSentHint.
  ///
  /// In fr, this message translates to:
  /// **'Demande envoyée : le restaurant vous confirmera la réservation.'**
  String get reservationSentHint;

  /// No description provided for @reservationNoteLabel.
  ///
  /// In fr, this message translates to:
  /// **'Remarque (facultatif)'**
  String get reservationNoteLabel;

  /// No description provided for @errorInvalidComment.
  ///
  /// In fr, this message translates to:
  /// **'Le commentaire doit contenir entre 1 et 500 caractères.'**
  String get errorInvalidComment;

  /// No description provided for @adStatReach.
  ///
  /// In fr, this message translates to:
  /// **'Portée'**
  String get adStatReach;

  /// No description provided for @adStatEngagement.
  ///
  /// In fr, this message translates to:
  /// **'Engagement'**
  String get adStatEngagement;

  /// No description provided for @adStatLikes.
  ///
  /// In fr, this message translates to:
  /// **'J\'aime'**
  String get adStatLikes;

  /// No description provided for @adStatSaves.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrements'**
  String get adStatSaves;

  /// No description provided for @adStatShares.
  ///
  /// In fr, this message translates to:
  /// **'Partages'**
  String get adStatShares;

  /// No description provided for @hideComment.
  ///
  /// In fr, this message translates to:
  /// **'Masquer'**
  String get hideComment;

  /// No description provided for @moderationReasonExample.
  ///
  /// In fr, this message translates to:
  /// **'Ex. : propos injurieux, hors sujet'**
  String get moderationReasonExample;

  /// No description provided for @hiddenBadge.
  ///
  /// In fr, this message translates to:
  /// **'Masqué'**
  String get hiddenBadge;

  /// No description provided for @hiddenBecause.
  ///
  /// In fr, this message translates to:
  /// **'Masqué : {reason}'**
  String hiddenBecause(String reason);

  /// No description provided for @allFilter.
  ///
  /// In fr, this message translates to:
  /// **'Tous'**
  String get allFilter;

  /// No description provided for @publishedComments.
  ///
  /// In fr, this message translates to:
  /// **'Publiés'**
  String get publishedComments;

  /// No description provided for @hiddenComments.
  ///
  /// In fr, this message translates to:
  /// **'Masqués'**
  String get hiddenComments;

  /// No description provided for @adCommentsHint.
  ///
  /// In fr, this message translates to:
  /// **'Les commentaires des clients sur vos publicités apparaissent ici. Masquez ceux qui sont injurieux ou hors sujet.'**
  String get adCommentsHint;

  /// No description provided for @happyBirthday.
  ///
  /// In fr, this message translates to:
  /// **'Joyeux anniversaire !'**
  String get happyBirthday;

  /// No description provided for @birthdayGift.
  ///
  /// In fr, this message translates to:
  /// **'{name} vous offre {points} points de fidélité.'**
  String birthdayGift(String name, int points);

  /// No description provided for @thanksAction.
  ///
  /// In fr, this message translates to:
  /// **'Merci !'**
  String get thanksAction;

  /// No description provided for @notificationsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// No description provided for @noNotifications.
  ///
  /// In fr, this message translates to:
  /// **'Aucune notification'**
  String get noNotifications;

  /// No description provided for @noNotificationsHint.
  ///
  /// In fr, this message translates to:
  /// **'Vous serez prévenu ici quand un restaurant accepte votre commande, quand elle est prête ou quand une réservation est confirmée.'**
  String get noNotificationsHint;

  /// No description provided for @notifOrderAcceptedTitle.
  ///
  /// In fr, this message translates to:
  /// **'Commande acceptée'**
  String get notifOrderAcceptedTitle;

  /// No description provided for @notifOrderAccepted.
  ///
  /// In fr, this message translates to:
  /// **'{brand} a accepté votre commande n° {number}.'**
  String notifOrderAccepted(String brand, String number);

  /// No description provided for @notifOrderReadyTitle.
  ///
  /// In fr, this message translates to:
  /// **'Commande prête'**
  String get notifOrderReadyTitle;

  /// No description provided for @notifOrderReady.
  ///
  /// In fr, this message translates to:
  /// **'Votre commande n° {number} est prête chez {brand} : vous pouvez la retirer.'**
  String notifOrderReady(String brand, String number);

  /// No description provided for @notifOrderOnTheWay.
  ///
  /// In fr, this message translates to:
  /// **'Votre commande n° {number} de {brand} est prête et part en livraison.'**
  String notifOrderOnTheWay(String brand, String number);

  /// No description provided for @notifOrderRejectedTitle.
  ///
  /// In fr, this message translates to:
  /// **'Commande refusée'**
  String get notifOrderRejectedTitle;

  /// No description provided for @notifOrderRejected.
  ///
  /// In fr, this message translates to:
  /// **'{brand} n\'a pas pu accepter votre commande n° {number} : {reason}'**
  String notifOrderRejected(String brand, String number, String reason);

  /// No description provided for @notifReservationConfirmedTitle.
  ///
  /// In fr, this message translates to:
  /// **'Réservation confirmée'**
  String get notifReservationConfirmedTitle;

  /// No description provided for @notifReservationConfirmed.
  ///
  /// In fr, this message translates to:
  /// **'{brand} a confirmé votre réservation du {date}.'**
  String notifReservationConfirmed(String brand, String date);

  /// No description provided for @notifReservationDeclinedTitle.
  ///
  /// In fr, this message translates to:
  /// **'Réservation refusée'**
  String get notifReservationDeclinedTitle;

  /// No description provided for @notifReservationDeclined.
  ///
  /// In fr, this message translates to:
  /// **'{brand} ne peut pas vous recevoir le {date} : {reason}'**
  String notifReservationDeclined(String brand, String date, String reason);

  /// No description provided for @notifGroupJoined.
  ///
  /// In fr, this message translates to:
  /// **'{name} a rejoint votre commande groupée chez {brand}.'**
  String notifGroupJoined(String name, String brand);

  /// No description provided for @notifGroupPlaced.
  ///
  /// In fr, this message translates to:
  /// **'{host} a envoyé la commande groupée chez {brand} (n° {number}).'**
  String notifGroupPlaced(String host, String brand, String number);

  /// No description provided for @groupOrderTitle.
  ///
  /// In fr, this message translates to:
  /// **'Commande groupée'**
  String get groupOrderTitle;

  /// No description provided for @groupOrderAction.
  ///
  /// In fr, this message translates to:
  /// **'Commande groupée'**
  String get groupOrderAction;

  /// No description provided for @groupInviteTitle.
  ///
  /// In fr, this message translates to:
  /// **'Invitez vos convives'**
  String get groupInviteTitle;

  /// No description provided for @groupInviteHint.
  ///
  /// In fr, this message translates to:
  /// **'Partagez ce lien : chacun choisit ses plats sur son téléphone, puis vous envoyez une seule commande.'**
  String get groupInviteHint;

  /// No description provided for @groupEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucun plat pour l\'instant'**
  String get groupEmpty;

  /// No description provided for @groupEmptyHint.
  ///
  /// In fr, this message translates to:
  /// **'Ajoutez vos plats et partagez le lien avec vos convives.'**
  String get groupEmptyHint;

  /// No description provided for @groupHostedBy.
  ///
  /// In fr, this message translates to:
  /// **'Organisée par {name}'**
  String groupHostedBy(String name);

  /// No description provided for @groupStatusOpen.
  ///
  /// In fr, this message translates to:
  /// **'Ouverte jusqu\'à {time}'**
  String groupStatusOpen(String time);

  /// No description provided for @groupStatusPlaced.
  ///
  /// In fr, this message translates to:
  /// **'Envoyée au restaurant'**
  String get groupStatusPlaced;

  /// No description provided for @groupStatusCancelled.
  ///
  /// In fr, this message translates to:
  /// **'Annulée'**
  String get groupStatusCancelled;

  /// No description provided for @groupStatusExpired.
  ///
  /// In fr, this message translates to:
  /// **'Expirée'**
  String get groupStatusExpired;

  /// No description provided for @groupParticipants.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{1 convive} other{{count} convives}}'**
  String groupParticipants(int count);

  /// No description provided for @groupCheckoutTitle.
  ///
  /// In fr, this message translates to:
  /// **'Envoyer pour tout le groupe'**
  String get groupCheckoutTitle;

  /// No description provided for @estimatedTotal.
  ///
  /// In fr, this message translates to:
  /// **'Total estimé'**
  String get estimatedTotal;

  /// No description provided for @groupPlaceOrder.
  ///
  /// In fr, this message translates to:
  /// **'Envoyer la commande au restaurant'**
  String get groupPlaceOrder;

  /// No description provided for @cancelGroupOrder.
  ///
  /// In fr, this message translates to:
  /// **'Annuler la commande groupée'**
  String get cancelGroupOrder;

  /// No description provided for @cancelGroupOrderConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Annuler cette commande groupée ? Les plats choisis par chacun seront perdus.'**
  String get cancelGroupOrderConfirm;

  /// No description provided for @groupAddMyDishes.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter mes plats'**
  String get groupAddMyDishes;

  /// No description provided for @groupPlacedInfo.
  ///
  /// In fr, this message translates to:
  /// **'{name} a envoyé la commande au restaurant.'**
  String groupPlacedInfo(String name);

  /// No description provided for @groupClosedInfo.
  ///
  /// In fr, this message translates to:
  /// **'Cette commande groupée est fermée.'**
  String get groupClosedInfo;

  /// No description provided for @groupOrderPlaced.
  ///
  /// In fr, this message translates to:
  /// **'Commande groupée envoyée au restaurant.'**
  String get groupOrderPlaced;

  /// No description provided for @addedToGroup.
  ///
  /// In fr, this message translates to:
  /// **'Ajouté à la commande groupée.'**
  String get addedToGroup;

  /// No description provided for @addToGroup.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter au groupe'**
  String get addToGroup;

  /// No description provided for @saveDishAction.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer le plat'**
  String get saveDishAction;

  /// No description provided for @saveDishTitle.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer « {name} »'**
  String saveDishTitle(String name);

  /// No description provided for @favoriteDishes.
  ///
  /// In fr, this message translates to:
  /// **'Plats favoris'**
  String get favoriteDishes;

  /// No description provided for @myLists.
  ///
  /// In fr, this message translates to:
  /// **'Mes listes'**
  String get myLists;

  /// No description provided for @myCoupons.
  ///
  /// In fr, this message translates to:
  /// **'Mes coupons'**
  String get myCoupons;

  /// No description provided for @restaurantsSection.
  ///
  /// In fr, this message translates to:
  /// **'Restaurants'**
  String get restaurantsSection;

  /// No description provided for @unavailableNow.
  ///
  /// In fr, this message translates to:
  /// **'Indisponible'**
  String get unavailableNow;

  /// No description provided for @removeAction.
  ///
  /// In fr, this message translates to:
  /// **'Retirer'**
  String get removeAction;

  /// No description provided for @noFavoriteDishes.
  ///
  /// In fr, this message translates to:
  /// **'Aucun plat favori'**
  String get noFavoriteDishes;

  /// No description provided for @noFavoriteDishesHint.
  ///
  /// In fr, this message translates to:
  /// **'Touchez le cœur sur la fiche d\'un plat pour le retrouver ici.'**
  String get noFavoriteDishesHint;

  /// No description provided for @newList.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle liste'**
  String get newList;

  /// No description provided for @noLists.
  ///
  /// In fr, this message translates to:
  /// **'Aucune liste'**
  String get noLists;

  /// No description provided for @noListsHint.
  ///
  /// In fr, this message translates to:
  /// **'Créez des listes comme « À tester » ou « Déjeuners du bureau ».'**
  String get noListsHint;

  /// No description provided for @deleteListConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer la liste « {name} » ?'**
  String deleteListConfirm(String name);

  /// No description provided for @renameAction.
  ///
  /// In fr, this message translates to:
  /// **'Renommer'**
  String get renameAction;

  /// No description provided for @dishesCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Aucun plat} =1{1 plat} other{{count} plats}}'**
  String dishesCount(int count);

  /// No description provided for @emptyListHint.
  ///
  /// In fr, this message translates to:
  /// **'Liste vide : ajoutez des plats depuis leur fiche.'**
  String get emptyListHint;

  /// No description provided for @listName.
  ///
  /// In fr, this message translates to:
  /// **'Nom de la liste'**
  String get listName;

  /// No description provided for @listNameExample.
  ///
  /// In fr, this message translates to:
  /// **'Ex. : À tester'**
  String get listNameExample;

  /// No description provided for @noCoupons.
  ///
  /// In fr, this message translates to:
  /// **'Aucun coupon'**
  String get noCoupons;

  /// No description provided for @noCouponsHint.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrez les offres des restaurants depuis l\'accueil pour les retrouver ici.'**
  String get noCouponsHint;

  /// No description provided for @couponsHowTo.
  ///
  /// In fr, this message translates to:
  /// **'Saisissez le code dans le suivi de votre commande pour profiter de la remise.'**
  String get couponsHowTo;

  /// No description provided for @validUntil.
  ///
  /// In fr, this message translates to:
  /// **'jusqu\'au {date}'**
  String validUntil(String date);

  /// No description provided for @couponUsed.
  ///
  /// In fr, this message translates to:
  /// **'Déjà utilisé'**
  String get couponUsed;

  /// No description provided for @couponExpired.
  ///
  /// In fr, this message translates to:
  /// **'Expiré'**
  String get couponExpired;

  /// No description provided for @codeCopied.
  ///
  /// In fr, this message translates to:
  /// **'Code copié.'**
  String get codeCopied;

  /// No description provided for @couponSaved.
  ///
  /// In fr, this message translates to:
  /// **'Coupon enregistré dans vos favoris.'**
  String get couponSaved;

  /// No description provided for @saveCouponAction.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer'**
  String get saveCouponAction;

  /// No description provided for @errorLimitReached.
  ///
  /// In fr, this message translates to:
  /// **'Limite atteinte : retirez des éléments avant d\'en ajouter.'**
  String get errorLimitReached;

  /// No description provided for @errorGroupClosed.
  ///
  /// In fr, this message translates to:
  /// **'Cette commande groupée est fermée ou a expiré.'**
  String get errorGroupClosed;

  /// No description provided for @customersTab.
  ///
  /// In fr, this message translates to:
  /// **'Clients'**
  String get customersTab;

  /// No description provided for @offersTab.
  ///
  /// In fr, this message translates to:
  /// **'Offres'**
  String get offersTab;

  /// No description provided for @loyaltyTab.
  ///
  /// In fr, this message translates to:
  /// **'Fidélité'**
  String get loyaltyTab;

  /// No description provided for @activeOffers.
  ///
  /// In fr, this message translates to:
  /// **'Offres en cours'**
  String get activeOffers;

  /// No description provided for @publicCoupons.
  ///
  /// In fr, this message translates to:
  /// **'Coupons publics'**
  String get publicCoupons;

  /// No description provided for @totalUses.
  ///
  /// In fr, this message translates to:
  /// **'Utilisations'**
  String get totalUses;

  /// No description provided for @newOffer.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle offre'**
  String get newOffer;

  /// No description provided for @editOffer.
  ///
  /// In fr, this message translates to:
  /// **'Modifier l\'offre'**
  String get editOffer;

  /// No description provided for @offersEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucune offre'**
  String get offersEmpty;

  /// No description provided for @offersEmptyHint.
  ///
  /// In fr, this message translates to:
  /// **'Créez une remise, un code promo ou un coupon public pour attirer et fidéliser vos clients.'**
  String get offersEmptyHint;

  /// No description provided for @offerStatusOff.
  ///
  /// In fr, this message translates to:
  /// **'Désactivée'**
  String get offerStatusOff;

  /// No description provided for @offerStatusEnded.
  ///
  /// In fr, this message translates to:
  /// **'Terminée'**
  String get offerStatusEnded;

  /// No description provided for @offerStatusScheduled.
  ///
  /// In fr, this message translates to:
  /// **'Programmée'**
  String get offerStatusScheduled;

  /// No description provided for @offerStatusActive.
  ///
  /// In fr, this message translates to:
  /// **'En cours'**
  String get offerStatusActive;

  /// No description provided for @publicCouponLabel.
  ///
  /// In fr, this message translates to:
  /// **'Coupon public'**
  String get publicCouponLabel;

  /// No description provided for @publicCouponHint.
  ///
  /// In fr, this message translates to:
  /// **'Visible dans l\'application : les clients peuvent l\'enregistrer dans leur portefeuille.'**
  String get publicCouponHint;

  /// No description provided for @publicCouponNeedsCode.
  ///
  /// In fr, this message translates to:
  /// **'Un coupon public doit avoir un code.'**
  String get publicCouponNeedsCode;

  /// No description provided for @usesCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Jamais utilisée} =1{1 utilisation} other{{count} utilisations}}'**
  String usesCount(int count);

  /// No description provided for @offerName.
  ///
  /// In fr, this message translates to:
  /// **'Nom de l\'offre'**
  String get offerName;

  /// No description provided for @offerNameExample.
  ///
  /// In fr, this message translates to:
  /// **'Ex. : Bienvenue, Happy hour'**
  String get offerNameExample;

  /// No description provided for @discountPercent.
  ///
  /// In fr, this message translates to:
  /// **'Pourcentage'**
  String get discountPercent;

  /// No description provided for @discountAmount.
  ///
  /// In fr, this message translates to:
  /// **'Montant'**
  String get discountAmount;

  /// No description provided for @offerValue.
  ///
  /// In fr, this message translates to:
  /// **'Remise'**
  String get offerValue;

  /// No description provided for @promoCodeLabel.
  ///
  /// In fr, this message translates to:
  /// **'Code (facultatif)'**
  String get promoCodeLabel;

  /// No description provided for @offerCodeHint.
  ///
  /// In fr, this message translates to:
  /// **'3 à 30 lettres ou chiffres, ex. BIENVENUE'**
  String get offerCodeHint;

  /// No description provided for @minOrderLabel.
  ///
  /// In fr, this message translates to:
  /// **'Commande minimum'**
  String get minOrderLabel;

  /// No description provided for @maxUsesLabel.
  ///
  /// In fr, this message translates to:
  /// **'Utilisations max.'**
  String get maxUsesLabel;

  /// No description provided for @perCustomerLabel.
  ///
  /// In fr, this message translates to:
  /// **'Par client'**
  String get perCustomerLabel;

  /// No description provided for @startsLabel.
  ///
  /// In fr, this message translates to:
  /// **'Début'**
  String get startsLabel;

  /// No description provided for @endsLabel.
  ///
  /// In fr, this message translates to:
  /// **'Fin'**
  String get endsLabel;

  /// No description provided for @offerNow.
  ///
  /// In fr, this message translates to:
  /// **'maintenant'**
  String get offerNow;

  /// No description provided for @noEndDate.
  ///
  /// In fr, this message translates to:
  /// **'Sans fin'**
  String get noEndDate;

  /// No description provided for @allBranchesLabel.
  ///
  /// In fr, this message translates to:
  /// **'Tous les établissements'**
  String get allBranchesLabel;

  /// No description provided for @thisBranchOnly.
  ///
  /// In fr, this message translates to:
  /// **'Cet établissement'**
  String get thisBranchOnly;

  /// No description provided for @offerActive.
  ///
  /// In fr, this message translates to:
  /// **'Offre active'**
  String get offerActive;

  /// No description provided for @loyaltyMembers.
  ///
  /// In fr, this message translates to:
  /// **'Membres'**
  String get loyaltyMembers;

  /// No description provided for @pointsInCirculation.
  ///
  /// In fr, this message translates to:
  /// **'Points en circulation'**
  String get pointsInCirculation;

  /// No description provided for @loyaltyProgramTitle.
  ///
  /// In fr, this message translates to:
  /// **'Programme de fidélité'**
  String get loyaltyProgramTitle;

  /// No description provided for @loyaltyExample.
  ///
  /// In fr, this message translates to:
  /// **'Exemple : une commande de {amount} rapporte {points} points.'**
  String loyaltyExample(String amount, int points);

  /// No description provided for @loyaltyActive.
  ///
  /// In fr, this message translates to:
  /// **'Programme actif'**
  String get loyaltyActive;

  /// No description provided for @amountPerPoint.
  ///
  /// In fr, this message translates to:
  /// **'Montant pour 1 point'**
  String get amountPerPoint;

  /// No description provided for @rewardPointsLabel.
  ///
  /// In fr, this message translates to:
  /// **'Points pour une récompense'**
  String get rewardPointsLabel;

  /// No description provided for @rewardValueLabel.
  ///
  /// In fr, this message translates to:
  /// **'Valeur de la récompense'**
  String get rewardValueLabel;

  /// No description provided for @birthdayPointsLabel.
  ///
  /// In fr, this message translates to:
  /// **'Points offerts à l\'anniversaire'**
  String get birthdayPointsLabel;

  /// No description provided for @birthdayPointsHint.
  ///
  /// In fr, this message translates to:
  /// **'Crédités automatiquement chaque année aux clients qui ont déjà commandé chez vous (0 = aucun).'**
  String get birthdayPointsHint;

  /// No description provided for @stockDashboardTab.
  ///
  /// In fr, this message translates to:
  /// **'Tableau de bord'**
  String get stockDashboardTab;

  /// No description provided for @stockArticlesTab.
  ///
  /// In fr, this message translates to:
  /// **'Articles'**
  String get stockArticlesTab;

  /// No description provided for @stockOrdersTab.
  ///
  /// In fr, this message translates to:
  /// **'Commandes'**
  String get stockOrdersTab;

  /// No description provided for @stockReportsTab.
  ///
  /// In fr, this message translates to:
  /// **'Rapports'**
  String get stockReportsTab;

  /// No description provided for @stockDashboardTitle.
  ///
  /// In fr, this message translates to:
  /// **'Tableau de bord du stock'**
  String get stockDashboardTitle;

  /// No description provided for @stockValueLabel.
  ///
  /// In fr, this message translates to:
  /// **'Valeur du stock'**
  String get stockValueLabel;

  /// No description provided for @belowThresholdLabel.
  ///
  /// In fr, this message translates to:
  /// **'Sous le seuil'**
  String get belowThresholdLabel;

  /// No description provided for @outOfStockLabel.
  ///
  /// In fr, this message translates to:
  /// **'En rupture'**
  String get outOfStockLabel;

  /// No description provided for @expiringSoonLabel.
  ///
  /// In fr, this message translates to:
  /// **'Dates limites proches'**
  String get expiringSoonLabel;

  /// No description provided for @inventoryVarianceLabel.
  ///
  /// In fr, this message translates to:
  /// **'Écarts d\'inventaire'**
  String get inventoryVarianceLabel;

  /// No description provided for @consumptionLabel.
  ///
  /// In fr, this message translates to:
  /// **'Consommation'**
  String get consumptionLabel;

  /// No description provided for @wasteLabel.
  ///
  /// In fr, this message translates to:
  /// **'Pertes'**
  String get wasteLabel;

  /// No description provided for @receiptsLabel.
  ///
  /// In fr, this message translates to:
  /// **'Réceptions'**
  String get receiptsLabel;

  /// No description provided for @articlesCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Aucun article} =1{1 article} other{{count} articles}}'**
  String articlesCount(int count);

  /// No description provided for @daysCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{1 jour} other{{count} jours}}'**
  String daysCount(int count);

  /// No description provided for @consumptionByDay.
  ///
  /// In fr, this message translates to:
  /// **'Consommation et pertes par jour'**
  String get consumptionByDay;

  /// No description provided for @topConsumedTitle.
  ///
  /// In fr, this message translates to:
  /// **'Les plus consommés'**
  String get topConsumedTitle;

  /// No description provided for @wasteByReason.
  ///
  /// In fr, this message translates to:
  /// **'Pertes par motif'**
  String get wasteByReason;

  /// No description provided for @noMovementsPeriod.
  ///
  /// In fr, this message translates to:
  /// **'Aucun mouvement sur cette période.'**
  String get noMovementsPeriod;

  /// No description provided for @noWastePeriod.
  ///
  /// In fr, this message translates to:
  /// **'Aucune perte sur cette période.'**
  String get noWastePeriod;

  /// No description provided for @expiringLotsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Lots à surveiller (dates limites)'**
  String get expiringLotsTitle;

  /// No description provided for @noExpiringLots.
  ///
  /// In fr, this message translates to:
  /// **'Aucun lot n\'arrive à sa date limite dans les 7 jours.'**
  String get noExpiringLots;

  /// No description provided for @toReorderTitle.
  ///
  /// In fr, this message translates to:
  /// **'À commander'**
  String get toReorderTitle;

  /// No description provided for @noAlerts.
  ///
  /// In fr, this message translates to:
  /// **'Aucun article sous le seuil.'**
  String get noAlerts;

  /// No description provided for @prepareOrder.
  ///
  /// In fr, this message translates to:
  /// **'Préparer la commande'**
  String get prepareOrder;

  /// No description provided for @expiredShort.
  ///
  /// In fr, this message translates to:
  /// **'Périmé'**
  String get expiredShort;

  /// No description provided for @daysLeftShort.
  ///
  /// In fr, this message translates to:
  /// **'J-{count}'**
  String daysLeftShort(int count);

  /// No description provided for @daysLeftLong.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{épuisé aujourd\'hui} =1{1 jour de stock} other{{count} jours de stock}}'**
  String daysLeftLong(int count);

  /// No description provided for @batchShort.
  ///
  /// In fr, this message translates to:
  /// **'Lot {batch}'**
  String batchShort(String batch);

  /// No description provided for @batchNumber.
  ///
  /// In fr, this message translates to:
  /// **'N° de lot'**
  String get batchNumber;

  /// No description provided for @expiryDate.
  ///
  /// In fr, this message translates to:
  /// **'Date limite'**
  String get expiryDate;

  /// No description provided for @stockEmptyHint.
  ///
  /// In fr, this message translates to:
  /// **'Créez vos articles dans l\'onglet Articles, puis enregistrez le stock de départ ou une réception.'**
  String get stockEmptyHint;

  /// No description provided for @searchArticle.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher un article'**
  String get searchArticle;

  /// No description provided for @showInactive.
  ///
  /// In fr, this message translates to:
  /// **'Afficher les inactifs'**
  String get showInactive;

  /// No description provided for @newArticle.
  ///
  /// In fr, this message translates to:
  /// **'Nouvel article'**
  String get newArticle;

  /// No description provided for @editArticle.
  ///
  /// In fr, this message translates to:
  /// **'Modifier l\'article'**
  String get editArticle;

  /// No description provided for @articlesEmptyHint.
  ///
  /// In fr, this message translates to:
  /// **'Ajoutez vos produits : légumes, viandes, boissons, emballages, préparations maison…'**
  String get articlesEmptyHint;

  /// No description provided for @storageLabel.
  ///
  /// In fr, this message translates to:
  /// **'Conservation'**
  String get storageLabel;

  /// No description provided for @storageAmbient.
  ///
  /// In fr, this message translates to:
  /// **'Ambiant'**
  String get storageAmbient;

  /// No description provided for @storageChilled.
  ///
  /// In fr, this message translates to:
  /// **'Frais'**
  String get storageChilled;

  /// No description provided for @storageFrozen.
  ///
  /// In fr, this message translates to:
  /// **'Surgelé'**
  String get storageFrozen;

  /// No description provided for @purchaseUnitLabel.
  ///
  /// In fr, this message translates to:
  /// **'Unité d\'achat'**
  String get purchaseUnitLabel;

  /// No description provided for @purchaseUnitExample.
  ///
  /// In fr, this message translates to:
  /// **'Ex. : Sac de 5 kg, Carton de 12'**
  String get purchaseUnitExample;

  /// No description provided for @purchaseUnitQty.
  ///
  /// In fr, this message translates to:
  /// **'Contenance'**
  String get purchaseUnitQty;

  /// No description provided for @preferredSupplier.
  ///
  /// In fr, this message translates to:
  /// **'Fournisseur habituel'**
  String get preferredSupplier;

  /// No description provided for @noneLabel.
  ///
  /// In fr, this message translates to:
  /// **'Aucun'**
  String get noneLabel;

  /// No description provided for @shelfLifeDays.
  ///
  /// In fr, this message translates to:
  /// **'Durée de conservation'**
  String get shelfLifeDays;

  /// No description provided for @daysShort.
  ///
  /// In fr, this message translates to:
  /// **'jours'**
  String get daysShort;

  /// No description provided for @barcodeLabel.
  ///
  /// In fr, this message translates to:
  /// **'Code-barres'**
  String get barcodeLabel;

  /// No description provided for @thresholdThisBranch.
  ///
  /// In fr, this message translates to:
  /// **'Seuil d\'alerte de cet établissement'**
  String get thresholdThisBranch;

  /// No description provided for @reorderTitle.
  ///
  /// In fr, this message translates to:
  /// **'Commande suggérée'**
  String get reorderTitle;

  /// No description provided for @reorderHint.
  ///
  /// In fr, this message translates to:
  /// **'De quoi tenir au-dessus du seuil, d\'après la consommation des 28 derniers jours.'**
  String get reorderHint;

  /// No description provided for @nothingToReorder.
  ///
  /// In fr, this message translates to:
  /// **'Rien à commander'**
  String get nothingToReorder;

  /// No description provided for @nothingToReorderHint.
  ///
  /// In fr, this message translates to:
  /// **'Tous les articles suivis ont un stock suffisant pour la période choisie.'**
  String get nothingToReorderHint;

  /// No description provided for @noSupplier.
  ///
  /// In fr, this message translates to:
  /// **'Sans fournisseur habituel'**
  String get noSupplier;

  /// No description provided for @noSupplierHint.
  ///
  /// In fr, this message translates to:
  /// **'Choisissez un fournisseur habituel dans la fiche article pour créer un bon de commande.'**
  String get noSupplierHint;

  /// No description provided for @orderFormPdf.
  ///
  /// In fr, this message translates to:
  /// **'Bon de commande PDF'**
  String get orderFormPdf;

  /// No description provided for @createPurchaseOrder.
  ///
  /// In fr, this message translates to:
  /// **'Créer le bon de commande'**
  String get createPurchaseOrder;

  /// No description provided for @purchaseOrderDraftCreated.
  ///
  /// In fr, this message translates to:
  /// **'Bon de commande créé en brouillon dans Achats.'**
  String get purchaseOrderDraftCreated;

  /// No description provided for @reorderNote.
  ///
  /// In fr, this message translates to:
  /// **'Commande suggérée par le stock'**
  String get reorderNote;

  /// No description provided for @inStockShort.
  ///
  /// In fr, this message translates to:
  /// **'En stock : {qty}'**
  String inStockShort(String qty);

  /// No description provided for @entriesFilter.
  ///
  /// In fr, this message translates to:
  /// **'Entrées'**
  String get entriesFilter;

  /// No description provided for @exitsLabel.
  ///
  /// In fr, this message translates to:
  /// **'Sorties'**
  String get exitsLabel;

  /// No description provided for @transfersFilter.
  ///
  /// In fr, this message translates to:
  /// **'Transferts'**
  String get transfersFilter;

  /// No description provided for @adjustmentsFilter.
  ///
  /// In fr, this message translates to:
  /// **'Ajustements'**
  String get adjustmentsFilter;

  /// No description provided for @movementsReportTitle.
  ///
  /// In fr, this message translates to:
  /// **'Mouvements de stock'**
  String get movementsReportTitle;

  /// No description provided for @wasteReportTitle.
  ///
  /// In fr, this message translates to:
  /// **'Pertes et casse'**
  String get wasteReportTitle;

  /// No description provided for @reportValuation.
  ///
  /// In fr, this message translates to:
  /// **'État du stock valorisé'**
  String get reportValuation;

  /// No description provided for @reportValuationHint.
  ///
  /// In fr, this message translates to:
  /// **'Quantités, seuils, coût moyen et valeur de chaque article à l\'instant.'**
  String get reportValuationHint;

  /// No description provided for @reportMovementsHint.
  ///
  /// In fr, this message translates to:
  /// **'Tous les mouvements de la période, avec les totaux par nature.'**
  String get reportMovementsHint;

  /// No description provided for @reportWasteHint.
  ///
  /// In fr, this message translates to:
  /// **'Pertes de la période avec leur motif et leur valeur.'**
  String get reportWasteHint;

  /// No description provided for @reportInventory.
  ///
  /// In fr, this message translates to:
  /// **'Inventaire avec écarts'**
  String get reportInventory;

  /// No description provided for @reportInventoryHint.
  ///
  /// In fr, this message translates to:
  /// **'Théorique, compté, écarts valorisés, avec les signatures.'**
  String get reportInventoryHint;

  /// No description provided for @reportFoodCost.
  ///
  /// In fr, this message translates to:
  /// **'Coût matière par plat'**
  String get reportFoodCost;

  /// No description provided for @reportFoodCostHint.
  ///
  /// In fr, this message translates to:
  /// **'Coût de revient, prix de vente, part du prix et marge de chaque plat.'**
  String get reportFoodCostHint;

  /// No description provided for @reportExpiringHint.
  ///
  /// In fr, this message translates to:
  /// **'Lots encore en stock dont la date limite tombe dans les 14 jours.'**
  String get reportExpiringHint;

  /// No description provided for @generatePdf.
  ///
  /// In fr, this message translates to:
  /// **'Générer le PDF'**
  String get generatePdf;

  /// No description provided for @noValidatedInventory.
  ///
  /// In fr, this message translates to:
  /// **'Aucun inventaire validé pour l\'instant.'**
  String get noValidatedInventory;

  /// No description provided for @chooseInventory.
  ///
  /// In fr, this message translates to:
  /// **'Choisir l\'inventaire'**
  String get chooseInventory;

  /// No description provided for @generatedOn.
  ///
  /// In fr, this message translates to:
  /// **'Édité le {date}'**
  String generatedOn(String date);

  /// No description provided for @articlesLabel.
  ///
  /// In fr, this message translates to:
  /// **'Articles'**
  String get articlesLabel;

  /// No description provided for @articleLabel.
  ///
  /// In fr, this message translates to:
  /// **'Article'**
  String get articleLabel;

  /// No description provided for @avgCostShort.
  ///
  /// In fr, this message translates to:
  /// **'Coût moyen'**
  String get avgCostShort;

  /// No description provided for @valueLabel.
  ///
  /// In fr, this message translates to:
  /// **'Valeur'**
  String get valueLabel;

  /// No description provided for @typeLabel.
  ///
  /// In fr, this message translates to:
  /// **'Nature'**
  String get typeLabel;

  /// No description provided for @inventoryGains.
  ///
  /// In fr, this message translates to:
  /// **'Excédents'**
  String get inventoryGains;

  /// No description provided for @inventoryLosses.
  ///
  /// In fr, this message translates to:
  /// **'Manquants'**
  String get inventoryLosses;

  /// No description provided for @inventoryNet.
  ///
  /// In fr, this message translates to:
  /// **'Écart net'**
  String get inventoryNet;

  /// No description provided for @theoreticalLabel.
  ///
  /// In fr, this message translates to:
  /// **'Théorique'**
  String get theoreticalLabel;

  /// No description provided for @countedBySignature.
  ///
  /// In fr, this message translates to:
  /// **'Compté par : ____________________'**
  String get countedBySignature;

  /// No description provided for @validatedBySignature.
  ///
  /// In fr, this message translates to:
  /// **'Validé par : ____________________'**
  String get validatedBySignature;

  /// No description provided for @targetFoodCost.
  ///
  /// In fr, this message translates to:
  /// **'Objectif de coût matière'**
  String get targetFoodCost;

  /// No description provided for @targetFoodCostHint.
  ///
  /// In fr, this message translates to:
  /// **'Part maximale du prix de vente que doivent représenter les ingrédients d\'un plat (souvent 25 à 35 %).'**
  String get targetFoodCostHint;

  /// No description provided for @targetFoodCostValue.
  ///
  /// In fr, this message translates to:
  /// **'Objectif coût matière : {percent} %'**
  String targetFoodCostValue(String percent);

  /// No description provided for @dishesWithRecipe.
  ///
  /// In fr, this message translates to:
  /// **'Plats avec fiche'**
  String get dishesWithRecipe;

  /// No description provided for @aboveTarget.
  ///
  /// In fr, this message translates to:
  /// **'Au-dessus de l\'objectif'**
  String get aboveTarget;

  /// No description provided for @aboveTargetShort.
  ///
  /// In fr, this message translates to:
  /// **'trop cher'**
  String get aboveTargetShort;

  /// No description provided for @withoutRecipe.
  ///
  /// In fr, this message translates to:
  /// **'Sans fiche'**
  String get withoutRecipe;

  /// No description provided for @recipeDefined.
  ///
  /// In fr, this message translates to:
  /// **'Fiche définie'**
  String get recipeDefined;

  /// No description provided for @dishLabel.
  ///
  /// In fr, this message translates to:
  /// **'Plat'**
  String get dishLabel;

  /// No description provided for @costPriceShort.
  ///
  /// In fr, this message translates to:
  /// **'Coût'**
  String get costPriceShort;

  /// No description provided for @sellingPriceShort.
  ///
  /// In fr, this message translates to:
  /// **'Prix'**
  String get sellingPriceShort;

  /// No description provided for @foodCostShort.
  ///
  /// In fr, this message translates to:
  /// **'coût matière'**
  String get foodCostShort;

  /// No description provided for @marginShort.
  ///
  /// In fr, this message translates to:
  /// **'Marge'**
  String get marginShort;

  /// No description provided for @orderFormTitle.
  ///
  /// In fr, this message translates to:
  /// **'Bon de commande'**
  String get orderFormTitle;

  /// No description provided for @supplierLabelValue.
  ///
  /// In fr, this message translates to:
  /// **'Fournisseur : {name}'**
  String supplierLabelValue(String name);

  /// No description provided for @packagingLabel.
  ///
  /// In fr, this message translates to:
  /// **'Conditionnement'**
  String get packagingLabel;

  /// No description provided for @unitPriceShort.
  ///
  /// In fr, this message translates to:
  /// **'Prix unitaire'**
  String get unitPriceShort;

  /// No description provided for @orderFormFooter.
  ///
  /// In fr, this message translates to:
  /// **'Merci de confirmer la disponibilité et le délai de livraison.'**
  String get orderFormFooter;

  /// No description provided for @accountTypeQuestion.
  ///
  /// In fr, this message translates to:
  /// **'Vous êtes :'**
  String get accountTypeQuestion;

  /// No description provided for @accountTypeCustomer.
  ///
  /// In fr, this message translates to:
  /// **'Client'**
  String get accountTypeCustomer;

  /// No description provided for @accountTypeCustomerHint.
  ///
  /// In fr, this message translates to:
  /// **'Découvrir les restaurants, commander, réserver'**
  String get accountTypeCustomerHint;

  /// No description provided for @accountTypeBusiness.
  ///
  /// In fr, this message translates to:
  /// **'Entreprise'**
  String get accountTypeBusiness;

  /// No description provided for @accountTypeBusinessHint.
  ///
  /// In fr, this message translates to:
  /// **'Gérer mon restaurant et mon équipe'**
  String get accountTypeBusinessHint;

  /// No description provided for @accountTypeRequired.
  ///
  /// In fr, this message translates to:
  /// **'Choisissez Client ou Entreprise.'**
  String get accountTypeRequired;

  /// No description provided for @accountTypeTitle.
  ///
  /// In fr, this message translates to:
  /// **'Bienvenue sur Resto'**
  String get accountTypeTitle;

  /// No description provided for @accountTypeSub.
  ///
  /// In fr, this message translates to:
  /// **'Comment allez-vous utiliser l\'application ?'**
  String get accountTypeSub;

  /// No description provided for @continueAction.
  ///
  /// In fr, this message translates to:
  /// **'Continuer'**
  String get continueAction;

  /// No description provided for @adVideoTooBig.
  ///
  /// In fr, this message translates to:
  /// **'{name} dépasse 50 Mo : choisissez une vidéo plus courte (30 secondes environ).'**
  String adVideoTooBig(String name);

  /// No description provided for @adMediaAdded.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{1 fichier ajouté.} other{{count} fichiers ajoutés.}}'**
  String adMediaAdded(int count);

  /// No description provided for @adNeedVideo.
  ///
  /// In fr, this message translates to:
  /// **'Ajoutez une vidéo avant de publier ce format.'**
  String get adNeedVideo;

  /// No description provided for @adNeedMedia.
  ///
  /// In fr, this message translates to:
  /// **'Ajoutez au moins une photo ou une vidéo avant de publier.'**
  String get adNeedMedia;

  /// No description provided for @adNeedItems.
  ///
  /// In fr, this message translates to:
  /// **'Choisissez au moins un plat à mettre en avant.'**
  String get adNeedItems;

  /// No description provided for @uploadingLabel.
  ///
  /// In fr, this message translates to:
  /// **'Envoi…'**
  String get uploadingLabel;

  /// No description provided for @errorInvalidMedia.
  ///
  /// In fr, this message translates to:
  /// **'Fichier refusé : il doit venir de votre médiathèque.'**
  String get errorInvalidMedia;

  /// No description provided for @errorFileTooLarge.
  ///
  /// In fr, this message translates to:
  /// **'Fichier trop volumineux.'**
  String get errorFileTooLarge;

  /// No description provided for @errorFileType.
  ///
  /// In fr, this message translates to:
  /// **'Format de fichier non accepté (JPG, PNG, WebP, MP4, WebM, MOV).'**
  String get errorFileType;

  /// No description provided for @adAddVideo.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter une vidéo'**
  String get adAddVideo;

  /// No description provided for @errorOutOfStock.
  ///
  /// In fr, this message translates to:
  /// **'Ce plat est épuisé pour aujourd\'hui.'**
  String get errorOutOfStock;

  /// No description provided for @errorInvalidRating.
  ///
  /// In fr, this message translates to:
  /// **'La note doit être comprise entre 1 et 5.'**
  String get errorInvalidRating;

  /// No description provided for @errorInvalidAllergen.
  ///
  /// In fr, this message translates to:
  /// **'Allergène inconnu.'**
  String get errorInvalidAllergen;

  /// No description provided for @bestSeller.
  ///
  /// In fr, this message translates to:
  /// **'Best-seller'**
  String get bestSeller;

  /// No description provided for @callAction.
  ///
  /// In fr, this message translates to:
  /// **'Appeler'**
  String get callAction;

  /// No description provided for @writeAction.
  ///
  /// In fr, this message translates to:
  /// **'Écrire'**
  String get writeAction;

  /// No description provided for @categoriesLabel.
  ///
  /// In fr, this message translates to:
  /// **'Catégories'**
  String get categoriesLabel;

  /// No description provided for @filtersLabel.
  ///
  /// In fr, this message translates to:
  /// **'Filtres'**
  String get filtersLabel;

  /// No description provided for @reviewsTab.
  ///
  /// In fr, this message translates to:
  /// **'Avis'**
  String get reviewsTab;

  /// No description provided for @infosTab.
  ///
  /// In fr, this message translates to:
  /// **'Infos'**
  String get infosTab;

  /// No description provided for @noDishMatches.
  ///
  /// In fr, this message translates to:
  /// **'Aucun plat ne correspond à ces filtres.'**
  String get noDishMatches;

  /// No description provided for @soldCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{1 vendu} other{{count} vendus}}'**
  String soldCount(int count);

  /// No description provided for @yourCart.
  ///
  /// In fr, this message translates to:
  /// **'Votre panier'**
  String get yourCart;

  /// No description provided for @coverPhoto.
  ///
  /// In fr, this message translates to:
  /// **'Photo d\'ambiance'**
  String get coverPhoto;

  /// No description provided for @coverPhotoHint.
  ///
  /// In fr, this message translates to:
  /// **'Grande photo en haut de votre page restaurant (salle, terrasse, façade).'**
  String get coverPhotoHint;

  /// No description provided for @changePhoto.
  ///
  /// In fr, this message translates to:
  /// **'Changer la photo'**
  String get changePhoto;

  /// No description provided for @itemTagsLabel.
  ///
  /// In fr, this message translates to:
  /// **'Étiquettes (filtres de votre carte)'**
  String get itemTagsLabel;

  /// No description provided for @itemTagsHint.
  ///
  /// In fr, this message translates to:
  /// **'Créez vos propres étiquettes : vos clients pourront filtrer la carte avec. Ex. : Piment doux, Halal, Sans alcool, Fait maison.'**
  String get itemTagsHint;

  /// No description provided for @addTagHint.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle étiquette + Entrée'**
  String get addTagHint;

  /// No description provided for @errorInvalidTag.
  ///
  /// In fr, this message translates to:
  /// **'Une étiquette compte 30 caractères au plus.'**
  String get errorInvalidTag;

  /// No description provided for @itemFavorites.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Aucun client ne l\'a en favori} =1{1 client l\'a en favori} other{{count} clients l\'ont en favori}}'**
  String itemFavorites(int count);

  /// No description provided for @itemSold30.
  ///
  /// In fr, this message translates to:
  /// **'Ventes des 30 derniers jours'**
  String get itemSold30;

  /// No description provided for @receiptOrderNo.
  ///
  /// In fr, this message translates to:
  /// **'Commande N°'**
  String get receiptOrderNo;

  /// No description provided for @receiptTicketNo.
  ///
  /// In fr, this message translates to:
  /// **'Ticket N°'**
  String get receiptTicketNo;

  /// No description provided for @receiptChannel.
  ///
  /// In fr, this message translates to:
  /// **'Canal'**
  String get receiptChannel;

  /// No description provided for @receiptQtyShort.
  ///
  /// In fr, this message translates to:
  /// **'Qté'**
  String get receiptQtyShort;

  /// No description provided for @receiptTotalInclTax.
  ///
  /// In fr, this message translates to:
  /// **'Total TTC'**
  String get receiptTotalInclTax;

  /// No description provided for @receiptTotalExclTax.
  ///
  /// In fr, this message translates to:
  /// **'Total HT'**
  String get receiptTotalExclTax;

  /// No description provided for @receiptApproved.
  ///
  /// In fr, this message translates to:
  /// **'Transaction approuvée'**
  String get receiptApproved;

  /// No description provided for @receiptRef.
  ///
  /// In fr, this message translates to:
  /// **'Réf. : {ref}'**
  String receiptRef(String ref);

  /// No description provided for @receiptSeeYou.
  ///
  /// In fr, this message translates to:
  /// **'À très bientôt chez {name}'**
  String receiptSeeYou(String name);

  /// No description provided for @receiptRecycle.
  ///
  /// In fr, this message translates to:
  /// **'Pour une planète plus verte, pensez à recycler ce ticket.'**
  String get receiptRecycle;

  /// No description provided for @receiptLoyaltyTitle.
  ///
  /// In fr, this message translates to:
  /// **'Votre fidélité vous récompense !'**
  String get receiptLoyaltyTitle;

  /// No description provided for @receiptLoyaltyCaption.
  ///
  /// In fr, this message translates to:
  /// **'Scannez ce QR code pour accéder à votre espace fidélité et profiter de vos avantages.'**
  String get receiptLoyaltyCaption;

  /// No description provided for @receiptPaperLabel.
  ///
  /// In fr, this message translates to:
  /// **'Imprimante de tickets de cet appareil'**
  String get receiptPaperLabel;

  /// No description provided for @receiptPaper80.
  ///
  /// In fr, this message translates to:
  /// **'Rouleau 80 mm'**
  String get receiptPaper80;

  /// No description provided for @receiptPaper58.
  ///
  /// In fr, this message translates to:
  /// **'Rouleau 58 mm'**
  String get receiptPaper58;

  /// No description provided for @receiptPhotosLabel.
  ///
  /// In fr, this message translates to:
  /// **'Photos des plats sur le ticket'**
  String get receiptPhotosLabel;

  /// No description provided for @receiptTestPrint.
  ///
  /// In fr, this message translates to:
  /// **'Imprimer un ticket d\'essai'**
  String get receiptTestPrint;

  /// No description provided for @receiptTestTitle.
  ///
  /// In fr, this message translates to:
  /// **'Ticket d\'essai'**
  String get receiptTestTitle;

  /// No description provided for @receiptHeaderSection.
  ///
  /// In fr, this message translates to:
  /// **'En-tête du ticket'**
  String get receiptHeaderSection;

  /// No description provided for @receiptFooterSection.
  ///
  /// In fr, this message translates to:
  /// **'Bas du ticket'**
  String get receiptFooterSection;

  /// No description provided for @receiptTitleLabel.
  ///
  /// In fr, this message translates to:
  /// **'Nom affiché'**
  String get receiptTitleLabel;

  /// No description provided for @receiptTitleHint.
  ///
  /// In fr, this message translates to:
  /// **'Par défaut : le nom de la marque'**
  String get receiptTitleHint;

  /// No description provided for @receiptSubtitleLabel.
  ///
  /// In fr, this message translates to:
  /// **'Sous-titre'**
  String get receiptSubtitleLabel;

  /// No description provided for @receiptSubtitleHint.
  ///
  /// In fr, this message translates to:
  /// **'Ex. : Restaurant & Saveurs'**
  String get receiptSubtitleHint;

  /// No description provided for @receiptSloganLabel.
  ///
  /// In fr, this message translates to:
  /// **'Slogan'**
  String get receiptSloganLabel;

  /// No description provided for @receiptSloganHint.
  ///
  /// In fr, this message translates to:
  /// **'Ex. : Une cuisine authentique, des saveurs du monde'**
  String get receiptSloganHint;

  /// No description provided for @websiteLabel.
  ///
  /// In fr, this message translates to:
  /// **'Site web'**
  String get websiteLabel;

  /// No description provided for @websiteHint.
  ///
  /// In fr, this message translates to:
  /// **'Ex. : www.monrestaurant.com'**
  String get websiteHint;

  /// No description provided for @receiptQrTitleLabel.
  ///
  /// In fr, this message translates to:
  /// **'Titre à côté du QR code'**
  String get receiptQrTitleLabel;

  /// No description provided for @receiptQrCaptionLabel.
  ///
  /// In fr, this message translates to:
  /// **'Texte à côté du QR code'**
  String get receiptQrCaptionLabel;

  /// No description provided for @receiptFarewellLabel.
  ///
  /// In fr, this message translates to:
  /// **'Formule d\'au revoir'**
  String get receiptFarewellLabel;

  /// No description provided for @receiptFarewellHint.
  ///
  /// In fr, this message translates to:
  /// **'Ex. : À très bientôt chez nous'**
  String get receiptFarewellHint;

  /// No description provided for @itemLikesTip.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Aucun J\'aime} =1{1 J\'aime} other{{count} J\'aime}}'**
  String itemLikesTip(int count);

  /// No description provided for @itemReviewAction.
  ///
  /// In fr, this message translates to:
  /// **'Avis'**
  String get itemReviewAction;

  /// No description provided for @itemHeartAction.
  ///
  /// In fr, this message translates to:
  /// **'Cœur'**
  String get itemHeartAction;

  /// No description provided for @itemCommentsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Avis des clients'**
  String get itemCommentsTitle;

  /// No description provided for @itemVerifiedReviews.
  ///
  /// In fr, this message translates to:
  /// **'Avis notés après une commande'**
  String get itemVerifiedReviews;

  /// No description provided for @notifStaffNewOrderTitle.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle commande'**
  String get notifStaffNewOrderTitle;

  /// No description provided for @notifStaffNewOrder.
  ///
  /// In fr, this message translates to:
  /// **'Commande n° {number} {customer} — {branch}'**
  String notifStaffNewOrder(String number, String customer, String branch);

  /// No description provided for @notifStaffOrderReadyTitle.
  ///
  /// In fr, this message translates to:
  /// **'Commande prête à servir'**
  String get notifStaffOrderReadyTitle;

  /// No description provided for @notifStaffOrderReady.
  ///
  /// In fr, this message translates to:
  /// **'Commande n° {number} — {branch}'**
  String notifStaffOrderReady(String number, String branch);

  /// No description provided for @notifStaffReservationTitle.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle réservation'**
  String get notifStaffReservationTitle;

  /// No description provided for @notifStaffReservation.
  ///
  /// In fr, this message translates to:
  /// **'{name} · {count, plural, =1{1 personne} other{{count} personnes}} · {date}'**
  String notifStaffReservation(String name, int count, String date);

  /// No description provided for @notifStaffReviewTitle.
  ///
  /// In fr, this message translates to:
  /// **'Nouvel avis'**
  String get notifStaffReviewTitle;

  /// No description provided for @notifStaffReview.
  ///
  /// In fr, this message translates to:
  /// **'{author} sur « {item} »'**
  String notifStaffReview(String author, String item);

  /// No description provided for @pushNewOrder.
  ///
  /// In fr, this message translates to:
  /// **'Notification sur le téléphone : nouvelle commande d\'un client'**
  String get pushNewOrder;

  /// No description provided for @pushOrderReady.
  ///
  /// In fr, this message translates to:
  /// **'Notification sur le téléphone : commande prête à servir'**
  String get pushOrderReady;

  /// No description provided for @pushReservations.
  ///
  /// In fr, this message translates to:
  /// **'Notification sur le téléphone : nouvelle réservation'**
  String get pushReservations;

  /// No description provided for @pushReviews.
  ///
  /// In fr, this message translates to:
  /// **'Notification sur le téléphone : nouvel avis sur un plat'**
  String get pushReviews;

  /// No description provided for @tablesTab.
  ///
  /// In fr, this message translates to:
  /// **'Tables'**
  String get tablesTab;

  /// No description provided for @tablesNow.
  ///
  /// In fr, this message translates to:
  /// **'Maintenant'**
  String get tablesNow;

  /// No description provided for @tablesLater.
  ///
  /// In fr, this message translates to:
  /// **'Choisir un moment'**
  String get tablesLater;

  /// No description provided for @tableLegendOccupied.
  ///
  /// In fr, this message translates to:
  /// **'Occupée'**
  String get tableLegendOccupied;

  /// No description provided for @tableLegendReserved.
  ///
  /// In fr, this message translates to:
  /// **'Réservée'**
  String get tableLegendReserved;

  /// No description provided for @tableLegendChosen.
  ///
  /// In fr, this message translates to:
  /// **'Votre choix'**
  String get tableLegendChosen;

  /// No description provided for @tableFreeUntil.
  ///
  /// In fr, this message translates to:
  /// **'Libre jusqu\'à {time}'**
  String tableFreeUntil(String time);

  /// No description provided for @tableOccupiedUntil.
  ///
  /// In fr, this message translates to:
  /// **'Libre vers {time}'**
  String tableOccupiedUntil(String time);

  /// No description provided for @tableReservedSlot.
  ///
  /// In fr, this message translates to:
  /// **'Réservée {from}–{to}'**
  String tableReservedSlot(String from, String to);

  /// No description provided for @tablesSelectHint.
  ///
  /// In fr, this message translates to:
  /// **'Touchez une ou plusieurs tables libres pour les réserver.'**
  String get tablesSelectHint;

  /// No description provided for @tablesSeatsChosen.
  ///
  /// In fr, this message translates to:
  /// **'{seats, plural, =1{1 place choisie} other{{seats} places choisies}} pour {party, plural, =1{1 personne} other{{party} personnes}}'**
  String tablesSeatsChosen(int seats, int party);

  /// No description provided for @reserveTablesAction.
  ///
  /// In fr, this message translates to:
  /// **'Réserver {tables}'**
  String reserveTablesAction(String tables);

  /// No description provided for @tableLabelChip.
  ///
  /// In fr, this message translates to:
  /// **'Table {label}'**
  String tableLabelChip(String label);

  /// No description provided for @tablesEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Ce restaurant n\'a pas encore présenté ses tables.'**
  String get tablesEmpty;

  /// No description provided for @appVersion.
  ///
  /// In fr, this message translates to:
  /// **'Resto · version {version} ({build})'**
  String appVersion(String version, String build);

  /// No description provided for @dashTabOverview.
  ///
  /// In fr, this message translates to:
  /// **'Vue d\'ensemble'**
  String get dashTabOverview;

  /// No description provided for @dashTabDishes.
  ///
  /// In fr, this message translates to:
  /// **'Plats'**
  String get dashTabDishes;

  /// No description provided for @dashTabTeam.
  ///
  /// In fr, this message translates to:
  /// **'Équipe et service'**
  String get dashTabTeam;

  /// No description provided for @dashTabFinance.
  ///
  /// In fr, this message translates to:
  /// **'Finances'**
  String get dashTabFinance;

  /// No description provided for @coversLabel.
  ///
  /// In fr, this message translates to:
  /// **'Couverts'**
  String get coversLabel;

  /// No description provided for @perCoverLabel.
  ///
  /// In fr, this message translates to:
  /// **'{amount} par couvert'**
  String perCoverLabel(String amount);

  /// No description provided for @occupancyLabel.
  ///
  /// In fr, this message translates to:
  /// **'Tables occupées'**
  String get occupancyLabel;

  /// No description provided for @paymentsByMethod.
  ///
  /// In fr, this message translates to:
  /// **'Encaissements par moyen de paiement'**
  String get paymentsByMethod;

  /// No description provided for @busyHours.
  ///
  /// In fr, this message translates to:
  /// **'Affluence par jour et par heure'**
  String get busyHours;

  /// No description provided for @menuEngineering.
  ///
  /// In fr, this message translates to:
  /// **'Ingénierie de menu'**
  String get menuEngineering;

  /// No description provided for @menuEngineeringHint.
  ///
  /// In fr, this message translates to:
  /// **'Ventes × marge de chaque plat, d\'après les fiches techniques.'**
  String get menuEngineeringHint;

  /// No description provided for @engStars.
  ///
  /// In fr, this message translates to:
  /// **'Vedettes'**
  String get engStars;

  /// No description provided for @engStarsHint.
  ///
  /// In fr, this message translates to:
  /// **'Très vendus et rentables : gardez-les en avant.'**
  String get engStarsHint;

  /// No description provided for @engPlowhorses.
  ///
  /// In fr, this message translates to:
  /// **'Populaires, peu rentables'**
  String get engPlowhorses;

  /// No description provided for @engPlowhorsesHint.
  ///
  /// In fr, this message translates to:
  /// **'Revoyez le prix ou le coût de revient.'**
  String get engPlowhorsesHint;

  /// No description provided for @engPuzzles.
  ///
  /// In fr, this message translates to:
  /// **'Rentables, peu vendus'**
  String get engPuzzles;

  /// No description provided for @engPuzzlesHint.
  ///
  /// In fr, this message translates to:
  /// **'Mettez-les en avant : photo, publicité, conseil des serveurs.'**
  String get engPuzzlesHint;

  /// No description provided for @engDogs.
  ///
  /// In fr, this message translates to:
  /// **'À revoir'**
  String get engDogs;

  /// No description provided for @engDogsHint.
  ///
  /// In fr, this message translates to:
  /// **'Peu vendus et peu rentables : à retravailler ou à retirer.'**
  String get engDogsHint;

  /// No description provided for @engNoRecipe.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{1 plat sans fiche technique n\'est pas classé.} other{{count} plats sans fiche technique ne sont pas classés.}}'**
  String engNoRecipe(int count);

  /// No description provided for @slowSellers.
  ///
  /// In fr, this message translates to:
  /// **'Plats qui se vendent peu'**
  String get slowSellers;

  /// No description provided for @teamPerformance.
  ///
  /// In fr, this message translates to:
  /// **'Performance de l\'équipe'**
  String get teamPerformance;

  /// No description provided for @memberLabel.
  ///
  /// In fr, this message translates to:
  /// **'Membre'**
  String get memberLabel;

  /// No description provided for @staffOrders.
  ///
  /// In fr, this message translates to:
  /// **'Commandes'**
  String get staffOrders;

  /// No description provided for @staffSales.
  ///
  /// In fr, this message translates to:
  /// **'Ventes'**
  String get staffSales;

  /// No description provided for @staffTips.
  ///
  /// In fr, this message translates to:
  /// **'Pourboires'**
  String get staffTips;

  /// No description provided for @serviceTimes.
  ///
  /// In fr, this message translates to:
  /// **'Temps de service'**
  String get serviceTimes;

  /// No description provided for @serveTime.
  ///
  /// In fr, this message translates to:
  /// **'Mise sur table'**
  String get serveTime;

  /// No description provided for @tableTime.
  ///
  /// In fr, this message translates to:
  /// **'Durée à table'**
  String get tableTime;

  /// No description provided for @minutesValue.
  ///
  /// In fr, this message translates to:
  /// **'{count} min'**
  String minutesValue(int count);

  /// No description provided for @targetMinutes.
  ///
  /// In fr, this message translates to:
  /// **'Objectif : {count} min'**
  String targetMinutes(int count);

  /// No description provided for @cancellationsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Annulations'**
  String get cancellationsTitle;

  /// No description provided for @cancelledOrdersCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Aucune commande annulée} =1{1 commande annulée} other{{count} commandes annulées}}'**
  String cancelledOrdersCount(int count);

  /// No description provided for @cancelledItemsCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Aucun article annulé après envoi} =1{1 article annulé après envoi} other{{count} articles annulés après envoi}}'**
  String cancelledItemsCount(int count);

  /// No description provided for @cancelReasonsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Motifs les plus fréquents'**
  String get cancelReasonsTitle;

  /// No description provided for @dashPdf.
  ///
  /// In fr, this message translates to:
  /// **'Rapport PDF'**
  String get dashPdf;

  /// No description provided for @insightsUnavailable.
  ///
  /// In fr, this message translates to:
  /// **'Les indicateurs détaillés apparaîtront après la mise à jour de la base (migration 034).'**
  String get insightsUnavailable;

  /// No description provided for @salesByDayTitle.
  ///
  /// In fr, this message translates to:
  /// **'Ventes par jour'**
  String get salesByDayTitle;

  /// No description provided for @ordersCountLabel.
  ///
  /// In fr, this message translates to:
  /// **'Commandes'**
  String get ordersCountLabel;

  /// No description provided for @financeItemLabel.
  ///
  /// In fr, this message translates to:
  /// **'Rubrique'**
  String get financeItemLabel;

  /// No description provided for @supplierLabel.
  ///
  /// In fr, this message translates to:
  /// **'Fournisseur'**
  String get supplierLabel;

  /// No description provided for @purchaseOrderTitle.
  ///
  /// In fr, this message translates to:
  /// **'Bon de commande'**
  String get purchaseOrderTitle;

  /// No description provided for @supplierStatementTitle.
  ///
  /// In fr, this message translates to:
  /// **'Relevé de compte fournisseur'**
  String get supplierStatementTitle;

  /// No description provided for @dueDateLabel.
  ///
  /// In fr, this message translates to:
  /// **'Échéance'**
  String get dueDateLabel;

  /// No description provided for @balanceDue.
  ///
  /// In fr, this message translates to:
  /// **'Solde dû'**
  String get balanceDue;

  /// No description provided for @purchasesThisMonth.
  ///
  /// In fr, this message translates to:
  /// **'Achats du mois'**
  String get purchasesThisMonth;

  /// No description provided for @openInvoicesCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Aucune facture à payer} =1{1 facture à payer} other{{count} factures à payer}}'**
  String openInvoicesCount(int count);

  /// No description provided for @overdueInvoices.
  ///
  /// In fr, this message translates to:
  /// **'Factures en retard'**
  String get overdueInvoices;

  /// No description provided for @dueWithinWeek.
  ///
  /// In fr, this message translates to:
  /// **'À payer sous 7 jours'**
  String get dueWithinWeek;

  /// No description provided for @pendingPurchaseOrders.
  ///
  /// In fr, this message translates to:
  /// **'Commandes en cours'**
  String get pendingPurchaseOrders;

  /// No description provided for @paymentSchedule.
  ///
  /// In fr, this message translates to:
  /// **'Échéancier'**
  String get paymentSchedule;

  /// No description provided for @nothingToPay.
  ///
  /// In fr, this message translates to:
  /// **'Aucune facture à payer.'**
  String get nothingToPay;

  /// No description provided for @noDueDate.
  ///
  /// In fr, this message translates to:
  /// **'Sans échéance'**
  String get noDueDate;

  /// No description provided for @purchasesByMonth.
  ///
  /// In fr, this message translates to:
  /// **'Achats par mois'**
  String get purchasesByMonth;

  /// No description provided for @topSuppliers.
  ///
  /// In fr, this message translates to:
  /// **'Principaux fournisseurs (90 jours)'**
  String get topSuppliers;

  /// No description provided for @noPurchasesYet.
  ///
  /// In fr, this message translates to:
  /// **'Aucun achat pour le moment.'**
  String get noPurchasesYet;

  /// No description provided for @totalPurchased.
  ///
  /// In fr, this message translates to:
  /// **'Total acheté'**
  String get totalPurchased;

  /// No description provided for @purchaseOrderPdf.
  ///
  /// In fr, this message translates to:
  /// **'Bon de commande PDF'**
  String get purchaseOrderPdf;

  /// No description provided for @recurringGenerated.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Aucune dépense à générer.} =1{1 dépense récurrente enregistrée.} other{{count} dépenses récurrentes enregistrées.}}'**
  String recurringGenerated(int count);

  /// No description provided for @recurringDue.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{1 dépense récurrente à enregistrer ce mois-ci ({amount})} other{{count} dépenses récurrentes à enregistrer ce mois-ci ({amount})}}'**
  String recurringDue(int count, String amount);

  /// No description provided for @generateNow.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer'**
  String get generateNow;

  /// No description provided for @expensesOfMonth.
  ///
  /// In fr, this message translates to:
  /// **'Dépenses du mois'**
  String get expensesOfMonth;

  /// No description provided for @vsLastMonth.
  ///
  /// In fr, this message translates to:
  /// **'{value} par rapport au mois dernier'**
  String vsLastMonth(String value);

  /// No description provided for @lastMonthLabel.
  ///
  /// In fr, this message translates to:
  /// **'Mois dernier'**
  String get lastMonthLabel;

  /// No description provided for @recurringTab.
  ///
  /// In fr, this message translates to:
  /// **'Récurrentes'**
  String get recurringTab;

  /// No description provided for @budgetsExceeded.
  ///
  /// In fr, this message translates to:
  /// **'Budgets dépassés'**
  String get budgetsExceeded;

  /// No description provided for @expensesSixMonths.
  ///
  /// In fr, this message translates to:
  /// **'Dépenses des six derniers mois'**
  String get expensesSixMonths;

  /// No description provided for @budgetsTab.
  ///
  /// In fr, this message translates to:
  /// **'Budgets'**
  String get budgetsTab;

  /// No description provided for @noBudgetsYet.
  ///
  /// In fr, this message translates to:
  /// **'Aucun budget défini. Fixez-en dans l\'onglet Budgets.'**
  String get noBudgetsYet;

  /// No description provided for @newRecurringExpense.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle dépense récurrente'**
  String get newRecurringExpense;

  /// No description provided for @recurringHint.
  ///
  /// In fr, this message translates to:
  /// **'Loyer, abonnements, salaires… : enregistrés chaque mois en un geste depuis la vue d\'ensemble.'**
  String get recurringHint;

  /// No description provided for @noRecurringYet.
  ///
  /// In fr, this message translates to:
  /// **'Aucune dépense récurrente.'**
  String get noRecurringYet;

  /// No description provided for @everyMonthOn.
  ///
  /// In fr, this message translates to:
  /// **'chaque mois le {day}'**
  String everyMonthOn(int day);

  /// No description provided for @recurringExample.
  ///
  /// In fr, this message translates to:
  /// **'Ex. : Loyer du local'**
  String get recurringExample;

  /// No description provided for @expenseCategoryField.
  ///
  /// In fr, this message translates to:
  /// **'Catégorie'**
  String get expenseCategoryField;

  /// No description provided for @dayOfMonthLabel.
  ///
  /// In fr, this message translates to:
  /// **'Jour du mois'**
  String get dayOfMonthLabel;

  /// No description provided for @budgetsHint.
  ///
  /// In fr, this message translates to:
  /// **'Montant à ne pas dépasser chaque mois, par catégorie. Laissez vide pour ne pas suivre une catégorie.'**
  String get budgetsHint;

  /// No description provided for @startTitle.
  ///
  /// In fr, this message translates to:
  /// **'Bien démarrer'**
  String get startTitle;

  /// No description provided for @startProgress.
  ///
  /// In fr, this message translates to:
  /// **'{done} étapes sur {total} terminées'**
  String startProgress(int done, int total);

  /// No description provided for @startProfile.
  ///
  /// In fr, this message translates to:
  /// **'Compléter la fiche du restaurant (adresse, téléphone, logo)'**
  String get startProfile;

  /// No description provided for @startDishes.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter vos plats et boissons'**
  String get startDishes;

  /// No description provided for @startTables.
  ///
  /// In fr, this message translates to:
  /// **'Créer vos tables'**
  String get startTables;

  /// No description provided for @startPayments.
  ///
  /// In fr, this message translates to:
  /// **'Vérifier vos modes de paiement'**
  String get startPayments;

  /// No description provided for @startTeam.
  ///
  /// In fr, this message translates to:
  /// **'Inviter votre équipe'**
  String get startTeam;

  /// No description provided for @startPublish.
  ///
  /// In fr, this message translates to:
  /// **'Publier votre restaurant pour les clients'**
  String get startPublish;

  /// No description provided for @hideAction.
  ///
  /// In fr, this message translates to:
  /// **'Masquer'**
  String get hideAction;

  /// No description provided for @adPushNote.
  ///
  /// In fr, this message translates to:
  /// **'La notification part aux clients qui suivent le restaurant, y ont commandé dans l\'année, aiment ses plats ou ses publicités, ou habitent à moins de 30 km. Une offre programmée part à sa date de début.'**
  String get adPushNote;

  /// No description provided for @adPushAudience.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Aucun client à prévenir pour l\'instant} =1{1 client recevra cette offre} other{{count} clients recevront cette offre}}'**
  String adPushAudience(int count);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'ar',
    'de',
    'en',
    'es',
    'fr',
    'pt',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+script codes are specified.
  switch (locale.languageCode) {
    case 'zh':
      {
        switch (locale.scriptCode) {
          case 'Hant':
            return AppLocalizationsZhHant();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'pt':
      return AppLocalizationsPt();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
