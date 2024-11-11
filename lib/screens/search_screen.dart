import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'profile_screen.dart';  // Import ProfileScreen để điều hướng

class SearchScreen extends StatefulWidget {
  final String currentUserId; // Thêm tham số currentUserId để truyền vào ProfileScreen
  const SearchScreen({super.key, required this.currentUserId});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, dynamic>> _userNames = [];  // Lưu trữ cả name, avatarUrl và userId
  List<Map<String, dynamic>> _filteredUserNames = [];

  // Hàm tìm kiếm người dùng trong Firestore
  Future<void> _searchUser(String query) async {
    if (query.isEmpty) {
      // Nếu không có gì để tìm, hiển thị tất cả người dùng
      setState(() {
        _filteredUserNames = _userNames;
      });
      return;
    }

    var querySnapshot = await FirebaseFirestore.instance
        .collection('Users')  // Tên collection của bạn trong Firestore
        .where('name', isGreaterThanOrEqualTo: query) // Tìm kiếm từ khóa bắt đầu với query
        .where('name', isLessThanOrEqualTo: '$query\uf8ff') // Tìm kiếm với phạm vi khớp tên
        .get();

    List<Map<String, dynamic>> users = [];
    for (var doc in querySnapshot.docs) {
      users.add({
        'name': doc['name'],
        'userId': doc.id, // Lưu trữ userId
        'avatarUrl': doc['avatarUrl'] ?? 'https://via.placeholder.com/150', // Dự phòng avatar nếu không có
      });
    }

    setState(() {
      _filteredUserNames = users;
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchAllUsers();
  }

  // Lấy tất cả người dùng từ Firestore
  Future<void> _fetchAllUsers() async {
    var querySnapshot = await FirebaseFirestore.instance.collection('Users').get();
    List<Map<String, dynamic>> users = [];
    for (var doc in querySnapshot.docs) {
      users.add({
        'name': doc['name'],
        'userId': doc.id, // Lưu trữ userId
        'avatarUrl': doc['avatarUrl'] ?? 'https://via.placeholder.com/150', // Dự phòng avatar nếu không có
      });
    }

    setState(() {
      _userNames = users;
      _filteredUserNames = users;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tìm kiếm người dùng'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    onChanged: (query) => _searchUser(query),  // Gọi hàm khi người dùng nhập
                    decoration: const InputDecoration(
                      labelText: 'Tìm kiếm người dùng',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    // Khi nhấn nút tìm kiếm, sẽ gọi _searchUser với giá trị trong _controller
                    _searchUser(_controller.text);
                  },
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: _filteredUserNames.isEmpty
                  ? const Center(child: Text('Không có kết quả'))
                  : ListView.builder(
                      itemCount: _filteredUserNames.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          leading: CircleAvatar(
                            radius: 25,
                            backgroundImage: NetworkImage(_filteredUserNames[index]['avatarUrl']), // Hiển thị ảnh đại diện
                          ),
                          title: Text(_filteredUserNames[index]['name']),
                          onTap: () {
                            // Điều hướng đến trang ProfileScreen của người được chọn
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProfileScreen(
                                  currentUserId: widget.currentUserId,  // Truyền currentUserId vào ProfileScreen
                                  profileUserId: _filteredUserNames[index]['userId'],  // Truyền userId của người được chọn
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
