import 'package:flutter/material.dart';
import 'package:mobile/views/login/login_button.dart';
import 'package:mobile/views/login/login_textfield.dart';

class LoginView extends StatelessWidget {
  LoginView({super.key});

  //controllers for editing text
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  //sign user in method
  void signUserIn() {

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
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
                  onTap: signUserIn,
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
                    const Text(
                        'Register Here',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
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
