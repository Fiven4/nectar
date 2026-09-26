// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Nectar';

  @override
  String get cancel => 'Отмена';

  @override
  String get save => 'Сохранить';

  @override
  String get delete => 'Удалить';

  @override
  String get retry => 'Повторить';

  @override
  String get logout => 'Выйти';

  @override
  String get logoutFromAccount => 'Выйти из аккаунта';

  @override
  String get apply => 'Применить';

  @override
  String get reset => 'Сбросить';

  @override
  String get back => 'Назад';

  @override
  String get add => 'Добавить';

  @override
  String get genericError => 'Произошла ошибка. Попробуйте еще раз.';

  @override
  String get saveFailed => 'Не удалось сохранить. Попробуйте еще раз.';

  @override
  String get loadFailedCheckConnection =>
      'Не удалось загрузить данные. Проверьте соединение.';

  @override
  String get loadFailedTryLater =>
      'Не удалось загрузить данные. Попробуйте позже.';

  @override
  String get notEnoughStock => 'Больше нет в наличии';

  @override
  String get language => 'Язык';

  @override
  String get languageRussian => 'Русский';

  @override
  String get languageEnglish => 'English';

  @override
  String get selectLanguage => 'Выберите язык';

  @override
  String get navShop => 'Магазин';

  @override
  String get navCatalog => 'Каталог';

  @override
  String get navCart => 'Корзина';

  @override
  String get navProfile => 'Профиль';

  @override
  String get roleAdmin => 'Администратор';

  @override
  String get roleManager => 'Менеджер';

  @override
  String get roleCourier => 'Курьер';

  @override
  String get roleBuyer => 'Покупатель';

  @override
  String get roleGuest => 'Гость';

  @override
  String get valLoginRequired => 'Введите логин';

  @override
  String get valLoginLength => 'Длина логина от 3 до 50 символов';

  @override
  String get valLoginChars => 'Только латиница, цифры и символы ._-';

  @override
  String get valFieldRequired => 'Поле не может быть пустым';

  @override
  String get valNameLength => 'Длина от 2 до 50 символов';

  @override
  String get valNameChars => 'Только буквы, пробелы и дефисы';

  @override
  String get valEmailRequired => 'Введите email';

  @override
  String get valEmailLength => 'Email не должен превышать 100 символов';

  @override
  String get valEmailFormat => 'Неверный формат email';

  @override
  String get valPhoneRequired => 'Введите номер телефона';

  @override
  String get valPhoneFormat => 'Неверный формат номера телефона';

  @override
  String get valPasswordRequired => 'Введите пароль';

  @override
  String get valPasswordNoSpaces => 'Пароль не должен содержать пробелы';

  @override
  String get valPasswordMaxLength => 'Не более 128 символов';

  @override
  String get valPasswordMinLength => 'Минимум 6 символов';

  @override
  String get valPasswordDigit => 'Пароль должен содержать минимум одну цифру';

  @override
  String get valPasswordConfirmRequired => 'Подтвердите пароль';

  @override
  String get valPasswordMismatch => 'Пароли не совпадают';

  @override
  String valNamedFieldRequired(String fieldName) {
    return 'Поле «$fieldName» обязательно';
  }

  @override
  String valNamedFieldMaxLength(String fieldName, int maxLength) {
    return 'Поле «$fieldName» не должно превышать $maxLength символов';
  }

  @override
  String get valPriceRequired => 'Введите цену';

  @override
  String get valPricePositive => 'Цена должна быть больше 0';

  @override
  String valNamedValueRequired(String fieldName) {
    return 'Введите значение для «$fieldName»';
  }

  @override
  String valNamedRange(String fieldName, int minValue, int maxValue) {
    return 'Поле «$fieldName» должно быть в диапазоне $minValue-$maxValue';
  }

  @override
  String get valPromoRequired => 'Введите промокод';

  @override
  String get valPromoChars => 'Только латиница и цифры';

  @override
  String get valTaxIdRequired => 'Введите ИНН';

  @override
  String get valTaxIdFormat => 'ИНН должен содержать 10 или 12 цифр';

  @override
  String get valCardRequired => 'Введите номер карты';

  @override
  String get valCardLength => 'Номер карты должен содержать 16 цифр';

  @override
  String get sortDefault => 'По умолчанию';

  @override
  String get sortFreshFirst => 'Сначала свежие';

  @override
  String get sortPriceDesc => 'По убыванию цены';

  @override
  String get sortPriceAsc => 'По возрастанию цены';

  @override
  String get filtersTitle => 'Фильтры';

  @override
  String filterPrice(int from, int to) {
    return 'Цена: $from – $to ₽';
  }

  @override
  String get filterBrand => 'Бренд';

  @override
  String get filterSort => 'Сортировка';

  @override
  String get noProductsForFilters =>
      'Нет товаров, подходящих под выбранные фильтры';

  @override
  String get slotAsap => 'Как можно скорее (до 60 минут)';

  @override
  String get noDescription => 'Детальное описание товара отсутствует.';

  @override
  String get currencyRub => '₽';

  @override
  String get unitKg => 'кг';

  @override
  String get unitG => 'г';

  @override
  String get unitMl => 'мл';

  @override
  String get unitL => 'л';

  @override
  String get unitPcs => 'шт';

  @override
  String get authInvalidEmail => 'Некорректный email.';

  @override
  String get authUserDisabled => 'Этот аккаунт отключен.';

  @override
  String get authWrongCredentials => 'Неверный email или пароль.';

  @override
  String get authEmailInUse => 'Этот email уже используется.';

  @override
  String get authWeakPassword => 'Пароль слишком простой.';

  @override
  String get authNetworkError => 'Не удалось подключиться к сети.';

  @override
  String get authTooManyRequests => 'Слишком много попыток. Попробуйте позже.';

  @override
  String get authAccountDeleted => 'Этот аккаунт был удален.';

  @override
  String get authNotSignedIn => 'Пользователь не авторизован.';

  @override
  String get authWrongCurrentPassword => 'Неверный текущий пароль.';

  @override
  String get errLoginTaken => 'Пользователь с таким логином уже существует.';

  @override
  String get errLoginNotFound => 'Пользователь с таким логином не найден.';

  @override
  String get errAddressEmpty => 'Адрес не может быть пустым.';

  @override
  String get errAddressTooLong => 'Адрес не должен превышать 300 символов.';

  @override
  String get errCardLength => 'Номер карты должен содержать 16 цифр.';

  @override
  String get errPromoInvalid => 'Неверный или просроченный промокод.';

  @override
  String get errCartEmpty => 'Корзина пуста.';

  @override
  String get errDeliveryAddressRequired => 'Укажите адрес доставки.';

  @override
  String get errPaymentMethodRequired => 'Выберите способ оплаты.';

  @override
  String get errUserNotFound => 'Пользователь не найден.';

  @override
  String get errQuantityPositive =>
      'Количество товара должно быть больше нуля.';

  @override
  String errProductUnavailable(String name) {
    return 'Товар «$name» недоступен.';
  }

  @override
  String errNotEnoughStock(String name) {
    return 'Недостаточно товара «$name» на складе.';
  }

  @override
  String get errOrderNotFound => 'Заказ не найден.';

  @override
  String get errUserHasActiveOrders =>
      'Нельзя удалить пользователя с незавершенными заказами.';

  @override
  String get errCategoryNameRequired => 'Название категории обязательно.';

  @override
  String get errCategoryNameTooLong =>
      'Название категории не должно превышать 100 символов.';

  @override
  String get errCategoryDescriptionTooLong =>
      'Описание категории не должно превышать 500 символов.';

  @override
  String get errCategoryExists => 'Категория с таким названием уже существует.';

  @override
  String get errCategoryNotFound => 'Категория не найдена.';

  @override
  String get errCategoryHasProducts =>
      'Нельзя удалить категорию, к которой привязаны продукты.';

  @override
  String get errManufacturerNameRequired =>
      'Название производителя обязательно.';

  @override
  String get errManufacturerNameTooLong =>
      'Название производителя не должно превышать 100 символов.';

  @override
  String get errManufacturerExists =>
      'Производитель с таким названием уже существует.';

  @override
  String get errManufacturerNotFound => 'Производитель не найден.';

  @override
  String get errManufacturerHasProducts =>
      'Нельзя удалить производителя, к которому привязаны продукты.';

  @override
  String get errSupplierNameRequired => 'Название поставщика обязательно.';

  @override
  String get errSupplierExists => 'Поставщик с таким названием уже существует.';

  @override
  String get errSupplierNotFound => 'Поставщик не найден.';

  @override
  String get errSupplierHasSupplies =>
      'Нельзя удалить поставщика, если существуют активные поставки продуктов.';

  @override
  String get errRoleNameRequired => 'Название роли обязательно.';

  @override
  String get errRoleNameTooLong =>
      'Название роли не должно превышать 50 символов.';

  @override
  String get errRoleExists => 'Роль с таким названием уже существует.';

  @override
  String get errRoleHasUsers =>
      'Нельзя удалить роль, если к ней привязаны пользователи.';

  @override
  String get errStatusNameRequired => 'Название статуса обязательно.';

  @override
  String get errStatusNameTooLong =>
      'Название статуса не должно превышать 50 символов.';

  @override
  String get errStatusExists => 'Статус с таким названием уже существует.';

  @override
  String get errStatusInUse =>
      'Нельзя удалить статус, который используется в заказах.';

  @override
  String get errPromoCodeRequired => 'Код промокода обязателен.';

  @override
  String get errPromoCodeChars =>
      'Промокод должен содержать только латиницу и цифры.';

  @override
  String get errPromoDiscountRange =>
      'Скидка должна быть в диапазоне от 1 до 99%.';

  @override
  String get errPromoExpiryPast =>
      'Срок действия промокода не может быть в прошлом.';

  @override
  String get errPromoCodeExists => 'Промокод с таким кодом уже существует.';

  @override
  String get errPromoInActiveOrders =>
      'Нельзя удалить промокод, который применен в незавершенных заказах.';

  @override
  String get errProductNameRequired => 'Название продукта обязательно.';

  @override
  String get errProductNameTooLong =>
      'Название продукта не должно превышать 255 символов.';

  @override
  String get errProductDescriptionTooLong =>
      'Описание продукта не должно превышать 2000 символов.';

  @override
  String get errProductPricePositive => 'Цена продукта должна быть больше 0.';

  @override
  String get errProductStockRange =>
      'Количество на складе должно быть в диапазоне 0-9999.';

  @override
  String get errProductNeedsCategory =>
      'Для продукта необходимо выбрать категорию и производителя.';

  @override
  String get aboutVersion => 'Версия 1.0.0';

  @override
  String get aboutTerms => 'Условия использования';

  @override
  String get aboutPrivacy => 'Политика конфиденциальности';

  @override
  String get aboutLicenses => 'Лицензии';

  @override
  String get avatarFormatError => 'Разрешены только изображения JPEG и PNG.';

  @override
  String get avatarTooBig =>
      'Изображение слишком большое: после сжатия не более 150 КБ.';

  @override
  String get avatarUpdated => 'Аватар успешно обновлен.';

  @override
  String get avatarUploadFailed => 'Не удалось загрузить изображение.';

  @override
  String get deleteAccountTitle => 'Удалить аккаунт?';

  @override
  String get deleteAccountBody =>
      'Аккаунт будет удален, если у вас нет незавершенных заказов. Это действие нельзя отменить.';

  @override
  String get deleteAccountRecentLogin =>
      'Для удаления аккаунта нужно войти в систему заново.';

  @override
  String get deleteAccountFailed => 'Не удалось удалить аккаунт.';

  @override
  String get noEmail => 'Нет email';

  @override
  String get menuOrders => 'Заказы';

  @override
  String get menuMyDetails => 'Мои данные';

  @override
  String get menuDeliveryAddress => 'Адрес доставки';

  @override
  String get menuPaymentMethods => 'Способы оплаты';

  @override
  String get menuPromoCodes => 'Промокоды';

  @override
  String get menuChangePassword => 'Сменить пароль';

  @override
  String get menuNotifications => 'Уведомления';

  @override
  String get menuHelp => 'Помощь';

  @override
  String get menuAbout => 'О приложении';

  @override
  String get deleteAccount => 'Удалить аккаунт';

  @override
  String get addAddressTitle => 'Добавить адрес';

  @override
  String get addAddressHint => 'Введите ваш адрес (улица, дом, кв)';

  @override
  String get addressRemoveFailed => 'Не удалось удалить адрес.';

  @override
  String get addressesSignIn => 'Авторизуйтесь для просмотра адресов';

  @override
  String get addressesEmptyTitle => 'Нет сохраненных адресов';

  @override
  String get addressesEmptyBody => 'Добавьте адрес для доставки ваших покупок.';

  @override
  String get resetSentTitle => 'Письмо отправлено!';

  @override
  String resetSentBody(String email) {
    return 'Мы отправили инструкцию по сбросу пароля на почту\n$email\n\nЕсли письма нет, проверьте папку «Спам».';
  }

  @override
  String get gotIt => 'Понятно';

  @override
  String get resetPasswordTitle => 'Сброс пароля';

  @override
  String get resetPasswordInfo =>
      'Введите email, который вы указывали при регистрации. Мы пришлем ссылку для создания нового пароля.';

  @override
  String get resetEmailLabel => 'Ваш Email';

  @override
  String get resetSendButton => 'Отправить письмо';

  @override
  String get loginPanelAppBar => 'Вход в панель';

  @override
  String get loginPanelTitle => 'Вход в web-панель';

  @override
  String get loginTitle => 'Вход в Nectar';

  @override
  String get loginPanelSubtitle =>
      'Войдите под ролью администратора или менеджера.';

  @override
  String get loginSubtitle =>
      'Войдите под логином или email, чтобы работать с заказами и покупками.';

  @override
  String get loginIdentifierLabel => 'Логин или email';

  @override
  String get loginIdentifierRequired => 'Введите логин или email';

  @override
  String get loginIdentifierInvalid => 'Логин или email указан некорректно';

  @override
  String get loginIdentifierHint => 'Например, ivan_01 или user@mail.com';

  @override
  String get labelPassword => 'Пароль';

  @override
  String get passwordHint => 'Введите пароль';

  @override
  String get forgotPasswordLink => 'Забыли пароль?';

  @override
  String get signInToPanel => 'Войти в панель';

  @override
  String get signIn => 'Войти';

  @override
  String get continueWithGoogle => 'Продолжить с Google';

  @override
  String get noAccount => 'Нет аккаунта?';

  @override
  String get registerAction => 'Зарегистрироваться';

  @override
  String get panelInfoNote =>
      'Покупатели и курьеры работают через мобильное приложение. Web-панель предназначена только для ролей «Администратор» и «Менеджер».';

  @override
  String get registerTitle => 'Регистрация';

  @override
  String get registerHeading => 'Новый аккаунт покупателя';

  @override
  String get registerRoleNote =>
      'После регистрации вам автоматически будет назначена роль «Покупатель».';

  @override
  String get labelLogin => 'Логин';

  @override
  String get registerLoginHint => 'Например, ivan_venikov';

  @override
  String get labelName => 'Имя';

  @override
  String get registerNameHint => 'Ваше имя';

  @override
  String get labelPhone => 'Телефон';

  @override
  String get labelEmail => 'Email';

  @override
  String get registerPasswordHint => 'Минимум 6 символов и одна цифра';

  @override
  String get labelPasswordConfirm => 'Подтверждение пароля';

  @override
  String get registerPasswordRepeatHint => 'Повторите пароль';

  @override
  String get haveAccountSignIn => 'Уже есть аккаунт? Войти';

  @override
  String get profileLoadFailed =>
      'Не удалось загрузить профиль. Проверьте соединение.';

  @override
  String roleBlockedTitle(String roleName) {
    return 'Роль «$roleName» не может работать в мобильном приложении.';
  }

  @override
  String get roleBlockedBody =>
      'Пожалуйста, используйте веб-версию (сайт) для администрирования.';

  @override
  String get checkoutSignInRequired => 'Необходимо войти в систему.';

  @override
  String get checkoutSelectAddress => 'Выберите адрес доставки.';

  @override
  String get checkoutSelectCard =>
      'Для онлайн-оплаты выберите сохраненную карту.';

  @override
  String get checkoutFailed => 'Не удалось оформить заказ.';

  @override
  String get checkoutTitle => 'Оформление заказа';

  @override
  String get addAddressInProfile => 'Добавьте адрес в профиле';

  @override
  String get paymentMethodTitle => 'Способ оплаты';

  @override
  String get cardLabel => 'Карта';

  @override
  String get addCardInProfile => 'Добавьте карту в профиле';

  @override
  String get promoCodeLabel => 'Промокод';

  @override
  String get promoNotSelected => 'Не выбран';

  @override
  String get choose => 'Выбрать';

  @override
  String get summaryItemsTotal => 'Сумма товаров';

  @override
  String get placeOrder => 'Разместить заказ';

  @override
  String get orderSuccessTitle => 'Заказ успешно оформлен!';

  @override
  String orderSuccessBody(String number) {
    return 'Номер заказа: $number\nИстория заказа и дальнейшие уведомления будут доступны в профиле.';
  }

  @override
  String get backToShop => 'Вернуться в магазин';

  @override
  String get courierUpdateFailed =>
      'Не удалось обновить заказ. Попробуйте еще раз.';

  @override
  String get courierNotSignedIn => 'Курьер не авторизован.';

  @override
  String get courierTitle => 'Доставка';

  @override
  String get courierNoOrders => 'У вас пока нет назначенных заказов.';

  @override
  String get courierOrderDefault => 'Заказ';

  @override
  String get courierAddressMissing => 'Адрес не указан';

  @override
  String courierSlot(String slot) {
    return 'Время: $slot';
  }

  @override
  String courierCustomer(String name, String phone) {
    return 'Клиент: $name$phone';
  }

  @override
  String courierCashDue(String amount) {
    return 'К оплате наличными: $amount';
  }

  @override
  String courierStatus(String status) {
    return 'Статус: $status';
  }

  @override
  String get courierStart => 'Начать доставку';

  @override
  String get courierComplete => 'Подтвердить доставку';

  @override
  String get courierActiveTitle => 'Активные заказы';

  @override
  String get courierHistoryTitle => 'История доставок';

  @override
  String get courierNoActive =>
      'Активных заказов нет. Новые назначения появятся здесь.';

  @override
  String get courierConfirmTitle => 'Подтвердить доставку?';

  @override
  String courierConfirmBody(String number) {
    return 'Заказ $number будет отмечен как доставленный. Отменить это действие нельзя.';
  }

  @override
  String get courierCancelledNote => 'Заказ отменен, доставка не нужна.';

  @override
  String courierPayment(String method) {
    return 'Оплата: $method';
  }

  @override
  String courierTotal(String amount) {
    return 'Сумма заказа: $amount';
  }

  @override
  String get courierPhoneCopied => 'Телефон скопирован';

  @override
  String get courierItemsTitle => 'Состав заказа';

  @override
  String get detailsSaved => 'Данные успешно сохранены';

  @override
  String get detailsSaveFailed =>
      'Не удалось сохранить данные. Попробуйте еще раз.';

  @override
  String get fullName => 'Полное имя';

  @override
  String get phoneNumber => 'Номер телефона';

  @override
  String get emailReadOnly => 'Email (нельзя изменить)';

  @override
  String get faqTitle => 'Часто задаваемые вопросы';

  @override
  String get faqTrackQ => 'Как отследить мой заказ?';

  @override
  String get faqTrackA =>
      'Вы можете отследить свой заказ в разделе «Заказы» вашего профиля.';

  @override
  String get faqReturnQ => 'Как вернуть товар?';

  @override
  String get faqReturnA =>
      'Возврат можно оформить в течение 7 дней после доставки, связавшись с нашей поддержкой.';

  @override
  String get faqPaymentQ => 'Какие способы оплаты принимаются?';

  @override
  String get faqPaymentA =>
      'Мы принимаем банковские карты, Apple Pay и оплату наличными курьеру.';

  @override
  String get faqPromoQ => 'Как использовать промокоды?';

  @override
  String get faqPromoA =>
      'Введите промокод на экране корзины или в разделе «Промокоды».';

  @override
  String get categoryOther => 'Другое';

  @override
  String shareMessage(String name, String price, String link) {
    return '🍏 Смотри, что я нашел в Nectar!\n\n✨ $name — всего за $price ₽.\n\nЗаказывай прямо сейчас:\n🔗 $link';
  }

  @override
  String get paymentOnline => 'Онлайн';

  @override
  String get paymentCash => 'Наличными';

  @override
  String get userDefaultName => 'Пользователь';

  @override
  String get notificationsSignIn => 'Авторизуйтесь для просмотра уведомлений';

  @override
  String get notificationsCleared => 'Все уведомления очищены.';

  @override
  String get notificationsClearFailed => 'Не удалось очистить уведомления.';

  @override
  String get clearAll => 'Очистить все';

  @override
  String get notifPushTitle => 'Push-уведомления';

  @override
  String get notifPushSubtitle =>
      'Получать внутрисистемные уведомления по заказам';

  @override
  String get notifSmsTitle => 'SMS-уведомления';

  @override
  String get notifSmsSubtitle => 'Получать сообщения о доставке';

  @override
  String get notifEmailTitle => 'Email-уведомления';

  @override
  String get notifEmailSubtitle => 'Получать акции и напоминания по почте';

  @override
  String get notifHistoryTitle => 'История уведомлений';

  @override
  String get notifEmpty =>
      'Пока нет уведомлений. Они будут появляться автоматически при изменении статуса заказа.';

  @override
  String get notifDefaultText => 'Уведомление';

  @override
  String get onboardingSkip => 'Пропустить';

  @override
  String get onboardingNext => 'Далее';

  @override
  String get onboardingStart => 'Начать';

  @override
  String get onboarding1Title => 'Гарантия свежести';

  @override
  String get onboarding1Body =>
      'Мы тщательно отбираем овощи, фрукты, мясо и молочные продукты для вашего стола.';

  @override
  String get onboarding2Title => 'Доставка за час';

  @override
  String get onboarding2Body =>
      'Курьер привезет заказ в удобное для вас время, а статус можно отслеживать в приложении.';

  @override
  String get onboarding3Title => 'Выгодные покупки';

  @override
  String get onboarding3Body =>
      'Собирайте избранное, применяйте промокоды и оформляйте заказ в пару касаний.';

  @override
  String get myOrders => 'Мои заказы';

  @override
  String get ordersSignInRequired => 'Авторизуйтесь для просмотра заказов';

  @override
  String get ordersLoadFailed =>
      'Не удалось загрузить заказы. Попробуйте позже.';

  @override
  String get ordersEmptyTitle => 'Пока нет заказов';

  @override
  String get ordersEmptyBody => 'Когда вы сделаете заказ, он появится здесь.';

  @override
  String get startShopping => 'За покупками';

  @override
  String orderNumberFallback(String id) {
    return 'Заказ #$id';
  }

  @override
  String get orderCancelled => 'Заказ отменен';

  @override
  String get stepCreated => 'Создан';

  @override
  String get stepWithCourier => 'У курьера';

  @override
  String get stepDelivered => 'Доставлен';

  @override
  String get labelAddress => 'Адрес';

  @override
  String get notSpecified => 'Не указан';

  @override
  String get deliveryTime => 'Время доставки';

  @override
  String get orderInfoPayment => 'Оплата';

  @override
  String get notSpecifiedFem => 'Не указана';

  @override
  String get orderInfoCourier => 'Курьер';

  @override
  String get orderInfoCourierPhone => 'Телефон курьера';

  @override
  String get total => 'Итого';

  @override
  String get itemDefaultName => 'Товар';

  @override
  String quantityLabel(String quantity) {
    return 'Количество: $quantity';
  }

  @override
  String get hideOrderFailed => 'Не удалось скрыть заказ.';

  @override
  String get hideOrder => 'Скрыть из списка';

  @override
  String get orderConfirmedWaiting =>
      'Вы подтвердили получение. Ожидаем менеджера.';

  @override
  String get orderConfirmedToast => 'Вы подтвердили, что всё хорошо!';

  @override
  String get orderConfirmFailed => 'Не удалось подтвердить получение.';

  @override
  String get orderConfirmButton => 'Подтвердить, что всё хорошо';

  @override
  String get passwordChanged => 'Пароль успешно изменен.';

  @override
  String get changePasswordTitle => 'Смена пароля';

  @override
  String get currentPasswordRequired => 'Введите текущий пароль';

  @override
  String get currentPasswordLabel => 'Текущий пароль';

  @override
  String get newPasswordSame => 'Новый пароль совпадает с текущим';

  @override
  String get newPasswordLabel => 'Новый пароль';

  @override
  String get newPasswordRepeatLabel => 'Повторите новый пароль';

  @override
  String get addCardTitle => 'Добавить карту';

  @override
  String get addCardHint => 'Номер карты (16 цифр)';

  @override
  String get cardRemoveFailed => 'Не удалось удалить карту.';

  @override
  String get cardsSignIn => 'Авторизуйтесь для просмотра карт';

  @override
  String get cardsEmptyTitle => 'Нет привязанных карт';

  @override
  String get cardsEmptyBody => 'Добавьте банковскую карту для оплаты.';

  @override
  String promoApplied(String code, String percent) {
    return 'Промокод $code применен. Скидка $percent%.';
  }

  @override
  String get promoCheckFailed =>
      'Не удалось проверить промокод. Попробуйте позже.';

  @override
  String get promoRemoved => 'Промокод удален.';

  @override
  String promoCurrentlyApplied(String code, String percent) {
    return 'Сейчас применен промокод $code со скидкой $percent%.';
  }

  @override
  String get promoAvailableTitle => 'Доступные промокоды';

  @override
  String get promoNoneActive => 'Активных промокодов пока нет.';

  @override
  String promoDiscountUntil(String percent, String date) {
    return 'Скидка $percent% до $date';
  }

  @override
  String get cartTitle => 'Моя корзина';

  @override
  String get cartEmpty => 'Ваша корзина пуста';

  @override
  String cartPromoApplied(String code, String percent, String savings) {
    return 'Применен промокод $code со скидкой $percent%. Экономия: $savings';
  }

  @override
  String get summarySubtotal => 'Подытог';

  @override
  String get summaryDiscount => 'Скидка';

  @override
  String get summaryDelivery => 'Доставка';

  @override
  String get free => 'Бесплатно';

  @override
  String deliveryFeeWithThreshold(String fee, String threshold) {
    return '$fee (бесплатно от $threshold ₽)';
  }

  @override
  String get checkout => 'Оформить заказ';

  @override
  String get productsLoadFailedLater =>
      'Не удалось загрузить товары. Попробуйте позже.';

  @override
  String get categoryEmpty => 'В этой категории пока нет товаров';

  @override
  String addedPartial(int count) {
    return 'Добавлено $count шт. — это весь доступный остаток';
  }

  @override
  String addedQuantityToCart(String name, int count) {
    return '«$name» × $count добавлен в корзину';
  }

  @override
  String stockLeft(int count) {
    return 'Осталось: $count шт';
  }

  @override
  String get productDescriptionTitle => 'Описание товара';

  @override
  String get soldOut => 'Распродано';

  @override
  String addToCartWithPrice(String price) {
    return 'В корзину · $price ₽';
  }

  @override
  String get factManufacturer => 'Производитель';

  @override
  String get factCountry => 'Страна происхождения';

  @override
  String get factBestBefore => 'Срок годности до';

  @override
  String get factComposition => 'Состав';

  @override
  String get productFactsTitle => 'Характеристики';

  @override
  String get nutritionTitle => 'Пищевая ценность на 100 г';

  @override
  String get nutritionCalories => 'Ккал';

  @override
  String get nutritionProteins => 'Белки';

  @override
  String get nutritionFats => 'Жиры';

  @override
  String get nutritionCarbs => 'Углеводы';

  @override
  String get categoriesLoadFailed => 'Не удалось загрузить категории.';

  @override
  String get categoriesEmpty => 'Категории пока не добавлены.';

  @override
  String get searchFailed =>
      'Не удалось выполнить поиск. Проверьте соединение.';

  @override
  String get favoritesNothingToAdd => 'Нет товаров в наличии для добавления';

  @override
  String favoritesAdded(int count) {
    return 'Товары добавлены в корзину ($count)';
  }

  @override
  String get favoritesTitle => 'Избранное';

  @override
  String get favoritesLoadFailed => 'Не удалось загрузить избранное.';

  @override
  String get favoritesEmpty => 'У вас пока нет любимых товаров ❤️';

  @override
  String get addAllToCart => 'В корзину всё';

  @override
  String get shopLocation => 'Москва, Россия';

  @override
  String get searchHint => 'Поиск по магазину';

  @override
  String get productsLoadFailedConnection =>
      'Не удалось загрузить товары. Проверьте соединение.';

  @override
  String get noProductsInDatabase => 'Товары отсутствуют в базе данных.';

  @override
  String get nothingFound => 'По вашему запросу ничего не найдено';

  @override
  String get promoBannerTitle => 'Скидка 20% на первый заказ';

  @override
  String get promoBannerCode => 'Промокод NECTAR20';

  @override
  String get popular => 'Популярное';

  @override
  String get seeAll => 'Все';

  @override
  String get splashBrand => 'нектар';

  @override
  String get splashTagline => 'онлайн магазин';

  @override
  String get statusNew => 'Новый';

  @override
  String get statusProcessing => 'В сборке';

  @override
  String get statusAssigned => 'Передан курьеру';

  @override
  String get statusDelivering => 'В пути';

  @override
  String get statusDelivered => 'Доставлен';

  @override
  String get statusCancelled => 'Отменен';

  @override
  String addedToCart(String name) {
    return '«$name» добавлен в корзину';
  }

  @override
  String noMoreStockNamed(String name) {
    return 'Больше нет в наличии: $name';
  }

  @override
  String get outOfStock => 'Нет в наличии';

  @override
  String get reseedTitle => 'Перезалить базу товаров?';

  @override
  String get reseedBody =>
      'Все текущие товары будут удалены и заменены стартовым каталогом (69 товаров, 9 категорий). Это действие нельзя отменить.';

  @override
  String get reseedConfirm => 'Перезалить';

  @override
  String get reseedLoading => 'Загружаем товары...';

  @override
  String get reseedDone => 'База товаров успешно обновлена!';

  @override
  String get reseedFailed => 'Не удалось обновить базу товаров.';

  @override
  String get adminHome => 'Главная';

  @override
  String get sectionInDevelopment => 'Раздел в разработке';

  @override
  String get adminDashboardTitle => 'Панель управления';

  @override
  String get adminNewOrders => 'Новые заказы';

  @override
  String get adminActive => 'Активные';

  @override
  String get adminProducts => 'Товары';

  @override
  String get adminInCatalog => 'В каталоге';

  @override
  String get adminQuickActions => 'Быстрые действия';

  @override
  String get adminReseedButton => 'Перезалить базу товаров (Сброс)';

  @override
  String get adminReseedHint =>
      'Загружает стартовый каталог с фотографиями, описанием, составом и пищевой ценностью.';

  @override
  String get adminOrdersTitle => 'Управление заказами';

  @override
  String get adminNoOrders => 'Нет заказов';

  @override
  String get adminNoName => 'Без имени';

  @override
  String get adminCourierRequired =>
      'Ошибка: нельзя перевести заказ в статус «В пути» или «Доставлен», пока не назначен курьер!';

  @override
  String get adminOrderUpdated => 'Заказ успешно обновлен!';

  @override
  String get adminOrderUpdateFailed => 'Не удалось обновить заказ.';

  @override
  String adminCustomer(String name) {
    return 'Клиент: $name';
  }

  @override
  String adminAddress(String address) {
    return 'Адрес: $address';
  }

  @override
  String adminPhone(String phone) {
    return 'Телефон: $phone';
  }

  @override
  String adminDeliverySlot(String slot) {
    return 'Время доставки: $slot';
  }

  @override
  String adminAmount(String amount) {
    return 'Сумма: ₽$amount';
  }

  @override
  String get adminCourierLabel => 'Курьер:';

  @override
  String get notAssigned => 'Не назначен';

  @override
  String get adminStatusLabel => 'Статус:';

  @override
  String get webBlockedTitle =>
      'Для оформления заказов скачайте наше приложение';

  @override
  String webBlockedBody(String roleName) {
    return 'Вы вошли как «$roleName». Данный веб-сайт предназначен только для управления магазином (для администраторов).\n\nПожалуйста, установите Nectar на свой телефон, чтобы совершать покупки.';
  }

  @override
  String get landingForCustomers => 'Покупателям';

  @override
  String get landingAbout => 'О компании';

  @override
  String get landingStaffLogin => 'Вход для сотрудников';

  @override
  String get landingBadge => '🚀 Доставка за 60 минут';

  @override
  String get landingHeadline => 'Свежие продукты\nс доставкой на дом';

  @override
  String get landingBody =>
      'Заказывайте любимые овощи, фрукты, мясо и молочные продукты. Мы тщательно отбираем товары и доставляем их прямо к вашей двери.';

  @override
  String get landingDownload => 'Скачайте наше приложение:';

  @override
  String get landingFreshOnly => 'Только\nсвежее';

  @override
  String get landingDownloadIn => 'Скачать в';
}
