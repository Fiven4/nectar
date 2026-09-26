import 'parsers.dart';

const Set<String> _startableStatuses = {'new', 'processing', 'assigned'};
const Set<String> _finishedStatuses = {'delivered', 'cancelled'};

/// Курьер может начать доставку, пока заказ не в пути и не завершен.
bool canStartDelivery(String statusId) => _startableStatuses.contains(statusId);

/// Завершить доставку можно только у заказа «в пути».
bool canCompleteDelivery(String statusId) => statusId == 'delivering';

bool isFinishedOrder(String statusId) => _finishedStatuses.contains(statusId);

class CourierOrderGroups {
  const CourierOrderGroups({required this.active, required this.history});

  final List<Map<String, dynamic>> active;
  final List<Map<String, dynamic>> history;
}

/// Делит заказы курьера на активные и историю.
/// Активные: сначала «в пути», затем по времени создания (старые раньше).
/// История: новые сверху.
CourierOrderGroups groupCourierOrders(List<Map<String, dynamic>> orders) {
  String statusOf(Map<String, dynamic> order) => order['statusId']?.toString() ?? 'new';
  DateTime createdAt(Map<String, dynamic> order) => toDateTimeValue(order['createdAt']);

  final active = orders.where((order) => !isFinishedOrder(statusOf(order))).toList()
    ..sort((left, right) {
      final leftOnTheWay = canCompleteDelivery(statusOf(left));
      final rightOnTheWay = canCompleteDelivery(statusOf(right));
      if (leftOnTheWay != rightOnTheWay) return leftOnTheWay ? -1 : 1;
      return createdAt(left).compareTo(createdAt(right));
    });
  final history = orders.where((order) => isFinishedOrder(statusOf(order))).toList()
    ..sort((left, right) => createdAt(right).compareTo(createdAt(left)));

  return CourierOrderGroups(active: active, history: history);
}
