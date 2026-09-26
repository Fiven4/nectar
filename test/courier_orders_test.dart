import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nectar/utils/courier_orders.dart';

Map<String, dynamic> _order(String id, String statusId, int day) => {
      'id': id,
      'statusId': statusId,
      'createdAt': Timestamp.fromDate(DateTime(2026, 9, day)),
    };

void main() {
  test('курьер начинает доставку только до выезда и завершает только в пути', () {
    for (final status in ['new', 'processing', 'assigned']) {
      expect(canStartDelivery(status), isTrue, reason: status);
      expect(canCompleteDelivery(status), isFalse, reason: status);
    }
    expect(canStartDelivery('delivering'), isFalse);
    expect(canCompleteDelivery('delivering'), isTrue);
    for (final status in ['delivered', 'cancelled']) {
      expect(canStartDelivery(status), isFalse, reason: status);
      expect(canCompleteDelivery(status), isFalse, reason: status);
      expect(isFinishedOrder(status), isTrue, reason: status);
    }
  });

  test('заказы делятся на активные и историю с нужной сортировкой', () {
    final groups = groupCourierOrders([
      _order('done-old', 'delivered', 1),
      _order('assigned-late', 'assigned', 20),
      _order('cancelled', 'cancelled', 12),
      _order('on-the-way', 'delivering', 15),
      _order('assigned-early', 'assigned', 10),
      _order('done-new', 'delivered', 18),
    ]);

    expect(groups.active.map((order) => order['id']), ['on-the-way', 'assigned-early', 'assigned-late']);
    expect(groups.history.map((order) => order['id']), ['done-new', 'cancelled', 'done-old']);
  });

  test('заказ без статуса считается новым и активным', () {
    final groups = groupCourierOrders([
      {'id': 'x'},
    ]);
    expect(groups.active, hasLength(1));
    expect(groups.history, isEmpty);
  });

  test('пустой список', () {
    final groups = groupCourierOrders([]);
    expect(groups.active, isEmpty);
    expect(groups.history, isEmpty);
  });
}
