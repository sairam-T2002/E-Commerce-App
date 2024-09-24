import 'package:flutter/material.dart';
import '../Shared/_localstorage.dart';

class ProfileScreen extends StatefulWidget {
  final Function logoutCallback;
  final Function noInternet;

  const ProfileScreen({
    super.key,
    required this.logoutCallback,
    required this.noInternet,
  });

  @override
  ProfileState createState() => ProfileState();
}

class ProfileState extends State<ProfileScreen> {
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
