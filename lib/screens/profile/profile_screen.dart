import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:test_1/screens/profile/edit_profile.dart';

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
  bool isCurrentUser = false;
  Map<String, dynamic>? userData;
  bool isLoading = true;
  bool isFollowing = false;
  int followerCount = 0;
  int followingCount = 0;

  @override
  void initState() {
    super.initState();
    isCurrentUser = widget.currentUserId == widget.profileUserId;
    _getUserData();
    _checkIfFollowing();
  }

  Future<void> _getUserData() async {
    try {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc(widget.profileUserId)
          .get();

      if (userSnapshot.exists) {
        setState(() {
          userData = userSnapshot.data() as Map<String, dynamic>?;
          isLoading = false;
        });
        _getFollowersAndFollowingCount();
      } else {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not found in Firestore')),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading user data: $e')),
      );
    }
  }

  Future<void> _getFollowersAndFollowingCount() async {
    final followerSnapshot = await FirebaseFirestore.instance
        .collection('Users')
        .doc(widget.profileUserId)
        .collection('followers')
        .get();

    final followingSnapshot = await FirebaseFirestore.instance
        .collection('Users')
        .doc(widget.profileUserId)
        .collection('following')
        .get();

    setState(() {
      followerCount = followerSnapshot.docs.length;
      followingCount = followingSnapshot.docs.length;
    });
  }

  Future<void> _checkIfFollowing() async {
    final doc = await FirebaseFirestore.instance
        .collection('Users')
        .doc(widget.profileUserId)
        .collection('followers')
        .doc(widget.currentUserId)
        .get();

    setState(() {
      isFollowing = doc.exists;
    });
  }

  Future<void> _toggleFollow() async {
    if (isFollowing) {
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(widget.profileUserId)
          .collection('followers')
          .doc(widget.currentUserId)
          .delete();

      await FirebaseFirestore.instance
          .collection('Users')
          .doc(widget.currentUserId)
          .collection('following')
          .doc(widget.profileUserId)
          .delete();
      setState(() {
        isFollowing = false;
        followerCount--;
      });
    } else {
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(widget.profileUserId)
          .collection('followers')
          .doc(widget.currentUserId)
          .set({});

      await FirebaseFirestore.instance
          .collection('Users')
          .doc(widget.currentUserId)
          .collection('following')
          .doc(widget.profileUserId)
          .set({});
      setState(() {
        isFollowing = true;
        followerCount++;
      });
    }
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacementNamed('/login');
  }

  // Cập nhật dữ liệu khi quay lại từ EditProfileScreen
  void _refreshProfile() {
    _getUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: isLoading
        ? const Center(child: CircularProgressIndicator())
        : userData == null
          ? const Center(child: Text('User not found'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        height: 210,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          image: userData!['coverUrl'] != null
                            ? DecorationImage(
                                image: NetworkImage(userData!['coverUrl']),
                                fit: BoxFit.cover,
                              )
                            : null,
                        ),
                      ),
                      Positioned(
                        top: 100,
                        child: CircleAvatar(
                          radius: 50,
                          backgroundImage: NetworkImage(
                            userData!['avatarUrl'] ?? 'https://via.placeholder.com/150',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 60),
                  Text(
                    userData!['name'] ?? 'No Name',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    userData!['email'] ?? 'No Email',
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    userData!['bio'] ?? 'No Bio',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          Text(
                            followerCount.toString(),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text('Followers'),
                        ],
                      ),
                      const SizedBox(width: 40),
                      Column(
                        children: [
                          Text(
                            followingCount.toString(),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text('Following'),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (isCurrentUser)
                    ElevatedButton.icon(
                      onPressed: () async {
                        // Chuyển đến trang EditProfile và cập nhật khi quay lại
                        final updated = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const EditProfileScreen(),
                          ),
                        );
                        if (updated != null && updated) {
                          _refreshProfile(); // Cập nhật lại dữ liệu khi quay lại từ trang EditProfile
                        }
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit Profile'),
                    )
                  else
                    ElevatedButton.icon(
                      onPressed: _toggleFollow,
                      icon: Icon(isFollowing ? Icons.remove : Icons.add),
                      label: Text(isFollowing ? 'Unfollow' : 'Follow'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isFollowing ? Colors.red : Colors.blue,
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}
