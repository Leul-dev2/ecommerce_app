import 'package:flutter/material.dart';
import '../models/product_model.dart';

class BookmarkProvider with ChangeNotifier {
  final List<ProductModel> _bookmarkedProducts = [];

  List<ProductModel> get bookmarkedProducts => _bookmarkedProducts;

  /// Check if a product is bookmarked
  bool isBookmarked(ProductModel product) {
    return _bookmarkedProducts.any((p) => p.id == product.id);
  }

  /// Add product to bookmarks
  void add(ProductModel product) {
    if (!isBookmarked(product)) {
      _bookmarkedProducts.add(product);
      notifyListeners();
    }
  }

  /// Remove product from bookmarks
  void remove(ProductModel product) {
    _bookmarkedProducts.removeWhere((p) => p.id == product.id);
    notifyListeners();
  }

  /// Toggle bookmark status
  void toggleBookmark(ProductModel product) {
    if (isBookmarked(product)) {
      remove(product);
    } else {
      add(product);
    }
  }

  /// Clear all bookmarks
  void clear() {
    _bookmarkedProducts.clear();
    notifyListeners();
  }

  /// Refresh bookmarks - useful for pull-to-refresh
  Future<void> refreshBookmarks() async {
    // Currently, just triggers a UI refresh
    notifyListeners();

    // Optional: you can reload from local storage or server
    // await loadFromStorage();
  }

  /// Optional: sort bookmarks by price, name, etc.
  void sortByPrice({bool ascending = true}) {
    _bookmarkedProducts.sort((a, b) =>
        ascending ? a.price.compareTo(b.price) : b.price.compareTo(a.price));
    notifyListeners();
  }

  void sortByName() {
    _bookmarkedProducts.sort((a, b) => a.title.compareTo(b.title));
    notifyListeners();
  }
}
