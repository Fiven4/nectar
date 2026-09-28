import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nectar/models/user_model.dart';
import 'package:nectar/services/database_service.dart';

const _buyerId = 'buyer1';

Future<FakeFirebaseFirestore> _seededStore() async {
  final store = FakeFirebaseFirestore();
  await store.collection('users').doc(_buyerId).set({
    'displayName': 'Борис',
    'email': 'b@example.com',
    'phoneNumber': '+7 900 000-00-00',
    'role': 'buyer',
    'isDeleted': false,
    'login': 'boris',
    'loginNormalized': 'boris',
  });
  await store.collection('orderStatuses').doc('new').set({'name': 'Новый'});
  await store.collection('products').doc('milk').set({
    'name': 'Молоко',
    'price': 100,
    'stockQuantity': 10,
    'isDeleted': false,
  });
  await store.collection('products').doc('bread').set({
    'name': 'Хлеб',
    'price': 50,
    'stockQuantity': 1,
    'isDeleted': false,
  });
  await store.collection('products').doc('gone').set({
    'name': 'Снятый',
    'price': 10,
    'stockQuantity': 5,
    'isDeleted': true,
  });
  await store.collection('promoCodes').doc('sale10').set({
    'code': 'SALE10',
    'codeNormalized': 'SALE10',
    'discountPercent': 10,
    'isActive': true,
    'usageCount': 0,
    'expiresAt': Timestamp.fromDate(DateTime.now().add(const Duration(days: 5))),
  });
  return store;
}

DatabaseService _service(FakeFirebaseFirestore store, {String? actor = _buyerId}) {
  return DatabaseService(firestore: store, currentUserId: () => actor);
}

Future<Map<String, dynamic>> _place(
  DatabaseService service, {
  List<Map<String, dynamic>>? items,
  String address = 'Москва, Тверская 1',
  String payment = 'Наличными',
  Map<String, dynamic>? promo,
}) {
  return service.placeOrder(
    userId: _buyerId,
    orderItems: items ??
        [
          {'id': 'milk', 'name': 'Молоко', 'price': 100, 'quantity': 2},
        ],
    deliveryAddress: address,
    paymentMethod: payment,
    promoCode: promo,
  );
}

