import 'package:flutter/material.dart';

class ProductCart {
  String productName;
  int? productId;
  int price;
  int categoryId;
  int count;
  ProductCart(
      {required this.productName,
      required this.productId,
      required this.price,
      required this.categoryId,
      required this.count});
}

class GlobalState extends ChangeNotifier {
  static final GlobalState _instance = GlobalState._internal();
  GlobalState._internal();
  factory GlobalState() {
    return _instance;
  }
  void updateUI() {
    notifyListeners();
  }

  List<ProductCart?> cart = [];
}
