class PostModel {
  final String id;
  final String title;
  final String content;
  final String author;
  final DateTime createdAt;
  final List<String> tags;
  final int likeCount;
  final int commentCount;
  final String imageUrl;

  PostModel({
    required this.id,
    required this.title,
    required this.content,
    required this.author,
    required this.createdAt,
    this.tags = const [],
    this.likeCount = 0,
    this.commentCount = 0,
    required this.imageUrl,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      author: json['author'],
      createdAt: DateTime.parse(json['createdAt']),
      tags: List<String>.from(json['tags']),
      likeCount: json['likeCount'],
      commentCount: json['commentCount'],
      imageUrl: json['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'author': author,
      'createdAt': createdAt.toIso8601String(),
      'tags': tags,
      'likeCount': likeCount,
      'commentCount': commentCount,
      'imageUrl': imageUrl,
    };
  }
}
