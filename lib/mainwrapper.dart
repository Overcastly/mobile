import 'package:flutter/material.dart';
import 'package:mobile/navigation/dashboard_nav.dart';
import 'package:mobile/navigation/map_nav.dart';
import 'package:mobile/views/login/login_view.dart';
import 'navigation/social_nav.dart';


class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(

        ///TOP APP BAR
        appBar: AppBar(
          backgroundColor: Colors.blueGrey,
          title: const Text(
            "Overcastly",
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            PopupMenuButton<String>(
              onSelected: (String item) {
                if (item == 'logout') {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginView()), // Replace with your login page
                  );
                }
              },
              offset: const Offset(0, 45),
              itemBuilder: (BuildContext context) {
                return [
                  const PopupMenuItem<String>(
                    value: 'logout',
                    child: Text('Logout'),
                  ),
                ];
              },
              icon: const Icon(
                  Icons.account_circle,
                  size: 35,
                  color: Colors.white,
              ), // Your user icon
            ),
          ],
        ),

      ///BOTTOM NAVIGATION BAR
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
              label: 'Dashboard'
          ),
          NavigationDestination(
              icon: Icon(Icons.map_outlined),
              label: 'Map'
          ),
          NavigationDestination(
              icon: Icon(Icons.people_alt),
              label: 'Social'
          ),
        ],
      ),

      ///BODY
      body: SafeArea(
        top: false,
          child: IndexedStack(
            index: selectedIndex,
            children: [
              const Dashboard(),
              const Map(),
              const Social(),
            ],
          )
      )

    );
  }
}
