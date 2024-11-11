import 'package:flutter/material.dart';

import '/auth/auth_service.dart';
import '/components/my_button.dart';
import '/components/my_textfield.dart';

class RegisterScreen extends StatelessWidget {
  RegisterScreen({
    super.key, 
    required this.onTap,
  });

  final void Function()? onTap;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmpasswordController = TextEditingController();
  final TextEditingController _avatarUrlController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  void Register(BuildContext context) async {
    final auth = AuthService();
    if (_passwordController.text == _confirmpasswordController.text) {
      try {
        await auth.signUpWithEmailPassword(
          _emailController.text,
          _passwordController.text,
          _nameController.text,
          _avatarUrlController.text,  // Chuyển avatar URL vào
          _bioController.text,         // Chuyển tiểu sử vào
        );
      } catch (e) {
        showDialog(
          context: context,
          builder: ((context) => AlertDialog(
                title: Text(e.toString()),
              )),
        );
      }
    } else {
      showDialog(
          context: context,
          builder: ((context) => const AlertDialog(
                title: Text("Password don't match!"),
              )));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
                top: 10,
                left: 230,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                )),
            Positioned(
                top: 10,
                left: 270,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                )),
            Positioned(
                bottom: 100,
                right: 280,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                )),
            Positioned(
                bottom: 10,
                right: 320,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                )),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Create Account",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 50),
                    MyTextfield(
                      hintText: "NAME",
                      icon: const Icon(Icons.person_outline),
                      controller: _nameController,
                      obsecureText: false,
                    ),
                    MyTextfield(
                      hintText: "EMAIL",
                      icon: const Icon(Icons.mail_outline),
                      controller: _emailController,
                      obsecureText: false,
                    ),
                    const SizedBox(height: 10),
                    MyTextfield(
                      hintText: "PASSWORD",
                      icon: const Icon(Icons.lock_outlined),
                      controller: _passwordController,
                      obsecureText: true,
                    ),
                    const SizedBox(height: 10),
                    MyTextfield(
                      hintText: "CONFIRM PASSWORD",
                      icon: const Icon(Icons.lock_outlined),
                      controller: _confirmpasswordController,
                      obsecureText: true,
                    ),
                    const SizedBox(height: 10),
                    MyButton(
                      text: "REGISTER",
                      onPressed: () => Register(context),
                    ),
                    const SizedBox(height: 25),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Already have an account? '),
                        GestureDetector(
                          onTap: onTap,
                          child: Text(
                            'Login now',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade300,
                            ),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
