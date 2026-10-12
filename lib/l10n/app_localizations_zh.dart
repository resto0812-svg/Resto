// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appName => 'Resto';

  @override
  String environmentBanner(String env) {
    return '环境：$env';
  }

  @override
  String get configMissingTitle => '缺少配置';

  @override
  String get configMissingBody => '未提供服务器地址和公钥（env/<环境>.json 文件）。';

  @override
  String get languageLabel => '语言';

  @override
  String get systemLanguage => '设备语言';

  @override
  String pendingSyncEvents(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 项操作待同步',
      zero: '全部已同步',
    );
    return '$_temp0';
  }

  @override
  String get errorNotAuthenticated => '请登录。';

  @override
  String get errorForbidden => '您无权执行此操作。';

  @override
  String get errorOwnerOnly => '只有所有者才能执行此操作。';

  @override
  String get errorRateLimited => '请求过多，请稍后再试。';

  @override
  String get errorInvalidTimezone => '未知时区。';

  @override
  String get errorInvalidRole => '未知角色。';

  @override
  String get errorInvalidEmail => '电子邮件地址无效。';

  @override
  String get errorInvalidBranch => '在此组织中找不到该门店。';

  @override
  String get errorBranchesRequired => '请至少选择一个门店。';

  @override
  String get errorAlreadyMember => '此人已是该组织的成员。';

  @override
  String get errorInvitationInvalid => '邀请无效、已过期或已被使用。';

  @override
  String get errorInvitationWrongAccount => '此邀请是发给另一个电子邮件地址的。';

  @override
  String get errorLastOwner => '组织必须至少保留一名所有者。';

  @override
  String get errorMembershipRevoked => '该成员已被移出组织。';

  @override
  String get errorNetwork => '无法连接，请检查您的网络。';

  @override
  String get errorUnknown => '发生意外错误。';

  @override
  String get welcomeTitle => '欢迎使用 Resto';

  @override
  String get signInTitle => '登录';

  @override
  String get signIn => '登录';

  @override
  String get signOut => '退出登录';

  @override
  String get createAccount => '创建账户';

  @override
  String get forgotPassword => '忘记密码';

  @override
  String get email => '电子邮件';

  @override
  String get password => '密码';

  @override
  String get passwordConfirm => '确认密码';

  @override
  String get passwordTooShort => '至少 8 个字符。';

  @override
  String get passwordsDiffer => '两次输入的密码不一致。';

  @override
  String get passwordChanged => '密码已更改。';

  @override
  String get newPasswordTitle => '新密码';

  @override
  String get changePassword => '更改密码';

  @override
  String get displayName => '姓名';

  @override
  String get fieldRequired => '必填项';

  @override
  String get verifyEmailTitle => '确认您的电子邮件地址';

  @override
  String codeSentTo(String email) {
    return '验证码已发送至 $email。';
  }

  @override
  String get code => '验证码';

  @override
  String get verify => '确认';

  @override
  String get resendCode => '重新发送验证码';

  @override
  String get codeResent => '新的验证码已发送。';

  @override
  String get sendCode => '发送验证码';

  @override
  String get authInvalidCredentials => '电子邮件或密码不正确。';

  @override
  String get authEmailNotConfirmed => '电子邮件地址尚未确认。';

  @override
  String get authUserExists => '该地址已注册账户。';

  @override
  String get authWeakPassword => '密码强度太弱。';

  @override
  String get authCodeInvalid => '验证码无效或已过期。';

  @override
  String get authSamePassword => '新密码必须与旧密码不同。';

  @override
  String get errorDuplicate => '该值已存在。';

  @override
  String get errorInvalidHours => '营业时间无效。';

  @override
  String get createRestaurant => '创建我的餐厅';

  @override
  String get joinTeam => '加入团队';

  @override
  String get organizationName => '组织名称';

  @override
  String get brandNameOptional => '商号（可选）';

  @override
  String get branchNameOptional => '门店名称（可选）';

  @override
  String get country => '国家/地区';

  @override
  String get currency => '货币';

  @override
  String get timezone => '时区';

  @override
  String get defaultLanguage => '主要语言';

  @override
  String get city => '城市';

  @override
  String get create => '创建';

  @override
  String get invitationCode => '邀请码';

  @override
  String get join => '加入';

  @override
  String get navBranches => '门店';

  @override
  String get navTeam => '团队';

  @override
  String get navAudit => '日志';

  @override
  String get navAccount => '账户';

  @override
  String get switchOrganization => '切换组织';

  @override
  String get orgSuspended => '组织已暂停：仅可查看。';

  @override
  String get newBranch => '新门店';

  @override
  String get noBranches => '暂无门店。';

  @override
  String get branchInfo => '信息';

  @override
  String get openingHours => '营业时间';

  @override
  String get floor => '餐厅区域';

  @override
  String get name => '名称';

  @override
  String get addressLine1 => '地址';

  @override
  String get addressLine2 => '地址补充';

  @override
  String get region => '省/州';

  @override
  String get postalCode => '邮政编码';

  @override
  String get phone => '电话';

  @override
  String get offeredLanguages => '提供的语言';

  @override
  String get published => '对顾客可见';

  @override
  String get archived => '已归档';

  @override
  String get readOnly => '仅可查看';

  @override
  String get save => '保存';

  @override
  String get saved => '已保存。';

  @override
  String get cancel => '取消';

  @override
  String get confirm => '确认';

  @override
  String get close => '关闭';

  @override
  String get edit => '编辑';

  @override
  String get retry => '重试';

  @override
  String get closed => '休息';

  @override
  String get addSlot => '添加时段';

  @override
  String get opensAt => '开始营业';

  @override
  String get closesAt => '结束营业';

  @override
  String get nextDay => '次日';

  @override
  String get weekday1 => '星期一';

  @override
  String get weekday2 => '星期二';

  @override
  String get weekday3 => '星期三';

  @override
  String get weekday4 => '星期四';

  @override
  String get weekday5 => '星期五';

  @override
  String get weekday6 => '星期六';

  @override
  String get weekday7 => '星期日';

  @override
  String get newArea => '新区域';

  @override
  String get areaName => '区域';

  @override
  String get noAreas => '暂无区域。';

  @override
  String get newTable => '新餐桌';

  @override
  String get tableLabel => '餐桌名称';

  @override
  String get seats => '座位';

  @override
  String get active => '启用';

  @override
  String get inactive => '已停用';

  @override
  String tablesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 张餐桌',
      zero: '无餐桌',
    );
    return '$_temp0';
  }

  @override
  String seatsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 个座位',
    );
    return '$_temp0';
  }

  @override
  String get invite => '邀请';

  @override
  String get role => '角色';

  @override
  String get allBranches => '所有门店';

  @override
  String get pendingInvitations => '待处理的邀请';

  @override
  String expiresOn(String date) {
    return '$date 到期';
  }

  @override
  String get revoke => '移除';

  @override
  String revokeConfirm(String name) {
    return '将 $name 移出组织？';
  }

  @override
  String get changeRole => '更改角色';

  @override
  String get you => '您';

  @override
  String get invitationCreatedTitle => '邀请已创建';

  @override
  String invitationCreatedBody(String email) {
    return '请将此邀请码发送给 $email。有效期 7 天，仅适用于该地址。';
  }

  @override
  String invitationMessage(String organization, String code) {
    return '您受邀在 Resto 上加入“$organization”。请使用此电子邮件地址创建账户，然后在“加入团队”中输入此邀请码：$code';
  }

  @override
  String get copyMessage => '复制消息';

  @override
  String get copied => '已复制。';

  @override
  String get roleOwner => '所有者';

  @override
  String get roleAdmin => '管理员';

  @override
  String get roleManager => '店长';

  @override
  String get roleAccountant => '会计';

  @override
  String get roleCashier => '收银员';

  @override
  String get roleStockKeeper => '库管员';

  @override
  String get roleWaiter => '服务员';

  @override
  String get roleKitchen => '厨房 / 吧台';

  @override
  String get roleViewer => '查看者';

  @override
  String get loadMore => '显示更多';

  @override
  String get noEntries => '暂无操作记录。';

  @override
  String get actionInsert => '创建';

  @override
  String get actionUpdate => '修改';

  @override
  String get actionDelete => '删除';

  @override
  String get entityOrganization => '组织';

  @override
  String get entityMembership => '成员';

  @override
  String get entityInvitation => '邀请';

  @override
  String get entityBrand => '品牌';

  @override
  String get entityBranch => '门店';

  @override
  String get entityArea => '区域';

  @override
  String get entityTable => '餐桌';

  @override
  String get navMenus => '菜单';

  @override
  String get brand => '品牌';

  @override
  String get category => '分类';

  @override
  String get description => '描述';

  @override
  String get newCategory => '新分类';

  @override
  String get kindFood => '菜品';

  @override
  String get kindDrink => '饮品';

  @override
  String get kindOther => '其他';

  @override
  String selectionRule(int min, String max) {
    return '选择：$min 至 $max';
  }

  @override
  String get allergens => '过敏原';

  @override
  String get allergenGluten => '麸质';

  @override
  String get allergenCrustaceans => '甲壳类';

  @override
  String get allergenEggs => '蛋类';

  @override
  String get allergenFish => '鱼类';

  @override
  String get allergenPeanuts => '花生';

  @override
  String get allergenSoybeans => '大豆';

  @override
  String get allergenMilk => '乳制品';

  @override
  String get allergenNuts => '坚果';

  @override
  String get allergenCelery => '芹菜';

  @override
  String get allergenMustard => '芥末';

  @override
  String get allergenSesame => '芝麻';

  @override
  String get allergenSulphites => '亚硫酸盐';

  @override
  String get allergenLupin => '羽扇豆';

  @override
  String get allergenMolluscs => '软体动物';

  @override
  String get translations => '翻译';

  @override
  String get soldOut => '售罄';

  @override
  String get channelDefault => '基础价格';

  @override
  String get channelDineIn => '堂食';

  @override
  String get channelTakeaway => '外带';

  @override
  String get channelDelivery => '外送';

  @override
  String get otherChannels => '按渠道定价';

  @override
  String get noPrice => '无价格';

  @override
  String get errorInvalidPrice => '价格无效。';

  @override
  String get errorCurrencyLocked => '货币无法再更改：该门店已有价格。';

  @override
  String get entityItem => '菜品';

  @override
  String get entityVariant => '规格';

  @override
  String get entityModifier => '加料';

  @override
  String get entityPrice => '价格';

  @override
  String get menuOfBranch => '门店菜单';

  @override
  String get menuEmptyTitle => '您的菜单还是空的';

  @override
  String get menuEmptyHint => '先创建一个分类（例如：菜品、饮品、甜点），再添加菜品及其价格。';

  @override
  String get categoryExamples => '例如：菜品、饮品、甜点';

  @override
  String get descriptionOptional => '描述（可选）';

  @override
  String get visibleOnMenu => '在菜单上显示';

  @override
  String get hidden => '已隐藏';

  @override
  String get addItem => '添加菜品';

  @override
  String addItemIn(String category) {
    return '在“$category”中添加菜品';
  }

  @override
  String get notSoldHere => '本门店未售卖';

  @override
  String get itemName => '菜品名称';

  @override
  String get itemExamples => '例如：恩多莱、DG 鸡、洛神花汁';

  @override
  String get priceTitle => '价格';

  @override
  String priceAt(String branch) {
    return '$branch 的价格';
  }

  @override
  String get price => '价格';

  @override
  String get severalSizes => '此菜品有多种规格';

  @override
  String get sizeName => '规格';

  @override
  String get sizeExamples => '例如：小份、33 毫升';

  @override
  String get addSize => '添加规格';

  @override
  String get removeSize => '移除此规格';

  @override
  String get sizeNameRequired => '请为每个规格命名（例如：小份、大份）。';

  @override
  String get samePriceEverywhere => '此价格将适用于下方选择的所有门店，之后可分别调整。';

  @override
  String get salesTitle => '售卖';

  @override
  String soldAt(String branch) {
    return '在 $branch 售卖';
  }

  @override
  String get soldOutToday => '暂时售罄';

  @override
  String get optionsForItem => '提供给顾客的选项';

  @override
  String get manageOptions => '管理选项';

  @override
  String get noOptionsYet => '暂无选项（配菜、熟度、酱料……）。';

  @override
  String get optionsTitle => '选项与加料';

  @override
  String get optionsIntro => '选项是顾客点菜时做出的选择：配菜、熟度、酱料、付费加料……';

  @override
  String get newOptionGroup => '新选项';

  @override
  String get optionGroupName => '选项名称';

  @override
  String get optionGroupExamples => '例如：配菜、熟度、辣度';

  @override
  String get customerMust => '顾客：';

  @override
  String get ruleRequiredOne => '必须选择 1 项（必选）';

  @override
  String get ruleOptionalOne => '可以选择 1 项（可选）';

  @override
  String get ruleOptionalMany => '可以选择多项（可选）';

  @override
  String get ruleRequiredMany => '至少选择 1 项，可多选';

  @override
  String get choices => '可选项';

  @override
  String choicePriceHint(String branch) {
    return '如免费，价格留空或填 0。$branch 的价格。';
  }

  @override
  String get choiceName => '选项';

  @override
  String get choiceExamples => '例如：木薯棒、米饭';

  @override
  String get extraPrice => '加价';

  @override
  String get addChoice => '添加选项';

  @override
  String get removeChoice => '移除此选项';

  @override
  String get choicesRequired => '请至少添加一个选项。';

  @override
  String get navOrders => '订单';

  @override
  String openOrdersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 个进行中的订单',
      zero: '暂无进行中的订单',
    );
    return '$_temp0';
  }

  @override
  String get refresh => '刷新';

  @override
  String get newTakeaway => '外带销售';

  @override
  String get takeawayOrders => '进行中的外带订单';

  @override
  String orderNumber(int number) {
    return '订单 $number 号';
  }

  @override
  String minutesAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 分钟前',
      zero: '刚刚',
    );
    return '$_temp0';
  }

  @override
  String get noTablesYet => '暂无餐桌：请在 门店 → 餐厅区域 中设置。外带销售仍可进行。';

  @override
  String get tableFree => '空闲';

  @override
  String get toSend => '待送厨房的菜品';

  @override
  String tableName(String label) {
    return '$label 号桌';
  }

  @override
  String get menuTab => '菜单';

  @override
  String ticketTab(int count) {
    return '订单（$count）';
  }

  @override
  String get allCategories => '全部';

  @override
  String get nothingToSell => '暂无可售菜品：请在 菜单 中添加带价格的菜品。';

  @override
  String fromPrice(String price) {
    return '$price 起';
  }

  @override
  String itemSoldOut(String name) {
    return '$name 已售罄。';
  }

  @override
  String get emptyTicket => '点击菜单中的菜品即可添加。';

  @override
  String get less => '减一份';

  @override
  String get more => '加一份';

  @override
  String get cancelLine => '取消此行';

  @override
  String get cancelOrder => '取消订单';

  @override
  String get cancelOrderConfirm => '取消此订单？尚未送往厨房。';

  @override
  String get reason => '原因';

  @override
  String get subtotal => '小计';

  @override
  String taxLine(String rate) {
    return '税（$rate%）';
  }

  @override
  String get total => '合计';

  @override
  String taxIncluded(String rate, String amount) {
    return '含税 $rate%：$amount';
  }

  @override
  String sendToKitchen(int count) {
    return '送往厨房（$count）';
  }

  @override
  String sentToKitchen(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '已将 $count 份菜品送往厨房',
    );
    return '$_temp0';
  }

  @override
  String get prepPending => '待送出';

  @override
  String get prepSent => '厨房中';

  @override
  String get prepPreparing => '制作中';

  @override
  String get prepReady => '已完成';

  @override
  String get prepServed => '已上菜';

  @override
  String get prepCancelled => '已取消';

  @override
  String get noneOption => '不需要';

  @override
  String get kitchenNote => '给厨房的备注（可选）';

  @override
  String get kitchenNoteExamples => '例如：不要洋葱、全熟';

  @override
  String get quantity => '数量';

  @override
  String addForPrice(String price) {
    return '添加 · $price';
  }

  @override
  String get taxTitle => '税';

  @override
  String get taxRate => '税率';

  @override
  String get taxRateHint => '例如：19.25（无税填 0）';

  @override
  String get pricesIncludeTax => '显示价格已含税';

  @override
  String get errorInvalidTaxRate => '税率无效（0 至 99.999）。';

  @override
  String get errorOrderNotOpen => '此订单已不再开放。';

  @override
  String get errorItemUnavailable => '此菜品在本门店不可售。';

  @override
  String get errorNoPrice => '此菜品在本门店没有价格。';

  @override
  String get errorOptionsInvalid => '所选选项不符合该菜品的规则。';

  @override
  String get errorInvalidQuantity => '数量无效。';

  @override
  String get errorItemAlreadySent => '此行已送往厨房，无法再修改。';

  @override
  String get errorReasonRequired => '请填写原因。';

  @override
  String get errorInvalidOrder => '订单无效。';

  @override
  String get errorBranchInactive => '此门店已归档。';

  @override
  String get navCash => '收银';

  @override
  String get amount => '金额';

  @override
  String get registerClosed => '已关闭';

  @override
  String get openRegisterShort => '打开收银台';

  @override
  String openRegister(String name) {
    return '打开 $name';
  }

  @override
  String get openingFloat => '备用金（初始零钱）';

  @override
  String registerOpenSince(String time) {
    return '自 $time 起开启';
  }

  @override
  String expectedCash(String amount) {
    return '应有现金：$amount';
  }

  @override
  String cashBreakdown(String float, String inAmount, String outAmount) {
    return '备用金 $float · 存入 $inAmount · 取出 $outAmount';
  }

  @override
  String paymentsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 笔付款',
      zero: '无付款',
    );
    return '$_temp0';
  }

  @override
  String get cashIn => '存入现金';

  @override
  String get cashOut => '取出现金';

  @override
  String get movementExamples => '例如：购买燃气、补充零钱';

  @override
  String get closeRegister => '关闭收银台';

  @override
  String get countedCash => '钱箱内清点的现金';

  @override
  String get countInfo => '清点钱箱内的纸币和硬币，包括备用金。';

  @override
  String get countResult => '清点结果';

  @override
  String countedCashValue(String amount) {
    return '实点：$amount';
  }

  @override
  String get noDifference => '无差额';

  @override
  String differenceValue(String amount) {
    return '差额：$amount';
  }

  @override
  String get awaitingValidation => '现在需要负责人确认此次结账。';

  @override
  String get awaitingValidationTitle => '待确认的结账';

  @override
  String get validateClosing => '确认结账';

  @override
  String get validate => '确认';

  @override
  String get comment => '备注';

  @override
  String get closedSessions => '最近的结账';

  @override
  String get dailyReport => '日报';

  @override
  String get previousDay => '前一天';

  @override
  String get nextDayButton => '后一天';

  @override
  String get salesTotal => '营业额';

  @override
  String get ordersClosedCount => '已付款订单';

  @override
  String get averageTicket => '客单价';

  @override
  String get taxCollected => '已收税额';

  @override
  String get paymentsReceived => '按付款方式收款';

  @override
  String ordersStillOpen(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 个订单仍在进行',
      zero: '无进行中的订单',
    );
    return '$_temp0';
  }

  @override
  String ordersCancelledCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 个已取消',
      zero: '无取消',
    );
    return '$_temp0';
  }

  @override
  String linesCancelledCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 行已取消',
      zero: '无取消的行',
    );
    return '$_temp0';
  }

  @override
  String refundsTotal(String amount) {
    return '已退款：$amount';
  }

  @override
  String get topItems => '最畅销菜品';

  @override
  String get payCash => '现金';

  @override
  String get payCard => '银行卡';

  @override
  String get payMobileMoney => '移动支付';

  @override
  String get payTransfer => '转账';

  @override
  String get payOther => '其他';

  @override
  String get collectPayment => '收款';

  @override
  String collectAmount(String amount) {
    return '收款 $amount';
  }

  @override
  String amountDue(String amount) {
    return '待付：$amount';
  }

  @override
  String get splitBill => '分摊账单';

  @override
  String splitParts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 份',
    );
    return '$_temp0';
  }

  @override
  String get amountToCollect => '收款金额';

  @override
  String get cashTendered => '顾客所付现金（可选）';

  @override
  String changeToGive(String amount) {
    return '找零：$amount';
  }

  @override
  String get giveChange => '应找零钱';

  @override
  String get transactionReference => '交易号（可选）';

  @override
  String get manualPaymentNote => '银行卡和移动支付：请在确认前核实款项已到账。';

  @override
  String get openCashFirst => '请先打开收银台（收银 栏目）。';

  @override
  String get chooseRegister => '选择收银台';

  @override
  String get orderPaidClosed => '订单已付款并关闭。';

  @override
  String get paid => '已付';

  @override
  String get remainingDue => '待付';

  @override
  String get voided => '已作废';

  @override
  String get voidPayment => '作废此笔付款';

  @override
  String get orderClosed => '订单已付款并关闭';

  @override
  String get orderCancelled => '订单已取消';

  @override
  String get errorNoOpenSession => '没有可用于此次收款的已开启收银台。';

  @override
  String get errorSessionAlreadyOpen => '此收银台已开启。';

  @override
  String get errorRegisterInactive => '此收银台已停用。';

  @override
  String get errorInvalidAmount => '金额无效。';

  @override
  String get errorNotEnoughCash => '收银台现金不足。';

  @override
  String get errorOverpayment => '金额超过待付金额。';

  @override
  String get errorTenderedTooLow => '顾客所付现金少于金额。';

  @override
  String get errorOrderHasPayments => '此订单已有付款：请先作废或退款。';

  @override
  String get errorPendingLines => '部分菜品尚未送往厨房。';

  @override
  String get errorNotFullyPaid => '订单尚未全额付款。';

  @override
  String get errorSessionNotCounted => '此收银台尚未清点。';

  @override
  String get navKitchen => '厨房';

  @override
  String get allStations => '所有工位';

  @override
  String get stations => '制作工位';

  @override
  String get newStation => '新工位';

  @override
  String get stationExamples => '例如：厨房、吧台、烧烤';

  @override
  String get stationPrepares => '此工位制作：';

  @override
  String get kitchenEmpty => '暂时没有需要制作的菜品。';

  @override
  String get allReady => '全部完成';

  @override
  String get markServed => '已上菜';

  @override
  String get errorInvalidStatus => '无法进行此状态变更。';

  @override
  String get navStock => '库存';

  @override
  String get stockLevels => '库存状况';

  @override
  String get ingredientsTab => '原料';

  @override
  String get recipesTab => '标准配方';

  @override
  String get inventoriesTab => '盘点';

  @override
  String get movementsTab => '出入库';

  @override
  String stockValue(String amount) {
    return '库存价值：$amount';
  }

  @override
  String lowStockCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 种原料低于预警值',
    );
    return '$_temp0';
  }

  @override
  String actionsAt(String location) {
    return '库位：$location';
  }

  @override
  String get newLocation => '新库位';

  @override
  String get locationExamples => '例如：冷库、酒窖、厨房';

  @override
  String get chooseLocation => '选择库位';

  @override
  String get toLocation => '调入库位';

  @override
  String get noIngredientsYet => '暂无原料：请在“原料”标签中添加。';

  @override
  String alertAt(String qty) {
    return '预警值 $qty';
  }

  @override
  String avgCost(String amount, String unit) {
    return '平均成本 $amount / $unit';
  }

  @override
  String get alertThreshold => '预警值';

  @override
  String get alertBelow => '低于此值时预警';

  @override
  String get produce => '生产';

  @override
  String get adjustmentQuantity => '调整（+ 或 −）';

  @override
  String unitCost(String unit) {
    return '每$unit成本';
  }

  @override
  String get unitPiece => '个';

  @override
  String get unitDozen => '打';

  @override
  String get newIngredient => '新原料';

  @override
  String get ingredientExamples => '例如：鸡肉、棕榈油、33 厘升可乐瓶';

  @override
  String get ingredientKind => '类型';

  @override
  String get stockUnit => '库存单位';

  @override
  String get ingRaw => '原材料';

  @override
  String get ingBeverage => '饮品';

  @override
  String get ingPackaging => '包装';

  @override
  String get ingSemiFinished => '自制半成品';

  @override
  String get ingConsumable => '耗材';

  @override
  String get mvOpening => '期初库存';

  @override
  String get mvReceipt => '入库（采购）';

  @override
  String get mvSale => '销售';

  @override
  String get mvProductionIn => '生产';

  @override
  String get mvProductionOut => '生产领用';

  @override
  String get mvWaste => '损耗 / 破损';

  @override
  String get mvStaffMeal => '员工餐';

  @override
  String get mvReturn => '退货给供应商';

  @override
  String get mvTransferIn => '调拨入库';

  @override
  String get mvTransferOut => '调拨';

  @override
  String get mvAdjustment => '调整';

  @override
  String get mvInventory => '盘点差异';

  @override
  String get recipesIntro => '标准配方列出菜品的原料：每笔已付款的销售都会自动扣减库存，并计算成本价。';

  @override
  String get noRecipe => '无配方';

  @override
  String costPrice(String amount) {
    return '成本价：$amount';
  }

  @override
  String sellingPrice(String amount) {
    return '售价 $amount';
  }

  @override
  String marginPercent(int percent) {
    return '毛利 $percent%';
  }

  @override
  String recipeOf(String name) {
    return '配方：$name';
  }

  @override
  String get portions => '份数';

  @override
  String get yieldQuantity => '产出数量';

  @override
  String get ingredient => '原料';

  @override
  String get wastePercent => '损耗';

  @override
  String get removeLine => '删除此行';

  @override
  String get addIngredientLine => '添加原料';

  @override
  String get preparationNotes => '制作说明（可选）';

  @override
  String get newInventory => '新盘点';

  @override
  String get inventoriesIntro => '盘点会比较实点库存与计算库存；经负责人确认后记录差异。';

  @override
  String inventoryValidated(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '已确认，$count 项差异',
      zero: '已确认，无差异',
    );
    return '$_temp0';
  }

  @override
  String inventoryDraft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '进行中，已清点 $count 行',
      zero: '进行中，尚未清点',
    );
    return '$_temp0';
  }

  @override
  String inventoryOf(String location) {
    return '盘点：$location';
  }

  @override
  String get inventoryHint => '请填写实际清点的数量。留空的行不会被修改。';

  @override
  String inventoryDifference(String qty) {
    return '差异 $qty';
  }

  @override
  String get search => '搜索';

  @override
  String get validateInventory => '确认盘点';

  @override
  String get validateInventoryConfirm => '确认此次盘点？差异将计入库存，且盘点将无法再修改。';

  @override
  String inventoryAdjustments(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '盘点已确认：已记录 $count 项差异',
      zero: '盘点已确认：无差异',
    );
    return '$_temp0';
  }

  @override
  String get errorInvalidMovement => '库存变动无效。';

  @override
  String get errorUnitLocked => '库存单位无法再更改：此原料已有出入库记录。';

  @override
  String get errorNoRecipe => '此半成品没有配方。';

  @override
  String get errorInvalidRecipe => '配方无效：请检查原料、数量和单位。';

  @override
  String get errorInventoryClosed => '此次盘点已确认。';

  @override
  String get navGroupService => '服务';

  @override
  String get navGroupManagement => '管理';

  @override
  String get navGroupOrganization => '组织';

  @override
  String get navPurchases => '采购';

  @override
  String get navExpenses => '支出';

  @override
  String get navReports => '报表';

  @override
  String get invoicesTab => '发票';

  @override
  String get purchaseOrdersTab => '采购单';

  @override
  String get receiptsTab => '收货';

  @override
  String get suppliersTab => '供应商';

  @override
  String get newSupplier => '新供应商';

  @override
  String get noSuppliersYet => '暂无供应商。请添加常用供应商（市场、批发商、啤酒厂……）。';

  @override
  String get addSupplierFirst => '请先添加供应商（“供应商”标签）。';

  @override
  String get contactName => '联系人';

  @override
  String get taxId => '税号';

  @override
  String get paymentTermsLabel => '付款期限';

  @override
  String get days => '天';

  @override
  String paymentTerms(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days 天内付款',
    );
    return '$_temp0';
  }

  @override
  String get supplier => '供应商';

  @override
  String get supplierOptional => '供应商（可选）';

  @override
  String get newPurchaseOrder => '新采购单';

  @override
  String get noPurchaseOrders => '暂无采购单。采购单用于准备采购；到货时点击“收货”即可入库。';

  @override
  String poNumber(int number) {
    return '采购单 $number 号';
  }

  @override
  String get poDraft => '草稿';

  @override
  String get poSent => '已发送';

  @override
  String get poPartial => '部分到货';

  @override
  String get poReceived => '已到货';

  @override
  String get poCancelled => '已取消';

  @override
  String get poMarkSent => '标记为已发送';

  @override
  String get poReceive => '收货';

  @override
  String get poCancel => '取消采购单';

  @override
  String get cancelPoConfirm => '取消此采购单？';

  @override
  String expectedOn(String date) {
    return '预计 $date 到货';
  }

  @override
  String get expectedDateOptional => '预计到货日期（可选）';

  @override
  String unitPrice(String unit) {
    return '每$unit价格';
  }

  @override
  String totalAmount(String amount) {
    return '合计：$amount';
  }

  @override
  String get newReceipt => '新收货';

  @override
  String get receiptsIntro => '收货用于登记已送达的货物：库存和平均成本会自动更新。';

  @override
  String receiveOrder(int number) {
    return '采购单 $number 号收货';
  }

  @override
  String get receiptHint => '请填写实际送达的数量和价格；保存后即入库。';

  @override
  String get deliveryNoteNumber => '送货单号（可选）';

  @override
  String get recordReceipt => '登记收货';

  @override
  String get receiptRecorded => '收货已登记：库存已更新。';

  @override
  String get newInvoice => '新发票';

  @override
  String get invoicesIntro => '在此登记供应商发票，跟踪应付款和付款情况。';

  @override
  String supplierDebt(String amount) {
    return '应付供应商总额：$amount';
  }

  @override
  String dueOn(String date) {
    return '$date 到期';
  }

  @override
  String remaining(String amount) {
    return '剩余 $amount';
  }

  @override
  String get invoicePaid => '已付';

  @override
  String get invoiceCancelled => '已取消';

  @override
  String get invoiceNumber => '供应商发票号';

  @override
  String invoiceDateValue(String date) {
    return '$date 的发票';
  }

  @override
  String get dueDateOptional => '到期日（可选：按供应商账期）';

  @override
  String get amountExclTax => '不含税金额';

  @override
  String get taxAmount => '税额';

  @override
  String get linkedReceipts => '相关收货';

  @override
  String get attachDocument => '附上凭证（PDF 或照片）';

  @override
  String get fileTooLarge => '文件过大（最大 5 MB）。';

  @override
  String get viewDocument => '查看凭证';

  @override
  String get payInvoice => '付款';

  @override
  String get cancelInvoice => '取消发票';

  @override
  String get paidFromRegister => '用收银台现金支付';

  @override
  String get newExpense => '新支出';

  @override
  String get noExpenses => '本月暂无支出。';

  @override
  String get previousMonth => '上个月';

  @override
  String get nextMonth => '下个月';

  @override
  String includingTax(String amount) {
    return '含税 $amount';
  }

  @override
  String get cancelledLabel => '已取消';

  @override
  String get cancelExpense => '取消支出';

  @override
  String get expenseExamples => '例如：十月电费、冰柜维修';

  @override
  String get amountInclTax => '支付金额';

  @override
  String get includedTaxOptional => '其中税额（可选）';

  @override
  String get expRent => '租金';

  @override
  String get expElectricity => '电费';

  @override
  String get expWater => '水费';

  @override
  String get expGas => '燃气';

  @override
  String get expSalaries => '工资';

  @override
  String get expTransport => '交通运输';

  @override
  String get expMaintenance => '维护与维修';

  @override
  String get expMarketing => '广告';

  @override
  String get expSupplies => '办公及杂项用品';

  @override
  String get expTaxes => '税费';

  @override
  String get expBankFees => '银行手续费';

  @override
  String get expOther => '其他';

  @override
  String get periodToday => '今天';

  @override
  String get periodLast7 => '最近 7 天';

  @override
  String get periodMonth => '本月';

  @override
  String get periodLastMonth => '上月';

  @override
  String get periodCustom => '其他时段…';

  @override
  String get salesInclTax => '含税营业额';

  @override
  String get salesExclTax => '不含税营业额';

  @override
  String get collected => '实收款';

  @override
  String get costOfSales => '销售成本';

  @override
  String get grossMargin => '毛利';

  @override
  String get lossesValue => '损耗与差异';

  @override
  String get expensesExclTax => '不含税支出';

  @override
  String get estimatedResult => '估算利润';

  @override
  String get purchasesValue => '采购（不含税发票）';

  @override
  String get supplierDebtShort => '应付供应商';

  @override
  String ordersCountShort(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 个订单',
      zero: '无订单',
    );
    return '$_temp0';
  }

  @override
  String get ruleSales => '期间内已付款并关闭的订单总额（按营业日）。';

  @override
  String get ruleSalesHt => '含税营业额减去已收税额。';

  @override
  String get ruleCollected => '期间内实际收到的款项（所有方式）减去退款。可能与营业额不同（预付款、未结订单）。';

  @override
  String get ruleCogs => '根据标准配方和平均采购成本计算的销售消耗原料价值。无配方的菜品不计入。';

  @override
  String get ruleGrossMargin => '不含税营业额减去销售成本。';

  @override
  String get ruleLosses => '损耗、员工餐、调整和盘点差异的价值。';

  @override
  String get ruleExpenses => '期间内登记的不含税支出（不含已取消的支出）。';

  @override
  String get ruleResult => '毛利减去损耗和支出。管理估算，不含折旧或未登记的费用：并非会计利润。';

  @override
  String get rulePurchases => '期间内日期的供应商发票（不含税）。采购计入库存：消耗前不算成本。';

  @override
  String get ruleDebt => '截至今日未结供应商发票的待付金额。';

  @override
  String get expensesByCategory => '按类别统计的支出（不含税）';

  @override
  String get resultDisclaimer =>
      '这些数据根据 Resto 中登记的业务计算：销售、收款、理论消耗、支出。将鼠标悬停在 ⓘ 上可查看每项指标的计算规则。';

  @override
  String get exportsTitle => '导出（CSV 文件，可用 Excel 打开）';

  @override
  String get exportOrders => '订单';

  @override
  String get exportPayments => '付款';

  @override
  String get exportExpenses => '支出';

  @override
  String get exportDownloaded => '文件已下载。';

  @override
  String get exportCopied => '数据已复制：请粘贴到电子表格中。';

  @override
  String get marginsByItem => '各菜品毛利';

  @override
  String marginsHint(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 道菜品尚无标准配方（库存 → 标准配方）。',
      zero: '所有已售菜品都有标准配方。',
    );
    return '$_temp0';
  }

  @override
  String get errorInvalidPurchase => '采购信息不完整：请检查供应商、原料、数量、单位和价格。';

  @override
  String get errorPurchaseNotDraft => '此采购单已无法修改。';

  @override
  String get errorDuplicateInvoice => '该供应商的此张发票已登记。';

  @override
  String get errorInvoiceNotOpen => '此发票已不再开放。';

  @override
  String get errorInvoiceHasPayments => '此发票已有付款：请先作废付款。';

  @override
  String get errorInvalidExpense => '支出信息不完整：类别、说明和金额为必填项；税额不能超过金额。';

  @override
  String get errorInvalidAttachment => '凭证被拒绝。';

  @override
  String get errorInvalidPeriod => '时段无效。';

  @override
  String get errorBelowMinimum => '未达到最低订单金额。';

  @override
  String get errorDeliveryUnavailable => '无法配送：请检查地址和电话，或选择“外带”。';

  @override
  String get errorInvalidImage => '照片被拒绝（格式或位置无效）。';

  @override
  String get errorNotFound => '未找到。';

  @override
  String get errorOnlineOrdersClosed => '该餐厅目前不接受在线订单。';

  @override
  String get errorTooLateToCancel => '为时已晚：餐厅已开始处理该订单。';

  @override
  String get errorReviewNotAllowed => '无法评价：只有 30 天内已付款的订单可评价一次。';

  @override
  String get errorReservationsClosed => '该餐厅不接受在线预订。';

  @override
  String get errorInvalidPartySize => '在线预订不接受该人数。';

  @override
  String get errorInvalidReservationTime => '时间无效：至少提前 15 分钟，最多 90 天内。';

  @override
  String get errorInvalidReservation => '预订信息不完整：需要姓名、电话和人数。';

  @override
  String get errorTablesRequired => '请至少选择一张桌子。';

  @override
  String get errorNotEnoughSeats => '所选桌子座位不足。';

  @override
  String get errorTableUnavailable => '该桌在此时段已被预订。';

  @override
  String get errorPromotionUnavailable => '优惠或代码无效。';

  @override
  String get errorPromotionLimit => '该顾客已达到此优惠的使用次数上限。';

  @override
  String get errorPromotionAlreadyApplied => '已应用于此订单。';

  @override
  String get errorNotEnoughPoints => '积分不足。';

  @override
  String get errorAddressRequired => '必须填写配送地址。';

  @override
  String get errorTableBusy => '该桌已有进行中的订单。';

  @override
  String errorBetween(int min, int max) {
    return '介于 $min 和 $max 之间';
  }

  @override
  String get notPublishedHint => '该门店尚未对顾客可见：请在“信息”标签中开启“已发布”。';

  @override
  String get onlineOrdersTitle => '在线订单';

  @override
  String get acceptOnlineOrders => '接受顾客订单';

  @override
  String get acceptOnlineOrdersHint => '来自应用、网站或桌台二维码。每个订单都会进入“订单”等待接受。';

  @override
  String get acceptDelivery => '提供外送';

  @override
  String get deliveryFee => '配送费';

  @override
  String get minimumOrder => '最低订单金额';

  @override
  String get reservationsTitle => '预订';

  @override
  String get acceptReservations => '接受在线预订';

  @override
  String get reservationDuration => '预订时长';

  @override
  String get minutesShort => '分钟';

  @override
  String get maxPartySize => '最多人数';

  @override
  String get publicProfileTitle => '餐厅公开资料';

  @override
  String get publicDescription => '简介';

  @override
  String get publicDescriptionHint => '例如：丰盛的喀麦隆菜、每日炭烤鱼、树荫露台。';

  @override
  String get cuisinesLabel => '菜系';

  @override
  String get cuisinesHint => '例如：非洲菜、烧烤、海鲜（用逗号分隔）';

  @override
  String get priceLevel => '价格档次';

  @override
  String get publicPageTitle => '餐厅页面';

  @override
  String get publicPageHint => '可分享（社交网络、WhatsApp）或打印：顾客在此查看菜单并下单。';

  @override
  String get copyLink => '复制链接';

  @override
  String get sourcePhone => '电话订单';

  @override
  String get sourceQr => '桌台二维码';

  @override
  String get sourceApp => '顾客应用';

  @override
  String get sourcePartner => '合作伙伴';

  @override
  String get sourceStaff => '店内点单';

  @override
  String get stageToValidate => '待确认';

  @override
  String get stageDraft => '尚未发送';

  @override
  String get stageCooking => '制作中';

  @override
  String get stageReady => '可上菜';

  @override
  String get stageReadyTakeaway => '待取餐';

  @override
  String get stageReadyDelivery => '待骑手取餐';

  @override
  String get stageToPay => '待收款';

  @override
  String get stageDone => '已完成';

  @override
  String get stageCancelled => '已取消';

  @override
  String get handToCustomer => '已交给顾客';

  @override
  String get handToCourier => '已交给骑手';

  @override
  String guestsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 人',
    );
    return '$_temp0';
  }

  @override
  String forTime(String time) {
    return '$time 取';
  }

  @override
  String get billTitle => '账单';

  @override
  String get thankYou => '感谢光临！';

  @override
  String kdsToPrepare(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 个订单待制作',
      zero: '无待制作',
    );
    return '$_temp0';
  }

  @override
  String kdsLate(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 个超时',
    );
    return '$_temp0';
  }

  @override
  String kdsReadyCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 个已完成',
      zero: '无已完成',
    );
    return '$_temp0';
  }

  @override
  String get kdsTickets => '小票';

  @override
  String get kdsSummary => '汇总';

  @override
  String get kdsFullScreen => '全屏（厨房模式）';

  @override
  String get kdsFlowHint =>
      '前厅发送的订单会伴随提示音出现在这里。点击菜品将其设为“制作中”，再设为“已完成”。“全部完成”会立即通知服务员。';

  @override
  String get kdsReadyStrip => '已完成 — 已通知前厅（“可上菜”栏），等待上菜';

  @override
  String get kdsStart => '开始';

  @override
  String kdsWaitingService(String time) {
    return '已等待 $time';
  }

  @override
  String get kdsRecall => '撤回（尚未完成）';

  @override
  String get serviceAndCustomers => '服务与顾客';

  @override
  String get serviceSettingsTitle => '服务';

  @override
  String get targetPrepTime => '目标制作时间';

  @override
  String get targetPrepTimeHint => '超过此时间，订单变为红色（超时）。';

  @override
  String get payFirstTakeaway => '外带：制作前先收款';

  @override
  String get payFirstTakeawayHint => '外带订单上会出现“先收款再发送”按钮。';

  @override
  String get tableOccupied => '已占用';

  @override
  String get tableReservedNow => '当前已预订';

  @override
  String get tableReservedSoon => '即将预订';

  @override
  String reservedAt(String time) {
    return '$time 已预订';
  }

  @override
  String get acceptWithDelay => '接受订单';

  @override
  String scheduledFor(String time) {
    return '要求 $time';
  }

  @override
  String get delayAnnounced => '多久能做好？系统会通知顾客。';

  @override
  String get orderAccepted => '订单已接受：开始制作。';

  @override
  String get rejectOrder => '拒绝订单';

  @override
  String get rejectReasonHint => '例如：鱼已售罄、没有骑手';

  @override
  String get paymentDone => '已记录付款。';

  @override
  String get partialPaymentDone => '已记录部分付款。';

  @override
  String get announcedDelay => '告知顾客的时长';

  @override
  String promisedFor(String time) {
    return '承诺 $time';
  }

  @override
  String get heldShort => '稍后';

  @override
  String moreItems(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '+ 另外 $count 项',
    );
    return '$_temp0';
  }

  @override
  String get paidShort => '已付款';

  @override
  String get partlyPaid => '部分付款';

  @override
  String get notPaid => '未付款';

  @override
  String get reject => '拒绝';

  @override
  String get accept => '接受';

  @override
  String get sendShort => '发送';

  @override
  String get fireNext => '上下一道';

  @override
  String get collectShort => '收款';

  @override
  String get columnInProgress => '进行中';

  @override
  String get columnReady => '可上菜';

  @override
  String get columnToValidateHint => '顾客下的订单（应用、网站、桌台二维码）会伴随提示音出现在这里。请告知时长并接受。';

  @override
  String get columnInProgressHint => '已点单并正在制作。“发送”会把菜品送到厨房和吧台。';

  @override
  String get columnReadyHint => '厨房点击“全部完成”后，订单会出现在这里（伴随提示音）：上桌、交给顾客或骑手。';

  @override
  String get columnToPayHint => '全部已上：只剩收款。付款后订单完成，桌子空出。';

  @override
  String get allOrders => '全部';

  @override
  String get searchOrderHint => '编号、顾客、桌号、电话';

  @override
  String get chooseTable => '选择桌子';

  @override
  String get tableHasOrder => '该桌已有进行中的订单：将打开该订单。';

  @override
  String tableReservationWarning(String time, String name, int count) {
    return '注意：$time 已预订 · $name · $count 人';
  }

  @override
  String get guestsLabel => '人数';

  @override
  String get receivedByPhone => '电话收到的订单';

  @override
  String get customerName => '顾客姓名';

  @override
  String get customerNameOptional => '顾客姓名（可选）';

  @override
  String get phoneOptional => '电话（可选）';

  @override
  String get deliveryAddress => '配送地址';

  @override
  String get deliveryAddressHint => '街区、街道、地标（例如：Bonamoussadi，药店旁）';

  @override
  String get deliveryInstructions => '给骑手的说明';

  @override
  String get deliveryInstructionsHint => '例如：黄色大楼，二楼，到达时来电';

  @override
  String get deliveryTime => '配送时间';

  @override
  String get pickupTime => '取餐时间';

  @override
  String get asap => '尽快';

  @override
  String get atFixedTime => '指定时间';

  @override
  String atTime(String time) {
    return '$time';
  }

  @override
  String get newOrder => '新订单';

  @override
  String get orderTypeQuestion => '哪种订单？';

  @override
  String get dineInHint => '顾客在桌台就座';

  @override
  String get takeawayHint => '顾客带走订单';

  @override
  String get deliveryHint => '送到指定地址';

  @override
  String get orderNote => '订单备注（可选）';

  @override
  String get orderNoteHint => '例如：生日、顾客赶时间、花生过敏';

  @override
  String get continueToMenu => '继续：选择菜品';

  @override
  String get moveTable => '换桌';

  @override
  String get noFreeTable => '目前没有空桌。';

  @override
  String get print => '打印';

  @override
  String get printKitchenTicket => '制作单（厨房）';

  @override
  String get printBill => '账单（顾客）';

  @override
  String get orderHistory => '订单记录';

  @override
  String get searchDish => '搜索菜品、饮品…';

  @override
  String get noResults => '无结果。';

  @override
  String get groupToSend => '待发送';

  @override
  String get groupHeld => '稍后（之后发送）';

  @override
  String get groupCooking => '制作中';

  @override
  String get groupReady => '可上菜';

  @override
  String get groupServed => '已上';

  @override
  String get groupCancelled => '已取消';

  @override
  String collectThenSend(String amount) {
    return '收款 $amount 后发送';
  }

  @override
  String fireNextCount(int count) {
    return '上下一道（$count）';
  }

  @override
  String get customerOrderToValidate => '待确认的顾客订单';

  @override
  String get customerOrderToValidateHint => '核对菜品后接受（并告知时长）或拒绝。系统会通知顾客。';

  @override
  String get payFirstHint => '外带：制作前付款（门店设置）。';

  @override
  String get addedByCustomer => '顾客添加';

  @override
  String get sendWithOrder => '与其余一起发送';

  @override
  String get holdForLater => '设为“稍后”（之后发送）';

  @override
  String openedAt(String time) {
    return '$time 开单';
  }

  @override
  String get fromReservation => '顾客已入座（预订）';

  @override
  String get editOrderDetails => '修改信息';

  @override
  String get evOpened => '订单已开';

  @override
  String evItemAdded(String item) {
    return '添加：$item';
  }

  @override
  String get evItemUpdated => '菜品已修改';

  @override
  String get evItemRemoved => '菜品已移除';

  @override
  String evSent(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '已发送到厨房（$count 项）',
    );
    return '$_temp0';
  }

  @override
  String get evItemCancelled => '菜品已取消';

  @override
  String get evCancelled => '订单已取消';

  @override
  String get evClosed => '订单已完成';

  @override
  String evPayment(String amount) {
    return '付款 $amount';
  }

  @override
  String get evRefund => '退款';

  @override
  String get evDetailsUpdated => '信息已修改';

  @override
  String get itemsTotal => '菜品';

  @override
  String get removeDiscount => '移除折扣';

  @override
  String get addDiscount => '添加折扣';

  @override
  String get applyPromotion => '应用优惠';

  @override
  String get promoCode => '优惠码';

  @override
  String get promoCodeHint => '例如：WELCOME10';

  @override
  String get manualDiscount => '折扣（商业让利）';

  @override
  String get useLoyalty => '使用积分';

  @override
  String get noActivePromotion => '暂无进行中的优惠。请在“顾客与会员”中创建。';

  @override
  String get inPercent => '按 %';

  @override
  String get inAmount => '按金额';

  @override
  String get percentValue => '百分比';

  @override
  String get manualDiscountHint => '例如：等待过久、老顾客';

  @override
  String get apply => '应用';

  @override
  String get allAreas => '所有区域';

  @override
  String get planView => '平面图';

  @override
  String get cardsView => '卡片';

  @override
  String get editFloor => '编辑餐厅布局';

  @override
  String get done => '完成';

  @override
  String get floorEmptyTitle => '创建您的餐厅布局';

  @override
  String get floorEmptyHint =>
      '先添加区域（大厅、露台、VIP…），再按您喜欢的名称添加桌子（1 号桌、VIP 1、吧台 2…）。之后即可实时查看哪些桌子空闲、占用或已预订。';

  @override
  String get editFloorHint => '拖动桌子以还原您的餐厅布局。点击桌子可修改名称、座位或形状。';

  @override
  String get noTablesInArea => '该区域没有桌子：点击“编辑餐厅布局”，再点“新建桌子”。';

  @override
  String get newOrderAtTable => '在此桌新建订单';

  @override
  String get openOrder => '打开订单';

  @override
  String get reservationsToday => '今日预订';

  @override
  String get reserveTable => '预订';

  @override
  String get noReservationToday => '此桌今天没有预订。';

  @override
  String get tableQrCode => '桌台二维码';

  @override
  String get tableQrHint => '打印后放在桌上：顾客扫码即可查看带图片的菜单并下单。订单会进入“待确认”。';

  @override
  String get areaNameHint => '例如：大厅、露台、VIP、楼上';

  @override
  String get tableLabelHint => '例如：1 号桌、VIP 1、吧台 2';

  @override
  String get tableShape => '形状';

  @override
  String get shapeSquare => '方形';

  @override
  String get shapeRound => '圆形';

  @override
  String get shapeRect => '长方形';

  @override
  String get resRequested => '已申请';

  @override
  String get resConfirmed => '已确认';

  @override
  String get resSeated => '已入座';

  @override
  String get resCompleted => '已完成';

  @override
  String get resNoShow => '未到店';

  @override
  String get resDeclined => '已拒绝';

  @override
  String get resCancelled => '已取消';

  @override
  String reservationRequests(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 个预订申请待处理',
    );
    return '$_temp0';
  }

  @override
  String get reservationRequestsHint => '顾客在线提交的申请：选择桌子确认，或说明原因拒绝。系统会通知顾客。';

  @override
  String get declineReservation => '拒绝预订';

  @override
  String get confirmReservation => '确认';

  @override
  String reservationsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 个预订',
      zero: '无预订',
    );
    return '$_temp0';
  }

  @override
  String coversCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 位',
    );
    return '$_temp0';
  }

  @override
  String get noReservationsDay => '当天没有预订。';

  @override
  String get today => '今天';

  @override
  String get timelineView => '时间轴';

  @override
  String get listView => '列表';

  @override
  String get newReservation => '新预订';

  @override
  String get nowLabel => '现在';

  @override
  String get seatGuests => '安排入座';

  @override
  String get changeTables => '更换桌子';

  @override
  String get markNoShow => '未到店';

  @override
  String get cancelReservation => '取消预订';

  @override
  String get markCompleted => '已完成';

  @override
  String get chooseTables => '桌子';

  @override
  String seatsForParty(int seats, int party) {
    return '已为 $party 人选择 $seats 个座位';
  }

  @override
  String get reservationNoteHint => '例如：生日、儿童椅、靠窗';

  @override
  String get noFreeTableSlot => '该时段没有空桌：请更改时间或时长。';

  @override
  String itemsCountLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 项',
      zero: '无菜品',
    );
    return '$_temp0';
  }

  @override
  String get alertNewCustomerOrder => '有新的顾客订单待确认';

  @override
  String get alertOrderReady => '有订单可以上菜';

  @override
  String get view => '查看';

  @override
  String ordersToValidateBanner(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 个顾客订单等待您确认',
    );
    return '$_temp0';
  }

  @override
  String get tabInProgress => '进行中';

  @override
  String get historyTab => '记录';

  @override
  String get newShort => '新建';

  @override
  String get brandPoint1 => '堂食、外带、外送与在线订单';

  @override
  String get brandPoint2 => '厨房与吧台实时联动，餐厅平面与预订';

  @override
  String get brandPoint3 => '收银、库存、采购与支出';

  @override
  String get brandPoint4 => '仪表板与专业报表';

  @override
  String get authWelcome => '欢迎';

  @override
  String get authWelcomeSub => '登录以返回您的餐厅';

  @override
  String get noAccountYet => '还没有账号？';

  @override
  String get alreadyAccount => '已有账号？';

  @override
  String get authSignUpSub => '只需几秒即可开始，无任何承诺';

  @override
  String get authForgotSub => '通过电子邮件接收验证码以设置新密码';

  @override
  String get authNewPasswordSub => '至少 8 个字符';

  @override
  String get navHome => '首页';

  @override
  String get greetingDay => '您好';

  @override
  String get greetingEvening => '晚上好';

  @override
  String get moreModules => '更多';

  @override
  String freeTablesCount(int free, int total) {
    return '$total 张桌中有 $free 张空闲';
  }

  @override
  String suggestedTable(String label, int seats) {
    return '建议：$label（$seats 座）';
  }

  @override
  String get slotFreeSoon => '届时空出';

  @override
  String get slotReserved => '此时段已预订';

  @override
  String freeAround(String time) {
    return '约 $time 空出';
  }

  @override
  String get timelineEmptyHint => '当天没有预订。点击某张桌子所在行的时间即可预订。';

  @override
  String get myAccount => '我的账户';

  @override
  String get brandTagline => '餐厅管理，流畅而清晰。';

  @override
  String get addPaymentMethod => '添加支付方式';

  @override
  String get allMethods => '所有支付方式';

  @override
  String get availableInBranches => '适用门店';

  @override
  String get availableWorldwide => '全球通用';

  @override
  String get blindCountHint => '请在不查看应有金额的情况下清点钱箱：记录清点后才会显示差额。';

  @override
  String get cashDrawer => '钱箱';

  @override
  String get cashMovementsTitle => '现金存入与取出';

  @override
  String get cashReportTitle => '收银报表';

  @override
  String get cashierLabel => '收银员';

  @override
  String get choosePaymentMethod => '请选择支付方式。';

  @override
  String get closingValidated => '结账已确认：Z 报表已编号。';

  @override
  String get closingsTab => '结账';

  @override
  String get coinsLabel => '硬币';

  @override
  String get collectTab => '收款';

  @override
  String collectWithTip(String amount, String tip) {
    return '收款 $amount + $tip';
  }

  @override
  String get collectedByDay => '每日收款';

  @override
  String get collectedByHour => '每小时收款';

  @override
  String get collectedTotal => '已收款';

  @override
  String commonInCountry(String country) {
    return '您所在国家常用（$country）';
  }

  @override
  String get countByDenomination => '逐张清点';

  @override
  String countConfirm(String amount) {
    return '确认清点金额：$amount？';
  }

  @override
  String get countDetailTitle => '清点明细';

  @override
  String get countRecorded => '清点已记录';

  @override
  String get countedLabel => '已清点';

  @override
  String get countedTotal => '清点总额';

  @override
  String get customMethod => '自定义方式';

  @override
  String get customMethodHint => '例如：店内代金券、会员卡、链接支付';

  @override
  String get dateLabel => '日期';

  @override
  String get differenceLabel => '差额';

  @override
  String get differenceReasonHint => '例如：找零出错、纸币破损';

  @override
  String get discountsTotal => '折扣';

  @override
  String get displayOrder => '顺序';

  @override
  String get enterAmount => '输入金额';

  @override
  String get errorPaymentMethodUnavailable => '此处不可使用该支付方式。';

  @override
  String get errorReferenceRequired => '请输入交易号（支付凭证）。';

  @override
  String get exactAmount => '金额正好';

  @override
  String get exportExcel => '导出（表格）';

  @override
  String get exportPdf => '导出 PDF';

  @override
  String get feePercentLabel => '手续费';

  @override
  String feeShort(String percent) {
    return '手续费 $percent %';
  }

  @override
  String get feesEstimate => '手续费（估算）';

  @override
  String get findTicket => '查找小票';

  @override
  String get lastPayments => '最近付款';

  @override
  String get legalNameLabel => '公司名称';

  @override
  String get managerMustValidate => '须由负责人确认结账。';

  @override
  String get methodKind => '类型';

  @override
  String get mySessionTab => '我的收银台';

  @override
  String get newRegister => '新建收银台';

  @override
  String get noActiveRegister => '没有启用的收银台：请在设置中创建。';

  @override
  String get noClosings => '暂无结账记录。';

  @override
  String get noMovements => '暂无现金变动。';

  @override
  String get noPaymentMethod => '没有启用的支付方式：请在设置中添加。';

  @override
  String get noPaymentsYet => '暂无付款。';

  @override
  String get noRefunds => '最近 30 天没有退款。';

  @override
  String get noTip => '不加';

  @override
  String get notesLabel => '纸币';

  @override
  String get nothingToCollect => '目前没有待收款。';

  @override
  String get openRegisterHint => '清点备用金（初始零钱）：作为班次结束清点的基础。';

  @override
  String openRegisterTitle(String register) {
    return '打开 $register';
  }

  @override
  String get openedLabel => '开班';

  @override
  String get orderDetails => '订单详情';

  @override
  String get orderShort => '订单';

  @override
  String get otherAmount => '其他金额';

  @override
  String get otherCountries => '其他国家';

  @override
  String get payKindAccount => '客户账户';

  @override
  String get payKindCheque => '支票';

  @override
  String get payKindInstant => '即时支付';

  @override
  String get payKindVoucher => '代金券';

  @override
  String get payKindWallet => '移动钱包';

  @override
  String get paymentComplete => '付款完成';

  @override
  String get paymentMethodLabel => '支付方式';

  @override
  String get paymentMethodsHint =>
      '收款时提供的支付方式。请根据您的国家调整：名称、是否必须填写交易号、手续费、适用门店。';

  @override
  String get paymentMethodsTitle => '支付方式';

  @override
  String get paymentsCountShort => '付款';

  @override
  String get periodYesterday => '昨天';

  @override
  String get printCountReport => '打印清点单';

  @override
  String get printReceipt => '打印小票';

  @override
  String get reasonChangeFloat => '补充零钱';

  @override
  String get reasonOtherIn => '其他存入';

  @override
  String get reasonOtherOut => '其他取出';

  @override
  String get reasonSafeDrop => '存入保险箱';

  @override
  String get reasonSmallPurchase => '小额采购';

  @override
  String get reasonTipsPaid => '发放给员工的小费';

  @override
  String get receiptFooterHint => '例如：感谢光临，欢迎再来！Wi-Fi：RestoGuest';

  @override
  String get receiptFooterLabel => '小票底部信息';

  @override
  String receiptNumberLabel(int number) {
    return '小票号 $number';
  }

  @override
  String get receiptSettingsHint => '打印在每张顾客小票和 Z 报表上。';

  @override
  String get receiptSettingsTitle => '小票信息';

  @override
  String get receiptShort => '小票';

  @override
  String receiptTaxId(String id) {
    return '税号：$id';
  }

  @override
  String get recentRefunds => '最近退款';

  @override
  String get recordCount => '记录清点';

  @override
  String get referenceRequiredShort => '必须填写交易号';

  @override
  String get refundAction => '退款';

  @override
  String get refundDone => '退款已记录。';

  @override
  String get refundReasonHint => '例如：菜品被退、录入错误';

  @override
  String get refundTitle => '向顾客退款';

  @override
  String refundableAmount(String amount) {
    return '可退：$amount';
  }

  @override
  String get refundsTab => '退款';

  @override
  String get registerClosedHint => '请先打开收银台（清点备用金）再收款。';

  @override
  String get registerClosedTitle => '收银台已关闭';

  @override
  String get registerLabel => '收银台';

  @override
  String get registerNameHint => '例如：前台、露台、吧台';

  @override
  String get registersTitle => '收银台';

  @override
  String get reportsTab => '报表';

  @override
  String get requireReferenceHint => '收银员必须输入交易号（用于与对账单核对）。';

  @override
  String get requireReferenceLabel => '必须填写交易号';

  @override
  String get salesByDay => '按日';

  @override
  String get salesByMethod => '按支付方式';

  @override
  String get salesByRegister => '按收银台';

  @override
  String get salesByStaff => '按服务员';

  @override
  String get searchAction => '搜索';

  @override
  String get searchMethodOrCountry => '支付方式名称或国家代码（例如 BR）';

  @override
  String get sendWhatsApp => '通过 WhatsApp 发送';

  @override
  String get sessionAwaitingValidation => '已清点 — 等待确认';

  @override
  String get settingsTab => '设置';

  @override
  String get shareReceipt => '分享小票';

  @override
  String get signatureCashier => '收银员签名';

  @override
  String get signatureManager => '负责人签名';

  @override
  String someBranchesOnly(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 家门店',
    );
    return '$_temp0';
  }

  @override
  String get splitAll => '全部';

  @override
  String get splitByItems => '按菜品';

  @override
  String get splitByParts => '按份数';

  @override
  String get splitCustom => '自定义金额';

  @override
  String get staffLabel => '服务员';

  @override
  String get statusLabel => '状态';

  @override
  String get taxIdHint => '您所在国家的税务识别号';

  @override
  String get taxIdLabel => '税务识别号';

  @override
  String get ticketOrOrderNumber => '小票号或订单号';

  @override
  String get tipLabel => '小费';

  @override
  String get tipPresetsLabel => '建议百分比';

  @override
  String get tipsEnabledHint => '收款时提供，单独计入（不计营业额），并归属于该订单的服务员。';

  @override
  String get tipsEnabledLabel => '提供小费选项';

  @override
  String get tipsTitle => '小费';

  @override
  String get tipsTotal => '小费';

  @override
  String get toCollectTotal => '待收款';

  @override
  String get transactionReferenceRequired => '交易号（必填）';

  @override
  String get transactionsTab => '交易';

  @override
  String get validateClosingConfirm => '确认此次结账？Z 报表将被编号，且无法再修改。';

  @override
  String get validateNowHint => '请在“结账”标签中确认结账，以获得编号的 Z 报表。';

  @override
  String get validatedLabel => '已确认';

  @override
  String get voidedPayments => '已作废付款';

  @override
  String get xReading => 'X 报表';

  @override
  String get xReportTitle => 'X 报表（临时）';

  @override
  String get zHistory => 'Z 报表记录';

  @override
  String zReportTitle(int number) {
    return 'Z 报表 $number 号';
  }

  @override
  String get zShort => 'Z';

  @override
  String get expectedCashLabel => '应有现金';

  @override
  String get countedAmountLabel => '已清点';

  @override
  String get refundsLabel => '退款';

  @override
  String get addressOptional => '地址（可选）';

  @override
  String get billedTo => '开票对象';

  @override
  String get cancelInvoiceHint => '例如：公司名称错误、客户错误';

  @override
  String get chooseOrder => '选择订单';

  @override
  String get companyOptional => '公司（可选）';

  @override
  String get customerTaxIdOptional => '客户税号（可选）';

  @override
  String get documentsTitle => '单据';

  @override
  String get emailOptional => '电子邮箱（可选）';

  @override
  String get errorCustomerNameRequired => '发票上必须填写客户姓名。';

  @override
  String get invoiceATicket => '为小票开发票';

  @override
  String get invoiceCancelledMention => '发票已作废';

  @override
  String get invoiceCancelledDone => '发票已作废：您可以重新开具。';

  @override
  String invoiceDateLabel(String date) {
    return '日期：$date';
  }

  @override
  String get invoiceDesignation => '项目';

  @override
  String invoiceEmailHint(String email) {
    return '发送至 $email：点击“分享”，然后选择邮件应用。';
  }

  @override
  String get invoiceFooterHint => '例如：付款条件、银行信息、您所在国家的法定信息';

  @override
  String get invoiceFooterLabel => '发票底部信息';

  @override
  String invoiceNumberLabel(String number) {
    return '发票号 $number';
  }

  @override
  String get invoicePayments => '已收款项';

  @override
  String get invoicePrefixHint => '例如：FA-2026-';

  @override
  String get invoicePrefixLabel => '发票号前缀';

  @override
  String get invoiceSettingsTitle => '发票';

  @override
  String get invoiceTitle => '发票';

  @override
  String get invoiceUnitPrice => '单价';

  @override
  String get invoicedTotal => '开票金额';

  @override
  String get invoicesCount => '发票';

  @override
  String get issueInvoice => '开具发票';

  @override
  String get issueInvoiceAction => '开具发票';

  @override
  String get issueInvoiceHint => '已开具的发票会编号且不可修改（如有错误：先作废，再重新开具）。';

  @override
  String get noInvoices => '此期间没有发票。可在订单中点击“发票”开具，或在此处使用“为小票开发票”。';

  @override
  String get printInvoice => '打印 / 下载';

  @override
  String get receiptDocument => '收银小票';

  @override
  String get searchInvoiceHint => '编号、客户、公司';

  @override
  String get shareInvoice => '分享';

  @override
  String get totalExclTax => '不含税合计';

  @override
  String get totalInclTax => '含税合计';

  @override
  String get receiptQrCaption => '扫码在线找到我们';

  @override
  String get receiptQrLabel => '小票底部的二维码';

  @override
  String get receiptQrUrlLabel => '二维码链接';

  @override
  String get receiptQrUrlHint => '留空 = 餐厅页面。例如：https://your-site.com 或您的评价页面';

  @override
  String get receiptQrUrlInvalid => '二维码链接必须以 https://（或 http://）开头。';

  @override
  String get restaurantLogo => '餐厅标志';

  @override
  String get chooseLogo => '选择标志';

  @override
  String get replaceLogo => '更换';

  @override
  String get removeLogo => '移除';

  @override
  String get logoTooBig => '此文件超过 1 MB：请选择更小的图片。';

  @override
  String get receiptTendered => '实收';

  @override
  String get receiptChange => '找零';

  @override
  String get restaurantLogoHint => '打印在小票顶部。建议使用透明背景的 PNG，最大 1 MB。';

  @override
  String get add => '添加';

  @override
  String get delete => '删除';

  @override
  String get branchLabel => '门店';

  @override
  String get kindDessert => '甜点';

  @override
  String get kindMenu => '套餐';

  @override
  String get navAds => '广告';

  @override
  String get navSettings => '设置';

  @override
  String get greetingShort => '您好';

  @override
  String get homeWelcome => '欢迎，这是您今天的经营情况';

  @override
  String get kpiSalesToday => '今日营业额';

  @override
  String get kpiOpenOrders => '进行中的订单';

  @override
  String kpiPendingCount(int count) {
    return '$count 个待处理';
  }

  @override
  String get kpiOccupancy => '上座率';

  @override
  String kpiTablesBusy(int busy, int total) {
    return '$total 张桌中 $busy 张已占用';
  }

  @override
  String get lowStockTitle => '库存不足';

  @override
  String get saveChanges => '保存修改';

  @override
  String get settingsProfile => '餐厅资料';

  @override
  String get settingsProfileHint => '您的餐厅信息，顾客可见。';

  @override
  String get settingsContact => '联系方式与位置';

  @override
  String get settingsContactHint => '地址、电话和地图位置。';

  @override
  String get settingsHours => '营业时间';

  @override
  String get settingsHoursHint => '营业日和时间、备餐时间、临时停业。';

  @override
  String get settingsDelivery => '外送与订单';

  @override
  String get settingsDeliveryHint => '在线订单、外送、预订和公开页面。';

  @override
  String get settingsPayments => '支付与开票';

  @override
  String get settingsPaymentsHint => '支付方式、收银台、小票、发票和小费。';

  @override
  String get settingsTeam => '团队与角色';

  @override
  String get settingsTeamHint => '成员、角色和邀请。';

  @override
  String get settingsNotifications => '通知';

  @override
  String get settingsNotificationsHint => '应用会提醒您的内容。';

  @override
  String get settingsSecurity => '安全';

  @override
  String get settingsSecurityHint => '密码和已登录设备。';

  @override
  String get restaurantName => '餐厅名称';

  @override
  String get sloganLabel => '标语';

  @override
  String get sloganHint => '例如：精致传统美食';

  @override
  String get registrationNumber => '注册号';

  @override
  String get registrationNumberHint => '您所在国家的商业登记号';

  @override
  String get logoUpload => '上传标志';

  @override
  String get logoFormats => 'PNG、JPG 或 WebP — 最大 1 MB。建议 512 × 512。';

  @override
  String get logoWhere => '标志会显示在应用、您的店铺页面和顾客小票上。';

  @override
  String get whatsappLabel => 'WhatsApp 电话';

  @override
  String get gpsTitle => 'GPS 坐标 / 地图';

  @override
  String get latitude => '纬度';

  @override
  String get longitude => '经度';

  @override
  String get gpsMissing => '未填写位置';

  @override
  String get openInMaps => '在地图中打开';

  @override
  String get deliveryZoneLabel => '外送范围';

  @override
  String get deliveryZoneHint => '例如：覆盖的街区或 5 公里范围';

  @override
  String get vacationMode => '休假模式';

  @override
  String get vacationModeHint => '临时停业：顾客会看到餐厅已关闭。';

  @override
  String get vacationMessage => '向顾客显示的信息';

  @override
  String get vacationMessageHint => '例如：9 月 15 日恢复营业';

  @override
  String get notifSoundNewOrder => '每个新订单提示音';

  @override
  String get notifSoundReady => '订单完成时提示音';

  @override
  String get notifLate => '订单超时提醒';

  @override
  String get notifLowStock => '库存不足提醒';

  @override
  String get notifReservations => '本小时预订提醒';

  @override
  String get notifCashGap => '结账时的现金差额';

  @override
  String get signedInAs => '当前登录账号';

  @override
  String get securityTip => '请使用至少 8 个字符的独立密码。';

  @override
  String get signOutOthers => '退出我的其他设备';

  @override
  String get signOutOthersDone => '您的其他设备已退出登录。';

  @override
  String get signOutAll => '在所有设备上退出';

  @override
  String fileTooBig(String name) {
    return '$name 文件过大。';
  }

  @override
  String get adsCreate => '创建广告';

  @override
  String get adsEdit => '修改广告';

  @override
  String get adsCampaigns => '我的推广';

  @override
  String get adsLibrary => '素材库';

  @override
  String get adsStats => '统计';

  @override
  String get adsCreateTitle => '创建';

  @override
  String get adsCreateHint => '选择广告形式。';

  @override
  String get adsContent => '内容';

  @override
  String get adsBudgetTargeting => '预算与定向';

  @override
  String get adsPreview => '预览';

  @override
  String get adsPreviewHint => '手机预览';

  @override
  String get adsPreviewSimulation => '此预览为模拟效果。';

  @override
  String get adsFromLibrary => '从素材库选择';

  @override
  String get adsUpload => '添加照片或视频';

  @override
  String get adsUploadHint =>
      'JPG、PNG、WebP（5 MB）· MP4、WebM、MOV（50 MB）· 建议 15–30 秒视频';

  @override
  String get adsLibraryEmpty => '素材库为空。';

  @override
  String get adsDeleteFile => '从素材库删除此文件？';

  @override
  String get adsEmpty => '暂无推广。';

  @override
  String get adsEmptyHint => '创建您的第一个广告：一段视频、一个 24 小时快拍或一道主推菜品。';

  @override
  String get adsActiveCampaigns => '推广';

  @override
  String adsCampaignCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 个进行中',
      zero: '无进行中',
    );
    return '$_temp0';
  }

  @override
  String get adFormat => '形式';

  @override
  String get adFormatVideo => '视频 15–30 秒';

  @override
  String get adFormatVideoHint => '吸引注意力的短视频';

  @override
  String get adFormatCarousel => '多图轮播';

  @override
  String get adFormatCarouselHint => '可滑动浏览的多张图片';

  @override
  String get adFormatStory => '24 小时快拍';

  @override
  String get adFormatStoryHint => '24 小时限时形式';

  @override
  String get adFormatSponsoredMenu => '推荐菜单';

  @override
  String get adFormatSponsoredMenuHint => '突出展示您的菜品';

  @override
  String get adFormatPush => '通知';

  @override
  String get adFormatPushHint => '直接触达您的顾客';

  @override
  String get adFormatClassified => '分类广告';

  @override
  String get adFormatClassifiedHint => '简洁有效的文字广告';

  @override
  String get adTitle => '标题';

  @override
  String get adTitleHint => '例如：黄油可颂';

  @override
  String get adTitleRequired => '请为广告填写标题。';

  @override
  String get adText => '文字';

  @override
  String get adTextHint => '例如：新品！手工自制可颂，仅限今晚 8 折';

  @override
  String get adMediaHelp => '广告照片或视频（最多 10 个）。';

  @override
  String get adVideoHelp => '添加一段短视频（15 至 30 秒）。';

  @override
  String get adChooseItems => '主推菜品';

  @override
  String get adCta => '按钮';

  @override
  String get adCtaHint => '例如：立即下单';

  @override
  String get adCtaDefault => '立即下单';

  @override
  String get adLink => '按钮链接（可选）';

  @override
  String get adPushNote => '通知将发送给同意接收您优惠信息的应用顾客。';

  @override
  String get adDailyBudget => '每日预算';

  @override
  String get adBudgetNote => '预计预算：推广投放费用将由平台结算。';

  @override
  String get adStart => '开始';

  @override
  String get adEnd => '结束';

  @override
  String get adStory24h => '展示 24 小时';

  @override
  String get adTargetAreas => '按街区定向';

  @override
  String get adAddArea => '添加街区';

  @override
  String get adMoments => '时段';

  @override
  String get momentMorning => '早上';

  @override
  String get momentNoon => '中午';

  @override
  String get momentAfternoon => '下午';

  @override
  String get momentEvening => '晚上';

  @override
  String get momentNight => '夜间';

  @override
  String get adBranches => '门店';

  @override
  String get adSaveDraft => '保存草稿';

  @override
  String get adPublish => '发布';

  @override
  String get adPublished => '广告已发布。';

  @override
  String get adSponsored => '推广';

  @override
  String get adStatusActive => '进行中';

  @override
  String get adStatusScheduled => '已排期';

  @override
  String get adStatusPaused => '已暂停';

  @override
  String get adStatusEnded => '已结束';

  @override
  String get adStatusDraft => '草稿';

  @override
  String get adRoi => '带来的营业额';

  @override
  String adRoiDetail(String amount) {
    return '已投入预算 $amount';
  }

  @override
  String adViews(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 次浏览',
    );
    return '$_temp0';
  }

  @override
  String adOrders(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 个订单',
    );
    return '$_temp0';
  }

  @override
  String get adDetails => '查看详情';

  @override
  String get adBoost => '加推';

  @override
  String get adBoostTitle => '延长投放';

  @override
  String adBoostDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '再延长 $count 天',
    );
    return '$_temp0';
  }

  @override
  String get adBoosted => '推广已延长。';

  @override
  String get adPause => '暂停';

  @override
  String get adResume => '恢复';

  @override
  String get adEndNow => '立即结束';

  @override
  String get adDeleteConfirm => '删除此推广及其统计数据？';

  @override
  String get adStatViews => '浏览';

  @override
  String get adStatClicks => '点击';

  @override
  String get adStatClickRate => '点击率';

  @override
  String get adStatOrders => '订单';

  @override
  String get adStatRevenue => '营业额';

  @override
  String get adStatByCampaign => '各推广浏览量';

  @override
  String get activeLabel => '上架';

  @override
  String get addPhotos => '添加照片';

  @override
  String get addProduct => '添加商品';

  @override
  String get allItems => '全部';

  @override
  String get available => '有货';

  @override
  String get categories => '分类';

  @override
  String get copySuffix => '副本';

  @override
  String get customerSideView => '顾客视角 — 在餐厅菜单中的样子';

  @override
  String get duplicate => '复制';

  @override
  String get everyDay => '每天';

  @override
  String get filterKind => '类型';

  @override
  String get itemDescriptionHint => '例如：花生酱炖苦叶配虾和大蕉';

  @override
  String get itemDuplicated => '已复制菜品：副本在保存前保持隐藏。';

  @override
  String get livePreview => '实时预览';

  @override
  String get mainPhoto => '主图';

  @override
  String get makeMainPhoto => '设为主图';

  @override
  String get markAvailable => '恢复供应';

  @override
  String get markSoldOut => '标记为售罄';

  @override
  String get menuProducts => '菜单商品';

  @override
  String get noProductsFound => '没有符合的商品。';

  @override
  String photosHint(int count) {
    return '最多 $count 张照片 · JPG、PNG、WebP · 最大 5 MB';
  }

  @override
  String get play => '播放';

  @override
  String prepMinutesShort(int minutes) {
    return '备餐：$minutes 分钟';
  }

  @override
  String get prepTime => '备餐时间';

  @override
  String get productInfo => '商品信息';

  @override
  String get productPhotos => '商品照片';

  @override
  String productsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 个商品',
      zero: '无商品',
    );
    return '$_temp0';
  }

  @override
  String get publish => '发布';

  @override
  String get replace => '更换';

  @override
  String get saleDays => '销售日';

  @override
  String get saleDaysRequired => '请至少选择一个销售日。';

  @override
  String get searchProduct => '搜索商品、菜品…';

  @override
  String get sizesLabel => '规格';

  @override
  String get sortBy => '排序';

  @override
  String get sortMenuOrder => '菜单顺序';

  @override
  String get sortName => '名称';

  @override
  String get sortPriceAsc => '价格从低到高';

  @override
  String get sortPriceDesc => '价格从高到低';

  @override
  String get stockAlertThreshold => '低于此数提醒';

  @override
  String get stockAndTime => '库存与时间';

  @override
  String stockLeft(int count) {
    return '库存：剩 $count';
  }

  @override
  String stockLow(int count) {
    return '库存不足：剩 $count';
  }

  @override
  String get stockNotTracked => '留空 = 不统计';

  @override
  String get stockOfDay => '今日库存';

  @override
  String get stockOfDayHint => '今天可供应的份数。每下一单就减少；为零时自动售罄。留空表示不统计。';

  @override
  String get stockQuantity => '库存数量';

  @override
  String get supplementsLabel => '加料';

  @override
  String get videoAdded => '已添加展示视频';

  @override
  String get videoOptional => '展示视频（可选，约 30 秒）';

  @override
  String get allChannels => '全部渠道';

  @override
  String get amountLabel => '金额';

  @override
  String averageTicketShort(String amount) {
    return '平均客单价 $amount';
  }

  @override
  String get customerLabel => '顾客';

  @override
  String get financialResult => '财务结果';

  @override
  String get inKitchenCount => '备餐中';

  @override
  String get inProgressCount => '进行中';

  @override
  String get itemsLabel => '菜品：';

  @override
  String get lateCount => '已超时';

  @override
  String get noOrdersHere => '这里没有订单';

  @override
  String get noSalesYet => '该时段暂无销售。';

  @override
  String get nothingToCollectHint => '暂无待处理：新的收款会显示在这里。';

  @override
  String get orderLabel => '订单';

  @override
  String get paymentLabel => '支付';

  @override
  String get periodLabel => '时段';

  @override
  String get recentTransactions => '最近交易';

  @override
  String get salesOfPeriod => '时段营业额';

  @override
  String get salesSplit => '销售构成';

  @override
  String get timeLabel => '时间';

  @override
  String get topDishes => '热销菜品';

  @override
  String get viewDetails => '查看详情';

  @override
  String vsPrevious(String amount) {
    return '上一时段：$amount';
  }

  @override
  String get addAddress => '添加地址';

  @override
  String get addedToCart => '已加入购物车。';

  @override
  String get addressLabel => '地址名称';

  @override
  String get addressLabelHint => '例如：家、公司';

  @override
  String get addToCart => '加入购物车';

  @override
  String get allCities => '所有城市';

  @override
  String get allRestaurants => '全部餐厅';

  @override
  String get birthday => '生日';

  @override
  String get cartEmpty => '购物车是空的。';

  @override
  String cartItems(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 件',
    );
    return '$_temp0';
  }

  @override
  String get changeCity => '更改';

  @override
  String get chooseCity => '选择城市';

  @override
  String chooseOptionRequired(String name) {
    return '请选择：$name';
  }

  @override
  String get closedNow => '休息中';

  @override
  String get customerFavorites => '收藏';

  @override
  String get customerHome => '首页';

  @override
  String get customerOrders => '订单';

  @override
  String get customerProfile => '我的';

  @override
  String customerReviews(int count) {
    return '顾客评价（$count）';
  }

  @override
  String get customerSearch => '搜索';

  @override
  String get customerSpaceLink => '顾客专区 · 点餐';

  @override
  String get deliveryDetailsRequired => '请填写外送地址和电话。';

  @override
  String get directions => '路线';

  @override
  String get discoverRestaurants => '发现餐厅';

  @override
  String get dishes => '菜品';

  @override
  String get favoritesSignIn => '登录后查看您收藏的餐厅。';

  @override
  String get fullName => '姓名';

  @override
  String get globalCatalog => '全部菜品';

  @override
  String get healthAllergies => '健康与过敏';

  @override
  String get howDoYouWant => '您希望如何用餐？';

  @override
  String loyaltyNextReward(int points, String amount) {
    return '满 $points 积分可得奖励：$amount';
  }

  @override
  String loyaltyPoints(int count) {
    return '$count 积分';
  }

  @override
  String get loyaltyProgram => '会员积分';

  @override
  String mapCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '地图上有 $count 家门店',
    );
    return '$_temp0';
  }

  @override
  String get mapView => '地图';

  @override
  String minimumOrderNotReached(String amount) {
    return '起送金额：$amount';
  }

  @override
  String minutesRange(int min, int max) {
    return '$min–$max 分钟';
  }

  @override
  String get myAddresses => '我的地址';

  @override
  String get myCart => '我的购物车';

  @override
  String get newRestaurant => '新店';

  @override
  String get noAddresses => '尚未保存地址。';

  @override
  String get noCustomerOrders => '您还没有下过单。';

  @override
  String get noFavorites => '暂无收藏。';

  @override
  String get noFavoritesHint => '点击餐厅的爱心即可收藏。';

  @override
  String get noLoyaltyYet => '下单后会显示您的积分。';

  @override
  String get noRestaurantsYet => '该城市暂无已上线的餐厅。';

  @override
  String get noteForKitchen => '给厨房的备注（可选）';

  @override
  String get noteForKitchenHint => '例如：不要辣、全熟';

  @override
  String get notifOrderUpdates => '订单进度';

  @override
  String get notifPromotions => '促销与优惠';

  @override
  String get notifReservationReminders => '预订提醒';

  @override
  String get onlineOrdersUnavailable => '暂不支持在线点餐';

  @override
  String get openFullMap => '全屏打开地图';

  @override
  String get openNow => '营业中';

  @override
  String get orderDone => '已完成';

  @override
  String orderingAtTable(String table) {
    return '$table 号桌点餐';
  }

  @override
  String get orderInProgress => '进行中';

  @override
  String get orderNoteOptional => '给餐厅的留言（可选）';

  @override
  String get orderRejected => '餐厅已拒单';

  @override
  String get orderSentToRestaurant => '订单已发送！餐厅确认后即可在此实时查看进度。';

  @override
  String get ordersSignIn => '登录后查看订单进度。';

  @override
  String get orderSummary => '订单概要';

  @override
  String get orderWaitingConfirmation => '等待确认';

  @override
  String get payMobileWallet => '手机钱包';

  @override
  String get personalProfile => '个人资料';

  @override
  String get personalProfileHint => '您的个人信息和偏好设置。';

  @override
  String get placeOrder => '下单';

  @override
  String get preferences => '偏好设置';

  @override
  String get preferredPayment => '首选支付方式';

  @override
  String get preferredPaymentHint => '仅供参考：不会保存任何卡号或账号。';

  @override
  String get productDetails => '商品详情';

  @override
  String get profileSignIn => '登录后管理资料、地址和积分。';

  @override
  String get rateOrder => '评价订单';

  @override
  String get requiredLabel => '必选';

  @override
  String get restaurantOnVacation => '餐厅暂停营业。';

  @override
  String get restaurants => '餐厅';

  @override
  String get restaurantSpace => '餐厅后台';

  @override
  String get restaurantUnavailable => '该餐厅暂不可用。';

  @override
  String get reviewComment => '您的评价（可选）';

  @override
  String reviewsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 条评价',
      zero: '暂无评价',
    );
    return '$_temp0';
  }

  @override
  String get searchRestaurantsHint => '搜索餐厅、菜品、菜系…';

  @override
  String get seeAll => '查看全部';

  @override
  String get send => '发送';

  @override
  String get signInToContinue => '登录后继续';

  @override
  String get spiceHot => '重辣';

  @override
  String get spiceLevel => '辣度';

  @override
  String get spiceMedium => '中辣';

  @override
  String get spiceMild => '微辣';

  @override
  String get spiceNone => '不辣';

  @override
  String get sponsoredAds => '推广';

  @override
  String get stepAccepted => '餐厅已接单';

  @override
  String get stepDone => '已完成';

  @override
  String get stepPreparing => '制作中';

  @override
  String get stepReady => '已出餐';

  @override
  String get stepSent => '已发送';

  @override
  String get storyLabel => '菜品故事';

  @override
  String get thanksForReview => '感谢您的评价！';

  @override
  String get viewCart => '查看购物车';

  @override
  String get watchVideo => '视频';

  @override
  String get yourName => '您的姓名';

  @override
  String get gpsHint => '点击“在地图中打开”会自动保存您当前所在的位置：请在餐厅内操作。也可以手动输入坐标。';

  @override
  String get locationSaved => '已保存餐厅位置。';

  @override
  String get locationServiceDisabled => '此设备的定位服务已关闭：请开启后重试。';

  @override
  String get locationDenied => '定位权限被拒绝：请在浏览器或手机设置中允许。';

  @override
  String get locationUnavailable => '暂时无法获取位置：请到室外重试或手动输入坐标。';

  @override
  String get openMapAction => '打开地图';

  @override
  String get customerReviewsTitle => '顾客评价';

  @override
  String get forYou => '为您推荐';

  @override
  String fromAmount(String amount) {
    return '$amount 起';
  }

  @override
  String helpfulCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '有用（$count）',
      zero: '有用',
    );
    return '$_temp0';
  }

  @override
  String get hideReview => '隐藏评价';

  @override
  String get hideReviewReason => '原因';

  @override
  String get locatedNearYou => '已按您的位置排序餐厅';

  @override
  String get locateMe => '定位我';

  @override
  String get locationRefusedChooseCity => '无法获取位置：请选择您的城市。';

  @override
  String get nearYouHint => '允许定位即可查看离您最近的餐厅和菜品。';

  @override
  String get nearYouRestaurants => '附近';

  @override
  String get nearYouTitle => '您附近的餐厅';

  @override
  String get newOnMenus => '新品';

  @override
  String get noReviewsYet => '暂无评价';

  @override
  String get openNowTitle => '正在营业';

  @override
  String get orderAgain => '再来一单';

  @override
  String get orderAgainAction => '再次下单';

  @override
  String get ordersInProgressTitle => '您进行中的订单';

  @override
  String get popularDishes => '热门菜品';

  @override
  String get popularNearYou => '附近热门';

  @override
  String get promotionsTitle => '优惠活动';

  @override
  String get publishReview => '发布评价';

  @override
  String rateDish(String name) {
    return '评价：$name';
  }

  @override
  String get rateShort => '评价';

  @override
  String get refreshLocation => '刷新';

  @override
  String get reorderPartial => '部分菜品已下架，其余已加入购物车。';

  @override
  String get reorderUnavailable => '这些菜品已下架。';

  @override
  String get reportReason => '该评价有何不当？';

  @override
  String get reportReview => '举报';

  @override
  String reportsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 次举报',
    );
    return '$_temp0';
  }

  @override
  String get reportSent => '感谢，举报已提交。';

  @override
  String get republishReview => '重新公开';

  @override
  String get reviewCommentHint => '例如：调味到位、分量足、送餐快';

  @override
  String satisfiedPercent(int percent) {
    return '$percent% 的顾客满意';
  }

  @override
  String get sortBestRated => '评分最高';

  @override
  String get sortHelpful => '最有用';

  @override
  String get sortRecent => '最新';

  @override
  String get sortWorstRated => '评分最低';

  @override
  String get verifiedPurchase => '已验证购买';

  @override
  String get verifiedReviewNote => '已验证评价：只有收到该菜品的顾客才能评价。';

  @override
  String get asSoonAsPossible => '尽快送达';

  @override
  String get customerOrdersHere => '在本店的订单';

  @override
  String get customerPrivacyNote => '您只能看到该顾客与本餐厅的往来，绝不会看到其在其他餐厅的订单。';

  @override
  String get customersCount => '位顾客';

  @override
  String multiRestaurantNote(int count) {
    return '购物车中有 $count 家餐厅：每家都会收到独立订单，各有编号和进度。';
  }

  @override
  String get navCustomers => '顾客';

  @override
  String get noCustomersYet => '暂无线上顾客。';

  @override
  String get noCustomersYetHint => '通过应用下单的顾客会自动出现在这里。';

  @override
  String get noDeliveryHere => '该餐厅不提供外送：按自取下单。';

  @override
  String get ordersSent => '订单已发送';

  @override
  String ordersSentHint(int count) {
    return '已发送 $count 个订单，每家餐厅一个，请分别查看进度。';
  }

  @override
  String placeOrders(int count) {
    return '提交 $count 个订单';
  }

  @override
  String get regularBadge => '常客';

  @override
  String get regularCustomers => '常客（3 单及以上）';

  @override
  String restaurantsCount(int count) {
    return '$count 家餐厅';
  }

  @override
  String get scheduleOrder => '预约时间';

  @override
  String get scheduleTooSoon => '请选择至少 15 分钟后的时间。';

  @override
  String get searchCustomer => '姓名或电话';

  @override
  String get sortBiggestSpenders => '消费最多';

  @override
  String get sortMostOrders => '下单最多';

  @override
  String get sortRecentVisit => '最近光顾';

  @override
  String get teamNotes => '团队备注';

  @override
  String get teamNotesExample => '例如：喜欢露台座位、爱吃辣酱';

  @override
  String get teamNotesHint => '仅团队可见。';

  @override
  String get trackOrder => '查看进度';

  @override
  String get customerDiscover => '发现';

  @override
  String get feedEmpty => '暂时没有可发现的内容';

  @override
  String get feedEmptyHint => '您所在城市餐厅的视频、菜品和优惠将显示在这里。';

  @override
  String get feedOrder => '下单';

  @override
  String get feedViewDish => '查看菜品';

  @override
  String get feedViewRestaurant => '查看餐厅';

  @override
  String get feedLike => '点赞';

  @override
  String get feedSave => '收藏';

  @override
  String get feedShare => '分享';

  @override
  String get feedSaved => '已收藏。';

  @override
  String get feedUnsaved => '已取消收藏。';

  @override
  String get feedLinkCopied => '链接已复制：粘贴即可分享。';

  @override
  String get commentsTitle => '评论';

  @override
  String get noCommentsYet => '暂无评论。';

  @override
  String get writeComment => '写评论…';

  @override
  String get adHideForever => '不再显示';

  @override
  String reserveAt(String name) {
    return '预订 $name';
  }

  @override
  String get reservationSentHint => '请求已发送：餐厅将确认您的预订。';

  @override
  String get reservationNoteLabel => '备注（选填）';

  @override
  String get errorInvalidComment => '评论须为 1 至 500 个字符。';

  @override
  String get adStatReach => '覆盖人数';

  @override
  String get adStatEngagement => '互动率';

  @override
  String get adStatLikes => '点赞';

  @override
  String get adStatSaves => '收藏';

  @override
  String get adStatShares => '分享';

  @override
  String get hideComment => '隐藏';

  @override
  String get moderationReasonExample => '例如：辱骂、离题';

  @override
  String get hiddenBadge => '已隐藏';

  @override
  String hiddenBecause(String reason) {
    return '已隐藏：$reason';
  }

  @override
  String get allFilter => '全部';

  @override
  String get publishedComments => '已发布';

  @override
  String get hiddenComments => '已隐藏';

  @override
  String get adCommentsHint => '顾客对您广告的评论会显示在这里。请隐藏辱骂或离题的评论。';

  @override
  String get happyBirthday => '生日快乐！';

  @override
  String birthdayGift(String name, int points) {
    return '$name 赠送您 $points 积分。';
  }

  @override
  String get thanksAction => '谢谢！';

  @override
  String get notificationsTitle => '通知';

  @override
  String get noNotifications => '暂无通知';

  @override
  String get noNotificationsHint => '餐厅接单、订单备好或预订确认时，会在这里通知您。';

  @override
  String get notifOrderAcceptedTitle => '订单已接受';

  @override
  String notifOrderAccepted(String brand, String number) {
    return '$brand 已接受您的订单 $number 号。';
  }

  @override
  String get notifOrderReadyTitle => '订单已备好';

  @override
  String notifOrderReady(String brand, String number) {
    return '您在 $brand 的订单 $number 号已备好，可以取餐了。';
  }

  @override
  String notifOrderOnTheWay(String brand, String number) {
    return '您在 $brand 的订单 $number 号已备好，正在配送。';
  }

  @override
  String get notifOrderRejectedTitle => '订单被拒';

  @override
  String notifOrderRejected(String brand, String number, String reason) {
    return '$brand 无法接受您的订单 $number 号：$reason';
  }

  @override
  String get notifReservationConfirmedTitle => '预订已确认';

  @override
  String notifReservationConfirmed(String brand, String date) {
    return '$brand 已确认您 $date 的预订。';
  }

  @override
  String get notifReservationDeclinedTitle => '预订被拒';

  @override
  String notifReservationDeclined(String brand, String date, String reason) {
    return '$brand 无法在 $date 接待您：$reason';
  }

  @override
  String notifGroupJoined(String name, String brand) {
    return '$name 加入了您在 $brand 的拼单。';
  }

  @override
  String notifGroupPlaced(String host, String brand, String number) {
    return '$host 已提交在 $brand 的拼单（$number 号）。';
  }

  @override
  String get groupOrderTitle => '拼单';

  @override
  String get groupOrderAction => '拼单';

  @override
  String get groupInviteTitle => '邀请同伴';

  @override
  String get groupInviteHint => '分享此链接：每人在自己的手机上选菜，最后由您提交一个订单。';

  @override
  String get groupEmpty => '还没有菜品';

  @override
  String get groupEmptyHint => '添加您的菜品，并把链接分享给同伴。';

  @override
  String groupHostedBy(String name) {
    return '发起人：$name';
  }

  @override
  String groupStatusOpen(String time) {
    return '开放至 $time';
  }

  @override
  String get groupStatusPlaced => '已发送给餐厅';

  @override
  String get groupStatusCancelled => '已取消';

  @override
  String get groupStatusExpired => '已过期';

  @override
  String groupParticipants(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 位同伴',
    );
    return '$_temp0';
  }

  @override
  String get groupCheckoutTitle => '为全组提交';

  @override
  String get estimatedTotal => '预计总额';

  @override
  String get groupPlaceOrder => '把订单发送给餐厅';

  @override
  String get cancelGroupOrder => '取消拼单';

  @override
  String get cancelGroupOrderConfirm => '取消此拼单？所有人选的菜都会丢失。';

  @override
  String get groupAddMyDishes => '添加我的菜品';

  @override
  String groupPlacedInfo(String name) {
    return '$name 已把订单发送给餐厅。';
  }

  @override
  String get groupClosedInfo => '此拼单已关闭。';

  @override
  String get groupOrderPlaced => '拼单已发送给餐厅。';

  @override
  String get addedToGroup => '已加入拼单。';

  @override
  String get addToGroup => '加入拼单';

  @override
  String get saveDishAction => '收藏菜品';

  @override
  String saveDishTitle(String name) {
    return '收藏“$name”';
  }

  @override
  String get favoriteDishes => '收藏的菜品';

  @override
  String get myLists => '我的清单';

  @override
  String get myCoupons => '我的优惠券';

  @override
  String get restaurantsSection => '餐厅';

  @override
  String get unavailableNow => '暂不供应';

  @override
  String get removeAction => '移除';

  @override
  String get noFavoriteDishes => '暂无收藏的菜品';

  @override
  String get noFavoriteDishesHint => '点按菜品页面上的爱心，即可在这里找到它。';

  @override
  String get newList => '新建清单';

  @override
  String get noLists => '暂无清单';

  @override
  String get noListsHint => '创建如“想尝试”或“办公室午餐”之类的清单。';

  @override
  String deleteListConfirm(String name) {
    return '删除清单“$name”？';
  }

  @override
  String get renameAction => '重命名';

  @override
  String dishesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 道菜',
      zero: '没有菜品',
    );
    return '$_temp0';
  }

  @override
  String get emptyListHint => '清单为空：请从菜品页面添加。';

  @override
  String get listName => '清单名称';

  @override
  String get listNameExample => '例如：想尝试';

  @override
  String get noCoupons => '暂无优惠券';

  @override
  String get noCouponsHint => '在首页收藏餐厅的优惠，即可在这里找到。';

  @override
  String get couponsHowTo => '在订单跟踪中输入优惠码即可享受折扣。';

  @override
  String validUntil(String date) {
    return '有效期至 $date';
  }

  @override
  String get couponUsed => '已使用';

  @override
  String get couponExpired => '已过期';

  @override
  String get codeCopied => '优惠码已复制。';

  @override
  String get couponSaved => '优惠券已收藏。';

  @override
  String get saveCouponAction => '收藏';

  @override
  String get errorLimitReached => '已达上限：请先移除部分内容再添加。';

  @override
  String get errorGroupClosed => '此拼单已关闭或已过期。';

  @override
  String get customersTab => '顾客';

  @override
  String get offersTab => '优惠';

  @override
  String get loyaltyTab => '会员积分';

  @override
  String get activeOffers => '进行中的优惠';

  @override
  String get publicCoupons => '公开优惠券';

  @override
  String get totalUses => '使用次数';

  @override
  String get newOffer => '新建优惠';

  @override
  String get editOffer => '编辑优惠';

  @override
  String get offersEmpty => '暂无优惠';

  @override
  String get offersEmptyHint => '创建折扣、优惠码或公开优惠券，吸引并留住顾客。';

  @override
  String get offerStatusOff => '已停用';

  @override
  String get offerStatusEnded => '已结束';

  @override
  String get offerStatusScheduled => '已排期';

  @override
  String get offerStatusActive => '进行中';

  @override
  String get publicCouponLabel => '公开优惠券';

  @override
  String get publicCouponHint => '在应用中展示：顾客可将其收藏到卡包。';

  @override
  String get publicCouponNeedsCode => '公开优惠券必须设置优惠码。';

  @override
  String usesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '已使用 $count 次',
      zero: '从未使用',
    );
    return '$_temp0';
  }

  @override
  String get offerName => '优惠名称';

  @override
  String get offerNameExample => '例如：欢迎礼、欢乐时光';

  @override
  String get discountPercent => '百分比';

  @override
  String get discountAmount => '金额';

  @override
  String get offerValue => '折扣';

  @override
  String get promoCodeLabel => '优惠码（选填）';

  @override
  String get offerCodeHint => '3 至 30 个字母或数字，例如 WELCOME';

  @override
  String get minOrderLabel => '最低消费';

  @override
  String get maxUsesLabel => '最多使用次数';

  @override
  String get perCustomerLabel => '每位顾客';

  @override
  String get startsLabel => '开始';

  @override
  String get endsLabel => '结束';

  @override
  String get offerNow => '立即';

  @override
  String get noEndDate => '长期有效';

  @override
  String get allBranchesLabel => '所有门店';

  @override
  String get thisBranchOnly => '本门店';

  @override
  String get offerActive => '启用优惠';

  @override
  String get loyaltyMembers => '会员';

  @override
  String get pointsInCirculation => '流通积分';

  @override
  String get loyaltyProgramTitle => '会员积分计划';

  @override
  String loyaltyExample(String amount, int points) {
    return '示例：消费 $amount 可获得 $points 积分。';
  }

  @override
  String get loyaltyActive => '启用计划';

  @override
  String get amountPerPoint => '每积 1 分所需金额';

  @override
  String get rewardPointsLabel => '兑换奖励所需积分';

  @override
  String get rewardValueLabel => '奖励价值';

  @override
  String get birthdayPointsLabel => '生日积分';

  @override
  String get birthdayPointsHint => '每年自动赠送给曾在您店里下过单的顾客（0 = 不赠送）。';

  @override
  String get stockDashboardTab => '概览';

  @override
  String get stockArticlesTab => '物料';

  @override
  String get stockOrdersTab => '订货';

  @override
  String get stockReportsTab => '报表';

  @override
  String get stockDashboardTitle => '库存概览';

  @override
  String get stockValueLabel => '库存价值';

  @override
  String get belowThresholdLabel => '低于预警';

  @override
  String get outOfStockLabel => '缺货';

  @override
  String get expiringSoonLabel => '即将过期';

  @override
  String get inventoryVarianceLabel => '盘点差异';

  @override
  String get consumptionLabel => '消耗';

  @override
  String get wasteLabel => '损耗';

  @override
  String get receiptsLabel => '入库';

  @override
  String articlesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 种物料',
      zero: '没有物料',
    );
    return '$_temp0';
  }

  @override
  String daysCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 天',
    );
    return '$_temp0';
  }

  @override
  String get consumptionByDay => '每日消耗与损耗';

  @override
  String get topConsumedTitle => '消耗最多';

  @override
  String get wasteByReason => '损耗原因';

  @override
  String get noMovementsPeriod => '此期间没有库存变动。';

  @override
  String get noWastePeriod => '此期间没有损耗。';

  @override
  String get expiringLotsTitle => '需关注的批次（保质期）';

  @override
  String get noExpiringLots => '7 天内没有批次过期。';

  @override
  String get toReorderTitle => '待订货';

  @override
  String get noAlerts => '没有低于预警的物料。';

  @override
  String get prepareOrder => '准备订货单';

  @override
  String get expiredShort => '已过期';

  @override
  String daysLeftShort(int count) {
    return '剩 $count 天';
  }

  @override
  String daysLeftLong(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '可用 $count 天',
      zero: '今天用完',
    );
    return '$_temp0';
  }

  @override
  String batchShort(String batch) {
    return '批次 $batch';
  }

  @override
  String get batchNumber => '批号';

  @override
  String get expiryDate => '到期日';

  @override
  String get stockEmptyHint => '先在“物料”页创建物料，再登记期初库存或入库。';

  @override
  String get searchArticle => '搜索物料';

  @override
  String get showInactive => '显示停用的';

  @override
  String get newArticle => '新建物料';

  @override
  String get editArticle => '编辑物料';

  @override
  String get articlesEmptyHint => '添加您的物料：蔬菜、肉类、饮料、包装、自制半成品……';

  @override
  String get storageLabel => '储存方式';

  @override
  String get storageAmbient => '常温';

  @override
  String get storageChilled => '冷藏';

  @override
  String get storageFrozen => '冷冻';

  @override
  String get purchaseUnitLabel => '采购单位';

  @override
  String get purchaseUnitExample => '例如：5 公斤一袋、12 个一箱';

  @override
  String get purchaseUnitQty => '规格';

  @override
  String get preferredSupplier => '常用供应商';

  @override
  String get noneLabel => '无';

  @override
  String get shelfLifeDays => '保质期';

  @override
  String get daysShort => '天';

  @override
  String get barcodeLabel => '条形码';

  @override
  String get thresholdThisBranch => '本门店的预警量';

  @override
  String get reorderTitle => '建议订货';

  @override
  String get reorderHint => '根据最近 28 天的消耗，订够保持在预警量以上所需的数量。';

  @override
  String get nothingToReorder => '无需订货';

  @override
  String get nothingToReorderHint => '所选期间内，所有跟踪的物料库存充足。';

  @override
  String get noSupplier => '无常用供应商';

  @override
  String get noSupplierHint => '在物料卡片中选择常用供应商，即可创建采购单。';

  @override
  String get orderFormPdf => '采购单 PDF';

  @override
  String get createPurchaseOrder => '创建采购单';

  @override
  String get purchaseOrderDraftCreated => '已在“采购”中创建采购单草稿。';

  @override
  String get reorderNote => '库存建议订货';

  @override
  String inStockShort(String qty) {
    return '库存：$qty';
  }

  @override
  String get entriesFilter => '入库';

  @override
  String get exitsLabel => '出库';

  @override
  String get transfersFilter => '调拨';

  @override
  String get adjustmentsFilter => '调整';

  @override
  String get movementsReportTitle => '库存变动';

  @override
  String get wasteReportTitle => '损耗与破损';

  @override
  String get reportValuation => '库存估值';

  @override
  String get reportValuationHint => '当前每种物料的数量、预警量、平均成本和价值。';

  @override
  String get reportMovementsHint => '期间内所有库存变动，并按类型汇总。';

  @override
  String get reportWasteHint => '期间内的损耗及其原因和价值。';

  @override
  String get reportInventory => '盘点差异表';

  @override
  String get reportInventoryHint => '账面、实盘、差异金额及签字栏。';

  @override
  String get reportFoodCost => '每道菜的食材成本';

  @override
  String get reportFoodCostHint => '每道菜的成本、售价、食材成本率和毛利。';

  @override
  String get reportExpiringHint => '14 天内到期的在库批次。';

  @override
  String get generatePdf => '生成 PDF';

  @override
  String get noValidatedInventory => '尚无已确认的盘点。';

  @override
  String get chooseInventory => '选择盘点';

  @override
  String generatedOn(String date) {
    return '生成于 $date';
  }

  @override
  String get articlesLabel => '物料';

  @override
  String get articleLabel => '物料';

  @override
  String get avgCostShort => '平均成本';

  @override
  String get valueLabel => '价值';

  @override
  String get typeLabel => '类型';

  @override
  String get inventoryGains => '盘盈';

  @override
  String get inventoryLosses => '盘亏';

  @override
  String get inventoryNet => '净差异';

  @override
  String get theoreticalLabel => '账面';

  @override
  String get countedBySignature => '盘点人：____________________';

  @override
  String get validatedBySignature => '审核人：____________________';

  @override
  String get targetFoodCost => '食材成本目标';

  @override
  String get targetFoodCostHint => '一道菜的食材成本占售价的最高比例（通常为 25% 至 35%）。';

  @override
  String targetFoodCostValue(String percent) {
    return '食材成本目标：$percent%';
  }

  @override
  String get dishesWithRecipe => '已有配方的菜品';

  @override
  String get aboveTarget => '高于目标';

  @override
  String get aboveTargetShort => '成本过高';

  @override
  String get withoutRecipe => '无配方';

  @override
  String get recipeDefined => '已设配方';

  @override
  String get dishLabel => '菜品';

  @override
  String get costPriceShort => '成本';

  @override
  String get sellingPriceShort => '售价';

  @override
  String get foodCostShort => '食材成本';

  @override
  String get marginShort => '毛利';

  @override
  String get orderFormTitle => '采购单';

  @override
  String supplierLabelValue(String name) {
    return '供应商：$name';
  }

  @override
  String get packagingLabel => '包装';

  @override
  String get unitPriceShort => '单价';

  @override
  String get orderFormFooter => '请确认供货情况和交货时间。';

  @override
  String get accountTypeQuestion => '您是：';

  @override
  String get accountTypeCustomer => '顾客';

  @override
  String get accountTypeCustomerHint => '发现餐厅、点餐、订座';

  @override
  String get accountTypeBusiness => '商家';

  @override
  String get accountTypeBusinessHint => '管理我的餐厅和团队';

  @override
  String get accountTypeRequired => '请选择顾客或商家。';

  @override
  String get accountTypeTitle => '欢迎使用 Resto';

  @override
  String get accountTypeSub => '您将如何使用本应用？';

  @override
  String get continueAction => '继续';

  @override
  String adVideoTooBig(String name) {
    return '$name 超过 50 MB：请选择更短的视频（约 30 秒）。';
  }

  @override
  String adMediaAdded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '已添加 $count 个文件。',
    );
    return '$_temp0';
  }

  @override
  String get adNeedVideo => '发布此形式前请先添加视频。';

  @override
  String get adNeedMedia => '发布前请至少添加一张照片或一个视频。';

  @override
  String get adNeedItems => '请至少选择一道推荐菜品。';

  @override
  String get uploadingLabel => '上传中…';

  @override
  String get errorInvalidMedia => '文件被拒绝：必须来自您的素材库。';

  @override
  String get errorFileTooLarge => '文件过大。';

  @override
  String get errorFileType => '不支持的文件格式（JPG、PNG、WebP、MP4、WebM、MOV）。';

  @override
  String get adAddVideo => '添加视频';

  @override
  String get errorOutOfStock => '这道菜今日已售罄。';

  @override
  String get errorInvalidRating => '评分必须在 1 到 5 之间。';

  @override
  String get errorInvalidAllergen => '未知的过敏原。';

  @override
  String get bestSeller => '热销';

  @override
  String get callAction => '致电';

  @override
  String get writeAction => '发消息';

  @override
  String get categoriesLabel => '分类';

  @override
  String get filtersLabel => '筛选';

  @override
  String get reviewsTab => '评价';

  @override
  String get infosTab => '信息';

  @override
  String get noDishMatches => '没有符合这些筛选条件的菜品。';

  @override
  String soldCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '已售 $count 份',
    );
    return '$_temp0';
  }

  @override
  String get yourCart => '您的购物车';

  @override
  String get coverPhoto => '封面照片';

  @override
  String get coverPhotoHint => '显示在餐厅页面顶部的大图（大堂、露台、门面）。';

  @override
  String get changePhoto => '更换照片';

  @override
  String get itemTagsLabel => '标签（菜单筛选）';

  @override
  String get itemTagsHint => '创建您自己的标签：顾客可用它们筛选菜单。例如：微辣、清真、无酒精、自制。';

  @override
  String get addTagHint => '新标签 + 回车';

  @override
  String get errorInvalidTag => '标签最多 30 个字符。';

  @override
  String itemFavorites(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 位顾客已收藏',
    );
    return '$_temp0';
  }

  @override
  String get itemSold30 => '最近 30 天销量';

  @override
  String get receiptOrderNo => '订单号';

  @override
  String get receiptTicketNo => '小票号';

  @override
  String get receiptChannel => '渠道';

  @override
  String get receiptQtyShort => '数量';

  @override
  String get receiptTotalInclTax => '含税总计';

  @override
  String get receiptTotalExclTax => '不含税总计';

  @override
  String get receiptApproved => '交易已批准';

  @override
  String receiptRef(String ref) {
    return '参考号：$ref';
  }

  @override
  String receiptSeeYou(String name) {
    return '期待再次光临$name';
  }

  @override
  String get receiptRecycle => '为了更绿色的地球，请回收此小票。';

  @override
  String get receiptLoyaltyTitle => '您的忠诚会有回报！';

  @override
  String get receiptLoyaltyCaption => '扫描此二维码进入您的会员空间，享受专属优惠。';

  @override
  String get receiptPaperLabel => '本设备的小票打印机';

  @override
  String get receiptPaper80 => '80 毫米纸卷';

  @override
  String get receiptPaper58 => '58 毫米纸卷';

  @override
  String get receiptPhotosLabel => '小票上显示菜品照片';

  @override
  String get receiptTestPrint => '打印测试小票';

  @override
  String get receiptTestTitle => '测试小票';

  @override
  String get receiptHeaderSection => '小票页眉';

  @override
  String get receiptFooterSection => '小票页脚';

  @override
  String get receiptTitleLabel => '显示名称';

  @override
  String get receiptTitleHint => '默认：品牌名称';

  @override
  String get receiptSubtitleLabel => '副标题';

  @override
  String get receiptSubtitleHint => '例如：餐厅与美味';

  @override
  String get receiptSloganLabel => '标语';

  @override
  String get receiptSloganHint => '例如：地道烹饪，世界风味';

  @override
  String get websiteLabel => '网站';

  @override
  String get websiteHint => '例如：www.myrestaurant.com';

  @override
  String get receiptQrTitleLabel => '二维码旁的标题';

  @override
  String get receiptQrCaptionLabel => '二维码旁的文字';

  @override
  String get receiptFarewellLabel => '告别语';

  @override
  String get receiptFarewellHint => '例如：期待再次光临！';

  @override
  String itemLikesTip(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 个赞',
      zero: '暂无点赞',
    );
    return '$_temp0';
  }

  @override
  String get itemReviewAction => '评价';

  @override
  String get itemHeartAction => '喜爱';

  @override
  String get itemCommentsTitle => '顾客评价';

  @override
  String get itemVerifiedReviews => '下单后的评分评价';

  @override
  String get notifStaffNewOrderTitle => '新订单';

  @override
  String notifStaffNewOrder(String number, String customer, String branch) {
    return '订单 #$number $customer — $branch';
  }

  @override
  String get notifStaffOrderReadyTitle => '订单可上菜';

  @override
  String notifStaffOrderReady(String number, String branch) {
    return '订单 #$number — $branch';
  }

  @override
  String get notifStaffReservationTitle => '新预订';

  @override
  String notifStaffReservation(String name, int count, String date) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 人',
    );
    return '$name · $_temp0 · $date';
  }

  @override
  String get notifStaffReviewTitle => '新评价';

  @override
  String notifStaffReview(String author, String item) {
    return '$author 评价了「$item」';
  }

  @override
  String get pushNewOrder => '手机通知：顾客新订单';

  @override
  String get pushOrderReady => '手机通知：订单可上菜';

  @override
  String get pushReservations => '手机通知：新预订';

  @override
  String get pushReviews => '手机通知：菜品新评价';

  @override
  String get tablesTab => '餐桌';

  @override
  String get tablesNow => '现在';

  @override
  String get tablesLater => '选择时间';

  @override
  String get tableLegendOccupied => '已占用';

  @override
  String get tableLegendReserved => '已预订';

  @override
  String get tableLegendChosen => '您的选择';

  @override
  String tableFreeUntil(String time) {
    return '空闲至 $time';
  }

  @override
  String tableOccupiedUntil(String time) {
    return '约 $time 空出';
  }

  @override
  String tableReservedSlot(String from, String to) {
    return '已预订 $from–$to';
  }

  @override
  String get tablesSelectHint => '点按一张或多张空闲餐桌进行预订。';

  @override
  String tablesSeatsChosen(int seats, int party) {
    String _temp0 = intl.Intl.pluralLogic(
      seats,
      locale: localeName,
      other: '$seats 个座位',
    );
    String _temp1 = intl.Intl.pluralLogic(
      party,
      locale: localeName,
      other: '$party 人',
    );
    return '已选 $_temp0，共 $_temp1';
  }

  @override
  String reserveTablesAction(String tables) {
    return '预订 $tables';
  }

  @override
  String tableLabelChip(String label) {
    return '餐桌 $label';
  }

  @override
  String get tablesEmpty => '该餐厅尚未展示其餐桌。';
}

