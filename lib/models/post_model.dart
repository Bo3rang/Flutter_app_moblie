import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  final String id;
  final String title;
  final String userId;
  final String content;
  final String? imageUrl;
  final Timestamp timestamp;

  PostModel({
    this.imageUrl,
    required this.id,
    required this.title,
    required this.userId,
    required this.content,
    required this.timestamp,
  });

  // Hàm chuyển từ Firestore sang PostModel
  factory PostModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PostModel(
      id: doc.id,
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      imageUrl: data['imageUrl'],
      timestamp: data['timestamp'] ?? Timestamp.now(),
      userId: data['userId'] ?? '',
    );
  }

  // Hàm chuyển từ PostModel sang Map để lưu vào Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'userId': userId,
      'content': content,
      'imageUrl': imageUrl,
      'timestamp': timestamp,
    };
  }
}
