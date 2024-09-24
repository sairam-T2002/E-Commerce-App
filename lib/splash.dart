import 'package:flutter/material.dart';
import 'app.dart';
import 'login.dart';
import 'Shared/_localstorage.dart';
import 'nointernet.dart';
import 'Shared/_networkutils.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkConnectivity();
  }

  Future<void> _checkConnectivity() async {
    bool isConnected = await NetworkUtils.hasInternetConnection();

    if (!isConnected) {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const NoInternetScreen()),
      );
    } else {
      _checkAuthentication();
    }
  }

  Future<void> _checkAuthentication() async {
    Map<String, dynamic>? temp =
        await UserDataHelper.getUserData(LocalStorageKeys.userCred);

    if (temp != null && temp['refreshToken'] != null) {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const AppScreen()),
      );
    } else {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