/// The translations for Chinese, using the Han script (`zh_Hant`).
class AppLocalizationsZhHant extends AppLocalizationsZh {
  AppLocalizationsZhHant() : super('zh_Hant');

  @override
  String get appName => 'Resto';

  @override
  String environmentBanner(String env) {
    return '環境：$env';
  }

  @override
  String get configMissingTitle => '缺少設定';

  @override
  String get configMissingBody => '未提供伺服器位址和公開金鑰（env/<環境>.json 檔案）。';

  @override
  String get languageLabel => '語言';

  @override
  String get systemLanguage => '裝置語言';

  @override
  String pendingSyncEvents(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 項操作待同步',
      zero: '全部已同步',
    );
    return '$_temp0';
  }

  @override
  String get errorNotAuthenticated => '請登入。';

  @override
  String get errorForbidden => '您無權執行此操作。';

  @override
  String get errorOwnerOnly => '只有擁有者才能執行此操作。';

  @override
  String get errorRateLimited => '請求過多，請稍後再試。';

  @override
  String get errorInvalidTimezone => '未知時區。';

  @override
  String get errorInvalidRole => '未知角色。';

  @override
  String get errorInvalidEmail => '電子郵件地址無效。';

  @override
  String get errorInvalidBranch => '在此組織中找不到該門市。';

  @override
  String get errorBranchesRequired => '請至少選擇一個門市。';

  @override
  String get errorAlreadyMember => '此人已是該組織的成員。';

  @override
  String get errorInvitationInvalid => '邀請無效、已過期或已被使用。';

  @override
  String get errorInvitationWrongAccount => '此邀請是發給另一個電子郵件地址的。';

  @override
  String get errorLastOwner => '組織必須至少保留一名擁有者。';

  @override
  String get errorMembershipRevoked => '該成員已被移出組織。';

  @override
  String get errorNetwork => '無法連線，請檢查您的網路。';

  @override
  String get errorUnknown => '發生意外錯誤。';

  @override
  String get welcomeTitle => '歡迎使用 Resto';

  @override
  String get signInTitle => '登入';

  @override
  String get signIn => '登入';

  @override
  String get signOut => '登出';

  @override
  String get createAccount => '建立帳戶';

  @override
  String get forgotPassword => '忘記密碼';

  @override
  String get email => '電子郵件';

  @override
  String get password => '密碼';

  @override
  String get passwordConfirm => '確認密碼';

  @override
  String get passwordTooShort => '至少 8 個字元。';

  @override
  String get passwordsDiffer => '兩次輸入的密碼不一致。';

  @override
  String get passwordChanged => '密碼已變更。';

  @override
  String get newPasswordTitle => '新密碼';

  @override
  String get changePassword => '變更密碼';

  @override
  String get displayName => '姓名';

  @override
  String get fieldRequired => '必填欄位';

  @override
  String get verifyEmailTitle => '確認您的電子郵件地址';

  @override
  String codeSentTo(String email) {
    return '驗證碼已寄至 $email。';
  }

  @override
  String get code => '驗證碼';

  @override
  String get verify => '確認';

  @override
  String get resendCode => '重新寄送驗證碼';

  @override
  String get codeResent => '新的驗證碼已寄出。';

  @override
  String get sendCode => '寄送驗證碼';

  @override
  String get authInvalidCredentials => '電子郵件或密碼不正確。';

  @override
  String get authEmailNotConfirmed => '電子郵件地址尚未確認。';

  @override
  String get authUserExists => '此地址已註冊帳戶。';

  @override
  String get authWeakPassword => '密碼強度太弱。';

  @override
  String get authCodeInvalid => '驗證碼無效或已過期。';

  @override
  String get authSamePassword => '新密碼必須與舊密碼不同。';

  @override
  String get errorDuplicate => '此值已存在。';

  @override
  String get errorInvalidHours => '營業時間無效。';

  @override
  String get createRestaurant => '建立我的餐廳';

  @override
  String get joinTeam => '加入團隊';

  @override
  String get organizationName => '組織名稱';

  @override
  String get brandNameOptional => '商號（選填）';

  @override
  String get branchNameOptional => '門市名稱（選填）';

  @override
  String get country => '國家/地區';

  @override
  String get currency => '貨幣';

  @override
  String get timezone => '時區';

  @override
  String get defaultLanguage => '主要語言';

  @override
  String get city => '城市';

  @override
  String get create => '建立';

  @override
  String get invitationCode => '邀請碼';

  @override
  String get join => '加入';

  @override
  String get navBranches => '門市';

  @override
  String get navTeam => '團隊';

  @override
  String get navAudit => '日誌';

  @override
  String get navAccount => '帳戶';

  @override
  String get switchOrganization => '切換組織';

  @override
  String get orgSuspended => '組織已暫停：僅可檢視。';

  @override
  String get newBranch => '新門市';

  @override
  String get noBranches => '尚無門市。';

  @override
  String get branchInfo => '資訊';

  @override
  String get openingHours => '營業時間';

  @override
  String get floor => '用餐區';

  @override
  String get name => '名稱';

  @override
  String get addressLine1 => '地址';

  @override
  String get addressLine2 => '地址補充';

  @override
  String get region => '省/州';

  @override
  String get postalCode => '郵遞區號';

  @override
  String get phone => '電話';

  @override
  String get offeredLanguages => '提供的語言';

  @override
  String get published => '顧客可見';

  @override
  String get archived => '已封存';

  @override
  String get readOnly => '僅可檢視';

  @override
  String get save => '儲存';

  @override
  String get saved => '已儲存。';

  @override
  String get cancel => '取消';

  @override
  String get confirm => '確認';

  @override
  String get close => '關閉';

  @override
  String get edit => '編輯';

  @override
  String get retry => '重試';

  @override
  String get closed => '休息';

  @override
  String get addSlot => '新增時段';

  @override
  String get opensAt => '開始營業';

  @override
  String get closesAt => '結束營業';

  @override
  String get nextDay => '隔日';

  @override
  String get weekday1 => '星期一';

  @override
  String get weekday2 => '星期二';

  @override
  String get weekday3 => '星期三';

  @override
  String get weekday4 => '星期四';

  @override
  String get weekday5 => '星期五';

  @override
  String get weekday6 => '星期六';

  @override
  String get weekday7 => '星期日';

  @override
  String get newArea => '新區域';

  @override
  String get areaName => '區域';

  @override
  String get noAreas => '尚無區域。';

  @override
  String get newTable => '新餐桌';

  @override
  String get tableLabel => '餐桌名稱';

  @override
  String get seats => '座位';

  @override
  String get active => '啟用';

  @override
  String get inactive => '已停用';

  @override
  String tablesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 張餐桌',
      zero: '無餐桌',
    );
    return '$_temp0';
  }

  @override
  String seatsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 個座位',
    );
    return '$_temp0';
  }

  @override
  String get invite => '邀請';

  @override
  String get role => '角色';

  @override
  String get allBranches => '所有門市';

  @override
  String get pendingInvitations => '待處理的邀請';

  @override
  String expiresOn(String date) {
    return '$date 到期';
  }

  @override
  String get revoke => '移除';

  @override
  String revokeConfirm(String name) {
    return '將 $name 移出組織？';
  }

  @override
  String get changeRole => '變更角色';

  @override
  String get you => '您';

  @override
  String get invitationCreatedTitle => '邀請已建立';

  @override
  String invitationCreatedBody(String email) {
    return '請將此邀請碼傳送給 $email。有效期 7 天，僅適用於此地址。';
  }

  @override
  String invitationMessage(String organization, String code) {
    return '您受邀在 Resto 上加入「$organization」。請使用此電子郵件地址建立帳戶，然後在「加入團隊」中輸入此邀請碼：$code';
  }

  @override
  String get copyMessage => '複製訊息';

  @override
  String get copied => '已複製。';

  @override
  String get roleOwner => '擁有者';

  @override
  String get roleAdmin => '管理員';

  @override
  String get roleManager => '店長';

  @override
  String get roleAccountant => '會計';

  @override
  String get roleCashier => '收銀員';

  @override
  String get roleStockKeeper => '倉管員';

  @override
  String get roleWaiter => '服務生';

  @override
  String get roleKitchen => '廚房 / 吧台';

  @override
  String get roleViewer => '檢視者';

  @override
  String get loadMore => '顯示更多';

  @override
  String get noEntries => '尚無操作紀錄。';

  @override
  String get actionInsert => '建立';

  @override
  String get actionUpdate => '修改';

  @override
  String get actionDelete => '刪除';

  @override
  String get entityOrganization => '組織';

  @override
  String get entityMembership => '成員';

  @override
  String get entityInvitation => '邀請';

  @override
  String get entityBrand => '品牌';

  @override
  String get entityBranch => '門市';

  @override
  String get entityArea => '區域';

  @override
  String get entityTable => '餐桌';

  @override
  String get navMenus => '菜單';

  @override
  String get brand => '品牌';

  @override
  String get category => '分類';

  @override
  String get description => '描述';

  @override
  String get newCategory => '新分類';

  @override
  String get kindFood => '餐點';

  @override
  String get kindDrink => '飲品';

  @override
  String get kindOther => '其他';

  @override
  String selectionRule(int min, String max) {
    return '選擇：$min 至 $max';
  }

  @override
  String get allergens => '過敏原';

  @override
  String get allergenGluten => '麩質';

  @override
  String get allergenCrustaceans => '甲殼類';

  @override
  String get allergenEggs => '蛋類';

  @override
  String get allergenFish => '魚類';

  @override
  String get allergenPeanuts => '花生';

  @override
  String get allergenSoybeans => '大豆';

  @override
  String get allergenMilk => '乳製品';

  @override
  String get allergenNuts => '堅果';

  @override
  String get allergenCelery => '芹菜';

  @override
  String get allergenMustard => '芥末';

  @override
  String get allergenSesame => '芝麻';

  @override
  String get allergenSulphites => '亞硫酸鹽';

  @override
  String get allergenLupin => '羽扇豆';

  @override
  String get allergenMolluscs => '軟體動物';

  @override
  String get translations => '翻譯';

  @override
  String get soldOut => '售完';

  @override
  String get channelDefault => '基本價格';

  @override
  String get channelDineIn => '內用';

  @override
  String get channelTakeaway => '外帶';

  @override
  String get channelDelivery => '外送';

  @override
  String get otherChannels => '依通路定價';

  @override
  String get noPrice => '無價格';

  @override
  String get errorInvalidPrice => '價格無效。';

  @override
  String get errorCurrencyLocked => '貨幣無法再變更：此門市已有價格。';

  @override
  String get entityItem => '品項';

  @override
  String get entityVariant => '規格';

  @override
  String get entityModifier => '加點';

  @override
  String get entityPrice => '價格';

  @override
  String get menuOfBranch => '門市菜單';

  @override
  String get menuEmptyTitle => '您的菜單還是空的';

  @override
  String get menuEmptyHint => '先建立一個分類（例如：餐點、飲品、甜點），再新增品項及其價格。';

  @override
  String get categoryExamples => '例如：餐點、飲品、甜點';

  @override
  String get descriptionOptional => '描述（選填）';

  @override
  String get visibleOnMenu => '在菜單上顯示';

  @override
  String get hidden => '已隱藏';

  @override
  String get addItem => '新增品項';

  @override
  String addItemIn(String category) {
    return '在「$category」中新增品項';
  }

  @override
  String get notSoldHere => '本門市未販售';

  @override
  String get itemName => '品項名稱';

  @override
  String get itemExamples => '例如：恩多萊、DG 雞、洛神花汁';

  @override
  String get priceTitle => '價格';

  @override
  String priceAt(String branch) {
    return '$branch 的價格';
  }

  @override
  String get price => '價格';

  @override
  String get severalSizes => '此品項有多種規格';

  @override
  String get sizeName => '規格';

  @override
  String get sizeExamples => '例如：小份、33 毫升';

  @override
  String get addSize => '新增規格';

  @override
  String get removeSize => '移除此規格';

  @override
  String get sizeNameRequired => '請為每個規格命名（例如：小份、大份）。';

  @override
  String get samePriceEverywhere => '此價格將適用於下方選擇的所有門市，之後可分別調整。';

  @override
  String get salesTitle => '販售';

  @override
  String soldAt(String branch) {
    return '在 $branch 販售';
  }

  @override
  String get soldOutToday => '暫時售完';

  @override
  String get optionsForItem => '提供給顧客的選項';

  @override
  String get manageOptions => '管理選項';

  @override
  String get noOptionsYet => '尚無選項（配菜、熟度、醬料……）。';

  @override
  String get optionsTitle => '選項與加點';

  @override
  String get optionsIntro => '選項是顧客點餐時所做的選擇：配菜、熟度、醬料、付費加點……';

  @override
  String get newOptionGroup => '新選項';

  @override
  String get optionGroupName => '選項名稱';

  @override
  String get optionGroupExamples => '例如：配菜、熟度、辣度';

  @override
  String get customerMust => '顧客：';

  @override
  String get ruleRequiredOne => '必須選擇 1 項（必選）';

  @override
  String get ruleOptionalOne => '可以選擇 1 項（選填）';

  @override
  String get ruleOptionalMany => '可以選擇多項（選填）';

  @override
  String get ruleRequiredMany => '至少選擇 1 項，可多選';

  @override
  String get choices => '可選項目';

  @override
  String choicePriceHint(String branch) {
    return '若免費，價格留空或填 0。$branch 的價格。';
  }

  @override
  String get choiceName => '選項';

  @override
  String get choiceExamples => '例如：木薯棒、米飯';

  @override
  String get extraPrice => '加價';

  @override
  String get addChoice => '新增選項';

  @override
  String get removeChoice => '移除此選項';

  @override
  String get choicesRequired => '請至少新增一個選項。';

  @override
  String get navOrders => '訂單';

  @override
  String openOrdersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 筆進行中的訂單',
      zero: '尚無進行中的訂單',
    );
    return '$_temp0';
  }

  @override
  String get refresh => '重新整理';

  @override
  String get newTakeaway => '外帶銷售';

  @override
  String get takeawayOrders => '進行中的外帶訂單';

  @override
  String orderNumber(int number) {
    return '訂單 $number 號';
  }

  @override
  String minutesAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 分鐘前',
      zero: '剛剛',
    );
    return '$_temp0';
  }

  @override
  String get noTablesYet => '尚無餐桌：請在 門市 → 用餐區 中設定。外帶銷售仍可進行。';

  @override
  String get tableFree => '空桌';

  @override
  String get toSend => '待送廚房的品項';

  @override
  String tableName(String label) {
    return '$label 號桌';
  }

  @override
  String get menuTab => '菜單';

  @override
  String ticketTab(int count) {
    return '訂單（$count）';
  }

  @override
  String get allCategories => '全部';

  @override
  String get nothingToSell => '尚無可售品項：請在 菜單 中新增有價格的品項。';

  @override
  String fromPrice(String price) {
    return '$price 起';
  }

  @override
  String itemSoldOut(String name) {
    return '$name 已售完。';
  }

  @override
  String get emptyTicket => '點選菜單中的品項即可加入。';

  @override
  String get less => '減一份';

  @override
  String get more => '加一份';

  @override
  String get cancelLine => '取消此行';

  @override
  String get cancelOrder => '取消訂單';

  @override
  String get cancelOrderConfirm => '取消此訂單？尚未送往廚房。';

  @override
  String get reason => '原因';

  @override
  String get subtotal => '小計';

  @override
  String taxLine(String rate) {
    return '稅（$rate%）';
  }

  @override
  String get total => '合計';

  @override
  String taxIncluded(String rate, String amount) {
    return '含稅 $rate%：$amount';
  }

  @override
  String sendToKitchen(int count) {
    return '送往廚房（$count）';
  }

  @override
  String sentToKitchen(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '已將 $count 份品項送往廚房',
    );
    return '$_temp0';
  }

  @override
  String get prepPending => '待送出';

  @override
  String get prepSent => '廚房中';

  @override
  String get prepPreparing => '製作中';

  @override
  String get prepReady => '已完成';

  @override
  String get prepServed => '已上菜';

  @override
  String get prepCancelled => '已取消';

  @override
  String get noneOption => '不需要';

  @override
  String get kitchenNote => '給廚房的備註（選填）';

  @override
  String get kitchenNoteExamples => '例如：不要洋蔥、全熟';

  @override
  String get quantity => '數量';

  @override
  String addForPrice(String price) {
    return '加入 · $price';
  }

  @override
  String get taxTitle => '稅';

  @override
  String get taxRate => '稅率';

  @override
  String get taxRateHint => '例如：19.25（無稅填 0）';

  @override
  String get pricesIncludeTax => '顯示價格已含稅';

  @override
  String get errorInvalidTaxRate => '稅率無效（0 至 99.999）。';

  @override
  String get errorOrderNotOpen => '此訂單已不再開放。';

  @override
  String get errorItemUnavailable => '此品項在本門市無法販售。';

  @override
  String get errorNoPrice => '此品項在本門市沒有價格。';

  @override
  String get errorOptionsInvalid => '所選選項不符合該品項的規則。';

  @override
  String get errorInvalidQuantity => '數量無效。';

  @override
  String get errorItemAlreadySent => '此行已送往廚房，無法再修改。';

  @override
  String get errorReasonRequired => '請填寫原因。';

  @override
  String get errorInvalidOrder => '訂單無效。';

  @override
  String get errorBranchInactive => '此門市已封存。';

  @override
  String get navCash => '收銀';

  @override
  String get amount => '金額';

  @override
  String get registerClosed => '已關閉';

  @override
  String get openRegisterShort => '開啟收銀台';

  @override
  String openRegister(String name) {
    return '開啟 $name';
  }

  @override
  String get openingFloat => '零用金（初始零錢）';

  @override
  String registerOpenSince(String time) {
    return '自 $time 起開啟';
  }

  @override
  String expectedCash(String amount) {
    return '應有現金：$amount';
  }

  @override
  String cashBreakdown(String float, String inAmount, String outAmount) {
    return '零用金 $float · 存入 $inAmount · 取出 $outAmount';
  }

  @override
  String paymentsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 筆付款',
      zero: '無付款',
    );
    return '$_temp0';
  }

  @override
  String get cashIn => '存入現金';

  @override
  String get cashOut => '取出現金';

  @override
  String get movementExamples => '例如：購買瓦斯、補充零錢';

  @override
  String get closeRegister => '關閉收銀台';

  @override
  String get countedCash => '錢箱內清點的現金';

  @override
  String get countInfo => '清點錢箱內的紙鈔和硬幣，包括零用金。';

  @override
  String get countResult => '清點結果';

  @override
  String countedCashValue(String amount) {
    return '實點：$amount';
  }

  @override
  String get noDifference => '無差額';

  @override
  String differenceValue(String amount) {
    return '差額：$amount';
  }

  @override
  String get awaitingValidation => '現在需要負責人確認此次結帳。';

  @override
  String get awaitingValidationTitle => '待確認的結帳';

  @override
  String get validateClosing => '確認結帳';

  @override
  String get validate => '確認';

  @override
  String get comment => '備註';

  @override
  String get closedSessions => '最近的結帳';

  @override
  String get dailyReport => '日報';

  @override
  String get previousDay => '前一天';

  @override
  String get nextDayButton => '後一天';

  @override
  String get salesTotal => '營業額';

  @override
  String get ordersClosedCount => '已付款訂單';

  @override
  String get averageTicket => '客單價';

  @override
  String get taxCollected => '已收稅額';

  @override
  String get paymentsReceived => '依付款方式收款';

  @override
  String ordersStillOpen(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 筆訂單仍在進行',
      zero: '無進行中的訂單',
    );
    return '$_temp0';
  }

  @override
  String ordersCancelledCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 筆已取消',
      zero: '無取消',
    );
    return '$_temp0';
  }

  @override
  String linesCancelledCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 行已取消',
      zero: '無取消的行',
    );
    return '$_temp0';
  }

  @override
  String refundsTotal(String amount) {
    return '已退款：$amount';
  }

  @override
  String get topItems => '最暢銷品項';

  @override
  String get payCash => '現金';

  @override
  String get payCard => '信用卡';

  @override
  String get payMobileMoney => '行動支付';

  @override
  String get payTransfer => '轉帳';

  @override
  String get payOther => '其他';

  @override
  String get collectPayment => '收款';

  @override
  String collectAmount(String amount) {
    return '收款 $amount';
  }

  @override
  String amountDue(String amount) {
    return '待付：$amount';
  }

  @override
  String get splitBill => '分攤帳單';

  @override
  String splitParts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 份',
    );
    return '$_temp0';
  }

  @override
  String get amountToCollect => '收款金額';

  @override
  String get cashTendered => '顧客所付現金（選填）';

  @override
  String changeToGive(String amount) {
    return '找零：$amount';
  }

  @override
  String get giveChange => '應找零錢';

  @override
  String get transactionReference => '交易編號（選填）';

  @override
  String get manualPaymentNote => '信用卡和行動支付：請在確認前核實款項已入帳。';

  @override
  String get openCashFirst => '請先開啟收銀台（收銀 區塊）。';

  @override
  String get chooseRegister => '選擇收銀台';

  @override
  String get orderPaidClosed => '訂單已付款並關閉。';

  @override
  String get paid => '已付';

  @override
  String get remainingDue => '待付';

  @override
  String get voided => '已作廢';

  @override
  String get voidPayment => '作廢此筆付款';

  @override
  String get orderClosed => '訂單已付款並關閉';

  @override
  String get orderCancelled => '訂單已取消';

  @override
  String get errorNoOpenSession => '沒有可用於此次收款的已開啟收銀台。';

  @override
  String get errorSessionAlreadyOpen => '此收銀台已開啟。';

  @override
  String get errorRegisterInactive => '此收銀台已停用。';

  @override
  String get errorInvalidAmount => '金額無效。';

  @override
  String get errorNotEnoughCash => '收銀台現金不足。';

  @override
  String get errorOverpayment => '金額超過待付金額。';

  @override
  String get errorTenderedTooLow => '顧客所付現金少於金額。';

  @override
  String get errorOrderHasPayments => '此訂單已有付款：請先作廢或退款。';

  @override
  String get errorPendingLines => '部分品項尚未送往廚房。';

  @override
  String get errorNotFullyPaid => '訂單尚未全額付款。';

  @override
  String get errorSessionNotCounted => '此收銀台尚未清點。';

  @override
  String get navKitchen => '廚房';

  @override
  String get allStations => '所有工作站';

  @override
  String get stations => '製作工作站';

  @override
  String get newStation => '新工作站';

  @override
  String get stationExamples => '例如：廚房、吧台、燒烤';

  @override
  String get stationPrepares => '此工作站製作：';

  @override
  String get kitchenEmpty => '目前沒有需要製作的品項。';

  @override
  String get allReady => '全部完成';

  @override
  String get markServed => '已上菜';

  @override
  String get errorInvalidStatus => '無法進行此狀態變更。';

  @override
  String get navStock => '庫存';

  @override
  String get stockLevels => '庫存狀況';

  @override
  String get ingredientsTab => '原料';

  @override
  String get recipesTab => '標準配方';

  @override
  String get inventoriesTab => '盤點';

  @override
  String get movementsTab => '進出庫';

  @override
  String stockValue(String amount) {
    return '庫存價值：$amount';
  }

  @override
  String lowStockCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 種原料低於警示值',
    );
    return '$_temp0';
  }

  @override
  String actionsAt(String location) {
    return '庫位：$location';
  }

  @override
  String get newLocation => '新庫位';

  @override
  String get locationExamples => '例如：冷藏庫、酒窖、廚房';

  @override
  String get chooseLocation => '選擇庫位';

  @override
  String get toLocation => '調入庫位';

  @override
  String get noIngredientsYet => '尚無原料：請在「原料」分頁中新增。';

  @override
  String alertAt(String qty) {
    return '警示值 $qty';
  }

  @override
  String avgCost(String amount, String unit) {
    return '平均成本 $amount / $unit';
  }

  @override
  String get alertThreshold => '警示值';

  @override
  String get alertBelow => '低於此值時警示';

  @override
  String get produce => '生產';

  @override
  String get adjustmentQuantity => '調整（+ 或 −）';

  @override
  String unitCost(String unit) {
    return '每$unit成本';
  }

  @override
  String get unitPiece => '個';

  @override
  String get unitDozen => '打';

  @override
  String get newIngredient => '新原料';

  @override
  String get ingredientExamples => '例如：雞肉、棕櫚油、33 公撮可樂瓶';

  @override
  String get ingredientKind => '類型';

  @override
  String get stockUnit => '庫存單位';

  @override
  String get ingRaw => '原材料';

  @override
  String get ingBeverage => '飲品';

  @override
  String get ingPackaging => '包裝';

  @override
  String get ingSemiFinished => '自製半成品';

  @override
  String get ingConsumable => '耗材';

  @override
  String get mvOpening => '期初庫存';

  @override
  String get mvReceipt => '入庫（採購）';

  @override
  String get mvSale => '銷售';

  @override
  String get mvProductionIn => '生產';

  @override
  String get mvProductionOut => '生產領用';

  @override
  String get mvWaste => '損耗 / 破損';

  @override
  String get mvStaffMeal => '員工餐';

  @override
  String get mvReturn => '退貨給供應商';

  @override
  String get mvTransferIn => '調撥入庫';

  @override
  String get mvTransferOut => '調撥';

  @override
  String get mvAdjustment => '調整';

  @override
  String get mvInventory => '盤點差異';

  @override
  String get recipesIntro => '標準配方列出品項的原料：每筆已付款的銷售都會自動扣減庫存，並計算成本價。';

  @override
  String get noRecipe => '無配方';

  @override
  String costPrice(String amount) {
    return '成本價：$amount';
  }

  @override
  String sellingPrice(String amount) {
    return '售價 $amount';
  }

  @override
  String marginPercent(int percent) {
    return '毛利 $percent%';
  }

  @override
  String recipeOf(String name) {
    return '配方：$name';
  }

  @override
  String get portions => '份數';

  @override
  String get yieldQuantity => '產出數量';

  @override
  String get ingredient => '原料';

  @override
  String get wastePercent => '損耗';

  @override
  String get removeLine => '刪除此行';

  @override
  String get addIngredientLine => '新增原料';

  @override
  String get preparationNotes => '製作說明（選填）';

  @override
  String get newInventory => '新盤點';

  @override
  String get inventoriesIntro => '盤點會比較實點庫存與計算庫存；經負責人確認後記錄差異。';

  @override
  String inventoryValidated(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '已確認，$count 項差異',
      zero: '已確認，無差異',
    );
    return '$_temp0';
  }

  @override
  String inventoryDraft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '進行中，已清點 $count 行',
      zero: '進行中，尚未清點',
    );
    return '$_temp0';
  }

  @override
  String inventoryOf(String location) {
    return '盤點：$location';
  }

  @override
  String get inventoryHint => '請填寫實際清點的數量。留空的行不會被修改。';

  @override
  String inventoryDifference(String qty) {
    return '差異 $qty';
  }

  @override
  String get search => '搜尋';

  @override
  String get validateInventory => '確認盤點';

  @override
  String get validateInventoryConfirm => '確認此次盤點？差異將計入庫存，且盤點將無法再修改。';

  @override
  String inventoryAdjustments(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '盤點已確認：已記錄 $count 項差異',
      zero: '盤點已確認：無差異',
    );
    return '$_temp0';
  }

  @override
  String get errorInvalidMovement => '庫存異動無效。';

  @override
  String get errorUnitLocked => '庫存單位無法再變更：此原料已有進出庫紀錄。';

  @override
  String get errorNoRecipe => '此半成品沒有配方。';

  @override
  String get errorInvalidRecipe => '配方無效：請檢查原料、數量和單位。';

  @override
  String get errorInventoryClosed => '此次盤點已確認。';

  @override
  String get navGroupService => '服務';

  @override
  String get navGroupManagement => '管理';

  @override
  String get navGroupOrganization => '組織';

  @override
  String get navPurchases => '採購';

  @override
  String get navExpenses => '支出';

  @override
  String get navReports => '報表';

  @override
  String get invoicesTab => '發票';

  @override
  String get purchaseOrdersTab => '採購單';

  @override
  String get receiptsTab => '收貨';

  @override
  String get suppliersTab => '供應商';

  @override
  String get newSupplier => '新供應商';

  @override
  String get noSuppliersYet => '尚無供應商。請新增常用供應商（市場、批發商、啤酒廠……）。';

  @override
  String get addSupplierFirst => '請先新增供應商（「供應商」分頁）。';

  @override
  String get contactName => '聯絡人';

  @override
  String get taxId => '統一編號 / 稅籍編號';

  @override
  String get paymentTermsLabel => '付款期限';

  @override
  String get days => '天';

  @override
  String paymentTerms(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days 天內付款',
    );
    return '$_temp0';
  }

  @override
  String get supplier => '供應商';

  @override
  String get supplierOptional => '供應商（選填）';

  @override
  String get newPurchaseOrder => '新採購單';

  @override
  String get noPurchaseOrders => '尚無採購單。採購單用於準備採購；到貨時點選「收貨」即可入庫。';

  @override
  String poNumber(int number) {
    return '採購單 $number 號';
  }

  @override
  String get poDraft => '草稿';

  @override
  String get poSent => '已送出';

  @override
  String get poPartial => '部分到貨';

  @override
  String get poReceived => '已到貨';

  @override
  String get poCancelled => '已取消';

  @override
  String get poMarkSent => '標記為已送出';

  @override
  String get poReceive => '收貨';

  @override
  String get poCancel => '取消採購單';

  @override
  String get cancelPoConfirm => '取消此採購單？';

  @override
  String expectedOn(String date) {
    return '預計 $date 到貨';
  }

  @override
  String get expectedDateOptional => '預計到貨日期（選填）';

  @override
  String unitPrice(String unit) {
    return '每$unit價格';
  }

  @override
  String totalAmount(String amount) {
    return '合計：$amount';
  }

  @override
  String get newReceipt => '新收貨';

  @override
  String get receiptsIntro => '收貨用於登記已送達的貨物：庫存與平均成本會自動更新。';

  @override
  String receiveOrder(int number) {
    return '採購單 $number 號收貨';
  }

  @override
  String get receiptHint => '請填寫實際送達的數量與價格；儲存後即入庫。';

  @override
  String get deliveryNoteNumber => '送貨單號（選填）';

  @override
  String get recordReceipt => '登記收貨';

  @override
  String get receiptRecorded => '收貨已登記：庫存已更新。';

  @override
  String get newInvoice => '新發票';

  @override
  String get invoicesIntro => '在此登記供應商發票，追蹤應付款與付款情況。';

  @override
  String supplierDebt(String amount) {
    return '應付供應商總額：$amount';
  }

  @override
  String dueOn(String date) {
    return '$date 到期';
  }

  @override
  String remaining(String amount) {
    return '剩餘 $amount';
  }

  @override
  String get invoicePaid => '已付';

  @override
  String get invoiceCancelled => '已取消';

  @override
  String get invoiceNumber => '供應商發票號碼';

  @override
  String invoiceDateValue(String date) {
    return '$date 的發票';
  }

  @override
  String get dueDateOptional => '到期日（選填：依供應商帳期）';

  @override
  String get amountExclTax => '未稅金額';

  @override
  String get taxAmount => '稅額';

  @override
  String get linkedReceipts => '相關收貨';

  @override
  String get attachDocument => '附上憑證（PDF 或照片）';

  @override
  String get fileTooLarge => '檔案過大（最大 5 MB）。';

  @override
  String get viewDocument => '檢視憑證';

  @override
  String get payInvoice => '付款';

  @override
  String get cancelInvoice => '取消發票';

  @override
  String get paidFromRegister => '以收銀台現金支付';

  @override
  String get newExpense => '新支出';

  @override
  String get noExpenses => '本月尚無支出。';

  @override
  String get previousMonth => '上個月';

  @override
  String get nextMonth => '下個月';

  @override
  String includingTax(String amount) {
    return '含稅 $amount';
  }

  @override
  String get cancelledLabel => '已取消';

  @override
  String get cancelExpense => '取消支出';

  @override
  String get expenseExamples => '例如：十月電費、冷凍櫃維修';

  @override
  String get amountInclTax => '支付金額';

  @override
  String get includedTaxOptional => '其中稅額（選填）';

  @override
  String get expRent => '租金';

  @override
  String get expElectricity => '電費';

  @override
  String get expWater => '水費';

  @override
  String get expGas => '瓦斯';

  @override
  String get expSalaries => '薪資';

  @override
  String get expTransport => '交通運輸';

  @override
  String get expMaintenance => '維護與維修';

  @override
  String get expMarketing => '廣告';

  @override
  String get expSupplies => '耗材用品';

  @override
  String get expTaxes => '稅捐';

  @override
  String get expBankFees => '銀行手續費';

  @override
  String get expOther => '其他';

  @override
  String get periodToday => '今天';

  @override
  String get periodLast7 => '最近 7 天';

  @override
  String get periodMonth => '本月';

  @override
  String get periodLastMonth => '上月';

  @override
  String get periodCustom => '其他期間…';

  @override
  String get salesInclTax => '含稅營業額';

  @override
  String get salesExclTax => '未稅營業額';

  @override
  String get collected => '實收款';

  @override
  String get costOfSales => '銷貨成本';

  @override
  String get grossMargin => '毛利';

  @override
  String get lossesValue => '損耗與差異';

  @override
  String get expensesExclTax => '未稅支出';

  @override
  String get estimatedResult => '估算損益';

  @override
  String get purchasesValue => '採購（未稅發票）';

  @override
  String get supplierDebtShort => '應付供應商';

  @override
  String ordersCountShort(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 筆訂單',
      zero: '無訂單',
    );
    return '$_temp0';
  }

  @override
  String get ruleSales => '期間內已付款並關閉的訂單總額（依營業日）。';

  @override
  String get ruleSalesHt => '含稅營業額減去已收稅額。';

  @override
  String get ruleCollected => '期間內實際收到的款項（所有方式）減去退款。可能與營業額不同（預付款、未結訂單）。';

  @override
  String get ruleCogs => '依標準配方與平均採購成本計算的銷售耗用原料價值。無配方的品項不計入。';

  @override
  String get ruleGrossMargin => '未稅營業額減去銷貨成本。';

  @override
  String get ruleLosses => '損耗、員工餐、調整與盤點差異的價值。';

  @override
  String get ruleExpenses => '期間內登記的未稅支出（不含已取消的支出）。';

  @override
  String get ruleResult => '毛利減去損耗與支出。管理估算，不含折舊或未登記的費用：並非會計損益。';

  @override
  String get rulePurchases => '期間內日期的供應商發票（未稅）。採購計入庫存：耗用前不算成本。';

  @override
  String get ruleDebt => '截至今日未結供應商發票的待付金額。';

  @override
  String get expensesByCategory => '依類別統計的支出（未稅）';

  @override
  String get resultDisclaimer =>
      '這些數據依 Resto 中登記的業務計算：銷售、收款、理論耗用、支出。將游標停在 ⓘ 上可檢視每項指標的計算規則。';

  @override
  String get exportsTitle => '匯出（CSV 檔案，可用 Excel 開啟）';

  @override
  String get exportOrders => '訂單';

  @override
  String get exportPayments => '付款';

  @override
  String get exportExpenses => '支出';

  @override
  String get exportDownloaded => '檔案已下載。';

  @override
  String get exportCopied => '資料已複製：請貼到試算表中。';

  @override
  String get marginsByItem => '各品項毛利';

  @override
  String marginsHint(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 項品項尚無標準配方（庫存 → 標準配方）。',
      zero: '所有已售品項都有標準配方。',
    );
    return '$_temp0';
  }

  @override
  String get errorInvalidPurchase => '採購資料不完整：請檢查供應商、原料、數量、單位與價格。';

  @override
  String get errorPurchaseNotDraft => '此採購單已無法修改。';

  @override
  String get errorDuplicateInvoice => '該供應商的此張發票已登記。';

  @override
  String get errorInvoiceNotOpen => '此發票已不再開放。';

  @override
  String get errorInvoiceHasPayments => '此發票已有付款：請先作廢付款。';

  @override
  String get errorInvalidExpense => '支出資料不完整：類別、說明與金額為必填；稅額不得超過金額。';

  @override
  String get errorInvalidAttachment => '憑證遭拒。';

  @override
  String get errorInvalidPeriod => '期間無效。';

  @override
  String get errorBelowMinimum => '未達最低訂單金額。';

  @override
  String get errorDeliveryUnavailable => '無法外送：請檢查地址和電話，或選擇「外帶」。';

  @override
  String get errorInvalidImage => '照片被拒絕（格式或位置無效）。';

  @override
  String get errorNotFound => '找不到。';

  @override
  String get errorOnlineOrdersClosed => '此餐廳目前不接受線上訂單。';

  @override
  String get errorTooLateToCancel => '為時已晚：餐廳已開始處理此訂單。';

  @override
  String get errorReviewNotAllowed => '無法評價：只有 30 天內已付款的訂單可評價一次。';

  @override
  String get errorReservationsClosed => '此餐廳不接受線上訂位。';

  @override
  String get errorInvalidPartySize => '線上訂位不接受此人數。';

  @override
  String get errorInvalidReservationTime => '時間無效：至少提前 15 分鐘，最多 90 天內。';

  @override
  String get errorInvalidReservation => '訂位資訊不完整：需要姓名、電話和人數。';

  @override
  String get errorTablesRequired => '請至少選擇一張桌子。';

  @override
  String get errorNotEnoughSeats => '所選桌子座位不足。';

  @override
  String get errorTableUnavailable => '此桌在該時段已被預訂。';

  @override
  String get errorPromotionUnavailable => '優惠或代碼無效。';

  @override
  String get errorPromotionLimit => '此顧客已達此優惠的使用次數上限。';

  @override
  String get errorPromotionAlreadyApplied => '已套用於此訂單。';

  @override
  String get errorNotEnoughPoints => '點數不足。';

  @override
  String get errorAddressRequired => '必須填寫外送地址。';

  @override
  String get errorTableBusy => '此桌已有進行中的訂單。';

  @override
  String errorBetween(int min, int max) {
    return '介於 $min 和 $max 之間';
  }

  @override
  String get notPublishedHint => '此門市尚未對顧客顯示：請在「資訊」分頁中開啟「已發布」。';

  @override
  String get onlineOrdersTitle => '線上訂單';

  @override
  String get acceptOnlineOrders => '接受顧客訂單';

  @override
  String get acceptOnlineOrdersHint => '來自 App、網站或桌位 QR 碼。每筆訂單都會進入「訂單」等待接受。';

  @override
  String get acceptDelivery => '提供外送';

  @override
  String get deliveryFee => '外送費';

  @override
  String get minimumOrder => '最低訂單金額';

  @override
  String get reservationsTitle => '訂位';

  @override
  String get acceptReservations => '接受線上訂位';

  @override
  String get reservationDuration => '訂位時長';

  @override
  String get minutesShort => '分鐘';

  @override
  String get maxPartySize => '最多人數';

  @override
  String get publicProfileTitle => '餐廳公開資料';

  @override
  String get publicDescription => '簡介';

  @override
  String get publicDescriptionHint => '例如：豐盛的喀麥隆料理、每日炭烤魚、樹蔭露台。';

  @override
  String get cuisinesLabel => '料理類型';

  @override
  String get cuisinesHint => '例如：非洲料理、燒烤、海鮮（以逗號分隔）';

  @override
  String get priceLevel => '價格等級';

  @override
  String get publicPageTitle => '餐廳頁面';

  @override
  String get publicPageHint => '可分享（社群網路、WhatsApp）或列印：顧客在此查看菜單並下單。';

  @override
  String get copyLink => '複製連結';

  @override
  String get sourcePhone => '電話訂單';

  @override
  String get sourceQr => '桌位 QR 碼';

  @override
  String get sourceApp => '顧客 App';

  @override
  String get sourcePartner => '合作夥伴';

  @override
  String get sourceStaff => '店內點餐';

  @override
  String get stageToValidate => '待確認';

  @override
  String get stageDraft => '尚未送出';

  @override
  String get stageCooking => '製作中';

  @override
  String get stageReady => '可上菜';

  @override
  String get stageReadyTakeaway => '待取餐';

  @override
  String get stageReadyDelivery => '待外送員取餐';

  @override
  String get stageToPay => '待收款';

  @override
  String get stageDone => '已完成';

  @override
  String get stageCancelled => '已取消';

  @override
  String get handToCustomer => '已交給顧客';

  @override
  String get handToCourier => '已交給外送員';

  @override
  String guestsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 人',
    );
    return '$_temp0';
  }

  @override
  String forTime(String time) {
    return '$time 取';
  }

  @override
  String get billTitle => '帳單';

  @override
  String get thankYou => '感謝光臨！';

  @override
  String kdsToPrepare(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 筆訂單待製作',
      zero: '無待製作',
    );
    return '$_temp0';
  }

  @override
  String kdsLate(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 筆逾時',
    );
    return '$_temp0';
  }

  @override
  String kdsReadyCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 筆已完成',
      zero: '無已完成',
    );
    return '$_temp0';
  }

  @override
  String get kdsTickets => '單據';

  @override
  String get kdsSummary => '彙總';

  @override
  String get kdsFullScreen => '全螢幕（廚房模式）';

  @override
  String get kdsFlowHint =>
      '外場送出的訂單會伴隨提示音出現在這裡。點選品項將其設為「製作中」，再設為「已完成」。「全部完成」會立即通知服務生。';

  @override
  String get kdsReadyStrip => '已完成 — 已通知外場（「可上菜」欄），等待上菜';

  @override
  String get kdsStart => '開始';

  @override
  String kdsWaitingService(String time) {
    return '已等候 $time';
  }

  @override
  String get kdsRecall => '撤回（尚未完成）';

  @override
  String get serviceAndCustomers => '服務與顧客';

  @override
  String get serviceSettingsTitle => '服務';

  @override
  String get targetPrepTime => '目標製作時間';

  @override
  String get targetPrepTimeHint => '超過此時間，訂單會變成紅色（逾時）。';

  @override
  String get payFirstTakeaway => '外帶：製作前先收款';

  @override
  String get payFirstTakeawayHint => '外帶訂單會出現「先收款再送出」按鈕。';

  @override
  String get tableOccupied => '使用中';

  @override
  String get tableReservedNow => '目前已預訂';

  @override
  String get tableReservedSoon => '即將預訂';

  @override
  String reservedAt(String time) {
    return '$time 已預訂';
  }

  @override
  String get acceptWithDelay => '接受訂單';

  @override
  String scheduledFor(String time) {
    return '要求 $time';
  }

  @override
  String get delayAnnounced => '多久能完成？系統會通知顧客。';

  @override
  String get orderAccepted => '訂單已接受：開始製作。';

  @override
  String get rejectOrder => '拒絕訂單';

  @override
  String get rejectReasonHint => '例如：魚已售完、沒有外送員';

  @override
  String get paymentDone => '已記錄付款。';

  @override
  String get partialPaymentDone => '已記錄部分付款。';

  @override
  String get announcedDelay => '告知顧客的時間';

  @override
  String promisedFor(String time) {
    return '承諾 $time';
  }

  @override
  String get heldShort => '稍後';

  @override
  String moreItems(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '+ 另外 $count 項',
    );
    return '$_temp0';
  }

  @override
  String get paidShort => '已付款';

  @override
  String get partlyPaid => '部分付款';

  @override
  String get notPaid => '未付款';

  @override
  String get reject => '拒絕';

  @override
  String get accept => '接受';

  @override
  String get sendShort => '送出';

  @override
  String get fireNext => '上下一道';

  @override
  String get collectShort => '收款';

  @override
  String get columnInProgress => '進行中';

  @override
  String get columnReady => '可上菜';

  @override
  String get columnToValidateHint =>
      '顧客下的訂單（App、網站、桌位 QR 碼）會伴隨提示音出現在這裡。請告知時間並接受。';

  @override
  String get columnInProgressHint => '已點餐且製作中。「送出」會把品項送到廚房和吧台。';

  @override
  String get columnReadyHint => '廚房點選「全部完成」後，訂單會出現在這裡（伴隨提示音）：上桌、交給顧客或外送員。';

  @override
  String get columnToPayHint => '全部已上桌：只剩收款。付款後訂單完成，桌位空出。';

  @override
  String get allOrders => '全部';

  @override
  String get searchOrderHint => '編號、顧客、桌號、電話';

  @override
  String get chooseTable => '選擇桌子';

  @override
  String get tableHasOrder => '此桌已有進行中的訂單：將開啟該訂單。';

  @override
  String tableReservationWarning(String time, String name, int count) {
    return '注意：$time 已預訂 · $name · $count 人';
  }

  @override
  String get guestsLabel => '人數';

  @override
  String get receivedByPhone => '電話接到的訂單';

  @override
  String get customerName => '顧客姓名';

  @override
  String get customerNameOptional => '顧客姓名（選填）';

  @override
  String get phoneOptional => '電話（選填）';

  @override
  String get deliveryAddress => '外送地址';

  @override
  String get deliveryAddressHint => '街區、街道、地標（例如：Bonamoussadi，藥局旁）';

  @override
  String get deliveryInstructions => '給外送員的說明';

  @override
  String get deliveryInstructionsHint => '例如：黃色大樓，二樓，抵達時來電';

  @override
  String get deliveryTime => '外送時間';

  @override
  String get pickupTime => '取餐時間';

  @override
  String get asap => '盡快';

  @override
  String get atFixedTime => '指定時間';

  @override
  String atTime(String time) {
    return '$time';
  }

  @override
  String get newOrder => '新訂單';

  @override
  String get orderTypeQuestion => '哪種訂單？';

  @override
  String get dineInHint => '顧客在桌位就座';

  @override
  String get takeawayHint => '顧客帶走訂單';

  @override
  String get deliveryHint => '送到指定地址';

  @override
  String get orderNote => '訂單備註（選填）';

  @override
  String get orderNoteHint => '例如：生日、顧客趕時間、花生過敏';

  @override
  String get continueToMenu => '繼續：選擇餐點';

  @override
  String get moveTable => '換桌';

  @override
  String get noFreeTable => '目前沒有空桌。';

  @override
  String get print => '列印';

  @override
  String get printKitchenTicket => '製作單（廚房）';

  @override
  String get printBill => '帳單（顧客）';

  @override
  String get orderHistory => '訂單紀錄';

  @override
  String get searchDish => '搜尋餐點、飲品…';

  @override
  String get noResults => '沒有結果。';

  @override
  String get groupToSend => '待送出';

  @override
  String get groupHeld => '稍後（之後送出）';

  @override
  String get groupCooking => '製作中';

  @override
  String get groupReady => '可上菜';

  @override
  String get groupServed => '已上桌';

  @override
  String get groupCancelled => '已取消';

  @override
  String collectThenSend(String amount) {
    return '收款 $amount 後送出';
  }

  @override
  String fireNextCount(int count) {
    return '上下一道（$count）';
  }

  @override
  String get customerOrderToValidate => '待確認的顧客訂單';

  @override
  String get customerOrderToValidateHint => '核對品項後接受（並告知時間）或拒絕。系統會通知顧客。';

  @override
  String get payFirstHint => '外帶：製作前付款（門市設定）。';

  @override
  String get addedByCustomer => '顧客新增';

  @override
  String get sendWithOrder => '與其餘一起送出';

  @override
  String get holdForLater => '設為「稍後」（之後送出）';

  @override
  String openedAt(String time) {
    return '$time 開單';
  }

  @override
  String get fromReservation => '顧客已入座（訂位）';

  @override
  String get editOrderDetails => '修改資訊';

  @override
  String get evOpened => '訂單已開立';

  @override
  String evItemAdded(String item) {
    return '新增：$item';
  }

  @override
  String get evItemUpdated => '品項已修改';

  @override
  String get evItemRemoved => '品項已移除';

  @override
  String evSent(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '已送到廚房（$count 項）',
    );
    return '$_temp0';
  }

  @override
  String get evItemCancelled => '品項已取消';

  @override
  String get evCancelled => '訂單已取消';

  @override
  String get evClosed => '訂單已完成';

  @override
  String evPayment(String amount) {
    return '付款 $amount';
  }

  @override
  String get evRefund => '退款';

  @override
  String get evDetailsUpdated => '資訊已修改';

  @override
  String get itemsTotal => '品項';

  @override
  String get removeDiscount => '移除折扣';

  @override
  String get addDiscount => '新增折扣';

  @override
  String get applyPromotion => '套用優惠';

  @override
  String get promoCode => '優惠碼';

  @override
  String get promoCodeHint => '例如：WELCOME10';

  @override
  String get manualDiscount => '折扣（商業讓利）';

  @override
  String get useLoyalty => '使用點數';

  @override
  String get noActivePromotion => '目前沒有進行中的優惠。請在「顧客與會員」中建立。';

  @override
  String get inPercent => '按 %';

  @override
  String get inAmount => '按金額';

  @override
  String get percentValue => '百分比';

  @override
  String get manualDiscountHint => '例如：等候過久、老顧客';

  @override
  String get apply => '套用';

  @override
  String get allAreas => '所有區域';

  @override
  String get planView => '座位圖';

  @override
  String get cardsView => '卡片';

  @override
  String get editFloor => '編輯座位配置';

  @override
  String get done => '完成';

  @override
  String get floorEmptyTitle => '建立您的座位配置';

  @override
  String get floorEmptyHint =>
      '先新增區域（大廳、露台、VIP…），再以您喜歡的名稱新增桌子（1 號桌、VIP 1、吧台 2…）。之後即可即時查看哪些桌子空閒、使用中或已預訂。';

  @override
  String get editFloorHint => '拖曳桌子以還原您的座位配置。點選桌子可修改名稱、座位或形狀。';

  @override
  String get noTablesInArea => '此區域沒有桌子：點選「編輯座位配置」，再點「新增桌子」。';

  @override
  String get newOrderAtTable => '在此桌新增訂單';

  @override
  String get openOrder => '開啟訂單';

  @override
  String get reservationsToday => '今日訂位';

  @override
  String get reserveTable => '訂位';

  @override
  String get noReservationToday => '此桌今天沒有訂位。';

  @override
  String get tableQrCode => '桌位 QR 碼';

  @override
  String get tableQrHint => '列印後放在桌上：顧客掃碼即可查看附照片的菜單並下單。訂單會進入「待確認」。';

  @override
  String get areaNameHint => '例如：大廳、露台、VIP、樓上';

  @override
  String get tableLabelHint => '例如：1 號桌、VIP 1、吧台 2';

  @override
  String get tableShape => '形狀';

  @override
  String get shapeSquare => '方形';

  @override
  String get shapeRound => '圓形';

  @override
  String get shapeRect => '長方形';

  @override
  String get resRequested => '已申請';

  @override
  String get resConfirmed => '已確認';

  @override
  String get resSeated => '已入座';

  @override
  String get resCompleted => '已完成';

  @override
  String get resNoShow => '未到店';

  @override
  String get resDeclined => '已拒絕';

  @override
  String get resCancelled => '已取消';

  @override
  String reservationRequests(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 筆訂位申請待處理',
    );
    return '$_temp0';
  }

  @override
  String get reservationRequestsHint => '顧客線上提出的申請：選擇桌子確認，或說明原因拒絕。系統會通知顧客。';

  @override
  String get declineReservation => '拒絕訂位';

  @override
  String get confirmReservation => '確認';

  @override
  String reservationsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 筆訂位',
      zero: '沒有訂位',
    );
    return '$_temp0';
  }

  @override
  String coversCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 位',
    );
    return '$_temp0';
  }

  @override
  String get noReservationsDay => '當天沒有訂位。';

  @override
  String get today => '今天';

  @override
  String get timelineView => '時間軸';

  @override
  String get listView => '清單';

  @override
  String get newReservation => '新增訂位';

  @override
  String get nowLabel => '現在';

  @override
  String get seatGuests => '安排入座';

  @override
  String get changeTables => '更換桌子';

  @override
  String get markNoShow => '未到店';

  @override
  String get cancelReservation => '取消訂位';

  @override
  String get markCompleted => '已完成';

  @override
  String get chooseTables => '桌子';

  @override
  String seatsForParty(int seats, int party) {
    return '已為 $party 人選擇 $seats 個座位';
  }

  @override
  String get reservationNoteHint => '例如：生日、兒童椅、靠窗';

  @override
  String get noFreeTableSlot => '此時段沒有空桌：請更改時間或時長。';

  @override
  String itemsCountLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 項',
      zero: '沒有品項',
    );
    return '$_temp0';
  }

  @override
  String get alertNewCustomerOrder => '有新的顧客訂單待確認';

  @override
  String get alertOrderReady => '有訂單可以上菜';

  @override
  String get view => '查看';

  @override
  String ordersToValidateBanner(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 筆顧客訂單等待您確認',
    );
    return '$_temp0';
  }

  @override
  String get tabInProgress => '進行中';

  @override
  String get historyTab => '紀錄';

  @override
  String get newShort => '新增';

  @override
  String get brandPoint1 => '內用、外帶、外送與線上訂單';

  @override
  String get brandPoint2 => '廚房與吧台即時連動，座位圖與訂位';

  @override
  String get brandPoint3 => '收銀、庫存、採購與支出';

  @override
  String get brandPoint4 => '儀表板與專業報表';

  @override
  String get authWelcome => '歡迎';

  @override
  String get authWelcomeSub => '登入以返回您的餐廳';

  @override
  String get noAccountYet => '還沒有帳號？';

  @override
  String get alreadyAccount => '已有帳號？';

  @override
  String get authSignUpSub => '只需幾秒即可開始，無任何承諾';

  @override
  String get authForgotSub => '透過電子郵件接收驗證碼以設定新密碼';

  @override
  String get authNewPasswordSub => '至少 8 個字元';

  @override
  String get navHome => '首頁';

  @override
  String get greetingDay => '您好';

  @override
  String get greetingEvening => '晚安';

  @override
  String get moreModules => '更多';

  @override
  String freeTablesCount(int free, int total) {
    return '$total 張桌中有 $free 張空閒';
  }

  @override
  String suggestedTable(String label, int seats) {
    return '建議：$label（$seats 座）';
  }

  @override
  String get slotFreeSoon => '屆時空出';

  @override
  String get slotReserved => '此時段已預訂';

  @override
  String freeAround(String time) {
    return '約 $time 空出';
  }

  @override
  String get timelineEmptyHint => '當天沒有訂位。點選某張桌子所在列的時間即可訂位。';

  @override
  String get myAccount => '我的帳戶';

  @override
  String get brandTagline => '餐廳管理，流暢而清晰。';

  @override
  String get addPaymentMethod => '新增付款方式';

  @override
  String get allMethods => '所有付款方式';

  @override
  String get availableInBranches => '適用門市';

  @override
  String get availableWorldwide => '全球通用';

  @override
  String get blindCountHint => '請在不查看應有金額的情況下清點錢櫃：記錄清點後才會顯示差額。';

  @override
  String get cashDrawer => '錢櫃';

  @override
  String get cashMovementsTitle => '現金存入與取出';

  @override
  String get cashReportTitle => '收銀報表';

  @override
  String get cashierLabel => '收銀員';

  @override
  String get choosePaymentMethod => '請選擇付款方式。';

  @override
  String get closingValidated => '結帳已確認：Z 報表已編號。';

  @override
  String get closingsTab => '結帳';

  @override
  String get coinsLabel => '硬幣';

  @override
  String get collectTab => '收款';

  @override
  String collectWithTip(String amount, String tip) {
    return '收款 $amount + $tip';
  }

  @override
  String get collectedByDay => '每日收款';

  @override
  String get collectedByHour => '每小時收款';

  @override
  String get collectedTotal => '已收款';

  @override
  String commonInCountry(String country) {
    return '您所在國家常用（$country）';
  }

  @override
  String get countByDenomination => '逐張清點';

  @override
  String countConfirm(String amount) {
    return '確認清點金額：$amount？';
  }

  @override
  String get countDetailTitle => '清點明細';

  @override
  String get countRecorded => '清點已記錄';

  @override
  String get countedLabel => '已清點';

  @override
  String get countedTotal => '清點總額';

  @override
  String get customMethod => '自訂方式';

  @override
  String get customMethodHint => '例如：店內禮券、會員卡、連結付款';

  @override
  String get dateLabel => '日期';

  @override
  String get differenceLabel => '差額';

  @override
  String get differenceReasonHint => '例如：找零錯誤、紙鈔破損';

  @override
  String get discountsTotal => '折扣';

  @override
  String get displayOrder => '順序';

  @override
  String get enterAmount => '輸入金額';

  @override
  String get errorPaymentMethodUnavailable => '此處無法使用此付款方式。';

  @override
  String get errorReferenceRequired => '請輸入交易編號（付款憑證）。';

  @override
  String get exactAmount => '金額剛好';

  @override
  String get exportExcel => '匯出（試算表）';

  @override
  String get exportPdf => '匯出 PDF';

  @override
  String get feePercentLabel => '手續費';

  @override
  String feeShort(String percent) {
    return '手續費 $percent %';
  }

  @override
  String get feesEstimate => '手續費（估算）';

  @override
  String get findTicket => '查找收據';

  @override
  String get lastPayments => '最近付款';

  @override
  String get legalNameLabel => '公司名稱';

  @override
  String get managerMustValidate => '須由負責人確認結帳。';

  @override
  String get methodKind => '類型';

  @override
  String get mySessionTab => '我的收銀台';

  @override
  String get newRegister => '新增收銀台';

  @override
  String get noActiveRegister => '沒有啟用的收銀台：請在設定中建立。';

  @override
  String get noClosings => '尚無結帳紀錄。';

  @override
  String get noMovements => '尚無現金異動。';

  @override
  String get noPaymentMethod => '沒有啟用的付款方式：請在設定中新增。';

  @override
  String get noPaymentsYet => '尚無付款。';

  @override
  String get noRefunds => '最近 30 天沒有退款。';

  @override
  String get noTip => '不加';

  @override
  String get notesLabel => '紙鈔';

  @override
  String get nothingToCollect => '目前沒有待收款。';

  @override
  String get openRegisterHint => '清點零用金（初始零錢）：作為班次結束清點的基礎。';

  @override
  String openRegisterTitle(String register) {
    return '開啟 $register';
  }

  @override
  String get openedLabel => '開班';

  @override
  String get orderDetails => '訂單明細';

  @override
  String get orderShort => '訂單';

  @override
  String get otherAmount => '其他金額';

  @override
  String get otherCountries => '其他國家';

  @override
  String get payKindAccount => '客戶帳戶';

  @override
  String get payKindCheque => '支票';

  @override
  String get payKindInstant => '即時付款';

  @override
  String get payKindVoucher => '禮券';

  @override
  String get payKindWallet => '行動錢包';

  @override
  String get paymentComplete => '付款完成';

  @override
  String get paymentMethodLabel => '付款方式';

  @override
  String get paymentMethodsHint =>
      '收款時提供的付款方式。請依您的國家調整：名稱、是否必須填寫交易編號、手續費、適用門市。';

  @override
  String get paymentMethodsTitle => '付款方式';

  @override
  String get paymentsCountShort => '付款';

  @override
  String get periodYesterday => '昨天';

  @override
  String get printCountReport => '列印清點單';

  @override
  String get printReceipt => '列印收據';

  @override
  String get reasonChangeFloat => '補充零錢';

  @override
  String get reasonOtherIn => '其他存入';

  @override
  String get reasonOtherOut => '其他取出';

  @override
  String get reasonSafeDrop => '存入保險箱';

  @override
  String get reasonSmallPurchase => '小額採購';

  @override
  String get reasonTipsPaid => '發放給員工的小費';

  @override
  String get receiptFooterHint => '例如：感謝光臨，歡迎再來！Wi-Fi：RestoGuest';

  @override
  String get receiptFooterLabel => '收據底部訊息';

  @override
  String receiptNumberLabel(int number) {
    return '收據編號 $number';
  }

  @override
  String get receiptSettingsHint => '列印在每張顧客收據與 Z 報表上。';

  @override
  String get receiptSettingsTitle => '收據資訊';

  @override
  String get receiptShort => '收據';

  @override
  String receiptTaxId(String id) {
    return '統一編號：$id';
  }

  @override
  String get recentRefunds => '最近退款';

  @override
  String get recordCount => '記錄清點';

  @override
  String get referenceRequiredShort => '必須填寫交易編號';

  @override
  String get refundAction => '退款';

  @override
  String get refundDone => '退款已記錄。';

  @override
  String get refundReasonHint => '例如：餐點被退、輸入錯誤';

  @override
  String get refundTitle => '退款給顧客';

  @override
  String refundableAmount(String amount) {
    return '可退：$amount';
  }

  @override
  String get refundsTab => '退款';

  @override
  String get registerClosedHint => '請先開啟收銀台（清點零用金）再收款。';

  @override
  String get registerClosedTitle => '收銀台已關閉';

  @override
  String get registerLabel => '收銀台';

  @override
  String get registerNameHint => '例如：櫃台、露台、吧台';

  @override
  String get registersTitle => '收銀台';

  @override
  String get reportsTab => '報表';

  @override
  String get requireReferenceHint => '收銀員必須輸入交易編號（用於與對帳單核對）。';

  @override
  String get requireReferenceLabel => '必須填寫交易編號';

  @override
  String get salesByDay => '按日';

  @override
  String get salesByMethod => '按付款方式';

  @override
  String get salesByRegister => '按收銀台';

  @override
  String get salesByStaff => '按服務生';

  @override
  String get searchAction => '搜尋';

  @override
  String get searchMethodOrCountry => '付款方式名稱或國家代碼（例如 BR）';

  @override
  String get sendWhatsApp => '透過 WhatsApp 傳送';

  @override
  String get sessionAwaitingValidation => '已清點 — 等待確認';

  @override
  String get settingsTab => '設定';

  @override
  String get shareReceipt => '分享收據';

  @override
  String get signatureCashier => '收銀員簽名';

  @override
  String get signatureManager => '負責人簽名';

  @override
  String someBranchesOnly(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 家門市',
    );
    return '$_temp0';
  }

  @override
  String get splitAll => '全部';

  @override
  String get splitByItems => '按品項';

  @override
  String get splitByParts => '按份數';

  @override
  String get splitCustom => '自訂金額';

  @override
  String get staffLabel => '服務生';

  @override
  String get statusLabel => '狀態';

  @override
  String get taxIdHint => '您所在國家的稅務識別號';

  @override
  String get taxIdLabel => '稅務識別號';

  @override
  String get ticketOrOrderNumber => '收據編號或訂單編號';

  @override
  String get tipLabel => '小費';

  @override
  String get tipPresetsLabel => '建議百分比';

  @override
  String get tipsEnabledHint => '收款時提供，單獨計入（不計營業額），並歸屬於該訂單的服務生。';

  @override
  String get tipsEnabledLabel => '提供小費選項';

  @override
  String get tipsTitle => '小費';

  @override
  String get tipsTotal => '小費';

  @override
  String get toCollectTotal => '待收款';

  @override
  String get transactionReferenceRequired => '交易編號（必填）';

  @override
  String get transactionsTab => '交易';

  @override
  String get validateClosingConfirm => '確認此次結帳？Z 報表將被編號，且無法再修改。';

  @override
  String get validateNowHint => '請在「結帳」分頁中確認結帳，以取得編號的 Z 報表。';

  @override
  String get validatedLabel => '已確認';

  @override
  String get voidedPayments => '已作廢付款';

  @override
  String get xReading => 'X 報表';

  @override
  String get xReportTitle => 'X 報表（暫時）';

  @override
  String get zHistory => 'Z 報表紀錄';

  @override
  String zReportTitle(int number) {
    return 'Z 報表 $number 號';
  }

  @override
  String get zShort => 'Z';

  @override
  String get expectedCashLabel => '應有現金';

  @override
  String get countedAmountLabel => '已清點';

  @override
  String get refundsLabel => '退款';

  @override
  String get addressOptional => '地址（選填）';

  @override
  String get billedTo => '開立對象';

  @override
  String get cancelInvoiceHint => '例如：公司名稱錯誤、客戶錯誤';

  @override
  String get chooseOrder => '選擇訂單';

  @override
  String get companyOptional => '公司（選填）';

  @override
  String get customerTaxIdOptional => '客戶統一編號（選填）';

  @override
  String get documentsTitle => '單據';

  @override
  String get emailOptional => '電子郵件（選填）';

  @override
  String get errorCustomerNameRequired => '發票上必須填寫客戶姓名。';

  @override
  String get invoiceATicket => '為收據開立發票';

  @override
  String get invoiceCancelledMention => '發票已作廢';

  @override
  String get invoiceCancelledDone => '發票已作廢：您可以重新開立。';

  @override
  String invoiceDateLabel(String date) {
    return '日期：$date';
  }

  @override
  String get invoiceDesignation => '品名';

  @override
  String invoiceEmailHint(String email) {
    return '寄送至 $email：點選「分享」，再選擇郵件應用程式。';
  }

  @override
  String get invoiceFooterHint => '例如：付款條件、銀行資訊、您所在國家的法定資訊';

  @override
  String get invoiceFooterLabel => '發票底部資訊';

  @override
  String invoiceNumberLabel(String number) {
    return '發票號碼 $number';
  }

  @override
  String get invoicePayments => '已收款項';

  @override
  String get invoicePrefixHint => '例如：FA-2026-';

  @override
  String get invoicePrefixLabel => '發票號碼前綴';

  @override
  String get invoiceSettingsTitle => '發票';

  @override
  String get invoiceTitle => '發票';

  @override
  String get invoiceUnitPrice => '單價';

  @override
  String get invoicedTotal => '開立金額';

  @override
  String get invoicesCount => '發票';

  @override
  String get issueInvoice => '開立發票';

  @override
  String get issueInvoiceAction => '開立發票';

  @override
  String get issueInvoiceHint => '已開立的發票會編號且不可修改（如有錯誤：先作廢，再重新開立）。';

  @override
  String get noInvoices => '此期間沒有發票。可在訂單中點選「發票」開立，或在此使用「為收據開立發票」。';

  @override
  String get printInvoice => '列印 / 下載';

  @override
  String get receiptDocument => '收銀收據';

  @override
  String get searchInvoiceHint => '編號、客戶、公司';

  @override
  String get shareInvoice => '分享';

  @override
  String get totalExclTax => '未稅合計';

  @override
  String get totalInclTax => '含稅合計';

  @override
  String get receiptQrCaption => '掃描 QR 碼在線上找到我們';

  @override
  String get receiptQrLabel => '收據底部的 QR 碼';

  @override
  String get receiptQrUrlLabel => 'QR 碼連結';

  @override
  String get receiptQrUrlHint => '留空 = 餐廳頁面。例如：https://your-site.com 或您的評價頁面';

  @override
  String get receiptQrUrlInvalid => 'QR 碼連結必須以 https://（或 http://）開頭。';

  @override
  String get restaurantLogo => '餐廳標誌';

  @override
  String get chooseLogo => '選擇標誌';

  @override
  String get replaceLogo => '更換';

  @override
  String get removeLogo => '移除';

  @override
  String get logoTooBig => '此檔案超過 1 MB：請選擇較小的圖片。';

  @override
  String get receiptTendered => '實收';

  @override
  String get receiptChange => '找零';

  @override
  String get restaurantLogoHint => '印在收據頂部。建議使用透明背景的 PNG，最大 1 MB。';

  @override
  String get add => '新增';

  @override
  String get delete => '刪除';

  @override
  String get branchLabel => '門市';

  @override
  String get kindDessert => '甜點';

  @override
  String get kindMenu => '套餐';

  @override
  String get navAds => '廣告';

  @override
  String get navSettings => '設定';

  @override
  String get greetingShort => '您好';

  @override
  String get homeWelcome => '歡迎，這是您今天的營運情況';

  @override
  String get kpiSalesToday => '今日營業額';

  @override
  String get kpiOpenOrders => '進行中的訂單';

  @override
  String kpiPendingCount(int count) {
    return '$count 筆待處理';
  }

  @override
  String get kpiOccupancy => '座位使用率';

  @override
  String kpiTablesBusy(int busy, int total) {
    return '$total 張桌中 $busy 張使用中';
  }

  @override
  String get lowStockTitle => '庫存不足';

  @override
  String get saveChanges => '儲存修改';

  @override
  String get settingsProfile => '餐廳資料';

  @override
  String get settingsProfileHint => '您的餐廳資訊，顧客可見。';

  @override
  String get settingsContact => '聯絡方式與位置';

  @override
  String get settingsContactHint => '地址、電話與地圖位置。';

  @override
  String get settingsHours => '營業時間';

  @override
  String get settingsHoursHint => '營業日與時間、備餐時間、暫停營業。';

  @override
  String get settingsDelivery => '外送與訂單';

  @override
  String get settingsDeliveryHint => '線上訂單、外送、訂位與公開頁面。';

  @override
  String get settingsPayments => '付款與開立發票';

  @override
  String get settingsPaymentsHint => '付款方式、收銀台、收據、發票與小費。';

  @override
  String get settingsTeam => '團隊與角色';

  @override
  String get settingsTeamHint => '成員、角色與邀請。';

  @override
  String get settingsNotifications => '通知';

  @override
  String get settingsNotificationsHint => '應用程式會提醒您的事項。';

  @override
  String get settingsSecurity => '安全';

  @override
  String get settingsSecurityHint => '密碼與已登入的裝置。';

  @override
  String get restaurantName => '餐廳名稱';

  @override
  String get sloganLabel => '標語';

  @override
  String get sloganHint => '例如：精緻傳統料理';

  @override
  String get registrationNumber => '登記號碼';

  @override
  String get registrationNumberHint => '您所在國家的商業登記';

  @override
  String get logoUpload => '上傳標誌';

  @override
  String get logoFormats => 'PNG、JPG 或 WebP — 最大 1 MB。建議 512 × 512。';

  @override
  String get logoWhere => '標誌會顯示在應用程式、您的店鋪頁面與顧客收據上。';

  @override
  String get whatsappLabel => 'WhatsApp 電話';

  @override
  String get gpsTitle => 'GPS 座標 / 地圖';

  @override
  String get latitude => '緯度';

  @override
  String get longitude => '經度';

  @override
  String get gpsMissing => '尚未填寫位置';

  @override
  String get openInMaps => '在地圖中開啟';

  @override
  String get deliveryZoneLabel => '外送範圍';

  @override
  String get deliveryZoneHint => '例如：服務的街區或 5 公里範圍';

  @override
  String get vacationMode => '休假模式';

  @override
  String get vacationModeHint => '暫停營業：顧客會看到餐廳已關閉。';

  @override
  String get vacationMessage => '向顧客顯示的訊息';

  @override
  String get vacationMessageHint => '例如：9 月 15 日恢復營業';

  @override
  String get notifSoundNewOrder => '每筆新訂單提示音';

  @override
  String get notifSoundReady => '訂單完成時提示音';

  @override
  String get notifLate => '訂單逾時提醒';

  @override
  String get notifLowStock => '庫存不足提醒';

  @override
  String get notifReservations => '本小時訂位提醒';

  @override
  String get notifCashGap => '結帳時的現金差額';

  @override
  String get signedInAs => '目前登入帳號';

  @override
  String get securityTip => '請使用至少 8 個字元的專屬密碼。';

  @override
  String get signOutOthers => '登出我的其他裝置';

  @override
  String get signOutOthersDone => '您的其他裝置已登出。';

  @override
  String get signOutAll => '在所有裝置上登出';

  @override
  String fileTooBig(String name) {
    return '$name 檔案過大。';
  }

  @override
  String get adsCreate => '建立廣告';

  @override
  String get adsEdit => '修改廣告';

  @override
  String get adsCampaigns => '我的廣告活動';

  @override
  String get adsLibrary => '素材庫';

  @override
  String get adsStats => '統計';

  @override
  String get adsCreateTitle => '建立';

  @override
  String get adsCreateHint => '選擇廣告形式。';

  @override
  String get adsContent => '內容';

  @override
  String get adsBudgetTargeting => '預算與鎖定對象';

  @override
  String get adsPreview => '預覽';

  @override
  String get adsPreviewHint => '手機預覽';

  @override
  String get adsPreviewSimulation => '此預覽為模擬畫面。';

  @override
  String get adsFromLibrary => '從素材庫選擇';

  @override
  String get adsUpload => '新增相片或影片';

  @override
  String get adsUploadHint =>
      'JPG、PNG、WebP（5 MB）· MP4、WebM、MOV（50 MB）· 建議 15–30 秒影片';

  @override
  String get adsLibraryEmpty => '素材庫是空的。';

  @override
  String get adsDeleteFile => '要從素材庫刪除此檔案嗎？';

  @override
  String get adsEmpty => '尚無廣告活動。';

  @override
  String get adsEmptyHint => '建立您的第一則廣告：一段影片、一則 24 小時限時動態或一道主打菜色。';

  @override
  String get adsActiveCampaigns => '廣告活動';

  @override
  String adsCampaignCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 個進行中',
      zero: '無進行中',
    );
    return '$_temp0';
  }

  @override
  String get adFormat => '形式';

  @override
  String get adFormatVideo => '影片 15–30 秒';

  @override
  String get adFormatVideoHint => '吸引目光的短影片';

  @override
  String get adFormatCarousel => '相片輪播';

  @override
  String get adFormatCarouselHint => '可滑動瀏覽的多張圖片';

  @override
  String get adFormatStory => '24 小時限時動態';

  @override
  String get adFormatStoryHint => '24 小時限時形式';

  @override
  String get adFormatSponsoredMenu => '推廣菜單';

  @override
  String get adFormatSponsoredMenuHint => '突顯您的菜色';

  @override
  String get adFormatPush => '通知';

  @override
  String get adFormatPushHint => '直接通知您的顧客';

  @override
  String get adFormatClassified => '分類廣告';

  @override
  String get adFormatClassifiedHint => '簡潔有效的文字廣告';

  @override
  String get adTitle => '標題';

  @override
  String get adTitleHint => '例如：奶油可頌';

  @override
  String get adTitleRequired => '請為廣告填寫標題。';

  @override
  String get adText => '文字';

  @override
  String get adTextHint => '例如：新品！手工自製可頌，僅限今晚 8 折';

  @override
  String get adMediaHelp => '廣告的相片或影片（最多 10 個）。';

  @override
  String get adVideoHelp => '新增一段短影片（15 至 30 秒）。';

  @override
  String get adChooseItems => '主打菜色';

  @override
  String get adCta => '按鈕';

  @override
  String get adCtaHint => '例如：立即訂購';

  @override
  String get adCtaDefault => '立即訂購';

  @override
  String get adLink => '按鈕連結（選填）';

  @override
  String get adPushNote => '通知會傳送給同意接收您優惠訊息的應用程式顧客。';

  @override
  String get adDailyBudget => '每日預算';

  @override
  String get adBudgetNote => '預計預算：推廣投放費用將由平台結算。';

  @override
  String get adStart => '開始';

  @override
  String get adEnd => '結束';

  @override
  String get adStory24h => '顯示 24 小時';

  @override
  String get adTargetAreas => '依街區鎖定';

  @override
  String get adAddArea => '新增街區';

  @override
  String get adMoments => '時段';

  @override
  String get momentMorning => '早上';

  @override
  String get momentNoon => '中午';

  @override
  String get momentAfternoon => '下午';

  @override
  String get momentEvening => '晚上';

  @override
  String get momentNight => '深夜';

  @override
  String get adBranches => '門市';

  @override
  String get adSaveDraft => '儲存草稿';

  @override
  String get adPublish => '發布';

  @override
  String get adPublished => '廣告已發布。';

  @override
  String get adSponsored => '贊助';

  @override
  String get adStatusActive => '進行中';

  @override
  String get adStatusScheduled => '已排程';

  @override
  String get adStatusPaused => '已暫停';

  @override
  String get adStatusEnded => '已結束';

  @override
  String get adStatusDraft => '草稿';

  @override
  String get adRoi => '帶來的營業額';

  @override
  String adRoiDetail(String amount) {
    return '已投入預算 $amount';
  }

  @override
  String adViews(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 次瀏覽',
    );
    return '$_temp0';
  }

  @override
  String adOrders(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 筆訂單',
    );
    return '$_temp0';
  }

  @override
  String get adDetails => '查看詳情';

  @override
  String get adBoost => '加強推廣';

  @override
  String get adBoostTitle => '延長投放';

  @override
  String adBoostDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '再延長 $count 天',
    );
    return '$_temp0';
  }

  @override
  String get adBoosted => '廣告活動已延長。';

  @override
  String get adPause => '暫停';

  @override
  String get adResume => '恢復';

  @override
  String get adEndNow => '立即結束';

  @override
  String get adDeleteConfirm => '要刪除此廣告活動及其統計資料嗎？';

  @override
  String get adStatViews => '瀏覽';

  @override
  String get adStatClicks => '點擊';

  @override
  String get adStatClickRate => '點擊率';

  @override
  String get adStatOrders => '訂單';

  @override
  String get adStatRevenue => '營業額';

  @override
  String get adStatByCampaign => '各廣告活動瀏覽量';

  @override
  String get activeLabel => '上架';

  @override
  String get addPhotos => '新增相片';

  @override
  String get addProduct => '新增商品';

  @override
  String get allItems => '全部';

  @override
  String get available => '供應中';

  @override
  String get categories => '分類';

  @override
  String get copySuffix => '副本';

  @override
  String get customerSideView => '顧客視角 — 在餐廳菜單中的樣子';

  @override
  String get duplicate => '複製';

  @override
  String get everyDay => '每天';

  @override
  String get filterKind => '類型';

  @override
  String get itemDescriptionHint => '例如：花生燉苦葉佐蝦與大蕉';

  @override
  String get itemDuplicated => '已複製品項：副本在儲存前保持隱藏。';

  @override
  String get livePreview => '即時預覽';

  @override
  String get mainPhoto => '主圖';

  @override
  String get makeMainPhoto => '設為主圖';

  @override
  String get markAvailable => '恢復供應';

  @override
  String get markSoldOut => '標示為售完';

  @override
  String get menuProducts => '菜單商品';

  @override
  String get noProductsFound => '沒有符合的商品。';

  @override
  String photosHint(int count) {
    return '最多 $count 張相片 · JPG、PNG、WebP · 最大 5 MB';
  }

  @override
  String get play => '播放';

  @override
  String prepMinutesShort(int minutes) {
    return '備餐：$minutes 分鐘';
  }

  @override
  String get prepTime => '備餐時間';

  @override
  String get productInfo => '商品資訊';

  @override
  String get productPhotos => '商品相片';

  @override
  String productsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 項商品',
      zero: '沒有商品',
    );
    return '$_temp0';
  }

  @override
  String get publish => '發布';

  @override
  String get replace => '更換';

  @override
  String get saleDays => '販售日';

  @override
  String get saleDaysRequired => '請至少選擇一個販售日。';

  @override
  String get searchProduct => '搜尋商品、菜色…';

  @override
  String get sizesLabel => '規格';

  @override
  String get sortBy => '排序';

  @override
  String get sortMenuOrder => '菜單順序';

  @override
  String get sortName => '名稱';

  @override
  String get sortPriceAsc => '價格由低到高';

  @override
  String get sortPriceDesc => '價格由高到低';

  @override
  String get stockAlertThreshold => '低於此數提醒';

  @override
  String get stockAndTime => '庫存與時間';

  @override
  String stockLeft(int count) {
    return '庫存：剩 $count';
  }

  @override
  String stockLow(int count) {
    return '庫存不足：剩 $count';
  }

  @override
  String get stockNotTracked => '留白 = 不追蹤';

  @override
  String get stockOfDay => '今日庫存';

  @override
  String get stockOfDayHint => '今天可供應的份數。每筆訂單都會減少；為零時自動售完。留白表示不追蹤。';

  @override
  String get stockQuantity => '庫存數量';

  @override
  String get supplementsLabel => '加點';

  @override
  String get videoAdded => '已新增介紹影片';

  @override
  String get videoOptional => '介紹影片（選填，約 30 秒）';

  @override
  String get allChannels => '全部通路';

  @override
  String get amountLabel => '金額';

  @override
  String averageTicketShort(String amount) {
    return '平均客單價 $amount';
  }

  @override
  String get customerLabel => '顧客';

  @override
  String get financialResult => '財務結果';

  @override
  String get inKitchenCount => '備餐中';

  @override
  String get inProgressCount => '進行中';

  @override
  String get itemsLabel => '品項：';

  @override
  String get lateCount => '已逾時';

  @override
  String get noOrdersHere => '這裡沒有訂單';

  @override
  String get noSalesYet => '此期間尚無銷售。';

  @override
  String get nothingToCollectHint => '目前沒有待處理：新的收款會顯示在這裡。';

  @override
  String get orderLabel => '訂單';

  @override
  String get paymentLabel => '付款';

  @override
  String get periodLabel => '期間';

  @override
  String get recentTransactions => '最近交易';

  @override
  String get salesOfPeriod => '期間營業額';

  @override
  String get salesSplit => '銷售組成';

  @override
  String get timeLabel => '時間';

  @override
  String get topDishes => '熱銷菜色';

  @override
  String get viewDetails => '查看詳情';

  @override
  String vsPrevious(String amount) {
    return '上一期間：$amount';
  }

  @override
  String get addAddress => '新增地址';

  @override
  String get addedToCart => '已加入購物車。';

  @override
  String get addressLabel => '地址名稱';

  @override
  String get addressLabelHint => '例如：家、公司';

  @override
  String get addToCart => '加入購物車';

  @override
  String get allCities => '所有城市';

  @override
  String get allRestaurants => '全部餐廳';

  @override
  String get birthday => '生日';

  @override
  String get cartEmpty => '購物車是空的。';

  @override
  String cartItems(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 件',
    );
    return '$_temp0';
  }

  @override
  String get changeCity => '變更';

  @override
  String get chooseCity => '選擇城市';

  @override
  String chooseOptionRequired(String name) {
    return '請選擇：$name';
  }

  @override
  String get closedNow => '休息中';

  @override
  String get customerFavorites => '收藏';

  @override
  String get customerHome => '首頁';

  @override
  String get customerOrders => '訂單';

  @override
  String get customerProfile => '我的';

  @override
  String customerReviews(int count) {
    return '顧客評價（$count）';
  }

  @override
  String get customerSearch => '搜尋';

  @override
  String get customerSpaceLink => '顧客專區 · 點餐';

  @override
  String get deliveryDetailsRequired => '請填寫外送地址與電話。';

  @override
  String get directions => '路線';

  @override
  String get discoverRestaurants => '探索餐廳';

  @override
  String get dishes => '菜色';

  @override
  String get favoritesSignIn => '登入後查看您收藏的餐廳。';

  @override
  String get fullName => '姓名';

  @override
  String get globalCatalog => '全部菜色';

  @override
  String get healthAllergies => '健康與過敏';

  @override
  String get howDoYouWant => '您希望如何用餐？';

  @override
  String loyaltyNextReward(int points, String amount) {
    return '累積 $points 點可得獎勵：$amount';
  }

  @override
  String loyaltyPoints(int count) {
    return '$count 點';
  }

  @override
  String get loyaltyProgram => '會員集點';

  @override
  String mapCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '地圖上有 $count 間門市',
    );
    return '$_temp0';
  }

  @override
  String get mapView => '地圖';

  @override
  String minimumOrderNotReached(String amount) {
    return '最低訂購金額：$amount';
  }

  @override
  String minutesRange(int min, int max) {
    return '$min–$max 分鐘';
  }

  @override
  String get myAddresses => '我的地址';

  @override
  String get myCart => '我的購物車';

  @override
  String get newRestaurant => '新店';

  @override
  String get noAddresses => '尚未儲存地址。';

  @override
  String get noCustomerOrders => '您還沒有下過訂單。';

  @override
  String get noFavorites => '尚無收藏。';

  @override
  String get noFavoritesHint => '點選餐廳的愛心即可收藏。';

  @override
  String get noLoyaltyYet => '下單後會顯示您的點數。';

  @override
  String get noRestaurantsYet => '此城市尚無上架的餐廳。';

  @override
  String get noteForKitchen => '給廚房的備註（選填）';

  @override
  String get noteForKitchenHint => '例如：不要辣、全熟';

  @override
  String get notifOrderUpdates => '訂單進度';

  @override
  String get notifPromotions => '促銷與優惠';

  @override
  String get notifReservationReminders => '訂位提醒';

  @override
  String get onlineOrdersUnavailable => '目前無法線上點餐';

  @override
  String get openFullMap => '全螢幕開啟地圖';

  @override
  String get openNow => '營業中';

  @override
  String get orderDone => '已完成';

  @override
  String orderingAtTable(String table) {
    return '$table 號桌點餐';
  }

  @override
  String get orderInProgress => '進行中';

  @override
  String get orderNoteOptional => '給餐廳的留言（選填）';

  @override
  String get orderRejected => '餐廳已拒絕';

  @override
  String get orderSentToRestaurant => '訂單已送出！餐廳確認後即可在此即時查看進度。';

  @override
  String get ordersSignIn => '登入後查看訂單進度。';

  @override
  String get orderSummary => '訂單摘要';

  @override
  String get orderWaitingConfirmation => '等待確認';

  @override
  String get payMobileWallet => '行動錢包';

  @override
  String get personalProfile => '個人資料';

  @override
  String get personalProfileHint => '您的個人資訊與偏好設定。';

  @override
  String get placeOrder => '下單';

  @override
  String get preferences => '偏好設定';

  @override
  String get preferredPayment => '偏好付款方式';

  @override
  String get preferredPaymentHint => '僅供參考：不會儲存任何卡號或帳號。';

  @override
  String get productDetails => '商品詳情';

  @override
  String get profileSignIn => '登入後管理資料、地址與點數。';

  @override
  String get rateOrder => '評價訂單';

  @override
  String get requiredLabel => '必選';

  @override
  String get restaurantOnVacation => '餐廳暫停營業。';

  @override
  String get restaurants => '餐廳';

  @override
  String get restaurantSpace => '餐廳後台';

  @override
  String get restaurantUnavailable => '此餐廳目前無法使用。';

  @override
  String get reviewComment => '您的評價（選填）';

  @override
  String reviewsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 則評價',
      zero: '尚無評價',
    );
    return '$_temp0';
  }

  @override
  String get searchRestaurantsHint => '搜尋餐廳、菜色、料理…';

  @override
  String get seeAll => '查看全部';

  @override
  String get send => '送出';

  @override
  String get signInToContinue => '登入後繼續';

  @override
  String get spiceHot => '大辣';

  @override
  String get spiceLevel => '辣度';

  @override
  String get spiceMedium => '中辣';

  @override
  String get spiceMild => '小辣';

  @override
  String get spiceNone => '不辣';

  @override
  String get sponsoredAds => '贊助推廣';

  @override
  String get stepAccepted => '餐廳已接單';

  @override
  String get stepDone => '已完成';

  @override
  String get stepPreparing => '製作中';

  @override
  String get stepReady => '已出餐';

  @override
  String get stepSent => '已送出';

  @override
  String get storyLabel => '菜色故事';

  @override
  String get thanksForReview => '感謝您的評價！';

  @override
  String get viewCart => '查看購物車';

  @override
  String get watchVideo => '影片';

  @override
  String get yourName => '您的姓名';

  @override
  String get gpsHint => '點選「在地圖中開啟」會自動儲存您目前所在的位置：請在餐廳內操作。也可以手動輸入座標。';

  @override
  String get locationSaved => '已儲存餐廳位置。';

  @override
  String get locationServiceDisabled => '此裝置的定位服務已關閉：請開啟後再試一次。';

  @override
  String get locationDenied => '定位權限遭拒：請在瀏覽器或手機設定中允許。';

  @override
  String get locationUnavailable => '目前無法取得位置：請到戶外再試或手動輸入座標。';

  @override
  String get openMapAction => '開啟地圖';

  @override
  String get customerReviewsTitle => '顧客評價';

  @override
  String get forYou => '為您推薦';

  @override
  String fromAmount(String amount) {
    return '$amount 起';
  }

  @override
  String helpfulCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '有幫助（$count）',
      zero: '有幫助',
    );
    return '$_temp0';
  }

  @override
  String get hideReview => '隱藏評價';

  @override
  String get hideReviewReason => '原因';

  @override
  String get locatedNearYou => '已依您的位置排序餐廳';

  @override
  String get locateMe => '定位我';

  @override
  String get locationRefusedChooseCity => '無法取得位置：請選擇您的城市。';

  @override
  String get nearYouHint => '允許定位即可查看離您最近的餐廳和菜色。';

  @override
  String get nearYouRestaurants => '附近';

  @override
  String get nearYouTitle => '您附近的餐廳';

  @override
  String get newOnMenus => '新品';

  @override
  String get noReviewsYet => '尚無評價';

  @override
  String get openNowTitle => '營業中';

  @override
  String get orderAgain => '再點一次';

  @override
  String get orderAgainAction => '再次訂購';

  @override
  String get ordersInProgressTitle => '您進行中的訂單';

  @override
  String get popularDishes => '熱門菜色';

  @override
  String get popularNearYou => '附近熱門';

  @override
  String get promotionsTitle => '優惠活動';

  @override
  String get publishReview => '發布評價';

  @override
  String rateDish(String name) {
    return '評價：$name';
  }

  @override
  String get rateShort => '評價';

  @override
  String get refreshLocation => '重新整理';

  @override
  String get reorderPartial => '部分菜色已停售，其餘已加入購物車。';

  @override
  String get reorderUnavailable => '這些菜色已停售。';

  @override
  String get reportReason => '這則評價有何不當？';

  @override
  String get reportReview => '檢舉';

  @override
  String reportsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 次檢舉',
    );
    return '$_temp0';
  }

  @override
  String get reportSent => '感謝，檢舉已送出。';

  @override
  String get republishReview => '重新公開';

  @override
  String get reviewCommentHint => '例如：調味到位、份量足、外送快';

  @override
  String satisfiedPercent(int percent) {
    return '$percent% 的顧客滿意';
  }

  @override
  String get sortBestRated => '評分最高';

  @override
  String get sortHelpful => '最有幫助';

  @override
  String get sortRecent => '最新';

  @override
  String get sortWorstRated => '評分最低';

  @override
  String get verifiedPurchase => '已驗證購買';

  @override
  String get verifiedReviewNote => '已驗證評價：只有收到此菜色的顧客才能評價。';

  @override
  String get asSoonAsPossible => '盡快送達';

  @override
  String get customerOrdersHere => '在本店的訂單';

  @override
  String get customerPrivacyNote => '您只能看到這位顧客與本餐廳的往來，絕不會看到其在其他餐廳的訂單。';

  @override
  String get customersCount => '位顧客';

  @override
  String multiRestaurantNote(int count) {
    return '購物車中有 $count 間餐廳：每間都會收到獨立訂單，各有編號與進度。';
  }

  @override
  String get navCustomers => '顧客';

  @override
  String get noCustomersYet => '尚無線上顧客。';

  @override
  String get noCustomersYetHint => '透過應用程式下單的顧客會自動出現在這裡。';

  @override
  String get noDeliveryHere => '這間餐廳不提供外送：以外帶下單。';

  @override
  String get ordersSent => '訂單已送出';

  @override
  String ordersSentHint(int count) {
    return '已送出 $count 筆訂單，每間餐廳一筆，請分別查看進度。';
  }

  @override
  String placeOrders(int count) {
    return '送出 $count 筆訂單';
  }

  @override
  String get regularBadge => '常客';

  @override
  String get regularCustomers => '常客（3 筆以上）';

  @override
  String restaurantsCount(int count) {
    return '$count 間餐廳';
  }

  @override
  String get scheduleOrder => '預約時間';

  @override
  String get scheduleTooSoon => '請選擇至少 15 分鐘後的時間。';

  @override
  String get searchCustomer => '姓名或電話';

  @override
  String get sortBiggestSpenders => '消費最多';

  @override
  String get sortMostOrders => '訂單最多';

  @override
  String get sortRecentVisit => '最近光臨';

  @override
  String get teamNotes => '團隊備註';

  @override
  String get teamNotesExample => '例如：喜歡露台座位、愛吃辣醬';

  @override
  String get teamNotesHint => '僅團隊可見。';

  @override
  String get trackOrder => '查看進度';

  @override
  String get customerDiscover => '探索';

  @override
  String get feedEmpty => '暫時沒有可探索的內容';

  @override
  String get feedEmptyHint => '您所在城市餐廳的影片、餐點與優惠將顯示在這裡。';

  @override
  String get feedOrder => '點餐';

  @override
  String get feedViewDish => '查看餐點';

  @override
  String get feedViewRestaurant => '查看餐廳';

  @override
  String get feedLike => '按讚';

  @override
  String get feedSave => '收藏';

  @override
  String get feedShare => '分享';

  @override
  String get feedSaved => '已收藏。';

  @override
  String get feedUnsaved => '已取消收藏。';

  @override
  String get feedLinkCopied => '連結已複製：貼上即可分享。';

  @override
  String get commentsTitle => '留言';

  @override
  String get noCommentsYet => '尚無留言。';

  @override
  String get writeComment => '寫留言…';

  @override
  String get adHideForever => '不再顯示';

  @override
  String reserveAt(String name) {
    return '預訂 $name';
  }

  @override
  String get reservationSentHint => '已送出請求：餐廳將確認您的訂位。';

  @override
  String get reservationNoteLabel => '備註（選填）';

  @override
  String get errorInvalidComment => '留言須為 1 至 500 個字元。';

  @override
  String get adStatReach => '觸及人數';

  @override
  String get adStatEngagement => '互動率';

  @override
  String get adStatLikes => '按讚';

  @override
  String get adStatSaves => '收藏';

  @override
  String get adStatShares => '分享';

  @override
  String get hideComment => '隱藏';

  @override
  String get moderationReasonExample => '例如：辱罵、離題';

  @override
  String get hiddenBadge => '已隱藏';

  @override
  String hiddenBecause(String reason) {
    return '已隱藏：$reason';
  }

  @override
  String get allFilter => '全部';

  @override
  String get publishedComments => '已發佈';

  @override
  String get hiddenComments => '已隱藏';

  @override
  String get adCommentsHint => '顧客對您廣告的留言會顯示在這裡。請隱藏辱罵或離題的留言。';

  @override
  String get happyBirthday => '生日快樂！';

  @override
  String birthdayGift(String name, int points) {
    return '$name 送您 $points 點會員點數。';
  }

  @override
  String get thanksAction => '謝謝！';

  @override
  String get notificationsTitle => '通知';

  @override
  String get noNotifications => '沒有通知';

  @override
  String get noNotificationsHint => '餐廳接單、餐點備妥或訂位確認時，會在這裡通知您。';

  @override
  String get notifOrderAcceptedTitle => '訂單已接受';

  @override
  String notifOrderAccepted(String brand, String number) {
    return '$brand 已接受您的訂單 $number 號。';
  }

  @override
  String get notifOrderReadyTitle => '餐點已備妥';

  @override
  String notifOrderReady(String brand, String number) {
    return '您在 $brand 的訂單 $number 號已備妥，可以取餐了。';
  }

  @override
  String notifOrderOnTheWay(String brand, String number) {
    return '您在 $brand 的訂單 $number 號已備妥，正在外送。';
  }

  @override
  String get notifOrderRejectedTitle => '訂單被拒';

  @override
  String notifOrderRejected(String brand, String number, String reason) {
    return '$brand 無法接受您的訂單 $number 號：$reason';
  }

  @override
  String get notifReservationConfirmedTitle => '訂位已確認';

  @override
  String notifReservationConfirmed(String brand, String date) {
    return '$brand 已確認您 $date 的訂位。';
  }

  @override
  String get notifReservationDeclinedTitle => '訂位被拒';

  @override
  String notifReservationDeclined(String brand, String date, String reason) {
    return '$brand 無法在 $date 接待您：$reason';
  }

  @override
  String notifGroupJoined(String name, String brand) {
    return '$name 加入了您在 $brand 的團體訂單。';
  }

  @override
  String notifGroupPlaced(String host, String brand, String number) {
    return '$host 已送出在 $brand 的團體訂單（$number 號）。';
  }

  @override
  String get groupOrderTitle => '團體訂單';

  @override
  String get groupOrderAction => '團體訂單';

  @override
  String get groupInviteTitle => '邀請同伴';

  @override
  String get groupInviteHint => '分享此連結：每人在自己的手機上選餐，最後由您送出一張訂單。';

  @override
  String get groupEmpty => '尚無餐點';

  @override
  String get groupEmptyHint => '加入您的餐點，並把連結分享給同伴。';

  @override
  String groupHostedBy(String name) {
    return '發起人：$name';
  }

  @override
  String groupStatusOpen(String time) {
    return '開放至 $time';
  }

  @override
  String get groupStatusPlaced => '已送至餐廳';

  @override
  String get groupStatusCancelled => '已取消';

  @override
  String get groupStatusExpired => '已過期';

  @override
  String groupParticipants(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 位同伴',
    );
    return '$_temp0';
  }

  @override
  String get groupCheckoutTitle => '為全組送出';

  @override
  String get estimatedTotal => '預估總額';

  @override
  String get groupPlaceOrder => '把訂單送至餐廳';

  @override
  String get cancelGroupOrder => '取消團體訂單';

  @override
  String get cancelGroupOrderConfirm => '取消此團體訂單？所有人選的餐點都會遺失。';

  @override
  String get groupAddMyDishes => '加入我的餐點';

  @override
  String groupPlacedInfo(String name) {
    return '$name 已把訂單送至餐廳。';
  }

  @override
  String get groupClosedInfo => '此團體訂單已關閉。';

  @override
  String get groupOrderPlaced => '團體訂單已送至餐廳。';

  @override
  String get addedToGroup => '已加入團體訂單。';

  @override
  String get addToGroup => '加入團體';

  @override
  String get saveDishAction => '收藏餐點';

  @override
  String saveDishTitle(String name) {
    return '收藏「$name」';
  }

  @override
  String get favoriteDishes => '收藏的餐點';

  @override
  String get myLists => '我的清單';

  @override
  String get myCoupons => '我的優惠券';

  @override
  String get restaurantsSection => '餐廳';

  @override
  String get unavailableNow => '暫不供應';

  @override
  String get removeAction => '移除';

  @override
  String get noFavoriteDishes => '尚無收藏的餐點';

  @override
  String get noFavoriteDishesHint => '點按餐點頁面上的愛心，就能在這裡找到它。';

  @override
  String get newList => '新增清單';

  @override
  String get noLists => '尚無清單';

  @override
  String get noListsHint => '建立如「想嘗試」或「辦公室午餐」之類的清單。';

  @override
  String deleteListConfirm(String name) {
    return '刪除清單「$name」？';
  }

  @override
  String get renameAction => '重新命名';

  @override
  String dishesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 道餐點',
      zero: '沒有餐點',
    );
    return '$_temp0';
  }

  @override
  String get emptyListHint => '清單是空的：請從餐點頁面加入。';

  @override
  String get listName => '清單名稱';

  @override
  String get listNameExample => '例如：想嘗試';

  @override
  String get noCoupons => '尚無優惠券';

  @override
  String get noCouponsHint => '在首頁收藏餐廳的優惠，就能在這裡找到。';

  @override
  String get couponsHowTo => '在訂單追蹤中輸入優惠碼即可享有折扣。';

  @override
  String validUntil(String date) {
    return '有效至 $date';
  }

  @override
  String get couponUsed => '已使用';

  @override
  String get couponExpired => '已過期';

  @override
  String get codeCopied => '優惠碼已複製。';

  @override
  String get couponSaved => '優惠券已收藏。';

  @override
  String get saveCouponAction => '收藏';

  @override
  String get errorLimitReached => '已達上限：請先移除部分項目再新增。';

  @override
  String get errorGroupClosed => '此團體訂單已關閉或已過期。';

  @override
  String get customersTab => '顧客';

  @override
  String get offersTab => '優惠';

  @override
  String get loyaltyTab => '會員點數';

  @override
  String get activeOffers => '進行中的優惠';

  @override
  String get publicCoupons => '公開優惠券';

  @override
  String get totalUses => '使用次數';

  @override
  String get newOffer => '新增優惠';

  @override
  String get editOffer => '編輯優惠';

  @override
  String get offersEmpty => '尚無優惠';

  @override
  String get offersEmptyHint => '建立折扣、優惠碼或公開優惠券，吸引並留住顧客。';

  @override
  String get offerStatusOff => '已停用';

  @override
  String get offerStatusEnded => '已結束';

  @override
  String get offerStatusScheduled => '已排程';

  @override
  String get offerStatusActive => '進行中';

  @override
  String get publicCouponLabel => '公開優惠券';

  @override
  String get publicCouponHint => '在應用程式中顯示：顧客可將其收藏到票夾。';

  @override
  String get publicCouponNeedsCode => '公開優惠券必須設定優惠碼。';

  @override
  String usesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '已使用 $count 次',
      zero: '從未使用',
    );
    return '$_temp0';
  }

  @override
  String get offerName => '優惠名稱';

  @override
  String get offerNameExample => '例如：歡迎禮、歡樂時光';

  @override
  String get discountPercent => '百分比';

  @override
  String get discountAmount => '金額';

  @override
  String get offerValue => '折扣';

  @override
  String get promoCodeLabel => '優惠碼（選填）';

  @override
  String get offerCodeHint => '3 至 30 個字母或數字，例如 WELCOME';

  @override
  String get minOrderLabel => '最低消費';

  @override
  String get maxUsesLabel => '最多使用次數';

  @override
  String get perCustomerLabel => '每位顧客';

  @override
  String get startsLabel => '開始';

  @override
  String get endsLabel => '結束';

  @override
  String get offerNow => '立即';

  @override
  String get noEndDate => '長期有效';

  @override
  String get allBranchesLabel => '所有分店';

  @override
  String get thisBranchOnly => '本分店';

  @override
  String get offerActive => '啟用優惠';

  @override
  String get loyaltyMembers => '會員';

  @override
  String get pointsInCirculation => '流通點數';

  @override
  String get loyaltyProgramTitle => '會員點數計畫';

  @override
  String loyaltyExample(String amount, int points) {
    return '範例：消費 $amount 可獲得 $points 點。';
  }

  @override
  String get loyaltyActive => '啟用計畫';

  @override
  String get amountPerPoint => '每 1 點所需金額';

  @override
  String get rewardPointsLabel => '兌換獎勵所需點數';

  @override
  String get rewardValueLabel => '獎勵價值';

  @override
  String get birthdayPointsLabel => '生日點數';

  @override
  String get birthdayPointsHint => '每年自動贈送給曾在您店裡下單的顧客（0 = 不贈送）。';

  @override
  String get stockDashboardTab => '總覽';

  @override
  String get stockArticlesTab => '品項';

  @override
  String get stockOrdersTab => '叫貨';

  @override
  String get stockReportsTab => '報表';

  @override
  String get stockDashboardTitle => '庫存總覽';

  @override
  String get stockValueLabel => '庫存價值';

  @override
  String get belowThresholdLabel => '低於警戒';

  @override
  String get outOfStockLabel => '缺貨';

  @override
  String get expiringSoonLabel => '即將到期';

  @override
  String get inventoryVarianceLabel => '盤點差異';

  @override
  String get consumptionLabel => '耗用';

  @override
  String get wasteLabel => '耗損';

  @override
  String get receiptsLabel => '進貨';

  @override
  String articlesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 項品項',
      zero: '沒有品項',
    );
    return '$_temp0';
  }

  @override
  String daysCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 天',
    );
    return '$_temp0';
  }

  @override
  String get consumptionByDay => '每日耗用與耗損';

  @override
  String get topConsumedTitle => '耗用最多';

  @override
  String get wasteByReason => '耗損原因';

  @override
  String get noMovementsPeriod => '此期間沒有庫存異動。';

  @override
  String get noWastePeriod => '此期間沒有耗損。';

  @override
  String get expiringLotsTitle => '需留意的批次（到期日）';

  @override
  String get noExpiringLots => '7 天內沒有批次到期。';

  @override
  String get toReorderTitle => '待叫貨';

  @override
  String get noAlerts => '沒有低於警戒的品項。';

  @override
  String get prepareOrder => '準備叫貨單';

  @override
  String get expiredShort => '已過期';

  @override
  String daysLeftShort(int count) {
    return '剩 $count 天';
  }

  @override
  String daysLeftLong(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '可用 $count 天',
      zero: '今天用完',
    );
    return '$_temp0';
  }

  @override
  String batchShort(String batch) {
    return '批次 $batch';
  }

  @override
  String get batchNumber => '批號';

  @override
  String get expiryDate => '到期日';

  @override
  String get stockEmptyHint => '先在「品項」頁建立品項，再登錄期初庫存或進貨。';

  @override
  String get searchArticle => '搜尋品項';

  @override
  String get showInactive => '顯示停用的';

  @override
  String get newArticle => '新增品項';

  @override
  String get editArticle => '編輯品項';

  @override
  String get articlesEmptyHint => '加入您的品項：蔬菜、肉類、飲料、包材、自製半成品……';

  @override
  String get storageLabel => '保存方式';

  @override
  String get storageAmbient => '常溫';

  @override
  String get storageChilled => '冷藏';

  @override
  String get storageFrozen => '冷凍';

  @override
  String get purchaseUnitLabel => '進貨單位';

  @override
  String get purchaseUnitExample => '例如：5 公斤一袋、12 個一箱';

  @override
  String get purchaseUnitQty => '規格';

  @override
  String get preferredSupplier => '常用供應商';

  @override
  String get noneLabel => '無';

  @override
  String get shelfLifeDays => '保存期限';

  @override
  String get daysShort => '天';

  @override
  String get barcodeLabel => '條碼';

  @override
  String get thresholdThisBranch => '本分店的警戒量';

  @override
  String get reorderTitle => '建議叫貨';

  @override
  String get reorderHint => '依最近 28 天的耗用，叫足維持在警戒量以上所需的數量。';

  @override
  String get nothingToReorder => '無需叫貨';

  @override
  String get nothingToReorderHint => '所選期間內，所有追蹤的品項庫存充足。';

  @override
  String get noSupplier => '無常用供應商';

  @override
  String get noSupplierHint => '在品項卡中選擇常用供應商，即可建立採購單。';

  @override
  String get orderFormPdf => '採購單 PDF';

  @override
  String get createPurchaseOrder => '建立採購單';

  @override
  String get purchaseOrderDraftCreated => '已在「採購」中建立採購單草稿。';

  @override
  String get reorderNote => '庫存建議叫貨';

  @override
  String inStockShort(String qty) {
    return '庫存：$qty';
  }

  @override
  String get entriesFilter => '入庫';

  @override
  String get exitsLabel => '出庫';

  @override
  String get transfersFilter => '調撥';

  @override
  String get adjustmentsFilter => '調整';

  @override
  String get movementsReportTitle => '庫存異動';

  @override
  String get wasteReportTitle => '耗損與破損';

  @override
  String get reportValuation => '庫存估值';

  @override
  String get reportValuationHint => '目前每項品項的數量、警戒量、平均成本與價值。';

  @override
  String get reportMovementsHint => '期間內所有庫存異動，並依類型加總。';

  @override
  String get reportWasteHint => '期間內的耗損及其原因與價值。';

  @override
  String get reportInventory => '盤點差異表';

  @override
  String get reportInventoryHint => '帳面、實盤、差異金額及簽名欄。';

  @override
  String get reportFoodCost => '每道餐點的食材成本';

  @override
  String get reportFoodCostHint => '每道餐點的成本、售價、食材成本率與毛利。';

  @override
  String get reportExpiringHint => '14 天內到期的在庫批次。';

  @override
  String get generatePdf => '產生 PDF';

  @override
  String get noValidatedInventory => '尚無已確認的盤點。';

  @override
  String get chooseInventory => '選擇盤點';

  @override
  String generatedOn(String date) {
    return '產生於 $date';
  }

  @override
  String get articlesLabel => '品項';

  @override
  String get articleLabel => '品項';

  @override
  String get avgCostShort => '平均成本';

  @override
  String get valueLabel => '價值';

  @override
  String get typeLabel => '類型';

  @override
  String get inventoryGains => '盤盈';

  @override
  String get inventoryLosses => '盤虧';

  @override
  String get inventoryNet => '淨差異';

  @override
  String get theoreticalLabel => '帳面';

  @override
  String get countedBySignature => '盤點人：____________________';

  @override
  String get validatedBySignature => '審核人：____________________';

  @override
  String get targetFoodCost => '食材成本目標';

  @override
  String get targetFoodCostHint => '一道餐點的食材成本占售價的最高比例（通常為 25% 至 35%）。';

  @override
  String targetFoodCostValue(String percent) {
    return '食材成本目標：$percent%';
  }

  @override
  String get dishesWithRecipe => '已有配方的餐點';

  @override
  String get aboveTarget => '高於目標';

  @override
  String get aboveTargetShort => '成本過高';

  @override
  String get withoutRecipe => '無配方';

  @override
  String get recipeDefined => '已設配方';

  @override
  String get dishLabel => '餐點';

  @override
  String get costPriceShort => '成本';

  @override
  String get sellingPriceShort => '售價';

  @override
  String get foodCostShort => '食材成本';

  @override
  String get marginShort => '毛利';

  @override
  String get orderFormTitle => '採購單';

  @override
  String supplierLabelValue(String name) {
    return '供應商：$name';
  }

  @override
  String get packagingLabel => '包裝';

  @override
  String get unitPriceShort => '單價';

  @override
  String get orderFormFooter => '請確認供貨情況與交貨時間。';

  @override
  String get accountTypeQuestion => '您是：';

  @override
  String get accountTypeCustomer => '顧客';

  @override
  String get accountTypeCustomerHint => '探索餐廳、點餐、訂位';

  @override
  String get accountTypeBusiness => '商家';

  @override
  String get accountTypeBusinessHint => '管理我的餐廳與團隊';

  @override
  String get accountTypeRequired => '請選擇顧客或商家。';

  @override
  String get accountTypeTitle => '歡迎使用 Resto';

  @override
  String get accountTypeSub => '您將如何使用本應用程式？';

  @override
  String get continueAction => '繼續';

  @override
  String adVideoTooBig(String name) {
    return '$name 超過 50 MB：請選擇較短的影片（約 30 秒）。';
  }

  @override
  String adMediaAdded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '已新增 $count 個檔案。',
    );
    return '$_temp0';
  }

  @override
  String get adNeedVideo => '發布此形式前請先加入影片。';

  @override
  String get adNeedMedia => '發布前請至少加入一張照片或一段影片。';

  @override
  String get adNeedItems => '請至少選擇一道主打餐點。';

  @override
  String get uploadingLabel => '上傳中…';

  @override
  String get errorInvalidMedia => '檔案遭拒：必須來自您的素材庫。';

  @override
  String get errorFileTooLarge => '檔案過大。';

  @override
  String get errorFileType => '不支援的檔案格式（JPG、PNG、WebP、MP4、WebM、MOV）。';

  @override
  String get adAddVideo => '加入影片';

  @override
  String get errorOutOfStock => '這道餐點今日已售完。';

  @override
  String get errorInvalidRating => '評分必須介於 1 到 5 之間。';

  @override
  String get errorInvalidAllergen => '未知的過敏原。';

  @override
  String get bestSeller => '熱銷';

  @override
  String get callAction => '撥打';

  @override
  String get writeAction => '傳訊息';

  @override
  String get categoriesLabel => '分類';

  @override
  String get filtersLabel => '篩選';

  @override
  String get reviewsTab => '評價';

  @override
  String get infosTab => '資訊';

  @override
  String get noDishMatches => '沒有符合這些篩選條件的餐點。';

  @override
  String soldCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '已售 $count 份',
    );
    return '$_temp0';
  }

  @override
  String get yourCart => '您的購物車';

  @override
  String get coverPhoto => '封面照片';

  @override
  String get coverPhotoHint => '顯示在餐廳頁面頂端的大圖（用餐區、露台、門面）。';

  @override
  String get changePhoto => '更換照片';

  @override
  String get itemTagsLabel => '標籤（菜單篩選）';

  @override
  String get itemTagsHint => '建立您自己的標籤：顧客可用它們篩選菜單。例如：小辣、清真、無酒精、自製。';

  @override
  String get addTagHint => '新標籤 + Enter';

  @override
  String get errorInvalidTag => '標籤最多 30 個字元。';

  @override
  String itemFavorites(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 位顧客已收藏',
    );
    return '$_temp0';
  }

  @override
  String get itemSold30 => '最近 30 天銷量';

  @override
  String get receiptOrderNo => '訂單號';

  @override
  String get receiptTicketNo => '收據號';

  @override
  String get receiptChannel => '管道';

  @override
  String get receiptQtyShort => '數量';

  @override
  String get receiptTotalInclTax => '含稅總計';

  @override
  String get receiptTotalExclTax => '未稅總計';

  @override
  String get receiptApproved => '交易已核准';

  @override
  String receiptRef(String ref) {
    return '參考號：$ref';
  }

  @override
  String receiptSeeYou(String name) {
    return '期待再次光臨$name';
  }

  @override
  String get receiptRecycle => '為了更綠色的地球，請回收此收據。';

  @override
  String get receiptLoyaltyTitle => '您的忠誠會有回報！';

  @override
  String get receiptLoyaltyCaption => '掃描此 QR 碼進入您的會員空間，享受專屬優惠。';

  @override
  String get receiptPaperLabel => '本裝置的收據印表機';

  @override
  String get receiptPaper80 => '80 公釐紙捲';

  @override
  String get receiptPaper58 => '58 公釐紙捲';

  @override
  String get receiptPhotosLabel => '收據上顯示餐點照片';

  @override
  String get receiptTestPrint => '列印測試收據';

  @override
  String get receiptTestTitle => '測試收據';

  @override
  String get receiptHeaderSection => '收據頁首';

  @override
  String get receiptFooterSection => '收據頁尾';

  @override
  String get receiptTitleLabel => '顯示名稱';

  @override
  String get receiptTitleHint => '預設：品牌名稱';

  @override
  String get receiptSubtitleLabel => '副標題';

  @override
  String get receiptSubtitleHint => '例如：餐廳與美味';

  @override
  String get receiptSloganLabel => '標語';

  @override
  String get receiptSloganHint => '例如：道地料理，世界風味';

  @override
  String get websiteLabel => '網站';

  @override
  String get websiteHint => '例如：www.myrestaurant.com';

  @override
  String get receiptQrTitleLabel => 'QR 碼旁的標題';

  @override
  String get receiptQrCaptionLabel => 'QR 碼旁的文字';

  @override
  String get receiptFarewellLabel => '告別語';

  @override
  String get receiptFarewellHint => '例如：期待再次光臨！';

  @override
  String itemLikesTip(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 個讚',
      zero: '暫無按讚',
    );
    return '$_temp0';
  }

  @override
  String get itemReviewAction => '評價';

  @override
  String get itemHeartAction => '喜愛';

  @override
  String get itemCommentsTitle => '顧客評價';

  @override
  String get itemVerifiedReviews => '下單後的評分評價';

  @override
  String get notifStaffNewOrderTitle => '新訂單';

  @override
  String notifStaffNewOrder(String number, String customer, String branch) {
    return '訂單 #$number $customer — $branch';
  }

  @override
  String get notifStaffOrderReadyTitle => '訂單可上菜';

  @override
  String notifStaffOrderReady(String number, String branch) {
    return '訂單 #$number — $branch';
  }

  @override
  String get notifStaffReservationTitle => '新預訂';

  @override
  String notifStaffReservation(String name, int count, String date) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 人',
    );
    return '$name · $_temp0 · $date';
  }

  @override
  String get notifStaffReviewTitle => '新評價';

  @override
  String notifStaffReview(String author, String item) {
    return '$author 評價了「$item」';
  }

  @override
  String get pushNewOrder => '手機通知：顧客新訂單';

  @override
  String get pushOrderReady => '手機通知：訂單可上菜';

  @override
  String get pushReservations => '手機通知：新預訂';

  @override
  String get pushReviews => '手機通知：餐點新評價';

  @override
  String get tablesTab => '餐桌';

  @override
  String get tablesNow => '現在';

  @override
  String get tablesLater => '選擇時間';

  @override
  String get tableLegendOccupied => '已佔用';

  @override
  String get tableLegendReserved => '已預訂';

  @override
  String get tableLegendChosen => '您的選擇';

  @override
  String tableFreeUntil(String time) {
    return '空閒至 $time';
  }

  @override
  String tableOccupiedUntil(String time) {
    return '約 $time 空出';
  }

  @override
  String tableReservedSlot(String from, String to) {
    return '已預訂 $from–$to';
  }

  @override
  String get tablesSelectHint => '點按一張或多張空閒餐桌進行預訂。';

  @override
  String tablesSeatsChosen(int seats, int party) {
    String _temp0 = intl.Intl.pluralLogic(
      seats,
      locale: localeName,
      other: '$seats 個座位',
    );
    String _temp1 = intl.Intl.pluralLogic(
      party,
      locale: localeName,
      other: '$party 人',
    );
    return '已選 $_temp0，共 $_temp1';
  }

  @override
  String reserveTablesAction(String tables) {
    return '預訂 $tables';
  }

  @override
  String tableLabelChip(String label) {
    return '餐桌 $label';
  }

  @override
  String get tablesEmpty => '這家餐廳尚未展示其餐桌。';
}
