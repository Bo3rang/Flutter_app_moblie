class UserModel {
  final String userId;
  final String name;
  final String email;
  final String bio;
  final String avatarUrl;
  final String coverUrl;

  UserModel({
    required this.userId,
    required this.name,
    required this.email,
    required this.avatarUrl,
    required this.coverUrl,
    required this.bio,
  });

  // Chuyển từ Map<String, dynamic> (dữ liệu Firestore) sang UserModel
  factory UserModel.fromMap(String id, Map<String, dynamic> map) {
    return UserModel(
      userId: id,
      name: map['name'] ?? 'Unknown',
      email: map['email'] ?? 'Unknow',
      bio: map['bio'] ?? '',
      avatarUrl: map['avatarUrl'] ?? '',
      coverUrl: map['coverUrl'] ?? '',
    );
  }

  // Chuyển từ UserModel sang Map<String, dynamic> (để lưu vào Firestore)
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'email': email,
      'bio': bio,
      'avatarImage': avatarUrl,
      'coverImage': coverUrl,
    };
  }
}
