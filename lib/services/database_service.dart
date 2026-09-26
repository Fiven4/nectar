import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../data/catalog_translations.dart';
import '../data/product_catalog.dart';
import '../l10n/l10n.dart';
import '../models/product_model.dart';
import '../models/user_model.dart';
import '../utils/parsers.dart';
import '../utils/pricing.dart';
import '../utils/role_utils.dart';

class DatabaseOperationException implements Exception {
  final String message;

  const DatabaseOperationException(this.message);

  @override
  String toString() => message;
}

class DatabaseService {
  DatabaseService({
    FirebaseFirestore? firestore,
    String? Function()? currentUserId,
  })  : _database = firestore ?? FirebaseFirestore.instance,
        _currentUserId = currentUserId ?? (() => FirebaseAuth.instance.currentUser?.uid);

  final FirebaseFirestore _database;
  final String? Function() _currentUserId;

  CollectionReference<Map<String, dynamic>> get _usersCollection => _database.collection('users');
  CollectionReference<Map<String, dynamic>> get _productsCollection => _database.collection('products');
  CollectionReference<Map<String, dynamic>> get _categoriesCollection => _database.collection('categories');
  CollectionReference<Map<String, dynamic>> get _manufacturersCollection => _database.collection('manufacturers');
  CollectionReference<Map<String, dynamic>> get _suppliersCollection => _database.collection('suppliers');
  CollectionReference<Map<String, dynamic>> get _rolesCollection => _database.collection('roles');
  CollectionReference<Map<String, dynamic>> get _promoCodesCollection => _database.collection('promoCodes');
  CollectionReference<Map<String, dynamic>> get _orderStatusesCollection => _database.collection('orderStatuses');
  CollectionReference<Map<String, dynamic>> get _ordersCollection => _database.collection('orders');
  CollectionReference<Map<String, dynamic>> get _notificationsCollection => _database.collection('notifications');

  /// Публичный индекс «логин -> email»: по нему гость находит почту при входе
  /// по логину, не имея доступа к самим профилям. Документ создается один раз,
  /// что гарантирует уникальность логина.
  CollectionReference<Map<String, dynamic>> get _loginIndexCollection => _database.collection('loginIndex');

