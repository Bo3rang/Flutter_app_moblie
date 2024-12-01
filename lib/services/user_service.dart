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
    }
    return null;
  }

  // Lấy danh sách các bài post từ Firestore
  Future<List<PostModel>> getPosts() async {
    try {
      // Truy vấn tất cả các bài viết từ collection 'Posts', sắp xếp theo thời gian giảm dần
      final postsSnapshot = await _firestore
          .collection('Posts')
          .orderBy('timestamp', descending: true)
          .get();

      // Chuyển đổi dữ liệu Firestore thành danh sách PostModel và trả về
      return postsSnapshot.docs
          .map((doc) => PostModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print("Error getting posts: $e");
      throw Exception("Error getting posts: $e"); // Trả về lỗi chi tiết hơn
    }
  }
}
