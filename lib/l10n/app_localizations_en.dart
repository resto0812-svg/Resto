// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Resto';

  @override
  String environmentBanner(String env) {
    return 'Environment: $env';
  }

  @override
  String get configMissingTitle => 'Missing configuration';

  @override
  String get configMissingBody =>
      'The server address and public key were not provided (env/<environment>.json file).';

  @override
  String get languageLabel => 'Language';

  @override
  String get systemLanguage => 'Device language';

  @override
  String pendingSyncEvents(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pending operations',
      one: '1 pending operation',
      zero: 'Everything is synced',
    );
    return '$_temp0';
  }

  @override
  String get errorNotAuthenticated => 'Please sign in.';

  @override
  String get errorForbidden => 'You are not allowed to perform this action.';

  @override
  String get errorOwnerOnly => 'Only an owner can perform this action.';

  @override
  String get errorRateLimited => 'Too many requests. Please try again later.';

  @override
  String get errorInvalidTimezone => 'Unknown time zone.';

  @override
  String get errorInvalidRole => 'Unknown role.';

  @override
  String get errorInvalidEmail => 'Invalid email address.';

  @override
  String get errorInvalidBranch => 'Location not found in this organization.';

  @override
  String get errorBranchesRequired => 'Select at least one location.';

  @override
  String get errorAlreadyMember =>
      'This person is already a member of the organization.';

  @override
  String get errorInvitationInvalid =>
      'Invalid, expired or already used invitation.';

  @override
  String get errorInvitationWrongAccount =>
      'This invitation is for a different email address.';

  @override
  String get errorLastOwner => 'The organization must keep at least one owner.';

  @override
  String get errorMembershipRevoked =>
      'This member was removed from the organization.';

  @override
  String get errorNetwork => 'Unable to connect. Check your Internet access.';

  @override
  String get errorUnknown => 'An unexpected error occurred.';

  @override
  String get welcomeTitle => 'Welcome to Resto';

  @override
  String get signInTitle => 'Sign in';

  @override
  String get signIn => 'Sign in';

  @override
  String get signOut => 'Sign out';

  @override
  String get createAccount => 'Create an account';

  @override
  String get forgotPassword => 'Forgot password';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get passwordConfirm => 'Confirm password';

  @override
  String get passwordTooShort => 'At least 8 characters.';

  @override
  String get passwordsDiffer => 'Passwords do not match.';

  @override
  String get passwordChanged => 'Password changed.';

  @override
  String get newPasswordTitle => 'New password';

  @override
  String get changePassword => 'Change password';

  @override
  String get displayName => 'Name';

  @override
  String get fieldRequired => 'Required field';

  @override
  String get verifyEmailTitle => 'Confirm your email address';

  @override
  String codeSentTo(String email) {
    return 'Code sent to $email.';
  }

  @override
  String get code => 'Code';

  @override
  String get verify => 'Confirm';

  @override
  String get resendCode => 'Resend code';

  @override
  String get codeResent => 'A new code has been sent.';

  @override
  String get sendCode => 'Send code';

  @override
  String get authInvalidCredentials => 'Incorrect email or password.';

  @override
  String get authEmailNotConfirmed => 'Email address not confirmed.';

  @override
  String get authUserExists => 'An account already exists with this address.';

  @override
  String get authWeakPassword => 'Password too weak.';

  @override
  String get authCodeInvalid => 'Invalid or expired code.';

  @override
  String get authSamePassword =>
      'The new password must differ from the old one.';

  @override
  String get errorDuplicate => 'This value already exists.';

  @override
  String get errorInvalidHours => 'Invalid opening hours.';

  @override
  String get createRestaurant => 'Create my restaurant';

  @override
  String get joinTeam => 'Join a team';

  @override
  String get organizationName => 'Organization name';

  @override
  String get brandNameOptional => 'Trade name (optional)';

  @override
  String get branchNameOptional => 'Location name (optional)';

  @override
  String get country => 'Country';

  @override
  String get currency => 'Currency';

  @override
  String get timezone => 'Time zone';

  @override
  String get defaultLanguage => 'Main language';

  @override
  String get city => 'City';

  @override
  String get create => 'Create';

  @override
  String get invitationCode => 'Invitation code';

  @override
  String get join => 'Join';

  @override
  String get navBranches => 'Locations';

  @override
  String get navTeam => 'Team';

  @override
  String get navAudit => 'Log';

  @override
  String get navAccount => 'Account';

  @override
  String get switchOrganization => 'Switch organization';

  @override
  String get orgSuspended => 'Organization suspended: read-only.';

  @override
  String get newBranch => 'New location';

  @override
  String get noBranches => 'No locations.';

  @override
  String get branchInfo => 'Details';

  @override
  String get openingHours => 'Opening hours';

  @override
  String get floor => 'Floor';

  @override
  String get name => 'Name';

  @override
  String get addressLine1 => 'Address';

  @override
  String get addressLine2 => 'Address line 2';

  @override
  String get region => 'Region';

  @override
  String get postalCode => 'Postal code';

  @override
  String get phone => 'Phone';

  @override
  String get offeredLanguages => 'Languages offered';

  @override
  String get published => 'Visible to customers';

  @override
  String get archived => 'Archived';

  @override
  String get readOnly => 'Read-only';

  @override
  String get save => 'Save';

  @override
  String get saved => 'Saved.';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get close => 'Close';

  @override
  String get edit => 'Edit';

  @override
  String get retry => 'Retry';

  @override
  String get closed => 'Closed';

  @override
  String get addSlot => 'Add a time slot';

  @override
  String get opensAt => 'Opening';

  @override
  String get closesAt => 'Closing';

  @override
  String get nextDay => 'next day';

  @override
  String get weekday1 => 'Monday';

  @override
  String get weekday2 => 'Tuesday';

  @override
  String get weekday3 => 'Wednesday';

  @override
  String get weekday4 => 'Thursday';

  @override
  String get weekday5 => 'Friday';

  @override
  String get weekday6 => 'Saturday';

  @override
  String get weekday7 => 'Sunday';

  @override
  String get newArea => 'New area';

  @override
  String get areaName => 'Area';

  @override
  String get noAreas => 'No areas yet.';

  @override
  String get newTable => 'New table';

  @override
  String get tableLabel => 'Table name';

  @override
  String get seats => 'Seats';

  @override
  String get active => 'Active';

  @override
  String get inactive => 'inactive';

  @override
  String tablesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tables',
      one: '1 table',
      zero: 'no tables',
    );
    return '$_temp0';
  }

  @override
  String seatsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count seats',
      one: '1 seat',
    );
    return '$_temp0';
  }

  @override
  String get invite => 'Invite';

  @override
  String get role => 'Role';

  @override
  String get allBranches => 'All locations';

  @override
  String get pendingInvitations => 'Pending invitations';

  @override
  String expiresOn(String date) {
    return 'Expires on $date';
  }

  @override
  String get revoke => 'Remove';

  @override
  String revokeConfirm(String name) {
    return 'Remove $name from the organization?';
  }

  @override
  String get changeRole => 'Change role';

  @override
  String get you => 'you';

  @override
  String get invitationCreatedTitle => 'Invitation created';

  @override
  String invitationCreatedBody(String email) {
    return 'Send this code to $email. It is valid for 7 days and only works with this address.';
  }

  @override
  String invitationMessage(String organization, String code) {
    return 'You are invited to join \"$organization\" on Resto. Create your account with this email address, then enter this code in \"Join a team\": $code';
  }

  @override
  String get copyMessage => 'Copy message';

  @override
  String get copied => 'Copied.';

  @override
  String get roleOwner => 'Owner';

  @override
  String get roleAdmin => 'Administrator';

  @override
  String get roleManager => 'Manager';

  @override
  String get roleAccountant => 'Accountant';

  @override
  String get roleCashier => 'Cashier';

  @override
  String get roleStockKeeper => 'Stock keeper';

  @override
  String get roleWaiter => 'Waiter';

  @override
  String get roleKitchen => 'Kitchen / bar';

  @override
  String get roleViewer => 'Viewer';

  @override
  String get loadMore => 'Show more';

  @override
  String get noEntries => 'No operations recorded.';

  @override
  String get actionInsert => 'Created';

  @override
  String get actionUpdate => 'Changed';

  @override
  String get actionDelete => 'Deleted';

  @override
  String get entityOrganization => 'Organization';

  @override
  String get entityMembership => 'Member';

  @override
  String get entityInvitation => 'Invitation';

  @override
  String get entityBrand => 'Brand';

  @override
  String get entityBranch => 'Location';

  @override
  String get entityArea => 'Area';

  @override
  String get entityTable => 'Table';

  @override
  String get navMenus => 'Menus';

  @override
  String get brand => 'Brand';

  @override
  String get category => 'Category';

  @override
  String get description => 'Description';

  @override
  String get newCategory => 'New category';

  @override
  String get kindFood => 'Dish';

  @override
  String get kindDrink => 'Drink';

  @override
  String get kindOther => 'Other';

  @override
  String selectionRule(int min, String max) {
    return 'Choices: $min to $max';
  }

  @override
  String get allergens => 'Allergens';

  @override
  String get allergenGluten => 'Gluten';

  @override
  String get allergenCrustaceans => 'Crustaceans';

  @override
  String get allergenEggs => 'Eggs';

  @override
  String get allergenFish => 'Fish';

  @override
  String get allergenPeanuts => 'Peanuts';

  @override
  String get allergenSoybeans => 'Soy';

  @override
  String get allergenMilk => 'Milk';

  @override
  String get allergenNuts => 'Tree nuts';

  @override
  String get allergenCelery => 'Celery';

  @override
  String get allergenMustard => 'Mustard';

  @override
  String get allergenSesame => 'Sesame';

  @override
  String get allergenSulphites => 'Sulphites';

  @override
  String get allergenLupin => 'Lupin';

  @override
  String get allergenMolluscs => 'Molluscs';

  @override
  String get translations => 'Translations';

  @override
  String get soldOut => 'Sold out';

  @override
  String get channelDefault => 'Base price';

  @override
  String get channelDineIn => 'Dine-in';

  @override
  String get channelTakeaway => 'Takeaway';

  @override
  String get channelDelivery => 'Delivery';

  @override
  String get otherChannels => 'Prices per channel';

  @override
  String get noPrice => 'No price';

  @override
  String get errorInvalidPrice => 'Invalid price.';

  @override
  String get errorCurrencyLocked =>
      'The currency can no longer change: prices already exist at this location.';

  @override
  String get entityItem => 'Item';

  @override
  String get entityVariant => 'Variant';

  @override
  String get entityModifier => 'Add-on';

  @override
  String get entityPrice => 'Price';

  @override
  String get menuOfBranch => 'Menu of location';

  @override
  String get menuEmptyTitle => 'Your menu is empty';

  @override
  String get menuEmptyHint =>
      'Start by creating a category (for example Dishes, Drinks, Desserts), then add your items with their price.';

  @override
  String get categoryExamples => 'E.g. Dishes, Drinks, Desserts';

  @override
  String get descriptionOptional => 'Description (optional)';

  @override
  String get visibleOnMenu => 'Visible on the menu';

  @override
  String get hidden => 'hidden';

  @override
  String get addItem => 'Add an item';

  @override
  String addItemIn(String category) {
    return 'Add an item to \"$category\"';
  }

  @override
  String get notSoldHere => 'Not sold at this location';

  @override
  String get itemName => 'Item name';

  @override
  String get itemExamples => 'E.g. Ndole, Chicken DG, Hibiscus juice';

  @override
  String get priceTitle => 'Price';

  @override
  String priceAt(String branch) {
    return 'Price at $branch';
  }

  @override
  String get price => 'Price';

  @override
  String get severalSizes => 'This item comes in several sizes or formats';

  @override
  String get sizeName => 'Size / format';

  @override
  String get sizeExamples => 'E.g. Small, 33 cl';

  @override
  String get addSize => 'Add a size';

  @override
  String get removeSize => 'Remove this size';

  @override
  String get sizeNameRequired =>
      'Give each size a name (for example Small, Large).';

  @override
  String get samePriceEverywhere =>
      'This price will apply at all the locations selected below; you can adjust it for each one later.';

  @override
  String get salesTitle => 'Sales';

  @override
  String soldAt(String branch) {
    return 'Sold at $branch';
  }

  @override
  String get soldOutToday => 'Sold out for now';

  @override
  String get optionsForItem => 'Options offered to the customer';

  @override
  String get manageOptions => 'Manage options';

  @override
  String get noOptionsYet => 'No options yet (side dish, cooking, sauce…).';

  @override
  String get optionsTitle => 'Options and add-ons';

  @override
  String get optionsIntro =>
      'An option is a choice the customer makes when ordering an item: side dish, cooking, a sauce, a paid add-on…';

  @override
  String get newOptionGroup => 'New option';

  @override
  String get optionGroupName => 'Option name';

  @override
  String get optionGroupExamples => 'E.g. Side dish, Cooking, Spiciness';

  @override
  String get customerMust => 'The customer:';

  @override
  String get ruleRequiredOne => 'must make 1 choice (required)';

  @override
  String get ruleOptionalOne => 'may make 1 choice (optional)';

  @override
  String get ruleOptionalMany => 'may make several choices (optional)';

  @override
  String get ruleRequiredMany => 'must make at least 1 choice, several allowed';

  @override
  String get choices => 'Choices offered';

  @override
  String choicePriceHint(String branch) {
    return 'Leave the price empty or 0 if the choice is free. Price for $branch.';
  }

  @override
  String get choiceName => 'Choice';

  @override
  String get choiceExamples => 'E.g. Miondo, Rice';

  @override
  String get extraPrice => 'Extra price';

  @override
  String get addChoice => 'Add a choice';

  @override
  String get removeChoice => 'Remove this choice';

  @override
  String get choicesRequired => 'Add at least one choice.';

  @override
  String get navOrders => 'Orders';

  @override
  String openOrdersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count open orders',
      one: '1 open order',
      zero: 'No open orders',
    );
    return '$_temp0';
  }

  @override
  String get refresh => 'Refresh';

  @override
  String get newTakeaway => 'Takeaway sale';

  @override
  String get takeawayOrders => 'Open takeaway orders';

  @override
  String orderNumber(int number) {
    return 'Order #$number';
  }

  @override
  String minutesAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count min ago',
      one: '1 min ago',
      zero: 'just now',
    );
    return '$_temp0';
  }

  @override
  String get noTablesYet =>
      'No tables: set up the floor in Locations → Floor. Takeaway sales are still possible.';

  @override
  String get tableFree => 'Free';

  @override
  String get toSend => 'Items to send to the kitchen';

  @override
  String tableName(String label) {
    return 'Table $label';
  }

  @override
  String get menuTab => 'Menu';

  @override
  String ticketTab(int count) {
    return 'Order ($count)';
  }

  @override
  String get allCategories => 'All';

  @override
  String get nothingToSell =>
      'Nothing to sell yet: add items with a price in Menus.';

  @override
  String fromPrice(String price) {
    return 'from $price';
  }

  @override
  String itemSoldOut(String name) {
    return '$name is sold out.';
  }

  @override
  String get emptyTicket => 'Tap an item on the menu to add it.';

  @override
  String get less => 'One less';

  @override
  String get more => 'One more';

  @override
  String get cancelLine => 'Cancel this line';

  @override
  String get cancelOrder => 'Cancel the order';

  @override
  String get cancelOrderConfirm =>
      'Cancel this order? Nothing has been sent to the kitchen yet.';

  @override
  String get reason => 'Reason';

  @override
  String get subtotal => 'Subtotal';

  @override
  String taxLine(String rate) {
    return 'Tax ($rate %)';
  }

  @override
  String get total => 'Total';

  @override
  String taxIncluded(String rate, String amount) {
    return 'including $rate % tax: $amount';
  }

  @override
  String sendToKitchen(int count) {
    return 'Send to kitchen ($count)';
  }

  @override
  String sentToKitchen(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items sent to the kitchen',
      one: '1 item sent to the kitchen',
    );
    return '$_temp0';
  }

  @override
  String get prepPending => 'To send';

  @override
  String get prepSent => 'In the kitchen';

  @override
  String get prepPreparing => 'Being prepared';

  @override
  String get prepReady => 'Ready';

  @override
  String get prepServed => 'Served';

  @override
  String get prepCancelled => 'Cancelled';

  @override
  String get noneOption => 'None';

  @override
  String get kitchenNote => 'Note for the kitchen (optional)';

  @override
  String get kitchenNoteExamples => 'E.g. no onion, well done';

  @override
  String get quantity => 'Quantity';

  @override
  String addForPrice(String price) {
    return 'Add · $price';
  }

  @override
  String get taxTitle => 'Tax';

  @override
  String get taxRate => 'Tax rate';

  @override
  String get taxRateHint => 'E.g. 19.25 (0 if no tax)';

  @override
  String get pricesIncludeTax => 'Displayed prices include tax';

  @override
  String get errorInvalidTaxRate => 'Invalid rate (0 to 99.999).';

  @override
  String get errorOrderNotOpen => 'This order is no longer open.';

  @override
  String get errorItemUnavailable =>
      'This item is not available at this location.';

  @override
  String get errorNoPrice => 'This item has no price at this location.';

  @override
  String get errorOptionsInvalid =>
      'The selected options do not follow the item\'s rules.';

  @override
  String get errorInvalidQuantity => 'Invalid quantity.';

  @override
  String get errorItemAlreadySent =>
      'This line has already gone to the kitchen and can no longer be changed.';

  @override
  String get errorReasonRequired => 'Please give a reason.';

  @override
  String get errorInvalidOrder => 'Invalid order.';

  @override
  String get errorBranchInactive => 'This location is archived.';

  @override
  String get navCash => 'Cash';

  @override
  String get amount => 'Amount';

  @override
  String get registerClosed => 'closed';

  @override
  String get openRegisterShort => 'Open the register';

  @override
  String openRegister(String name) {
    return 'Open $name';
  }

  @override
  String get openingFloat => 'Opening float (starting change)';

  @override
  String registerOpenSince(String time) {
    return 'open since $time';
  }

  @override
  String expectedCash(String amount) {
    return 'Expected cash: $amount';
  }

  @override
  String cashBreakdown(String float, String inAmount, String outAmount) {
    return 'Float $float · in $inAmount · out $outAmount';
  }

  @override
  String paymentsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count payments',
      one: '1 payment',
      zero: 'no payments',
    );
    return '$_temp0';
  }

  @override
  String get cashIn => 'Cash in';

  @override
  String get cashOut => 'Cash out';

  @override
  String get movementExamples => 'E.g. gas purchase, extra change';

  @override
  String get closeRegister => 'Close the register';

  @override
  String get countedCash => 'Cash counted in the drawer';

  @override
  String get countInfo =>
      'Count the notes and coins in the drawer, float included.';

  @override
  String get countResult => 'Count result';

  @override
  String countedCashValue(String amount) {
    return 'Counted: $amount';
  }

  @override
  String get noDifference => 'No difference';

  @override
  String differenceValue(String amount) {
    return 'Difference: $amount';
  }

  @override
  String get awaitingValidation => 'A manager must now validate this closing.';

  @override
  String get awaitingValidationTitle => 'Closings to validate';

  @override
  String get validateClosing => 'Validate the closing';

  @override
  String get validate => 'Validate';

  @override
  String get comment => 'Comment';

  @override
  String get closedSessions => 'Recent closings';

  @override
  String get dailyReport => 'Daily report';

  @override
  String get previousDay => 'Previous day';

  @override
  String get nextDayButton => 'Next day';

  @override
  String get salesTotal => 'Sales';

  @override
  String get ordersClosedCount => 'Paid orders';

  @override
  String get averageTicket => 'Average ticket';

  @override
  String get taxCollected => 'Tax collected';

  @override
  String get paymentsReceived => 'Payments by method';

  @override
  String ordersStillOpen(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count orders still open',
      one: '1 order still open',
      zero: 'no open orders',
    );
    return '$_temp0';
  }

  @override
  String ordersCancelledCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cancelled',
      one: '1 cancelled',
      zero: 'none cancelled',
    );
    return '$_temp0';
  }

  @override
  String linesCancelledCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lines cancelled',
      one: '1 line cancelled',
      zero: 'no lines cancelled',
    );
    return '$_temp0';
  }

  @override
  String refundsTotal(String amount) {
    return 'refunded: $amount';
  }

  @override
  String get topItems => 'Best-selling items';

  @override
  String get payCash => 'Cash';

  @override
  String get payCard => 'Card';

  @override
  String get payMobileMoney => 'Mobile Money';

  @override
  String get payTransfer => 'Transfer';

  @override
  String get payOther => 'Other';

  @override
  String get collectPayment => 'Collect payment';

  @override
  String collectAmount(String amount) {
    return 'Collect $amount';
  }

  @override
  String amountDue(String amount) {
    return 'Amount due: $amount';
  }

  @override
  String get splitBill => 'Split the bill';

  @override
  String splitParts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count shares',
      one: '1 share',
    );
    return '$_temp0';
  }

  @override
  String get amountToCollect => 'Amount collected';

  @override
  String get cashTendered => 'Cash given by the customer (optional)';

  @override
  String changeToGive(String amount) {
    return 'Change: $amount';
  }

  @override
  String get giveChange => 'Change to give back';

  @override
  String get transactionReference => 'Transaction number (optional)';

  @override
  String get manualPaymentNote =>
      'Card and Mobile Money: check that the payment has been received before confirming.';

  @override
  String get openCashFirst => 'Open the register first (Cash section).';

  @override
  String get chooseRegister => 'Choose the register';

  @override
  String get orderPaidClosed => 'Order paid and closed.';

  @override
  String get paid => 'Already paid';

  @override
  String get remainingDue => 'Amount due';

  @override
  String get voided => 'voided';

  @override
  String get voidPayment => 'Void this payment';

  @override
  String get orderClosed => 'Order paid and closed';

  @override
  String get orderCancelled => 'Order cancelled';

  @override
  String get errorNoOpenSession => 'No open register for this payment.';

  @override
  String get errorSessionAlreadyOpen => 'This register is already open.';

  @override
  String get errorRegisterInactive => 'This register is disabled.';

  @override
  String get errorInvalidAmount => 'Invalid amount.';

  @override
  String get errorNotEnoughCash => 'There is not enough cash in the register.';

  @override
  String get errorOverpayment => 'The amount exceeds what is due.';

  @override
  String get errorTenderedTooLow => 'The cash given is less than the amount.';

  @override
  String get errorOrderHasPayments =>
      'This order already has payments: void or refund them first.';

  @override
  String get errorPendingLines =>
      'Some items have not been sent to the kitchen yet.';

  @override
  String get errorNotFullyPaid => 'The order is not fully paid.';

  @override
  String get errorSessionNotCounted =>
      'This register has not been counted yet.';

  @override
  String get navKitchen => 'Kitchen';

  @override
  String get allStations => 'All stations';

  @override
  String get stations => 'Preparation stations';

  @override
  String get newStation => 'New station';

  @override
  String get stationExamples => 'E.g. Kitchen, Bar, Grill';

  @override
  String get stationPrepares => 'This station prepares:';

  @override
  String get kitchenEmpty => 'Nothing to prepare right now.';

  @override
  String get allReady => 'All ready';

  @override
  String get markServed => 'Served';

  @override
  String get errorInvalidStatus => 'This status change is not possible.';

  @override
  String get navStock => 'Stock';

  @override
  String get stockLevels => 'Stock levels';

  @override
  String get ingredientsTab => 'Ingredients';

  @override
  String get recipesTab => 'Recipe cards';

  @override
  String get inventoriesTab => 'Stock counts';

  @override
  String get movementsTab => 'Movements';

  @override
  String stockValue(String amount) {
    return 'Stock value: $amount';
  }

  @override
  String lowStockCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ingredients below threshold',
      one: '1 ingredient below threshold',
    );
    return '$_temp0';
  }

  @override
  String actionsAt(String location) {
    return 'Movements at: $location';
  }

  @override
  String get newLocation => 'New location';

  @override
  String get locationExamples => 'E.g. Cold room, Cellar, Kitchen';

  @override
  String get chooseLocation => 'Choose the location';

  @override
  String get toLocation => 'To location';

  @override
  String get noIngredientsYet =>
      'No ingredients yet: add some in the Ingredients tab.';

  @override
  String alertAt(String qty) {
    return 'alert at $qty';
  }

  @override
  String avgCost(String amount, String unit) {
    return 'average cost $amount / $unit';
  }

  @override
  String get alertThreshold => 'Alert threshold';

  @override
  String get alertBelow => 'Alert below';

  @override
  String get produce => 'Produce';

  @override
  String get adjustmentQuantity => 'Correction (+ or −)';

  @override
  String unitCost(String unit) {
    return 'Cost per $unit';
  }

  @override
  String get unitPiece => 'piece';

  @override
  String get unitDozen => 'dozen';

  @override
  String get newIngredient => 'New ingredient';

  @override
  String get ingredientExamples => 'E.g. Chicken, Palm oil, 33 cl Coke bottle';

  @override
  String get ingredientKind => 'Type';

  @override
  String get stockUnit => 'Stock unit';

  @override
  String get ingRaw => 'Raw material';

  @override
  String get ingBeverage => 'Beverage';

  @override
  String get ingPackaging => 'Packaging';

  @override
  String get ingSemiFinished => 'House preparation';

  @override
  String get ingConsumable => 'Consumable';

  @override
  String get mvOpening => 'Opening stock';

  @override
  String get mvReceipt => 'Receipt (purchase)';

  @override
  String get mvSale => 'Sale';

  @override
  String get mvProductionIn => 'Production';

  @override
  String get mvProductionOut => 'Used in production';

  @override
  String get mvWaste => 'Waste / breakage';

  @override
  String get mvStaffMeal => 'Staff meal';

  @override
  String get mvReturn => 'Return to supplier';

  @override
  String get mvTransferIn => 'Transfer received';

  @override
  String get mvTransferOut => 'Transfer';

  @override
  String get mvAdjustment => 'Adjustment';

  @override
  String get mvInventory => 'Count difference';

  @override
  String get recipesIntro =>
      'A recipe card lists a dish\'s ingredients: stock goes down automatically with each paid sale and the cost price is calculated.';

  @override
  String get noRecipe => 'No recipe';

  @override
  String costPrice(String amount) {
    return 'Cost price: $amount';
  }

  @override
  String sellingPrice(String amount) {
    return 'price $amount';
  }

  @override
  String marginPercent(int percent) {
    return 'margin $percent %';
  }

  @override
  String recipeOf(String name) {
    return 'Recipe: $name';
  }

  @override
  String get portions => 'Number of portions';

  @override
  String get yieldQuantity => 'Quantity produced';

  @override
  String get ingredient => 'Ingredient';

  @override
  String get wastePercent => 'Waste';

  @override
  String get removeLine => 'Remove the line';

  @override
  String get addIngredientLine => 'Add an ingredient';

  @override
  String get preparationNotes => 'Preparation notes (optional)';

  @override
  String get newInventory => 'New stock count';

  @override
  String get inventoriesIntro =>
      'A stock count compares counted stock with calculated stock; differences are recorded once a manager validates it.';

  @override
  String inventoryValidated(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'validated, $count differences',
      one: 'validated, 1 difference',
      zero: 'validated, no difference',
    );
    return '$_temp0';
  }

  @override
  String inventoryDraft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'in progress, $count lines counted',
      one: 'in progress, 1 line counted',
      zero: 'in progress, nothing counted',
    );
    return '$_temp0';
  }

  @override
  String inventoryOf(String location) {
    return 'Stock count: $location';
  }

  @override
  String get inventoryHint =>
      'Enter what you actually count. Lines left empty are not changed.';

  @override
  String inventoryDifference(String qty) {
    return 'difference $qty';
  }

  @override
  String get search => 'Search';

  @override
  String get validateInventory => 'Validate the count';

  @override
  String get validateInventoryConfirm =>
      'Validate this count? Differences will be recorded in the stock and the count can no longer be changed.';

  @override
  String inventoryAdjustments(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Count validated: $count differences recorded',
      one: 'Count validated: 1 difference recorded',
      zero: 'Count validated: no difference',
    );
    return '$_temp0';
  }

  @override
  String get errorInvalidMovement => 'Invalid stock movement.';

  @override
  String get errorUnitLocked =>
      'The stock unit can no longer change: this ingredient already has movements.';

  @override
  String get errorNoRecipe => 'This preparation has no recipe card.';

  @override
  String get errorInvalidRecipe =>
      'Invalid recipe card: check ingredients, quantities and units.';

  @override
  String get errorInventoryClosed => 'This stock count is already validated.';

  @override
  String get navGroupService => 'Service';

  @override
  String get navGroupManagement => 'Management';

  @override
  String get navGroupOrganization => 'Organization';

  @override
  String get navPurchases => 'Purchasing';

  @override
  String get navExpenses => 'Expenses';

  @override
  String get navReports => 'Reports';

  @override
  String get invoicesTab => 'Invoices';

  @override
  String get purchaseOrdersTab => 'Purchase orders';

  @override
  String get receiptsTab => 'Deliveries';

  @override
  String get suppliersTab => 'Suppliers';

  @override
  String get newSupplier => 'New supplier';

  @override
  String get noSuppliersYet =>
      'No suppliers yet. Add your usual suppliers (market, wholesaler, brewery…).';

  @override
  String get addSupplierFirst => 'First add a supplier (Suppliers tab).';

  @override
  String get contactName => 'Contact person';

  @override
  String get taxId => 'Tax ID';

  @override
  String get paymentTermsLabel => 'Payment terms';

  @override
  String get days => 'days';

  @override
  String paymentTerms(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'payment in $days days',
      one: 'payment in 1 day',
    );
    return '$_temp0';
  }

  @override
  String get supplier => 'Supplier';

  @override
  String get supplierOptional => 'Supplier (optional)';

  @override
  String get newPurchaseOrder => 'New purchase order';

  @override
  String get noPurchaseOrders =>
      'No purchase orders. A purchase order prepares a purchase; on delivery, \"Receive\" adds the goods to stock.';

  @override
  String poNumber(int number) {
    return 'PO #$number';
  }

  @override
  String get poDraft => 'draft';

  @override
  String get poSent => 'sent';

  @override
  String get poPartial => 'partly received';

  @override
  String get poReceived => 'received';

  @override
  String get poCancelled => 'cancelled';

  @override
  String get poMarkSent => 'Mark as sent';

  @override
  String get poReceive => 'Receive';

  @override
  String get poCancel => 'Cancel the order';

  @override
  String get cancelPoConfirm => 'Cancel this purchase order?';

  @override
  String expectedOn(String date) {
    return 'delivery expected on $date';
  }

  @override
  String get expectedDateOptional => 'Expected delivery date (optional)';

  @override
  String unitPrice(String unit) {
    return 'Price per $unit';
  }

  @override
  String totalAmount(String amount) {
    return 'Total: $amount';
  }

  @override
  String get newReceipt => 'New delivery';

  @override
  String get receiptsIntro =>
      'A delivery records the goods received: stock and average cost are updated automatically.';

  @override
  String receiveOrder(int number) {
    return 'Delivery for PO #$number';
  }

  @override
  String get receiptHint =>
      'Enter the quantities actually delivered and their price; they go into stock when saved.';

  @override
  String get deliveryNoteNumber => 'Delivery note number (optional)';

  @override
  String get recordReceipt => 'Record the delivery';

  @override
  String get receiptRecorded => 'Delivery recorded: stock is up to date.';

  @override
  String get newInvoice => 'New invoice';

  @override
  String get invoicesIntro =>
      'Record your suppliers\' invoices here to track what you owe them and your payments.';

  @override
  String supplierDebt(String amount) {
    return 'Total owed to suppliers: $amount';
  }

  @override
  String dueOn(String date) {
    return 'due on $date';
  }

  @override
  String remaining(String amount) {
    return '$amount left';
  }

  @override
  String get invoicePaid => 'paid';

  @override
  String get invoiceCancelled => 'cancelled';

  @override
  String get invoiceNumber => 'Supplier invoice number';

  @override
  String invoiceDateValue(String date) {
    return 'Invoice of $date';
  }

  @override
  String get dueDateOptional => 'Due date (optional: supplier\'s terms)';

  @override
  String get amountExclTax => 'Amount excluding tax';

  @override
  String get taxAmount => 'Tax';

  @override
  String get linkedReceipts => 'Related deliveries';

  @override
  String get attachDocument => 'Attach a receipt (PDF or photo)';

  @override
  String get fileTooLarge => 'File too large (5 MB maximum).';

  @override
  String get viewDocument => 'View the receipt';

  @override
  String get payInvoice => 'Pay';

  @override
  String get cancelInvoice => 'Cancel the invoice';

  @override
  String get paidFromRegister => 'Paid with cash from the register';

  @override
  String get newExpense => 'New expense';

  @override
  String get noExpenses => 'No expenses this month.';

  @override
  String get previousMonth => 'Previous month';

  @override
  String get nextMonth => 'Next month';

  @override
  String includingTax(String amount) {
    return 'including tax $amount';
  }

  @override
  String get cancelledLabel => 'cancelled';

  @override
  String get cancelExpense => 'Cancel the expense';

  @override
  String get expenseExamples => 'E.g. October electricity bill, freezer repair';

  @override
  String get amountInclTax => 'Amount paid';

  @override
  String get includedTaxOptional => 'Of which tax (optional)';

  @override
  String get expRent => 'Rent';

  @override
  String get expElectricity => 'Electricity';

  @override
  String get expWater => 'Water';

  @override
  String get expGas => 'Gas';

  @override
  String get expSalaries => 'Salaries';

  @override
  String get expTransport => 'Transport';

  @override
  String get expMaintenance => 'Maintenance and repairs';

  @override
  String get expMarketing => 'Advertising';

  @override
  String get expSupplies => 'Supplies';

  @override
  String get expTaxes => 'Taxes and duties';

  @override
  String get expBankFees => 'Bank fees';

  @override
  String get expOther => 'Other';

  @override
  String get periodToday => 'Today';

  @override
  String get periodLast7 => 'Last 7 days';

  @override
  String get periodMonth => 'This month';

  @override
  String get periodLastMonth => 'Last month';

  @override
  String get periodCustom => 'Other period…';

  @override
  String get salesInclTax => 'Sales incl. tax';

  @override
  String get salesExclTax => 'Sales excl. tax';

  @override
  String get collected => 'Money received';

  @override
  String get costOfSales => 'Cost of sales';

  @override
  String get grossMargin => 'Gross margin';

  @override
  String get lossesValue => 'Losses and differences';

  @override
  String get expensesExclTax => 'Expenses excl. tax';

  @override
  String get estimatedResult => 'Estimated result';

  @override
  String get purchasesValue => 'Purchases (invoices excl. tax)';

  @override
  String get supplierDebtShort => 'Owed to suppliers';

  @override
  String ordersCountShort(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count orders',
      one: '1 order',
      zero: 'no orders',
    );
    return '$_temp0';
  }

  @override
  String get ruleSales =>
      'Total of paid and closed orders in the period (service date).';

  @override
  String get ruleSalesHt => 'Sales including tax minus tax collected.';

  @override
  String get ruleCollected =>
      'Money actually received in the period, all methods, minus refunds. May differ from sales (deposits, orders still open).';

  @override
  String get ruleCogs =>
      'Value of ingredients used by sales, based on recipe cards and average purchase cost. Dishes without a recipe card are not included.';

  @override
  String get ruleGrossMargin => 'Sales excluding tax minus cost of sales.';

  @override
  String get ruleLosses =>
      'Value of waste, staff meals, adjustments and stock count differences.';

  @override
  String get ruleExpenses =>
      'Expenses recorded in the period, excluding tax (cancelled expenses excluded).';

  @override
  String get ruleResult =>
      'Gross margin minus losses and expenses. A management estimate, without depreciation or unrecorded costs: not an accounting result.';

  @override
  String get rulePurchases =>
      'Supplier invoices (excluding tax) dated in the period. Purchases go into stock: they are not a cost until used.';

  @override
  String get ruleDebt =>
      'Amount still due on open supplier invoices, as of today.';

  @override
  String get expensesByCategory => 'Expenses by category (excl. tax)';

  @override
  String get resultDisclaimer =>
      'These figures are calculated from operations recorded in Resto: sales, payments, theoretical consumption, expenses. Hover ⓘ for each indicator\'s rule.';

  @override
  String get exportsTitle => 'Exports (CSV files, open in Excel)';

  @override
  String get exportOrders => 'Orders';

  @override
  String get exportPayments => 'Payments';

  @override
  String get exportExpenses => 'Expenses';

  @override
  String get exportDownloaded => 'File downloaded.';

  @override
  String get exportCopied => 'Data copied: paste it into a spreadsheet.';

  @override
  String get marginsByItem => 'Margin by dish';

  @override
  String marginsHint(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dishes have no recipe card yet (Stock → Recipe cards).',
      one: '1 dish has no recipe card yet (Stock → Recipe cards).',
      zero: 'All dishes sold have a recipe card.',
    );
    return '$_temp0';
  }

  @override
  String get errorInvalidPurchase =>
      'Incomplete purchase: check supplier, ingredients, quantities, units and prices.';

  @override
  String get errorPurchaseNotDraft =>
      'This purchase order can no longer be changed.';

  @override
  String get errorDuplicateInvoice =>
      'This invoice from this supplier is already recorded.';

  @override
  String get errorInvoiceNotOpen => 'This invoice is no longer open.';

  @override
  String get errorInvoiceHasPayments =>
      'This invoice has payments: void them first.';

  @override
  String get errorInvalidExpense =>
      'Incomplete expense: category, description and amount are required; tax cannot exceed the amount.';

  @override
  String get errorInvalidAttachment => 'Attachment rejected.';

  @override
  String get errorInvalidPeriod => 'Invalid period.';

  @override
  String get errorBelowMinimum => 'Minimum order amount not reached.';

  @override
  String get errorDeliveryUnavailable =>
      'Delivery not possible: check the address and phone number, or choose “Takeaway”.';

  @override
  String get errorInvalidImage =>
      'Photo rejected (invalid format or location).';

  @override
  String get errorNotFound => 'Not found.';

  @override
  String get errorOnlineOrdersClosed =>
      'This restaurant is not taking online orders right now.';

  @override
  String get errorTooLateToCancel =>
      'Too late: the restaurant has already started on the order.';

  @override
  String get errorReviewNotAllowed =>
      'Review not possible: only a paid order less than 30 days old can be rated, once.';

  @override
  String get errorReservationsClosed =>
      'This restaurant does not take online reservations.';

  @override
  String get errorInvalidPartySize =>
      'Party size not accepted for an online reservation.';

  @override
  String get errorInvalidReservationTime =>
      'Invalid time: at least 15 minutes ahead and at most 90 days.';

  @override
  String get errorInvalidReservation =>
      'Incomplete reservation: name, phone and party size are required.';

  @override
  String get errorTablesRequired => 'Choose at least one table.';

  @override
  String get errorNotEnoughSeats => 'Not enough seats at the selected tables.';

  @override
  String get errorTableUnavailable =>
      'This table is already reserved for that time.';

  @override
  String get errorPromotionUnavailable => 'Promotion or code not valid.';

  @override
  String get errorPromotionLimit =>
      'This customer has already used this promotion the allowed number of times.';

  @override
  String get errorPromotionAlreadyApplied => 'Already applied to this order.';

  @override
  String get errorNotEnoughPoints => 'Not enough loyalty points.';

  @override
  String get errorAddressRequired => 'Delivery address required.';

  @override
  String get errorTableBusy => 'This table already has an order in progress.';

  @override
  String errorBetween(int min, int max) {
    return 'Between $min and $max';
  }

  @override
  String get notPublishedHint =>
      'This location is not visible to customers yet: turn on “Published” in the Information tab.';

  @override
  String get onlineOrdersTitle => 'Online orders';

  @override
  String get acceptOnlineOrders => 'Accept customer orders';

  @override
  String get acceptOnlineOrdersHint =>
      'From the app, the website or the table QR codes. Each order arrives in “Orders” to be accepted.';

  @override
  String get acceptDelivery => 'Offer delivery';

  @override
  String get deliveryFee => 'Delivery fee';

  @override
  String get minimumOrder => 'Minimum order';

  @override
  String get reservationsTitle => 'Reservations';

  @override
  String get acceptReservations => 'Accept online reservations';

  @override
  String get reservationDuration => 'Reservation length';

  @override
  String get minutesShort => 'min';

  @override
  String get maxPartySize => 'Maximum party size';

  @override
  String get publicProfileTitle => 'Restaurant public profile';

  @override
  String get publicDescription => 'Description';

  @override
  String get publicDescriptionHint =>
      'E.g. generous Cameroonian cuisine, grilled fish of the day, shaded terrace.';

  @override
  String get cuisinesLabel => 'Cuisine types';

  @override
  String get cuisinesHint =>
      'E.g. African, grill, seafood (separated by commas)';

  @override
  String get priceLevel => 'Price range';

  @override
  String get publicPageTitle => 'Restaurant page';

  @override
  String get publicPageHint =>
      'Share it (social media, WhatsApp) or print it: customers see the menu and order there.';

  @override
  String get copyLink => 'Copy link';

  @override
  String get sourcePhone => 'By phone';

  @override
  String get sourceQr => 'Table QR code';

  @override
  String get sourceApp => 'Customer app';

  @override
  String get sourcePartner => 'Partner';

  @override
  String get sourceStaff => 'Taken in the dining room';

  @override
  String get stageToValidate => 'To confirm';

  @override
  String get stageDraft => 'Not sent yet';

  @override
  String get stageCooking => 'Being prepared';

  @override
  String get stageReady => 'Ready to serve';

  @override
  String get stageReadyTakeaway => 'Ready for pickup';

  @override
  String get stageReadyDelivery => 'Ready for the courier';

  @override
  String get stageToPay => 'To be paid';

  @override
  String get stageDone => 'Completed';

  @override
  String get stageCancelled => 'Cancelled';

  @override
  String get handToCustomer => 'Handed to customer';

  @override
  String get handToCourier => 'Handed to courier';

  @override
  String guestsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count guests',
      one: '1 guest',
    );
    return '$_temp0';
  }

  @override
  String forTime(String time) {
    return 'For $time';
  }

  @override
  String get billTitle => 'Bill';

  @override
  String get thankYou => 'Thank you for your visit!';

  @override
  String kdsToPrepare(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count orders to prepare',
      one: '1 order to prepare',
      zero: 'Nothing to prepare',
    );
    return '$_temp0';
  }

  @override
  String kdsLate(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count late',
      one: '1 late',
    );
    return '$_temp0';
  }

  @override
  String kdsReadyCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ready',
      one: '1 ready',
      zero: 'None ready',
    );
    return '$_temp0';
  }

  @override
  String get kdsTickets => 'Tickets';

  @override
  String get kdsSummary => 'Totals';

  @override
  String get kdsFullScreen => 'Full screen (kitchen mode)';

  @override
  String get kdsFlowHint =>
      'Orders sent from the dining room arrive here with a chime. Tap an item to mark it “in preparation”, then “ready”. “All ready” alerts the waiters immediately.';

  @override
  String get kdsReadyStrip =>
      'Ready — the dining room has been alerted (“Ready to serve” column), waiting to be served';

  @override
  String get kdsStart => 'Start';

  @override
  String kdsWaitingService(String time) {
    return 'waiting for $time';
  }

  @override
  String get kdsRecall => 'Recall (not ready yet)';

  @override
  String get serviceAndCustomers => 'Service & customers';

  @override
  String get serviceSettingsTitle => 'Service';

  @override
  String get targetPrepTime => 'Target preparation time';

  @override
  String get targetPrepTimeHint => 'Beyond this, the order turns red (late).';

  @override
  String get payFirstTakeaway => 'Takeaway: take payment before preparation';

  @override
  String get payFirstTakeawayHint =>
      'The “Collect then send” button appears on takeaway orders.';

  @override
  String get tableOccupied => 'Occupied';

  @override
  String get tableReservedNow => 'Reserved now';

  @override
  String get tableReservedSoon => 'Reserved soon';

  @override
  String reservedAt(String time) {
    return 'Reserved at $time';
  }

  @override
  String get acceptWithDelay => 'Accept the order';

  @override
  String scheduledFor(String time) {
    return 'Requested for $time';
  }

  @override
  String get delayAnnounced =>
      'How long until it is ready? The customer is notified.';

  @override
  String get orderAccepted => 'Order accepted: it is going into preparation.';

  @override
  String get rejectOrder => 'Reject the order';

  @override
  String get rejectReasonHint => 'E.g. out of fish, no courier available';

  @override
  String get paymentDone => 'Payment recorded.';

  @override
  String get partialPaymentDone => 'Partial payment recorded.';

  @override
  String get announcedDelay => 'Time announced to the customer';

  @override
  String promisedFor(String time) {
    return 'Promised for $time';
  }

  @override
  String get heldShort => 'to follow';

  @override
  String moreItems(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '+ $count more items',
      one: '+ 1 more item',
    );
    return '$_temp0';
  }

  @override
  String get paidShort => 'Paid';

  @override
  String get partlyPaid => 'Partly paid';

  @override
  String get notPaid => 'Not paid';

  @override
  String get reject => 'Reject';

  @override
  String get accept => 'Accept';

  @override
  String get sendShort => 'Send';

  @override
  String get fireNext => 'Fire next course';

  @override
  String get collectShort => 'Collect';

  @override
  String get columnInProgress => 'In progress';

  @override
  String get columnReady => 'Ready to serve';

  @override
  String get columnToValidateHint =>
      'Orders placed by customers (app, website, table QR codes) arrive here with a chime. Accept them by announcing a time.';

  @override
  String get columnInProgressHint =>
      'Orders taken and being prepared. “Send” sends the items to the kitchen and the bar.';

  @override
  String get columnReadyHint =>
      'When the kitchen taps “All ready”, the order arrives here (with a chime): serve at the table, hand to the customer or to the courier.';

  @override
  String get columnToPayHint =>
      'Everything is served: payment remains. Once paid, the order is completed and the table is freed.';

  @override
  String get allOrders => 'All';

  @override
  String get searchOrderHint => 'No., customer, table, phone';

  @override
  String get chooseTable => 'Choose the table';

  @override
  String get tableHasOrder =>
      'This table already has an order in progress: it will open.';

  @override
  String tableReservationWarning(String time, String name, int count) {
    return 'Warning: reserved at $time · $name · $count guests';
  }

  @override
  String get guestsLabel => 'Number of guests';

  @override
  String get receivedByPhone => 'Order received by phone';

  @override
  String get customerName => 'Customer name';

  @override
  String get customerNameOptional => 'Customer name (optional)';

  @override
  String get phoneOptional => 'Phone (optional)';

  @override
  String get deliveryAddress => 'Delivery address';

  @override
  String get deliveryAddressHint =>
      'Neighbourhood, street, landmark (e.g. Bonamoussadi, near the pharmacy)';

  @override
  String get deliveryInstructions => 'Instructions for the courier';

  @override
  String get deliveryInstructionsHint =>
      'E.g. yellow building, 2nd floor, call on arrival';

  @override
  String get deliveryTime => 'Delivery time';

  @override
  String get pickupTime => 'Pickup time';

  @override
  String get asap => 'As soon as possible';

  @override
  String get atFixedTime => 'At a set time';

  @override
  String atTime(String time) {
    return 'At $time';
  }

  @override
  String get newOrder => 'New order';

  @override
  String get orderTypeQuestion => 'What type of order?';

  @override
  String get dineInHint => 'Customer seated at a table';

  @override
  String get takeawayHint => 'The customer leaves with the order';

  @override
  String get deliveryHint => 'Delivered to an address';

  @override
  String get orderNote => 'Note on the order (optional)';

  @override
  String get orderNoteHint =>
      'E.g. birthday, customer in a hurry, peanut allergy';

  @override
  String get continueToMenu => 'Continue: choose the dishes';

  @override
  String get moveTable => 'Change table';

  @override
  String get noFreeTable => 'No free table at the moment.';

  @override
  String get print => 'Print';

  @override
  String get printKitchenTicket => 'Preparation ticket (kitchen)';

  @override
  String get printBill => 'Bill (customer)';

  @override
  String get orderHistory => 'Order history';

  @override
  String get searchDish => 'Search for a dish, a drink…';

  @override
  String get noResults => 'No results.';

  @override
  String get groupToSend => 'To send';

  @override
  String get groupHeld => 'To follow (sent later)';

  @override
  String get groupCooking => 'Being prepared';

  @override
  String get groupReady => 'Ready to serve';

  @override
  String get groupServed => 'Served';

  @override
  String get groupCancelled => 'Cancelled';

  @override
  String collectThenSend(String amount) {
    return 'Collect $amount then send';
  }

  @override
  String fireNextCount(int count) {
    return 'Fire next course ($count)';
  }

  @override
  String get customerOrderToValidate => 'Customer order to confirm';

  @override
  String get customerOrderToValidateHint =>
      'Check the items, then accept (with a time) or reject. The customer is notified.';

  @override
  String get payFirstHint =>
      'Takeaway: payment before preparation (location setting).';

  @override
  String get addedByCustomer => 'added by the customer';

  @override
  String get sendWithOrder => 'Send with the rest';

  @override
  String get holdForLater => 'Mark “to follow” (sent later)';

  @override
  String openedAt(String time) {
    return 'opened at $time';
  }

  @override
  String get fromReservation => 'Guests seated (reservation)';

  @override
  String get editOrderDetails => 'Edit details';

  @override
  String get evOpened => 'Order opened';

  @override
  String evItemAdded(String item) {
    return 'Added: $item';
  }

  @override
  String get evItemUpdated => 'Item changed';

  @override
  String get evItemRemoved => 'Item removed';

  @override
  String evSent(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Sent to the kitchen ($count items)',
      one: 'Sent to the kitchen (1 item)',
    );
    return '$_temp0';
  }

  @override
  String get evItemCancelled => 'Item cancelled';

  @override
  String get evCancelled => 'Order cancelled';

  @override
  String get evClosed => 'Order completed';

  @override
  String evPayment(String amount) {
    return 'Payment of $amount';
  }

  @override
  String get evRefund => 'Refund';

  @override
  String get evDetailsUpdated => 'Details changed';

  @override
  String get itemsTotal => 'Items';

  @override
  String get removeDiscount => 'Remove the discount';

  @override
  String get addDiscount => 'Add a discount';

  @override
  String get applyPromotion => 'Apply a promotion';

  @override
  String get promoCode => 'Promo code';

  @override
  String get promoCodeHint => 'E.g. WELCOME10';

  @override
  String get manualDiscount => 'Discount (goodwill gesture)';

  @override
  String get useLoyalty => 'Use loyalty points';

  @override
  String get noActivePromotion =>
      'No promotion running. Create some in “Customers & loyalty”.';

  @override
  String get inPercent => 'In %';

  @override
  String get inAmount => 'As an amount';

  @override
  String get percentValue => 'Percentage';

  @override
  String get manualDiscountHint => 'E.g. long wait, loyal customer';

  @override
  String get apply => 'Apply';

  @override
  String get allAreas => 'All areas';

  @override
  String get planView => 'Floor plan';

  @override
  String get cardsView => 'Cards';

  @override
  String get editFloor => 'Edit the floor';

  @override
  String get done => 'Done';

  @override
  String get floorEmptyTitle => 'Create your dining room';

  @override
  String get floorEmptyHint =>
      'First add your areas (Dining room, Terrace, VIP…), then your tables with any name you like (Table 1, VIP 1, Bar 2…). You will then see live which tables are free, occupied or reserved.';

  @override
  String get editFloorHint =>
      'Drag the tables to recreate your dining room. Tap a table to rename it or change its seats or shape.';

  @override
  String get noTablesInArea =>
      'No table in this area: “Edit the floor”, then “New table”.';

  @override
  String get newOrderAtTable => 'New order at this table';

  @override
  String get openOrder => 'Open the order';

  @override
  String get reservationsToday => 'Today\'s reservations';

  @override
  String get reserveTable => 'Reserve';

  @override
  String get noReservationToday => 'No reservation today for this table.';

  @override
  String get tableQrCode => 'Table QR code';

  @override
  String get tableQrHint =>
      'Print it and place it on the table: the customer scans it, sees the menu with photos and orders. The order arrives in “To confirm”.';

  @override
  String get areaNameHint => 'E.g. Dining room, Terrace, VIP, Upstairs';

  @override
  String get tableLabelHint => 'E.g. Table 1, VIP 1, Bar 2';

  @override
  String get tableShape => 'Shape';

  @override
  String get shapeSquare => 'Square';

  @override
  String get shapeRound => 'Round';

  @override
  String get shapeRect => 'Rectangular';

  @override
  String get resRequested => 'Requested';

  @override
  String get resConfirmed => 'Confirmed';

  @override
  String get resSeated => 'Seated';

  @override
  String get resCompleted => 'Completed';

  @override
  String get resNoShow => 'No-show';

  @override
  String get resDeclined => 'Declined';

  @override
  String get resCancelled => 'Cancelled';

  @override
  String reservationRequests(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count reservation requests to handle',
      one: '1 reservation request to handle',
    );
    return '$_temp0';
  }

  @override
  String get reservationRequestsHint =>
      'Requests made by customers online: confirm by choosing the tables, or decline with a reason. The customer is notified.';

  @override
  String get declineReservation => 'Decline the reservation';

  @override
  String get confirmReservation => 'Confirm';

  @override
  String reservationsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count reservations',
      one: '1 reservation',
      zero: 'No reservations',
    );
    return '$_temp0';
  }

  @override
  String coversCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count covers',
      one: '1 cover',
      zero: '0 covers',
    );
    return '$_temp0';
  }

  @override
  String get noReservationsDay => 'No reservations that day.';

  @override
  String get today => 'Today';

  @override
  String get timelineView => 'Timeline';

  @override
  String get listView => 'List';

  @override
  String get newReservation => 'New reservation';

  @override
  String get nowLabel => 'now';

  @override
  String get seatGuests => 'Seat the guests';

  @override
  String get changeTables => 'Change tables';

  @override
  String get markNoShow => 'No-show';

  @override
  String get cancelReservation => 'Cancel the reservation';

  @override
  String get markCompleted => 'Completed';

  @override
  String get chooseTables => 'Tables';

  @override
  String seatsForParty(int seats, int party) {
    return '$seats seats chosen for $party guests';
  }

  @override
  String get reservationNoteHint => 'E.g. birthday, high chair, by the window';

  @override
  String get noFreeTableSlot =>
      'No free table for this slot: change the time or the length.';

  @override
  String itemsCountLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '1 item',
      zero: 'no items',
    );
    return '$_temp0';
  }

  @override
  String get alertNewCustomerOrder => 'New customer order to confirm';

  @override
  String get alertOrderReady => 'An order is ready to serve';

  @override
  String get view => 'View';

  @override
  String ordersToValidateBanner(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count customer orders are waiting for your confirmation',
      one: '1 customer order is waiting for your confirmation',
    );
    return '$_temp0';
  }

  @override
  String get tabInProgress => 'In progress';

  @override
  String get historyTab => 'History';

  @override
  String get newShort => 'New';

  @override
  String get brandPoint1 => 'Dine-in, takeaway, delivery and online orders';

  @override
  String get brandPoint2 => 'Live kitchen and bar, floor plan and reservations';

  @override
  String get brandPoint3 => 'Cash register, stock, purchasing and expenses';

  @override
  String get brandPoint4 => 'Dashboards and professional reports';

  @override
  String get authWelcome => 'Welcome';

  @override
  String get authWelcomeSub => 'Sign in to get back to your restaurant';

  @override
  String get noAccountYet => 'No account yet?';

  @override
  String get alreadyAccount => 'Already have an account?';

  @override
  String get authSignUpSub => 'A few seconds to get started, no commitment';

  @override
  String get authForgotSub =>
      'Receive a code by email to choose a new password';

  @override
  String get authNewPasswordSub => 'At least 8 characters';

  @override
  String get navHome => 'Home';

  @override
  String get greetingDay => 'Good day';

  @override
  String get greetingEvening => 'Good evening';

  @override
  String get moreModules => 'More';

  @override
  String freeTablesCount(int free, int total) {
    return '$free of $total tables free';
  }

  @override
  String suggestedTable(String label, int seats) {
    return 'Suggestion: $label ($seats seats)';
  }

  @override
  String get slotFreeSoon => 'Free in time';

  @override
  String get slotReserved => 'Reserved for this slot';

  @override
  String freeAround(String time) {
    return 'free around $time';
  }

  @override
  String get timelineEmptyHint =>
      'No reservations that day. Tap a time on a table\'s row to reserve it.';

  @override
  String get myAccount => 'My account';

  @override
  String get brandTagline => 'Restaurant management, smooth and crystal clear.';

  @override
  String get addPaymentMethod => 'Add a method';

  @override
  String get allMethods => 'All methods';

  @override
  String get availableInBranches => 'Available at';

  @override
  String get availableWorldwide => 'Valid everywhere';

  @override
  String get blindCountHint =>
      'Count the drawer without looking at the expected amount: the difference appears once the count is recorded.';

  @override
  String get cashDrawer => 'Cash drawer';

  @override
  String get cashMovementsTitle => 'Cash in and out';

  @override
  String get cashReportTitle => 'Cash report';

  @override
  String get cashierLabel => 'Cashier';

  @override
  String get choosePaymentMethod => 'Choose the payment method.';

  @override
  String get closingValidated => 'Closing validated: Z report numbered.';

  @override
  String get closingsTab => 'Closings';

  @override
  String get coinsLabel => 'Coins';

  @override
  String get collectTab => 'Collect';

  @override
  String collectWithTip(String amount, String tip) {
    return 'Collect $amount + $tip';
  }

  @override
  String get collectedByDay => 'Collected per day';

  @override
  String get collectedByHour => 'Collected per hour';

  @override
  String get collectedTotal => 'Collected';

  @override
  String commonInCountry(String country) {
    return 'Common in your country ($country)';
  }

  @override
  String get countByDenomination => 'Note by note';

  @override
  String countConfirm(String amount) {
    return 'Confirm the count: $amount?';
  }

  @override
  String get countDetailTitle => 'Count details';

  @override
  String get countRecorded => 'Count recorded';

  @override
  String get countedLabel => 'Counted';

  @override
  String get countedTotal => 'Counted total';

  @override
  String get customMethod => 'Custom method';

  @override
  String get customMethodHint =>
      'E.g. house voucher, loyalty card, payment link';

  @override
  String get dateLabel => 'Date';

  @override
  String get differenceLabel => 'Difference';

  @override
  String get differenceReasonHint =>
      'E.g. change given incorrectly, damaged note';

  @override
  String get discountsTotal => 'Discounts';

  @override
  String get displayOrder => 'Order';

  @override
  String get enterAmount => 'Enter the amount';

  @override
  String get errorPaymentMethodUnavailable =>
      'This payment method is not available here.';

  @override
  String get errorReferenceRequired =>
      'Enter the transaction number (payment reference).';

  @override
  String get exactAmount => 'Exact amount';

  @override
  String get exportExcel => 'Export (spreadsheet)';

  @override
  String get exportPdf => 'Export as PDF';

  @override
  String get feePercentLabel => 'Fee charged';

  @override
  String feeShort(String percent) {
    return 'fee $percent %';
  }

  @override
  String get feesEstimate => 'Fees (estimate)';

  @override
  String get findTicket => 'Find a receipt';

  @override
  String get lastPayments => 'Latest payments';

  @override
  String get legalNameLabel => 'Legal name';

  @override
  String get managerMustValidate => 'A manager must validate the closing.';

  @override
  String get methodKind => 'Type';

  @override
  String get mySessionTab => 'My register';

  @override
  String get newRegister => 'New register';

  @override
  String get noActiveRegister => 'No active register: create one in Settings.';

  @override
  String get noClosings => 'No closings yet.';

  @override
  String get noMovements => 'No movements.';

  @override
  String get noPaymentMethod =>
      'No active payment method: add some in Settings.';

  @override
  String get noPaymentsYet => 'No payments yet.';

  @override
  String get noRefunds => 'No refunds in the last 30 days.';

  @override
  String get noTip => 'None';

  @override
  String get notesLabel => 'Notes';

  @override
  String get nothingToCollect => 'Nothing to collect right now.';

  @override
  String get openRegisterHint =>
      'Count the opening float (the starting change): it is the basis for the end-of-shift count.';

  @override
  String openRegisterTitle(String register) {
    return 'Open $register';
  }

  @override
  String get openedLabel => 'Opened';

  @override
  String get orderDetails => 'Order details';

  @override
  String get orderShort => 'Order';

  @override
  String get otherAmount => 'Other amount';

  @override
  String get otherCountries => 'Other countries';

  @override
  String get payKindAccount => 'Customer account';

  @override
  String get payKindCheque => 'Cheque';

  @override
  String get payKindInstant => 'Instant payment';

  @override
  String get payKindVoucher => 'Voucher';

  @override
  String get payKindWallet => 'Mobile wallet';

  @override
  String get paymentComplete => 'Payment complete';

  @override
  String get paymentMethodLabel => 'Payment method';

  @override
  String get paymentMethodsHint =>
      'The methods offered when collecting. Adapt them to your country: name, required transaction number, fee, locations.';

  @override
  String get paymentMethodsTitle => 'Payment methods';

  @override
  String get paymentsCountShort => 'Payments';

  @override
  String get periodYesterday => 'Yesterday';

  @override
  String get printCountReport => 'Print the count';

  @override
  String get printReceipt => 'Print the receipt';

  @override
  String get reasonChangeFloat => 'Change added';

  @override
  String get reasonOtherIn => 'Other cash in';

  @override
  String get reasonOtherOut => 'Other cash out';

  @override
  String get reasonSafeDrop => 'Safe drop';

  @override
  String get reasonSmallPurchase => 'Small purchase';

  @override
  String get reasonTipsPaid => 'Tips paid to staff';

  @override
  String get receiptFooterHint =>
      'E.g. Thank you, see you soon! Wi-Fi: RestoGuest';

  @override
  String get receiptFooterLabel => 'Message at the bottom of the receipt';

  @override
  String receiptNumberLabel(int number) {
    return 'Receipt no. $number';
  }

  @override
  String get receiptSettingsHint =>
      'Printed on every customer receipt and on Z reports.';

  @override
  String get receiptSettingsTitle => 'Receipt details';

  @override
  String get receiptShort => 'Receipt';

  @override
  String receiptTaxId(String id) {
    return 'Tax ID: $id';
  }

  @override
  String get recentRefunds => 'Recent refunds';

  @override
  String get recordCount => 'Record the count';

  @override
  String get referenceRequiredShort => 'transaction number required';

  @override
  String get refundAction => 'Refund';

  @override
  String get refundDone => 'Refund recorded.';

  @override
  String get refundReasonHint => 'E.g. dish refused, entry error';

  @override
  String get refundTitle => 'Refund the customer';

  @override
  String refundableAmount(String amount) {
    return 'refundable: $amount';
  }

  @override
  String get refundsTab => 'Refunds';

  @override
  String get registerClosedHint =>
      'Open the register (counted float) to collect payments.';

  @override
  String get registerClosedTitle => 'Register closed';

  @override
  String get registerLabel => 'Register';

  @override
  String get registerNameHint => 'E.g. Counter, Terrace, Bar';

  @override
  String get registersTitle => 'Registers';

  @override
  String get reportsTab => 'Reports';

  @override
  String get requireReferenceHint =>
      'The cashier must enter the transaction number (matching with the statement).';

  @override
  String get requireReferenceLabel => 'Transaction number required';

  @override
  String get salesByDay => 'By day';

  @override
  String get salesByMethod => 'By payment method';

  @override
  String get salesByRegister => 'By register';

  @override
  String get salesByStaff => 'By waiter';

  @override
  String get searchAction => 'Search';

  @override
  String get searchMethodOrCountry => 'Method name or country code (e.g. BR)';

  @override
  String get sendWhatsApp => 'Send via WhatsApp';

  @override
  String get sessionAwaitingValidation => 'Counted — awaiting validation';

  @override
  String get settingsTab => 'Settings';

  @override
  String get shareReceipt => 'Share the receipt';

  @override
  String get signatureCashier => 'Cashier signature';

  @override
  String get signatureManager => 'Manager signature';

  @override
  String someBranchesOnly(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count locations',
      one: '1 location',
    );
    return '$_temp0';
  }

  @override
  String get splitAll => 'All';

  @override
  String get splitByItems => 'By items';

  @override
  String get splitByParts => 'By shares';

  @override
  String get splitCustom => 'Custom amount';

  @override
  String get staffLabel => 'Waiter';

  @override
  String get statusLabel => 'Status';

  @override
  String get taxIdHint => 'Your country\'s tax identification number';

  @override
  String get taxIdLabel => 'Tax identification number';

  @override
  String get ticketOrOrderNumber => 'Receipt or order number';

  @override
  String get tipLabel => 'Tip';

  @override
  String get tipPresetsLabel => 'Suggested percentages';

  @override
  String get tipsEnabledHint =>
      'Offered when collecting, counted separately from revenue and attributed to the order\'s waiter.';

  @override
  String get tipsEnabledLabel => 'Offer a tip';

  @override
  String get tipsTitle => 'Tips';

  @override
  String get tipsTotal => 'Tips';

  @override
  String get toCollectTotal => 'To collect';

  @override
  String get transactionReferenceRequired => 'Transaction number (required)';

  @override
  String get transactionsTab => 'Transactions';

  @override
  String get validateClosingConfirm =>
      'Validate this closing? The Z report will be numbered and can no longer be changed.';

  @override
  String get validateNowHint =>
      'Validate the closing in the Closings tab to get the numbered Z report.';

  @override
  String get validatedLabel => 'Validated';

  @override
  String get voidedPayments => 'Voided payments';

  @override
  String get xReading => 'X reading';

  @override
  String get xReportTitle => 'X reading (provisional)';

  @override
  String get zHistory => 'Z report history';

  @override
  String zReportTitle(int number) {
    return 'Z report no. $number';
  }

  @override
  String get zShort => 'Z';

  @override
  String get expectedCashLabel => 'Expected cash';

  @override
  String get countedAmountLabel => 'Counted';

  @override
  String get refundsLabel => 'Refunds';

  @override
  String get addressOptional => 'Address (optional)';

  @override
  String get billedTo => 'Billed to';

  @override
  String get cancelInvoiceHint => 'E.g. wrong company name, wrong customer';

  @override
  String get chooseOrder => 'Choose the order';

  @override
  String get companyOptional => 'Company (optional)';

  @override
  String get customerTaxIdOptional => 'Customer tax ID (optional)';

  @override
  String get documentsTitle => 'Documents';

  @override
  String get emailOptional => 'Email (optional)';

  @override
  String get errorCustomerNameRequired =>
      'The customer name is required on an invoice.';

  @override
  String get invoiceATicket => 'Invoice a receipt';

  @override
  String get invoiceCancelledMention => 'INVOICE CANCELLED';

  @override
  String get invoiceCancelledDone =>
      'Invoice cancelled: you can issue a new one.';

  @override
  String invoiceDateLabel(String date) {
    return 'Date: $date';
  }

  @override
  String get invoiceDesignation => 'Description';

  @override
  String invoiceEmailHint(String email) {
    return 'To send it to $email: tap “Share”, then choose your email app.';
  }

  @override
  String get invoiceFooterHint =>
      'E.g. payment terms, bank details, legal mentions for your country';

  @override
  String get invoiceFooterLabel => 'Footer of the invoice';

  @override
  String invoiceNumberLabel(String number) {
    return 'Invoice no. $number';
  }

  @override
  String get invoicePayments => 'Payments received';

  @override
  String get invoicePrefixHint => 'E.g. INV-2026-';

  @override
  String get invoicePrefixLabel => 'Invoice number prefix';

  @override
  String get invoiceSettingsTitle => 'Invoices';

  @override
  String get invoiceTitle => 'Invoice';

  @override
  String get invoiceUnitPrice => 'Unit price';

  @override
  String get invoicedTotal => 'Invoiced';

  @override
  String get invoicesCount => 'Invoices';

  @override
  String get issueInvoice => 'Create an invoice';

  @override
  String get issueInvoiceAction => 'Issue the invoice';

  @override
  String get issueInvoiceHint =>
      'An issued invoice is numbered and can no longer be changed (if there is a mistake: cancel it, then issue a new one).';

  @override
  String get noInvoices =>
      'No invoices for this period. An invoice is created from an order (“Invoice” button) or here with “Invoice a receipt”.';

  @override
  String get printInvoice => 'Print / download';

  @override
  String get receiptDocument => 'Receipt';

  @override
  String get searchInvoiceHint => 'No., customer, company';

  @override
  String get shareInvoice => 'Share';

  @override
  String get totalExclTax => 'Total excluding tax';

  @override
  String get totalInclTax => 'Total including tax';

  @override
  String get receiptQrCaption => 'Scan to find us online';

  @override
  String get receiptQrLabel => 'QR code at the bottom of the receipt';

  @override
  String get receiptQrUrlLabel => 'QR code link';

  @override
  String get receiptQrUrlHint =>
      'Empty = restaurant page. E.g. https://your-site.com or your reviews page';

  @override
  String get receiptQrUrlInvalid =>
      'The QR code link must start with https:// (or http://).';

  @override
  String get restaurantLogo => 'Restaurant logo';

  @override
  String get chooseLogo => 'Choose the logo';

  @override
  String get replaceLogo => 'Replace';

  @override
  String get removeLogo => 'Remove';

  @override
  String get logoTooBig =>
      'This file is larger than 1 MB: choose a lighter image.';

  @override
  String get receiptTendered => 'Amount tendered';

  @override
  String get receiptChange => 'Change given';

  @override
  String get restaurantLogoHint =>
      'Printed at the top of receipts. Transparent PNG recommended, 1 MB max.';

  @override
  String get add => 'Add';

  @override
  String get delete => 'Delete';

  @override
  String get branchLabel => 'Branch';

  @override
  String get kindDessert => 'Dessert';

  @override
  String get kindMenu => 'Set menu';

  @override
  String get navAds => 'Advertising';

  @override
  String get navSettings => 'Settings';

  @override
  String get greetingShort => 'Hello';

  @override
  String get homeWelcome => 'Welcome, here is today\'s activity';

  @override
  String get kpiSalesToday => 'Today\'s sales';

  @override
  String get kpiOpenOrders => 'Orders in progress';

  @override
  String kpiPendingCount(int count) {
    return '$count pending';
  }

  @override
  String get kpiOccupancy => 'Occupancy rate';

  @override
  String kpiTablesBusy(int busy, int total) {
    return '$busy of $total tables occupied';
  }

  @override
  String get lowStockTitle => 'Low stock';

  @override
  String get saveChanges => 'Save changes';

  @override
  String get settingsProfile => 'Restaurant profile';

  @override
  String get settingsProfileHint =>
      'Your restaurant\'s information, visible to your customers.';

  @override
  String get settingsContact => 'Contact & location';

  @override
  String get settingsContactHint =>
      'Address, phone numbers and position on the map.';

  @override
  String get settingsHours => 'Opening hours';

  @override
  String get settingsHoursHint =>
      'Opening days and hours, preparation time, temporary closure.';

  @override
  String get settingsDelivery => 'Delivery & orders';

  @override
  String get settingsDeliveryHint =>
      'Online orders, delivery, reservations and public page.';

  @override
  String get settingsPayments => 'Payments & invoicing';

  @override
  String get settingsPaymentsHint =>
      'Payment methods, registers, receipt, invoices and tips.';

  @override
  String get settingsTeam => 'Team & roles';

  @override
  String get settingsTeamHint => 'Members, roles and invitations.';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get settingsNotificationsHint => 'What the app alerts you about.';

  @override
  String get settingsSecurity => 'Security';

  @override
  String get settingsSecurityHint => 'Password and signed-in devices.';

  @override
  String get restaurantName => 'Restaurant name';

  @override
  String get sloganLabel => 'Tagline';

  @override
  String get sloganHint => 'E.g. Refined traditional cuisine';

  @override
  String get registrationNumber => 'Registration number';

  @override
  String get registrationNumberHint => 'Your country\'s business register';

  @override
  String get logoUpload => 'Upload the logo';

  @override
  String get logoFormats => 'PNG, JPG or WebP — 1 MB max. Ideal: 512 × 512.';

  @override
  String get logoWhere =>
      'The logo appears in the app, on your storefront and on your customers\' receipts.';

  @override
  String get whatsappLabel => 'WhatsApp number';

  @override
  String get gpsTitle => 'GPS coordinates / map';

  @override
  String get latitude => 'Latitude';

  @override
  String get longitude => 'Longitude';

  @override
  String get gpsMissing => 'Location not set';

  @override
  String get openInMaps => 'Open in Maps';

  @override
  String get deliveryZoneLabel => 'Delivery area';

  @override
  String get deliveryZoneHint => 'E.g. neighbourhoods served or a 5 km radius';

  @override
  String get vacationMode => 'Vacation mode';

  @override
  String get vacationModeHint =>
      'Temporarily close the restaurant: it shows as closed to your customers.';

  @override
  String get vacationMessage => 'Message shown to customers';

  @override
  String get vacationMessageHint => 'E.g. Reopening on 15 September';

  @override
  String get notifSoundNewOrder => 'Sound for each new order';

  @override
  String get notifSoundReady => 'Sound when an order is ready';

  @override
  String get notifLate => 'Alert for late orders';

  @override
  String get notifLowStock => 'Low stock alert';

  @override
  String get notifReservations => 'Reminder of this hour\'s reservations';

  @override
  String get notifCashGap => 'Cash difference at closing';

  @override
  String get signedInAs => 'Signed in as';

  @override
  String get securityTip => 'Use a unique password of at least 8 characters.';

  @override
  String get signOutOthers => 'Sign out my other devices';

  @override
  String get signOutOthersDone => 'Your other devices are signed out.';

  @override
  String get signOutAll => 'Sign out everywhere';

  @override
  String fileTooBig(String name) {
    return '$name is too large.';
  }

  @override
  String get adsCreate => 'Create an ad';

  @override
  String get adsEdit => 'Edit the ad';

  @override
  String get adsCampaigns => 'My campaigns';

  @override
  String get adsLibrary => 'Library';

  @override
  String get adsStats => 'Statistics';

  @override
  String get adsCreateTitle => 'Create';

  @override
  String get adsCreateHint => 'Choose your ad format.';

  @override
  String get adsContent => 'Content';

  @override
  String get adsBudgetTargeting => 'Budget & targeting';

  @override
  String get adsPreview => 'Preview';

  @override
  String get adsPreviewHint => 'Mobile preview';

  @override
  String get adsPreviewSimulation => 'This preview is a simulation.';

  @override
  String get adsFromLibrary => 'From the library';

  @override
  String get adsUpload => 'Add photos or videos';

  @override
  String get adsUploadHint =>
      'JPG, PNG, WebP (5 MB) · MP4, WebM, MOV (50 MB) · 15–30 second videos recommended';

  @override
  String get adsLibraryEmpty => 'The library is empty.';

  @override
  String get adsDeleteFile => 'Delete this file from the library?';

  @override
  String get adsEmpty => 'No campaigns yet.';

  @override
  String get adsEmptyHint =>
      'Create your first ad: a video, a 24-hour story or a featured dish.';

  @override
  String get adsActiveCampaigns => 'Campaigns';

  @override
  String adsCampaignCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count active',
      one: '1 active',
      zero: 'none active',
    );
    return '$_temp0';
  }

  @override
  String get adFormat => 'Format';

  @override
  String get adFormatVideo => 'Video 15–30 s';

  @override
  String get adFormatVideoHint => 'Short video to grab attention';

  @override
  String get adFormatCarousel => 'Photo carousel';

  @override
  String get adFormatCarouselHint => 'Several swipeable images';

  @override
  String get adFormatStory => '24-hour story';

  @override
  String get adFormatStoryHint => 'Ephemeral 24-hour format';

  @override
  String get adFormatSponsoredMenu => 'Sponsored menu';

  @override
  String get adFormatSponsoredMenuHint => 'Feature your dishes';

  @override
  String get adFormatPush => 'Notification';

  @override
  String get adFormatPushHint => 'Reach your customers directly';

  @override
  String get adFormatClassified => 'Classified ad';

  @override
  String get adFormatClassifiedHint => 'Simple, effective text ad';

  @override
  String get adTitle => 'Title';

  @override
  String get adTitleHint => 'E.g. Butter croissant';

  @override
  String get adTitleRequired => 'Give your ad a title.';

  @override
  String get adText => 'Text';

  @override
  String get adTextHint => 'E.g. New! Homemade croissant, 20% off tonight only';

  @override
  String get adMediaHelp => 'Photos or videos for the ad (up to 10).';

  @override
  String get adVideoHelp => 'Add a short video (15 to 30 seconds).';

  @override
  String get adChooseItems => 'Featured dishes';

  @override
  String get adCta => 'Button';

  @override
  String get adCtaHint => 'E.g. Order now';

  @override
  String get adCtaDefault => 'Order now';

  @override
  String get adLink => 'Button link (optional)';

  @override
  String get adPushNote =>
      'The notification will be sent to app customers who agreed to receive your offers.';

  @override
  String get adDailyBudget => 'Daily budget';

  @override
  String get adBudgetNote =>
      'Planned budget: sponsored delivery will be billed by the platform.';

  @override
  String get adStart => 'Start';

  @override
  String get adEnd => 'End';

  @override
  String get adStory24h => 'Visible for 24 hours';

  @override
  String get adTargetAreas => 'Neighbourhood targeting';

  @override
  String get adAddArea => 'Add a neighbourhood';

  @override
  String get adMoments => 'Time of day';

  @override
  String get momentMorning => 'Morning';

  @override
  String get momentNoon => 'Lunch';

  @override
  String get momentAfternoon => 'Afternoon';

  @override
  String get momentEvening => 'Evening';

  @override
  String get momentNight => 'Night';

  @override
  String get adBranches => 'Branches';

  @override
  String get adSaveDraft => 'Save draft';

  @override
  String get adPublish => 'Publish';

  @override
  String get adPublished => 'Ad published.';

  @override
  String get adSponsored => 'Sponsored';

  @override
  String get adStatusActive => 'Active';

  @override
  String get adStatusScheduled => 'Scheduled';

  @override
  String get adStatusPaused => 'Paused';

  @override
  String get adStatusEnded => 'Ended';

  @override
  String get adStatusDraft => 'Draft';

  @override
  String get adRoi => 'Revenue generated';

  @override
  String adRoiDetail(String amount) {
    return 'for $amount of committed budget';
  }

  @override
  String adViews(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count views',
      one: '1 view',
      zero: '0 views',
    );
    return '$_temp0';
  }

  @override
  String adOrders(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count orders',
      one: '1 order',
      zero: '0 orders',
    );
    return '$_temp0';
  }

  @override
  String get adDetails => 'View details';

  @override
  String get adBoost => 'Boost';

  @override
  String get adBoostTitle => 'Extend the campaign';

  @override
  String adBoostDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count more days',
      one: '1 more day',
    );
    return '$_temp0';
  }

  @override
  String get adBoosted => 'Campaign extended.';

  @override
  String get adPause => 'Pause';

  @override
  String get adResume => 'Resume';

  @override
  String get adEndNow => 'End now';

  @override
  String get adDeleteConfirm => 'Delete this campaign and its statistics?';

  @override
  String get adStatViews => 'Views';

  @override
  String get adStatClicks => 'Clicks';

  @override
  String get adStatClickRate => 'Click rate';

  @override
  String get adStatOrders => 'Orders';

  @override
  String get adStatRevenue => 'Revenue';

  @override
  String get adStatByCampaign => 'Views per campaign';

  @override
  String get activeLabel => 'Active';

  @override
  String get addPhotos => 'Add photos';

  @override
  String get addProduct => 'Add a product';

  @override
  String get allItems => 'All';

  @override
  String get available => 'Available';

  @override
  String get categories => 'Categories';

  @override
  String get copySuffix => 'copy';

  @override
  String get customerSideView =>
      'Customer view — how it looks on the restaurant\'s menu';

  @override
  String get duplicate => 'Duplicate';

  @override
  String get everyDay => 'Every day';

  @override
  String get filterKind => 'Type';

  @override
  String get itemDescriptionHint =>
      'E.g. Ndolé leaves with peanuts, prawns and plantain';

  @override
  String get itemDuplicated =>
      'Item duplicated: the copy stays hidden until you save it.';

  @override
  String get livePreview => 'Live preview';

  @override
  String get mainPhoto => 'Main';

  @override
  String get makeMainPhoto => 'Set as main photo';

  @override
  String get markAvailable => 'Make available again';

  @override
  String get markSoldOut => 'Mark as sold out';

  @override
  String get menuProducts => 'Menu products';

  @override
  String get noProductsFound => 'No matching products.';

  @override
  String photosHint(int count) {
    return 'Up to $count photos · JPG, PNG, WebP · 5 MB max';
  }

  @override
  String get play => 'Play';

  @override
  String prepMinutesShort(int minutes) {
    return 'Preparation: $minutes min';
  }

  @override
  String get prepTime => 'Preparation time';

  @override
  String get productInfo => 'Product information';

  @override
  String get productPhotos => 'Product photos';

  @override
  String productsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count products',
      one: '1 product',
      zero: 'No products',
    );
    return '$_temp0';
  }

  @override
  String get publish => 'Publish';

  @override
  String get replace => 'Replace';

  @override
  String get saleDays => 'Days on sale';

  @override
  String get saleDaysRequired => 'Choose at least one day on sale.';

  @override
  String get searchProduct => 'Search a product, a dish…';

  @override
  String get sizesLabel => 'Sizes';

  @override
  String get sortBy => 'Sort';

  @override
  String get sortMenuOrder => 'Menu order';

  @override
  String get sortName => 'Name';

  @override
  String get sortPriceAsc => 'Price: low to high';

  @override
  String get sortPriceDesc => 'Price: high to low';

  @override
  String get stockAlertThreshold => 'Alert below';

  @override
  String get stockAndTime => 'Stock & time';

  @override
  String stockLeft(int count) {
    return 'Stock: $count left';
  }

  @override
  String stockLow(int count) {
    return 'Low stock: $count left';
  }

  @override
  String get stockNotTracked => 'Empty = not tracked';

  @override
  String get stockOfDay => 'Today\'s stock';

  @override
  String get stockOfDayHint =>
      'Number of portions available today. It goes down with each order; at zero the item is sold out. Leave empty to not track it.';

  @override
  String get stockQuantity => 'Quantity in stock';

  @override
  String get supplementsLabel => 'Extras';

  @override
  String get videoAdded => 'Presentation video added';

  @override
  String get videoOptional => 'Presentation video (optional, about 30 s)';

  @override
  String get allChannels => 'All channels';

  @override
  String get amountLabel => 'Amount';

  @override
  String averageTicketShort(String amount) {
    return 'Average ticket $amount';
  }

  @override
  String get customerLabel => 'Customer';

  @override
  String get financialResult => 'Financial result';

  @override
  String get inKitchenCount => 'in preparation';

  @override
  String get inProgressCount => 'in progress';

  @override
  String get itemsLabel => 'Items:';

  @override
  String get lateCount => 'late';

  @override
  String get noOrdersHere => 'No orders here';

  @override
  String get noSalesYet => 'No sales for this period yet.';

  @override
  String get nothingToCollectHint =>
      'Nothing pending: new payments will appear here.';

  @override
  String get orderLabel => 'Order';

  @override
  String get paymentLabel => 'Payment';

  @override
  String get periodLabel => 'Period';

  @override
  String get recentTransactions => 'Recent transactions';

  @override
  String get salesOfPeriod => 'Sales for the period';

  @override
  String get salesSplit => 'Sales breakdown';

  @override
  String get timeLabel => 'Time';

  @override
  String get topDishes => 'Top dishes';

  @override
  String get viewDetails => 'View details';

  @override
  String vsPrevious(String amount) {
    return 'Previous period: $amount';
  }

  @override
  String get addAddress => 'Add an address';

  @override
  String get addedToCart => 'Added to cart.';

  @override
  String get addressLabel => 'Address name';

  @override
  String get addressLabelHint => 'E.g. Home, Office';

  @override
  String get addToCart => 'Add to cart';

  @override
  String get allCities => 'All cities';

  @override
  String get allRestaurants => 'All restaurants';

  @override
  String get birthday => 'Birthday';

  @override
  String get cartEmpty => 'Your cart is empty.';

  @override
  String cartItems(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '1 item',
    );
    return '$_temp0';
  }

  @override
  String get changeCity => 'Change';

  @override
  String get chooseCity => 'Choose the city';

  @override
  String chooseOptionRequired(String name) {
    return 'Please choose: $name';
  }

  @override
  String get closedNow => 'Closed';

  @override
  String get customerFavorites => 'Favourites';

  @override
  String get customerHome => 'Home';

  @override
  String get customerOrders => 'Orders';

  @override
  String get customerProfile => 'Profile';

  @override
  String customerReviews(int count) {
    return 'Customer reviews ($count)';
  }

  @override
  String get customerSearch => 'Search';

  @override
  String get customerSpaceLink => 'Customer area · order';

  @override
  String get deliveryDetailsRequired =>
      'Enter the delivery address and a phone number.';

  @override
  String get directions => 'Directions';

  @override
  String get discoverRestaurants => 'Discover restaurants';

  @override
  String get dishes => 'Dishes';

  @override
  String get favoritesSignIn => 'Sign in to find your favourite restaurants.';

  @override
  String get fullName => 'Full name';

  @override
  String get globalCatalog => 'Global catalogue';

  @override
  String get healthAllergies => 'Health & allergies';

  @override
  String get howDoYouWant => 'How would you like to be served?';

  @override
  String loyaltyNextReward(int points, String amount) {
    return 'Next reward at $points points: $amount';
  }

  @override
  String loyaltyPoints(int count) {
    return '$count points';
  }

  @override
  String get loyaltyProgram => 'Loyalty programme';

  @override
  String mapCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count places on the map',
      one: '1 place on the map',
    );
    return '$_temp0';
  }

  @override
  String get mapView => 'Map';

  @override
  String minimumOrderNotReached(String amount) {
    return 'Minimum order: $amount';
  }

  @override
  String minutesRange(int min, int max) {
    return '$min–$max min';
  }

  @override
  String get myAddresses => 'My addresses';

  @override
  String get myCart => 'My cart';

  @override
  String get newRestaurant => 'New';

  @override
  String get noAddresses => 'No saved addresses.';

  @override
  String get noCustomerOrders => 'You haven\'t ordered yet.';

  @override
  String get noFavorites => 'No favourites yet.';

  @override
  String get noFavoritesHint => 'Tap a restaurant\'s heart to add it.';

  @override
  String get noLoyaltyYet => 'Your points will appear after your first orders.';

  @override
  String get noRestaurantsYet => 'No restaurants published in this city yet.';

  @override
  String get noteForKitchen => 'Note for the kitchen (optional)';

  @override
  String get noteForKitchenHint => 'E.g. no chilli, well done';

  @override
  String get notifOrderUpdates => 'My order updates';

  @override
  String get notifPromotions => 'Promotions & offers';

  @override
  String get notifReservationReminders => 'Reservation reminders';

  @override
  String get onlineOrdersUnavailable => 'Online ordering unavailable right now';

  @override
  String get openFullMap => 'Open the full map';

  @override
  String get openNow => 'Open';

  @override
  String get orderDone => 'Completed';

  @override
  String orderingAtTable(String table) {
    return 'Ordering at table $table';
  }

  @override
  String get orderInProgress => 'In progress';

  @override
  String get orderNoteOptional => 'Message for the restaurant (optional)';

  @override
  String get orderRejected => 'Declined by the restaurant';

  @override
  String get orderSentToRestaurant =>
      'Order sent! The restaurant will confirm it: follow it live here.';

  @override
  String get ordersSignIn => 'Sign in to track your orders.';

  @override
  String get orderSummary => 'Summary';

  @override
  String get orderWaitingConfirmation => 'Awaiting confirmation';

  @override
  String get payMobileWallet => 'Mobile wallet';

  @override
  String get personalProfile => 'Personal profile';

  @override
  String get personalProfileHint =>
      'Your personal information and preferences.';

  @override
  String get placeOrder => 'Place order';

  @override
  String get preferences => 'Preferences';

  @override
  String get preferredPayment => 'Preferred payment';

  @override
  String get preferredPaymentHint =>
      'For information only: no card or account number is stored.';

  @override
  String get productDetails => 'Product details';

  @override
  String get profileSignIn =>
      'Sign in to manage your profile, addresses and points.';

  @override
  String get rateOrder => 'Rate my order';

  @override
  String get requiredLabel => 'Required';

  @override
  String get restaurantOnVacation => 'The restaurant is temporarily closed.';

  @override
  String get restaurants => 'Restaurants';

  @override
  String get restaurantSpace => 'Restaurant area';

  @override
  String get restaurantUnavailable => 'This restaurant is not available.';

  @override
  String get reviewComment => 'Your review (optional)';

  @override
  String reviewsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count reviews',
      one: '1 review',
      zero: 'no reviews',
    );
    return '$_temp0';
  }

  @override
  String get searchRestaurantsHint => 'Search restaurants, dishes, cuisines…';

  @override
  String get seeAll => 'See all';

  @override
  String get send => 'Send';

  @override
  String get signInToContinue => 'Sign in to continue';

  @override
  String get spiceHot => 'Hot';

  @override
  String get spiceLevel => 'Spice';

  @override
  String get spiceMedium => 'Medium';

  @override
  String get spiceMild => 'Mild';

  @override
  String get spiceNone => 'None';

  @override
  String get sponsoredAds => 'Sponsored';

  @override
  String get stepAccepted => 'Accepted by the restaurant';

  @override
  String get stepDone => 'Completed';

  @override
  String get stepPreparing => 'Being prepared';

  @override
  String get stepReady => 'Ready';

  @override
  String get stepSent => 'Sent';

  @override
  String get storyLabel => 'Story';

  @override
  String get thanksForReview => 'Thank you for your review!';

  @override
  String get viewCart => 'View cart';

  @override
  String get watchVideo => 'Video';

  @override
  String get yourName => 'Your name';

  @override
  String get gpsHint =>
      '“Open in Maps” automatically saves the position where you are: do it from the restaurant. You can also enter the coordinates.';

  @override
  String get locationSaved => 'Restaurant location saved.';

  @override
  String get locationServiceDisabled =>
      'Location is turned off on this device: turn it on and try again.';

  @override
  String get locationDenied =>
      'Location access denied: allow it in your browser or phone settings.';

  @override
  String get locationUnavailable =>
      'Location not available right now: try again outdoors or enter the coordinates.';

  @override
  String get openMapAction => 'Open the map';

  @override
  String get customerReviewsTitle => 'Customer reviews';

  @override
  String get forYou => 'For you';

  @override
  String fromAmount(String amount) {
    return 'from $amount';
  }

  @override
  String helpfulCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Helpful ($count)',
      zero: 'Helpful',
    );
    return '$_temp0';
  }

  @override
  String get hideReview => 'Hide review';

  @override
  String get hideReviewReason => 'Reason';

  @override
  String get locatedNearYou => 'Restaurants sorted by your location';

  @override
  String get locateMe => 'Locate me';

  @override
  String get locationRefusedChooseCity =>
      'Location unavailable: choose your city.';

  @override
  String get nearYouHint =>
      'Allow location to see the nearest restaurants and dishes.';

  @override
  String get nearYouRestaurants => 'Near you';

  @override
  String get nearYouTitle => 'Restaurants near you';

  @override
  String get newOnMenus => 'New';

  @override
  String get noReviewsYet => 'No reviews yet';

  @override
  String get openNowTitle => 'Open now';

  @override
  String get orderAgain => 'Order again';

  @override
  String get orderAgainAction => 'Reorder';

  @override
  String get ordersInProgressTitle => 'Your orders in progress';

  @override
  String get popularDishes => 'Popular dishes';

  @override
  String get popularNearYou => 'Popular near you';

  @override
  String get promotionsTitle => 'Promotions';

  @override
  String get publishReview => 'Publish my review';

  @override
  String rateDish(String name) {
    return 'Rate: $name';
  }

  @override
  String get rateShort => 'Rate';

  @override
  String get refreshLocation => 'Refresh';

  @override
  String get reorderPartial =>
      'Some dishes are no longer available: the rest was added to your cart.';

  @override
  String get reorderUnavailable => 'These dishes are no longer available.';

  @override
  String get reportReason => 'Why is this review abusive?';

  @override
  String get reportReview => 'Report';

  @override
  String reportsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count reports',
      one: '1 report',
    );
    return '$_temp0';
  }

  @override
  String get reportSent => 'Thank you, the report has been sent.';

  @override
  String get republishReview => 'Republish';

  @override
  String get reviewCommentHint =>
      'E.g. well seasoned, generous portion, fast delivery';

  @override
  String satisfiedPercent(int percent) {
    return '$percent% satisfied customers';
  }

  @override
  String get sortBestRated => 'Highest rated';

  @override
  String get sortHelpful => 'Most helpful';

  @override
  String get sortRecent => 'Most recent';

  @override
  String get sortWorstRated => 'Lowest rated';

  @override
  String get verifiedPurchase => 'Verified purchase';

  @override
  String get verifiedReviewNote =>
      'Verified review: only customers who received this dish can rate it.';

  @override
  String get asSoonAsPossible => 'As soon as possible';

  @override
  String get customerOrdersHere => 'Their orders with you';

  @override
  String get customerPrivacyNote =>
      'You only see this customer\'s relationship with your restaurant: never their orders at other restaurants.';

  @override
  String get customersCount => 'customers';

  @override
  String multiRestaurantNote(int count) {
    return '$count restaurants in your cart: each one receives its own order, with its own number and tracking.';
  }

  @override
  String get navCustomers => 'Customers';

  @override
  String get noCustomersYet => 'No online customers yet.';

  @override
  String get noCustomersYetHint =>
      'Every customer who orders through the app appears here automatically.';

  @override
  String get noDeliveryHere =>
      'This restaurant doesn\'t deliver: takeaway order.';

  @override
  String get ordersSent => 'Orders sent';

  @override
  String ordersSentHint(int count) {
    return '$count orders sent, one per restaurant. Track each one separately.';
  }

  @override
  String placeOrders(int count) {
    return 'Place the $count orders';
  }

  @override
  String get regularBadge => 'Regular';

  @override
  String get regularCustomers => 'regulars (3 orders or more)';

  @override
  String restaurantsCount(int count) {
    return '$count restaurants';
  }

  @override
  String get scheduleOrder => 'Schedule';

  @override
  String get scheduleTooSoon => 'Choose a time at least 15 minutes from now.';

  @override
  String get searchCustomer => 'Name or phone';

  @override
  String get sortBiggestSpenders => 'Biggest spenders';

  @override
  String get sortMostOrders => 'Most orders';

  @override
  String get sortRecentVisit => 'Recent visits';

  @override
  String get teamNotes => 'Team notes';

  @override
  String get teamNotesExample => 'E.g. prefers the terrace, likes hot sauce';

  @override
  String get teamNotesHint => 'Only visible to your team.';

  @override
  String get trackOrder => 'Track';

  @override
  String get customerDiscover => 'Discover';

  @override
  String get feedEmpty => 'Nothing to discover yet';

  @override
  String get feedEmptyHint =>
      'Videos, dishes and offers from restaurants in your city will appear here.';

  @override
  String get feedOrder => 'Order';

  @override
  String get feedViewDish => 'View dish';

  @override
  String get feedViewRestaurant => 'View restaurant';

  @override
  String get feedLike => 'Like';

  @override
  String get feedSave => 'Save';

  @override
  String get feedShare => 'Share';

  @override
  String get feedSaved => 'Saved to your collection.';

  @override
  String get feedUnsaved => 'Removed from your saved posts.';

  @override
  String get feedLinkCopied => 'Link copied: paste it to share.';

  @override
  String get commentsTitle => 'Comments';

  @override
  String get noCommentsYet => 'No comments yet.';

  @override
  String get writeComment => 'Write a comment…';

  @override
  String get adHideForever => 'Don\'t show again';

  @override
  String reserveAt(String name) {
    return 'Book at $name';
  }

  @override
  String get reservationSentHint =>
      'Request sent: the restaurant will confirm your booking.';

  @override
  String get reservationNoteLabel => 'Note (optional)';

  @override
  String get errorInvalidComment =>
      'Comments must be between 1 and 500 characters.';

  @override
  String get adStatReach => 'Reach';

  @override
  String get adStatEngagement => 'Engagement';

  @override
  String get adStatLikes => 'Likes';

  @override
  String get adStatSaves => 'Saves';

  @override
  String get adStatShares => 'Shares';

  @override
  String get hideComment => 'Hide';

  @override
  String get moderationReasonExample => 'E.g. abusive, off-topic';

  @override
  String get hiddenBadge => 'Hidden';

  @override
  String hiddenBecause(String reason) {
    return 'Hidden: $reason';
  }

  @override
  String get allFilter => 'All';

  @override
  String get publishedComments => 'Published';

  @override
  String get hiddenComments => 'Hidden';

  @override
  String get adCommentsHint =>
      'Customer comments on your ads appear here. Hide any that are abusive or off-topic.';

  @override
  String get happyBirthday => 'Happy birthday!';

  @override
  String birthdayGift(String name, int points) {
    return '$name gives you $points loyalty points.';
  }

  @override
  String get thanksAction => 'Thank you!';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get noNotifications => 'No notifications';

  @override
  String get noNotificationsHint =>
      'You\'ll be notified here when a restaurant accepts your order, when it\'s ready or when a booking is confirmed.';

  @override
  String get notifOrderAcceptedTitle => 'Order accepted';

  @override
  String notifOrderAccepted(String brand, String number) {
    return '$brand accepted your order no. $number.';
  }

  @override
  String get notifOrderReadyTitle => 'Order ready';

  @override
  String notifOrderReady(String brand, String number) {
    return 'Your order no. $number is ready at $brand: you can pick it up.';
  }

  @override
  String notifOrderOnTheWay(String brand, String number) {
    return 'Your order no. $number from $brand is ready and on its way.';
  }

  @override
  String get notifOrderRejectedTitle => 'Order declined';

  @override
  String notifOrderRejected(String brand, String number, String reason) {
    return '$brand couldn\'t accept your order no. $number: $reason';
  }

  @override
  String get notifReservationConfirmedTitle => 'Booking confirmed';

  @override
  String notifReservationConfirmed(String brand, String date) {
    return '$brand confirmed your booking for $date.';
  }

  @override
  String get notifReservationDeclinedTitle => 'Booking declined';

  @override
  String notifReservationDeclined(String brand, String date, String reason) {
    return '$brand can\'t welcome you on $date: $reason';
  }

  @override
  String notifGroupJoined(String name, String brand) {
    return '$name joined your group order at $brand.';
  }

  @override
  String notifGroupPlaced(String host, String brand, String number) {
    return '$host sent the group order at $brand (no. $number).';
  }

  @override
  String get groupOrderTitle => 'Group order';

  @override
  String get groupOrderAction => 'Group order';

  @override
  String get groupInviteTitle => 'Invite your guests';

  @override
  String get groupInviteHint =>
      'Share this link: everyone picks their dishes on their phone, then you send a single order.';

  @override
  String get groupEmpty => 'No dishes yet';

  @override
  String get groupEmptyHint =>
      'Add your dishes and share the link with your guests.';

  @override
  String groupHostedBy(String name) {
    return 'Hosted by $name';
  }

  @override
  String groupStatusOpen(String time) {
    return 'Open until $time';
  }

  @override
  String get groupStatusPlaced => 'Sent to the restaurant';

  @override
  String get groupStatusCancelled => 'Cancelled';

  @override
  String get groupStatusExpired => 'Expired';

  @override
  String groupParticipants(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count guests',
      one: '1 guest',
    );
    return '$_temp0';
  }

  @override
  String get groupCheckoutTitle => 'Send for the whole group';

  @override
  String get estimatedTotal => 'Estimated total';

  @override
  String get groupPlaceOrder => 'Send the order to the restaurant';

  @override
  String get cancelGroupOrder => 'Cancel the group order';

  @override
  String get cancelGroupOrderConfirm =>
      'Cancel this group order? Everyone\'s dishes will be lost.';

  @override
  String get groupAddMyDishes => 'Add my dishes';

  @override
  String groupPlacedInfo(String name) {
    return '$name sent the order to the restaurant.';
  }

  @override
  String get groupClosedInfo => 'This group order is closed.';

  @override
  String get groupOrderPlaced => 'Group order sent to the restaurant.';

  @override
  String get addedToGroup => 'Added to the group order.';

  @override
  String get addToGroup => 'Add to group';

  @override
  String get saveDishAction => 'Save dish';

  @override
  String saveDishTitle(String name) {
    return 'Save “$name”';
  }

  @override
  String get favoriteDishes => 'Favourite dishes';

  @override
  String get myLists => 'My lists';

  @override
  String get myCoupons => 'My coupons';

  @override
  String get restaurantsSection => 'Restaurants';

  @override
  String get unavailableNow => 'Unavailable';

  @override
  String get removeAction => 'Remove';

  @override
  String get noFavoriteDishes => 'No favourite dishes';

  @override
  String get noFavoriteDishesHint => 'Tap the heart on a dish to find it here.';

  @override
  String get newList => 'New list';

  @override
  String get noLists => 'No lists';

  @override
  String get noListsHint =>
      'Create lists such as “To try” or “Office lunches”.';

  @override
  String deleteListConfirm(String name) {
    return 'Delete the list “$name”?';
  }

  @override
  String get renameAction => 'Rename';

  @override
  String dishesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dishes',
      one: '1 dish',
      zero: 'No dishes',
    );
    return '$_temp0';
  }

  @override
  String get emptyListHint => 'Empty list: add dishes from their page.';

  @override
  String get listName => 'List name';

  @override
  String get listNameExample => 'E.g. To try';

  @override
  String get noCoupons => 'No coupons';

  @override
  String get noCouponsHint =>
      'Save restaurant offers from the home screen to find them here.';

  @override
  String get couponsHowTo =>
      'Enter the code in your order tracking to get the discount.';

  @override
  String validUntil(String date) {
    return 'until $date';
  }

  @override
  String get couponUsed => 'Already used';

  @override
  String get couponExpired => 'Expired';

  @override
  String get codeCopied => 'Code copied.';

  @override
  String get couponSaved => 'Coupon saved to your favourites.';

  @override
  String get saveCouponAction => 'Save';

  @override
  String get errorLimitReached =>
      'Limit reached: remove some items before adding more.';

  @override
  String get errorGroupClosed => 'This group order is closed or has expired.';

  @override
  String get customersTab => 'Customers';

  @override
  String get offersTab => 'Offers';

  @override
  String get loyaltyTab => 'Loyalty';

  @override
  String get activeOffers => 'Live offers';

  @override
  String get publicCoupons => 'Public coupons';

  @override
  String get totalUses => 'Uses';

  @override
  String get newOffer => 'New offer';

  @override
  String get editOffer => 'Edit offer';

  @override
  String get offersEmpty => 'No offers';

  @override
  String get offersEmptyHint =>
      'Create a discount, a promo code or a public coupon to attract and retain customers.';

  @override
  String get offerStatusOff => 'Disabled';

  @override
  String get offerStatusEnded => 'Ended';

  @override
  String get offerStatusScheduled => 'Scheduled';

  @override
  String get offerStatusActive => 'Live';

  @override
  String get publicCouponLabel => 'Public coupon';

  @override
  String get publicCouponHint =>
      'Shown in the app: customers can save it to their wallet.';

  @override
  String get publicCouponNeedsCode => 'A public coupon needs a code.';

  @override
  String usesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count uses',
      one: '1 use',
      zero: 'Never used',
    );
    return '$_temp0';
  }

  @override
  String get offerName => 'Offer name';

  @override
  String get offerNameExample => 'E.g. Welcome, Happy hour';

  @override
  String get discountPercent => 'Percentage';

  @override
  String get discountAmount => 'Amount';

  @override
  String get offerValue => 'Discount';

  @override
  String get promoCodeLabel => 'Code (optional)';

  @override
  String get offerCodeHint => '3 to 30 letters or digits, e.g. WELCOME';

  @override
  String get minOrderLabel => 'Minimum order';

  @override
  String get maxUsesLabel => 'Max. uses';

  @override
  String get perCustomerLabel => 'Per customer';

  @override
  String get startsLabel => 'Start';

  @override
  String get endsLabel => 'End';

  @override
  String get offerNow => 'now';

  @override
  String get noEndDate => 'No end';

  @override
  String get allBranchesLabel => 'All locations';

  @override
  String get thisBranchOnly => 'This location';

  @override
  String get offerActive => 'Offer active';

  @override
  String get loyaltyMembers => 'Members';

  @override
  String get pointsInCirculation => 'Points in circulation';

  @override
  String get loyaltyProgramTitle => 'Loyalty programme';

  @override
  String loyaltyExample(String amount, int points) {
    return 'Example: an order of $amount earns $points points.';
  }

  @override
  String get loyaltyActive => 'Programme active';

  @override
  String get amountPerPoint => 'Amount for 1 point';

  @override
  String get rewardPointsLabel => 'Points for a reward';

  @override
  String get rewardValueLabel => 'Reward value';

  @override
  String get birthdayPointsLabel => 'Birthday points';

  @override
  String get birthdayPointsHint =>
      'Credited automatically every year to customers who have already ordered from you (0 = none).';

  @override
  String get stockDashboardTab => 'Dashboard';

  @override
  String get stockArticlesTab => 'Items';

  @override
  String get stockOrdersTab => 'Orders';

  @override
  String get stockReportsTab => 'Reports';

  @override
  String get stockDashboardTitle => 'Stock dashboard';

  @override
  String get stockValueLabel => 'Stock value';

  @override
  String get belowThresholdLabel => 'Below threshold';

  @override
  String get outOfStockLabel => 'Out of stock';

  @override
  String get expiringSoonLabel => 'Expiring soon';

  @override
  String get inventoryVarianceLabel => 'Stock-count variances';

  @override
  String get consumptionLabel => 'Consumption';

  @override
  String get wasteLabel => 'Waste';

  @override
  String get receiptsLabel => 'Deliveries';

  @override
  String articlesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '1 item',
      zero: 'No items',
    );
    return '$_temp0';
  }

  @override
  String daysCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '1 day',
    );
    return '$_temp0';
  }

  @override
  String get consumptionByDay => 'Consumption and waste by day';

  @override
  String get topConsumedTitle => 'Most used';

  @override
  String get wasteByReason => 'Waste by reason';

  @override
  String get noMovementsPeriod => 'No movements in this period.';

  @override
  String get noWastePeriod => 'No waste in this period.';

  @override
  String get expiringLotsTitle => 'Batches to watch (expiry dates)';

  @override
  String get noExpiringLots => 'No batch expires within 7 days.';

  @override
  String get toReorderTitle => 'To reorder';

  @override
  String get noAlerts => 'No item below its threshold.';

  @override
  String get prepareOrder => 'Prepare the order';

  @override
  String get expiredShort => 'Expired';

  @override
  String daysLeftShort(int count) {
    return 'D-$count';
  }

  @override
  String daysLeftLong(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days of stock',
      one: '1 day of stock',
      zero: 'runs out today',
    );
    return '$_temp0';
  }

  @override
  String batchShort(String batch) {
    return 'Batch $batch';
  }

  @override
  String get batchNumber => 'Batch no.';

  @override
  String get expiryDate => 'Expiry date';

  @override
  String get stockEmptyHint =>
      'Create your items in the Items tab, then record the opening stock or a delivery.';

  @override
  String get searchArticle => 'Search an item';

  @override
  String get showInactive => 'Show inactive';

  @override
  String get newArticle => 'New item';

  @override
  String get editArticle => 'Edit item';

  @override
  String get articlesEmptyHint =>
      'Add your products: vegetables, meat, drinks, packaging, house-made preparations…';

  @override
  String get storageLabel => 'Storage';

  @override
  String get storageAmbient => 'Ambient';

  @override
  String get storageChilled => 'Chilled';

  @override
  String get storageFrozen => 'Frozen';

  @override
  String get purchaseUnitLabel => 'Purchase unit';

  @override
  String get purchaseUnitExample => 'E.g. 5 kg bag, Case of 12';

  @override
  String get purchaseUnitQty => 'Contents';

  @override
  String get preferredSupplier => 'Usual supplier';

  @override
  String get noneLabel => 'None';

  @override
  String get shelfLifeDays => 'Shelf life';

  @override
  String get daysShort => 'days';

  @override
  String get barcodeLabel => 'Barcode';

  @override
  String get thresholdThisBranch => 'Alert threshold for this location';

  @override
  String get reorderTitle => 'Suggested order';

  @override
  String get reorderHint =>
      'Enough to stay above the threshold, based on the last 28 days of consumption.';

  @override
  String get nothingToReorder => 'Nothing to order';

  @override
  String get nothingToReorderHint =>
      'Every tracked item has enough stock for the chosen period.';

  @override
  String get noSupplier => 'No usual supplier';

  @override
  String get noSupplierHint =>
      'Choose a usual supplier on the item page to create a purchase order.';

  @override
  String get orderFormPdf => 'Purchase order PDF';

  @override
  String get createPurchaseOrder => 'Create purchase order';

  @override
  String get purchaseOrderDraftCreated =>
      'Purchase order created as a draft in Purchases.';

  @override
  String get reorderNote => 'Order suggested by stock';

  @override
  String inStockShort(String qty) {
    return 'In stock: $qty';
  }

  @override
  String get entriesFilter => 'In';

  @override
  String get exitsLabel => 'Out';

  @override
  String get transfersFilter => 'Transfers';

  @override
  String get adjustmentsFilter => 'Adjustments';

  @override
  String get movementsReportTitle => 'Stock movements';

  @override
  String get wasteReportTitle => 'Waste and breakage';

  @override
  String get reportValuation => 'Stock valuation';

  @override
  String get reportValuationHint =>
      'Quantities, thresholds, average cost and value of every item right now.';

  @override
  String get reportMovementsHint =>
      'All movements in the period, with totals by type.';

  @override
  String get reportWasteHint =>
      'Waste in the period with its reason and value.';

  @override
  String get reportInventory => 'Stock count with variances';

  @override
  String get reportInventoryHint =>
      'Expected, counted and valued variances, with signatures.';

  @override
  String get reportFoodCost => 'Food cost per dish';

  @override
  String get reportFoodCostHint =>
      'Cost price, selling price, food-cost ratio and margin of every dish.';

  @override
  String get reportExpiringHint =>
      'Batches still in stock expiring within 14 days.';

  @override
  String get generatePdf => 'Generate PDF';

  @override
  String get noValidatedInventory => 'No validated stock count yet.';

  @override
  String get chooseInventory => 'Choose the stock count';

  @override
  String generatedOn(String date) {
    return 'Printed on $date';
  }

  @override
  String get articlesLabel => 'Items';

  @override
  String get articleLabel => 'Item';

  @override
  String get avgCostShort => 'Average cost';

  @override
  String get valueLabel => 'Value';

  @override
  String get typeLabel => 'Type';

  @override
  String get inventoryGains => 'Surplus';

  @override
  String get inventoryLosses => 'Shortages';

  @override
  String get inventoryNet => 'Net variance';

  @override
  String get theoreticalLabel => 'Expected';

  @override
  String get countedBySignature => 'Counted by: ____________________';

  @override
  String get validatedBySignature => 'Approved by: ____________________';

  @override
  String get targetFoodCost => 'Food cost target';

  @override
  String get targetFoodCostHint =>
      'Maximum share of the selling price the ingredients of a dish should represent (often 25 to 35%).';

  @override
  String targetFoodCostValue(String percent) {
    return 'Food cost target: $percent%';
  }

  @override
  String get dishesWithRecipe => 'Dishes with a recipe';

  @override
  String get aboveTarget => 'Above target';

  @override
  String get aboveTargetShort => 'too costly';

  @override
  String get withoutRecipe => 'Without recipe';

  @override
  String get recipeDefined => 'Recipe set';

  @override
  String get dishLabel => 'Dish';

  @override
  String get costPriceShort => 'Cost';

  @override
  String get sellingPriceShort => 'Price';

  @override
  String get foodCostShort => 'food cost';

  @override
  String get marginShort => 'Margin';

  @override
  String get orderFormTitle => 'Purchase order';

  @override
  String supplierLabelValue(String name) {
    return 'Supplier: $name';
  }

  @override
  String get packagingLabel => 'Packaging';

  @override
  String get unitPriceShort => 'Unit price';

  @override
  String get orderFormFooter =>
      'Please confirm availability and delivery time.';

  @override
  String get accountTypeQuestion => 'You are:';

  @override
  String get accountTypeCustomer => 'Customer';

  @override
  String get accountTypeCustomerHint => 'Discover restaurants, order, book';

  @override
  String get accountTypeBusiness => 'Business';

  @override
  String get accountTypeBusinessHint => 'Manage my restaurant and my team';

  @override
  String get accountTypeRequired => 'Choose Customer or Business.';

  @override
  String get accountTypeTitle => 'Welcome to Resto';

  @override
  String get accountTypeSub => 'How will you use the app?';

  @override
  String get continueAction => 'Continue';

  @override
  String adVideoTooBig(String name) {
    return '$name is over 50 MB: choose a shorter video (about 30 seconds).';
  }

  @override
  String adMediaAdded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count files added.',
      one: '1 file added.',
    );
    return '$_temp0';
  }

  @override
  String get adNeedVideo => 'Add a video before publishing this format.';

  @override
  String get adNeedMedia =>
      'Add at least one photo or video before publishing.';

  @override
  String get adNeedItems => 'Choose at least one dish to feature.';

  @override
  String get uploadingLabel => 'Uploading…';

  @override
  String get errorInvalidMedia =>
      'File refused: it must come from your media library.';

  @override
  String get errorFileTooLarge => 'File too large.';

  @override
  String get errorFileType =>
      'File format not accepted (JPG, PNG, WebP, MP4, WebM, MOV).';

  @override
  String get adAddVideo => 'Add a video';

  @override
  String get errorOutOfStock => 'This dish is sold out for today.';

  @override
  String get errorInvalidRating => 'The rating must be between 1 and 5.';

  @override
  String get errorInvalidAllergen => 'Unknown allergen.';

  @override
  String get bestSeller => 'Best seller';

  @override
  String get callAction => 'Call';

  @override
  String get writeAction => 'Message';

  @override
  String get categoriesLabel => 'Categories';

  @override
  String get filtersLabel => 'Filters';

  @override
  String get reviewsTab => 'Reviews';

  @override
  String get infosTab => 'Info';

  @override
  String get noDishMatches => 'No dish matches these filters.';

  @override
  String soldCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sold',
      one: '1 sold',
    );
    return '$_temp0';
  }

  @override
  String get yourCart => 'Your cart';

  @override
  String get coverPhoto => 'Cover photo';

  @override
  String get coverPhotoHint =>
      'Large photo at the top of your restaurant page (dining room, terrace, storefront).';

  @override
  String get changePhoto => 'Change photo';

  @override
  String get itemTagsLabel => 'Tags (filters for your menu)';

  @override
  String get itemTagsHint =>
      'Create your own tags: customers can filter your menu with them. E.g. Mild spice, Halal, Alcohol-free, Homemade.';

  @override
  String get addTagHint => 'New tag + Enter';

  @override
  String get errorInvalidTag => 'A tag can have up to 30 characters.';

  @override
  String itemFavorites(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count customers have it in favorites',
      one: '1 customer has it in favorites',
      zero: 'No customer has it in favorites',
    );
    return '$_temp0';
  }

  @override
  String get itemSold30 => 'Sales over the last 30 days';

  @override
  String get receiptOrderNo => 'Order No.';

  @override
  String get receiptTicketNo => 'Receipt No.';

  @override
  String get receiptChannel => 'Channel';

  @override
  String get receiptQtyShort => 'Qty';

  @override
  String get receiptTotalInclTax => 'Total incl. tax';

  @override
  String get receiptTotalExclTax => 'Total excl. tax';

  @override
  String get receiptApproved => 'Transaction approved';

  @override
  String receiptRef(String ref) {
    return 'Ref.: $ref';
  }

  @override
  String receiptSeeYou(String name) {
    return 'See you soon at $name';
  }

  @override
  String get receiptRecycle =>
      'For a greener planet, please recycle this receipt.';

  @override
  String get receiptLoyaltyTitle => 'Your loyalty pays off!';

  @override
  String get receiptLoyaltyCaption =>
      'Scan this QR code to open your loyalty space and enjoy your rewards.';

  @override
  String get receiptPaperLabel => 'Receipt printer on this device';

  @override
  String get receiptPaper80 => '80 mm roll';

  @override
  String get receiptPaper58 => '58 mm roll';

  @override
  String get receiptPhotosLabel => 'Dish photos on the receipt';

  @override
  String get receiptTestPrint => 'Print a test receipt';

  @override
  String get receiptTestTitle => 'Test receipt';

  @override
  String get receiptHeaderSection => 'Receipt header';

  @override
  String get receiptFooterSection => 'Receipt footer';

  @override
  String get receiptTitleLabel => 'Displayed name';

  @override
  String get receiptTitleHint => 'Default: the brand name';

  @override
  String get receiptSubtitleLabel => 'Subtitle';

  @override
  String get receiptSubtitleHint => 'E.g. Restaurant & Flavours';

  @override
  String get receiptSloganLabel => 'Slogan';

  @override
  String get receiptSloganHint =>
      'E.g. Authentic cooking, flavours from around the world';

  @override
  String get websiteLabel => 'Website';

  @override
  String get websiteHint => 'E.g. www.myrestaurant.com';

  @override
  String get receiptQrTitleLabel => 'Title next to the QR code';

  @override
  String get receiptQrCaptionLabel => 'Text next to the QR code';

  @override
  String get receiptFarewellLabel => 'Farewell line';

  @override
  String get receiptFarewellHint => 'E.g. See you soon!';

  @override
  String itemLikesTip(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count likes',
      one: '1 like',
      zero: 'No likes',
    );
    return '$_temp0';
  }

  @override
  String get itemReviewAction => 'Review';

  @override
  String get itemHeartAction => 'Love';

  @override
  String get itemCommentsTitle => 'Customer reviews';

  @override
  String get itemVerifiedReviews => 'Rated reviews after an order';

  @override
  String get notifStaffNewOrderTitle => 'New order';

  @override
  String notifStaffNewOrder(String number, String customer, String branch) {
    return 'Order #$number $customer — $branch';
  }

  @override
  String get notifStaffOrderReadyTitle => 'Order ready to serve';

  @override
  String notifStaffOrderReady(String number, String branch) {
    return 'Order #$number — $branch';
  }

  @override
  String get notifStaffReservationTitle => 'New reservation';

  @override
  String notifStaffReservation(String name, int count, String date) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count guests',
      one: '1 guest',
    );
    return '$name · $_temp0 · $date';
  }

  @override
  String get notifStaffReviewTitle => 'New review';

  @override
  String notifStaffReview(String author, String item) {
    return '$author on “$item”';
  }

  @override
  String get pushNewOrder => 'Phone notification: new customer order';

  @override
  String get pushOrderReady => 'Phone notification: order ready to serve';

  @override
  String get pushReservations => 'Phone notification: new reservation';

  @override
  String get pushReviews => 'Phone notification: new dish review';

  @override
  String get tablesTab => 'Tables';

  @override
  String get tablesNow => 'Now';

  @override
  String get tablesLater => 'Pick a time';

  @override
  String get tableLegendOccupied => 'Occupied';

  @override
  String get tableLegendReserved => 'Reserved';

  @override
  String get tableLegendChosen => 'Your choice';

  @override
  String tableFreeUntil(String time) {
    return 'Free until $time';
  }

  @override
  String tableOccupiedUntil(String time) {
    return 'Free around $time';
  }

  @override
  String tableReservedSlot(String from, String to) {
    return 'Reserved $from–$to';
  }

  @override
  String get tablesSelectHint => 'Tap one or more free tables to reserve them.';

  @override
  String tablesSeatsChosen(int seats, int party) {
    String _temp0 = intl.Intl.pluralLogic(
      seats,
      locale: localeName,
      other: '$seats seats chosen',
      one: '1 seat chosen',
    );
    String _temp1 = intl.Intl.pluralLogic(
      party,
      locale: localeName,
      other: '$party guests',
      one: '1 guest',
    );
    return '$_temp0 for $_temp1';
  }

  @override
  String reserveTablesAction(String tables) {
    return 'Reserve $tables';
  }

  @override
  String tableLabelChip(String label) {
    return 'Table $label';
  }

  @override
  String get tablesEmpty => 'This restaurant has not shown its tables yet.';

  @override
  String appVersion(String version, String build) {
    return 'Resto · version $version ($build)';
  }

  @override
  String get dashTabOverview => 'Overview';

  @override
  String get dashTabDishes => 'Dishes';

  @override
  String get dashTabTeam => 'Team and service';

  @override
  String get dashTabFinance => 'Finances';

  @override
  String get coversLabel => 'Covers';

  @override
  String perCoverLabel(String amount) {
    return '$amount per cover';
  }

  @override
  String get occupancyLabel => 'Tables occupied';

  @override
  String get paymentsByMethod => 'Payments by method';

  @override
  String get busyHours => 'Busy times by day and hour';

  @override
  String get menuEngineering => 'Menu engineering';

  @override
  String get menuEngineeringHint =>
      'Sales × margin of each dish, based on recipe cards.';

  @override
  String get engStars => 'Stars';

  @override
  String get engStarsHint =>
      'Popular and profitable: keep them in the spotlight.';

  @override
  String get engPlowhorses => 'Popular, low margin';

  @override
  String get engPlowhorsesHint => 'Review the price or the food cost.';

  @override
  String get engPuzzles => 'Profitable, rarely sold';

  @override
  String get engPuzzlesHint =>
      'Promote them: photo, advertising, staff suggestions.';

  @override
  String get engDogs => 'To review';

  @override
  String get engDogsHint => 'Rarely sold and low margin: rework or remove.';

  @override
  String engNoRecipe(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dishes without a recipe card are not ranked.',
      one: '1 dish without a recipe card is not ranked.',
    );
    return '$_temp0';
  }

  @override
  String get slowSellers => 'Slow-selling dishes';

  @override
  String get teamPerformance => 'Team performance';

  @override
  String get memberLabel => 'Member';

  @override
  String get staffOrders => 'Orders';

  @override
  String get staffSales => 'Sales';

  @override
  String get staffTips => 'Tips';

  @override
  String get serviceTimes => 'Service times';

  @override
  String get serveTime => 'Time to table';

  @override
  String get tableTime => 'Time at table';

  @override
  String minutesValue(int count) {
    return '$count min';
  }

  @override
  String targetMinutes(int count) {
    return 'Target: $count min';
  }

  @override
  String get cancellationsTitle => 'Cancellations';

  @override
  String cancelledOrdersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cancelled orders',
      one: '1 cancelled order',
      zero: 'No cancelled order',
    );
    return '$_temp0';
  }

  @override
  String cancelledItemsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items cancelled after sending',
      one: '1 item cancelled after sending',
      zero: 'No item cancelled after sending',
    );
    return '$_temp0';
  }

  @override
  String get cancelReasonsTitle => 'Most common reasons';

  @override
  String get dashPdf => 'PDF report';

  @override
  String get insightsUnavailable =>
      'Detailed indicators will appear after the database update (migration 034).';

  @override
  String get salesByDayTitle => 'Sales by day';

  @override
  String get ordersCountLabel => 'Orders';

  @override
  String get financeItemLabel => 'Item';

  @override
  String get supplierLabel => 'Supplier';

  @override
  String get purchaseOrderTitle => 'Purchase order';

  @override
  String get supplierStatementTitle => 'Supplier statement';

  @override
  String get dueDateLabel => 'Due date';

  @override
  String get balanceDue => 'Balance due';

  @override
  String get purchasesThisMonth => 'Purchases this month';

  @override
  String openInvoicesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count invoices to pay',
      one: '1 invoice to pay',
      zero: 'No invoice to pay',
    );
    return '$_temp0';
  }

  @override
  String get overdueInvoices => 'Overdue invoices';

  @override
  String get dueWithinWeek => 'Due within 7 days';

  @override
  String get pendingPurchaseOrders => 'Orders in progress';

  @override
  String get paymentSchedule => 'Payment schedule';

  @override
  String get nothingToPay => 'No invoice to pay.';

  @override
  String get noDueDate => 'No due date';

  @override
  String get purchasesByMonth => 'Purchases by month';

  @override
  String get topSuppliers => 'Top suppliers (90 days)';

  @override
  String get noPurchasesYet => 'No purchases yet.';

  @override
  String get totalPurchased => 'Total purchased';

  @override
  String get purchaseOrderPdf => 'Purchase order PDF';
}
