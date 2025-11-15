import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../models/product_model.dart';

class WishlistProvider extends ChangeNotifier {
  final Box _wishlistBox = Hive.box('wishlist');

  List<ProductModel> _items = [];

  WishlistProvider() {
    _loadWishlist();
  }

  List<ProductModel> get wishlist => _items;

  void _loadWishlist() {
    final data = _wishlistBox.get('items', defaultValue: []);
    _items = List<ProductModel>.from(
      (data as List).map(
        (item) => ProductModel.fromMap(Map<String, dynamic>.from(item)),
      ),
    );
  }

  void add(ProductModel product) {
    if (!_items.any((item) => item.id == product.id)) {
      _items.add(product);
      _save();
      notifyListeners();
    }
  }

  void remove(ProductModel product) {
    _items.removeWhere((item) => item.id == product.id);
    _save();
    notifyListeners();
  }

  bool isInWishlist(ProductModel product) {
    return _items.any((item) => item.id == product.id);
  }

  void toggle(ProductModel product) {
    if (isInWishlist(product)) {
      remove(product);
    } else {
      add(product);
    }
  }

  void _save() {
    _wishlistBox.put('items', _items.map((e) => e.toMap()).toList());
  }
}
