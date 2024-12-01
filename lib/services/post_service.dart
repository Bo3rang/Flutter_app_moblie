import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../models/post_model.dart';

class PostService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Chọn ảnh từ thư viện và tải lên Firebase Storage
  Future<String?> uploadImage(XFile imageFile) async {
    try {
      final image = File(imageFile.path);
      final storageRef = _storage
          .ref()
          .child('posts/${DateTime.now().millisecondsSinceEpoch}.jpg');

      // Đảm bảo tải ảnh lên Firestore Storage
      final uploadTask = storageRef.putFile(image);
      final snapshot = await uploadTask.whenComplete(() => {});

      // Lấy URL ảnh sau khi tải lên thành công
      final imageUrl = await snapshot.ref.getDownloadURL();
      return imageUrl;
    } catch (e) {
      print("Error uploading image: $e");
      return null; // Có thể ném lỗi chi tiết hoặc log để xử lý
    }
  }

  // Lưu bài viết vào Firestore
  Future<void> createPost(
    String title,
    String content,
    String? imageUrl,
    String userId, // Thêm tham số userId
  ) async {
    try {
      final newPost = PostModel(
        id: '',
        title: title,
        content: content,
        imageUrl: imageUrl,
        timestamp: Timestamp.now(),
        userId: userId,
      );

      // Lưu bài viết vào Firestore
      await _firestore.collection('Posts').add(newPost.toMap());
      print("Post added successfully!");
    } catch (e) {
      print("Error posting article: $e");
      throw e;
    }
  }

  // Lấy tất cả bài viết từ Firestore
  Future<List<PostModel>> getPosts() async {
    try {
      final querySnapshot = await _firestore
          .collection('Posts')
          .orderBy('timestamp', descending: true)
          .get();
      return querySnapshot.docs
          .map((doc) =>
              PostModel.fromFirestore(doc)) // Chuyển docs thành PostModel
          .toList();
    } catch (e) {
      print("Error getting posts: $e");
      rethrow; // Ném lại lỗi để có thể xử lý tại nơi gọi
    }
  }
}
