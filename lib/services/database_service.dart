import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Hàm follow
  Future<void> followUser(String currentUserId, String targetUserId) async {
    try {
      // Thêm vào subcollection 'following' của người hiện tại
      await _firestore
          .collection('Follows')
          .doc(currentUserId)
          .collection('following')
          .doc(targetUserId)
          .set({});

      // Thêm vào subcollection 'followers' của người được follow
      await _firestore
          .collection('Follows')
          .doc(targetUserId)
          .collection('followers')
          .doc(currentUserId)
          .set({});
    } catch (e) {
      print("Error in followUser: $e");
      rethrow;
    }
  }

  // Hàm unfollow
  Future<void> unfollowUser(String currentUserId, String targetUserId) async {
    try {
      // Xóa khỏi subcollection 'following' của người hiện tại
      await _firestore
          .collection('Follows')
          .doc(currentUserId)
          .collection('following')
          .doc(targetUserId)
          .delete();

      // Xóa khỏi subcollection 'followers' của người được follow
      await _firestore
          .collection('Follows')
          .doc(targetUserId)
          .collection('followers')
          .doc(currentUserId)
          .delete();
    } catch (e) {
      print("Error in unfollowUser: $e");
      rethrow;
    }
  }

  // Kiểm tra trạng thái follow
  Future<bool> isFollowing(String currentUserId, String targetUserId) async {
    try {
      final doc = await _firestore
          .collection('Follows')
          .doc(currentUserId)
          .collection('following')
          .doc(targetUserId)
          .get();

      return doc.exists;
    } catch (e) {
      print("Error in isFollowing: $e");
      return false;
    }
  }
}
