import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/post_model.dart';
import '../../models/user_model.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Lấy thông tin người dùng từ Firestore theo userId
  Future<UserModel?> getUserData(String userId) async {
    try {
      final userDocument =
          await _firestore.collection('Users').doc(userId).get();

      // Kiểm tra nếu tài liệu người dùng tồn tại và chuyển đổi dữ liệu từ Firestore thành UserModel
      if (userDocument.exists) {
        return UserModel.fromMap(userDocument.id, userDocument.data()!);
      } else {
        print("User not found");
      }
    } catch (e) {
      print("Error loading user data: $e");
      throw Exception("Error loading user data: $e");
    }
    return null;
  }

  // Lấy danh sách các bài post của người dùng từ Firestore theo userId
  Future<List<PostModel>> getPosts(String userId) async {
    try {
      final postsSnapshot = await _firestore
          .collection('Posts')
          .where('userId', isEqualTo: userId) // Lọc bài viết theo userId
          .orderBy('timestamp', descending: true)
          .get();

      // Chuyển đổi dữ liệu Firestore thành danh sách Post và trả về
      return postsSnapshot.docs.map((doc) {
        return PostModel.fromJson(doc.data() as Map<String,
            dynamic>); // Sử dụng PostModel.fromJson() thay cho PostModel.fromFirestore()
      }).toList();
    } catch (e) {
      print("Error getting posts: $e");
      throw Exception("Error getting posts: $e");
    }
  }
}