void main() {
  group('placeOrder', () {
    test('считает суммы по ценам из базы, списывает остаток и создает заказ', () async {
      final store = await _seededStore();
      final order = await _place(
        _service(store),
        items: [
          // Цена с клиента (1) игнорируется: берется цена товара из базы.
          {'id': 'milk', 'name': 'Молоко', 'price': 1, 'quantity': 2},
        ],
      );

      expect(order['subtotalAmount'], 200);
      expect(order['deliveryAmount'], 149, reason: 'до 1500 доставка платная');
      expect(order['totalAmount'], 349);
      expect(order['statusId'], 'new');
      expect(order['courierId'], isNull);
      expect(order['userId'], _buyerId);

      final saved = await store.collection('orders').doc(order['id'] as String).get();
      expect(saved.exists, isTrue);
      expect((saved.data()!['items'] as List).single['price'], 100);

      final milk = await store.collection('products').doc('milk').get();
      expect(milk.data()!['stockQuantity'], 8);
    });

    test('бесплатная доставка от порога и скидка промокода', () async {
      final store = await _seededStore();
      final promo = {'id': 'sale10', 'code': 'SALE10', 'discountPercent': 10};
      final order = await _place(
        _service(store),
        items: [
          {'id': 'milk', 'name': 'Молоко', 'quantity': 10},
        ],
        promo: promo,
      );

      expect(order['subtotalAmount'], 1000);
      expect(order['discountAmount'], 100);
      expect(order['deliveryAmount'], 149, reason: '900 после скидки < 1500');
      expect(order['totalAmount'], 1049);
      expect(order['promoCodeId'], 'sale10');

      final saved = await store.collection('promoCodes').doc('sale10').get();
      expect(saved.data()!['usageCount'], 1);
    });

    test('нехватка товара отклоняет заказ и ничего не списывает', () async {
      final store = await _seededStore();

      await expectLater(
        _place(_service(store), items: [
          {'id': 'milk', 'name': 'Молоко', 'quantity': 3},
          {'id': 'bread', 'name': 'Хлеб', 'quantity': 2},
        ]),
        throwsA(isA<DatabaseOperationException>()),
      );

      expect((await store.collection('products').doc('milk').get()).data()!['stockQuantity'], 10);
      expect((await store.collection('products').doc('bread').get()).data()!['stockQuantity'], 1);
      expect((await store.collection('orders').get()).docs, isEmpty);
    });

    test('снятый с продажи и несуществующий товар нельзя заказать', () async {
      final store = await _seededStore();
      final service = _service(store);

      await expectLater(
        _place(service, items: [
          {'id': 'gone', 'name': 'Снятый', 'quantity': 1},
        ]),
        throwsA(isA<DatabaseOperationException>()),
      );
      await expectLater(
        _place(service, items: [
          {'id': 'missing', 'name': 'Призрак', 'quantity': 1},
        ]),
        throwsA(isA<DatabaseOperationException>()),
      );
    });

    test('одинаковые товары суммируются при проверке остатка', () async {
      final store = await _seededStore();
      final service = _service(store);

      await expectLater(
        _place(service, items: [
          {'id': 'bread', 'name': 'Хлеб', 'quantity': 1},
          {'id': 'bread', 'name': 'Хлеб', 'quantity': 1},
        ]),
        throwsA(isA<DatabaseOperationException>()),
      );

      final order = await _place(service, items: [
        {'id': 'milk', 'name': 'Молоко', 'quantity': 2},
        {'id': 'milk', 'name': 'Молоко', 'quantity': 3},
      ]);
      expect(order['subtotalAmount'], 500);
      expect((order['items'] as List), hasLength(1));
      expect((await store.collection('products').doc('milk').get()).data()!['stockQuantity'], 5);
    });

    test('проверяет пустую корзину, адрес, оплату и количество', () async {
      final store = await _seededStore();
      final service = _service(store);

      await expectLater(_place(service, items: []), throwsA(isA<DatabaseOperationException>()));
      await expectLater(_place(service, address: '   '), throwsA(isA<DatabaseOperationException>()));
      await expectLater(_place(service, payment: ''), throwsA(isA<DatabaseOperationException>()));
      for (final quantity in [0, -1]) {
        await expectLater(
          _place(service, items: [
            {'id': 'milk', 'name': 'Молоко', 'quantity': quantity},
          ]),
          throwsA(isA<DatabaseOperationException>()),
          reason: 'quantity=$quantity',
        );
      }
      expect((await store.collection('products').doc('milk').get()).data()!['stockQuantity'], 10);
    });

    test('неизвестный пользователь не может оформить заказ', () async {
      final store = await _seededStore();
      await expectLater(
        _service(store).placeOrder(
          userId: 'nobody',
          orderItems: [
            {'id': 'milk', 'name': 'Молоко', 'quantity': 1},
          ],
          deliveryAddress: 'Адрес',
          paymentMethod: 'Наличными',
        ),
        throwsA(isA<DatabaseOperationException>()),
      );
    });
  });

  group('validatePromoCode', () {
    test('находит действующий код без учета регистра и пробелов', () async {
      final store = await _seededStore();
      final promo = await _service(store).validatePromoCode('  sale10 ');
      expect(promo['id'], 'sale10');
      expect(promo['discountPercent'], 10);
    });

    test('отклоняет неизвестный, просроченный и отключенный код', () async {
      final store = await _seededStore();
      await store.collection('promoCodes').doc('old').set({
        'code': 'OLD',
        'codeNormalized': 'OLD',
        'discountPercent': 5,
        'expiresAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 1))),
      });
      await store.collection('promoCodes').doc('off').set({
        'code': 'OFF',
        'codeNormalized': 'OFF',
        'discountPercent': 5,
        'isActive': false,
        'expiresAt': Timestamp.fromDate(DateTime.now().add(const Duration(days: 1))),
      });

      final service = _service(store);
      for (final code in ['NOPE', 'OLD', 'OFF']) {
        await expectLater(service.validatePromoCode(code), throwsA(isA<DatabaseOperationException>()), reason: code);
      }
    });
  });

  group('updateOrder', () {
    test('уведомляет покупателя о доставке ровно один раз', () async {
      final store = await _seededStore();
      await store.collection('orderStatuses').doc('delivered').set({'name': 'Доставлен'});
      await store.collection('orders').doc('o1').set({
        'userId': _buyerId,
        'number': 'ORD-1',
        'statusId': 'delivering',
        'statusName': 'В пути',
      });
      final service = _service(store, actor: 'courier1');

      await service.updateOrder(orderId: 'o1', statusId: 'delivered', courierId: 'courier1');
      await service.updateOrder(orderId: 'o1', statusId: 'delivered', courierId: 'courier1');

      final notifications = await store.collection('notifications').get();
      expect(notifications.docs, hasLength(1));
      expect(notifications.docs.single.data()['userId'], _buyerId);
      expect(notifications.docs.single.data()['textEn'], contains('ORD-1'));
      expect((await store.collection('orders').doc('o1').get()).data()!['statusId'], 'delivered');
    });

    test('несуществующий заказ вызывает понятную ошибку', () async {
      final store = await _seededStore();
      await expectLater(
        _service(store).updateOrder(orderId: 'nope', statusId: 'delivering'),
        throwsA(isA<DatabaseOperationException>()),
      );
    });
  });

  group('пользователи и логины', () {
    test('логин уникален', () async {
      final store = FakeFirebaseFirestore();
      final service = _service(store);
      UserModel user(String id, String login) => UserModel(
            id: id,
            login: login,
            name: 'Имя',
            email: '$id@example.com',
            phoneNumber: '+7 900 000-00-00',
            role: 'buyer',
          );

      await service.createUser(user('u1', 'Ivan'));
      await expectLater(service.createUser(user('u2', 'ivan')), throwsA(isA<DatabaseOperationException>()));
      await expectLater(service.assertLoginAvailable('IVAN'), throwsA(isA<DatabaseOperationException>()));
      await service.assertLoginAvailable('other');

      expect(await service.resolveEmailForIdentifier('IVAN'), 'u1@example.com');
      expect(await service.resolveEmailForIdentifier('A@B.COM'), 'a@b.com');
      await expectLater(service.resolveEmailForIdentifier('ghost'), throwsA(isA<DatabaseOperationException>()));
    });

    test('логин освобождается и возвращается обратно', () async {
      final store = await _seededStore();
      await store.collection('loginIndex').doc('boris').set({'uid': _buyerId, 'email': 'b@example.com'});
      final service = _service(store);

      final released = await service.releaseLoginIndex(_buyerId);
      expect(released, isNotNull);
      expect((await store.collection('loginIndex').doc('boris').get()).exists, isFalse);
      await service.assertLoginAvailable('boris');

      await service.restoreLoginIndex(released);
      expect((await store.collection('loginIndex').doc('boris').get()).data(), {'uid': _buyerId, 'email': 'b@example.com'});
    });

    test('чужой логин освободить нельзя', () async {
      final store = await _seededStore();
      await store.collection('loginIndex').doc('boris').set({'uid': 'someone-else', 'email': 'x@example.com'});

      expect(await _service(store).releaseLoginIndex(_buyerId), isNull);
      expect((await store.collection('loginIndex').doc('boris').get()).exists, isTrue);
    });

    test('удаление аккаунта запоминает, кто удалил, а откат снимает отметку', () async {
      final store = await _seededStore();
      final service = _service(store);

      await service.deleteUser(_buyerId);
      var data = (await store.collection('users').doc(_buyerId).get()).data()!;
      expect(data['isDeleted'], isTrue);
      expect(data['deletedBy'], _buyerId);

      await service.restoreUser(_buyerId);
      data = (await store.collection('users').doc(_buyerId).get()).data()!;
      expect(data['isDeleted'], isFalse);
      expect(data.containsKey('deletedBy'), isFalse);
    });

    test('нельзя удалить аккаунт с незавершенным заказом, завершенные не мешают', () async {
      final store = await _seededStore();
      final service = _service(store);
      await store.collection('orders').doc('done').set({'userId': _buyerId, 'statusId': 'delivered', 'statusName': 'Доставлен'});
      await store.collection('orders').doc('cancelled').set({'userId': _buyerId, 'statusId': 'cancelled', 'statusName': 'Отменен'});
      await service.deleteUser(_buyerId);
      await service.restoreUser(_buyerId);

      await store.collection('orders').doc('active').set({'userId': _buyerId, 'statusId': 'processing', 'statusName': 'В сборке'});
      await expectLater(service.deleteUser(_buyerId), throwsA(isA<DatabaseOperationException>()));
      expect((await store.collection('users').doc(_buyerId).get()).data()!['isDeleted'], isFalse);
    });
  });

  group('курьер берет заказы сам', () {
    Future<void> seedOrders(FakeFirebaseFirestore store) async {
      await store.collection('users').doc('courier1').set({'displayName': 'Иван Курьер', 'phoneNumber': '+7 900 111-22-33', 'role': 'courier'});
      await store.collection('users').doc('courier2').set({'displayName': 'Второй', 'phoneNumber': '+7 900 000-00-00', 'role': 'courier'});
      await store.collection('orders').doc('free-new').set({
        'userId': _buyerId, 'number': 'ORD-1', 'statusId': 'new', 'statusName': 'Новый', 'courierId': null,
        'createdAt': Timestamp.fromDate(DateTime(2026, 9, 2)),
      });
      await store.collection('orders').doc('free-processing').set({
        'userId': _buyerId, 'number': 'ORD-2', 'statusId': 'processing', 'statusName': 'В сборке', 'courierId': null,
        'createdAt': Timestamp.fromDate(DateTime(2026, 9, 1)),
      });
      await store.collection('orders').doc('taken').set({
        'userId': _buyerId, 'number': 'ORD-3', 'statusId': 'assigned', 'statusName': 'Передан курьеру', 'courierId': 'courier2',
      });
      await store.collection('orders').doc('cancelled').set({
        'userId': _buyerId, 'number': 'ORD-4', 'statusId': 'cancelled', 'statusName': 'Отменен', 'courierId': null,
      });
    }

    test('пул содержит только свободные заказы, старые первыми', () async {
      final store = await _seededStore();
      await seedOrders(store);

      final pool = await _service(store, actor: 'courier1').watchAvailableOrders().first;
      expect(pool.map((order) => order['id']), ['free-processing', 'free-new']);
    });

    test('взятый заказ закрепляется за курьером, покупатель получает уведомление', () async {
      final store = await _seededStore();
      await seedOrders(store);
      final service = _service(store, actor: 'courier1');

      await service.claimOrder(orderId: 'free-new', courierId: 'courier1');

      final order = (await store.collection('orders').doc('free-new').get()).data()!;
      expect(order['courierId'], 'courier1');
      expect(order['courierName'], 'Иван Курьер');
      expect(order['courierPhone'], '+7 900 111-22-33');
      expect(order['statusId'], 'assigned');

      final notifications = await store.collection('notifications').get();
      expect(notifications.docs.single.data()['userId'], _buyerId);
      expect(notifications.docs.single.data()['textEn'], contains('ORD-1'));

      final pool = await service.watchAvailableOrders().first;
      expect(pool.map((item) => item['id']), ['free-processing']);
    });

    test('второй курьер не может взять уже взятый, чужой или отмененный заказ', () async {
      final store = await _seededStore();
      await seedOrders(store);
      final service = _service(store, actor: 'courier2');

      await _service(store, actor: 'courier1').claimOrder(orderId: 'free-new', courierId: 'courier1');
      for (final id in ['free-new', 'taken', 'cancelled']) {
        await expectLater(
          service.claimOrder(orderId: id, courierId: 'courier2'),
          throwsA(isA<DatabaseOperationException>()),
          reason: id,
        );
      }
      await expectLater(service.claimOrder(orderId: 'missing', courierId: 'courier2'), throwsA(isA<DatabaseOperationException>()));
      expect((await store.collection('orders').doc('free-new').get()).data()!['courierId'], 'courier1');
    });

    test('заказ можно вернуть в пул только до выезда и только свой', () async {
      final store = await _seededStore();
      await seedOrders(store);
      final service = _service(store, actor: 'courier1');
      await service.claimOrder(orderId: 'free-new', courierId: 'courier1');

      await expectLater(
        _service(store, actor: 'courier2').releaseOrder(orderId: 'free-new', courierId: 'courier2'),
        throwsA(isA<DatabaseOperationException>()),
      );

      await service.releaseOrder(orderId: 'free-new', courierId: 'courier1');
      final released = (await store.collection('orders').doc('free-new').get()).data()!;
      expect(released['courierId'], isNull);
      expect(released['statusId'], 'processing');
      expect((await service.watchAvailableOrders().first).map((order) => order['id']), contains('free-new'));

      await service.claimOrder(orderId: 'free-new', courierId: 'courier1');
      await service.updateOrder(orderId: 'free-new', statusId: 'delivering', courierId: 'courier1');
      await expectLater(
        service.releaseOrder(orderId: 'free-new', courierId: 'courier1'),
        throwsA(isA<DatabaseOperationException>()),
      );
    });
  });

  group('адреса и карты', () {
    test('адрес: пустой и слишком длинный отклоняются, дубликат не добавляется', () async {
      final store = await _seededStore();
      final service = _service(store);

      await expectLater(service.addDeliveryAddress(userId: _buyerId, address: '  '), throwsA(isA<DatabaseOperationException>()));
      await expectLater(
        service.addDeliveryAddress(userId: _buyerId, address: 'а' * 301),
        throwsA(isA<DatabaseOperationException>()),
      );

      await service.addDeliveryAddress(userId: _buyerId, address: ' Москва ');
      await service.addDeliveryAddress(userId: _buyerId, address: 'Москва');
      final data = (await store.collection('users').doc(_buyerId).get()).data()!;
      expect(data['addresses'], ['Москва']);
    });

    test('карта хранится только в маске, номер из 16 цифр', () async {
      final store = await _seededStore();
      final service = _service(store);

      await expectLater(service.addPaymentCard(userId: _buyerId, cardNumber: '1234'), throwsA(isA<DatabaseOperationException>()));
      await service.addPaymentCard(userId: _buyerId, cardNumber: '1234 5678 9012 3456');

      final data = (await store.collection('users').doc(_buyerId).get()).data()!;
      expect(data['cards'], ['**** **** **** 3456']);
      expect(data.toString(), isNot(contains('1234567890123456')));
    });
  });

  group('аватар', () {
    test('хранится в профиле как base64, слишком большой и пустой отклоняются', () async {
      final store = await _seededStore();
      final service = _service(store);
      final bytes = Uint8List.fromList(List.generate(1000, (index) => index % 256));

      await service.saveUserAvatar(userId: _buyerId, imageBytes: bytes);
      final data = (await store.collection('users').doc(_buyerId).get()).data()!;
      expect(base64Decode(data['photoData'] as String), bytes);

      await expectLater(
        service.saveUserAvatar(userId: _buyerId, imageBytes: Uint8List(DatabaseService.maxAvatarBytes + 1)),
        throwsA(isA<DatabaseOperationException>()),
      );
      await expectLater(
        service.saveUserAvatar(userId: _buyerId, imageBytes: Uint8List(0)),
        throwsA(isA<DatabaseOperationException>()),
      );
    });
  });

  group('избранное', () {
    test('добавление и удаление', () async {
      final store = await _seededStore();
      final service = _service(store);

      await service.setFavorite(userId: _buyerId, productId: 'milk', isFavorite: true);
      await service.setFavorite(userId: _buyerId, productId: 'milk', isFavorite: true);
      await service.setFavorite(userId: _buyerId, productId: 'bread', isFavorite: true);
      expect(await service.watchFavoriteIds(_buyerId).first, {'milk', 'bread'});

      await service.setFavorite(userId: _buyerId, productId: 'milk', isFavorite: false);
      expect(await service.watchFavoriteIds(_buyerId).first, {'bread'});
    });
  });
}
