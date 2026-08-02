import 'package:flutter/material.dart';
import '../models/product_model.dart';

class WishlistProvider with ChangeNotifier {
  final List<Product> _items = [];

  List<Product> get items => _items;

  bool isFavorite(String productId) {
    return _items.any((p) => p.id == productId);
  }

  void toggleFavorite(Product product) {
    int index = _items.indexWhere((p) => p.id == product.id);
    if (index != -1) {
      _items.removeAt(index);
    } else {
      _items.add(product);
    }
    notifyListeners();
  }
}
