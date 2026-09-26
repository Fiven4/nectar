import 'dart:math' as math;

import '../l10n/l10n.dart';

const double freeDeliveryThreshold = 1500;
const double standardDeliveryFee = 149;

/// Стоимость доставки зависит от суммы заказа после скидки.
double calculateDeliveryFee(double amountAfterDiscount) {
  if (amountAfterDiscount <= 0 || amountAfterDiscount >= freeDeliveryThreshold) {
    return 0;
  }
  return standardDeliveryFee;
}

double calculateOrderTotal({
  required double subtotal,
  required double discountPercent,
}) {
  final discount = subtotal * discountPercent / 100;
  final afterDiscount = math.max(0.0, subtotal - discount);
  return afterDiscount + calculateDeliveryFee(afterDiscount);
}

/// В заказе способ оплаты хранится русским словом (для персонала), пользователю показывается перевод.
String paymentMethodLabel(String? stored, AppLocalizations l10n) {
  switch (stored) {
    case 'Онлайн':
      return l10n.paymentOnline;
    case 'Наличными':
      return l10n.paymentCash;
    default:
      return stored ?? l10n.notSpecifiedFem;
  }
}

String formatMoney(num value) => '₽${value.toStringAsFixed(2)}';

/// Ключ первого слота: в заказ пишется русская подпись (для персонала),
/// а пользователю показывается перевод через [deliverySlotLabel].
const String asapSlot = 'Как можно скорее (до 60 минут)';

String deliverySlotLabel(String slot, AppLocalizations l10n) => slot == asapSlot ? l10n.slotAsap : slot;

const List<String> deliverySlots = [
  asapSlot,
  '09:00 – 11:00',
  '11:00 – 13:00',
  '13:00 – 15:00',
  '15:00 – 17:00',
  '17:00 – 19:00',
  '19:00 – 21:00',
];
