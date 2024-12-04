import 'package:flutter/material.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 210, 52, 52),
        title: const Text(
          "Dashboard View",
          style: TextStyle(color: Colors.white),
        ),
      ),
        body: SizedBox.expand(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              IconButton(
                  icon: const Icon(Icons.add),
                  //child: const Text('Test'),
                  onPressed: () {},
              ),
            ],
          ),
        ),
    );
  }
}
