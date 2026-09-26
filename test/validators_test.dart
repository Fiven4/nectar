import 'package:flutter_test/flutter_test.dart';
import 'package:nectar/utils/role_utils.dart';
import 'package:nectar/utils/validators.dart';

void main() {
  group('Validators', () {
    test('email', () {
      expect(Validators.validateEmail('user@example.com'), isNull);
      expect(Validators.validateEmail('user@'), isNotNull);
      expect(Validators.validateEmail('  '), isNotNull);
    });

    test('password needs 6+ chars, a digit and no spaces', () {
      expect(Validators.validatePassword('abcde1'), isNull);
      expect(Validators.validatePassword('abcd1'), isNotNull);
      expect(Validators.validatePassword('abcdef'), isNotNull);
      expect(Validators.validatePassword('ab 12345'), isNotNull);
      expect(Validators.validatePassword('a1'), isNotNull);
      expect(Validators.validatePassword('a1${'x' * 130}'), isNotNull);
    });

    test('login only requires a non-empty password', () {
      expect(Validators.validatePasswordForLogin('x'), isNull);
      expect(Validators.validatePasswordForLogin(''), isNotNull);
      expect(Validators.validatePasswordForLogin(null), isNotNull);
    });

    test('password confirmation', () {
      expect(Validators.validatePasswordConfirmation('abc12', 'abc12'), isNull);
      expect(Validators.validatePasswordConfirmation('abc13', 'abc12'), isNotNull);
    });

    test('login', () {
      expect(Validators.validateLogin('nectar_user'), isNull);
      expect(Validators.validateLogin('ab'), isNotNull);
      expect(Validators.validateLogin('bad login'), isNotNull);
    });

    test('phone and card', () {
      expect(Validators.validatePhone('+7 (900) 123-45-67'), isNull);
      expect(Validators.validatePhone('123'), isNotNull);
      expect(Validators.validatePhone('hello 89001234567'), isNotNull);
      expect(Validators.validatePhone('8900123456789012345'), isNotNull);
      expect(Validators.validateCardNumber('1234567812345678'), isNull);
      expect(Validators.validateCardNumber('1234'), isNotNull);
      expect(Validators.validateCardNumber('1234 5678 1234 5678'), isNull);
      expect(Validators.validateCardNumber('abcd567812345678'), isNotNull);
    });

    test('login identifier accepts an email or a login', () {
      expect(Validators.validateLoginIdentifier('user@example.com'), isNull);
      expect(Validators.validateLoginIdentifier('nectar_user'), isNull);
      expect(Validators.validateLoginIdentifier('user@'), isNotNull);
      expect(Validators.validateLoginIdentifier('ab'), isNotNull);
      expect(Validators.validateLoginIdentifier('bad login'), isNotNull);
      expect(Validators.validateLoginIdentifier(' '), isNotNull);
    });

    test('promo code', () {
      expect(Validators.validatePromoCode('nectar20'), isNull);
      expect(Validators.validatePromoCode('bad code!'), isNotNull);
    });
  });

  group('Roles', () {
    test('mobile app access', () {
      expect(canAccessBuyerApp(AppRoles.buyer), isTrue);
      expect(canAccessBuyerApp(AppRoles.admin), isFalse);
      expect(canAccessCourierApp(AppRoles.courier), isTrue);
    });

    test('admin panel access', () {
      expect(canAccessAdminPanel(AppRoles.admin), isTrue);
      expect(canAccessAdminPanel(AppRoles.manager), isTrue);
      expect(canAccessAdminPanel(AppRoles.buyer), isFalse);
    });
  });
}
