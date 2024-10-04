import 'package:flutter/material.dart';
import '../Shared/_localstorage.dart';

class OrdersScreen extends StatefulWidget {
  final Function logoutCallback;
  final Function noInternet;

  const OrdersScreen({
    super.key,
    required this.logoutCallback,
    required this.noInternet,
  });

  @override
  OrdersState createState() => OrdersState();
}

class OrdersState extends State<OrdersScreen> {
  bool _isLoading = false;

  void _logout() async {
    setState(() {
      _isLoading = true;
    });
    await UserDataHelper.deleteUserData(LocalStorageKeys.userCred);
    setState(() {
      _isLoading = false;
    });
    widget.logoutCallback();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    } else {
      return Center(
        child: ElevatedButton(onPressed: _logout, child: const Text('Logout')),
      );
    }
  }
}
