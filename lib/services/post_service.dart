import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/post_model.dart';

class PostService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Hàm tải hình ảnh lên Firebase Storage và trả về URL
  Future<String?> uploadImage(PickedFile file) async {
    try {
      File imageFile = File(file.path);
      String fileName =
          'post_images/${DateTime.now().millisecondsSinceEpoch}.jpg';

      // Tải ảnh lên Firebase Storage
      UploadTask uploadTask = _storage.ref(fileName).putFile(imageFile);
      TaskSnapshot taskSnapshot = await uploadTask;

      // Lấy URL tải xuống của hình ảnh
      String imageUrl = await taskSnapshot.ref.getDownloadURL();
      return imageUrl;
    } catch (e) {
      print("Error uploading image: $e");
      return null;
    }
  }

  // Thêm bài viết mới vào Firestore
  Future<void> addPost(PostModel post) async {
    try {
      await _firestore.collection('posts').doc(post.id).set(post.toJson());
    } catch (e) {
      print("Error adding post: $e");
    }
  }

  // Cập nhật bài viết trên Firestore
  Future<void> updatePost(PostModel post) async {
    try {
      await _firestore.collection('posts').doc(post.id).update(post.toJson());
    } catch (e) {
      print("Error updating post: $e");
    }
  }

  // Lấy bài viết theo ID
  Future<PostModel?> getPostById(String postId) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('posts').doc(postId).get();
      if (doc.exists) {
        return PostModel.fromJson(doc.data() as Map<String, dynamic>);
      }
    } catch (e) {
      print("Error getting post: $e");
    }
    return null;
  }

  // Lấy danh sách bài viết
  Future<List<PostModel>> getPosts() async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('posts').get();
      return querySnapshot.docs
          .map((doc) => PostModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print("Error getting posts: $e");
      return [];
    }
  }

  // Đồng bộ trạng thái like của bài viết với Firestore
  Future<void> toggleLike(PostModel post) async {
    try {
      PostModel updatedPost = post.toggleLike();
      await _firestore
          .collection('posts')
          .doc(updatedPost.id)
          .update(updatedPost.toJson());
    } catch (e) {
      print("Error toggling like: $e");
    }
  }

  // Cập nhật nội dung bài viết và đồng bộ với Firestore
  Future<void> updateContent(PostModel post, String newContent) async {
    try {
      PostModel updatedPost = post.updateContent(newContent);
      await _firestore
          .collection('posts')
          .doc(updatedPost.id)
          .update(updatedPost.toJson());
    } catch (e) {
      print("Error updating content: $e");
    }
  }

  deletePost(String postId) {}
}
