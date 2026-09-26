import '../l10n/l10n.dart';

class Validators {
  /// Firebase Authentication не принимает пароли короче 6 символов.
  static const int minPasswordLength = 6;

  static AppLocalizations get l10n => AppLocale.strings;

  static String? validateLogin(String? value) {
    if (value == null || value.trim().isEmpty) return l10n.valLoginRequired;
    final trimmed = value.trim();
    if (trimmed.length < 3 || trimmed.length > 50) return l10n.valLoginLength;
    if (!RegExp(r'^[a-zA-Z0-9._-]+$').hasMatch(trimmed)) return l10n.valLoginChars;
    return null;
  }

  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) return l10n.valFieldRequired;
    final trimmed = value.trim();
    if (trimmed.length < 2 || trimmed.length > 50) return l10n.valNameLength;
    if (!RegExp(r'^[a-zA-Zа-яА-ЯёЁ\s-]+$').hasMatch(trimmed)) return l10n.valNameChars;
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return l10n.valEmailRequired;
    final trimmed = value.trim().toLowerCase();
    if (trimmed.length > 100) return l10n.valEmailLength;
    if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]+$').hasMatch(trimmed)) return l10n.valEmailFormat;
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) return l10n.valPhoneRequired;
    if (!RegExp(r'^\+?[\d\s\-()]+$').hasMatch(value.trim())) return l10n.valPhoneFormat;
    final digitsOnly = value.replaceAll(RegExp(r'\D'), '');
    if (digitsOnly.length < 10 || digitsOnly.length > 15) return l10n.valPhoneFormat;
    return null;
  }

  /// Поле входа принимает либо email, либо логин.
  static String? validateLoginIdentifier(String? value) {
    if (value == null || value.trim().isEmpty) return l10n.loginIdentifierRequired;
    final trimmed = value.trim();
    final error = trimmed.contains('@') ? validateEmail(trimmed) : validateLogin(trimmed);
    return error == null ? null : l10n.loginIdentifierInvalid;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) return l10n.valPasswordRequired;
    if (value.contains(' ')) return l10n.valPasswordNoSpaces;
    if (value.length < minPasswordLength) return l10n.valPasswordMinLength;
    if (!RegExp(r'\d').hasMatch(value)) return l10n.valPasswordDigit;
    if (value.length > 128) return l10n.valPasswordMaxLength;
    return null;
  }

  /// При входе проверяется только заполненность: пароль, созданный раньше или
  /// другим способом, не должен блокироваться правилами регистрации.
  static String? validatePasswordForLogin(String? value) {
    if (value == null || value.isEmpty) return l10n.valPasswordRequired;
    return null;
  }

  static String? validatePasswordConfirmation(String? value, String originalPassword) {
    if (value == null || value.isEmpty) return l10n.valPasswordConfirmRequired;
    if (value != originalPassword) return l10n.valPasswordMismatch;
    return null;
  }

  static String? validateRequiredText(
    String? value, {
    required String fieldName,
    int? maxLength,
  }) {
    if (value == null || value.trim().isEmpty) return l10n.valNamedFieldRequired(fieldName);
    if (maxLength != null && value.trim().length > maxLength) {
      return l10n.valNamedFieldMaxLength(fieldName, maxLength);
    }
    return null;
  }

  static String? validatePositivePrice(String? value) {
    if (value == null || value.trim().isEmpty) return l10n.valPriceRequired;
    final parsedValue = double.tryParse(value.replaceAll(',', '.'));
    if (parsedValue == null || parsedValue <= 0) return l10n.valPricePositive;
    return null;
  }

  static String? validateIntegerRange(
    String? value, {
    required String fieldName,
    required int minValue,
    required int maxValue,
  }) {
    if (value == null || value.trim().isEmpty) return l10n.valNamedValueRequired(fieldName);
    final parsedValue = int.tryParse(value);
    if (parsedValue == null || parsedValue < minValue || parsedValue > maxValue) {
      return l10n.valNamedRange(fieldName, minValue, maxValue);
    }
    return null;
  }

  static String? validatePromoCode(String? value) {
    if (value == null || value.trim().isEmpty) return l10n.valPromoRequired;
    final normalizedValue = value.trim().toUpperCase();
    if (!RegExp(r'^[A-Z0-9]+$').hasMatch(normalizedValue)) return l10n.valPromoChars;
    return null;
  }

  static String? validateTaxId(String? value) {
    if (value == null || value.trim().isEmpty) return l10n.valTaxIdRequired;
    if (!RegExp(r'^\d{10}(\d{2})?$').hasMatch(value.trim())) {
      return l10n.valTaxIdFormat;
    }
    return null;
  }

  static String? validateCardNumber(String? value) {
    if (value == null || value.trim().isEmpty) return l10n.valCardRequired;
    if (!RegExp(r'^[\d\s-]+$').hasMatch(value.trim())) return l10n.valCardLength;
    final digitsOnly = value.replaceAll(RegExp(r'\D'), '');
    if (digitsOnly.length != 16) return l10n.valCardLength;
    return null;
  }
}
