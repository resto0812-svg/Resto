// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appName => 'Resto';

  @override
  String environmentBanner(String env) {
    return 'Umgebung: $env';
  }

  @override
  String get configMissingTitle => 'Konfiguration fehlt';

  @override
  String get configMissingBody =>
      'Serveradresse und öffentlicher Schlüssel wurden nicht angegeben (Datei env/<Umgebung>.json).';

  @override
  String get languageLabel => 'Sprache';

  @override
  String get systemLanguage => 'Gerätesprache';

  @override
  String pendingSyncEvents(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ausstehende Vorgänge',
      one: '1 ausstehender Vorgang',
      zero: 'Alles synchronisiert',
    );
    return '$_temp0';
  }

  @override
  String get errorNotAuthenticated => 'Bitte melden Sie sich an.';

  @override
  String get errorForbidden =>
      'Sie sind nicht berechtigt, diese Aktion auszuführen.';

  @override
  String get errorOwnerOnly => 'Nur ein Inhaber kann diese Aktion ausführen.';

  @override
  String get errorRateLimited =>
      'Zu viele Anfragen. Bitte versuchen Sie es später erneut.';

  @override
  String get errorInvalidTimezone => 'Unbekannte Zeitzone.';

  @override
  String get errorInvalidRole => 'Unbekannte Rolle.';

  @override
  String get errorInvalidEmail => 'Ungültige E-Mail-Adresse.';

  @override
  String get errorInvalidBranch =>
      'Standort in dieser Organisation nicht gefunden.';

  @override
  String get errorBranchesRequired => 'Wählen Sie mindestens einen Standort.';

  @override
  String get errorAlreadyMember =>
      'Diese Person ist bereits Mitglied der Organisation.';

  @override
  String get errorInvitationInvalid =>
      'Ungültige, abgelaufene oder bereits verwendete Einladung.';

  @override
  String get errorInvitationWrongAccount =>
      'Diese Einladung gilt für eine andere E-Mail-Adresse.';

  @override
  String get errorLastOwner =>
      'Die Organisation muss mindestens einen Inhaber behalten.';

  @override
  String get errorMembershipRevoked =>
      'Dieses Mitglied wurde aus der Organisation entfernt.';

  @override
  String get errorNetwork =>
      'Verbindung nicht möglich. Prüfen Sie Ihren Internetzugang.';

  @override
  String get errorUnknown => 'Ein unerwarteter Fehler ist aufgetreten.';

  @override
  String get welcomeTitle => 'Willkommen bei Resto';

  @override
  String get signInTitle => 'Anmeldung';

  @override
  String get signIn => 'Anmelden';

  @override
  String get signOut => 'Abmelden';

  @override
  String get createAccount => 'Konto erstellen';

  @override
  String get forgotPassword => 'Passwort vergessen';

  @override
  String get email => 'E-Mail';

  @override
  String get password => 'Passwort';

  @override
  String get passwordConfirm => 'Passwort bestätigen';

  @override
  String get passwordTooShort => 'Mindestens 8 Zeichen.';

  @override
  String get passwordsDiffer => 'Die Passwörter stimmen nicht überein.';

  @override
  String get passwordChanged => 'Passwort geändert.';

  @override
  String get newPasswordTitle => 'Neues Passwort';

  @override
  String get changePassword => 'Passwort ändern';

  @override
  String get displayName => 'Name';

  @override
  String get fieldRequired => 'Pflichtfeld';

  @override
  String get verifyEmailTitle => 'E-Mail-Adresse bestätigen';

  @override
  String codeSentTo(String email) {
    return 'Code an $email gesendet.';
  }

  @override
  String get code => 'Code';

  @override
  String get verify => 'Bestätigen';

  @override
  String get resendCode => 'Code erneut senden';

  @override
  String get codeResent => 'Ein neuer Code wurde gesendet.';

  @override
  String get sendCode => 'Code senden';

  @override
  String get authInvalidCredentials => 'E-Mail oder Passwort falsch.';

  @override
  String get authEmailNotConfirmed => 'E-Mail-Adresse nicht bestätigt.';

  @override
  String get authUserExists =>
      'Mit dieser Adresse existiert bereits ein Konto.';

  @override
  String get authWeakPassword => 'Passwort zu schwach.';

  @override
  String get authCodeInvalid => 'Ungültiger oder abgelaufener Code.';

  @override
  String get authSamePassword =>
      'Das neue Passwort muss sich vom alten unterscheiden.';

  @override
  String get errorDuplicate => 'Dieser Wert existiert bereits.';

  @override
  String get errorInvalidHours => 'Ungültige Öffnungszeiten.';

  @override
  String get createRestaurant => 'Mein Restaurant erstellen';

  @override
  String get joinTeam => 'Einem Team beitreten';

  @override
  String get organizationName => 'Name der Organisation';

  @override
  String get brandNameOptional => 'Handelsname (optional)';

  @override
  String get branchNameOptional => 'Name des Standorts (optional)';

  @override
  String get country => 'Land';

  @override
  String get currency => 'Währung';

  @override
  String get timezone => 'Zeitzone';

  @override
  String get defaultLanguage => 'Hauptsprache';

  @override
  String get city => 'Stadt';

  @override
  String get create => 'Erstellen';

  @override
  String get invitationCode => 'Einladungscode';

  @override
  String get join => 'Beitreten';

  @override
  String get navBranches => 'Standorte';

  @override
  String get navTeam => 'Team';

  @override
  String get navAudit => 'Protokoll';

  @override
  String get navAccount => 'Konto';

  @override
  String get switchOrganization => 'Organisation wechseln';

  @override
  String get orgSuspended => 'Organisation gesperrt: nur Lesezugriff.';

  @override
  String get newBranch => 'Neuer Standort';

  @override
  String get noBranches => 'Keine Standorte.';

  @override
  String get branchInfo => 'Angaben';

  @override
  String get openingHours => 'Öffnungszeiten';

  @override
  String get floor => 'Gastraum';

  @override
  String get name => 'Name';

  @override
  String get addressLine1 => 'Adresse';

  @override
  String get addressLine2 => 'Adresszusatz';

  @override
  String get region => 'Region';

  @override
  String get postalCode => 'Postleitzahl';

  @override
  String get phone => 'Telefon';

  @override
  String get offeredLanguages => 'Angebotene Sprachen';

  @override
  String get published => 'Für Gäste sichtbar';

  @override
  String get archived => 'Archiviert';

  @override
  String get readOnly => 'Nur Lesezugriff';

  @override
  String get save => 'Speichern';

  @override
  String get saved => 'Gespeichert.';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get confirm => 'Bestätigen';

  @override
  String get close => 'Schließen';

  @override
  String get edit => 'Bearbeiten';

  @override
  String get retry => 'Erneut versuchen';

  @override
  String get closed => 'Geschlossen';

  @override
  String get addSlot => 'Zeitraum hinzufügen';

  @override
  String get opensAt => 'Öffnung';

  @override
  String get closesAt => 'Schließung';

  @override
  String get nextDay => 'Folgetag';

  @override
  String get weekday1 => 'Montag';

  @override
  String get weekday2 => 'Dienstag';

  @override
  String get weekday3 => 'Mittwoch';

  @override
  String get weekday4 => 'Donnerstag';

  @override
  String get weekday5 => 'Freitag';

  @override
  String get weekday6 => 'Samstag';

  @override
  String get weekday7 => 'Sonntag';

  @override
  String get newArea => 'Neuer Bereich';

  @override
  String get areaName => 'Bereich';

  @override
  String get noAreas => 'Noch keine Bereiche.';

  @override
  String get newTable => 'Neuer Tisch';

  @override
  String get tableLabel => 'Tischname';

  @override
  String get seats => 'Plätze';

  @override
  String get active => 'Aktiv';

  @override
  String get inactive => 'deaktiviert';

  @override
  String tablesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Tische',
      one: '1 Tisch',
      zero: 'keine Tische',
    );
    return '$_temp0';
  }

  @override
  String seatsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Plätze',
      one: '1 Platz',
    );
    return '$_temp0';
  }

  @override
  String get invite => 'Einladen';

  @override
  String get role => 'Rolle';

  @override
  String get allBranches => 'Alle Standorte';

  @override
  String get pendingInvitations => 'Offene Einladungen';

  @override
  String expiresOn(String date) {
    return 'Läuft ab am $date';
  }

  @override
  String get revoke => 'Entfernen';

  @override
  String revokeConfirm(String name) {
    return '$name aus der Organisation entfernen?';
  }

  @override
  String get changeRole => 'Rolle ändern';

  @override
  String get you => 'Sie';

  @override
  String get invitationCreatedTitle => 'Einladung erstellt';

  @override
  String invitationCreatedBody(String email) {
    return 'Senden Sie diesen Code an $email. Er ist 7 Tage gültig und funktioniert nur mit dieser Adresse.';
  }

  @override
  String invitationMessage(String organization, String code) {
    return 'Sie sind eingeladen, „$organization“ auf Resto beizutreten. Erstellen Sie Ihr Konto mit dieser E-Mail-Adresse und geben Sie dann diesen Code unter „Einem Team beitreten“ ein: $code';
  }

  @override
  String get copyMessage => 'Nachricht kopieren';

  @override
  String get copied => 'Kopiert.';

  @override
  String get roleOwner => 'Inhaber';

  @override
  String get roleAdmin => 'Administrator';

  @override
  String get roleManager => 'Leitung';

  @override
  String get roleAccountant => 'Buchhaltung';

  @override
  String get roleCashier => 'Kasse';

  @override
  String get roleStockKeeper => 'Lagerverwaltung';

  @override
  String get roleWaiter => 'Service';

  @override
  String get roleKitchen => 'Küche / Bar';

  @override
  String get roleViewer => 'Nur Lesen';

  @override
  String get loadMore => 'Mehr anzeigen';

  @override
  String get noEntries => 'Keine Vorgänge erfasst.';

  @override
  String get actionInsert => 'Erstellt';

  @override
  String get actionUpdate => 'Geändert';

  @override
  String get actionDelete => 'Gelöscht';

  @override
  String get entityOrganization => 'Organisation';

  @override
  String get entityMembership => 'Mitglied';

  @override
  String get entityInvitation => 'Einladung';

  @override
  String get entityBrand => 'Marke';

  @override
  String get entityBranch => 'Standort';

  @override
  String get entityArea => 'Bereich';

  @override
  String get entityTable => 'Tisch';

  @override
  String get navMenus => 'Speisekarten';

  @override
  String get brand => 'Marke';

  @override
  String get category => 'Kategorie';

  @override
  String get description => 'Beschreibung';

  @override
  String get newCategory => 'Neue Kategorie';

  @override
  String get kindFood => 'Gericht';

  @override
  String get kindDrink => 'Getränk';

  @override
  String get kindOther => 'Sonstiges';

  @override
  String selectionRule(int min, String max) {
    return 'Auswahl: $min bis $max';
  }

  @override
  String get allergens => 'Allergene';

  @override
  String get allergenGluten => 'Gluten';

  @override
  String get allergenCrustaceans => 'Krebstiere';

  @override
  String get allergenEggs => 'Eier';

  @override
  String get allergenFish => 'Fisch';

  @override
  String get allergenPeanuts => 'Erdnüsse';

  @override
  String get allergenSoybeans => 'Soja';

  @override
  String get allergenMilk => 'Milch';

  @override
  String get allergenNuts => 'Schalenfrüchte';

  @override
  String get allergenCelery => 'Sellerie';

  @override
  String get allergenMustard => 'Senf';

  @override
  String get allergenSesame => 'Sesam';

  @override
  String get allergenSulphites => 'Sulfite';

  @override
  String get allergenLupin => 'Lupinen';

  @override
  String get allergenMolluscs => 'Weichtiere';

  @override
  String get translations => 'Übersetzungen';

  @override
  String get soldOut => 'Ausverkauft';

  @override
  String get channelDefault => 'Grundpreis';

  @override
  String get channelDineIn => 'Vor Ort';

  @override
  String get channelTakeaway => 'Zum Mitnehmen';

  @override
  String get channelDelivery => 'Lieferung';

  @override
  String get otherChannels => 'Preise je Kanal';

  @override
  String get noPrice => 'Kein Preis';

  @override
  String get errorInvalidPrice => 'Ungültiger Preis.';

  @override
  String get errorCurrencyLocked =>
      'Die Währung kann nicht mehr geändert werden: An diesem Standort gibt es bereits Preise.';

  @override
  String get entityItem => 'Artikel';

  @override
  String get entityVariant => 'Variante';

  @override
  String get entityModifier => 'Extra';

  @override
  String get entityPrice => 'Preis';

  @override
  String get menuOfBranch => 'Speisekarte des Standorts';

  @override
  String get menuEmptyTitle => 'Ihre Speisekarte ist leer';

  @override
  String get menuEmptyHint =>
      'Legen Sie zuerst eine Kategorie an (zum Beispiel Gerichte, Getränke, Desserts) und fügen Sie dann Ihre Artikel mit Preis hinzu.';

  @override
  String get categoryExamples => 'z. B. Gerichte, Getränke, Desserts';

  @override
  String get descriptionOptional => 'Beschreibung (optional)';

  @override
  String get visibleOnMenu => 'Auf der Karte sichtbar';

  @override
  String get hidden => 'ausgeblendet';

  @override
  String get addItem => 'Artikel hinzufügen';

  @override
  String addItemIn(String category) {
    return 'Artikel zu „$category“ hinzufügen';
  }

  @override
  String get notSoldHere => 'An diesem Standort nicht im Verkauf';

  @override
  String get itemName => 'Name des Artikels';

  @override
  String get itemExamples => 'z. B. Ndolé, Poulet DG, Hibiskussaft';

  @override
  String get priceTitle => 'Preis';

  @override
  String priceAt(String branch) {
    return 'Preis in $branch';
  }

  @override
  String get price => 'Preis';

  @override
  String get severalSizes =>
      'Diesen Artikel gibt es in mehreren Größen oder Formaten';

  @override
  String get sizeName => 'Größe / Format';

  @override
  String get sizeExamples => 'z. B. Klein, 0,33 l';

  @override
  String get addSize => 'Größe hinzufügen';

  @override
  String get removeSize => 'Diese Größe entfernen';

  @override
  String get sizeNameRequired =>
      'Geben Sie jeder Größe einen Namen (zum Beispiel Klein, Groß).';

  @override
  String get samePriceEverywhere =>
      'Dieser Preis gilt an allen unten ausgewählten Standorten; Sie können ihn später für jeden anpassen.';

  @override
  String get salesTitle => 'Verkauf';

  @override
  String soldAt(String branch) {
    return 'Im Verkauf in $branch';
  }

  @override
  String get soldOutToday => 'Derzeit ausverkauft';

  @override
  String get optionsForItem => 'Dem Gast angebotene Optionen';

  @override
  String get manageOptions => 'Optionen verwalten';

  @override
  String get noOptionsYet => 'Noch keine Optionen (Beilage, Garstufe, Soße…).';

  @override
  String get optionsTitle => 'Optionen und Extras';

  @override
  String get optionsIntro =>
      'Eine Option ist eine Wahl, die der Gast bei der Bestellung trifft: Beilage, Garstufe, Soße, kostenpflichtiges Extra…';

  @override
  String get newOptionGroup => 'Neue Option';

  @override
  String get optionGroupName => 'Name der Option';

  @override
  String get optionGroupExamples => 'z. B. Beilage, Garstufe, Schärfe';

  @override
  String get customerMust => 'Der Gast:';

  @override
  String get ruleRequiredOne => 'muss 1 Auswahl treffen (Pflicht)';

  @override
  String get ruleOptionalOne => 'kann 1 Auswahl treffen (optional)';

  @override
  String get ruleOptionalMany => 'kann mehrere Auswahlen treffen (optional)';

  @override
  String get ruleRequiredMany =>
      'muss mindestens 1 Auswahl treffen, mehrere möglich';

  @override
  String get choices => 'Angebotene Auswahl';

  @override
  String choicePriceHint(String branch) {
    return 'Preis leer lassen oder 0, wenn die Auswahl kostenlos ist. Preis für $branch.';
  }

  @override
  String get choiceName => 'Auswahl';

  @override
  String get choiceExamples => 'z. B. Miondo, Reis';

  @override
  String get extraPrice => 'Aufpreis';

  @override
  String get addChoice => 'Auswahl hinzufügen';

  @override
  String get removeChoice => 'Diese Auswahl entfernen';

  @override
  String get choicesRequired => 'Fügen Sie mindestens eine Auswahl hinzu.';

  @override
  String get navOrders => 'Bestellungen';

  @override
  String openOrdersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count offene Bestellungen',
      one: '1 offene Bestellung',
      zero: 'Keine offenen Bestellungen',
    );
    return '$_temp0';
  }

  @override
  String get refresh => 'Aktualisieren';

  @override
  String get newTakeaway => 'Verkauf zum Mitnehmen';

  @override
  String get takeawayOrders => 'Offene Bestellungen zum Mitnehmen';

  @override
  String orderNumber(int number) {
    return 'Bestellung Nr. $number';
  }

  @override
  String minutesAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'vor $count Min.',
      one: 'vor 1 Min.',
      zero: 'gerade eben',
    );
    return '$_temp0';
  }

  @override
  String get noTablesYet =>
      'Keine Tische: Legen Sie den Gastraum unter Standorte → Gastraum an. Verkäufe zum Mitnehmen sind weiterhin möglich.';

  @override
  String get tableFree => 'Frei';

  @override
  String get toSend => 'Artikel an die Küche zu senden';

  @override
  String tableName(String label) {
    return 'Tisch $label';
  }

  @override
  String get menuTab => 'Karte';

  @override
  String ticketTab(int count) {
    return 'Bestellung ($count)';
  }

  @override
  String get allCategories => 'Alle';

  @override
  String get nothingToSell =>
      'Noch nichts zu verkaufen: Fügen Sie unter Speisekarten Artikel mit Preis hinzu.';

  @override
  String fromPrice(String price) {
    return 'ab $price';
  }

  @override
  String itemSoldOut(String name) {
    return '$name ist ausverkauft.';
  }

  @override
  String get emptyTicket =>
      'Tippen Sie auf einen Artikel der Karte, um ihn hinzuzufügen.';

  @override
  String get less => 'Einer weniger';

  @override
  String get more => 'Einer mehr';

  @override
  String get cancelLine => 'Diese Position stornieren';

  @override
  String get cancelOrder => 'Bestellung stornieren';

  @override
  String get cancelOrderConfirm =>
      'Diese Bestellung stornieren? Es wurde noch nichts an die Küche gesendet.';

  @override
  String get reason => 'Grund';

  @override
  String get subtotal => 'Zwischensumme';

  @override
  String taxLine(String rate) {
    return 'Steuer ($rate %)';
  }

  @override
  String get total => 'Gesamt';

  @override
  String taxIncluded(String rate, String amount) {
    return 'inkl. $rate % Steuer: $amount';
  }

  @override
  String sendToKitchen(int count) {
    return 'An die Küche senden ($count)';
  }

  @override
  String sentToKitchen(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Artikel an die Küche gesendet',
      one: '1 Artikel an die Küche gesendet',
    );
    return '$_temp0';
  }

  @override
  String get prepPending => 'Zu senden';

  @override
  String get prepSent => 'In der Küche';

  @override
  String get prepPreparing => 'In Zubereitung';

  @override
  String get prepReady => 'Fertig';

  @override
  String get prepServed => 'Serviert';

  @override
  String get prepCancelled => 'Storniert';

  @override
  String get noneOption => 'Keine';

  @override
  String get kitchenNote => 'Hinweis für die Küche (optional)';

  @override
  String get kitchenNoteExamples => 'z. B. ohne Zwiebeln, durchgebraten';

  @override
  String get quantity => 'Menge';

  @override
  String addForPrice(String price) {
    return 'Hinzufügen · $price';
  }

  @override
  String get taxTitle => 'Steuer';

  @override
  String get taxRate => 'Steuersatz';

  @override
  String get taxRateHint => 'z. B. 19,25 (0 ohne Steuer)';

  @override
  String get pricesIncludeTax => 'Angezeigte Preise enthalten die Steuer';

  @override
  String get errorInvalidTaxRate => 'Ungültiger Satz (0 bis 99,999).';

  @override
  String get errorOrderNotOpen => 'Diese Bestellung ist nicht mehr offen.';

  @override
  String get errorItemUnavailable =>
      'Dieser Artikel ist an diesem Standort nicht verfügbar.';

  @override
  String get errorNoPrice =>
      'Dieser Artikel hat an diesem Standort keinen Preis.';

  @override
  String get errorOptionsInvalid =>
      'Die gewählten Optionen entsprechen nicht den Regeln des Artikels.';

  @override
  String get errorInvalidQuantity => 'Ungültige Menge.';

  @override
  String get errorItemAlreadySent =>
      'Diese Position ist bereits in der Küche und kann nicht mehr geändert werden.';

  @override
  String get errorReasonRequired => 'Bitte geben Sie einen Grund an.';

  @override
  String get errorInvalidOrder => 'Ungültige Bestellung.';

  @override
  String get errorBranchInactive => 'Dieser Standort ist archiviert.';

  @override
  String get navCash => 'Kasse';

  @override
  String get amount => 'Betrag';

  @override
  String get registerClosed => 'geschlossen';

  @override
  String get openRegisterShort => 'Kasse öffnen';

  @override
  String openRegister(String name) {
    return '$name öffnen';
  }

  @override
  String get openingFloat => 'Wechselgeld zu Beginn';

  @override
  String registerOpenSince(String time) {
    return 'geöffnet seit $time';
  }

  @override
  String expectedCash(String amount) {
    return 'Erwartetes Bargeld: $amount';
  }

  @override
  String cashBreakdown(String float, String inAmount, String outAmount) {
    return 'Anfangsbestand $float · Einlagen $inAmount · Entnahmen $outAmount';
  }

  @override
  String paymentsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Zahlungen',
      one: '1 Zahlung',
      zero: 'keine Zahlungen',
    );
    return '$_temp0';
  }

  @override
  String get cashIn => 'Bargeldeinlage';

  @override
  String get cashOut => 'Bargeldentnahme';

  @override
  String get movementExamples => 'z. B. Gaskauf, zusätzliches Wechselgeld';

  @override
  String get closeRegister => 'Kasse schließen';

  @override
  String get countedCash => 'Gezähltes Bargeld in der Schublade';

  @override
  String get countInfo =>
      'Zählen Sie Scheine und Münzen in der Schublade, Anfangsbestand inbegriffen.';

  @override
  String get countResult => 'Zählergebnis';

  @override
  String countedCashValue(String amount) {
    return 'Gezählt: $amount';
  }

  @override
  String get noDifference => 'Keine Differenz';

  @override
  String differenceValue(String amount) {
    return 'Differenz: $amount';
  }

  @override
  String get awaitingValidation =>
      'Eine Leitung muss diesen Abschluss nun bestätigen.';

  @override
  String get awaitingValidationTitle => 'Zu bestätigende Abschlüsse';

  @override
  String get validateClosing => 'Abschluss bestätigen';

  @override
  String get validate => 'Bestätigen';

  @override
  String get comment => 'Kommentar';

  @override
  String get closedSessions => 'Letzte Abschlüsse';

  @override
  String get dailyReport => 'Tagesbericht';

  @override
  String get previousDay => 'Vorheriger Tag';

  @override
  String get nextDayButton => 'Nächster Tag';

  @override
  String get salesTotal => 'Umsatz';

  @override
  String get ordersClosedCount => 'Bezahlte Bestellungen';

  @override
  String get averageTicket => 'Durchschnittsbon';

  @override
  String get taxCollected => 'Eingenommene Steuer';

  @override
  String get paymentsReceived => 'Zahlungen nach Zahlungsart';

  @override
  String ordersStillOpen(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Bestellungen noch offen',
      one: '1 Bestellung noch offen',
      zero: 'keine offenen Bestellungen',
    );
    return '$_temp0';
  }

  @override
  String ordersCancelledCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count storniert',
      one: '1 storniert',
      zero: 'keine storniert',
    );
    return '$_temp0';
  }

  @override
  String linesCancelledCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Positionen storniert',
      one: '1 Position storniert',
      zero: 'keine Position storniert',
    );
    return '$_temp0';
  }

  @override
  String refundsTotal(String amount) {
    return 'erstattet: $amount';
  }

  @override
  String get topItems => 'Meistverkaufte Artikel';

  @override
  String get payCash => 'Bar';

  @override
  String get payCard => 'Karte';

  @override
  String get payMobileMoney => 'Mobile Money';

  @override
  String get payTransfer => 'Überweisung';

  @override
  String get payOther => 'Sonstiges';

  @override
  String get collectPayment => 'Kassieren';

  @override
  String collectAmount(String amount) {
    return '$amount kassieren';
  }

  @override
  String amountDue(String amount) {
    return 'Offener Betrag: $amount';
  }

  @override
  String get splitBill => 'Rechnung teilen';

  @override
  String splitParts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Anteile',
      one: '1 Anteil',
    );
    return '$_temp0';
  }

  @override
  String get amountToCollect => 'Kassierter Betrag';

  @override
  String get cashTendered => 'Vom Gast gegebenes Bargeld (optional)';

  @override
  String changeToGive(String amount) {
    return 'Rückgeld: $amount';
  }

  @override
  String get giveChange => 'Rückgeld';

  @override
  String get transactionReference => 'Transaktionsnummer (optional)';

  @override
  String get manualPaymentNote =>
      'Karte und Mobile Money: Prüfen Sie den Zahlungseingang vor dem Bestätigen.';

  @override
  String get openCashFirst => 'Öffnen Sie zuerst die Kasse (Bereich Kasse).';

  @override
  String get chooseRegister => 'Kasse wählen';

  @override
  String get orderPaidClosed => 'Bestellung bezahlt und abgeschlossen.';

  @override
  String get paid => 'Bereits bezahlt';

  @override
  String get remainingDue => 'Offener Betrag';

  @override
  String get voided => 'storniert';

  @override
  String get voidPayment => 'Diese Zahlung stornieren';

  @override
  String get orderClosed => 'Bestellung bezahlt und abgeschlossen';

  @override
  String get orderCancelled => 'Bestellung storniert';

  @override
  String get errorNoOpenSession => 'Keine geöffnete Kasse für diese Zahlung.';

  @override
  String get errorSessionAlreadyOpen => 'Diese Kasse ist bereits geöffnet.';

  @override
  String get errorRegisterInactive => 'Diese Kasse ist deaktiviert.';

  @override
  String get errorInvalidAmount => 'Ungültiger Betrag.';

  @override
  String get errorNotEnoughCash => 'Nicht genug Bargeld in der Kasse.';

  @override
  String get errorOverpayment => 'Der Betrag übersteigt den offenen Betrag.';

  @override
  String get errorTenderedTooLow =>
      'Das gegebene Bargeld ist geringer als der Betrag.';

  @override
  String get errorOrderHasPayments =>
      'Diese Bestellung hat bereits Zahlungen: stornieren oder erstatten Sie diese zuerst.';

  @override
  String get errorPendingLines =>
      'Einige Artikel wurden noch nicht an die Küche gesendet.';

  @override
  String get errorNotFullyPaid =>
      'Die Bestellung ist nicht vollständig bezahlt.';

  @override
  String get errorSessionNotCounted => 'Diese Kasse wurde noch nicht gezählt.';

  @override
  String get navKitchen => 'Küche';

  @override
  String get allStations => 'Alle Stationen';

  @override
  String get stations => 'Zubereitungsstationen';

  @override
  String get newStation => 'Neue Station';

  @override
  String get stationExamples => 'z. B. Küche, Bar, Grill';

  @override
  String get stationPrepares => 'Diese Station bereitet zu:';

  @override
  String get kitchenEmpty => 'Derzeit nichts zuzubereiten.';

  @override
  String get allReady => 'Alles fertig';

  @override
  String get markServed => 'Serviert';

  @override
  String get errorInvalidStatus => 'Dieser Statuswechsel ist nicht möglich.';

  @override
  String get navStock => 'Lager';

  @override
  String get stockLevels => 'Lagerbestand';

  @override
  String get ingredientsTab => 'Zutaten';

  @override
  String get recipesTab => 'Rezepturen';

  @override
  String get inventoriesTab => 'Inventuren';

  @override
  String get movementsTab => 'Bewegungen';

  @override
  String stockValue(String amount) {
    return 'Lagerwert: $amount';
  }

  @override
  String lowStockCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Zutaten unter dem Mindestbestand',
      one: '1 Zutat unter dem Mindestbestand',
    );
    return '$_temp0';
  }

  @override
  String actionsAt(String location) {
    return 'Bewegungen in: $location';
  }

  @override
  String get newLocation => 'Neuer Lagerort';

  @override
  String get locationExamples => 'z. B. Kühlraum, Keller, Küche';

  @override
  String get chooseLocation => 'Lagerort wählen';

  @override
  String get toLocation => 'Zum Lagerort';

  @override
  String get noIngredientsYet =>
      'Noch keine Zutaten: Fügen Sie welche im Reiter Zutaten hinzu.';

  @override
  String alertAt(String qty) {
    return 'Warnung bei $qty';
  }

  @override
  String avgCost(String amount, String unit) {
    return 'Durchschnittskosten $amount / $unit';
  }

  @override
  String get alertThreshold => 'Mindestbestand';

  @override
  String get alertBelow => 'Warnen unter';

  @override
  String get produce => 'Herstellen';

  @override
  String get adjustmentQuantity => 'Korrektur (+ oder −)';

  @override
  String unitCost(String unit) {
    return 'Kosten pro $unit';
  }

  @override
  String get unitPiece => 'Stück';

  @override
  String get unitDozen => 'Dutzend';

  @override
  String get newIngredient => 'Neue Zutat';

  @override
  String get ingredientExamples =>
      'z. B. Hähnchen, Palmöl, Cola-Flasche 0,33 l';

  @override
  String get ingredientKind => 'Art';

  @override
  String get stockUnit => 'Lagereinheit';

  @override
  String get ingRaw => 'Rohstoff';

  @override
  String get ingBeverage => 'Getränk';

  @override
  String get ingPackaging => 'Verpackung';

  @override
  String get ingSemiFinished => 'Hausgemachte Zubereitung';

  @override
  String get ingConsumable => 'Verbrauchsmaterial';

  @override
  String get mvOpening => 'Anfangsbestand';

  @override
  String get mvReceipt => 'Wareneingang (Einkauf)';

  @override
  String get mvSale => 'Verkauf';

  @override
  String get mvProductionIn => 'Herstellung';

  @override
  String get mvProductionOut => 'In Herstellung verbraucht';

  @override
  String get mvWaste => 'Verlust / Bruch';

  @override
  String get mvStaffMeal => 'Personalessen';

  @override
  String get mvReturn => 'Rücksendung an Lieferanten';

  @override
  String get mvTransferIn => 'Umlagerung erhalten';

  @override
  String get mvTransferOut => 'Umlagerung';

  @override
  String get mvAdjustment => 'Korrektur';

  @override
  String get mvInventory => 'Inventurdifferenz';

  @override
  String get recipesIntro =>
      'Eine Rezeptur listet die Zutaten eines Gerichts: Der Bestand sinkt bei jedem bezahlten Verkauf automatisch, und die Herstellkosten werden berechnet.';

  @override
  String get noRecipe => 'Keine Rezeptur';

  @override
  String costPrice(String amount) {
    return 'Herstellkosten: $amount';
  }

  @override
  String sellingPrice(String amount) {
    return 'Preis $amount';
  }

  @override
  String marginPercent(int percent) {
    return 'Marge $percent %';
  }

  @override
  String recipeOf(String name) {
    return 'Rezeptur: $name';
  }

  @override
  String get portions => 'Anzahl Portionen';

  @override
  String get yieldQuantity => 'Hergestellte Menge';

  @override
  String get ingredient => 'Zutat';

  @override
  String get wastePercent => 'Verlust';

  @override
  String get removeLine => 'Zeile entfernen';

  @override
  String get addIngredientLine => 'Zutat hinzufügen';

  @override
  String get preparationNotes => 'Zubereitungshinweise (optional)';

  @override
  String get newInventory => 'Neue Inventur';

  @override
  String get inventoriesIntro =>
      'Eine Inventur vergleicht den gezählten mit dem berechneten Bestand; Differenzen werden nach Bestätigung durch eine Leitung gebucht.';

  @override
  String inventoryValidated(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'bestätigt, $count Differenzen',
      one: 'bestätigt, 1 Differenz',
      zero: 'bestätigt, keine Differenz',
    );
    return '$_temp0';
  }

  @override
  String inventoryDraft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'in Arbeit, $count Zeilen gezählt',
      one: 'in Arbeit, 1 Zeile gezählt',
      zero: 'in Arbeit, nichts gezählt',
    );
    return '$_temp0';
  }

  @override
  String inventoryOf(String location) {
    return 'Inventur: $location';
  }

  @override
  String get inventoryHint =>
      'Geben Sie ein, was Sie tatsächlich zählen. Leere Zeilen werden nicht geändert.';

  @override
  String inventoryDifference(String qty) {
    return 'Differenz $qty';
  }

  @override
  String get search => 'Suchen';

  @override
  String get validateInventory => 'Inventur bestätigen';

  @override
  String get validateInventoryConfirm =>
      'Diese Inventur bestätigen? Die Differenzen werden im Bestand gebucht und die Inventur kann nicht mehr geändert werden.';

  @override
  String inventoryAdjustments(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Inventur bestätigt: $count Differenzen gebucht',
      one: 'Inventur bestätigt: 1 Differenz gebucht',
      zero: 'Inventur bestätigt: keine Differenz',
    );
    return '$_temp0';
  }

  @override
  String get errorInvalidMovement => 'Ungültige Lagerbewegung.';

  @override
  String get errorUnitLocked =>
      'Die Lagereinheit kann nicht mehr geändert werden: Diese Zutat hat bereits Bewegungen.';

  @override
  String get errorNoRecipe => 'Diese Zubereitung hat keine Rezeptur.';

  @override
  String get errorInvalidRecipe =>
      'Ungültige Rezeptur: Prüfen Sie Zutaten, Mengen und Einheiten.';

  @override
  String get errorInventoryClosed => 'Diese Inventur ist bereits bestätigt.';

  @override
  String get navGroupService => 'Service';

  @override
  String get navGroupManagement => 'Verwaltung';

  @override
  String get navGroupOrganization => 'Organisation';

  @override
  String get navPurchases => 'Einkauf';

  @override
  String get navExpenses => 'Ausgaben';

  @override
  String get navReports => 'Berichte';

  @override
  String get invoicesTab => 'Rechnungen';

  @override
  String get purchaseOrdersTab => 'Bestellungen';

  @override
  String get receiptsTab => 'Wareneingänge';

  @override
  String get suppliersTab => 'Lieferanten';

  @override
  String get newSupplier => 'Neuer Lieferant';

  @override
  String get noSuppliersYet =>
      'Noch keine Lieferanten. Fügen Sie Ihre üblichen Lieferanten hinzu (Markt, Großhändler, Brauerei…).';

  @override
  String get addSupplierFirst =>
      'Fügen Sie zuerst einen Lieferanten hinzu (Reiter Lieferanten).';

  @override
  String get contactName => 'Ansprechpartner';

  @override
  String get taxId => 'Steuernummer';

  @override
  String get paymentTermsLabel => 'Zahlungsziel';

  @override
  String get days => 'Tage';

  @override
  String paymentTerms(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Zahlung in $days Tagen',
      one: 'Zahlung in 1 Tag',
    );
    return '$_temp0';
  }

  @override
  String get supplier => 'Lieferant';

  @override
  String get supplierOptional => 'Lieferant (optional)';

  @override
  String get newPurchaseOrder => 'Neue Bestellung';

  @override
  String get noPurchaseOrders =>
      'Keine Bestellungen. Eine Bestellung bereitet einen Einkauf vor; bei Lieferung bucht „Empfangen“ die Ware ins Lager.';

  @override
  String poNumber(int number) {
    return 'Bestellung Nr. $number';
  }

  @override
  String get poDraft => 'Entwurf';

  @override
  String get poSent => 'gesendet';

  @override
  String get poPartial => 'teilweise erhalten';

  @override
  String get poReceived => 'erhalten';

  @override
  String get poCancelled => 'storniert';

  @override
  String get poMarkSent => 'Als gesendet markieren';

  @override
  String get poReceive => 'Empfangen';

  @override
  String get poCancel => 'Bestellung stornieren';

  @override
  String get cancelPoConfirm => 'Diese Bestellung stornieren?';

  @override
  String expectedOn(String date) {
    return 'Lieferung erwartet am $date';
  }

  @override
  String get expectedDateOptional => 'Erwartetes Lieferdatum (optional)';

  @override
  String unitPrice(String unit) {
    return 'Preis pro $unit';
  }

  @override
  String totalAmount(String amount) {
    return 'Gesamt: $amount';
  }

  @override
  String get newReceipt => 'Neuer Wareneingang';

  @override
  String get receiptsIntro =>
      'Ein Wareneingang erfasst die gelieferte Ware: Bestand und Durchschnittskosten werden automatisch aktualisiert.';

  @override
  String receiveOrder(int number) {
    return 'Wareneingang zu Bestellung Nr. $number';
  }

  @override
  String get receiptHint =>
      'Geben Sie die tatsächlich gelieferten Mengen und Preise ein; sie werden beim Speichern eingebucht.';

  @override
  String get deliveryNoteNumber => 'Lieferscheinnummer (optional)';

  @override
  String get recordReceipt => 'Wareneingang buchen';

  @override
  String get receiptRecorded =>
      'Wareneingang gebucht: Der Bestand ist aktuell.';

  @override
  String get newInvoice => 'Neue Rechnung';

  @override
  String get invoicesIntro =>
      'Erfassen Sie hier die Rechnungen Ihrer Lieferanten, um Ihre Schulden und Zahlungen zu verfolgen.';

  @override
  String supplierDebt(String amount) {
    return 'Gesamtschulden bei Lieferanten: $amount';
  }

  @override
  String dueOn(String date) {
    return 'fällig am $date';
  }

  @override
  String remaining(String amount) {
    return 'offen $amount';
  }

  @override
  String get invoicePaid => 'bezahlt';

  @override
  String get invoiceCancelled => 'storniert';

  @override
  String get invoiceNumber => 'Rechnungsnummer des Lieferanten';

  @override
  String invoiceDateValue(String date) {
    return 'Rechnung vom $date';
  }

  @override
  String get dueDateOptional =>
      'Fälligkeit (optional: Zahlungsziel des Lieferanten)';

  @override
  String get amountExclTax => 'Nettobetrag';

  @override
  String get taxAmount => 'Steuer';

  @override
  String get linkedReceipts => 'Zugehörige Wareneingänge';

  @override
  String get attachDocument => 'Beleg anhängen (PDF oder Foto)';

  @override
  String get fileTooLarge => 'Datei zu groß (höchstens 5 MB).';

  @override
  String get viewDocument => 'Beleg ansehen';

  @override
  String get payInvoice => 'Bezahlen';

  @override
  String get cancelInvoice => 'Rechnung stornieren';

  @override
  String get paidFromRegister => 'Mit Bargeld aus der Kasse bezahlt';

  @override
  String get newExpense => 'Neue Ausgabe';

  @override
  String get noExpenses => 'Keine Ausgaben in diesem Monat.';

  @override
  String get previousMonth => 'Vorheriger Monat';

  @override
  String get nextMonth => 'Nächster Monat';

  @override
  String includingTax(String amount) {
    return 'davon Steuer $amount';
  }

  @override
  String get cancelledLabel => 'storniert';

  @override
  String get cancelExpense => 'Ausgabe stornieren';

  @override
  String get expenseExamples =>
      'z. B. Stromrechnung Oktober, Reparatur des Gefrierschranks';

  @override
  String get amountInclTax => 'Bezahlter Betrag';

  @override
  String get includedTaxOptional => 'Davon Steuer (optional)';

  @override
  String get expRent => 'Miete';

  @override
  String get expElectricity => 'Strom';

  @override
  String get expWater => 'Wasser';

  @override
  String get expGas => 'Gas';

  @override
  String get expSalaries => 'Gehälter';

  @override
  String get expTransport => 'Transport';

  @override
  String get expMaintenance => 'Wartung und Reparaturen';

  @override
  String get expMarketing => 'Werbung';

  @override
  String get expSupplies => 'Material';

  @override
  String get expTaxes => 'Steuern und Abgaben';

  @override
  String get expBankFees => 'Bankgebühren';

  @override
  String get expOther => 'Sonstiges';

  @override
  String get periodToday => 'Heute';

  @override
  String get periodLast7 => 'Letzte 7 Tage';

  @override
  String get periodMonth => 'Dieser Monat';

  @override
  String get periodLastMonth => 'Letzter Monat';

  @override
  String get periodCustom => 'Anderer Zeitraum…';

  @override
  String get salesInclTax => 'Umsatz brutto';

  @override
  String get salesExclTax => 'Umsatz netto';

  @override
  String get collected => 'Einnahmen';

  @override
  String get costOfSales => 'Wareneinsatz';

  @override
  String get grossMargin => 'Rohertrag';

  @override
  String get lossesValue => 'Verluste und Differenzen';

  @override
  String get expensesExclTax => 'Ausgaben netto';

  @override
  String get estimatedResult => 'Geschätztes Ergebnis';

  @override
  String get purchasesValue => 'Einkäufe (Rechnungen netto)';

  @override
  String get supplierDebtShort => 'Lieferantenschulden';

  @override
  String ordersCountShort(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Bestellungen',
      one: '1 Bestellung',
      zero: 'keine Bestellungen',
    );
    return '$_temp0';
  }

  @override
  String get ruleSales =>
      'Summe der bezahlten und abgeschlossenen Bestellungen im Zeitraum (Servicedatum).';

  @override
  String get ruleSalesHt => 'Bruttoumsatz abzüglich eingenommener Steuer.';

  @override
  String get ruleCollected =>
      'Tatsächlich eingenommenes Geld im Zeitraum, alle Zahlungsarten, abzüglich Erstattungen. Kann vom Umsatz abweichen (Anzahlungen, offene Bestellungen).';

  @override
  String get ruleCogs =>
      'Wert der durch Verkäufe verbrauchten Zutaten laut Rezepturen und Durchschnittseinkaufspreis. Gerichte ohne Rezeptur sind nicht enthalten.';

  @override
  String get ruleGrossMargin => 'Nettoumsatz abzüglich Wareneinsatz.';

  @override
  String get ruleLosses =>
      'Wert von Verlusten, Personalessen, Korrekturen und Inventurdifferenzen.';

  @override
  String get ruleExpenses =>
      'Im Zeitraum erfasste Ausgaben, netto (stornierte Ausgaben ausgenommen).';

  @override
  String get ruleResult =>
      'Rohertrag abzüglich Verluste und Ausgaben. Eine Managementschätzung ohne Abschreibungen oder nicht erfasste Kosten: kein buchhalterisches Ergebnis.';

  @override
  String get rulePurchases =>
      'Lieferantenrechnungen (netto) mit Datum im Zeitraum. Einkäufe gehen ins Lager: Sie sind erst bei Verbrauch Kosten.';

  @override
  String get ruleDebt =>
      'Noch offene Beträge auf offenen Lieferantenrechnungen, Stand heute.';

  @override
  String get expensesByCategory => 'Ausgaben nach Kategorie (netto)';

  @override
  String get resultDisclaimer =>
      'Diese Zahlen werden aus den in Resto erfassten Vorgängen berechnet: Verkäufe, Zahlungen, theoretischer Verbrauch, Ausgaben. Fahren Sie über ⓘ für die Regel jedes Kennwerts.';

  @override
  String get exportsTitle => 'Exporte (CSV-Dateien, in Excel zu öffnen)';

  @override
  String get exportOrders => 'Bestellungen';

  @override
  String get exportPayments => 'Zahlungen';

  @override
  String get exportExpenses => 'Ausgaben';

  @override
  String get exportDownloaded => 'Datei heruntergeladen.';

  @override
  String get exportCopied =>
      'Daten kopiert: Fügen Sie sie in eine Tabelle ein.';

  @override
  String get marginsByItem => 'Marge pro Gericht';

  @override
  String marginsHint(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Gerichte haben noch keine Rezeptur (Lager → Rezepturen).',
      one: '1 Gericht hat noch keine Rezeptur (Lager → Rezepturen).',
      zero: 'Alle verkauften Gerichte haben eine Rezeptur.',
    );
    return '$_temp0';
  }

  @override
  String get errorInvalidPurchase =>
      'Unvollständiger Einkauf: Prüfen Sie Lieferant, Zutaten, Mengen, Einheiten und Preise.';

  @override
  String get errorPurchaseNotDraft =>
      'Diese Bestellung kann nicht mehr geändert werden.';

  @override
  String get errorDuplicateInvoice =>
      'Diese Rechnung dieses Lieferanten ist bereits erfasst.';

  @override
  String get errorInvoiceNotOpen => 'Diese Rechnung ist nicht mehr offen.';

  @override
  String get errorInvoiceHasPayments =>
      'Diese Rechnung hat Zahlungen: Stornieren Sie diese zuerst.';

  @override
  String get errorInvalidExpense =>
      'Unvollständige Ausgabe: Kategorie, Beschreibung und Betrag sind Pflicht; die Steuer darf den Betrag nicht übersteigen.';

  @override
  String get errorInvalidAttachment => 'Beleg abgelehnt.';

  @override
  String get errorInvalidPeriod => 'Ungültiger Zeitraum.';

  @override
  String get errorBelowMinimum => 'Mindestbestellwert nicht erreicht.';

  @override
  String get errorDeliveryUnavailable =>
      'Lieferung nicht möglich: Adresse und Telefonnummer prüfen oder „Zum Mitnehmen“ wählen.';

  @override
  String get errorInvalidImage =>
      'Foto abgelehnt (ungültiges Format oder ungültiger Speicherort).';

  @override
  String get errorNotFound => 'Nicht gefunden.';

  @override
  String get errorOnlineOrdersClosed =>
      'Dieses Restaurant nimmt derzeit keine Online-Bestellungen an.';

  @override
  String get errorTooLateToCancel =>
      'Zu spät: Das Restaurant bearbeitet die Bestellung bereits.';

  @override
  String get errorReviewNotAllowed =>
      'Bewertung nicht möglich: Nur eine bezahlte Bestellung, jünger als 30 Tage, kann einmal bewertet werden.';

  @override
  String get errorReservationsClosed =>
      'Dieses Restaurant nimmt keine Online-Reservierungen an.';

  @override
  String get errorInvalidPartySize =>
      'Personenzahl für eine Online-Reservierung nicht zulässig.';

  @override
  String get errorInvalidReservationTime =>
      'Ungültige Uhrzeit: mindestens 15 Minuten im Voraus und höchstens 90 Tage.';

  @override
  String get errorInvalidReservation =>
      'Reservierung unvollständig: Name, Telefon und Personenzahl sind erforderlich.';

  @override
  String get errorTablesRequired => 'Wählen Sie mindestens einen Tisch.';

  @override
  String get errorNotEnoughSeats =>
      'Nicht genug Plätze an den gewählten Tischen.';

  @override
  String get errorTableUnavailable =>
      'Dieser Tisch ist zu dieser Zeit bereits reserviert.';

  @override
  String get errorPromotionUnavailable => 'Aktion oder Code ungültig.';

  @override
  String get errorPromotionLimit =>
      'Dieser Gast hat die Aktion bereits so oft wie erlaubt genutzt.';

  @override
  String get errorPromotionAlreadyApplied =>
      'Bereits auf diese Bestellung angewendet.';

  @override
  String get errorNotEnoughPoints => 'Nicht genug Treuepunkte.';

  @override
  String get errorAddressRequired => 'Lieferadresse erforderlich.';

  @override
  String get errorTableBusy => 'An diesem Tisch läuft bereits eine Bestellung.';

  @override
  String errorBetween(int min, int max) {
    return 'Zwischen $min und $max';
  }

  @override
  String get notPublishedHint =>
      'Dieser Standort ist für Gäste noch nicht sichtbar: Aktivieren Sie „Veröffentlicht“ im Reiter Informationen.';

  @override
  String get onlineOrdersTitle => 'Online-Bestellungen';

  @override
  String get acceptOnlineOrders => 'Bestellungen der Gäste annehmen';

  @override
  String get acceptOnlineOrdersHint =>
      'Über die App, die Website oder die QR-Codes der Tische. Jede Bestellung erscheint unter „Bestellungen“ zur Annahme.';

  @override
  String get acceptDelivery => 'Lieferung anbieten';

  @override
  String get deliveryFee => 'Liefergebühr';

  @override
  String get minimumOrder => 'Mindestbestellwert';

  @override
  String get reservationsTitle => 'Reservierungen';

  @override
  String get acceptReservations => 'Online-Reservierungen annehmen';

  @override
  String get reservationDuration => 'Dauer einer Reservierung';

  @override
  String get minutesShort => 'Min.';

  @override
  String get maxPartySize => 'Maximale Personenzahl';

  @override
  String get publicProfileTitle => 'Öffentliches Restaurantprofil';

  @override
  String get publicDescription => 'Beschreibung';

  @override
  String get publicDescriptionHint =>
      'Z. B. großzügige kamerunische Küche, gegrillter Fisch des Tages, schattige Terrasse.';

  @override
  String get cuisinesLabel => 'Küchenarten';

  @override
  String get cuisinesHint =>
      'Z. B. afrikanisch, Grill, Meeresfrüchte (durch Kommas getrennt)';

  @override
  String get priceLevel => 'Preisklasse';

  @override
  String get publicPageTitle => 'Restaurantseite';

  @override
  String get publicPageHint =>
      'Zum Teilen (soziale Netzwerke, WhatsApp) oder Ausdrucken: Gäste sehen dort die Karte und bestellen.';

  @override
  String get copyLink => 'Link kopieren';

  @override
  String get sourcePhone => 'Per Telefon';

  @override
  String get sourceQr => 'QR-Code des Tisches';

  @override
  String get sourceApp => 'Gäste-App';

  @override
  String get sourcePartner => 'Partner';

  @override
  String get sourceStaff => 'Im Gastraum aufgenommen';

  @override
  String get stageToValidate => 'Zu bestätigen';

  @override
  String get stageDraft => 'Noch nicht gesendet';

  @override
  String get stageCooking => 'In Zubereitung';

  @override
  String get stageReady => 'Servierbereit';

  @override
  String get stageReadyTakeaway => 'Abholbereit';

  @override
  String get stageReadyDelivery => 'Bereit für den Kurier';

  @override
  String get stageToPay => 'Zu kassieren';

  @override
  String get stageDone => 'Abgeschlossen';

  @override
  String get stageCancelled => 'Storniert';

  @override
  String get handToCustomer => 'An Gast übergeben';

  @override
  String get handToCourier => 'An Kurier übergeben';

  @override
  String guestsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Personen',
      one: '1 Person',
    );
    return '$_temp0';
  }

  @override
  String forTime(String time) {
    return 'Für $time';
  }

  @override
  String get billTitle => 'Rechnung';

  @override
  String get thankYou => 'Vielen Dank für Ihren Besuch!';

  @override
  String kdsToPrepare(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Bestellungen zuzubereiten',
      one: '1 Bestellung zuzubereiten',
      zero: 'Nichts zuzubereiten',
    );
    return '$_temp0';
  }

  @override
  String kdsLate(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count verspätet',
      one: '1 verspätet',
    );
    return '$_temp0';
  }

  @override
  String kdsReadyCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fertig',
      one: '1 fertig',
      zero: 'Keine fertig',
    );
    return '$_temp0';
  }

  @override
  String get kdsTickets => 'Bons';

  @override
  String get kdsSummary => 'Summen';

  @override
  String get kdsFullScreen => 'Vollbild (Küchenmodus)';

  @override
  String get kdsFlowHint =>
      'Vom Gastraum gesendete Bestellungen erscheinen hier mit einem Signalton. Tippen Sie auf einen Artikel für „in Zubereitung“, dann „fertig“. „Alles fertig“ benachrichtigt sofort das Servicepersonal.';

  @override
  String get kdsReadyStrip =>
      'Fertig — der Gastraum ist informiert (Spalte „Servierbereit“), wartet auf Service';

  @override
  String get kdsStart => 'Beginnen';

  @override
  String kdsWaitingService(String time) {
    return 'wartet seit $time';
  }

  @override
  String get kdsRecall => 'Zurückholen (noch nicht fertig)';

  @override
  String get serviceAndCustomers => 'Service & Gäste';

  @override
  String get serviceSettingsTitle => 'Service';

  @override
  String get targetPrepTime => 'Ziel-Zubereitungszeit';

  @override
  String get targetPrepTimeHint =>
      'Danach wird die Bestellung rot (verspätet).';

  @override
  String get payFirstTakeaway => 'Zum Mitnehmen: vor der Zubereitung kassieren';

  @override
  String get payFirstTakeawayHint =>
      'Die Schaltfläche „Kassieren, dann senden“ erscheint bei Bestellungen zum Mitnehmen.';

  @override
  String get tableOccupied => 'Besetzt';

  @override
  String get tableReservedNow => 'Jetzt reserviert';

  @override
  String get tableReservedSoon => 'Bald reserviert';

  @override
  String reservedAt(String time) {
    return 'Reserviert um $time';
  }

  @override
  String get acceptWithDelay => 'Bestellung annehmen';

  @override
  String scheduledFor(String time) {
    return 'Gewünscht für $time';
  }

  @override
  String get delayAnnounced => 'Wann ist sie fertig? Der Gast wird informiert.';

  @override
  String get orderAccepted =>
      'Bestellung angenommen: Sie geht in die Zubereitung.';

  @override
  String get rejectOrder => 'Bestellung ablehnen';

  @override
  String get rejectReasonHint =>
      'Z. B. Fisch ausverkauft, kein Kurier verfügbar';

  @override
  String get paymentDone => 'Zahlung erfasst.';

  @override
  String get partialPaymentDone => 'Teilzahlung erfasst.';

  @override
  String get announcedDelay => 'Dem Gast angekündigte Zeit';

  @override
  String promisedFor(String time) {
    return 'Zugesagt für $time';
  }

  @override
  String get heldShort => 'folgt';

  @override
  String moreItems(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '+ $count weitere Artikel',
      one: '+ 1 weiterer Artikel',
    );
    return '$_temp0';
  }

  @override
  String get paidShort => 'Bezahlt';

  @override
  String get partlyPaid => 'Teilweise bezahlt';

  @override
  String get notPaid => 'Nicht bezahlt';

  @override
  String get reject => 'Ablehnen';

  @override
  String get accept => 'Annehmen';

  @override
  String get sendShort => 'Senden';

  @override
  String get fireNext => 'Nächsten Gang abrufen';

  @override
  String get collectShort => 'Kassieren';

  @override
  String get columnInProgress => 'Laufend';

  @override
  String get columnReady => 'Servierbereit';

  @override
  String get columnToValidateHint =>
      'Von Gästen aufgegebene Bestellungen (App, Website, QR-Codes der Tische) erscheinen hier mit Signalton. Nehmen Sie sie mit einer Zeitangabe an.';

  @override
  String get columnInProgressHint =>
      'Aufgenommene Bestellungen in Zubereitung. „Senden“ schickt die Artikel an Küche und Bar.';

  @override
  String get columnReadyHint =>
      'Wenn die Küche „Alles fertig“ tippt, erscheint die Bestellung hier (mit Signalton): am Tisch servieren, dem Gast oder dem Kurier übergeben.';

  @override
  String get columnToPayHint =>
      'Alles serviert: Es bleibt zu kassieren. Nach der Zahlung ist die Bestellung abgeschlossen und der Tisch frei.';

  @override
  String get allOrders => 'Alle';

  @override
  String get searchOrderHint => 'Nr., Gast, Tisch, Telefon';

  @override
  String get chooseTable => 'Tisch wählen';

  @override
  String get tableHasOrder =>
      'An diesem Tisch läuft bereits eine Bestellung: Sie wird geöffnet.';

  @override
  String tableReservationWarning(String time, String name, int count) {
    return 'Achtung: reserviert um $time · $name · $count Pers.';
  }

  @override
  String get guestsLabel => 'Personenzahl';

  @override
  String get receivedByPhone => 'Telefonisch erhaltene Bestellung';

  @override
  String get customerName => 'Name des Gastes';

  @override
  String get customerNameOptional => 'Name des Gastes (optional)';

  @override
  String get phoneOptional => 'Telefon (optional)';

  @override
  String get deliveryAddress => 'Lieferadresse';

  @override
  String get deliveryAddressHint =>
      'Viertel, Straße, Orientierungspunkt (z. B. Bonamoussadi, neben der Apotheke)';

  @override
  String get deliveryInstructions => 'Hinweise für den Kurier';

  @override
  String get deliveryInstructionsHint =>
      'Z. B. gelbes Gebäude, 2. Stock, bei Ankunft anrufen';

  @override
  String get deliveryTime => 'Lieferzeit';

  @override
  String get pickupTime => 'Abholzeit';

  @override
  String get asap => 'So bald wie möglich';

  @override
  String get atFixedTime => 'Zu einer festen Uhrzeit';

  @override
  String atTime(String time) {
    return 'Um $time';
  }

  @override
  String get newOrder => 'Neue Bestellung';

  @override
  String get orderTypeQuestion => 'Welche Art von Bestellung?';

  @override
  String get dineInHint => 'Gast sitzt an einem Tisch';

  @override
  String get takeawayHint => 'Der Gast nimmt die Bestellung mit';

  @override
  String get deliveryHint => 'An eine Adresse geliefert';

  @override
  String get orderNote => 'Hinweis zur Bestellung (optional)';

  @override
  String get orderNoteHint => 'Z. B. Geburtstag, Gast in Eile, Erdnussallergie';

  @override
  String get continueToMenu => 'Weiter: Gerichte wählen';

  @override
  String get moveTable => 'Tisch wechseln';

  @override
  String get noFreeTable => 'Derzeit kein freier Tisch.';

  @override
  String get print => 'Drucken';

  @override
  String get printKitchenTicket => 'Zubereitungsbon (Küche)';

  @override
  String get printBill => 'Rechnung (Gast)';

  @override
  String get orderHistory => 'Verlauf der Bestellung';

  @override
  String get searchDish => 'Gericht, Getränk suchen…';

  @override
  String get noResults => 'Keine Ergebnisse.';

  @override
  String get groupToSend => 'Zu senden';

  @override
  String get groupHeld => 'Folgt (später gesendet)';

  @override
  String get groupCooking => 'In Zubereitung';

  @override
  String get groupReady => 'Servierbereit';

  @override
  String get groupServed => 'Serviert';

  @override
  String get groupCancelled => 'Storniert';

  @override
  String collectThenSend(String amount) {
    return '$amount kassieren, dann senden';
  }

  @override
  String fireNextCount(int count) {
    return 'Nächsten Gang abrufen ($count)';
  }

  @override
  String get customerOrderToValidate => 'Gastbestellung zu bestätigen';

  @override
  String get customerOrderToValidateHint =>
      'Artikel prüfen, dann annehmen (mit Zeitangabe) oder ablehnen. Der Gast wird informiert.';

  @override
  String get payFirstHint =>
      'Zum Mitnehmen: Zahlung vor der Zubereitung (Standorteinstellung).';

  @override
  String get addedByCustomer => 'vom Gast hinzugefügt';

  @override
  String get sendWithOrder => 'Mit dem Rest senden';

  @override
  String get holdForLater => 'Als „folgt“ markieren (später gesendet)';

  @override
  String openedAt(String time) {
    return 'geöffnet um $time';
  }

  @override
  String get fromReservation => 'Gäste platziert (Reservierung)';

  @override
  String get editOrderDetails => 'Angaben ändern';

  @override
  String get evOpened => 'Bestellung eröffnet';

  @override
  String evItemAdded(String item) {
    return 'Hinzugefügt: $item';
  }

  @override
  String get evItemUpdated => 'Artikel geändert';

  @override
  String get evItemRemoved => 'Artikel entfernt';

  @override
  String evSent(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'An die Küche gesendet ($count Artikel)',
      one: 'An die Küche gesendet (1 Artikel)',
    );
    return '$_temp0';
  }

  @override
  String get evItemCancelled => 'Artikel storniert';

  @override
  String get evCancelled => 'Bestellung storniert';

  @override
  String get evClosed => 'Bestellung abgeschlossen';

  @override
  String evPayment(String amount) {
    return 'Zahlung von $amount';
  }

  @override
  String get evRefund => 'Erstattung';

  @override
  String get evDetailsUpdated => 'Angaben geändert';

  @override
  String get itemsTotal => 'Artikel';

  @override
  String get removeDiscount => 'Rabatt entfernen';

  @override
  String get addDiscount => 'Rabatt hinzufügen';

  @override
  String get applyPromotion => 'Aktion anwenden';

  @override
  String get promoCode => 'Aktionscode';

  @override
  String get promoCodeHint => 'Z. B. WILLKOMMEN10';

  @override
  String get manualDiscount => 'Nachlass (Kulanz)';

  @override
  String get useLoyalty => 'Treuepunkte einlösen';

  @override
  String get noActivePromotion =>
      'Keine laufende Aktion. Legen Sie welche unter „Gäste & Treue“ an.';

  @override
  String get inPercent => 'In %';

  @override
  String get inAmount => 'Als Betrag';

  @override
  String get percentValue => 'Prozentsatz';

  @override
  String get manualDiscountHint => 'Z. B. lange Wartezeit, Stammgast';

  @override
  String get apply => 'Anwenden';

  @override
  String get allAreas => 'Alle Bereiche';

  @override
  String get planView => 'Plan';

  @override
  String get cardsView => 'Karten';

  @override
  String get editFloor => 'Gastraum bearbeiten';

  @override
  String get done => 'Fertig';

  @override
  String get floorEmptyTitle => 'Gastraum anlegen';

  @override
  String get floorEmptyHint =>
      'Legen Sie zuerst Ihre Bereiche an (Gastraum, Terrasse, VIP…), dann Ihre Tische mit beliebigem Namen (Tisch 1, VIP 1, Bar 2…). Danach sehen Sie live, welche Tische frei, besetzt oder reserviert sind.';

  @override
  String get editFloorHint =>
      'Ziehen Sie die Tische, um Ihren Gastraum nachzubilden. Tippen Sie auf einen Tisch, um Namen, Plätze oder Form zu ändern.';

  @override
  String get noTablesInArea =>
      'Kein Tisch in diesem Bereich: „Gastraum bearbeiten“, dann „Neuer Tisch“.';

  @override
  String get newOrderAtTable => 'Neue Bestellung an diesem Tisch';

  @override
  String get openOrder => 'Bestellung öffnen';

  @override
  String get reservationsToday => 'Reservierungen heute';

  @override
  String get reserveTable => 'Reservieren';

  @override
  String get noReservationToday => 'Heute keine Reservierung für diesen Tisch.';

  @override
  String get tableQrCode => 'QR-Code des Tisches';

  @override
  String get tableQrHint =>
      'Ausdrucken und auf den Tisch stellen: Der Gast scannt, sieht die Karte mit Fotos und bestellt. Die Bestellung erscheint unter „Zu bestätigen“.';

  @override
  String get areaNameHint => 'Z. B. Gastraum, Terrasse, VIP, Obergeschoss';

  @override
  String get tableLabelHint => 'Z. B. Tisch 1, VIP 1, Bar 2';

  @override
  String get tableShape => 'Form';

  @override
  String get shapeSquare => 'Quadratisch';

  @override
  String get shapeRound => 'Rund';

  @override
  String get shapeRect => 'Rechteckig';

  @override
  String get resRequested => 'Angefragt';

  @override
  String get resConfirmed => 'Bestätigt';

  @override
  String get resSeated => 'Platziert';

  @override
  String get resCompleted => 'Abgeschlossen';

  @override
  String get resNoShow => 'Nicht erschienen';

  @override
  String get resDeclined => 'Abgelehnt';

  @override
  String get resCancelled => 'Storniert';

  @override
  String reservationRequests(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Reservierungsanfragen zu bearbeiten',
      one: '1 Reservierungsanfrage zu bearbeiten',
    );
    return '$_temp0';
  }

  @override
  String get reservationRequestsHint =>
      'Online-Anfragen der Gäste: durch Wahl der Tische bestätigen oder mit Begründung ablehnen. Der Gast wird informiert.';

  @override
  String get declineReservation => 'Reservierung ablehnen';

  @override
  String get confirmReservation => 'Bestätigen';

  @override
  String reservationsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Reservierungen',
      one: '1 Reservierung',
      zero: 'Keine Reservierung',
    );
    return '$_temp0';
  }

  @override
  String coversCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Gedecke',
      one: '1 Gedeck',
      zero: '0 Gedecke',
    );
    return '$_temp0';
  }

  @override
  String get noReservationsDay => 'An diesem Tag keine Reservierungen.';

  @override
  String get today => 'Heute';

  @override
  String get timelineView => 'Zeitplan';

  @override
  String get listView => 'Liste';

  @override
  String get newReservation => 'Neue Reservierung';

  @override
  String get nowLabel => 'jetzt';

  @override
  String get seatGuests => 'Gäste platzieren';

  @override
  String get changeTables => 'Tische ändern';

  @override
  String get markNoShow => 'Nicht erschienen';

  @override
  String get cancelReservation => 'Reservierung stornieren';

  @override
  String get markCompleted => 'Abgeschlossen';

  @override
  String get chooseTables => 'Tische';

  @override
  String seatsForParty(int seats, int party) {
    return '$seats Plätze für $party Personen gewählt';
  }

  @override
  String get reservationNoteHint => 'Z. B. Geburtstag, Kinderstuhl, am Fenster';

  @override
  String get noFreeTableSlot =>
      'Kein freier Tisch in diesem Zeitraum: Uhrzeit oder Dauer ändern.';

  @override
  String itemsCountLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Artikel',
      one: '1 Artikel',
      zero: 'keine Artikel',
    );
    return '$_temp0';
  }

  @override
  String get alertNewCustomerOrder => 'Neue Gastbestellung zu bestätigen';

  @override
  String get alertOrderReady => 'Eine Bestellung ist servierbereit';

  @override
  String get view => 'Ansehen';

  @override
  String ordersToValidateBanner(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Gastbestellungen warten auf Ihre Bestätigung',
      one: '1 Gastbestellung wartet auf Ihre Bestätigung',
    );
    return '$_temp0';
  }

  @override
  String get tabInProgress => 'Laufend';

  @override
  String get historyTab => 'Verlauf';

  @override
  String get newShort => 'Neu';

  @override
  String get brandPoint1 =>
      'Bestellungen im Haus, zum Mitnehmen, Lieferung und online';

  @override
  String get brandPoint2 => 'Küche und Bar live, Gastraum und Reservierungen';

  @override
  String get brandPoint3 => 'Kasse, Lager, Einkauf und Ausgaben';

  @override
  String get brandPoint4 => 'Dashboards und professionelle Berichte';

  @override
  String get authWelcome => 'Willkommen';

  @override
  String get authWelcomeSub =>
      'Melden Sie sich an, um zu Ihrem Restaurant zu gelangen';

  @override
  String get noAccountYet => 'Noch kein Konto?';

  @override
  String get alreadyAccount => 'Bereits ein Konto?';

  @override
  String get authSignUpSub => 'In wenigen Sekunden startklar, unverbindlich';

  @override
  String get authForgotSub =>
      'Erhalten Sie einen Code per E-Mail, um ein neues Passwort zu wählen';

  @override
  String get authNewPasswordSub => 'Mindestens 8 Zeichen';

  @override
  String get navHome => 'Start';

  @override
  String get greetingDay => 'Guten Tag';

  @override
  String get greetingEvening => 'Guten Abend';

  @override
  String get moreModules => 'Mehr';

  @override
  String freeTablesCount(int free, int total) {
    return '$free von $total Tischen frei';
  }

  @override
  String suggestedTable(String label, int seats) {
    return 'Vorschlag: $label ($seats Plätze)';
  }

  @override
  String get slotFreeSoon => 'Rechtzeitig frei';

  @override
  String get slotReserved => 'In diesem Zeitraum reserviert';

  @override
  String freeAround(String time) {
    return 'frei gegen $time';
  }

  @override
  String get timelineEmptyHint =>
      'An diesem Tag keine Reservierungen. Tippen Sie auf eine Uhrzeit in der Zeile eines Tisches, um ihn zu reservieren.';

  @override
  String get myAccount => 'Mein Konto';

  @override
  String get brandTagline => 'Restaurantverwaltung – fließend und glasklar.';

  @override
  String get addPaymentMethod => 'Zahlungsart hinzufügen';

  @override
  String get allMethods => 'Alle Zahlungsarten';

  @override
  String get availableInBranches => 'Verfügbar in';

  @override
  String get availableWorldwide => 'Überall gültig';

  @override
  String get blindCountHint =>
      'Zählen Sie die Kasse, ohne den Sollbetrag anzusehen: Die Differenz erscheint nach dem Speichern der Zählung.';

  @override
  String get cashDrawer => 'Kassenschublade';

  @override
  String get cashMovementsTitle => 'Bareinlagen und -entnahmen';

  @override
  String get cashReportTitle => 'Kassenbericht';

  @override
  String get cashierLabel => 'Kassierer';

  @override
  String get choosePaymentMethod => 'Wählen Sie die Zahlungsart.';

  @override
  String get closingValidated => 'Abschluss bestätigt: Z-Bon nummeriert.';

  @override
  String get closingsTab => 'Abschlüsse';

  @override
  String get coinsLabel => 'Münzen';

  @override
  String get collectTab => 'Kassieren';

  @override
  String collectWithTip(String amount, String tip) {
    return '$amount + $tip kassieren';
  }

  @override
  String get collectedByDay => 'Eingenommen pro Tag';

  @override
  String get collectedByHour => 'Eingenommen pro Stunde';

  @override
  String get collectedTotal => 'Eingenommen';

  @override
  String commonInCountry(String country) {
    return 'In Ihrem Land üblich ($country)';
  }

  @override
  String get countByDenomination => 'Schein für Schein';

  @override
  String countConfirm(String amount) {
    return 'Zählung bestätigen: $amount?';
  }

  @override
  String get countDetailTitle => 'Details der Zählung';

  @override
  String get countRecorded => 'Zählung gespeichert';

  @override
  String get countedLabel => 'Gezählt';

  @override
  String get countedTotal => 'Gezählter Betrag';

  @override
  String get customMethod => 'Eigene Zahlungsart';

  @override
  String get customMethodHint =>
      'Z. B. Hausgutschein, Treuekarte, Zahlungslink';

  @override
  String get dateLabel => 'Datum';

  @override
  String get differenceLabel => 'Differenz';

  @override
  String get differenceReasonHint =>
      'Z. B. falsch herausgegeben, beschädigter Schein';

  @override
  String get discountsTotal => 'Rabatte';

  @override
  String get displayOrder => 'Reihenfolge';

  @override
  String get enterAmount => 'Betrag eingeben';

  @override
  String get errorPaymentMethodUnavailable =>
      'Diese Zahlungsart ist hier nicht verfügbar.';

  @override
  String get errorReferenceRequired =>
      'Geben Sie die Transaktionsnummer ein (Zahlungsreferenz).';

  @override
  String get exactAmount => 'Passender Betrag';

  @override
  String get exportExcel => 'Exportieren (Tabelle)';

  @override
  String get exportPdf => 'Als PDF exportieren';

  @override
  String get feePercentLabel => 'Erhobene Gebühr';

  @override
  String feeShort(String percent) {
    return 'Gebühr $percent %';
  }

  @override
  String get feesEstimate => 'Gebühren (Schätzung)';

  @override
  String get findTicket => 'Beleg suchen';

  @override
  String get lastPayments => 'Letzte Zahlungen';

  @override
  String get legalNameLabel => 'Firmenname';

  @override
  String get managerMustValidate =>
      'Eine verantwortliche Person muss den Abschluss bestätigen.';

  @override
  String get methodKind => 'Art';

  @override
  String get mySessionTab => 'Meine Kasse';

  @override
  String get newRegister => 'Neue Kasse';

  @override
  String get noActiveRegister =>
      'Keine aktive Kasse: Legen Sie eine unter Einstellungen an.';

  @override
  String get noClosings => 'Noch keine Abschlüsse.';

  @override
  String get noMovements => 'Keine Bewegungen.';

  @override
  String get noPaymentMethod =>
      'Keine aktive Zahlungsart: Fügen Sie welche unter Einstellungen hinzu.';

  @override
  String get noPaymentsYet => 'Noch keine Zahlungen.';

  @override
  String get noRefunds => 'Keine Erstattungen in den letzten 30 Tagen.';

  @override
  String get noTip => 'Keines';

  @override
  String get notesLabel => 'Scheine';

  @override
  String get nothingToCollect => 'Derzeit nichts zu kassieren.';

  @override
  String get openRegisterHint =>
      'Zählen Sie das Wechselgeld (Anfangsbestand): Es ist die Grundlage für die Zählung zum Schichtende.';

  @override
  String openRegisterTitle(String register) {
    return '$register öffnen';
  }

  @override
  String get openedLabel => 'Eröffnet';

  @override
  String get orderDetails => 'Bestelldetails';

  @override
  String get orderShort => 'Bestellung';

  @override
  String get otherAmount => 'Anderer Betrag';

  @override
  String get otherCountries => 'Andere Länder';

  @override
  String get payKindAccount => 'Kundenkonto';

  @override
  String get payKindCheque => 'Scheck';

  @override
  String get payKindInstant => 'Sofortzahlung';

  @override
  String get payKindVoucher => 'Gutschein';

  @override
  String get payKindWallet => 'Mobile Wallet';

  @override
  String get paymentComplete => 'Zahlung abgeschlossen';

  @override
  String get paymentMethodLabel => 'Zahlungsart';

  @override
  String get paymentMethodsHint =>
      'Die beim Kassieren angebotenen Zahlungsarten. Passen Sie sie an Ihr Land an: Name, Pflicht zur Transaktionsnummer, Gebühr, Standorte.';

  @override
  String get paymentMethodsTitle => 'Zahlungsarten';

  @override
  String get paymentsCountShort => 'Zahlungen';

  @override
  String get periodYesterday => 'Gestern';

  @override
  String get printCountReport => 'Zählung drucken';

  @override
  String get printReceipt => 'Beleg drucken';

  @override
  String get reasonChangeFloat => 'Wechselgeld eingelegt';

  @override
  String get reasonOtherIn => 'Sonstige Einlage';

  @override
  String get reasonOtherOut => 'Sonstige Entnahme';

  @override
  String get reasonSafeDrop => 'Einzahlung in den Tresor';

  @override
  String get reasonSmallPurchase => 'Kleiner Einkauf';

  @override
  String get reasonTipsPaid => 'Trinkgeld an das Team ausgezahlt';

  @override
  String get receiptFooterHint => 'Z. B. Danke und bis bald! WLAN: RestoGast';

  @override
  String get receiptFooterLabel => 'Text unten auf dem Beleg';

  @override
  String receiptNumberLabel(int number) {
    return 'Beleg Nr. $number';
  }

  @override
  String get receiptSettingsHint =>
      'Erscheint auf jedem Kundenbeleg und auf den Z-Bons.';

  @override
  String get receiptSettingsTitle => 'Angaben auf dem Beleg';

  @override
  String get receiptShort => 'Beleg';

  @override
  String receiptTaxId(String id) {
    return 'Steuernr.: $id';
  }

  @override
  String get recentRefunds => 'Letzte Erstattungen';

  @override
  String get recordCount => 'Zählung speichern';

  @override
  String get referenceRequiredShort => 'Transaktionsnummer erforderlich';

  @override
  String get refundAction => 'Erstatten';

  @override
  String get refundDone => 'Erstattung gespeichert.';

  @override
  String get refundReasonHint => 'Z. B. Gericht abgelehnt, Eingabefehler';

  @override
  String get refundTitle => 'Dem Gast erstatten';

  @override
  String refundableAmount(String amount) {
    return 'erstattbar: $amount';
  }

  @override
  String get refundsTab => 'Erstattungen';

  @override
  String get registerClosedHint =>
      'Öffnen Sie die Kasse (gezählter Anfangsbestand), um zu kassieren.';

  @override
  String get registerClosedTitle => 'Kasse geschlossen';

  @override
  String get registerLabel => 'Kasse';

  @override
  String get registerNameHint => 'Z. B. Theke, Terrasse, Bar';

  @override
  String get registersTitle => 'Kassen';

  @override
  String get reportsTab => 'Berichte';

  @override
  String get requireReferenceHint =>
      'Der Kassierer muss die Transaktionsnummer eingeben (Abgleich mit dem Kontoauszug).';

  @override
  String get requireReferenceLabel => 'Transaktionsnummer erforderlich';

  @override
  String get salesByDay => 'Pro Tag';

  @override
  String get salesByMethod => 'Nach Zahlungsart';

  @override
  String get salesByRegister => 'Nach Kasse';

  @override
  String get salesByStaff => 'Nach Servicekraft';

  @override
  String get searchAction => 'Suchen';

  @override
  String get searchMethodOrCountry =>
      'Name der Zahlungsart oder Ländercode (z. B. BR)';

  @override
  String get sendWhatsApp => 'Per WhatsApp senden';

  @override
  String get sessionAwaitingValidation => 'Gezählt — wartet auf Bestätigung';

  @override
  String get settingsTab => 'Einstellungen';

  @override
  String get shareReceipt => 'Beleg teilen';

  @override
  String get signatureCashier => 'Unterschrift Kassierer';

  @override
  String get signatureManager => 'Unterschrift Verantwortliche/r';

  @override
  String someBranchesOnly(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Standorte',
      one: '1 Standort',
    );
    return '$_temp0';
  }

  @override
  String get splitAll => 'Alles';

  @override
  String get splitByItems => 'Nach Artikeln';

  @override
  String get splitByParts => 'Nach Anteilen';

  @override
  String get splitCustom => 'Freier Betrag';

  @override
  String get staffLabel => 'Servicekraft';

  @override
  String get statusLabel => 'Status';

  @override
  String get taxIdHint => 'Steueridentifikationsnummer Ihres Landes';

  @override
  String get taxIdLabel => 'Steueridentifikationsnummer';

  @override
  String get ticketOrOrderNumber => 'Beleg- oder Bestellnummer';

  @override
  String get tipLabel => 'Trinkgeld';

  @override
  String get tipPresetsLabel => 'Vorgeschlagene Prozentsätze';

  @override
  String get tipsEnabledHint =>
      'Beim Kassieren angeboten, getrennt vom Umsatz erfasst und der Servicekraft der Bestellung zugeordnet.';

  @override
  String get tipsEnabledLabel => 'Trinkgeld anbieten';

  @override
  String get tipsTitle => 'Trinkgeld';

  @override
  String get tipsTotal => 'Trinkgeld';

  @override
  String get toCollectTotal => 'Zu kassieren';

  @override
  String get transactionReferenceRequired =>
      'Transaktionsnummer (erforderlich)';

  @override
  String get transactionsTab => 'Transaktionen';

  @override
  String get validateClosingConfirm =>
      'Diesen Abschluss bestätigen? Der Z-Bon wird nummeriert und kann nicht mehr geändert werden.';

  @override
  String get validateNowHint =>
      'Bestätigen Sie den Abschluss im Reiter Abschlüsse, um den nummerierten Z-Bon zu erhalten.';

  @override
  String get validatedLabel => 'Bestätigt';

  @override
  String get voidedPayments => 'Stornierte Zahlungen';

  @override
  String get xReading => 'X-Bon';

  @override
  String get xReportTitle => 'X-Bon (vorläufig)';

  @override
  String get zHistory => 'Z-Bon-Verlauf';

  @override
  String zReportTitle(int number) {
    return 'Z-Bon Nr. $number';
  }

  @override
  String get zShort => 'Z';

  @override
  String get expectedCashLabel => 'Soll-Bargeld';

  @override
  String get countedAmountLabel => 'Gezählt';

  @override
  String get refundsLabel => 'Erstattungen';

  @override
  String get addressOptional => 'Adresse (optional)';

  @override
  String get billedTo => 'Rechnung an';

  @override
  String get cancelInvoiceHint => 'Z. B. falscher Firmenname, falscher Kunde';

  @override
  String get chooseOrder => 'Bestellung wählen';

  @override
  String get companyOptional => 'Firma (optional)';

  @override
  String get customerTaxIdOptional => 'Steuernummer des Kunden (optional)';

  @override
  String get documentsTitle => 'Dokumente';

  @override
  String get emailOptional => 'E-Mail (optional)';

  @override
  String get errorCustomerNameRequired =>
      'Der Kundenname ist auf einer Rechnung Pflicht.';

  @override
  String get invoiceATicket => 'Beleg in Rechnung stellen';

  @override
  String get invoiceCancelledMention => 'RECHNUNG STORNIERT';

  @override
  String get invoiceCancelledDone =>
      'Rechnung storniert: Sie können eine neue ausstellen.';

  @override
  String invoiceDateLabel(String date) {
    return 'Datum: $date';
  }

  @override
  String get invoiceDesignation => 'Bezeichnung';

  @override
  String invoiceEmailHint(String email) {
    return 'Zum Senden an $email: „Teilen“ tippen und Ihre E-Mail-App wählen.';
  }

  @override
  String get invoiceFooterHint =>
      'Z. B. Zahlungsbedingungen, Bankverbindung, gesetzliche Angaben Ihres Landes';

  @override
  String get invoiceFooterLabel => 'Angaben unten auf der Rechnung';

  @override
  String invoiceNumberLabel(String number) {
    return 'Rechnung Nr. $number';
  }

  @override
  String get invoicePayments => 'Erhaltene Zahlungen';

  @override
  String get invoicePrefixHint => 'Z. B. RE-2026-';

  @override
  String get invoicePrefixLabel => 'Präfix der Rechnungsnummer';

  @override
  String get invoiceSettingsTitle => 'Rechnungen';

  @override
  String get invoiceTitle => 'Rechnung';

  @override
  String get invoiceUnitPrice => 'Einzelpreis';

  @override
  String get invoicedTotal => 'In Rechnung gestellt';

  @override
  String get invoicesCount => 'Rechnungen';

  @override
  String get issueInvoice => 'Rechnung erstellen';

  @override
  String get issueInvoiceAction => 'Rechnung ausstellen';

  @override
  String get issueInvoiceHint =>
      'Eine ausgestellte Rechnung ist nummeriert und kann nicht mehr geändert werden (bei Fehlern: stornieren und neu ausstellen).';

  @override
  String get noInvoices =>
      'Keine Rechnungen in diesem Zeitraum. Eine Rechnung wird aus einer Bestellung (Schaltfläche „Rechnung“) oder hier mit „Beleg in Rechnung stellen“ erstellt.';

  @override
  String get printInvoice => 'Drucken / herunterladen';

  @override
  String get receiptDocument => 'Kassenbeleg';

  @override
  String get searchInvoiceHint => 'Nr., Kunde, Firma';

  @override
  String get shareInvoice => 'Teilen';

  @override
  String get totalExclTax => 'Gesamt netto';

  @override
  String get totalInclTax => 'Gesamt brutto';

  @override
  String get receiptQrCaption => 'Scannen und uns online finden';

  @override
  String get receiptQrLabel => 'QR-Code unten auf dem Beleg';

  @override
  String get receiptQrUrlLabel => 'Link des QR-Codes';

  @override
  String get receiptQrUrlHint =>
      'Leer = Seite des Restaurants. Z. B. https://ihre-seite.de oder Ihre Bewertungsseite';

  @override
  String get receiptQrUrlInvalid =>
      'Der Link des QR-Codes muss mit https:// (oder http://) beginnen.';

  @override
  String get restaurantLogo => 'Logo des Restaurants';

  @override
  String get chooseLogo => 'Logo wählen';

  @override
  String get replaceLogo => 'Ersetzen';

  @override
  String get removeLogo => 'Entfernen';

  @override
  String get logoTooBig =>
      'Diese Datei ist größer als 1 MB: Wählen Sie ein kleineres Bild.';

  @override
  String get receiptTendered => 'Gegeben';

  @override
  String get receiptChange => 'Rückgeld';

  @override
  String get restaurantLogoHint =>
      'Wird oben auf die Belege gedruckt. Transparentes PNG empfohlen, max. 1 MB.';

  @override
  String get add => 'Hinzufügen';

  @override
  String get delete => 'Löschen';

  @override
  String get branchLabel => 'Filiale';

  @override
  String get kindDessert => 'Dessert';

  @override
  String get kindMenu => 'Menü';

  @override
  String get navAds => 'Werbung';

  @override
  String get navSettings => 'Einstellungen';

  @override
  String get greetingShort => 'Hallo';

  @override
  String get homeWelcome => 'Willkommen, hier ist Ihre heutige Aktivität';

  @override
  String get kpiSalesToday => 'Umsatz heute';

  @override
  String get kpiOpenOrders => 'Laufende Bestellungen';

  @override
  String kpiPendingCount(int count) {
    return '$count wartend';
  }

  @override
  String get kpiOccupancy => 'Auslastung';

  @override
  String kpiTablesBusy(int busy, int total) {
    return '$busy von $total Tischen belegt';
  }

  @override
  String get lowStockTitle => 'Niedriger Bestand';

  @override
  String get saveChanges => 'Änderungen speichern';

  @override
  String get settingsProfile => 'Restaurantprofil';

  @override
  String get settingsProfileHint =>
      'Die Angaben Ihres Restaurants, für Ihre Gäste sichtbar.';

  @override
  String get settingsContact => 'Kontakt & Standort';

  @override
  String get settingsContactHint =>
      'Adresse, Telefonnummern und Position auf der Karte.';

  @override
  String get settingsHours => 'Öffnungszeiten';

  @override
  String get settingsHoursHint =>
      'Öffnungstage und -zeiten, Zubereitungszeit, vorübergehende Schließung.';

  @override
  String get settingsDelivery => 'Lieferung & Bestellungen';

  @override
  String get settingsDeliveryHint =>
      'Online-Bestellungen, Lieferung, Reservierungen und öffentliche Seite.';

  @override
  String get settingsPayments => 'Zahlung & Rechnungen';

  @override
  String get settingsPaymentsHint =>
      'Zahlungsarten, Kassen, Beleg, Rechnungen und Trinkgeld.';

  @override
  String get settingsTeam => 'Team & Rollen';

  @override
  String get settingsTeamHint => 'Mitglieder, Rollen und Einladungen.';

  @override
  String get settingsNotifications => 'Benachrichtigungen';

  @override
  String get settingsNotificationsHint => 'Worauf die App Sie hinweist.';

  @override
  String get settingsSecurity => 'Sicherheit';

  @override
  String get settingsSecurityHint => 'Passwort und angemeldete Geräte.';

  @override
  String get restaurantName => 'Name des Restaurants';

  @override
  String get sloganLabel => 'Slogan';

  @override
  String get sloganHint => 'Z. B. Feine traditionelle Küche';

  @override
  String get registrationNumber => 'Registernummer';

  @override
  String get registrationNumberHint => 'Handelsregister Ihres Landes';

  @override
  String get logoUpload => 'Logo hochladen';

  @override
  String get logoFormats => 'PNG, JPG oder WebP — max. 1 MB. Ideal: 512 × 512.';

  @override
  String get logoWhere =>
      'Das Logo erscheint in der App, auf Ihrem Schaufenster und auf den Belegen Ihrer Gäste.';

  @override
  String get whatsappLabel => 'WhatsApp-Nummer';

  @override
  String get gpsTitle => 'GPS-Koordinaten / Karte';

  @override
  String get latitude => 'Breitengrad';

  @override
  String get longitude => 'Längengrad';

  @override
  String get gpsMissing => 'Standort nicht angegeben';

  @override
  String get openInMaps => 'In Maps öffnen';

  @override
  String get deliveryZoneLabel => 'Liefergebiet';

  @override
  String get deliveryZoneHint => 'Z. B. belieferte Viertel oder 5-km-Umkreis';

  @override
  String get vacationMode => 'Urlaubsmodus';

  @override
  String get vacationModeHint =>
      'Restaurant vorübergehend schließen: Es erscheint für Ihre Gäste als geschlossen.';

  @override
  String get vacationMessage => 'Nachricht für die Gäste';

  @override
  String get vacationMessageHint => 'Z. B. Wiedereröffnung am 15. September';

  @override
  String get notifSoundNewOrder => 'Ton bei jeder neuen Bestellung';

  @override
  String get notifSoundReady => 'Ton, wenn eine Bestellung fertig ist';

  @override
  String get notifLate => 'Warnung bei verspäteten Bestellungen';

  @override
  String get notifLowStock => 'Warnung bei niedrigem Bestand';

  @override
  String get notifReservations => 'Erinnerung an die Reservierungen der Stunde';

  @override
  String get notifCashGap => 'Kassendifferenz beim Abschluss';

  @override
  String get signedInAs => 'Angemeldet als';

  @override
  String get securityTip =>
      'Verwenden Sie ein eigenes Passwort mit mindestens 8 Zeichen.';

  @override
  String get signOutOthers => 'Meine anderen Geräte abmelden';

  @override
  String get signOutOthersDone => 'Ihre anderen Geräte sind abgemeldet.';

  @override
  String get signOutAll => 'Überall abmelden';

  @override
  String fileTooBig(String name) {
    return '$name ist zu groß.';
  }

  @override
  String get adsCreate => 'Anzeige erstellen';

  @override
  String get adsEdit => 'Anzeige bearbeiten';

  @override
  String get adsCampaigns => 'Meine Kampagnen';

  @override
  String get adsLibrary => 'Mediathek';

  @override
  String get adsStats => 'Statistiken';

  @override
  String get adsCreateTitle => 'Erstellen';

  @override
  String get adsCreateHint => 'Wählen Sie das Format Ihrer Anzeige.';

  @override
  String get adsContent => 'Inhalt';

  @override
  String get adsBudgetTargeting => 'Budget & Zielgruppe';

  @override
  String get adsPreview => 'Vorschau';

  @override
  String get adsPreviewHint => 'Vorschau auf dem Handy';

  @override
  String get adsPreviewSimulation => 'Diese Vorschau ist eine Simulation.';

  @override
  String get adsFromLibrary => 'Aus der Mediathek';

  @override
  String get adsUpload => 'Fotos oder Videos hinzufügen';

  @override
  String get adsUploadHint =>
      'JPG, PNG, WebP (5 MB) · MP4, WebM, MOV (50 MB) · Videos von 15–30 Sekunden empfohlen';

  @override
  String get adsLibraryEmpty => 'Die Mediathek ist leer.';

  @override
  String get adsDeleteFile => 'Diese Datei aus der Mediathek löschen?';

  @override
  String get adsEmpty => 'Noch keine Kampagnen.';

  @override
  String get adsEmptyHint =>
      'Erstellen Sie Ihre erste Anzeige: ein Video, eine 24-Stunden-Story oder ein hervorgehobenes Gericht.';

  @override
  String get adsActiveCampaigns => 'Kampagnen';

  @override
  String adsCampaignCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count aktiv',
      one: '1 aktiv',
      zero: 'keine aktiv',
    );
    return '$_temp0';
  }

  @override
  String get adFormat => 'Format';

  @override
  String get adFormatVideo => 'Video 15–30 s';

  @override
  String get adFormatVideoHint => 'Kurzes Video für Aufmerksamkeit';

  @override
  String get adFormatCarousel => 'Foto-Karussell';

  @override
  String get adFormatCarouselHint => 'Mehrere Bilder zum Durchblättern';

  @override
  String get adFormatStory => '24-Stunden-Story';

  @override
  String get adFormatStoryHint => 'Kurzlebiges 24-Stunden-Format';

  @override
  String get adFormatSponsoredMenu => 'Gesponsertes Menü';

  @override
  String get adFormatSponsoredMenuHint => 'Ihre Gerichte hervorheben';

  @override
  String get adFormatPush => 'Benachrichtigung';

  @override
  String get adFormatPushHint => 'Ihre Gäste direkt erreichen';

  @override
  String get adFormatClassified => 'Kleinanzeige';

  @override
  String get adFormatClassifiedHint => 'Einfache, wirksame Textanzeige';

  @override
  String get adTitle => 'Titel';

  @override
  String get adTitleHint => 'Z. B. Buttercroissant';

  @override
  String get adTitleRequired => 'Geben Sie Ihrer Anzeige einen Titel.';

  @override
  String get adText => 'Text';

  @override
  String get adTextHint =>
      'Z. B. Neu! Hausgemachtes Croissant, nur heute Abend -20 %';

  @override
  String get adMediaHelp => 'Fotos oder Videos der Anzeige (höchstens 10).';

  @override
  String get adVideoHelp =>
      'Fügen Sie ein kurzes Video hinzu (15 bis 30 Sekunden).';

  @override
  String get adChooseItems => 'Hervorgehobene Gerichte';

  @override
  String get adCta => 'Schaltfläche';

  @override
  String get adCtaHint => 'Z. B. Jetzt bestellen';

  @override
  String get adCtaDefault => 'Jetzt bestellen';

  @override
  String get adLink => 'Link der Schaltfläche (optional)';

  @override
  String get adPushNote =>
      'Die Benachrichtigung geht an App-Kunden, die Ihren Angeboten zugestimmt haben.';

  @override
  String get adDailyBudget => 'Tagesbudget';

  @override
  String get adBudgetNote =>
      'Geplantes Budget: Die gesponserte Ausspielung wird von der Plattform abgerechnet.';

  @override
  String get adStart => 'Beginn';

  @override
  String get adEnd => 'Ende';

  @override
  String get adStory24h => '24 Stunden sichtbar';

  @override
  String get adTargetAreas => 'Ausrichtung nach Viertel';

  @override
  String get adAddArea => 'Viertel hinzufügen';

  @override
  String get adMoments => 'Tageszeit';

  @override
  String get momentMorning => 'Morgen';

  @override
  String get momentNoon => 'Mittag';

  @override
  String get momentAfternoon => 'Nachmittag';

  @override
  String get momentEvening => 'Abend';

  @override
  String get momentNight => 'Nacht';

  @override
  String get adBranches => 'Filialen';

  @override
  String get adSaveDraft => 'Entwurf speichern';

  @override
  String get adPublish => 'Veröffentlichen';

  @override
  String get adPublished => 'Anzeige veröffentlicht.';

  @override
  String get adSponsored => 'Gesponsert';

  @override
  String get adStatusActive => 'Aktiv';

  @override
  String get adStatusScheduled => 'Geplant';

  @override
  String get adStatusPaused => 'Pausiert';

  @override
  String get adStatusEnded => 'Beendet';

  @override
  String get adStatusDraft => 'Entwurf';

  @override
  String get adRoi => 'Erzielter Umsatz';

  @override
  String adRoiDetail(String amount) {
    return 'für $amount eingesetztes Budget';
  }

  @override
  String adViews(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Aufrufe',
      one: '1 Aufruf',
      zero: '0 Aufrufe',
    );
    return '$_temp0';
  }

  @override
  String adOrders(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Bestellungen',
      one: '1 Bestellung',
      zero: '0 Bestellungen',
    );
    return '$_temp0';
  }

  @override
  String get adDetails => 'Details ansehen';

  @override
  String get adBoost => 'Boosten';

  @override
  String get adBoostTitle => 'Laufzeit verlängern';

  @override
  String adBoostDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Tage mehr',
      one: '1 Tag mehr',
    );
    return '$_temp0';
  }

  @override
  String get adBoosted => 'Kampagne verlängert.';

  @override
  String get adPause => 'Pausieren';

  @override
  String get adResume => 'Fortsetzen';

  @override
  String get adEndNow => 'Jetzt beenden';

  @override
  String get adDeleteConfirm => 'Diese Kampagne und ihre Statistiken löschen?';

  @override
  String get adStatViews => 'Aufrufe';

  @override
  String get adStatClicks => 'Klicks';

  @override
  String get adStatClickRate => 'Klickrate';

  @override
  String get adStatOrders => 'Bestellungen';

  @override
  String get adStatRevenue => 'Umsatz';

  @override
  String get adStatByCampaign => 'Aufrufe pro Kampagne';

  @override
  String get activeLabel => 'Aktiv';

  @override
  String get addPhotos => 'Fotos hinzufügen';

  @override
  String get addProduct => 'Produkt hinzufügen';

  @override
  String get allItems => 'Alle';

  @override
  String get available => 'Verfügbar';

  @override
  String get categories => 'Kategorien';

  @override
  String get copySuffix => 'Kopie';

  @override
  String get customerSideView =>
      'Kundenansicht — so erscheint es auf der Speisekarte';

  @override
  String get duplicate => 'Duplizieren';

  @override
  String get everyDay => 'Jeden Tag';

  @override
  String get filterKind => 'Art';

  @override
  String get itemDescriptionHint =>
      'Z. B. Ndolé-Blätter mit Erdnüssen, Garnelen und Kochbanane';

  @override
  String get itemDuplicated =>
      'Artikel dupliziert: Die Kopie bleibt verborgen, bis Sie sie speichern.';

  @override
  String get livePreview => 'Live-Vorschau';

  @override
  String get mainPhoto => 'Hauptfoto';

  @override
  String get makeMainPhoto => 'Als Hauptfoto festlegen';

  @override
  String get markAvailable => 'Wieder verfügbar machen';

  @override
  String get markSoldOut => 'Als ausverkauft markieren';

  @override
  String get menuProducts => 'Produkte der Karte';

  @override
  String get noProductsFound => 'Keine passenden Produkte.';

  @override
  String photosHint(int count) {
    return 'Bis zu $count Fotos · JPG, PNG, WebP · max. 5 MB';
  }

  @override
  String get play => 'Abspielen';

  @override
  String prepMinutesShort(int minutes) {
    return 'Zubereitung: $minutes Min.';
  }

  @override
  String get prepTime => 'Zubereitungszeit';

  @override
  String get productInfo => 'Produktinformationen';

  @override
  String get productPhotos => 'Produktfotos';

  @override
  String productsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Produkte',
      one: '1 Produkt',
      zero: 'Keine Produkte',
    );
    return '$_temp0';
  }

  @override
  String get publish => 'Veröffentlichen';

  @override
  String get replace => 'Ersetzen';

  @override
  String get saleDays => 'Verkaufstage';

  @override
  String get saleDaysRequired => 'Wählen Sie mindestens einen Verkaufstag.';

  @override
  String get searchProduct => 'Produkt, Gericht suchen…';

  @override
  String get sizesLabel => 'Größen';

  @override
  String get sortBy => 'Sortieren';

  @override
  String get sortMenuOrder => 'Reihenfolge der Karte';

  @override
  String get sortName => 'Name';

  @override
  String get sortPriceAsc => 'Preis aufsteigend';

  @override
  String get sortPriceDesc => 'Preis absteigend';

  @override
  String get stockAlertThreshold => 'Warnung unter';

  @override
  String get stockAndTime => 'Bestand & Zeit';

  @override
  String stockLeft(int count) {
    return 'Bestand: $count übrig';
  }

  @override
  String stockLow(int count) {
    return 'Niedriger Bestand: $count übrig';
  }

  @override
  String get stockNotTracked => 'Leer = nicht erfasst';

  @override
  String get stockOfDay => 'Tagesbestand';

  @override
  String get stockOfDayHint =>
      'Anzahl der heute verfügbaren Portionen. Sie sinkt mit jeder Bestellung; bei null ist der Artikel ausverkauft. Leer lassen, um nicht zu erfassen.';

  @override
  String get stockQuantity => 'Menge auf Lager';

  @override
  String get supplementsLabel => 'Extras';

  @override
  String get videoAdded => 'Präsentationsvideo hinzugefügt';

  @override
  String get videoOptional => 'Präsentationsvideo (optional, ca. 30 s)';

  @override
  String get allChannels => 'Alle Kanäle';

  @override
  String get amountLabel => 'Betrag';

  @override
  String averageTicketShort(String amount) {
    return 'Durchschnittsbon $amount';
  }

  @override
  String get customerLabel => 'Kunde';

  @override
  String get financialResult => 'Finanzergebnis';

  @override
  String get inKitchenCount => 'in Zubereitung';

  @override
  String get inProgressCount => 'laufend';

  @override
  String get itemsLabel => 'Artikel:';

  @override
  String get lateCount => 'verspätet';

  @override
  String get noOrdersHere => 'Keine Bestellungen hier';

  @override
  String get noSalesYet => 'Noch keine Verkäufe in diesem Zeitraum.';

  @override
  String get nothingToCollectHint =>
      'Nichts offen: neue Zahlungen erscheinen hier.';

  @override
  String get orderLabel => 'Bestellung';

  @override
  String get paymentLabel => 'Zahlung';

  @override
  String get periodLabel => 'Zeitraum';

  @override
  String get recentTransactions => 'Letzte Transaktionen';

  @override
  String get salesOfPeriod => 'Umsatz des Zeitraums';

  @override
  String get salesSplit => 'Umsatzverteilung';

  @override
  String get timeLabel => 'Uhrzeit';

  @override
  String get topDishes => 'Top-Gerichte';

  @override
  String get viewDetails => 'Details ansehen';

  @override
  String vsPrevious(String amount) {
    return 'Vorheriger Zeitraum: $amount';
  }

  @override
  String get addAddress => 'Adresse hinzufügen';

  @override
  String get addedToCart => 'In den Warenkorb gelegt.';

  @override
  String get addressLabel => 'Name der Adresse';

  @override
  String get addressLabelHint => 'Z. B. Zuhause, Büro';

  @override
  String get addToCart => 'In den Warenkorb';

  @override
  String get allCities => 'Alle Städte';

  @override
  String get allRestaurants => 'Alle Restaurants';

  @override
  String get birthday => 'Geburtstag';

  @override
  String get cartEmpty => 'Ihr Warenkorb ist leer.';

  @override
  String cartItems(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Artikel',
      one: '1 Artikel',
    );
    return '$_temp0';
  }

  @override
  String get changeCity => 'Ändern';

  @override
  String get chooseCity => 'Stadt wählen';

  @override
  String chooseOptionRequired(String name) {
    return 'Bitte wählen: $name';
  }

  @override
  String get closedNow => 'Geschlossen';

  @override
  String get customerFavorites => 'Favoriten';

  @override
  String get customerHome => 'Start';

  @override
  String get customerOrders => 'Bestellungen';

  @override
  String get customerProfile => 'Profil';

  @override
  String customerReviews(int count) {
    return 'Kundenbewertungen ($count)';
  }

  @override
  String get customerSearch => 'Suche';

  @override
  String get customerSpaceLink => 'Kundenbereich · bestellen';

  @override
  String get deliveryDetailsRequired =>
      'Geben Sie Lieferadresse und Telefonnummer an.';

  @override
  String get directions => 'Route';

  @override
  String get discoverRestaurants => 'Restaurants entdecken';

  @override
  String get dishes => 'Gerichte';

  @override
  String get favoritesSignIn =>
      'Melden Sie sich an, um Ihre Lieblingsrestaurants zu sehen.';

  @override
  String get fullName => 'Vor- und Nachname';

  @override
  String get globalCatalog => 'Gesamtkatalog';

  @override
  String get healthAllergies => 'Gesundheit & Allergien';

  @override
  String get howDoYouWant => 'Wie möchten Sie bedient werden?';

  @override
  String loyaltyNextReward(int points, String amount) {
    return 'Nächste Prämie bei $points Punkten: $amount';
  }

  @override
  String loyaltyPoints(int count) {
    return '$count Punkte';
  }

  @override
  String get loyaltyProgram => 'Treueprogramm';

  @override
  String mapCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Lokale auf der Karte',
      one: '1 Lokal auf der Karte',
    );
    return '$_temp0';
  }

  @override
  String get mapView => 'Karte';

  @override
  String minimumOrderNotReached(String amount) {
    return 'Mindestbestellwert: $amount';
  }

  @override
  String minutesRange(int min, int max) {
    return '$min–$max Min.';
  }

  @override
  String get myAddresses => 'Meine Adressen';

  @override
  String get myCart => 'Mein Warenkorb';

  @override
  String get newRestaurant => 'Neu';

  @override
  String get noAddresses => 'Keine gespeicherten Adressen.';

  @override
  String get noCustomerOrders => 'Sie haben noch nicht bestellt.';

  @override
  String get noFavorites => 'Noch keine Favoriten.';

  @override
  String get noFavoritesHint =>
      'Tippen Sie auf das Herz eines Restaurants, um es hinzuzufügen.';

  @override
  String get noLoyaltyYet =>
      'Ihre Punkte erscheinen nach Ihren ersten Bestellungen.';

  @override
  String get noRestaurantsYet =>
      'In dieser Stadt ist noch kein Restaurant veröffentlicht.';

  @override
  String get noteForKitchen => 'Hinweis für die Küche (optional)';

  @override
  String get noteForKitchenHint => 'Z. B. ohne Chili, gut durch';

  @override
  String get notifOrderUpdates => 'Status meiner Bestellungen';

  @override
  String get notifPromotions => 'Aktionen & Angebote';

  @override
  String get notifReservationReminders => 'Reservierungserinnerungen';

  @override
  String get onlineOrdersUnavailable =>
      'Online-Bestellung derzeit nicht verfügbar';

  @override
  String get openFullMap => 'Karte im Vollbild öffnen';

  @override
  String get openNow => 'Geöffnet';

  @override
  String get orderDone => 'Abgeschlossen';

  @override
  String orderingAtTable(String table) {
    return 'Bestellung an Tisch $table';
  }

  @override
  String get orderInProgress => 'In Bearbeitung';

  @override
  String get orderNoteOptional => 'Nachricht an das Restaurant (optional)';

  @override
  String get orderRejected => 'Vom Restaurant abgelehnt';

  @override
  String get orderSentToRestaurant =>
      'Bestellung gesendet! Das Restaurant bestätigt sie: Verfolgen Sie sie hier live.';

  @override
  String get ordersSignIn =>
      'Melden Sie sich an, um Ihre Bestellungen zu verfolgen.';

  @override
  String get orderSummary => 'Zusammenfassung';

  @override
  String get orderWaitingConfirmation => 'Wartet auf Bestätigung';

  @override
  String get payMobileWallet => 'Mobile Wallet';

  @override
  String get personalProfile => 'Persönliches Profil';

  @override
  String get personalProfileHint =>
      'Ihre persönlichen Daten und Einstellungen.';

  @override
  String get placeOrder => 'Bestellen';

  @override
  String get preferences => 'Einstellungen';

  @override
  String get preferredPayment => 'Bevorzugte Zahlung';

  @override
  String get preferredPaymentHint =>
      'Nur zur Information: Es werden keine Karten- oder Kontonummern gespeichert.';

  @override
  String get productDetails => 'Produktdetails';

  @override
  String get profileSignIn =>
      'Melden Sie sich an, um Profil, Adressen und Punkte zu verwalten.';

  @override
  String get rateOrder => 'Bestellung bewerten';

  @override
  String get requiredLabel => 'Pflicht';

  @override
  String get restaurantOnVacation =>
      'Das Restaurant ist vorübergehend geschlossen.';

  @override
  String get restaurants => 'Restaurants';

  @override
  String get restaurantSpace => 'Restaurantbereich';

  @override
  String get restaurantUnavailable => 'Dieses Restaurant ist nicht verfügbar.';

  @override
  String get reviewComment => 'Ihre Bewertung (optional)';

  @override
  String reviewsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Bewertungen',
      one: '1 Bewertung',
      zero: 'keine Bewertungen',
    );
    return '$_temp0';
  }

  @override
  String get searchRestaurantsHint => 'Restaurants, Gerichte, Küchen suchen…';

  @override
  String get seeAll => 'Alle ansehen';

  @override
  String get send => 'Senden';

  @override
  String get signInToContinue => 'Zum Fortfahren anmelden';

  @override
  String get spiceHot => 'Scharf';

  @override
  String get spiceLevel => 'Schärfe';

  @override
  String get spiceMedium => 'Mittel';

  @override
  String get spiceMild => 'Mild';

  @override
  String get spiceNone => 'Ohne';

  @override
  String get sponsoredAds => 'Gesponserte Anzeigen';

  @override
  String get stepAccepted => 'Vom Restaurant angenommen';

  @override
  String get stepDone => 'Abgeschlossen';

  @override
  String get stepPreparing => 'In Zubereitung';

  @override
  String get stepReady => 'Fertig';

  @override
  String get stepSent => 'Gesendet';

  @override
  String get storyLabel => 'Geschichte';

  @override
  String get thanksForReview => 'Danke für Ihre Bewertung!';

  @override
  String get viewCart => 'Warenkorb ansehen';

  @override
  String get watchVideo => 'Video';

  @override
  String get yourName => 'Ihr Name';

  @override
  String get gpsHint =>
      '„In Maps öffnen“ speichert automatisch Ihre aktuelle Position: Tun Sie dies im Restaurant. Sie können die Koordinaten auch eingeben.';

  @override
  String get locationSaved => 'Standort des Restaurants gespeichert.';

  @override
  String get locationServiceDisabled =>
      'Die Standortermittlung ist auf diesem Gerät deaktiviert: Aktivieren Sie sie und versuchen Sie es erneut.';

  @override
  String get locationDenied =>
      'Standortzugriff verweigert: Erlauben Sie ihn in den Browser- oder Telefoneinstellungen.';

  @override
  String get locationUnavailable =>
      'Standort derzeit nicht verfügbar: Versuchen Sie es im Freien erneut oder geben Sie die Koordinaten ein.';

  @override
  String get openMapAction => 'Karte öffnen';

  @override
  String get customerReviewsTitle => 'Kundenbewertungen';

  @override
  String get forYou => 'Für Sie';

  @override
  String fromAmount(String amount) {
    return 'ab $amount';
  }

  @override
  String helpfulCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Hilfreich ($count)',
      zero: 'Hilfreich',
    );
    return '$_temp0';
  }

  @override
  String get hideReview => 'Bewertung ausblenden';

  @override
  String get hideReviewReason => 'Grund';

  @override
  String get locatedNearYou => 'Restaurants nach Ihrem Standort sortiert';

  @override
  String get locateMe => 'Mich orten';

  @override
  String get locationRefusedChooseCity =>
      'Standort nicht verfügbar: Wählen Sie Ihre Stadt.';

  @override
  String get nearYouHint =>
      'Erlauben Sie die Ortung, um die nächstgelegenen Restaurants und Gerichte zu sehen.';

  @override
  String get nearYouRestaurants => 'In Ihrer Nähe';

  @override
  String get nearYouTitle => 'Restaurants in Ihrer Nähe';

  @override
  String get newOnMenus => 'Neuheiten';

  @override
  String get noReviewsYet => 'Noch keine Bewertungen';

  @override
  String get openNowTitle => 'Jetzt geöffnet';

  @override
  String get orderAgain => 'Erneut bestellen';

  @override
  String get orderAgainAction => 'Nachbestellen';

  @override
  String get ordersInProgressTitle => 'Ihre laufenden Bestellungen';

  @override
  String get popularDishes => 'Beliebte Gerichte';

  @override
  String get popularNearYou => 'Beliebt in Ihrer Nähe';

  @override
  String get promotionsTitle => 'Aktionen';

  @override
  String get publishReview => 'Bewertung veröffentlichen';

  @override
  String rateDish(String name) {
    return 'Bewerten: $name';
  }

  @override
  String get rateShort => 'Bewerten';

  @override
  String get refreshLocation => 'Aktualisieren';

  @override
  String get reorderPartial =>
      'Einige Gerichte sind nicht mehr verfügbar: Der Rest wurde in den Warenkorb gelegt.';

  @override
  String get reorderUnavailable => 'Diese Gerichte sind nicht mehr verfügbar.';

  @override
  String get reportReason => 'Warum ist diese Bewertung missbräuchlich?';

  @override
  String get reportReview => 'Melden';

  @override
  String reportsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Meldungen',
      one: '1 Meldung',
    );
    return '$_temp0';
  }

  @override
  String get reportSent => 'Danke, die Meldung wurde übermittelt.';

  @override
  String get republishReview => 'Wieder veröffentlichen';

  @override
  String get reviewCommentHint =>
      'Z. B. gut gewürzt, großzügige Portion, schnelle Lieferung';

  @override
  String satisfiedPercent(int percent) {
    return '$percent % zufriedene Kunden';
  }

  @override
  String get sortBestRated => 'Beste Bewertungen';

  @override
  String get sortHelpful => 'Hilfreichste';

  @override
  String get sortRecent => 'Neueste';

  @override
  String get sortWorstRated => 'Schlechteste Bewertungen';

  @override
  String get verifiedPurchase => 'Verifizierter Kauf';

  @override
  String get verifiedReviewNote =>
      'Verifizierte Bewertung: Nur Kunden, die dieses Gericht erhalten haben, können es bewerten.';

  @override
  String get asSoonAsPossible => 'So bald wie möglich';

  @override
  String get customerOrdersHere => 'Bestellungen bei Ihnen';

  @override
  String get customerPrivacyNote =>
      'Sie sehen nur die Beziehung dieses Kunden zu Ihrem Restaurant: niemals seine Bestellungen bei anderen Restaurants.';

  @override
  String get customersCount => 'Kunden';

  @override
  String multiRestaurantNote(int count) {
    return '$count Restaurants im Warenkorb: Jedes erhält eine eigene Bestellung mit eigener Nummer und Verfolgung.';
  }

  @override
  String get navCustomers => 'Kunden';

  @override
  String get noCustomersYet => 'Noch keine Online-Kunden.';

  @override
  String get noCustomersYetHint =>
      'Jeder Kunde, der über die App bestellt, erscheint hier automatisch.';

  @override
  String get noDeliveryHere =>
      'Dieses Restaurant liefert nicht: Bestellung zum Mitnehmen.';

  @override
  String get ordersSent => 'Bestellungen gesendet';

  @override
  String ordersSentHint(int count) {
    return '$count Bestellungen gesendet, eine pro Restaurant. Verfolgen Sie jede einzeln.';
  }

  @override
  String placeOrders(int count) {
    return 'Die $count Bestellungen aufgeben';
  }

  @override
  String get regularBadge => 'Stammkunde';

  @override
  String get regularCustomers => 'Stammkunden (ab 3 Bestellungen)';

  @override
  String restaurantsCount(int count) {
    return '$count Restaurants';
  }

  @override
  String get scheduleOrder => 'Planen';

  @override
  String get scheduleTooSoon =>
      'Wählen Sie eine Uhrzeit mindestens 15 Minuten später.';

  @override
  String get searchCustomer => 'Name oder Telefon';

  @override
  String get sortBiggestSpenders => 'Höchste Ausgaben';

  @override
  String get sortMostOrders => 'Meiste Bestellungen';

  @override
  String get sortRecentVisit => 'Zuletzt da';

  @override
  String get teamNotes => 'Notizen des Teams';

  @override
  String get teamNotesExample =>
      'Z. B. sitzt gern auf der Terrasse, mag scharfe Soße';

  @override
  String get teamNotesHint => 'Nur für Ihr Team sichtbar.';

  @override
  String get trackOrder => 'Verfolgen';

  @override
  String get customerDiscover => 'Entdecken';

  @override
  String get feedEmpty => 'Noch nichts zu entdecken';

  @override
  String get feedEmptyHint =>
      'Videos, Gerichte und Angebote der Restaurants in Ihrer Stadt erscheinen hier.';

  @override
  String get feedOrder => 'Bestellen';

  @override
  String get feedViewDish => 'Gericht ansehen';

  @override
  String get feedViewRestaurant => 'Restaurant ansehen';

  @override
  String get feedLike => 'Gefällt mir';

  @override
  String get feedSave => 'Speichern';

  @override
  String get feedShare => 'Teilen';

  @override
  String get feedSaved => 'In Ihren Inhalten gespeichert.';

  @override
  String get feedUnsaved => 'Aus Ihren gespeicherten Inhalten entfernt.';

  @override
  String get feedLinkCopied => 'Link kopiert: Fügen Sie ihn zum Teilen ein.';

  @override
  String get commentsTitle => 'Kommentare';

  @override
  String get noCommentsYet => 'Noch keine Kommentare.';

  @override
  String get writeComment => 'Kommentar schreiben…';

  @override
  String get adHideForever => 'Nicht mehr anzeigen';

  @override
  String reserveAt(String name) {
    return 'Bei $name reservieren';
  }

  @override
  String get reservationSentHint =>
      'Anfrage gesendet: Das Restaurant bestätigt Ihre Reservierung.';

  @override
  String get reservationNoteLabel => 'Hinweis (optional)';

  @override
  String get errorInvalidComment =>
      'Ein Kommentar muss 1 bis 500 Zeichen lang sein.';

  @override
  String get adStatReach => 'Reichweite';

  @override
  String get adStatEngagement => 'Interaktion';

  @override
  String get adStatLikes => 'Gefällt mir';

  @override
  String get adStatSaves => 'Gespeichert';

  @override
  String get adStatShares => 'Geteilt';

  @override
  String get hideComment => 'Ausblenden';

  @override
  String get moderationReasonExample => 'Z. B. beleidigend, themenfremd';

  @override
  String get hiddenBadge => 'Ausgeblendet';

  @override
  String hiddenBecause(String reason) {
    return 'Ausgeblendet: $reason';
  }

  @override
  String get allFilter => 'Alle';

  @override
  String get publishedComments => 'Veröffentlicht';

  @override
  String get hiddenComments => 'Ausgeblendet';

  @override
  String get adCommentsHint =>
      'Kommentare von Kunden zu Ihren Anzeigen erscheinen hier. Blenden Sie beleidigende oder themenfremde aus.';

  @override
  String get happyBirthday => 'Alles Gute zum Geburtstag!';

  @override
  String birthdayGift(String name, int points) {
    return '$name schenkt Ihnen $points Treuepunkte.';
  }

  @override
  String get thanksAction => 'Danke!';

  @override
  String get notificationsTitle => 'Benachrichtigungen';

  @override
  String get noNotifications => 'Keine Benachrichtigungen';

  @override
  String get noNotificationsHint =>
      'Hier werden Sie informiert, wenn ein Restaurant Ihre Bestellung annimmt, sie fertig ist oder eine Reservierung bestätigt wird.';

  @override
  String get notifOrderAcceptedTitle => 'Bestellung angenommen';

  @override
  String notifOrderAccepted(String brand, String number) {
    return '$brand hat Ihre Bestellung Nr. $number angenommen.';
  }

  @override
  String get notifOrderReadyTitle => 'Bestellung fertig';

  @override
  String notifOrderReady(String brand, String number) {
    return 'Ihre Bestellung Nr. $number ist bei $brand fertig: Sie können sie abholen.';
  }

  @override
  String notifOrderOnTheWay(String brand, String number) {
    return 'Ihre Bestellung Nr. $number von $brand ist fertig und unterwegs.';
  }

  @override
  String get notifOrderRejectedTitle => 'Bestellung abgelehnt';

  @override
  String notifOrderRejected(String brand, String number, String reason) {
    return '$brand konnte Ihre Bestellung Nr. $number nicht annehmen: $reason';
  }

  @override
  String get notifReservationConfirmedTitle => 'Reservierung bestätigt';

  @override
  String notifReservationConfirmed(String brand, String date) {
    return '$brand hat Ihre Reservierung für $date bestätigt.';
  }

  @override
  String get notifReservationDeclinedTitle => 'Reservierung abgelehnt';

  @override
  String notifReservationDeclined(String brand, String date, String reason) {
    return '$brand kann Sie am $date nicht empfangen: $reason';
  }

  @override
  String notifGroupJoined(String name, String brand) {
    return '$name ist Ihrer Gruppenbestellung bei $brand beigetreten.';
  }

  @override
  String notifGroupPlaced(String host, String brand, String number) {
    return '$host hat die Gruppenbestellung bei $brand gesendet (Nr. $number).';
  }

  @override
  String get groupOrderTitle => 'Gruppenbestellung';

  @override
  String get groupOrderAction => 'Gruppenbestellung';

  @override
  String get groupInviteTitle => 'Laden Sie Ihre Gäste ein';

  @override
  String get groupInviteHint =>
      'Teilen Sie diesen Link: Jeder wählt seine Gerichte auf dem eigenen Handy, dann senden Sie eine einzige Bestellung.';

  @override
  String get groupEmpty => 'Noch keine Gerichte';

  @override
  String get groupEmptyHint =>
      'Fügen Sie Ihre Gerichte hinzu und teilen Sie den Link mit Ihren Gästen.';

  @override
  String groupHostedBy(String name) {
    return 'Organisiert von $name';
  }

  @override
  String groupStatusOpen(String time) {
    return 'Offen bis $time';
  }

  @override
  String get groupStatusPlaced => 'An das Restaurant gesendet';

  @override
  String get groupStatusCancelled => 'Storniert';

  @override
  String get groupStatusExpired => 'Abgelaufen';

  @override
  String groupParticipants(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Gäste',
      one: '1 Gast',
    );
    return '$_temp0';
  }

  @override
  String get groupCheckoutTitle => 'Für die ganze Gruppe senden';

  @override
  String get estimatedTotal => 'Geschätzte Summe';

  @override
  String get groupPlaceOrder => 'Bestellung an das Restaurant senden';

  @override
  String get cancelGroupOrder => 'Gruppenbestellung stornieren';

  @override
  String get cancelGroupOrderConfirm =>
      'Diese Gruppenbestellung stornieren? Die Gerichte aller gehen verloren.';

  @override
  String get groupAddMyDishes => 'Meine Gerichte hinzufügen';

  @override
  String groupPlacedInfo(String name) {
    return '$name hat die Bestellung an das Restaurant gesendet.';
  }

  @override
  String get groupClosedInfo => 'Diese Gruppenbestellung ist geschlossen.';

  @override
  String get groupOrderPlaced =>
      'Gruppenbestellung an das Restaurant gesendet.';

  @override
  String get addedToGroup => 'Zur Gruppenbestellung hinzugefügt.';

  @override
  String get addToGroup => 'Zur Gruppe hinzufügen';

  @override
  String get saveDishAction => 'Gericht speichern';

  @override
  String saveDishTitle(String name) {
    return '„$name“ speichern';
  }

  @override
  String get favoriteDishes => 'Lieblingsgerichte';

  @override
  String get myLists => 'Meine Listen';

  @override
  String get myCoupons => 'Meine Gutscheine';

  @override
  String get restaurantsSection => 'Restaurants';

  @override
  String get unavailableNow => 'Nicht verfügbar';

  @override
  String get removeAction => 'Entfernen';

  @override
  String get noFavoriteDishes => 'Keine Lieblingsgerichte';

  @override
  String get noFavoriteDishesHint =>
      'Tippen Sie auf das Herz eines Gerichts, um es hier wiederzufinden.';

  @override
  String get newList => 'Neue Liste';

  @override
  String get noLists => 'Keine Listen';

  @override
  String get noListsHint =>
      'Erstellen Sie Listen wie „Zum Probieren“ oder „Büro-Mittagessen“.';

  @override
  String deleteListConfirm(String name) {
    return 'Liste „$name“ löschen?';
  }

  @override
  String get renameAction => 'Umbenennen';

  @override
  String dishesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Gerichte',
      one: '1 Gericht',
      zero: 'Keine Gerichte',
    );
    return '$_temp0';
  }

  @override
  String get emptyListHint =>
      'Leere Liste: Fügen Sie Gerichte über ihre Seite hinzu.';

  @override
  String get listName => 'Name der Liste';

  @override
  String get listNameExample => 'Z. B. Zum Probieren';

  @override
  String get noCoupons => 'Keine Gutscheine';

  @override
  String get noCouponsHint =>
      'Speichern Sie Angebote der Restaurants auf der Startseite, um sie hier wiederzufinden.';

  @override
  String get couponsHowTo =>
      'Geben Sie den Code in der Bestellverfolgung ein, um den Rabatt zu erhalten.';

  @override
  String validUntil(String date) {
    return 'bis $date';
  }

  @override
  String get couponUsed => 'Bereits verwendet';

  @override
  String get couponExpired => 'Abgelaufen';

  @override
  String get codeCopied => 'Code kopiert.';

  @override
  String get couponSaved => 'Gutschein in Ihren Favoriten gespeichert.';

  @override
  String get saveCouponAction => 'Speichern';

  @override
  String get errorLimitReached =>
      'Limit erreicht: Entfernen Sie Einträge, bevor Sie neue hinzufügen.';

  @override
  String get errorGroupClosed =>
      'Diese Gruppenbestellung ist geschlossen oder abgelaufen.';

  @override
  String get customersTab => 'Kunden';

  @override
  String get offersTab => 'Angebote';

  @override
  String get loyaltyTab => 'Treue';

  @override
  String get activeOffers => 'Laufende Angebote';

  @override
  String get publicCoupons => 'Öffentliche Gutscheine';

  @override
  String get totalUses => 'Einlösungen';

  @override
  String get newOffer => 'Neues Angebot';

  @override
  String get editOffer => 'Angebot bearbeiten';

  @override
  String get offersEmpty => 'Keine Angebote';

  @override
  String get offersEmptyHint =>
      'Erstellen Sie einen Rabatt, einen Aktionscode oder einen öffentlichen Gutschein, um Kunden zu gewinnen und zu binden.';

  @override
  String get offerStatusOff => 'Deaktiviert';

  @override
  String get offerStatusEnded => 'Beendet';

  @override
  String get offerStatusScheduled => 'Geplant';

  @override
  String get offerStatusActive => 'Läuft';

  @override
  String get publicCouponLabel => 'Öffentlicher Gutschein';

  @override
  String get publicCouponHint =>
      'In der App sichtbar: Kunden können ihn in ihrer Geldbörse speichern.';

  @override
  String get publicCouponNeedsCode =>
      'Ein öffentlicher Gutschein braucht einen Code.';

  @override
  String usesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Einlösungen',
      one: '1 Einlösung',
      zero: 'Nie verwendet',
    );
    return '$_temp0';
  }

  @override
  String get offerName => 'Name des Angebots';

  @override
  String get offerNameExample => 'Z. B. Willkommen, Happy Hour';

  @override
  String get discountPercent => 'Prozent';

  @override
  String get discountAmount => 'Betrag';

  @override
  String get offerValue => 'Rabatt';

  @override
  String get promoCodeLabel => 'Code (optional)';

  @override
  String get offerCodeHint =>
      '3 bis 30 Buchstaben oder Ziffern, z. B. WILLKOMMEN';

  @override
  String get minOrderLabel => 'Mindestbestellwert';

  @override
  String get maxUsesLabel => 'Max. Einlösungen';

  @override
  String get perCustomerLabel => 'Pro Kunde';

  @override
  String get startsLabel => 'Beginn';

  @override
  String get endsLabel => 'Ende';

  @override
  String get offerNow => 'sofort';

  @override
  String get noEndDate => 'Ohne Ende';

  @override
  String get allBranchesLabel => 'Alle Standorte';

  @override
  String get thisBranchOnly => 'Dieser Standort';

  @override
  String get offerActive => 'Angebot aktiv';

  @override
  String get loyaltyMembers => 'Mitglieder';

  @override
  String get pointsInCirculation => 'Punkte im Umlauf';

  @override
  String get loyaltyProgramTitle => 'Treueprogramm';

  @override
  String loyaltyExample(String amount, int points) {
    return 'Beispiel: Eine Bestellung über $amount bringt $points Punkte.';
  }

  @override
  String get loyaltyActive => 'Programm aktiv';

  @override
  String get amountPerPoint => 'Betrag für 1 Punkt';

  @override
  String get rewardPointsLabel => 'Punkte für eine Prämie';

  @override
  String get rewardValueLabel => 'Wert der Prämie';

  @override
  String get birthdayPointsLabel => 'Geburtstagspunkte';

  @override
  String get birthdayPointsHint =>
      'Jedes Jahr automatisch Kunden gutgeschrieben, die bereits bei Ihnen bestellt haben (0 = keine).';

  @override
  String get stockDashboardTab => 'Übersicht';

  @override
  String get stockArticlesTab => 'Artikel';

  @override
  String get stockOrdersTab => 'Bestellungen';

  @override
  String get stockReportsTab => 'Berichte';

  @override
  String get stockDashboardTitle => 'Lager-Übersicht';

  @override
  String get stockValueLabel => 'Lagerwert';

  @override
  String get belowThresholdLabel => 'Unter Mindestbestand';

  @override
  String get outOfStockLabel => 'Ausverkauft';

  @override
  String get expiringSoonLabel => 'Bald ablaufend';

  @override
  String get inventoryVarianceLabel => 'Inventurdifferenzen';

  @override
  String get consumptionLabel => 'Verbrauch';

  @override
  String get wasteLabel => 'Verluste';

  @override
  String get receiptsLabel => 'Wareneingänge';

  @override
  String articlesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Artikel',
      one: '1 Artikel',
      zero: 'Keine Artikel',
    );
    return '$_temp0';
  }

  @override
  String daysCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Tage',
      one: '1 Tag',
    );
    return '$_temp0';
  }

  @override
  String get consumptionByDay => 'Verbrauch und Verluste pro Tag';

  @override
  String get topConsumedTitle => 'Meistverbraucht';

  @override
  String get wasteByReason => 'Verluste nach Grund';

  @override
  String get noMovementsPeriod => 'Keine Bewegungen in diesem Zeitraum.';

  @override
  String get noWastePeriod => 'Keine Verluste in diesem Zeitraum.';

  @override
  String get expiringLotsTitle => 'Zu überwachende Chargen (Ablaufdaten)';

  @override
  String get noExpiringLots => 'Keine Charge läuft in den nächsten 7 Tagen ab.';

  @override
  String get toReorderTitle => 'Nachzubestellen';

  @override
  String get noAlerts => 'Kein Artikel unter dem Mindestbestand.';

  @override
  String get prepareOrder => 'Bestellung vorbereiten';

  @override
  String get expiredShort => 'Abgelaufen';

  @override
  String daysLeftShort(int count) {
    return 'T-$count';
  }

  @override
  String daysLeftLong(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Tage Vorrat',
      one: '1 Tag Vorrat',
      zero: 'heute aufgebraucht',
    );
    return '$_temp0';
  }

  @override
  String batchShort(String batch) {
    return 'Charge $batch';
  }

  @override
  String get batchNumber => 'Chargennr.';

  @override
  String get expiryDate => 'Ablaufdatum';

  @override
  String get stockEmptyHint =>
      'Legen Sie Ihre Artikel im Tab Artikel an und erfassen Sie dann den Anfangsbestand oder einen Wareneingang.';

  @override
  String get searchArticle => 'Artikel suchen';

  @override
  String get showInactive => 'Inaktive anzeigen';

  @override
  String get newArticle => 'Neuer Artikel';

  @override
  String get editArticle => 'Artikel bearbeiten';

  @override
  String get articlesEmptyHint =>
      'Fügen Sie Ihre Produkte hinzu: Gemüse, Fleisch, Getränke, Verpackungen, eigene Zubereitungen…';

  @override
  String get storageLabel => 'Lagerung';

  @override
  String get storageAmbient => 'Raumtemperatur';

  @override
  String get storageChilled => 'Gekühlt';

  @override
  String get storageFrozen => 'Tiefgekühlt';

  @override
  String get purchaseUnitLabel => 'Einkaufseinheit';

  @override
  String get purchaseUnitExample => 'Z. B. Sack zu 5 kg, Karton mit 12';

  @override
  String get purchaseUnitQty => 'Inhalt';

  @override
  String get preferredSupplier => 'Stammlieferant';

  @override
  String get noneLabel => 'Keiner';

  @override
  String get shelfLifeDays => 'Haltbarkeit';

  @override
  String get daysShort => 'Tage';

  @override
  String get barcodeLabel => 'Barcode';

  @override
  String get thresholdThisBranch => 'Mindestbestand dieses Standorts';

  @override
  String get reorderTitle => 'Bestellvorschlag';

  @override
  String get reorderHint =>
      'Genug, um über dem Mindestbestand zu bleiben, basierend auf dem Verbrauch der letzten 28 Tage.';

  @override
  String get nothingToReorder => 'Nichts zu bestellen';

  @override
  String get nothingToReorderHint =>
      'Alle erfassten Artikel reichen für den gewählten Zeitraum.';

  @override
  String get noSupplier => 'Ohne Stammlieferant';

  @override
  String get noSupplierHint =>
      'Wählen Sie im Artikel einen Stammlieferanten, um eine Bestellung anzulegen.';

  @override
  String get orderFormPdf => 'Bestellschein als PDF';

  @override
  String get createPurchaseOrder => 'Bestellung anlegen';

  @override
  String get purchaseOrderDraftCreated =>
      'Bestellung als Entwurf im Einkauf angelegt.';

  @override
  String get reorderNote => 'Vom Lager vorgeschlagene Bestellung';

  @override
  String inStockShort(String qty) {
    return 'Bestand: $qty';
  }

  @override
  String get entriesFilter => 'Zugänge';

  @override
  String get exitsLabel => 'Abgänge';

  @override
  String get transfersFilter => 'Umlagerungen';

  @override
  String get adjustmentsFilter => 'Korrekturen';

  @override
  String get movementsReportTitle => 'Lagerbewegungen';

  @override
  String get wasteReportTitle => 'Verluste und Bruch';

  @override
  String get reportValuation => 'Bewerteter Lagerbestand';

  @override
  String get reportValuationHint =>
      'Mengen, Mindestbestände, Durchschnittskosten und Wert jedes Artikels zum jetzigen Zeitpunkt.';

  @override
  String get reportMovementsHint =>
      'Alle Bewegungen des Zeitraums mit Summen nach Art.';

  @override
  String get reportWasteHint => 'Verluste des Zeitraums mit Grund und Wert.';

  @override
  String get reportInventory => 'Inventur mit Differenzen';

  @override
  String get reportInventoryHint =>
      'Soll, gezählt, bewertete Differenzen, mit Unterschriften.';

  @override
  String get reportFoodCost => 'Wareneinsatz pro Gericht';

  @override
  String get reportFoodCostHint =>
      'Selbstkosten, Verkaufspreis, Wareneinsatzquote und Marge jedes Gerichts.';

  @override
  String get reportExpiringHint =>
      'Chargen im Bestand, die innerhalb von 14 Tagen ablaufen.';

  @override
  String get generatePdf => 'PDF erstellen';

  @override
  String get noValidatedInventory => 'Noch keine bestätigte Inventur.';

  @override
  String get chooseInventory => 'Inventur wählen';

  @override
  String generatedOn(String date) {
    return 'Erstellt am $date';
  }

  @override
  String get articlesLabel => 'Artikel';

  @override
  String get articleLabel => 'Artikel';

  @override
  String get avgCostShort => 'Durchschnittskosten';

  @override
  String get valueLabel => 'Wert';

  @override
  String get typeLabel => 'Art';

  @override
  String get inventoryGains => 'Überbestände';

  @override
  String get inventoryLosses => 'Fehlbestände';

  @override
  String get inventoryNet => 'Nettodifferenz';

  @override
  String get theoreticalLabel => 'Soll';

  @override
  String get countedBySignature => 'Gezählt von: ____________________';

  @override
  String get validatedBySignature => 'Bestätigt von: ____________________';

  @override
  String get targetFoodCost => 'Ziel-Wareneinsatz';

  @override
  String get targetFoodCostHint =>
      'Höchster Anteil des Verkaufspreises, den die Zutaten eines Gerichts ausmachen sollen (oft 25 bis 35 %).';

  @override
  String targetFoodCostValue(String percent) {
    return 'Ziel-Wareneinsatz: $percent %';
  }

  @override
  String get dishesWithRecipe => 'Gerichte mit Rezeptur';

  @override
  String get aboveTarget => 'Über dem Ziel';

  @override
  String get aboveTargetShort => 'zu teuer';

  @override
  String get withoutRecipe => 'Ohne Rezeptur';

  @override
  String get recipeDefined => 'Rezeptur vorhanden';

  @override
  String get dishLabel => 'Gericht';

  @override
  String get costPriceShort => 'Kosten';

  @override
  String get sellingPriceShort => 'Preis';

  @override
  String get foodCostShort => 'Wareneinsatz';

  @override
  String get marginShort => 'Marge';

  @override
  String get orderFormTitle => 'Bestellschein';

  @override
  String supplierLabelValue(String name) {
    return 'Lieferant: $name';
  }

  @override
  String get packagingLabel => 'Verpackung';

  @override
  String get unitPriceShort => 'Stückpreis';

  @override
  String get orderFormFooter =>
      'Bitte bestätigen Sie Verfügbarkeit und Lieferzeit.';

  @override
  String get accountTypeQuestion => 'Sie sind:';

  @override
  String get accountTypeCustomer => 'Gast';

  @override
  String get accountTypeCustomerHint =>
      'Restaurants entdecken, bestellen, reservieren';

  @override
  String get accountTypeBusiness => 'Unternehmen';

  @override
  String get accountTypeBusinessHint =>
      'Mein Restaurant und mein Team verwalten';

  @override
  String get accountTypeRequired => 'Wählen Sie Gast oder Unternehmen.';

  @override
  String get accountTypeTitle => 'Willkommen bei Resto';

  @override
  String get accountTypeSub => 'Wie möchten Sie die App nutzen?';

  @override
  String get continueAction => 'Weiter';

  @override
  String adVideoTooBig(String name) {
    return '$name ist größer als 50 MB: Wählen Sie ein kürzeres Video (etwa 30 Sekunden).';
  }

  @override
  String adMediaAdded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Dateien hinzugefügt.',
      one: '1 Datei hinzugefügt.',
    );
    return '$_temp0';
  }

  @override
  String get adNeedVideo =>
      'Fügen Sie vor dem Veröffentlichen dieses Formats ein Video hinzu.';

  @override
  String get adNeedMedia =>
      'Fügen Sie vor dem Veröffentlichen mindestens ein Foto oder Video hinzu.';

  @override
  String get adNeedItems => 'Wählen Sie mindestens ein Gericht aus.';

  @override
  String get uploadingLabel => 'Wird hochgeladen…';

  @override
  String get errorInvalidMedia =>
      'Datei abgelehnt: Sie muss aus Ihrer Mediathek stammen.';

  @override
  String get errorFileTooLarge => 'Datei zu groß.';

  @override
  String get errorFileType =>
      'Dateiformat nicht unterstützt (JPG, PNG, WebP, MP4, WebM, MOV).';

  @override
  String get adAddVideo => 'Video hinzufügen';

  @override
  String get errorOutOfStock => 'Dieses Gericht ist für heute ausverkauft.';

  @override
  String get errorInvalidRating =>
      'Die Bewertung muss zwischen 1 und 5 liegen.';

  @override
  String get errorInvalidAllergen => 'Unbekanntes Allergen.';

  @override
  String get bestSeller => 'Bestseller';

  @override
  String get callAction => 'Anrufen';

  @override
  String get writeAction => 'Schreiben';

  @override
  String get categoriesLabel => 'Kategorien';

  @override
  String get filtersLabel => 'Filter';

  @override
  String get reviewsTab => 'Bewertungen';

  @override
  String get infosTab => 'Infos';

  @override
  String get noDishMatches => 'Kein Gericht passt zu diesen Filtern.';

  @override
  String soldCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count verkauft',
      one: '1 verkauft',
    );
    return '$_temp0';
  }

  @override
  String get yourCart => 'Ihr Warenkorb';

  @override
  String get coverPhoto => 'Titelbild';

  @override
  String get coverPhotoHint =>
      'Großes Foto oben auf Ihrer Restaurantseite (Gastraum, Terrasse, Fassade).';

  @override
  String get changePhoto => 'Foto ändern';

  @override
  String get itemTagsLabel => 'Etiketten (Filter Ihrer Speisekarte)';

  @override
  String get itemTagsHint =>
      'Erstellen Sie eigene Etiketten: Ihre Gäste können die Karte damit filtern. Z. B. Leicht scharf, Halal, Alkoholfrei, Hausgemacht.';

  @override
  String get addTagHint => 'Neues Etikett + Enter';

  @override
  String get errorInvalidTag => 'Ein Etikett darf höchstens 30 Zeichen haben.';

  @override
  String itemFavorites(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Kunden haben es als Favorit',
      one: '1 Kunde hat es als Favorit',
      zero: 'Kein Kunde hat es als Favorit',
    );
    return '$_temp0';
  }

  @override
  String get itemSold30 => 'Verkäufe der letzten 30 Tage';

  @override
  String get receiptOrderNo => 'Bestellung Nr.';

  @override
  String get receiptTicketNo => 'Beleg Nr.';

  @override
  String get receiptChannel => 'Kanal';

  @override
  String get receiptQtyShort => 'Menge';

  @override
  String get receiptTotalInclTax => 'Gesamt inkl. Steuern';

  @override
  String get receiptTotalExclTax => 'Gesamt ohne Steuern';

  @override
  String get receiptApproved => 'Transaktion genehmigt';

  @override
  String receiptRef(String ref) {
    return 'Ref.: $ref';
  }

  @override
  String receiptSeeYou(String name) {
    return 'Bis bald bei $name';
  }

  @override
  String get receiptRecycle =>
      'Für einen grüneren Planeten: Bitte recyceln Sie diesen Beleg.';

  @override
  String get receiptLoyaltyTitle => 'Ihre Treue wird belohnt!';

  @override
  String get receiptLoyaltyCaption =>
      'Scannen Sie diesen QR-Code, um Ihren Treuebereich zu öffnen und Ihre Vorteile zu nutzen.';

  @override
  String get receiptPaperLabel => 'Belegdrucker dieses Geräts';

  @override
  String get receiptPaper80 => '80-mm-Rolle';

  @override
  String get receiptPaper58 => '58-mm-Rolle';

  @override
  String get receiptPhotosLabel => 'Fotos der Gerichte auf dem Beleg';

  @override
  String get receiptTestPrint => 'Testbeleg drucken';

  @override
  String get receiptTestTitle => 'Testbeleg';

  @override
  String get receiptHeaderSection => 'Kopf des Belegs';

  @override
  String get receiptFooterSection => 'Fuß des Belegs';

  @override
  String get receiptTitleLabel => 'Angezeigter Name';

  @override
  String get receiptTitleHint => 'Standard: der Markenname';

  @override
  String get receiptSubtitleLabel => 'Untertitel';

  @override
  String get receiptSubtitleHint => 'z. B. Restaurant & Genuss';

  @override
  String get receiptSloganLabel => 'Slogan';

  @override
  String get receiptSloganHint =>
      'z. B. Authentische Küche, Aromen aus aller Welt';

  @override
  String get websiteLabel => 'Website';

  @override
  String get websiteHint => 'z. B. www.meinrestaurant.de';

  @override
  String get receiptQrTitleLabel => 'Titel neben dem QR-Code';

  @override
  String get receiptQrCaptionLabel => 'Text neben dem QR-Code';

  @override
  String get receiptFarewellLabel => 'Abschiedsgruß';

  @override
  String get receiptFarewellHint => 'z. B. Bis bald!';

  @override
  String itemLikesTip(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Likes',
      one: '1 Like',
      zero: 'Keine Likes',
    );
    return '$_temp0';
  }

  @override
  String get itemReviewAction => 'Bewerten';

  @override
  String get itemHeartAction => 'Herz';

  @override
  String get itemCommentsTitle => 'Kundenmeinungen';

  @override
  String get itemVerifiedReviews => 'Bewertungen nach einer Bestellung';

  @override
  String get notifStaffNewOrderTitle => 'Neue Bestellung';

  @override
  String notifStaffNewOrder(String number, String customer, String branch) {
    return 'Bestellung Nr. $number $customer — $branch';
  }

  @override
  String get notifStaffOrderReadyTitle => 'Bestellung servierbereit';

  @override
  String notifStaffOrderReady(String number, String branch) {
    return 'Bestellung Nr. $number — $branch';
  }

  @override
  String get notifStaffReservationTitle => 'Neue Reservierung';

  @override
  String notifStaffReservation(String name, int count, String date) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Personen',
      one: '1 Person',
    );
    return '$name · $_temp0 · $date';
  }

  @override
  String get notifStaffReviewTitle => 'Neue Bewertung';

  @override
  String notifStaffReview(String author, String item) {
    return '$author zu „$item“';
  }

  @override
  String get pushNewOrder =>
      'Benachrichtigung auf dem Telefon: neue Kundenbestellung';

  @override
  String get pushOrderReady =>
      'Benachrichtigung auf dem Telefon: Bestellung servierbereit';

  @override
  String get pushReservations =>
      'Benachrichtigung auf dem Telefon: neue Reservierung';

  @override
  String get pushReviews =>
      'Benachrichtigung auf dem Telefon: neue Bewertung eines Gerichts';

  @override
  String get tablesTab => 'Tische';

  @override
  String get tablesNow => 'Jetzt';

  @override
  String get tablesLater => 'Zeitpunkt wählen';

  @override
  String get tableLegendOccupied => 'Besetzt';

  @override
  String get tableLegendReserved => 'Reserviert';

  @override
  String get tableLegendChosen => 'Ihre Wahl';

  @override
  String tableFreeUntil(String time) {
    return 'Frei bis $time';
  }

  @override
  String tableOccupiedUntil(String time) {
    return 'Frei gegen $time';
  }

  @override
  String tableReservedSlot(String from, String to) {
    return 'Reserviert $from–$to';
  }

  @override
  String get tablesSelectHint =>
      'Tippen Sie auf einen oder mehrere freie Tische, um sie zu reservieren.';

  @override
  String tablesSeatsChosen(int seats, int party) {
    String _temp0 = intl.Intl.pluralLogic(
      seats,
      locale: localeName,
      other: '$seats Plätze gewählt',
      one: '1 Platz gewählt',
    );
    String _temp1 = intl.Intl.pluralLogic(
      party,
      locale: localeName,
      other: '$party Personen',
      one: '1 Person',
    );
    return '$_temp0 für $_temp1';
  }

  @override
  String reserveTablesAction(String tables) {
    return '$tables reservieren';
  }

  @override
  String tableLabelChip(String label) {
    return 'Tisch $label';
  }

  @override
  String get tablesEmpty =>
      'Dieses Restaurant hat seine Tische noch nicht vorgestellt.';

  @override
  String appVersion(String version, String build) {
    return 'Resto · Version $version ($build)';
  }

  @override
  String get dashTabOverview => 'Überblick';

  @override
  String get dashTabDishes => 'Gerichte';

  @override
  String get dashTabTeam => 'Team und Service';

  @override
  String get dashTabFinance => 'Finanzen';

  @override
  String get coversLabel => 'Gedecke';

  @override
  String perCoverLabel(String amount) {
    return '$amount pro Gedeck';
  }

  @override
  String get occupancyLabel => 'Belegte Tische';

  @override
  String get paymentsByMethod => 'Einnahmen nach Zahlungsart';

  @override
  String get busyHours => 'Andrang nach Tag und Uhrzeit';

  @override
  String get menuEngineering => 'Menü-Engineering';

  @override
  String get menuEngineeringHint =>
      'Verkäufe × Marge je Gericht, laut Rezepturen.';

  @override
  String get engStars => 'Stars';

  @override
  String get engStarsHint => 'Beliebt und rentabel: weiter hervorheben.';

  @override
  String get engPlowhorses => 'Beliebt, wenig rentabel';

  @override
  String get engPlowhorsesHint => 'Preis oder Wareneinsatz prüfen.';

  @override
  String get engPuzzles => 'Rentabel, selten verkauft';

  @override
  String get engPuzzlesHint =>
      'Hervorheben: Foto, Werbung, Empfehlung des Personals.';

  @override
  String get engDogs => 'Zu überprüfen';

  @override
  String get engDogsHint =>
      'Selten verkauft und wenig rentabel: überarbeiten oder streichen.';

  @override
  String engNoRecipe(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Gerichte ohne Rezeptur sind nicht eingeordnet.',
      one: '1 Gericht ohne Rezeptur ist nicht eingeordnet.',
    );
    return '$_temp0';
  }

  @override
  String get slowSellers => 'Selten verkaufte Gerichte';

  @override
  String get teamPerformance => 'Leistung des Teams';

  @override
  String get memberLabel => 'Mitglied';

  @override
  String get staffOrders => 'Bestellungen';

  @override
  String get staffSales => 'Umsatz';

  @override
  String get staffTips => 'Trinkgeld';

  @override
  String get serviceTimes => 'Servicezeiten';

  @override
  String get serveTime => 'Bis zum Tisch';

  @override
  String get tableTime => 'Zeit am Tisch';

  @override
  String minutesValue(int count) {
    return '$count Min.';
  }

  @override
  String targetMinutes(int count) {
    return 'Ziel: $count Min.';
  }

  @override
  String get cancellationsTitle => 'Stornierungen';

  @override
  String cancelledOrdersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count stornierte Bestellungen',
      one: '1 stornierte Bestellung',
      zero: 'Keine stornierte Bestellung',
    );
    return '$_temp0';
  }

  @override
  String cancelledItemsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Artikel nach dem Senden storniert',
      one: '1 Artikel nach dem Senden storniert',
      zero: 'Kein Artikel nach dem Senden storniert',
    );
    return '$_temp0';
  }

  @override
  String get cancelReasonsTitle => 'Häufigste Gründe';

  @override
  String get dashPdf => 'PDF-Bericht';

  @override
  String get insightsUnavailable =>
      'Die detaillierten Kennzahlen erscheinen nach dem Datenbank-Update (Migration 034).';

  @override
  String get salesByDayTitle => 'Umsatz pro Tag';

  @override
  String get ordersCountLabel => 'Bestellungen';

  @override
  String get financeItemLabel => 'Posten';

  @override
  String get supplierLabel => 'Lieferant';

  @override
  String get purchaseOrderTitle => 'Bestellschein';

  @override
  String get supplierStatementTitle => 'Kontoauszug des Lieferanten';

  @override
  String get dueDateLabel => 'Fälligkeit';

  @override
  String get balanceDue => 'Offener Betrag';

  @override
  String get purchasesThisMonth => 'Einkäufe des Monats';

  @override
  String openInvoicesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count offene Rechnungen',
      one: '1 offene Rechnung',
      zero: 'Keine offene Rechnung',
    );
    return '$_temp0';
  }

  @override
  String get overdueInvoices => 'Überfällige Rechnungen';

  @override
  String get dueWithinWeek => 'Fällig in 7 Tagen';

  @override
  String get pendingPurchaseOrders => 'Laufende Bestellungen';

  @override
  String get paymentSchedule => 'Zahlungsplan';

  @override
  String get nothingToPay => 'Keine offene Rechnung.';

  @override
  String get noDueDate => 'Ohne Fälligkeit';

  @override
  String get purchasesByMonth => 'Einkäufe pro Monat';

  @override
  String get topSuppliers => 'Wichtigste Lieferanten (90 Tage)';

  @override
  String get noPurchasesYet => 'Noch keine Einkäufe.';

  @override
  String get totalPurchased => 'Gesamt eingekauft';

  @override
  String get purchaseOrderPdf => 'Bestellschein als PDF';

  @override
  String recurringGenerated(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count wiederkehrende Ausgaben gebucht.',
      one: '1 wiederkehrende Ausgabe gebucht.',
      zero: 'Keine Ausgabe zu buchen.',
    );
    return '$_temp0';
  }

  @override
  String recurringDue(int count, String amount) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count wiederkehrende Ausgaben diesen Monat zu buchen ($amount)',
      one: '1 wiederkehrende Ausgabe diesen Monat zu buchen ($amount)',
    );
    return '$_temp0';
  }

  @override
  String get generateNow => 'Buchen';

  @override
  String get expensesOfMonth => 'Ausgaben des Monats';

  @override
  String vsLastMonth(String value) {
    return '$value zum Vormonat';
  }

  @override
  String get lastMonthLabel => 'Vormonat';

  @override
  String get recurringTab => 'Wiederkehrend';

  @override
  String get budgetsExceeded => 'Überschrittene Budgets';

  @override
  String get expensesSixMonths => 'Ausgaben der letzten sechs Monate';

  @override
  String get budgetsTab => 'Budgets';

  @override
  String get noBudgetsYet =>
      'Kein Budget festgelegt. Legen Sie welche im Reiter Budgets an.';

  @override
  String get newRecurringExpense => 'Neue wiederkehrende Ausgabe';

  @override
  String get recurringHint =>
      'Miete, Abos, Gehälter…: jeden Monat mit einem Tipp in der Übersicht gebucht.';

  @override
  String get noRecurringYet => 'Keine wiederkehrende Ausgabe.';

  @override
  String everyMonthOn(int day) {
    return 'jeden Monat am $day.';
  }

  @override
  String get recurringExample => 'z. B. Miete der Räume';

  @override
  String get expenseCategoryField => 'Kategorie';

  @override
  String get dayOfMonthLabel => 'Tag des Monats';

  @override
  String get budgetsHint =>
      'Monatlicher Höchstbetrag je Kategorie. Leer lassen, um eine Kategorie nicht zu verfolgen.';
}
