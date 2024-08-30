import 'package:my_app/Dto/_apiobjects.dart';

class GlobalState {
  static final GlobalState _instance = GlobalState._internal();
  GlobalState._internal();
  factory GlobalState() {
    return _instance;
  }
  List<ProductDto> cart = [];
}
