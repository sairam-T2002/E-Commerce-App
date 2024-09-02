import 'package:my_app/Dto/_apiobjects.dart';

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

class GlobalState {
  static final GlobalState _instance = GlobalState._internal();
  GlobalState._internal();
  factory GlobalState() {
    return _instance;
  }
  List<ProductCart?> cart = [];
}
