import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '/auth/login_or_register.dart';
import '/screens/feed_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(), 
        builder: (context, snapshot){
          if(snapshot.hasData){
            return FeedScreen(
              currentUserId: snapshot.data!.uid, 
              profileUserId: snapshot.data!.uid,
            );
          }
          else{
            return const LoginOrRegister();
          }
        },
      ),
    );
  }
}
