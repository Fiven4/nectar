import 'dart:async';

import 'package:flutter/foundation.dart';

import '../services/database_service.dart';

/// Keeps the ids of the signed-in user's favorite products, synced with the
/// `favorites` array of the user document. Product data itself is always read
/// from the live catalog so price and stock never go stale.
class FavoriteProvider with ChangeNotifier {
  FavoriteProvider({DatabaseService? database}) : _databaseOverride = database;

  final DatabaseService? _databaseOverride;
  late final DatabaseService _database = _databaseOverride ?? DatabaseService();

  Set<String> _ids = <String>{};
  StreamSubscription<Set<String>>? _subscription;
  String? _userId;

  Set<String> get ids => Set.unmodifiable(_ids);

  int get count => _ids.length;

  bool isFavorite(String id) => _ids.contains(id);

  void bindUser(String? userId) {
    if (userId == _userId) return;

    _userId = userId;
    _subscription?.cancel();
    _subscription = null;

    if (_ids.isNotEmpty) {
      _ids = <String>{};
      notifyListeners();
    }

    if (userId == null) return;

    _subscription = _database.watchFavoriteIds(userId).listen(
      (ids) {
        _ids = ids;
        notifyListeners();
      },
      onError: (Object error) => debugPrint('Favorites sync failed: $error'),
    );
  }

  Future<void> toggle(String productId) async {
    final userId = _userId;
    if (userId == null) return;

    final shouldAdd = !_ids.contains(productId);
    _ids = shouldAdd ? {..._ids, productId} : ({..._ids}..remove(productId));
    notifyListeners();

    try {
      await _database.setFavorite(
        userId: userId,
        productId: productId,
        isFavorite: shouldAdd,
      );
    } catch (error) {
      debugPrint('Could not update favorites: $error');
      _ids = shouldAdd ? ({..._ids}..remove(productId)) : {..._ids, productId};
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
