import 'package:flutter/material.dart';
import '../Shared/_localstorage.dart';
import '../login.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  ProfileState createState() => ProfileState();
}

class ProfileState extends State<ProfileScreen> {
  int i = 0;
  bool _isLoading = false;
  void _logout() async {
    setState(() {
      _isLoading = true;
    });
    await UserDataHelper.deleteUserData(LocalStorageKeys.userCred);
    setState(() {
      _isLoading = false;
    });
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
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
