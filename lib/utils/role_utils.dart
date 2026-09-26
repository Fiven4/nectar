import '../l10n/l10n.dart';

class AppRoles {
  static const String guest = 'guest';
  static const String admin = 'admin';
  static const String manager = 'manager';
  static const String courier = 'courier';
  static const String buyer = 'buyer';

  /// Синоним роли покупателя из технического задания.
  static const String customer = 'customer';
}

String roleLabel(String roleCode) {
  final l10n = AppLocale.strings;
  switch (roleCode) {
    case AppRoles.admin:
      return l10n.roleAdmin;
    case AppRoles.manager:
      return l10n.roleManager;
    case AppRoles.courier:
      return l10n.roleCourier;
    case AppRoles.buyer:
    case AppRoles.customer:
      return l10n.roleBuyer;
    default:
      return l10n.roleGuest;
  }
}

bool canAccessAdminPanel(String roleCode) {
  return roleCode == AppRoles.admin || roleCode == AppRoles.manager;
}

bool canAccessBuyerApp(String roleCode) {
  return roleCode == AppRoles.buyer || roleCode == AppRoles.customer;
}

bool canAccessCourierApp(String roleCode) {
  return roleCode == AppRoles.courier;
}

bool isAdminRole(String roleCode) {
  return roleCode == AppRoles.admin;
}

bool isManagerRole(String roleCode) {
  return roleCode == AppRoles.manager;
}

bool canManageProducts(String roleCode) {
  return isAdminRole(roleCode) || isManagerRole(roleCode);
}

bool canDeleteProducts(String roleCode) {
  return isAdminRole(roleCode);
}

bool canManagePromoCodes(String roleCode) {
  return isAdminRole(roleCode) || isManagerRole(roleCode);
}

bool canDeletePromoCodes(String roleCode) {
  return isAdminRole(roleCode) || isManagerRole(roleCode);
}

bool canManageOrders(String roleCode) {
  return isAdminRole(roleCode) || isManagerRole(roleCode);
}
