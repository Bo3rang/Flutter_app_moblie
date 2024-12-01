import 'package:flutter/material.dart';

import 'post_screen.dart';
import '../../models/post_model.dart';
import '../../services/post_service.dart';

class HomeScreen extends StatefulWidget {
  final String currentUserId;

  const HomeScreen({
    super.key,
    required this.currentUserId,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<PostModel> allPosts = [];
  bool isLoading = true;

  final PostService _postService = PostService();

  @override
  void initState() {
    super.initState();
    _loadAllPosts();
  }

  Future<void> _loadAllPosts() async {
    try {
      final posts = await _postService.getPosts();
      setState(() {
        allPosts = posts;
        isLoading = false;
      });
    } catch (e) {
      print("Error loading posts: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("An error occurred while loading posts: $e")),
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : allPosts.isEmpty
              ? const Center(child: Text("No posts available"))
              : ListView.builder(
                  itemCount: allPosts.length,
                  itemBuilder: (context, index) {
                    final post = allPosts[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: ListTile(
                        title: Text(post.title),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(post.content),
                            const SizedBox(height: 8),
                            if (post.imageUrl.isNotEmpty)
                              Image.network(
                                post.imageUrl,
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
                            Row(
                              children: [
                                const Icon(Icons.thumb_up_alt, size: 16),
                                const SizedBox(width: 4),
                                Text("${post.likeCount} Likes"),
                                const SizedBox(width: 16),
                                const Icon(Icons.comment, size: 16),
                                const SizedBox(width: 4),
                                Text("${post.commentCount} Comments"),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Posted by: ${post.author}",
                              style: const TextStyle(color: Colors.grey),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Posted on: ${post.createdAt.toLocal().toString().split(' ')[0]}",
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  PostScreen(currentUserId: widget.currentUserId),
            ),
          ).then((_) => _loadAllPosts());
        },
        tooltip: 'Post bài',
        child: const Icon(Icons.add),
      ),
    );
  }
}
