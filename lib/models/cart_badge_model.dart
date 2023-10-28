import 'package:flutter/material.dart';

class CartBadge extends ChangeNotifier {
  int _cartCount = 0;

  int get cartCount => _cartCount;

  void updateCartCount(int newValue) {
    _cartCount = newValue;
    notifyListeners(); // Notifie les écouteurs (les widgets qui écoutent les changements)
  }
}
