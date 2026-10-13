// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appName => 'Resto';

  @override
  String environmentBanner(String env) {
    return 'Ambiente: $env';
  }

  @override
  String get configMissingTitle => 'Configuração em falta';

  @override
  String get configMissingBody =>
      'O endereço do servidor e a chave pública não foram fornecidos (ficheiro env/<ambiente>.json).';

  @override
  String get languageLabel => 'Idioma';

  @override
  String get systemLanguage => 'Idioma do dispositivo';

  @override
  String pendingSyncEvents(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count operações pendentes',
      one: '1 operação pendente',
      zero: 'Tudo sincronizado',
    );
    return '$_temp0';
  }

  @override
  String get errorNotAuthenticated => 'Inicie sessão.';

  @override
  String get errorForbidden => 'Não tem permissão para realizar esta ação.';

  @override
  String get errorOwnerOnly =>
      'Apenas um proprietário pode realizar esta ação.';

  @override
  String get errorRateLimited =>
      'Demasiados pedidos. Tente novamente mais tarde.';

  @override
  String get errorInvalidTimezone => 'Fuso horário desconhecido.';

  @override
  String get errorInvalidRole => 'Função desconhecida.';

  @override
  String get errorInvalidEmail => 'Endereço de e-mail inválido.';

  @override
  String get errorInvalidBranch =>
      'Estabelecimento não encontrado nesta organização.';

  @override
  String get errorBranchesRequired => 'Escolha pelo menos um estabelecimento.';

  @override
  String get errorAlreadyMember => 'Esta pessoa já faz parte da organização.';

  @override
  String get errorInvitationInvalid =>
      'Convite inválido, expirado ou já utilizado.';

  @override
  String get errorInvitationWrongAccount =>
      'Este convite destina-se a outro endereço de e-mail.';

  @override
  String get errorLastOwner =>
      'A organização deve manter pelo menos um proprietário.';

  @override
  String get errorMembershipRevoked =>
      'Este membro foi retirado da organização.';

  @override
  String get errorNetwork =>
      'Não foi possível ligar. Verifique o acesso à Internet.';

  @override
  String get errorUnknown => 'Ocorreu um erro inesperado.';

  @override
  String get welcomeTitle => 'Bem-vindo ao Resto';

  @override
  String get signInTitle => 'Início de sessão';

  @override
  String get signIn => 'Iniciar sessão';

  @override
  String get signOut => 'Terminar sessão';

  @override
  String get createAccount => 'Criar uma conta';

  @override
  String get forgotPassword => 'Palavra-passe esquecida';

  @override
  String get email => 'E-mail';

  @override
  String get password => 'Palavra-passe';

  @override
  String get passwordConfirm => 'Confirmar a palavra-passe';

  @override
  String get passwordTooShort => 'Mínimo de 8 caracteres.';

  @override
  String get passwordsDiffer => 'As palavras-passe não coincidem.';

  @override
  String get passwordChanged => 'Palavra-passe alterada.';

  @override
  String get newPasswordTitle => 'Nova palavra-passe';

  @override
  String get changePassword => 'Alterar a palavra-passe';

  @override
  String get displayName => 'Nome';

  @override
  String get fieldRequired => 'Campo obrigatório';

  @override
  String get verifyEmailTitle => 'Confirme o seu e-mail';

  @override
  String codeSentTo(String email) {
    return 'Código enviado para $email.';
  }

  @override
  String get code => 'Código';

  @override
  String get verify => 'Validar';

  @override
  String get resendCode => 'Reenviar o código';

  @override
  String get codeResent => 'Foi enviado um novo código.';

  @override
  String get sendCode => 'Enviar o código';

  @override
  String get authInvalidCredentials => 'E-mail ou palavra-passe incorretos.';

  @override
  String get authEmailNotConfirmed => 'E-mail não confirmado.';

  @override
  String get authUserExists => 'Já existe uma conta com este endereço.';

  @override
  String get authWeakPassword => 'Palavra-passe demasiado fraca.';

  @override
  String get authCodeInvalid => 'Código inválido ou expirado.';

  @override
  String get authSamePassword =>
      'A nova palavra-passe deve ser diferente da anterior.';

  @override
  String get errorDuplicate => 'Este valor já existe.';

  @override
  String get errorInvalidHours => 'Horário inválido.';

  @override
  String get createRestaurant => 'Criar o meu restaurante';

  @override
  String get joinTeam => 'Juntar-se a uma equipa';

  @override
  String get organizationName => 'Nome da organização';

  @override
  String get brandNameOptional => 'Nome comercial (opcional)';

  @override
  String get branchNameOptional => 'Nome do estabelecimento (opcional)';

  @override
  String get country => 'País';

  @override
  String get currency => 'Moeda';

  @override
  String get timezone => 'Fuso horário';

  @override
  String get defaultLanguage => 'Idioma principal';

  @override
  String get city => 'Cidade';

  @override
  String get create => 'Criar';

  @override
  String get invitationCode => 'Código de convite';

  @override
  String get join => 'Juntar-se';

  @override
  String get navBranches => 'Estabelecimentos';

  @override
  String get navTeam => 'Equipa';

  @override
  String get navAudit => 'Registo';

  @override
  String get navAccount => 'Conta';

  @override
  String get switchOrganization => 'Mudar de organização';

  @override
  String get orgSuspended => 'Organização suspensa: apenas consulta.';

  @override
  String get newBranch => 'Novo estabelecimento';

  @override
  String get noBranches => 'Nenhum estabelecimento.';

  @override
  String get branchInfo => 'Informações';

  @override
  String get openingHours => 'Horário';

  @override
  String get floor => 'Sala';

  @override
  String get name => 'Nome';

  @override
  String get addressLine1 => 'Morada';

  @override
  String get addressLine2 => 'Complemento da morada';

  @override
  String get region => 'Região';

  @override
  String get postalCode => 'Código postal';

  @override
  String get phone => 'Telefone';

  @override
  String get offeredLanguages => 'Idiomas disponíveis';

  @override
  String get published => 'Visível para os clientes';

  @override
  String get archived => 'Arquivado';

  @override
  String get readOnly => 'Apenas consulta';

  @override
  String get save => 'Guardar';

  @override
  String get saved => 'Guardado.';

  @override
  String get cancel => 'Cancelar';

  @override
  String get confirm => 'Confirmar';

  @override
  String get close => 'Fechar';

  @override
  String get edit => 'Modificar';

  @override
  String get retry => 'Tentar novamente';

  @override
  String get closed => 'Fechado';

  @override
  String get addSlot => 'Adicionar um período';

  @override
  String get opensAt => 'Abertura';

  @override
  String get closesAt => 'Fecho';

  @override
  String get nextDay => 'dia seguinte';

  @override
  String get weekday1 => 'Segunda-feira';

  @override
  String get weekday2 => 'Terça-feira';

  @override
  String get weekday3 => 'Quarta-feira';

  @override
  String get weekday4 => 'Quinta-feira';

  @override
  String get weekday5 => 'Sexta-feira';

  @override
  String get weekday6 => 'Sábado';

  @override
  String get weekday7 => 'Domingo';

  @override
  String get newArea => 'Nova zona';

  @override
  String get areaName => 'Zona';

  @override
  String get noAreas => 'Ainda não há zonas.';

  @override
  String get newTable => 'Nova mesa';

  @override
  String get tableLabel => 'Nome da mesa';

  @override
  String get seats => 'Lugares';

  @override
  String get active => 'Ativo';

  @override
  String get inactive => 'desativado';

  @override
  String tablesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mesas',
      one: '1 mesa',
      zero: 'nenhuma mesa',
    );
    return '$_temp0';
  }

  @override
  String seatsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lugares',
      one: '1 lugar',
    );
    return '$_temp0';
  }

  @override
  String get invite => 'Convidar';

  @override
  String get role => 'Função';

  @override
  String get allBranches => 'Todos os estabelecimentos';

  @override
  String get pendingInvitations => 'Convites pendentes';

  @override
  String expiresOn(String date) {
    return 'Expira a $date';
  }

  @override
  String get revoke => 'Retirar';

  @override
  String revokeConfirm(String name) {
    return 'Retirar $name da organização?';
  }

  @override
  String get changeRole => 'Alterar a função';

  @override
  String get you => 'você';

  @override
  String get invitationCreatedTitle => 'Convite criado';

  @override
  String invitationCreatedBody(String email) {
    return 'Envie este código a $email. É válido durante 7 dias e só funciona com este endereço.';
  }

  @override
  String invitationMessage(String organization, String code) {
    return 'Foi convidado(a) a juntar-se a «$organization» no Resto. Crie a sua conta com este e-mail e depois introduza este código em «Juntar-se a uma equipa»: $code';
  }

  @override
  String get copyMessage => 'Copiar a mensagem';

  @override
  String get copied => 'Copiado.';

  @override
  String get roleOwner => 'Proprietário';

  @override
  String get roleAdmin => 'Administrador';

  @override
  String get roleManager => 'Responsável';

  @override
  String get roleAccountant => 'Contabilista';

  @override
  String get roleCashier => 'Caixa';

  @override
  String get roleStockKeeper => 'Fiel de armazém';

  @override
  String get roleWaiter => 'Empregado de mesa';

  @override
  String get roleKitchen => 'Cozinha / bar';

  @override
  String get roleViewer => 'Leitor';

  @override
  String get loadMore => 'Mostrar mais';

  @override
  String get noEntries => 'Nenhuma operação registada.';

  @override
  String get actionInsert => 'Criação';

  @override
  String get actionUpdate => 'Alteração';

  @override
  String get actionDelete => 'Eliminação';

  @override
  String get entityOrganization => 'Organização';

  @override
  String get entityMembership => 'Membro';

  @override
  String get entityInvitation => 'Convite';

  @override
  String get entityBrand => 'Marca';

  @override
  String get entityBranch => 'Estabelecimento';

  @override
  String get entityArea => 'Zona';

  @override
  String get entityTable => 'Mesa';

  @override
  String get navMenus => 'Menus';

  @override
  String get brand => 'Marca';

  @override
  String get category => 'Categoria';

  @override
  String get description => 'Descrição';

  @override
  String get newCategory => 'Nova categoria';

  @override
  String get kindFood => 'Prato';

  @override
  String get kindDrink => 'Bebida';

  @override
  String get kindOther => 'Outro';

  @override
  String selectionRule(int min, String max) {
    return 'Escolha: de $min a $max';
  }

  @override
  String get allergens => 'Alergénios';

  @override
  String get allergenGluten => 'Glúten';

  @override
  String get allergenCrustaceans => 'Crustáceos';

  @override
  String get allergenEggs => 'Ovos';

  @override
  String get allergenFish => 'Peixe';

  @override
  String get allergenPeanuts => 'Amendoins';

  @override
  String get allergenSoybeans => 'Soja';

  @override
  String get allergenMilk => 'Leite';

  @override
  String get allergenNuts => 'Frutos de casca rija';

  @override
  String get allergenCelery => 'Aipo';

  @override
  String get allergenMustard => 'Mostarda';

  @override
  String get allergenSesame => 'Sésamo';

  @override
  String get allergenSulphites => 'Sulfitos';

  @override
  String get allergenLupin => 'Tremoço';

  @override
  String get allergenMolluscs => 'Moluscos';

  @override
  String get translations => 'Traduções';

  @override
  String get soldOut => 'Esgotado';

  @override
  String get channelDefault => 'Preço base';

  @override
  String get channelDineIn => 'No local';

  @override
  String get channelTakeaway => 'Para levar';

  @override
  String get channelDelivery => 'Entrega';

  @override
  String get otherChannels => 'Preços por canal';

  @override
  String get noPrice => 'Sem preço';

  @override
  String get errorInvalidPrice => 'Preço inválido.';

  @override
  String get errorCurrencyLocked =>
      'A moeda já não pode mudar: já existem preços neste estabelecimento.';

  @override
  String get entityItem => 'Artigo';

  @override
  String get entityVariant => 'Variante';

  @override
  String get entityModifier => 'Extra';

  @override
  String get entityPrice => 'Preço';

  @override
  String get menuOfBranch => 'Menu do estabelecimento';

  @override
  String get menuEmptyTitle => 'O seu menu está vazio';

  @override
  String get menuEmptyHint =>
      'Comece por criar uma categoria (por exemplo Pratos, Bebidas, Sobremesas) e depois adicione os seus artigos com o preço.';

  @override
  String get categoryExamples => 'Ex.: Pratos, Bebidas, Sobremesas';

  @override
  String get descriptionOptional => 'Descrição (opcional)';

  @override
  String get visibleOnMenu => 'Visível na carta';

  @override
  String get hidden => 'oculto';

  @override
  String get addItem => 'Adicionar um artigo';

  @override
  String addItemIn(String category) {
    return 'Adicionar um artigo em «$category»';
  }

  @override
  String get notSoldHere => 'Não vendido neste estabelecimento';

  @override
  String get itemName => 'Nome do artigo';

  @override
  String get itemExamples => 'Ex.: Ndolé, Frango DG, Sumo de bissap';

  @override
  String get priceTitle => 'Preço';

  @override
  String priceAt(String branch) {
    return 'Preço em $branch';
  }

  @override
  String get price => 'Preço';

  @override
  String get severalSizes =>
      'Este artigo existe em vários tamanhos ou formatos';

  @override
  String get sizeName => 'Tamanho / formato';

  @override
  String get sizeExamples => 'Ex.: Pequena, 33 cl';

  @override
  String get addSize => 'Adicionar um tamanho';

  @override
  String get removeSize => 'Retirar este tamanho';

  @override
  String get sizeNameRequired =>
      'Dê um nome a cada tamanho (por exemplo Pequena, Grande).';

  @override
  String get samePriceEverywhere =>
      'Este preço aplica-se em todos os estabelecimentos escolhidos abaixo; poderá ajustá-lo depois em cada um.';

  @override
  String get salesTitle => 'Venda';

  @override
  String soldAt(String branch) {
    return 'Vendido em $branch';
  }

  @override
  String get soldOutToday => 'Esgotado de momento';

  @override
  String get optionsForItem => 'Opções oferecidas ao cliente';

  @override
  String get manageOptions => 'Gerir as opções';

  @override
  String get noOptionsYet =>
      'Ainda não há opções (acompanhamento, cozedura, molho…).';

  @override
  String get optionsTitle => 'Opções e extras';

  @override
  String get optionsIntro =>
      'Uma opção é uma escolha que o cliente faz ao pedir um artigo: acompanhamento, cozedura, um molho, um extra pago…';

  @override
  String get newOptionGroup => 'Nova opção';

  @override
  String get optionGroupName => 'Nome da opção';

  @override
  String get optionGroupExamples => 'Ex.: Acompanhamento, Cozedura, Picante';

  @override
  String get customerMust => 'O cliente:';

  @override
  String get ruleRequiredOne => 'deve fazer 1 escolha (obrigatória)';

  @override
  String get ruleOptionalOne => 'pode fazer 1 escolha (opcional)';

  @override
  String get ruleOptionalMany => 'pode fazer várias escolhas (opcional)';

  @override
  String get ruleRequiredMany =>
      'deve fazer pelo menos 1 escolha, várias possíveis';

  @override
  String get choices => 'Escolhas oferecidas';

  @override
  String choicePriceHint(String branch) {
    return 'Deixe o preço vazio ou a 0 se a escolha for gratuita. Preço para $branch.';
  }

  @override
  String get choiceName => 'Escolha';

  @override
  String get choiceExamples => 'Ex.: Miondo, Arroz';

  @override
  String get extraPrice => 'Preço adicional';

  @override
  String get addChoice => 'Adicionar uma escolha';

  @override
  String get removeChoice => 'Retirar esta escolha';

  @override
  String get choicesRequired => 'Adicione pelo menos uma escolha.';

  @override
  String get navOrders => 'Pedidos';

  @override
  String openOrdersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pedidos em curso',
      one: '1 pedido em curso',
      zero: 'Nenhum pedido em curso',
    );
    return '$_temp0';
  }

  @override
  String get refresh => 'Atualizar';

  @override
  String get newTakeaway => 'Venda para levar';

  @override
  String get takeawayOrders => 'Para levar em curso';

  @override
  String orderNumber(int number) {
    return 'Pedido n.º $number';
  }

  @override
  String minutesAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'há $count min',
      one: 'há 1 min',
      zero: 'agora mesmo',
    );
    return '$_temp0';
  }

  @override
  String get noTablesYet =>
      'Sem mesas: crie a sala em Estabelecimentos → Sala. As vendas para levar continuam possíveis.';

  @override
  String get tableFree => 'Livre';

  @override
  String get toSend => 'Artigos por enviar para a cozinha';

  @override
  String tableName(String label) {
    return 'Mesa $label';
  }

  @override
  String get menuTab => 'Carta';

  @override
  String ticketTab(int count) {
    return 'Pedido ($count)';
  }

  @override
  String get allCategories => 'Tudo';

  @override
  String get nothingToSell =>
      'Ainda nada para vender: adicione artigos com preço em Menus.';

  @override
  String fromPrice(String price) {
    return 'desde $price';
  }

  @override
  String itemSoldOut(String name) {
    return '$name está esgotado.';
  }

  @override
  String get emptyTicket => 'Toque num artigo da carta para o adicionar.';

  @override
  String get less => 'Menos um';

  @override
  String get more => 'Mais um';

  @override
  String get cancelLine => 'Anular esta linha';

  @override
  String get cancelOrder => 'Anular o pedido';

  @override
  String get cancelOrderConfirm =>
      'Anular este pedido? Ainda nada foi enviado para a cozinha.';

  @override
  String get reason => 'Motivo';

  @override
  String get subtotal => 'Subtotal';

  @override
  String taxLine(String rate) {
    return 'Imposto ($rate %)';
  }

  @override
  String get total => 'Total';

  @override
  String taxIncluded(String rate, String amount) {
    return 'imposto $rate % incluído: $amount';
  }

  @override
  String sendToKitchen(int count) {
    return 'Enviar para a cozinha ($count)';
  }

  @override
  String sentToKitchen(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count artigos enviados para a cozinha',
      one: '1 artigo enviado para a cozinha',
    );
    return '$_temp0';
  }

  @override
  String get prepPending => 'Por enviar';

  @override
  String get prepSent => 'Na cozinha';

  @override
  String get prepPreparing => 'Em preparação';

  @override
  String get prepReady => 'Pronto';

  @override
  String get prepServed => 'Servido';

  @override
  String get prepCancelled => 'Anulado';

  @override
  String get noneOption => 'Nenhum';

  @override
  String get kitchenNote => 'Nota para a cozinha (opcional)';

  @override
  String get kitchenNoteExamples => 'Ex.: sem cebola, bem passado';

  @override
  String get quantity => 'Quantidade';

  @override
  String addForPrice(String price) {
    return 'Adicionar · $price';
  }

  @override
  String get taxTitle => 'Imposto';

  @override
  String get taxRate => 'Taxa de imposto';

  @override
  String get taxRateHint => 'Ex.: 19,25 (0 se não houver imposto)';

  @override
  String get pricesIncludeTax => 'Os preços apresentados incluem o imposto';

  @override
  String get errorInvalidTaxRate => 'Taxa inválida (de 0 a 99,999).';

  @override
  String get errorOrderNotOpen => 'Este pedido já não está aberto.';

  @override
  String get errorItemUnavailable =>
      'Este artigo não está disponível neste estabelecimento.';

  @override
  String get errorNoPrice => 'Este artigo não tem preço neste estabelecimento.';

  @override
  String get errorOptionsInvalid =>
      'As opções escolhidas não respeitam as regras do artigo.';

  @override
  String get errorInvalidQuantity => 'Quantidade inválida.';

  @override
  String get errorItemAlreadySent =>
      'Esta linha já foi para a cozinha e não pode ser alterada.';

  @override
  String get errorReasonRequired => 'Indique um motivo.';

  @override
  String get errorInvalidOrder => 'Pedido inválido.';

  @override
  String get errorBranchInactive => 'Este estabelecimento está arquivado.';

  @override
  String get navCash => 'Caixa';

  @override
  String get amount => 'Montante';

  @override
  String get registerClosed => 'fechada';

  @override
  String get openRegisterShort => 'Abrir a caixa';

  @override
  String openRegister(String name) {
    return 'Abrir $name';
  }

  @override
  String get openingFloat => 'Fundo de caixa (troco inicial)';

  @override
  String registerOpenSince(String time) {
    return 'aberta desde as $time';
  }

  @override
  String expectedCash(String amount) {
    return 'Numerário esperado: $amount';
  }

  @override
  String cashBreakdown(String float, String inAmount, String outAmount) {
    return 'Fundo $float · entradas $inAmount · saídas $outAmount';
  }

  @override
  String paymentsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pagamentos',
      one: '1 pagamento',
      zero: 'nenhum pagamento',
    );
    return '$_temp0';
  }

  @override
  String get cashIn => 'Entrada de dinheiro';

  @override
  String get cashOut => 'Saída de dinheiro';

  @override
  String get movementExamples => 'Ex.: compra de gás, reforço de troco';

  @override
  String get closeRegister => 'Fechar a caixa';

  @override
  String get countedCash => 'Numerário contado na gaveta';

  @override
  String get countInfo => 'Conte as notas e moedas da gaveta, fundo incluído.';

  @override
  String get countResult => 'Resultado da contagem';

  @override
  String countedCashValue(String amount) {
    return 'Contado: $amount';
  }

  @override
  String get noDifference => 'Sem diferença';

  @override
  String differenceValue(String amount) {
    return 'Diferença: $amount';
  }

  @override
  String get awaitingValidation =>
      'Um responsável deve agora validar este fecho.';

  @override
  String get awaitingValidationTitle => 'Fechos por validar';

  @override
  String get validateClosing => 'Validar o fecho';

  @override
  String get validate => 'Validar';

  @override
  String get comment => 'Comentário';

  @override
  String get closedSessions => 'Últimos fechos';

  @override
  String get dailyReport => 'Relatório do dia';

  @override
  String get previousDay => 'Dia anterior';

  @override
  String get nextDayButton => 'Dia seguinte';

  @override
  String get salesTotal => 'Vendas';

  @override
  String get ordersClosedCount => 'Pedidos pagos';

  @override
  String get averageTicket => 'Talão médio';

  @override
  String get taxCollected => 'Imposto cobrado';

  @override
  String get paymentsReceived => 'Recebimentos por meio de pagamento';

  @override
  String ordersStillOpen(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pedidos ainda em curso',
      one: '1 pedido ainda em curso',
      zero: 'nenhum pedido em curso',
    );
    return '$_temp0';
  }

  @override
  String ordersCancelledCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count anulados',
      one: '1 anulado',
      zero: 'nenhum anulado',
    );
    return '$_temp0';
  }

  @override
  String linesCancelledCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count linhas anuladas',
      one: '1 linha anulada',
      zero: 'nenhuma linha anulada',
    );
    return '$_temp0';
  }

  @override
  String refundsTotal(String amount) {
    return 'reembolsado: $amount';
  }

  @override
  String get topItems => 'Artigos mais vendidos';

  @override
  String get payCash => 'Numerário';

  @override
  String get payCard => 'Cartão';

  @override
  String get payMobileMoney => 'Mobile Money';

  @override
  String get payTransfer => 'Transferência';

  @override
  String get payOther => 'Outro';

  @override
  String get collectPayment => 'Cobrar';

  @override
  String collectAmount(String amount) {
    return 'Cobrar $amount';
  }

  @override
  String amountDue(String amount) {
    return 'Em dívida: $amount';
  }

  @override
  String get splitBill => 'Dividir a conta';

  @override
  String splitParts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count partes',
      one: '1 parte',
    );
    return '$_temp0';
  }

  @override
  String get amountToCollect => 'Montante cobrado';

  @override
  String get cashTendered => 'Dinheiro entregue pelo cliente (opcional)';

  @override
  String changeToGive(String amount) {
    return 'Troco: $amount';
  }

  @override
  String get giveChange => 'Troco a devolver';

  @override
  String get transactionReference => 'N.º de transação (opcional)';

  @override
  String get manualPaymentNote =>
      'Cartão e Mobile Money: verifique que o pagamento foi recebido antes de validar.';

  @override
  String get openCashFirst => 'Abra primeiro a caixa (secção Caixa).';

  @override
  String get chooseRegister => 'Escolher a caixa';

  @override
  String get orderPaidClosed => 'Pedido pago e fechado.';

  @override
  String get paid => 'Já pago';

  @override
  String get remainingDue => 'Em dívida';

  @override
  String get voided => 'anulado';

  @override
  String get voidPayment => 'Anular este pagamento';

  @override
  String get orderClosed => 'Pedido pago e fechado';

  @override
  String get orderCancelled => 'Pedido anulado';

  @override
  String get errorNoOpenSession => 'Nenhuma caixa aberta para este pagamento.';

  @override
  String get errorSessionAlreadyOpen => 'Esta caixa já está aberta.';

  @override
  String get errorRegisterInactive => 'Esta caixa está desativada.';

  @override
  String get errorInvalidAmount => 'Montante inválido.';

  @override
  String get errorNotEnoughCash => 'Não há numerário suficiente na caixa.';

  @override
  String get errorOverpayment => 'O montante excede o valor em dívida.';

  @override
  String get errorTenderedTooLow =>
      'O dinheiro entregue é inferior ao montante.';

  @override
  String get errorOrderHasPayments =>
      'Este pedido já tem pagamentos: anule-os ou reembolse-os primeiro.';

  @override
  String get errorPendingLines =>
      'Alguns artigos ainda não foram enviados para a cozinha.';

  @override
  String get errorNotFullyPaid => 'O pedido não está totalmente pago.';

  @override
  String get errorSessionNotCounted => 'Esta caixa ainda não foi contada.';

  @override
  String get navKitchen => 'Cozinha';

  @override
  String get allStations => 'Todos os postos';

  @override
  String get stations => 'Postos de preparação';

  @override
  String get newStation => 'Novo posto';

  @override
  String get stationExamples => 'Ex.: Cozinha, Bar, Grelhados';

  @override
  String get stationPrepares => 'Este posto prepara:';

  @override
  String get kitchenEmpty => 'Nada para preparar de momento.';

  @override
  String get allReady => 'Tudo pronto';

  @override
  String get markServed => 'Servido';

  @override
  String get errorInvalidStatus => 'Esta mudança de estado não é possível.';

  @override
  String get navStock => 'Stocks';

  @override
  String get stockLevels => 'Estado dos stocks';

  @override
  String get ingredientsTab => 'Ingredientes';

  @override
  String get recipesTab => 'Fichas técnicas';

  @override
  String get inventoriesTab => 'Inventários';

  @override
  String get movementsTab => 'Movimentos';

  @override
  String stockValue(String amount) {
    return 'Valor do stock: $amount';
  }

  @override
  String lowStockCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ingredientes abaixo do limite',
      one: '1 ingrediente abaixo do limite',
    );
    return '$_temp0';
  }

  @override
  String actionsAt(String location) {
    return 'Movimentos em: $location';
  }

  @override
  String get newLocation => 'Novo local';

  @override
  String get locationExamples => 'Ex.: Câmara frigorífica, Cave, Cozinha';

  @override
  String get chooseLocation => 'Escolher o local';

  @override
  String get toLocation => 'Para o local';

  @override
  String get noIngredientsYet =>
      'Ainda sem ingredientes: adicione-os no separador Ingredientes.';

  @override
  String alertAt(String qty) {
    return 'alerta a $qty';
  }

  @override
  String avgCost(String amount, String unit) {
    return 'custo médio $amount / $unit';
  }

  @override
  String get alertThreshold => 'Limite de alerta';

  @override
  String get alertBelow => 'Alertar abaixo de';

  @override
  String get produce => 'Produzir';

  @override
  String get adjustmentQuantity => 'Correção (+ ou −)';

  @override
  String unitCost(String unit) {
    return 'Custo por $unit';
  }

  @override
  String get unitPiece => 'unidade';

  @override
  String get unitDozen => 'dúzia';

  @override
  String get newIngredient => 'Novo ingrediente';

  @override
  String get ingredientExamples =>
      'Ex.: Frango, Óleo de palma, Garrafa de Coca 33 cl';

  @override
  String get ingredientKind => 'Tipo';

  @override
  String get stockUnit => 'Unidade de stock';

  @override
  String get ingRaw => 'Matéria-prima';

  @override
  String get ingBeverage => 'Bebida';

  @override
  String get ingPackaging => 'Embalagem';

  @override
  String get ingSemiFinished => 'Preparação caseira';

  @override
  String get ingConsumable => 'Consumível';

  @override
  String get mvOpening => 'Stock inicial';

  @override
  String get mvReceipt => 'Entrada (compra)';

  @override
  String get mvSale => 'Venda';

  @override
  String get mvProductionIn => 'Produção';

  @override
  String get mvProductionOut => 'Usado na produção';

  @override
  String get mvWaste => 'Perda / quebra';

  @override
  String get mvStaffMeal => 'Refeição do pessoal';

  @override
  String get mvReturn => 'Devolução ao fornecedor';

  @override
  String get mvTransferIn => 'Transferência recebida';

  @override
  String get mvTransferOut => 'Transferência';

  @override
  String get mvAdjustment => 'Ajuste';

  @override
  String get mvInventory => 'Diferença de inventário';

  @override
  String get recipesIntro =>
      'Uma ficha técnica indica os ingredientes de um prato: o stock baixa automaticamente a cada venda paga e o custo é calculado.';

  @override
  String get noRecipe => 'Sem ficha';

  @override
  String costPrice(String amount) {
    return 'Custo: $amount';
  }

  @override
  String sellingPrice(String amount) {
    return 'preço $amount';
  }

  @override
  String marginPercent(int percent) {
    return 'margem $percent %';
  }

  @override
  String recipeOf(String name) {
    return 'Ficha: $name';
  }

  @override
  String get portions => 'Número de doses';

  @override
  String get yieldQuantity => 'Quantidade obtida';

  @override
  String get ingredient => 'Ingrediente';

  @override
  String get wastePercent => 'Desperdício';

  @override
  String get removeLine => 'Retirar a linha';

  @override
  String get addIngredientLine => 'Adicionar um ingrediente';

  @override
  String get preparationNotes => 'Notas de preparação (opcional)';

  @override
  String get newInventory => 'Novo inventário';

  @override
  String get inventoriesIntro =>
      'Um inventário compara o stock contado com o stock calculado; as diferenças são registadas após validação por um responsável.';

  @override
  String inventoryValidated(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'validado, $count diferenças',
      one: 'validado, 1 diferença',
      zero: 'validado, sem diferenças',
    );
    return '$_temp0';
  }

  @override
  String inventoryDraft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'em curso, $count linhas contadas',
      one: 'em curso, 1 linha contada',
      zero: 'em curso, nada contado',
    );
    return '$_temp0';
  }

  @override
  String inventoryOf(String location) {
    return 'Inventário: $location';
  }

  @override
  String get inventoryHint =>
      'Introduza o que conta realmente. As linhas vazias não são alteradas.';

  @override
  String inventoryDifference(String qty) {
    return 'diferença $qty';
  }

  @override
  String get search => 'Pesquisar';

  @override
  String get validateInventory => 'Validar o inventário';

  @override
  String get validateInventoryConfirm =>
      'Validar este inventário? As diferenças serão registadas no stock e o inventário deixará de poder ser alterado.';

  @override
  String inventoryAdjustments(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Inventário validado: $count diferenças registadas',
      one: 'Inventário validado: 1 diferença registada',
      zero: 'Inventário validado: sem diferenças',
    );
    return '$_temp0';
  }

  @override
  String get errorInvalidMovement => 'Movimento de stock inválido.';

  @override
  String get errorUnitLocked =>
      'A unidade de stock já não pode mudar: este ingrediente já tem movimentos.';

  @override
  String get errorNoRecipe => 'Esta preparação não tem ficha técnica.';

  @override
  String get errorInvalidRecipe =>
      'Ficha técnica inválida: verifique ingredientes, quantidades e unidades.';

  @override
  String get errorInventoryClosed => 'Este inventário já está validado.';

  @override
  String get navGroupService => 'Serviço';

  @override
  String get navGroupManagement => 'Gestão';

  @override
  String get navGroupOrganization => 'Organização';

  @override
  String get navPurchases => 'Compras';

  @override
  String get navExpenses => 'Despesas';

  @override
  String get navReports => 'Relatórios';

  @override
  String get invoicesTab => 'Faturas';

  @override
  String get purchaseOrdersTab => 'Notas de encomenda';

  @override
  String get receiptsTab => 'Receções';

  @override
  String get suppliersTab => 'Fornecedores';

  @override
  String get newSupplier => 'Novo fornecedor';

  @override
  String get noSuppliersYet =>
      'Ainda sem fornecedores. Adicione os seus fornecedores habituais (mercado, grossista, cervejeira…).';

  @override
  String get addSupplierFirst =>
      'Adicione primeiro um fornecedor (separador Fornecedores).';

  @override
  String get contactName => 'Pessoa de contacto';

  @override
  String get taxId => 'N.º de contribuinte';

  @override
  String get paymentTermsLabel => 'Prazo de pagamento';

  @override
  String get days => 'dias';

  @override
  String paymentTerms(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'pagamento a $days dias',
      one: 'pagamento a 1 dia',
    );
    return '$_temp0';
  }

  @override
  String get supplier => 'Fornecedor';

  @override
  String get supplierOptional => 'Fornecedor (opcional)';

  @override
  String get newPurchaseOrder => 'Nova nota de encomenda';

  @override
  String get noPurchaseOrders =>
      'Nenhuma nota de encomenda. Uma encomenda prepara uma compra; na entrega, «Rececionar» dá entrada da mercadoria em stock.';

  @override
  String poNumber(int number) {
    return 'Encomenda n.º $number';
  }

  @override
  String get poDraft => 'rascunho';

  @override
  String get poSent => 'enviada';

  @override
  String get poPartial => 'recebida em parte';

  @override
  String get poReceived => 'recebida';

  @override
  String get poCancelled => 'anulada';

  @override
  String get poMarkSent => 'Marcar como enviada';

  @override
  String get poReceive => 'Rececionar';

  @override
  String get poCancel => 'Anular a encomenda';

  @override
  String get cancelPoConfirm => 'Anular esta nota de encomenda?';

  @override
  String expectedOn(String date) {
    return 'entrega prevista a $date';
  }

  @override
  String get expectedDateOptional => 'Data de entrega prevista (opcional)';

  @override
  String unitPrice(String unit) {
    return 'Preço por $unit';
  }

  @override
  String totalAmount(String amount) {
    return 'Total: $amount';
  }

  @override
  String get newReceipt => 'Nova receção';

  @override
  String get receiptsIntro =>
      'Uma receção regista a mercadoria entregue: o stock e o custo médio são atualizados automaticamente.';

  @override
  String receiveOrder(int number) {
    return 'Receção da encomenda n.º $number';
  }

  @override
  String get receiptHint =>
      'Indique as quantidades realmente entregues e o seu preço; entram em stock ao guardar.';

  @override
  String get deliveryNoteNumber => 'N.º da guia de remessa (opcional)';

  @override
  String get recordReceipt => 'Registar a receção';

  @override
  String get receiptRecorded => 'Receção registada: o stock está atualizado.';

  @override
  String get newInvoice => 'Nova fatura';

  @override
  String get invoicesIntro =>
      'Registe aqui as faturas dos seus fornecedores para acompanhar o que lhes deve e os seus pagamentos.';

  @override
  String supplierDebt(String amount) {
    return 'Total devido aos fornecedores: $amount';
  }

  @override
  String dueOn(String date) {
    return 'vence a $date';
  }

  @override
  String remaining(String amount) {
    return 'faltam $amount';
  }

  @override
  String get invoicePaid => 'paga';

  @override
  String get invoiceCancelled => 'anulada';

  @override
  String get invoiceNumber => 'N.º da fatura do fornecedor';

  @override
  String invoiceDateValue(String date) {
    return 'Fatura de $date';
  }

  @override
  String get dueDateOptional => 'Vencimento (opcional: prazo do fornecedor)';

  @override
  String get amountExclTax => 'Montante sem imposto';

  @override
  String get taxAmount => 'Imposto';

  @override
  String get linkedReceipts => 'Receções relacionadas';

  @override
  String get attachDocument => 'Anexar um comprovativo (PDF ou foto)';

  @override
  String get fileTooLarge => 'Ficheiro demasiado grande (máximo 5 MB).';

  @override
  String get viewDocument => 'Ver o comprovativo';

  @override
  String get payInvoice => 'Pagar';

  @override
  String get cancelInvoice => 'Anular a fatura';

  @override
  String get paidFromRegister => 'Pago com o dinheiro da caixa';

  @override
  String get newExpense => 'Nova despesa';

  @override
  String get noExpenses => 'Nenhuma despesa este mês.';

  @override
  String get previousMonth => 'Mês anterior';

  @override
  String get nextMonth => 'Mês seguinte';

  @override
  String includingTax(String amount) {
    return 'imposto incluído $amount';
  }

  @override
  String get cancelledLabel => 'anulada';

  @override
  String get cancelExpense => 'Anular a despesa';

  @override
  String get expenseExamples =>
      'Ex.: fatura de eletricidade de outubro, reparação do congelador';

  @override
  String get amountInclTax => 'Montante pago';

  @override
  String get includedTaxOptional => 'Do qual imposto (opcional)';

  @override
  String get expRent => 'Renda';

  @override
  String get expElectricity => 'Eletricidade';

  @override
  String get expWater => 'Água';

  @override
  String get expGas => 'Gás';

  @override
  String get expSalaries => 'Salários';

  @override
  String get expTransport => 'Transporte';

  @override
  String get expMaintenance => 'Manutenção e reparações';

  @override
  String get expMarketing => 'Publicidade';

  @override
  String get expSupplies => 'Material';

  @override
  String get expTaxes => 'Impostos e taxas';

  @override
  String get expBankFees => 'Comissões bancárias';

  @override
  String get expOther => 'Outros';

  @override
  String get periodToday => 'Hoje';

  @override
  String get periodLast7 => 'Últimos 7 dias';

  @override
  String get periodMonth => 'Este mês';

  @override
  String get periodLastMonth => 'Mês passado';

  @override
  String get periodCustom => 'Outro período…';

  @override
  String get salesInclTax => 'Vendas com imposto';

  @override
  String get salesExclTax => 'Vendas sem imposto';

  @override
  String get collected => 'Recebimentos';

  @override
  String get costOfSales => 'Custo das vendas';

  @override
  String get grossMargin => 'Margem bruta';

  @override
  String get lossesValue => 'Perdas e diferenças';

  @override
  String get expensesExclTax => 'Despesas sem imposto';

  @override
  String get estimatedResult => 'Resultado estimado';

  @override
  String get purchasesValue => 'Compras (faturas sem imposto)';

  @override
  String get supplierDebtShort => 'Devido a fornecedores';

  @override
  String ordersCountShort(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pedidos',
      one: '1 pedido',
      zero: 'nenhum pedido',
    );
    return '$_temp0';
  }

  @override
  String get ruleSales =>
      'Total dos pedidos pagos e fechados no período (data de serviço).';

  @override
  String get ruleSalesHt => 'Vendas com imposto menos o imposto cobrado.';

  @override
  String get ruleCollected =>
      'Dinheiro realmente recebido no período, todos os meios, menos reembolsos. Pode diferir das vendas (adiantamentos, pedidos em aberto).';

  @override
  String get ruleCogs =>
      'Valor dos ingredientes consumidos pelas vendas, segundo as fichas técnicas e o custo médio de compra. Os pratos sem ficha não são incluídos.';

  @override
  String get ruleGrossMargin => 'Vendas sem imposto menos o custo das vendas.';

  @override
  String get ruleLosses =>
      'Valor de perdas, refeições do pessoal, ajustes e diferenças de inventário.';

  @override
  String get ruleExpenses =>
      'Despesas registadas no período, sem imposto (despesas anuladas excluídas).';

  @override
  String get ruleResult =>
      'Margem bruta menos perdas e despesas. Estimativa de gestão, sem amortizações nem custos não registados: não é um resultado contabilístico.';

  @override
  String get rulePurchases =>
      'Faturas de fornecedores (sem imposto) datadas no período. As compras entram em stock: só são custo quando consumidas.';

  @override
  String get ruleDebt =>
      'Valor ainda em dívida nas faturas de fornecedores abertas, à data de hoje.';

  @override
  String get expensesByCategory => 'Despesas por categoria (sem imposto)';

  @override
  String get resultDisclaimer =>
      'Estes valores são calculados a partir das operações registadas no Resto: vendas, recebimentos, consumos teóricos, despesas. Passe o rato por ⓘ para ver a regra de cada indicador.';

  @override
  String get exportsTitle => 'Exportações (ficheiros CSV, abrem no Excel)';

  @override
  String get exportOrders => 'Pedidos';

  @override
  String get exportPayments => 'Pagamentos';

  @override
  String get exportExpenses => 'Despesas';

  @override
  String get exportDownloaded => 'Ficheiro descarregado.';

  @override
  String get exportCopied => 'Dados copiados: cole-os numa folha de cálculo.';

  @override
  String get marginsByItem => 'Margem por prato';

  @override
  String marginsHint(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count pratos ainda não têm ficha técnica (Stocks → Fichas técnicas).',
      one: '1 prato ainda não tem ficha técnica (Stocks → Fichas técnicas).',
      zero: 'Todos os pratos vendidos têm ficha técnica.',
    );
    return '$_temp0';
  }

  @override
  String get errorInvalidPurchase =>
      'Compra incompleta: verifique fornecedor, ingredientes, quantidades, unidades e preços.';

  @override
  String get errorPurchaseNotDraft =>
      'Esta nota de encomenda já não pode ser alterada.';

  @override
  String get errorDuplicateInvoice =>
      'Esta fatura deste fornecedor já está registada.';

  @override
  String get errorInvoiceNotOpen => 'Esta fatura já não está aberta.';

  @override
  String get errorInvoiceHasPayments =>
      'Esta fatura tem pagamentos: anule-os primeiro.';

  @override
  String get errorInvalidExpense =>
      'Despesa incompleta: categoria, descrição e montante são obrigatórios; o imposto não pode exceder o montante.';

  @override
  String get errorInvalidAttachment => 'Comprovativo recusado.';

  @override
  String get errorInvalidPeriod => 'Período inválido.';

  @override
  String get errorBelowMinimum => 'Valor mínimo do pedido não atingido.';

  @override
  String get errorDeliveryUnavailable =>
      'Entrega impossível: verifique a morada e o telefone, ou escolha «Para levar».';

  @override
  String get errorInvalidImage =>
      'Foto recusada (formato ou localização inválidos).';

  @override
  String get errorNotFound => 'Não encontrado.';

  @override
  String get errorOnlineOrdersClosed =>
      'Este restaurante não está a aceitar pedidos online de momento.';

  @override
  String get errorTooLateToCancel =>
      'Tarde demais: o restaurante já está a tratar do pedido.';

  @override
  String get errorReviewNotAllowed =>
      'Avaliação impossível: só um pedido pago, com menos de 30 dias, pode ser avaliado uma vez.';

  @override
  String get errorReservationsClosed =>
      'Este restaurante não aceita reservas online.';

  @override
  String get errorInvalidPartySize =>
      'Número de pessoas não aceite para uma reserva online.';

  @override
  String get errorInvalidReservationTime =>
      'Hora inválida: pelo menos 15 minutos de antecedência e no máximo 90 dias.';

  @override
  String get errorInvalidReservation =>
      'Reserva incompleta: nome, telefone e número de pessoas são necessários.';

  @override
  String get errorTablesRequired => 'Escolha pelo menos uma mesa.';

  @override
  String get errorNotEnoughSeats =>
      'Lugares insuficientes nas mesas escolhidas.';

  @override
  String get errorTableUnavailable =>
      'Esta mesa já está reservada nesse horário.';

  @override
  String get errorPromotionUnavailable => 'Promoção ou código inválido.';

  @override
  String get errorPromotionLimit =>
      'Este cliente já usou esta promoção o número de vezes permitido.';

  @override
  String get errorPromotionAlreadyApplied => 'Já aplicada a este pedido.';

  @override
  String get errorNotEnoughPoints => 'Pontos de fidelidade insuficientes.';

  @override
  String get errorAddressRequired => 'Morada de entrega obrigatória.';

  @override
  String get errorTableBusy => 'Esta mesa já tem um pedido em curso.';

  @override
  String errorBetween(int min, int max) {
    return 'Entre $min e $max';
  }

  @override
  String get notPublishedHint =>
      'Este estabelecimento ainda não está visível para os clientes: ative «Publicado» no separador Informações.';

  @override
  String get onlineOrdersTitle => 'Pedidos online';

  @override
  String get acceptOnlineOrders => 'Aceitar pedidos de clientes';

  @override
  String get acceptOnlineOrdersHint =>
      'A partir da aplicação, do site ou dos códigos QR das mesas. Cada pedido chega a «Pedidos» para ser aceite.';

  @override
  String get acceptDelivery => 'Oferecer entrega';

  @override
  String get deliveryFee => 'Taxa de entrega';

  @override
  String get minimumOrder => 'Pedido mínimo';

  @override
  String get reservationsTitle => 'Reservas';

  @override
  String get acceptReservations => 'Aceitar reservas online';

  @override
  String get reservationDuration => 'Duração de uma reserva';

  @override
  String get minutesShort => 'min';

  @override
  String get maxPartySize => 'Máximo de pessoas';

  @override
  String get publicProfileTitle => 'Ficha pública do restaurante';

  @override
  String get publicDescription => 'Apresentação';

  @override
  String get publicDescriptionHint =>
      'Ex.: cozinha camaronesa generosa, peixe grelhado do dia, esplanada com sombra.';

  @override
  String get cuisinesLabel => 'Tipos de cozinha';

  @override
  String get cuisinesHint =>
      'Ex.: africana, grelhados, marisco (separados por vírgulas)';

  @override
  String get priceLevel => 'Gama de preços';

  @override
  String get publicPageTitle => 'Página do restaurante';

  @override
  String get publicPageHint =>
      'Para partilhar (redes sociais, WhatsApp) ou imprimir: os clientes veem a ementa e fazem o pedido.';

  @override
  String get copyLink => 'Copiar a ligação';

  @override
  String get sourcePhone => 'Por telefone';

  @override
  String get sourceQr => 'Código QR da mesa';

  @override
  String get sourceApp => 'Aplicação cliente';

  @override
  String get sourcePartner => 'Parceiro';

  @override
  String get sourceStaff => 'Registado na sala';

  @override
  String get stageToValidate => 'A confirmar';

  @override
  String get stageDraft => 'Ainda não enviado';

  @override
  String get stageCooking => 'Em preparação';

  @override
  String get stageReady => 'Pronto a servir';

  @override
  String get stageReadyTakeaway => 'Pronto a entregar';

  @override
  String get stageReadyDelivery => 'Pronto para o estafeta';

  @override
  String get stageToPay => 'A cobrar';

  @override
  String get stageDone => 'Concluído';

  @override
  String get stageCancelled => 'Cancelado';

  @override
  String get handToCustomer => 'Entregue ao cliente';

  @override
  String get handToCourier => 'Entregue ao estafeta';

  @override
  String guestsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pessoas',
      one: '1 pessoa',
    );
    return '$_temp0';
  }

  @override
  String forTime(String time) {
    return 'Para as $time';
  }

  @override
  String get billTitle => 'Conta';

  @override
  String get thankYou => 'Obrigado pela sua visita!';

  @override
  String kdsToPrepare(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pedidos a preparar',
      one: '1 pedido a preparar',
      zero: 'Nada a preparar',
    );
    return '$_temp0';
  }

  @override
  String kdsLate(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count atrasados',
      one: '1 atrasado',
    );
    return '$_temp0';
  }

  @override
  String kdsReadyCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count prontos',
      one: '1 pronto',
      zero: 'Nenhum pronto',
    );
    return '$_temp0';
  }

  @override
  String get kdsTickets => 'Talões';

  @override
  String get kdsSummary => 'Totais';

  @override
  String get kdsFullScreen => 'Ecrã inteiro (modo cozinha)';

  @override
  String get kdsFlowHint =>
      'Os pedidos enviados pela sala chegam aqui com um aviso sonoro. Toque num artigo para o passar a «em preparação» e depois a «pronto». «Tudo pronto» avisa logo os empregados.';

  @override
  String get kdsReadyStrip =>
      'Prontos — a sala foi avisada (coluna «Pronto a servir»), à espera de serviço';

  @override
  String get kdsStart => 'Começar';

  @override
  String kdsWaitingService(String time) {
    return 'à espera há $time';
  }

  @override
  String get kdsRecall => 'Recuperar (ainda não está pronto)';

  @override
  String get serviceAndCustomers => 'Serviço e clientes';

  @override
  String get serviceSettingsTitle => 'Serviço';

  @override
  String get targetPrepTime => 'Tempo de preparação alvo';

  @override
  String get targetPrepTimeHint =>
      'Depois disso, o pedido fica a vermelho (atrasado).';

  @override
  String get payFirstTakeaway => 'Para levar: cobrar antes da preparação';

  @override
  String get payFirstTakeawayHint =>
      'O botão «Cobrar e depois enviar» aparece nos pedidos para levar.';

  @override
  String get tableOccupied => 'Ocupada';

  @override
  String get tableReservedNow => 'Reservada agora';

  @override
  String get tableReservedSoon => 'Reservada em breve';

  @override
  String reservedAt(String time) {
    return 'Reservada às $time';
  }

  @override
  String get acceptWithDelay => 'Aceitar o pedido';

  @override
  String scheduledFor(String time) {
    return 'Pedido para as $time';
  }

  @override
  String get delayAnnounced =>
      'Daqui a quanto tempo estará pronto? O cliente é avisado.';

  @override
  String get orderAccepted => 'Pedido aceite: passa para preparação.';

  @override
  String get rejectOrder => 'Recusar o pedido';

  @override
  String get rejectReasonHint => 'Ex.: sem peixe, nenhum estafeta disponível';

  @override
  String get paymentDone => 'Pagamento registado.';

  @override
  String get partialPaymentDone => 'Pagamento parcial registado.';

  @override
  String get announcedDelay => 'Prazo anunciado ao cliente';

  @override
  String promisedFor(String time) {
    return 'Prometido para as $time';
  }

  @override
  String get heldShort => 'a seguir';

  @override
  String moreItems(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '+ $count outros artigos',
      one: '+ 1 outro artigo',
    );
    return '$_temp0';
  }

  @override
  String get paidShort => 'Pago';

  @override
  String get partlyPaid => 'Pago em parte';

  @override
  String get notPaid => 'Não pago';

  @override
  String get reject => 'Recusar';

  @override
  String get accept => 'Aceitar';

  @override
  String get sendShort => 'Enviar';

  @override
  String get fireNext => 'Lançar o seguinte';

  @override
  String get collectShort => 'Cobrar';

  @override
  String get columnInProgress => 'Em curso';

  @override
  String get columnReady => 'Prontos a servir';

  @override
  String get columnToValidateHint =>
      'Os pedidos feitos pelos clientes (aplicação, site, códigos QR das mesas) chegam aqui com um aviso sonoro. Aceite-os anunciando um prazo.';

  @override
  String get columnInProgressHint =>
      'Pedidos registados e em preparação. «Enviar» manda os artigos para a cozinha e o bar.';

  @override
  String get columnReadyHint =>
      'Quando a cozinha carrega em «Tudo pronto», o pedido chega aqui (com aviso sonoro): servir à mesa, entregar ao cliente ou ao estafeta.';

  @override
  String get columnToPayHint =>
      'Tudo servido: falta cobrar. Depois de pago, o pedido termina e a mesa fica livre.';

  @override
  String get allOrders => 'Todos';

  @override
  String get searchOrderHint => 'N.º, cliente, mesa, telefone';

  @override
  String get chooseTable => 'Escolha a mesa';

  @override
  String get tableHasOrder => 'Esta mesa já tem um pedido em curso: vai abrir.';

  @override
  String tableReservationWarning(String time, String name, int count) {
    return 'Atenção: reservada às $time · $name · $count pess.';
  }

  @override
  String get guestsLabel => 'Número de pessoas';

  @override
  String get receivedByPhone => 'Pedido recebido por telefone';

  @override
  String get customerName => 'Nome do cliente';

  @override
  String get customerNameOptional => 'Nome do cliente (opcional)';

  @override
  String get phoneOptional => 'Telefone (opcional)';

  @override
  String get deliveryAddress => 'Morada de entrega';

  @override
  String get deliveryAddressHint =>
      'Bairro, rua, referência (ex.: Bonamoussadi, perto da farmácia)';

  @override
  String get deliveryInstructions => 'Indicações para o estafeta';

  @override
  String get deliveryInstructionsHint =>
      'Ex.: prédio amarelo, 2.º andar, ligar ao chegar';

  @override
  String get deliveryTime => 'Hora de entrega';

  @override
  String get pickupTime => 'Hora de levantamento';

  @override
  String get asap => 'O mais depressa possível';

  @override
  String get atFixedTime => 'A uma hora precisa';

  @override
  String atTime(String time) {
    return 'Às $time';
  }

  @override
  String get newOrder => 'Novo pedido';

  @override
  String get orderTypeQuestion => 'Que tipo de pedido?';

  @override
  String get dineInHint => 'Cliente sentado a uma mesa';

  @override
  String get takeawayHint => 'O cliente leva o pedido';

  @override
  String get deliveryHint => 'Entregue numa morada';

  @override
  String get orderNote => 'Observação sobre o pedido (opcional)';

  @override
  String get orderNoteHint =>
      'Ex.: aniversário, cliente com pressa, alergia a amendoim';

  @override
  String get continueToMenu => 'Continuar: escolher os pratos';

  @override
  String get moveTable => 'Mudar de mesa';

  @override
  String get noFreeTable => 'Nenhuma mesa livre de momento.';

  @override
  String get print => 'Imprimir';

  @override
  String get printKitchenTicket => 'Talão de preparação (cozinha)';

  @override
  String get printBill => 'Conta (cliente)';

  @override
  String get orderHistory => 'Histórico do pedido';

  @override
  String get searchDish => 'Procurar um prato, uma bebida…';

  @override
  String get noResults => 'Nenhum resultado.';

  @override
  String get groupToSend => 'A enviar';

  @override
  String get groupHeld => 'A seguir (enviados mais tarde)';

  @override
  String get groupCooking => 'Em preparação';

  @override
  String get groupReady => 'Prontos a servir';

  @override
  String get groupServed => 'Servidos';

  @override
  String get groupCancelled => 'Cancelados';

  @override
  String collectThenSend(String amount) {
    return 'Cobrar $amount e depois enviar';
  }

  @override
  String fireNextCount(int count) {
    return 'Lançar o seguinte ($count)';
  }

  @override
  String get customerOrderToValidate => 'Pedido de um cliente a confirmar';

  @override
  String get customerOrderToValidateHint =>
      'Verifique os artigos e aceite (com um prazo) ou recuse. O cliente é avisado.';

  @override
  String get payFirstHint =>
      'Para levar: pagamento antes da preparação (definição do estabelecimento).';

  @override
  String get addedByCustomer => 'adicionado pelo cliente';

  @override
  String get sendWithOrder => 'Enviar com o resto';

  @override
  String get holdForLater => 'Marcar «a seguir» (enviado mais tarde)';

  @override
  String openedAt(String time) {
    return 'aberto às $time';
  }

  @override
  String get fromReservation => 'Clientes sentados (reserva)';

  @override
  String get editOrderDetails => 'Alterar as informações';

  @override
  String get evOpened => 'Pedido aberto';

  @override
  String evItemAdded(String item) {
    return 'Adicionado: $item';
  }

  @override
  String get evItemUpdated => 'Artigo alterado';

  @override
  String get evItemRemoved => 'Artigo retirado';

  @override
  String evSent(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Enviado para a cozinha ($count artigos)',
      one: 'Enviado para a cozinha (1 artigo)',
    );
    return '$_temp0';
  }

  @override
  String get evItemCancelled => 'Artigo cancelado';

  @override
  String get evCancelled => 'Pedido cancelado';

  @override
  String get evClosed => 'Pedido concluído';

  @override
  String evPayment(String amount) {
    return 'Pagamento de $amount';
  }

  @override
  String get evRefund => 'Reembolso';

  @override
  String get evDetailsUpdated => 'Informações alteradas';

  @override
  String get itemsTotal => 'Artigos';

  @override
  String get removeDiscount => 'Retirar o desconto';

  @override
  String get addDiscount => 'Adicionar um desconto';

  @override
  String get applyPromotion => 'Aplicar uma promoção';

  @override
  String get promoCode => 'Código promocional';

  @override
  String get promoCodeHint => 'Ex.: BEMVINDO10';

  @override
  String get manualDiscount => 'Desconto (gesto comercial)';

  @override
  String get useLoyalty => 'Usar os pontos de fidelidade';

  @override
  String get noActivePromotion =>
      'Nenhuma promoção em curso. Crie algumas em «Clientes e fidelidade».';

  @override
  String get inPercent => 'Em %';

  @override
  String get inAmount => 'Em valor';

  @override
  String get percentValue => 'Percentagem';

  @override
  String get manualDiscountHint => 'Ex.: espera demasiado longa, cliente fiel';

  @override
  String get apply => 'Aplicar';

  @override
  String get allAreas => 'Todas as zonas';

  @override
  String get planView => 'Planta';

  @override
  String get cardsView => 'Cartões';

  @override
  String get editFloor => 'Alterar a sala';

  @override
  String get done => 'Concluído';

  @override
  String get floorEmptyTitle => 'Crie a sua sala';

  @override
  String get floorEmptyHint =>
      'Adicione primeiro as suas zonas (Sala, Esplanada, VIP…) e depois as mesas com o nome que quiser (Mesa 1, VIP 1, Bar 2…). Verá depois em direto que mesas estão livres, ocupadas ou reservadas.';

  @override
  String get editFloorHint =>
      'Arraste as mesas para reproduzir a sua sala. Toque numa mesa para mudar o nome, os lugares ou a forma.';

  @override
  String get noTablesInArea =>
      'Nenhuma mesa nesta zona: «Alterar a sala» e depois «Nova mesa».';

  @override
  String get newOrderAtTable => 'Novo pedido nesta mesa';

  @override
  String get openOrder => 'Abrir o pedido';

  @override
  String get reservationsToday => 'Reservas do dia';

  @override
  String get reserveTable => 'Reservar';

  @override
  String get noReservationToday => 'Nenhuma reserva hoje para esta mesa.';

  @override
  String get tableQrCode => 'Código QR da mesa';

  @override
  String get tableQrHint =>
      'Imprima e coloque na mesa: o cliente digitaliza, vê a ementa com fotos e faz o pedido. O pedido chega a «A confirmar».';

  @override
  String get areaNameHint => 'Ex.: Sala, Esplanada, VIP, Piso superior';

  @override
  String get tableLabelHint => 'Ex.: Mesa 1, VIP 1, Bar 2';

  @override
  String get tableShape => 'Forma';

  @override
  String get shapeSquare => 'Quadrada';

  @override
  String get shapeRound => 'Redonda';

  @override
  String get shapeRect => 'Retangular';

  @override
  String get resRequested => 'Pedida';

  @override
  String get resConfirmed => 'Confirmada';

  @override
  String get resSeated => 'Sentados';

  @override
  String get resCompleted => 'Concluída';

  @override
  String get resNoShow => 'Não compareceram';

  @override
  String get resDeclined => 'Recusada';

  @override
  String get resCancelled => 'Cancelada';

  @override
  String reservationRequests(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pedidos de reserva a tratar',
      one: '1 pedido de reserva a tratar',
    );
    return '$_temp0';
  }

  @override
  String get reservationRequestsHint =>
      'Pedidos feitos pelos clientes online: confirme escolhendo as mesas ou recuse com um motivo. O cliente é avisado.';

  @override
  String get declineReservation => 'Recusar a reserva';

  @override
  String get confirmReservation => 'Confirmar';

  @override
  String reservationsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count reservas',
      one: '1 reserva',
      zero: 'Nenhuma reserva',
    );
    return '$_temp0';
  }

  @override
  String coversCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lugares',
      one: '1 lugar',
      zero: '0 lugares',
    );
    return '$_temp0';
  }

  @override
  String get noReservationsDay => 'Nenhuma reserva nesse dia.';

  @override
  String get today => 'Hoje';

  @override
  String get timelineView => 'Planeamento';

  @override
  String get listView => 'Lista';

  @override
  String get newReservation => 'Nova reserva';

  @override
  String get nowLabel => 'agora';

  @override
  String get seatGuests => 'Sentar os clientes';

  @override
  String get changeTables => 'Mudar de mesas';

  @override
  String get markNoShow => 'Não compareceram';

  @override
  String get cancelReservation => 'Cancelar a reserva';

  @override
  String get markCompleted => 'Concluída';

  @override
  String get chooseTables => 'Mesas';

  @override
  String seatsForParty(int seats, int party) {
    return '$seats lugares escolhidos para $party pessoas';
  }

  @override
  String get reservationNoteHint =>
      'Ex.: aniversário, cadeira de bebé, junto à janela';

  @override
  String get noFreeTableSlot =>
      'Nenhuma mesa livre neste horário: mude a hora ou a duração.';

  @override
  String itemsCountLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count artigos',
      one: '1 artigo',
      zero: 'nenhum artigo',
    );
    return '$_temp0';
  }

  @override
  String get alertNewCustomerOrder => 'Novo pedido de um cliente a confirmar';

  @override
  String get alertOrderReady => 'Um pedido está pronto a servir';

  @override
  String get view => 'Ver';

  @override
  String ordersToValidateBanner(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pedidos de clientes aguardam a sua confirmação',
      one: '1 pedido de cliente aguarda a sua confirmação',
    );
    return '$_temp0';
  }

  @override
  String get tabInProgress => 'Em curso';

  @override
  String get historyTab => 'Histórico';

  @override
  String get newShort => 'Novo';

  @override
  String get brandPoint1 => 'Pedidos na sala, para levar, entrega e online';

  @override
  String get brandPoint2 => 'Cozinha e bar em direto, sala e reservas';

  @override
  String get brandPoint3 => 'Caixa, stock, compras e despesas';

  @override
  String get brandPoint4 => 'Painéis e relatórios profissionais';

  @override
  String get authWelcome => 'Bem-vindo';

  @override
  String get authWelcomeSub => 'Inicie sessão para voltar ao seu restaurante';

  @override
  String get noAccountYet => 'Ainda não tem conta?';

  @override
  String get alreadyAccount => 'Já tem uma conta?';

  @override
  String get authSignUpSub => 'Alguns segundos para começar, sem compromisso';

  @override
  String get authForgotSub =>
      'Receba um código por e-mail para escolher uma nova palavra-passe';

  @override
  String get authNewPasswordSub => 'Pelo menos 8 caracteres';

  @override
  String get navHome => 'Início';

  @override
  String get greetingDay => 'Bom dia';

  @override
  String get greetingEvening => 'Boa noite';

  @override
  String get moreModules => 'Mais';

  @override
  String freeTablesCount(int free, int total) {
    return '$free mesas livres de $total';
  }

  @override
  String suggestedTable(String label, int seats) {
    return 'Sugestão: $label ($seats lugares)';
  }

  @override
  String get slotFreeSoon => 'Livre a tempo';

  @override
  String get slotReserved => 'Reservada neste horário';

  @override
  String freeAround(String time) {
    return 'livre por volta das $time';
  }

  @override
  String get timelineEmptyHint =>
      'Nenhuma reserva nesse dia. Toque numa hora na linha de uma mesa para a reservar.';

  @override
  String get myAccount => 'A minha conta';

  @override
  String get brandTagline => 'A gestão de restaurantes, fluida e cristalina.';

  @override
  String get addPaymentMethod => 'Adicionar um meio';

  @override
  String get allMethods => 'Todos os meios';

  @override
  String get availableInBranches => 'Disponível em';

  @override
  String get availableWorldwide => 'Válidos em todo o lado';

  @override
  String get blindCountHint =>
      'Conte a gaveta sem olhar para o esperado: a diferença aparece depois de registar a contagem.';

  @override
  String get cashDrawer => 'Gaveta da caixa';

  @override
  String get cashMovementsTitle => 'Entradas e saídas de numerário';

  @override
  String get cashReportTitle => 'Relatório de caixa';

  @override
  String get cashierLabel => 'Operador de caixa';

  @override
  String get choosePaymentMethod => 'Escolha o meio de pagamento.';

  @override
  String get closingValidated => 'Fecho validado: Z numerado.';

  @override
  String get closingsTab => 'Fechos';

  @override
  String get coinsLabel => 'Moedas';

  @override
  String get collectTab => 'Cobrar';

  @override
  String collectWithTip(String amount, String tip) {
    return 'Cobrar $amount + $tip';
  }

  @override
  String get collectedByDay => 'Cobrado por dia';

  @override
  String get collectedByHour => 'Cobrado por hora';

  @override
  String get collectedTotal => 'Cobrado';

  @override
  String commonInCountry(String country) {
    return 'Comuns no seu país ($country)';
  }

  @override
  String get countByDenomination => 'Nota a nota';

  @override
  String countConfirm(String amount) {
    return 'Confirmar a contagem: $amount?';
  }

  @override
  String get countDetailTitle => 'Detalhe da contagem';

  @override
  String get countRecorded => 'Contagem registada';

  @override
  String get countedLabel => 'Contada';

  @override
  String get countedTotal => 'Total contado';

  @override
  String get customMethod => 'Meio personalizado';

  @override
  String get customMethodHint =>
      'Ex.: vale da casa, cartão de fidelidade, pagamento por ligação';

  @override
  String get dateLabel => 'Data';

  @override
  String get differenceLabel => 'Diferença';

  @override
  String get differenceReasonHint => 'Ex.: troco errado, nota danificada';

  @override
  String get discountsTotal => 'Descontos';

  @override
  String get displayOrder => 'Ordem';

  @override
  String get enterAmount => 'Introduzir o valor';

  @override
  String get errorPaymentMethodUnavailable =>
      'Este meio de pagamento não está disponível aqui.';

  @override
  String get errorReferenceRequired =>
      'Introduza o n.º da transação (referência do pagamento).';

  @override
  String get exactAmount => 'Valor exato';

  @override
  String get exportExcel => 'Exportar (folha de cálculo)';

  @override
  String get exportPdf => 'Exportar em PDF';

  @override
  String get feePercentLabel => 'Comissão cobrada';

  @override
  String feeShort(String percent) {
    return 'comissão $percent %';
  }

  @override
  String get feesEstimate => 'Comissões (estimativa)';

  @override
  String get findTicket => 'Encontrar um talão';

  @override
  String get lastPayments => 'Últimos pagamentos';

  @override
  String get legalNameLabel => 'Denominação social';

  @override
  String get managerMustValidate => 'Um responsável tem de validar o fecho.';

  @override
  String get methodKind => 'Tipo';

  @override
  String get mySessionTab => 'A minha caixa';

  @override
  String get newRegister => 'Nova caixa';

  @override
  String get noActiveRegister => 'Nenhuma caixa ativa: crie uma em Definições.';

  @override
  String get noClosings => 'Ainda não há fechos.';

  @override
  String get noMovements => 'Nenhum movimento.';

  @override
  String get noPaymentMethod =>
      'Nenhum meio de pagamento ativo: adicione em Definições.';

  @override
  String get noPaymentsYet => 'Ainda não há pagamentos.';

  @override
  String get noRefunds => 'Nenhum reembolso nos últimos 30 dias.';

  @override
  String get noTip => 'Nenhuma';

  @override
  String get notesLabel => 'Notas';

  @override
  String get nothingToCollect => 'Nada a cobrar de momento.';

  @override
  String get openRegisterHint =>
      'Conte o fundo de caixa (o troco inicial): será a base da contagem de fim de turno.';

  @override
  String openRegisterTitle(String register) {
    return 'Abrir $register';
  }

  @override
  String get openedLabel => 'Abertura';

  @override
  String get orderDetails => 'Detalhe do pedido';

  @override
  String get orderShort => 'Pedido';

  @override
  String get otherAmount => 'Outro valor';

  @override
  String get otherCountries => 'Outros países';

  @override
  String get payKindAccount => 'Conta de cliente';

  @override
  String get payKindCheque => 'Cheque';

  @override
  String get payKindInstant => 'Pagamento instantâneo';

  @override
  String get payKindVoucher => 'Vale ou senha';

  @override
  String get payKindWallet => 'Carteira móvel';

  @override
  String get paymentComplete => 'Pagamento concluído';

  @override
  String get paymentMethodLabel => 'Meio de pagamento';

  @override
  String get paymentMethodsHint =>
      'Os meios propostos ao cobrar. Adapte-os ao seu país: nome, n.º de transação obrigatório, comissão, estabelecimentos.';

  @override
  String get paymentMethodsTitle => 'Meios de pagamento';

  @override
  String get paymentsCountShort => 'Pagamentos';

  @override
  String get periodYesterday => 'Ontem';

  @override
  String get printCountReport => 'Imprimir a contagem';

  @override
  String get printReceipt => 'Imprimir o talão';

  @override
  String get reasonChangeFloat => 'Reforço de troco';

  @override
  String get reasonOtherIn => 'Outra entrada';

  @override
  String get reasonOtherOut => 'Outra saída';

  @override
  String get reasonSafeDrop => 'Depósito no cofre';

  @override
  String get reasonSmallPurchase => 'Pequena compra';

  @override
  String get reasonTipsPaid => 'Gorjetas entregues à equipa';

  @override
  String get receiptFooterHint =>
      'Ex.: Obrigado e até breve! Wi-Fi: RestoConvidado';

  @override
  String get receiptFooterLabel => 'Mensagem no fim do talão';

  @override
  String receiptNumberLabel(int number) {
    return 'Talão n.º $number';
  }

  @override
  String get receiptSettingsHint =>
      'Impressos em cada talão de cliente e nos Z de caixa.';

  @override
  String get receiptSettingsTitle => 'Menções do talão';

  @override
  String get receiptShort => 'Talão';

  @override
  String receiptTaxId(String id) {
    return 'N.º fiscal: $id';
  }

  @override
  String get recentRefunds => 'Reembolsos recentes';

  @override
  String get recordCount => 'Registar a contagem';

  @override
  String get referenceRequiredShort => 'n.º de transação obrigatório';

  @override
  String get refundAction => 'Reembolsar';

  @override
  String get refundDone => 'Reembolso registado.';

  @override
  String get refundReasonHint => 'Ex.: prato recusado, erro de registo';

  @override
  String get refundTitle => 'Reembolsar o cliente';

  @override
  String refundableAmount(String amount) {
    return 'reembolsável: $amount';
  }

  @override
  String get refundsTab => 'Reembolsos';

  @override
  String get registerClosedHint => 'Abra a caixa (fundo contado) para cobrar.';

  @override
  String get registerClosedTitle => 'Caixa fechada';

  @override
  String get registerLabel => 'Caixa';

  @override
  String get registerNameHint => 'Ex.: Balcão, Esplanada, Bar';

  @override
  String get registersTitle => 'Caixas';

  @override
  String get reportsTab => 'Relatórios';

  @override
  String get requireReferenceHint =>
      'O operador tem de introduzir o n.º da transação (conciliação com o extrato).';

  @override
  String get requireReferenceLabel => 'N.º de transação obrigatório';

  @override
  String get salesByDay => 'Por dia';

  @override
  String get salesByMethod => 'Por meio de pagamento';

  @override
  String get salesByRegister => 'Por caixa';

  @override
  String get salesByStaff => 'Por empregado';

  @override
  String get searchAction => 'Procurar';

  @override
  String get searchMethodOrCountry => 'Nome do meio ou código do país (ex. BR)';

  @override
  String get sendWhatsApp => 'Enviar por WhatsApp';

  @override
  String get sessionAwaitingValidation => 'Contada — a aguardar validação';

  @override
  String get settingsTab => 'Definições';

  @override
  String get shareReceipt => 'Partilhar o talão';

  @override
  String get signatureCashier => 'Assinatura do operador';

  @override
  String get signatureManager => 'Assinatura do responsável';

  @override
  String someBranchesOnly(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count estabelecimentos',
      one: '1 estabelecimento',
    );
    return '$_temp0';
  }

  @override
  String get splitAll => 'Tudo';

  @override
  String get splitByItems => 'Por artigos';

  @override
  String get splitByParts => 'Por partes';

  @override
  String get splitCustom => 'Valor livre';

  @override
  String get staffLabel => 'Empregado';

  @override
  String get statusLabel => 'Estado';

  @override
  String get taxIdHint => 'Número de identificação fiscal do seu país';

  @override
  String get taxIdLabel => 'N.º de identificação fiscal';

  @override
  String get ticketOrOrderNumber => 'N.º de talão ou de pedido';

  @override
  String get tipLabel => 'Gorjeta';

  @override
  String get tipPresetsLabel => 'Percentagens propostas';

  @override
  String get tipsEnabledHint =>
      'Proposta ao cobrar, contada à parte da faturação e atribuída ao empregado do pedido.';

  @override
  String get tipsEnabledLabel => 'Propor gorjeta';

  @override
  String get tipsTitle => 'Gorjetas';

  @override
  String get tipsTotal => 'Gorjetas';

  @override
  String get toCollectTotal => 'A cobrar';

  @override
  String get transactionReferenceRequired => 'N.º de transação (obrigatório)';

  @override
  String get transactionsTab => 'Transações';

  @override
  String get validateClosingConfirm =>
      'Validar este fecho? O Z de caixa será numerado e não poderá ser alterado.';

  @override
  String get validateNowHint =>
      'Valide o fecho no separador Fechos para obter o Z numerado.';

  @override
  String get validatedLabel => 'Validada';

  @override
  String get voidedPayments => 'Pagamentos anulados';

  @override
  String get xReading => 'Leitura X';

  @override
  String get xReportTitle => 'Leitura X (provisória)';

  @override
  String get zHistory => 'Histórico de Z';

  @override
  String zReportTitle(int number) {
    return 'Z de caixa n.º $number';
  }

  @override
  String get zShort => 'Z';

  @override
  String get expectedCashLabel => 'Numerário esperado';

  @override
  String get countedAmountLabel => 'Contado';

  @override
  String get refundsLabel => 'Reembolsos';

  @override
  String get addressOptional => 'Morada (opcional)';

  @override
  String get billedTo => 'Faturado a';

  @override
  String get cancelInvoiceHint =>
      'Ex.: denominação social errada, cliente errado';

  @override
  String get chooseOrder => 'Escolha o pedido';

  @override
  String get companyOptional => 'Empresa (opcional)';

  @override
  String get customerTaxIdOptional => 'N.º fiscal do cliente (opcional)';

  @override
  String get documentsTitle => 'Documentos';

  @override
  String get emailOptional => 'E-mail (opcional)';

  @override
  String get errorCustomerNameRequired =>
      'O nome do cliente é obrigatório numa fatura.';

  @override
  String get invoiceATicket => 'Faturar um talão';

  @override
  String get invoiceCancelledMention => 'FATURA ANULADA';

  @override
  String get invoiceCancelledDone => 'Fatura anulada: pode emitir uma nova.';

  @override
  String invoiceDateLabel(String date) {
    return 'Data: $date';
  }

  @override
  String get invoiceDesignation => 'Designação';

  @override
  String invoiceEmailHint(String email) {
    return 'Para a enviar para $email: toque em «Partilhar» e escolha o seu e-mail.';
  }

  @override
  String get invoiceFooterHint =>
      'Ex.: condições de pagamento, dados bancários, menções legais do seu país';

  @override
  String get invoiceFooterLabel => 'Menções no fim da fatura';

  @override
  String invoiceNumberLabel(String number) {
    return 'Fatura n.º $number';
  }

  @override
  String get invoicePayments => 'Pagamentos recebidos';

  @override
  String get invoicePrefixHint => 'Ex.: FT-2026-';

  @override
  String get invoicePrefixLabel => 'Prefixo do número da fatura';

  @override
  String get invoiceSettingsTitle => 'Faturas';

  @override
  String get invoiceTitle => 'Fatura';

  @override
  String get invoiceUnitPrice => 'Preço unitário';

  @override
  String get invoicedTotal => 'Faturado';

  @override
  String get invoicesCount => 'Faturas';

  @override
  String get issueInvoice => 'Emitir uma fatura';

  @override
  String get issueInvoiceAction => 'Emitir a fatura';

  @override
  String get issueInvoiceHint =>
      'Uma fatura emitida fica numerada e já não pode ser alterada (em caso de erro: anulação e nova fatura).';

  @override
  String get noInvoices =>
      'Nenhuma fatura neste período. Uma fatura emite-se a partir de um pedido (botão «Fatura») ou aqui com «Faturar um talão».';

  @override
  String get printInvoice => 'Imprimir / transferir';

  @override
  String get receiptDocument => 'Talão de caixa';

  @override
  String get searchInvoiceHint => 'N.º, cliente, empresa';

  @override
  String get shareInvoice => 'Partilhar';

  @override
  String get totalExclTax => 'Total sem impostos';

  @override
  String get totalInclTax => 'Total com impostos';

  @override
  String get receiptQrCaption => 'Leia o código para nos encontrar online';

  @override
  String get receiptQrLabel => 'Código QR no fim do talão';

  @override
  String get receiptQrUrlLabel => 'Ligação do código QR';

  @override
  String get receiptQrUrlHint =>
      'Vazio = página do restaurante. Ex.: https://o-seu-site.com ou a sua página de avaliações';

  @override
  String get receiptQrUrlInvalid =>
      'A ligação do código QR deve começar por https:// (ou http://).';

  @override
  String get restaurantLogo => 'Logótipo do restaurante';

  @override
  String get chooseLogo => 'Escolher o logótipo';

  @override
  String get replaceLogo => 'Substituir';

  @override
  String get removeLogo => 'Remover';

  @override
  String get logoTooBig =>
      'Este ficheiro excede 1 MB: escolha uma imagem mais leve.';

  @override
  String get receiptTendered => 'Entregue';

  @override
  String get receiptChange => 'Troco';

  @override
  String get restaurantLogoHint =>
      'Impresso no topo dos talões. Recomenda-se PNG com fundo transparente, 1 MB no máximo.';

  @override
  String get add => 'Adicionar';

  @override
  String get delete => 'Eliminar';

  @override
  String get branchLabel => 'Estabelecimento';

  @override
  String get kindDessert => 'Sobremesa';

  @override
  String get kindMenu => 'Menu';

  @override
  String get navAds => 'Publicidade';

  @override
  String get navSettings => 'Definições';

  @override
  String get greetingShort => 'Olá';

  @override
  String get homeWelcome => 'Bem-vindo, eis a sua atividade de hoje';

  @override
  String get kpiSalesToday => 'Faturação de hoje';

  @override
  String get kpiOpenOrders => 'Pedidos em curso';

  @override
  String kpiPendingCount(int count) {
    return '$count em espera';
  }

  @override
  String get kpiOccupancy => 'Taxa de ocupação';

  @override
  String kpiTablesBusy(int busy, int total) {
    return '$busy de $total mesas ocupadas';
  }

  @override
  String get lowStockTitle => 'Stock baixo';

  @override
  String get saveChanges => 'Guardar as alterações';

  @override
  String get settingsProfile => 'Perfil do estabelecimento';

  @override
  String get settingsProfileHint =>
      'As informações do seu restaurante, visíveis para os seus clientes.';

  @override
  String get settingsContact => 'Contacto e localização';

  @override
  String get settingsContactHint => 'Morada, telefones e posição no mapa.';

  @override
  String get settingsHours => 'Horários';

  @override
  String get settingsHoursHint =>
      'Dias e horas de abertura, tempo de preparação, encerramento temporário.';

  @override
  String get settingsDelivery => 'Entrega e pedidos';

  @override
  String get settingsDeliveryHint =>
      'Pedidos online, entrega, reservas e página pública.';

  @override
  String get settingsPayments => 'Pagamento e faturação';

  @override
  String get settingsPaymentsHint =>
      'Meios de pagamento, caixas, talão, faturas e gorjetas.';

  @override
  String get settingsTeam => 'Equipa e funções';

  @override
  String get settingsTeamHint => 'Membros, funções e convites.';

  @override
  String get settingsNotifications => 'Notificações';

  @override
  String get settingsNotificationsHint => 'O que a aplicação lhe assinala.';

  @override
  String get settingsSecurity => 'Segurança';

  @override
  String get settingsSecurityHint => 'Palavra-passe e dispositivos ligados.';

  @override
  String get restaurantName => 'Nome do restaurante';

  @override
  String get sloganLabel => 'Slogan';

  @override
  String get sloganHint => 'Ex.: Cozinha tradicional requintada';

  @override
  String get registrationNumber => 'N.º de registo';

  @override
  String get registrationNumberHint => 'Registo comercial do seu país';

  @override
  String get logoUpload => 'Carregar o logótipo';

  @override
  String get logoFormats =>
      'PNG, JPG ou WebP — 1 MB no máximo. Ideal: 512 × 512.';

  @override
  String get logoWhere =>
      'O logótipo aparece na aplicação, na sua montra e nos talões dos seus clientes.';

  @override
  String get whatsappLabel => 'Telefone WhatsApp';

  @override
  String get gpsTitle => 'Coordenadas GPS / mapa';

  @override
  String get latitude => 'Latitude';

  @override
  String get longitude => 'Longitude';

  @override
  String get gpsMissing => 'Localização não indicada';

  @override
  String get openInMaps => 'Abrir no Maps';

  @override
  String get deliveryZoneLabel => 'Zona de entrega';

  @override
  String get deliveryZoneHint => 'Ex.: bairros servidos ou raio de 5 km';

  @override
  String get vacationMode => 'Modo férias';

  @override
  String get vacationModeHint =>
      'Fechar temporariamente o restaurante: aparece como fechado para os seus clientes.';

  @override
  String get vacationMessage => 'Mensagem para os clientes';

  @override
  String get vacationMessageHint => 'Ex.: Reabertura a 15 de setembro';

  @override
  String get notifSoundNewOrder => 'Som a cada novo pedido';

  @override
  String get notifSoundReady => 'Som quando um pedido está pronto';

  @override
  String get notifLate => 'Alerta de pedidos atrasados';

  @override
  String get notifLowStock => 'Alerta de stock baixo';

  @override
  String get notifReservations => 'Lembrete das reservas da hora';

  @override
  String get notifCashGap => 'Diferença de caixa no fecho';

  @override
  String get signedInAs => 'Ligado como';

  @override
  String get securityTip =>
      'Use uma palavra-passe única com pelo menos 8 caracteres.';

  @override
  String get signOutOthers => 'Terminar sessão nos meus outros dispositivos';

  @override
  String get signOutOthersDone =>
      'Os seus outros dispositivos foram desligados.';

  @override
  String get signOutAll => 'Terminar sessão em todo o lado';

  @override
  String fileTooBig(String name) {
    return '$name é demasiado grande.';
  }

  @override
  String get adsCreate => 'Criar um anúncio';

  @override
  String get adsEdit => 'Alterar o anúncio';

  @override
  String get adsCampaigns => 'As minhas campanhas';

  @override
  String get adsLibrary => 'Biblioteca';

  @override
  String get adsStats => 'Estatísticas';

  @override
  String get adsCreateTitle => 'Criar';

  @override
  String get adsCreateHint => 'Escolha o formato do seu anúncio.';

  @override
  String get adsContent => 'Conteúdo';

  @override
  String get adsBudgetTargeting => 'Orçamento e segmentação';

  @override
  String get adsPreview => 'Pré-visualização';

  @override
  String get adsPreviewHint => 'Pré-visualização no telemóvel';

  @override
  String get adsPreviewSimulation => 'Esta pré-visualização é uma simulação.';

  @override
  String get adsFromLibrary => 'Da biblioteca';

  @override
  String get adsUpload => 'Adicionar fotos ou vídeos';

  @override
  String get adsUploadHint =>
      'JPG, PNG, WebP (5 MB) · MP4, WebM, MOV (50 MB) · vídeos de 15 a 30 segundos recomendados';

  @override
  String get adsLibraryEmpty => 'A biblioteca está vazia.';

  @override
  String get adsDeleteFile => 'Eliminar este ficheiro da biblioteca?';

  @override
  String get adsEmpty => 'Ainda não há campanhas.';

  @override
  String get adsEmptyHint =>
      'Crie o seu primeiro anúncio: um vídeo, uma story de 24 h ou um prato em destaque.';

  @override
  String get adsActiveCampaigns => 'Campanhas';

  @override
  String adsCampaignCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ativas',
      one: '1 ativa',
      zero: 'nenhuma ativa',
    );
    return '$_temp0';
  }

  @override
  String get adFormat => 'Formato';

  @override
  String get adFormatVideo => 'Vídeo 15–30 s';

  @override
  String get adFormatVideoHint => 'Vídeo curto para captar a atenção';

  @override
  String get adFormatCarousel => 'Carrossel de fotos';

  @override
  String get adFormatCarouselHint => 'Várias imagens para deslizar';

  @override
  String get adFormatStory => 'Story 24 h';

  @override
  String get adFormatStoryHint => 'Formato efémero de 24 horas';

  @override
  String get adFormatSponsoredMenu => 'Menu patrocinado';

  @override
  String get adFormatSponsoredMenuHint => 'Destacar os seus pratos';

  @override
  String get adFormatPush => 'Notificação';

  @override
  String get adFormatPushHint => 'Avisar diretamente os seus clientes';

  @override
  String get adFormatClassified => 'Pequeno anúncio';

  @override
  String get adFormatClassifiedHint => 'Anúncio de texto simples e eficaz';

  @override
  String get adTitle => 'Título';

  @override
  String get adTitleHint => 'Ex.: Croissant de manteiga';

  @override
  String get adTitleRequired => 'Dê um título ao seu anúncio.';

  @override
  String get adText => 'Texto';

  @override
  String get adTextHint =>
      'Ex.: Novidade! Croissant artesanal caseiro, -20 % só esta noite';

  @override
  String get adMediaHelp => 'Fotos ou vídeos do anúncio (10 no máximo).';

  @override
  String get adVideoHelp => 'Adicione um vídeo curto (15 a 30 segundos).';

  @override
  String get adChooseItems => 'Pratos em destaque';

  @override
  String get adCta => 'Botão';

  @override
  String get adCtaHint => 'Ex.: Encomendar agora';

  @override
  String get adCtaDefault => 'Encomendar agora';

  @override
  String get adLink => 'Ligação do botão (opcional)';

  @override
  String get adDailyBudget => 'Orçamento diário';

  @override
  String get adBudgetNote =>
      'Orçamento previsto: a difusão patrocinada será faturada pela plataforma.';

  @override
  String get adStart => 'Início';

  @override
  String get adEnd => 'Fim';

  @override
  String get adStory24h => 'Visível 24 horas';

  @override
  String get adTargetAreas => 'Segmentação por bairro';

  @override
  String get adAddArea => 'Adicionar um bairro';

  @override
  String get adMoments => 'Momento';

  @override
  String get momentMorning => 'Manhã';

  @override
  String get momentNoon => 'Almoço';

  @override
  String get momentAfternoon => 'Tarde';

  @override
  String get momentEvening => 'Noite';

  @override
  String get momentNight => 'Madrugada';

  @override
  String get adBranches => 'Estabelecimentos';

  @override
  String get adSaveDraft => 'Guardar o rascunho';

  @override
  String get adPublish => 'Publicar';

  @override
  String get adPublished => 'Anúncio publicado.';

  @override
  String get adSponsored => 'Patrocinado';

  @override
  String get adStatusActive => 'Ativa';

  @override
  String get adStatusScheduled => 'Agendada';

  @override
  String get adStatusPaused => 'Em pausa';

  @override
  String get adStatusEnded => 'Terminada';

  @override
  String get adStatusDraft => 'Rascunho';

  @override
  String get adRoi => 'Faturação gerada';

  @override
  String adRoiDetail(String amount) {
    return 'para $amount de orçamento comprometido';
  }

  @override
  String adViews(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count visualizações',
      one: '1 visualização',
      zero: '0 visualizações',
    );
    return '$_temp0';
  }

  @override
  String adOrders(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pedidos',
      one: '1 pedido',
      zero: '0 pedidos',
    );
    return '$_temp0';
  }

  @override
  String get adDetails => 'Ver detalhes';

  @override
  String get adBoost => 'Impulsionar';

  @override
  String get adBoostTitle => 'Prolongar a difusão';

  @override
  String adBoostDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'mais $count dias',
      one: 'mais 1 dia',
    );
    return '$_temp0';
  }

  @override
  String get adBoosted => 'Campanha prolongada.';

  @override
  String get adPause => 'Pausar';

  @override
  String get adResume => 'Retomar';

  @override
  String get adEndNow => 'Terminar agora';

  @override
  String get adDeleteConfirm =>
      'Eliminar esta campanha e as suas estatísticas?';

  @override
  String get adStatViews => 'Visualizações';

  @override
  String get adStatClicks => 'Cliques';

  @override
  String get adStatClickRate => 'Taxa de cliques';

  @override
  String get adStatOrders => 'Pedidos';

  @override
  String get adStatRevenue => 'Faturação';

  @override
  String get adStatByCampaign => 'Visualizações por campanha';

  @override
  String get activeLabel => 'Ativo';

  @override
  String get addPhotos => 'Adicionar fotos';

  @override
  String get addProduct => 'Adicionar um produto';

  @override
  String get allItems => 'Todos';

  @override
  String get available => 'Disponível';

  @override
  String get categories => 'Categorias';

  @override
  String get copySuffix => 'cópia';

  @override
  String get customerSideView =>
      'Vista do cliente — aspeto no menu do restaurante';

  @override
  String get duplicate => 'Duplicar';

  @override
  String get everyDay => 'Todos os dias';

  @override
  String get filterKind => 'Tipo';

  @override
  String get itemDescriptionHint =>
      'Ex.: Folhas de ndolé com amendoim, camarão e banana-pão';

  @override
  String get itemDuplicated =>
      'Artigo duplicado: a cópia fica oculta até a guardar.';

  @override
  String get livePreview => 'Pré-visualização em direto';

  @override
  String get mainPhoto => 'Principal';

  @override
  String get makeMainPhoto => 'Definir como foto principal';

  @override
  String get markAvailable => 'Voltar a disponibilizar';

  @override
  String get markSoldOut => 'Marcar como esgotado';

  @override
  String get menuProducts => 'Produtos do menu';

  @override
  String get noProductsFound => 'Nenhum produto corresponde.';

  @override
  String photosHint(int count) {
    return 'Até $count fotos · JPG, PNG, WebP · 5 MB máx.';
  }

  @override
  String get play => 'Reproduzir';

  @override
  String prepMinutesShort(int minutes) {
    return 'Preparação: $minutes min';
  }

  @override
  String get prepTime => 'Tempo de preparação';

  @override
  String get productInfo => 'Informações do produto';

  @override
  String get productPhotos => 'Fotos do produto';

  @override
  String productsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count produtos',
      one: '1 produto',
      zero: 'Nenhum produto',
    );
    return '$_temp0';
  }

  @override
  String get publish => 'Publicar';

  @override
  String get replace => 'Substituir';

  @override
  String get saleDays => 'Dias de venda';

  @override
  String get saleDaysRequired => 'Escolha pelo menos um dia de venda.';

  @override
  String get searchProduct => 'Procurar um produto, um prato…';

  @override
  String get sizesLabel => 'Tamanhos';

  @override
  String get sortBy => 'Ordenar';

  @override
  String get sortMenuOrder => 'Ordem do menu';

  @override
  String get sortName => 'Nome';

  @override
  String get sortPriceAsc => 'Preço crescente';

  @override
  String get sortPriceDesc => 'Preço decrescente';

  @override
  String get stockAlertThreshold => 'Alerta abaixo de';

  @override
  String get stockAndTime => 'Stock e tempo';

  @override
  String stockLeft(int count) {
    return 'Stock: restam $count';
  }

  @override
  String stockLow(int count) {
    return 'Stock baixo: restam $count';
  }

  @override
  String get stockNotTracked => 'Vazio = sem seguimento';

  @override
  String get stockOfDay => 'Stock do dia';

  @override
  String get stockOfDayHint =>
      'Número de porções disponíveis hoje. Diminui a cada pedido; a zero, o artigo fica esgotado. Deixe vazio para não seguir.';

  @override
  String get stockQuantity => 'Quantidade em stock';

  @override
  String get supplementsLabel => 'Suplementos';

  @override
  String get videoAdded => 'Vídeo de apresentação adicionado';

  @override
  String get videoOptional => 'Vídeo de apresentação (opcional, cerca de 30 s)';

  @override
  String get allChannels => 'Todos os canais';

  @override
  String get amountLabel => 'Montante';

  @override
  String averageTicketShort(String amount) {
    return 'Talão médio $amount';
  }

  @override
  String get customerLabel => 'Cliente';

  @override
  String get financialResult => 'Resultado financeiro';

  @override
  String get inKitchenCount => 'em preparação';

  @override
  String get inProgressCount => 'em curso';

  @override
  String get itemsLabel => 'Artigos:';

  @override
  String get lateCount => 'atrasados';

  @override
  String get noOrdersHere => 'Nenhum pedido aqui';

  @override
  String get noSalesYet => 'Ainda sem vendas no período.';

  @override
  String get nothingToCollectHint =>
      'Nada pendente: os novos recebimentos aparecerão aqui.';

  @override
  String get orderLabel => 'Pedido';

  @override
  String get paymentLabel => 'Pagamento';

  @override
  String get periodLabel => 'Período';

  @override
  String get recentTransactions => 'Transações recentes';

  @override
  String get salesOfPeriod => 'Faturação do período';

  @override
  String get salesSplit => 'Repartição das vendas';

  @override
  String get timeLabel => 'Hora';

  @override
  String get topDishes => 'Pratos mais vendidos';

  @override
  String get viewDetails => 'Ver detalhes';

  @override
  String vsPrevious(String amount) {
    return 'Período anterior: $amount';
  }

  @override
  String get addAddress => 'Adicionar uma morada';

  @override
  String get addedToCart => 'Adicionado ao carrinho.';

  @override
  String get addressLabel => 'Nome da morada';

  @override
  String get addressLabelHint => 'Ex.: Casa, Escritório';

  @override
  String get addToCart => 'Adicionar ao carrinho';

  @override
  String get allCities => 'Todas as cidades';

  @override
  String get allRestaurants => 'Todos os restaurantes';

  @override
  String get birthday => 'Data de aniversário';

  @override
  String get cartEmpty => 'O seu carrinho está vazio.';

  @override
  String cartItems(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count artigos',
      one: '1 artigo',
    );
    return '$_temp0';
  }

  @override
  String get changeCity => 'Alterar';

  @override
  String get chooseCity => 'Escolher a cidade';

  @override
  String chooseOptionRequired(String name) {
    return 'Escolha: $name';
  }

  @override
  String get closedNow => 'Fechado';

  @override
  String get customerFavorites => 'Favoritos';

  @override
  String get customerHome => 'Início';

  @override
  String get customerOrders => 'Pedidos';

  @override
  String get customerProfile => 'Perfil';

  @override
  String customerReviews(int count) {
    return 'Avaliações de clientes ($count)';
  }

  @override
  String get customerSearch => 'Pesquisa';

  @override
  String get customerSpaceLink => 'Área de clientes · encomendar';

  @override
  String get deliveryDetailsRequired =>
      'Indique a morada de entrega e um telefone.';

  @override
  String get directions => 'Itinerário';

  @override
  String get discoverRestaurants => 'Descobrir restaurantes';

  @override
  String get dishes => 'Pratos';

  @override
  String get favoritesSignIn =>
      'Inicie sessão para encontrar os seus restaurantes favoritos.';

  @override
  String get fullName => 'Nome completo';

  @override
  String get globalCatalog => 'Catálogo global';

  @override
  String get healthAllergies => 'Saúde e alergias';

  @override
  String get howDoYouWant => 'Como deseja ser servido?';

  @override
  String loyaltyNextReward(int points, String amount) {
    return 'Próxima recompensa aos $points pontos: $amount';
  }

  @override
  String loyaltyPoints(int count) {
    return '$count pontos';
  }

  @override
  String get loyaltyProgram => 'Programa de fidelidade';

  @override
  String mapCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count estabelecimentos no mapa',
      one: '1 estabelecimento no mapa',
    );
    return '$_temp0';
  }

  @override
  String get mapView => 'Mapa';

  @override
  String minimumOrderNotReached(String amount) {
    return 'Pedido mínimo: $amount';
  }

  @override
  String minutesRange(int min, int max) {
    return '$min–$max min';
  }

  @override
  String get myAddresses => 'As minhas moradas';

  @override
  String get myCart => 'O meu carrinho';

  @override
  String get newRestaurant => 'Novo';

  @override
  String get noAddresses => 'Nenhuma morada guardada.';

  @override
  String get noCustomerOrders => 'Ainda não fez nenhum pedido.';

  @override
  String get noFavorites => 'Ainda sem favoritos.';

  @override
  String get noFavoritesHint =>
      'Toque no coração de um restaurante para o adicionar.';

  @override
  String get noLoyaltyYet =>
      'Os seus pontos aparecerão após os primeiros pedidos.';

  @override
  String get noRestaurantsYet =>
      'Ainda não há restaurantes publicados nesta cidade.';

  @override
  String get noteForKitchen => 'Indicação para a cozinha (opcional)';

  @override
  String get noteForKitchenHint => 'Ex.: sem picante, bem passado';

  @override
  String get notifOrderUpdates => 'Acompanhamento dos meus pedidos';

  @override
  String get notifPromotions => 'Promoções e ofertas';

  @override
  String get notifReservationReminders => 'Lembretes de reserva';

  @override
  String get onlineOrdersUnavailable =>
      'Encomenda online indisponível de momento';

  @override
  String get openFullMap => 'Abrir o mapa em ecrã inteiro';

  @override
  String get openNow => 'Aberto';

  @override
  String get orderDone => 'Concluído';

  @override
  String orderingAtTable(String table) {
    return 'Pedido na mesa $table';
  }

  @override
  String get orderInProgress => 'Em curso';

  @override
  String get orderNoteOptional => 'Mensagem para o restaurante (opcional)';

  @override
  String get orderRejected => 'Recusado pelo restaurante';

  @override
  String get orderSentToRestaurant =>
      'Pedido enviado! O restaurante vai confirmá-lo: acompanhe-o aqui em direto.';

  @override
  String get ordersSignIn => 'Inicie sessão para acompanhar os seus pedidos.';

  @override
  String get orderSummary => 'Resumo';

  @override
  String get orderWaitingConfirmation => 'A aguardar confirmação';

  @override
  String get payMobileWallet => 'Carteira móvel';

  @override
  String get personalProfile => 'Perfil pessoal';

  @override
  String get personalProfileHint =>
      'As suas informações pessoais e preferências.';

  @override
  String get placeOrder => 'Encomendar';

  @override
  String get preferences => 'Preferências';

  @override
  String get preferredPayment => 'Pagamento preferido';

  @override
  String get preferredPaymentHint =>
      'Apenas indicativo: nenhum número de cartão ou de conta é guardado.';

  @override
  String get productDetails => 'Detalhes do produto';

  @override
  String get profileSignIn =>
      'Inicie sessão para gerir o seu perfil, moradas e pontos.';

  @override
  String get rateOrder => 'Avaliar o meu pedido';

  @override
  String get requiredLabel => 'Obrigatório';

  @override
  String get restaurantOnVacation =>
      'O restaurante está temporariamente fechado.';

  @override
  String get restaurants => 'Restaurantes';

  @override
  String get restaurantSpace => 'Área do restaurante';

  @override
  String get restaurantUnavailable => 'Este restaurante não está disponível.';

  @override
  String get reviewComment => 'A sua avaliação (opcional)';

  @override
  String reviewsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count avaliações',
      one: '1 avaliação',
      zero: 'sem avaliações',
    );
    return '$_temp0';
  }

  @override
  String get searchRestaurantsHint =>
      'Pesquisar restaurantes, pratos, cozinhas…';

  @override
  String get seeAll => 'Ver tudo';

  @override
  String get send => 'Enviar';

  @override
  String get signInToContinue => 'Inicie sessão para continuar';

  @override
  String get spiceHot => 'Forte';

  @override
  String get spiceLevel => 'Picante';

  @override
  String get spiceMedium => 'Médio';

  @override
  String get spiceMild => 'Suave';

  @override
  String get spiceNone => 'Sem';

  @override
  String get sponsoredAds => 'Anúncios patrocinados';

  @override
  String get stepAccepted => 'Aceite pelo restaurante';

  @override
  String get stepDone => 'Concluído';

  @override
  String get stepPreparing => 'Em preparação';

  @override
  String get stepReady => 'Pronto';

  @override
  String get stepSent => 'Enviado';

  @override
  String get storyLabel => 'História';

  @override
  String get thanksForReview => 'Obrigado pela sua avaliação!';

  @override
  String get viewCart => 'Ver o carrinho';

  @override
  String get watchVideo => 'Vídeo';

  @override
  String get yourName => 'O seu nome';

  @override
  String get gpsHint =>
      '«Abrir no Maps» guarda automaticamente a posição onde se encontra: faça-o a partir do estabelecimento. Também pode introduzir as coordenadas.';

  @override
  String get locationSaved => 'Localização do estabelecimento guardada.';

  @override
  String get locationServiceDisabled =>
      'A localização do dispositivo está desativada: ative-a e tente novamente.';

  @override
  String get locationDenied =>
      'Acesso à localização recusado: autorize-o nas definições do navegador ou do telemóvel.';

  @override
  String get locationUnavailable =>
      'Localização indisponível de momento: tente no exterior ou introduza as coordenadas.';

  @override
  String get openMapAction => 'Abrir o mapa';

  @override
  String get customerReviewsTitle => 'Avaliações de clientes';

  @override
  String get forYou => 'Para si';

  @override
  String fromAmount(String amount) {
    return 'desde $amount';
  }

  @override
  String helpfulCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Útil ($count)',
      zero: 'Útil',
    );
    return '$_temp0';
  }

  @override
  String get hideReview => 'Ocultar a avaliação';

  @override
  String get hideReviewReason => 'Motivo';

  @override
  String get locatedNearYou => 'Restaurantes ordenados pela sua localização';

  @override
  String get locateMe => 'Localizar-me';

  @override
  String get locationRefusedChooseCity =>
      'Localização indisponível: escolha a sua cidade.';

  @override
  String get nearYouHint =>
      'Permita a localização para ver os restaurantes e pratos mais próximos.';

  @override
  String get nearYouRestaurants => 'Perto de si';

  @override
  String get nearYouTitle => 'Restaurantes perto de si';

  @override
  String get newOnMenus => 'Novidades';

  @override
  String get noReviewsYet => 'Ainda sem avaliações';

  @override
  String get openNowTitle => 'Abertos agora';

  @override
  String get orderAgain => 'Encomendar novamente';

  @override
  String get orderAgainAction => 'Repetir';

  @override
  String get ordersInProgressTitle => 'Os seus pedidos em curso';

  @override
  String get popularDishes => 'Pratos populares';

  @override
  String get popularNearYou => 'Populares perto de si';

  @override
  String get promotionsTitle => 'Promoções';

  @override
  String get publishReview => 'Publicar a minha avaliação';

  @override
  String rateDish(String name) {
    return 'Avaliar: $name';
  }

  @override
  String get rateShort => 'Avaliar';

  @override
  String get refreshLocation => 'Atualizar';

  @override
  String get reorderPartial =>
      'Alguns pratos já não estão disponíveis: o resto foi adicionado ao carrinho.';

  @override
  String get reorderUnavailable => 'Estes pratos já não estão disponíveis.';

  @override
  String get reportReason => 'Porque é que esta avaliação é abusiva?';

  @override
  String get reportReview => 'Denunciar';

  @override
  String reportsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count denúncias',
      one: '1 denúncia',
    );
    return '$_temp0';
  }

  @override
  String get reportSent => 'Obrigado, a denúncia foi enviada.';

  @override
  String get republishReview => 'Voltar a publicar';

  @override
  String get reviewCommentHint =>
      'Ex.: bem temperado, dose generosa, entrega rápida';

  @override
  String satisfiedPercent(int percent) {
    return '$percent % de clientes satisfeitos';
  }

  @override
  String get sortBestRated => 'Melhor avaliadas';

  @override
  String get sortHelpful => 'Mais úteis';

  @override
  String get sortRecent => 'Mais recentes';

  @override
  String get sortWorstRated => 'Pior avaliadas';

  @override
  String get verifiedPurchase => 'Compra verificada';

  @override
  String get verifiedReviewNote =>
      'Avaliação verificada: só os clientes que receberam este prato o podem avaliar.';

  @override
  String get asSoonAsPossible => 'O mais rápido possível';

  @override
  String get customerOrdersHere => 'Os pedidos dele consigo';

  @override
  String get customerPrivacyNote =>
      'Só vê a relação deste cliente com o seu restaurante: nunca os pedidos dele noutros restaurantes.';

  @override
  String get customersCount => 'clientes';

  @override
  String multiRestaurantNote(int count) {
    return '$count restaurantes no seu carrinho: cada um recebe o seu próprio pedido, com número e acompanhamento.';
  }

  @override
  String get navCustomers => 'Clientes';

  @override
  String get noCustomersYet => 'Ainda sem clientes online.';

  @override
  String get noCustomersYetHint =>
      'Cada cliente que encomenda pela aplicação aparece aqui automaticamente.';

  @override
  String get noDeliveryHere =>
      'Este restaurante não faz entregas: pedido para levar.';

  @override
  String get ordersSent => 'Pedidos enviados';

  @override
  String ordersSentHint(int count) {
    return '$count pedidos enviados, um por restaurante. Acompanhe cada um separadamente.';
  }

  @override
  String placeOrders(int count) {
    return 'Fazer os $count pedidos';
  }

  @override
  String get regularBadge => 'Habitual';

  @override
  String get regularCustomers => 'habituais (3 pedidos ou mais)';

  @override
  String restaurantsCount(int count) {
    return '$count restaurantes';
  }

  @override
  String get scheduleOrder => 'Agendar';

  @override
  String get scheduleTooSoon =>
      'Escolha uma hora pelo menos 15 minutos mais tarde.';

  @override
  String get searchCustomer => 'Nome ou telefone';

  @override
  String get sortBiggestSpenders => 'Maiores gastos';

  @override
  String get sortMostOrders => 'Mais pedidos';

  @override
  String get sortRecentVisit => 'Visita recente';

  @override
  String get teamNotes => 'Notas da equipa';

  @override
  String get teamNotesExample =>
      'Ex.: prefere a esplanada, gosta de molho picante';

  @override
  String get teamNotesHint => 'Visíveis apenas para a sua equipa.';

  @override
  String get trackOrder => 'Acompanhar';

  @override
  String get customerDiscover => 'Descobrir';

  @override
  String get feedEmpty => 'Ainda não há nada para descobrir';

  @override
  String get feedEmptyHint =>
      'Os vídeos, pratos e ofertas dos restaurantes da sua cidade aparecerão aqui.';

  @override
  String get feedOrder => 'Pedir';

  @override
  String get feedViewDish => 'Ver o prato';

  @override
  String get feedViewRestaurant => 'Ver o restaurante';

  @override
  String get feedLike => 'Gostar';

  @override
  String get feedSave => 'Guardar';

  @override
  String get feedShare => 'Partilhar';

  @override
  String get feedSaved => 'Guardado nos seus conteúdos.';

  @override
  String get feedUnsaved => 'Removido dos seus conteúdos guardados.';

  @override
  String get feedLinkCopied => 'Link copiado: cole-o para partilhar.';

  @override
  String get commentsTitle => 'Comentários';

  @override
  String get noCommentsYet => 'Ainda não há comentários.';

  @override
  String get writeComment => 'Escrever um comentário…';

  @override
  String get adHideForever => 'Não mostrar novamente';

  @override
  String reserveAt(String name) {
    return 'Reservar em $name';
  }

  @override
  String get reservationSentHint =>
      'Pedido enviado: o restaurante vai confirmar a sua reserva.';

  @override
  String get reservationNoteLabel => 'Observação (opcional)';

  @override
  String get errorInvalidComment =>
      'O comentário deve ter entre 1 e 500 caracteres.';

  @override
  String get adStatReach => 'Alcance';

  @override
  String get adStatEngagement => 'Envolvimento';

  @override
  String get adStatLikes => 'Gostos';

  @override
  String get adStatSaves => 'Guardados';

  @override
  String get adStatShares => 'Partilhas';

  @override
  String get hideComment => 'Ocultar';

  @override
  String get moderationReasonExample => 'Ex.: ofensivo, fora do tema';

  @override
  String get hiddenBadge => 'Oculto';

  @override
  String hiddenBecause(String reason) {
    return 'Oculto: $reason';
  }

  @override
  String get allFilter => 'Todos';

  @override
  String get publishedComments => 'Publicados';

  @override
  String get hiddenComments => 'Ocultos';

  @override
  String get adCommentsHint =>
      'Os comentários dos clientes sobre os seus anúncios aparecem aqui. Oculte os ofensivos ou fora do tema.';

  @override
  String get happyBirthday => 'Feliz aniversário!';

  @override
  String birthdayGift(String name, int points) {
    return '$name oferece-lhe $points pontos de fidelidade.';
  }

  @override
  String get thanksAction => 'Obrigado!';

  @override
  String get notificationsTitle => 'Notificações';

  @override
  String get noNotifications => 'Sem notificações';

  @override
  String get noNotificationsHint =>
      'Será avisado aqui quando um restaurante aceitar o seu pedido, quando estiver pronto ou quando uma reserva for confirmada.';

  @override
  String get notifOrderAcceptedTitle => 'Pedido aceite';

  @override
  String notifOrderAccepted(String brand, String number) {
    return '$brand aceitou o seu pedido n.º $number.';
  }

  @override
  String get notifOrderReadyTitle => 'Pedido pronto';

  @override
  String notifOrderReady(String brand, String number) {
    return 'O seu pedido n.º $number está pronto em $brand: pode levantá-lo.';
  }

  @override
  String notifOrderOnTheWay(String brand, String number) {
    return 'O seu pedido n.º $number de $brand está pronto e a caminho.';
  }

  @override
  String get notifOrderRejectedTitle => 'Pedido recusado';

  @override
  String notifOrderRejected(String brand, String number, String reason) {
    return '$brand não pôde aceitar o seu pedido n.º $number: $reason';
  }

  @override
  String get notifReservationConfirmedTitle => 'Reserva confirmada';

  @override
  String notifReservationConfirmed(String brand, String date) {
    return '$brand confirmou a sua reserva de $date.';
  }

  @override
  String get notifReservationDeclinedTitle => 'Reserva recusada';

  @override
  String notifReservationDeclined(String brand, String date, String reason) {
    return '$brand não o pode receber a $date: $reason';
  }

  @override
  String notifGroupJoined(String name, String brand) {
    return '$name juntou-se ao seu pedido de grupo em $brand.';
  }

  @override
  String notifGroupPlaced(String host, String brand, String number) {
    return '$host enviou o pedido de grupo em $brand (n.º $number).';
  }

  @override
  String get groupOrderTitle => 'Pedido de grupo';

  @override
  String get groupOrderAction => 'Pedido de grupo';

  @override
  String get groupInviteTitle => 'Convide os seus convivas';

  @override
  String get groupInviteHint =>
      'Partilhe este link: cada um escolhe os seus pratos no telemóvel e depois envia um único pedido.';

  @override
  String get groupEmpty => 'Ainda não há pratos';

  @override
  String get groupEmptyHint =>
      'Adicione os seus pratos e partilhe o link com os seus convivas.';

  @override
  String groupHostedBy(String name) {
    return 'Organizado por $name';
  }

  @override
  String groupStatusOpen(String time) {
    return 'Aberto até às $time';
  }

  @override
  String get groupStatusPlaced => 'Enviado ao restaurante';

  @override
  String get groupStatusCancelled => 'Cancelado';

  @override
  String get groupStatusExpired => 'Expirado';

  @override
  String groupParticipants(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count convivas',
      one: '1 conviva',
    );
    return '$_temp0';
  }

  @override
  String get groupCheckoutTitle => 'Enviar para todo o grupo';

  @override
  String get estimatedTotal => 'Total estimado';

  @override
  String get groupPlaceOrder => 'Enviar o pedido ao restaurante';

  @override
  String get cancelGroupOrder => 'Cancelar o pedido de grupo';

  @override
  String get cancelGroupOrderConfirm =>
      'Cancelar este pedido de grupo? Os pratos de todos serão perdidos.';

  @override
  String get groupAddMyDishes => 'Adicionar os meus pratos';

  @override
  String groupPlacedInfo(String name) {
    return '$name enviou o pedido ao restaurante.';
  }

  @override
  String get groupClosedInfo => 'Este pedido de grupo está fechado.';

  @override
  String get groupOrderPlaced => 'Pedido de grupo enviado ao restaurante.';

  @override
  String get addedToGroup => 'Adicionado ao pedido de grupo.';

  @override
  String get addToGroup => 'Adicionar ao grupo';

  @override
  String get saveDishAction => 'Guardar o prato';

  @override
  String saveDishTitle(String name) {
    return 'Guardar «$name»';
  }

  @override
  String get favoriteDishes => 'Pratos favoritos';

  @override
  String get myLists => 'As minhas listas';

  @override
  String get myCoupons => 'Os meus cupões';

  @override
  String get restaurantsSection => 'Restaurantes';

  @override
  String get unavailableNow => 'Indisponível';

  @override
  String get removeAction => 'Remover';

  @override
  String get noFavoriteDishes => 'Nenhum prato favorito';

  @override
  String get noFavoriteDishesHint =>
      'Toque no coração na ficha de um prato para o encontrar aqui.';

  @override
  String get newList => 'Nova lista';

  @override
  String get noLists => 'Nenhuma lista';

  @override
  String get noListsHint =>
      'Crie listas como «Para provar» ou «Almoços do escritório».';

  @override
  String deleteListConfirm(String name) {
    return 'Eliminar a lista «$name»?';
  }

  @override
  String get renameAction => 'Mudar o nome';

  @override
  String dishesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pratos',
      one: '1 prato',
      zero: 'Nenhum prato',
    );
    return '$_temp0';
  }

  @override
  String get emptyListHint =>
      'Lista vazia: adicione pratos a partir da ficha deles.';

  @override
  String get listName => 'Nome da lista';

  @override
  String get listNameExample => 'Ex.: Para provar';

  @override
  String get noCoupons => 'Nenhum cupão';

  @override
  String get noCouponsHint =>
      'Guarde as ofertas dos restaurantes a partir do início para as encontrar aqui.';

  @override
  String get couponsHowTo =>
      'Introduza o código no acompanhamento do seu pedido para obter o desconto.';

  @override
  String validUntil(String date) {
    return 'até $date';
  }

  @override
  String get couponUsed => 'Já utilizado';

  @override
  String get couponExpired => 'Expirado';

  @override
  String get codeCopied => 'Código copiado.';

  @override
  String get couponSaved => 'Cupão guardado nos seus favoritos.';

  @override
  String get saveCouponAction => 'Guardar';

  @override
  String get errorLimitReached =>
      'Limite atingido: remova elementos antes de adicionar outros.';

  @override
  String get errorGroupClosed =>
      'Este pedido de grupo está fechado ou expirou.';

  @override
  String get customersTab => 'Clientes';

  @override
  String get offersTab => 'Ofertas';

  @override
  String get loyaltyTab => 'Fidelidade';

  @override
  String get activeOffers => 'Ofertas em curso';

  @override
  String get publicCoupons => 'Cupões públicos';

  @override
  String get totalUses => 'Utilizações';

  @override
  String get newOffer => 'Nova oferta';

  @override
  String get editOffer => 'Editar a oferta';

  @override
  String get offersEmpty => 'Nenhuma oferta';

  @override
  String get offersEmptyHint =>
      'Crie um desconto, um código promocional ou um cupão público para atrair e fidelizar os seus clientes.';

  @override
  String get offerStatusOff => 'Desativada';

  @override
  String get offerStatusEnded => 'Terminada';

  @override
  String get offerStatusScheduled => 'Agendada';

  @override
  String get offerStatusActive => 'Em curso';

  @override
  String get publicCouponLabel => 'Cupão público';

  @override
  String get publicCouponHint =>
      'Visível na aplicação: os clientes podem guardá-lo na carteira.';

  @override
  String get publicCouponNeedsCode => 'Um cupão público precisa de um código.';

  @override
  String usesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count utilizações',
      one: '1 utilização',
      zero: 'Nunca utilizada',
    );
    return '$_temp0';
  }

  @override
  String get offerName => 'Nome da oferta';

  @override
  String get offerNameExample => 'Ex.: Boas-vindas, Happy hour';

  @override
  String get discountPercent => 'Percentagem';

  @override
  String get discountAmount => 'Montante';

  @override
  String get offerValue => 'Desconto';

  @override
  String get promoCodeLabel => 'Código (opcional)';

  @override
  String get offerCodeHint => '3 a 30 letras ou algarismos, ex. BEMVINDO';

  @override
  String get minOrderLabel => 'Pedido mínimo';

  @override
  String get maxUsesLabel => 'Utilizações máx.';

  @override
  String get perCustomerLabel => 'Por cliente';

  @override
  String get startsLabel => 'Início';

  @override
  String get endsLabel => 'Fim';

  @override
  String get offerNow => 'agora';

  @override
  String get noEndDate => 'Sem fim';

  @override
  String get allBranchesLabel => 'Todos os estabelecimentos';

  @override
  String get thisBranchOnly => 'Este estabelecimento';

  @override
  String get offerActive => 'Oferta ativa';

  @override
  String get loyaltyMembers => 'Membros';

  @override
  String get pointsInCirculation => 'Pontos em circulação';

  @override
  String get loyaltyProgramTitle => 'Programa de fidelidade';

  @override
  String loyaltyExample(String amount, int points) {
    return 'Exemplo: um pedido de $amount dá $points pontos.';
  }

  @override
  String get loyaltyActive => 'Programa ativo';

  @override
  String get amountPerPoint => 'Montante por 1 ponto';

  @override
  String get rewardPointsLabel => 'Pontos para uma recompensa';

  @override
  String get rewardValueLabel => 'Valor da recompensa';

  @override
  String get birthdayPointsLabel => 'Pontos de aniversário';

  @override
  String get birthdayPointsHint =>
      'Creditados automaticamente todos os anos aos clientes que já fizeram pedidos no seu restaurante (0 = nenhum).';

  @override
  String get stockDashboardTab => 'Painel';

  @override
  String get stockArticlesTab => 'Artigos';

  @override
  String get stockOrdersTab => 'Encomendas';

  @override
  String get stockReportsTab => 'Relatórios';

  @override
  String get stockDashboardTitle => 'Painel do stock';

  @override
  String get stockValueLabel => 'Valor do stock';

  @override
  String get belowThresholdLabel => 'Abaixo do limite';

  @override
  String get outOfStockLabel => 'Em rutura';

  @override
  String get expiringSoonLabel => 'Validade próxima';

  @override
  String get inventoryVarianceLabel => 'Diferenças de inventário';

  @override
  String get consumptionLabel => 'Consumo';

  @override
  String get wasteLabel => 'Perdas';

  @override
  String get receiptsLabel => 'Receções';

  @override
  String articlesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count artigos',
      one: '1 artigo',
      zero: 'Nenhum artigo',
    );
    return '$_temp0';
  }

  @override
  String daysCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dias',
      one: '1 dia',
    );
    return '$_temp0';
  }

  @override
  String get consumptionByDay => 'Consumo e perdas por dia';

  @override
  String get topConsumedTitle => 'Os mais consumidos';

  @override
  String get wasteByReason => 'Perdas por motivo';

  @override
  String get noMovementsPeriod => 'Sem movimentos neste período.';

  @override
  String get noWastePeriod => 'Sem perdas neste período.';

  @override
  String get expiringLotsTitle => 'Lotes a vigiar (validades)';

  @override
  String get noExpiringLots => 'Nenhum lote expira nos próximos 7 dias.';

  @override
  String get toReorderTitle => 'A encomendar';

  @override
  String get noAlerts => 'Nenhum artigo abaixo do limite.';

  @override
  String get prepareOrder => 'Preparar a encomenda';

  @override
  String get expiredShort => 'Expirado';

  @override
  String daysLeftShort(int count) {
    return 'D-$count';
  }

  @override
  String daysLeftLong(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dias de stock',
      one: '1 dia de stock',
      zero: 'esgota hoje',
    );
    return '$_temp0';
  }

  @override
  String batchShort(String batch) {
    return 'Lote $batch';
  }

  @override
  String get batchNumber => 'N.º de lote';

  @override
  String get expiryDate => 'Data de validade';

  @override
  String get stockEmptyHint =>
      'Crie os seus artigos no separador Artigos e registe o stock inicial ou uma receção.';

  @override
  String get searchArticle => 'Procurar um artigo';

  @override
  String get showInactive => 'Mostrar inativos';

  @override
  String get newArticle => 'Novo artigo';

  @override
  String get editArticle => 'Editar o artigo';

  @override
  String get articlesEmptyHint =>
      'Adicione os seus produtos: legumes, carnes, bebidas, embalagens, preparações próprias…';

  @override
  String get storageLabel => 'Conservação';

  @override
  String get storageAmbient => 'Ambiente';

  @override
  String get storageChilled => 'Refrigerado';

  @override
  String get storageFrozen => 'Congelado';

  @override
  String get purchaseUnitLabel => 'Unidade de compra';

  @override
  String get purchaseUnitExample => 'Ex.: Saco de 5 kg, Caixa de 12';

  @override
  String get purchaseUnitQty => 'Conteúdo';

  @override
  String get preferredSupplier => 'Fornecedor habitual';

  @override
  String get noneLabel => 'Nenhum';

  @override
  String get shelfLifeDays => 'Prazo de validade';

  @override
  String get daysShort => 'dias';

  @override
  String get barcodeLabel => 'Código de barras';

  @override
  String get thresholdThisBranch => 'Limite de alerta deste estabelecimento';

  @override
  String get reorderTitle => 'Encomenda sugerida';

  @override
  String get reorderHint =>
      'O necessário para ficar acima do limite, com base no consumo dos últimos 28 dias.';

  @override
  String get nothingToReorder => 'Nada a encomendar';

  @override
  String get nothingToReorderHint =>
      'Todos os artigos acompanhados têm stock suficiente para o período escolhido.';

  @override
  String get noSupplier => 'Sem fornecedor habitual';

  @override
  String get noSupplierHint =>
      'Escolha um fornecedor habitual na ficha do artigo para criar uma nota de encomenda.';

  @override
  String get orderFormPdf => 'Nota de encomenda em PDF';

  @override
  String get createPurchaseOrder => 'Criar a nota de encomenda';

  @override
  String get purchaseOrderDraftCreated =>
      'Nota de encomenda criada como rascunho em Compras.';

  @override
  String get reorderNote => 'Encomenda sugerida pelo stock';

  @override
  String inStockShort(String qty) {
    return 'Em stock: $qty';
  }

  @override
  String get entriesFilter => 'Entradas';

  @override
  String get exitsLabel => 'Saídas';

  @override
  String get transfersFilter => 'Transferências';

  @override
  String get adjustmentsFilter => 'Ajustes';

  @override
  String get movementsReportTitle => 'Movimentos de stock';

  @override
  String get wasteReportTitle => 'Perdas e quebras';

  @override
  String get reportValuation => 'Stock valorizado';

  @override
  String get reportValuationHint =>
      'Quantidades, limites, custo médio e valor de cada artigo neste momento.';

  @override
  String get reportMovementsHint =>
      'Todos os movimentos do período, com totais por tipo.';

  @override
  String get reportWasteHint => 'Perdas do período com o motivo e o valor.';

  @override
  String get reportInventory => 'Inventário com diferenças';

  @override
  String get reportInventoryHint =>
      'Teórico, contado, diferenças valorizadas, com assinaturas.';

  @override
  String get reportFoodCost => 'Custo de matéria-prima por prato';

  @override
  String get reportFoodCostHint =>
      'Custo, preço de venda, peso no preço e margem de cada prato.';

  @override
  String get reportExpiringHint =>
      'Lotes em stock que expiram nos próximos 14 dias.';

  @override
  String get generatePdf => 'Gerar o PDF';

  @override
  String get noValidatedInventory => 'Ainda não há inventários validados.';

  @override
  String get chooseInventory => 'Escolher o inventário';

  @override
  String generatedOn(String date) {
    return 'Emitido em $date';
  }

  @override
  String get articlesLabel => 'Artigos';

  @override
  String get articleLabel => 'Artigo';

  @override
  String get avgCostShort => 'Custo médio';

  @override
  String get valueLabel => 'Valor';

  @override
  String get typeLabel => 'Tipo';

  @override
  String get inventoryGains => 'Excedentes';

  @override
  String get inventoryLosses => 'Faltas';

  @override
  String get inventoryNet => 'Diferença líquida';

  @override
  String get theoreticalLabel => 'Teórico';

  @override
  String get countedBySignature => 'Contado por: ____________________';

  @override
  String get validatedBySignature => 'Validado por: ____________________';

  @override
  String get targetFoodCost => 'Objetivo de custo de matéria-prima';

  @override
  String get targetFoodCostHint =>
      'Parte máxima do preço de venda que os ingredientes de um prato devem representar (muitas vezes 25 a 35 %).';

  @override
  String targetFoodCostValue(String percent) {
    return 'Objetivo de matéria-prima: $percent %';
  }

  @override
  String get dishesWithRecipe => 'Pratos com ficha';

  @override
  String get aboveTarget => 'Acima do objetivo';

  @override
  String get aboveTargetShort => 'demasiado caro';

  @override
  String get withoutRecipe => 'Sem ficha';

  @override
  String get recipeDefined => 'Ficha definida';

  @override
  String get dishLabel => 'Prato';

  @override
  String get costPriceShort => 'Custo';

  @override
  String get sellingPriceShort => 'Preço';

  @override
  String get foodCostShort => 'matéria-prima';

  @override
  String get marginShort => 'Margem';

  @override
  String get orderFormTitle => 'Nota de encomenda';

  @override
  String supplierLabelValue(String name) {
    return 'Fornecedor: $name';
  }

  @override
  String get packagingLabel => 'Embalagem';

  @override
  String get unitPriceShort => 'Preço unitário';

  @override
  String get orderFormFooter =>
      'Por favor, confirme a disponibilidade e o prazo de entrega.';

  @override
  String get accountTypeQuestion => 'Você é:';

  @override
  String get accountTypeCustomer => 'Cliente';

  @override
  String get accountTypeCustomerHint =>
      'Descobrir restaurantes, encomendar, reservar';

  @override
  String get accountTypeBusiness => 'Empresa';

  @override
  String get accountTypeBusinessHint =>
      'Gerir o meu restaurante e a minha equipa';

  @override
  String get accountTypeRequired => 'Escolha Cliente ou Empresa.';

  @override
  String get accountTypeTitle => 'Bem-vindo ao Resto';

  @override
  String get accountTypeSub => 'Como vai utilizar a aplicação?';

  @override
  String get continueAction => 'Continuar';

  @override
  String adVideoTooBig(String name) {
    return '$name ultrapassa 50 MB: escolha um vídeo mais curto (cerca de 30 segundos).';
  }

  @override
  String adMediaAdded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ficheiros adicionados.',
      one: '1 ficheiro adicionado.',
    );
    return '$_temp0';
  }

  @override
  String get adNeedVideo => 'Adicione um vídeo antes de publicar este formato.';

  @override
  String get adNeedMedia =>
      'Adicione pelo menos uma foto ou um vídeo antes de publicar.';

  @override
  String get adNeedItems => 'Escolha pelo menos um prato para destacar.';

  @override
  String get uploadingLabel => 'A enviar…';

  @override
  String get errorInvalidMedia =>
      'Ficheiro recusado: deve vir da sua mediateca.';

  @override
  String get errorFileTooLarge => 'Ficheiro demasiado grande.';

  @override
  String get errorFileType =>
      'Formato de ficheiro não aceite (JPG, PNG, WebP, MP4, WebM, MOV).';

  @override
  String get adAddVideo => 'Adicionar um vídeo';

  @override
  String get errorOutOfStock => 'Este prato está esgotado por hoje.';

  @override
  String get errorInvalidRating => 'A nota deve estar entre 1 e 5.';

  @override
  String get errorInvalidAllergen => 'Alergénio desconhecido.';

  @override
  String get bestSeller => 'Mais vendido';

  @override
  String get callAction => 'Ligar';

  @override
  String get writeAction => 'Escrever';

  @override
  String get categoriesLabel => 'Categorias';

  @override
  String get filtersLabel => 'Filtros';

  @override
  String get reviewsTab => 'Avaliações';

  @override
  String get infosTab => 'Info';

  @override
  String get noDishMatches => 'Nenhum prato corresponde a estes filtros.';

  @override
  String soldCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count vendidos',
      one: '1 vendido',
    );
    return '$_temp0';
  }

  @override
  String get yourCart => 'O seu carrinho';

  @override
  String get coverPhoto => 'Foto de capa';

  @override
  String get coverPhotoHint =>
      'Foto grande no topo da página do seu restaurante (sala, esplanada, fachada).';

  @override
  String get changePhoto => 'Mudar a foto';

  @override
  String get itemTagsLabel => 'Etiquetas (filtros da sua carta)';

  @override
  String get itemTagsHint =>
      'Crie as suas próprias etiquetas: os clientes poderão filtrar a carta com elas. Ex.: Picante suave, Halal, Sem álcool, Caseiro.';

  @override
  String get addTagHint => 'Nova etiqueta + Enter';

  @override
  String get errorInvalidTag => 'Uma etiqueta tem no máximo 30 caracteres.';

  @override
  String itemFavorites(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count clientes o têm nos favoritos',
      one: '1 cliente o tem nos favoritos',
      zero: 'Nenhum cliente o tem nos favoritos',
    );
    return '$_temp0';
  }

  @override
  String get itemSold30 => 'Vendas dos últimos 30 dias';

  @override
  String get receiptOrderNo => 'Pedido N.º';

  @override
  String get receiptTicketNo => 'Recibo N.º';

  @override
  String get receiptChannel => 'Canal';

  @override
  String get receiptQtyShort => 'Qtd.';

  @override
  String get receiptTotalInclTax => 'Total com impostos';

  @override
  String get receiptTotalExclTax => 'Total sem impostos';

  @override
  String get receiptApproved => 'Transação aprovada';

  @override
  String receiptRef(String ref) {
    return 'Ref.: $ref';
  }

  @override
  String receiptSeeYou(String name) {
    return 'Até breve no $name';
  }

  @override
  String get receiptRecycle =>
      'Por um planeta mais verde, recicle este recibo.';

  @override
  String get receiptLoyaltyTitle => 'A sua fidelidade é recompensada!';

  @override
  String get receiptLoyaltyCaption =>
      'Leia este QR code para aceder ao seu espaço de fidelidade e aproveitar as suas vantagens.';

  @override
  String get receiptPaperLabel => 'Impressora de recibos deste aparelho';

  @override
  String get receiptPaper80 => 'Rolo de 80 mm';

  @override
  String get receiptPaper58 => 'Rolo de 58 mm';

  @override
  String get receiptPhotosLabel => 'Fotos dos pratos no recibo';

  @override
  String get receiptTestPrint => 'Imprimir um recibo de teste';

  @override
  String get receiptTestTitle => 'Recibo de teste';

  @override
  String get receiptHeaderSection => 'Cabeçalho do recibo';

  @override
  String get receiptFooterSection => 'Rodapé do recibo';

  @override
  String get receiptTitleLabel => 'Nome apresentado';

  @override
  String get receiptTitleHint => 'Por defeito: o nome da marca';

  @override
  String get receiptSubtitleLabel => 'Subtítulo';

  @override
  String get receiptSubtitleHint => 'Ex.: Restaurante & Sabores';

  @override
  String get receiptSloganLabel => 'Slogan';

  @override
  String get receiptSloganHint => 'Ex.: Cozinha autêntica, sabores do mundo';

  @override
  String get websiteLabel => 'Site';

  @override
  String get websiteHint => 'Ex.: www.meurestaurante.com';

  @override
  String get receiptQrTitleLabel => 'Título ao lado do QR code';

  @override
  String get receiptQrCaptionLabel => 'Texto ao lado do QR code';

  @override
  String get receiptFarewellLabel => 'Frase de despedida';

  @override
  String get receiptFarewellHint => 'Ex.: Até breve!';

  @override
  String itemLikesTip(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count gostos',
      one: '1 gosto',
      zero: 'Nenhum gosto',
    );
    return '$_temp0';
  }

  @override
  String get itemReviewAction => 'Opinião';

  @override
  String get itemHeartAction => 'Adoro';

  @override
  String get itemCommentsTitle => 'Opiniões dos clientes';

  @override
  String get itemVerifiedReviews => 'Opiniões com nota após uma encomenda';

  @override
  String get notifStaffNewOrderTitle => 'Novo pedido';

  @override
  String notifStaffNewOrder(String number, String customer, String branch) {
    return 'Pedido n.º $number $customer — $branch';
  }

  @override
  String get notifStaffOrderReadyTitle => 'Pedido pronto a servir';

  @override
  String notifStaffOrderReady(String number, String branch) {
    return 'Pedido n.º $number — $branch';
  }

  @override
  String get notifStaffReservationTitle => 'Nova reserva';

  @override
  String notifStaffReservation(String name, int count, String date) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pessoas',
      one: '1 pessoa',
    );
    return '$name · $_temp0 · $date';
  }

  @override
  String get notifStaffReviewTitle => 'Nova opinião';

  @override
  String notifStaffReview(String author, String item) {
    return '$author sobre «$item»';
  }

  @override
  String get pushNewOrder =>
      'Notificação no telemóvel: novo pedido de um cliente';

  @override
  String get pushOrderReady =>
      'Notificação no telemóvel: pedido pronto a servir';

  @override
  String get pushReservations => 'Notificação no telemóvel: nova reserva';

  @override
  String get pushReviews =>
      'Notificação no telemóvel: nova opinião sobre um prato';

  @override
  String get tablesTab => 'Mesas';

  @override
  String get tablesNow => 'Agora';

  @override
  String get tablesLater => 'Escolher um momento';

  @override
  String get tableLegendOccupied => 'Ocupada';

  @override
  String get tableLegendReserved => 'Reservada';

  @override
  String get tableLegendChosen => 'A sua escolha';

  @override
  String tableFreeUntil(String time) {
    return 'Livre até às $time';
  }

  @override
  String tableOccupiedUntil(String time) {
    return 'Livre por volta das $time';
  }

  @override
  String tableReservedSlot(String from, String to) {
    return 'Reservada $from–$to';
  }

  @override
  String get tablesSelectHint =>
      'Toque numa ou mais mesas livres para as reservar.';

  @override
  String tablesSeatsChosen(int seats, int party) {
    String _temp0 = intl.Intl.pluralLogic(
      seats,
      locale: localeName,
      other: '$seats lugares escolhidos',
      one: '1 lugar escolhido',
    );
    String _temp1 = intl.Intl.pluralLogic(
      party,
      locale: localeName,
      other: '$party pessoas',
      one: '1 pessoa',
    );
    return '$_temp0 para $_temp1';
  }

  @override
  String reserveTablesAction(String tables) {
    return 'Reservar $tables';
  }

  @override
  String tableLabelChip(String label) {
    return 'Mesa $label';
  }

  @override
  String get tablesEmpty =>
      'Este restaurante ainda não apresentou as suas mesas.';

  @override
  String appVersion(String version, String build) {
    return 'Resto · versão $version ($build)';
  }

  @override
  String get dashTabOverview => 'Visão geral';

  @override
  String get dashTabDishes => 'Pratos';

  @override
  String get dashTabTeam => 'Equipa e serviço';

  @override
  String get dashTabFinance => 'Finanças';

  @override
  String get coversLabel => 'Talheres';

  @override
  String perCoverLabel(String amount) {
    return '$amount por talher';
  }

  @override
  String get occupancyLabel => 'Mesas ocupadas';

  @override
  String get paymentsByMethod => 'Recebimentos por meio de pagamento';

  @override
  String get busyHours => 'Afluência por dia e hora';

  @override
  String get menuEngineering => 'Engenharia de menu';

  @override
  String get menuEngineeringHint =>
      'Vendas × margem de cada prato, segundo as fichas técnicas.';

  @override
  String get engStars => 'Estrelas';

  @override
  String get engStarsHint =>
      'Muito vendidos e rentáveis: mantenha-os em destaque.';

  @override
  String get engPlowhorses => 'Populares, pouco rentáveis';

  @override
  String get engPlowhorsesHint => 'Reveja o preço ou o custo.';

  @override
  String get engPuzzles => 'Rentáveis, pouco vendidos';

  @override
  String get engPuzzlesHint =>
      'Destaque-os: foto, publicidade, sugestão da equipa.';

  @override
  String get engDogs => 'A rever';

  @override
  String get engDogsHint =>
      'Pouco vendidos e pouco rentáveis: refazer ou retirar.';

  @override
  String engNoRecipe(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pratos sem ficha técnica não estão classificados.',
      one: '1 prato sem ficha técnica não está classificado.',
    );
    return '$_temp0';
  }

  @override
  String get slowSellers => 'Pratos que vendem pouco';

  @override
  String get teamPerformance => 'Desempenho da equipa';

  @override
  String get memberLabel => 'Membro';

  @override
  String get staffOrders => 'Pedidos';

  @override
  String get staffSales => 'Vendas';

  @override
  String get staffTips => 'Gorjetas';

  @override
  String get serviceTimes => 'Tempos de serviço';

  @override
  String get serveTime => 'Chegada à mesa';

  @override
  String get tableTime => 'Tempo à mesa';

  @override
  String minutesValue(int count) {
    return '$count min';
  }

  @override
  String targetMinutes(int count) {
    return 'Objetivo: $count min';
  }

  @override
  String get cancellationsTitle => 'Anulações';

  @override
  String cancelledOrdersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pedidos anulados',
      one: '1 pedido anulado',
      zero: 'Nenhum pedido anulado',
    );
    return '$_temp0';
  }

  @override
  String cancelledItemsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count artigos anulados após envio',
      one: '1 artigo anulado após envio',
      zero: 'Nenhum artigo anulado após envio',
    );
    return '$_temp0';
  }

  @override
  String get cancelReasonsTitle => 'Motivos mais frequentes';

  @override
  String get dashPdf => 'Relatório PDF';

  @override
  String get insightsUnavailable =>
      'Os indicadores detalhados aparecerão após a atualização da base (migração 034).';

  @override
  String get salesByDayTitle => 'Vendas por dia';

  @override
  String get ordersCountLabel => 'Pedidos';

  @override
  String get financeItemLabel => 'Rubrica';

  @override
  String get supplierLabel => 'Fornecedor';

  @override
  String get purchaseOrderTitle => 'Nota de encomenda';

  @override
  String get supplierStatementTitle => 'Extrato de conta do fornecedor';

  @override
  String get dueDateLabel => 'Vencimento';

  @override
  String get balanceDue => 'Saldo em dívida';

  @override
  String get purchasesThisMonth => 'Compras do mês';

  @override
  String openInvoicesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count faturas a pagar',
      one: '1 fatura a pagar',
      zero: 'Nenhuma fatura a pagar',
    );
    return '$_temp0';
  }

  @override
  String get overdueInvoices => 'Faturas em atraso';

  @override
  String get dueWithinWeek => 'A pagar em 7 dias';

  @override
  String get pendingPurchaseOrders => 'Encomendas em curso';

  @override
  String get paymentSchedule => 'Calendário de pagamentos';

  @override
  String get nothingToPay => 'Nenhuma fatura a pagar.';

  @override
  String get noDueDate => 'Sem vencimento';

  @override
  String get purchasesByMonth => 'Compras por mês';

  @override
  String get topSuppliers => 'Principais fornecedores (90 dias)';

  @override
  String get noPurchasesYet => 'Ainda não há compras.';

  @override
  String get totalPurchased => 'Total comprado';

  @override
  String get purchaseOrderPdf => 'Nota de encomenda PDF';

  @override
  String recurringGenerated(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count despesas recorrentes registadas.',
      one: '1 despesa recorrente registada.',
      zero: 'Nenhuma despesa a registar.',
    );
    return '$_temp0';
  }

  @override
  String recurringDue(int count, String amount) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count despesas recorrentes a registar este mês ($amount)',
      one: '1 despesa recorrente a registar este mês ($amount)',
    );
    return '$_temp0';
  }

  @override
  String get generateNow => 'Registar';

  @override
  String get expensesOfMonth => 'Despesas do mês';

  @override
  String vsLastMonth(String value) {
    return '$value face ao mês passado';
  }

  @override
  String get lastMonthLabel => 'Mês passado';

  @override
  String get recurringTab => 'Recorrentes';

  @override
  String get budgetsExceeded => 'Orçamentos ultrapassados';

  @override
  String get expensesSixMonths => 'Despesas dos últimos seis meses';

  @override
  String get budgetsTab => 'Orçamentos';

  @override
  String get noBudgetsYet =>
      'Nenhum orçamento definido. Adicione-os no separador Orçamentos.';

  @override
  String get newRecurringExpense => 'Nova despesa recorrente';

  @override
  String get recurringHint =>
      'Renda, assinaturas, salários…: registados todos os meses com um gesto a partir da visão geral.';

  @override
  String get noRecurringYet => 'Nenhuma despesa recorrente.';

  @override
  String everyMonthOn(int day) {
    return 'todos os meses no dia $day';
  }

  @override
  String get recurringExample => 'Ex.: Renda do espaço';

  @override
  String get expenseCategoryField => 'Categoria';

  @override
  String get dayOfMonthLabel => 'Dia do mês';

  @override
  String get budgetsHint =>
      'Montante a não ultrapassar por mês, por categoria. Deixe vazio para não acompanhar uma categoria.';

  @override
  String get startTitle => 'Começar bem';

  @override
  String startProgress(int done, int total) {
    return '$done de $total passos feitos';
  }

  @override
  String get startProfile =>
      'Complete a ficha do restaurante (morada, telefone, logótipo)';

  @override
  String get startDishes => 'Adicione os seus pratos e bebidas';

  @override
  String get startTables => 'Crie as suas mesas';

  @override
  String get startPayments => 'Verifique os meios de pagamento';

  @override
  String get startTeam => 'Convide a sua equipa';

  @override
  String get startPublish => 'Publique o restaurante para os clientes';

  @override
  String get hideAction => 'Ocultar';

  @override
  String get adPushNote =>
      'A notificação chega aos clientes que seguem o restaurante, encomendaram lá no último ano, gostam dos seus pratos ou anúncios, ou moram a menos de 30 km. Uma oferta agendada é enviada na data de início.';

  @override
  String adPushAudience(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count clientes receberão esta oferta',
      one: '1 cliente receberá esta oferta',
      zero: 'Ainda não há clientes a avisar',
    );
    return '$_temp0';
  }
}
