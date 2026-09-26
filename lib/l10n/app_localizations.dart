import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';

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
    Locale('en'),
    Locale('ru'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In ru, this message translates to:
  /// **'Nectar'**
  String get appTitle;

  /// No description provided for @cancel.
  ///
  /// In ru, this message translates to:
  /// **'Отмена'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In ru, this message translates to:
  /// **'Сохранить'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In ru, this message translates to:
  /// **'Удалить'**
  String get delete;

  /// No description provided for @retry.
  ///
  /// In ru, this message translates to:
  /// **'Повторить'**
  String get retry;

  /// No description provided for @logout.
  ///
  /// In ru, this message translates to:
  /// **'Выйти'**
  String get logout;

  /// No description provided for @logoutFromAccount.
  ///
  /// In ru, this message translates to:
  /// **'Выйти из аккаунта'**
  String get logoutFromAccount;

  /// No description provided for @apply.
  ///
  /// In ru, this message translates to:
  /// **'Применить'**
  String get apply;

  /// No description provided for @reset.
  ///
  /// In ru, this message translates to:
  /// **'Сбросить'**
  String get reset;

  /// No description provided for @back.
  ///
  /// In ru, this message translates to:
  /// **'Назад'**
  String get back;

  /// No description provided for @add.
  ///
  /// In ru, this message translates to:
  /// **'Добавить'**
  String get add;

  /// No description provided for @genericError.
  ///
  /// In ru, this message translates to:
  /// **'Произошла ошибка. Попробуйте еще раз.'**
  String get genericError;

  /// No description provided for @saveFailed.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось сохранить. Попробуйте еще раз.'**
  String get saveFailed;

  /// No description provided for @loadFailedCheckConnection.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось загрузить данные. Проверьте соединение.'**
  String get loadFailedCheckConnection;

  /// No description provided for @loadFailedTryLater.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось загрузить данные. Попробуйте позже.'**
  String get loadFailedTryLater;

  /// No description provided for @notEnoughStock.
  ///
  /// In ru, this message translates to:
  /// **'Больше нет в наличии'**
  String get notEnoughStock;

  /// No description provided for @language.
  ///
  /// In ru, this message translates to:
  /// **'Язык'**
  String get language;

  /// No description provided for @languageRussian.
  ///
  /// In ru, this message translates to:
  /// **'Русский'**
  String get languageRussian;

  /// No description provided for @languageEnglish.
  ///
  /// In ru, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @selectLanguage.
  ///
  /// In ru, this message translates to:
  /// **'Выберите язык'**
  String get selectLanguage;

  /// No description provided for @navShop.
  ///
  /// In ru, this message translates to:
  /// **'Магазин'**
  String get navShop;

  /// No description provided for @navCatalog.
  ///
  /// In ru, this message translates to:
  /// **'Каталог'**
  String get navCatalog;

  /// No description provided for @navCart.
  ///
  /// In ru, this message translates to:
  /// **'Корзина'**
  String get navCart;

  /// No description provided for @navProfile.
  ///
  /// In ru, this message translates to:
  /// **'Профиль'**
  String get navProfile;

  /// No description provided for @roleAdmin.
  ///
  /// In ru, this message translates to:
  /// **'Администратор'**
  String get roleAdmin;

  /// No description provided for @roleManager.
  ///
  /// In ru, this message translates to:
  /// **'Менеджер'**
  String get roleManager;

  /// No description provided for @roleCourier.
  ///
  /// In ru, this message translates to:
  /// **'Курьер'**
  String get roleCourier;

  /// No description provided for @roleBuyer.
  ///
  /// In ru, this message translates to:
  /// **'Покупатель'**
  String get roleBuyer;

  /// No description provided for @roleGuest.
  ///
  /// In ru, this message translates to:
  /// **'Гость'**
  String get roleGuest;

  /// No description provided for @valLoginRequired.
  ///
  /// In ru, this message translates to:
  /// **'Введите логин'**
  String get valLoginRequired;

  /// No description provided for @valLoginLength.
  ///
  /// In ru, this message translates to:
  /// **'Длина логина от 3 до 50 символов'**
  String get valLoginLength;

  /// No description provided for @valLoginChars.
  ///
  /// In ru, this message translates to:
  /// **'Только латиница, цифры и символы ._-'**
  String get valLoginChars;

  /// No description provided for @valFieldRequired.
  ///
  /// In ru, this message translates to:
  /// **'Поле не может быть пустым'**
  String get valFieldRequired;

  /// No description provided for @valNameLength.
  ///
  /// In ru, this message translates to:
  /// **'Длина от 2 до 50 символов'**
  String get valNameLength;

  /// No description provided for @valNameChars.
  ///
  /// In ru, this message translates to:
  /// **'Только буквы, пробелы и дефисы'**
  String get valNameChars;

  /// No description provided for @valEmailRequired.
  ///
  /// In ru, this message translates to:
  /// **'Введите email'**
  String get valEmailRequired;

  /// No description provided for @valEmailLength.
  ///
  /// In ru, this message translates to:
  /// **'Email не должен превышать 100 символов'**
  String get valEmailLength;

  /// No description provided for @valEmailFormat.
  ///
  /// In ru, this message translates to:
  /// **'Неверный формат email'**
  String get valEmailFormat;

  /// No description provided for @valPhoneRequired.
  ///
  /// In ru, this message translates to:
  /// **'Введите номер телефона'**
  String get valPhoneRequired;

  /// No description provided for @valPhoneFormat.
  ///
  /// In ru, this message translates to:
  /// **'Неверный формат номера телефона'**
  String get valPhoneFormat;

  /// No description provided for @valPasswordRequired.
  ///
  /// In ru, this message translates to:
  /// **'Введите пароль'**
  String get valPasswordRequired;

  /// No description provided for @valPasswordNoSpaces.
  ///
  /// In ru, this message translates to:
  /// **'Пароль не должен содержать пробелы'**
  String get valPasswordNoSpaces;

  /// No description provided for @valPasswordMaxLength.
  ///
  /// In ru, this message translates to:
  /// **'Не более 128 символов'**
  String get valPasswordMaxLength;

  /// No description provided for @valPasswordMinLength.
  ///
  /// In ru, this message translates to:
  /// **'Минимум 6 символов'**
  String get valPasswordMinLength;

  /// No description provided for @valPasswordDigit.
  ///
  /// In ru, this message translates to:
  /// **'Пароль должен содержать минимум одну цифру'**
  String get valPasswordDigit;

  /// No description provided for @valPasswordConfirmRequired.
  ///
  /// In ru, this message translates to:
  /// **'Подтвердите пароль'**
  String get valPasswordConfirmRequired;

  /// No description provided for @valPasswordMismatch.
  ///
  /// In ru, this message translates to:
  /// **'Пароли не совпадают'**
  String get valPasswordMismatch;

  /// No description provided for @valNamedFieldRequired.
  ///
  /// In ru, this message translates to:
  /// **'Поле «{fieldName}» обязательно'**
  String valNamedFieldRequired(String fieldName);

  /// No description provided for @valNamedFieldMaxLength.
  ///
  /// In ru, this message translates to:
  /// **'Поле «{fieldName}» не должно превышать {maxLength} символов'**
  String valNamedFieldMaxLength(String fieldName, int maxLength);

  /// No description provided for @valPriceRequired.
  ///
  /// In ru, this message translates to:
  /// **'Введите цену'**
  String get valPriceRequired;

  /// No description provided for @valPricePositive.
  ///
  /// In ru, this message translates to:
  /// **'Цена должна быть больше 0'**
  String get valPricePositive;

  /// No description provided for @valNamedValueRequired.
  ///
  /// In ru, this message translates to:
  /// **'Введите значение для «{fieldName}»'**
  String valNamedValueRequired(String fieldName);

  /// No description provided for @valNamedRange.
  ///
  /// In ru, this message translates to:
  /// **'Поле «{fieldName}» должно быть в диапазоне {minValue}-{maxValue}'**
  String valNamedRange(String fieldName, int minValue, int maxValue);

  /// No description provided for @valPromoRequired.
  ///
  /// In ru, this message translates to:
  /// **'Введите промокод'**
  String get valPromoRequired;

  /// No description provided for @valPromoChars.
  ///
  /// In ru, this message translates to:
  /// **'Только латиница и цифры'**
  String get valPromoChars;

  /// No description provided for @valTaxIdRequired.
  ///
  /// In ru, this message translates to:
  /// **'Введите ИНН'**
  String get valTaxIdRequired;

  /// No description provided for @valTaxIdFormat.
  ///
  /// In ru, this message translates to:
  /// **'ИНН должен содержать 10 или 12 цифр'**
  String get valTaxIdFormat;

  /// No description provided for @valCardRequired.
  ///
  /// In ru, this message translates to:
  /// **'Введите номер карты'**
  String get valCardRequired;

  /// No description provided for @valCardLength.
  ///
  /// In ru, this message translates to:
  /// **'Номер карты должен содержать 16 цифр'**
  String get valCardLength;

  /// No description provided for @sortDefault.
  ///
  /// In ru, this message translates to:
  /// **'По умолчанию'**
  String get sortDefault;

  /// No description provided for @sortFreshFirst.
  ///
  /// In ru, this message translates to:
  /// **'Сначала свежие'**
  String get sortFreshFirst;

  /// No description provided for @sortPriceDesc.
  ///
  /// In ru, this message translates to:
  /// **'По убыванию цены'**
  String get sortPriceDesc;

  /// No description provided for @sortPriceAsc.
  ///
  /// In ru, this message translates to:
  /// **'По возрастанию цены'**
  String get sortPriceAsc;

  /// No description provided for @filtersTitle.
  ///
  /// In ru, this message translates to:
  /// **'Фильтры'**
  String get filtersTitle;

  /// No description provided for @filterPrice.
  ///
  /// In ru, this message translates to:
  /// **'Цена: {from} – {to} ₽'**
  String filterPrice(int from, int to);

  /// No description provided for @filterBrand.
  ///
  /// In ru, this message translates to:
  /// **'Бренд'**
  String get filterBrand;

  /// No description provided for @filterSort.
  ///
  /// In ru, this message translates to:
  /// **'Сортировка'**
  String get filterSort;

  /// No description provided for @noProductsForFilters.
  ///
  /// In ru, this message translates to:
  /// **'Нет товаров, подходящих под выбранные фильтры'**
  String get noProductsForFilters;

  /// No description provided for @slotAsap.
  ///
  /// In ru, this message translates to:
  /// **'Как можно скорее (до 60 минут)'**
  String get slotAsap;

  /// No description provided for @noDescription.
  ///
  /// In ru, this message translates to:
  /// **'Детальное описание товара отсутствует.'**
  String get noDescription;

  /// No description provided for @currencyRub.
  ///
  /// In ru, this message translates to:
  /// **'₽'**
  String get currencyRub;

  /// No description provided for @unitKg.
  ///
  /// In ru, this message translates to:
  /// **'кг'**
  String get unitKg;

  /// No description provided for @unitG.
  ///
  /// In ru, this message translates to:
  /// **'г'**
  String get unitG;

  /// No description provided for @unitMl.
  ///
  /// In ru, this message translates to:
  /// **'мл'**
  String get unitMl;

  /// No description provided for @unitL.
  ///
  /// In ru, this message translates to:
  /// **'л'**
  String get unitL;

  /// No description provided for @unitPcs.
  ///
  /// In ru, this message translates to:
  /// **'шт'**
  String get unitPcs;

  /// No description provided for @authInvalidEmail.
  ///
  /// In ru, this message translates to:
  /// **'Некорректный email.'**
  String get authInvalidEmail;

  /// No description provided for @authUserDisabled.
  ///
  /// In ru, this message translates to:
  /// **'Этот аккаунт отключен.'**
  String get authUserDisabled;

  /// No description provided for @authWrongCredentials.
  ///
  /// In ru, this message translates to:
  /// **'Неверный email или пароль.'**
  String get authWrongCredentials;

  /// No description provided for @authEmailInUse.
  ///
  /// In ru, this message translates to:
  /// **'Этот email уже используется.'**
  String get authEmailInUse;

  /// No description provided for @authWeakPassword.
  ///
  /// In ru, this message translates to:
  /// **'Пароль слишком простой.'**
  String get authWeakPassword;

  /// No description provided for @authNetworkError.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось подключиться к сети.'**
  String get authNetworkError;

  /// No description provided for @authTooManyRequests.
  ///
  /// In ru, this message translates to:
  /// **'Слишком много попыток. Попробуйте позже.'**
  String get authTooManyRequests;

  /// No description provided for @authAccountDeleted.
  ///
  /// In ru, this message translates to:
  /// **'Этот аккаунт был удален.'**
  String get authAccountDeleted;

  /// No description provided for @authNotSignedIn.
  ///
  /// In ru, this message translates to:
  /// **'Пользователь не авторизован.'**
  String get authNotSignedIn;

  /// No description provided for @authWrongCurrentPassword.
  ///
  /// In ru, this message translates to:
  /// **'Неверный текущий пароль.'**
  String get authWrongCurrentPassword;

  /// No description provided for @errLoginTaken.
  ///
  /// In ru, this message translates to:
  /// **'Пользователь с таким логином уже существует.'**
  String get errLoginTaken;

  /// No description provided for @errLoginNotFound.
  ///
  /// In ru, this message translates to:
  /// **'Пользователь с таким логином не найден.'**
  String get errLoginNotFound;

  /// No description provided for @errAddressEmpty.
  ///
  /// In ru, this message translates to:
  /// **'Адрес не может быть пустым.'**
  String get errAddressEmpty;

  /// No description provided for @errAddressTooLong.
  ///
  /// In ru, this message translates to:
  /// **'Адрес не должен превышать 300 символов.'**
  String get errAddressTooLong;

  /// No description provided for @errCardLength.
  ///
  /// In ru, this message translates to:
  /// **'Номер карты должен содержать 16 цифр.'**
  String get errCardLength;

  /// No description provided for @errPromoInvalid.
  ///
  /// In ru, this message translates to:
  /// **'Неверный или просроченный промокод.'**
  String get errPromoInvalid;

  /// No description provided for @errCartEmpty.
  ///
  /// In ru, this message translates to:
  /// **'Корзина пуста.'**
  String get errCartEmpty;

  /// No description provided for @errDeliveryAddressRequired.
  ///
  /// In ru, this message translates to:
  /// **'Укажите адрес доставки.'**
  String get errDeliveryAddressRequired;

  /// No description provided for @errPaymentMethodRequired.
  ///
  /// In ru, this message translates to:
  /// **'Выберите способ оплаты.'**
  String get errPaymentMethodRequired;

  /// No description provided for @errUserNotFound.
  ///
  /// In ru, this message translates to:
  /// **'Пользователь не найден.'**
  String get errUserNotFound;

  /// No description provided for @errQuantityPositive.
  ///
  /// In ru, this message translates to:
  /// **'Количество товара должно быть больше нуля.'**
  String get errQuantityPositive;

  /// No description provided for @errProductUnavailable.
  ///
  /// In ru, this message translates to:
  /// **'Товар «{name}» недоступен.'**
  String errProductUnavailable(String name);

  /// No description provided for @errNotEnoughStock.
  ///
  /// In ru, this message translates to:
  /// **'Недостаточно товара «{name}» на складе.'**
  String errNotEnoughStock(String name);

  /// No description provided for @errOrderNotFound.
  ///
  /// In ru, this message translates to:
  /// **'Заказ не найден.'**
  String get errOrderNotFound;

  /// No description provided for @errUserHasActiveOrders.
  ///
  /// In ru, this message translates to:
  /// **'Нельзя удалить пользователя с незавершенными заказами.'**
  String get errUserHasActiveOrders;

  /// No description provided for @errCategoryNameRequired.
  ///
  /// In ru, this message translates to:
  /// **'Название категории обязательно.'**
  String get errCategoryNameRequired;

  /// No description provided for @errCategoryNameTooLong.
  ///
  /// In ru, this message translates to:
  /// **'Название категории не должно превышать 100 символов.'**
  String get errCategoryNameTooLong;

  /// No description provided for @errCategoryDescriptionTooLong.
  ///
  /// In ru, this message translates to:
  /// **'Описание категории не должно превышать 500 символов.'**
  String get errCategoryDescriptionTooLong;

  /// No description provided for @errCategoryExists.
  ///
  /// In ru, this message translates to:
  /// **'Категория с таким названием уже существует.'**
  String get errCategoryExists;

  /// No description provided for @errCategoryNotFound.
  ///
  /// In ru, this message translates to:
  /// **'Категория не найдена.'**
  String get errCategoryNotFound;

  /// No description provided for @errCategoryHasProducts.
  ///
  /// In ru, this message translates to:
  /// **'Нельзя удалить категорию, к которой привязаны продукты.'**
  String get errCategoryHasProducts;

  /// No description provided for @errManufacturerNameRequired.
  ///
  /// In ru, this message translates to:
  /// **'Название производителя обязательно.'**
  String get errManufacturerNameRequired;

  /// No description provided for @errManufacturerNameTooLong.
  ///
  /// In ru, this message translates to:
  /// **'Название производителя не должно превышать 100 символов.'**
  String get errManufacturerNameTooLong;

  /// No description provided for @errManufacturerExists.
  ///
  /// In ru, this message translates to:
  /// **'Производитель с таким названием уже существует.'**
  String get errManufacturerExists;

  /// No description provided for @errManufacturerNotFound.
  ///
  /// In ru, this message translates to:
  /// **'Производитель не найден.'**
  String get errManufacturerNotFound;

  /// No description provided for @errManufacturerHasProducts.
  ///
  /// In ru, this message translates to:
  /// **'Нельзя удалить производителя, к которому привязаны продукты.'**
  String get errManufacturerHasProducts;

  /// No description provided for @errSupplierNameRequired.
  ///
  /// In ru, this message translates to:
  /// **'Название поставщика обязательно.'**
  String get errSupplierNameRequired;

  /// No description provided for @errSupplierExists.
  ///
  /// In ru, this message translates to:
  /// **'Поставщик с таким названием уже существует.'**
  String get errSupplierExists;

  /// No description provided for @errSupplierNotFound.
  ///
  /// In ru, this message translates to:
  /// **'Поставщик не найден.'**
  String get errSupplierNotFound;

  /// No description provided for @errSupplierHasSupplies.
  ///
  /// In ru, this message translates to:
  /// **'Нельзя удалить поставщика, если существуют активные поставки продуктов.'**
  String get errSupplierHasSupplies;

  /// No description provided for @errRoleNameRequired.
  ///
  /// In ru, this message translates to:
  /// **'Название роли обязательно.'**
  String get errRoleNameRequired;

  /// No description provided for @errRoleNameTooLong.
  ///
  /// In ru, this message translates to:
  /// **'Название роли не должно превышать 50 символов.'**
  String get errRoleNameTooLong;

  /// No description provided for @errRoleExists.
  ///
  /// In ru, this message translates to:
  /// **'Роль с таким названием уже существует.'**
  String get errRoleExists;

  /// No description provided for @errRoleHasUsers.
  ///
  /// In ru, this message translates to:
  /// **'Нельзя удалить роль, если к ней привязаны пользователи.'**
  String get errRoleHasUsers;

  /// No description provided for @errStatusNameRequired.
  ///
  /// In ru, this message translates to:
  /// **'Название статуса обязательно.'**
  String get errStatusNameRequired;

  /// No description provided for @errStatusNameTooLong.
  ///
  /// In ru, this message translates to:
  /// **'Название статуса не должно превышать 50 символов.'**
  String get errStatusNameTooLong;

  /// No description provided for @errStatusExists.
  ///
  /// In ru, this message translates to:
  /// **'Статус с таким названием уже существует.'**
  String get errStatusExists;

  /// No description provided for @errStatusInUse.
  ///
  /// In ru, this message translates to:
  /// **'Нельзя удалить статус, который используется в заказах.'**
  String get errStatusInUse;

  /// No description provided for @errPromoCodeRequired.
  ///
  /// In ru, this message translates to:
  /// **'Код промокода обязателен.'**
  String get errPromoCodeRequired;

  /// No description provided for @errPromoCodeChars.
  ///
  /// In ru, this message translates to:
  /// **'Промокод должен содержать только латиницу и цифры.'**
  String get errPromoCodeChars;

  /// No description provided for @errPromoDiscountRange.
  ///
  /// In ru, this message translates to:
  /// **'Скидка должна быть в диапазоне от 1 до 99%.'**
  String get errPromoDiscountRange;

  /// No description provided for @errPromoExpiryPast.
  ///
  /// In ru, this message translates to:
  /// **'Срок действия промокода не может быть в прошлом.'**
  String get errPromoExpiryPast;

  /// No description provided for @errPromoCodeExists.
  ///
  /// In ru, this message translates to:
  /// **'Промокод с таким кодом уже существует.'**
  String get errPromoCodeExists;

  /// No description provided for @errPromoInActiveOrders.
  ///
  /// In ru, this message translates to:
  /// **'Нельзя удалить промокод, который применен в незавершенных заказах.'**
  String get errPromoInActiveOrders;

  /// No description provided for @errProductNameRequired.
  ///
  /// In ru, this message translates to:
  /// **'Название продукта обязательно.'**
  String get errProductNameRequired;

  /// No description provided for @errProductNameTooLong.
  ///
  /// In ru, this message translates to:
  /// **'Название продукта не должно превышать 255 символов.'**
  String get errProductNameTooLong;

  /// No description provided for @errProductDescriptionTooLong.
  ///
  /// In ru, this message translates to:
  /// **'Описание продукта не должно превышать 2000 символов.'**
  String get errProductDescriptionTooLong;

  /// No description provided for @errProductPricePositive.
  ///
  /// In ru, this message translates to:
  /// **'Цена продукта должна быть больше 0.'**
  String get errProductPricePositive;

  /// No description provided for @errProductStockRange.
  ///
  /// In ru, this message translates to:
  /// **'Количество на складе должно быть в диапазоне 0-9999.'**
  String get errProductStockRange;

  /// No description provided for @errProductNeedsCategory.
  ///
  /// In ru, this message translates to:
  /// **'Для продукта необходимо выбрать категорию и производителя.'**
  String get errProductNeedsCategory;

  /// No description provided for @aboutVersion.
  ///
  /// In ru, this message translates to:
  /// **'Версия 1.0.0'**
  String get aboutVersion;

  /// No description provided for @aboutTerms.
  ///
  /// In ru, this message translates to:
  /// **'Условия использования'**
  String get aboutTerms;

  /// No description provided for @aboutPrivacy.
  ///
  /// In ru, this message translates to:
  /// **'Политика конфиденциальности'**
  String get aboutPrivacy;

  /// No description provided for @aboutLicenses.
  ///
  /// In ru, this message translates to:
  /// **'Лицензии'**
  String get aboutLicenses;

  /// No description provided for @avatarFormatError.
  ///
  /// In ru, this message translates to:
  /// **'Разрешены только изображения JPEG и PNG.'**
  String get avatarFormatError;

  /// No description provided for @avatarTooBig.
  ///
  /// In ru, this message translates to:
  /// **'Изображение слишком большое: после сжатия не более 150 КБ.'**
  String get avatarTooBig;

  /// No description provided for @avatarUpdated.
  ///
  /// In ru, this message translates to:
  /// **'Аватар успешно обновлен.'**
  String get avatarUpdated;

  /// No description provided for @avatarUploadFailed.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось загрузить изображение.'**
  String get avatarUploadFailed;

  /// No description provided for @deleteAccountTitle.
  ///
  /// In ru, this message translates to:
  /// **'Удалить аккаунт?'**
  String get deleteAccountTitle;

  /// No description provided for @deleteAccountBody.
  ///
  /// In ru, this message translates to:
  /// **'Аккаунт будет удален, если у вас нет незавершенных заказов. Это действие нельзя отменить.'**
  String get deleteAccountBody;

  /// No description provided for @deleteAccountRecentLogin.
  ///
  /// In ru, this message translates to:
  /// **'Для удаления аккаунта нужно войти в систему заново.'**
  String get deleteAccountRecentLogin;

  /// No description provided for @deleteAccountFailed.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось удалить аккаунт.'**
  String get deleteAccountFailed;

  /// No description provided for @noEmail.
  ///
  /// In ru, this message translates to:
  /// **'Нет email'**
  String get noEmail;

  /// No description provided for @menuOrders.
  ///
  /// In ru, this message translates to:
  /// **'Заказы'**
  String get menuOrders;

  /// No description provided for @menuMyDetails.
  ///
  /// In ru, this message translates to:
  /// **'Мои данные'**
  String get menuMyDetails;

  /// No description provided for @menuDeliveryAddress.
  ///
  /// In ru, this message translates to:
  /// **'Адрес доставки'**
  String get menuDeliveryAddress;

  /// No description provided for @menuPaymentMethods.
  ///
  /// In ru, this message translates to:
  /// **'Способы оплаты'**
  String get menuPaymentMethods;

  /// No description provided for @menuPromoCodes.
  ///
  /// In ru, this message translates to:
  /// **'Промокоды'**
  String get menuPromoCodes;

  /// No description provided for @menuChangePassword.
  ///
  /// In ru, this message translates to:
  /// **'Сменить пароль'**
  String get menuChangePassword;

  /// No description provided for @menuNotifications.
  ///
  /// In ru, this message translates to:
  /// **'Уведомления'**
  String get menuNotifications;

  /// No description provided for @menuHelp.
  ///
  /// In ru, this message translates to:
  /// **'Помощь'**
  String get menuHelp;

  /// No description provided for @menuAbout.
  ///
  /// In ru, this message translates to:
  /// **'О приложении'**
  String get menuAbout;

  /// No description provided for @deleteAccount.
  ///
  /// In ru, this message translates to:
  /// **'Удалить аккаунт'**
  String get deleteAccount;

  /// No description provided for @addAddressTitle.
  ///
  /// In ru, this message translates to:
  /// **'Добавить адрес'**
  String get addAddressTitle;

  /// No description provided for @addAddressHint.
  ///
  /// In ru, this message translates to:
  /// **'Введите ваш адрес (улица, дом, кв)'**
  String get addAddressHint;

  /// No description provided for @addressRemoveFailed.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось удалить адрес.'**
  String get addressRemoveFailed;

  /// No description provided for @addressesSignIn.
  ///
  /// In ru, this message translates to:
  /// **'Авторизуйтесь для просмотра адресов'**
  String get addressesSignIn;

  /// No description provided for @addressesEmptyTitle.
  ///
  /// In ru, this message translates to:
  /// **'Нет сохраненных адресов'**
  String get addressesEmptyTitle;

  /// No description provided for @addressesEmptyBody.
  ///
  /// In ru, this message translates to:
  /// **'Добавьте адрес для доставки ваших покупок.'**
  String get addressesEmptyBody;

  /// No description provided for @resetSentTitle.
  ///
  /// In ru, this message translates to:
  /// **'Письмо отправлено!'**
  String get resetSentTitle;

  /// No description provided for @resetSentBody.
  ///
  /// In ru, this message translates to:
  /// **'Мы отправили инструкцию по сбросу пароля на почту\n{email}\n\nЕсли письма нет, проверьте папку «Спам».'**
  String resetSentBody(String email);

  /// No description provided for @gotIt.
  ///
  /// In ru, this message translates to:
  /// **'Понятно'**
  String get gotIt;

  /// No description provided for @resetPasswordTitle.
  ///
  /// In ru, this message translates to:
  /// **'Сброс пароля'**
  String get resetPasswordTitle;

  /// No description provided for @resetPasswordInfo.
  ///
  /// In ru, this message translates to:
  /// **'Введите email, который вы указывали при регистрации. Мы пришлем ссылку для создания нового пароля.'**
  String get resetPasswordInfo;

  /// No description provided for @resetEmailLabel.
  ///
  /// In ru, this message translates to:
  /// **'Ваш Email'**
  String get resetEmailLabel;

  /// No description provided for @resetSendButton.
  ///
  /// In ru, this message translates to:
  /// **'Отправить письмо'**
  String get resetSendButton;

  /// No description provided for @loginPanelAppBar.
  ///
  /// In ru, this message translates to:
  /// **'Вход в панель'**
  String get loginPanelAppBar;

  /// No description provided for @loginPanelTitle.
  ///
  /// In ru, this message translates to:
  /// **'Вход в web-панель'**
  String get loginPanelTitle;

  /// No description provided for @loginTitle.
  ///
  /// In ru, this message translates to:
  /// **'Вход в Nectar'**
  String get loginTitle;

  /// No description provided for @loginPanelSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Войдите под ролью администратора или менеджера.'**
  String get loginPanelSubtitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Войдите под логином или email, чтобы работать с заказами и покупками.'**
  String get loginSubtitle;

  /// No description provided for @loginIdentifierLabel.
  ///
  /// In ru, this message translates to:
  /// **'Логин или email'**
  String get loginIdentifierLabel;

  /// No description provided for @loginIdentifierRequired.
  ///
  /// In ru, this message translates to:
  /// **'Введите логин или email'**
  String get loginIdentifierRequired;

  /// No description provided for @loginIdentifierInvalid.
  ///
  /// In ru, this message translates to:
  /// **'Логин или email указан некорректно'**
  String get loginIdentifierInvalid;

  /// No description provided for @loginIdentifierHint.
  ///
  /// In ru, this message translates to:
  /// **'Например, ivan_01 или user@mail.com'**
  String get loginIdentifierHint;

  /// No description provided for @labelPassword.
  ///
  /// In ru, this message translates to:
  /// **'Пароль'**
  String get labelPassword;

  /// No description provided for @passwordHint.
  ///
  /// In ru, this message translates to:
  /// **'Введите пароль'**
  String get passwordHint;

  /// No description provided for @forgotPasswordLink.
  ///
  /// In ru, this message translates to:
  /// **'Забыли пароль?'**
  String get forgotPasswordLink;

  /// No description provided for @signInToPanel.
  ///
  /// In ru, this message translates to:
  /// **'Войти в панель'**
  String get signInToPanel;

  /// No description provided for @signIn.
  ///
  /// In ru, this message translates to:
  /// **'Войти'**
  String get signIn;

  /// No description provided for @continueWithGoogle.
  ///
  /// In ru, this message translates to:
  /// **'Продолжить с Google'**
  String get continueWithGoogle;

  /// No description provided for @noAccount.
  ///
  /// In ru, this message translates to:
  /// **'Нет аккаунта?'**
  String get noAccount;

  /// No description provided for @registerAction.
  ///
  /// In ru, this message translates to:
  /// **'Зарегистрироваться'**
  String get registerAction;

  /// No description provided for @panelInfoNote.
  ///
  /// In ru, this message translates to:
  /// **'Покупатели и курьеры работают через мобильное приложение. Web-панель предназначена только для ролей «Администратор» и «Менеджер».'**
  String get panelInfoNote;

  /// No description provided for @registerTitle.
  ///
  /// In ru, this message translates to:
  /// **'Регистрация'**
  String get registerTitle;

  /// No description provided for @registerHeading.
  ///
  /// In ru, this message translates to:
  /// **'Новый аккаунт покупателя'**
  String get registerHeading;

  /// No description provided for @registerRoleNote.
  ///
  /// In ru, this message translates to:
  /// **'После регистрации вам автоматически будет назначена роль «Покупатель».'**
  String get registerRoleNote;

  /// No description provided for @labelLogin.
  ///
  /// In ru, this message translates to:
  /// **'Логин'**
  String get labelLogin;

  /// No description provided for @registerLoginHint.
  ///
  /// In ru, this message translates to:
  /// **'Например, ivan_venikov'**
  String get registerLoginHint;

  /// No description provided for @labelName.
  ///
  /// In ru, this message translates to:
  /// **'Имя'**
  String get labelName;

  /// No description provided for @registerNameHint.
  ///
  /// In ru, this message translates to:
  /// **'Ваше имя'**
  String get registerNameHint;

  /// No description provided for @labelPhone.
  ///
  /// In ru, this message translates to:
  /// **'Телефон'**
  String get labelPhone;

  /// No description provided for @labelEmail.
  ///
  /// In ru, this message translates to:
  /// **'Email'**
  String get labelEmail;

  /// No description provided for @registerPasswordHint.
  ///
  /// In ru, this message translates to:
  /// **'Минимум 6 символов и одна цифра'**
  String get registerPasswordHint;

  /// No description provided for @labelPasswordConfirm.
  ///
  /// In ru, this message translates to:
  /// **'Подтверждение пароля'**
  String get labelPasswordConfirm;

  /// No description provided for @registerPasswordRepeatHint.
  ///
  /// In ru, this message translates to:
  /// **'Повторите пароль'**
  String get registerPasswordRepeatHint;

  /// No description provided for @haveAccountSignIn.
  ///
  /// In ru, this message translates to:
  /// **'Уже есть аккаунт? Войти'**
  String get haveAccountSignIn;

  /// No description provided for @profileLoadFailed.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось загрузить профиль. Проверьте соединение.'**
  String get profileLoadFailed;

  /// No description provided for @roleBlockedTitle.
  ///
  /// In ru, this message translates to:
  /// **'Роль «{roleName}» не может работать в мобильном приложении.'**
  String roleBlockedTitle(String roleName);

  /// No description provided for @roleBlockedBody.
  ///
  /// In ru, this message translates to:
  /// **'Пожалуйста, используйте веб-версию (сайт) для администрирования.'**
  String get roleBlockedBody;

  /// No description provided for @checkoutSignInRequired.
  ///
  /// In ru, this message translates to:
  /// **'Необходимо войти в систему.'**
  String get checkoutSignInRequired;

  /// No description provided for @checkoutSelectAddress.
  ///
  /// In ru, this message translates to:
  /// **'Выберите адрес доставки.'**
  String get checkoutSelectAddress;

  /// No description provided for @checkoutSelectCard.
  ///
  /// In ru, this message translates to:
  /// **'Для онлайн-оплаты выберите сохраненную карту.'**
  String get checkoutSelectCard;

  /// No description provided for @checkoutFailed.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось оформить заказ.'**
  String get checkoutFailed;

  /// No description provided for @checkoutTitle.
  ///
  /// In ru, this message translates to:
  /// **'Оформление заказа'**
  String get checkoutTitle;

  /// No description provided for @addAddressInProfile.
  ///
  /// In ru, this message translates to:
  /// **'Добавьте адрес в профиле'**
  String get addAddressInProfile;

  /// No description provided for @paymentMethodTitle.
  ///
  /// In ru, this message translates to:
  /// **'Способ оплаты'**
  String get paymentMethodTitle;

  /// No description provided for @cardLabel.
  ///
  /// In ru, this message translates to:
  /// **'Карта'**
  String get cardLabel;

  /// No description provided for @addCardInProfile.
  ///
  /// In ru, this message translates to:
  /// **'Добавьте карту в профиле'**
  String get addCardInProfile;

  /// No description provided for @promoCodeLabel.
  ///
  /// In ru, this message translates to:
  /// **'Промокод'**
  String get promoCodeLabel;

  /// No description provided for @promoNotSelected.
  ///
  /// In ru, this message translates to:
  /// **'Не выбран'**
  String get promoNotSelected;

  /// No description provided for @choose.
  ///
  /// In ru, this message translates to:
  /// **'Выбрать'**
  String get choose;

  /// No description provided for @summaryItemsTotal.
  ///
  /// In ru, this message translates to:
  /// **'Сумма товаров'**
  String get summaryItemsTotal;

  /// No description provided for @placeOrder.
  ///
  /// In ru, this message translates to:
  /// **'Разместить заказ'**
  String get placeOrder;

  /// No description provided for @orderSuccessTitle.
  ///
  /// In ru, this message translates to:
  /// **'Заказ успешно оформлен!'**
  String get orderSuccessTitle;

  /// No description provided for @orderSuccessBody.
  ///
  /// In ru, this message translates to:
  /// **'Номер заказа: {number}\nИстория заказа и дальнейшие уведомления будут доступны в профиле.'**
  String orderSuccessBody(String number);

  /// No description provided for @backToShop.
  ///
  /// In ru, this message translates to:
  /// **'Вернуться в магазин'**
  String get backToShop;

  /// No description provided for @courierUpdateFailed.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось обновить заказ. Попробуйте еще раз.'**
  String get courierUpdateFailed;

  /// No description provided for @courierNotSignedIn.
  ///
  /// In ru, this message translates to:
  /// **'Курьер не авторизован.'**
  String get courierNotSignedIn;

  /// No description provided for @courierTitle.
  ///
  /// In ru, this message translates to:
  /// **'Доставка'**
  String get courierTitle;

  /// No description provided for @courierNoOrders.
  ///
  /// In ru, this message translates to:
  /// **'У вас пока нет назначенных заказов.'**
  String get courierNoOrders;

  /// No description provided for @courierOrderDefault.
  ///
  /// In ru, this message translates to:
  /// **'Заказ'**
  String get courierOrderDefault;

  /// No description provided for @courierAddressMissing.
  ///
  /// In ru, this message translates to:
  /// **'Адрес не указан'**
  String get courierAddressMissing;

  /// No description provided for @courierSlot.
  ///
  /// In ru, this message translates to:
  /// **'Время: {slot}'**
  String courierSlot(String slot);

  /// No description provided for @courierCustomer.
  ///
  /// In ru, this message translates to:
  /// **'Клиент: {name}{phone}'**
  String courierCustomer(String name, String phone);

  /// No description provided for @courierCashDue.
  ///
  /// In ru, this message translates to:
  /// **'К оплате наличными: {amount}'**
  String courierCashDue(String amount);

  /// No description provided for @courierStatus.
  ///
  /// In ru, this message translates to:
  /// **'Статус: {status}'**
  String courierStatus(String status);

  /// No description provided for @courierStart.
  ///
  /// In ru, this message translates to:
  /// **'Начать доставку'**
  String get courierStart;

  /// No description provided for @courierComplete.
  ///
  /// In ru, this message translates to:
  /// **'Подтвердить доставку'**
  String get courierComplete;

  /// No description provided for @courierActiveTitle.
  ///
  /// In ru, this message translates to:
  /// **'Активные заказы'**
  String get courierActiveTitle;

  /// No description provided for @courierHistoryTitle.
  ///
  /// In ru, this message translates to:
  /// **'История доставок'**
  String get courierHistoryTitle;

  /// No description provided for @courierNoActive.
  ///
  /// In ru, this message translates to:
  /// **'Активных заказов нет. Новые назначения появятся здесь.'**
  String get courierNoActive;

  /// No description provided for @courierConfirmTitle.
  ///
  /// In ru, this message translates to:
  /// **'Подтвердить доставку?'**
  String get courierConfirmTitle;

  /// No description provided for @courierConfirmBody.
  ///
  /// In ru, this message translates to:
  /// **'Заказ {number} будет отмечен как доставленный. Отменить это действие нельзя.'**
  String courierConfirmBody(String number);

  /// No description provided for @courierCancelledNote.
  ///
  /// In ru, this message translates to:
  /// **'Заказ отменен, доставка не нужна.'**
  String get courierCancelledNote;

  /// No description provided for @courierPayment.
  ///
  /// In ru, this message translates to:
  /// **'Оплата: {method}'**
  String courierPayment(String method);

  /// No description provided for @courierTotal.
  ///
  /// In ru, this message translates to:
  /// **'Сумма заказа: {amount}'**
  String courierTotal(String amount);

  /// No description provided for @courierPhoneCopied.
  ///
  /// In ru, this message translates to:
  /// **'Телефон скопирован'**
  String get courierPhoneCopied;

  /// No description provided for @courierItemsTitle.
  ///
  /// In ru, this message translates to:
  /// **'Состав заказа'**
  String get courierItemsTitle;

  /// No description provided for @detailsSaved.
  ///
  /// In ru, this message translates to:
  /// **'Данные успешно сохранены'**
  String get detailsSaved;

  /// No description provided for @detailsSaveFailed.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось сохранить данные. Попробуйте еще раз.'**
  String get detailsSaveFailed;

  /// No description provided for @fullName.
  ///
  /// In ru, this message translates to:
  /// **'Полное имя'**
  String get fullName;

  /// No description provided for @phoneNumber.
  ///
  /// In ru, this message translates to:
  /// **'Номер телефона'**
  String get phoneNumber;

  /// No description provided for @emailReadOnly.
  ///
  /// In ru, this message translates to:
  /// **'Email (нельзя изменить)'**
  String get emailReadOnly;

  /// No description provided for @faqTitle.
  ///
  /// In ru, this message translates to:
  /// **'Часто задаваемые вопросы'**
  String get faqTitle;

  /// No description provided for @faqTrackQ.
  ///
  /// In ru, this message translates to:
  /// **'Как отследить мой заказ?'**
  String get faqTrackQ;

  /// No description provided for @faqTrackA.
  ///
  /// In ru, this message translates to:
  /// **'Вы можете отследить свой заказ в разделе «Заказы» вашего профиля.'**
  String get faqTrackA;

  /// No description provided for @faqReturnQ.
  ///
  /// In ru, this message translates to:
  /// **'Как вернуть товар?'**
  String get faqReturnQ;

  /// No description provided for @faqReturnA.
  ///
  /// In ru, this message translates to:
  /// **'Возврат можно оформить в течение 7 дней после доставки, связавшись с нашей поддержкой.'**
  String get faqReturnA;

  /// No description provided for @faqPaymentQ.
  ///
  /// In ru, this message translates to:
  /// **'Какие способы оплаты принимаются?'**
  String get faqPaymentQ;

  /// No description provided for @faqPaymentA.
  ///
  /// In ru, this message translates to:
  /// **'Мы принимаем банковские карты, Apple Pay и оплату наличными курьеру.'**
  String get faqPaymentA;

  /// No description provided for @faqPromoQ.
  ///
  /// In ru, this message translates to:
  /// **'Как использовать промокоды?'**
  String get faqPromoQ;

  /// No description provided for @faqPromoA.
  ///
  /// In ru, this message translates to:
  /// **'Введите промокод на экране корзины или в разделе «Промокоды».'**
  String get faqPromoA;

  /// No description provided for @categoryOther.
  ///
  /// In ru, this message translates to:
  /// **'Другое'**
  String get categoryOther;

  /// No description provided for @shareMessage.
  ///
  /// In ru, this message translates to:
  /// **'🍏 Смотри, что я нашел в Nectar!\n\n✨ {name} — всего за {price} ₽.\n\nЗаказывай прямо сейчас:\n🔗 {link}'**
  String shareMessage(String name, String price, String link);

  /// No description provided for @paymentOnline.
  ///
  /// In ru, this message translates to:
  /// **'Онлайн'**
  String get paymentOnline;

  /// No description provided for @paymentCash.
  ///
  /// In ru, this message translates to:
  /// **'Наличными'**
  String get paymentCash;

  /// No description provided for @userDefaultName.
  ///
  /// In ru, this message translates to:
  /// **'Пользователь'**
  String get userDefaultName;

  /// No description provided for @notificationsSignIn.
  ///
  /// In ru, this message translates to:
  /// **'Авторизуйтесь для просмотра уведомлений'**
  String get notificationsSignIn;

  /// No description provided for @notificationsCleared.
  ///
  /// In ru, this message translates to:
  /// **'Все уведомления очищены.'**
  String get notificationsCleared;

  /// No description provided for @notificationsClearFailed.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось очистить уведомления.'**
  String get notificationsClearFailed;

  /// No description provided for @clearAll.
  ///
  /// In ru, this message translates to:
  /// **'Очистить все'**
  String get clearAll;

  /// No description provided for @notifPushTitle.
  ///
  /// In ru, this message translates to:
  /// **'Push-уведомления'**
  String get notifPushTitle;

  /// No description provided for @notifPushSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Получать внутрисистемные уведомления по заказам'**
  String get notifPushSubtitle;

  /// No description provided for @notifSmsTitle.
  ///
  /// In ru, this message translates to:
  /// **'SMS-уведомления'**
  String get notifSmsTitle;

  /// No description provided for @notifSmsSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Получать сообщения о доставке'**
  String get notifSmsSubtitle;

  /// No description provided for @notifEmailTitle.
  ///
  /// In ru, this message translates to:
  /// **'Email-уведомления'**
  String get notifEmailTitle;

  /// No description provided for @notifEmailSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Получать акции и напоминания по почте'**
  String get notifEmailSubtitle;

  /// No description provided for @notifHistoryTitle.
  ///
  /// In ru, this message translates to:
  /// **'История уведомлений'**
  String get notifHistoryTitle;

  /// No description provided for @notifEmpty.
  ///
  /// In ru, this message translates to:
  /// **'Пока нет уведомлений. Они будут появляться автоматически при изменении статуса заказа.'**
  String get notifEmpty;

  /// No description provided for @notifDefaultText.
  ///
  /// In ru, this message translates to:
  /// **'Уведомление'**
  String get notifDefaultText;

  /// No description provided for @onboardingSkip.
  ///
  /// In ru, this message translates to:
  /// **'Пропустить'**
  String get onboardingSkip;

  /// No description provided for @onboardingNext.
  ///
  /// In ru, this message translates to:
  /// **'Далее'**
  String get onboardingNext;

  /// No description provided for @onboardingStart.
  ///
  /// In ru, this message translates to:
  /// **'Начать'**
  String get onboardingStart;

  /// No description provided for @onboarding1Title.
  ///
  /// In ru, this message translates to:
  /// **'Гарантия свежести'**
  String get onboarding1Title;

  /// No description provided for @onboarding1Body.
  ///
  /// In ru, this message translates to:
  /// **'Мы тщательно отбираем овощи, фрукты, мясо и молочные продукты для вашего стола.'**
  String get onboarding1Body;

  /// No description provided for @onboarding2Title.
  ///
  /// In ru, this message translates to:
  /// **'Доставка за час'**
  String get onboarding2Title;

  /// No description provided for @onboarding2Body.
  ///
  /// In ru, this message translates to:
  /// **'Курьер привезет заказ в удобное для вас время, а статус можно отслеживать в приложении.'**
  String get onboarding2Body;

  /// No description provided for @onboarding3Title.
  ///
  /// In ru, this message translates to:
  /// **'Выгодные покупки'**
  String get onboarding3Title;

  /// No description provided for @onboarding3Body.
  ///
  /// In ru, this message translates to:
  /// **'Собирайте избранное, применяйте промокоды и оформляйте заказ в пару касаний.'**
  String get onboarding3Body;

  /// No description provided for @myOrders.
  ///
  /// In ru, this message translates to:
  /// **'Мои заказы'**
  String get myOrders;

  /// No description provided for @ordersSignInRequired.
  ///
  /// In ru, this message translates to:
  /// **'Авторизуйтесь для просмотра заказов'**
  String get ordersSignInRequired;

  /// No description provided for @ordersLoadFailed.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось загрузить заказы. Попробуйте позже.'**
  String get ordersLoadFailed;

  /// No description provided for @ordersEmptyTitle.
  ///
  /// In ru, this message translates to:
  /// **'Пока нет заказов'**
  String get ordersEmptyTitle;

  /// No description provided for @ordersEmptyBody.
  ///
  /// In ru, this message translates to:
  /// **'Когда вы сделаете заказ, он появится здесь.'**
  String get ordersEmptyBody;

  /// No description provided for @startShopping.
  ///
  /// In ru, this message translates to:
  /// **'За покупками'**
  String get startShopping;

  /// No description provided for @orderNumberFallback.
  ///
  /// In ru, this message translates to:
  /// **'Заказ #{id}'**
  String orderNumberFallback(String id);

  /// No description provided for @orderCancelled.
  ///
  /// In ru, this message translates to:
  /// **'Заказ отменен'**
  String get orderCancelled;

  /// No description provided for @stepCreated.
  ///
  /// In ru, this message translates to:
  /// **'Создан'**
  String get stepCreated;

  /// No description provided for @stepWithCourier.
  ///
  /// In ru, this message translates to:
  /// **'У курьера'**
  String get stepWithCourier;

  /// No description provided for @stepDelivered.
  ///
  /// In ru, this message translates to:
  /// **'Доставлен'**
  String get stepDelivered;

  /// No description provided for @labelAddress.
  ///
  /// In ru, this message translates to:
  /// **'Адрес'**
  String get labelAddress;

  /// No description provided for @notSpecified.
  ///
  /// In ru, this message translates to:
  /// **'Не указан'**
  String get notSpecified;

  /// No description provided for @deliveryTime.
  ///
  /// In ru, this message translates to:
  /// **'Время доставки'**
  String get deliveryTime;

  /// No description provided for @orderInfoPayment.
  ///
  /// In ru, this message translates to:
  /// **'Оплата'**
  String get orderInfoPayment;

  /// No description provided for @notSpecifiedFem.
  ///
  /// In ru, this message translates to:
  /// **'Не указана'**
  String get notSpecifiedFem;

  /// No description provided for @orderInfoCourier.
  ///
  /// In ru, this message translates to:
  /// **'Курьер'**
  String get orderInfoCourier;

  /// No description provided for @orderInfoCourierPhone.
  ///
  /// In ru, this message translates to:
  /// **'Телефон курьера'**
  String get orderInfoCourierPhone;

  /// No description provided for @total.
  ///
  /// In ru, this message translates to:
  /// **'Итого'**
  String get total;

  /// No description provided for @itemDefaultName.
  ///
  /// In ru, this message translates to:
  /// **'Товар'**
  String get itemDefaultName;

  /// No description provided for @quantityLabel.
  ///
  /// In ru, this message translates to:
  /// **'Количество: {quantity}'**
  String quantityLabel(String quantity);

  /// No description provided for @hideOrderFailed.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось скрыть заказ.'**
  String get hideOrderFailed;

  /// No description provided for @hideOrder.
  ///
  /// In ru, this message translates to:
  /// **'Скрыть из списка'**
  String get hideOrder;

  /// No description provided for @orderConfirmedWaiting.
  ///
  /// In ru, this message translates to:
  /// **'Вы подтвердили получение. Ожидаем менеджера.'**
  String get orderConfirmedWaiting;

  /// No description provided for @orderConfirmedToast.
  ///
  /// In ru, this message translates to:
  /// **'Вы подтвердили, что всё хорошо!'**
  String get orderConfirmedToast;

  /// No description provided for @orderConfirmFailed.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось подтвердить получение.'**
  String get orderConfirmFailed;

  /// No description provided for @orderConfirmButton.
  ///
  /// In ru, this message translates to:
  /// **'Подтвердить, что всё хорошо'**
  String get orderConfirmButton;

  /// No description provided for @passwordChanged.
  ///
  /// In ru, this message translates to:
  /// **'Пароль успешно изменен.'**
  String get passwordChanged;

  /// No description provided for @changePasswordTitle.
  ///
  /// In ru, this message translates to:
  /// **'Смена пароля'**
  String get changePasswordTitle;

  /// No description provided for @currentPasswordRequired.
  ///
  /// In ru, this message translates to:
  /// **'Введите текущий пароль'**
  String get currentPasswordRequired;

  /// No description provided for @currentPasswordLabel.
  ///
  /// In ru, this message translates to:
  /// **'Текущий пароль'**
  String get currentPasswordLabel;

  /// No description provided for @newPasswordSame.
  ///
  /// In ru, this message translates to:
  /// **'Новый пароль совпадает с текущим'**
  String get newPasswordSame;

  /// No description provided for @newPasswordLabel.
  ///
  /// In ru, this message translates to:
  /// **'Новый пароль'**
  String get newPasswordLabel;

  /// No description provided for @newPasswordRepeatLabel.
  ///
  /// In ru, this message translates to:
  /// **'Повторите новый пароль'**
  String get newPasswordRepeatLabel;

  /// No description provided for @addCardTitle.
  ///
  /// In ru, this message translates to:
  /// **'Добавить карту'**
  String get addCardTitle;

  /// No description provided for @addCardHint.
  ///
  /// In ru, this message translates to:
  /// **'Номер карты (16 цифр)'**
  String get addCardHint;

  /// No description provided for @cardRemoveFailed.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось удалить карту.'**
  String get cardRemoveFailed;

  /// No description provided for @cardsSignIn.
  ///
  /// In ru, this message translates to:
  /// **'Авторизуйтесь для просмотра карт'**
  String get cardsSignIn;

  /// No description provided for @cardsEmptyTitle.
  ///
  /// In ru, this message translates to:
  /// **'Нет привязанных карт'**
  String get cardsEmptyTitle;

  /// No description provided for @cardsEmptyBody.
  ///
  /// In ru, this message translates to:
  /// **'Добавьте банковскую карту для оплаты.'**
  String get cardsEmptyBody;

  /// No description provided for @promoApplied.
  ///
  /// In ru, this message translates to:
  /// **'Промокод {code} применен. Скидка {percent}%.'**
  String promoApplied(String code, String percent);

  /// No description provided for @promoCheckFailed.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось проверить промокод. Попробуйте позже.'**
  String get promoCheckFailed;

  /// No description provided for @promoRemoved.
  ///
  /// In ru, this message translates to:
  /// **'Промокод удален.'**
  String get promoRemoved;

  /// No description provided for @promoCurrentlyApplied.
  ///
  /// In ru, this message translates to:
  /// **'Сейчас применен промокод {code} со скидкой {percent}%.'**
  String promoCurrentlyApplied(String code, String percent);

  /// No description provided for @promoAvailableTitle.
  ///
  /// In ru, this message translates to:
  /// **'Доступные промокоды'**
  String get promoAvailableTitle;

  /// No description provided for @promoNoneActive.
  ///
  /// In ru, this message translates to:
  /// **'Активных промокодов пока нет.'**
  String get promoNoneActive;

  /// No description provided for @promoDiscountUntil.
  ///
  /// In ru, this message translates to:
  /// **'Скидка {percent}% до {date}'**
  String promoDiscountUntil(String percent, String date);

  /// No description provided for @cartTitle.
  ///
  /// In ru, this message translates to:
  /// **'Моя корзина'**
  String get cartTitle;

  /// No description provided for @cartEmpty.
  ///
  /// In ru, this message translates to:
  /// **'Ваша корзина пуста'**
  String get cartEmpty;

  /// No description provided for @cartPromoApplied.
  ///
  /// In ru, this message translates to:
  /// **'Применен промокод {code} со скидкой {percent}%. Экономия: {savings}'**
  String cartPromoApplied(String code, String percent, String savings);

  /// No description provided for @summarySubtotal.
  ///
  /// In ru, this message translates to:
  /// **'Подытог'**
  String get summarySubtotal;

  /// No description provided for @summaryDiscount.
  ///
  /// In ru, this message translates to:
  /// **'Скидка'**
  String get summaryDiscount;

  /// No description provided for @summaryDelivery.
  ///
  /// In ru, this message translates to:
  /// **'Доставка'**
  String get summaryDelivery;

  /// No description provided for @free.
  ///
  /// In ru, this message translates to:
  /// **'Бесплатно'**
  String get free;

  /// No description provided for @deliveryFeeWithThreshold.
  ///
  /// In ru, this message translates to:
  /// **'{fee} (бесплатно от {threshold} ₽)'**
  String deliveryFeeWithThreshold(String fee, String threshold);

  /// No description provided for @checkout.
  ///
  /// In ru, this message translates to:
  /// **'Оформить заказ'**
  String get checkout;

  /// No description provided for @productsLoadFailedLater.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось загрузить товары. Попробуйте позже.'**
  String get productsLoadFailedLater;

  /// No description provided for @categoryEmpty.
  ///
  /// In ru, this message translates to:
  /// **'В этой категории пока нет товаров'**
  String get categoryEmpty;

  /// No description provided for @addedPartial.
  ///
  /// In ru, this message translates to:
  /// **'Добавлено {count} шт. — это весь доступный остаток'**
  String addedPartial(int count);

  /// No description provided for @addedQuantityToCart.
  ///
  /// In ru, this message translates to:
  /// **'«{name}» × {count} добавлен в корзину'**
  String addedQuantityToCart(String name, int count);

  /// No description provided for @stockLeft.
  ///
  /// In ru, this message translates to:
  /// **'Осталось: {count} шт'**
  String stockLeft(int count);

  /// No description provided for @productDescriptionTitle.
  ///
  /// In ru, this message translates to:
  /// **'Описание товара'**
  String get productDescriptionTitle;

  /// No description provided for @soldOut.
  ///
  /// In ru, this message translates to:
  /// **'Распродано'**
  String get soldOut;

  /// No description provided for @addToCartWithPrice.
  ///
  /// In ru, this message translates to:
  /// **'В корзину · {price} ₽'**
  String addToCartWithPrice(String price);

  /// No description provided for @factManufacturer.
  ///
  /// In ru, this message translates to:
  /// **'Производитель'**
  String get factManufacturer;

  /// No description provided for @factCountry.
  ///
  /// In ru, this message translates to:
  /// **'Страна происхождения'**
  String get factCountry;

  /// No description provided for @factBestBefore.
  ///
  /// In ru, this message translates to:
  /// **'Срок годности до'**
  String get factBestBefore;

  /// No description provided for @factComposition.
  ///
  /// In ru, this message translates to:
  /// **'Состав'**
  String get factComposition;

  /// No description provided for @productFactsTitle.
  ///
  /// In ru, this message translates to:
  /// **'Характеристики'**
  String get productFactsTitle;

  /// No description provided for @nutritionTitle.
  ///
  /// In ru, this message translates to:
  /// **'Пищевая ценность на 100 г'**
  String get nutritionTitle;

  /// No description provided for @nutritionCalories.
  ///
  /// In ru, this message translates to:
  /// **'Ккал'**
  String get nutritionCalories;

  /// No description provided for @nutritionProteins.
  ///
  /// In ru, this message translates to:
  /// **'Белки'**
  String get nutritionProteins;

  /// No description provided for @nutritionFats.
  ///
  /// In ru, this message translates to:
  /// **'Жиры'**
  String get nutritionFats;

  /// No description provided for @nutritionCarbs.
  ///
  /// In ru, this message translates to:
  /// **'Углеводы'**
  String get nutritionCarbs;

  /// No description provided for @categoriesLoadFailed.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось загрузить категории.'**
  String get categoriesLoadFailed;

  /// No description provided for @categoriesEmpty.
  ///
  /// In ru, this message translates to:
  /// **'Категории пока не добавлены.'**
  String get categoriesEmpty;

  /// No description provided for @searchFailed.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось выполнить поиск. Проверьте соединение.'**
  String get searchFailed;

  /// No description provided for @favoritesNothingToAdd.
  ///
  /// In ru, this message translates to:
  /// **'Нет товаров в наличии для добавления'**
  String get favoritesNothingToAdd;

  /// No description provided for @favoritesAdded.
  ///
  /// In ru, this message translates to:
  /// **'Товары добавлены в корзину ({count})'**
  String favoritesAdded(int count);

  /// No description provided for @favoritesTitle.
  ///
  /// In ru, this message translates to:
  /// **'Избранное'**
  String get favoritesTitle;

  /// No description provided for @favoritesLoadFailed.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось загрузить избранное.'**
  String get favoritesLoadFailed;

  /// No description provided for @favoritesEmpty.
  ///
  /// In ru, this message translates to:
  /// **'У вас пока нет любимых товаров ❤️'**
  String get favoritesEmpty;

  /// No description provided for @addAllToCart.
  ///
  /// In ru, this message translates to:
  /// **'В корзину всё'**
  String get addAllToCart;

  /// No description provided for @shopLocation.
  ///
  /// In ru, this message translates to:
  /// **'Москва, Россия'**
  String get shopLocation;

  /// No description provided for @searchHint.
  ///
  /// In ru, this message translates to:
  /// **'Поиск по магазину'**
  String get searchHint;

  /// No description provided for @productsLoadFailedConnection.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось загрузить товары. Проверьте соединение.'**
  String get productsLoadFailedConnection;

  /// No description provided for @noProductsInDatabase.
  ///
  /// In ru, this message translates to:
  /// **'Товары отсутствуют в базе данных.'**
  String get noProductsInDatabase;

  /// No description provided for @nothingFound.
  ///
  /// In ru, this message translates to:
  /// **'По вашему запросу ничего не найдено'**
  String get nothingFound;

  /// No description provided for @promoBannerTitle.
  ///
  /// In ru, this message translates to:
  /// **'Скидка 20% на первый заказ'**
  String get promoBannerTitle;

  /// No description provided for @promoBannerCode.
  ///
  /// In ru, this message translates to:
  /// **'Промокод NECTAR20'**
  String get promoBannerCode;

  /// No description provided for @popular.
  ///
  /// In ru, this message translates to:
  /// **'Популярное'**
  String get popular;

  /// No description provided for @seeAll.
  ///
  /// In ru, this message translates to:
  /// **'Все'**
  String get seeAll;

  /// No description provided for @splashBrand.
  ///
  /// In ru, this message translates to:
  /// **'нектар'**
  String get splashBrand;

  /// No description provided for @splashTagline.
  ///
  /// In ru, this message translates to:
  /// **'онлайн магазин'**
  String get splashTagline;

  /// No description provided for @statusNew.
  ///
  /// In ru, this message translates to:
  /// **'Новый'**
  String get statusNew;

  /// No description provided for @statusProcessing.
  ///
  /// In ru, this message translates to:
  /// **'В сборке'**
  String get statusProcessing;

  /// No description provided for @statusAssigned.
  ///
  /// In ru, this message translates to:
  /// **'Передан курьеру'**
  String get statusAssigned;

  /// No description provided for @statusDelivering.
  ///
  /// In ru, this message translates to:
  /// **'В пути'**
  String get statusDelivering;

  /// No description provided for @statusDelivered.
  ///
  /// In ru, this message translates to:
  /// **'Доставлен'**
  String get statusDelivered;

  /// No description provided for @statusCancelled.
  ///
  /// In ru, this message translates to:
  /// **'Отменен'**
  String get statusCancelled;

  /// No description provided for @addedToCart.
  ///
  /// In ru, this message translates to:
  /// **'«{name}» добавлен в корзину'**
  String addedToCart(String name);

  /// No description provided for @noMoreStockNamed.
  ///
  /// In ru, this message translates to:
  /// **'Больше нет в наличии: {name}'**
  String noMoreStockNamed(String name);

  /// No description provided for @outOfStock.
  ///
  /// In ru, this message translates to:
  /// **'Нет в наличии'**
  String get outOfStock;

  /// No description provided for @reseedTitle.
  ///
  /// In ru, this message translates to:
  /// **'Перезалить базу товаров?'**
  String get reseedTitle;

  /// No description provided for @reseedBody.
  ///
  /// In ru, this message translates to:
  /// **'Все текущие товары будут удалены и заменены стартовым каталогом (69 товаров, 9 категорий). Это действие нельзя отменить.'**
  String get reseedBody;

  /// No description provided for @reseedConfirm.
  ///
  /// In ru, this message translates to:
  /// **'Перезалить'**
  String get reseedConfirm;

  /// No description provided for @reseedLoading.
  ///
  /// In ru, this message translates to:
  /// **'Загружаем товары...'**
  String get reseedLoading;

  /// No description provided for @reseedDone.
  ///
  /// In ru, this message translates to:
  /// **'База товаров успешно обновлена!'**
  String get reseedDone;

  /// No description provided for @reseedFailed.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось обновить базу товаров.'**
  String get reseedFailed;

  /// No description provided for @adminHome.
  ///
  /// In ru, this message translates to:
  /// **'Главная'**
  String get adminHome;

  /// No description provided for @sectionInDevelopment.
  ///
  /// In ru, this message translates to:
  /// **'Раздел в разработке'**
  String get sectionInDevelopment;

  /// No description provided for @adminDashboardTitle.
  ///
  /// In ru, this message translates to:
  /// **'Панель управления'**
  String get adminDashboardTitle;

  /// No description provided for @adminNewOrders.
  ///
  /// In ru, this message translates to:
  /// **'Новые заказы'**
  String get adminNewOrders;

  /// No description provided for @adminActive.
  ///
  /// In ru, this message translates to:
  /// **'Активные'**
  String get adminActive;

  /// No description provided for @adminProducts.
  ///
  /// In ru, this message translates to:
  /// **'Товары'**
  String get adminProducts;

  /// No description provided for @adminInCatalog.
  ///
  /// In ru, this message translates to:
  /// **'В каталоге'**
  String get adminInCatalog;

  /// No description provided for @adminQuickActions.
  ///
  /// In ru, this message translates to:
  /// **'Быстрые действия'**
  String get adminQuickActions;

  /// No description provided for @adminReseedButton.
  ///
  /// In ru, this message translates to:
  /// **'Перезалить базу товаров (Сброс)'**
  String get adminReseedButton;

  /// No description provided for @adminReseedHint.
  ///
  /// In ru, this message translates to:
  /// **'Загружает стартовый каталог с фотографиями, описанием, составом и пищевой ценностью.'**
  String get adminReseedHint;

  /// No description provided for @adminOrdersTitle.
  ///
  /// In ru, this message translates to:
  /// **'Управление заказами'**
  String get adminOrdersTitle;

  /// No description provided for @adminNoOrders.
  ///
  /// In ru, this message translates to:
  /// **'Нет заказов'**
  String get adminNoOrders;

  /// No description provided for @adminNoName.
  ///
  /// In ru, this message translates to:
  /// **'Без имени'**
  String get adminNoName;

  /// No description provided for @adminCourierRequired.
  ///
  /// In ru, this message translates to:
  /// **'Ошибка: нельзя перевести заказ в статус «В пути» или «Доставлен», пока не назначен курьер!'**
  String get adminCourierRequired;

  /// No description provided for @adminOrderUpdated.
  ///
  /// In ru, this message translates to:
  /// **'Заказ успешно обновлен!'**
  String get adminOrderUpdated;

  /// No description provided for @adminOrderUpdateFailed.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось обновить заказ.'**
  String get adminOrderUpdateFailed;

  /// No description provided for @adminCustomer.
  ///
  /// In ru, this message translates to:
  /// **'Клиент: {name}'**
  String adminCustomer(String name);

  /// No description provided for @adminAddress.
  ///
  /// In ru, this message translates to:
  /// **'Адрес: {address}'**
  String adminAddress(String address);

  /// No description provided for @adminPhone.
  ///
  /// In ru, this message translates to:
  /// **'Телефон: {phone}'**
  String adminPhone(String phone);

  /// No description provided for @adminDeliverySlot.
  ///
  /// In ru, this message translates to:
  /// **'Время доставки: {slot}'**
  String adminDeliverySlot(String slot);

  /// No description provided for @adminAmount.
  ///
  /// In ru, this message translates to:
  /// **'Сумма: ₽{amount}'**
  String adminAmount(String amount);

  /// No description provided for @adminCourierLabel.
  ///
  /// In ru, this message translates to:
  /// **'Курьер:'**
  String get adminCourierLabel;

  /// No description provided for @notAssigned.
  ///
  /// In ru, this message translates to:
  /// **'Не назначен'**
  String get notAssigned;

  /// No description provided for @adminStatusLabel.
  ///
  /// In ru, this message translates to:
  /// **'Статус:'**
  String get adminStatusLabel;

  /// No description provided for @webBlockedTitle.
  ///
  /// In ru, this message translates to:
  /// **'Для оформления заказов скачайте наше приложение'**
  String get webBlockedTitle;

  /// No description provided for @webBlockedBody.
  ///
  /// In ru, this message translates to:
  /// **'Вы вошли как «{roleName}». Данный веб-сайт предназначен только для управления магазином (для администраторов).\n\nПожалуйста, установите Nectar на свой телефон, чтобы совершать покупки.'**
  String webBlockedBody(String roleName);

  /// No description provided for @landingForCustomers.
  ///
  /// In ru, this message translates to:
  /// **'Покупателям'**
  String get landingForCustomers;

  /// No description provided for @landingAbout.
  ///
  /// In ru, this message translates to:
  /// **'О компании'**
  String get landingAbout;

  /// No description provided for @landingStaffLogin.
  ///
  /// In ru, this message translates to:
  /// **'Вход для сотрудников'**
  String get landingStaffLogin;

  /// No description provided for @landingBadge.
  ///
  /// In ru, this message translates to:
  /// **'🚀 Доставка за 60 минут'**
  String get landingBadge;

  /// No description provided for @landingHeadline.
  ///
  /// In ru, this message translates to:
  /// **'Свежие продукты\nс доставкой на дом'**
  String get landingHeadline;

  /// No description provided for @landingBody.
  ///
  /// In ru, this message translates to:
  /// **'Заказывайте любимые овощи, фрукты, мясо и молочные продукты. Мы тщательно отбираем товары и доставляем их прямо к вашей двери.'**
  String get landingBody;

  /// No description provided for @landingDownload.
  ///
  /// In ru, this message translates to:
  /// **'Скачайте наше приложение:'**
  String get landingDownload;

  /// No description provided for @landingFreshOnly.
  ///
  /// In ru, this message translates to:
  /// **'Только\nсвежее'**
  String get landingFreshOnly;

  /// No description provided for @landingDownloadIn.
  ///
  /// In ru, this message translates to:
  /// **'Скачать в'**
  String get landingDownloadIn;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
