import 'package:flutter/material.dart';
import 'login_textfield.dart';
import '../../mongodb.dart';
import 'login_view.dart';

class RegisterView extends StatelessWidget {
  RegisterView({super.key});

  //controllers for editing text
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final firstnameController = TextEditingController();
  final lastnameController = TextEditingController();
  final emailController = TextEditingController();

  //sign user in method
  void registerUser(BuildContext context) async {
    String username = usernameController.text.trim();
    String password = passwordController.text.trim();
    String firstname = firstnameController.text.trim();
    String lastname = lastnameController.text.trim();
    String email = emailController.text.trim();

    final error = await MongoDatabase.doRegister(firstname, lastname, email, username, password);

    if(error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
    } else {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginView())
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginView()),);
            },
            icon: const Icon(
              Icons.arrow_back,
              size: 35,
            ),
        ),
        backgroundColor: Colors.transparent,
      ),
        body: SafeArea(
          child: Center(
            child: Column(
              children: [
                const Icon(
                  Icons.lock_outlined,
                  size: 75,
                ),
                const SizedBox(height: 30),

                Text(
                  'Please Register an Account',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                ),

                const SizedBox(height: 25),

                //firstname box
                LoginTextField(
                  controller: firstnameController,
                  hintText: 'First Name',
                  obscureText: false,
                ),

                const SizedBox(height: 10),

                //lastname box
                LoginTextField(
                  controller: lastnameController,
                  hintText: 'Last Name',
                  obscureText: false,
                ),

                const SizedBox(height: 10),

                //email box
                LoginTextField(
                  controller: emailController,
                  hintText: 'Email',
                  obscureText: false,
                ),

                const SizedBox(height: 10),

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

                const SizedBox(height: 25),

                //register button
                GestureDetector(
                  onTap: () => registerUser(context),
                  child: Container(
                    padding: const EdgeInsets.all(25),
                    margin: const EdgeInsets.symmetric(horizontal: 25),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Text(
                        'Register',
                        style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