  Future<void> createUser(UserModel user) async {
    final normalizedLogin = user.login.trim().toLowerCase();
    final normalizedEmail = user.email.trim().toLowerCase();
    final indexReference = _loginIndexCollection.doc(normalizedLogin);
    final userReference = _usersCollection.doc(user.id);

    await _database.runTransaction((transaction) async {
      final indexDocument = await transaction.get(indexReference);
      if (indexDocument.exists && indexDocument.data()?['uid'] != user.id) {
        throw DatabaseOperationException(AppLocale.strings.errLoginTaken);
      }

      if (!indexDocument.exists) {
        transaction.set(indexReference, {'uid': user.id, 'email': normalizedEmail});
      }

      transaction.set(userReference, {
        ...user.toJson(),
        'addresses': <String>[],
        'cards': <String>[],
        'notificationSettings': {
          'push': true,
          'sms': false,
          'email': true,
        },
        'isDeleted': false,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    });
  }

  Future<void> ensureUserProfileFromAuth(
    User firebaseUser, {
    String defaultRole = AppRoles.buyer,
  }) async {
    final userReference = _usersCollection.doc(firebaseUser.uid);
    final email = (firebaseUser.email ?? '').trim().toLowerCase();

    await _database.runTransaction((transaction) async {
      final userDocument = await transaction.get(userReference);
      final currentData = userDocument.data() ?? <String, dynamic>{};

      var loginValue = (currentData['login'] ??
              _buildDefaultLogin(email, firebaseUser.displayName ?? ''))
          .toString();

      var indexReference = _loginIndexCollection.doc(loginValue.trim().toLowerCase());
      var indexDocument = await transaction.get(indexReference);
      var shouldCreateIndex = !indexDocument.exists;
      final loginTakenByAnother = indexDocument.exists && indexDocument.data()?['uid'] != firebaseUser.uid;
      if (loginTakenByAnother && currentData['login'] == null) {
        // Сгенерированный логин занят другим пользователем: подбираем свободный.
        loginValue = '$loginValue${firebaseUser.uid.substring(0, 4).toLowerCase()}';
        indexReference = _loginIndexCollection.doc(loginValue.toLowerCase());
        indexDocument = await transaction.get(indexReference);
        shouldCreateIndex = !indexDocument.exists;
      }

      final defaults = <String, dynamic>{
        'uid': firebaseUser.uid,
        'login': loginValue,
        'loginNormalized': loginValue.trim().toLowerCase(),
        'email': email,
        'emailNormalized': email,
        'displayName': firebaseUser.displayName ?? 'Пользователь',
        'phoneNumber': '',
        'role': defaultRole,
        'addresses': <String>[],
        'cards': <String>[],
        'notificationSettings': {
          'push': true,
          'sms': false,
          'email': true,
        },
        'isDeleted': false,
        'createdAt': FieldValue.serverTimestamp(),
      };

      final updates = <String, dynamic>{
        for (final entry in defaults.entries)
          if (currentData[entry.key] == null) entry.key: entry.value,
      };

      final authPhotoUrl = firebaseUser.photoURL;
      if (authPhotoUrl != null && authPhotoUrl != currentData['photoUrl']) {
        updates['photoUrl'] = authPhotoUrl;
      }

      if (shouldCreateIndex && email.isNotEmpty) {
        transaction.set(indexReference, {'uid': firebaseUser.uid, 'email': email});
      }

      if (updates.isEmpty) {
        return;
      }

      updates['updatedAt'] = FieldValue.serverTimestamp();
      transaction.set(userReference, updates, SetOptions(merge: true));
    });
  }

  Future<String> resolveEmailForIdentifier(String loginOrEmail) async {
    final normalizedIdentifier = loginOrEmail.trim();

    if (normalizedIdentifier.contains('@')) {
      return normalizedIdentifier.toLowerCase();
    }

    final indexDocument = await _loginIndexCollection.doc(normalizedIdentifier.toLowerCase()).get();
    final email = _stringValue(indexDocument.data()?['email']);
    if (email.isEmpty) {
      throw DatabaseOperationException(AppLocale.strings.errLoginNotFound);
    }
    return email;
  }

  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    final userDocument = await _usersCollection.doc(userId).get();
    if (!userDocument.exists) {
      return null;
    }
    return _documentToMap(userDocument);
  }

  Stream<Map<String, dynamic>?> watchUserProfile(String userId) {
    return _usersCollection.doc(userId).snapshots().map((userDocument) {
      if (!userDocument.exists) {
        return null;
      }
      return _documentToMap(userDocument);
    });
  }

  Stream<List<Map<String, dynamic>>> watchProducts({
    bool includeDeleted = false,
  }) {
    return _productsCollection.snapshots().map((snapshot) {
      final products = snapshot.docs
          .map(_documentToMap)
          .where((product) => includeDeleted || product['isDeleted'] != true)
          .toList();
      products.sort((leftProduct, rightProduct) {
        return _stringValue(leftProduct['name']).compareTo(_stringValue(rightProduct['name']));
      });
      return products;
    });
  }

  Stream<List<Product>> watchCatalog() {
    return watchProducts().map((products) => products.map(Product.fromMap).toList());
  }

  Stream<List<Map<String, dynamic>>> watchCategories() {
    return _watchOrderedCollection(_categoriesCollection, 'name');
  }

  Stream<List<Map<String, dynamic>>> watchManufacturers() {
    return _watchOrderedCollection(_manufacturersCollection, 'name');
  }

  Stream<List<Map<String, dynamic>>> watchSuppliers() {
    return _watchOrderedCollection(_suppliersCollection, 'name');
  }

  Stream<List<Map<String, dynamic>>> watchRoles() {
    return _watchOrderedCollection(_rolesCollection, 'name');
  }

  Stream<List<Map<String, dynamic>>> watchPromoCodes() {
    return _promoCodesCollection.snapshots().map((snapshot) {
      final promoCodes = snapshot.docs.map(_documentToMap).toList();
      promoCodes.sort((leftPromoCode, rightPromoCode) {
        return _stringValue(leftPromoCode['code']).compareTo(_stringValue(rightPromoCode['code']));
      });
      return promoCodes;
    });
  }

  Stream<List<Map<String, dynamic>>> watchOrderStatuses() {
    return _watchOrderedCollection(_orderStatusesCollection, 'name');
  }

  Stream<List<Map<String, dynamic>>> watchUsers() {
    return _usersCollection.snapshots().map((snapshot) {
      final users = snapshot.docs
          .map(_documentToMap)
          .where((user) => user['isDeleted'] != true)
          .toList();
      users.sort((leftUser, rightUser) {
        return _stringValue(leftUser['displayName']).compareTo(_stringValue(rightUser['displayName']));
      });
      return users;
    });
  }

  Stream<List<Map<String, dynamic>>> watchOrders() {
    return _ordersCollection.snapshots().map((snapshot) {
      final orders = snapshot.docs.map(_documentToMap).toList();
      orders.sort((leftOrder, rightOrder) {
        return _dateTimeValue(rightOrder['createdAt']).compareTo(_dateTimeValue(leftOrder['createdAt']));
      });
      return orders;
    });
  }

  Stream<List<Map<String, dynamic>>> watchOrdersForUser(String userId) {
    return _watchOrdersWhere('userId', userId);
  }

  Stream<List<Map<String, dynamic>>> watchAssignedOrders(String courierId) {
    return _watchOrdersWhere('courierId', courierId);
  }

  Stream<List<Map<String, dynamic>>> _watchOrdersWhere(String field, String value) {
    return _ordersCollection.where(field, isEqualTo: value).snapshots().map((snapshot) {
      final orders = snapshot.docs.map(_documentToMap).toList();
      orders.sort((leftOrder, rightOrder) {
        return _dateTimeValue(rightOrder['createdAt']).compareTo(_dateTimeValue(leftOrder['createdAt']));
      });
      return orders;
    });
  }

  Stream<List<Map<String, dynamic>>> watchNotifications(String userId) {
    return _notificationsCollection.where('userId', isEqualTo: userId).snapshots().map((snapshot) {
      final notifications = snapshot.docs.map(_documentToMap).toList();
      notifications.sort((leftNotification, rightNotification) {
        return _dateTimeValue(rightNotification['createdAt']).compareTo(_dateTimeValue(leftNotification['createdAt']));
      });
      return notifications;
    });
  }

  Stream<Set<String>> watchFavoriteIds(String userId) {
    return _usersCollection.doc(userId).snapshots().map((userDocument) {
      final favorites = userDocument.data()?['favorites'];
      if (favorites is! List) {
        return <String>{};
      }
      return favorites.map((id) => id.toString()).toSet();
    });
  }

  Future<void> setFavorite({
    required String userId,
    required String productId,
    required bool isFavorite,
  }) async {
    await _usersCollection.doc(userId).set({
      'favorites': isFavorite
          ? FieldValue.arrayUnion([productId])
          : FieldValue.arrayRemove([productId]),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> updateUserProfile({
    required String userId,
    required String displayName,
    required String phoneNumber,
  }) async {
    await _usersCollection.doc(userId).set({
      'displayName': displayName.trim(),
      'phoneNumber': phoneNumber.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Максимальный размер аватара после сжатия. Картинка хранится прямо в
  /// документе профиля (Firebase Storage платный), поэтому она маленькая.
  static const int maxAvatarBytes = 150 * 1024;

  /// Сохраняет аватар в профиле как base64 (JPEG/PNG уже уменьшены на устройстве).
  Future<void> saveUserAvatar({
    required String userId,
    required Uint8List imageBytes,
  }) async {
    if (imageBytes.isEmpty || imageBytes.length > maxAvatarBytes) {
      throw DatabaseOperationException(AppLocale.strings.avatarTooBig);
    }
    await _usersCollection.doc(userId).set({
      'photoData': base64Encode(imageBytes),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> saveNotificationSettings({
    required String userId,
    required bool pushEnabled,
    required bool smsEnabled,
    required bool emailEnabled,
  }) async {
    await _usersCollection.doc(userId).set({
      'notificationSettings': {
        'push': pushEnabled,
        'sms': smsEnabled,
        'email': emailEnabled,
      },
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> addDeliveryAddress({
    required String userId,
    required String address,
  }) async {
    final normalizedAddress = address.trim();
    if (normalizedAddress.isEmpty) {
      throw DatabaseOperationException(AppLocale.strings.errAddressEmpty);
    }
    if (normalizedAddress.length > 300) {
      throw DatabaseOperationException(AppLocale.strings.errAddressTooLong);
    }

    await _usersCollection.doc(userId).set({
      'addresses': FieldValue.arrayUnion([normalizedAddress]),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> removeDeliveryAddress({
    required String userId,
    required String address,
  }) async {
    await _usersCollection.doc(userId).set({
      'addresses': FieldValue.arrayRemove([address]),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> addPaymentCard({
    required String userId,
    required String cardNumber,
  }) async {
    final normalizedCardNumber = cardNumber.replaceAll(RegExp(r'\D'), '');
    if (normalizedCardNumber.length != 16) {
      throw DatabaseOperationException(AppLocale.strings.errCardLength);
    }

    final maskedCardNumber = '**** **** **** ${normalizedCardNumber.substring(12)}';

    await _usersCollection.doc(userId).set({
      'cards': FieldValue.arrayUnion([maskedCardNumber]),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> removePaymentCard({
    required String userId,
    required String maskedCardNumber,
  }) async {
    await _usersCollection.doc(userId).set({
      'cards': FieldValue.arrayRemove([maskedCardNumber]),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<Map<String, dynamic>> validatePromoCode(String promoCode) async {
    final normalizedPromoCode = promoCode.trim().toUpperCase();
    final invalidMessage = AppLocale.strings.errPromoInvalid;

    final promoCodes = await _promoCodesCollection
        .where('codeNormalized', isEqualTo: normalizedPromoCode)
        .get();
    final currentDate = DateTime.now();

    for (final promoCodeDocument in promoCodes.docs) {
      final promoCodeData = promoCodeDocument.data();
      if (promoCodeData['isActive'] == false) {
        continue;
      }

      if (_dateTimeValue(promoCodeData['expiresAt']).isBefore(currentDate)) {
        continue;
      }

      return _documentToMap(promoCodeDocument);
    }

    throw DatabaseOperationException(invalidMessage);
  }

  Future<Map<String, dynamic>> placeOrder({
    required String userId,
    required List<Map<String, dynamic>> orderItems,
    required String deliveryAddress,
    required String paymentMethod,
    String? paymentCard,
    String? deliverySlot,
    Map<String, dynamic>? promoCode,
  }) async {
    if (orderItems.isEmpty) {
      throw DatabaseOperationException(AppLocale.strings.errCartEmpty);
    }

    if (deliveryAddress.trim().isEmpty) {
      throw DatabaseOperationException(AppLocale.strings.errDeliveryAddressRequired);
    }

    if (paymentMethod.trim().isEmpty) {
      throw DatabaseOperationException(AppLocale.strings.errPaymentMethodRequired);
    }

    // Одинаковые товары объединяются: остаток проверяется по суммарному количеству.
    final mergedItems = <String, Map<String, dynamic>>{};
    for (final orderItem in orderItems) {
      final productId = _stringValue(orderItem['id']);
      final productQuantity = _intValue(orderItem['quantity']);
      if (productQuantity <= 0) {
        throw DatabaseOperationException(AppLocale.strings.errQuantityPositive);
      }
      final existingItem = mergedItems[productId];
      mergedItems[productId] = {
        ...(existingItem ?? orderItem),
        'quantity': (existingItem == null ? 0 : _intValue(existingItem['quantity'])) + productQuantity,
      };
    }
    final normalizedOrderItems = mergedItems.values.toList();

    final userDocument = await _usersCollection.doc(userId).get();
    final userData = userDocument.data();
    if (!userDocument.exists || userData == null) {
      throw DatabaseOperationException(AppLocale.strings.errUserNotFound);
    }

    final orderStatusDocument = await _orderStatusesCollection.doc('new').get();
    final orderStatusData = orderStatusDocument.data() ??
        {
          'code': 'new',
          'name': 'Новый',
        };

    final orderDocumentReference = _ordersCollection.doc();

    final createdOrder = await _database.runTransaction<Map<String, dynamic>>((transaction) async {
      // Firestore требует, чтобы все чтения шли до записей.
      final productDocs = <String, DocumentSnapshot<Map<String, dynamic>>>{};
      for (final orderItem in normalizedOrderItems) {
        final productId = _stringValue(orderItem['id']);
        productDocs[productId] = await transaction.get(_productsCollection.doc(productId));
      }

      double subtotalAmount = 0;
      final normalizedItems = <Map<String, dynamic>>[];
      final stockUpdates = <DocumentReference<Map<String, dynamic>>, int>{};

      for (final orderItem in normalizedOrderItems) {
        final productId = _stringValue(orderItem['id']);
        final productQuantity = _intValue(orderItem['quantity']);
        if (productQuantity <= 0) {
          throw DatabaseOperationException(AppLocale.strings.errQuantityPositive);
        }

        final productDocument = productDocs[productId]!;
        final productData = productDocument.data();

        if (productData == null || productData['isDeleted'] == true) {
          throw DatabaseOperationException(AppLocale.strings.errProductUnavailable(orderItem['name'].toString()));
        }

        final productStockQuantity = _intValue(productData['stockQuantity'] ?? productData['stock'] ?? 0);
        if (productStockQuantity < productQuantity) {
          throw DatabaseOperationException(AppLocale.strings.errNotEnoughStock(_stringValue(productData['name'])));
        }

        final productPrice = _doubleValue(productData['price']);
        subtotalAmount += productPrice * productQuantity;

        normalizedItems.add({
          'id': productId,
          'name': productData['name'],
          'nameEn': _stringValue(productData['nameEn']).isNotEmpty
              ? productData['nameEn']
              : (productTranslations[productId]?.name ?? ''),
          'price': productPrice,
          'quantity': productQuantity,
          'imageUrl': productData['imageUrl'],
          'categoryName': productData['categoryName'],
        });

        stockUpdates[productDocument.reference] = productStockQuantity - productQuantity;
      }

      // Записи выполняются только после проверки всех позиций.
      stockUpdates.forEach((reference, remainingStock) {
        transaction.update(reference, {
          'stockQuantity': remainingStock,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });

      final discountPercent = _intValue(promoCode?['discountPercent']);
      final discountAmount = subtotalAmount * discountPercent / 100;
      final deliveryAmount = calculateDeliveryFee(subtotalAmount - discountAmount);
      final totalAmount = subtotalAmount - discountAmount + deliveryAmount;

      final orderData = {
        'number': 'ORD-${DateTime.now().millisecondsSinceEpoch}',
        'userId': userId,
        'customerName': userData['displayName'] ?? 'Покупатель',
        'customerEmail': userData['email'] ?? '',
        'customerPhone': userData['phoneNumber'] ?? '',
        'customerRole': userData['role'] ?? AppRoles.buyer,
        'address': deliveryAddress.trim(),
        'paymentMethod': paymentMethod.trim(),
        'paymentCard': paymentCard,
        'deliverySlot': deliverySlot,
        'promoCodeId': promoCode?['id'],
        'promoCode': promoCode?['code'],
        'discountPercent': discountPercent,
        'discountAmount': discountAmount,
        'subtotalAmount': subtotalAmount,
        'deliveryAmount': deliveryAmount,
        'totalAmount': totalAmount,
        'statusId': orderStatusDocument.id,
        'statusName': orderStatusData['name'] ?? 'Новый',
        'courierId': null,
        'courierName': null,
        'items': normalizedItems,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      transaction.set(orderDocumentReference, orderData);

      if (promoCode != null) {
        transaction.update(_promoCodesCollection.doc(promoCode['id'].toString()), {
          'usageCount': FieldValue.increment(1),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      return {
        'id': orderDocumentReference.id,
        ...orderData,
      };
    });

    return createdOrder;
  }

  Future<void> updateOrder({
    required String orderId,
    required String statusId,
    String? courierId,
  }) async {
    final statusSnapshot = await _orderStatusesCollection.doc(statusId).get();
    final fallbackStatusSnapshot = await _orderStatusesCollection.doc('processing').get();
    final statusData = statusSnapshot.data() ?? fallbackStatusSnapshot.data() ?? {'name': 'В обработке'};

    final orderDocument = await _ordersCollection.doc(orderId).get();
    final orderData = orderDocument.data();
    if (orderData == null) {
      throw DatabaseOperationException(AppLocale.strings.errOrderNotFound);
    }

    String? courierName;
    String? courierPhone;
    if (courierId != null && courierId.isNotEmpty) {
      final courierDocument = await _usersCollection.doc(courierId).get();
      courierName = courierDocument.data()?['displayName']?.toString();
      courierPhone = courierDocument.data()?['phoneNumber']?.toString();
    }

    await _ordersCollection.doc(orderId).set({
      'statusId': statusId,
      'statusName': statusData['name'] ?? 'В обработке',
      'courierId': courierId,
      'courierName': courierName,
      'courierPhone': courierPhone,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    if (statusId == 'delivered' && orderData['statusId'] != 'delivered') {
      final orderNumber = orderData['number'] ?? orderId.padRight(6, '0').substring(0, 6).toUpperCase();
      await createNotification(
        userId: _stringValue(orderData['userId']),
        text: 'Заказ №$orderNumber доставлен',
        textEn: 'Order #$orderNumber has been delivered',
      );
    }
  }

  Future<void> createNotification({
    required String userId,
    required String text,
    String textEn = '',
  }) async {
    await _notificationsCollection.add({
      'userId': userId,
      'text': text,
      'textEn': textEn,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> clearNotifications(String userId) async {
    final notificationsSnapshot = await _notificationsCollection.where('userId', isEqualTo: userId).get();

    const batchLimit = 400;
    for (var start = 0; start < notificationsSnapshot.docs.length; start += batchLimit) {
      final batch = _database.batch();
      final end = start + batchLimit < notificationsSnapshot.docs.length
          ? start + batchLimit
          : notificationsSnapshot.docs.length;
      for (final notificationDocument in notificationsSnapshot.docs.sublist(start, end)) {
        batch.delete(notificationDocument.reference);
      }
      await batch.commit();
    }
  }

  /// Заказ физически не удаляется: для финансовой отчетности он только
  /// скрывается из списка покупателя.
  Future<void> hideOrderForUser(String orderId) async {
    await _ordersCollection.doc(orderId).set({
      'hiddenByUser': true,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> confirmOrderReceived(String orderId) async {
    await _ordersCollection.doc(orderId).set({
      'userConfirmed': true,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> deleteUser(String userId) async {
    await assertUserCanBeDeleted(userId);
    await _setUserDeleted(userId, true);
  }

  Future<void> restoreUser(String userId) async {
    await _setUserDeleted(userId, false);
  }

  /// Кто пометил профиль удаленным, хранится в `deletedBy`: по нему правила
  /// Firestore отличают самоудаление (его владелец может откатить) от блокировки
  /// администратором (снять ее может только администратор).
  Future<void> _setUserDeleted(String userId, bool isDeleted) async {
    await _usersCollection.doc(userId).set({
      'isDeleted': isDeleted,
      if (isDeleted) 'deletedBy': _currentUserId() ?? userId,
      if (!isDeleted) 'deletedBy': FieldValue.delete(),
      'deletedAt': isDeleted ? FieldValue.serverTimestamp() : FieldValue.delete(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Освобождает логин пользователя перед удалением его учетной записи и
  /// возвращает данные записи, чтобы при неудаче ее можно было вернуть.
  Future<Map<String, dynamic>?> releaseLoginIndex(String userId) async {
    final profile = await getUserProfile(userId);
    final login = _stringValue(profile?['loginNormalized']).isNotEmpty
        ? _stringValue(profile?['loginNormalized'])
        : _stringValue(profile?['login']).toLowerCase();
    if (login.isEmpty) {
      return null;
    }

    final indexReference = _loginIndexCollection.doc(login);
    final indexDocument = await indexReference.get();
    final indexData = indexDocument.data();
    if (indexData == null || indexData['uid'] != userId) {
      return null;
    }

    await indexReference.delete();
    return {'login': login, ...indexData};
  }

  Future<void> restoreLoginIndex(Map<String, dynamic>? released) async {
    if (released == null) return;
    await _loginIndexCollection.doc(released['login'].toString()).set({
      'uid': released['uid'],
      'email': released['email'],
    });
  }

  Future<void> assertUserCanBeDeleted(String userId) async {
    final ordersSnapshot = await _ordersCollection.where('userId', isEqualTo: userId).get();
    for (final orderDocument in ordersSnapshot.docs) {
      final orderData = orderDocument.data();
      final statusId = _stringValue(orderData['statusId']);
      final statusName = _stringValue(orderData['statusName']).toLowerCase();
      final isFinished = statusId == 'delivered' || statusId == 'cancelled' || _isFinishedOrderStatus(statusName);
      if (!isFinished) {
        throw DatabaseOperationException(AppLocale.strings.errUserHasActiveOrders);
      }
    }
  }

  Future<void> saveCategory({
    String? categoryId,
    required String name,
    required String description,
  }) async {
    final normalizedName = name.trim();
    if (normalizedName.isEmpty) {
      throw DatabaseOperationException(AppLocale.strings.errCategoryNameRequired);
    }
    if (normalizedName.length > 100) {
      throw DatabaseOperationException(AppLocale.strings.errCategoryNameTooLong);
    }
    if (description.trim().length > 500) {
      throw DatabaseOperationException(AppLocale.strings.errCategoryDescriptionTooLong);
    }

    await _ensureUniqueValue(
      collection: _categoriesCollection,
      fieldName: 'nameNormalized',
      normalizedValue: normalizedName.toLowerCase(),
      currentDocumentId: categoryId,
      errorMessage: AppLocale.strings.errCategoryExists,
    );

    final categoryReference = categoryId == null || categoryId.isEmpty
        ? _categoriesCollection.doc()
        : _categoriesCollection.doc(categoryId);

    await categoryReference.set({
      'name': normalizedName,
      'nameNormalized': normalizedName.toLowerCase(),
      'description': description.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> deleteCategory(String categoryId) async {
    final categoryDocument = await _categoriesCollection.doc(categoryId).get();
    final categoryData = categoryDocument.data();
    if (categoryData == null) {
      throw DatabaseOperationException(AppLocale.strings.errCategoryNotFound);
    }

    final productsSnapshot = await _productsCollection.get();
    for (final productDocument in productsSnapshot.docs) {
      final productData = productDocument.data();
      final categoryLinkedById = productData['categoryId'] == categoryId;
      final categoryLinkedByName = _stringValue(productData['categoryName']) == _stringValue(categoryData['name']) ||
          _stringValue(productData['category']) == _stringValue(categoryData['name']);

      if (categoryLinkedById || categoryLinkedByName) {
        throw DatabaseOperationException(AppLocale.strings.errCategoryHasProducts);
      }
    }

    await _categoriesCollection.doc(categoryId).delete();
  }

  Future<void> saveManufacturer({
    String? manufacturerId,
    required String name,
    required String country,
    required String contactPhone,
  }) async {
    final normalizedName = name.trim();
    if (normalizedName.isEmpty) {
      throw DatabaseOperationException(AppLocale.strings.errManufacturerNameRequired);
    }
    if (normalizedName.length > 100) {
      throw DatabaseOperationException(AppLocale.strings.errManufacturerNameTooLong);
    }

    await _ensureUniqueValue(
      collection: _manufacturersCollection,
      fieldName: 'nameNormalized',
      normalizedValue: normalizedName.toLowerCase(),
      currentDocumentId: manufacturerId,
      errorMessage: AppLocale.strings.errManufacturerExists,
    );

    final manufacturerReference = manufacturerId == null || manufacturerId.isEmpty
        ? _manufacturersCollection.doc()
        : _manufacturersCollection.doc(manufacturerId);

    await manufacturerReference.set({
      'name': normalizedName,
      'nameNormalized': normalizedName.toLowerCase(),
      'country': country.trim(),
      'contactPhone': contactPhone.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> deleteManufacturer(String manufacturerId) async {
    final manufacturerDocument = await _manufacturersCollection.doc(manufacturerId).get();
    final manufacturerData = manufacturerDocument.data();
    if (manufacturerData == null) {
      throw DatabaseOperationException(AppLocale.strings.errManufacturerNotFound);
    }

    final productsSnapshot = await _productsCollection.get();
    for (final productDocument in productsSnapshot.docs) {
      final productData = productDocument.data();
      final isLinked = productData['manufacturerId'] == manufacturerId ||
          _stringValue(productData['manufacturerName']) == _stringValue(manufacturerData['name']);
      if (isLinked) {
        throw DatabaseOperationException(AppLocale.strings.errManufacturerHasProducts);
      }
    }

    await _manufacturersCollection.doc(manufacturerId).delete();
  }

  Future<void> saveSupplier({
    String? supplierId,
    required String name,
    required String taxId,
    required String address,
    required String contactPhone,
    required String email,
  }) async {
    final normalizedName = name.trim();
    if (normalizedName.isEmpty) {
      throw DatabaseOperationException(AppLocale.strings.errSupplierNameRequired);
    }

    await _ensureUniqueValue(
      collection: _suppliersCollection,
      fieldName: 'nameNormalized',
      normalizedValue: normalizedName.toLowerCase(),
      currentDocumentId: supplierId,
      errorMessage: AppLocale.strings.errSupplierExists,
    );

    final supplierReference = supplierId == null || supplierId.isEmpty
        ? _suppliersCollection.doc()
        : _suppliersCollection.doc(supplierId);

    await supplierReference.set({
      'name': normalizedName,
      'nameNormalized': normalizedName.toLowerCase(),
      'taxId': taxId.trim(),
      'address': address.trim(),
      'contactPhone': contactPhone.trim(),
      'email': email.trim().toLowerCase(),
      'updatedAt': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> deleteSupplier(String supplierId) async {
    final supplierDocument = await _suppliersCollection.doc(supplierId).get();
    final supplierData = supplierDocument.data();
    if (supplierData == null) {
      throw DatabaseOperationException(AppLocale.strings.errSupplierNotFound);
    }

    final productsSnapshot = await _productsCollection.get();
    for (final productDocument in productsSnapshot.docs) {
      final productData = productDocument.data();
      final isLinked = productData['supplierId'] == supplierId ||
          _stringValue(productData['supplierName']) == _stringValue(supplierData['name']);
      if (isLinked) {
        throw DatabaseOperationException(AppLocale.strings.errSupplierHasSupplies);
      }
    }

    await _suppliersCollection.doc(supplierId).delete();
  }

  Future<void> saveRole({
    String? roleId,
    required String name,
  }) async {
    final normalizedName = name.trim();
    if (normalizedName.isEmpty) {
      throw DatabaseOperationException(AppLocale.strings.errRoleNameRequired);
    }
    if (normalizedName.length > 50) {
      throw DatabaseOperationException(AppLocale.strings.errRoleNameTooLong);
    }

    final normalizedRoleCode = normalizedName.toLowerCase().replaceAll(RegExp(r'[^a-zа-я0-9]+'), '_');

    await _ensureUniqueValue(
      collection: _rolesCollection,
      fieldName: 'nameNormalized',
      normalizedValue: normalizedName.toLowerCase(),
      currentDocumentId: roleId,
      errorMessage: AppLocale.strings.errRoleExists,
    );

    final roleReference = roleId == null || roleId.isEmpty
        ? _rolesCollection.doc(normalizedRoleCode)
        : _rolesCollection.doc(roleId);

    await roleReference.set({
      'name': normalizedName,
      'nameNormalized': normalizedName.toLowerCase(),
      'code': roleReference.id,
      'updatedAt': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> deleteRole(String roleId) async {
    final usersSnapshot = await _usersCollection.get();
    for (final userDocument in usersSnapshot.docs) {
      final userData = userDocument.data();
      if (userData['role'] == roleId) {
        throw DatabaseOperationException(AppLocale.strings.errRoleHasUsers);
      }
    }

    await _rolesCollection.doc(roleId).delete();
  }

  Future<void> saveOrderStatus({
    String? statusId,
    required String name,
  }) async {
    final normalizedName = name.trim();
    if (normalizedName.isEmpty) {
      throw DatabaseOperationException(AppLocale.strings.errStatusNameRequired);
    }
    if (normalizedName.length > 50) {
      throw DatabaseOperationException(AppLocale.strings.errStatusNameTooLong);
    }

    await _ensureUniqueValue(
      collection: _orderStatusesCollection,
      fieldName: 'nameNormalized',
      normalizedValue: normalizedName.toLowerCase(),
      currentDocumentId: statusId,
      errorMessage: AppLocale.strings.errStatusExists,
    );

    final normalizedCode = normalizedName.toLowerCase().replaceAll(RegExp(r'[^a-zа-я0-9]+'), '_');
    final statusReference = statusId == null || statusId.isEmpty
        ? _orderStatusesCollection.doc(normalizedCode)
        : _orderStatusesCollection.doc(statusId);

    await statusReference.set({
      'name': normalizedName,
      'nameNormalized': normalizedName.toLowerCase(),
      'code': statusReference.id,
      'updatedAt': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> deleteOrderStatus(String statusId) async {
    final ordersSnapshot = await _ordersCollection.get();
    for (final orderDocument in ordersSnapshot.docs) {
      final orderData = orderDocument.data();
      if (orderData['statusId'] == statusId) {
        throw DatabaseOperationException(AppLocale.strings.errStatusInUse);
      }
    }

    await _orderStatusesCollection.doc(statusId).delete();
  }

  Future<void> savePromoCode({
    String? promoCodeId,
    required String code,
    required int discountPercent,
    required DateTime expiresAt,
  }) async {
    final normalizedCode = code.trim().toUpperCase();
    if (normalizedCode.isEmpty) {
      throw DatabaseOperationException(AppLocale.strings.errPromoCodeRequired);
    }
    if (!RegExp(r'^[A-Z0-9]+$').hasMatch(normalizedCode)) {
      throw DatabaseOperationException(AppLocale.strings.errPromoCodeChars);
    }
    if (discountPercent < 1 || discountPercent > 99) {
      throw DatabaseOperationException(AppLocale.strings.errPromoDiscountRange);
    }
    if (expiresAt.isBefore(DateTime.now().subtract(const Duration(days: 1)))) {
      throw DatabaseOperationException(AppLocale.strings.errPromoExpiryPast);
    }

    await _ensureUniqueValue(
      collection: _promoCodesCollection,
      fieldName: 'codeNormalized',
      normalizedValue: normalizedCode,
      currentDocumentId: promoCodeId,
      errorMessage: AppLocale.strings.errPromoCodeExists,
    );

    final promoCodeReference = promoCodeId == null || promoCodeId.isEmpty
        ? _promoCodesCollection.doc()
        : _promoCodesCollection.doc(promoCodeId);

    await promoCodeReference.set({
      'code': normalizedCode,
      'codeNormalized': normalizedCode,
      'discountPercent': discountPercent,
      'expiresAt': Timestamp.fromDate(expiresAt),
      'isActive': true,
      'updatedAt': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> deletePromoCode(String promoCodeId) async {
    final ordersSnapshot = await _ordersCollection.get();
    for (final orderDocument in ordersSnapshot.docs) {
      final orderData = orderDocument.data();
      final isPromoLinked = orderData['promoCodeId'] == promoCodeId;
      final statusName = _stringValue(orderData['statusName']).toLowerCase();
      if (isPromoLinked && !_isFinishedOrderStatus(statusName)) {
        throw DatabaseOperationException(AppLocale.strings.errPromoInActiveOrders);
      }
    }

    await _promoCodesCollection.doc(promoCodeId).delete();
  }

  Future<void> saveProduct({
    String? productId,
    required String name,
    required String description,
    required double price,
    required int stockQuantity,
    required String categoryId,
    required String manufacturerId,
    String? supplierId,
    required String quantityLabel,
    String imageUrl = '',
    DateTime? expiryDate,
  }) async {
    if (name.trim().isEmpty) {
      throw DatabaseOperationException(AppLocale.strings.errProductNameRequired);
    }
    if (name.trim().length > 255) {
      throw DatabaseOperationException(AppLocale.strings.errProductNameTooLong);
    }
    if (description.trim().length > 2000) {
      throw DatabaseOperationException(AppLocale.strings.errProductDescriptionTooLong);
    }
    if (price <= 0) {
      throw DatabaseOperationException(AppLocale.strings.errProductPricePositive);
    }
    if (stockQuantity < 0 || stockQuantity > 9999) {
      throw DatabaseOperationException(AppLocale.strings.errProductStockRange);
    }

    final categoryDocument = await _categoriesCollection.doc(categoryId).get();
    final manufacturerDocument = await _manufacturersCollection.doc(manufacturerId).get();
    final supplierDocument = supplierId == null || supplierId.isEmpty
        ? null
        : await _suppliersCollection.doc(supplierId).get();

    if (!categoryDocument.exists || !manufacturerDocument.exists) {
      throw DatabaseOperationException(AppLocale.strings.errProductNeedsCategory);
    }

    final productReference = productId == null || productId.isEmpty
        ? _productsCollection.doc()
        : _productsCollection.doc(productId);

    await productReference.set({
      'name': name.trim(),
      'description': description.trim(),
      'price': price,
      'stockQuantity': stockQuantity,
      'qty': quantityLabel.trim(),
      'categoryId': categoryId,
      'categoryName': categoryDocument.data()?['name'],
      'manufacturerId': manufacturerId,
      'manufacturerName': manufacturerDocument.data()?['name'],
      'supplierId': supplierId,
      'supplierName': supplierDocument?.data()?['name'],
      'imageUrl': imageUrl.trim(),
      'expiryDate': expiryDate == null ? null : Timestamp.fromDate(expiryDate),
      'minStock': 5,
      'isDeleted': false,
      'updatedAt': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> deleteProduct(String productId) async {
    final ordersSnapshot = await _ordersCollection.get();
    for (final orderDocument in ordersSnapshot.docs) {
      final orderData = orderDocument.data();
      final orderItems = List<Map<String, dynamic>>.from(orderData['items'] ?? []);
      final statusName = _stringValue(orderData['statusName']).toLowerCase();
      final containsProduct = orderItems.any((orderItem) => orderItem['id'] == productId);
      if (containsProduct && !_isFinishedOrderStatus(statusName)) {
        await _productsCollection.doc(productId).set({
          'isDeleted': true,
          'updatedAt': FieldValue.serverTimestamp(),
          'deletedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        return;
      }
    }

    await _productsCollection.doc(productId).delete();
  }

  Future<Map<String, dynamic>> getDashboardData() async {
    final productsSnapshot = await _productsCollection.get();
    final usersSnapshot = await _usersCollection.get();
    final ordersSnapshot = await _ordersCollection.get();

    final products = productsSnapshot.docs.map(_documentToMap).where((product) => product['isDeleted'] != true).toList();
    final users = usersSnapshot.docs.map(_documentToMap).where((user) => user['isDeleted'] != true).toList();
    final orders = ordersSnapshot.docs.map(_documentToMap).toList();
    final now = DateTime.now();

    final expiringProducts = products.where((product) {
      final expiryDate = product['expiryDate'];
      if (expiryDate == null) {
        return false;
      }
      final parsedDate = _dateTimeValue(expiryDate);
      return parsedDate.isAfter(now.subtract(const Duration(days: 1))) &&
          parsedDate.isBefore(now.add(const Duration(days: 7)));
    }).toList();

    expiringProducts.sort((leftProduct, rightProduct) {
      return _dateTimeValue(leftProduct['expiryDate']).compareTo(_dateTimeValue(rightProduct['expiryDate']));
    });

    final buyersCount = users.where((user) => user['role'] == AppRoles.buyer).length;

    final monthlySales = <String, double>{};
    final productPopularity = <String, int>{};

    for (final order in orders) {
      final orderDate = _dateTimeValue(order['createdAt']);
      final monthKey = '${orderDate.year}-${orderDate.month.toString().padLeft(2, '0')}';
      monthlySales[monthKey] = (monthlySales[monthKey] ?? 0) + _doubleValue(order['totalAmount']);

      final orderItems = List<Map<String, dynamic>>.from(order['items'] ?? []);
      for (final orderItem in orderItems) {
        final productName = _stringValue(orderItem['name']);
        productPopularity[productName] = (productPopularity[productName] ?? 0) + _intValue(orderItem['quantity']);
      }
    }

    final topProducts = productPopularity.entries.toList()
      ..sort((leftEntry, rightEntry) => rightEntry.value.compareTo(leftEntry.value));

    return {
      'expiringProducts': expiringProducts.take(5).toList(),
      'buyersCount': buyersCount,
      'monthlySales': monthlySales,
      'topProducts': topProducts.take(5).map((entry) {
        return {
          'name': entry.key,
          'count': entry.value,
        };
      }).toList(),
    };
  }

  Future<List<Map<String, dynamic>>> getCategoriesList() async {
    final categoriesSnapshot = await _categoriesCollection.get();
    final categories = categoriesSnapshot.docs.map(_documentToMap).toList();
    categories.sort((leftCategory, rightCategory) {
      return _stringValue(leftCategory['name']).compareTo(_stringValue(rightCategory['name']));
    });
    return categories;
  }

  Future<List<Map<String, dynamic>>> getManufacturersList() async {
    final manufacturersSnapshot = await _manufacturersCollection.get();
    final manufacturers = manufacturersSnapshot.docs.map(_documentToMap).toList();
    manufacturers.sort((leftManufacturer, rightManufacturer) {
      return _stringValue(leftManufacturer['name']).compareTo(_stringValue(rightManufacturer['name']));
    });
    return manufacturers;
  }

  Future<List<Map<String, dynamic>>> getSuppliersList() async {
    final suppliersSnapshot = await _suppliersCollection.get();
    final suppliers = suppliersSnapshot.docs.map(_documentToMap).toList();
    suppliers.sort((leftSupplier, rightSupplier) {
      return _stringValue(leftSupplier['name']).compareTo(_stringValue(rightSupplier['name']));
    });
    return suppliers;
  }

  Future<List<Map<String, dynamic>>> getRolesList() async {
    final rolesSnapshot = await _rolesCollection.get();
    final roles = rolesSnapshot.docs.map(_documentToMap).toList();
    roles.sort((leftRole, rightRole) {
      return _stringValue(leftRole['name']).compareTo(_stringValue(rightRole['name']));
    });
    return roles;
  }

  Future<List<Map<String, dynamic>>> getOrderStatusesList() async {
    final statusesSnapshot = await _orderStatusesCollection.get();
    final statuses = statusesSnapshot.docs.map(_documentToMap).toList();
    statuses.sort((leftStatus, rightStatus) {
      return _stringValue(leftStatus['name']).compareTo(_stringValue(rightStatus['name']));
    });
    return statuses;
  }

  Future<List<Map<String, dynamic>>> getUsersList() async {
    final usersSnapshot = await _usersCollection.get();
    final users = usersSnapshot.docs.map(_documentToMap).where((user) => user['isDeleted'] != true).toList();
    users.sort((leftUser, rightUser) {
      return _stringValue(leftUser['displayName']).compareTo(_stringValue(rightUser['displayName']));
    });
    return users;
  }

  Future<void> _seedCategories() async {
    final batch = _database.batch();
    for (final category in catalogCategories) {
      final translation = categoryTranslations[category.id];
      batch.set(_categoriesCollection.doc(category.id), {
        'name': category.name,
        'nameEn': translation?.name ?? '',
        'nameNormalized': category.name.toLowerCase(),
        'description': category.description,
        'descriptionEn': translation?.description ?? '',
        'imageUrl': category.imageUrl,
        'updatedAt': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
    await batch.commit();
  }

  Future<void> _seedManufacturers() async {
    final batch = _database.batch();
    for (final manufacturer in catalogManufacturers) {
      batch.set(_manufacturersCollection.doc(manufacturer.id), {
        'name': manufacturer.name,
        'nameNormalized': manufacturer.name.toLowerCase(),
        'country': manufacturer.country,
        'contactPhone': manufacturer.contactPhone,
        'updatedAt': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
    await batch.commit();
  }

  Map<String, dynamic> _catalogProductData(CatalogProduct product) {
    final category = catalogCategories.firstWhere((category) => category.id == product.categoryId);
    final manufacturer = catalogManufacturers.firstWhere(
      (manufacturer) => manufacturer.id == product.manufacturerId,
    );
    final translation = productTranslations[product.id];
    final categoryTranslation = categoryTranslations[category.id];
    final supplierIndex = product.id.codeUnits.fold<int>(0, (total, unit) => total + unit) % 2;

    return {
      'name': product.name,
      'nameEn': translation?.name ?? '',
      'nameNormalized': product.name.toLowerCase(),
      'description': product.description,
      'descriptionEn': translation?.description ?? '',
      'composition': product.composition,
      'compositionEn': translation?.composition ?? '',
      'country': product.country,
      'price': product.price,
      'unit': product.unit,
      'qty': product.qty,
      'stockQuantity': product.stock,
      'minStock': 5,
      'imageUrl': product.imageUrl,
      'categoryId': category.id,
      'categoryName': category.name,
      'categoryNameEn': categoryTranslation?.name ?? '',
      'manufacturerId': manufacturer.id,
      'manufacturerName': manufacturer.name,
      'supplierId': supplierIndex == 0 ? 'supply-one' : 'supply-two',
      'supplierName': supplierIndex == 0 ? 'ООО Поставка Маркет' : 'ИП Экспресс Поставка',
      'calories': product.calories,
      'proteins': product.proteins,
      'fats': product.fats,
      'carbs': product.carbs,
      'shelfLifeDays': product.shelfLifeDays,
      'expiryDate': Timestamp.fromDate(DateTime.now().add(Duration(days: product.shelfLifeDays))),
      'popularity': product.popularity,
      'isDeleted': false,
    };
  }

  /// Полностью пересоздает каталог: удаляет все товары и загружает стартовый набор.
  Future<void> reseedCatalog() async {
    await _seedCategories();
    await _seedManufacturers();

    final existingSnapshot = await _productsCollection.get();
    var batch = _database.batch();
    var operations = 0;

    for (final document in existingSnapshot.docs) {
      batch.delete(document.reference);
      if (++operations >= 400) {
        await batch.commit();
        batch = _database.batch();
        operations = 0;
      }
    }

    for (final product in catalogProducts) {
      batch.set(_productsCollection.doc(product.id), {
        ..._catalogProductData(product),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      if (++operations >= 400) {
        await batch.commit();
        batch = _database.batch();
        operations = 0;
      }
    }

    await batch.commit();
  }

  Stream<List<Map<String, dynamic>>> _watchOrderedCollection(
      CollectionReference<Map<String, dynamic>> collection,
      String orderField,
      ) {
    return collection.snapshots().map((snapshot) {
      final records = snapshot.docs.map(_documentToMap).toList();
      records.sort((leftRecord, rightRecord) {
        return _stringValue(leftRecord[orderField]).compareTo(_stringValue(rightRecord[orderField]));
      });
      return records;
    });
  }

  Map<String, dynamic> _documentToMap(DocumentSnapshot<Map<String, dynamic>> documentSnapshot) {
    final documentData = documentSnapshot.data() ?? <String, dynamic>{};
    return {
      'id': documentSnapshot.id,
      ...documentData,
    };
  }

  Future<void> assertLoginAvailable(String login) async {
    final indexDocument = await _loginIndexCollection.doc(login.trim().toLowerCase()).get();
    if (indexDocument.exists) {
      throw DatabaseOperationException(AppLocale.strings.errLoginTaken);
    }
  }

  Future<void> _ensureUniqueValue({
    required CollectionReference<Map<String, dynamic>> collection,
    required String fieldName,
    required String normalizedValue,
    String? currentDocumentId,
    required String errorMessage,
  }) async {
    final snapshot = await collection.where(fieldName, isEqualTo: normalizedValue).get();
    for (final document in snapshot.docs) {
      if (document.id == currentDocumentId || document.data()['isDeleted'] == true) {
        continue;
      }
      throw DatabaseOperationException(errorMessage);
    }
  }

  String _buildDefaultLogin(String email, String displayName) {
    final sourceValue = email.isNotEmpty ? email.split('@').first : displayName;
    final normalizedSource = sourceValue
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]'), '');
    if (normalizedSource.length >= 3) {
      return normalizedSource;
    }
    return 'user${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
  }

  bool _isFinishedOrderStatus(String statusName) {
    return statusName.contains('доставлен') ||
        statusName.contains('отмен') ||
        statusName.contains('cancel');
  }

  String _stringValue(dynamic value) => toStringValue(value);

  int _intValue(dynamic value) => toIntValue(value);

  double _doubleValue(dynamic value) => toDoubleValue(value);

  DateTime _dateTimeValue(dynamic value) => toDateTimeValue(value);
}
