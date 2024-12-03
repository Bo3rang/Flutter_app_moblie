import 'package:flutter/material.dart';

import 'edit_profile.dart';
import '../../models/user_model.dart';
import '../../models/post_model.dart';
import '../../services/auth_service.dart';
import '../../services/user_service.dart';
import '../../services/follows_service.dart';

class ProfileScreen extends StatefulWidget {
  final String currentUserId;
  final String profileUserId;

  const ProfileScreen({
    super.key,
    required this.currentUserId,
    required this.profileUserId,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserModel? userModel;
  bool isFollowing = false;
  bool isLoading = true;
  int followerCount = 0;
  int followingCount = 0;
  List<PostModel> userPosts = [];

  final UserService _userService = UserService();
  final FollowsService _followService = FollowsService();

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      // Lấy dữ liệu người dùng
      final user = await _userService.getUserData(widget.profileUserId);
      final followStatus = await _followService.checkFollowStatus(
        widget.currentUserId,
        widget.profileUserId,
      );
      final followCounts =
          await _followService.loadFollowCounts(widget.profileUserId);

      setState(() {
        userModel = user;
        isFollowing = followStatus;
        followerCount = followCounts['followers'] ?? 0;
        followingCount = followCounts['following'] ?? 0;
        isLoading = false;
      });
    } catch (e) {
      print("Error loading initial data: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("An error occurred: $e")),
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _toggleFollow() async {
    try {
      await _followService.toggleFollow(
        widget.currentUserId,
        widget.profileUserId,
        isFollowing,
      );
      setState(() {
        isFollowing = !isFollowing;
        followerCount += isFollowing ? 1 : -1;
      });
    } catch (e) {
      print("Error toggling follow: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("An error occurred while toggling follow: $e")),
      );
    }
  }

  void _logout() async {
    try {
      final AuthService auth = AuthService();
      await auth.signOut();
    } catch (e) {
      print("Error logging out: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("An error occurred while logging out: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isOwnProfile = widget.currentUserId == widget.profileUserId;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : userModel == null
              ? const Center(child: Text("User not found"))
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Ảnh cover và avatar
                      Stack(
                        children: [
                          Image.network(
                            userModel?.coverUrl.isNotEmpty == true
                                ? userModel!.coverUrl
                                : 'https://via.placeholder.com/600x200',
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 200,
                                color: Colors.grey,
                                child: const Center(
                                  child: Icon(Icons.image_not_supported,
                                      size: 50, color: Colors.white),
                                ),
                              );
                            },
                          ),
                          Positioned(
                            bottom: 16,
                            left: 16,
                            child: CircleAvatar(
                              radius: 50,
                              backgroundImage:
                                  userModel?.avatarUrl.isNotEmpty == true
                                      ? NetworkImage(userModel!.avatarUrl)
                                      : const NetworkImage(
                                          'https://via.placeholder.com/100'),
                              onBackgroundImageError: (_, __) {},
                              child: userModel?.avatarUrl.isEmpty == true
                                  ? const Icon(Icons.person,
                                      size: 50, color: Colors.white)
                                  : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        userModel!.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        userModel!.email,
                        style:
                            const TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        userModel!.bio,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Column(
                            children: [
                              Text(
                                '$followerCount',
                                style: const TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              const Text("Followers"),
                            ],
                          ),
                          const SizedBox(width: 32),
                          Column(
                            children: [
                              Text(
                                '$followingCount',
                                style: const TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              const Text("Following"),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      if (isOwnProfile)
                        Column(
                          children: [
                            ElevatedButton(
                              onPressed: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const EditProfileScreen(),
                                  ),
                                );
                                if (result == true) {
                                  setState(() {
                                    isLoading = true;
                                  });
                                  _loadInitialData();
                                }
                              },
                              child: const Text("Edit Profile"),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: _logout,
                              icon: const Icon(Icons.logout),
                              label: const Text("Logout"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                            ),
                          ],
                        )
                      else
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: _toggleFollow,
                              child: Text(isFollowing ? "Unfollow" : "Follow"),
                            ),
                            const SizedBox(width: 10),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  '/messenger',
                                  arguments: userModel,
                                );
                              },
                              child: const Text("Messenger"),
                            ),
                          ],
                        ),

                      // Hiển thị bài viết của người dùng hiện tại
                      const SizedBox(height: 32),
                      const Text(
                        "User Posts",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      // Hiển thị danh sách bài viết
                      ...userPosts.map((post) {
                        return Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(8),
                            title: Text(post.title),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text(post.content),
                                const SizedBox(height: 8),
                                if (post.imageUrl != null &&
                                    post.imageUrl!.isNotEmpty)
                                  Image.network(
                                    post.imageUrl!,
                                    fit: BoxFit.cover,
                                    height: 150,
                                    width: double.infinity,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        height: 150,
                                        color: Colors.grey,
                                        child: const Center(
                                          child: Icon(Icons.image_not_supported,
                                              size: 50, color: Colors.white),
                                        ),
                                      );
                                    },
                                  ),
                                const SizedBox(height: 8),
                                const Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.thumb_up, size: 16),
                                        SizedBox(width: 4),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Icon(Icons.comment, size: 16),
                                        SizedBox(width: 4),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
    );
  }
}
