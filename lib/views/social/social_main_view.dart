import 'package:flutter/material.dart';

class SocialView extends StatelessWidget {
  const SocialView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text(
          "Social View",
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
