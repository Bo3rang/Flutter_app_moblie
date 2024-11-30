import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';

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

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _checkFollowStatus();
    _loadFollowCounts();
  }

  Future<void> _loadUserData() async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(widget.profileUserId)
          .get();

      if (userDoc.exists) {
        setState(() {
          userModel = UserModel.fromMap(userDoc.id, userDoc.data()!);
        });
      }
    } catch (e) {
      print("Error loading user data: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _checkFollowStatus() async {
    try {
      final followDoc = await FirebaseFirestore.instance
          .collection('Follows')
          .doc(widget.currentUserId)
          .get();

      if (followDoc.exists) {
        List<dynamic> following = followDoc['following'] ?? [];
        setState(() {
          isFollowing = following.contains(widget.profileUserId);
        });
      }
    } catch (e) {
      print("Error checking follow status: $e");
    }
  }

  Future<void> _loadFollowCounts() async {
    try {
      final followDoc = await FirebaseFirestore.instance
          .collection('Follows')
          .doc(widget.profileUserId)
          .get();

      if (followDoc.exists) {
        setState(() {
          followerCount = (followDoc['followers'] as List<dynamic>).length;
          followingCount = (followDoc['following'] as List<dynamic>).length;
        });
      }
    } catch (e) {
      print("Error loading follow counts: $e");
    }
  }

  Future<void> _toggleFollow() async {
    try {
      final followsRef = FirebaseFirestore.instance.collection('Follows');

      if (isFollowing) {
        await followsRef.doc(widget.currentUserId).update({
          'following': FieldValue.arrayRemove([widget.profileUserId])
        });
        await followsRef.doc(widget.profileUserId).update({
          'followers': FieldValue.arrayRemove([widget.currentUserId])
        });

        setState(() {
          isFollowing = false;
          followerCount--;
        });
      } else {
        await followsRef.doc(widget.currentUserId).set({
          'following': FieldValue.arrayUnion([widget.profileUserId])
        }, SetOptions(merge: true));
        await followsRef.doc(widget.profileUserId).set({
          'followers': FieldValue.arrayUnion([widget.currentUserId])
        }, SetOptions(merge: true));

        setState(() {
          isFollowing = true;
          followerCount++;
        });
      }
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
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: _logout,
          ),
        ],
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
                    ],
                  ),
                ),
    );
  }
}
