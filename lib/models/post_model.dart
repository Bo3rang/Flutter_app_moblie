class PostModel {
  final String id;
  final String userId;
  final String content;
  final List<String> images;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isLiked;
  final int likeCount;
  final int commentCount;

  PostModel({
    required this.id,
    required this.userId,
    required this.content,
    required this.images,
    required this.createdAt,
    required this.updatedAt,
    required this.isLiked,
    required this.likeCount,
    required this.commentCount,
  });

  // Hàm tạo đối tượng PostModel từ dữ liệu JSON
  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'],
      userId: json['userId'],
      content: json['content'],
      images: List<String>.from(json['images'] ?? []),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      isLiked: json['isLiked'],
      likeCount: json['likeCount'],
      commentCount: json['commentCount'],
    );
  }

  // Hàm chuyển đối tượng PostModel thành dữ liệu JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'content': content,
      'images': images,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isLiked': isLiked,
      'likeCount': likeCount,
      'commentCount': commentCount,
    };
  }

  // Hàm trả về chuỗi mô tả đối tượng PostModel
  @override
  String toString() {
    return 'PostModel{id: $id, userId: $userId, content: $content, images: $images, createdAt: $createdAt, updatedAt: $updatedAt, isLiked: $isLiked, likeCount: $likeCount, commentCount: $commentCount}';
  }

  // Hàm thay đổi trạng thái like của bài viết
  PostModel toggleLike() {
    return PostModel(
      id: id,
      userId: userId,
      content: content,
      images: images,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      isLiked: !isLiked,
      likeCount: isLiked ? likeCount - 1 : likeCount + 1,
      commentCount: commentCount,
    );
  }

  // Hàm cập nhật nội dung bài viết
  PostModel updateContent(String newContent) {
    return PostModel(
      id: id,
      userId: userId,
      content: newContent,
      images: images,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      isLiked: isLiked,
      likeCount: likeCount,
      commentCount: commentCount,
    );
  }
}
