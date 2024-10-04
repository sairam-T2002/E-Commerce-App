import 'package:flutter/material.dart';
import 'Shared/_apimanager.dart';
import 'app.dart';
import 'Shared/_localstorage.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String _username = '';
  String _password = '';
  String _email = '';
  String _retypePassword = '';
  bool _isLoading = false;
  bool _isLoginMode = true;

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      _formKey.currentState!.save();

      Map<String, String> userCred = {
        'Username': _username,
        'Password': _password,
      };

      Map<String, dynamic>? response =
          await fetchApiPOST('api/Auth/Login', userCred, isLogin: true);
      setState(() {
        _isLoading = false;
      });
      if (response != null && response.containsKey('accessToken')) {
        await UserDataHelper.storeUserData(LocalStorageKeys.userCred, response);
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const AppScreen()),
        );
      } else {
        // Handle login error
      }
    }
  }

  Future<void> _register() async {
    _formKey.currentState!.save();
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      Map<String, dynamic> userRegData = {
        'Id': 0,
        'Usr_Nam': _username,
        'E_Mail': _email,
        'Pwd': _password,
      };

      Map<String, dynamic>? response =
          await fetchApiPOST('api/Auth/Signup', userRegData, isLogin: true);
      setState(() {
        _isLoading = false;
      });
      if (response != null) {
        bool status = response["status"];
        String message = response["message"];
        if (status) {
          if (mounted) showSnackBar(context, "User Registered Successfully");
          setState(() {
            _isLoginMode = true;
          });
        } else {
          if (mounted) showSnackBar(context, message);
          setState(() {
            _isLoginMode = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(title: Text(_isLoginMode ? 'Login' : 'Register')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                if (_isLoginMode) ...[
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Username'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your username';
                      }
                      return null;
                    },
                    onSaved: (value) => _username = value!,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Password'),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      return null;
                    },
                    onSaved: (value) => _password = value!,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _login,
                    child: const Text('Login'),
                  ),
                ] else ...[
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Username'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a username';
                      }
                      return null;
                    },
                    onSaved: (value) => _username = value!,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Email'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an email';
                      }
                      // Add email format validation if needed
                      return null;
                    },
                    onSaved: (value) => _email = value!,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Password'),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a password';
                      }
                      return null;
                    },
                    onSaved: (value) => _password = value!,
                  ),
                  TextFormField(
                    decoration:
                        const InputDecoration(labelText: 'Re-type Password'),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please re-type your password';
                      }
                      if (value != _password) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                    onSaved: (value) => _retypePassword = value!,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _register,
                    child: const Text('Register'),
                  ),
                ],
                const SizedBox(height: 10),
                InkWell(
                  onTap: () {
                    setState(() {
                      _isLoginMode = !_isLoginMode;
                      _formKey.currentState?.reset();
                    });
                  },
                  child: Text(
                    _isLoginMode
                        ? 'Create an account'
                        : 'Already have an account? Login',
                    style: TextStyle(color: Theme.of(context).primaryColor),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }
}

void showSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 3),
    ),
  );
}
