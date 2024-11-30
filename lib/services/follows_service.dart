import 'package:cloud_firestore/cloud_firestore.dart';

class FollowsService {
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

  Future<bool> checkFollowStatus(
      String currentUserId, String profileUserId) async {
    try {
      final followDoc =
          await _firestore.collection('Follows').doc(currentUserId).get();
      if (followDoc.exists) {
        List<dynamic> following = followDoc['following'] ?? [];
        return following.contains(profileUserId);
      }
    } catch (e) {
      print("Error checking follow status: $e");
    }
    return false;
  }

  Future<void> toggleFollow(
      String currentUserId, String profileUserId, bool isFollowing) async {
    try {
      final followsRef = _firestore.collection('Follows');

      if (isFollowing) {
        await followsRef.doc(currentUserId).update({
          'following': FieldValue.arrayRemove([profileUserId])
        });
        await followsRef.doc(profileUserId).update({
          'followers': FieldValue.arrayRemove([currentUserId])
        });
      } else {
        await followsRef.doc(currentUserId).set({
          'following': FieldValue.arrayUnion([profileUserId])
        }, SetOptions(merge: true));
        await followsRef.doc(profileUserId).set({
          'followers': FieldValue.arrayUnion([currentUserId])
        }, SetOptions(merge: true));
      }
    } catch (e) {
      print("Error toggling follow: $e");
    }
  }

  Future<Map<String, int>> loadFollowCounts(String profileUserId) async {
    try {
      final followDoc =
          await _firestore.collection('Follows').doc(profileUserId).get();
      if (followDoc.exists) {
        int followers = (followDoc['followers'] as List<dynamic>).length;
        int following = (followDoc['following'] as List<dynamic>).length;
        return {'followers': followers, 'following': following};
      }
    } catch (e) {
      print("Error loading follow counts: $e");
    }
    return {'followers': 0, 'following': 0};
  }
}
