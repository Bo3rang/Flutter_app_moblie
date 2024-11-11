import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileScreen extends StatefulWidget {
  final String currentUserId;
  final String profileUserId;
  const ProfileScreen({
    super.key, 
    required this.currentUserId, 
    required this.profileUserId
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String name = '';
  String email = '';
  String avatarUrl = '';
  String bio = '';
  int posts = 0;
  int followers = 0;
  int following = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Hàm tải thông tin người dùng từ Firestore
  Future<void> _loadUserData() async {
    try {
      var doc = await FirebaseFirestore.instance.collection('Users').doc(widget.profileUserId).get();
      if (doc.exists) {
        setState(() {
          name = doc['name'] ?? 'No name';
          email = doc['email'] ?? 'No email';
          avatarUrl = doc['avatarUrl'] ?? 'https://via.placeholder.com/150';
          bio = doc['bio'] ?? 'No bio';
          posts = doc['posts'] ?? 0;
          followers = doc['followers'] ?? 0;
          following = doc['following'] ?? 0;
          isLoading = false;
        });
      }
    } catch (e) {
      print("Lỗi khi tải dữ liệu người dùng: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  // Hàm đăng xuất
  Future<void> _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      print("Lỗi đăng xuất: $e");
    }
  }

  // Hàm chỉnh sửa profile (dành cho người dùng của mình)
  void _editProfile() {
    Navigator.pushNamed(context, '/editProfile');
  }

  // Hàm follow người khác
  void _followUser() {
    print("Follow user ${widget.profileUserId}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isLoading ? 'Loading...' : name),
        backgroundColor: const Color(0xff006df1),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())  // Hiển thị loading khi đang tải dữ liệu
          : Column(
              children: [
                Expanded(flex: 2, child: _TopPortion(avatarUrl: avatarUrl)),
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Text(
                          name,
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(email, style: Theme.of(context).textTheme.bodyMedium),
                        const SizedBox(height: 10),
                        Text(bio, style: Theme.of(context).textTheme.bodyMedium),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Thay đổi nút nếu là profile của mình hoặc người khác
                            widget.currentUserId == widget.profileUserId
                                ? FloatingActionButton.extended(
                                    onPressed: _editProfile,
                                    heroTag: 'editProfile',
                                    elevation: 0,
                                    label: const Text("Edit Profile"),
                                    icon: const Icon(Icons.edit),
                                  )
                                : FloatingActionButton.extended(
                                    onPressed: _followUser,
                                    heroTag: 'follow',
                                    elevation: 0,
                                    label: const Text("Follow"),
                                    icon: const Icon(Icons.person_add_alt_1),
                                  ),
                            const SizedBox(width: 16.0),
                            FloatingActionButton.extended(
                              onPressed: () {
                                // Logic message user here
                              },
                              heroTag: 'message',
                              elevation: 0,
                              backgroundColor: Colors.red,
                              label: const Text("Message"),
                              icon: const Icon(Icons.message_rounded),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _ProfileInfoRow(posts, followers, following),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _ProfileInfoRow extends StatelessWidget {
  final int posts;
  final int followers;
  final int following;

  const _ProfileInfoRow(this.posts, this.followers, this.following);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      constraints: const BoxConstraints(maxWidth: 400),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _ProfileInfoItem("Posts", posts),
          const VerticalDivider(),
          _ProfileInfoItem("Followers", followers),
          const VerticalDivider(),
          _ProfileInfoItem("Following", following),
        ],
      ),
    );
  }
}

class _ProfileInfoItem extends StatelessWidget {
  final String title;
  final int value;

  const _ProfileInfoItem(this.title, this.value);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            value.toString(),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
        Text(
          title,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _TopPortion extends StatelessWidget {
  final String avatarUrl;

  const _TopPortion({required this.avatarUrl});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 50),
          decoration: const BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Color(0xff0043ba), Color(0xff006df1)]),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(50),
                bottomRight: Radius.circular(50),
              )),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: SizedBox(
            width: 150,
            height: 150,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                    image: DecorationImage(
                        fit: BoxFit.cover,
                        image: NetworkImage(avatarUrl)),  // Dùng avatar URL từ Firestore hoặc dự phòng
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    child: Container(
                      margin: const EdgeInsets.all(8.0),
                      decoration: const BoxDecoration(
                          color: Colors.green, shape: BoxShape.circle),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
