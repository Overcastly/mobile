import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/mainwrapper.dart';
import 'package:mobile/views/login/login_button.dart';
import 'package:mobile/views/login/login_textfield.dart';

class LoginView extends StatelessWidget {
  LoginView({super.key});

  //controllers for editing text
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  //sign user in method
  void signUserIn(BuildContext context) async {

    const String apiURL = 'http://localhost:3000/api/login';

    try {
      final response = await http.post(
        Uri.parse(apiURL),
        headers: <String, String> {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic> {
          'username': usernameController.text,
          'password': passwordController.text,
        }),
      );

      if(response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData['success']) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Login successful')));
          Navigator.pushReplacement(context, MainWrapper() as Route<Object?>);
        } else {
          // Handle failed login
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Invalid credentials')));
        }
      } else {
        // Handle server errors
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to login')));
      }

    } catch(error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $error')));
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
