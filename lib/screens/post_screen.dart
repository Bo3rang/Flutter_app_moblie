import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/post_service.dart';

class PostScreen extends StatefulWidget {
  final String currentUserId;

  const PostScreen({
    super.key,
    required this.currentUserId,
  });

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  String? _imageUrl;
  final ImagePicker _picker = ImagePicker();
  final PostService _postService = PostService();

  // Chọn ảnh từ thư viện
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      // Tải ảnh lên Firebase Storage
      final imageUrl = await _postService.uploadImage(pickedFile);
      if (imageUrl != null) {
        setState(() {
          _imageUrl = imageUrl;
        });
      }
    }
  }

  // Đăng bài lên Firestore
  Future<void> _postArticle() async {
    final title = _titleController.text;
    final content = _contentController.text;

    if (title.isNotEmpty && content.isNotEmpty) {
      try {
        // Lưu bài viết vào Firestore kèm theo userId
        await _postService.createPost(
          title,
          content,
          _imageUrl,
          widget.currentUserId,
        );

        // Hiển thị thông báo thành công
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post successfully created!')),
        );

        Navigator.pop(context);
      } catch (e) {
        print("Error posting article: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error posting article: $e")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter both title and content')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post New Article'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _contentController,
                decoration: const InputDecoration(labelText: 'Content'),
                maxLines: 5,
              ),
              const SizedBox(height: 16),
              // Hiển thị hình ảnh đã chọn
              if (_imageUrl != null)
                Center(
                  child: Image.network(
                    _imageUrl!,
                    height: 200,
                    width: 200,
                    fit: BoxFit.cover,
                  ),
                ),
              const SizedBox(height: 8),
              Center(
                child: ElevatedButton(
                  onPressed: _pickImage,
                  child: const Text('Pick an Image'),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  onPressed: _postArticle,
                  child: const Text('Post'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
