import 'package:flutter/material.dart';
import 'package:test_1/auth/auth_service.dart';

import '../components/my_button.dart';
import '../components/my_textfield.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({
    super.key, 
    required this.onTap});

  final void Function()? onTap;

  void login(BuildContext context) async{
    final authService = AuthService();

    try {
      await authService.signInWithEmailPassword(
        _emailController.text, 
        _passwordController.text);
    }
    catch(e){
      showDialog(
        context: context, 
        builder: ((context) => AlertDialog(
          title: Text(e.toString()),
        ))
      );
    }
  }

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: Stack(
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
                    "Login", 
                    style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5,),
                  const Text(
                    "Please sign in to continue", 
                    style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w300,
                    ),
                  ),
                  const SizedBox(height: 50),
                  MyTextfield(
                    hintText: "EMAIL",
                    icon: const Icon(Icons.mail_outline),
                    controller: _emailController,
                    obsecureText: false,
                  ),
                  const SizedBox(height: 10,),
                  MyTextfield(
                    hintText: "PASSWORD",
                    icon: const Icon(Icons.lock_outlined),
                    controller: _passwordController,
                    obsecureText: true,
                  ),
                  const SizedBox(height: 25),
                  MyButton(
                    text: "LOGIN", 
                    onPressed: () => login(context),
                  ),
                  const SizedBox(height: 25),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Not a member? '),
                      GestureDetector(
                        onTap: onTap,
                        child: Text(
                          'Register now',
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
      ))
    );
  }
}