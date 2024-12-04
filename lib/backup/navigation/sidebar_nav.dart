import 'package:flutter/material.dart';
import 'package:mobile/views/profile/edit_profile_page.dart';
import 'package:mobile/views/profile/update_password_page.dart';
import 'package:mobile/views/login/login_view.dart';

class SidebarNav extends StatelessWidget {
  const SidebarNav({super.key});

  void _handleProfileMenuSelection(int index, BuildContext context) {
    switch (index) {
      case 0:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => EditProfilePage()),
        );
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const UpdatePasswordPage()),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginView()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Edit Profile'),
            onTap: () {
              _handleProfileMenuSelection(0, context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text('Update Password'),
            onTap: () {
              _handleProfileMenuSelection(1, context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () {
              _handleProfileMenuSelection(2, context);
            },
          ),
        ],
      ),
    );
  }
}