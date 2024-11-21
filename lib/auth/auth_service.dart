import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Đăng nhập
  Future<UserCredential> signInWithEmailPassword(
      String email, String password) async {
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
  Future<UserCredential> signUpWithEmailPassword(String email, String password,
      String name, String avatarUrl, String coverUrl, String bio) async {
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
          'coverUrl': coverUrl,
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

  // Hàm follow và unfollow
  Future<void> followUser(String currentUserId, String targetUserId) async {
    try {
      DocumentReference currentUserDoc =
          _firestore.collection("Users").doc(currentUserId);
      DocumentReference targetUserDoc =
          _firestore.collection("Users").doc(targetUserId);

      // Bắt đầu batch để thực hiện các thao tác Firestore cùng lúc
      WriteBatch batch = _firestore.batch();

      // Thêm targetUserId vào danh sách following của currentUserId
      batch.update(currentUserDoc, {
        "following": FieldValue.arrayUnion([targetUserId])
      });

      // Thêm currentUserId vào danh sách followers của targetUserId
      batch.update(targetUserDoc, {
        "followers": FieldValue.arrayUnion([currentUserId])
      });

      // Commit batch
      await batch.commit();
    } catch (e) {
      throw Exception("Error while following user: $e");
    }
  }

  Future<void> unfollowUser(String currentUserId, String targetUserId) async {
    try {
      DocumentReference currentUserDoc =
          _firestore.collection("Users").doc(currentUserId);
      DocumentReference targetUserDoc =
          _firestore.collection("Users").doc(targetUserId);

      // Bắt đầu batch để thực hiện các thao tác Firestore cùng lúc
      WriteBatch batch = _firestore.batch();

      // Xóa targetUserId khỏi danh sách following của currentUserId
      batch.update(currentUserDoc, {
        "following": FieldValue.arrayRemove([targetUserId])
      });

      // Xóa currentUserId khỏi danh sách followers của targetUserId
      batch.update(targetUserDoc, {
        "followers": FieldValue.arrayRemove([currentUserId])
      });

      // Commit batch
      await batch.commit();
    } catch (e) {
      throw Exception("Error while unfollowing user: $e");
    }
  }

  // Hiển thị số lượng Following và Follower
  Stream<DocumentSnapshot> getUserStream(String userId) {
    return _firestore.collection("Users").doc(userId).snapshots();
  }
}
