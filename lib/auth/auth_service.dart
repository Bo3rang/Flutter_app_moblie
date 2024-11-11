import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {

  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //Sign in 
  Future<UserCredential> signInWithEmailPassword(String email, password) async {
    try {
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  //Sign up
  Future<UserCredential> signUpWithEmailPassword(
      String email,
      password,
      String name,
      String avatarUrl,
      String bio
  ) async {
    try {
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Lấy user từ userCredential
      User? user = userCredential.user;

      if (user != null) {
        // Lưu thông tin người dùng vào Firestore
        await _firestore.collection("Users").doc(user.uid).set({
          'name': name,
          'email': email,
          'avatarUrl': avatarUrl,  // Thêm link hình ảnh đại diện
          'bio': bio,              // Thêm nội dung tiểu sử
          'createdAt': Timestamp.now(),
        });
      }
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  //Sign out
  Future<void> signOut() async {
    return await auth.signOut();
  }
}