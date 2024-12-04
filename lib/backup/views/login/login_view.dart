import 'package:flutter/material.dart';
import 'package:mobile/mainwrapper.dart';
import 'package:mobile/views/login/login_button.dart';
import 'package:mobile/views/login/login_textfield.dart';
import 'package:mobile/views/login/register_view.dart';
import '../../mongodb.dart';

class LoginView extends StatelessWidget {
  LoginView({super.key});

  //controllers for editing text
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  //sign user in method
  void signUserIn(BuildContext context) async {
    String username = usernameController.text.trim();
    String password = passwordController.text.trim();

    final error =  await MongoDatabase.doLogin(username, password);

    if(error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
    } else {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainWrapper())
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Center(
            child: Column(
              children: [
                const SizedBox(height: 50),
                const Icon(
                  Icons.lock_outlined,
                  size: 75,
                ),
                const SizedBox(height: 50),

                Text(
                  'Please Log In To Your Account',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                ),

                const SizedBox(height: 25),

                //username box
                LoginTextField(
                  controller: usernameController,
                  hintText: 'Username',
                  obscureText: false,
                ),

                const SizedBox(height: 10),

                //password box
                LoginTextField(
                  controller: passwordController,
                  hintText: 'Password',
                  obscureText: true,
                ),

                const SizedBox(height: 10),

                //forgot password text
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'Forgot Password?',
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                //sign in button
                LoginButton(
                  onTap: () => signUserIn(context),
                ),

                const SizedBox(height: 20),

                //register button
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                        'Don\'t have an account?',
                        style: TextStyle(color: Colors.grey[700])),
                    const SizedBox(width: 4),
                    GestureDetector(
                      child: const Text(
                        'Register Here',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => RegisterView()),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
      ),
    );
  }
}
