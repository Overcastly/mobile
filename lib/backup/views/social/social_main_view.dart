import 'package:flutter/material.dart';
import 'create_post.dart';

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
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const CreatePost()));
              },
            ),
          ],
        ),
      ),
    );
  }
}
