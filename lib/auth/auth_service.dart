import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Đăng nhập
  Future<UserCredential> signInWithEmailPassword(String email, String password) async {
    try {
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception("Error during sign in: ${e.code}");
    }
  }

  // Đăng ký tài khoản mới
  Future<UserCredential> signUpWithEmailPassword(
    String email,
    String password,
    String name,
    String avatarUrl,
    String bio) async {
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
          'avatarUrl': avatarUrl,
          'bio': bio,
          'createdAt': Timestamp.now(),
        });
      }
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception("Error during sign up: ${e.code}");
    }
  }

  // Đăng xuất
  Future<void> signOut() async {
    return await auth.signOut();
  }

  // Thêm người vào danh sách followers
  Future<void> followUser(String currentUserId, String profileUserId) async {
    try {
      // Thêm người theo dõi
      await _firestore.collection('Followers').doc(profileUserId).collection('followers').doc(currentUserId).set({
        'userId': currentUserId,
        'createdAt': Timestamp.now(),
      });

      // Thêm người đang theo dõi vào danh sách following của người dùng
      await _firestore.collection('Following').doc(currentUserId).collection('following').doc(profileUserId).set({
        'userId': profileUserId,
        'createdAt': Timestamp.now(),
      });
    } catch (e) {
      print("Lỗi khi follow: $e");
    }
  }

  // Xóa người khỏi danh sách followers
  Future<void> unfollowUser(String currentUserId, String profileUserId) async {
    try {
      // Xóa người khỏi danh sách followers
      await _firestore.collection('Followers').doc(profileUserId).collection('followers').doc(currentUserId).delete();

      // Xóa người khỏi danh sách following
      await _firestore.collection('Following').doc(currentUserId).collection('following').doc(profileUserId).delete();
    } catch (e) {
      print("Lỗi khi unfollow: $e");
    }
  }

  // Lấy số lượng followers
  Future<int> followersNum(String userId) async {
    QuerySnapshot followersSnapshot = await _firestore.collection('Followers').doc(userId).collection('followers').get();
    return followersSnapshot.docs.length;
  }

  // Lấy số lượng following
  Future<int> followingNum(String userId) async {
    QuerySnapshot followingSnapshot = await _firestore.collection('Following').doc(userId).collection('following').get();
    return followingSnapshot.docs.length;
  }
}

