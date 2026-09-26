import '../l10n/l10n.dart';

/// Подпись статуса заказа на языке интерфейса. Если статус неизвестен
/// (создан вручную), показывается сохраненное название.
String orderStatusLabel(String? statusId, String? storedName, AppLocalizations l10n) {
  switch (statusId) {
    case 'new':
      return l10n.statusNew;
    case 'processing':
      return l10n.statusProcessing;
    case 'assigned':
      return l10n.statusAssigned;
    case 'delivering':
      return l10n.statusDelivering;
    case 'delivered':
      return l10n.statusDelivered;
    case 'cancelled':
      return l10n.statusCancelled;
    default:
      return storedName ?? l10n.statusNew;
  }
}
