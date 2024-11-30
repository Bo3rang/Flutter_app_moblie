import 'package:flutter/material.dart';

import '../../models/user_model.dart';
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

  final UserService _userService = UserService();
  final FollowsService _followService = FollowsService();

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
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
    }
  }

  void _logout() {
    final AuthService auth = AuthService();
    auth.signOut();
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
                      // Ảnh bìa
                      Stack(
                        children: [
                          Image.network(
                            userModel!.coverUrl,
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                          Positioned(
                            bottom: 16,
                            left: 16,
                            child: CircleAvatar(
                              radius: 50,
                              backgroundImage:
                                  NetworkImage(userModel!.avatarUrl),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Tên và email
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

                      // Bio
                      Text(
                        userModel!.bio,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 24),

                      // Số lượng follower và following
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

                      // Nút Follow/Unfollow hoặc Edit Profile
                      if (isOwnProfile)
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/edit_profile');
                          },
                          child: const Text("Edit Profile"),
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
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _logout,
                        icon: const Icon(Icons.exit_to_app),
                        label: const Text("Logout"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
