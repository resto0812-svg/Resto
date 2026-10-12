// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'Resto';

  @override
  String environmentBanner(String env) {
    return 'البيئة: $env';
  }

  @override
  String get configMissingTitle => 'الإعدادات غير مكتملة';

  @override
  String get configMissingBody =>
      'لم يتم توفير عنوان الخادم والمفتاح العام (ملف env/<البيئة>.json).';

  @override
  String get languageLabel => 'اللغة';

  @override
  String get systemLanguage => 'لغة الجهاز';

  @override
  String pendingSyncEvents(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count عملية قيد الانتظار',
      many: '$count عملية قيد الانتظار',
      few: '$count عمليات قيد الانتظار',
      two: 'عمليتان قيد الانتظار',
      one: 'عملية واحدة قيد الانتظار',
      zero: 'تمت مزامنة كل شيء',
    );
    return '$_temp0';
  }

  @override
  String get errorNotAuthenticated => 'يرجى تسجيل الدخول.';

  @override
  String get errorForbidden => 'ليس لديك صلاحية تنفيذ هذا الإجراء.';

  @override
  String get errorOwnerOnly => 'لا يمكن تنفيذ هذا الإجراء إلا من قبل مالك.';

  @override
  String get errorRateLimited => 'طلبات كثيرة جدًا. حاول مرة أخرى لاحقًا.';

  @override
  String get errorInvalidTimezone => 'منطقة زمنية غير معروفة.';

  @override
  String get errorInvalidRole => 'دور غير معروف.';

  @override
  String get errorInvalidEmail => 'عنوان بريد إلكتروني غير صالح.';

  @override
  String get errorInvalidBranch => 'الفرع غير موجود في هذه المؤسسة.';

  @override
  String get errorBranchesRequired => 'اختر فرعًا واحدًا على الأقل.';

  @override
  String get errorAlreadyMember => 'هذا الشخص عضو بالفعل في المؤسسة.';

  @override
  String get errorInvitationInvalid =>
      'دعوة غير صالحة أو منتهية أو مستخدمة من قبل.';

  @override
  String get errorInvitationWrongAccount =>
      'هذه الدعوة موجهة إلى عنوان بريد إلكتروني آخر.';

  @override
  String get errorLastOwner => 'يجب أن تحتفظ المؤسسة بمالك واحد على الأقل.';

  @override
  String get errorMembershipRevoked => 'تمت إزالة هذا العضو من المؤسسة.';

  @override
  String get errorNetwork => 'تعذر الاتصال. تحقق من اتصالك بالإنترنت.';

  @override
  String get errorUnknown => 'حدث خطأ غير متوقع.';

  @override
  String get welcomeTitle => 'مرحبًا بك في Resto';

  @override
  String get signInTitle => 'تسجيل الدخول';

  @override
  String get signIn => 'تسجيل الدخول';

  @override
  String get signOut => 'تسجيل الخروج';

  @override
  String get createAccount => 'إنشاء حساب';

  @override
  String get forgotPassword => 'نسيت كلمة المرور';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get password => 'كلمة المرور';

  @override
  String get passwordConfirm => 'تأكيد كلمة المرور';

  @override
  String get passwordTooShort => '8 أحرف على الأقل.';

  @override
  String get passwordsDiffer => 'كلمتا المرور غير متطابقتين.';

  @override
  String get passwordChanged => 'تم تغيير كلمة المرور.';

  @override
  String get newPasswordTitle => 'كلمة مرور جديدة';

  @override
  String get changePassword => 'تغيير كلمة المرور';

  @override
  String get displayName => 'الاسم';

  @override
  String get fieldRequired => 'حقل إلزامي';

  @override
  String get verifyEmailTitle => 'تأكيد بريدك الإلكتروني';

  @override
  String codeSentTo(String email) {
    return 'تم إرسال الرمز إلى $email.';
  }

  @override
  String get code => 'الرمز';

  @override
  String get verify => 'تأكيد';

  @override
  String get resendCode => 'إعادة إرسال الرمز';

  @override
  String get codeResent => 'تم إرسال رمز جديد.';

  @override
  String get sendCode => 'إرسال الرمز';

  @override
  String get authInvalidCredentials =>
      'البريد الإلكتروني أو كلمة المرور غير صحيحة.';

  @override
  String get authEmailNotConfirmed => 'البريد الإلكتروني غير مؤكد.';

  @override
  String get authUserExists => 'يوجد حساب بهذا العنوان بالفعل.';

  @override
  String get authWeakPassword => 'كلمة المرور ضعيفة جدًا.';

  @override
  String get authCodeInvalid => 'رمز غير صالح أو منتهي الصلاحية.';

  @override
  String get authSamePassword => 'يجب أن تختلف كلمة المرور الجديدة عن القديمة.';

  @override
  String get errorDuplicate => 'هذه القيمة موجودة بالفعل.';

  @override
  String get errorInvalidHours => 'ساعات عمل غير صالحة.';

  @override
  String get createRestaurant => 'إنشاء مطعمي';

  @override
  String get joinTeam => 'الانضمام إلى فريق';

  @override
  String get organizationName => 'اسم المؤسسة';

  @override
  String get brandNameOptional => 'الاسم التجاري (اختياري)';

  @override
  String get branchNameOptional => 'اسم الفرع (اختياري)';

  @override
  String get country => 'البلد';

  @override
  String get currency => 'العملة';

  @override
  String get timezone => 'المنطقة الزمنية';

  @override
  String get defaultLanguage => 'اللغة الرئيسية';

  @override
  String get city => 'المدينة';

  @override
  String get create => 'إنشاء';

  @override
  String get invitationCode => 'رمز الدعوة';

  @override
  String get join => 'انضمام';

  @override
  String get navBranches => 'الفروع';

  @override
  String get navTeam => 'الفريق';

  @override
  String get navAudit => 'السجل';

  @override
  String get navAccount => 'الحساب';

  @override
  String get switchOrganization => 'تغيير المؤسسة';

  @override
  String get orgSuspended => 'المؤسسة موقوفة: للاطلاع فقط.';

  @override
  String get newBranch => 'فرع جديد';

  @override
  String get noBranches => 'لا توجد فروع.';

  @override
  String get branchInfo => 'المعلومات';

  @override
  String get openingHours => 'ساعات العمل';

  @override
  String get floor => 'الصالة';

  @override
  String get name => 'الاسم';

  @override
  String get addressLine1 => 'العنوان';

  @override
  String get addressLine2 => 'تتمة العنوان';

  @override
  String get region => 'المنطقة';

  @override
  String get postalCode => 'الرمز البريدي';

  @override
  String get phone => 'الهاتف';

  @override
  String get offeredLanguages => 'اللغات المتاحة';

  @override
  String get published => 'مرئي للعملاء';

  @override
  String get archived => 'مؤرشف';

  @override
  String get readOnly => 'للاطلاع فقط';

  @override
  String get save => 'حفظ';

  @override
  String get saved => 'تم الحفظ.';

  @override
  String get cancel => 'إلغاء';

  @override
  String get confirm => 'تأكيد';

  @override
  String get close => 'إغلاق';

  @override
  String get edit => 'تعديل';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get closed => 'مغلق';

  @override
  String get addSlot => 'إضافة فترة';

  @override
  String get opensAt => 'الافتتاح';

  @override
  String get closesAt => 'الإغلاق';

  @override
  String get nextDay => 'اليوم التالي';

  @override
  String get weekday1 => 'الاثنين';

  @override
  String get weekday2 => 'الثلاثاء';

  @override
  String get weekday3 => 'الأربعاء';

  @override
  String get weekday4 => 'الخميس';

  @override
  String get weekday5 => 'الجمعة';

  @override
  String get weekday6 => 'السبت';

  @override
  String get weekday7 => 'الأحد';

  @override
  String get newArea => 'منطقة جديدة';

  @override
  String get areaName => 'المنطقة';

  @override
  String get noAreas => 'لا توجد مناطق بعد.';

  @override
  String get newTable => 'طاولة جديدة';

  @override
  String get tableLabel => 'اسم الطاولة';

  @override
  String get seats => 'المقاعد';

  @override
  String get active => 'نشط';

  @override
  String get inactive => 'معطّل';

  @override
  String tablesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count طاولة',
      many: '$count طاولة',
      few: '$count طاولات',
      two: 'طاولتان',
      one: 'طاولة واحدة',
      zero: 'لا توجد طاولات',
    );
    return '$_temp0';
  }

  @override
  String seatsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مقعد',
      many: '$count مقعدًا',
      few: '$count مقاعد',
      two: 'مقعدان',
      one: 'مقعد واحد',
    );
    return '$_temp0';
  }

  @override
  String get invite => 'دعوة';

  @override
  String get role => 'الدور';

  @override
  String get allBranches => 'كل الفروع';

  @override
  String get pendingInvitations => 'دعوات قيد الانتظار';

  @override
  String expiresOn(String date) {
    return 'تنتهي في $date';
  }

  @override
  String get revoke => 'إزالة';

  @override
  String revokeConfirm(String name) {
    return 'إزالة $name من المؤسسة؟';
  }

  @override
  String get changeRole => 'تغيير الدور';

  @override
  String get you => 'أنت';

  @override
  String get invitationCreatedTitle => 'تم إنشاء الدعوة';

  @override
  String invitationCreatedBody(String email) {
    return 'أرسل هذا الرمز إلى $email. صالح لمدة 7 أيام ولا يعمل إلا مع هذا العنوان.';
  }

  @override
  String invitationMessage(String organization, String code) {
    return 'أنت مدعو للانضمام إلى «$organization» على Resto. أنشئ حسابك بهذا البريد الإلكتروني، ثم أدخل هذا الرمز في «الانضمام إلى فريق»: $code';
  }

  @override
  String get copyMessage => 'نسخ الرسالة';

  @override
  String get copied => 'تم النسخ.';

  @override
  String get roleOwner => 'المالك';

  @override
  String get roleAdmin => 'المسؤول';

  @override
  String get roleManager => 'المدير';

  @override
  String get roleAccountant => 'المحاسب';

  @override
  String get roleCashier => 'أمين الصندوق';

  @override
  String get roleStockKeeper => 'أمين المخزن';

  @override
  String get roleWaiter => 'النادل';

  @override
  String get roleKitchen => 'المطبخ / البار';

  @override
  String get roleViewer => 'قارئ';

  @override
  String get loadMore => 'عرض المزيد';

  @override
  String get noEntries => 'لا توجد عمليات مسجلة.';

  @override
  String get actionInsert => 'إنشاء';

  @override
  String get actionUpdate => 'تعديل';

  @override
  String get actionDelete => 'حذف';

  @override
  String get entityOrganization => 'المؤسسة';

  @override
  String get entityMembership => 'عضو';

  @override
  String get entityInvitation => 'دعوة';

  @override
  String get entityBrand => 'العلامة التجارية';

  @override
  String get entityBranch => 'الفرع';

  @override
  String get entityArea => 'المنطقة';

  @override
  String get entityTable => 'الطاولة';

  @override
  String get navMenus => 'القوائم';

  @override
  String get brand => 'العلامة التجارية';

  @override
  String get category => 'الفئة';

  @override
  String get description => 'الوصف';

  @override
  String get newCategory => 'فئة جديدة';

  @override
  String get kindFood => 'طبق';

  @override
  String get kindDrink => 'مشروب';

  @override
  String get kindOther => 'أخرى';

  @override
  String selectionRule(int min, String max) {
    return 'الاختيار: من $min إلى $max';
  }

  @override
  String get allergens => 'مسببات الحساسية';

  @override
  String get allergenGluten => 'الغلوتين';

  @override
  String get allergenCrustaceans => 'القشريات';

  @override
  String get allergenEggs => 'البيض';

  @override
  String get allergenFish => 'السمك';

  @override
  String get allergenPeanuts => 'الفول السوداني';

  @override
  String get allergenSoybeans => 'الصويا';

  @override
  String get allergenMilk => 'الحليب';

  @override
  String get allergenNuts => 'المكسرات';

  @override
  String get allergenCelery => 'الكرفس';

  @override
  String get allergenMustard => 'الخردل';

  @override
  String get allergenSesame => 'السمسم';

  @override
  String get allergenSulphites => 'الكبريتيت';

  @override
  String get allergenLupin => 'الترمس';

  @override
  String get allergenMolluscs => 'الرخويات';

  @override
  String get translations => 'الترجمات';

  @override
  String get soldOut => 'نفد';

  @override
  String get channelDefault => 'السعر الأساسي';

  @override
  String get channelDineIn => 'في المطعم';

  @override
  String get channelTakeaway => 'سفري';

  @override
  String get channelDelivery => 'توصيل';

  @override
  String get otherChannels => 'الأسعار حسب القناة';

  @override
  String get noPrice => 'بدون سعر';

  @override
  String get errorInvalidPrice => 'سعر غير صالح.';

  @override
  String get errorCurrencyLocked =>
      'لم يعد بالإمكان تغيير العملة: توجد أسعار بالفعل في هذا الفرع.';

  @override
  String get entityItem => 'صنف';

  @override
  String get entityVariant => 'حجم';

  @override
  String get entityModifier => 'إضافة';

  @override
  String get entityPrice => 'السعر';

  @override
  String get menuOfBranch => 'قائمة الفرع';

  @override
  String get menuEmptyTitle => 'قائمتك فارغة';

  @override
  String get menuEmptyHint =>
      'ابدأ بإنشاء فئة (مثل الأطباق، المشروبات، الحلويات)، ثم أضف أصنافك مع أسعارها.';

  @override
  String get categoryExamples => 'مثال: الأطباق، المشروبات، الحلويات';

  @override
  String get descriptionOptional => 'الوصف (اختياري)';

  @override
  String get visibleOnMenu => 'ظاهر في القائمة';

  @override
  String get hidden => 'مخفي';

  @override
  String get addItem => 'إضافة صنف';

  @override
  String addItemIn(String category) {
    return 'إضافة صنف إلى «$category»';
  }

  @override
  String get notSoldHere => 'غير معروض في هذا الفرع';

  @override
  String get itemName => 'اسم الصنف';

  @override
  String get itemExamples => 'مثال: ندولي، دجاج DG، عصير الكركديه';

  @override
  String get priceTitle => 'السعر';

  @override
  String priceAt(String branch) {
    return 'السعر في $branch';
  }

  @override
  String get price => 'السعر';

  @override
  String get severalSizes => 'هذا الصنف متوفر بعدة أحجام أو أشكال';

  @override
  String get sizeName => 'الحجم / الشكل';

  @override
  String get sizeExamples => 'مثال: صغير، 33 سل';

  @override
  String get addSize => 'إضافة حجم';

  @override
  String get removeSize => 'إزالة هذا الحجم';

  @override
  String get sizeNameRequired => 'أعطِ كل حجم اسمًا (مثل صغير، كبير).';

  @override
  String get samePriceEverywhere =>
      'سيُطبَّق هذا السعر في كل الفروع المختارة أدناه؛ يمكنك تعديله لاحقًا لكل فرع.';

  @override
  String get salesTitle => 'البيع';

  @override
  String soldAt(String branch) {
    return 'يُباع في $branch';
  }

  @override
  String get soldOutToday => 'نفد حاليًا';

  @override
  String get optionsForItem => 'الخيارات المعروضة على العميل';

  @override
  String get manageOptions => 'إدارة الخيارات';

  @override
  String get noOptionsYet =>
      'لا توجد خيارات بعد (طبق جانبي، درجة الطهي، صلصة…).';

  @override
  String get optionsTitle => 'الخيارات والإضافات';

  @override
  String get optionsIntro =>
      'الخيار هو اختيار يقوم به العميل عند طلب صنف: الطبق الجانبي، درجة الطهي، صلصة، إضافة مدفوعة…';

  @override
  String get newOptionGroup => 'خيار جديد';

  @override
  String get optionGroupName => 'اسم الخيار';

  @override
  String get optionGroupExamples => 'مثال: طبق جانبي، درجة الطهي، الحرارة';

  @override
  String get customerMust => 'العميل:';

  @override
  String get ruleRequiredOne => 'يجب أن يختار خيارًا واحدًا (إلزامي)';

  @override
  String get ruleOptionalOne => 'يمكنه اختيار خيار واحد (اختياري)';

  @override
  String get ruleOptionalMany => 'يمكنه اختيار عدة خيارات (اختياري)';

  @override
  String get ruleRequiredMany =>
      'يجب أن يختار خيارًا واحدًا على الأقل، ويمكنه اختيار المزيد';

  @override
  String get choices => 'الاختيارات المعروضة';

  @override
  String choicePriceHint(String branch) {
    return 'اترك السعر فارغًا أو 0 إذا كان الاختيار مجانيًا. السعر في $branch.';
  }

  @override
  String get choiceName => 'الاختيار';

  @override
  String get choiceExamples => 'مثال: ميوندو، أرز';

  @override
  String get extraPrice => 'سعر إضافي';

  @override
  String get addChoice => 'إضافة اختيار';

  @override
  String get removeChoice => 'إزالة هذا الاختيار';

  @override
  String get choicesRequired => 'أضف اختيارًا واحدًا على الأقل.';

  @override
  String get navOrders => 'الطلبات';

  @override
  String openOrdersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count طلب جارٍ',
      many: '$count طلبًا جاريًا',
      few: '$count طلبات جارية',
      two: 'طلبان جاريان',
      one: 'طلب جارٍ واحد',
      zero: 'لا توجد طلبات جارية',
    );
    return '$_temp0';
  }

  @override
  String get refresh => 'تحديث';

  @override
  String get newTakeaway => 'بيع سفري';

  @override
  String get takeawayOrders => 'طلبات سفري جارية';

  @override
  String orderNumber(int number) {
    return 'الطلب رقم $number';
  }

  @override
  String minutesAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'منذ $count دقيقة',
      many: 'منذ $count دقيقة',
      few: 'منذ $count دقائق',
      two: 'منذ دقيقتين',
      one: 'منذ دقيقة',
      zero: 'الآن',
    );
    return '$_temp0';
  }

  @override
  String get noTablesYet =>
      'لا توجد طاولات: أنشئ الصالة من الفروع ← الصالة. يبقى البيع السفري ممكنًا.';

  @override
  String get tableFree => 'متاحة';

  @override
  String get toSend => 'أصناف بانتظار الإرسال إلى المطبخ';

  @override
  String tableName(String label) {
    return 'الطاولة $label';
  }

  @override
  String get menuTab => 'القائمة';

  @override
  String ticketTab(int count) {
    return 'الطلب ($count)';
  }

  @override
  String get allCategories => 'الكل';

  @override
  String get nothingToSell =>
      'لا شيء للبيع حاليًا: أضف أصنافًا بأسعارها في القوائم.';

  @override
  String fromPrice(String price) {
    return 'ابتداءً من $price';
  }

  @override
  String itemSoldOut(String name) {
    return '$name نفد.';
  }

  @override
  String get emptyTicket => 'المس صنفًا من القائمة لإضافته.';

  @override
  String get less => 'واحد أقل';

  @override
  String get more => 'واحد أكثر';

  @override
  String get cancelLine => 'إلغاء هذا السطر';

  @override
  String get cancelOrder => 'إلغاء الطلب';

  @override
  String get cancelOrderConfirm =>
      'إلغاء هذا الطلب؟ لم يُرسل شيء إلى المطبخ بعد.';

  @override
  String get reason => 'السبب';

  @override
  String get subtotal => 'المجموع الفرعي';

  @override
  String taxLine(String rate) {
    return 'الضريبة ($rate %)';
  }

  @override
  String get total => 'الإجمالي';

  @override
  String taxIncluded(String rate, String amount) {
    return 'منها ضريبة $rate %: $amount';
  }

  @override
  String sendToKitchen(int count) {
    return 'إرسال إلى المطبخ ($count)';
  }

  @override
  String sentToKitchen(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'أُرسل $count صنف إلى المطبخ',
      many: 'أُرسل $count صنفًا إلى المطبخ',
      few: 'أُرسلت $count أصناف إلى المطبخ',
      two: 'أُرسل صنفان إلى المطبخ',
      one: 'أُرسل صنف واحد إلى المطبخ',
    );
    return '$_temp0';
  }

  @override
  String get prepPending => 'بانتظار الإرسال';

  @override
  String get prepSent => 'في المطبخ';

  @override
  String get prepPreparing => 'قيد التحضير';

  @override
  String get prepReady => 'جاهز';

  @override
  String get prepServed => 'قُدِّم';

  @override
  String get prepCancelled => 'ملغى';

  @override
  String get noneOption => 'لا شيء';

  @override
  String get kitchenNote => 'ملاحظة للمطبخ (اختياري)';

  @override
  String get kitchenNoteExamples => 'مثال: بدون بصل، مطهو جيدًا';

  @override
  String get quantity => 'الكمية';

  @override
  String addForPrice(String price) {
    return 'إضافة · $price';
  }

  @override
  String get taxTitle => 'الضريبة';

  @override
  String get taxRate => 'نسبة الضريبة';

  @override
  String get taxRateHint => 'مثال: 19.25 (0 إذا لم توجد ضريبة)';

  @override
  String get pricesIncludeTax => 'الأسعار المعروضة تشمل الضريبة';

  @override
  String get errorInvalidTaxRate => 'نسبة غير صالحة (من 0 إلى 99.999).';

  @override
  String get errorOrderNotOpen => 'هذا الطلب لم يعد مفتوحًا.';

  @override
  String get errorItemUnavailable => 'هذا الصنف غير متوفر في هذا الفرع.';

  @override
  String get errorNoPrice => 'هذا الصنف بلا سعر في هذا الفرع.';

  @override
  String get errorOptionsInvalid => 'الخيارات المختارة لا تحترم قواعد الصنف.';

  @override
  String get errorInvalidQuantity => 'كمية غير صالحة.';

  @override
  String get errorItemAlreadySent =>
      'هذا السطر أُرسل إلى المطبخ ولم يعد قابلًا للتعديل.';

  @override
  String get errorReasonRequired => 'يرجى ذكر السبب.';

  @override
  String get errorInvalidOrder => 'طلب غير صالح.';

  @override
  String get errorBranchInactive => 'هذا الفرع مؤرشف.';

  @override
  String get navCash => 'الصندوق';

  @override
  String get amount => 'المبلغ';

  @override
  String get registerClosed => 'مغلق';

  @override
  String get openRegisterShort => 'فتح الصندوق';

  @override
  String openRegister(String name) {
    return 'فتح $name';
  }

  @override
  String get openingFloat => 'رصيد البداية (فكة البداية)';

  @override
  String registerOpenSince(String time) {
    return 'مفتوح منذ $time';
  }

  @override
  String expectedCash(String amount) {
    return 'النقد المتوقع: $amount';
  }

  @override
  String cashBreakdown(String float, String inAmount, String outAmount) {
    return 'رصيد البداية $float · إيداعات $inAmount · سحوبات $outAmount';
  }

  @override
  String paymentsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count دفعة',
      many: '$count دفعة',
      few: '$count دفعات',
      two: 'دفعتان',
      one: 'دفعة واحدة',
      zero: 'لا مدفوعات',
    );
    return '$_temp0';
  }

  @override
  String get cashIn => 'إيداع نقدي';

  @override
  String get cashOut => 'سحب نقدي';

  @override
  String get movementExamples => 'مثال: شراء غاز، إضافة فكة';

  @override
  String get closeRegister => 'إغلاق الصندوق';

  @override
  String get countedCash => 'النقد المعدود في الدرج';

  @override
  String get countInfo =>
      'عُدّ الأوراق والقطع النقدية في الدرج، بما فيها رصيد البداية.';

  @override
  String get countResult => 'نتيجة العد';

  @override
  String countedCashValue(String amount) {
    return 'المعدود: $amount';
  }

  @override
  String get noDifference => 'لا يوجد فرق';

  @override
  String differenceValue(String amount) {
    return 'الفرق: $amount';
  }

  @override
  String get awaitingValidation => 'يجب على مسؤول الآن اعتماد هذا الإغلاق.';

  @override
  String get awaitingValidationTitle => 'إغلاقات بانتظار الاعتماد';

  @override
  String get validateClosing => 'اعتماد الإغلاق';

  @override
  String get validate => 'اعتماد';

  @override
  String get comment => 'تعليق';

  @override
  String get closedSessions => 'آخر الإغلاقات';

  @override
  String get dailyReport => 'تقرير اليوم';

  @override
  String get previousDay => 'اليوم السابق';

  @override
  String get nextDayButton => 'اليوم التالي';

  @override
  String get salesTotal => 'رقم المبيعات';

  @override
  String get ordersClosedCount => 'طلبات مدفوعة';

  @override
  String get averageTicket => 'متوسط الفاتورة';

  @override
  String get taxCollected => 'الضريبة المحصلة';

  @override
  String get paymentsReceived => 'التحصيلات حسب وسيلة الدفع';

  @override
  String ordersStillOpen(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count طلب ما زال جاريًا',
      many: '$count طلبًا ما زال جاريًا',
      few: '$count طلبات ما زالت جارية',
      two: 'طلبان ما زالا جاريين',
      one: 'طلب واحد ما زال جاريًا',
      zero: 'لا طلبات جارية',
    );
    return '$_temp0';
  }

  @override
  String ordersCancelledCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ملغى',
      many: '$count ملغى',
      few: '$count ملغاة',
      two: 'اثنان ملغيان',
      one: 'واحد ملغى',
      zero: 'لا ملغاة',
    );
    return '$_temp0';
  }

  @override
  String linesCancelledCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count سطر ملغى',
      many: '$count سطرًا ملغى',
      few: '$count أسطر ملغاة',
      two: 'سطران ملغيان',
      one: 'سطر واحد ملغى',
      zero: 'لا أسطر ملغاة',
    );
    return '$_temp0';
  }

  @override
  String refundsTotal(String amount) {
    return 'المسترد: $amount';
  }

  @override
  String get topItems => 'الأصناف الأكثر مبيعًا';

  @override
  String get payCash => 'نقدًا';

  @override
  String get payCard => 'بطاقة';

  @override
  String get payMobileMoney => 'Mobile Money';

  @override
  String get payTransfer => 'تحويل';

  @override
  String get payOther => 'أخرى';

  @override
  String get collectPayment => 'تحصيل';

  @override
  String collectAmount(String amount) {
    return 'تحصيل $amount';
  }

  @override
  String amountDue(String amount) {
    return 'المتبقي للدفع: $amount';
  }

  @override
  String get splitBill => 'تقسيم الفاتورة';

  @override
  String splitParts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count حصة',
      many: '$count حصة',
      few: '$count حصص',
      two: 'حصتان',
      one: 'حصة واحدة',
    );
    return '$_temp0';
  }

  @override
  String get amountToCollect => 'المبلغ المحصل';

  @override
  String get cashTendered => 'المبلغ الذي دفعه العميل (اختياري)';

  @override
  String changeToGive(String amount) {
    return 'الباقي: $amount';
  }

  @override
  String get giveChange => 'الباقي المستحق للعميل';

  @override
  String get transactionReference => 'رقم العملية (اختياري)';

  @override
  String get manualPaymentNote =>
      'البطاقة و Mobile Money: تحقق من استلام الدفعة قبل التأكيد.';

  @override
  String get openCashFirst => 'افتح الصندوق أولًا (قسم الصندوق).';

  @override
  String get chooseRegister => 'اختيار الصندوق';

  @override
  String get orderPaidClosed => 'الطلب مدفوع ومغلق.';

  @override
  String get paid => 'المدفوع';

  @override
  String get remainingDue => 'المتبقي للدفع';

  @override
  String get voided => 'ملغى';

  @override
  String get voidPayment => 'إلغاء هذه الدفعة';

  @override
  String get orderClosed => 'الطلب مدفوع ومغلق';

  @override
  String get orderCancelled => 'الطلب ملغى';

  @override
  String get errorNoOpenSession => 'لا يوجد صندوق مفتوح لهذا التحصيل.';

  @override
  String get errorSessionAlreadyOpen => 'هذا الصندوق مفتوح بالفعل.';

  @override
  String get errorRegisterInactive => 'هذا الصندوق معطّل.';

  @override
  String get errorInvalidAmount => 'مبلغ غير صالح.';

  @override
  String get errorNotEnoughCash => 'لا يوجد نقد كافٍ في الصندوق.';

  @override
  String get errorOverpayment => 'المبلغ يتجاوز المتبقي للدفع.';

  @override
  String get errorTenderedTooLow => 'المبلغ المدفوع أقل من المطلوب.';

  @override
  String get errorOrderHasPayments =>
      'لهذا الطلب مدفوعات: ألغها أو استردها أولًا.';

  @override
  String get errorPendingLines => 'بعض الأصناف لم تُرسل إلى المطبخ بعد.';

  @override
  String get errorNotFullyPaid => 'الطلب غير مدفوع بالكامل.';

  @override
  String get errorSessionNotCounted => 'لم يُعدّ هذا الصندوق بعد.';

  @override
  String get navKitchen => 'المطبخ';

  @override
  String get allStations => 'كل المحطات';

  @override
  String get stations => 'محطات التحضير';

  @override
  String get newStation => 'محطة جديدة';

  @override
  String get stationExamples => 'مثال: المطبخ، البار، المشويات';

  @override
  String get stationPrepares => 'تحضّر هذه المحطة:';

  @override
  String get kitchenEmpty => 'لا شيء للتحضير حاليًا.';

  @override
  String get allReady => 'كل شيء جاهز';

  @override
  String get markServed => 'قُدِّم';

  @override
  String get errorInvalidStatus => 'تغيير الحالة هذا غير ممكن.';

  @override
  String get navStock => 'المخزون';

  @override
  String get stockLevels => 'حالة المخزون';

  @override
  String get ingredientsTab => 'المكونات';

  @override
  String get recipesTab => 'البطاقات الفنية';

  @override
  String get inventoriesTab => 'الجرد';

  @override
  String get movementsTab => 'الحركات';

  @override
  String stockValue(String amount) {
    return 'قيمة المخزون: $amount';
  }

  @override
  String lowStockCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مكوّن تحت الحد',
      many: '$count مكوّنًا تحت الحد',
      few: '$count مكونات تحت الحد',
      two: 'مكوّنان تحت الحد',
      one: 'مكوّن واحد تحت الحد',
    );
    return '$_temp0';
  }

  @override
  String actionsAt(String location) {
    return 'الحركات في: $location';
  }

  @override
  String get newLocation => 'مكان تخزين جديد';

  @override
  String get locationExamples => 'مثال: غرفة التبريد، القبو، المطبخ';

  @override
  String get chooseLocation => 'اختيار مكان التخزين';

  @override
  String get toLocation => 'إلى مكان التخزين';

  @override
  String get noIngredientsYet => 'لا توجد مكونات بعد: أضفها في تبويب المكونات.';

  @override
  String alertAt(String qty) {
    return 'تنبيه عند $qty';
  }

  @override
  String avgCost(String amount, String unit) {
    return 'متوسط التكلفة $amount / $unit';
  }

  @override
  String get alertThreshold => 'حد التنبيه';

  @override
  String get alertBelow => 'التنبيه تحت';

  @override
  String get produce => 'إنتاج';

  @override
  String get adjustmentQuantity => 'تصحيح (+ أو −)';

  @override
  String unitCost(String unit) {
    return 'التكلفة لكل $unit';
  }

  @override
  String get unitPiece => 'قطعة';

  @override
  String get unitDozen => 'دزينة';

  @override
  String get newIngredient => 'مكوّن جديد';

  @override
  String get ingredientExamples => 'مثال: دجاج، زيت النخيل، زجاجة كولا 33 سل';

  @override
  String get ingredientKind => 'النوع';

  @override
  String get stockUnit => 'وحدة التخزين';

  @override
  String get ingRaw => 'مادة أولية';

  @override
  String get ingBeverage => 'مشروب';

  @override
  String get ingPackaging => 'تغليف';

  @override
  String get ingSemiFinished => 'تحضير منزلي';

  @override
  String get ingConsumable => 'مستهلكات';

  @override
  String get mvOpening => 'المخزون الافتتاحي';

  @override
  String get mvReceipt => 'إدخال (شراء)';

  @override
  String get mvSale => 'بيع';

  @override
  String get mvProductionIn => 'إنتاج';

  @override
  String get mvProductionOut => 'مستخدم في الإنتاج';

  @override
  String get mvWaste => 'فاقد / كسر';

  @override
  String get mvStaffMeal => 'وجبة الموظفين';

  @override
  String get mvReturn => 'إرجاع للمورد';

  @override
  String get mvTransferIn => 'تحويل مستلم';

  @override
  String get mvTransferOut => 'تحويل';

  @override
  String get mvAdjustment => 'تسوية';

  @override
  String get mvInventory => 'فرق الجرد';

  @override
  String get recipesIntro =>
      'تحدد البطاقة الفنية مكونات الطبق: ينخفض المخزون تلقائيًا مع كل بيع مدفوع وتُحسب التكلفة.';

  @override
  String get noRecipe => 'بلا بطاقة';

  @override
  String costPrice(String amount) {
    return 'التكلفة: $amount';
  }

  @override
  String sellingPrice(String amount) {
    return 'السعر $amount';
  }

  @override
  String marginPercent(int percent) {
    return 'الهامش $percent %';
  }

  @override
  String recipeOf(String name) {
    return 'البطاقة: $name';
  }

  @override
  String get portions => 'عدد الحصص';

  @override
  String get yieldQuantity => 'الكمية الناتجة';

  @override
  String get ingredient => 'المكوّن';

  @override
  String get wastePercent => 'الفاقد';

  @override
  String get removeLine => 'إزالة السطر';

  @override
  String get addIngredientLine => 'إضافة مكوّن';

  @override
  String get preparationNotes => 'ملاحظات التحضير (اختياري)';

  @override
  String get newInventory => 'جرد جديد';

  @override
  String get inventoriesIntro =>
      'يقارن الجرد المخزون المعدود بالمخزون المحسوب؛ وتُسجل الفروقات بعد اعتماد مسؤول.';

  @override
  String inventoryValidated(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'معتمد، $count فرق',
      many: 'معتمد، $count فرقًا',
      few: 'معتمد، $count فروق',
      two: 'معتمد، فرقان',
      one: 'معتمد، فرق واحد',
      zero: 'معتمد، بلا فروق',
    );
    return '$_temp0';
  }

  @override
  String inventoryDraft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'جارٍ، $count سطر معدود',
      many: 'جارٍ، $count سطرًا معدودًا',
      few: 'جارٍ، $count أسطر معدودة',
      two: 'جارٍ، سطران معدودان',
      one: 'جارٍ، سطر واحد معدود',
      zero: 'جارٍ، لم يُعدّ شيء',
    );
    return '$_temp0';
  }

  @override
  String inventoryOf(String location) {
    return 'الجرد: $location';
  }

  @override
  String get inventoryHint => 'أدخل ما تعدّه فعليًا. الأسطر الفارغة لا تتغير.';

  @override
  String inventoryDifference(String qty) {
    return 'الفرق $qty';
  }

  @override
  String get search => 'بحث';

  @override
  String get validateInventory => 'اعتماد الجرد';

  @override
  String get validateInventoryConfirm =>
      'اعتماد هذا الجرد؟ ستُسجل الفروقات في المخزون ولن يمكن تعديل الجرد بعد ذلك.';

  @override
  String inventoryAdjustments(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'اعتُمد الجرد: سُجل $count فرق',
      many: 'اعتُمد الجرد: سُجل $count فرقًا',
      few: 'اعتُمد الجرد: سُجلت $count فروق',
      two: 'اعتُمد الجرد: سُجل فرقان',
      one: 'اعتُمد الجرد: سُجل فرق واحد',
      zero: 'اعتُمد الجرد: بلا فروق',
    );
    return '$_temp0';
  }

  @override
  String get errorInvalidMovement => 'حركة مخزون غير صالحة.';

  @override
  String get errorUnitLocked =>
      'لم يعد بالإمكان تغيير وحدة التخزين: لهذا المكوّن حركات بالفعل.';

  @override
  String get errorNoRecipe => 'ليس لهذا التحضير بطاقة فنية.';

  @override
  String get errorInvalidRecipe =>
      'بطاقة فنية غير صالحة: تحقق من المكونات والكميات والوحدات.';

  @override
  String get errorInventoryClosed => 'هذا الجرد معتمد بالفعل.';

  @override
  String get navGroupService => 'الخدمة';

  @override
  String get navGroupManagement => 'الإدارة';

  @override
  String get navGroupOrganization => 'المؤسسة';

  @override
  String get navPurchases => 'المشتريات';

  @override
  String get navExpenses => 'المصروفات';

  @override
  String get navReports => 'التقارير';

  @override
  String get invoicesTab => 'الفواتير';

  @override
  String get purchaseOrdersTab => 'أوامر الشراء';

  @override
  String get receiptsTab => 'الاستلامات';

  @override
  String get suppliersTab => 'الموردون';

  @override
  String get newSupplier => 'مورد جديد';

  @override
  String get noSuppliersYet =>
      'لا يوجد موردون بعد. أضف مورديك المعتادين (السوق، تاجر الجملة، مصنع المشروبات…).';

  @override
  String get addSupplierFirst => 'أضف موردًا أولًا (تبويب الموردين).';

  @override
  String get contactName => 'الشخص المسؤول';

  @override
  String get taxId => 'الرقم الضريبي';

  @override
  String get paymentTermsLabel => 'مهلة الدفع';

  @override
  String get days => 'أيام';

  @override
  String paymentTerms(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'الدفع خلال $days يوم',
      many: 'الدفع خلال $days يومًا',
      few: 'الدفع خلال $days أيام',
      two: 'الدفع خلال يومين',
      one: 'الدفع خلال يوم واحد',
    );
    return '$_temp0';
  }

  @override
  String get supplier => 'المورد';

  @override
  String get supplierOptional => 'المورد (اختياري)';

  @override
  String get newPurchaseOrder => 'أمر شراء جديد';

  @override
  String get noPurchaseOrders =>
      'لا توجد أوامر شراء. يجهّز أمر الشراء عملية الشراء؛ وعند التسليم يُدخل «استلام» البضاعة إلى المخزون.';

  @override
  String poNumber(int number) {
    return 'أمر الشراء رقم $number';
  }

  @override
  String get poDraft => 'مسودة';

  @override
  String get poSent => 'مُرسل';

  @override
  String get poPartial => 'مستلم جزئيًا';

  @override
  String get poReceived => 'مستلم';

  @override
  String get poCancelled => 'ملغى';

  @override
  String get poMarkSent => 'تحديد كمُرسل';

  @override
  String get poReceive => 'استلام';

  @override
  String get poCancel => 'إلغاء الأمر';

  @override
  String get cancelPoConfirm => 'إلغاء أمر الشراء هذا؟';

  @override
  String expectedOn(String date) {
    return 'التسليم المتوقع في $date';
  }

  @override
  String get expectedDateOptional => 'تاريخ التسليم المتوقع (اختياري)';

  @override
  String unitPrice(String unit) {
    return 'السعر لكل $unit';
  }

  @override
  String totalAmount(String amount) {
    return 'الإجمالي: $amount';
  }

  @override
  String get newReceipt => 'استلام جديد';

  @override
  String get receiptsIntro =>
      'يسجّل الاستلام البضاعة المسلّمة: يُحدَّث المخزون ومتوسط التكلفة تلقائيًا.';

  @override
  String receiveOrder(int number) {
    return 'استلام أمر الشراء رقم $number';
  }

  @override
  String get receiptHint =>
      'أدخل الكميات المسلّمة فعليًا وأسعارها؛ تدخل المخزون عند الحفظ.';

  @override
  String get deliveryNoteNumber => 'رقم سند التسليم (اختياري)';

  @override
  String get recordReceipt => 'تسجيل الاستلام';

  @override
  String get receiptRecorded => 'سُجل الاستلام: المخزون محدّث.';

  @override
  String get newInvoice => 'فاتورة جديدة';

  @override
  String get invoicesIntro =>
      'سجّل هنا فواتير مورديك لمتابعة ما تدين به لهم ومدفوعاتك.';

  @override
  String supplierDebt(String amount) {
    return 'إجمالي المستحق للموردين: $amount';
  }

  @override
  String dueOn(String date) {
    return 'يستحق في $date';
  }

  @override
  String remaining(String amount) {
    return 'المتبقي $amount';
  }

  @override
  String get invoicePaid => 'مدفوعة';

  @override
  String get invoiceCancelled => 'ملغاة';

  @override
  String get invoiceNumber => 'رقم فاتورة المورد';

  @override
  String invoiceDateValue(String date) {
    return 'فاتورة بتاريخ $date';
  }

  @override
  String get dueDateOptional => 'تاريخ الاستحقاق (اختياري: مهلة المورد)';

  @override
  String get amountExclTax => 'المبلغ دون ضريبة';

  @override
  String get taxAmount => 'الضريبة';

  @override
  String get linkedReceipts => 'الاستلامات المرتبطة';

  @override
  String get attachDocument => 'إرفاق مستند (PDF أو صورة)';

  @override
  String get fileTooLarge => 'الملف كبير جدًا (5 ميغابايت كحد أقصى).';

  @override
  String get viewDocument => 'عرض المستند';

  @override
  String get payInvoice => 'دفع';

  @override
  String get cancelInvoice => 'إلغاء الفاتورة';

  @override
  String get paidFromRegister => 'مدفوع من نقد الصندوق';

  @override
  String get newExpense => 'مصروف جديد';

  @override
  String get noExpenses => 'لا مصروفات هذا الشهر.';

  @override
  String get previousMonth => 'الشهر السابق';

  @override
  String get nextMonth => 'الشهر التالي';

  @override
  String includingTax(String amount) {
    return 'منها ضريبة $amount';
  }

  @override
  String get cancelledLabel => 'ملغى';

  @override
  String get cancelExpense => 'إلغاء المصروف';

  @override
  String get expenseExamples => 'مثال: فاتورة كهرباء أكتوبر، إصلاح المجمّد';

  @override
  String get amountInclTax => 'المبلغ المدفوع';

  @override
  String get includedTaxOptional => 'منها ضريبة (اختياري)';

  @override
  String get expRent => 'الإيجار';

  @override
  String get expElectricity => 'الكهرباء';

  @override
  String get expWater => 'المياه';

  @override
  String get expGas => 'الغاز';

  @override
  String get expSalaries => 'الرواتب';

  @override
  String get expTransport => 'النقل';

  @override
  String get expMaintenance => 'الصيانة والإصلاحات';

  @override
  String get expMarketing => 'الإعلان';

  @override
  String get expSupplies => 'اللوازم';

  @override
  String get expTaxes => 'الضرائب والرسوم';

  @override
  String get expBankFees => 'الرسوم المصرفية';

  @override
  String get expOther => 'أخرى';

  @override
  String get periodToday => 'اليوم';

  @override
  String get periodLast7 => 'آخر 7 أيام';

  @override
  String get periodMonth => 'هذا الشهر';

  @override
  String get periodLastMonth => 'الشهر الماضي';

  @override
  String get periodCustom => 'فترة أخرى…';

  @override
  String get salesInclTax => 'المبيعات شاملة الضريبة';

  @override
  String get salesExclTax => 'المبيعات دون ضريبة';

  @override
  String get collected => 'التحصيلات';

  @override
  String get costOfSales => 'تكلفة المبيعات';

  @override
  String get grossMargin => 'الهامش الإجمالي';

  @override
  String get lossesValue => 'الخسائر والفروقات';

  @override
  String get expensesExclTax => 'المصروفات دون ضريبة';

  @override
  String get estimatedResult => 'النتيجة التقديرية';

  @override
  String get purchasesValue => 'المشتريات (فواتير دون ضريبة)';

  @override
  String get supplierDebtShort => 'المستحق للموردين';

  @override
  String ordersCountShort(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count طلب',
      many: '$count طلبًا',
      few: '$count طلبات',
      two: 'طلبان',
      one: 'طلب واحد',
      zero: 'لا طلبات',
    );
    return '$_temp0';
  }

  @override
  String get ruleSales =>
      'مجموع الطلبات المدفوعة والمغلقة خلال الفترة (تاريخ الخدمة).';

  @override
  String get ruleSalesHt => 'المبيعات شاملة الضريبة ناقص الضريبة المحصلة.';

  @override
  String get ruleCollected =>
      'المال المحصل فعليًا خلال الفترة بكل الوسائل ناقص المبالغ المستردة. قد يختلف عن المبيعات (عربون، طلبات ما زالت مفتوحة).';

  @override
  String get ruleCogs =>
      'قيمة المكونات المستهلكة في المبيعات وفق البطاقات الفنية ومتوسط تكلفة الشراء. لا تُحتسب الأطباق بلا بطاقة.';

  @override
  String get ruleGrossMargin => 'المبيعات دون ضريبة ناقص تكلفة المبيعات.';

  @override
  String get ruleLosses =>
      'قيمة الفاقد ووجبات الموظفين والتسويات وفروقات الجرد.';

  @override
  String get ruleExpenses =>
      'المصروفات المسجلة خلال الفترة دون ضريبة (تُستثنى الملغاة).';

  @override
  String get ruleResult =>
      'الهامش الإجمالي ناقص الخسائر والمصروفات. تقدير إداري دون الاستهلاكات أو التكاليف غير المسجلة: ليس نتيجة محاسبية.';

  @override
  String get rulePurchases =>
      'فواتير الموردين (دون ضريبة) المؤرخة في الفترة. تدخل المشتريات المخزون: لا تُعد تكلفة حتى تُستهلك.';

  @override
  String get ruleDebt =>
      'المبالغ المتبقية على فواتير الموردين المفتوحة حتى اليوم.';

  @override
  String get expensesByCategory => 'المصروفات حسب الفئة (دون ضريبة)';

  @override
  String get resultDisclaimer =>
      'تُحسب هذه الأرقام من العمليات المسجلة في Resto: المبيعات والتحصيلات والاستهلاك النظري والمصروفات. مرّر المؤشر على ⓘ لمعرفة قاعدة كل مؤشر.';

  @override
  String get exportsTitle => 'التصدير (ملفات CSV تُفتح في Excel)';

  @override
  String get exportOrders => 'الطلبات';

  @override
  String get exportPayments => 'المدفوعات';

  @override
  String get exportExpenses => 'المصروفات';

  @override
  String get exportDownloaded => 'تم تنزيل الملف.';

  @override
  String get exportCopied => 'نُسخت البيانات: الصقها في جدول بيانات.';

  @override
  String get marginsByItem => 'الهامش لكل طبق';

  @override
  String marginsHint(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count طبق بلا بطاقة فنية بعد (المخزون ← البطاقات الفنية).',
      many: '$count طبقًا بلا بطاقة فنية بعد (المخزون ← البطاقات الفنية).',
      few: '$count أطباق بلا بطاقة فنية بعد (المخزون ← البطاقات الفنية).',
      two: 'طبقان بلا بطاقة فنية بعد (المخزون ← البطاقات الفنية).',
      one: 'طبق واحد بلا بطاقة فنية بعد (المخزون ← البطاقات الفنية).',
      zero: 'كل الأطباق المبيعة لها بطاقة فنية.',
    );
    return '$_temp0';
  }

  @override
  String get errorInvalidPurchase =>
      'شراء غير مكتمل: تحقق من المورد والمكونات والكميات والوحدات والأسعار.';

  @override
  String get errorPurchaseNotDraft => 'لم يعد بالإمكان تعديل أمر الشراء هذا.';

  @override
  String get errorDuplicateInvoice => 'فاتورة هذا المورد مسجلة بالفعل.';

  @override
  String get errorInvoiceNotOpen => 'هذه الفاتورة لم تعد مفتوحة.';

  @override
  String get errorInvoiceHasPayments => 'لهذه الفاتورة مدفوعات: ألغها أولًا.';

  @override
  String get errorInvalidExpense =>
      'مصروف غير مكتمل: الفئة والوصف والمبلغ إلزامية؛ ولا يمكن أن تتجاوز الضريبة المبلغ.';

  @override
  String get errorInvalidAttachment => 'المستند مرفوض.';

  @override
  String get errorInvalidPeriod => 'فترة غير صالحة.';

  @override
  String get errorBelowMinimum => 'لم يتم بلوغ الحد الأدنى لمبلغ الطلب.';

  @override
  String get errorDeliveryUnavailable =>
      'التوصيل غير ممكن: تحقّق من العنوان والهاتف، أو اختر «سفري».';

  @override
  String get errorInvalidImage => 'تم رفض الصورة (صيغة أو موقع غير صالح).';

  @override
  String get errorNotFound => 'غير موجود.';

  @override
  String get errorOnlineOrdersClosed =>
      'هذا المطعم لا يستقبل الطلبات عبر الإنترنت حاليًا.';

  @override
  String get errorTooLateToCancel => 'فات الأوان: بدأ المطعم في تحضير الطلب.';

  @override
  String get errorReviewNotAllowed =>
      'لا يمكن التقييم: يُقيَّم الطلب المدفوع خلال 30 يومًا مرة واحدة فقط.';

  @override
  String get errorReservationsClosed =>
      'هذا المطعم لا يقبل الحجوزات عبر الإنترنت.';

  @override
  String get errorInvalidPartySize =>
      'عدد الأشخاص غير مقبول للحجز عبر الإنترنت.';

  @override
  String get errorInvalidReservationTime =>
      'وقت غير صالح: قبل 15 دقيقة على الأقل وخلال 90 يومًا على الأكثر.';

  @override
  String get errorInvalidReservation =>
      'حجز غير مكتمل: الاسم والهاتف وعدد الأشخاص مطلوبة.';

  @override
  String get errorTablesRequired => 'اختر طاولة واحدة على الأقل.';

  @override
  String get errorNotEnoughSeats => 'المقاعد غير كافية على الطاولات المختارة.';

  @override
  String get errorTableUnavailable => 'هذه الطاولة محجوزة بالفعل في هذا الوقت.';

  @override
  String get errorPromotionUnavailable => 'العرض أو الرمز غير صالح.';

  @override
  String get errorPromotionLimit =>
      'استخدم هذا الزبون العرض بالعدد المسموح به.';

  @override
  String get errorPromotionAlreadyApplied => 'مطبَّق بالفعل على هذا الطلب.';

  @override
  String get errorNotEnoughPoints => 'نقاط الولاء غير كافية.';

  @override
  String get errorAddressRequired => 'عنوان التوصيل مطلوب.';

  @override
  String get errorTableBusy => 'هذه الطاولة لديها طلب قيد التنفيذ.';

  @override
  String errorBetween(int min, int max) {
    return 'بين $min و$max';
  }

  @override
  String get notPublishedHint =>
      'هذا الفرع غير ظاهر للزبائن بعد: فعّل «منشور» في تبويب المعلومات.';

  @override
  String get onlineOrdersTitle => 'الطلبات عبر الإنترنت';

  @override
  String get acceptOnlineOrders => 'قبول طلبات الزبائن';

  @override
  String get acceptOnlineOrdersHint =>
      'من التطبيق أو الموقع أو رموز QR على الطاولات. يصل كل طلب إلى «الطلبات» لقبوله.';

  @override
  String get acceptDelivery => 'تقديم خدمة التوصيل';

  @override
  String get deliveryFee => 'رسوم التوصيل';

  @override
  String get minimumOrder => 'الحد الأدنى للطلب';

  @override
  String get reservationsTitle => 'الحجوزات';

  @override
  String get acceptReservations => 'قبول الحجوزات عبر الإنترنت';

  @override
  String get reservationDuration => 'مدة الحجز';

  @override
  String get minutesShort => 'د';

  @override
  String get maxPartySize => 'الحد الأقصى للأشخاص';

  @override
  String get publicProfileTitle => 'الصفحة العامة للمطعم';

  @override
  String get publicDescription => 'التعريف';

  @override
  String get publicDescriptionHint =>
      'مثال: مطبخ كاميروني سخي، سمك مشوي طازج يوميًا، شرفة مظللة.';

  @override
  String get cuisinesLabel => 'أنواع المطبخ';

  @override
  String get cuisinesHint => 'مثال: أفريقي، مشاوي، مأكولات بحرية (افصل بفواصل)';

  @override
  String get priceLevel => 'فئة الأسعار';

  @override
  String get publicPageTitle => 'صفحة المطعم';

  @override
  String get publicPageHint =>
      'للمشاركة (الشبكات الاجتماعية، واتساب) أو الطباعة: يرى الزبائن القائمة ويطلبون منها.';

  @override
  String get copyLink => 'نسخ الرابط';

  @override
  String get sourcePhone => 'عبر الهاتف';

  @override
  String get sourceQr => 'رمز QR للطاولة';

  @override
  String get sourceApp => 'تطبيق الزبون';

  @override
  String get sourcePartner => 'شريك';

  @override
  String get sourceStaff => 'مأخوذ في الصالة';

  @override
  String get stageToValidate => 'بانتظار التأكيد';

  @override
  String get stageDraft => 'لم يُرسل بعد';

  @override
  String get stageCooking => 'قيد التحضير';

  @override
  String get stageReady => 'جاهز للتقديم';

  @override
  String get stageReadyTakeaway => 'جاهز للتسليم';

  @override
  String get stageReadyDelivery => 'جاهز لعامل التوصيل';

  @override
  String get stageToPay => 'بانتظار الدفع';

  @override
  String get stageDone => 'منتهٍ';

  @override
  String get stageCancelled => 'ملغى';

  @override
  String get handToCustomer => 'سُلّم للزبون';

  @override
  String get handToCourier => 'سُلّم لعامل التوصيل';

  @override
  String guestsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count شخصًا',
      few: '$count أشخاص',
      two: 'شخصان',
      one: 'شخص واحد',
    );
    return '$_temp0';
  }

  @override
  String forTime(String time) {
    return 'للساعة $time';
  }

  @override
  String get billTitle => 'الفاتورة';

  @override
  String get thankYou => 'شكرًا لزيارتكم!';

  @override
  String kdsToPrepare(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count طلبًا للتحضير',
      few: '$count طلبات للتحضير',
      two: 'طلبان للتحضير',
      one: 'طلب واحد للتحضير',
      zero: 'لا شيء للتحضير',
    );
    return '$_temp0';
  }

  @override
  String kdsLate(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count متأخرة',
      one: 'واحد متأخر',
    );
    return '$_temp0';
  }

  @override
  String kdsReadyCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count جاهزة',
      one: 'واحد جاهز',
      zero: 'لا شيء جاهز',
    );
    return '$_temp0';
  }

  @override
  String get kdsTickets => 'التذاكر';

  @override
  String get kdsSummary => 'المجموع';

  @override
  String get kdsFullScreen => 'ملء الشاشة (وضع المطبخ)';

  @override
  String get kdsFlowHint =>
      'تصل الطلبات المرسلة من الصالة إلى هنا مع تنبيه صوتي. المس صنفًا لتحويله إلى «قيد التحضير» ثم «جاهز». «كل شيء جاهز» ينبّه النُّدُل فورًا.';

  @override
  String get kdsReadyStrip =>
      'جاهزة — تم تنبيه الصالة (عمود «جاهز للتقديم»)، بانتظار التقديم';

  @override
  String get kdsStart => 'ابدأ';

  @override
  String kdsWaitingService(String time) {
    return 'ينتظر منذ $time';
  }

  @override
  String get kdsRecall => 'استرجاع (غير جاهز بعد)';

  @override
  String get serviceAndCustomers => 'الخدمة والزبائن';

  @override
  String get serviceSettingsTitle => 'الخدمة';

  @override
  String get targetPrepTime => 'وقت التحضير المستهدف';

  @override
  String get targetPrepTimeHint => 'بعده يصبح الطلب أحمر (متأخرًا).';

  @override
  String get payFirstTakeaway => 'السفري: الدفع قبل التحضير';

  @override
  String get payFirstTakeawayHint =>
      'يظهر زر «الدفع ثم الإرسال» على طلبات السفري.';

  @override
  String get tableOccupied => 'مشغولة';

  @override
  String get tableReservedNow => 'محجوزة الآن';

  @override
  String get tableReservedSoon => 'محجوزة قريبًا';

  @override
  String reservedAt(String time) {
    return 'محجوزة الساعة $time';
  }

  @override
  String get acceptWithDelay => 'قبول الطلب';

  @override
  String scheduledFor(String time) {
    return 'مطلوب للساعة $time';
  }

  @override
  String get delayAnnounced => 'متى سيكون جاهزًا؟ سيُبلَّغ الزبون.';

  @override
  String get orderAccepted => 'تم قبول الطلب: انتقل إلى التحضير.';

  @override
  String get rejectOrder => 'رفض الطلب';

  @override
  String get rejectReasonHint => 'مثال: نفاد السمك، لا يوجد عامل توصيل';

  @override
  String get paymentDone => 'تم تسجيل الدفع.';

  @override
  String get partialPaymentDone => 'تم تسجيل دفع جزئي.';

  @override
  String get announcedDelay => 'المدة المعلنة للزبون';

  @override
  String promisedFor(String time) {
    return 'موعود للساعة $time';
  }

  @override
  String get heldShort => 'لاحقًا';

  @override
  String moreItems(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '+ $count أصناف أخرى',
      one: '+ صنف آخر',
    );
    return '$_temp0';
  }

  @override
  String get paidShort => 'مدفوع';

  @override
  String get partlyPaid => 'مدفوع جزئيًا';

  @override
  String get notPaid => 'غير مدفوع';

  @override
  String get reject => 'رفض';

  @override
  String get accept => 'قبول';

  @override
  String get sendShort => 'إرسال';

  @override
  String get fireNext => 'إطلاق التالي';

  @override
  String get collectShort => 'تحصيل';

  @override
  String get columnInProgress => 'قيد التنفيذ';

  @override
  String get columnReady => 'جاهزة للتقديم';

  @override
  String get columnToValidateHint =>
      'تصل طلبات الزبائن (التطبيق، الموقع، رموز QR على الطاولات) إلى هنا مع تنبيه صوتي. اقبلها مع إعلان مدة.';

  @override
  String get columnInProgressHint =>
      'طلبات مأخوذة وقيد التحضير. «إرسال» يرسل الأصناف إلى المطبخ والبار.';

  @override
  String get columnReadyHint =>
      'عندما يضغط المطبخ «كل شيء جاهز» يصل الطلب إلى هنا (مع تنبيه): للتقديم على الطاولة أو التسليم للزبون أو لعامل التوصيل.';

  @override
  String get columnToPayHint =>
      'تم تقديم كل شيء: يبقى التحصيل. بعد الدفع ينتهي الطلب وتتحرر الطاولة.';

  @override
  String get allOrders => 'الكل';

  @override
  String get searchOrderHint => 'الرقم، الزبون، الطاولة، الهاتف';

  @override
  String get chooseTable => 'اختر الطاولة';

  @override
  String get tableHasOrder => 'لهذه الطاولة طلب قيد التنفيذ: سيُفتح.';

  @override
  String tableReservationWarning(String time, String name, int count) {
    return 'تنبيه: محجوزة الساعة $time · $name · $count أشخاص';
  }

  @override
  String get guestsLabel => 'عدد الأشخاص';

  @override
  String get receivedByPhone => 'طلب مستلم عبر الهاتف';

  @override
  String get customerName => 'اسم الزبون';

  @override
  String get customerNameOptional => 'اسم الزبون (اختياري)';

  @override
  String get phoneOptional => 'الهاتف (اختياري)';

  @override
  String get deliveryAddress => 'عنوان التوصيل';

  @override
  String get deliveryAddressHint =>
      'الحي، الشارع، معلم (مثال: بوناموسادي، قرب الصيدلية)';

  @override
  String get deliveryInstructions => 'إرشادات لعامل التوصيل';

  @override
  String get deliveryInstructionsHint =>
      'مثال: المبنى الأصفر، الطابق الثاني، اتصل عند الوصول';

  @override
  String get deliveryTime => 'وقت التوصيل';

  @override
  String get pickupTime => 'وقت الاستلام';

  @override
  String get asap => 'في أقرب وقت';

  @override
  String get atFixedTime => 'في وقت محدد';

  @override
  String atTime(String time) {
    return 'الساعة $time';
  }

  @override
  String get newOrder => 'طلب جديد';

  @override
  String get orderTypeQuestion => 'ما نوع الطلب؟';

  @override
  String get dineInHint => 'الزبون جالس إلى طاولة';

  @override
  String get takeawayHint => 'يأخذ الزبون طلبه معه';

  @override
  String get deliveryHint => 'يُوصَّل إلى عنوان';

  @override
  String get orderNote => 'ملاحظة على الطلب (اختياري)';

  @override
  String get orderNoteHint =>
      'مثال: عيد ميلاد، زبون مستعجل، حساسية من الفول السوداني';

  @override
  String get continueToMenu => 'متابعة: اختيار الأطباق';

  @override
  String get moveTable => 'تغيير الطاولة';

  @override
  String get noFreeTable => 'لا توجد طاولة شاغرة حاليًا.';

  @override
  String get print => 'طباعة';

  @override
  String get printKitchenTicket => 'قسيمة التحضير (المطبخ)';

  @override
  String get printBill => 'الفاتورة (الزبون)';

  @override
  String get orderHistory => 'سجل الطلب';

  @override
  String get searchDish => 'ابحث عن طبق أو مشروب…';

  @override
  String get noResults => 'لا توجد نتائج.';

  @override
  String get groupToSend => 'للإرسال';

  @override
  String get groupHeld => 'لاحقًا (تُرسل فيما بعد)';

  @override
  String get groupCooking => 'قيد التحضير';

  @override
  String get groupReady => 'جاهزة للتقديم';

  @override
  String get groupServed => 'تم التقديم';

  @override
  String get groupCancelled => 'ملغاة';

  @override
  String collectThenSend(String amount) {
    return 'تحصيل $amount ثم الإرسال';
  }

  @override
  String fireNextCount(int count) {
    return 'إطلاق التالي ($count)';
  }

  @override
  String get customerOrderToValidate => 'طلب زبون بانتظار التأكيد';

  @override
  String get customerOrderToValidateHint =>
      'تحقّق من الأصناف ثم اقبل (مع مدة) أو ارفض. سيُبلَّغ الزبون.';

  @override
  String get payFirstHint => 'السفري: الدفع قبل التحضير (إعداد الفرع).';

  @override
  String get addedByCustomer => 'أضافه الزبون';

  @override
  String get sendWithOrder => 'إرسال مع الباقي';

  @override
  String get holdForLater => 'تأجيل (يُرسل لاحقًا)';

  @override
  String openedAt(String time) {
    return 'فُتح الساعة $time';
  }

  @override
  String get fromReservation => 'تم إجلاس الزبائن (حجز)';

  @override
  String get editOrderDetails => 'تعديل المعلومات';

  @override
  String get evOpened => 'فُتح الطلب';

  @override
  String evItemAdded(String item) {
    return 'إضافة: $item';
  }

  @override
  String get evItemUpdated => 'تم تعديل صنف';

  @override
  String get evItemRemoved => 'تمت إزالة صنف';

  @override
  String evSent(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'أُرسل إلى المطبخ ($count أصناف)',
      one: 'أُرسل إلى المطبخ (صنف واحد)',
    );
    return '$_temp0';
  }

  @override
  String get evItemCancelled => 'تم إلغاء صنف';

  @override
  String get evCancelled => 'تم إلغاء الطلب';

  @override
  String get evClosed => 'انتهى الطلب';

  @override
  String evPayment(String amount) {
    return 'دفع $amount';
  }

  @override
  String get evRefund => 'استرداد';

  @override
  String get evDetailsUpdated => 'تم تعديل المعلومات';

  @override
  String get itemsTotal => 'الأصناف';

  @override
  String get removeDiscount => 'إزالة الخصم';

  @override
  String get addDiscount => 'إضافة خصم';

  @override
  String get applyPromotion => 'تطبيق عرض';

  @override
  String get promoCode => 'رمز ترويجي';

  @override
  String get promoCodeHint => 'مثال: WELCOME10';

  @override
  String get manualDiscount => 'خصم (مبادرة تجارية)';

  @override
  String get useLoyalty => 'استخدام نقاط الولاء';

  @override
  String get noActivePromotion =>
      'لا يوجد عرض جارٍ. أنشئ عروضًا في «الزبائن والولاء».';

  @override
  String get inPercent => 'بالنسبة %';

  @override
  String get inAmount => 'بالمبلغ';

  @override
  String get percentValue => 'النسبة المئوية';

  @override
  String get manualDiscountHint => 'مثال: انتظار طويل، زبون وفيّ';

  @override
  String get apply => 'تطبيق';

  @override
  String get allAreas => 'كل المناطق';

  @override
  String get planView => 'المخطط';

  @override
  String get cardsView => 'البطاقات';

  @override
  String get editFloor => 'تعديل الصالة';

  @override
  String get done => 'تم';

  @override
  String get floorEmptyTitle => 'أنشئ صالتك';

  @override
  String get floorEmptyHint =>
      'أضف أولًا المناطق (الصالة، الشرفة، VIP…) ثم الطاولات بالاسم الذي تريده (طاولة 1، VIP 1، بار 2…). سترى بعدها مباشرة الطاولات الشاغرة والمشغولة والمحجوزة.';

  @override
  String get editFloorHint =>
      'اسحب الطاولات لتطابق صالتك. المس طاولة لتغيير اسمها أو مقاعدها أو شكلها.';

  @override
  String get noTablesInArea =>
      'لا توجد طاولات في هذه المنطقة: «تعديل الصالة» ثم «طاولة جديدة».';

  @override
  String get newOrderAtTable => 'طلب جديد على هذه الطاولة';

  @override
  String get openOrder => 'فتح الطلب';

  @override
  String get reservationsToday => 'حجوزات اليوم';

  @override
  String get reserveTable => 'حجز';

  @override
  String get noReservationToday => 'لا يوجد حجز اليوم لهذه الطاولة.';

  @override
  String get tableQrCode => 'رمز QR للطاولة';

  @override
  String get tableQrHint =>
      'اطبعه وضعه على الطاولة: يمسحه الزبون ويرى القائمة بالصور ويطلب. يصل الطلب إلى «بانتظار التأكيد».';

  @override
  String get areaNameHint => 'مثال: الصالة، الشرفة، VIP، الطابق العلوي';

  @override
  String get tableLabelHint => 'مثال: طاولة 1، VIP 1، بار 2';

  @override
  String get tableShape => 'الشكل';

  @override
  String get shapeSquare => 'مربعة';

  @override
  String get shapeRound => 'دائرية';

  @override
  String get shapeRect => 'مستطيلة';

  @override
  String get resRequested => 'مطلوب';

  @override
  String get resConfirmed => 'مؤكد';

  @override
  String get resSeated => 'تم الإجلاس';

  @override
  String get resCompleted => 'منتهٍ';

  @override
  String get resNoShow => 'لم يحضروا';

  @override
  String get resDeclined => 'مرفوض';

  @override
  String get resCancelled => 'ملغى';

  @override
  String reservationRequests(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count طلب حجز للمعالجة',
      few: '$count طلبات حجز للمعالجة',
      two: 'طلبا حجز للمعالجة',
      one: 'طلب حجز واحد للمعالجة',
    );
    return '$_temp0';
  }

  @override
  String get reservationRequestsHint =>
      'طلبات الزبائن عبر الإنترنت: أكّد باختيار الطاولات أو ارفض مع ذكر السبب. سيُبلَّغ الزبون.';

  @override
  String get declineReservation => 'رفض الحجز';

  @override
  String get confirmReservation => 'تأكيد';

  @override
  String reservationsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count حجزًا',
      few: '$count حجوزات',
      two: 'حجزان',
      one: 'حجز واحد',
      zero: 'لا توجد حجوزات',
    );
    return '$_temp0';
  }

  @override
  String coversCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مقعدًا',
      few: '$count مقاعد',
      two: 'مقعدان',
      one: 'مقعد واحد',
      zero: '0 مقعد',
    );
    return '$_temp0';
  }

  @override
  String get noReservationsDay => 'لا توجد حجوزات في ذلك اليوم.';

  @override
  String get today => 'اليوم';

  @override
  String get timelineView => 'الجدول الزمني';

  @override
  String get listView => 'القائمة';

  @override
  String get newReservation => 'حجز جديد';

  @override
  String get nowLabel => 'الآن';

  @override
  String get seatGuests => 'إجلاس الزبائن';

  @override
  String get changeTables => 'تغيير الطاولات';

  @override
  String get markNoShow => 'لم يحضروا';

  @override
  String get cancelReservation => 'إلغاء الحجز';

  @override
  String get markCompleted => 'منتهٍ';

  @override
  String get chooseTables => 'الطاولات';

  @override
  String seatsForParty(int seats, int party) {
    return '$seats مقاعد مختارة لـ $party أشخاص';
  }

  @override
  String get reservationNoteHint =>
      'مثال: عيد ميلاد، كرسي أطفال، بجانب النافذة';

  @override
  String get noFreeTableSlot =>
      'لا توجد طاولة شاغرة في هذا الوقت: غيّر الساعة أو المدة.';

  @override
  String itemsCountLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count صنفًا',
      few: '$count أصناف',
      two: 'صنفان',
      one: 'صنف واحد',
      zero: 'لا أصناف',
    );
    return '$_temp0';
  }

  @override
  String get alertNewCustomerOrder => 'طلب زبون جديد بانتظار التأكيد';

  @override
  String get alertOrderReady => 'طلب جاهز للتقديم';

  @override
  String get view => 'عرض';

  @override
  String ordersToValidateBanner(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count طلبًا بانتظار تأكيدك',
      few: '$count طلبات زبائن بانتظار تأكيدك',
      two: 'طلبا زبائن بانتظار تأكيدك',
      one: 'طلب زبون واحد بانتظار تأكيدك',
    );
    return '$_temp0';
  }

  @override
  String get tabInProgress => 'قيد التنفيذ';

  @override
  String get historyTab => 'السجل';

  @override
  String get newShort => 'جديد';

  @override
  String get brandPoint1 => 'طلبات في الصالة وسفري وتوصيل وعبر الإنترنت';

  @override
  String get brandPoint2 => 'المطبخ والبار مباشرة، الصالة والحجوزات';

  @override
  String get brandPoint3 => 'الصندوق والمخزون والمشتريات والمصاريف';

  @override
  String get brandPoint4 => 'لوحات قيادة وتقارير احترافية';

  @override
  String get authWelcome => 'مرحبًا';

  @override
  String get authWelcomeSub => 'سجّل الدخول للعودة إلى مطعمك';

  @override
  String get noAccountYet => 'ليس لديك حساب بعد؟';

  @override
  String get alreadyAccount => 'لديك حساب بالفعل؟';

  @override
  String get authSignUpSub => 'ثوانٍ قليلة للبدء، دون أي التزام';

  @override
  String get authForgotSub =>
      'استلم رمزًا عبر البريد الإلكتروني لاختيار كلمة مرور جديدة';

  @override
  String get authNewPasswordSub => '8 أحرف على الأقل';

  @override
  String get navHome => 'الرئيسية';

  @override
  String get greetingDay => 'مرحبًا';

  @override
  String get greetingEvening => 'مساء الخير';

  @override
  String get moreModules => 'المزيد';

  @override
  String freeTablesCount(int free, int total) {
    return '$free طاولات شاغرة من $total';
  }

  @override
  String suggestedTable(String label, int seats) {
    return 'اقتراح: $label ($seats مقاعد)';
  }

  @override
  String get slotFreeSoon => 'تتحرر في الوقت';

  @override
  String get slotReserved => 'محجوزة في هذا الوقت';

  @override
  String freeAround(String time) {
    return 'تتحرر نحو $time';
  }

  @override
  String get timelineEmptyHint =>
      'لا توجد حجوزات في ذلك اليوم. المس ساعة في سطر طاولة لحجزها.';

  @override
  String get myAccount => 'حسابي';

  @override
  String get brandTagline => 'إدارة المطاعم بسلاسة ووضوح.';

  @override
  String get addPaymentMethod => 'إضافة وسيلة';

  @override
  String get allMethods => 'كل الوسائل';

  @override
  String get availableInBranches => 'متاحة في';

  @override
  String get availableWorldwide => 'صالحة في كل مكان';

  @override
  String get blindCountHint =>
      'عُدّ الدرج دون النظر إلى المبلغ المتوقع: يظهر الفرق بعد تسجيل العدّ.';

  @override
  String get cashDrawer => 'درج الصندوق';

  @override
  String get cashMovementsTitle => 'إدخالات وإخراجات نقدية';

  @override
  String get cashReportTitle => 'تقرير الصندوق';

  @override
  String get cashierLabel => 'أمين الصندوق';

  @override
  String get choosePaymentMethod => 'اختر وسيلة الدفع.';

  @override
  String get closingValidated => 'تم اعتماد الإقفال: تقرير Z مرقّم.';

  @override
  String get closingsTab => 'الإقفالات';

  @override
  String get coinsLabel => 'قطع نقدية';

  @override
  String get collectTab => 'التحصيل';

  @override
  String collectWithTip(String amount, String tip) {
    return 'تحصيل $amount + $tip';
  }

  @override
  String get collectedByDay => 'المحصّل يوميًا';

  @override
  String get collectedByHour => 'المحصّل بالساعة';

  @override
  String get collectedTotal => 'المحصّل';

  @override
  String commonInCountry(String country) {
    return 'الشائعة في بلدك ($country)';
  }

  @override
  String get countByDenomination => 'ورقة بورقة';

  @override
  String countConfirm(String amount) {
    return 'تأكيد العدّ: $amount؟';
  }

  @override
  String get countDetailTitle => 'تفاصيل العدّ';

  @override
  String get countRecorded => 'تم تسجيل العدّ';

  @override
  String get countedLabel => 'معدودة';

  @override
  String get countedTotal => 'المجموع المعدود';

  @override
  String get customMethod => 'وسيلة مخصّصة';

  @override
  String get customMethodHint =>
      'مثال: قسيمة المطعم، بطاقة الولاء، الدفع عبر رابط';

  @override
  String get dateLabel => 'التاريخ';

  @override
  String get differenceLabel => 'الفرق';

  @override
  String get differenceReasonHint => 'مثال: خطأ في الباقي، ورقة تالفة';

  @override
  String get discountsTotal => 'الخصومات';

  @override
  String get displayOrder => 'الترتيب';

  @override
  String get enterAmount => 'إدخال المبلغ';

  @override
  String get errorPaymentMethodUnavailable => 'وسيلة الدفع هذه غير متاحة هنا.';

  @override
  String get errorReferenceRequired => 'أدخل رقم المعاملة (مرجع الدفع).';

  @override
  String get exactAmount => 'المبلغ بالضبط';

  @override
  String get exportExcel => 'تصدير (جدول بيانات)';

  @override
  String get exportPdf => 'تصدير بصيغة PDF';

  @override
  String get feePercentLabel => 'العمولة المقتطعة';

  @override
  String feeShort(String percent) {
    return 'عمولة $percent %';
  }

  @override
  String get feesEstimate => 'العمولات (تقديرية)';

  @override
  String get findTicket => 'البحث عن إيصال';

  @override
  String get lastPayments => 'آخر المدفوعات';

  @override
  String get legalNameLabel => 'الاسم التجاري';

  @override
  String get managerMustValidate => 'يجب أن يعتمد مسؤول الإقفال.';

  @override
  String get methodKind => 'النوع';

  @override
  String get mySessionTab => 'صندوقي';

  @override
  String get newRegister => 'صندوق جديد';

  @override
  String get noActiveRegister => 'لا يوجد صندوق نشط: أنشئ واحدًا في الإعدادات.';

  @override
  String get noClosings => 'لا توجد إقفالات بعد.';

  @override
  String get noMovements => 'لا توجد حركات.';

  @override
  String get noPaymentMethod =>
      'لا توجد وسيلة دفع نشطة: أضف وسائل في الإعدادات.';

  @override
  String get noPaymentsYet => 'لا توجد مدفوعات بعد.';

  @override
  String get noRefunds => 'لا توجد استردادات خلال آخر 30 يومًا.';

  @override
  String get noTip => 'بدون';

  @override
  String get notesLabel => 'أوراق نقدية';

  @override
  String get nothingToCollect => 'لا شيء للتحصيل حاليًا.';

  @override
  String get openRegisterHint =>
      'عُدّ رصيد الافتتاح (الفكّة الأولية): سيكون أساس العدّ في نهاية الوردية.';

  @override
  String openRegisterTitle(String register) {
    return 'فتح $register';
  }

  @override
  String get openedLabel => 'الفتح';

  @override
  String get orderDetails => 'تفاصيل الطلب';

  @override
  String get orderShort => 'الطلب';

  @override
  String get otherAmount => 'مبلغ آخر';

  @override
  String get otherCountries => 'بلدان أخرى';

  @override
  String get payKindAccount => 'حساب الزبون';

  @override
  String get payKindCheque => 'شيك';

  @override
  String get payKindInstant => 'دفع فوري';

  @override
  String get payKindVoucher => 'قسيمة';

  @override
  String get payKindWallet => 'محفظة إلكترونية';

  @override
  String get paymentComplete => 'اكتمل الدفع';

  @override
  String get paymentMethodLabel => 'وسيلة الدفع';

  @override
  String get paymentMethodsHint =>
      'الوسائل المعروضة عند التحصيل. كيّفها مع بلدك: الاسم، إلزامية رقم المعاملة، العمولة، الفروع.';

  @override
  String get paymentMethodsTitle => 'وسائل الدفع';

  @override
  String get paymentsCountShort => 'المدفوعات';

  @override
  String get periodYesterday => 'أمس';

  @override
  String get printCountReport => 'طباعة العدّ';

  @override
  String get printReceipt => 'طباعة الإيصال';

  @override
  String get reasonChangeFloat => 'إضافة فكّة';

  @override
  String get reasonOtherIn => 'إدخال آخر';

  @override
  String get reasonOtherOut => 'إخراج آخر';

  @override
  String get reasonSafeDrop => 'إيداع في الخزنة';

  @override
  String get reasonSmallPurchase => 'شراء صغير';

  @override
  String get reasonTipsPaid => 'بقشيش سُلّم للفريق';

  @override
  String get receiptFooterHint =>
      'مثال: شكرًا وإلى اللقاء! واي فاي: RestoGuest';

  @override
  String get receiptFooterLabel => 'رسالة أسفل الإيصال';

  @override
  String receiptNumberLabel(int number) {
    return 'إيصال رقم $number';
  }

  @override
  String get receiptSettingsHint => 'تُطبع على كل إيصال للزبون وعلى تقارير Z.';

  @override
  String get receiptSettingsTitle => 'بيانات الإيصال';

  @override
  String get receiptShort => 'إيصال';

  @override
  String receiptTaxId(String id) {
    return 'الرقم الضريبي: $id';
  }

  @override
  String get recentRefunds => 'الاستردادات الأخيرة';

  @override
  String get recordCount => 'تسجيل العدّ';

  @override
  String get referenceRequiredShort => 'رقم المعاملة إلزامي';

  @override
  String get refundAction => 'استرداد';

  @override
  String get refundDone => 'تم تسجيل الاسترداد.';

  @override
  String get refundReasonHint => 'مثال: طبق مرفوض، خطأ في الإدخال';

  @override
  String get refundTitle => 'ردّ المبلغ للزبون';

  @override
  String refundableAmount(String amount) {
    return 'قابل للاسترداد: $amount';
  }

  @override
  String get refundsTab => 'الاستردادات';

  @override
  String get registerClosedHint => 'افتح الصندوق (رصيد معدود) للتحصيل.';

  @override
  String get registerClosedTitle => 'الصندوق مغلق';

  @override
  String get registerLabel => 'الصندوق';

  @override
  String get registerNameHint => 'مثال: الكاونتر، الشرفة، البار';

  @override
  String get registersTitle => 'الصناديق';

  @override
  String get reportsTab => 'التقارير';

  @override
  String get requireReferenceHint =>
      'يجب أن يدخل أمين الصندوق رقم المعاملة (للمطابقة مع الكشف).';

  @override
  String get requireReferenceLabel => 'رقم المعاملة إلزامي';

  @override
  String get salesByDay => 'حسب اليوم';

  @override
  String get salesByMethod => 'حسب وسيلة الدفع';

  @override
  String get salesByRegister => 'حسب الصندوق';

  @override
  String get salesByStaff => 'حسب النادل';

  @override
  String get searchAction => 'بحث';

  @override
  String get searchMethodOrCountry => 'اسم الوسيلة أو رمز البلد (مثال: BR)';

  @override
  String get sendWhatsApp => 'إرسال عبر واتساب';

  @override
  String get sessionAwaitingValidation => 'معدودة — بانتظار الاعتماد';

  @override
  String get settingsTab => 'الإعدادات';

  @override
  String get shareReceipt => 'مشاركة الإيصال';

  @override
  String get signatureCashier => 'توقيع أمين الصندوق';

  @override
  String get signatureManager => 'توقيع المسؤول';

  @override
  String someBranchesOnly(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count فرعًا',
      few: '$count فروع',
      two: 'فرعان',
      one: 'فرع واحد',
    );
    return '$_temp0';
  }

  @override
  String get splitAll => 'الكل';

  @override
  String get splitByItems => 'حسب الأصناف';

  @override
  String get splitByParts => 'حسب الحصص';

  @override
  String get splitCustom => 'مبلغ حر';

  @override
  String get staffLabel => 'النادل';

  @override
  String get statusLabel => 'الحالة';

  @override
  String get taxIdHint => 'رقم التعريف الضريبي في بلدك';

  @override
  String get taxIdLabel => 'رقم التعريف الضريبي';

  @override
  String get ticketOrOrderNumber => 'رقم الإيصال أو الطلب';

  @override
  String get tipLabel => 'بقشيش';

  @override
  String get tipPresetsLabel => 'النسب المقترحة';

  @override
  String get tipsEnabledHint =>
      'يُقترح عند التحصيل، ويُحتسب خارج رقم الأعمال ويُنسب إلى نادل الطلب.';

  @override
  String get tipsEnabledLabel => 'اقتراح بقشيش';

  @override
  String get tipsTitle => 'البقشيش';

  @override
  String get tipsTotal => 'البقشيش';

  @override
  String get toCollectTotal => 'للتحصيل';

  @override
  String get transactionReferenceRequired => 'رقم المعاملة (إلزامي)';

  @override
  String get transactionsTab => 'المعاملات';

  @override
  String get validateClosingConfirm =>
      'اعتماد هذا الإقفال؟ سيُرقّم تقرير Z ولن يمكن تعديله.';

  @override
  String get validateNowHint =>
      'اعتمد الإقفال في تبويب الإقفالات للحصول على تقرير Z المرقّم.';

  @override
  String get validatedLabel => 'معتمدة';

  @override
  String get voidedPayments => 'المدفوعات الملغاة';

  @override
  String get xReading => 'قراءة X';

  @override
  String get xReportTitle => 'قراءة X (مؤقتة)';

  @override
  String get zHistory => 'سجل تقارير Z';

  @override
  String zReportTitle(int number) {
    return 'تقرير Z رقم $number';
  }

  @override
  String get zShort => 'Z';

  @override
  String get expectedCashLabel => 'النقد المتوقع';

  @override
  String get countedAmountLabel => 'المعدود';

  @override
  String get refundsLabel => 'الاستردادات';

  @override
  String get addressOptional => 'العنوان (اختياري)';

  @override
  String get billedTo => 'فاتورة باسم';

  @override
  String get cancelInvoiceHint => 'مثال: خطأ في الاسم التجاري، زبون خاطئ';

  @override
  String get chooseOrder => 'اختر الطلب';

  @override
  String get companyOptional => 'الشركة (اختياري)';

  @override
  String get customerTaxIdOptional => 'الرقم الضريبي للزبون (اختياري)';

  @override
  String get documentsTitle => 'المستندات';

  @override
  String get emailOptional => 'البريد الإلكتروني (اختياري)';

  @override
  String get errorCustomerNameRequired => 'اسم الزبون إلزامي في الفاتورة.';

  @override
  String get invoiceATicket => 'فوترة إيصال';

  @override
  String get invoiceCancelledMention => 'فاتورة ملغاة';

  @override
  String get invoiceCancelledDone =>
      'تم إلغاء الفاتورة: يمكنك إصدار فاتورة جديدة.';

  @override
  String invoiceDateLabel(String date) {
    return 'التاريخ: $date';
  }

  @override
  String get invoiceDesignation => 'البيان';

  @override
  String invoiceEmailHint(String email) {
    return 'لإرسالها إلى $email: اضغط «مشاركة» ثم اختر بريدك.';
  }

  @override
  String get invoiceFooterHint =>
      'مثال: شروط الدفع، البيانات البنكية، البيانات القانونية في بلدك';

  @override
  String get invoiceFooterLabel => 'بيانات أسفل الفاتورة';

  @override
  String invoiceNumberLabel(String number) {
    return 'فاتورة رقم $number';
  }

  @override
  String get invoicePayments => 'المدفوعات المستلمة';

  @override
  String get invoicePrefixHint => 'مثال: FA-2026-';

  @override
  String get invoicePrefixLabel => 'بادئة رقم الفاتورة';

  @override
  String get invoiceSettingsTitle => 'الفواتير';

  @override
  String get invoiceTitle => 'فاتورة';

  @override
  String get invoiceUnitPrice => 'سعر الوحدة';

  @override
  String get invoicedTotal => 'المفوتر';

  @override
  String get invoicesCount => 'الفواتير';

  @override
  String get issueInvoice => 'إعداد فاتورة';

  @override
  String get issueInvoiceAction => 'إصدار الفاتورة';

  @override
  String get issueInvoiceHint =>
      'الفاتورة الصادرة مرقّمة ولا تُعدّل (عند الخطأ: إلغاء ثم فاتورة جديدة).';

  @override
  String get noInvoices =>
      'لا توجد فواتير في هذه الفترة. تُعدّ الفاتورة من الطلب (زر «فاتورة») أو هنا عبر «فوترة إيصال».';

  @override
  String get printInvoice => 'طباعة / تنزيل';

  @override
  String get receiptDocument => 'إيصال الصندوق';

  @override
  String get searchInvoiceHint => 'الرقم، الزبون، الشركة';

  @override
  String get shareInvoice => 'مشاركة';

  @override
  String get totalExclTax => 'المجموع دون ضرائب';

  @override
  String get totalInclTax => 'المجموع شامل الضرائب';

  @override
  String get receiptQrCaption => 'امسح الرمز لتجدنا على الإنترنت';

  @override
  String get receiptQrLabel => 'رمز QR أسفل الإيصال';

  @override
  String get receiptQrUrlLabel => 'رابط رمز QR';

  @override
  String get receiptQrUrlHint =>
      'فارغ = صفحة المطعم. مثال: https://your-site.com أو صفحة التقييمات';

  @override
  String get receiptQrUrlInvalid =>
      'يجب أن يبدأ رابط رمز QR بـ https://‎ (أو http://‎).';

  @override
  String get restaurantLogo => 'شعار المطعم';

  @override
  String get chooseLogo => 'اختيار الشعار';

  @override
  String get replaceLogo => 'استبدال';

  @override
  String get removeLogo => 'إزالة';

  @override
  String get logoTooBig => 'يتجاوز هذا الملف 1 ميغابايت: اختر صورة أخف.';

  @override
  String get receiptTendered => 'المبلغ المدفوع';

  @override
  String get receiptChange => 'الباقي المُعاد';

  @override
  String get restaurantLogoHint =>
      'يُطبع أعلى الإيصالات. يُنصح بصورة PNG بخلفية شفافة، 1 ميغابايت كحد أقصى.';

  @override
  String get add => 'إضافة';

  @override
  String get delete => 'حذف';

  @override
  String get branchLabel => 'الفرع';

  @override
  String get kindDessert => 'حلوى';

  @override
  String get kindMenu => 'وجبة كاملة';

  @override
  String get navAds => 'الإعلانات';

  @override
  String get navSettings => 'الإعدادات';

  @override
  String get greetingShort => 'مرحبًا';

  @override
  String get homeWelcome => 'أهلًا بك، هذا نشاطك اليوم';

  @override
  String get kpiSalesToday => 'مبيعات اليوم';

  @override
  String get kpiOpenOrders => 'الطلبات الجارية';

  @override
  String kpiPendingCount(int count) {
    return '$count قيد الانتظار';
  }

  @override
  String get kpiOccupancy => 'نسبة الإشغال';

  @override
  String kpiTablesBusy(int busy, int total) {
    return '$busy طاولات مشغولة من $total';
  }

  @override
  String get lowStockTitle => 'مخزون منخفض';

  @override
  String get saveChanges => 'حفظ التعديلات';

  @override
  String get settingsProfile => 'ملف المطعم';

  @override
  String get settingsProfileHint => 'معلومات مطعمك التي يراها زبائنك.';

  @override
  String get settingsContact => 'الاتصال والموقع';

  @override
  String get settingsContactHint => 'العنوان والهواتف والموقع على الخريطة.';

  @override
  String get settingsHours => 'مواعيد العمل';

  @override
  String get settingsHoursHint =>
      'أيام وساعات العمل، مدة التحضير، الإغلاق المؤقت.';

  @override
  String get settingsDelivery => 'التوصيل والطلبات';

  @override
  String get settingsDeliveryHint =>
      'الطلبات عبر الإنترنت، التوصيل، الحجوزات والصفحة العامة.';

  @override
  String get settingsPayments => 'الدفع والفوترة';

  @override
  String get settingsPaymentsHint =>
      'طرق الدفع، الصناديق، الإيصال، الفواتير والإكراميات.';

  @override
  String get settingsTeam => 'الفريق والأدوار';

  @override
  String get settingsTeamHint => 'الأعضاء والأدوار والدعوات.';

  @override
  String get settingsNotifications => 'الإشعارات';

  @override
  String get settingsNotificationsHint => 'ما ينبهك إليه التطبيق.';

  @override
  String get settingsSecurity => 'الأمان';

  @override
  String get settingsSecurityHint => 'كلمة المرور والأجهزة المتصلة.';

  @override
  String get restaurantName => 'اسم المطعم';

  @override
  String get sloganLabel => 'الشعار النصي';

  @override
  String get sloganHint => 'مثال: مطبخ تقليدي راقٍ';

  @override
  String get registrationNumber => 'رقم التسجيل';

  @override
  String get registrationNumberHint => 'السجل التجاري في بلدك';

  @override
  String get logoUpload => 'رفع الشعار';

  @override
  String get logoFormats =>
      'PNG أو JPG أو WebP — 1 ميغابايت كحد أقصى. المثالي: 512 × 512.';

  @override
  String get logoWhere =>
      'يظهر الشعار في التطبيق وفي واجهتك وعلى إيصالات زبائنك.';

  @override
  String get whatsappLabel => 'رقم واتساب';

  @override
  String get gpsTitle => 'إحداثيات GPS / الخريطة';

  @override
  String get latitude => 'خط العرض';

  @override
  String get longitude => 'خط الطول';

  @override
  String get gpsMissing => 'الموقع غير محدد';

  @override
  String get openInMaps => 'فتح في الخرائط';

  @override
  String get deliveryZoneLabel => 'منطقة التوصيل';

  @override
  String get deliveryZoneHint => 'مثال: الأحياء المخدومة أو نطاق 5 كم';

  @override
  String get vacationMode => 'وضع العطلة';

  @override
  String get vacationModeHint => 'إغلاق المطعم مؤقتًا: يظهر مغلقًا لزبائنك.';

  @override
  String get vacationMessage => 'رسالة تظهر للزبائن';

  @override
  String get vacationMessageHint => 'مثال: إعادة الافتتاح في 15 سبتمبر';

  @override
  String get notifSoundNewOrder => 'صوت عند كل طلب جديد';

  @override
  String get notifSoundReady => 'صوت عندما يصبح الطلب جاهزًا';

  @override
  String get notifLate => 'تنبيه بالطلبات المتأخرة';

  @override
  String get notifLowStock => 'تنبيه بانخفاض المخزون';

  @override
  String get notifReservations => 'تذكير بحجوزات الساعة';

  @override
  String get notifCashGap => 'فرق الصندوق عند الإغلاق';

  @override
  String get signedInAs => 'متصل باسم';

  @override
  String get securityTip => 'استخدم كلمة مرور فريدة من 8 أحرف على الأقل.';

  @override
  String get signOutOthers => 'تسجيل الخروج من أجهزتي الأخرى';

  @override
  String get signOutOthersDone => 'تم تسجيل خروج أجهزتك الأخرى.';

  @override
  String get signOutAll => 'تسجيل الخروج من كل الأجهزة';

  @override
  String fileTooBig(String name) {
    return '$name كبير جدًا.';
  }

  @override
  String get adsCreate => 'إنشاء إعلان';

  @override
  String get adsEdit => 'تعديل الإعلان';

  @override
  String get adsCampaigns => 'حملاتي';

  @override
  String get adsLibrary => 'المكتبة';

  @override
  String get adsStats => 'الإحصاءات';

  @override
  String get adsCreateTitle => 'إنشاء';

  @override
  String get adsCreateHint => 'اختر صيغة إعلانك.';

  @override
  String get adsContent => 'المحتوى';

  @override
  String get adsBudgetTargeting => 'الميزانية والاستهداف';

  @override
  String get adsPreview => 'معاينة';

  @override
  String get adsPreviewHint => 'المعاينة على الهاتف';

  @override
  String get adsPreviewSimulation => 'هذه المعاينة محاكاة.';

  @override
  String get adsFromLibrary => 'من المكتبة';

  @override
  String get adsUpload => 'إضافة صور أو مقاطع فيديو';

  @override
  String get adsUploadHint =>
      'JPG وPNG وWebP (5 ميغابايت) · MP4 وWebM وMOV (50 ميغابايت) · يُنصح بمقاطع من 15 إلى 30 ثانية';

  @override
  String get adsLibraryEmpty => 'المكتبة فارغة.';

  @override
  String get adsDeleteFile => 'حذف هذا الملف من المكتبة؟';

  @override
  String get adsEmpty => 'لا توجد حملات بعد.';

  @override
  String get adsEmptyHint =>
      'أنشئ إعلانك الأول: فيديو، أو قصة 24 ساعة، أو طبقًا مميزًا.';

  @override
  String get adsActiveCampaigns => 'الحملات';

  @override
  String adsCampaignCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count حملات نشطة',
      one: 'حملة نشطة واحدة',
      zero: 'لا توجد حملة نشطة',
    );
    return '$_temp0';
  }

  @override
  String get adFormat => 'الصيغة';

  @override
  String get adFormatVideo => 'فيديو 15–30 ث';

  @override
  String get adFormatVideoHint => 'فيديو قصير يلفت الانتباه';

  @override
  String get adFormatCarousel => 'صور متتالية';

  @override
  String get adFormatCarouselHint => 'عدة صور يمكن تمريرها';

  @override
  String get adFormatStory => 'قصة 24 ساعة';

  @override
  String get adFormatStoryHint => 'صيغة مؤقتة لمدة 24 ساعة';

  @override
  String get adFormatSponsoredMenu => 'قائمة مموّلة';

  @override
  String get adFormatSponsoredMenuHint => 'إبراز أطباقك';

  @override
  String get adFormatPush => 'إشعار';

  @override
  String get adFormatPushHint => 'الوصول إلى زبائنك مباشرة';

  @override
  String get adFormatClassified => 'إعلان صغير';

  @override
  String get adFormatClassifiedHint => 'إعلان نصي بسيط وفعّال';

  @override
  String get adTitle => 'العنوان';

  @override
  String get adTitleHint => 'مثال: كرواسون بالزبدة';

  @override
  String get adTitleRequired => 'أعطِ إعلانك عنوانًا.';

  @override
  String get adText => 'النص';

  @override
  String get adTextHint => 'مثال: جديد! كرواسون منزلي، خصم 20 % الليلة فقط';

  @override
  String get adMediaHelp => 'صور أو مقاطع فيديو للإعلان (10 كحد أقصى).';

  @override
  String get adVideoHelp => 'أضف فيديو قصيرًا (من 15 إلى 30 ثانية).';

  @override
  String get adChooseItems => 'الأطباق المميزة';

  @override
  String get adCta => 'الزر';

  @override
  String get adCtaHint => 'مثال: اطلب الآن';

  @override
  String get adCtaDefault => 'اطلب الآن';

  @override
  String get adLink => 'رابط الزر (اختياري)';

  @override
  String get adPushNote =>
      'سيُرسل الإشعار إلى زبائن التطبيق الذين وافقوا على تلقي عروضك.';

  @override
  String get adDailyBudget => 'الميزانية اليومية';

  @override
  String get adBudgetNote => 'ميزانية مقدّرة: ستُفوتر المنصة البث المموّل.';

  @override
  String get adStart => 'البداية';

  @override
  String get adEnd => 'النهاية';

  @override
  String get adStory24h => 'مرئي لمدة 24 ساعة';

  @override
  String get adTargetAreas => 'الاستهداف حسب الحي';

  @override
  String get adAddArea => 'إضافة حي';

  @override
  String get adMoments => 'التوقيت';

  @override
  String get momentMorning => 'الصباح';

  @override
  String get momentNoon => 'الظهر';

  @override
  String get momentAfternoon => 'بعد الظهر';

  @override
  String get momentEvening => 'المساء';

  @override
  String get momentNight => 'الليل';

  @override
  String get adBranches => 'الفروع';

  @override
  String get adSaveDraft => 'حفظ المسودة';

  @override
  String get adPublish => 'نشر';

  @override
  String get adPublished => 'تم نشر الإعلان.';

  @override
  String get adSponsored => 'مموّل';

  @override
  String get adStatusActive => 'نشطة';

  @override
  String get adStatusScheduled => 'مجدولة';

  @override
  String get adStatusPaused => 'متوقفة مؤقتًا';

  @override
  String get adStatusEnded => 'منتهية';

  @override
  String get adStatusDraft => 'مسودة';

  @override
  String get adRoi => 'رقم الأعمال المحقق';

  @override
  String adRoiDetail(String amount) {
    return 'مقابل $amount من الميزانية الملتزم بها';
  }

  @override
  String adViews(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مشاهدات',
      one: 'مشاهدة واحدة',
      zero: '0 مشاهدة',
    );
    return '$_temp0';
  }

  @override
  String adOrders(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count طلبات',
      one: 'طلب واحد',
      zero: '0 طلب',
    );
    return '$_temp0';
  }

  @override
  String get adDetails => 'عرض التفاصيل';

  @override
  String get adBoost => 'تعزيز';

  @override
  String get adBoostTitle => 'تمديد البث';

  @override
  String adBoostDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count أيام إضافية',
      one: 'يوم إضافي',
    );
    return '$_temp0';
  }

  @override
  String get adBoosted => 'تم تمديد الحملة.';

  @override
  String get adPause => 'إيقاف مؤقت';

  @override
  String get adResume => 'استئناف';

  @override
  String get adEndNow => 'إنهاء الآن';

  @override
  String get adDeleteConfirm => 'حذف هذه الحملة وإحصاءاتها؟';

  @override
  String get adStatViews => 'المشاهدات';

  @override
  String get adStatClicks => 'النقرات';

  @override
  String get adStatClickRate => 'نسبة النقر';

  @override
  String get adStatOrders => 'الطلبات';

  @override
  String get adStatRevenue => 'رقم الأعمال';

  @override
  String get adStatByCampaign => 'المشاهدات حسب الحملة';

  @override
  String get activeLabel => 'نشط';

  @override
  String get addPhotos => 'إضافة صور';

  @override
  String get addProduct => 'إضافة منتج';

  @override
  String get allItems => 'الكل';

  @override
  String get available => 'متوفر';

  @override
  String get categories => 'الفئات';

  @override
  String get copySuffix => 'نسخة';

  @override
  String get customerSideView => 'عرض الزبون — هكذا يظهر في قائمة المطعم';

  @override
  String get duplicate => 'تكرار';

  @override
  String get everyDay => 'كل يوم';

  @override
  String get filterKind => 'النوع';

  @override
  String get itemDescriptionHint =>
      'مثال: أوراق ندولي بالفول السوداني والروبيان والموز';

  @override
  String get itemDuplicated => 'تم تكرار الصنف: تبقى النسخة مخفية حتى تحفظها.';

  @override
  String get livePreview => 'معاينة مباشرة';

  @override
  String get mainPhoto => 'الرئيسية';

  @override
  String get makeMainPhoto => 'جعلها الصورة الرئيسية';

  @override
  String get markAvailable => 'إعادته متوفرًا';

  @override
  String get markSoldOut => 'وضع علامة نفاد';

  @override
  String get menuProducts => 'منتجات القائمة';

  @override
  String get noProductsFound => 'لا توجد منتجات مطابقة.';

  @override
  String photosHint(int count) {
    return 'حتى $count صور · JPG وPNG وWebP · 5 ميغابايت كحد أقصى';
  }

  @override
  String get play => 'تشغيل';

  @override
  String prepMinutesShort(int minutes) {
    return 'التحضير: $minutes د';
  }

  @override
  String get prepTime => 'مدة التحضير';

  @override
  String get productInfo => 'معلومات المنتج';

  @override
  String get productPhotos => 'صور المنتج';

  @override
  String productsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count منتجات',
      one: 'منتج واحد',
      zero: 'لا توجد منتجات',
    );
    return '$_temp0';
  }

  @override
  String get publish => 'نشر';

  @override
  String get replace => 'استبدال';

  @override
  String get saleDays => 'أيام البيع';

  @override
  String get saleDaysRequired => 'اختر يوم بيع واحدًا على الأقل.';

  @override
  String get searchProduct => 'ابحث عن منتج أو طبق…';

  @override
  String get sizesLabel => 'الأحجام';

  @override
  String get sortBy => 'ترتيب';

  @override
  String get sortMenuOrder => 'ترتيب القائمة';

  @override
  String get sortName => 'الاسم';

  @override
  String get sortPriceAsc => 'السعر تصاعديًا';

  @override
  String get sortPriceDesc => 'السعر تنازليًا';

  @override
  String get stockAlertThreshold => 'تنبيه دون';

  @override
  String get stockAndTime => 'المخزون والوقت';

  @override
  String stockLeft(int count) {
    return 'المخزون: $count متبقية';
  }

  @override
  String stockLow(int count) {
    return 'مخزون منخفض: $count متبقية';
  }

  @override
  String get stockNotTracked => 'فارغ = دون متابعة';

  @override
  String get stockOfDay => 'مخزون اليوم';

  @override
  String get stockOfDayHint =>
      'عدد الحصص المتاحة اليوم. ينخفض مع كل طلب؛ وعند الصفر ينفد الصنف. اتركه فارغًا لعدم المتابعة.';

  @override
  String get stockQuantity => 'الكمية في المخزون';

  @override
  String get supplementsLabel => 'الإضافات';

  @override
  String get videoAdded => 'تمت إضافة فيديو العرض';

  @override
  String get videoOptional => 'فيديو العرض (اختياري، نحو 30 ث)';

  @override
  String get allChannels => 'كل القنوات';

  @override
  String get amountLabel => 'المبلغ';

  @override
  String averageTicketShort(String amount) {
    return 'متوسط الفاتورة $amount';
  }

  @override
  String get customerLabel => 'الزبون';

  @override
  String get financialResult => 'النتيجة المالية';

  @override
  String get inKitchenCount => 'قيد التحضير';

  @override
  String get inProgressCount => 'جارية';

  @override
  String get itemsLabel => 'الأصناف:';

  @override
  String get lateCount => 'متأخرة';

  @override
  String get noOrdersHere => 'لا توجد طلبات هنا';

  @override
  String get noSalesYet => 'لا توجد مبيعات في هذه الفترة بعد.';

  @override
  String get nothingToCollectHint =>
      'لا شيء معلق: ستظهر عمليات التحصيل الجديدة هنا.';

  @override
  String get orderLabel => 'الطلب';

  @override
  String get paymentLabel => 'الدفع';

  @override
  String get periodLabel => 'الفترة';

  @override
  String get recentTransactions => 'آخر المعاملات';

  @override
  String get salesOfPeriod => 'مبيعات الفترة';

  @override
  String get salesSplit => 'توزيع المبيعات';

  @override
  String get timeLabel => 'الوقت';

  @override
  String get topDishes => 'أفضل الأطباق';

  @override
  String get viewDetails => 'عرض التفاصيل';

  @override
  String vsPrevious(String amount) {
    return 'الفترة السابقة: $amount';
  }

  @override
  String get addAddress => 'إضافة عنوان';

  @override
  String get addedToCart => 'أُضيف إلى السلة.';

  @override
  String get addressLabel => 'اسم العنوان';

  @override
  String get addressLabelHint => 'مثال: المنزل، المكتب';

  @override
  String get addToCart => 'أضف إلى السلة';

  @override
  String get allCities => 'كل المدن';

  @override
  String get allRestaurants => 'كل المطاعم';

  @override
  String get birthday => 'تاريخ الميلاد';

  @override
  String get cartEmpty => 'سلتك فارغة.';

  @override
  String cartItems(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count أصناف',
      one: 'صنف واحد',
    );
    return '$_temp0';
  }

  @override
  String get changeCity => 'تغيير';

  @override
  String get chooseCity => 'اختيار المدينة';

  @override
  String chooseOptionRequired(String name) {
    return 'يرجى الاختيار: $name';
  }

  @override
  String get closedNow => 'مغلق';

  @override
  String get customerFavorites => 'المفضلة';

  @override
  String get customerHome => 'الرئيسية';

  @override
  String get customerOrders => 'الطلبات';

  @override
  String get customerProfile => 'الملف';

  @override
  String customerReviews(int count) {
    return 'آراء الزبائن ($count)';
  }

  @override
  String get customerSearch => 'بحث';

  @override
  String get customerSpaceLink => 'فضاء الزبائن · اطلب';

  @override
  String get deliveryDetailsRequired => 'أدخل عنوان التوصيل ورقم هاتف.';

  @override
  String get directions => 'الاتجاهات';

  @override
  String get discoverRestaurants => 'اكتشف المطاعم';

  @override
  String get dishes => 'الأطباق';

  @override
  String get favoritesSignIn => 'سجّل الدخول لتجد مطاعمك المفضلة.';

  @override
  String get fullName => 'الاسم الكامل';

  @override
  String get globalCatalog => 'الكتالوج العام';

  @override
  String get healthAllergies => 'الصحة والحساسية';

  @override
  String get howDoYouWant => 'كيف تفضّل أن تُخدم؟';

  @override
  String loyaltyNextReward(int points, String amount) {
    return 'المكافأة التالية عند $points نقطة: $amount';
  }

  @override
  String loyaltyPoints(int count) {
    return '$count نقطة';
  }

  @override
  String get loyaltyProgram => 'برنامج الولاء';

  @override
  String mapCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مطاعم على الخريطة',
      one: 'مطعم واحد على الخريطة',
    );
    return '$_temp0';
  }

  @override
  String get mapView => 'الخريطة';

  @override
  String minimumOrderNotReached(String amount) {
    return 'الحد الأدنى للطلب: $amount';
  }

  @override
  String minutesRange(int min, int max) {
    return '$min–$max د';
  }

  @override
  String get myAddresses => 'عناويني';

  @override
  String get myCart => 'سلتي';

  @override
  String get newRestaurant => 'جديد';

  @override
  String get noAddresses => 'لا توجد عناوين محفوظة.';

  @override
  String get noCustomerOrders => 'لم تطلب شيئًا بعد.';

  @override
  String get noFavorites => 'لا توجد مفضلات بعد.';

  @override
  String get noFavoritesHint => 'اضغط على قلب المطعم لإضافته.';

  @override
  String get noLoyaltyYet => 'ستظهر نقاطك بعد طلباتك الأولى.';

  @override
  String get noRestaurantsYet => 'لا توجد مطاعم منشورة في هذه المدينة بعد.';

  @override
  String get noteForKitchen => 'ملاحظة للمطبخ (اختياري)';

  @override
  String get noteForKitchenHint => 'مثال: بدون فلفل حار، مطهو جيدًا';

  @override
  String get notifOrderUpdates => 'متابعة طلباتي';

  @override
  String get notifPromotions => 'العروض والتخفيضات';

  @override
  String get notifReservationReminders => 'تذكيرات الحجز';

  @override
  String get onlineOrdersUnavailable => 'الطلب عبر الإنترنت غير متاح حاليًا';

  @override
  String get openFullMap => 'فتح الخريطة بملء الشاشة';

  @override
  String get openNow => 'مفتوح';

  @override
  String get orderDone => 'منتهٍ';

  @override
  String orderingAtTable(String table) {
    return 'الطلب على الطاولة $table';
  }

  @override
  String get orderInProgress => 'جارٍ';

  @override
  String get orderNoteOptional => 'رسالة إلى المطعم (اختياري)';

  @override
  String get orderRejected => 'رفضه المطعم';

  @override
  String get orderSentToRestaurant =>
      'تم إرسال الطلب! سيؤكده المطعم: تابعه هنا مباشرة.';

  @override
  String get ordersSignIn => 'سجّل الدخول لمتابعة طلباتك.';

  @override
  String get orderSummary => 'الملخص';

  @override
  String get orderWaitingConfirmation => 'في انتظار التأكيد';

  @override
  String get payMobileWallet => 'محفظة الهاتف';

  @override
  String get personalProfile => 'الملف الشخصي';

  @override
  String get personalProfileHint => 'معلوماتك الشخصية وتفضيلاتك.';

  @override
  String get placeOrder => 'اطلب';

  @override
  String get preferences => 'التفضيلات';

  @override
  String get preferredPayment => 'طريقة الدفع المفضلة';

  @override
  String get preferredPaymentHint =>
      'للعلم فقط: لا يُحفظ أي رقم بطاقة أو حساب.';

  @override
  String get productDetails => 'تفاصيل المنتج';

  @override
  String get profileSignIn => 'سجّل الدخول لإدارة ملفك وعناوينك ونقاطك.';

  @override
  String get rateOrder => 'قيّم طلبي';

  @override
  String get requiredLabel => 'إلزامي';

  @override
  String get restaurantOnVacation => 'المطعم مغلق مؤقتًا.';

  @override
  String get restaurants => 'المطاعم';

  @override
  String get restaurantSpace => 'فضاء المطعم';

  @override
  String get restaurantUnavailable => 'هذا المطعم غير متاح.';

  @override
  String get reviewComment => 'رأيك (اختياري)';

  @override
  String reviewsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count آراء',
      one: 'رأي واحد',
      zero: 'لا توجد آراء',
    );
    return '$_temp0';
  }

  @override
  String get searchRestaurantsHint => 'ابحث عن مطاعم وأطباق ومطابخ…';

  @override
  String get seeAll => 'عرض الكل';

  @override
  String get send => 'إرسال';

  @override
  String get signInToContinue => 'سجّل الدخول للمتابعة';

  @override
  String get spiceHot => 'حار';

  @override
  String get spiceLevel => 'الحرارة';

  @override
  String get spiceMedium => 'متوسط';

  @override
  String get spiceMild => 'خفيف';

  @override
  String get spiceNone => 'بدون';

  @override
  String get sponsoredAds => 'إعلانات مموّلة';

  @override
  String get stepAccepted => 'قبله المطعم';

  @override
  String get stepDone => 'منتهٍ';

  @override
  String get stepPreparing => 'قيد التحضير';

  @override
  String get stepReady => 'جاهز';

  @override
  String get stepSent => 'مُرسل';

  @override
  String get storyLabel => 'الحكاية';

  @override
  String get thanksForReview => 'شكرًا على رأيك!';

  @override
  String get viewCart => 'عرض السلة';

  @override
  String get watchVideo => 'فيديو';

  @override
  String get yourName => 'اسمك';

  @override
  String get gpsHint =>
      '«فتح في الخرائط» يحفظ تلقائيًا موقعك الحالي: افعل ذلك من داخل المطعم. يمكنك أيضًا إدخال الإحداثيات.';

  @override
  String get locationSaved => 'تم حفظ موقع المطعم.';

  @override
  String get locationServiceDisabled =>
      'خدمة الموقع معطلة على هذا الجهاز: فعّلها ثم أعد المحاولة.';

  @override
  String get locationDenied =>
      'تم رفض الوصول إلى الموقع: اسمح به في إعدادات المتصفح أو الهاتف.';

  @override
  String get locationUnavailable =>
      'الموقع غير متاح حاليًا: أعد المحاولة في الخارج أو أدخل الإحداثيات.';

  @override
  String get openMapAction => 'فتح الخريطة';

  @override
  String get customerReviewsTitle => 'آراء الزبائن';

  @override
  String get forYou => 'مقترحات لك';

  @override
  String fromAmount(String amount) {
    return 'ابتداءً من $amount';
  }

  @override
  String helpfulCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'مفيد ($count)',
      zero: 'مفيد',
    );
    return '$_temp0';
  }

  @override
  String get hideReview => 'إخفاء الرأي';

  @override
  String get hideReviewReason => 'السبب';

  @override
  String get locatedNearYou => 'المطاعم مرتبة حسب موقعك';

  @override
  String get locateMe => 'حدد موقعي';

  @override
  String get locationRefusedChooseCity => 'الموقع غير متاح: اختر مدينتك.';

  @override
  String get nearYouHint => 'اسمح بتحديد الموقع لرؤية أقرب المطاعم والأطباق.';

  @override
  String get nearYouRestaurants => 'بالقرب منك';

  @override
  String get nearYouTitle => 'المطاعم القريبة منك';

  @override
  String get newOnMenus => 'الجديد';

  @override
  String get noReviewsYet => 'لا توجد آراء بعد';

  @override
  String get openNowTitle => 'مفتوحة الآن';

  @override
  String get orderAgain => 'اطلب مجددًا';

  @override
  String get orderAgainAction => 'أعد الطلب';

  @override
  String get ordersInProgressTitle => 'طلباتك الجارية';

  @override
  String get popularDishes => 'أطباق رائجة';

  @override
  String get popularNearYou => 'رائجة بالقرب منك';

  @override
  String get promotionsTitle => 'العروض';

  @override
  String get publishReview => 'نشر رأيي';

  @override
  String rateDish(String name) {
    return 'تقييم: $name';
  }

  @override
  String get rateShort => 'قيّم';

  @override
  String get refreshLocation => 'تحديث';

  @override
  String get reorderPartial =>
      'بعض الأطباق لم تعد متاحة: أُضيف الباقي إلى السلة.';

  @override
  String get reorderUnavailable => 'هذه الأطباق لم تعد متاحة.';

  @override
  String get reportReason => 'لماذا يعد هذا الرأي مسيئًا؟';

  @override
  String get reportReview => 'إبلاغ';

  @override
  String reportsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count بلاغات',
      one: 'بلاغ واحد',
    );
    return '$_temp0';
  }

  @override
  String get reportSent => 'شكرًا، تم إرسال البلاغ.';

  @override
  String get republishReview => 'إعادة النشر';

  @override
  String get reviewCommentHint => 'مثال: متبّل جيدًا، حصة سخية، توصيل سريع';

  @override
  String satisfiedPercent(int percent) {
    return '$percent % من الزبائن راضون';
  }

  @override
  String get sortBestRated => 'الأعلى تقييمًا';

  @override
  String get sortHelpful => 'الأكثر فائدة';

  @override
  String get sortRecent => 'الأحدث';

  @override
  String get sortWorstRated => 'الأدنى تقييمًا';

  @override
  String get verifiedPurchase => 'شراء موثّق';

  @override
  String get verifiedReviewNote =>
      'رأي موثّق: لا يقيّم هذا الطبق إلا من استلمه.';

  @override
  String get asSoonAsPossible => 'في أقرب وقت';

  @override
  String get customerOrdersHere => 'طلباته لديكم';

  @override
  String get customerPrivacyNote =>
      'ترى فقط علاقة هذا الزبون بمطعمك: لا ترى أبدًا طلباته في مطاعم أخرى.';

  @override
  String get customersCount => 'زبائن';

  @override
  String multiRestaurantNote(int count) {
    return '$count مطاعم في سلتك: يتلقى كل مطعم طلبه الخاص برقمه ومتابعته.';
  }

  @override
  String get navCustomers => 'الزبائن';

  @override
  String get noCustomersYet => 'لا يوجد زبائن عبر الإنترنت بعد.';

  @override
  String get noCustomersYetHint =>
      'يظهر هنا تلقائيًا كل زبون يطلب عبر التطبيق.';

  @override
  String get noDeliveryHere => 'هذا المطعم لا يوصّل: طلب للاستلام.';

  @override
  String get ordersSent => 'تم إرسال الطلبات';

  @override
  String ordersSentHint(int count) {
    return 'تم إرسال $count طلبات، طلب لكل مطعم. تابع كل طلب على حدة.';
  }

  @override
  String placeOrders(int count) {
    return 'إرسال الطلبات الـ $count';
  }

  @override
  String get regularBadge => 'زبون دائم';

  @override
  String get regularCustomers => 'دائمون (3 طلبات أو أكثر)';

  @override
  String restaurantsCount(int count) {
    return '$count مطاعم';
  }

  @override
  String get scheduleOrder => 'جدولة';

  @override
  String get scheduleTooSoon => 'اختر وقتًا بعد 15 دقيقة على الأقل.';

  @override
  String get searchCustomer => 'الاسم أو الهاتف';

  @override
  String get sortBiggestSpenders => 'الأكثر إنفاقًا';

  @override
  String get sortMostOrders => 'الأكثر طلبًا';

  @override
  String get sortRecentVisit => 'زيارة حديثة';

  @override
  String get teamNotes => 'ملاحظات الفريق';

  @override
  String get teamNotesExample => 'مثال: يفضّل الشرفة، يحب الصلصة الحارة';

  @override
  String get teamNotesHint => 'مرئية لفريقك فقط.';

  @override
  String get trackOrder => 'متابعة';

  @override
  String get customerDiscover => 'اكتشف';

  @override
  String get feedEmpty => 'لا شيء لاكتشافه حاليًا';

  @override
  String get feedEmptyHint =>
      'ستظهر هنا مقاطع الفيديو والأطباق والعروض من مطاعم مدينتك.';

  @override
  String get feedOrder => 'اطلب';

  @override
  String get feedViewDish => 'عرض الطبق';

  @override
  String get feedViewRestaurant => 'عرض المطعم';

  @override
  String get feedLike => 'إعجاب';

  @override
  String get feedSave => 'حفظ';

  @override
  String get feedShare => 'مشاركة';

  @override
  String get feedSaved => 'تم الحفظ في محتوياتك.';

  @override
  String get feedUnsaved => 'تمت الإزالة من المحتويات المحفوظة.';

  @override
  String get feedLinkCopied => 'تم نسخ الرابط: الصقه لمشاركته.';

  @override
  String get commentsTitle => 'التعليقات';

  @override
  String get noCommentsYet => 'لا توجد تعليقات بعد.';

  @override
  String get writeComment => 'اكتب تعليقًا…';

  @override
  String get adHideForever => 'عدم العرض مجددًا';

  @override
  String reserveAt(String name) {
    return 'احجز لدى $name';
  }

  @override
  String get reservationSentHint => 'تم إرسال الطلب: سيؤكد المطعم حجزك.';

  @override
  String get reservationNoteLabel => 'ملاحظة (اختياري)';

  @override
  String get errorInvalidComment => 'يجب أن يتراوح التعليق بين 1 و500 حرف.';

  @override
  String get adStatReach => 'الوصول';

  @override
  String get adStatEngagement => 'التفاعل';

  @override
  String get adStatLikes => 'الإعجابات';

  @override
  String get adStatSaves => 'مرات الحفظ';

  @override
  String get adStatShares => 'المشاركات';

  @override
  String get hideComment => 'إخفاء';

  @override
  String get moderationReasonExample => 'مثال: مسيء، خارج الموضوع';

  @override
  String get hiddenBadge => 'مخفي';

  @override
  String hiddenBecause(String reason) {
    return 'مخفي: $reason';
  }

  @override
  String get allFilter => 'الكل';

  @override
  String get publishedComments => 'منشورة';

  @override
  String get hiddenComments => 'مخفية';

  @override
  String get adCommentsHint =>
      'تظهر هنا تعليقات الزبائن على إعلاناتك. أخفِ المسيئة أو الخارجة عن الموضوع.';

  @override
  String get happyBirthday => 'عيد ميلاد سعيد!';

  @override
  String birthdayGift(String name, int points) {
    return 'يقدّم لك $name $points نقطة ولاء.';
  }

  @override
  String get thanksAction => 'شكرًا!';

  @override
  String get notificationsTitle => 'الإشعارات';

  @override
  String get noNotifications => 'لا توجد إشعارات';

  @override
  String get noNotificationsHint =>
      'سنُعلمك هنا عندما يقبل مطعم طلبك، أو عندما يصبح جاهزًا، أو عند تأكيد حجز.';

  @override
  String get notifOrderAcceptedTitle => 'تم قبول الطلب';

  @override
  String notifOrderAccepted(String brand, String number) {
    return 'قبل $brand طلبك رقم $number.';
  }

  @override
  String get notifOrderReadyTitle => 'الطلب جاهز';

  @override
  String notifOrderReady(String brand, String number) {
    return 'طلبك رقم $number جاهز لدى $brand: يمكنك استلامه.';
  }

  @override
  String notifOrderOnTheWay(String brand, String number) {
    return 'طلبك رقم $number من $brand جاهز وفي الطريق إليك.';
  }

  @override
  String get notifOrderRejectedTitle => 'تم رفض الطلب';

  @override
  String notifOrderRejected(String brand, String number, String reason) {
    return 'لم يتمكن $brand من قبول طلبك رقم $number: $reason';
  }

  @override
  String get notifReservationConfirmedTitle => 'تم تأكيد الحجز';

  @override
  String notifReservationConfirmed(String brand, String date) {
    return 'أكّد $brand حجزك ليوم $date.';
  }

  @override
  String get notifReservationDeclinedTitle => 'تم رفض الحجز';

  @override
  String notifReservationDeclined(String brand, String date, String reason) {
    return 'لا يستطيع $brand استقبالك يوم $date: $reason';
  }

  @override
  String notifGroupJoined(String name, String brand) {
    return 'انضم $name إلى طلبك الجماعي لدى $brand.';
  }

  @override
  String notifGroupPlaced(String host, String brand, String number) {
    return 'أرسل $host الطلب الجماعي لدى $brand (رقم $number).';
  }

  @override
  String get groupOrderTitle => 'طلب جماعي';

  @override
  String get groupOrderAction => 'طلب جماعي';

  @override
  String get groupInviteTitle => 'ادعُ ضيوفك';

  @override
  String get groupInviteHint =>
      'شارك هذا الرابط: يختار كل شخص أطباقه من هاتفه، ثم ترسل طلبًا واحدًا.';

  @override
  String get groupEmpty => 'لا توجد أطباق بعد';

  @override
  String get groupEmptyHint => 'أضف أطباقك وشارك الرابط مع ضيوفك.';

  @override
  String groupHostedBy(String name) {
    return 'ينظّمه $name';
  }

  @override
  String groupStatusOpen(String time) {
    return 'مفتوح حتى $time';
  }

  @override
  String get groupStatusPlaced => 'أُرسل إلى المطعم';

  @override
  String get groupStatusCancelled => 'ملغى';

  @override
  String get groupStatusExpired => 'منتهي الصلاحية';

  @override
  String groupParticipants(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ضيوف',
      one: 'ضيف واحد',
    );
    return '$_temp0';
  }

  @override
  String get groupCheckoutTitle => 'إرسال للمجموعة كلها';

  @override
  String get estimatedTotal => 'المجموع التقديري';

  @override
  String get groupPlaceOrder => 'إرسال الطلب إلى المطعم';

  @override
  String get cancelGroupOrder => 'إلغاء الطلب الجماعي';

  @override
  String get cancelGroupOrderConfirm =>
      'إلغاء هذا الطلب الجماعي؟ ستضيع أطباق الجميع.';

  @override
  String get groupAddMyDishes => 'إضافة أطباقي';

  @override
  String groupPlacedInfo(String name) {
    return 'أرسل $name الطلب إلى المطعم.';
  }

  @override
  String get groupClosedInfo => 'هذا الطلب الجماعي مغلق.';

  @override
  String get groupOrderPlaced => 'تم إرسال الطلب الجماعي إلى المطعم.';

  @override
  String get addedToGroup => 'أُضيف إلى الطلب الجماعي.';

  @override
  String get addToGroup => 'إضافة إلى المجموعة';

  @override
  String get saveDishAction => 'حفظ الطبق';

  @override
  String saveDishTitle(String name) {
    return 'حفظ «$name»';
  }

  @override
  String get favoriteDishes => 'الأطباق المفضلة';

  @override
  String get myLists => 'قوائمي';

  @override
  String get myCoupons => 'قسائمي';

  @override
  String get restaurantsSection => 'المطاعم';

  @override
  String get unavailableNow => 'غير متوفر';

  @override
  String get removeAction => 'إزالة';

  @override
  String get noFavoriteDishes => 'لا توجد أطباق مفضلة';

  @override
  String get noFavoriteDishesHint => 'المس القلب في صفحة الطبق لتجده هنا.';

  @override
  String get newList => 'قائمة جديدة';

  @override
  String get noLists => 'لا توجد قوائم';

  @override
  String get noListsHint => 'أنشئ قوائم مثل «للتجربة» أو «غداء المكتب».';

  @override
  String deleteListConfirm(String name) {
    return 'حذف القائمة «$name»؟';
  }

  @override
  String get renameAction => 'إعادة التسمية';

  @override
  String dishesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count أطباق',
      one: 'طبق واحد',
      zero: 'لا أطباق',
    );
    return '$_temp0';
  }

  @override
  String get emptyListHint => 'القائمة فارغة: أضف أطباقًا من صفحاتها.';

  @override
  String get listName => 'اسم القائمة';

  @override
  String get listNameExample => 'مثال: للتجربة';

  @override
  String get noCoupons => 'لا توجد قسائم';

  @override
  String get noCouponsHint =>
      'احفظ عروض المطاعم من الصفحة الرئيسية لتجدها هنا.';

  @override
  String get couponsHowTo => 'أدخل الرمز في متابعة طلبك للحصول على الخصم.';

  @override
  String validUntil(String date) {
    return 'حتى $date';
  }

  @override
  String get couponUsed => 'مستخدمة';

  @override
  String get couponExpired => 'منتهية';

  @override
  String get codeCopied => 'تم نسخ الرمز.';

  @override
  String get couponSaved => 'تم حفظ القسيمة في مفضلتك.';

  @override
  String get saveCouponAction => 'حفظ';

  @override
  String get errorLimitReached =>
      'تم بلوغ الحد: أزل بعض العناصر قبل إضافة غيرها.';

  @override
  String get errorGroupClosed => 'هذا الطلب الجماعي مغلق أو منتهي الصلاحية.';

  @override
  String get customersTab => 'الزبائن';

  @override
  String get offersTab => 'العروض';

  @override
  String get loyaltyTab => 'الولاء';

  @override
  String get activeOffers => 'العروض الجارية';

  @override
  String get publicCoupons => 'القسائم العامة';

  @override
  String get totalUses => 'مرات الاستخدام';

  @override
  String get newOffer => 'عرض جديد';

  @override
  String get editOffer => 'تعديل العرض';

  @override
  String get offersEmpty => 'لا توجد عروض';

  @override
  String get offersEmptyHint =>
      'أنشئ خصمًا أو رمزًا ترويجيًا أو قسيمة عامة لجذب زبائنك وكسب ولائهم.';

  @override
  String get offerStatusOff => 'معطّل';

  @override
  String get offerStatusEnded => 'منتهٍ';

  @override
  String get offerStatusScheduled => 'مجدول';

  @override
  String get offerStatusActive => 'جارٍ';

  @override
  String get publicCouponLabel => 'قسيمة عامة';

  @override
  String get publicCouponHint =>
      'تظهر في التطبيق: يمكن للزبائن حفظها في محفظتهم.';

  @override
  String get publicCouponNeedsCode => 'تحتاج القسيمة العامة إلى رمز.';

  @override
  String usesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count استخدامات',
      one: 'استخدام واحد',
      zero: 'لم يُستخدم',
    );
    return '$_temp0';
  }

  @override
  String get offerName => 'اسم العرض';

  @override
  String get offerNameExample => 'مثال: ترحيب، ساعة سعيدة';

  @override
  String get discountPercent => 'نسبة مئوية';

  @override
  String get discountAmount => 'مبلغ';

  @override
  String get offerValue => 'الخصم';

  @override
  String get promoCodeLabel => 'الرمز (اختياري)';

  @override
  String get offerCodeHint => 'من 3 إلى 30 حرفًا أو رقمًا، مثل WELCOME';

  @override
  String get minOrderLabel => 'الحد الأدنى للطلب';

  @override
  String get maxUsesLabel => 'أقصى استخدام';

  @override
  String get perCustomerLabel => 'لكل زبون';

  @override
  String get startsLabel => 'البداية';

  @override
  String get endsLabel => 'النهاية';

  @override
  String get offerNow => 'الآن';

  @override
  String get noEndDate => 'بلا نهاية';

  @override
  String get allBranchesLabel => 'كل الفروع';

  @override
  String get thisBranchOnly => 'هذا الفرع';

  @override
  String get offerActive => 'العرض مفعّل';

  @override
  String get loyaltyMembers => 'الأعضاء';

  @override
  String get pointsInCirculation => 'النقاط المتداولة';

  @override
  String get loyaltyProgramTitle => 'برنامج الولاء';

  @override
  String loyaltyExample(String amount, int points) {
    return 'مثال: طلب بقيمة $amount يمنح $points نقاط.';
  }

  @override
  String get loyaltyActive => 'البرنامج مفعّل';

  @override
  String get amountPerPoint => 'المبلغ مقابل نقطة واحدة';

  @override
  String get rewardPointsLabel => 'النقاط اللازمة لمكافأة';

  @override
  String get rewardValueLabel => 'قيمة المكافأة';

  @override
  String get birthdayPointsLabel => 'نقاط عيد الميلاد';

  @override
  String get birthdayPointsHint =>
      'تُضاف تلقائيًا كل عام للزبائن الذين طلبوا من مطعمك من قبل (0 = لا شيء).';

  @override
  String get stockDashboardTab => 'لوحة المتابعة';

  @override
  String get stockArticlesTab => 'الأصناف';

  @override
  String get stockOrdersTab => 'الطلبيات';

  @override
  String get stockReportsTab => 'التقارير';

  @override
  String get stockDashboardTitle => 'لوحة متابعة المخزون';

  @override
  String get stockValueLabel => 'قيمة المخزون';

  @override
  String get belowThresholdLabel => 'تحت الحد الأدنى';

  @override
  String get outOfStockLabel => 'نفد';

  @override
  String get expiringSoonLabel => 'تنتهي صلاحيتها قريبًا';

  @override
  String get inventoryVarianceLabel => 'فروقات الجرد';

  @override
  String get consumptionLabel => 'الاستهلاك';

  @override
  String get wasteLabel => 'الهدر';

  @override
  String get receiptsLabel => 'الاستلامات';

  @override
  String articlesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count أصناف',
      one: 'صنف واحد',
      zero: 'لا أصناف',
    );
    return '$_temp0';
  }

  @override
  String daysCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count أيام',
      one: 'يوم واحد',
    );
    return '$_temp0';
  }

  @override
  String get consumptionByDay => 'الاستهلاك والهدر حسب اليوم';

  @override
  String get topConsumedTitle => 'الأكثر استهلاكًا';

  @override
  String get wasteByReason => 'الهدر حسب السبب';

  @override
  String get noMovementsPeriod => 'لا حركات في هذه الفترة.';

  @override
  String get noWastePeriod => 'لا هدر في هذه الفترة.';

  @override
  String get expiringLotsTitle => 'دفعات للمراقبة (تواريخ الصلاحية)';

  @override
  String get noExpiringLots => 'لا تنتهي صلاحية أي دفعة خلال 7 أيام.';

  @override
  String get toReorderTitle => 'للطلب';

  @override
  String get noAlerts => 'لا صنف تحت الحد الأدنى.';

  @override
  String get prepareOrder => 'تحضير الطلبية';

  @override
  String get expiredShort => 'منتهي';

  @override
  String daysLeftShort(int count) {
    return 'ي-$count';
  }

  @override
  String daysLeftLong(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'مخزون $count أيام',
      one: 'مخزون يوم واحد',
      zero: 'ينفد اليوم',
    );
    return '$_temp0';
  }

  @override
  String batchShort(String batch) {
    return 'دفعة $batch';
  }

  @override
  String get batchNumber => 'رقم الدفعة';

  @override
  String get expiryDate => 'تاريخ الصلاحية';

  @override
  String get stockEmptyHint =>
      'أنشئ أصنافك في تبويب الأصناف، ثم سجّل المخزون الافتتاحي أو استلامًا.';

  @override
  String get searchArticle => 'البحث عن صنف';

  @override
  String get showInactive => 'إظهار غير النشطة';

  @override
  String get newArticle => 'صنف جديد';

  @override
  String get editArticle => 'تعديل الصنف';

  @override
  String get articlesEmptyHint =>
      'أضف منتجاتك: خضار، لحوم، مشروبات، تغليف، تحضيرات منزلية…';

  @override
  String get storageLabel => 'طريقة الحفظ';

  @override
  String get storageAmbient => 'حرارة الغرفة';

  @override
  String get storageChilled => 'مبرّد';

  @override
  String get storageFrozen => 'مجمّد';

  @override
  String get purchaseUnitLabel => 'وحدة الشراء';

  @override
  String get purchaseUnitExample => 'مثال: كيس 5 كغ، كرتونة 12';

  @override
  String get purchaseUnitQty => 'المحتوى';

  @override
  String get preferredSupplier => 'المورّد المعتاد';

  @override
  String get noneLabel => 'لا شيء';

  @override
  String get shelfLifeDays => 'مدة الصلاحية';

  @override
  String get daysShort => 'أيام';

  @override
  String get barcodeLabel => 'الرمز الشريطي';

  @override
  String get thresholdThisBranch => 'حد التنبيه لهذا الفرع';

  @override
  String get reorderTitle => 'الطلبية المقترحة';

  @override
  String get reorderHint =>
      'ما يكفي للبقاء فوق الحد الأدنى، حسب استهلاك آخر 28 يومًا.';

  @override
  String get nothingToReorder => 'لا شيء للطلب';

  @override
  String get nothingToReorderHint =>
      'كل الأصناف المتابعة لديها مخزون كافٍ للفترة المختارة.';

  @override
  String get noSupplier => 'دون مورّد معتاد';

  @override
  String get noSupplierHint =>
      'اختر مورّدًا معتادًا في بطاقة الصنف لإنشاء أمر شراء.';

  @override
  String get orderFormPdf => 'أمر الشراء PDF';

  @override
  String get createPurchaseOrder => 'إنشاء أمر الشراء';

  @override
  String get purchaseOrderDraftCreated =>
      'تم إنشاء أمر الشراء كمسودة في المشتريات.';

  @override
  String get reorderNote => 'طلبية مقترحة من المخزون';

  @override
  String inStockShort(String qty) {
    return 'في المخزون: $qty';
  }

  @override
  String get entriesFilter => 'الداخل';

  @override
  String get exitsLabel => 'الخارج';

  @override
  String get transfersFilter => 'التحويلات';

  @override
  String get adjustmentsFilter => 'التسويات';

  @override
  String get movementsReportTitle => 'حركات المخزون';

  @override
  String get wasteReportTitle => 'الهدر والكسر';

  @override
  String get reportValuation => 'المخزون المقوَّم';

  @override
  String get reportValuationHint =>
      'الكميات والحدود ومتوسط التكلفة وقيمة كل صنف في هذه اللحظة.';

  @override
  String get reportMovementsHint => 'كل حركات الفترة مع المجاميع حسب النوع.';

  @override
  String get reportWasteHint => 'هدر الفترة مع سببه وقيمته.';

  @override
  String get reportInventory => 'الجرد مع الفروقات';

  @override
  String get reportInventoryHint =>
      'النظري والمعدود والفروقات المقوَّمة مع التوقيعات.';

  @override
  String get reportFoodCost => 'تكلفة المواد لكل طبق';

  @override
  String get reportFoodCostHint =>
      'التكلفة وسعر البيع ونسبة المواد والهامش لكل طبق.';

  @override
  String get reportExpiringHint =>
      'دفعات في المخزون تنتهي صلاحيتها خلال 14 يومًا.';

  @override
  String get generatePdf => 'إنشاء ملف PDF';

  @override
  String get noValidatedInventory => 'لا يوجد جرد معتمد بعد.';

  @override
  String get chooseInventory => 'اختيار الجرد';

  @override
  String generatedOn(String date) {
    return 'صدر في $date';
  }

  @override
  String get articlesLabel => 'الأصناف';

  @override
  String get articleLabel => 'الصنف';

  @override
  String get avgCostShort => 'متوسط التكلفة';

  @override
  String get valueLabel => 'القيمة';

  @override
  String get typeLabel => 'النوع';

  @override
  String get inventoryGains => 'الفوائض';

  @override
  String get inventoryLosses => 'النواقص';

  @override
  String get inventoryNet => 'صافي الفرق';

  @override
  String get theoreticalLabel => 'النظري';

  @override
  String get countedBySignature => 'عدّه: ____________________';

  @override
  String get validatedBySignature => 'اعتمده: ____________________';

  @override
  String get targetFoodCost => 'هدف تكلفة المواد';

  @override
  String get targetFoodCostHint =>
      'أقصى نسبة من سعر البيع يجب أن تمثلها مكونات الطبق (غالبًا من 25 إلى 35 ٪).';

  @override
  String targetFoodCostValue(String percent) {
    return 'هدف تكلفة المواد: $percent ٪';
  }

  @override
  String get dishesWithRecipe => 'أطباق لها بطاقة';

  @override
  String get aboveTarget => 'فوق الهدف';

  @override
  String get aboveTargetShort => 'مكلف جدًا';

  @override
  String get withoutRecipe => 'دون بطاقة';

  @override
  String get recipeDefined => 'البطاقة محددة';

  @override
  String get dishLabel => 'الطبق';

  @override
  String get costPriceShort => 'التكلفة';

  @override
  String get sellingPriceShort => 'السعر';

  @override
  String get foodCostShort => 'تكلفة المواد';

  @override
  String get marginShort => 'الهامش';

  @override
  String get orderFormTitle => 'أمر شراء';

  @override
  String supplierLabelValue(String name) {
    return 'المورّد: $name';
  }

  @override
  String get packagingLabel => 'التعبئة';

  @override
  String get unitPriceShort => 'سعر الوحدة';

  @override
  String get orderFormFooter => 'يرجى تأكيد التوفر وموعد التسليم.';

  @override
  String get accountTypeQuestion => 'أنت:';

  @override
  String get accountTypeCustomer => 'زبون';

  @override
  String get accountTypeCustomerHint => 'اكتشاف المطاعم، الطلب، الحجز';

  @override
  String get accountTypeBusiness => 'مؤسسة';

  @override
  String get accountTypeBusinessHint => 'إدارة مطعمي وفريقي';

  @override
  String get accountTypeRequired => 'اختر زبون أو مؤسسة.';

  @override
  String get accountTypeTitle => 'مرحبًا بك في Resto';

  @override
  String get accountTypeSub => 'كيف ستستخدم التطبيق؟';

  @override
  String get continueAction => 'متابعة';

  @override
  String adVideoTooBig(String name) {
    return '$name يتجاوز 50 ميغابايت: اختر فيديو أقصر (نحو 30 ثانية).';
  }

  @override
  String adMediaAdded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'أُضيفت $count ملفات.',
      one: 'أُضيف ملف واحد.',
    );
    return '$_temp0';
  }

  @override
  String get adNeedVideo => 'أضف فيديو قبل نشر هذا النوع.';

  @override
  String get adNeedMedia => 'أضف صورة أو فيديو واحدًا على الأقل قبل النشر.';

  @override
  String get adNeedItems => 'اختر طبقًا واحدًا على الأقل لإبرازه.';

  @override
  String get uploadingLabel => 'جارٍ الإرسال…';

  @override
  String get errorInvalidMedia =>
      'رُفض الملف: يجب أن يكون من مكتبة الوسائط الخاصة بك.';

  @override
  String get errorFileTooLarge => 'الملف كبير جدًا.';

  @override
  String get errorFileType =>
      'صيغة الملف غير مقبولة (JPG، PNG، WebP، MP4، WebM، MOV).';

  @override
  String get adAddVideo => 'إضافة فيديو';

  @override
  String get errorOutOfStock => 'نفد هذا الطبق لهذا اليوم.';

  @override
  String get errorInvalidRating => 'يجب أن يكون التقييم بين 1 و5.';

  @override
  String get errorInvalidAllergen => 'مسبب حساسية غير معروف.';

  @override
  String get bestSeller => 'الأكثر مبيعًا';

  @override
  String get callAction => 'اتصال';

  @override
  String get writeAction => 'مراسلة';

  @override
  String get categoriesLabel => 'الفئات';

  @override
  String get filtersLabel => 'عوامل التصفية';

  @override
  String get reviewsTab => 'التقييمات';

  @override
  String get infosTab => 'معلومات';

  @override
  String get noDishMatches => 'لا يوجد طبق يطابق عوامل التصفية هذه.';

  @override
  String soldCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'بيع $count مرة',
      one: 'بيع مرة واحدة',
    );
    return '$_temp0';
  }

  @override
  String get yourCart => 'سلتك';

  @override
  String get coverPhoto => 'صورة الغلاف';

  @override
  String get coverPhotoHint =>
      'صورة كبيرة أعلى صفحة مطعمك (الصالة، الشرفة، الواجهة).';

  @override
  String get changePhoto => 'تغيير الصورة';

  @override
  String get itemTagsLabel => 'الوسوم (عوامل تصفية قائمتك)';

  @override
  String get itemTagsHint =>
      'أنشئ وسومك الخاصة: يمكن لزبائنك تصفية القائمة بها. مثال: حار قليلًا، حلال، بدون كحول، منزلي الصنع.';

  @override
  String get addTagHint => 'وسم جديد + إدخال';

  @override
  String get errorInvalidTag => 'لا يتجاوز الوسم 30 حرفًا.';

  @override
  String itemFavorites(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'أضافه $count زبونًا إلى المفضلة',
      one: 'أضافه زبون واحد إلى المفضلة',
      zero: 'لم يضفه أي زبون إلى المفضلة',
    );
    return '$_temp0';
  }

  @override
  String get itemSold30 => 'المبيعات خلال آخر 30 يومًا';

  @override
  String get receiptOrderNo => 'رقم الطلب';

  @override
  String get receiptTicketNo => 'رقم الإيصال';

  @override
  String get receiptChannel => 'القناة';

  @override
  String get receiptQtyShort => 'الكمية';

  @override
  String get receiptTotalInclTax => 'الإجمالي شامل الضريبة';

  @override
  String get receiptTotalExclTax => 'الإجمالي دون ضريبة';

  @override
  String get receiptApproved => 'تمت الموافقة على المعاملة';

  @override
  String receiptRef(String ref) {
    return 'المرجع: $ref';
  }

  @override
  String receiptSeeYou(String name) {
    return 'إلى اللقاء قريبًا في $name';
  }

  @override
  String get receiptRecycle =>
      'من أجل كوكب أكثر خضرة، يرجى إعادة تدوير هذا الإيصال.';

  @override
  String get receiptLoyaltyTitle => 'وفاؤك له مكافأة!';

  @override
  String get receiptLoyaltyCaption =>
      'امسح رمز QR هذا للوصول إلى مساحة الوفاء والاستفادة من مزاياك.';

  @override
  String get receiptPaperLabel => 'طابعة الإيصالات في هذا الجهاز';

  @override
  String get receiptPaper80 => 'لفافة 80 مم';

  @override
  String get receiptPaper58 => 'لفافة 58 مم';

  @override
  String get receiptPhotosLabel => 'صور الأطباق على الإيصال';

  @override
  String get receiptTestPrint => 'طباعة إيصال تجريبي';

  @override
  String get receiptTestTitle => 'إيصال تجريبي';

  @override
  String get receiptHeaderSection => 'رأس الإيصال';

  @override
  String get receiptFooterSection => 'أسفل الإيصال';

  @override
  String get receiptTitleLabel => 'الاسم المعروض';

  @override
  String get receiptTitleHint => 'افتراضيًا: اسم العلامة';

  @override
  String get receiptSubtitleLabel => 'العنوان الفرعي';

  @override
  String get receiptSubtitleHint => 'مثال: مطعم ونكهات';

  @override
  String get receiptSloganLabel => 'الشعار';

  @override
  String get receiptSloganHint => 'مثال: مطبخ أصيل، نكهات من العالم';

  @override
  String get websiteLabel => 'الموقع الإلكتروني';

  @override
  String get websiteHint => 'مثال: www.myrestaurant.com';

  @override
  String get receiptQrTitleLabel => 'العنوان بجانب رمز QR';

  @override
  String get receiptQrCaptionLabel => 'النص بجانب رمز QR';

  @override
  String get receiptFarewellLabel => 'عبارة الوداع';

  @override
  String get receiptFarewellHint => 'مثال: إلى اللقاء قريبًا!';

  @override
  String itemLikesTip(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count إعجاب',
      one: 'إعجاب واحد',
      zero: 'لا إعجابات',
    );
    return '$_temp0';
  }

  @override
  String get itemReviewAction => 'رأي';

  @override
  String get itemHeartAction => 'قلب';

  @override
  String get itemCommentsTitle => 'آراء الزبائن';

  @override
  String get itemVerifiedReviews => 'تقييمات بعد الطلب';

  @override
  String get notifStaffNewOrderTitle => 'طلب جديد';

  @override
  String notifStaffNewOrder(String number, String customer, String branch) {
    return 'طلب رقم $number $customer — $branch';
  }

  @override
  String get notifStaffOrderReadyTitle => 'الطلب جاهز للتقديم';

  @override
  String notifStaffOrderReady(String number, String branch) {
    return 'طلب رقم $number — $branch';
  }

  @override
  String get notifStaffReservationTitle => 'حجز جديد';

  @override
  String notifStaffReservation(String name, int count, String date) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count أشخاص',
      one: 'شخص واحد',
    );
    return '$name · $_temp0 · $date';
  }

  @override
  String get notifStaffReviewTitle => 'رأي جديد';

  @override
  String notifStaffReview(String author, String item) {
    return '$author عن «$item»';
  }

  @override
  String get pushNewOrder => 'إشعار على الهاتف: طلب جديد من زبون';

  @override
  String get pushOrderReady => 'إشعار على الهاتف: طلب جاهز للتقديم';

  @override
  String get pushReservations => 'إشعار على الهاتف: حجز جديد';

  @override
  String get pushReviews => 'إشعار على الهاتف: رأي جديد عن طبق';

  @override
  String get tablesTab => 'الطاولات';

  @override
  String get tablesNow => 'الآن';

  @override
  String get tablesLater => 'اختر وقتًا';

  @override
  String get tableLegendOccupied => 'مشغولة';

  @override
  String get tableLegendReserved => 'محجوزة';

  @override
  String get tableLegendChosen => 'اختيارك';

  @override
  String tableFreeUntil(String time) {
    return 'متاحة حتى $time';
  }

  @override
  String tableOccupiedUntil(String time) {
    return 'تتاح نحو $time';
  }

  @override
  String tableReservedSlot(String from, String to) {
    return 'محجوزة $from–$to';
  }

  @override
  String get tablesSelectHint => 'المس طاولة متاحة أو أكثر لحجزها.';

  @override
  String tablesSeatsChosen(int seats, int party) {
    String _temp0 = intl.Intl.pluralLogic(
      seats,
      locale: localeName,
      other: '$seats مقاعد مختارة',
      one: 'مقعد واحد مختار',
    );
    String _temp1 = intl.Intl.pluralLogic(
      party,
      locale: localeName,
      other: '$party أشخاص',
      one: 'شخص واحد',
    );
    return '$_temp0 لـ $_temp1';
  }

  @override
  String reserveTablesAction(String tables) {
    return 'احجز $tables';
  }

  @override
  String tableLabelChip(String label) {
    return 'طاولة $label';
  }

  @override
  String get tablesEmpty => 'لم يعرض هذا المطعم طاولاته بعد.';

  @override
  String appVersion(String version, String build) {
    return 'Resto · الإصدار $version ($build)';
  }

  @override
  String get dashTabOverview => 'نظرة عامة';

  @override
  String get dashTabDishes => 'الأطباق';

  @override
  String get dashTabTeam => 'الفريق والخدمة';

  @override
  String get dashTabFinance => 'المالية';

  @override
  String get coversLabel => 'الأشخاص';

  @override
  String perCoverLabel(String amount) {
    return '$amount للشخص';
  }

  @override
  String get occupancyLabel => 'الطاولات المشغولة';

  @override
  String get paymentsByMethod => 'التحصيل حسب وسيلة الدفع';

  @override
  String get busyHours => 'الإقبال حسب اليوم والساعة';

  @override
  String get menuEngineering => 'هندسة القائمة';

  @override
  String get menuEngineeringHint =>
      'المبيعات × هامش كل طبق، حسب البطاقات الفنية.';

  @override
  String get engStars => 'النجوم';

  @override
  String get engStarsHint => 'مطلوبة ومربحة: أبقها في الواجهة.';

  @override
  String get engPlowhorses => 'مطلوبة، قليلة الربح';

  @override
  String get engPlowhorsesHint => 'راجع السعر أو التكلفة.';

  @override
  String get engPuzzles => 'مربحة، قليلة المبيع';

  @override
  String get engPuzzlesHint => 'أبرزها: صورة، إعلان، توصية الفريق.';

  @override
  String get engDogs => 'للمراجعة';

  @override
  String get engDogsHint => 'قليلة المبيع والربح: أعد العمل عليها أو أزلها.';

  @override
  String engNoRecipe(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count أطباق بلا بطاقة فنية غير مصنفة.',
      one: 'طبق واحد بلا بطاقة فنية غير مصنف.',
    );
    return '$_temp0';
  }

  @override
  String get slowSellers => 'أطباق قليلة المبيع';

  @override
  String get teamPerformance => 'أداء الفريق';

  @override
  String get memberLabel => 'العضو';

  @override
  String get staffOrders => 'الطلبات';

  @override
  String get staffSales => 'المبيعات';

  @override
  String get staffTips => 'الإكراميات';

  @override
  String get serviceTimes => 'أوقات الخدمة';

  @override
  String get serveTime => 'الوصول إلى الطاولة';

  @override
  String get tableTime => 'المدة على الطاولة';

  @override
  String minutesValue(int count) {
    return '$count د';
  }

  @override
  String targetMinutes(int count) {
    return 'الهدف: $count د';
  }

  @override
  String get cancellationsTitle => 'الإلغاءات';

  @override
  String cancelledOrdersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count طلبات ملغاة',
      one: 'طلب واحد ملغى',
      zero: 'لا طلبات ملغاة',
    );
    return '$_temp0';
  }

  @override
  String cancelledItemsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count أصناف ملغاة بعد الإرسال',
      one: 'صنف واحد ملغى بعد الإرسال',
      zero: 'لا أصناف ملغاة بعد الإرسال',
    );
    return '$_temp0';
  }

  @override
  String get cancelReasonsTitle => 'الأسباب الأكثر تكرارًا';

  @override
  String get dashPdf => 'تقرير PDF';

  @override
  String get insightsUnavailable =>
      'ستظهر المؤشرات التفصيلية بعد تحديث قاعدة البيانات (الترحيل 034).';

  @override
  String get salesByDayTitle => 'المبيعات حسب اليوم';

  @override
  String get ordersCountLabel => 'الطلبات';

  @override
  String get financeItemLabel => 'البند';

  @override
  String get supplierLabel => 'المورد';

  @override
  String get purchaseOrderTitle => 'أمر شراء';

  @override
  String get supplierStatementTitle => 'كشف حساب المورد';

  @override
  String get dueDateLabel => 'تاريخ الاستحقاق';

  @override
  String get balanceDue => 'الرصيد المستحق';

  @override
  String get purchasesThisMonth => 'مشتريات الشهر';

  @override
  String openInvoicesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count فواتير للدفع',
      one: 'فاتورة واحدة للدفع',
      zero: 'لا فواتير للدفع',
    );
    return '$_temp0';
  }

  @override
  String get overdueInvoices => 'فواتير متأخرة';

  @override
  String get dueWithinWeek => 'تستحق خلال 7 أيام';

  @override
  String get pendingPurchaseOrders => 'طلبات جارية';

  @override
  String get paymentSchedule => 'جدول الدفعات';

  @override
  String get nothingToPay => 'لا فواتير للدفع.';

  @override
  String get noDueDate => 'بدون تاريخ استحقاق';

  @override
  String get purchasesByMonth => 'المشتريات حسب الشهر';

  @override
  String get topSuppliers => 'أهم الموردين (90 يومًا)';

  @override
  String get noPurchasesYet => 'لا مشتريات بعد.';

  @override
  String get totalPurchased => 'إجمالي المشتريات';

  @override
  String get purchaseOrderPdf => 'أمر شراء PDF';

  @override
  String recurringGenerated(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'تم تسجيل $count مصاريف متكررة.',
      one: 'تم تسجيل مصروف متكرر واحد.',
      zero: 'لا مصاريف للتسجيل.',
    );
    return '$_temp0';
  }

  @override
  String recurringDue(int count, String amount) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مصاريف متكررة للتسجيل هذا الشهر ($amount)',
      one: 'مصروف متكرر واحد للتسجيل هذا الشهر ($amount)',
    );
    return '$_temp0';
  }

  @override
  String get generateNow => 'تسجيل';

  @override
  String get expensesOfMonth => 'مصاريف الشهر';

  @override
  String vsLastMonth(String value) {
    return '$value مقارنة بالشهر الماضي';
  }

  @override
  String get lastMonthLabel => 'الشهر الماضي';

  @override
  String get recurringTab => 'متكررة';

  @override
  String get budgetsExceeded => 'ميزانيات متجاوزة';

  @override
  String get expensesSixMonths => 'مصاريف الأشهر الستة الأخيرة';

  @override
  String get budgetsTab => 'الميزانيات';

  @override
  String get noBudgetsYet => 'لا ميزانية محددة. أضفها في تبويب الميزانيات.';

  @override
  String get newRecurringExpense => 'مصروف متكرر جديد';

  @override
  String get recurringHint =>
      'الإيجار، الاشتراكات، الرواتب…: تُسجل كل شهر بلمسة من النظرة العامة.';

  @override
  String get noRecurringYet => 'لا مصاريف متكررة.';

  @override
  String everyMonthOn(int day) {
    return 'كل شهر في اليوم $day';
  }

  @override
  String get recurringExample => 'مثال: إيجار المحل';

  @override
  String get expenseCategoryField => 'الفئة';

  @override
  String get dayOfMonthLabel => 'يوم الشهر';

  @override
  String get budgetsHint =>
      'مبلغ لا يُتجاوز كل شهر لكل فئة. اتركه فارغًا لعدم متابعة الفئة.';

  @override
  String get startTitle => 'بداية جيدة';

  @override
  String startProgress(int done, int total) {
    return '$done من $total خطوات مكتملة';
  }

  @override
  String get startProfile => 'أكمل بطاقة المطعم (العنوان، الهاتف، الشعار)';

  @override
  String get startDishes => 'أضف أطباقك ومشروباتك';

  @override
  String get startTables => 'أنشئ طاولاتك';

  @override
  String get startPayments => 'تحقق من وسائل الدفع';

  @override
  String get startTeam => 'ادعُ فريقك';

  @override
  String get startPublish => 'انشر مطعمك للزبائن';

  @override
  String get hideAction => 'إخفاء';
}
