// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appName => 'Resto';

  @override
  String environmentBanner(String env) {
    return 'Entorno: $env';
  }

  @override
  String get configMissingTitle => 'Falta la configuración';

  @override
  String get configMissingBody =>
      'No se han indicado la dirección del servidor ni la clave pública (archivo env/<entorno>.json).';

  @override
  String get languageLabel => 'Idioma';

  @override
  String get systemLanguage => 'Idioma del dispositivo';

  @override
  String pendingSyncEvents(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count operaciones pendientes',
      one: '1 operación pendiente',
      zero: 'Todo está sincronizado',
    );
    return '$_temp0';
  }

  @override
  String get errorNotAuthenticated => 'Inicie sesión.';

  @override
  String get errorForbidden => 'No tiene permiso para realizar esta acción.';

  @override
  String get errorOwnerOnly =>
      'Solo un propietario puede realizar esta acción.';

  @override
  String get errorRateLimited => 'Demasiadas solicitudes. Inténtelo más tarde.';

  @override
  String get errorInvalidTimezone => 'Zona horaria desconocida.';

  @override
  String get errorInvalidRole => 'Rol desconocido.';

  @override
  String get errorInvalidEmail => 'Correo electrónico no válido.';

  @override
  String get errorInvalidBranch => 'Local no encontrado en esta organización.';

  @override
  String get errorBranchesRequired => 'Seleccione al menos un local.';

  @override
  String get errorAlreadyMember =>
      'Esta persona ya forma parte de la organización.';

  @override
  String get errorInvitationInvalid =>
      'Invitación no válida, caducada o ya utilizada.';

  @override
  String get errorInvitationWrongAccount =>
      'Esta invitación es para otra dirección de correo.';

  @override
  String get errorLastOwner =>
      'La organización debe conservar al menos un propietario.';

  @override
  String get errorMembershipRevoked =>
      'Este miembro fue retirado de la organización.';

  @override
  String get errorNetwork =>
      'No se puede conectar. Compruebe su acceso a Internet.';

  @override
  String get errorUnknown => 'Se ha producido un error inesperado.';

  @override
  String get welcomeTitle => 'Bienvenido a Resto';

  @override
  String get signInTitle => 'Inicio de sesión';

  @override
  String get signIn => 'Iniciar sesión';

  @override
  String get signOut => 'Cerrar sesión';

  @override
  String get createAccount => 'Crear una cuenta';

  @override
  String get forgotPassword => 'Contraseña olvidada';

  @override
  String get email => 'Correo electrónico';

  @override
  String get password => 'Contraseña';

  @override
  String get passwordConfirm => 'Confirmar contraseña';

  @override
  String get passwordTooShort => 'Mínimo 8 caracteres.';

  @override
  String get passwordsDiffer => 'Las contraseñas no coinciden.';

  @override
  String get passwordChanged => 'Contraseña cambiada.';

  @override
  String get newPasswordTitle => 'Nueva contraseña';

  @override
  String get changePassword => 'Cambiar la contraseña';

  @override
  String get displayName => 'Nombre';

  @override
  String get fieldRequired => 'Campo obligatorio';

  @override
  String get verifyEmailTitle => 'Confirme su correo electrónico';

  @override
  String codeSentTo(String email) {
    return 'Código enviado a $email.';
  }

  @override
  String get code => 'Código';

  @override
  String get verify => 'Validar';

  @override
  String get resendCode => 'Reenviar el código';

  @override
  String get codeResent => 'Se ha enviado un nuevo código.';

  @override
  String get sendCode => 'Enviar el código';

  @override
  String get authInvalidCredentials => 'Correo o contraseña incorrectos.';

  @override
  String get authEmailNotConfirmed => 'Correo electrónico no confirmado.';

  @override
  String get authUserExists => 'Ya existe una cuenta con esta dirección.';

  @override
  String get authWeakPassword => 'Contraseña demasiado débil.';

  @override
  String get authCodeInvalid => 'Código no válido o caducado.';

  @override
  String get authSamePassword =>
      'La nueva contraseña debe ser distinta de la anterior.';

  @override
  String get errorDuplicate => 'Este valor ya existe.';

  @override
  String get errorInvalidHours => 'Horario no válido.';

  @override
  String get createRestaurant => 'Crear mi restaurante';

  @override
  String get joinTeam => 'Unirse a un equipo';

  @override
  String get organizationName => 'Nombre de la organización';

  @override
  String get brandNameOptional => 'Nombre comercial (opcional)';

  @override
  String get branchNameOptional => 'Nombre del local (opcional)';

  @override
  String get country => 'País';

  @override
  String get currency => 'Moneda';

  @override
  String get timezone => 'Zona horaria';

  @override
  String get defaultLanguage => 'Idioma principal';

  @override
  String get city => 'Ciudad';

  @override
  String get create => 'Crear';

  @override
  String get invitationCode => 'Código de invitación';

  @override
  String get join => 'Unirse';

  @override
  String get navBranches => 'Locales';

  @override
  String get navTeam => 'Equipo';

  @override
  String get navAudit => 'Registro';

  @override
  String get navAccount => 'Cuenta';

  @override
  String get switchOrganization => 'Cambiar de organización';

  @override
  String get orgSuspended => 'Organización suspendida: solo consulta.';

  @override
  String get newBranch => 'Nuevo local';

  @override
  String get noBranches => 'Ningún local.';

  @override
  String get branchInfo => 'Información';

  @override
  String get openingHours => 'Horario';

  @override
  String get floor => 'Sala';

  @override
  String get name => 'Nombre';

  @override
  String get addressLine1 => 'Dirección';

  @override
  String get addressLine2 => 'Complemento de dirección';

  @override
  String get region => 'Región';

  @override
  String get postalCode => 'Código postal';

  @override
  String get phone => 'Teléfono';

  @override
  String get offeredLanguages => 'Idiomas ofrecidos';

  @override
  String get published => 'Visible para los clientes';

  @override
  String get archived => 'Archivado';

  @override
  String get readOnly => 'Solo consulta';

  @override
  String get save => 'Guardar';

  @override
  String get saved => 'Guardado.';

  @override
  String get cancel => 'Cancelar';

  @override
  String get confirm => 'Confirmar';

  @override
  String get close => 'Cerrar';

  @override
  String get edit => 'Modificar';

  @override
  String get retry => 'Reintentar';

  @override
  String get closed => 'Cerrado';

  @override
  String get addSlot => 'Añadir una franja';

  @override
  String get opensAt => 'Apertura';

  @override
  String get closesAt => 'Cierre';

  @override
  String get nextDay => 'día siguiente';

  @override
  String get weekday1 => 'Lunes';

  @override
  String get weekday2 => 'Martes';

  @override
  String get weekday3 => 'Miércoles';

  @override
  String get weekday4 => 'Jueves';

  @override
  String get weekday5 => 'Viernes';

  @override
  String get weekday6 => 'Sábado';

  @override
  String get weekday7 => 'Domingo';

  @override
  String get newArea => 'Nueva zona';

  @override
  String get areaName => 'Zona';

  @override
  String get noAreas => 'Todavía no hay zonas.';

  @override
  String get newTable => 'Nueva mesa';

  @override
  String get tableLabel => 'Nombre de la mesa';

  @override
  String get seats => 'Plazas';

  @override
  String get active => 'Activo';

  @override
  String get inactive => 'desactivado';

  @override
  String tablesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mesas',
      one: '1 mesa',
      zero: 'ninguna mesa',
    );
    return '$_temp0';
  }

  @override
  String seatsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count plazas',
      one: '1 plaza',
    );
    return '$_temp0';
  }

  @override
  String get invite => 'Invitar';

  @override
  String get role => 'Rol';

  @override
  String get allBranches => 'Todos los locales';

  @override
  String get pendingInvitations => 'Invitaciones pendientes';

  @override
  String expiresOn(String date) {
    return 'Caduca el $date';
  }

  @override
  String get revoke => 'Retirar';

  @override
  String revokeConfirm(String name) {
    return '¿Retirar a $name de la organización?';
  }

  @override
  String get changeRole => 'Cambiar el rol';

  @override
  String get you => 'usted';

  @override
  String get invitationCreatedTitle => 'Invitación creada';

  @override
  String invitationCreatedBody(String email) {
    return 'Envíe este código a $email. Es válido 7 días y solo funciona con esta dirección.';
  }

  @override
  String invitationMessage(String organization, String code) {
    return 'Está invitado/a a unirse a «$organization» en Resto. Cree su cuenta con esta dirección de correo y después introduzca este código en «Unirse a un equipo»: $code';
  }

  @override
  String get copyMessage => 'Copiar el mensaje';

  @override
  String get copied => 'Copiado.';

  @override
  String get roleOwner => 'Propietario';

  @override
  String get roleAdmin => 'Administrador';

  @override
  String get roleManager => 'Responsable';

  @override
  String get roleAccountant => 'Contable';

  @override
  String get roleCashier => 'Cajero';

  @override
  String get roleStockKeeper => 'Almacenero';

  @override
  String get roleWaiter => 'Camarero';

  @override
  String get roleKitchen => 'Cocina / bar';

  @override
  String get roleViewer => 'Lector';

  @override
  String get loadMore => 'Mostrar más';

  @override
  String get noEntries => 'Ninguna operación registrada.';

  @override
  String get actionInsert => 'Creación';

  @override
  String get actionUpdate => 'Modificación';

  @override
  String get actionDelete => 'Eliminación';

  @override
  String get entityOrganization => 'Organización';

  @override
  String get entityMembership => 'Miembro';

  @override
  String get entityInvitation => 'Invitación';

  @override
  String get entityBrand => 'Marca';

  @override
  String get entityBranch => 'Local';

  @override
  String get entityArea => 'Zona';

  @override
  String get entityTable => 'Mesa';

  @override
  String get navMenus => 'Menús';

  @override
  String get brand => 'Marca';

  @override
  String get category => 'Categoría';

  @override
  String get description => 'Descripción';

  @override
  String get newCategory => 'Nueva categoría';

  @override
  String get kindFood => 'Plato';

  @override
  String get kindDrink => 'Bebida';

  @override
  String get kindOther => 'Otro';

  @override
  String selectionRule(int min, String max) {
    return 'Elección: de $min a $max';
  }

  @override
  String get allergens => 'Alérgenos';

  @override
  String get allergenGluten => 'Gluten';

  @override
  String get allergenCrustaceans => 'Crustáceos';

  @override
  String get allergenEggs => 'Huevos';

  @override
  String get allergenFish => 'Pescado';

  @override
  String get allergenPeanuts => 'Cacahuetes';

  @override
  String get allergenSoybeans => 'Soja';

  @override
  String get allergenMilk => 'Leche';

  @override
  String get allergenNuts => 'Frutos de cáscara';

  @override
  String get allergenCelery => 'Apio';

  @override
  String get allergenMustard => 'Mostaza';

  @override
  String get allergenSesame => 'Sésamo';

  @override
  String get allergenSulphites => 'Sulfitos';

  @override
  String get allergenLupin => 'Altramuces';

  @override
  String get allergenMolluscs => 'Moluscos';

  @override
  String get translations => 'Traducciones';

  @override
  String get soldOut => 'Agotado';

  @override
  String get channelDefault => 'Precio base';

  @override
  String get channelDineIn => 'En el local';

  @override
  String get channelTakeaway => 'Para llevar';

  @override
  String get channelDelivery => 'A domicilio';

  @override
  String get otherChannels => 'Precios por canal';

  @override
  String get noPrice => 'Sin precio';

  @override
  String get errorInvalidPrice => 'Precio no válido.';

  @override
  String get errorCurrencyLocked =>
      'La moneda ya no puede cambiar: ya existen precios en este local.';

  @override
  String get entityItem => 'Artículo';

  @override
  String get entityVariant => 'Variante';

  @override
  String get entityModifier => 'Extra';

  @override
  String get entityPrice => 'Precio';

  @override
  String get menuOfBranch => 'Menú del local';

  @override
  String get menuEmptyTitle => 'Su menú está vacío';

  @override
  String get menuEmptyHint =>
      'Empiece creando una categoría (por ejemplo Platos, Bebidas, Postres) y luego añada sus artículos con su precio.';

  @override
  String get categoryExamples => 'Ej.: Platos, Bebidas, Postres';

  @override
  String get descriptionOptional => 'Descripción (opcional)';

  @override
  String get visibleOnMenu => 'Visible en la carta';

  @override
  String get hidden => 'oculto';

  @override
  String get addItem => 'Añadir un artículo';

  @override
  String addItemIn(String category) {
    return 'Añadir un artículo en «$category»';
  }

  @override
  String get notSoldHere => 'No se vende en este local';

  @override
  String get itemName => 'Nombre del artículo';

  @override
  String get itemExamples => 'Ej.: Ndolé, Pollo DG, Zumo de bissap';

  @override
  String get priceTitle => 'Precio';

  @override
  String priceAt(String branch) {
    return 'Precio en $branch';
  }

  @override
  String get price => 'Precio';

  @override
  String get severalSizes =>
      'Este artículo existe en varios tamaños o formatos';

  @override
  String get sizeName => 'Tamaño / formato';

  @override
  String get sizeExamples => 'Ej.: Pequeña, 33 cl';

  @override
  String get addSize => 'Añadir un tamaño';

  @override
  String get removeSize => 'Quitar este tamaño';

  @override
  String get sizeNameRequired =>
      'Dé un nombre a cada tamaño (por ejemplo Pequeña, Grande).';

  @override
  String get samePriceEverywhere =>
      'Este precio se aplicará en todos los locales elegidos abajo; podrá ajustarlo después en cada uno.';

  @override
  String get salesTitle => 'Venta';

  @override
  String soldAt(String branch) {
    return 'Se vende en $branch';
  }

  @override
  String get soldOutToday => 'Agotado por ahora';

  @override
  String get optionsForItem => 'Opciones ofrecidas al cliente';

  @override
  String get manageOptions => 'Gestionar las opciones';

  @override
  String get noOptionsYet =>
      'Todavía no hay opciones (guarnición, cocción, salsa…).';

  @override
  String get optionsTitle => 'Opciones y extras';

  @override
  String get optionsIntro =>
      'Una opción es una elección que el cliente hace al pedir un artículo: guarnición, cocción, una salsa, un extra de pago…';

  @override
  String get newOptionGroup => 'Nueva opción';

  @override
  String get optionGroupName => 'Nombre de la opción';

  @override
  String get optionGroupExamples => 'Ej.: Guarnición, Cocción, Picante';

  @override
  String get customerMust => 'El cliente:';

  @override
  String get ruleRequiredOne => 'debe hacer 1 elección (obligatoria)';

  @override
  String get ruleOptionalOne => 'puede hacer 1 elección (opcional)';

  @override
  String get ruleOptionalMany => 'puede hacer varias elecciones (opcional)';

  @override
  String get ruleRequiredMany =>
      'debe hacer al menos 1 elección, varias posibles';

  @override
  String get choices => 'Elecciones ofrecidas';

  @override
  String choicePriceHint(String branch) {
    return 'Deje el precio vacío o en 0 si la elección es gratuita. Precio para $branch.';
  }

  @override
  String get choiceName => 'Elección';

  @override
  String get choiceExamples => 'Ej.: Miondo, Arroz';

  @override
  String get extraPrice => 'Precio adicional';

  @override
  String get addChoice => 'Añadir una elección';

  @override
  String get removeChoice => 'Quitar esta elección';

  @override
  String get choicesRequired => 'Añada al menos una elección.';

  @override
  String get navOrders => 'Pedidos';

  @override
  String openOrdersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pedidos en curso',
      one: '1 pedido en curso',
      zero: 'Ningún pedido en curso',
    );
    return '$_temp0';
  }

  @override
  String get refresh => 'Actualizar';

  @override
  String get newTakeaway => 'Venta para llevar';

  @override
  String get takeawayOrders => 'Para llevar en curso';

  @override
  String orderNumber(int number) {
    return 'Pedido n.º $number';
  }

  @override
  String minutesAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'hace $count min',
      one: 'hace 1 min',
      zero: 'ahora mismo',
    );
    return '$_temp0';
  }

  @override
  String get noTablesYet =>
      'No hay mesas: cree la sala en Locales → Sala. Las ventas para llevar siguen siendo posibles.';

  @override
  String get tableFree => 'Libre';

  @override
  String get toSend => 'Artículos por enviar a cocina';

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
  String get allCategories => 'Todo';

  @override
  String get nothingToSell =>
      'Todavía no hay nada que vender: añada artículos con precio en Menús.';

  @override
  String fromPrice(String price) {
    return 'desde $price';
  }

  @override
  String itemSoldOut(String name) {
    return '$name está agotado.';
  }

  @override
  String get emptyTicket => 'Toque un artículo de la carta para añadirlo.';

  @override
  String get less => 'Uno menos';

  @override
  String get more => 'Uno más';

  @override
  String get cancelLine => 'Anular esta línea';

  @override
  String get cancelOrder => 'Anular el pedido';

  @override
  String get cancelOrderConfirm =>
      '¿Anular este pedido? Todavía no se ha enviado nada a cocina.';

  @override
  String get reason => 'Motivo';

  @override
  String get subtotal => 'Subtotal';

  @override
  String taxLine(String rate) {
    return 'Impuesto ($rate %)';
  }

  @override
  String get total => 'Total';

  @override
  String taxIncluded(String rate, String amount) {
    return 'impuesto $rate % incluido: $amount';
  }

  @override
  String sendToKitchen(int count) {
    return 'Enviar a cocina ($count)';
  }

  @override
  String sentToKitchen(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count artículos enviados a cocina',
      one: '1 artículo enviado a cocina',
    );
    return '$_temp0';
  }

  @override
  String get prepPending => 'Por enviar';

  @override
  String get prepSent => 'En cocina';

  @override
  String get prepPreparing => 'En preparación';

  @override
  String get prepReady => 'Listo';

  @override
  String get prepServed => 'Servido';

  @override
  String get prepCancelled => 'Anulado';

  @override
  String get noneOption => 'Ninguno';

  @override
  String get kitchenNote => 'Nota para la cocina (opcional)';

  @override
  String get kitchenNoteExamples => 'Ej.: sin cebolla, muy hecho';

  @override
  String get quantity => 'Cantidad';

  @override
  String addForPrice(String price) {
    return 'Añadir · $price';
  }

  @override
  String get taxTitle => 'Impuesto';

  @override
  String get taxRate => 'Tipo impositivo';

  @override
  String get taxRateHint => 'Ej.: 19,25 (0 si no hay impuesto)';

  @override
  String get pricesIncludeTax => 'Los precios mostrados incluyen el impuesto';

  @override
  String get errorInvalidTaxRate => 'Tipo no válido (de 0 a 99,999).';

  @override
  String get errorOrderNotOpen => 'Este pedido ya no está abierto.';

  @override
  String get errorItemUnavailable =>
      'Este artículo no está disponible en este local.';

  @override
  String get errorNoPrice => 'Este artículo no tiene precio en este local.';

  @override
  String get errorOptionsInvalid =>
      'Las opciones elegidas no respetan las reglas del artículo.';

  @override
  String get errorInvalidQuantity => 'Cantidad no válida.';

  @override
  String get errorItemAlreadySent =>
      'Esta línea ya está en cocina y no se puede modificar.';

  @override
  String get errorReasonRequired => 'Indique un motivo.';

  @override
  String get errorInvalidOrder => 'Pedido no válido.';

  @override
  String get errorBranchInactive => 'Este local está archivado.';

  @override
  String get navCash => 'Caja';

  @override
  String get amount => 'Importe';

  @override
  String get registerClosed => 'cerrada';

  @override
  String get openRegisterShort => 'Abrir la caja';

  @override
  String openRegister(String name) {
    return 'Abrir $name';
  }

  @override
  String get openingFloat => 'Fondo de caja (cambio inicial)';

  @override
  String registerOpenSince(String time) {
    return 'abierta desde las $time';
  }

  @override
  String expectedCash(String amount) {
    return 'Efectivo esperado: $amount';
  }

  @override
  String cashBreakdown(String float, String inAmount, String outAmount) {
    return 'Fondo $float · entradas $inAmount · salidas $outAmount';
  }

  @override
  String paymentsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pagos',
      one: '1 pago',
      zero: 'ningún pago',
    );
    return '$_temp0';
  }

  @override
  String get cashIn => 'Entrada de dinero';

  @override
  String get cashOut => 'Salida de dinero';

  @override
  String get movementExamples => 'Ej.: compra de gas, aporte de cambio';

  @override
  String get closeRegister => 'Cerrar la caja';

  @override
  String get countedCash => 'Efectivo contado en el cajón';

  @override
  String get countInfo =>
      'Cuente billetes y monedas del cajón, fondo incluido.';

  @override
  String get countResult => 'Resultado del recuento';

  @override
  String countedCashValue(String amount) {
    return 'Contado: $amount';
  }

  @override
  String get noDifference => 'Sin diferencia';

  @override
  String differenceValue(String amount) {
    return 'Diferencia: $amount';
  }

  @override
  String get awaitingValidation =>
      'Un responsable debe validar ahora este cierre.';

  @override
  String get awaitingValidationTitle => 'Cierres por validar';

  @override
  String get validateClosing => 'Validar el cierre';

  @override
  String get validate => 'Validar';

  @override
  String get comment => 'Comentario';

  @override
  String get closedSessions => 'Últimos cierres';

  @override
  String get dailyReport => 'Informe del día';

  @override
  String get previousDay => 'Día anterior';

  @override
  String get nextDayButton => 'Día siguiente';

  @override
  String get salesTotal => 'Ventas';

  @override
  String get ordersClosedCount => 'Pedidos pagados';

  @override
  String get averageTicket => 'Ticket medio';

  @override
  String get taxCollected => 'Impuesto recaudado';

  @override
  String get paymentsReceived => 'Cobros por medio de pago';

  @override
  String ordersStillOpen(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pedidos aún en curso',
      one: '1 pedido aún en curso',
      zero: 'ningún pedido en curso',
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
      zero: 'ninguno anulado',
    );
    return '$_temp0';
  }

  @override
  String linesCancelledCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count líneas anuladas',
      one: '1 línea anulada',
      zero: 'ninguna línea anulada',
    );
    return '$_temp0';
  }

  @override
  String refundsTotal(String amount) {
    return 'reembolsado: $amount';
  }

  @override
  String get topItems => 'Artículos más vendidos';

  @override
  String get payCash => 'Efectivo';

  @override
  String get payCard => 'Tarjeta';

  @override
  String get payMobileMoney => 'Mobile Money';

  @override
  String get payTransfer => 'Transferencia';

  @override
  String get payOther => 'Otro';

  @override
  String get collectPayment => 'Cobrar';

  @override
  String collectAmount(String amount) {
    return 'Cobrar $amount';
  }

  @override
  String amountDue(String amount) {
    return 'Pendiente de pago: $amount';
  }

  @override
  String get splitBill => 'Dividir la cuenta';

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
  String get amountToCollect => 'Importe cobrado';

  @override
  String get cashTendered => 'Dinero entregado por el cliente (opcional)';

  @override
  String changeToGive(String amount) {
    return 'Cambio: $amount';
  }

  @override
  String get giveChange => 'Cambio a devolver';

  @override
  String get transactionReference => 'N.º de transacción (opcional)';

  @override
  String get manualPaymentNote =>
      'Tarjeta y Mobile Money: compruebe que el pago se ha recibido antes de validar.';

  @override
  String get openCashFirst => 'Abra primero la caja (sección Caja).';

  @override
  String get chooseRegister => 'Elegir la caja';

  @override
  String get orderPaidClosed => 'Pedido pagado y cerrado.';

  @override
  String get paid => 'Ya pagado';

  @override
  String get remainingDue => 'Pendiente de pago';

  @override
  String get voided => 'anulado';

  @override
  String get voidPayment => 'Anular este pago';

  @override
  String get orderClosed => 'Pedido pagado y cerrado';

  @override
  String get orderCancelled => 'Pedido anulado';

  @override
  String get errorNoOpenSession =>
      'No hay ninguna caja abierta para este cobro.';

  @override
  String get errorSessionAlreadyOpen => 'Esta caja ya está abierta.';

  @override
  String get errorRegisterInactive => 'Esta caja está desactivada.';

  @override
  String get errorInvalidAmount => 'Importe no válido.';

  @override
  String get errorNotEnoughCash => 'No hay suficiente efectivo en la caja.';

  @override
  String get errorOverpayment => 'El importe supera lo pendiente de pago.';

  @override
  String get errorTenderedTooLow =>
      'El dinero entregado es inferior al importe.';

  @override
  String get errorOrderHasPayments =>
      'Este pedido ya tiene pagos: anúlelos o reembólselos primero.';

  @override
  String get errorPendingLines =>
      'Algunos artículos aún no se han enviado a cocina.';

  @override
  String get errorNotFullyPaid => 'El pedido no está totalmente pagado.';

  @override
  String get errorSessionNotCounted => 'Esta caja aún no se ha contado.';

  @override
  String get navKitchen => 'Cocina';

  @override
  String get allStations => 'Todos los puestos';

  @override
  String get stations => 'Puestos de preparación';

  @override
  String get newStation => 'Nuevo puesto';

  @override
  String get stationExamples => 'Ej.: Cocina, Bar, Parrilla';

  @override
  String get stationPrepares => 'Este puesto prepara:';

  @override
  String get kitchenEmpty => 'Nada que preparar por ahora.';

  @override
  String get allReady => 'Todo listo';

  @override
  String get markServed => 'Servido';

  @override
  String get errorInvalidStatus => 'Este cambio de estado no es posible.';

  @override
  String get navStock => 'Existencias';

  @override
  String get stockLevels => 'Estado de existencias';

  @override
  String get ingredientsTab => 'Ingredientes';

  @override
  String get recipesTab => 'Fichas técnicas';

  @override
  String get inventoriesTab => 'Inventarios';

  @override
  String get movementsTab => 'Movimientos';

  @override
  String stockValue(String amount) {
    return 'Valor de las existencias: $amount';
  }

  @override
  String lowStockCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ingredientes bajo el umbral',
      one: '1 ingrediente bajo el umbral',
    );
    return '$_temp0';
  }

  @override
  String actionsAt(String location) {
    return 'Movimientos en: $location';
  }

  @override
  String get newLocation => 'Nuevo almacén';

  @override
  String get locationExamples => 'Ej.: Cámara frigorífica, Bodega, Cocina';

  @override
  String get chooseLocation => 'Elegir el almacén';

  @override
  String get toLocation => 'Hacia el almacén';

  @override
  String get noIngredientsYet =>
      'Todavía no hay ingredientes: añádalos en la pestaña Ingredientes.';

  @override
  String alertAt(String qty) {
    return 'alerta en $qty';
  }

  @override
  String avgCost(String amount, String unit) {
    return 'coste medio $amount / $unit';
  }

  @override
  String get alertThreshold => 'Umbral de alerta';

  @override
  String get alertBelow => 'Alertar por debajo de';

  @override
  String get produce => 'Producir';

  @override
  String get adjustmentQuantity => 'Corrección (+ o −)';

  @override
  String unitCost(String unit) {
    return 'Coste por $unit';
  }

  @override
  String get unitPiece => 'unidad';

  @override
  String get unitDozen => 'docena';

  @override
  String get newIngredient => 'Nuevo ingrediente';

  @override
  String get ingredientExamples =>
      'Ej.: Pollo, Aceite de palma, Botella de Coca 33 cl';

  @override
  String get ingredientKind => 'Tipo';

  @override
  String get stockUnit => 'Unidad de existencias';

  @override
  String get ingRaw => 'Materia prima';

  @override
  String get ingBeverage => 'Bebida';

  @override
  String get ingPackaging => 'Envase';

  @override
  String get ingSemiFinished => 'Preparación casera';

  @override
  String get ingConsumable => 'Consumible';

  @override
  String get mvOpening => 'Existencias iniciales';

  @override
  String get mvReceipt => 'Entrada (compra)';

  @override
  String get mvSale => 'Venta';

  @override
  String get mvProductionIn => 'Producción';

  @override
  String get mvProductionOut => 'Usado en producción';

  @override
  String get mvWaste => 'Pérdida / rotura';

  @override
  String get mvStaffMeal => 'Comida del personal';

  @override
  String get mvReturn => 'Devolución al proveedor';

  @override
  String get mvTransferIn => 'Traspaso recibido';

  @override
  String get mvTransferOut => 'Traspaso';

  @override
  String get mvAdjustment => 'Ajuste';

  @override
  String get mvInventory => 'Diferencia de inventario';

  @override
  String get recipesIntro =>
      'Una ficha técnica indica los ingredientes de un plato: las existencias bajan automáticamente con cada venta pagada y se calcula el coste.';

  @override
  String get noRecipe => 'Sin ficha';

  @override
  String costPrice(String amount) {
    return 'Coste: $amount';
  }

  @override
  String sellingPrice(String amount) {
    return 'precio $amount';
  }

  @override
  String marginPercent(int percent) {
    return 'margen $percent %';
  }

  @override
  String recipeOf(String name) {
    return 'Ficha: $name';
  }

  @override
  String get portions => 'Número de raciones';

  @override
  String get yieldQuantity => 'Cantidad obtenida';

  @override
  String get ingredient => 'Ingrediente';

  @override
  String get wastePercent => 'Merma';

  @override
  String get removeLine => 'Quitar la línea';

  @override
  String get addIngredientLine => 'Añadir un ingrediente';

  @override
  String get preparationNotes => 'Notas de preparación (opcional)';

  @override
  String get newInventory => 'Nuevo inventario';

  @override
  String get inventoriesIntro =>
      'Un inventario compara las existencias contadas con las calculadas; las diferencias se registran tras la validación de un responsable.';

  @override
  String inventoryValidated(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'validado, $count diferencias',
      one: 'validado, 1 diferencia',
      zero: 'validado, sin diferencias',
    );
    return '$_temp0';
  }

  @override
  String inventoryDraft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'en curso, $count líneas contadas',
      one: 'en curso, 1 línea contada',
      zero: 'en curso, nada contado',
    );
    return '$_temp0';
  }

  @override
  String inventoryOf(String location) {
    return 'Inventario: $location';
  }

  @override
  String get inventoryHint =>
      'Introduzca lo que cuenta realmente. Las líneas vacías no se modifican.';

  @override
  String inventoryDifference(String qty) {
    return 'diferencia $qty';
  }

  @override
  String get search => 'Buscar';

  @override
  String get validateInventory => 'Validar el inventario';

  @override
  String get validateInventoryConfirm =>
      '¿Validar este inventario? Las diferencias se registrarán en las existencias y el inventario ya no podrá modificarse.';

  @override
  String inventoryAdjustments(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Inventario validado: $count diferencias registradas',
      one: 'Inventario validado: 1 diferencia registrada',
      zero: 'Inventario validado: sin diferencias',
    );
    return '$_temp0';
  }

  @override
  String get errorInvalidMovement => 'Movimiento de existencias no válido.';

  @override
  String get errorUnitLocked =>
      'La unidad ya no puede cambiar: este ingrediente ya tiene movimientos.';

  @override
  String get errorNoRecipe => 'Esta preparación no tiene ficha técnica.';

  @override
  String get errorInvalidRecipe =>
      'Ficha técnica no válida: compruebe ingredientes, cantidades y unidades.';

  @override
  String get errorInventoryClosed => 'Este inventario ya está validado.';

  @override
  String get navGroupService => 'Servicio';

  @override
  String get navGroupManagement => 'Gestión';

  @override
  String get navGroupOrganization => 'Organización';

  @override
  String get navPurchases => 'Compras';

  @override
  String get navExpenses => 'Gastos';

  @override
  String get navReports => 'Informes';

  @override
  String get invoicesTab => 'Facturas';

  @override
  String get purchaseOrdersTab => 'Pedidos de compra';

  @override
  String get receiptsTab => 'Recepciones';

  @override
  String get suppliersTab => 'Proveedores';

  @override
  String get newSupplier => 'Nuevo proveedor';

  @override
  String get noSuppliersYet =>
      'Todavía no hay proveedores. Añada sus proveedores habituales (mercado, mayorista, cervecera…).';

  @override
  String get addSupplierFirst =>
      'Añada primero un proveedor (pestaña Proveedores).';

  @override
  String get contactName => 'Persona de contacto';

  @override
  String get taxId => 'N.º de identificación fiscal';

  @override
  String get paymentTermsLabel => 'Plazo de pago';

  @override
  String get days => 'días';

  @override
  String paymentTerms(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'pago a $days días',
      one: 'pago a 1 día',
    );
    return '$_temp0';
  }

  @override
  String get supplier => 'Proveedor';

  @override
  String get supplierOptional => 'Proveedor (opcional)';

  @override
  String get newPurchaseOrder => 'Nuevo pedido de compra';

  @override
  String get noPurchaseOrders =>
      'Ningún pedido de compra. Un pedido prepara una compra; a la entrega, «Recibir» da entrada a la mercancía.';

  @override
  String poNumber(int number) {
    return 'Pedido n.º $number';
  }

  @override
  String get poDraft => 'borrador';

  @override
  String get poSent => 'enviado';

  @override
  String get poPartial => 'recibido en parte';

  @override
  String get poReceived => 'recibido';

  @override
  String get poCancelled => 'anulado';

  @override
  String get poMarkSent => 'Marcar como enviado';

  @override
  String get poReceive => 'Recibir';

  @override
  String get poCancel => 'Anular el pedido';

  @override
  String get cancelPoConfirm => '¿Anular este pedido de compra?';

  @override
  String expectedOn(String date) {
    return 'entrega prevista el $date';
  }

  @override
  String get expectedDateOptional => 'Fecha de entrega prevista (opcional)';

  @override
  String unitPrice(String unit) {
    return 'Precio por $unit';
  }

  @override
  String totalAmount(String amount) {
    return 'Total: $amount';
  }

  @override
  String get newReceipt => 'Nueva recepción';

  @override
  String get receiptsIntro =>
      'Una recepción registra la mercancía entregada: las existencias y el coste medio se actualizan automáticamente.';

  @override
  String receiveOrder(int number) {
    return 'Recepción del pedido n.º $number';
  }

  @override
  String get receiptHint =>
      'Indique las cantidades realmente entregadas y su precio; entran en existencias al guardar.';

  @override
  String get deliveryNoteNumber => 'N.º del albarán (opcional)';

  @override
  String get recordReceipt => 'Registrar la recepción';

  @override
  String get receiptRecorded =>
      'Recepción registrada: las existencias están al día.';

  @override
  String get newInvoice => 'Nueva factura';

  @override
  String get invoicesIntro =>
      'Registre aquí las facturas de sus proveedores para seguir lo que les debe y sus pagos.';

  @override
  String supplierDebt(String amount) {
    return 'Total adeudado a proveedores: $amount';
  }

  @override
  String dueOn(String date) {
    return 'vence el $date';
  }

  @override
  String remaining(String amount) {
    return 'quedan $amount';
  }

  @override
  String get invoicePaid => 'pagada';

  @override
  String get invoiceCancelled => 'anulada';

  @override
  String get invoiceNumber => 'N.º de factura del proveedor';

  @override
  String invoiceDateValue(String date) {
    return 'Factura del $date';
  }

  @override
  String get dueDateOptional => 'Vencimiento (opcional: plazo del proveedor)';

  @override
  String get amountExclTax => 'Importe sin impuestos';

  @override
  String get taxAmount => 'Impuesto';

  @override
  String get linkedReceipts => 'Recepciones relacionadas';

  @override
  String get attachDocument => 'Adjuntar un justificante (PDF o foto)';

  @override
  String get fileTooLarge => 'Archivo demasiado grande (5 MB como máximo).';

  @override
  String get viewDocument => 'Ver el justificante';

  @override
  String get payInvoice => 'Pagar';

  @override
  String get cancelInvoice => 'Anular la factura';

  @override
  String get paidFromRegister => 'Pagado con el dinero de la caja';

  @override
  String get newExpense => 'Nuevo gasto';

  @override
  String get noExpenses => 'Ningún gasto este mes.';

  @override
  String get previousMonth => 'Mes anterior';

  @override
  String get nextMonth => 'Mes siguiente';

  @override
  String includingTax(String amount) {
    return 'impuesto incluido $amount';
  }

  @override
  String get cancelledLabel => 'anulado';

  @override
  String get cancelExpense => 'Anular el gasto';

  @override
  String get expenseExamples =>
      'Ej.: factura de luz de octubre, reparación del congelador';

  @override
  String get amountInclTax => 'Importe pagado';

  @override
  String get includedTaxOptional => 'Del cual impuesto (opcional)';

  @override
  String get expRent => 'Alquiler';

  @override
  String get expElectricity => 'Electricidad';

  @override
  String get expWater => 'Agua';

  @override
  String get expGas => 'Gas';

  @override
  String get expSalaries => 'Salarios';

  @override
  String get expTransport => 'Transporte';

  @override
  String get expMaintenance => 'Mantenimiento y reparaciones';

  @override
  String get expMarketing => 'Publicidad';

  @override
  String get expSupplies => 'Suministros';

  @override
  String get expTaxes => 'Impuestos y tasas';

  @override
  String get expBankFees => 'Comisiones bancarias';

  @override
  String get expOther => 'Otros';

  @override
  String get periodToday => 'Hoy';

  @override
  String get periodLast7 => 'Últimos 7 días';

  @override
  String get periodMonth => 'Este mes';

  @override
  String get periodLastMonth => 'Mes pasado';

  @override
  String get periodCustom => 'Otro periodo…';

  @override
  String get salesInclTax => 'Ventas con impuestos';

  @override
  String get salesExclTax => 'Ventas sin impuestos';

  @override
  String get collected => 'Cobros';

  @override
  String get costOfSales => 'Coste de las ventas';

  @override
  String get grossMargin => 'Margen bruto';

  @override
  String get lossesValue => 'Pérdidas y diferencias';

  @override
  String get expensesExclTax => 'Gastos sin impuestos';

  @override
  String get estimatedResult => 'Resultado estimado';

  @override
  String get purchasesValue => 'Compras (facturas sin impuestos)';

  @override
  String get supplierDebtShort => 'Adeudado a proveedores';

  @override
  String ordersCountShort(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pedidos',
      one: '1 pedido',
      zero: 'ningún pedido',
    );
    return '$_temp0';
  }

  @override
  String get ruleSales =>
      'Total de los pedidos pagados y cerrados en el periodo (fecha de servicio).';

  @override
  String get ruleSalesHt => 'Ventas con impuestos menos el impuesto recaudado.';

  @override
  String get ruleCollected =>
      'Dinero realmente cobrado en el periodo, todos los medios, menos los reembolsos. Puede diferir de las ventas (anticipos, pedidos abiertos).';

  @override
  String get ruleCogs =>
      'Valor de los ingredientes consumidos por las ventas, según las fichas técnicas y el coste medio de compra. Los platos sin ficha no se incluyen.';

  @override
  String get ruleGrossMargin =>
      'Ventas sin impuestos menos el coste de las ventas.';

  @override
  String get ruleLosses =>
      'Valor de pérdidas, comidas del personal, ajustes y diferencias de inventario.';

  @override
  String get ruleExpenses =>
      'Gastos registrados en el periodo, sin impuestos (gastos anulados excluidos).';

  @override
  String get ruleResult =>
      'Margen bruto menos pérdidas y gastos. Estimación de gestión, sin amortizaciones ni gastos no registrados: no es un resultado contable.';

  @override
  String get rulePurchases =>
      'Facturas de proveedores (sin impuestos) fechadas en el periodo. Las compras entran en existencias: no son un gasto hasta que se consumen.';

  @override
  String get ruleDebt =>
      'Importe pendiente de las facturas de proveedores abiertas, a fecha de hoy.';

  @override
  String get expensesByCategory => 'Gastos por categoría (sin impuestos)';

  @override
  String get resultDisclaimer =>
      'Estas cifras se calculan a partir de las operaciones registradas en Resto: ventas, cobros, consumos teóricos, gastos. Pase el ratón por ⓘ para ver la regla de cada indicador.';

  @override
  String get exportsTitle => 'Exportaciones (archivos CSV, se abren en Excel)';

  @override
  String get exportOrders => 'Pedidos';

  @override
  String get exportPayments => 'Pagos';

  @override
  String get exportExpenses => 'Gastos';

  @override
  String get exportDownloaded => 'Archivo descargado.';

  @override
  String get exportCopied => 'Datos copiados: péguelos en una hoja de cálculo.';

  @override
  String get marginsByItem => 'Margen por plato';

  @override
  String marginsHint(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count platos aún no tienen ficha técnica (Existencias → Fichas técnicas).',
      one:
          '1 plato aún no tiene ficha técnica (Existencias → Fichas técnicas).',
      zero: 'Todos los platos vendidos tienen ficha técnica.',
    );
    return '$_temp0';
  }

  @override
  String get errorInvalidPurchase =>
      'Compra incompleta: compruebe proveedor, ingredientes, cantidades, unidades y precios.';

  @override
  String get errorPurchaseNotDraft =>
      'Este pedido de compra ya no se puede modificar.';

  @override
  String get errorDuplicateInvoice =>
      'Esta factura de este proveedor ya está registrada.';

  @override
  String get errorInvoiceNotOpen => 'Esta factura ya no está abierta.';

  @override
  String get errorInvoiceHasPayments =>
      'Esta factura tiene pagos: anúlelos primero.';

  @override
  String get errorInvalidExpense =>
      'Gasto incompleto: categoría, descripción e importe son obligatorios; el impuesto no puede superar el importe.';

  @override
  String get errorInvalidAttachment => 'Justificante rechazado.';

  @override
  String get errorInvalidPeriod => 'Periodo no válido.';

  @override
  String get errorBelowMinimum => 'No se alcanza el importe mínimo del pedido.';

  @override
  String get errorDeliveryUnavailable =>
      'Entrega imposible: compruebe la dirección y el teléfono, o elija «Para llevar».';

  @override
  String get errorInvalidImage =>
      'Foto rechazada (formato o ubicación no válidos).';

  @override
  String get errorNotFound => 'No encontrado.';

  @override
  String get errorOnlineOrdersClosed =>
      'Este restaurante no acepta pedidos en línea en este momento.';

  @override
  String get errorTooLateToCancel =>
      'Demasiado tarde: el restaurante ya se ha hecho cargo del pedido.';

  @override
  String get errorReviewNotAllowed =>
      'Reseña imposible: solo un pedido pagado, de menos de 30 días, puede valorarse una vez.';

  @override
  String get errorReservationsClosed =>
      'Este restaurante no acepta reservas en línea.';

  @override
  String get errorInvalidPartySize =>
      'Número de personas no aceptado para una reserva en línea.';

  @override
  String get errorInvalidReservationTime =>
      'Hora no válida: al menos 15 minutos de antelación y como máximo 90 días.';

  @override
  String get errorInvalidReservation =>
      'Reserva incompleta: se necesitan nombre, teléfono y número de personas.';

  @override
  String get errorTablesRequired => 'Elija al menos una mesa.';

  @override
  String get errorNotEnoughSeats =>
      'No hay suficientes plazas en las mesas elegidas.';

  @override
  String get errorTableUnavailable =>
      'Esta mesa ya está reservada en esa franja.';

  @override
  String get errorPromotionUnavailable => 'Promoción o código no válido.';

  @override
  String get errorPromotionLimit =>
      'Este cliente ya ha usado esta promoción el número de veces permitido.';

  @override
  String get errorPromotionAlreadyApplied => 'Ya aplicada a este pedido.';

  @override
  String get errorNotEnoughPoints => 'Puntos de fidelidad insuficientes.';

  @override
  String get errorAddressRequired => 'Dirección de entrega obligatoria.';

  @override
  String get errorTableBusy => 'Esta mesa ya tiene un pedido en curso.';

  @override
  String errorBetween(int min, int max) {
    return 'Entre $min y $max';
  }

  @override
  String get notPublishedHint =>
      'Este local aún no es visible para los clientes: active «Publicado» en la pestaña Información.';

  @override
  String get onlineOrdersTitle => 'Pedidos en línea';

  @override
  String get acceptOnlineOrders => 'Aceptar pedidos de clientes';

  @override
  String get acceptOnlineOrdersHint =>
      'Desde la aplicación, la web o los códigos QR de las mesas. Cada pedido llega a «Pedidos» para ser aceptado.';

  @override
  String get acceptDelivery => 'Ofrecer entrega a domicilio';

  @override
  String get deliveryFee => 'Gastos de envío';

  @override
  String get minimumOrder => 'Pedido mínimo';

  @override
  String get reservationsTitle => 'Reservas';

  @override
  String get acceptReservations => 'Aceptar reservas en línea';

  @override
  String get reservationDuration => 'Duración de una reserva';

  @override
  String get minutesShort => 'min';

  @override
  String get maxPartySize => 'Máximo de personas';

  @override
  String get publicProfileTitle => 'Ficha pública del restaurante';

  @override
  String get publicDescription => 'Presentación';

  @override
  String get publicDescriptionHint =>
      'Ej.: cocina camerunesa generosa, pescado a la brasa del día, terraza con sombra.';

  @override
  String get cuisinesLabel => 'Tipos de cocina';

  @override
  String get cuisinesHint =>
      'Ej.: africana, parrilla, marisco (separados por comas)';

  @override
  String get priceLevel => 'Rango de precios';

  @override
  String get publicPageTitle => 'Página del restaurante';

  @override
  String get publicPageHint =>
      'Para compartir (redes sociales, WhatsApp) o imprimir: los clientes ven la carta y hacen su pedido.';

  @override
  String get copyLink => 'Copiar el enlace';

  @override
  String get sourcePhone => 'Por teléfono';

  @override
  String get sourceQr => 'Código QR de la mesa';

  @override
  String get sourceApp => 'Aplicación cliente';

  @override
  String get sourcePartner => 'Socio';

  @override
  String get sourceStaff => 'Tomado en sala';

  @override
  String get stageToValidate => 'Por confirmar';

  @override
  String get stageDraft => 'Aún no enviado';

  @override
  String get stageCooking => 'En preparación';

  @override
  String get stageReady => 'Listo para servir';

  @override
  String get stageReadyTakeaway => 'Listo para entregar';

  @override
  String get stageReadyDelivery => 'Listo para el repartidor';

  @override
  String get stageToPay => 'Por cobrar';

  @override
  String get stageDone => 'Terminado';

  @override
  String get stageCancelled => 'Cancelado';

  @override
  String get handToCustomer => 'Entregado al cliente';

  @override
  String get handToCourier => 'Entregado al repartidor';

  @override
  String guestsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count personas',
      one: '1 persona',
    );
    return '$_temp0';
  }

  @override
  String forTime(String time) {
    return 'Para las $time';
  }

  @override
  String get billTitle => 'Cuenta';

  @override
  String get thankYou => '¡Gracias por su visita!';

  @override
  String kdsToPrepare(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pedidos por preparar',
      one: '1 pedido por preparar',
      zero: 'Nada que preparar',
    );
    return '$_temp0';
  }

  @override
  String kdsLate(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count con retraso',
      one: '1 con retraso',
    );
    return '$_temp0';
  }

  @override
  String kdsReadyCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count listos',
      one: '1 listo',
      zero: 'Ninguno listo',
    );
    return '$_temp0';
  }

  @override
  String get kdsTickets => 'Comandas';

  @override
  String get kdsSummary => 'Totales';

  @override
  String get kdsFullScreen => 'Pantalla completa (modo cocina)';

  @override
  String get kdsFlowHint =>
      'Los pedidos enviados desde la sala llegan aquí con un aviso sonoro. Toque un artículo para pasarlo a «en preparación» y luego a «listo». «Todo listo» avisa enseguida a los camareros.';

  @override
  String get kdsReadyStrip =>
      'Listos — la sala está avisada (columna «Listo para servir»), esperando servicio';

  @override
  String get kdsStart => 'Empezar';

  @override
  String kdsWaitingService(String time) {
    return 'espera desde hace $time';
  }

  @override
  String get kdsRecall => 'Recuperar (aún no está listo)';

  @override
  String get serviceAndCustomers => 'Servicio y clientes';

  @override
  String get serviceSettingsTitle => 'Servicio';

  @override
  String get targetPrepTime => 'Tiempo de preparación objetivo';

  @override
  String get targetPrepTimeHint =>
      'Pasado este tiempo, el pedido se pone en rojo (con retraso).';

  @override
  String get payFirstTakeaway => 'Para llevar: cobrar antes de la preparación';

  @override
  String get payFirstTakeawayHint =>
      'El botón «Cobrar y luego enviar» aparece en los pedidos para llevar.';

  @override
  String get tableOccupied => 'Ocupada';

  @override
  String get tableReservedNow => 'Reservada ahora';

  @override
  String get tableReservedSoon => 'Reservada pronto';

  @override
  String reservedAt(String time) {
    return 'Reservada a las $time';
  }

  @override
  String get acceptWithDelay => 'Aceptar el pedido';

  @override
  String scheduledFor(String time) {
    return 'Solicitado para las $time';
  }

  @override
  String get delayAnnounced =>
      '¿En cuánto tiempo estará listo? Se avisa al cliente.';

  @override
  String get orderAccepted => 'Pedido aceptado: pasa a preparación.';

  @override
  String get rejectOrder => 'Rechazar el pedido';

  @override
  String get rejectReasonHint =>
      'Ej.: sin pescado, ningún repartidor disponible';

  @override
  String get paymentDone => 'Pago registrado.';

  @override
  String get partialPaymentDone => 'Pago parcial registrado.';

  @override
  String get announcedDelay => 'Plazo anunciado al cliente';

  @override
  String promisedFor(String time) {
    return 'Prometido para las $time';
  }

  @override
  String get heldShort => 'a continuación';

  @override
  String moreItems(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '+ $count artículos más',
      one: '+ 1 artículo más',
    );
    return '$_temp0';
  }

  @override
  String get paidShort => 'Pagado';

  @override
  String get partlyPaid => 'Pagado en parte';

  @override
  String get notPaid => 'No pagado';

  @override
  String get reject => 'Rechazar';

  @override
  String get accept => 'Aceptar';

  @override
  String get sendShort => 'Enviar';

  @override
  String get fireNext => 'Marchar lo siguiente';

  @override
  String get collectShort => 'Cobrar';

  @override
  String get columnInProgress => 'En curso';

  @override
  String get columnReady => 'Listos para servir';

  @override
  String get columnToValidateHint =>
      'Los pedidos de los clientes (aplicación, web, códigos QR de las mesas) llegan aquí con un aviso sonoro. Acéptelos anunciando un plazo.';

  @override
  String get columnInProgressHint =>
      'Pedidos tomados y en preparación. «Enviar» manda los artículos a cocina y bar.';

  @override
  String get columnReadyHint =>
      'Cuando la cocina pulsa «Todo listo», el pedido llega aquí (con aviso sonoro): servir en la mesa, entregar al cliente o al repartidor.';

  @override
  String get columnToPayHint =>
      'Todo está servido: queda cobrar. Una vez pagado, el pedido termina y la mesa queda libre.';

  @override
  String get allOrders => 'Todos';

  @override
  String get searchOrderHint => 'N.º, cliente, mesa, teléfono';

  @override
  String get chooseTable => 'Elija la mesa';

  @override
  String get tableHasOrder =>
      'Esta mesa ya tiene un pedido en curso: se abrirá.';

  @override
  String tableReservationWarning(String time, String name, int count) {
    return 'Atención: reservada a las $time · $name · $count pers.';
  }

  @override
  String get guestsLabel => 'Número de personas';

  @override
  String get receivedByPhone => 'Pedido recibido por teléfono';

  @override
  String get customerName => 'Nombre del cliente';

  @override
  String get customerNameOptional => 'Nombre del cliente (opcional)';

  @override
  String get phoneOptional => 'Teléfono (opcional)';

  @override
  String get deliveryAddress => 'Dirección de entrega';

  @override
  String get deliveryAddressHint =>
      'Barrio, calle, referencia (ej.: Bonamoussadi, junto a la farmacia)';

  @override
  String get deliveryInstructions => 'Indicaciones para el repartidor';

  @override
  String get deliveryInstructionsHint =>
      'Ej.: edificio amarillo, 2.º piso, llamar al llegar';

  @override
  String get deliveryTime => 'Hora de entrega';

  @override
  String get pickupTime => 'Hora de recogida';

  @override
  String get asap => 'Lo antes posible';

  @override
  String get atFixedTime => 'A una hora concreta';

  @override
  String atTime(String time) {
    return 'A las $time';
  }

  @override
  String get newOrder => 'Nuevo pedido';

  @override
  String get orderTypeQuestion => '¿Qué tipo de pedido?';

  @override
  String get dineInHint => 'Cliente sentado en una mesa';

  @override
  String get takeawayHint => 'El cliente se lleva su pedido';

  @override
  String get deliveryHint => 'Entregado en una dirección';

  @override
  String get orderNote => 'Observación sobre el pedido (opcional)';

  @override
  String get orderNoteHint =>
      'Ej.: cumpleaños, cliente con prisa, alergia al cacahuete';

  @override
  String get continueToMenu => 'Continuar: elegir los platos';

  @override
  String get moveTable => 'Cambiar de mesa';

  @override
  String get noFreeTable => 'No hay ninguna mesa libre por ahora.';

  @override
  String get print => 'Imprimir';

  @override
  String get printKitchenTicket => 'Comanda de preparación (cocina)';

  @override
  String get printBill => 'Cuenta (cliente)';

  @override
  String get orderHistory => 'Historial del pedido';

  @override
  String get searchDish => 'Buscar un plato, una bebida…';

  @override
  String get noResults => 'Sin resultados.';

  @override
  String get groupToSend => 'Por enviar';

  @override
  String get groupHeld => 'A continuación (enviados más tarde)';

  @override
  String get groupCooking => 'En preparación';

  @override
  String get groupReady => 'Listos para servir';

  @override
  String get groupServed => 'Servidos';

  @override
  String get groupCancelled => 'Cancelados';

  @override
  String collectThenSend(String amount) {
    return 'Cobrar $amount y luego enviar';
  }

  @override
  String fireNextCount(int count) {
    return 'Marchar lo siguiente ($count)';
  }

  @override
  String get customerOrderToValidate => 'Pedido de un cliente por confirmar';

  @override
  String get customerOrderToValidateHint =>
      'Compruebe los artículos y acepte (con un plazo) o rechace. Se avisa al cliente.';

  @override
  String get payFirstHint =>
      'Para llevar: pago antes de la preparación (ajuste del local).';

  @override
  String get addedByCustomer => 'añadido por el cliente';

  @override
  String get sendWithOrder => 'Enviar con el resto';

  @override
  String get holdForLater => 'Dejar «a continuación» (se envía más tarde)';

  @override
  String openedAt(String time) {
    return 'abierto a las $time';
  }

  @override
  String get fromReservation => 'Clientes sentados (reserva)';

  @override
  String get editOrderDetails => 'Modificar los datos';

  @override
  String get evOpened => 'Pedido abierto';

  @override
  String evItemAdded(String item) {
    return 'Añadido: $item';
  }

  @override
  String get evItemUpdated => 'Artículo modificado';

  @override
  String get evItemRemoved => 'Artículo retirado';

  @override
  String evSent(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Enviado a cocina ($count artículos)',
      one: 'Enviado a cocina (1 artículo)',
    );
    return '$_temp0';
  }

  @override
  String get evItemCancelled => 'Artículo cancelado';

  @override
  String get evCancelled => 'Pedido cancelado';

  @override
  String get evClosed => 'Pedido terminado';

  @override
  String evPayment(String amount) {
    return 'Pago de $amount';
  }

  @override
  String get evRefund => 'Reembolso';

  @override
  String get evDetailsUpdated => 'Datos modificados';

  @override
  String get itemsTotal => 'Artículos';

  @override
  String get removeDiscount => 'Quitar el descuento';

  @override
  String get addDiscount => 'Añadir un descuento';

  @override
  String get applyPromotion => 'Aplicar una promoción';

  @override
  String get promoCode => 'Código promocional';

  @override
  String get promoCodeHint => 'Ej.: BIENVENIDA10';

  @override
  String get manualDiscount => 'Descuento (gesto comercial)';

  @override
  String get useLoyalty => 'Usar los puntos de fidelidad';

  @override
  String get noActivePromotion =>
      'Ninguna promoción en curso. Cree alguna en «Clientes y fidelidad».';

  @override
  String get inPercent => 'En %';

  @override
  String get inAmount => 'En importe';

  @override
  String get percentValue => 'Porcentaje';

  @override
  String get manualDiscountHint => 'Ej.: espera demasiado larga, cliente fiel';

  @override
  String get apply => 'Aplicar';

  @override
  String get allAreas => 'Todas las zonas';

  @override
  String get planView => 'Plano';

  @override
  String get cardsView => 'Tarjetas';

  @override
  String get editFloor => 'Modificar la sala';

  @override
  String get done => 'Terminado';

  @override
  String get floorEmptyTitle => 'Cree su sala';

  @override
  String get floorEmptyHint =>
      'Añada primero sus zonas (Sala, Terraza, VIP…) y luego sus mesas con el nombre que quiera (Mesa 1, VIP 1, Barra 2…). Verá en directo qué mesas están libres, ocupadas o reservadas.';

  @override
  String get editFloorHint =>
      'Arrastre las mesas para reproducir su sala. Toque una mesa para cambiarle el nombre, las plazas o la forma.';

  @override
  String get noTablesInArea =>
      'Ninguna mesa en esta zona: «Modificar la sala» y luego «Nueva mesa».';

  @override
  String get newOrderAtTable => 'Nuevo pedido en esta mesa';

  @override
  String get openOrder => 'Abrir el pedido';

  @override
  String get reservationsToday => 'Reservas del día';

  @override
  String get reserveTable => 'Reservar';

  @override
  String get noReservationToday => 'Ninguna reserva hoy para esta mesa.';

  @override
  String get tableQrCode => 'Código QR de la mesa';

  @override
  String get tableQrHint =>
      'Imprímalo y póngalo en la mesa: el cliente lo escanea, ve la carta con fotos y pide. El pedido llega a «Por confirmar».';

  @override
  String get areaNameHint => 'Ej.: Sala, Terraza, VIP, Planta alta';

  @override
  String get tableLabelHint => 'Ej.: Mesa 1, VIP 1, Barra 2';

  @override
  String get tableShape => 'Forma';

  @override
  String get shapeSquare => 'Cuadrada';

  @override
  String get shapeRound => 'Redonda';

  @override
  String get shapeRect => 'Rectangular';

  @override
  String get resRequested => 'Solicitada';

  @override
  String get resConfirmed => 'Confirmada';

  @override
  String get resSeated => 'Sentados';

  @override
  String get resCompleted => 'Terminada';

  @override
  String get resNoShow => 'No se presentaron';

  @override
  String get resDeclined => 'Rechazada';

  @override
  String get resCancelled => 'Cancelada';

  @override
  String reservationRequests(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count solicitudes de reserva por tratar',
      one: '1 solicitud de reserva por tratar',
    );
    return '$_temp0';
  }

  @override
  String get reservationRequestsHint =>
      'Solicitudes hechas por los clientes en línea: confirme eligiendo las mesas o rechace con un motivo. Se avisa al cliente.';

  @override
  String get declineReservation => 'Rechazar la reserva';

  @override
  String get confirmReservation => 'Confirmar';

  @override
  String reservationsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count reservas',
      one: '1 reserva',
      zero: 'Ninguna reserva',
    );
    return '$_temp0';
  }

  @override
  String coversCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cubiertos',
      one: '1 cubierto',
      zero: '0 cubiertos',
    );
    return '$_temp0';
  }

  @override
  String get noReservationsDay => 'Ninguna reserva ese día.';

  @override
  String get today => 'Hoy';

  @override
  String get timelineView => 'Planificación';

  @override
  String get listView => 'Lista';

  @override
  String get newReservation => 'Nueva reserva';

  @override
  String get nowLabel => 'ahora';

  @override
  String get seatGuests => 'Sentar a los clientes';

  @override
  String get changeTables => 'Cambiar de mesas';

  @override
  String get markNoShow => 'No se presentaron';

  @override
  String get cancelReservation => 'Cancelar la reserva';

  @override
  String get markCompleted => 'Terminada';

  @override
  String get chooseTables => 'Mesas';

  @override
  String seatsForParty(int seats, int party) {
    return '$seats plazas elegidas para $party personas';
  }

  @override
  String get reservationNoteHint =>
      'Ej.: cumpleaños, trona, junto a la ventana';

  @override
  String get noFreeTableSlot =>
      'Ninguna mesa libre en esta franja: cambie la hora o la duración.';

  @override
  String itemsCountLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count artículos',
      one: '1 artículo',
      zero: 'ningún artículo',
    );
    return '$_temp0';
  }

  @override
  String get alertNewCustomerOrder =>
      'Nuevo pedido de un cliente por confirmar';

  @override
  String get alertOrderReady => 'Un pedido está listo para servir';

  @override
  String get view => 'Ver';

  @override
  String ordersToValidateBanner(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pedidos de clientes esperan su confirmación',
      one: '1 pedido de cliente espera su confirmación',
    );
    return '$_temp0';
  }

  @override
  String get tabInProgress => 'En curso';

  @override
  String get historyTab => 'Historial';

  @override
  String get newShort => 'Nuevo';

  @override
  String get brandPoint1 =>
      'Pedidos en sala, para llevar, a domicilio y en línea';

  @override
  String get brandPoint2 => 'Cocina y bar en directo, sala y reservas';

  @override
  String get brandPoint3 => 'Caja, existencias, compras y gastos';

  @override
  String get brandPoint4 => 'Paneles e informes profesionales';

  @override
  String get authWelcome => 'Bienvenido';

  @override
  String get authWelcomeSub => 'Inicie sesión para volver a su restaurante';

  @override
  String get noAccountYet => '¿Aún no tiene cuenta?';

  @override
  String get alreadyAccount => '¿Ya tiene una cuenta?';

  @override
  String get authSignUpSub => 'Unos segundos para empezar, sin compromiso';

  @override
  String get authForgotSub =>
      'Reciba un código por correo para elegir una nueva contraseña';

  @override
  String get authNewPasswordSub => 'Al menos 8 caracteres';

  @override
  String get navHome => 'Inicio';

  @override
  String get greetingDay => 'Buenos días';

  @override
  String get greetingEvening => 'Buenas noches';

  @override
  String get moreModules => 'Más';

  @override
  String freeTablesCount(int free, int total) {
    return '$free mesas libres de $total';
  }

  @override
  String suggestedTable(String label, int seats) {
    return 'Sugerencia: $label ($seats plazas)';
  }

  @override
  String get slotFreeSoon => 'Libre a tiempo';

  @override
  String get slotReserved => 'Reservada en esta franja';

  @override
  String freeAround(String time) {
    return 'libre hacia las $time';
  }

  @override
  String get timelineEmptyHint =>
      'Ninguna reserva ese día. Toque una hora en la línea de una mesa para reservarla.';

  @override
  String get myAccount => 'Mi cuenta';

  @override
  String get brandTagline => 'La gestión de restaurantes, fluida y nítida.';

  @override
  String get addPaymentMethod => 'Añadir un medio';

  @override
  String get allMethods => 'Todos los medios';

  @override
  String get availableInBranches => 'Disponible en';

  @override
  String get availableWorldwide => 'Válidos en todas partes';

  @override
  String get blindCountHint =>
      'Cuente el cajón sin mirar lo esperado: la diferencia aparece una vez registrado el recuento.';

  @override
  String get cashDrawer => 'Cajón de caja';

  @override
  String get cashMovementsTitle => 'Entradas y salidas de efectivo';

  @override
  String get cashReportTitle => 'Informe de caja';

  @override
  String get cashierLabel => 'Cajero';

  @override
  String get choosePaymentMethod => 'Elija el medio de pago.';

  @override
  String get closingValidated => 'Cierre validado: Z numerado.';

  @override
  String get closingsTab => 'Cierres';

  @override
  String get coinsLabel => 'Monedas';

  @override
  String get collectTab => 'Cobrar';

  @override
  String collectWithTip(String amount, String tip) {
    return 'Cobrar $amount + $tip';
  }

  @override
  String get collectedByDay => 'Cobrado por día';

  @override
  String get collectedByHour => 'Cobrado por hora';

  @override
  String get collectedTotal => 'Cobrado';

  @override
  String commonInCountry(String country) {
    return 'Habituales en su país ($country)';
  }

  @override
  String get countByDenomination => 'Billete a billete';

  @override
  String countConfirm(String amount) {
    return '¿Confirmar el recuento: $amount?';
  }

  @override
  String get countDetailTitle => 'Detalle del recuento';

  @override
  String get countRecorded => 'Recuento registrado';

  @override
  String get countedLabel => 'Contada';

  @override
  String get countedTotal => 'Total contado';

  @override
  String get customMethod => 'Medio personalizado';

  @override
  String get customMethodHint =>
      'Ej.: vale de la casa, tarjeta de fidelidad, pago por enlace';

  @override
  String get dateLabel => 'Fecha';

  @override
  String get differenceLabel => 'Diferencia';

  @override
  String get differenceReasonHint =>
      'Ej.: error al dar el cambio, billete dañado';

  @override
  String get discountsTotal => 'Descuentos';

  @override
  String get displayOrder => 'Orden';

  @override
  String get enterAmount => 'Introducir el importe';

  @override
  String get errorPaymentMethodUnavailable =>
      'Este medio de pago no está disponible aquí.';

  @override
  String get errorReferenceRequired =>
      'Introduzca el n.º de transacción (referencia del pago).';

  @override
  String get exactAmount => 'Importe exacto';

  @override
  String get exportExcel => 'Exportar (hoja de cálculo)';

  @override
  String get exportPdf => 'Exportar en PDF';

  @override
  String get feePercentLabel => 'Comisión cobrada';

  @override
  String feeShort(String percent) {
    return 'comisión $percent %';
  }

  @override
  String get feesEstimate => 'Comisiones (estimación)';

  @override
  String get findTicket => 'Buscar un ticket';

  @override
  String get lastPayments => 'Últimos pagos';

  @override
  String get legalNameLabel => 'Razón social';

  @override
  String get managerMustValidate => 'Un responsable debe validar el cierre.';

  @override
  String get methodKind => 'Tipo';

  @override
  String get mySessionTab => 'Mi caja';

  @override
  String get newRegister => 'Nueva caja';

  @override
  String get noActiveRegister => 'Ninguna caja activa: cree una en Ajustes.';

  @override
  String get noClosings => 'Aún no hay cierres.';

  @override
  String get noMovements => 'Ningún movimiento.';

  @override
  String get noPaymentMethod =>
      'Ningún medio de pago activo: añada alguno en Ajustes.';

  @override
  String get noPaymentsYet => 'Aún no hay pagos.';

  @override
  String get noRefunds => 'Ningún reembolso en los últimos 30 días.';

  @override
  String get noTip => 'Ninguna';

  @override
  String get notesLabel => 'Billetes';

  @override
  String get nothingToCollect => 'Nada que cobrar por ahora.';

  @override
  String get openRegisterHint =>
      'Cuente el fondo de caja (el cambio inicial): servirá de base para el recuento de fin de turno.';

  @override
  String openRegisterTitle(String register) {
    return 'Abrir $register';
  }

  @override
  String get openedLabel => 'Apertura';

  @override
  String get orderDetails => 'Detalle del pedido';

  @override
  String get orderShort => 'Pedido';

  @override
  String get otherAmount => 'Otro importe';

  @override
  String get otherCountries => 'Otros países';

  @override
  String get payKindAccount => 'Cuenta de cliente';

  @override
  String get payKindCheque => 'Cheque';

  @override
  String get payKindInstant => 'Pago instantáneo';

  @override
  String get payKindVoucher => 'Vale o bono';

  @override
  String get payKindWallet => 'Monedero móvil';

  @override
  String get paymentComplete => 'Pago completado';

  @override
  String get paymentMethodLabel => 'Medio de pago';

  @override
  String get paymentMethodsHint =>
      'Los medios ofrecidos al cobrar. Adáptelos a su país: nombre, n.º de transacción obligatorio, comisión, locales.';

  @override
  String get paymentMethodsTitle => 'Medios de pago';

  @override
  String get paymentsCountShort => 'Pagos';

  @override
  String get periodYesterday => 'Ayer';

  @override
  String get printCountReport => 'Imprimir el recuento';

  @override
  String get printReceipt => 'Imprimir el ticket';

  @override
  String get reasonChangeFloat => 'Aporte de cambio';

  @override
  String get reasonOtherIn => 'Otra entrada';

  @override
  String get reasonOtherOut => 'Otra salida';

  @override
  String get reasonSafeDrop => 'Depósito en la caja fuerte';

  @override
  String get reasonSmallPurchase => 'Pequeña compra';

  @override
  String get reasonTipsPaid => 'Propinas entregadas al equipo';

  @override
  String get receiptFooterHint =>
      'Ej.: ¡Gracias y hasta pronto! Wi-Fi: RestoInvitado';

  @override
  String get receiptFooterLabel => 'Mensaje al pie del ticket';

  @override
  String receiptNumberLabel(int number) {
    return 'Ticket n.º $number';
  }

  @override
  String get receiptSettingsHint =>
      'Impresos en cada ticket de cliente y en los Z de caja.';

  @override
  String get receiptSettingsTitle => 'Datos del ticket';

  @override
  String get receiptShort => 'Ticket';

  @override
  String receiptTaxId(String id) {
    return 'N.º fiscal: $id';
  }

  @override
  String get recentRefunds => 'Reembolsos recientes';

  @override
  String get recordCount => 'Registrar el recuento';

  @override
  String get referenceRequiredShort => 'n.º de transacción obligatorio';

  @override
  String get refundAction => 'Reembolsar';

  @override
  String get refundDone => 'Reembolso registrado.';

  @override
  String get refundReasonHint => 'Ej.: plato rechazado, error de introducción';

  @override
  String get refundTitle => 'Reembolsar al cliente';

  @override
  String refundableAmount(String amount) {
    return 'reembolsable: $amount';
  }

  @override
  String get refundsTab => 'Reembolsos';

  @override
  String get registerClosedHint => 'Abra la caja (fondo contado) para cobrar.';

  @override
  String get registerClosedTitle => 'Caja cerrada';

  @override
  String get registerLabel => 'Caja';

  @override
  String get registerNameHint => 'Ej.: Mostrador, Terraza, Barra';

  @override
  String get registersTitle => 'Cajas';

  @override
  String get reportsTab => 'Informes';

  @override
  String get requireReferenceHint =>
      'El cajero debe introducir el n.º de transacción (conciliación con el extracto).';

  @override
  String get requireReferenceLabel => 'N.º de transacción obligatorio';

  @override
  String get salesByDay => 'Por día';

  @override
  String get salesByMethod => 'Por medio de pago';

  @override
  String get salesByRegister => 'Por caja';

  @override
  String get salesByStaff => 'Por camarero';

  @override
  String get searchAction => 'Buscar';

  @override
  String get searchMethodOrCountry =>
      'Nombre del medio o código de país (ej. BR)';

  @override
  String get sendWhatsApp => 'Enviar por WhatsApp';

  @override
  String get sessionAwaitingValidation => 'Contada — pendiente de validación';

  @override
  String get settingsTab => 'Ajustes';

  @override
  String get shareReceipt => 'Compartir el ticket';

  @override
  String get signatureCashier => 'Firma del cajero';

  @override
  String get signatureManager => 'Firma del responsable';

  @override
  String someBranchesOnly(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count locales',
      one: '1 local',
    );
    return '$_temp0';
  }

  @override
  String get splitAll => 'Todo';

  @override
  String get splitByItems => 'Por artículos';

  @override
  String get splitByParts => 'Por partes';

  @override
  String get splitCustom => 'Importe libre';

  @override
  String get staffLabel => 'Camarero';

  @override
  String get statusLabel => 'Estado';

  @override
  String get taxIdHint => 'Número de identificación fiscal de su país';

  @override
  String get taxIdLabel => 'N.º de identificación fiscal';

  @override
  String get ticketOrOrderNumber => 'N.º de ticket o de pedido';

  @override
  String get tipLabel => 'Propina';

  @override
  String get tipPresetsLabel => 'Porcentajes propuestos';

  @override
  String get tipsEnabledHint =>
      'Se propone al cobrar, se cuenta aparte de la facturación y se atribuye al camarero del pedido.';

  @override
  String get tipsEnabledLabel => 'Proponer propina';

  @override
  String get tipsTitle => 'Propinas';

  @override
  String get tipsTotal => 'Propinas';

  @override
  String get toCollectTotal => 'Por cobrar';

  @override
  String get transactionReferenceRequired => 'N.º de transacción (obligatorio)';

  @override
  String get transactionsTab => 'Transacciones';

  @override
  String get validateClosingConfirm =>
      '¿Validar este cierre? El Z de caja se numerará y ya no podrá modificarse.';

  @override
  String get validateNowHint =>
      'Valide el cierre en la pestaña Cierres para obtener el Z numerado.';

  @override
  String get validatedLabel => 'Validada';

  @override
  String get voidedPayments => 'Pagos anulados';

  @override
  String get xReading => 'Lectura X';

  @override
  String get xReportTitle => 'Lectura X (provisional)';

  @override
  String get zHistory => 'Historial de Z';

  @override
  String zReportTitle(int number) {
    return 'Z de caja n.º $number';
  }

  @override
  String get zShort => 'Z';

  @override
  String get expectedCashLabel => 'Efectivo esperado';

  @override
  String get countedAmountLabel => 'Contado';

  @override
  String get refundsLabel => 'Reembolsos';

  @override
  String get addressOptional => 'Dirección (opcional)';

  @override
  String get billedTo => 'Facturado a';

  @override
  String get cancelInvoiceHint =>
      'Ej.: razón social errónea, cliente equivocado';

  @override
  String get chooseOrder => 'Elija el pedido';

  @override
  String get companyOptional => 'Empresa (opcional)';

  @override
  String get customerTaxIdOptional => 'N.º fiscal del cliente (opcional)';

  @override
  String get documentsTitle => 'Documentos';

  @override
  String get emailOptional => 'Correo electrónico (opcional)';

  @override
  String get errorCustomerNameRequired =>
      'El nombre del cliente es obligatorio en una factura.';

  @override
  String get invoiceATicket => 'Facturar un ticket';

  @override
  String get invoiceCancelledMention => 'FACTURA ANULADA';

  @override
  String get invoiceCancelledDone => 'Factura anulada: puede emitir una nueva.';

  @override
  String invoiceDateLabel(String date) {
    return 'Fecha: $date';
  }

  @override
  String get invoiceDesignation => 'Concepto';

  @override
  String invoiceEmailHint(String email) {
    return 'Para enviarla a $email: pulse «Compartir» y elija su correo.';
  }

  @override
  String get invoiceFooterHint =>
      'Ej.: condiciones de pago, datos bancarios, menciones legales de su país';

  @override
  String get invoiceFooterLabel => 'Menciones al pie de la factura';

  @override
  String invoiceNumberLabel(String number) {
    return 'Factura n.º $number';
  }

  @override
  String get invoicePayments => 'Pagos recibidos';

  @override
  String get invoicePrefixHint => 'Ej.: FA-2026-';

  @override
  String get invoicePrefixLabel => 'Prefijo del número de factura';

  @override
  String get invoiceSettingsTitle => 'Facturas';

  @override
  String get invoiceTitle => 'Factura';

  @override
  String get invoiceUnitPrice => 'Precio unitario';

  @override
  String get invoicedTotal => 'Facturado';

  @override
  String get invoicesCount => 'Facturas';

  @override
  String get issueInvoice => 'Hacer una factura';

  @override
  String get issueInvoiceAction => 'Emitir la factura';

  @override
  String get issueInvoiceHint =>
      'Una factura emitida queda numerada y ya no se modifica (si hay un error: anulación y nueva factura).';

  @override
  String get noInvoices =>
      'No hay facturas en este periodo. Una factura se hace desde un pedido (botón «Factura») o aquí con «Facturar un ticket».';

  @override
  String get printInvoice => 'Imprimir / descargar';

  @override
  String get receiptDocument => 'Ticket de caja';

  @override
  String get searchInvoiceHint => 'N.º, cliente, empresa';

  @override
  String get shareInvoice => 'Compartir';

  @override
  String get totalExclTax => 'Total sin impuestos';

  @override
  String get totalInclTax => 'Total con impuestos';

  @override
  String get receiptQrCaption => 'Escanee para encontrarnos en línea';

  @override
  String get receiptQrLabel => 'Código QR al pie del ticket';

  @override
  String get receiptQrUrlLabel => 'Enlace del código QR';

  @override
  String get receiptQrUrlHint =>
      'Vacío = página del restaurante. Ej.: https://su-sitio.com o su página de reseñas';

  @override
  String get receiptQrUrlInvalid =>
      'El enlace del código QR debe empezar por https:// (o http://).';

  @override
  String get restaurantLogo => 'Logotipo del restaurante';

  @override
  String get chooseLogo => 'Elegir el logotipo';

  @override
  String get replaceLogo => 'Reemplazar';

  @override
  String get removeLogo => 'Quitar';

  @override
  String get logoTooBig =>
      'Este archivo supera 1 MB: elija una imagen más ligera.';

  @override
  String get receiptTendered => 'Entregado';

  @override
  String get receiptChange => 'Cambio';

  @override
  String get restaurantLogoHint =>
      'Se imprime en la cabecera de los tickets. Se recomienda PNG con fondo transparente, 1 MB como máximo.';

  @override
  String get add => 'Añadir';

  @override
  String get delete => 'Eliminar';

  @override
  String get branchLabel => 'Local';

  @override
  String get kindDessert => 'Postre';

  @override
  String get kindMenu => 'Menú';

  @override
  String get navAds => 'Publicidad';

  @override
  String get navSettings => 'Ajustes';

  @override
  String get greetingShort => 'Hola';

  @override
  String get homeWelcome => 'Bienvenido, esta es su actividad de hoy';

  @override
  String get kpiSalesToday => 'Ventas de hoy';

  @override
  String get kpiOpenOrders => 'Pedidos en curso';

  @override
  String kpiPendingCount(int count) {
    return '$count en espera';
  }

  @override
  String get kpiOccupancy => 'Tasa de ocupación';

  @override
  String kpiTablesBusy(int busy, int total) {
    return '$busy de $total mesas ocupadas';
  }

  @override
  String get lowStockTitle => 'Existencias bajas';

  @override
  String get saveChanges => 'Guardar los cambios';

  @override
  String get settingsProfile => 'Perfil del local';

  @override
  String get settingsProfileHint =>
      'La información de su restaurante, visible para sus clientes.';

  @override
  String get settingsContact => 'Contacto y ubicación';

  @override
  String get settingsContactHint =>
      'Dirección, teléfonos y posición en el mapa.';

  @override
  String get settingsHours => 'Horarios';

  @override
  String get settingsHoursHint =>
      'Días y horas de apertura, tiempo de preparación, cierre temporal.';

  @override
  String get settingsDelivery => 'Entrega y pedidos';

  @override
  String get settingsDeliveryHint =>
      'Pedidos en línea, entrega, reservas y página pública.';

  @override
  String get settingsPayments => 'Pago y facturación';

  @override
  String get settingsPaymentsHint =>
      'Formas de pago, cajas, ticket, facturas y propinas.';

  @override
  String get settingsTeam => 'Equipo y roles';

  @override
  String get settingsTeamHint => 'Miembros, roles e invitaciones.';

  @override
  String get settingsNotifications => 'Notificaciones';

  @override
  String get settingsNotificationsHint => 'Lo que la aplicación le avisa.';

  @override
  String get settingsSecurity => 'Seguridad';

  @override
  String get settingsSecurityHint => 'Contraseña y dispositivos conectados.';

  @override
  String get restaurantName => 'Nombre del restaurante';

  @override
  String get sloganLabel => 'Eslogan';

  @override
  String get sloganHint => 'Ej.: Cocina tradicional refinada';

  @override
  String get registrationNumber => 'N.º de registro';

  @override
  String get registrationNumberHint => 'Registro mercantil de su país';

  @override
  String get logoUpload => 'Subir el logotipo';

  @override
  String get logoFormats =>
      'PNG, JPG o WebP — 1 MB como máximo. Ideal: 512 × 512.';

  @override
  String get logoWhere =>
      'El logotipo aparece en la aplicación, en su escaparate y en los tickets de sus clientes.';

  @override
  String get whatsappLabel => 'Teléfono WhatsApp';

  @override
  String get gpsTitle => 'Coordenadas GPS / mapa';

  @override
  String get latitude => 'Latitud';

  @override
  String get longitude => 'Longitud';

  @override
  String get gpsMissing => 'Ubicación sin indicar';

  @override
  String get openInMaps => 'Abrir en Maps';

  @override
  String get deliveryZoneLabel => 'Zona de entrega';

  @override
  String get deliveryZoneHint => 'Ej.: barrios atendidos o radio de 5 km';

  @override
  String get vacationMode => 'Modo vacaciones';

  @override
  String get vacationModeHint =>
      'Cerrar temporalmente el restaurante: aparece como cerrado para sus clientes.';

  @override
  String get vacationMessage => 'Mensaje para los clientes';

  @override
  String get vacationMessageHint => 'Ej.: Reapertura el 15 de septiembre';

  @override
  String get notifSoundNewOrder => 'Sonido con cada pedido nuevo';

  @override
  String get notifSoundReady => 'Sonido cuando un pedido está listo';

  @override
  String get notifLate => 'Aviso de pedidos retrasados';

  @override
  String get notifLowStock => 'Aviso de existencias bajas';

  @override
  String get notifReservations => 'Recordatorio de las reservas de la hora';

  @override
  String get notifCashGap => 'Diferencia de caja al cierre';

  @override
  String get signedInAs => 'Conectado como';

  @override
  String get securityTip =>
      'Use una contraseña única de al menos 8 caracteres.';

  @override
  String get signOutOthers => 'Cerrar sesión en mis otros dispositivos';

  @override
  String get signOutOthersDone => 'Sus otros dispositivos están desconectados.';

  @override
  String get signOutAll => 'Cerrar sesión en todas partes';

  @override
  String fileTooBig(String name) {
    return '$name es demasiado grande.';
  }

  @override
  String get adsCreate => 'Crear un anuncio';

  @override
  String get adsEdit => 'Modificar el anuncio';

  @override
  String get adsCampaigns => 'Mis campañas';

  @override
  String get adsLibrary => 'Biblioteca';

  @override
  String get adsStats => 'Estadísticas';

  @override
  String get adsCreateTitle => 'Crear';

  @override
  String get adsCreateHint => 'Elija el formato de su anuncio.';

  @override
  String get adsContent => 'Contenido';

  @override
  String get adsBudgetTargeting => 'Presupuesto y segmentación';

  @override
  String get adsPreview => 'Vista previa';

  @override
  String get adsPreviewHint => 'Vista previa en el móvil';

  @override
  String get adsPreviewSimulation => 'Esta vista previa es una simulación.';

  @override
  String get adsFromLibrary => 'Desde la biblioteca';

  @override
  String get adsUpload => 'Añadir fotos o vídeos';

  @override
  String get adsUploadHint =>
      'JPG, PNG, WebP (5 MB) · MP4, WebM, MOV (50 MB) · vídeos de 15 a 30 segundos recomendados';

  @override
  String get adsLibraryEmpty => 'La biblioteca está vacía.';

  @override
  String get adsDeleteFile => '¿Eliminar este archivo de la biblioteca?';

  @override
  String get adsEmpty => 'Aún no hay campañas.';

  @override
  String get adsEmptyHint =>
      'Cree su primer anuncio: un vídeo, una story de 24 h o un plato destacado.';

  @override
  String get adsActiveCampaigns => 'Campañas';

  @override
  String adsCampaignCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count activas',
      one: '1 activa',
      zero: 'ninguna activa',
    );
    return '$_temp0';
  }

  @override
  String get adFormat => 'Formato';

  @override
  String get adFormatVideo => 'Vídeo 15–30 s';

  @override
  String get adFormatVideoHint => 'Vídeo corto para captar la atención';

  @override
  String get adFormatCarousel => 'Carrusel de fotos';

  @override
  String get adFormatCarouselHint => 'Varias imágenes deslizables';

  @override
  String get adFormatStory => 'Story 24 h';

  @override
  String get adFormatStoryHint => 'Formato efímero de 24 horas';

  @override
  String get adFormatSponsoredMenu => 'Menú patrocinado';

  @override
  String get adFormatSponsoredMenuHint => 'Destacar sus platos';

  @override
  String get adFormatPush => 'Notificación';

  @override
  String get adFormatPushHint => 'Avisar directamente a sus clientes';

  @override
  String get adFormatClassified => 'Anuncio clasificado';

  @override
  String get adFormatClassifiedHint => 'Anuncio de texto simple y eficaz';

  @override
  String get adTitle => 'Título';

  @override
  String get adTitleHint => 'Ej.: Cruasán de mantequilla';

  @override
  String get adTitleRequired => 'Dé un título a su anuncio.';

  @override
  String get adText => 'Texto';

  @override
  String get adTextHint =>
      'Ej.: ¡Novedad! Cruasán artesanal casero, -20 % solo esta noche';

  @override
  String get adMediaHelp => 'Fotos o vídeos del anuncio (10 como máximo).';

  @override
  String get adVideoHelp => 'Añada un vídeo corto (de 15 a 30 segundos).';

  @override
  String get adChooseItems => 'Platos destacados';

  @override
  String get adCta => 'Botón';

  @override
  String get adCtaHint => 'Ej.: Pedir ahora';

  @override
  String get adCtaDefault => 'Pedir ahora';

  @override
  String get adLink => 'Enlace del botón (opcional)';

  @override
  String get adDailyBudget => 'Presupuesto diario';

  @override
  String get adBudgetNote =>
      'Presupuesto previsto: la difusión patrocinada la facturará la plataforma.';

  @override
  String get adStart => 'Inicio';

  @override
  String get adEnd => 'Fin';

  @override
  String get adStory24h => 'Visible 24 horas';

  @override
  String get adTargetAreas => 'Segmentación por barrio';

  @override
  String get adAddArea => 'Añadir un barrio';

  @override
  String get adMoments => 'Momento';

  @override
  String get momentMorning => 'Mañana';

  @override
  String get momentNoon => 'Mediodía';

  @override
  String get momentAfternoon => 'Tarde';

  @override
  String get momentEvening => 'Noche';

  @override
  String get momentNight => 'Madrugada';

  @override
  String get adBranches => 'Locales';

  @override
  String get adSaveDraft => 'Guardar el borrador';

  @override
  String get adPublish => 'Publicar';

  @override
  String get adPublished => 'Anuncio publicado.';

  @override
  String get adSponsored => 'Patrocinado';

  @override
  String get adStatusActive => 'Activa';

  @override
  String get adStatusScheduled => 'Programada';

  @override
  String get adStatusPaused => 'En pausa';

  @override
  String get adStatusEnded => 'Terminada';

  @override
  String get adStatusDraft => 'Borrador';

  @override
  String get adRoi => 'Facturación generada';

  @override
  String adRoiDetail(String amount) {
    return 'con $amount de presupuesto comprometido';
  }

  @override
  String adViews(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count vistas',
      one: '1 vista',
      zero: '0 vistas',
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
  String get adDetails => 'Ver detalles';

  @override
  String get adBoost => 'Impulsar';

  @override
  String get adBoostTitle => 'Prolongar la difusión';

  @override
  String adBoostDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count días más',
      one: '1 día más',
    );
    return '$_temp0';
  }

  @override
  String get adBoosted => 'Campaña prolongada.';

  @override
  String get adPause => 'Pausar';

  @override
  String get adResume => 'Reanudar';

  @override
  String get adEndNow => 'Terminar ahora';

  @override
  String get adDeleteConfirm => '¿Eliminar esta campaña y sus estadísticas?';

  @override
  String get adStatViews => 'Vistas';

  @override
  String get adStatClicks => 'Clics';

  @override
  String get adStatClickRate => 'Tasa de clics';

  @override
  String get adStatOrders => 'Pedidos';

  @override
  String get adStatRevenue => 'Facturación';

  @override
  String get adStatByCampaign => 'Vistas por campaña';

  @override
  String get activeLabel => 'Activo';

  @override
  String get addPhotos => 'Añadir fotos';

  @override
  String get addProduct => 'Añadir un producto';

  @override
  String get allItems => 'Todos';

  @override
  String get available => 'Disponible';

  @override
  String get categories => 'Categorías';

  @override
  String get copySuffix => 'copia';

  @override
  String get customerSideView =>
      'Vista del cliente — así aparece en el menú del restaurante';

  @override
  String get duplicate => 'Duplicar';

  @override
  String get everyDay => 'Todos los días';

  @override
  String get filterKind => 'Tipo';

  @override
  String get itemDescriptionHint =>
      'Ej.: Hojas de ndolé con cacahuetes, gambas y plátano';

  @override
  String get itemDuplicated =>
      'Artículo duplicado: la copia queda oculta hasta que la guarde.';

  @override
  String get livePreview => 'Vista previa en directo';

  @override
  String get mainPhoto => 'Principal';

  @override
  String get makeMainPhoto => 'Poner como foto principal';

  @override
  String get markAvailable => 'Volver a disponible';

  @override
  String get markSoldOut => 'Marcar como agotado';

  @override
  String get menuProducts => 'Productos del menú';

  @override
  String get noProductsFound => 'Ningún producto coincide.';

  @override
  String photosHint(int count) {
    return 'Hasta $count fotos · JPG, PNG, WebP · 5 MB máx.';
  }

  @override
  String get play => 'Reproducir';

  @override
  String prepMinutesShort(int minutes) {
    return 'Preparación: $minutes min';
  }

  @override
  String get prepTime => 'Tiempo de preparación';

  @override
  String get productInfo => 'Información del producto';

  @override
  String get productPhotos => 'Fotos del producto';

  @override
  String productsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count productos',
      one: '1 producto',
      zero: 'Ningún producto',
    );
    return '$_temp0';
  }

  @override
  String get publish => 'Publicar';

  @override
  String get replace => 'Reemplazar';

  @override
  String get saleDays => 'Días de venta';

  @override
  String get saleDaysRequired => 'Elija al menos un día de venta.';

  @override
  String get searchProduct => 'Buscar un producto, un plato…';

  @override
  String get sizesLabel => 'Tamaños';

  @override
  String get sortBy => 'Ordenar';

  @override
  String get sortMenuOrder => 'Orden del menú';

  @override
  String get sortName => 'Nombre';

  @override
  String get sortPriceAsc => 'Precio ascendente';

  @override
  String get sortPriceDesc => 'Precio descendente';

  @override
  String get stockAlertThreshold => 'Aviso por debajo de';

  @override
  String get stockAndTime => 'Existencias y tiempo';

  @override
  String stockLeft(int count) {
    return 'Existencias: quedan $count';
  }

  @override
  String stockLow(int count) {
    return 'Existencias bajas: quedan $count';
  }

  @override
  String get stockNotTracked => 'Vacío = sin seguimiento';

  @override
  String get stockOfDay => 'Existencias del día';

  @override
  String get stockOfDayHint =>
      'Número de raciones disponibles hoy. Baja con cada pedido; a cero, el artículo se agota. Déjelo vacío para no hacer seguimiento.';

  @override
  String get stockQuantity => 'Cantidad en existencias';

  @override
  String get supplementsLabel => 'Suplementos';

  @override
  String get videoAdded => 'Vídeo de presentación añadido';

  @override
  String get videoOptional => 'Vídeo de presentación (opcional, unos 30 s)';

  @override
  String get allChannels => 'Todos los canales';

  @override
  String get amountLabel => 'Importe';

  @override
  String averageTicketShort(String amount) {
    return 'Ticket medio $amount';
  }

  @override
  String get customerLabel => 'Cliente';

  @override
  String get financialResult => 'Resultado financiero';

  @override
  String get inKitchenCount => 'en preparación';

  @override
  String get inProgressCount => 'en curso';

  @override
  String get itemsLabel => 'Artículos:';

  @override
  String get lateCount => 'con retraso';

  @override
  String get noOrdersHere => 'No hay pedidos aquí';

  @override
  String get noSalesYet => 'Aún no hay ventas en el periodo.';

  @override
  String get nothingToCollectHint =>
      'Nada pendiente: los nuevos cobros aparecerán aquí.';

  @override
  String get orderLabel => 'Pedido';

  @override
  String get paymentLabel => 'Pago';

  @override
  String get periodLabel => 'Periodo';

  @override
  String get recentTransactions => 'Transacciones recientes';

  @override
  String get salesOfPeriod => 'Ventas del periodo';

  @override
  String get salesSplit => 'Reparto de ventas';

  @override
  String get timeLabel => 'Hora';

  @override
  String get topDishes => 'Platos estrella';

  @override
  String get viewDetails => 'Ver detalles';

  @override
  String vsPrevious(String amount) {
    return 'Periodo anterior: $amount';
  }

  @override
  String get addAddress => 'Añadir una dirección';

  @override
  String get addedToCart => 'Añadido al carrito.';

  @override
  String get addressLabel => 'Nombre de la dirección';

  @override
  String get addressLabelHint => 'Ej.: Casa, Oficina';

  @override
  String get addToCart => 'Añadir al carrito';

  @override
  String get allCities => 'Todas las ciudades';

  @override
  String get allRestaurants => 'Todos los restaurantes';

  @override
  String get birthday => 'Fecha de cumpleaños';

  @override
  String get cartEmpty => 'Su carrito está vacío.';

  @override
  String cartItems(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count artículos',
      one: '1 artículo',
    );
    return '$_temp0';
  }

  @override
  String get changeCity => 'Cambiar';

  @override
  String get chooseCity => 'Elegir la ciudad';

  @override
  String chooseOptionRequired(String name) {
    return 'Elija: $name';
  }

  @override
  String get closedNow => 'Cerrado';

  @override
  String get customerFavorites => 'Favoritos';

  @override
  String get customerHome => 'Inicio';

  @override
  String get customerOrders => 'Pedidos';

  @override
  String get customerProfile => 'Perfil';

  @override
  String customerReviews(int count) {
    return 'Opiniones de clientes ($count)';
  }

  @override
  String get customerSearch => 'Búsqueda';

  @override
  String get customerSpaceLink => 'Área de clientes · pedir';

  @override
  String get deliveryDetailsRequired =>
      'Indique la dirección de entrega y un teléfono.';

  @override
  String get directions => 'Cómo llegar';

  @override
  String get discoverRestaurants => 'Descubrir restaurantes';

  @override
  String get dishes => 'Platos';

  @override
  String get favoritesSignIn =>
      'Inicie sesión para encontrar sus restaurantes favoritos.';

  @override
  String get fullName => 'Nombre y apellidos';

  @override
  String get globalCatalog => 'Catálogo global';

  @override
  String get healthAllergies => 'Salud y alergias';

  @override
  String get howDoYouWant => '¿Cómo desea que le sirvan?';

  @override
  String loyaltyNextReward(int points, String amount) {
    return 'Próxima recompensa a los $points puntos: $amount';
  }

  @override
  String loyaltyPoints(int count) {
    return '$count puntos';
  }

  @override
  String get loyaltyProgram => 'Programa de fidelidad';

  @override
  String mapCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count locales en el mapa',
      one: '1 local en el mapa',
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
  String get myAddresses => 'Mis direcciones';

  @override
  String get myCart => 'Mi carrito';

  @override
  String get newRestaurant => 'Nuevo';

  @override
  String get noAddresses => 'No hay direcciones guardadas.';

  @override
  String get noCustomerOrders => 'Aún no ha pedido nada.';

  @override
  String get noFavorites => 'Aún no hay favoritos.';

  @override
  String get noFavoritesHint =>
      'Toque el corazón de un restaurante para añadirlo.';

  @override
  String get noLoyaltyYet => 'Sus puntos aparecerán tras sus primeros pedidos.';

  @override
  String get noRestaurantsYet =>
      'Aún no hay restaurantes publicados en esta ciudad.';

  @override
  String get noteForKitchen => 'Indicación para la cocina (opcional)';

  @override
  String get noteForKitchenHint => 'Ej.: sin picante, bien hecho';

  @override
  String get notifOrderUpdates => 'Seguimiento de mis pedidos';

  @override
  String get notifPromotions => 'Promociones y ofertas';

  @override
  String get notifReservationReminders => 'Recordatorios de reserva';

  @override
  String get onlineOrdersUnavailable =>
      'Pedido en línea no disponible por ahora';

  @override
  String get openFullMap => 'Abrir el mapa a pantalla completa';

  @override
  String get openNow => 'Abierto';

  @override
  String get orderDone => 'Terminado';

  @override
  String orderingAtTable(String table) {
    return 'Pedido en la mesa $table';
  }

  @override
  String get orderInProgress => 'En curso';

  @override
  String get orderNoteOptional => 'Mensaje para el restaurante (opcional)';

  @override
  String get orderRejected => 'Rechazado por el restaurante';

  @override
  String get orderSentToRestaurant =>
      '¡Pedido enviado! El restaurante lo confirmará: sígalo aquí en directo.';

  @override
  String get ordersSignIn => 'Inicie sesión para seguir sus pedidos.';

  @override
  String get orderSummary => 'Resumen';

  @override
  String get orderWaitingConfirmation => 'Pendiente de confirmación';

  @override
  String get payMobileWallet => 'Monedero móvil';

  @override
  String get personalProfile => 'Perfil personal';

  @override
  String get personalProfileHint =>
      'Su información personal y sus preferencias.';

  @override
  String get placeOrder => 'Pedir';

  @override
  String get preferences => 'Preferencias';

  @override
  String get preferredPayment => 'Pago preferido';

  @override
  String get preferredPaymentHint =>
      'Solo indicativo: no se guarda ningún número de tarjeta ni de cuenta.';

  @override
  String get productDetails => 'Detalles del producto';

  @override
  String get profileSignIn =>
      'Inicie sesión para gestionar su perfil, direcciones y puntos.';

  @override
  String get rateOrder => 'Valorar mi pedido';

  @override
  String get requiredLabel => 'Obligatorio';

  @override
  String get restaurantOnVacation =>
      'El restaurante está cerrado temporalmente.';

  @override
  String get restaurants => 'Restaurantes';

  @override
  String get restaurantSpace => 'Área del restaurante';

  @override
  String get restaurantUnavailable => 'Este restaurante no está disponible.';

  @override
  String get reviewComment => 'Su opinión (opcional)';

  @override
  String reviewsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count opiniones',
      one: '1 opinión',
      zero: 'ninguna opinión',
    );
    return '$_temp0';
  }

  @override
  String get searchRestaurantsHint => 'Buscar restaurantes, platos, cocinas…';

  @override
  String get seeAll => 'Ver todo';

  @override
  String get send => 'Enviar';

  @override
  String get signInToContinue => 'Inicie sesión para continuar';

  @override
  String get spiceHot => 'Fuerte';

  @override
  String get spiceLevel => 'Picante';

  @override
  String get spiceMedium => 'Medio';

  @override
  String get spiceMild => 'Suave';

  @override
  String get spiceNone => 'Sin';

  @override
  String get sponsoredAds => 'Anuncios patrocinados';

  @override
  String get stepAccepted => 'Aceptado por el restaurante';

  @override
  String get stepDone => 'Terminado';

  @override
  String get stepPreparing => 'En preparación';

  @override
  String get stepReady => 'Listo';

  @override
  String get stepSent => 'Enviado';

  @override
  String get storyLabel => 'Historia';

  @override
  String get thanksForReview => '¡Gracias por su opinión!';

  @override
  String get viewCart => 'Ver el carrito';

  @override
  String get watchVideo => 'Vídeo';

  @override
  String get yourName => 'Su nombre';

  @override
  String get gpsHint =>
      '«Abrir en Maps» guarda automáticamente la posición donde se encuentra: hágalo desde el local. También puede introducir las coordenadas.';

  @override
  String get locationSaved => 'Ubicación del local guardada.';

  @override
  String get locationServiceDisabled =>
      'La ubicación del dispositivo está desactivada: actívela y vuelva a intentarlo.';

  @override
  String get locationDenied =>
      'Acceso a la ubicación denegado: permítalo en los ajustes del navegador o del teléfono.';

  @override
  String get locationUnavailable =>
      'Ubicación no disponible por ahora: inténtelo en el exterior o introduzca las coordenadas.';

  @override
  String get openMapAction => 'Abrir el mapa';

  @override
  String get customerReviewsTitle => 'Opiniones de clientes';

  @override
  String get forYou => 'Para usted';

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
  String get hideReview => 'Ocultar la opinión';

  @override
  String get hideReviewReason => 'Motivo';

  @override
  String get locatedNearYou => 'Restaurantes ordenados según su ubicación';

  @override
  String get locateMe => 'Localizarme';

  @override
  String get locationRefusedChooseCity =>
      'Ubicación no disponible: elija su ciudad.';

  @override
  String get nearYouHint =>
      'Permita la ubicación para ver los restaurantes y platos más cercanos.';

  @override
  String get nearYouRestaurants => 'Cerca de usted';

  @override
  String get nearYouTitle => 'Restaurantes cerca de usted';

  @override
  String get newOnMenus => 'Novedades';

  @override
  String get noReviewsYet => 'Aún no hay opiniones';

  @override
  String get openNowTitle => 'Abiertos ahora';

  @override
  String get orderAgain => 'Volver a pedir';

  @override
  String get orderAgainAction => 'Repetir pedido';

  @override
  String get ordersInProgressTitle => 'Sus pedidos en curso';

  @override
  String get popularDishes => 'Platos populares';

  @override
  String get popularNearYou => 'Populares cerca de usted';

  @override
  String get promotionsTitle => 'Promociones';

  @override
  String get publishReview => 'Publicar mi opinión';

  @override
  String rateDish(String name) {
    return 'Valorar: $name';
  }

  @override
  String get rateShort => 'Valorar';

  @override
  String get refreshLocation => 'Actualizar';

  @override
  String get reorderPartial =>
      'Algunos platos ya no están disponibles: el resto se ha añadido al carrito.';

  @override
  String get reorderUnavailable => 'Estos platos ya no están disponibles.';

  @override
  String get reportReason => '¿Por qué es abusiva esta opinión?';

  @override
  String get reportReview => 'Denunciar';

  @override
  String reportsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count denuncias',
      one: '1 denuncia',
    );
    return '$_temp0';
  }

  @override
  String get reportSent => 'Gracias, la denuncia se ha enviado.';

  @override
  String get republishReview => 'Volver a publicar';

  @override
  String get reviewCommentHint =>
      'Ej.: bien sazonado, ración generosa, entrega rápida';

  @override
  String satisfiedPercent(int percent) {
    return '$percent % de clientes satisfechos';
  }

  @override
  String get sortBestRated => 'Mejor valoradas';

  @override
  String get sortHelpful => 'Más útiles';

  @override
  String get sortRecent => 'Más recientes';

  @override
  String get sortWorstRated => 'Peor valoradas';

  @override
  String get verifiedPurchase => 'Compra verificada';

  @override
  String get verifiedReviewNote =>
      'Opinión verificada: solo los clientes que recibieron este plato pueden valorarlo.';

  @override
  String get asSoonAsPossible => 'Lo antes posible';

  @override
  String get customerOrdersHere => 'Sus pedidos en su local';

  @override
  String get customerPrivacyNote =>
      'Solo ve la relación de este cliente con su restaurante: nunca sus pedidos en otros restaurantes.';

  @override
  String get customersCount => 'clientes';

  @override
  String multiRestaurantNote(int count) {
    return '$count restaurantes en su carrito: cada uno recibe su propio pedido, con su número y su seguimiento.';
  }

  @override
  String get navCustomers => 'Clientes';

  @override
  String get noCustomersYet => 'Aún no hay clientes en línea.';

  @override
  String get noCustomersYetHint =>
      'Cada cliente que pide desde la aplicación aparece aquí automáticamente.';

  @override
  String get noDeliveryHere =>
      'Este restaurante no hace entregas: pedido para llevar.';

  @override
  String get ordersSent => 'Pedidos enviados';

  @override
  String ordersSentHint(int count) {
    return '$count pedidos enviados, uno por restaurante. Siga cada uno por separado.';
  }

  @override
  String placeOrders(int count) {
    return 'Hacer los $count pedidos';
  }

  @override
  String get regularBadge => 'Habitual';

  @override
  String get regularCustomers => 'habituales (3 pedidos o más)';

  @override
  String restaurantsCount(int count) {
    return '$count restaurantes';
  }

  @override
  String get scheduleOrder => 'Programar';

  @override
  String get scheduleTooSoon => 'Elija una hora al menos 15 minutos más tarde.';

  @override
  String get searchCustomer => 'Nombre o teléfono';

  @override
  String get sortBiggestSpenders => 'Mayor gasto';

  @override
  String get sortMostOrders => 'Más pedidos';

  @override
  String get sortRecentVisit => 'Visita reciente';

  @override
  String get teamNotes => 'Notas del equipo';

  @override
  String get teamNotesExample =>
      'Ej.: prefiere la terraza, le gusta la salsa picante';

  @override
  String get teamNotesHint => 'Visibles solo para su equipo.';

  @override
  String get trackOrder => 'Seguir';

  @override
  String get customerDiscover => 'Descubrir';

  @override
  String get feedEmpty => 'Aún no hay nada que descubrir';

  @override
  String get feedEmptyHint =>
      'Aquí aparecerán los vídeos, platos y ofertas de los restaurantes de tu ciudad.';

  @override
  String get feedOrder => 'Pedir';

  @override
  String get feedViewDish => 'Ver el plato';

  @override
  String get feedViewRestaurant => 'Ver el restaurante';

  @override
  String get feedLike => 'Me gusta';

  @override
  String get feedSave => 'Guardar';

  @override
  String get feedShare => 'Compartir';

  @override
  String get feedSaved => 'Guardado en tus contenidos.';

  @override
  String get feedUnsaved => 'Quitado de tus contenidos guardados.';

  @override
  String get feedLinkCopied => 'Enlace copiado: pégalo para compartirlo.';

  @override
  String get commentsTitle => 'Comentarios';

  @override
  String get noCommentsYet => 'Aún no hay comentarios.';

  @override
  String get writeComment => 'Escribe un comentario…';

  @override
  String get adHideForever => 'No volver a mostrar';

  @override
  String reserveAt(String name) {
    return 'Reservar en $name';
  }

  @override
  String get reservationSentHint =>
      'Solicitud enviada: el restaurante confirmará tu reserva.';

  @override
  String get reservationNoteLabel => 'Comentario (opcional)';

  @override
  String get errorInvalidComment =>
      'El comentario debe tener entre 1 y 500 caracteres.';

  @override
  String get adStatReach => 'Alcance';

  @override
  String get adStatEngagement => 'Interacción';

  @override
  String get adStatLikes => 'Me gusta';

  @override
  String get adStatSaves => 'Guardados';

  @override
  String get adStatShares => 'Compartidos';

  @override
  String get hideComment => 'Ocultar';

  @override
  String get moderationReasonExample => 'P. ej.: insultante, fuera de tema';

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
      'Aquí aparecen los comentarios de los clientes sobre tus anuncios. Oculta los insultantes o fuera de tema.';

  @override
  String get happyBirthday => '¡Feliz cumpleaños!';

  @override
  String birthdayGift(String name, int points) {
    return '$name te regala $points puntos de fidelidad.';
  }

  @override
  String get thanksAction => '¡Gracias!';

  @override
  String get notificationsTitle => 'Notificaciones';

  @override
  String get noNotifications => 'Sin notificaciones';

  @override
  String get noNotificationsHint =>
      'Aquí te avisaremos cuando un restaurante acepte tu pedido, cuando esté listo o cuando se confirme una reserva.';

  @override
  String get notifOrderAcceptedTitle => 'Pedido aceptado';

  @override
  String notifOrderAccepted(String brand, String number) {
    return '$brand ha aceptado tu pedido n.º $number.';
  }

  @override
  String get notifOrderReadyTitle => 'Pedido listo';

  @override
  String notifOrderReady(String brand, String number) {
    return 'Tu pedido n.º $number está listo en $brand: puedes recogerlo.';
  }

  @override
  String notifOrderOnTheWay(String brand, String number) {
    return 'Tu pedido n.º $number de $brand está listo y en camino.';
  }

  @override
  String get notifOrderRejectedTitle => 'Pedido rechazado';

  @override
  String notifOrderRejected(String brand, String number, String reason) {
    return '$brand no ha podido aceptar tu pedido n.º $number: $reason';
  }

  @override
  String get notifReservationConfirmedTitle => 'Reserva confirmada';

  @override
  String notifReservationConfirmed(String brand, String date) {
    return '$brand ha confirmado tu reserva del $date.';
  }

  @override
  String get notifReservationDeclinedTitle => 'Reserva rechazada';

  @override
  String notifReservationDeclined(String brand, String date, String reason) {
    return '$brand no puede recibirte el $date: $reason';
  }

  @override
  String notifGroupJoined(String name, String brand) {
    return '$name se ha unido a tu pedido en grupo en $brand.';
  }

  @override
  String notifGroupPlaced(String host, String brand, String number) {
    return '$host ha enviado el pedido en grupo en $brand (n.º $number).';
  }

  @override
  String get groupOrderTitle => 'Pedido en grupo';

  @override
  String get groupOrderAction => 'Pedido en grupo';

  @override
  String get groupInviteTitle => 'Invita a tus comensales';

  @override
  String get groupInviteHint =>
      'Comparte este enlace: cada uno elige sus platos en su móvil y tú envías un único pedido.';

  @override
  String get groupEmpty => 'Aún no hay platos';

  @override
  String get groupEmptyHint =>
      'Añade tus platos y comparte el enlace con tus comensales.';

  @override
  String groupHostedBy(String name) {
    return 'Organizado por $name';
  }

  @override
  String groupStatusOpen(String time) {
    return 'Abierto hasta las $time';
  }

  @override
  String get groupStatusPlaced => 'Enviado al restaurante';

  @override
  String get groupStatusCancelled => 'Cancelado';

  @override
  String get groupStatusExpired => 'Caducado';

  @override
  String groupParticipants(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count comensales',
      one: '1 comensal',
    );
    return '$_temp0';
  }

  @override
  String get groupCheckoutTitle => 'Enviar para todo el grupo';

  @override
  String get estimatedTotal => 'Total estimado';

  @override
  String get groupPlaceOrder => 'Enviar el pedido al restaurante';

  @override
  String get cancelGroupOrder => 'Cancelar el pedido en grupo';

  @override
  String get cancelGroupOrderConfirm =>
      '¿Cancelar este pedido en grupo? Se perderán los platos de todos.';

  @override
  String get groupAddMyDishes => 'Añadir mis platos';

  @override
  String groupPlacedInfo(String name) {
    return '$name ha enviado el pedido al restaurante.';
  }

  @override
  String get groupClosedInfo => 'Este pedido en grupo está cerrado.';

  @override
  String get groupOrderPlaced => 'Pedido en grupo enviado al restaurante.';

  @override
  String get addedToGroup => 'Añadido al pedido en grupo.';

  @override
  String get addToGroup => 'Añadir al grupo';

  @override
  String get saveDishAction => 'Guardar el plato';

  @override
  String saveDishTitle(String name) {
    return 'Guardar «$name»';
  }

  @override
  String get favoriteDishes => 'Platos favoritos';

  @override
  String get myLists => 'Mis listas';

  @override
  String get myCoupons => 'Mis cupones';

  @override
  String get restaurantsSection => 'Restaurantes';

  @override
  String get unavailableNow => 'No disponible';

  @override
  String get removeAction => 'Quitar';

  @override
  String get noFavoriteDishes => 'Ningún plato favorito';

  @override
  String get noFavoriteDishesHint =>
      'Toca el corazón en la ficha de un plato para encontrarlo aquí.';

  @override
  String get newList => 'Nueva lista';

  @override
  String get noLists => 'Ninguna lista';

  @override
  String get noListsHint =>
      'Crea listas como «Por probar» o «Almuerzos de oficina».';

  @override
  String deleteListConfirm(String name) {
    return '¿Eliminar la lista «$name»?';
  }

  @override
  String get renameAction => 'Renombrar';

  @override
  String dishesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count platos',
      one: '1 plato',
      zero: 'Ningún plato',
    );
    return '$_temp0';
  }

  @override
  String get emptyListHint => 'Lista vacía: añade platos desde su ficha.';

  @override
  String get listName => 'Nombre de la lista';

  @override
  String get listNameExample => 'P. ej.: Por probar';

  @override
  String get noCoupons => 'Ningún cupón';

  @override
  String get noCouponsHint =>
      'Guarda las ofertas de los restaurantes desde el inicio para encontrarlas aquí.';

  @override
  String get couponsHowTo =>
      'Introduce el código en el seguimiento de tu pedido para obtener el descuento.';

  @override
  String validUntil(String date) {
    return 'hasta el $date';
  }

  @override
  String get couponUsed => 'Ya utilizado';

  @override
  String get couponExpired => 'Caducado';

  @override
  String get codeCopied => 'Código copiado.';

  @override
  String get couponSaved => 'Cupón guardado en tus favoritos.';

  @override
  String get saveCouponAction => 'Guardar';

  @override
  String get errorLimitReached =>
      'Límite alcanzado: quita elementos antes de añadir otros.';

  @override
  String get errorGroupClosed =>
      'Este pedido en grupo está cerrado o ha caducado.';

  @override
  String get customersTab => 'Clientes';

  @override
  String get offersTab => 'Ofertas';

  @override
  String get loyaltyTab => 'Fidelidad';

  @override
  String get activeOffers => 'Ofertas activas';

  @override
  String get publicCoupons => 'Cupones públicos';

  @override
  String get totalUses => 'Usos';

  @override
  String get newOffer => 'Nueva oferta';

  @override
  String get editOffer => 'Editar la oferta';

  @override
  String get offersEmpty => 'Ninguna oferta';

  @override
  String get offersEmptyHint =>
      'Crea un descuento, un código promocional o un cupón público para atraer y fidelizar a tus clientes.';

  @override
  String get offerStatusOff => 'Desactivada';

  @override
  String get offerStatusEnded => 'Finalizada';

  @override
  String get offerStatusScheduled => 'Programada';

  @override
  String get offerStatusActive => 'Activa';

  @override
  String get publicCouponLabel => 'Cupón público';

  @override
  String get publicCouponHint =>
      'Visible en la aplicación: los clientes pueden guardarlo en su cartera.';

  @override
  String get publicCouponNeedsCode => 'Un cupón público necesita un código.';

  @override
  String usesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count usos',
      one: '1 uso',
      zero: 'Nunca usada',
    );
    return '$_temp0';
  }

  @override
  String get offerName => 'Nombre de la oferta';

  @override
  String get offerNameExample => 'P. ej.: Bienvenida, Happy hour';

  @override
  String get discountPercent => 'Porcentaje';

  @override
  String get discountAmount => 'Importe';

  @override
  String get offerValue => 'Descuento';

  @override
  String get promoCodeLabel => 'Código (opcional)';

  @override
  String get offerCodeHint => 'De 3 a 30 letras o cifras, p. ej. BIENVENIDA';

  @override
  String get minOrderLabel => 'Pedido mínimo';

  @override
  String get maxUsesLabel => 'Usos máx.';

  @override
  String get perCustomerLabel => 'Por cliente';

  @override
  String get startsLabel => 'Inicio';

  @override
  String get endsLabel => 'Fin';

  @override
  String get offerNow => 'ahora';

  @override
  String get noEndDate => 'Sin fin';

  @override
  String get allBranchesLabel => 'Todos los locales';

  @override
  String get thisBranchOnly => 'Este local';

  @override
  String get offerActive => 'Oferta activa';

  @override
  String get loyaltyMembers => 'Miembros';

  @override
  String get pointsInCirculation => 'Puntos en circulación';

  @override
  String get loyaltyProgramTitle => 'Programa de fidelidad';

  @override
  String loyaltyExample(String amount, int points) {
    return 'Ejemplo: un pedido de $amount da $points puntos.';
  }

  @override
  String get loyaltyActive => 'Programa activo';

  @override
  String get amountPerPoint => 'Importe por 1 punto';

  @override
  String get rewardPointsLabel => 'Puntos para una recompensa';

  @override
  String get rewardValueLabel => 'Valor de la recompensa';

  @override
  String get birthdayPointsLabel => 'Puntos de cumpleaños';

  @override
  String get birthdayPointsHint =>
      'Se abonan automáticamente cada año a los clientes que ya han pedido en tu restaurante (0 = ninguno).';

  @override
  String get stockDashboardTab => 'Panel';

  @override
  String get stockArticlesTab => 'Artículos';

  @override
  String get stockOrdersTab => 'Pedidos';

  @override
  String get stockReportsTab => 'Informes';

  @override
  String get stockDashboardTitle => 'Panel del stock';

  @override
  String get stockValueLabel => 'Valor del stock';

  @override
  String get belowThresholdLabel => 'Bajo el umbral';

  @override
  String get outOfStockLabel => 'Agotados';

  @override
  String get expiringSoonLabel => 'Caducan pronto';

  @override
  String get inventoryVarianceLabel => 'Diferencias de inventario';

  @override
  String get consumptionLabel => 'Consumo';

  @override
  String get wasteLabel => 'Mermas';

  @override
  String get receiptsLabel => 'Recepciones';

  @override
  String articlesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count artículos',
      one: '1 artículo',
      zero: 'Ningún artículo',
    );
    return '$_temp0';
  }

  @override
  String daysCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count días',
      one: '1 día',
    );
    return '$_temp0';
  }

  @override
  String get consumptionByDay => 'Consumo y mermas por día';

  @override
  String get topConsumedTitle => 'Los más consumidos';

  @override
  String get wasteByReason => 'Mermas por motivo';

  @override
  String get noMovementsPeriod => 'Sin movimientos en este periodo.';

  @override
  String get noWastePeriod => 'Sin mermas en este periodo.';

  @override
  String get expiringLotsTitle => 'Lotes a vigilar (caducidad)';

  @override
  String get noExpiringLots => 'Ningún lote caduca en los próximos 7 días.';

  @override
  String get toReorderTitle => 'Por pedir';

  @override
  String get noAlerts => 'Ningún artículo bajo el umbral.';

  @override
  String get prepareOrder => 'Preparar el pedido';

  @override
  String get expiredShort => 'Caducado';

  @override
  String daysLeftShort(int count) {
    return 'D-$count';
  }

  @override
  String daysLeftLong(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count días de stock',
      one: '1 día de stock',
      zero: 'se agota hoy',
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
  String get expiryDate => 'Fecha de caducidad';

  @override
  String get stockEmptyHint =>
      'Crea tus artículos en la pestaña Artículos y registra el stock inicial o una recepción.';

  @override
  String get searchArticle => 'Buscar un artículo';

  @override
  String get showInactive => 'Mostrar inactivos';

  @override
  String get newArticle => 'Nuevo artículo';

  @override
  String get editArticle => 'Editar el artículo';

  @override
  String get articlesEmptyHint =>
      'Añade tus productos: verduras, carnes, bebidas, envases, preparaciones propias…';

  @override
  String get storageLabel => 'Conservación';

  @override
  String get storageAmbient => 'Ambiente';

  @override
  String get storageChilled => 'Refrigerado';

  @override
  String get storageFrozen => 'Congelado';

  @override
  String get purchaseUnitLabel => 'Unidad de compra';

  @override
  String get purchaseUnitExample => 'P. ej.: Saco de 5 kg, Caja de 12';

  @override
  String get purchaseUnitQty => 'Contenido';

  @override
  String get preferredSupplier => 'Proveedor habitual';

  @override
  String get noneLabel => 'Ninguno';

  @override
  String get shelfLifeDays => 'Vida útil';

  @override
  String get daysShort => 'días';

  @override
  String get barcodeLabel => 'Código de barras';

  @override
  String get thresholdThisBranch => 'Umbral de alerta de este local';

  @override
  String get reorderTitle => 'Pedido sugerido';

  @override
  String get reorderHint =>
      'Lo necesario para seguir por encima del umbral, según el consumo de los últimos 28 días.';

  @override
  String get nothingToReorder => 'Nada que pedir';

  @override
  String get nothingToReorderHint =>
      'Todos los artículos controlados tienen stock suficiente para el periodo elegido.';

  @override
  String get noSupplier => 'Sin proveedor habitual';

  @override
  String get noSupplierHint =>
      'Elige un proveedor habitual en la ficha del artículo para crear una orden de compra.';

  @override
  String get orderFormPdf => 'Orden de compra en PDF';

  @override
  String get createPurchaseOrder => 'Crear la orden de compra';

  @override
  String get purchaseOrderDraftCreated =>
      'Orden de compra creada como borrador en Compras.';

  @override
  String get reorderNote => 'Pedido sugerido por el stock';

  @override
  String inStockShort(String qty) {
    return 'En stock: $qty';
  }

  @override
  String get entriesFilter => 'Entradas';

  @override
  String get exitsLabel => 'Salidas';

  @override
  String get transfersFilter => 'Traspasos';

  @override
  String get adjustmentsFilter => 'Ajustes';

  @override
  String get movementsReportTitle => 'Movimientos de stock';

  @override
  String get wasteReportTitle => 'Mermas y roturas';

  @override
  String get reportValuation => 'Stock valorado';

  @override
  String get reportValuationHint =>
      'Cantidades, umbrales, coste medio y valor de cada artículo en este momento.';

  @override
  String get reportMovementsHint =>
      'Todos los movimientos del periodo, con totales por tipo.';

  @override
  String get reportWasteHint => 'Mermas del periodo con su motivo y su valor.';

  @override
  String get reportInventory => 'Inventario con diferencias';

  @override
  String get reportInventoryHint =>
      'Teórico, contado, diferencias valoradas, con firmas.';

  @override
  String get reportFoodCost => 'Coste de materia prima por plato';

  @override
  String get reportFoodCostHint =>
      'Coste, precio de venta, porcentaje del precio y margen de cada plato.';

  @override
  String get reportExpiringHint =>
      'Lotes en stock que caducan en los próximos 14 días.';

  @override
  String get generatePdf => 'Generar el PDF';

  @override
  String get noValidatedInventory => 'Aún no hay inventarios validados.';

  @override
  String get chooseInventory => 'Elegir el inventario';

  @override
  String generatedOn(String date) {
    return 'Emitido el $date';
  }

  @override
  String get articlesLabel => 'Artículos';

  @override
  String get articleLabel => 'Artículo';

  @override
  String get avgCostShort => 'Coste medio';

  @override
  String get valueLabel => 'Valor';

  @override
  String get typeLabel => 'Tipo';

  @override
  String get inventoryGains => 'Sobrantes';

  @override
  String get inventoryLosses => 'Faltantes';

  @override
  String get inventoryNet => 'Diferencia neta';

  @override
  String get theoreticalLabel => 'Teórico';

  @override
  String get countedBySignature => 'Contado por: ____________________';

  @override
  String get validatedBySignature => 'Validado por: ____________________';

  @override
  String get targetFoodCost => 'Objetivo de coste de materia prima';

  @override
  String get targetFoodCostHint =>
      'Parte máxima del precio de venta que deben representar los ingredientes de un plato (a menudo del 25 al 35 %).';

  @override
  String targetFoodCostValue(String percent) {
    return 'Objetivo de materia prima: $percent %';
  }

  @override
  String get dishesWithRecipe => 'Platos con ficha';

  @override
  String get aboveTarget => 'Por encima del objetivo';

  @override
  String get aboveTargetShort => 'demasiado caro';

  @override
  String get withoutRecipe => 'Sin ficha';

  @override
  String get recipeDefined => 'Ficha definida';

  @override
  String get dishLabel => 'Plato';

  @override
  String get costPriceShort => 'Coste';

  @override
  String get sellingPriceShort => 'Precio';

  @override
  String get foodCostShort => 'materia prima';

  @override
  String get marginShort => 'Margen';

  @override
  String get orderFormTitle => 'Orden de compra';

  @override
  String supplierLabelValue(String name) {
    return 'Proveedor: $name';
  }

  @override
  String get packagingLabel => 'Presentación';

  @override
  String get unitPriceShort => 'Precio unitario';

  @override
  String get orderFormFooter =>
      'Por favor, confirme la disponibilidad y el plazo de entrega.';

  @override
  String get accountTypeQuestion => 'Usted es:';

  @override
  String get accountTypeCustomer => 'Cliente';

  @override
  String get accountTypeCustomerHint =>
      'Descubrir restaurantes, pedir, reservar';

  @override
  String get accountTypeBusiness => 'Empresa';

  @override
  String get accountTypeBusinessHint => 'Gestionar mi restaurante y mi equipo';

  @override
  String get accountTypeRequired => 'Elija Cliente o Empresa.';

  @override
  String get accountTypeTitle => 'Bienvenido a Resto';

  @override
  String get accountTypeSub => '¿Cómo va a usar la aplicación?';

  @override
  String get continueAction => 'Continuar';

  @override
  String adVideoTooBig(String name) {
    return '$name supera los 50 MB: elige un vídeo más corto (unos 30 segundos).';
  }

  @override
  String adMediaAdded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count archivos añadidos.',
      one: '1 archivo añadido.',
    );
    return '$_temp0';
  }

  @override
  String get adNeedVideo => 'Añade un vídeo antes de publicar este formato.';

  @override
  String get adNeedMedia =>
      'Añade al menos una foto o un vídeo antes de publicar.';

  @override
  String get adNeedItems => 'Elige al menos un plato para destacar.';

  @override
  String get uploadingLabel => 'Enviando…';

  @override
  String get errorInvalidMedia =>
      'Archivo rechazado: debe venir de tu mediateca.';

  @override
  String get errorFileTooLarge => 'Archivo demasiado grande.';

  @override
  String get errorFileType =>
      'Formato de archivo no admitido (JPG, PNG, WebP, MP4, WebM, MOV).';

  @override
  String get adAddVideo => 'Añadir un vídeo';

  @override
  String get errorOutOfStock => 'Este plato está agotado por hoy.';

  @override
  String get errorInvalidRating => 'La nota debe estar entre 1 y 5.';

  @override
  String get errorInvalidAllergen => 'Alérgeno desconocido.';

  @override
  String get bestSeller => 'Más vendido';

  @override
  String get callAction => 'Llamar';

  @override
  String get writeAction => 'Escribir';

  @override
  String get categoriesLabel => 'Categorías';

  @override
  String get filtersLabel => 'Filtros';

  @override
  String get reviewsTab => 'Opiniones';

  @override
  String get infosTab => 'Info';

  @override
  String get noDishMatches => 'Ningún plato coincide con estos filtros.';

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
  String get yourCart => 'Tu carrito';

  @override
  String get coverPhoto => 'Foto de portada';

  @override
  String get coverPhotoHint =>
      'Foto grande en la parte superior de la página de tu restaurante (sala, terraza, fachada).';

  @override
  String get changePhoto => 'Cambiar la foto';

  @override
  String get itemTagsLabel => 'Etiquetas (filtros de tu carta)';

  @override
  String get itemTagsHint =>
      'Crea tus propias etiquetas: tus clientes podrán filtrar la carta con ellas. P. ej.: Picante suave, Halal, Sin alcohol, Casero.';

  @override
  String get addTagHint => 'Nueva etiqueta + Intro';

  @override
  String get errorInvalidTag => 'Una etiqueta tiene 30 caracteres como máximo.';

  @override
  String itemFavorites(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count clientes lo tienen en favoritos',
      one: '1 cliente lo tiene en favoritos',
      zero: 'Ningún cliente lo tiene en favoritos',
    );
    return '$_temp0';
  }

  @override
  String get itemSold30 => 'Ventas de los últimos 30 días';

  @override
  String get receiptOrderNo => 'Pedido N.º';

  @override
  String get receiptTicketNo => 'Ticket N.º';

  @override
  String get receiptChannel => 'Canal';

  @override
  String get receiptQtyShort => 'Cant.';

  @override
  String get receiptTotalInclTax => 'Total con impuestos';

  @override
  String get receiptTotalExclTax => 'Total sin impuestos';

  @override
  String get receiptApproved => 'Transacción aprobada';

  @override
  String receiptRef(String ref) {
    return 'Ref.: $ref';
  }

  @override
  String receiptSeeYou(String name) {
    return '¡Hasta pronto en $name!';
  }

  @override
  String get receiptRecycle => 'Por un planeta más verde, recicle este ticket.';

  @override
  String get receiptLoyaltyTitle => '¡Su fidelidad tiene recompensa!';

  @override
  String get receiptLoyaltyCaption =>
      'Escanee este código QR para acceder a su espacio de fidelidad y disfrutar de sus ventajas.';

  @override
  String get receiptPaperLabel => 'Impresora de tickets de este dispositivo';

  @override
  String get receiptPaper80 => 'Rollo de 80 mm';

  @override
  String get receiptPaper58 => 'Rollo de 58 mm';

  @override
  String get receiptPhotosLabel => 'Fotos de los platos en el ticket';

  @override
  String get receiptTestPrint => 'Imprimir un ticket de prueba';

  @override
  String get receiptTestTitle => 'Ticket de prueba';

  @override
  String get receiptHeaderSection => 'Encabezado del ticket';

  @override
  String get receiptFooterSection => 'Pie del ticket';

  @override
  String get receiptTitleLabel => 'Nombre mostrado';

  @override
  String get receiptTitleHint => 'Por defecto: el nombre de la marca';

  @override
  String get receiptSubtitleLabel => 'Subtítulo';

  @override
  String get receiptSubtitleHint => 'Ej.: Restaurante & Sabores';

  @override
  String get receiptSloganLabel => 'Eslogan';

  @override
  String get receiptSloganHint => 'Ej.: Cocina auténtica, sabores del mundo';

  @override
  String get websiteLabel => 'Sitio web';

  @override
  String get websiteHint => 'Ej.: www.mirestaurante.com';

  @override
  String get receiptQrTitleLabel => 'Título junto al código QR';

  @override
  String get receiptQrCaptionLabel => 'Texto junto al código QR';

  @override
  String get receiptFarewellLabel => 'Frase de despedida';

  @override
  String get receiptFarewellHint => 'Ej.: ¡Hasta pronto!';

  @override
  String itemLikesTip(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count me gusta',
      one: '1 me gusta',
      zero: 'Ningún me gusta',
    );
    return '$_temp0';
  }

  @override
  String get itemReviewAction => 'Opinión';

  @override
  String get itemHeartAction => 'Me encanta';

  @override
  String get itemCommentsTitle => 'Opiniones de clientes';

  @override
  String get itemVerifiedReviews => 'Opiniones con nota tras un pedido';

  @override
  String get notifStaffNewOrderTitle => 'Nuevo pedido';

  @override
  String notifStaffNewOrder(String number, String customer, String branch) {
    return 'Pedido n.º $number $customer — $branch';
  }

  @override
  String get notifStaffOrderReadyTitle => 'Pedido listo para servir';

  @override
  String notifStaffOrderReady(String number, String branch) {
    return 'Pedido n.º $number — $branch';
  }

  @override
  String get notifStaffReservationTitle => 'Nueva reserva';

  @override
  String notifStaffReservation(String name, int count, String date) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count personas',
      one: '1 persona',
    );
    return '$name · $_temp0 · $date';
  }

  @override
  String get notifStaffReviewTitle => 'Nueva opinión';

  @override
  String notifStaffReview(String author, String item) {
    return '$author sobre «$item»';
  }

  @override
  String get pushNewOrder =>
      'Notificación en el teléfono: nuevo pedido de un cliente';

  @override
  String get pushOrderReady =>
      'Notificación en el teléfono: pedido listo para servir';

  @override
  String get pushReservations => 'Notificación en el teléfono: nueva reserva';

  @override
  String get pushReviews =>
      'Notificación en el teléfono: nueva opinión sobre un plato';

  @override
  String get tablesTab => 'Mesas';

  @override
  String get tablesNow => 'Ahora';

  @override
  String get tablesLater => 'Elegir un momento';

  @override
  String get tableLegendOccupied => 'Ocupada';

  @override
  String get tableLegendReserved => 'Reservada';

  @override
  String get tableLegendChosen => 'Su elección';

  @override
  String tableFreeUntil(String time) {
    return 'Libre hasta las $time';
  }

  @override
  String tableOccupiedUntil(String time) {
    return 'Libre hacia las $time';
  }

  @override
  String tableReservedSlot(String from, String to) {
    return 'Reservada $from–$to';
  }

  @override
  String get tablesSelectHint =>
      'Toque una o varias mesas libres para reservarlas.';

  @override
  String tablesSeatsChosen(int seats, int party) {
    String _temp0 = intl.Intl.pluralLogic(
      seats,
      locale: localeName,
      other: '$seats plazas elegidas',
      one: '1 plaza elegida',
    );
    String _temp1 = intl.Intl.pluralLogic(
      party,
      locale: localeName,
      other: '$party personas',
      one: '1 persona',
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
  String get tablesEmpty => 'Este restaurante aún no ha presentado sus mesas.';

  @override
  String appVersion(String version, String build) {
    return 'Resto · versión $version ($build)';
  }

  @override
  String get dashTabOverview => 'Resumen';

  @override
  String get dashTabDishes => 'Platos';

  @override
  String get dashTabTeam => 'Equipo y servicio';

  @override
  String get dashTabFinance => 'Finanzas';

  @override
  String get coversLabel => 'Cubiertos';

  @override
  String perCoverLabel(String amount) {
    return '$amount por cubierto';
  }

  @override
  String get occupancyLabel => 'Mesas ocupadas';

  @override
  String get paymentsByMethod => 'Cobros por medio de pago';

  @override
  String get busyHours => 'Afluencia por día y hora';

  @override
  String get menuEngineering => 'Ingeniería de menú';

  @override
  String get menuEngineeringHint =>
      'Ventas × margen de cada plato, según las fichas técnicas.';

  @override
  String get engStars => 'Estrellas';

  @override
  String get engStarsHint =>
      'Muy vendidos y rentables: manténgalos destacados.';

  @override
  String get engPlowhorses => 'Populares, poco rentables';

  @override
  String get engPlowhorsesHint => 'Revise el precio o el coste.';

  @override
  String get engPuzzles => 'Rentables, poco vendidos';

  @override
  String get engPuzzlesHint =>
      'Destáquelos: foto, publicidad, recomendación del personal.';

  @override
  String get engDogs => 'A revisar';

  @override
  String get engDogsHint =>
      'Poco vendidos y poco rentables: rehacer o retirar.';

  @override
  String engNoRecipe(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count platos sin ficha técnica no están clasificados.',
      one: '1 plato sin ficha técnica no está clasificado.',
    );
    return '$_temp0';
  }

  @override
  String get slowSellers => 'Platos que se venden poco';

  @override
  String get teamPerformance => 'Rendimiento del equipo';

  @override
  String get memberLabel => 'Miembro';

  @override
  String get staffOrders => 'Pedidos';

  @override
  String get staffSales => 'Ventas';

  @override
  String get staffTips => 'Propinas';

  @override
  String get serviceTimes => 'Tiempos de servicio';

  @override
  String get serveTime => 'Llegada a la mesa';

  @override
  String get tableTime => 'Tiempo en la mesa';

  @override
  String minutesValue(int count) {
    return '$count min';
  }

  @override
  String targetMinutes(int count) {
    return 'Objetivo: $count min';
  }

  @override
  String get cancellationsTitle => 'Anulaciones';

  @override
  String cancelledOrdersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pedidos anulados',
      one: '1 pedido anulado',
      zero: 'Ningún pedido anulado',
    );
    return '$_temp0';
  }

  @override
  String cancelledItemsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count artículos anulados tras el envío',
      one: '1 artículo anulado tras el envío',
      zero: 'Ningún artículo anulado tras el envío',
    );
    return '$_temp0';
  }

  @override
  String get cancelReasonsTitle => 'Motivos más frecuentes';

  @override
  String get dashPdf => 'Informe PDF';

  @override
  String get insightsUnavailable =>
      'Los indicadores detallados aparecerán tras la actualización de la base (migración 034).';

  @override
  String get salesByDayTitle => 'Ventas por día';

  @override
  String get ordersCountLabel => 'Pedidos';

  @override
  String get financeItemLabel => 'Concepto';

  @override
  String get supplierLabel => 'Proveedor';

  @override
  String get purchaseOrderTitle => 'Orden de compra';

  @override
  String get supplierStatementTitle => 'Estado de cuenta del proveedor';

  @override
  String get dueDateLabel => 'Vencimiento';

  @override
  String get balanceDue => 'Saldo pendiente';

  @override
  String get purchasesThisMonth => 'Compras del mes';

  @override
  String openInvoicesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count facturas por pagar',
      one: '1 factura por pagar',
      zero: 'Ninguna factura por pagar',
    );
    return '$_temp0';
  }

  @override
  String get overdueInvoices => 'Facturas vencidas';

  @override
  String get dueWithinWeek => 'A pagar en 7 días';

  @override
  String get pendingPurchaseOrders => 'Pedidos en curso';

  @override
  String get paymentSchedule => 'Calendario de pagos';

  @override
  String get nothingToPay => 'Ninguna factura por pagar.';

  @override
  String get noDueDate => 'Sin vencimiento';

  @override
  String get purchasesByMonth => 'Compras por mes';

  @override
  String get topSuppliers => 'Principales proveedores (90 días)';

  @override
  String get noPurchasesYet => 'Aún no hay compras.';

  @override
  String get totalPurchased => 'Total comprado';

  @override
  String get purchaseOrderPdf => 'Orden de compra PDF';

  @override
  String recurringGenerated(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count gastos recurrentes registrados.',
      one: '1 gasto recurrente registrado.',
      zero: 'Ningún gasto que registrar.',
    );
    return '$_temp0';
  }

  @override
  String recurringDue(int count, String amount) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count gastos recurrentes por registrar este mes ($amount)',
      one: '1 gasto recurrente por registrar este mes ($amount)',
    );
    return '$_temp0';
  }

  @override
  String get generateNow => 'Registrar';

  @override
  String get expensesOfMonth => 'Gastos del mes';

  @override
  String vsLastMonth(String value) {
    return '$value respecto al mes pasado';
  }

  @override
  String get lastMonthLabel => 'Mes pasado';

  @override
  String get recurringTab => 'Recurrentes';

  @override
  String get budgetsExceeded => 'Presupuestos superados';

  @override
  String get expensesSixMonths => 'Gastos de los últimos seis meses';

  @override
  String get budgetsTab => 'Presupuestos';

  @override
  String get noBudgetsYet =>
      'Ningún presupuesto definido. Añádalos en la pestaña Presupuestos.';

  @override
  String get newRecurringExpense => 'Nuevo gasto recurrente';

  @override
  String get recurringHint =>
      'Alquiler, suscripciones, salarios…: se registran cada mes con un gesto desde el resumen.';

  @override
  String get noRecurringYet => 'Ningún gasto recurrente.';

  @override
  String everyMonthOn(int day) {
    return 'cada mes el día $day';
  }

  @override
  String get recurringExample => 'Ej.: Alquiler del local';

  @override
  String get expenseCategoryField => 'Categoría';

  @override
  String get dayOfMonthLabel => 'Día del mes';

  @override
  String get budgetsHint =>
      'Importe que no debe superarse cada mes, por categoría. Déjelo vacío para no seguir una categoría.';

  @override
  String get startTitle => 'Empezar bien';

  @override
  String startProgress(int done, int total) {
    return '$done de $total pasos hechos';
  }

  @override
  String get startProfile =>
      'Complete la ficha del restaurante (dirección, teléfono, logo)';

  @override
  String get startDishes => 'Añada sus platos y bebidas';

  @override
  String get startTables => 'Cree sus mesas';

  @override
  String get startPayments => 'Revise sus medios de pago';

  @override
  String get startTeam => 'Invite a su equipo';

  @override
  String get startPublish => 'Publique su restaurante para los clientes';

  @override
  String get hideAction => 'Ocultar';

  @override
  String get adPushNote =>
      'La notificación llega a los clientes que siguen el restaurante, pidieron allí en el último año, les gustan sus platos o anuncios, o viven a menos de 30 km. Una oferta programada se envía en su fecha de inicio.';

  @override
  String adPushAudience(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count clientes recibirán esta oferta',
      one: '1 cliente recibirá esta oferta',
      zero: 'Aún no hay clientes a quienes avisar',
    );
    return '$_temp0';
  }
}
