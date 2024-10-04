import 'package:flutter/material.dart';
import 'login.dart';
import 'Shared/_localstorage.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  ProfileState createState() => ProfileState();
}

class ProfileState extends State<Profile> {
  String userName = "";

  @override
  void initState() {
    updateState();
    super.initState();
  }

  Future<void> updateState() async {
    dynamic creds =
        (await UserDataHelper.getUserData(LocalStorageKeys.userCred));
    setState(() {
      userName = creds["username"];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Implement edit profile functionality
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: AssetImage('assets/profile_picture.jpg'),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  userName,
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Account Settings',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _buildSettingsItem(Icons.person, 'Personal Information'),
              _buildSettingsItem(Icons.location_on, 'Addresses'),
              _buildSettingsItem(Icons.credit_card, 'Payment Methods'),
              _buildSettingsItem(Icons.notifications, 'Notifications'),
              const SizedBox(height: 24),
              const Text(
                'Orders',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _buildSettingsItem(Icons.receipt_long, 'Order History'),
              _buildSettingsItem(Icons.favorite, 'Favorite Orders'),
              const SizedBox(height: 24),
              const Text(
                'Preferences',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _buildSettingsItem(Icons.language, 'Language'),
              _buildSettingsItem(Icons.dark_mode, 'Dark Mode'),
              const SizedBox(height: 24),
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    await UserDataHelper.deleteUserData(
                        LocalStorageKeys.userCred);
                    if (mounted) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LoginScreen()),
                        (Route<dynamic> route) => false,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 12),
                  ),
                  child: const Text('Log Out'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsItem(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        // Implement navigation to respective settings pages
      },
    );
  }
}
