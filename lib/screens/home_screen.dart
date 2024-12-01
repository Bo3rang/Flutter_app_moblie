import 'post_screen.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  final String currentUserId;

  const HomeScreen({
    super.key,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: const Center(
        child: Text('Home'),
      ),
      // Thêm nút FloatingActionButton ở góc dưới bên phải
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Chuyển hướng đến màn hình Post bài
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PostScreen(currentUserId: currentUserId),
            ),
          );
        },
        child: const Icon(Icons.add),
        tooltip: 'Post bài',
      ),
    );
  }
}
