import 'package:flutter/material.dart';

class CartItem {
  final String id;
  final String title;
  final String imageUrl;
  final double price;
  final String color;
  final String size;
  int quantity;

  CartItem({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.price,
    required this.color,
    required this.size,
    required this.quantity,
  });
}

class CartProvider with ChangeNotifier {
  final Map<String, CartItem> _items = {};

  Map<String, CartItem> get items => {..._items};

  String _generateKey(String id, String color, String size) => '$id-$color-$size';

  void addItem({
    required String productId,
    required String title,
    required String imageUrl,
    required double price,
    required String color,
    required String size,
    required int quantity,
  }) {
    final key = _generateKey(productId, color, size);

    print('🛒 Adding item to cart key: $key');

    if (_items.containsKey(key)) {
      _items[key]!.quantity += quantity;
    } else {
      _items[key] = CartItem(
        id: productId,
        title: title,
        imageUrl: imageUrl,
        price: price,
        color: color,
        size: size,
        quantity: quantity,
      );
    }

    debugCart();
    notifyListeners();
  }

  void removeItem(String key) {
    _items.remove(key);
    notifyListeners();
  }

  void updateQuantity(String key, int quantity) {
    if (_items.containsKey(key)) {
      if (quantity <= 0) {
        _items.remove(key);
      } else {
        _items[key]!.quantity = quantity;
      }
      notifyListeners();
    }
  }

  double get totalAmount {
    return _items.values.fold(
      0,
      (total, item) => total + item.price * item.quantity,
    );
  }

  get itemCount => null;

  void clear() {
    _items.clear();
    notifyListeners();
  }

  void debugCart() {
    print('🧾 Current Cart State:');
    _items.forEach((key, item) {
      print('🔹 $key => ${item.title}, Qty: ${item.quantity}');
    });
  }
}
