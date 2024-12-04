import 'package:flutter/material.dart';
import 'package:mobile/navigation/dashboard_nav.dart';
import 'package:mobile/navigation/map_nav.dart';
import 'package:mobile/navigation/social_nav.dart';
import 'package:mobile/views/login/login_view.dart';
import 'package:mobile/views/profile/edit_profile_page.dart';
import 'package:mobile/views/profile/update_password_page.dart';
import 'package:mobile/views/social/create_post.dart';
import 'package:mobile/widgets/location_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int selectedIndex = 0;
  String _currentLocation = 'Alafaya, FL';
  Key _dashboardKey = UniqueKey();
  Key _mapKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    _loadCurrentLocation();
  }

  Future<void> _loadCurrentLocation() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentLocation = prefs.getString('locationName') ?? 'Alafaya, FL';
    });
  }

  void _refreshAfterLocationUpdate() async {
    await _loadCurrentLocation();
    setState(() {
      _dashboardKey = UniqueKey();
      _mapKey = UniqueKey();
    });
  }

  void _handleProfileMenuSelection(int index) {
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey,
        title: Row(
          children: [
            const Text(
              "Overcastly",
              style: TextStyle(color: Colors.white),
            ),
            const SizedBox(width: 16),
            TextButton.icon(
              icon: const Icon(Icons.location_on, color: Colors.white),
              label: Text(
                _currentLocation,
                style: const TextStyle(color: Colors.white),
                overflow: TextOverflow.ellipsis,
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => LocationDialog(
                    onLocationUpdated: _refreshAfterLocationUpdate,
                  ),
                );
              },
            ),
          ],
        ),
        actions: [
          PopupMenuButton<int>(
            onSelected: _handleProfileMenuSelection,
            offset: const Offset(0, 45),
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem<int>(
                  value: 0,
                  child: Text('Edit Profile'),
                ),
                const PopupMenuItem<int>(
                  value: 1,
                  child: Text('Update Password'),
                ),
                const PopupMenuItem<int>(
                  value: 2,
                  child: Text('Logout'),
                ),
              ];
            },
            icon: const Icon(
              Icons.account_circle,
              size: 35,
              color: Colors.white,
            ),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (int index) {
          setState(() {
            selectedIndex = index;
          });
        },
        destinations: const <NavigationDestination>[
          NavigationDestination(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            label: 'Map',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_alt),
            label: 'Social',
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: IndexedStack(
          index: selectedIndex,
          children: [
            Dashboard(key: _dashboardKey),
            Map(key: _mapKey),
            Navigator(
              onGenerateRoute: (RouteSettings settings) {
                Widget page;
                switch (settings.name) {
                  case '/create_post':
                    page = const CreatePost();
                    break;
                  default:
                    page = const Social();
                }
                return MaterialPageRoute(builder: (context) => page);
              },
            ),
          ],
        ),
      ),
    );
  }
}